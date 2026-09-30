# Waiting for goroutines with `sync.WaitGroup`

`sync.WaitGroup` is a synchronization tool used to wait for a group of goroutines to finish their work.

Its job is simple: it keeps count of how many jobs have not finished yet. When this number drops to zero, all registered jobs are considered finished and the waiting goroutine continues.

In earlier topics we saw an important situation: when the `main()` function finishes, the program finishes too. Go does not automatically wait for other goroutines to finish.

For example, if you start a goroutine and then `main()` returns immediately, the helper goroutine may not manage to finish its work.

Sometimes `time.Sleep` is used to prevent this:

```go
time.Sleep(time.Second)
```

But this is not a reliable solution.

If the work takes longer than a second, the program may still finish early. If the work finishes in 10 milliseconds, the program waits the remaining time for nothing.

`WaitGroup`, on the other hand, does not guess the time. It tracks that the work has actually finished.

## How does `WaitGroup` work?

The classic way of working with `WaitGroup` mainly uses three methods:

* `Add(n)` — adds `n` to the counter of unfinished jobs;
* `Done()` — decreases the counter by one;
* `Wait()` — makes the current goroutine wait until the counter becomes zero.

The ordinary workflow is as follows:

1. First the job to be done is added to the counter.
2. Then the goroutine is started.
3. When the goroutine finishes its work, it calls `Done()`.
4. The waiting code waits for all jobs to finish through `Wait()`.
5. When the counter drops to zero, `Wait()` returns.

For example, if three goroutines need to run, the counter logically changes like this:

```text
Start:
counter = 0

Add(3):
counter = 3

goroutine 1 Done():
counter = 2

goroutine 2 Done():
counter = 1

goroutine 3 Done():
counter = 0

Wait() continues
```

The zero value of `WaitGroup` is ready to use.

That is why there is no need to call a separate constructor:

```go
var wg sync.WaitGroup
```

After this line, the `wg.Add()`, `wg.Done()` and `wg.Wait()` methods can be used right away.

## `WaitGroup.Go()` in Go 1.25 and newer

Starting from Go 1.25, `WaitGroup` also has a `Go()` method. It increases the counter, starts a new goroutine and automatically decreases the counter when the function finishes.

```go
package main

import (
	"fmt"
	"sync"
)

func main() {
	var wg sync.WaitGroup

	for i := 1; i <= 5; i++ {
		id := i
		wg.Go(func() {
			fmt.Println("Hello!", id)
		})
	}

	wg.Wait()
	fmt.Println("All goroutines finished")
}
```

With this technique there is no need to write `wg.Add(1)`, `go` and `wg.Done()` separately. Do not call `Done()` again inside the function given to `Go()`, otherwise the counter decreases too much. This function must not panic.

Knowing the `Add()` and `Done()` methods is still important. They appear in code for Go 1.24 and older versions, as well as in cases where the work has already been started elsewhere. In the following examples we will also look at the classic technique.

## The first example

The following program starts five goroutines. And `main()` waits for all of them to finish.

```go
package main

import (
	"fmt"
	"sync"
)

func greet(id int, wg *sync.WaitGroup) {
	defer wg.Done()
	fmt.Println("Hello!", id)
}

func main() {
	var wg sync.WaitGroup

	for i := 1; i <= 5; i++ {
		wg.Add(1)
		go greet(i, &wg)
	}

	wg.Wait()
	fmt.Println("All goroutines finished")
}
```

One of the possible outputs:

```text
Hello! 5
Hello! 1
Hello! 2
Hello! 3
Hello! 4
All goroutines finished
```

Now let's go through the code step by step.

First a `WaitGroup` is created:

```go
var wg sync.WaitGroup
```

The counter is initially `0`.

On each iteration of the loop:

```go
wg.Add(1)
```

is called.

This says there is a new unfinished job.

After the first iteration:

```text
counter = 1
```

After the second iteration:

```text
counter = 2
```

And after the fifth iteration:

```text
counter = 5
```

After that the goroutine is started:

```go
go greet(i, &wg)
```

Note that `&wg` is used here. Not a copy of the `WaitGroup` but its pointer is passed to the function.

That is why all goroutines work with exactly one `WaitGroup`.

Inside `greet()` we wrote:

```go
defer wg.Done()
```

`Done()` decreases the counter by one.

For example:

```text
5 -> 4 -> 3 -> 2 -> 1 -> 0
```

Because of `defer`, `Done()` runs before the function finishes.

The line inside `main()`:

```go
wg.Wait()
```

waits until the counter drops to zero.

Only after all five goroutines have called `Done()` does the following line run:

```go
fmt.Println("All goroutines finished")
```

The order of the greeting lines is not guaranteed.

For example, they may also be printed like this:

```text
Hello! 3
Hello! 2
Hello! 5
Hello! 1
Hello! 4
All goroutines finished
```

The reason is that goroutines are scheduled by the Go scheduler. Which goroutine gets CPU time first is not guaranteed in advance.

But one thing is guaranteed: the line `"All goroutines finished"` is printed after all `greet()` calls have finished.

## Why is `Done()` usually written with `defer`?

`Done()` actually decreases the counter by one.

The following two operations mean the same thing:

```go
wg.Done()
```

and:

```go
wg.Add(-1)
```

But in practical code using `Done()` is much clearer.

It can also simply be called at the end of the function:

```go
func work(wg *sync.WaitGroup) {
	doSomething()
	wg.Done()
}
```

This code works.

The problem begins when the function can return from several places.

For example:

```go
func work(value int, wg *sync.WaitGroup) {
	if value < 0 {
		return
	}

	wg.Done()
}
```

Here, if `value < 0`, the function does not reach `wg.Done()`.

As a result, the `WaitGroup` counter is not decreased.

That is why it is usually written like this:

```go
func work(wg *sync.WaitGroup) {
	defer wg.Done()

	// Whichever return path the function exits through,
	// Done is called before the function returns.
}
```

`defer` delays the call until the function finishes.

That is why, no matter where the function exits with an ordinary `return`, `Done()` runs.

This is especially useful in functions with several `return` statements.

But there is a subtle situation here.

If the function never returns, for example if it blocks forever, the deferred `Done()` does not run either.

Example:

```go
func work(wg *sync.WaitGroup) {
	defer wg.Done()

	select {}
}
```

`select {}` blocks forever. The function does not finish. So `Done()` is not called either.

Another situation is `panic`.

If a `panic` happens inside the function, the deferred functions run during stack unwinding. So `wg.Done()` may be called.

But if the `panic` is not recovered, the program still stops after that.

## Call `Add` before the goroutine starts

One of the most important rules when working with `WaitGroup`:

> A positive `Add` call must run before the goroutine is started.

The following is wrong:

```go
// Wrong example:
// go func() {
//     wg.Add(1)
//     defer wg.Done()
//     work()
// }()
// wg.Wait()
```

At first glance this code may look logical.

The goroutine starts, adds itself to the counter, does the work and calls `Done()`.

But the scheduler decides when goroutines run.

The following sequence may happen:

```text
1. main creates the new goroutine.
2. The new goroutine does not get the CPU yet.
3. main calls wg.Wait().
4. The WaitGroup counter is still 0.
5. Wait() returns immediately.
6. main continues or the program ends.
7. The new goroutine may run Add(1) later.
```

So `Wait()` may return before the new job is added to the counter.

The correct form:

```go
wg.Add(1)

go func() {
	defer wg.Done()
	work()
}()
```

Here, first:

```go
wg.Add(1)
```

runs.

Only after that is the goroutine created.

Now, no matter in what order the scheduler works, `Wait()` sees that there is at least one unfinished job.

For example:

```text
counter = 0

wg.Add(1)
counter = 1

the goroutine is started

wg.Wait()
if counter is still 1, Wait waits

goroutine Done()
counter = 0

Wait returns
```

A positive `Add` call made while the counter is at zero must run before the corresponding `Wait()`.

## What happens if the counter does not match?

How `WaitGroup` works depends on the counter being managed correctly.

Every registered job must eventually be removed from the counter.

For example, if two goroutines are used, the counter can be increased to `2` at once:

```go
package main

import (
	"fmt"
	"sync"
)

func main() {
	var wg sync.WaitGroup
	wg.Add(2)

	for i := 1; i <= 2; i++ {
		go func(id int) {
			defer wg.Done()
			fmt.Println("Job finished:", id)
		}(i)
	}

	wg.Wait()
	fmt.Println("All work finished")
}
```

A possible output:

```text
Job finished: 2
Job finished: 1
All work finished
```

Here:

```go
wg.Add(2)
```

says there are two unfinished jobs.

The initial state:

```text
counter = 0
```

After `Add(2)`:

```text
counter = 2
```

When the first goroutine finishes:

```text
counter = 1
```

When the second goroutine finishes:

```text
counter = 0
```

After that `Wait()` returns.

The order of the first two lines may change. But:

```text
All work finished
```

is always printed after the worker goroutines.

If the counter and the `Done()` calls do not match each other, two main errors occur.

### If `Done()` is not called enough

Example:

```go
wg.Add(2)
wg.Done()
wg.Wait()
```

The counter changes like this:

```text
0 -> 2 -> 1
```

But it never drops to `0`.

That is why:

```go
wg.Wait()
```

keeps waiting.

If there is no other goroutine in the program that can continue, the runtime may detect a deadlock.

A deliberately wrong example:

```go
// The counter does not drop to zero:
// wg.Add(2)
// wg.Done()
// wg.Wait() // Waits forever because one more Done is missing.
```

### If `Done()` is called too many times

Now let's look at another error:

```go
wg.Add(1)
wg.Done()
wg.Done()
```

The counter:

```text
0 -> 1 -> 0 -> -1
```

The `WaitGroup` counter cannot be negative.

That is why the runtime panics:

```text
panic: sync: negative WaitGroup counter
```

A deliberately wrong example:

```go
// The counter becomes negative:
// wg.Add(1)
// wg.Done()
// wg.Done() // panic: sync: negative WaitGroup counter
```

The important point is that the `n` in `Add(n)` does not necessarily have to be the number of goroutines.

It expresses the number of logically unfinished jobs.

But in ordinary code, if one goroutine does one logical job, the following pair is clear and safer:

```go
wg.Add(1)

go func() {
	defer wg.Done()
	// work
}()
```

With this technique it is easier to see that `Add` and `Done` match each other.

## A practical example: computing file sizes in parallel

Now let's look at an example that uses `WaitGroup` together with collecting results.

The following program splits a task related to several files across separate goroutines.

So that the example does not depend on a real file system, the file names and sizes are given in advance.

```go
package main

import (
	"fmt"
	"sync"
)

type file struct {
	name string
	size int64
}

func main() {
	files := []file{
		{name: "users.json", size: 1200},
		{name: "orders.json", size: 3400},
		{name: "report.csv", size: 800},
	}

	sizes := make([]int64, len(files))
	var wg sync.WaitGroup

	for i, item := range files {
		wg.Add(1)
		go func(index int, current file) {
			defer wg.Done()
			sizes[index] = current.size
		}(i, item)
	}

	wg.Wait()

	var total int64
	for i, item := range files {
		fmt.Printf("%s: %d bytes\n", item.name, sizes[i])
		total += sizes[i]
	}
	fmt.Println("Total:", total, "bytes")
}
```

Output:

```text
users.json: 1200 bytes
orders.json: 3400 bytes
report.csv: 800 bytes
Total: 5400 bytes
```

There are several important points in this example.

First a slice is created to store the results:

```go
sizes := make([]int64, len(files))
```

`files` has three elements. So `sizes` also has three elements:

```text
[0 0 0]
```

Then a goroutine is created for each file:

```go
for i, item := range files {
	wg.Add(1)

	go func(index int, current file) {
		defer wg.Done()
		sizes[index] = current.size
	}(i, item)
}
```

Each goroutine writes to a different index of the `sizes` slice.

For example:

```text
goroutine 1 -> sizes[0]
goroutine 2 -> sizes[1]
goroutine 3 -> sizes[2]
```

That is why two goroutines do not write to exactly the same element.

Besides that, the slice length is fixed in advance.

Here:

```go
append(sizes, ...)
```

is not used.

This matters, because if several goroutines concurrently `append` to the same slice, a data race can occur on the slice header or its underlying array.

The index and value are passed to the anonymous function as arguments:

```go
}(i, item)
```

and the parameters are received like this:

```go
func(index int, current file)
```

This makes clear which index and which file each goroutine works with.

Then:

```go
wg.Wait()
```

is called.

`main` reads the results only after all goroutines have finished:

```go
for i, item := range files {
	fmt.Printf("%s: %d bytes\n", item.name, sizes[i])
	total += sizes[i]
}
```

That is why the writes of the worker goroutines and the reads of `main` do not happen at the same time.

The results are not printed according to the order in which the goroutines finished.

They are printed in the order of the `files` slice:

```text
users.json
orders.json
report.csv
```

That is why the final output is deterministic.

In a real program, instead of taking `current.size` from a ready value, the goroutine might call, for example, `os.Stat`.

In such real code additional issues appear:

* storing an error that occurred while checking the file;
* limiting how many files are opened at the same time;
* stopping the operation through cancellation;
* applying a timeout.

`WaitGroup` does none of these jobs itself.

## What does `WaitGroup` not do?

The job of `WaitGroup` is narrow and precise:

> It only waits for the registered jobs to finish.

It does not do the following:

* it does not return results from goroutines;
* it does not collect errors automatically;
* it does not pass errors to another goroutine;
* it does not cancel goroutines;
* it does not provide a timeout;
* it does not limit the number of goroutines running at the same time;
* it does not protect a shared `map`, slice or other memory from concurrent writes.

For example, if two goroutines write to the same `map`:

```go
var wg sync.WaitGroup
m := map[string]int{}

wg.Add(2)

go func() {
	defer wg.Done()
	m["a"] = 1
}()

go func() {
	defer wg.Done()
	m["b"] = 2
}()

wg.Wait()
```

even though a `WaitGroup` is present here, concurrent writes to the `map` do not become safe.

`WaitGroup` only waits for the two goroutines to finish.

Protecting shared data needs another tool. For example:

* `sync.Mutex`;
* a channel;
* a goroutine ownership model.

Channels are often used to pass a result or an error.

For cancellation and timeouts:

```go
context.Context
```

is usually used.

To limit the number of goroutines running at the same time, an approach such as a worker pool or a semaphore is used.

> **Warning**
>
> Using a `WaitGroup` does not automatically protect code from data races. It only ensures that the registered jobs finish before `Wait()` returns. If several goroutines concurrently write to the same memory, separate synchronization is needed.

## Memory visibility and synchronization

`WaitGroup` is not only a "waiting" tool. It also gives the corresponding memory synchronization guarantees.

Put simply:

> The data a goroutine wrote before `Done()` is visible to the waiting goroutine after the corresponding `Wait()` returns.

Let's recall the earlier example:

```go
go func(index int, current file) {
	defer wg.Done()
	sizes[index] = current.size
}(i, item)
```

The goroutine first performs the write:

```go
sizes[index] = current.size
```

Then, when the function is finishing:

```go
wg.Done()
```

runs.

`main` reads `sizes` only after:

```go
wg.Wait()
```

returns.

The flow is as follows:

```text
worker:
sizes[index] = value
        |
        v
     Done()

        synchronization

        |
        v
main:
Wait() returns
        |
        v
sizes[index] is read
```

For this reason the read after `Wait()` sees the worker's earlier write.

If `main` reads `sizes` before `Wait()`, a different situation occurs.

For example:

```go
go func() {
	sizes[0] = 10
	wg.Done()
}()

fmt.Println(sizes[0]) // may be read too early
wg.Wait()
```

Here the read of `main` and the write of the worker may happen at the same time.

As a result, there is a chance of a data race.

An important difference:

`WaitGroup` provides the necessary synchronization between the workers and the waiting goroutine.

But it does not automatically make the concurrent writes of the worker goroutines to each other safe.

For example:

```text
goroutine A -> writes to x
goroutine B -> writes to x
```

if both write to the same value at the same time, `WaitGroup` does not prevent it.

In such a case a mutex, a channel or other suitable synchronization is needed.

## Don't copy a `WaitGroup`

Once a `WaitGroup` has started being used, it should not be copied.

It is important to understand the reason for this rule.

Imagine there is one `WaitGroup` inside `main`:

```go
var wg sync.WaitGroup
wg.Add(1)
```

Then we pass it to a function by value:

```go
work(wg)
```

If the function signature is:

```go
func work(wg sync.WaitGroup)
```

the function works not with the original `WaitGroup` but with its copy.

A wrong example:

```go
// Wrong: the WaitGroup is copied by value.
// func work(wg sync.WaitGroup) {
//     defer wg.Done()
// }
```

In this case roughly the following situation occurs:

```text
main wg:
counter = 1

the copy inside work():
counter = 1
```

When the worker calls:

```go
wg.Done()
```

only the counter of the copy changes:

```text
worker's copy:
1 -> 0
```

But the original object in `main` stays in the state:

```text
main wg:
counter = 1
```

As a result:

```go
wg.Wait()
```

may never return.

The correct variant takes a pointer:

```go
func work(wg *sync.WaitGroup) {
	defer wg.Done()
}
```

Calling it:

```go
go work(&wg)
```

Now both `work()` and `main()` work with exactly one `WaitGroup`.

`go vet` helps find some cases of copying a `WaitGroup`:

```bash
go vet ./...
```

`go vet` statically analyzes code constructs that pass ordinary compilation but may be suspicious.

That is why `go vet` is a useful check when working with types that must not be copied, such as `WaitGroup`.

## Reusing a `WaitGroup`

A `WaitGroup` does not have to be used only once.

After a group of jobs has completely finished, it can be reused for a new independent group.

For example:

```go
wg.Add(1)

go func() {
	defer wg.Done()
	// first job
}()

wg.Wait()
```

Here the first group has completely finished.

After that it can be used again:

```go
wg.Add(1)

go func() {
	defer wg.Done()
	// second job
}()

wg.Wait()
```

The important condition is that you must not start positive `Add`s for a new independent group while the `Wait()` calls of the previous group are still waiting.

Logically the groups should be separated like this:

```text
group 1:
Add
goroutine
Done
Wait returns

group 2:
Add
goroutine
Done
Wait returns
```

A lifecycle like the following makes things hard to understand:

```text
group 1 Wait still waiting
        |
        +--> Add for a new independent group
```

In practical code it is often easier to create a local `WaitGroup` for each separate operation.

For example:

```go
func processBatch() {
	var wg sync.WaitGroup
	// ...
}
```

This approach shows clearly where the `WaitGroup` is created and where it ends.

Making it a global variable or keeping it for a long time between unrelated jobs can make the code's lifecycle harder to understand.

## Common mistakes

### Calling `Add` inside the goroutine

The wrong approach:

```go
go func() {
	wg.Add(1)
	defer wg.Done()
	work()
}()

wg.Wait()
```

Here `Wait()` may run before the counter is increased.

As a result, `Wait()` sees the counter as `0` and returns immediately.

The correct approach:

```go
wg.Add(1)

go func() {
	defer wg.Done()
	work()
}()
```

The main rule:

> First add the job to the counter, then start the goroutine.

### Forgetting `Done`

If:

```go
wg.Add(1)
```

was called, the corresponding job must eventually decrease the counter.

Otherwise:

```go
wg.Wait()
```

never returns.

That is why at the start of a worker function one usually writes:

```go
defer wg.Done()
```

This is especially useful in functions with several `return` statements.

### Passing a `WaitGroup` by value

Wrong:

```go
func work(wg sync.WaitGroup)
```

This may create a separate copy.

Correct:

```go
func work(wg *sync.WaitGroup)
```

and:

```go
go work(&wg)
```

Don't copy a `WaitGroup` that has started being used.

### Thinking `WaitGroup` protects results

`WaitGroup` only waits for the jobs to finish.

For example, if several goroutines write to one shared `map`, the presence of a `WaitGroup` does not make this operation safe.

The following idea is wrong:

```text
there is a WaitGroup -> so concurrent writes are safe
```

The correct understanding:

```text
there is a WaitGroup -> you can wait for all registered jobs to finish
```

Protecting shared memory needs separate synchronization.

### Guessing the number of `Add` and `Done` calls

Managing the counter in a place disconnected from the number of jobs being run can lead to errors.

For example:

```go
wg.Add(10)

for _, job := range jobs {
	go ...
}
```

If later the number of `jobs` differs from `10`, the counter and the real number of jobs no longer match.

It is often safer to write:

```go
wg.Add(len(jobs))
```

or in one place together with each job:

```go
for _, job := range jobs {
	wg.Add(1)

	go func() {
		defer wg.Done()
		// ...
	}()
}
```

Then if the code changes, there is less chance that the counter drifts away from the number of jobs.

## What do interviews focus on?

When asked about `sync.WaitGroup`, knowing only its syntax is not enough.

It is important to understand the following points:

* `WaitGroup` manages an internal counter;
* `Add(n)` increases the counter;
* `Done()` decreases the counter by one;
* when the counter becomes zero, `Wait()` returns;
* a positive `Add(1)` must run before the goroutine is started;
* `Done()` is usually written with `defer`;
* if there are not enough `Done()` calls, `Wait()` may never return;
* if there are too many `Done()` calls, the counter becomes negative and a runtime panic occurs;
* a `WaitGroup` must not be copied once it has started being used;
* a `*sync.WaitGroup` is usually passed to a helper function;
* `WaitGroup` does not return results;
* it does not handle errors;
* it does not provide cancellation;
* it does not set a concurrency limit;
* it does not protect shared memory from data races;
* writes before `Done()` are visible to the waiting goroutine after the corresponding `Wait()` returns;
* if worker goroutines concurrently write to the same memory, separate synchronization is still required.

## Examples

### 1. Waiting for one goroutine

This example shows the simplest case of `WaitGroup`.

One helper goroutine is started. And `main()` waits for it to finish.

```go
package main

import (
	"fmt"
	"sync"
)

func main() {
	var wg sync.WaitGroup
	wg.Add(1)

	go func() {
		defer wg.Done()
		fmt.Println("The work is done")
	}()

	wg.Wait()
	fmt.Println("main finished")
}
```

First, with:

```go
var wg sync.WaitGroup
```

a zero-value `WaitGroup` is created.

Then:

```go
wg.Add(1)
```

registers one unfinished job.

The counter becomes:

```text
0 -> 1
```

Inside the goroutine we wrote:

```go
defer wg.Done()
```

When the goroutine finishes, the counter drops:

```text
1 -> 0
```

And `main()` waits for exactly this state through:

```go
wg.Wait()
```

Only after that is:

```text
main finished
```

printed.

The main rule of this example: `Add(1)` runs before the work starts, and `Done()` when the work finishes.

### 2. Registering each job in a loop

In this example three goroutines are created.

Before each goroutine starts, the corresponding job is added to the `WaitGroup`.

```go
package main

import (
	"fmt"
	"sync"
)

func main() {
	var wg sync.WaitGroup

	for id := 1; id <= 3; id++ {
		wg.Add(1)

		go func(workerID int) {
			defer wg.Done()
			fmt.Println("Worker:", workerID)
		}(id)
	}

	wg.Wait()
}
```

The loop runs three times:

```text
id = 1
id = 2
id = 3
```

On each iteration:

```go
wg.Add(1)
```

runs.

That is why, after three goroutines are created, the counter is logically `3`.

Each goroutine calls `Done()` once:

```text
3 -> 2 -> 1 -> 0
```

The `id` value is passed to the anonymous function as an argument:

```go
}(id)
```

and received through:

```go
func(workerID int)
```

This shows explicitly which worker ID each goroutine works with.

The order in which the `Worker:` lines are printed is not guaranteed. For example, they may appear in the order `3`, `1`, `2`.

The main rule in this example: `Add(1)` runs not inside the goroutine but before the `go` call.

### 3. Adding the number of jobs at once

It is not necessary to call `Add(1)` on every iteration of the loop.

If the number of jobs is known in advance, they can be added to the counter at once.

```go
package main

import (
	"fmt"
	"sync"
)

func main() {
	files := []string{"a.txt", "b.txt", "c.txt"}

	var wg sync.WaitGroup
	wg.Add(len(files))

	for _, file := range files {
		go func(name string) {
			defer wg.Done()
			fmt.Println("Checked:", name)
		}(file)
	}

	wg.Wait()
}
```

Here the value of:

```go
len(files)
```

is:

```text
3
```

That is why:

```go
wg.Add(len(files))
```

gives the same result as:

```go
wg.Add(3)
```

The counter waits for three jobs.

Each goroutine must call `Done()` once.

If later a new element is added to the `files` list:

```go
files := []string{"a.txt", "b.txt", "c.txt", "d.txt"}
```

`len(files)` automatically becomes `4`.

This is safer than the hard-coded:

```go
wg.Add(3)
```

The main rule of this example: if the number of jobs is known, the counter can be computed from that source.

### 4. Passing a `WaitGroup` to a helper function by pointer

In this example the worker logic is moved into a separate `process()` function.

```go
package main

import (
	"fmt"
	"sync"
)

func process(name string, wg *sync.WaitGroup) {
	defer wg.Done()
	fmt.Println("Processed:", name)
}

func main() {
	var wg sync.WaitGroup
	items := []string{"image", "video"}

	for _, item := range items {
		wg.Add(1)
		go process(item, &wg)
	}

	wg.Wait()
}
```

The `process()` function takes:

```go
wg *sync.WaitGroup
```

This says the `WaitGroup` is not copied by value.

When calling it:

```go
go process(item, &wg)
```

is used.

`&wg` is the address of the original `WaitGroup` inside `main()`.

That is why inside `process()`:

```go
wg.Done()
```

decreases exactly the counter `main()` is waiting on.

If the function had been written like this:

```go
func process(name string, wg sync.WaitGroup)
```

`wg` could have been copied, and the worker would not have changed the original counter.

The main rule of this example: pass a `WaitGroup` that has started being used to a helper function by pointer.

### 5. Running `Done()` even on early return

This example shows why `defer wg.Done()` is useful.

Some values do not pass the check, and the function does an early `return`.

```go
package main

import (
	"fmt"
	"sync"
)

func validate(value int, wg *sync.WaitGroup) {
	defer wg.Done()

	if value < 0 {
		fmt.Println("Negative value skipped:", value)
		return
	}

	fmt.Println("Accepted:", value)
}

func main() {
	values := []int{5, -2, 8}

	var wg sync.WaitGroup
	wg.Add(len(values))

	for _, value := range values {
		go validate(value, &wg)
	}

	wg.Wait()
}
```

The values:

```text
5
-2
8
```

For `-2` the following condition holds:

```go
if value < 0
```

and the function finishes early with:

```go
return
```

But `Done()` was deferred in advance:

```go
defer wg.Done()
```

That is why, even with an early `return`, `Done()` is called.

If `Done()` had been written only at the end of the function:

```go
func validate(value int, wg *sync.WaitGroup) {
	if value < 0 {
		return
	}

	wg.Done()
}
```

it would not run at all on the negative value path.

As a result, the counter might never drop to zero.

The main rule of this example: in a worker function, `defer wg.Done()` handles early `return` cases more safely.

### 6. Writing results to different slice elements

In this example several goroutines perform calculations in parallel.

Each writes its result to a different index of a slice created in advance.

```go
package main

import (
	"fmt"
	"sync"
)

func main() {
	numbers := []int{2, 3, 4}
	results := make([]int, len(numbers))

	var wg sync.WaitGroup
	wg.Add(len(numbers))

	for index, number := range numbers {
		go func(i, value int) {
			defer wg.Done()
			results[i] = value * value
		}(index, number)
	}

	wg.Wait()
	fmt.Println(results)
}
```

The initial values:

```text
numbers = [2 3 4]
results = [0 0 0]
```

The goroutines do roughly the following work:

```text
results[0] = 2 * 2
results[1] = 3 * 3
results[2] = 4 * 4
```

As a result we get:

```text
[4 9 16]
```

Here each goroutine writes to a different index:

```text
goroutine A -> results[0]
goroutine B -> results[1]
goroutine C -> results[2]
```

The length of `results` is fixed in advance:

```go
make([]int, len(numbers))
```

That is why no concurrent `append` happens.

And `main()` does not read the results until:

```go
wg.Wait()
```

returns.

This keeps the writes of the workers and the reads of `main` from happening at the same time.

The main rule of this example: `WaitGroup` does not store results itself, but it helps determine when to read the results after all workers have finished.

### 7. Reusing a `WaitGroup` in sequential stages

In this example one `WaitGroup` is used sequentially for two independent stages.

```go
package main

import (
	"fmt"
	"sync"
)

func main() {
	var wg sync.WaitGroup

	wg.Add(1)
	go func() {
		defer wg.Done()
		fmt.Println("First stage")
	}()
	wg.Wait()

	wg.Add(1)
	go func() {
		defer wg.Done()
		fmt.Println("Second stage")
	}()
	wg.Wait()
}
```

In the first stage:

```text
Add(1)
counter = 1
```

When the goroutine finishes:

```text
Done()
counter = 0
```

The first:

```go
wg.Wait()
```

returns.

At this point the first group has completely finished.

Then the second stage starts:

```go
wg.Add(1)
```

The counter again becomes:

```text
0 -> 1
```

When the second goroutine finishes:

```text
1 -> 0
```

and the second `Wait()` returns.

The important point: the new group starts after the first group has completely finished.

The main rule of this example: a `WaitGroup` can be reused, but the waiting cycle of the previous group must have finished.

### 8. Waiting for one group from several places

Several goroutines can call the `Wait()` method of one `WaitGroup`.

In the following example two observers wait for one worker to finish.

```go
package main

import (
	"fmt"
	"sync"
)

func main() {
	var workers sync.WaitGroup
	var observers sync.WaitGroup

	workers.Add(1)

	go func() {
		defer workers.Done()
		fmt.Println("The main work finished")
	}()

	observers.Add(2)

	for id := 1; id <= 2; id++ {
		go func(observerID int) {
			defer observers.Done()

			workers.Wait()
			fmt.Println("Observer notified:", observerID)
		}(id)
	}

	observers.Wait()
}
```

There are two separate `WaitGroup`s here.

The first:

```go
workers
```

tracks the main worker's job.

The second:

```go
observers
```

tracks the completion of the two observer goroutines.

For the main worker:

```go
workers.Add(1)
```

runs.

The two observers call:

```go
workers.Wait()
```

When the counter drops to zero, both `Wait()` calls can continue.

Then each observer prints the line:

```go
fmt.Println("Observer notified:", observerID)
```

And `main()` waits for both observers to finish through:

```go
observers.Wait()
```

The output may be roughly:

```text
The main work finished
Observer notified: 2
Observer notified: 1
```

The order of the observers is not guaranteed.

The main rule of this example: several goroutines can wait on one `WaitGroup`.

### 9. Creating an inner group for each outer job

Sometimes a parallel job is itself split into several smaller parallel jobs.

In such a case outer and inner `WaitGroup`s can be used.

```go
package main

import (
	"fmt"
	"sync"
)

func section(name string, outer *sync.WaitGroup) {
	defer outer.Done()

	var inner sync.WaitGroup
	inner.Add(2)

	for part := 1; part <= 2; part++ {
		go func(number int) {
			defer inner.Done()
			fmt.Println(name, "part", number)
		}(part)
	}

	inner.Wait()
}

func main() {
	var outer sync.WaitGroup

	outer.Add(2)

	go section("A", &outer)
	go section("B", &outer)

	outer.Wait()
}
```

`main()` creates two outer jobs:

```text
section A
section B
```

That is why:

```go
outer.Add(2)
```

is called.

Inside each `section()` a separate local:

```go
var inner sync.WaitGroup
```

is created.

The important point: the `inner` values of sections `A` and `B` are independent of each other.

Each section has two parts:

```go
inner.Add(2)
```

Then separate goroutines are created for:

```text
A part 1
A part 2

B part 1
B part 2
```

Each `section()` waits for its own two inner goroutines through:

```go
inner.Wait()
```

Only after they finish does the `section()` function return.

When the function returns:

```go
defer outer.Done()
```

runs.

So `outer` decreases only after all the work inside the section has completely finished.

The logical structure is as follows:

```text
outer
├── section A
│   ├── part 1
│   └── part 2
│
└── section B
    ├── part 1
    └── part 2
```

The main rule of this example: each higher-level job can wait for its inner goroutines through its own local `WaitGroup`.

### 10. Safely waiting on an empty list of jobs

`WaitGroup` works with its zero value. That is why, even if there are no jobs to run, there is no need to write a special condition.

```go
package main

import (
	"fmt"
	"sync"
)

func main() {
	jobs := []string{}

	var wg sync.WaitGroup
	wg.Add(len(jobs))

	for _, job := range jobs {
		go func(name string) {
			defer wg.Done()
			fmt.Println(name)
		}(job)
	}

	wg.Wait()
	fmt.Println("No jobs to run")
}
```

Here:

```go
jobs := []string{}
```

is an empty slice.

So the value of:

```go
len(jobs)
```

is:

```text
0
```

That is why:

```go
wg.Add(len(jobs))
```

is actually equal to:

```go
wg.Add(0)
```

The counter does not change:

```text
counter = 0
```

The loop:

```go
for _, job := range jobs
```

does not run even once.

The next:

```go
wg.Wait()
```

returns immediately because the counter is already zero.

Output:

```text
No jobs to run
```

For this, a separate check:

```go
if len(jobs) == 0 {
	// ...
}
```

is not needed.

The main rule of this example: `WaitGroup` works naturally with an empty group too. If the counter is zero, `Wait()` returns immediately.
