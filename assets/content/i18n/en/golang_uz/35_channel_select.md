# The `select` statement

`select` chooses, among several channel operations, one that is ready to run at the moment.

An ordinary channel operation waits for only one send or receive. `select` lets you watch several channels at the same time.

For example, a backend service may wait for the following two events at the same time:

* a result arriving from an external API;
* the user cancelling the request.

Whichever event becomes ready first, `select` runs the code belonging to that case.

That is why `select` is usually used:

* when waiting for results coming from several goroutines;
* for setting a timeout, that is, a time limit;
* for watching a cancellation signal through `context`;
* for choosing the one that is ready among several channels.

## Basic syntax

On the outside `select` looks like `switch`. But its `case`s wait not for ordinary conditions but for channel operations:

```go
select {
case msg := <-messages:
	fmt.Println("Received:", msg)
case results <- value:
	fmt.Println("Result sent")
default:
	fmt.Println("No channel is ready yet")
}
```

There are three options here.

The first `case`:

```go
case msg := <-messages:
```

tries to receive a value from the `messages` channel.

The second `case`:

```go
case results <- value:
```

tries to send `value` to the `results` channel.

And `default` runs if no channel operation is ready to run right now.

When a `select` runs, the following rules apply:

* if only one `case` is ready, exactly that `case` runs;
* if several `case`s are ready at the same time, Go picks one of them pseudo-randomly;
* if no `case` is ready and there is no `default`, the current goroutine blocks;
* if no `case` is ready and there is a `default`, `default` runs immediately.

There is an important rule here: the order of `case`s in the code does not give them priority.

For example:

```go
select {
case value := <-first:
	fmt.Println(value)
case value := <-second:
	fmt.Println(value)
}
```

if both `first` and `second` are ready to receive, `first` is not chosen automatically just because it is written above.

`select` does not go from top to bottom and pick the first ready `case`. If several operations are ready, one of them is chosen.

## The first working example

In the following example two goroutines send results at different times:

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	fast := make(chan string)
	slow := make(chan string)

	go func() {
		time.Sleep(100 * time.Millisecond)
		fast <- "fast result"
	}()

	go func() {
		time.Sleep(200 * time.Millisecond)
		slow <- "slow result"
	}()

	select {
	case value := <-fast:
		fmt.Println(value)
	case value := <-slow:
		fmt.Println(value)
	}
}
```

The usual output:

```text
fast result
```

Let's go through the process step by step.

First two unbuffered channels are created:

```go
fast := make(chan string)
slow := make(chan string)
```

Then the first goroutine starts:

```go
go func() {
	time.Sleep(100 * time.Millisecond)
	fast <- "fast result"
}()
```

It waits about 100 milliseconds and wants to send a value to the `fast` channel.

The second goroutine:

```go
go func() {
	time.Sleep(200 * time.Millisecond)
	slow <- "slow result"
}()
```

sends a value to the `slow` channel after about 200 milliseconds.

And the `main` goroutine reaches the following `select`:

```go
select {
case value := <-fast:
	fmt.Println(value)
case value := <-slow:
	fmt.Println(value)
}
```

If no value has arrived yet at this point, `select` blocks. It waits for either of the two channels to become ready for receiving.

After about 100 milliseconds a send operation appears on the `fast` channel. That is why:

```go
case value := <-fast:
```

becomes ready to run and `select` chooses this `case`.

Both channels are unbuffered. In an unbuffered channel the sender and the receiver must match each other. The sender cannot just drop the value into the channel and continue. It waits for the receiver to be ready.

In this example the sleep times are deliberately different. That is why `fast` is usually chosen first.

But remember the following: if both channel operations become ready at the same time, you cannot predict which `case` will be chosen from the order in the code.

There is another important point. Here the `select` runs only once.

Once a value is taken from `fast`, the `select` finishes and the `main` function ends. When `main` finishes, Go does not wait for other goroutines to finish too.

That is why the program does not receive the second result from the `slow` channel.

## Receiving several results

If both results are needed, running `select` once is not enough.

It can be repeated as many times as needed:

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	first := make(chan string)
	second := make(chan string)

	go func() {
		time.Sleep(100 * time.Millisecond)
		first <- "first channel"
	}()

	go func() {
		time.Sleep(200 * time.Millisecond)
		second <- "second channel"
	}()

	for i := 0; i < 2; i++ {
		select {
		case value := <-first:
			fmt.Println(value)
		case value := <-second:
			fmt.Println(value)
		}
	}
}
```

Output:

```text
first channel
second channel
```

The main difference here is in the loop:

```go
for i := 0; i < 2; i++ {
```

The `select` runs twice.

On the first iteration `first` becomes ready after about 100 milliseconds, and the value:

```text
first channel
```

is taken.

After that the loop runs a second time. The `select` again waits for one of the channels to become ready.

This time the value:

```text
second channel
```

is taken from the remaining `second` channel.

So `select` itself does not collect all ready results at once. Each time it runs, at most one `case` is chosen.

If the number of results is known in advance, you can count them as in this example.

But if the number of results is unknown in advance, you usually need to watch for the channel being closed. In such a situation the `value, ok := <-ch` form helps. We will see this later in the section on closed channels.

## What is blocking?

When working with channels, it is important to clearly understand the concept of `blocking`.

If a goroutine is left waiting for the conditions needed to perform an operation, it is considered blocked.

In an unbuffered channel, sending and receiving must match each other.

For a send:

```go
ch <- value
```

to run, a receiver must exist.

For a receive:

```go
value := <-ch
```

to run, a sender must exist.

Otherwise the goroutine performing the operation waits.

In the following code the `main` goroutine wants to send a value to an unbuffered channel:

```go
package main

func main() {
	ch := make(chan int)
	ch <- 10 // There is no receiver, so the runtime detects a deadlock.
}
```

This is a deliberately wrong example.

The process is as follows:

1. An unbuffered channel named `ch` is created.
2. The `main` goroutine reaches sending the value `10`.
3. But no other goroutine is receiving from `ch`.
4. That is why `main` blocks right on this line.
5. There is no other goroutine that can run either.
6. The Go runtime detects that the program cannot continue.

As a result the program usually ends with the following error:

```text
fatal error: all goroutines are asleep - deadlock!
```

The problem can be solved in several ways.

For example, a receiving goroutine can be started:

```go
go func() {
	<-ch
}()
```

Or, if it suits the task, the channel can be given a buffer.

But adding a buffer is not a universal solution for every deadlock. The right solution depends on where the data comes from, who receives it and how the goroutines are synchronized.

## A non-blocking channel operation

Sometimes, if a channel is not ready, there is no need to wait. The program should carry on with other work.

In such a case `default` inside `select` can be used:

```go
package main

import "fmt"

func main() {
	ch := make(chan int, 1)

	select {
	case value := <-ch:
		fmt.Println("Received:", value)
	default:
		fmt.Println("No value in the channel")
	}
}
```

Output:

```text
No value in the channel
```

Here the channel is buffered:

```go
ch := make(chan int, 1)
```

but no value has been written into it.

That is why:

```go
case value := <-ch:
```

is not ready to run right now.

Without `default`, the `select` would block waiting for a value to arrive.

But here:

```go
default:
	fmt.Println("No value in the channel")
```

is present. That is why the `select` does not wait and `default` runs immediately.

This approach is called a `non-blocking` channel operation. That is, even if the channel is not ready, the program does not get stuck waiting at this point.

This technique can be useful, for example, for telemetry, statistics or a signal that may be dropped.

But you must be careful with important data.

For example, code of the form:

```go
select {
case jobs <- job:
	// sent
default:
	// not sent
}
```

lets the producer continue without waiting. If the `jobs` channel is not ready, the `job` is dropped.

If this is an important business task, such behavior can lead to data loss.

`default` also affects backpressure.

Backpressure is when the producer naturally slows down or waits because the consumer cannot keep up with the producer's speed.

If we make sending always non-blocking through `default`, we may bypass this natural waiting mechanism.

**Warning**

If a `for` loop contains only `select` and `default`, there may be no blocking operation at all. As a result the loop spins over and over very fast. This situation is called a **busy loop** and can waste CPU time.

For example:

```go
for {
    select {
    default:
    }
}
```

This loop does not wait for anything. It keeps spinning as fast as possible.

## Time limits

Waiting forever for a response from an external service or for a long computation is often not a good solution.

For example, if an external API stops responding, the whole request handler may wait for a long time.

By adding a timer channel to `select`, you can give an operation a time limit:

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	result := make(chan string, 1)

	go func() {
		time.Sleep(200 * time.Millisecond)
		result <- "ready"
	}()

	timer := time.NewTimer(100 * time.Millisecond)
	defer timer.Stop()

	select {
	case value := <-result:
		fmt.Println(value)
	case <-timer.C:
		fmt.Println("time is up")
	}
}
```

Output:

```text
time is up
```

Let's go through this code step by step.

First a channel is created for the result:

```go
result := make(chan string, 1)
```

Its capacity is `1`. So one value can be placed in the buffer.

Then a goroutine starts:

```go
go func() {
	time.Sleep(200 * time.Millisecond)
	result <- "ready"
}()
```

This goroutine sends the result after 200 milliseconds.

But the timeout is set to 100 milliseconds:

```go
timer := time.NewTimer(100 * time.Millisecond)
```

`timer.C` is a channel that sends a value when the time is up.

And the `select` waits for two events:

```go
select {
case value := <-result:
	fmt.Println(value)
case <-timer.C:
	fmt.Println("time is up")
}
```

After about 100 milliseconds the timer becomes ready first.

That is why:

```go
case <-timer.C:
```

is chosen and:

```text
time is up
```

is printed.

In this example pay special attention to the fact that the `result` channel is buffered.

If it had been unbuffered:

```go
result := make(chan string)
```

after `main` left the `select` because of the timeout, the worker goroutine could reach the line:

```go
result <- "ready"
```

But then there would be no goroutine left to receive from `result`. Because of the unbuffered channel, the sender could get stuck here.

A buffer with capacity `1` lets the worker put the value in and finish its work.

This shows a very important property of timeouts:

> a timeout stops the waiting, but does not automatically cancel the running goroutine.

If the computation itself must also be stopped, `context` or a separate cancellation signal is usually used.

For one simple wait, `time.After` can also be used:

```go
select {
case value := <-result:
	fmt.Println(value)
case <-time.After(100 * time.Millisecond):
	fmt.Println("time is up")
}
```

This is short and easy to read.

But in a long-running loop, creating a new `time.After` on every iteration creates new timer objects.

If you need to manage the timer's lifecycle more precisely, it may be better to use `time.NewTimer` and `Reset` it when needed.

And if a periodic signal is needed, `time.NewTicker` is used.

## Cancellation through `context`

In real backend code, just waiting for a timeout is not enough.

Often the running operation must also be cancelled.

In Go such a signal is usually passed through `context.Context`.

The:

```go
ctx.Done()
```

method of a `Context` returns a channel that is closed on cancellation or when the deadline passes.

Once the channel is closed, receiving from it is immediately ready. That is why waiting on `ctx.Done()` inside `select` is very convenient.

Creating a `Context`, timeouts, deadlines and the rules of `cancel()` are explained in detail in the `context` basics lesson.

In the following example the worker performs steps periodically, but stops the work if the `context` is cancelled:

```go
package main

import (
	"context"
	"fmt"
	"time"
)

func work(ctx context.Context) error {
	ticker := time.NewTicker(20 * time.Millisecond)
	defer ticker.Stop()

	for step := 1; step <= 10; step++ {
		select {
		case <-ctx.Done():
			return ctx.Err()
		case <-ticker.C:
			fmt.Println("step:", step)
		}
	}

	return nil
}

func main() {
	ctx, cancel := context.WithTimeout(context.Background(), 50*time.Millisecond)
	defer cancel()

	if err := work(ctx); err != nil {
		fmt.Println("the work stopped:", err)
	}
}
```

In this code:

```go
ticker := time.NewTicker(20 * time.Millisecond)
```

gives a signal roughly every 20 milliseconds.

The worker loop:

```go
for step := 1; step <= 10; step++ {
```

tries to perform at most 10 steps.

On each iteration the `select` waits for two events:

```go
case <-ctx.Done():
```

or:

```go
case <-ticker.C:
```

If the ticker is ready first:

```go
fmt.Println("step:", step)
```

runs.

In `main` a 50-millisecond timeout is given for the context:

```go
ctx, cancel := context.WithTimeout(
	context.Background(),
	50*time.Millisecond,
)
```

After about 50 milliseconds the deadline passes and `ctx.Done()` is closed.

After that:

```go
case <-ctx.Done():
	return ctx.Err()
```

may run.

`ctx.Err()` in this case returns the error:

```text
context deadline exceeded
```

That is why the final line looks like:

```text
the work stopped: context deadline exceeded
```

How many:

```text
step: ...
```

lines are printed before it may depend on the scheduler and on when the timers actually fire. That is why you should not rely on an exact number of steps.

This pattern is very common in real programs.

For example:

* when an HTTP request is cancelled by the client;
* when a database query exceeds its deadline;
* when several goroutines must be stopped through one shared signal;
* when managing workers during server shutdown.

The main rule here is that a worker should not just accept a `context` and ignore it. It should watch `ctx.Done()` in the necessary places or pass the context on to context-aware APIs.

## Closed and `nil` channels

When working with `select`, the difference between a closed channel and a `nil` channel is very important.

They behave almost oppositely:

* receiving from a closed channel does not block;
* receiving from a `nil` channel blocks.

Let's look at a closed channel first.

After a channel is closed, the values remaining in its buffer are read first. Once the buffer runs out, receiving from it again returns the zero value of the channel's element type.

To check whether a channel is really closed, the two-value receive is used:

```go
value, ok := <-ch
if !ok {
	// The channel is closed.
}
```

Here:

* `value` — the value taken;
* `ok` — reports whether the receive produced a real value.

If:

```go
ok == false
```

then the channel is closed and no other values remain in its buffer.

This check is especially important for types with a zero value such as `int`, `bool`, pointers and others.

For example, for an `int` channel the value after closing is:

```go
0
```

But `0` can also be real business data. If we don't check `ok`, we may take the zero value coming from a closed channel as real data.

Now let's look at the problem in `select`.

Because receiving from a closed channel does not block, its `case` is always ready.

If we read several channels in a loop, a closed channel may keep getting picked by `select` over and over.

To stop this, the channel variable can be set to `nil`.

Both sending to and receiving from a `nil` channel block forever in the ordinary case. Inside `select`, however, a `case` belonging to such a channel is never chosen.

The following example shows this technique:

```go
package main

import "fmt"

func main() {
	left := make(chan int, 1)
	right := make(chan int, 1)

	left <- 10
	right <- 20

	close(left)
	close(right)

	for left != nil || right != nil {
		select {
		case value, ok := <-left:
			if !ok {
				left = nil
				continue
			}
			fmt.Println("left:", value)

		case value, ok := <-right:
			if !ok {
				right = nil
				continue
			}
			fmt.Println("right:", value)
		}
	}
}
```

The order of the output lines may change:

```text
left: 10
right: 20
```

First one value is written into each of the two buffered channels:

```go
left <- 10
right <- 20
```

Then both are closed:

```go
close(left)
close(right)
```

Closing a channel does not destroy the buffered values already in it.

That is why you can still take `10` from `left` and `20` from `right`.

The loop continues like this:

```go
for left != nil || right != nil {
```

As long as at least one channel is active, the loop runs.

When a channel's values run out and its closed state is detected:

```go
if !ok {
	left = nil
	continue
}
```

the variable is set to `nil`.

After that:

```go
case value, ok := <-left:
```

is practically disabled, because `left` is now `nil`.

The same process happens for `right`.

Once both are:

```go
left == nil
right == nil
```

the loop condition becomes false and the loop ends.

If we did not switch a closed channel to `nil`, its receive `case` would stay ready forever. As a result the `select` could choose it again and again and return the zero value.

This is a very useful pattern for dynamically managing several channels with `select`.

## An empty `select`

In Go the following code is also valid syntax:

```go
select {}
```

In this `select` there is:

* no `case`;
* no `default`.

So there is no operation that could become ready to run.

As a result the current goroutine blocks forever.

For example:

```go
func main() {
	select {}
}
```

The `main` goroutine stays here without finishing.

Sometimes you may see such code used to start background goroutines and artificially keep `main` alive.

But in a practical program this is often not the best way to manage things.

The reason is that `select {}` knows nothing about the state of the background goroutines.

For example:

* a worker may have finished with an error;
* all goroutines may already have stopped working;
* the server may need to shut down.

But `main` still waits forever.

That is why it is usually clearer to manage the lifecycle of goroutines with:

* `sync.WaitGroup`;
* channels;
* `context`.

These tools help not only with waiting, but also with managing when and why the work ends.

## Common mistakes

Even though the syntax of `select` looks simple, it is easy to misunderstand its behavior.

The following mistakes are especially common.

### Thinking `select` runs all ready `case`s

This is wrong.

When a `select` runs once, it chooses at most one `case`.

For example, even if three channels are ready at the same time:

```go
select {
case <-a:
case <-b:
case <-c:
}
```

only one runs.

If all results need to be taken, `select` is usually used inside a loop.

### Assuming the top `case` has priority

This is also wrong.

In the following code:

```go
select {
case <-first:
case <-second:
}
```

`first` has no priority just because it is written above.

If both operations are ready, Go chooses one of the ready operations.

Code order does not work as priority.

If an exact priority is needed, it must be expressed with separate control logic.

### Not checking the `ok` value on a closed channel

The following receive:

```go
value := <-ch
```

does not itself show that the channel is closed.

If the channel is closed and the buffer is empty, `value` gets the zero value of the element type.

That is why, where closing matters, the form:

```go
value, ok := <-ch
```

should be used.

Otherwise the zero value may be taken as real data.

### Using `default` everywhere

`default` removes blocking.

This is very useful in some situations. But automatically adding it to every `select` is not a good idea.

For example:

```go
select {
case jobs <- job:
default:
}
```

lets the producer not wait for the consumer.

This can lead to losing natural backpressure or to data being dropped.

That is why, when adding `default`, you should ask:

> If the channel is not ready right now, is it really correct to drop this operation or continue without waiting?

### Forgetting the sending goroutine after a timeout

A timeout can only stop the waiting of a `select`.

For example:

```go
select {
case result := <-results:
	fmt.Println(result)
case <-timer.C:
	fmt.Println("timeout")
}
```

once the timeout is chosen, the goroutine producing the result does not stop automatically.

It may later reach the line:

```go
results <- value
```

If the channel is unbuffered and no other receiver is left, the worker may get stuck.

That is why in code with a timeout you must also think about the worker's lifecycle.

Often, for this:

* a buffered result channel;
* `context.Context`;
* a separate cancellation channel

is used.

### Closing a channel on the receiving side

Who closes a channel also matters.

Usually the side that knows for sure no more values will be sent to the channel closes it. Most often this is the producer, that is, the sending side.

For example:

```go
for _, job := range jobs {
	results <- process(job)
}

close(results)
```

Here the producer knows it has sent all the results. That is why it also knows when `results` can be closed.

The consumer, on the other hand, usually may not know whether another producer will still send.

If a value is sent to a closed channel again, a panic occurs.

That is why it is important to clearly define ownership of closing a channel.

## Important points for interviews

In a conversation or interview about `select`, it helps to be able to state the following rules clearly.

* Each time it runs, `select` chooses at most one ready `case`.

* In a `select` without `default`, if no operation is ready, the current goroutine blocks.

* If there is a `default` and the other `case`s are not ready, `default` runs immediately. That is why such a `select` does not block.

* If several `case`s are ready at the same time, the one written higher in the code does not automatically take priority.

* Receiving from a closed channel does not block. Once the buffer runs out, the zero value and `ok == false` are received.

* A `nil` channel, on the other hand, is never ready for sending or receiving. That is why setting a channel to `nil` inside `select` can be used as a way to temporarily disable its `case`.

* `select {}` has no `case` or `default`. That is why it blocks the current goroutine forever.

* A timeout only stops waiting for the result. It does not automatically cancel the goroutine doing the work.

* If the worker itself must also be stopped after a timeout, `context` or a separate cancellation mechanism is needed.
