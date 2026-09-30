# Benchmarks

A benchmark helps measure how long a certain operation in a program takes and how much memory it allocates. For this, the code being measured is run many times over.

## Writing a benchmark

Go benchmarks are usually written in a `_test.go` file. The name of a benchmark function starts with `Benchmark`, and it takes a `*testing.B`:

```go
package text

import (
	"strings"
	"testing"
)

var result string

func BenchmarkJoin(b *testing.B) {
	parts := []string{"go", "lang", "uz"}
	b.ReportAllocs()

	for i := 0; i < b.N; i++ {
		result = strings.Join(parts, "-")
	}
}
```

This benchmark measures the performance of the `strings.Join()` operation.

The important line:

```go
for i := 0; i < b.N; i++ {
```

Here `b.N` is not an ordinary number fixed in advance. The benchmark runner controls its value itself.

At first `b.N` may be small. Then Go runs the benchmark again and again and increases `b.N`. The goal is for the measurement to last long enough and for the result to be relatively stable.

That is why the following form is usually used inside a benchmark:

```go
for i := 0; i < b.N; i++ {
	// the operation being measured
}
```

The benchmark result is written to the package-level variable `result`:

```go
var result string
```

and:

```go
result = strings.Join(parts, "-")
```

The reason is to show the compiler that the benchmark result is used. If the computed value is not used anywhere, the compiler may in some cases optimize away the unneeded computation.

The benchmark can be run like this:

```bash
go test -bench=.
```

This command runs the benchmarks in the current package.

To also see information about memory allocations:

```bash
go test -bench=. -benchmem
```

is used.

The following metrics may appear in the benchmark result:

* `ns/op` — how many nanoseconds one operation took on average;
* `B/op` — how many bytes of memory were allocated per operation on average;
* `allocs/op` — how many allocations happened per operation on average.

For example, the result may look like this:

```text
BenchmarkJoin-8    12000000    95.0 ns/op    16 B/op    1 allocs/op
```

The exact numbers here vary depending on the computer, the Go version and the environment.

`b.ReportAllocs()` asks to add allocation information to the benchmark result:

```go
b.ReportAllocs()
```

The same information can also be printed from the command line with `-benchmem`.

A benchmark can also contain one-time setup code. For example, if you need to create a big slice or prepare test data in advance, that time may not belong to the main operation being measured.

In such a case you can do the setup before the loop and then call:

```go
b.ResetTimer()
```

`ResetTimer()` clears the time and benchmark statistics collected before it. After that the main measurement starts.

## Interpreting results correctly

Seeing a benchmark result is easy. Interpreting it correctly requires separate attention.

A benchmark gives a result only for the exact:

* code;
* input data;
* computer;
* Go version;
* operating system;
* CPU state;
* other processes

that were tested.

That is why it is wrong to conclude from a microbenchmark result:

> This solution will run exactly this fast on a real server too.

A microbenchmark usually measures a very small operation in isolation. A real program, on the other hand, has other costs too:

* network I/O;
* the database;
* the disk;
* locks;
* the scheduler;
* the garbage collector;
* other goroutines;
* request parsing;
* serialization.

That is why a microbenchmark can be useful for comparing two implementations, but on its own it does not prove the overall latency the user sees.

The following mistakes are common in microbenchmarks.

### The compiler may remove the computation

If the result is not used anywhere, the compiler may find some computations unneeded.

For example, if a value is only computed and then not used, there is a chance the benchmark does not measure the real work.

That is why many benchmarks write the important result to a package-level or otherwise externally observable place.

### Setup may be more expensive than the main operation

Imagine you want to measure one map lookup. But if you create a huge map on every iteration, a large part of the result measures map creation time.

Such a benchmark shows mainly the setup cost, not the operation you had in mind.

That is why you may need to do the setup separately or temporarily stop the timer.

### Overly simple data may not represent the real situation

For example, a benchmark working on a slice of 3 elements may not fully represent the behavior of a slice of a million elements in production.

In the same way, always the same string or data that always sits in the cache may differ from the real workload.

### The state of the computer affects the result

Background processes, CPU frequency scaling, thermal throttling and the scheduler state can change the benchmark result.

That is why relying on a single measurement is not a good idea.

When comparing benchmarks, it helps to run them several times:

```bash
go test -bench=. -count=5
```

The important point is to take the before and after results in the same environment as far as possible.

First you need to measure the problem. Then you need to optimize the bottleneck that really matters for performance.

Gaining a few nanoseconds in a microbenchmark alone does not always give a noticeable benefit for the real program.

## Examples

### 1. Measuring the sum of integers

This example shows writing a benchmark in an ordinary `_test.go` file.

The benchmark repeatedly runs the operation of summing the numbers from `1` to `100`.

```go
package benchmark

import "testing"

var sumResult int

func BenchmarkSum(b *testing.B) {
	for i := 0; i < b.N; i++ {
		sum := 0

		for number := 1; number <= 100; number++ {
			sum += number
		}

		sumResult = sum
	}
}
```

First:

```go
sum := 0
```

is written.

The reason the sum starts from `0` is simple:

```text
0 + x = x
```

Adding `0` does not change the result.

The next loop:

```go
for number := 1; number <= 100; number++ {
	sum += number
}
```

increases the value of `number` step by step:

```text
1
2
3
...
99
100
```

Because `<= 100` is used here, `100` is also included in the sum.

After the calculation finishes:

```go
sumResult = sum
```

runs.

`sumResult` is declared as a global variable:

```go
var sumResult int
```

This writes the benchmark result to an externally observable place. As a result, the chance that the compiler removes the whole computation as unused code decreases.

The main rule in this example is that the main operation inside the benchmark runs `b.N` times.

### 2. The cost of joining strings with `+`

In this example joining several strings with the `+` operator is benchmarked.

```go
package benchmark

import "testing"

var textResult string

func BenchmarkStringPlus(b *testing.B) {
	b.ReportAllocs()

	for i := 0; i < b.N; i++ {
		textResult = "Go" + " " + "programming" + " " + "language"
	}
}
```

Here:

```go
b.ReportAllocs()
```

adds allocation information to the benchmark result.

The command `go test -bench=. -benchmem` shows how many allocations happened per operation on average.

But there is a subtle point in this example.

All the parts being joined are constant strings:

```go
"Go"
" "
"programming"
" "
"language"
```

The compiler may join such an expression in advance at compile time.

That is, even though the source code says:

```go
"Go" + " " + "programming" + " " + "language"
```

a separate string concatenation does not have to happen at runtime every time.

That is why this benchmark result does not give the general conclusion:

> In general the `+` operator always makes this many allocations when joining strings.

It only measures the behavior of exactly this form of code.

### 3. Reserving capacity for `strings.Builder`

In this example a string is built with `strings.Builder`.

The capacity the builder will need is given in advance through `Grow()`.

```go
package benchmark

import (
	"strings"
	"testing"
)

var builderResult string

func BenchmarkBuilder(b *testing.B) {
	b.ReportAllocs()

	for i := 0; i < b.N; i++ {
		var builder strings.Builder

		builder.Grow(18)
		builder.WriteString("Go")
		builder.WriteString(" language basics")

		builderResult = builder.String()
	}
}
```

First an empty builder is created:

```go
var builder strings.Builder
```

Then:

```go
builder.Grow(18)
```

is called.

The final string is:

```text
Go language basics
```

Its length is `18` bytes.

That is why the builder is told in advance that it needs at least `18` bytes of capacity.

Then two parts are written:

```go
builder.WriteString("Go")
builder.WriteString(" language basics")
```

If the reserved capacity is enough, the builder may not need an extra allocation to grow the buffer.

The final string is obtained through:

```go
builderResult = builder.String()
```

This example shows the main purpose of `Grow()`: if the needed size is estimated in advance, extra allocations during buffer growth can be reduced.

### 4. Excluding setup time with `ResetTimer()`

In this example a slice is prepared before the benchmark.

Creating and filling the slice is not the main operation being benchmarked. That is why this time is excluded from the measurement.

```go
package benchmark

import "testing"

var lastValue int

func BenchmarkLastValue(b *testing.B) {
	numbers := make([]int, 1000)

	for i := range numbers {
		numbers[i] = i
	}

	b.ResetTimer()

	for i := 0; i < b.N; i++ {
		lastValue = numbers[len(numbers)-1]
	}
}
```

First, with:

```go
numbers := make([]int, 1000)
```

a slice of length `1000` is created.

Its valid indexes are:

```text
0
1
2
...
998
999
```

Then the slice is filled with the index values:

```go
for i := range numbers {
	numbers[i] = i
}
```

After that:

```go
b.ResetTimer()
```

is called.

The setup before this point is not included in the benchmark time.

In the main benchmark operation:

```go
numbers[len(numbers)-1]
```

is used.

The value of `len(numbers)` is:

```text
1000
```

That is why we get:

```text
len(numbers) - 1
1000 - 1
999
```

So the last element is taken.

The main rule in this example is to separate the setup cost outside the benchmark with `ResetTimer()`.

### 5. Temporarily stopping for setup

In this example the timer is stopped by hand and then started again.

```go
package benchmark

import "testing"

var lookupResult bool

func BenchmarkLookup(b *testing.B) {
	b.StopTimer()

	values := map[string]int{
		"go":  1,
		"api": 2,
	}

	b.StartTimer()

	for i := 0; i < b.N; i++ {
		_, lookupResult = values["go"]
	}
}
```

First:

```go
b.StopTimer()
```

temporarily stops the timer.

Then a map is created:

```go
values := map[string]int{
	"go":  1,
	"api": 2,
}
```

In this example creating the map is not the operation being measured.

That is why, once the map is ready, the benchmark timer is started again with:

```go
b.StartTimer()
```

Inside the loop:

```go
_, lookupResult = values["go"]
```

performs a map lookup.

A map lookup can return two values:

```go
value, ok := values["go"]
```

In this example the value itself is not needed. That is why the first result is discarded with `_`.

`lookupResult` stores whether the key was found.

`"go"` exists in this map, so it is `true`.

This example shows separating the setup and the main benchmark operation using the timer.

### 6. Reporting the input size with `SetBytes()`

In some benchmarks what matters is not only how long one operation took, but also how much data was processed.

`SetBytes()` is used in such cases.

```go
package benchmark

import (
	"strings"
	"testing"
)

var containsResult bool

func BenchmarkContains(b *testing.B) {
	text := strings.Repeat("a", 1024)

	b.SetBytes(int64(len(text)))

	for i := 0; i < b.N; i++ {
		containsResult = strings.Contains(text, "z")
	}
}
```

First, with:

```go
text := strings.Repeat("a", 1024)
```

a string of `1024` `a` characters is created.

Because these characters are ASCII, each takes one byte.

So the size of the string is:

```text
1024 bytes
```

`1024` bytes equals:

```text
1 KiB
```

Then:

```go
b.SetBytes(int64(len(text)))
```

tells the benchmark runner roughly how many bytes are processed in each operation.

The main operation:

```go
strings.Contains(text, "z")
```

There is no `z` in the text.

That is why the search finds no matching character and, for this input, keeps searching through the string.

`SetBytes()` lets the benchmark result compute a throughput metric, for example `MB/s`.

This is especially useful for code that does parsing, encoding, hashing or works with large buffers.

### 7. Reporting a custom metric

Go benchmarks are not limited to the standard `ns/op` or allocation metrics.

With `ReportMetric()` you can also print a metric you need.

```go
package benchmark

import "testing"

var productResult int

func BenchmarkProduct(b *testing.B) {
	numbers := []int{2, 3, 4, 5}

	b.ReportMetric(float64(len(numbers)), "elements/op")

	for i := 0; i < b.N; i++ {
		product := 1

		for _, number := range numbers {
			product *= number
		}

		productResult = product
	}
}
```

Here the slice:

```go
numbers := []int{2, 3, 4, 5}
```

consists of four elements.

That is why the result of:

```go
len(numbers)
```

is:

```text
4
```

Then:

```go
b.ReportMetric(float64(len(numbers)), "elements/op")
```

adds a metric to the benchmark result meaning:

```text
4 elements/op
```

The product starts from:

```go
product := 1
```

The reason:

```text
1 × x = x
```

`1` is the neutral value for multiplication.

The calculation steps:

```text
1 × 2 = 2
2 × 3 = 6
6 × 4 = 24
24 × 5 = 120
```

The final result is:

```text
120
```

This example shows that you can add your own domain-specific metric to a benchmark.

### 8. Repeating a benchmark several times

A single benchmark result may by chance come out faster or slower than usual.

That is why, when comparing performance, it helps to run the benchmark several times.

```go
package benchmark

import "testing"

var compareResult int

func BenchmarkCalculation(b *testing.B) {
	a, multiplier, extra := 25, 4, 10

	for i := 0; i < b.N; i++ {
		compareResult = (a * multiplier) + extra
	}
}
```

In this example the calculation:

```go
(25 * 4) + 10
```

is performed.

Step by step:

```text
25 × 4 = 100
100 + 10 = 110
```

But the main idea of this example is not the calculation itself. The main goal is to show repeating a benchmark several times.

A real `_test.go` benchmark can be run five times like this:

```bash
go test -bench=. -count=5
```

Here:

```text
-count=5
```

repeats the benchmark run five times.

Why is this useful?

Because a single result may come out under the influence of temporary factors:

* another process may be using the CPU;
* the scheduler may have distributed work differently;
* the CPU frequency may have changed;
* the cache state may differ.

Several measurements help you see the spread of the result.

But the benchmarks being compared should be run in the same environment as far as possible.

Detecting data races in concurrent code is covered separately in the Race detector lesson.
