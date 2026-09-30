# Race detector

## Detecting data races

A data race is one of the important errors in concurrent programming.

Put simply, a data race occurs when:

1. at least two goroutines access the same memory address;
2. these accesses happen without the necessary synchronization;
3. at least one of the accesses is a write.

For example, if two goroutines change the same variable at the same time, a data race may occur.

To run Go tests with the race detector:

```bash
go test -race ./...
```

is used.

Here:

* `-race` — enables the race detector;
* `./...` — recursively checks the packages under the current module.

An ordinary program can also be run with the race detector:

```bash
go run -race main.go
```

The race detector adds extra instrumentation to the program code. It needs to track memory accesses.

That is why a program running with `-race`:

* may run slower than usual;
* may use more memory.

So a performance result obtained with the race detector should not be used as a production performance measurement.

> **Warning**
>
> The race detector only watches the code paths that actually ran during program execution. For example, if a data
> race is inside a rarely taken branch and the tests do not run that branch, the detector does not see it.
>
> That is why `-race` printing no warning does not mean there is no data race in all possible executions.
> Try to actually exercise the important concurrent code paths through tests.

When the race detector finds a data race, the report usually shows the conflicting memory accesses.

It also gives the stack traces of the goroutines that performed those accesses.

This information helps determine where the problem comes from.

Simply hiding a race warning is not the right solution.

The main question should be:

> Which goroutine owns this shared state, and how should other goroutines access it safely?

Depending on the problem, different synchronization tools can be used:

* `sync.Mutex`;
* `sync.RWMutex`;
* channels;
* atomic operations;
* an architecture where only one goroutine manages the state.

Which tool is needed depends on the purpose of the code.

## Examples

### 1. Seeing a data race on a shared variable

This example deliberately writes wrong concurrent code.

Two goroutines write to the same `value` variable.

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	value := 0

	go func() {
		value = 1
	}()

	go func() {
		value = 2
	}()

	time.Sleep(100 * time.Millisecond)
	fmt.Println(value)
}
```

First:

```go
value := 0
```

is written.

The zero value of the `int` type is `0`, but here the value is also explicitly given as `0`.

Then the first goroutine:

```go
go func() {
	value = 1
}()
```

writes `1` to `value`.

And the second goroutine:

```go
go func() {
	value = 2
}()
```

writes `2` to the same variable.

Both goroutines are writing to the same memory address.

Between them there is no:

* mutex;
* channel;
* atomic operation;
* other synchronization.

That is why this is a data race.

When the program is run with:

```bash
go run -race main.go
```

the race detector may detect the conflicting memory writes.

The next line:

```go
time.Sleep(100 * time.Millisecond)
```

has an important subtlety.

`Sleep()` gives the goroutines time to run. But it does not synchronize them.

That is:

```go
time.Sleep(...)
```

does not fix the data race.

It is used only so that `main()` does not finish too quickly in this small example.

In production code, waiting for goroutines to finish usually needs an explicit synchronization mechanism.

For example, depending on the situation, `sync.WaitGroup`, a channel or another solution can be used.

### 2. Writing to different slice elements

In this example two goroutines also work with one slice.

But they write to different elements of the slice.

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	values := make([]int, 2)

	go func() {
		values[0] = 10
	}()

	go func() {
		values[1] = 20
	}()

	time.Sleep(100 * time.Millisecond)
	fmt.Println("The writes are done")
}
```

First, with:

```go
values := make([]int, 2)
```

a slice of length `2` is created.

Its indexes are:

```text
0
1
```

The first goroutine:

```go
values[0] = 10
```

writes to element `0`.

And the second goroutine:

```go
values[1] = 20
```

writes to element `1`.

These two slice elements refer to separate memory locations.

That is why these two writes are not considered conflicting accesses.

Besides that, while the goroutines are running, `main()` does not read the values of:

```go
values[0]
```

or:

```go
values[1]
```

It only prints another text:

```go
fmt.Println("The writes are done")
```

That is why:

```bash
go run -race main.go
```

should not report a data race for writing to these two elements.

But here too:

```go
time.Sleep(100 * time.Millisecond)
```

is not a synchronization mechanism that reliably confirms the goroutines have finished.

In this small example it is used only to give the goroutines a chance to run.

In real code, if you need to know exactly when goroutines have finished, you should use a proper synchronization tool instead of `Sleep()`.
