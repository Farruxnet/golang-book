# Goroutines

A **goroutine** is a lightweight unit of execution managed by the Go runtime. Put simply, a goroutine lets you run a function at the same time as other work, that is, concurrently.

For example, a backend server may wait for many HTTP requests at once. A CLI program may process several files. Another service may collect data from several external APIs.

If such tasks are independent of each other, it is convenient to run them in separate goroutines.

There is an important difference here: a goroutine is not itself an operating system thread.

The Go runtime schedules many goroutines on a few operating system threads. That is, the developer does not create a separate OS thread for each goroutine. That is why creating a goroutine is usually cheaper than creating a new thread.

But this does not lead to the conclusion that a goroutine is completely free. Each goroutine:

* uses memory for its stack;
* is managed by the scheduler;
* may be tied to certain resources;
* may cause a goroutine leak if not finished properly.

That is why, even though creating a goroutine is easy, designing its lifecycle correctly remains the developer's job.

## How is a goroutine started?

In an ordinary function call, the program waits for the function to finish:

```go
work()
```

In this case the line after it does not run until `work()` finishes.

If the `go` keyword is written before the call:

```go
go work()
```

`work()` is started as a new goroutine. The calling goroutine moves on to the next line without waiting for it to finish.

For example:

```go
go sendEmail()
fmt.Println("Moving on")
```

In this code there is no need to wait for `sendEmail()` to finish. `fmt.Println()` may run almost immediately.

But the scheduler decides which goroutine gets the CPU first. That is why, even though we wrote:

```go
go sendEmail()
fmt.Println("Moving on")
```

some code inside `sendEmail()` may run before `fmt.Println()`.

After the `go` operator there must be a function or method **call**.

For example, this is correct:

```go
go work()
```

This is also correct:

```go
go printer.Print("Hello")
```

But you cannot use a plain value with `go`.

There is one more subtle rule: the arguments passed to the function are evaluated in the calling goroutine, before the new goroutine starts running.

For example:

```go
go process(calculate())
```

Here `calculate()` runs first in the calling goroutine. Once its result is ready, `process(...)` is scheduled as a new goroutine.

## The first example

The following program creates a new goroutine. In this first example no tool for waiting for the helper goroutine is used,
on purpose:

```go
package main

import "fmt"

func greet(name string) {
	fmt.Println("Hello,", name)
}

func main() {
	go greet("Go")
	fmt.Println("main continued")
}
```

One of the possible outputs:

```text
Hello, Go
main continued
```

The following line starts the `greet()` function in a new goroutine:

```go
go greet("Go")
```

`main` does not wait for it to finish and moves on to the next line:

```go
fmt.Println("main continued")
```

That is why it is not guaranteed which of the following two lines is printed first:

```text
Hello, Go
main continued
```

If `main()` finishes very quickly, `Hello, Go` may not be printed at all. This is not a bug: the Go runtime does not
automatically wait for helper goroutines. For now the main goal is to see that the `go` keyword does not make the caller wait.
In the next lesson we will learn to reliably wait for goroutines to finish with `sync.WaitGroup`.

## `main` also runs as a goroutine

A Go program starts by running the `main()` function in the `main` goroutine.

That is, `main()` also runs inside a goroutine, like other goroutines. It just has a special significance: when `main()` finishes, the whole process ends.

The runtime does not automatically wait for other goroutines, even if they are still running.

The following program is deliberately written to be unreliable:

```go
package main

import "fmt"

func main() {
	go fmt.Println("This line may not be printed")
	fmt.Println("main finished")
}
```

The guaranteed line in this program is:

```text
main finished
```

The following line may or may not be printed:

```text
This line may not be printed
```

The reason:

```go
go fmt.Println("This line may not be printed")
```

creates a new goroutine.

But `main()` may immediately run the next line:

```go
fmt.Println("main finished")
```

and then finish.

If the new goroutine has not been started by the scheduler yet, the process ends and it does not manage to run its code.

That is why you cannot rely on how the scheduler happens to behave.

### Why is `time.Sleep` not a solution?

Beginners often write code like this:

```go
go work()
time.Sleep(time.Second)
```

This may work in a small demo program. Because `main` waits for one second and the helper goroutine finds time to run.

But this is not real synchronization.

`time.Sleep` only waits for a certain amount of time. It does not know whether the goroutine has finished its work.

For example, if the work usually takes 500 milliseconds, you might write:

```go
go work()
time.Sleep(time.Second)
```

At first glance this looks enough.

But if the external API slows down and `work()` takes 2 seconds, `main` finishes after one second. And the goroutine stops halfway.

On the other hand, if `work()` finishes in 10 milliseconds, the program waits the remaining 990 milliseconds for nothing.

That is why the completion of work should be awaited not through a time guess but through a specific event.

Commonly used tools:

* `sync.WaitGroup` for just waiting for goroutines to finish;
* a channel for passing a value or an error;
* `context.Context` for cancellation and timeouts.

In the next lesson we will look at how to wait for several goroutines to finish with `sync.WaitGroup`.

## Working with several goroutines

Imagine the program needs to get data from three independent services:

* the profile service;
* the order service;
* the payment service.

If we call them one after another, the waiting time of each service adds up.

For example:

```text
profile:  30 ms
order:    10 ms
payment:  20 ms
```

If run sequentially, the approximate total wait is:

```text
30 + 10 + 20 = 60 ms
```

If they are independent, all three can be started in separate goroutines. Then a large part of the I/O waiting time overlaps.

The following example shows this situation:

```go
package main

import (
	"fmt"
	"time"
)

type result struct {
	service string
	value   string
}

func fetch(service string, delay time.Duration, results chan<- result) {
	time.Sleep(delay)
	results <- result{
		service: service,
		value:   service + " data",
	}
}

func main() {
	services := []string{"profile", "order", "payment"}
	delays := []time.Duration{
		30 * time.Millisecond,
		10 * time.Millisecond,
		20 * time.Millisecond,
	}
	results := make(chan result, len(services))

	for i, service := range services {
		go fetch(service, delays[i], results)
	}

	values := make(map[string]string, len(services))
	for range services {
		item := <-results
		values[item.service] = item.value
	}

	for _, service := range services {
		fmt.Println(values[service])
	}
}
```

Output:

```text
profile data
order data
payment data
```

First the list of services is given:

```go
services := []string{"profile", "order", "payment"}
```

Then an artificial delay is given for each service:

```go
delays := []time.Duration{
	30 * time.Millisecond,
	10 * time.Millisecond,
	20 * time.Millisecond,
}
```

Here `time.Sleep` is not used for synchronization.

It only models a real I/O operation, such as waiting for a response from an external API.

A buffered channel is created to receive the results:

```go
results := make(chan result, len(services))
```

The value of `len(services)` is `3`.

So the channel capacity is `3` as well.

Each goroutine sends its result to the channel:

```go
results <- result{
	service: service,
	value:   service + " data",
}
```

Because the channel is buffered, the goroutine can put the result into the buffer even if `main` is not ready to receive it at that very moment. Of course, there must be room in the buffer.

Then three goroutines are started:

```go
for i, service := range services {
	go fetch(service, delays[i], results)
}
```

This loop runs three times.

As a result, roughly the following start waiting in parallel:

```text
profile  -> 30 ms
order    -> 10 ms
payment  -> 20 ms
```

That is why the `order` result may arrive at the channel first. Then `payment`, and after that `profile`.

But the program does not print the results directly in the order they arrive.

First they are placed into a `map`:

```go
values := make(map[string]string, len(services))

for range services {
	item := <-results
	values[item.service] = item.value
}
```

The program started exactly three goroutines. That is why it waits for exactly three results.

Then the results are printed in the order of the `services` slice again:

```go
for _, service := range services {
	fmt.Println(values[service])
}
```

That is why, no matter in what order the goroutines finish, the order on the screen is stable:

```text
profile data
order data
payment data
```

In a real project passing only the value is often not enough.

For example, the result could look like this:

```go
type result struct {
	service string
	value   string
	err     error
}
```

Then each goroutine can send its error along with its value.

Long-running external requests also need a timeout or cancellation. Otherwise, if one service does not respond, the whole operation may wait forever.

The concurrency in this example does not automatically mean parallel CPU computation.

**Concurrency** is managing several jobs within one time interval.

**Parallelism** means several jobs running at exactly the same time on different CPU cores.

When a goroutine waiting for I/O is blocked, the runtime can run another ready goroutine. Whether goroutines run at exactly the same moment on different CPU cores depends on the runtime, `GOMAXPROCS`, the available CPU cores and other factors.

## Anonymous functions and arguments

A goroutine does not have to work only with a named function.

An anonymous function can also be started as a goroutine:

```go
go func(id int) {
	fmt.Println("Job:", id)
}(id)
```

It is convenient to split this syntax into two parts.

The first part creates the anonymous function:

```go
func(id int) {
	fmt.Println("Job:", id)
}
```

The next part calls it:

```go
(id)
```

That is why the overall form is:

```go
go func(id int) {
	fmt.Println("Job:", id)
}(id)
```

The `(id)` at the end passes the current `id` value to the anonymous function's `id int` parameter.

This technique shows explicitly exactly which value the goroutine works with.

For example:

```go
for id := 1; id <= 3; id++ {
	go func(value int) {
		fmt.Println(value)
	}(id)
}
```

On each call the current `id` value is evaluated as the argument and passed to the `value` parameter.

Using the loop variable directly from the outer scope inside a closure was one of the widespread mistakes in old Go versions.

For example:

```go
for _, value := range values {
	go func() {
		fmt.Println(value)
	}()
}
```

Under the old semantics the closure could refer to the same loop variable. By the time the goroutine got to run, that variable had already moved on to the next value.

In modern Go versions the semantics of iteration variables in `for` loops has been improved. Even so, passing the value through a parameter often shows the intent more clearly:

```go
go func(value string) {
	fmt.Println(value)
}(value)
```

Besides that, this technique is safer and clearer when reading a module that works with an old Go version too.

## Returning a result from a goroutine

In an ordinary function the returned value can be written to a variable:

```go
value := calculate()
```

But you cannot get the result from a function started with `go` this way.

The following is wrong:

```go
// Wrong example:
// value := go calculate()
```

This code does not compile.

The reason is that the `go calculate()` call does not wait for `calculate()` to finish.

If `calculate()` prepares its result after 10 milliseconds, the calling goroutine may already have moved on to run other code during that time.

So when the result is ready must be managed separately.

One of the most natural ways to do this is a channel:

```go
result := make(chan int)

go func() {
	result <- calculate()
}()

value := <-result
```

Here the helper goroutine sends the result to the channel. The calling goroutine waits until the value arrives.

Another way is to write the result into a shared data structure.

But you must be careful when working with shared memory.

If two goroutines access the same memory location at the same time and at least one of them writes, a **data race** can occur without synchronization.

For example:

```go
counter := 0

go func() {
	counter++
}()

go func() {
	counter++
}()
```

This code looks simple on the outside.

But `counter++` does not have to be a single atomic operation. It may include several steps, such as reading the value, increasing it and writing it back.

That is why two goroutines may lose each other's changes.

Such code working correctly 100 times in a test does not prove it is safe.

Go has a race detector for detecting data races:

```bash
go test -race ./...
go run -race main.go
```

The first command runs the tests in the packages with the race detector:

```bash
go test -race ./...
```

The second runs an ordinary program with the race detector:

```bash
go run -race main.go
```

The race detector helps detect incorrect concurrent memory accesses observed during program execution.

But it does not try all possible scheduler orders.

That is why:

```text
the race detector found no errors
```

does not mean:

```text
the code will never have a data race
```

You should also check in the code itself that access to shared memory is properly protected.

Tools such as `sync.Mutex`, `sync.RWMutex`, `atomic` operations or managing ownership through channels can be used for this.

## How does the Go runtime manage goroutines?

One of the main reasons goroutines are lightweight has to do with how their stacks are managed.

Each goroutine starts with a relatively small stack.

If function calls pile up and more stack is needed, the Go runtime can grow it.

Later, when the need decreases, the runtime can also shrink the stack.

This is an important difference compared with OS threads.

Threads are often tied to a larger stack reservation. A goroutine, on the other hand, does not require a very large stack at the start.

That is why working with thousands of goroutines or even more is practically possible.

But the program logic should not depend on the exact initial stack size.

For example, writing a program based on the assumption:

```text
"Each goroutine gets exactly N kilobytes of stack"
```

is wrong.

This is an internal detail of the runtime implementation and may change between Go versions.

### The scheduler

The Go runtime scheduler distributes goroutines over OS threads.

To picture it simply:

```text
goroutine 1 ─┐
goroutine 2 ─┼──> Go scheduler ───> OS threads
goroutine 3 ─┤
goroutine 4 ─┘
```

If a goroutine is waiting on a channel:

```go
value := <-ch
```

it cannot continue for now.

Then the runtime can run another ready goroutine.

The same happens with a mutex, a timer or some I/O operations.

An important rule: the scheduler does not guarantee the execution order of goroutines.

For example, even if we write:

```go
go first()
go second()
```

the order:

```text
first finishes
second finishes
```

is not guaranteed.

The code inside `second()` may even run before the code inside `first()`.

### Switching goroutines is not free either

A goroutine may be lighter than a thread, but it has costs too.

The runtime:

* tracks goroutine state;
* manages scheduler queues;
* manages stacks;
* tracks blocked and ready goroutines;
* distributes them over OS threads.

That is why splitting every very small task into a separate goroutine is not always useful.

For example, splitting a million trivial calculations into a million goroutines can increase scheduler overhead.

Concurrency gives good results only when the jobs are independent by nature or when overlapping waiting times helps.

## Goroutine lifecycle

For every goroutine created, you should answer at least the following questions:

1. When does it finish?
2. Where is the result or error passed?
3. How is the waiting cancelled?
4. Who closes the resources it uses?

These questions are especially important in long-running servers.

A small one-off program may return all resources to the OS when the process ends. But in a server running for weeks, badly managed goroutines slowly pile up.

A goroutine function naturally finishes in the following cases:

* when the function reaches its end;
* when `return` runs.

For example:

```go
func worker() {
	doWork()
	return
}
```

or:

```go
func worker() {
	doWork()
}
```

In both cases, when the function finishes, the goroutine finishes too.

In Go there is no special operator for safely "killing" another goroutine from the outside.

For example, there is no standard mechanism like:

```text
kill(goroutine)
```

Cancellation usually works on the principle of **cooperative cancellation**.

That is, the goroutine receives a cancellation signal and does `return` itself.

For this, one usually uses:

* a channel;
* `context.Context`.

For example, a conceptual view:

```go
select {
case <-ctx.Done():
	return
case item := <-jobs:
	process(item)
}
```

Here, if `ctx.Done()` is closed, the goroutine receives the cancellation signal and finishes itself.

### Goroutine leak

A **goroutine leak** is a situation where a goroutine no longer does useful work but does not finish and stays inside the process.

For example:

```go
ch := make(chan int)

go func() {
	value := <-ch
	fmt.Println(value)
}()
```

If no one ever sends a value to the `ch` channel, the goroutine waits forever on the line:

```go
value := <-ch
```

This can be a goroutine leak.

A similar situation happens with sending:

```go
ch := make(chan int)

go func() {
	ch <- 10
}()
```

If the channel is unbuffered and no one receives a value from it, the sending goroutine stays blocked.

If a long-running I/O operation is also left without a way to cancel it, the goroutine may live for a long time.

Even when a goroutine does no useful work, it may still hold:

* its stack;
* the objects tied to it;
* some open resources.

That is why in server code it is important to check:

* whether there is a timeout for long operations;
* whether there is a cancellation path;
* whether a channel send can block forever;
* whether a channel receive can wait forever;
* whether the goroutines tied to a request finish when the request finishes.

For example, if a background goroutine belonging to an HTTP request keeps running after the request has finished, over time this can turn into a leak.

### `panic` inside a goroutine

`panic` requires special attention when working with goroutines.

If a `panic` happens inside a goroutine and is not caught, not just that goroutine but the whole program stops.

For example:

```go
go func() {
	panic("error")
}()
```

If this panic is not recovered, the process ends.

`recover()` works only through a deferred function inside **the same goroutine** where the panic happened.

For example:

```go
func worker() {
	defer func() {
		if value := recover(); value != nil {
			fmt.Println("Panic:", value)
		}
	}()

	panic("error")
}
```

Here `recover()` is placed in the goroutine where `worker()` runs.

A `recover()` in another goroutine cannot catch this panic.

For example, you cannot put a `recover()` inside `main` and catch a panic from another goroutine.

Putting `recover()` everywhere is not a good solution either.

It can hide programming errors.

`recover()` is usually used at clear boundaries. For example:

* a server request handler;
* a worker;
* a task executor;
* a task managed by a framework.

The goal is not to silently swallow the panic.

Usually the panic is:

* logged;
* the needed resources are closed;
* a controlled error response is returned or the task is finished.

## Common mistakes

### Thinking goroutines run in order

The following code:

```go
go first()
go second()
```

does not mean `first()` definitely finishes first because it was written first.

The scheduler can produce any of the following orders:

```text
first starts
second starts
second finishes
first finishes
```

or:

```text
second starts
second finishes
first starts
first finishes
```

or another order.

If the execution order matters, it must be expressed explicitly in the code.

For this a channel, a mutex, a `WaitGroup` or another suitable synchronization tool is used.

Relying on how the scheduler "usually works" is a mistake.

### Creating unlimited goroutines

The following pattern can be dangerous:

```go
for item := range items {
	go process(item)
}
```

If elements arrive in `items` very quickly, the program may create thousands or millions of goroutines.

This does not affect only goroutine memory.

For example, if `process()` needs a database connection, the number of goroutines may grow faster than the database connection pool.

Or if an external API allows 100 requests per second, thousands of goroutines sending requests at once break the rate limit.

That is why the number of parallel jobs often needs to be limited.

Common approaches:

* a worker pool;
* a semaphore;
* a bounded queue.

The main idea: even though creating a goroutine is cheap, the external resources it uses are not unlimited.

### Losing errors and results

A goroutine cannot return a result or an error to the caller through an ordinary `return`.

For example:

```go
go save()
```

if `save()` returns an `error`, the caller cannot receive this error directly.

The result and the error must be passed separately.

For example:

```go
type result struct {
	value string
	err   error
}
```

Then:

```go
results <- result{
	value: value,
	err:   err,
}
```

There is another important question: if one goroutine fails, what should the others do?

The options can differ:

* the remaining jobs continue;
* everything is cancelled at the first error;
* all results are collected and the errors are returned at the end.

This decision should not come about by accident. It must be designed in advance.

### Synchronizing with `time.Sleep`

The following code is a common mistake in tests:

```go
go work()
time.Sleep(100 * time.Millisecond)
checkResult()
```

This code assumes `work()` finishes within 100 milliseconds.

But the CI server may be slower. External I/O may take longer. The scheduler may behave differently.

As a result the test sometimes passes and sometimes fails.

Such a test can turn into a **flaky test**.

The completion of work should be awaited with:

* a `WaitGroup`;
* a channel.

A timeout is used for a separate purpose: to control that an operation does not exceed the allowed time.

### Unprotected writes to a shared variable

If several goroutines change the same data, a data race may appear.

For example:

```go
values := map[string]int{}

go func() {
	values["a"] = 1
}()

go func() {
	values["b"] = 2
}()
```

Writing to a Go `map` from several goroutines without synchronization is not safe.

The same problem can happen with:

* slice elements;
* a counter;
* struct fields;
* shared pointers.

There are two common ways to solve the problem.

The first is to protect the shared memory with a mutex:

```go
var mu sync.Mutex
```

The second is to give ownership of the data to one goroutine and communicate with the other goroutines through channels.

Which approach is better depends on the task.

An important rule: if several goroutines work with shared mutable state, the synchronization question must always be checked.

## What do interviews focus on?

In interview questions about goroutines, knowing just the syntax:

```go
go f()
```

is not enough.

It is important to clearly distinguish the following concepts:

* a goroutine is not an OS thread; it is managed by the Go runtime;
* `go f()` schedules the function as a new goroutine;
* the calling goroutine does not wait for it to finish;
* when `main()` returns, other goroutines are not waited for automatically;
* the execution order of goroutines is not guaranteed because of the scheduler;
* a result or `error` is not passed to the caller from inside a goroutine with an ordinary `return`;
* a channel or another synchronization mechanism is needed for the result;
* shared mutable state can cause a data race;
* a goroutine leak is a serious problem in long-running programs;
* uncontrolled fan-out can exhaust resources;
* instead of forcibly killing a goroutine from the outside, it should be finished cooperatively with a cancellation signal.

In an interview you may also be asked:

> If creating a goroutine is so easy, why don't we put every job in a goroutine?

The answer is that even though a goroutine is lightweight, it has scheduling and memory costs. Besides that, the external resources it uses, such as database connections, sockets, API quota or CPU, may be limited.

That is why concurrency is also used with control.

## Examples

### 1. Starting a named function as a goroutine

This example shows starting an ordinary named function concurrently with the `go` keyword.

```go
package main

import (
	"fmt"
	"time"
)

func greet() {
	fmt.Println("Hello from a goroutine")
}

func main() {
	go greet()
	time.Sleep(20 * time.Millisecond)
}
```

The main line:

```go
go greet()
```

Without `go`:

```go
greet()
```

`main()` would wait for `greet()` to finish.

Once `go` is added, `greet()` is scheduled as a separate goroutine. `main()` immediately moves on to the next line:

```go
time.Sleep(20 * time.Millisecond)
```

In this example `Sleep()` is used only for demonstration. It holds `main` for a short time so the helper goroutine manages to print to the screen.

This is not reliable synchronization for production code.

If running `greet()` takes more than 20 milliseconds, `main()` may still finish.

The main rule: `go f()` schedules the function to run concurrently but does not wait for it to finish.

### 2. Running an anonymous function in a goroutine

In this example an anonymous function is used instead of creating a separate named function for a one-off job.

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	go func() {
		fmt.Println("The anonymous goroutine ran")
	}()

	time.Sleep(20 * time.Millisecond)
}
```

The anonymous function is declared as:

```go
func() {
	fmt.Println("The anonymous goroutine ran")
}
```

But declaring a function does not run it.

That is why at the end:

```go
()
```

is written:

```go
func() {
	fmt.Println("The anonymous goroutine ran")
}()
```

This calls the anonymous function immediately.

And `go` stands before the whole call:

```go
go func() {
	fmt.Println("The anonymous goroutine ran")
}()
```

If this function is needed only in this place, there is no need to give it a separate name.

This pattern is common in short background tasks, when using closures or when using values from the same scope.

### 3. Passing an argument to a goroutine

In this example an argument is passed to a named function, and each goroutine works with its own value.

```go
package main

import (
	"fmt"
	"time"
)

func printNumber(number int) {
	fmt.Println("Number:", number)
}

func main() {
	for number := 1; number <= 3; number++ {
		go printNumber(number)
	}
	time.Sleep(20 * time.Millisecond)
}
```

The loop:

```go
for number := 1; number <= 3; number++ {
```

gives `number` the following values:

```text
1
2
3
```

On each iteration:

```go
go printNumber(number)
```

is called.

The function argument is evaluated before the goroutine starts working.

That is why each call gets the value at that moment.

As a result, three goroutines work roughly with:

```text
printNumber(1)
printNumber(2)
printNumber(3)
```

But the order on the screen is not guaranteed.

For example, the result may be:

```text
Number: 2
Number: 1
Number: 3
```

Or it may be:

```text
Number: 3
Number: 2
Number: 1
```

The loop order does not determine the order in which goroutines finish.

### 4. Giving a value to an anonymous function through a parameter

In this example the value from the loop is passed to the anonymous function through a parameter.

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	words := []string{"Go", "fast", "simple"}

	for _, word := range words {
		go func(value string) {
			fmt.Println(value)
		}(word)
	}

	time.Sleep(20 * time.Millisecond)
}
```

On each iteration of the loop `word` gets the next value:

```text
Go
fast
simple
```

The anonymous function has a parameter:

```go
func(value string) {
	fmt.Println(value)
}
```

The part at the end:

```go
(word)
```

passes the current `word` value to the `value` parameter.

That is, logically it is similar to:

```text
value = "Go"
value = "fast"
value = "simple"
```

separately for each goroutine.

This approach shows the code's intent clearly: the goroutine must work with exactly the value from this iteration.

The output order does not have to match the order written in the slice.

For example:

```text
simple
Go
fast
```

is also a correct result.

The main rule: the argument value is taken at the moment of the call, but the execution order of goroutines depends on the scheduler.

### 5. Running one function in several goroutines

In this example the same `download()` function is used in several goroutines with different arguments.

```go
package main

import (
	"fmt"
	"time"
)

func download(file string, delay time.Duration) {
	time.Sleep(delay)
	fmt.Println(file, "downloaded")
}

func main() {
	go download("small.txt", 10*time.Millisecond)
	go download("large.zip", 40*time.Millisecond)
	time.Sleep(60 * time.Millisecond)
}
```

The first goroutine:

```go
go download("small.txt", 10*time.Millisecond)
```

waits `10` milliseconds.

The second goroutine:

```go
go download("large.zip", 40*time.Millisecond)
```

waits `40` milliseconds.

Because of this artificial delay, `small.txt` is usually printed first:

```text
small.txt downloaded
large.zip downloaded
```

But real-life download time cannot be known in advance.

A small file may come from a distant server. A large file may be fetched from a very fast local network.

That is why the program should not rely on the assumption that "the goroutine started first definitely finishes first".

The `Sleep()` in this example models I/O time. The `60`-millisecond `Sleep()` at the end of `main()` was added only so the demo program does not end the process early.

### 6. Seeing `main()` finish early

This example shows that `main()` does not automatically wait for a helper goroutine.

```go
package main

import (
	"fmt"
	"time"
)

func delayedMessage() {
	time.Sleep(100 * time.Millisecond)
	fmt.Println("This line may not be printed")
}

func main() {
	go delayedMessage()
	fmt.Println("main finished")
}
```

`main()` starts the helper goroutine:

```go
go delayedMessage()
```

`delayedMessage()` immediately waits 100 milliseconds through:

```go
time.Sleep(100 * time.Millisecond)
```

Meanwhile `main()` continues:

```go
fmt.Println("main finished")
```

and the function finishes.

As soon as `main()` finishes, the process ends.

That is why the helper goroutine may not reach the line:

```go
fmt.Println("This line may not be printed")
```

In most cases the output is only:

```text
main finished
```

This example shows that a goroutine's work must be seen separately from the `main` lifecycle.

The solution is not "adding a big `Sleep()`". A `WaitGroup` or a channel should be used for explicit waiting.

### 7. Watching the number of goroutines

In this example the number of goroutines existing at the moment is obtained with `runtime.NumGoroutine()`.

```go
package main

import (
	"fmt"
	"runtime"
	"time"
)

func main() {
	fmt.Println("At the start:", runtime.NumGoroutine())

	go func() {
		time.Sleep(50 * time.Millisecond)
	}()

	time.Sleep(10 * time.Millisecond)
	fmt.Println("While working:", runtime.NumGoroutine())
}
```

At the start of the program:

```go
runtime.NumGoroutine()
```

returns the current number of goroutines.

In an ordinary small program this usually counts the `main` goroutine.

Then a new goroutine is created:

```go
go func() {
	time.Sleep(50 * time.Millisecond)
}()
```

This goroutine lives for 50 milliseconds.

`main()` waits for 10 milliseconds:

```go
time.Sleep(10 * time.Millisecond)
```

So when the second `NumGoroutine()` is called, the helper goroutine has most likely not finished yet.

The result may look roughly like:

```text
At the start: 1
While working: 2
```

But the program logic should not be tied to an exact number.

`runtime.NumGoroutine()` gives only a snapshot at that moment. The value may differ depending on the program structure and runtime activity.

This function can be useful in debugging or monitoring. For example, when you suspect a goroutine leak, you can watch whether the number of goroutines keeps growing over time.

### 8. Recording an error inside a goroutine

In this example the function called by the goroutine returns an `error`. The error is checked in the goroutine itself.

```go
package main

import (
	"errors"
	"fmt"
	"time"
)

func save(name string) error {
	if name == "" {
		return errors.New("the name is empty")
	}
	return nil
}

func main() {
	go func() {
		if err := save(""); err != nil {
			fmt.Println("Save error:", err)
		}
	}()

	time.Sleep(20 * time.Millisecond)
}
```

`save()` has the following signature:

```go
func save(name string) error
```

So it can return an error.

When an empty string is passed:

```go
save("")
```

the following error is returned:

```go
errors.New("the name is empty")
```

Inside the goroutine:

```go
if err := save(""); err != nil {
	fmt.Println("Save error:", err)
}
```

checks the error immediately.

Output:

```text
Save error: the name is empty
```

In this small example, just logging the error is enough.

But in a real system the caller may also need to know about the error.

In such a case the error can be returned through a channel:

```go
errorsCh <- err
```

or the result and the `error` are passed together in one struct.

The main rule: you can `return err` from inside a goroutine, but the code that started the `go` call does not automatically receive this `error` as in an ordinary function call.

### 9. Catching a panic inside a goroutine in place

This example shows that `recover()` works only inside the goroutine where the panic happened.

```go
package main

import (
	"fmt"
	"time"
)

func riskyWork() {
	defer func() {
		if value := recover(); value != nil {
			fmt.Println("Panic caught:", value)
		}
	}()

	panic("unexpected situation")
}

func main() {
	go riskyWork()
	time.Sleep(20 * time.Millisecond)
	fmt.Println("The program continued")
}
```

At the start of `riskyWork()` a deferred function is registered:

```go
defer func() {
	if value := recover(); value != nil {
		fmt.Println("Panic caught:", value)
	}
}()
```

Then:

```go
panic("unexpected situation")
```

runs.

Because of the panic the function does not continue its normal flow. But during stack unwinding the deferred function runs.

Inside this deferred function:

```go
recover()
```

catches the panic value.

The output may be roughly:

```text
Panic caught: unexpected situation
The program continued
```

The important rule is that `recover()` cannot catch a panic in another goroutine.

For example, a deferred `recover()` inside `main()` does not catch a panic inside a helper goroutine.

That is why in this example the deferred function is placed exactly inside `riskyWork()`.

In production code putting `recover()` in every function is not recommended. It is usually used at a clear task or request boundary.

### 10. Calling a method as a goroutine

A goroutine can run not only an ordinary function but also a method call.

```go
package main

import (
	"fmt"
	"time"
)

type Printer struct {
	Prefix string
}

func (printer Printer) Print(message string) {
	fmt.Println(printer.Prefix, message)
}

func main() {
	printer := Printer{Prefix: "LOG:"}
	go printer.Print("message ready")
	time.Sleep(20 * time.Millisecond)
}
```

Here:

```go
printer.Print("message ready")
```

is an ordinary method call.

When `go` is written before it:

```go
go printer.Print("message ready")
```

the method runs as a new goroutine.

`Print()` is written with a value receiver:

```go
func (printer Printer) Print(message string)
```

So the method takes a `Printer` value as its receiver.

In this example `Printer` is a very simple struct:

```go
type Printer struct {
	Prefix string
}
```

The value of `Prefix` is:

```text
LOG:
```

That is why the method:

```go
fmt.Println(printer.Prefix, message)
```

prints roughly the following:

```text
LOG: message ready
```

Because a value receiver is used, the method works with a copy of the receiver value.

But remember one subtle point about value receivers: the struct itself is copied, but if it contains values such as slices, maps or pointers, the semantics of accessing other data through them can be different.

In this example there is only a `string` field. That is why the question of copying the receiver is simple.

The main rule: a method call, like a function call, can be started as a new goroutine with the `go` keyword.
