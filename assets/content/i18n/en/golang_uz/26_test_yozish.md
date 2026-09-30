# Writing tests in Go

A test is code that automatically checks that other code gives the expected result.

For example, if the function `Add(2, 3)` must return `5`, there is no need to check it by hand every time. If we write a test, Go runs this check automatically.

In Go there is no need to install a separate test framework for this. The `testing` package in the standard library and the `go test` command are enough to write the main tests.

Tests are not only for checking that a function returns the right result. They can also check error cases, boundary values, working with files, `error` values and other behavior.

## The first test

Let's start with a very simple function.

The following `calc` package adds two integers:

```go
package calc

func Add(a, b int) int {
	return a + b
}
```

`Add()` takes two `int` values and returns their sum.

For example:

```text
Add(2, 3) → 5
```

Now let's check this behavior with a test.

The names of Go test files must end with `_test.go`. For example:

```text
calc.go
calc_test.go
```

A test function is usually written in the form `TestXxx(t *testing.T)`:

```go
package calc

import "testing"

func TestAdd(t *testing.T) {
	got := Add(2, 3)
	want := 5

	if got != want {
		t.Errorf("Add(2, 3) = %d; want %d", got, want)
	}
}
```

Let's go through this test step by step.

First the actual result is obtained:

```go
got := Add(2, 3)
```

`got` is the value the function actually returned. Here it should be `5`.

Then we write the expected result:

```go
want := 5
```

`want` is the value the test considers correct.

Then the two values are compared:

```go
if got != want {
	t.Errorf("Add(2, 3) = %d; want %d", got, want)
}
```

If `got` and `want` are not equal, the test is considered failed.

For example, if `Add()` was accidentally written like this:

```go
func Add(a, b int) int {
	return a - b
}
```

the result of `Add(2, 3)` would be `-1`. But the test expects `5`. Then `t.Errorf()` records the error.

The tests in the current package can be run like this:

```bash
go test
```

To run the tests of all packages in the module:

```bash
go test ./...
```

There is an important difference between these two commands:

```text
go test
```

tests only the current package.

```text
go test ./...
```

checks the packages in the current module and their subpackages too.

### The difference between `t.Errorf()` and `t.Fatalf()`

There are several ways to record an error in tests. Two of the most common are `t.Errorf()` and `t.Fatalf()`.

`t.Errorf()` marks the test as failed, but the current test function keeps running:

```go
if got != want {
	t.Errorf("wrong result")
}
```

This is used when it is useful to run the following checks too.

`t.Fatalf()` records the error and stops the current test function right there:

```go
if err != nil {
	t.Fatalf("unexpected error: %v", err)
}
```

This is usually needed when running the rest of the code no longer makes sense.

For example, if opening a file itself failed, there is no way to check the data inside the file. In such a case `t.Fatalf()` is logically more correct.

The important point is that `t.Fatalf()` does not stop the whole `go test` process. It stops the execution of exactly the current test. Other tests can usually keep running.

## Table-driven tests and subtests

Often checking a function with only one value is not enough.

For example, we may want to check the `Add()` function in the following cases:

* two positive numbers;
* two negative numbers;
* a number and zero.

You could write a separate `Test...` function for each case. But in Go it is very common to keep such tests in the form of a table.

This technique is called a **table-driven test**.

```go
func TestAdd(t *testing.T) {
	tests := []struct {
		name       string
		a, b, want int
	}{
		{name: "positive", a: 2, b: 3, want: 5},
		{name: "negative", a: -2, b: -3, want: -5},
		{name: "zero", a: 4, b: 0, want: 4},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := Add(tt.a, tt.b)

			if got != tt.want {
				t.Errorf(
					"Add(%d, %d) = %d; want %d",
					tt.a,
					tt.b,
					got,
					tt.want,
				)
			}
		})
	}
}
```

Here `tests` is a slice where the test cases are stored.

Each element stores the following data:

```go
name       string
a, b, want int
```

`name` is the name of the test case.

`a` and `b` are the arguments passed to the `Add()` function.

`want` is the expected result.

For example:

```go
{name: "negative", a: -2, b: -3, want: -5}
```

stands for the following check:

```text
Add(-2, -3) → must be -5
```

Then all the cases are taken one by one with `for`:

```go
for _, tt := range tests {
	...
}
```

For each case `t.Run()` is called:

```go
t.Run(tt.name, func(t *testing.T) {
	...
})
```

`t.Run()` creates a separate **subtest**.

As a result, the tests appear roughly under the following names:

```text
TestAdd/positive
TestAdd/negative
TestAdd/zero
```

The benefit is that it becomes easy to see exactly which case failed.

For example, you can run only the `positive` subtest:

```bash
go test -run 'TestAdd/positive'
```

If one subtest fails, the other subtests usually keep running too.

A table-driven test is especially useful when the same rule must be checked with many values. To add a new case, there is no need to write a new test function. Adding one more element to the table is enough.

## Keeping tests independent

A good test should not depend on the result of another test or on the order in which tests run.

For example, this approach is dangerous:

```text
TestA changes a global value
↓
TestB relies on that changed value
```

If the order in which the tests run changes, or `TestB` runs on its own, it may fail.

That is why each test should prepare its own state as far as possible and leave no unneeded changes in the outside environment after it finishes.

You should be especially careful with:

* changing global state;
* using the user's real files;
* relying on shared database state;
* making unnecessary requests to external network services;
* depending on a file or data created by another test.

Tests that work with files may need a temporary directory. For this Go provides the `t.TempDir()` method.

```go
func TestSave(t *testing.T) {
	dir := t.TempDir()
	path := filepath.Join(dir, "result.txt")

	if err := os.WriteFile(path, []byte("hello"), 0o600); err != nil {
		t.Fatalf("file was not written: %v", err)
	}

	data, err := os.ReadFile(path)
	if err != nil {
		t.Fatalf("file was not read: %v", err)
	}

	if string(data) != "hello" {
		t.Errorf("result = %q; want %q", data, "hello")
	}
}
```

This snippet needs the following imports:

```go
import (
	"os"
	"path/filepath"
	"testing"
)
```

Let's go through the process step by step.

First a temporary directory is created for the test:

```go
dir := t.TempDir()
```

This directory belongs to the test. When the test finishes, Go cleans it up automatically.

Then a file path inside this directory is created:

```go
path := filepath.Join(dir, "result.txt")
```

`filepath.Join()` builds a file path suitable for the operating system.

Then the text `"hello"` is written to the file:

```go
os.WriteFile(path, []byte("hello"), 0o600)
```

`0o600` is a Unix-style permission value:

```text
owner:  read + write
others: no access
```

If an error occurs while writing:

```go
t.Fatalf("file was not written: %v", err)
```

is called.

The reason `Fatalf` is used here matters. If the file was not written, there is no point in reading it and checking its data in the next step.

Then the file is read back:

```go
data, err := os.ReadFile(path)
```

And finally the value inside the file is checked:

```go
if string(data) != "hello" {
	t.Errorf(...)
}
```

With `t.TempDir()` the test does not depend on the user's real files. This makes tests safer and more convenient to run repeatedly.

## Coverage

**Coverage** shows which parts of the code the tests executed.

To get a simple coverage percentage:

```bash
go test -cover ./...
```

For example, the result may contain information like this:

```text
coverage: 82.4% of statements
```

This means how many of the statements were run while the tests executed.

To save the coverage result to a file:

```bash
go test -coverprofile=coverage.out ./...
```

This command creates a profile named `coverage.out`.

Then it can be opened as HTML:

```bash
go tool cover -html=coverage.out
```

The HTML report makes it easy to see which code was executed by the tests and which part was not.

But the coverage percentage should not be taken as a complete measure of code quality.

For example, a test may execute every line inside a function and still not check for wrong results. Such a test may give high coverage but be of little real use.

That is why in tests you should look not only at the coverage percentage but also at the behavior being checked.

The important cases usually include:

* the ordinary success path;
* boundary values;
* invalid input;
* paths that return an `error`;
* zero or empty values;
* special cases that matter to the business.

High coverage can be a useful signal. But it does not on its own prove that the code is correct.

## Examples

### 1. Checking a simple result

This example shows the most basic form of writing a test. The actual value returned by the function is compared with the expected value.

```go
package main

import "testing"

func multiply(a, b int) int {
	return a * b
}

func TestMultiply(t *testing.T) {
	got := multiply(4, 3)
	want := 12

	if got != want {
		t.Errorf("multiply(4, 3) = %d; want %d", got, want)
	}
}
```

The first important line of the test:

```go
got := multiply(4, 3)
```

Here we get what the function actually returns.

The calculation:

```text
4 * 3 = 12
```

The next line:

```go
want := 12
```

stores the result the test expects.

Then:

```go
if got != want {
	...
}
```

compares the actual and expected values.

If `multiply(4, 3)` returns `12`, the test passes.

If it returns another value:

```go
t.Errorf("multiply(4, 3) = %d; want %d", got, want)
```

puts the test into the failed state.

The main rule in this example is very simple:

```text
got = actual result
want = expected result
```

Many Go tests are based on exactly this approach.

### 2. Checking the error before the result

If a function returns an `error` along with a value, the `error` should often be checked first.

The following function divides two integers:

```go
package main

import (
	"errors"
	"testing"
)

func divide(a, b int) (int, error) {
	if b == 0 {
		return 0, errors.New("cannot divide by zero")
	}

	return a / b, nil
}

func TestDivide(t *testing.T) {
	got, err := divide(12, 3)
	if err != nil {
		t.Fatalf("divide() returned an unexpected error: %v", err)
	}

	want := 4
	if got != want {
		t.Errorf("divide(12, 3) = %d; want %d", got, want)
	}
}
```

`divide()` returns two results:

```go
(int, error)
```

In the success case it does:

```go
return a / b, nil
```

For example:

```text
12 / 3 = 4
```

That is why after:

```go
got, err := divide(12, 3)
```

we expect:

```text
got = 4
err = nil
```

The first check is written exactly for `err`:

```go
if err != nil {
	t.Fatalf("divide() returned an unexpected error: %v", err)
}
```

`t.Fatalf()` was chosen here. The reason is that if `divide()` returned an error, it is no longer logical to check `got` as a normal result.

Only after making sure there is no error do:

```go
want := 4
```

and:

```go
if got != want {
	...
}
```

run.

In this example `12` and `3` were not chosen at random. `12 / 3` gives exactly `4` as an integer. That is why this test does not mix in other subtleties of integer division.

The main rule:

```text
If the meaning of the result depends on successful execution,
check the error first.
```

### 3. Checking boundary values in a table

This example checks several important cases of a function with a table-driven test.

```go
package main

import "testing"

func normalize(value int) int {
	if value < 0 {
		return 0
	}

	return value
}

func TestNormalize(t *testing.T) {
	tests := []struct {
		name  string
		value int
		want  int
	}{
		{name: "negative", value: -1, want: 0},
		{name: "boundary", value: 0, want: 0},
		{name: "positive", value: 5, want: 5},
	}

	for _, tt := range tests {
		got := normalize(tt.value)

		if got != tt.want {
			t.Errorf(
				"%s: normalize(%d) = %d; want %d",
				tt.name,
				tt.value,
				got,
				tt.want,
			)
		}
	}
}
```

The rule of `normalize()`:

```text
if value < 0 → 0
otherwise    → value
```

That is why the test checks three important cases.

The first:

```go
{name: "negative", value: -1, want: 0}
```

`-1 < 0` is true. The function should return `0`.

The second:

```go
{name: "boundary", value: 0, want: 0}
```

This is exactly the boundary of the condition.

The function says:

```go
if value < 0
```

`0 < 0` is false. So `0` is returned unchanged.

The third:

```go
{name: "positive", value: 5, want: 5}
```

Because `5` is a positive value, the function should return it unchanged.

Testing boundary values is important. A change of a single character in operators such as `<`, `<=`, `>`, `>=` can change the function's behavior exactly at the boundary.

The main rule of this example is to check not only ordinary values but also the boundary where the condition changes.

### 4. Splitting cases into subtests

This example shows running each case of a table-driven test as a separate subtest.

```go
package main

import "testing"

func isEven(value int) bool {
	return value%2 == 0
}

func TestIsEven(t *testing.T) {
	tests := []struct {
		name  string
		value int
		want  bool
	}{
		{name: "even", value: 8, want: true},
		{name: "odd", value: 7, want: false},
		{name: "zero", value: 0, want: true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := isEven(tt.value)

			if got != tt.want {
				t.Errorf(
					"isEven(%d) = %t; want %t",
					tt.value,
					got,
					tt.want,
				)
			}
		})
	}
}
```

`isEven()` checks evenness through the remainder:

```go
value%2 == 0
```

For example:

```text
8 % 2 = 0
```

That is why `8` is even.

```text
7 % 2 = 1
```

That is why `7` is odd.

For zero:

```text
0 % 2 = 0
```

So `0` also counts as an even number.

With `t.Run()` each case gets its own name:

```text
TestIsEven/even
TestIsEven/odd
TestIsEven/zero
```

This makes the test result easier to read.

For example, you can run only the even-number case:

```bash
go test -run 'TestIsEven/even'
```

This is especially convenient in a large test suite. If the problem is only in one case, there may be no need to run the whole table again and again.

The main rule is that `t.Run()` gives test cases a separate name and a separate subtest context.

### 5. Moving a repeated check into a helper function

If the same test check is repeated in many places, it can be moved into a helper function.

```go
package main

import "testing"

func add(a, b int) int {
	return a + b
}

func assertEqual(t *testing.T, got, want int) {
	t.Helper()

	if got != want {
		t.Errorf("result = %d; want %d", got, want)
	}
}

func TestAdd(t *testing.T) {
	assertEqual(t, add(2, 3), 5)
	assertEqual(t, add(-2, 2), 0)
}
```

The helper function:

```go
func assertEqual(t *testing.T, got, want int)
```

gathers the same equality check in one place.

The important line:

```go
t.Helper()
```

This tells the `testing` package that `assertEqual()` is not ordinary test logic but a helper test function.

The benefit shows in the error report.

If the check inside the helper fails, Go links the error location, as far as possible, not to the:

```go
t.Errorf(...)
```

line inside the helper, but to the test line where the helper was called.

For example:

```go
assertEqual(t, add(2, 3), 5)
```

This helps find more quickly which check caused the problem.

The second case:

```go
assertEqual(t, add(-2, 2), 0)
```

checks opposite values:

```text
-2 + 2 = 0
```

Helper functions are especially useful in large tests for separating repeated checks, setup or other helper operations.

The main rule is that when you write a test helper, it helps to mark it as a helper function with `t.Helper()` where needed.

### 6. Registering a test cleanup function

During a test you may need to create a temporary resource.

For example:

* a file;
* a temporary server;
* test database state;
* a changed global configuration.

Such a resource must be cleaned up after the test finishes.

`t.Cleanup()` registers a function that runs after the test or subtest finishes.

```go
package main

import "testing"

func TestCleanup(t *testing.T) {
	events := make([]string, 0, 2)

	t.Run("resource", func(t *testing.T) {
		t.Cleanup(func() {
			events = append(events, "cleaned up")
		})

		events = append(events, "used")
	})

	if len(events) != 2 {
		t.Fatalf("number of events = %d; want 2", len(events))
	}

	if events[0] != "used" || events[1] != "cleaned up" {
		t.Errorf("wrong order of events: %v", events)
	}
}
```

First a slice is created:

```go
events := make([]string, 0, 2)
```

Here:

```text
len = 0
cap = 2
```

`len` is `0`, because there are no elements in the slice yet.

`cap` is `2`, because this test expects two events to be written:

```text
used
cleaned up
```

Then the subtest starts:

```go
t.Run("resource", func(t *testing.T) {
	...
})
```

Inside the subtest a cleanup function is registered:

```go
t.Cleanup(func() {
	events = append(events, "cleaned up")
})
```

This function does not run right away.

The next line runs:

```go
events = append(events, "used")
```

At this point:

```text
events = ["used"]
```

When the subtest finishes, its cleanup function runs:

```text
events = ["used", "cleaned up"]
```

By the time `t.Run()` returns, the subtest's cleanup functions have already run. That is why the outer test can check the following order:

```go
events[0] == "used"
events[1] == "cleaned up"
```

First the length is checked:

```go
if len(events) != 2 {
	t.Fatalf(...)
}
```

Using `Fatalf` here makes sense. If the slice does not contain two elements, the following accesses such as `events[0]` or `events[1]` can be dangerous.

The main rule of this example is that a test that creates a resource should also manage its cleanup itself.

### 7. Checking a file in a temporary directory

In this example the test checks writing a file without touching the user's real directories.

```go
package main

import (
	"os"
	"path/filepath"
	"testing"
)

func TestWriteMessage(t *testing.T) {
	dir := t.TempDir()
	path := filepath.Join(dir, "message.txt")

	if err := os.WriteFile(path, []byte("hello"), 0o600); err != nil {
		t.Fatalf("file was not written: %v", err)
	}

	data, err := os.ReadFile(path)
	if err != nil {
		t.Fatalf("file was not read: %v", err)
	}

	if string(data) != "hello" {
		t.Errorf("file = %q; want %q", data, "hello")
	}
}
```

The first step:

```go
dir := t.TempDir()
```

Go creates a temporary directory for the test.

The next step:

```go
path := filepath.Join(dir, "message.txt")
```

builds a path to the `message.txt` file inside this directory.

Then the file is written:

```go
os.WriteFile(path, []byte("hello"), 0o600)
```

`[]byte("hello")` turns the text into a byte slice.

The permission:

```text
0o600
```

gives the owner read and write access.

If the file is not written:

```go
t.Fatalf("file was not written: %v", err)
```

there is no point in continuing the test.

Then the file is read back:

```go
data, err := os.ReadFile(path)
```

If this also succeeds, the byte slice that was read is turned into text:

```go
string(data)
```

and compared with the expected value:

```go
if string(data) != "hello" {
	...
}
```

This test does not rely on a real user file such as:

```text
/home/user/message.txt
```

`t.TempDir()` helps isolate tests better from each other and from the outside environment. When the test finishes, the temporary directory is cleaned up automatically too.

### 8. Checking a sentinel error with `errors.Is()`

In Go some errors are created in advance at the package level:

```go
var ErrNotFound = errors.New("not found")
```

Such errors are often called **sentinel errors**.

In the following example the function wraps `ErrNotFound` with extra context:

```go
package main

import (
	"errors"
	"fmt"
	"testing"
)

var ErrNotFound = errors.New("not found")

func find(id int) error {
	if id != 10 {
		return fmt.Errorf("id %d: %w", id, ErrNotFound)
	}

	return nil
}

func TestFindNotFound(t *testing.T) {
	err := find(25)

	if !errors.Is(err, ErrNotFound) {
		t.Fatalf("error = %v; want ErrNotFound", err)
	}
}
```

The rule of `find()` is simple:

```text
id == 10 → found, nil
id != 10 → ErrNotFound
```

But the error is not returned simply as:

```go
return ErrNotFound
```

It is wrapped with `%w`:

```go
fmt.Errorf("id %d: %w", id, ErrNotFound)
```

For example, if `id = 25`, the error text looks roughly like:

```text
id 25: not found
```

But `ErrNotFound` is also kept in the error's inner chain.

That is why, instead of comparing the error text, the test uses:

```go
errors.Is(err, ErrNotFound)
```

This check means:

> is `ErrNotFound` either `err` itself or somewhere in its chain of wrapped errors?

The plain:

```go
err == ErrNotFound
```

does not work in this example, because `err` is a different error value created by the outer `fmt.Errorf()`.

Checking the error text in the form:

```go
err.Error() == "id 25: not found"
```

is also usually a brittle approach. If the message text changes, the test fails even though the semantic cause did not change.

The main rule of this example is to use `errors.Is()` to check a wrapped sentinel error.

### 9. Checking a documentation example with a test

In Go, `Example` functions can serve both as a documentation example and as an automatically checked test at the same time.

```go
package main

import "fmt"

func greeting(name string) string {
	return "Hello, " + name + "!"
}

func Example_greeting() {
	fmt.Println(greeting("Ali"))

	// Output: Hello, Ali!
}
```

`greeting()` returns a simple string:

```go
func greeting(name string) string {
	return "Hello, " + name + "!"
}
```

For example, the result of:

```text
greeting("Ali")
```

is:

```text
Hello, Ali!
```

Inside `Example_greeting()` the result is printed to stdout:

```go
fmt.Println(greeting("Ali"))
```

Then a special comment is written:

```go
// Output: Hello, Ali!
```

When `go test` runs the example function, it compares the actual stdout result with this `Output` value.

In simplified form, the process looks like this:

```text
greeting("Ali")
        ↓
"Hello, Ali!"
        ↓
fmt.Println(...)
        ↓
stdout: Hello, Ali!
        ↓
 // Output: Hello, Ali!
        ↓
comparison
```

If the actual result and `Output` match, the example passes.

For example, if the function is later changed to:

```go
return "Good day, " + name + "!"
```

but `// Output:` is not updated, `go test` marks the example as failed.

That is why an `Example` is not only code shown to the reader. It can also automatically check that the example in the documentation matches the actual code.

The name `Example_greeting` in this example means an example tied to the `greeting` function. `go test` can run it together with the ordinary tests.

The main rule is that `Example` functions with `// Output:` serve as documentation and an automatic test together.
