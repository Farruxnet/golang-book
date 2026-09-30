# Working with channels in Go

A channel is a means of passing values of a certain type between goroutines. It is used not only for sending data but also for synchronizing the work of goroutines with each other.

Put simply, one goroutine sends a value to a channel, and another goroutine receives that value.

For example, suppose several goroutines are fetching data from different external APIs. Each goroutine could write its result into a shared `map`. But if several goroutines write to one `map` at the same time, separate synchronization is needed.

Instead, each goroutine can send its result through a channel to a single collecting goroutine. Then the need for several goroutines to write to shared data at the same time decreases.

There is an important subtlety here. Values with reference properties, such as pointers, slices or maps, can also be sent through a channel. The channel synchronizes the sending and receiving of such a value.

But the channel does not automatically protect the data inside the sent object.

For example, a pointer to an object was sent through a channel. If afterwards both the sending goroutine and the receiving goroutine change that object at the same time, a `data race` can occur.

So:

* a channel synchronizes passing a value;
* but it does not automatically protect later concurrent mutation of the sent object.

## Creating a channel

A channel type is written with the `chan` keyword and the type of the elements passed through the channel:

```go
var ch chan int
```

Here the type of the variable `ch` is `chan int`.

This means `int` values are sent and received through the channel.

But the code above does not yet create a working channel. The value of `ch` is `nil`.

A channel used in practice is usually created with `make`:

```go
ch := make(chan int)
```

This code creates an unbuffered channel that works with `int` values.

`chan int` accepts only `int` values. For example, the following code leads to a compile-time error:

```go
ch := make(chan int)

// ch <- "hello" // compile error
```

The reason is that the value `"hello"` is of type `string`, while the channel expects `int` values.

So channels are type-safe. Only values of the specified type are sent.

There is no need to import any special package to create a channel. `make` is a built-in function of the Go language.

## Sending and receiving

The `<-` operator is used when working with channels.

Sending a value:

```go
ch <- value
```

Here `value` is sent to the `ch` channel.

Receiving a value:

```go
value := <-ch
```

Here a value is taken from the `ch` channel and written to the `value` variable.

The `<-` symbol shows which direction the value flows.

In the following code:

```go
ch <- value
```

the value goes from `value` toward the channel.

And in the following code:

```go
value := <-ch
```

the value comes from the channel toward `value`.

Send and receive operations can be blocking.

Especially in an unbuffered channel, send and receive wait for each other.

For example, a goroutine reached the following line:

```go
ch <- 10
```

If at that moment no goroutine is ready to take a value from `ch`, the sending goroutine waits on this line.

In the same way, when the line:

```go
value := <-ch
```

runs and no one has sent a value yet, the receiving goroutine waits.

In an unbuffered channel the value is passed when the send and the receive meet at one point. After that both goroutines can continue.

That is why a channel does not only pass data. It also creates synchronization between goroutines.

## The first example

In the following example a separate goroutine computes the square of a number and sends the result through a channel to the `main` goroutine:

```go
package main

import "fmt"

func square(number int, results chan<- int) {
	results <- number * number
}

func main() {
	results := make(chan int)

	go square(6, results)
	value := <-results

	fmt.Println("Result:", value)
}
```

Output:

```text
Result: 36
```

Let's see step by step how the code works.

First a channel is created inside `main`:

```go
results := make(chan int)
```

This is an unbuffered `int` channel.

Then the `square` function is started in a new goroutine:

```go
go square(6, results)
```

The second parameter of the `square` function is written like this:

```go
results chan<- int
```

`chan<- int` is a channel type that allows only sending values.

That is, the `square` function can send a value to the `results` channel:

```go
results <- number * number
```

But receiving a value through this parameter is not allowed.

The benefit of using a directional channel is that how the function should work with the channel is visible right in the signature.

After `6 * 6` is computed, the value `36` is sent to the channel.

At this time the `main` goroutine is waiting on the following line:

```go
value := <-results
```

`main` does not continue until a value arrives in the channel.

When the `square` goroutine reaches the send, the send and the receive meet:

```text
square goroutine:

results <- 36
       |
       | the value is passed
       v
main goroutine:

value := <-results
```

As a result, `value` becomes `36`.

Then:

```go
fmt.Println("Result:", value)
```

prints:

```text
Result: 36
```

In this example a separate `WaitGroup` is not needed.

The reason is that `main` is waiting anyway to take the result from the channel. Receiving the result guarantees that the `square` goroutine has computed the result and got as far as sending it to the channel.

So the channel itself provides the necessary synchronization here.

## Collecting several results

Now let's look at an example where several goroutines run at the same time.

The following program computes squares for three numbers. Each calculation runs in a separate goroutine.

The results are sent to one channel:

```go
package main

import (
	"fmt"
	"sync"
)

type result struct {
	number int
	square int
}

func calculate(number int, results chan<- result, wg *sync.WaitGroup) {
	defer wg.Done()

	results <- result{
		number: number,
		square: number * number,
	}
}

func main() {
	numbers := []int{2, 3, 4}
	results := make(chan result)

	var wg sync.WaitGroup

	for _, number := range numbers {
		wg.Add(1)
		go calculate(number, results, &wg)
	}

	go func() {
		wg.Wait()
		close(results)
	}()

	values := make(map[int]int, len(numbers))

	for item := range results {
		values[item.number] = item.square
	}

	for _, number := range numbers {
		fmt.Printf("Square of %d: %d\n", number, values[number])
	}
}
```

Output:

```text
Square of 2: 4
Square of 3: 9
Square of 4: 16
```

First a `result` struct representing a result is created:

```go
type result struct {
	number int
	square int
}
```

Each result stores two pieces of data:

* which number was computed;
* what its square equals.

For example:

```go
result{
	number: 3,
	square: 9,
}
```

The `calculate` function takes one number:

```go
func calculate(number int, results chan<- result, wg *sync.WaitGroup)
```

`results chan<- result` says this function only sends `result` values to the channel.

`wg *sync.WaitGroup` is used to tell `main` that the work has finished.

At the start of the function we wrote:

```go
defer wg.Done()
```

This guarantees that `wg.Done()` is called when the `calculate` function finishes.

Then the result is computed and sent to the channel:

```go
results <- result{
	number: number,
	square: number * number,
}
```

Inside `main` there are three numbers:

```go
numbers := []int{2, 3, 4}
```

The loop starts a goroutine for each:

```go
for _, number := range numbers {
	wg.Add(1)
	go calculate(number, results, &wg)
}
```

Before each goroutine starts:

```go
wg.Add(1)
```

is called.

So the `WaitGroup` waits for three jobs to finish.

An important question comes up here: who closes the `results` channel, and when?

The channel must be closed after all workers have finished.

That is why a separate goroutine is created:

```go
go func() {
	wg.Wait()
	close(results)
}()
```

This goroutine:

1. waits for all `calculate` goroutines to finish;
2. then closes the `results` channel.

Meanwhile the main `main` goroutine receives the results:

```go
for item := range results {
	values[item.number] = item.square
}
```

`range` keeps running until the channel is closed and all values in it have been taken.

For example, the results may arrive at the channel in the following order:

```text
4 -> 16
2 -> 4
3 -> 9
```

or:

```text
3 -> 9
4 -> 16
2 -> 4
```

There is no guarantee which of the goroutines finishes first.

That is why the results are collected into a `map`:

```go
values[item.number] = item.square
```

Then the order of the `numbers` slice is used when printing:

```go
for _, number := range numbers {
	fmt.Printf("Square of %d: %d\n", number, values[number])
}
```

That is why, even though the results arrived at the channel in different orders, the output on the screen always comes out in the following order:

```text
Square of 2: 4
Square of 3: 9
Square of 4: 16
```

There is also a very important deadlock situation in this example.

If it had been written like this:

```go
wg.Wait()

for item := range results {
	// ...
}
```

a problem could have occurred.

Let's look at the reason step by step.

`results` is an unbuffered channel:

```go
results := make(chan result)
```

Each worker tries to send a value on the line:

```go
results <- result{...}
```

But in an unbuffered channel a send needs a receiver at the same time in order to work.

If `main` first does:

```go
wg.Wait()
```

it does not start receiving the results yet.

Then the situation is as follows:

```text
worker goroutines:
    results <- ...
    waiting for a receiver

main:
    wg.Wait()
    waiting for the workers to finish
```

Because the workers cannot send their values, they never reach `Done()`.

And `main` waits for the workers to call `Done()`.

As a result, they end up waiting for each other.

That is why `wg.Wait()` and `close(results)` are done in a separate goroutine.

At the same time, `main` keeps receiving values through `range`.

## Closing a channel

A channel can be closed like this:

```go
close(ch)
```

The meaning of `close(ch)`:

> No more new values will be sent through this channel.

Closing a channel does not delete it from memory.

Also, `close` is not a command telling receiving goroutines to "stop".

It only says there will be no more sends to the channel.

A channel is usually closed by the side that produces the values.

For example:

```text
producer -> channel -> consumer
```

In this case the producer knows it will not send any more values. That is why the responsibility for closing the channel usually lies with the producer.

If there are several producers:

```text
producer 1 \
producer 2  -> channel -> consumer
producer 3 /
```

a separate coordinating goroutine can wait for all of them to finish and then close the channel.

In the previous example:

```go
go func() {
	wg.Wait()
	close(results)
}()
```

did exactly this job.

A consumer usually should not close the channel.

The reason is that the consumer does not always know whether other producers will still send values.

If the consumer closes the channel early and a producer later does:

```go
ch <- value
```

the program panics.

There are several important rules for working with a closed channel.

### Values left in the buffer are still received

If a buffered channel is closed, the values in it are not lost.

For example:

```go
ch := make(chan int, 2)

ch <- 10
ch <- 20
close(ch)
```

Even though the channel is closed:

```go
fmt.Println(<-ch)
fmt.Println(<-ch)
```

first gives the values:

```text
10
20
```

### After the values run out, the zero value is returned

If the channel is closed and no other values are left in it, a receive does not block.

It immediately returns the `zero value` of the element type.

For example, for `chan int` the zero value is:

```text
0
```

For `chan string`:

```text
""
```

For `chan bool`:

```text
false
```

### Sending to a closed channel panics

The following code is wrong:

```go
ch := make(chan int)
close(ch)

ch <- 10
```

`ch` is already closed. Sending another value to it causes a runtime panic.

### Closing a channel a second time panics

The following code is also wrong:

```go
ch := make(chan int)

close(ch)
close(ch)
```

A channel can be closed only once.

The second `close(ch)` causes a panic.

### Closing a `nil` channel panics

For example:

```go
var ch chan int

close(ch)
```

Here `ch == nil`.

Trying to close a `nil` channel causes a panic.

### How can you tell a channel is closed?

The problem is that a closed channel returns the zero value on a receive operation.

For example:

```go
value := <-ch
```

Imagine `value == 0` came out.

This can mean one of two things:

1. `0` was really sent through the channel;
2. the channel is closed and the values have run out.

To tell these two cases apart, the two-value receive is used:

```go
value, ok := <-ch
```

For example:

```go
value, ok := <-ch
if !ok {
	// The channel is closed and has no more values.
}
```

Here `ok` reports the state of the channel.

If:

```text
ok == true
```

then `value` is a real channel value.

If:

```text
ok == false
```

then the channel is closed and there are no more values to take from it.

In this case `value` is the zero value of the element type.

For example, the result of:

```go
value, ok := <-ch
```

may be:

```text
value = 0
ok = false
```

That is why checking only:

```go
if value == 0 {
	// the channel is closed
}
```

is wrong.

Because `0` may also have been sent as real data.

## Receiving with `range`

`range` is very convenient for taking values from a channel one after another:

```go
for value := range ch {
	fmt.Println(value)
}
```

This loop receives the values that came through the channel one by one.

For example, if we have:

```go
ch <- 10
ch <- 20
ch <- 30
close(ch)
```

`range` takes the values:

```text
10
20
30
```

When the channel is closed and all values in it have run out, the loop finishes automatically.

This is actually similar to a more convenient form of a loop written with `value, ok := <-ch`.

Logically it is close to:

```go
for {
	value, ok := <-ch
	if !ok {
		break
	}

	fmt.Println(value)
}
```

There is an important subtlety here.

If the channel used with `range` is not closed, the loop may keep waiting for the next value.

For example:

```go
for value := range ch {
	fmt.Println(value)
}
```

all values were sent to the channel, but `close(ch)` was not called.

The loop does not get the signal "there will be no more values". That is why it gets stuck waiting on the next receive.

But this does not lead to the rule "every channel must always be closed".

A channel needs to be closed only when the receiver must know that the stream has ended.

For example, if the channel is a permanent event stream used throughout the program, it may not need to be closed at any particular point.

## `nil` channel

The zero value of a channel type is `nil`.

For example:

```go
var ch chan int
```

Here:

```go
ch == nil
```

holds.

A `nil` channel is not a working but empty channel.

These two situations should not be confused.

The following channel is a real channel:

```go
ch := make(chan int)
```

Even though there is no value in it right now, if another goroutine appears and sends or receives, the operation can proceed.

But in a `nil` channel created with:

```go
var ch chan int
```

send and receive block forever.

For example:

```go
var ch chan int

ch <- 10
```

This send never completes successfully.

Because on the other side of a `nil` channel there is no real channel structure where a receive could work.

In the same way:

```go
var ch chan int

value := <-ch
```

the receive also blocks forever.

A wrong example:

```go
// Wrong example: never continues.
// var ch chan int
// ch <- 10
```

This behavior is sometimes used on purpose.

For example, inside a `select` a channel variable can be set to `nil` to temporarily disable a certain case.

The reason is that a send or receive on a `nil` channel never becomes ready.

This technique is covered in detail in the `select` topic.

## Channels and memory synchronization

One of the important jobs of a channel is synchronizing memory visibility.

In simple terms, if one goroutine wrote some data before a send and another goroutine performs the matching receive, then after the receive completes it can see the earlier writes.

For example:

```go
data := 0
ch := make(chan struct{})

go func() {
	data = 42
	ch <- struct{}{}
}()

<-ch
fmt.Println(data)
```

Here the worker first does:

```go
data = 42
```

Then it sends a signal through:

```go
ch <- struct{}{}
```

And `main` receives the signal with:

```go
<-ch
```

Because of the synchronization that happened through the channel, after the receive completes, the worker's writes before the send become visible on the receiving side.

Here `42` itself was not sent through the channel. Only a signal was sent.

Even so, the send and receive create the necessary synchronization point between the goroutines.

But this does not lead to the conclusion that two goroutines can later change one object at the same time.

For example:

```go
items := []int{1, 2, 3}
ch := make(chan []int)

go func() {
	ch <- items
}()
```

A slice was sent through the channel.

But a slice does not deep-copy its whole backing array. The sender and receiver may refer to the same backing array.

If afterwards both goroutines at the same time do a write like:

```go
items[0] = ...
```

a `data race` can occur.

That is why the following approach is useful as a practical rule:

> After a value is sent through a channel, hand its ownership over to the receiver.

That is, after sending, the sender should not change that mutable data again.

If the data must be shared by several goroutines, concurrent mutation must be protected with a `mutex` or another suitable synchronization tool.

## A situation leading to deadlock

In the following program an unbuffered channel is created:

```go
package main

func main() {
	ch := make(chan int)
	ch <- 10
}
```

The code compiles.

But at runtime the program cannot continue.

The runtime usually prints a message like:

```text
fatal error: all goroutines are asleep - deadlock!
```

Let's look at the reason step by step.

First a channel is created:

```go
ch := make(chan int)
```

This is an unbuffered channel.

Then:

```go
ch <- 10
```

runs.

A send on an unbuffered channel needs a receive on the other side.

For example:

```go
value := <-ch
```

But there is no other goroutine in the program.

`main` itself is blocked on the send line.

The situation is as follows:

```text
main goroutine:
    ch <- 10
    |
    +-- waiting for a receiver

other runnable goroutines:
    none
```

Because there is no other goroutine left in the program that can continue, the Go runtime detects a deadlock.

But you should not think you will definitely see this message in every deadlock situation.

For example, in a real server some goroutines may be waiting on:

* a network socket;
* a timer;
* external I/O;
* another runtime event.

Even if the program is logically stuck somewhere, the runtime may not consider all goroutines to be completely asleep.

That is why a logical deadlock does not always immediately lead to the message:

```text
fatal error: all goroutines are asleep - deadlock!
```

## Common mistakes

### The wrong side closing the channel

Who closes a channel must be clear in advance.

Usually the channel is closed by the side sending the values.

If the receiver closes the channel itself, another sender may still be running.

For example:

```text
sender 1 ----\
sender 2 -----> channel ---> receiver
sender 3 ----/
```

Imagine the receiver closed the channel.

At this time `sender 3` may not yet have managed to do:

```go
ch <- value
```

If a sender sends a value after the channel is closed, a panic occurs.

That is why it is best to keep the closing responsibility on the side of:

* the single sender;
* or a coordinator that knows all senders have finished.

### Forcibly closing every channel

Beginners sometimes think that after every `make(chan T)` there must be a `close` somewhere.

This is not correct.

A channel does not need to be closed to free memory.

The garbage collector can collect an unused channel and the memory belonging to it.

The main job of `close` is different:

> To tell the receiver that no more new values will come.

For example, `close` may be needed to signal the end of a stream to a `for range`.

But if the channel was used only to send a signal once and no one accesses it afterwards, closing it separately is not always necessary.

### Endlessly receiving from a closed channel

An ordinary receive from a closed channel does not block.

For example:

```go
ch := make(chan int)
close(ch)

fmt.Println(<-ch)
fmt.Println(<-ch)
fmt.Println(<-ch)
```

These receives keep returning the zero value of `chan int`:

```text
0
0
0
```

That is why, if you need to know that the stream has ended:

```go
value, ok := <-ch
```

is used.

Or you can use:

```go
for value := range ch {
	// ...
}
```

`range` finishes automatically when the channel is closed and all values have run out.

### Thinking a channel eliminates data races completely

Using a channel does not automatically make a program free of `data race`s.

For example:

```go
type User struct {
	Name string
}
```

A pointer was sent through a channel:

```go
users := make(chan *User)
```

The pointer itself can be safely passed from one goroutine to another.

But if afterwards the sender and receiver at the same time do:

```go
user.Name = ...
```

they are changing the same `User` object.

The channel does not automatically protect these later writes.

The same thing matters for slices and maps.

For example, when a slice is sent, the slice header may be copied, but its backing array remains shared.

And a map works through a reference to its internal data structure.

That is why it helps to think about ownership when working with channels:

```text
sender -- sends the value --> receiver
sender -- no longer changes it
receiver -- becomes the owner of the value
```

If ownership cannot be handed over and the data stays shared, concurrent mutation must be synchronized separately.

## What do interviews focus on?

In interview questions about channels, knowing only the syntax is not enough. It is also important to understand their blocking and synchronization behavior.

Pay attention to the following:

* in an unbuffered channel, send and receive can wait for each other;
* besides passing values, a channel also creates synchronization between goroutines;
* `ch <- value` sends a value;
* `<-ch` receives a value;
* `chan<- T` is a channel type that allows only sending;
* sending to a closed channel causes a panic;
* receiving from a closed channel first gives the remaining values;
* after the values run out, a receive returns the zero value of the element type;
* `value, ok := <-ch` lets you tell a real value apart from the channel being closed;
* `ok == false` means the channel is closed and no other values remain in it;
* a channel is usually closed by the sender or by a coordinator that knows all senders have finished;
* both send and receive on a `nil` channel block forever;
* a `nil` channel and a channel created with `make` that is currently empty are not the same;
* sending a pointer, slice or map through a channel does not automatically protect the inner data;
* if a sent mutable object is later changed in parallel by several goroutines, a `data race` can occur;
* when working with channels it must be clear in advance who sends, who receives, who closes and when the receiver stops.

The next important part of channels is the difference between unbuffered and buffered channels. A channel can also be restricted to only sending or only receiving. These features directly affect how traffic and synchronization between goroutines work.
