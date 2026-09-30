# Tools for checking Go code

Checking code in a Go project is not only about running tests. Different tools check different aspects of the code.

For example:

* formatting tools make the way code is written consistent;
* static analysis tools try to find suspicious constructs before the code runs;
* tests check that the program works as expected;
* the race detector looks for data races in concurrent code.

The jobs of these checks differ from each other. That is why one of them succeeding does not mean the others need not be run.

In practice it helps to run them one after another in the same order. This helps catch errors early, both before review and before releasing the code.

## Formatting

In Go the main tool for bringing code to the standard style is `gofmt`.

Formatting one file:

```bash
gofmt -w main.go
```

The `-w` flag matters here.

`gofmt` formats the code, and `-w` writes the result back into the same file. That is, the command does not just show which changes are needed; it actually changes the `main.go` file.

For example, wrong indentation, extra spaces or some layouts that do not match the Go standard are fixed automatically.

To format the packages of the whole module through the Go command:

```bash
go fmt ./...
```

`go fmt` first selects the packages. Then it runs `gofmt` on the Go files in those packages.

In this command:

```text
./...
```

is used to select the current package inside the current module as well as the packages under it.

The job of formatting is to standardize how code looks. For example, if two developers wrote the same code with different indentation, `gofmt` brings both to the same look.

But there is an important limitation here.

Formatting does not check business logic.

For example, if:

```go
total := price - tax
```

should actually be:

```go
total := price + tax
```

`gofmt` does not detect this. Because both pieces of code are correct syntactically and in terms of format.

That is why formatting should be seen as the first stage of checking code quality, not as a complete check.

## Static analysis

`go vet` analyzes code without running it.

It looks for certain constructs that the compiler may accept but that are quite likely to be wrong or suspicious in practice.

Checking the whole module:

```bash
go vet ./...
```

For example, `go vet` can detect problems such as:

* a format string not matching the argument type in functions like `fmt.Printf`;
* copying certain synchronization values that must not be copied;
* other suspicious constructs the standard analyzers can detect.

For example:

```go
count := "three"
fmt.Printf("%d\n", count)
```

This code may compile. But `%d` is meant for an integer, while `count` is a `string`.

`go vet` can point out such a mismatch in advance.

This is the main benefit of static analysis: finding a problem not while the program is running, but before that.

But `go vet` does not find every kind of error either.

For example, if a business rule is written incorrectly:

```go
if age > 18 {
	allow()
}
```

and the requirement is actually `age >= 18`, `go vet` does not know this. Because that requires understanding the program's requirements.

That is why `go vet` does not replace tests.

## Tests and race checks

To run the tests of the whole module:

```bash
go test ./...
```

`go test` compiles the selected packages and runs their tests.

If tests are written, they check the expected behavior of the code.

For example, given the following function:

```go
func Add(a, b int) int {
	return a + b
}
```

a test can check that it returns `5` for `2 + 3`.

Here a test answers not the question of whether the code runs, but whether the code gives the required result.

Concurrent code may need an additional check:

```bash
go test -race ./...
```

The `-race` flag enables the race detector.

An ordinary test checks the expected behavior. The race detector watches for signs of data races in the concurrent code paths the tests executed. Their jobs are not the same.

The definition of a data race, practical examples and the detector's limitations are explained in detail in the Race detector lesson.

## Recommended sequence

For a small Go project the following checks can be a good starting workflow:

```bash
go fmt ./...
go vet ./...
go test ./...
go test -race ./...
```

The meaning of this order is as follows.

First:

```bash
go fmt ./...
```

brings the code to the standard format.

Then:

```bash
go vet ./...
```

runs static analysis.

Next:

```bash
go test ./...
```

runs the ordinary tests.

Finally:

```bash
go test -race ./...
```

runs the tests again with the race detector.

Formatting can change files. Especially if `go fmt` or `gofmt -w` is used, real changes appear in the files in the repository.

That is why after the checks it helps to look at:

```bash
git diff
```

This lets you check which lines changed as a result of formatting or other work.

The goal is to commit only the expected changes.

The race check runs slower than an ordinary test. The reason is that the race detector uses extra instrumentation and runtime checks to track memory accesses.

That is why using `-race` on every very fast local iteration may not always be convenient.

But in projects with a lot of concurrent code, running it in CI or before a release is very useful.

In large projects these commands are usually also run inside the CI pipeline.

For example, if the local environment uses:

```bash
go vet ./...
go test ./...
```

and CI runs completely different commands, a problem the developer did not see locally may appear only after the push.

If local and CI use the same or very similar checks, problems are usually detected earlier.

This also simplifies the review process. Instead of spending time on formatting or simple static problems, the reviewer can pay more attention to the architecture and logic of the code.

## The limits of the tools

Each tool has a specific job.

* formatting makes code style consistent;
* `go vet` finds certain suspicious constructs;
* tests check the required behavior;
* the race detector looks for data races in the executed code paths.

One of these tools succeeding does not make another unnecessary.

For example:

```text
go fmt succeeded
```

does not mean the business logic of the code is correct.

In the same way:

```text
go test succeeded
```

does not mean there are no races.

Even if `go vet` finds no problems, a wrong algorithm or a business rule that does not match the requirements may remain.

Besides that, these tools are not meant for fully analyzing performance problems.

Performance needs other tools.

For example:

* benchmarks;
* CPU profiling;
* memory profiling;
* execution trace.

That is why there is no "one universal tool" in the process of checking code. Each tool detects a separate kind of problem.

## Examples

### 1. Seeing the difference with `gofmt -d`

This example shows how to see the result of `gofmt` formatting without writing it to the file.

```go
package main

import "fmt"

func main() {
	numbers := []int{3, 1, 4}
	fmt.Println(numbers)
}
```

If the `main.go` file was deliberately written with wrong indentation or layout, you can run the following command:

```bash
gofmt -d main.go
```

The `-d` flag is used in the sense of "show the diff".

It does not change the file.

Instead it prints the difference between the current code and the code `gofmt` recommends.

For example, the output shows in diff format which line should be removed and what it should be replaced with.

This is especially useful when checking in CI or before review. Because you can see whether a file meets the format requirement without touching it.

The code block above shows the standard look after `gofmt`.

The main rule: `gofmt -d` shows the format difference but does not change the file.

### 2. Formatting a file with `gofmt -w`

This example shows the standard layout of a `map` literal.

```go
package main

import "fmt"

func main() {
	ports := map[string]int{
		"http":  80,
		"https": 443,
	}
	fmt.Println(ports)
}
```

To format the file automatically:

```bash
gofmt -w main.go
```

This time `-w` is used.

So the result produced by `gofmt` is written directly into `main.go`.

`ports` is a `map` of `string` keys and `int` values.

It has the values:

```go
"http": 80
```

and:

```go
"https": 443
```

`80` is usually used as the HTTP port and `443` as the HTTPS port. In this example they were chosen to show the formatting result.

`gofmt` aligns the following parts to make them easier to read:

```go
"http":  80,
"https": 443,
```

This is only formatting.

`gofmt` does not check whether `80` or `443` really are the right ports for those protocols.

Even if you write:

```go
"http": 9999
```

`gofmt` happily formats the code.

So formatting tidies up the syntactic look but does not check the business or technical meaning of values.

### 3. Listing unformatted files

In this example a `struct` value is written in the standard format.

```go
package main

import "fmt"

type Server struct {
	Host string
	Port int
}

func main() {
	server := Server{
		Host: "localhost",
		Port: 8080,
	}
	fmt.Println(server)
}
```

To see the Go files in the current directory that need formatting:

```bash
gofmt -l .
```

The `-l` flag lists file names.

It does not change the files.

For example, if `main.go` does not have the standard `gofmt` look, the output may show:

```text
main.go
```

If no file name is printed, `gofmt` found no differences requiring formatting in the files it checked.

The part of the code:

```go
type Server struct {
	Host string
	Port int
}
```

declares a `struct` named `Server`.

Then its value is created with:

```go
server := Server{
	Host: "localhost",
	Port: 8080,
}
```

`8080` was chosen as an alternative HTTP port often seen in local development environments. This value does not affect the formatting purpose of the example.

The main rule: `gofmt -l` shows which files need formatting but does not change them.

### 4. Switching to a simpler form with `gofmt -s`

In this example a slice expression is deliberately written in a longer form.

```go
package main

import "fmt"

func main() {
	values := []int{10, 20, 30, 40}
	last := values[2:len(values)]
	fmt.Println(last)
}
```

Here:

```go
values[2:len(values)]
```

takes the part of the slice from index `2` to the end.

In Go indexes start from `0`:

```text
index 0 -> 10
index 1 -> 20
index 2 -> 30
index 3 -> 40
```

So starting from index `2` means starting from the third element.

The upper bound:

```go
len(values)
```

that is, `4`.

In a slice expression the upper bound is not included in the result.

That is why:

```go
values[2:4]
```

gives the following values:

```text
[30 40]
```

But in Go, when slicing to the end, you can omit the upper bound.

That is why, instead of:

```go
values[2:len(values)]
```

writing:

```go
values[2:]
```

is enough.

The following command:

```bash
gofmt -s -d main.go
```

may suggest this simplification in diff form.

Here `-s` enables the "simplify" mode, and `-d` shows the difference.

The main rule: `gofmt -s` can bring certain syntactic constructs to a simpler form without changing their meaning.

### 5. Checking the whole module with `go fmt`

This example has a small calculation function.

```go
package main

import "fmt"

func Total(prices []int) int {
	total := 0
	for _, price := range prices {
		total += price
	}
	return total
}

func main() {
	fmt.Println(Total([]int{12, 8, 5}))
}
```

If:

```bash
go fmt ./...
```

runs at the module root, the relevant packages of the current module are selected and formatted.

Now let's look at the code itself.

The function:

```go
func Total(prices []int) int
```

takes `[]int` and returns an `int`.

The sum starts from:

```go
total := 0
```

The reason is that no price has been added to the sum yet.

Then all values are added in turn with:

```go
for _, price := range prices {
	total += price
}
```

The calculation step by step:

```text
start: 0
0 + 12 = 12
12 + 8 = 20
20 + 5 = 25
```

The result is:

```text
25
```

But `go fmt` does not check this.

It only looks at the code format.

Even if the code mistakenly says:

```go
total -= price
```

that line may be correct in terms of format.

A test should check that the result really is `25`.

The main rule: `go fmt ./...` helps format the packages of the whole module but does not check functional correctness.

### 6. Finding a format string error with `go vet`

This example shows the practical benefit of `go vet`.

```go
package main

import "fmt"

func main() {
	count := "three"
	fmt.Printf("Number of files: %d\n", count)
}
```

The problem in this code is in the format specifier:

```go
%d
```

`%d` is meant for printing an integer.

But because of:

```go
count := "three"
```

the type of `count` is `string`.

So the format and the argument type do not match.

When `go run` runs, `fmt` may show this situation with a special diagnostic text.

But it is better to find the problem before running the code.

That is why:

```bash
go vet ./...
```

is used.

`go vet` can check whether the format string and the arguments match for functions in the `Printf` family.

The correct variant:

```go
fmt.Printf("Number of files: %s\n", count)
```

Here `%s` is suitable for a `string`.

Or, if `count` really should be a number, you can write:

```go
count := 3
fmt.Printf("Number of files: %d\n", count)
```

This example shows that `go vet` detects in advance certain suspicious constructs that the compiler may accept.

### 7. Checking package compilation with `go test`

In this example there is no separate test file.

```go
package main

import "fmt"

func average(total, count int) int {
	if count == 0 {
		return 0
	}
	return total / count
}

func main() {
	fmt.Println(average(30, 3))
}
```

Even so, when:

```bash
go test ./...
```

runs, the packages are still compiled.

If a package has no test functions, Go may print a message like:

```text
[no test files]
```

This does not mean "the package was not checked at all".

The package has been compiled as part of the test process.

Let's look at the function itself:

```go
func average(total, count int) int
```

First:

```go
if count == 0 {
	return 0
}
```

is checked.

This prevents division by zero.

Without this check, the `count == 0` case in the part:

```go
total / count
```

could lead to a runtime panic.

In the example:

```text
30 / 3 = 10
```

Because numbers that divide exactly were chosen, there is no extra fractional-part issue related to integer division.

For example:

```text
10 / 3
```

computed with `int` would be `3`, not `3.333...`.

The main rule of this example: `go test ./...` also compiles packages that have no test files.

But the output `[no test files]` does not mean the business behavior was checked by tests.

### 8. Applying the race check to the whole module

In this example a slice is filled sequentially.

```go
package main

import "fmt"

func main() {
	values := make([]int, 3)
	for index := range values {
		values[index] = (index + 1) * 10
	}
	fmt.Println(values)
}
```

First:

```go
values := make([]int, 3)
```

runs.

This creates an `[]int` of length `3`.

The zero value of `int` is `0`.

That is why the initial state can be pictured as:

```text
[0 0 0]
```

Then:

```go
for index := range values
```

walks over the indexes.

The indexes are:

```text
0
1
2
```

The calculation is done through:

```go
values[index] = (index + 1) * 10
```

Step by step:

```text
index = 0
(0 + 1) * 10 = 10

index = 1
(1 + 1) * 10 = 20

index = 2
(2 + 1) * 10 = 30
```

The result is:

```text
[10 20 30]
```

This code itself has no goroutines. That is why the flow shown runs sequentially and there is no concurrent access to shared memory.

When:

```bash
go test -race ./...
```

is used for the whole module, the race detector watches the code paths the tests executed.

The important difference here is that using the `-race` flag does not automatically make all code concurrent.

It looks for dangerous memory accesses in existing concurrent code.

The main rule: the race detector watches only the code paths that actually ran. If the problematic path does not run in a test, it may not be detected.

### 9. Evaluating coverage and test success separately

This example has a small function with two logical paths.

```go
package main

import "fmt"

func discount(total int) int {
	if total < 100 {
		return 0
	}
	return 10
}

func main() {
	fmt.Println(discount(100))
}
```

The condition in the function is written as:

```go
if total < 100
```

So:

```text
total = 99  -> 0
total = 100 -> 10
total = 101 -> 10
```

`100` in particular is the boundary value here.

The reason is the operator:

```go
<
```

that is, "less than".

If the condition were:

```go
total <= 100
```

the result for `100` would be different.

That is why testing boundary values is important.

After tests are written, coverage can be seen with:

```bash
go test -cover ./...
```

Coverage shows how much of the code ran during the tests.

For example, if both branches of the function are exercised by tests, coverage may increase.

But high coverage does not automatically mean a good test.

For example, a test may call:

```go
discount(100)
```

but expect the wrong result.

Or every statement of the function may run, but an important case from the business requirement may not be asserted at all.

So two things must be looked at separately:

* did the code paths run;
* are the results on those paths correct.

The main rule: coverage shows test reach but does not by itself guarantee the quality of the tests.

### 10. Running the checks in one order

This example shows a small program that can pass the main checking tools.

```go
package main

import (
	"fmt"
	"strings"
)

func normalize(words []string) string {
	cleaned := make([]string, 0, len(words))
	for _, word := range words {
		cleaned = append(cleaned, strings.TrimSpace(word))
	}
	return strings.Join(cleaned, ", ")
}

func main() {
	words := []string{" Go ", " test ", " vet "}
	fmt.Println(normalize(words))
}
```

The checks can be run in the following order:

```bash
go fmt ./...
go vet ./...
go test ./...
go test -race ./...
```

Now let's see how the code works.

The function:

```go
func normalize(words []string) string
```

takes a slice of strings and returns one `string`.

First a new slice is created with:

```go
cleaned := make([]string, 0, len(words))
```

Here the length is:

```text
0
```

because no word has been added to the result yet.

The capacity equals:

```go
len(words)
```

In the example `words` contains three elements:

```text
" Go "
" test "
" vet "
```

So room for three elements can be reserved for `cleaned` from the start.

The reason for this approach is simple: one cleaned result is expected for each input element.

Then:

```go
for _, word := range words {
	cleaned = append(cleaned, strings.TrimSpace(word))
}
```

walks over each element.

`strings.TrimSpace` removes whitespace characters from the start and end of a string.

That is why we get:

```text
" Go "   -> "Go"
" test " -> "test"
" vet "  -> "vet"
```

As a result, `cleaned` contains:

```text
["Go", "test", "vet"]
```

Finally:

```go
return strings.Join(cleaned, ", ")
```

joins the elements with `", "`.

The result is:

```text
Go, test, vet
```

In this program each check does a different job.

`go fmt ./...` checks the code format and changes it if needed.

`go vet ./...` looks for statically suspicious constructs.

`go test ./...` compiles the packages and runs the existing tests.

`go test -race ./...` also looks for data races in the code paths the tests executed.

That is why these commands can be seen as one general "code check", but you should not forget that each of them does a separate job.
