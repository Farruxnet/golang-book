# Unbuffered, buffered and directional channels

In Go all channels do the same basic job: one goroutine sends a value, and another goroutine receives that value.

But depending on how a channel is created, the way it works differs.

There are three main important cases:

* an **unbuffered channel** — the sender and the receiver wait for each other at the moment the value is exchanged;
* a **buffered channel** — has a limited queue where values are stored temporarily;
* a **directional channel** — defines at the type level whether a function can only send or only receive through the channel.

These differences are not just a matter of syntax. They directly affect when goroutines block, how load is managed and how an API is structured.

## Unbuffered channel

If no capacity is given when creating a channel, an unbuffered channel is created:

```go
ch := make(chan int)
```

Giving the capacity explicitly as `0` produces the same result:

```go
other := make(chan int, 0)
```

So the semantics of the following two channels are the same:

```go
ch := make(chan int)
other := make(chan int, 0)
```

An unbuffered channel has no queue for storing values temporarily.

That is why send and receive are tied directly to each other:

* the sending goroutine waits until a matching receive is ready;
* the receiving goroutine waits until a matching send is ready;
* when both sides are ready, the value is passed.

At this moment synchronization happens between the two goroutines.

In other words, with an unbuffered channel you cannot simply "drop a value into the channel and leave". The value is passed exactly at the moment the other side is ready to receive it.

### Example: signaling that work has finished

In the following example the channel is used not to carry useful data but to report that work has finished.

```go
package main

import "fmt"

func prepare(done chan<- struct{}) {
	fmt.Println("Data prepared")
	done <- struct{}{}
}

func main() {
	done := make(chan struct{})

	go prepare(done)
	<-done

	fmt.Println("The program continued")
}
```

Output:

```text
Data prepared
The program continued
```

Here `done` is an unbuffered channel:

```go
done := make(chan struct{})
```

`prepare` runs inside a separate goroutine:

```go
go prepare(done)
```

And `main` waits on the following line:

```go
<-done
```

This is a receive operation.

But because `done` is unbuffered, `main` blocks here until the signal arrives.

The `prepare` function first runs the line:

```go
fmt.Println("Data prepared")
```

After that it sends a signal through:

```go
done <- struct{}{}
```

`struct{}{}` here does not store any useful data. Its job is only to deliver the signal "the work is finished".

Once the signal is sent, the receive in `main`:

```go
<-done
```

completes and the program continues:

```go
fmt.Println("The program continued")
```

That is why the output first shows:

```text
Data prepared
```

and then:

```text
The program continued
```

An unbuffered channel is especially useful when:

* handing work over to another goroutine and waiting until it has received it;
* signaling that execution has finished;
* waiting until a response arrives;
* creating a precise synchronization point between two goroutines.

### A send without a receiver

To send a value to an unbuffered channel, a receiving side must also exist.

For example:

```go
package main

func main() {
	ch := make(chan int)
	ch <- 10
}
```

This program does not finish successfully.

`ch` is unbuffered:

```go
ch := make(chan int)
```

Then `main` tries to perform the following send:

```go
ch <- 10
```

But nowhere is there:

```go
<-ch
```

or an equivalent receive operation.

That is why `main` blocks on the send.

Because the only goroutine in the program is also blocked, the Go runtime detects a deadlock and the program ends with an error.

The important rule here is:

> A send to an unbuffered channel does not complete until a matching receive is ready.

## Buffered channel

If a channel is given a positive capacity, a buffered channel is created:

```go
ch := make(chan int, 3)
```

Here `3` is the capacity of the channel's buffer.

So the channel can temporarily keep three values in its queue.

In a buffered channel, send and receive work as follows:

* if there is free space in the buffer, a send can complete without waiting for a receiver;
* if the buffer is full, the next send blocks until space frees up;
* if there is a value in the buffer, a receive can take it immediately;
* if the buffer is empty, a receive blocks until a new value arrives.

That is why a buffer decouples the working speeds of the sender and the receiver up to a certain limit.

But this decoupling is not unlimited. Only as many values as the buffer capacity can wait in the queue.

### The smallest example

```go
package main

import "fmt"

func main() {
	ch := make(chan int, 2)

	ch <- 10
	ch <- 20

	fmt.Println(<-ch)
	fmt.Println(<-ch)
}
```

Output:

```text
10
20
```

The channel's capacity is `2`:

```go
ch := make(chan int, 2)
```

The first send:

```go
ch <- 10
```

puts the value into the buffer.

The buffer state:

```text
[10]
```

The next send:

```go
ch <- 20
```

also completes, because there is still one free slot in the buffer.

The buffer state:

```text
[10, 20]
```

Now the buffer is full.

Then the first receive runs:

```go
fmt.Println(<-ch)
```

The channel returns the earliest value:

```text
10
```

The buffer state:

```text
[20]
```

The second receive takes the value:

```text
20
```

Values in a channel are taken in FIFO order.

**FIFO — First In, First Out**, that is, the value that went in first comes out first.

There is a subtle point here.

FIFO applies to the order of values successfully sent to the channel. If several goroutines try to send at the same time, exactly which goroutine completes its send first may depend on the scheduler.

For example, if two goroutines at the same time are doing:

```go
ch <- 10
```

and:

```go
ch <- 20
```

Go does not guarantee that "`10` always goes in first".

But if `10` was successfully sent to the channel first, a receive will not take `20` before it.

The channel keeps the receive order matching the order of successful sends.

If the buffer is full, a new send blocks.

For example:

```go
// ch := make(chan int, 2)
// ch <- 10
// ch <- 20
// ch <- 30 // The buffer is full and there is no receiver: deadlock.
```

Step by step:

```text
ch <- 10
buffer: [10]

ch <- 20
buffer: [10, 20]

ch <- 30
buffer is full
no receive
the send blocks
```

If another goroutine takes one value, for example:

```go
<-ch
```

space opens up in the buffer and the third send can continue.

## A practical example: a bounded queue

One of the most useful uses of a buffered channel is creating a bounded queue between a producer and a consumer.

In the following example `produce` creates jobs and `main` receives them.

```go
package main

import "fmt"

func produce(jobs chan<- int) {
	for job := 1; job <= 5; job++ {
		jobs <- job
	}
	close(jobs)
}

func main() {
	jobs := make(chan int, 2)

	go produce(jobs)

	for job := range jobs {
		fmt.Println("Received:", job)
	}
}
```

Output:

```text
Received: 1
Received: 2
Received: 3
Received: 4
Received: 5
```

Here:

```go
jobs := make(chan int, 2)
```

creates a buffer of two elements.

`produce` is started as a separate goroutine:

```go
go produce(jobs)
```

It creates five jobs in the following loop:

```go
for job := 1; job <= 5; job++ {
	jobs <- job
}
```

If there is room in the buffer, the producer can keep sending values without waiting for the receiver.

For example, imagine the consumer has not started working yet.

The first value:

```text
1
```

goes into the buffer:

```text
[1]
```

The second value:

```text
2
```

also fits:

```text
[1, 2]
```

Now the buffer is full.

When the producer reaches:

```go
jobs <- 3
```

it temporarily blocks.

The consumer starts taking values from the channel through:

```go
for job := range jobs
```

Once one value is taken, space opens up in the buffer and the producer continues again.

This way the producer and consumer do not wait for each other completely, but the gap between them does not grow without limit either.

After `produce` has sent all values, it closes the channel with:

```go
close(jobs)
```

This is very important.

`range`:

```go
for job := range jobs
```

keeps running until the channel is closed and all remaining values in it have been taken.

When the channel is closed, values may still remain in the buffer.

For example:

```text
[4, 5]
```

Even though the channel is closed, `range` takes these two values.

`range` finishes only when:

1. the channel is closed;
2. the buffer is empty.

### Backpressure

A buffer temporarily decouples the speeds of the producer and the consumer.

For example, suppose the producer creates 100 jobs per second, while the consumer processes 80 jobs per second.

At first the buffer can temporarily absorb the difference.

But if the consumer is always slower than the producer, the queue keeps filling up.

Once the buffer capacity runs out, the producer cannot send new values and blocks.

This situation is called **backpressure**.

In simple terms:

> The slower part of the system puts pressure on the faster part, saying "wait now".

This is a useful property.

Otherwise, if the producer kept creating new jobs at unlimited speed, they could pile up in memory without limit.

A bounded buffer sets a clear limit for the queue.

## How should the capacity be chosen?

Choosing the buffer size simply as some big random number is not the right approach.

For example, writing:

```go
jobs := make(chan Job, 100000)
```

does not automatically solve the problem.

The buffer capacity actually defines how many unfinished jobs are allowed to wait in the queue in the system at the same time.

That is why several questions must be answered when choosing the capacity.

### How many jobs can the consumer process?

If the consumer or the workers can work efficiently with only 10 jobs at a time, a very large queue is not always useful.

Thousands of jobs in the queue will wait anyway.

### How much can the load temporarily rise?

Sometimes the producer's speed rises only for a short time.

For example, usually 100 requests per second arrive, but for a short time it can go up to 150.

In such a case a buffer can be useful for absorbing a short burst.

### How much memory does each value take?

Values in a channel's buffer are stored in memory.

If the channel holds small `int` values, the issue may not be big.

But if each value holds a big `struct`, a slice or references to other large objects, a big buffer can noticeably increase memory usage.

### Does waiting long in the queue make the result stale?

For some jobs old data becomes useless.

For example, if real-time metrics or user interface update events wait in a long queue, they may already be stale by the time they are processed.

In such a case a big queue only hides the latency problem.

### Should the sender block when the system slows down?

Sometimes the producer blocking is exactly the desired behavior.

For example, if a downstream service cannot keep up, the upstream should also reduce its speed.

This is one of the main goals of backpressure.

A very small buffer, on the other hand, can cause the opposite problem.

Even if the producer and consumer speeds are almost equal, because of the small queue they may block more often than necessary.

A very large buffer:

* shows the problem later;
* increases memory usage;
* increases latency;
* keeps old jobs in the queue for a long time.

That is why it is important to first define the needed semantics.

Then you should measure with the real workload.

It is better to check the buffer capacity not by guesses about performance but with benchmark, profiling and load test results.

## `len` and `cap`

The built-in `len` and `cap` functions can be used with a channel.

`cap(ch)` returns the total capacity of the channel's buffer.

`len(ch)` returns how many values are currently in the buffer.

For example:

```go
package main

import "fmt"

func main() {
	ch := make(chan string, 3)
	ch <- "one"
	ch <- "two"

	fmt.Println("Length:", len(ch))
	fmt.Println("Capacity:", cap(ch))
}
```

Output:

```text
Length: 2
Capacity: 3
```

Because of the channel:

```go
ch := make(chan string, 3)
```

the result of:

```go
cap(ch)
```

is:

```text
3
```

Two values were sent:

```go
ch <- "one"
ch <- "two"
```

That is why there are currently two values in the buffer:

```text
["one", "two"]
```

So the result of:

```go
len(ch)
```

is:

```text
2
```

For an unbuffered channel:

```go
ch := make(chan int)
```

`cap(ch)` is always `0`.

There is an important concurrency subtlety related to `len(ch)` here.

For example:

```go
if len(ch) < cap(ch) {
	ch <- value
}
```

may look safe at first glance.

As if the program:

1. checks that there is room in the buffer;
2. then sends.

But these two operations are not atomic.

After `len(ch)` is checked, another goroutine may send a value to the channel.

For example:

```text
1. Goroutine A: len(ch) = 1, cap(ch) = 2
2. A has not sent yet
3. Goroutine B sends a value to the channel
4. The buffer becomes full
5. Goroutine A sends
6. A blocks
```

That is why:

```go
if len(ch) < cap(ch)
```

does not guarantee that the next send will not block.

`len(ch)` shows only the state at that exact moment.

With concurrency this information can become stale immediately.

For this reason program logic should usually not depend on `len(ch)`.

If a non-blocking send or receive is needed, `select` and `default` are used for that.

This topic is covered in the next lesson.

## Directional channel types

The ordinary:

```go
chan T
```

is a bidirectional channel.

For example, for:

```go
chan int
```

both of the following operations are possible:

```go
ch <- 10
```

and:

```go
value := <-ch
```

But if a function should work with a channel in only one direction, this right can be restricted through the type.

For example:

```go
func send(out chan<- int) {
	out <- 10
}

func receive(in <-chan int) int {
	return <-in
}
```

Here:

```go
chan<- int
```

is a channel type that only allows sending.

The `<-` symbol stands after `chan`:

```go
chan<- int
```

that is, the value is sent toward the channel.

In the `receive` function:

```go
<-chan int
```

is used.

This is a channel that only allows receiving.

This syntax can be remembered like this:

```go
chan<- T
```

the value goes toward the channel.

```go
<-chan T
```

the value comes out of the channel.

The main types:

* `chan<- int` — only for sending;
* `<-chan int` — only for receiving;
* `chan int` — both sending and receiving are possible.

A bidirectional channel can be passed to a directional parameter.

For example:

```go
ch := make(chan int, 1)
send(ch)
fmt.Println(receive(ch))
```

The type of `ch` is:

```go
chan int
```

But the `send` function accepts only:

```go
chan<- int
```

Here Go automatically narrows the bidirectional channel to a view that has only the right to send.

The same channel can then also be passed through:

```go
receive(ch)
```

to a parameter that only receives.

The benefit is that the function can perform only the needed operation.

For example, inside:

```go
func send(out chan<- int) {
	out <- 10
}
```

you cannot write the following code:

```go
value := <-out
```

This is a compile-time error.

In the same way, inside:

```go
func receive(in <-chan int) int
```

you cannot write:

```go
in <- 10
```

This lets errors be detected at compile time, not at runtime.

A directional channel also shows the intent of an API clearly.

For example, a developer who sees the signature:

```go
func produce(out chan<- Job)
```

immediately understands that the function does not read values from `out`.

### Closing a channel and direction

A channel given only for receiving cannot be closed.

For example, inside the following function:

```go
func consume(in <-chan int) {
	close(in) // compile-time error
}
```

`close(in)` is not allowed.

The reason is that `in` is given only for receiving.

And closing a channel is an operation belonging to the sending side's responsibility.

That is why `close` needs a channel that has the right to send:

```go
chan T
```

or:

```go
chan<- T
```

Usually the channel is closed by the producer that knows no more new values will be sent.

## Which channel type should you choose?

The following table summarizes the main cases.

| Situation                                                            | Suitable choice      |
| -------------------------------------------------------------------- | -------------------- |
| The sender and receiver must meet exactly at the moment of exchange  | Unbuffered channel   |
| A short spike in load must be held in a bounded queue                | Buffered channel     |
| The function only produces values                                    | `chan<- T` parameter |
| The function only consumes values                                    | `<-chan T` parameter |

There is no general rule here that "an unbuffered channel is slow, a buffered channel is fast".

A buffered channel can improve throughput in some workloads.

In other cases it may only bring an extra queue, latency and memory usage.

The precise synchronization of an unbuffered channel, on the other hand, can be exactly the needed semantics in some algorithms.

That is why the choice should not be made only on the basis of performance guesses.

First the question should be:

> What semantics are needed here between the sender and the receiver?

Then:

> Is a queue needed?

> If so, how big?

> When should the sender block?

The performance difference should be measured with a benchmark on the specific workload.

## Common mistakes

### Thinking a buffer eliminates deadlock completely

A buffer decouples a send from a receive only up to its capacity.

For example:

```go
ch := make(chan int, 2)

ch <- 1
ch <- 2
ch <- 3
```

the first two sends may complete.

But the third send:

```go
ch <- 3
```

blocks because there is no room in the buffer.

If the receiver never runs, the program may end up in a deadlock.

So a buffer does not automatically eliminate the deadlock problem.

The lifecycle of goroutines, closing the channel and the send/receive flow must still be organized correctly.

### Growing the buffer without limit

A big buffer does not fix the problem of a slow consumer.

It only delays the moment the problem becomes visible.

For example, if the consumer is always slower than the producer:

```text
producer speed > consumer speed
```

the queue fills up anyway.

The only difference is:

* a small buffer fills up sooner;
* a big buffer fills up later.

During that time a big buffer uses more memory and increases the time jobs wait in the queue.

That is why a clear limit and a backpressure mechanism suited to the system must be defined.

### Thinking FIFO gives a global execution order

Even though a channel is FIFO, this does not mean all goroutines run in a strict global order.

For example:

```go
go func() {
	ch <- 1
}()

go func() {
	ch <- 2
}()
```

in this code the scheduler decides exactly which goroutine sends first.

On some runs the result may be:

```text
1
2
```

Another time it may be:

```text
2
1
```

FIFO guarantees this:

> Whichever value was successfully sent to the channel first is received first.

But the channel does not guarantee which of the different goroutines sends first.

### Synchronizing with `len(ch)`

The following approach is not safe synchronization:

```go
if len(ch) > 0 {
	value := <-ch
	_ = value
}
```

After the `len(ch)` check, another goroutine may take the value from the channel.

Then this goroutine may block on the operation:

```go
<-ch
```

The same problem exists on the send side.

That is why you should not conclude from the result of `len` that the next channel operation will not block.

Such a decision should be expressed as a single channel operation through `select`.

### Giving too many rights in a function parameter

If a function only sends, writing:

```go
func produce(ch chan int)
```

is technically possible.

But this also allows receiving inside the function.

For example:

```go
value := <-ch
```

compiles.

If the function is actually only a producer, the more correct signature is:

```go
func produce(ch chan<- int)
```

In the same way, for a consumer it is better to write:

```go
func consume(ch <-chan int)
```

This gives the API the narrowest necessary rights and prevents accidental misuse.

## What do interviews focus on?

In interview questions, understanding the blocking semantics of channels is often more important than the syntax.

You should know the following points precisely:

* an unbuffered send blocks until a matching receive is ready;
* an unbuffered receive blocks until a matching send is ready;
* a buffered send can continue without a receiver only while there is room in the buffer;
* when the buffer is full, a send blocks again;
* when the buffer is empty, a receive blocks until a new value arrives;
* a channel keeps FIFO order;
* FIFO does not guarantee the scheduler order of different goroutines;
* a buffer is a tool for creating a bounded queue and producing backpressure;
* `len(ch)` shows only the state at that moment and gives no synchronization guarantee;
* `chan<- T` is only for sending;
* `<-chan T` is only for receiving;
* a receive-only channel cannot be closed;
* a channel's capacity is not chosen just on the assumption that "it will work faster";
* the capacity is chosen based on the needed semantics, the memory limit, the latency requirement and real measurement.

In the next topic the `select` operator is used to choose, among several send and receive operations, the one that is ready to run at the moment.
