# Error handling in Go

Not every operation finishes successfully while a program runs. For example, the file the program wants to open may not exist. The user may enter a wrong value. A request sent over the network may also fail for various reasons.

These are natural situations in a program. In Go, such expected problems are usually handled through an `error` value.

Not every function has to return an `error`. If a function can fail, it usually returns an `error` along with its main result.

For example, a simple function such as adding two numbers usually does not need to return an error. But operations such as opening a file, connecting to a database or validating a value entered by the user can fail. Returning an `error` is natural in such functions.

## What is `error`?

In Go, `error` is a separate built-in interface. It requires only one method:

```go
type error interface {
	Error() string
}
```

An interface defines not what data a type holds, but which methods it must have. For now it is enough to think of
`error` as a value that has an `Error() string` method. In the later interface lesson this idea, and how a type
satisfies an interface's requirements, is covered in detail.

The main idea here is very simple: the `Error()` method represents the error as a `string` that a person can read.

If a type has a method with the following signature:

```go
Error() string
```

it can satisfy the `error` interface.

When a function succeeds, it usually returns `nil` in place of the `error`. When an error occurs, it returns a real `error` value that describes the cause of the problem.

The following function divides two `float64` numbers:

```go
package main

import (
	"errors"
	"fmt"
)

func divide(a, b float64) (float64, error) {
	if b == 0 {
		return 0, errors.New("cannot divide by zero")
	}

	return a / b, nil
}

func main() {
	result, err := divide(10, 4)
	if err != nil {
		fmt.Println("Error:", err)
		return
	}

	fmt.Println("Result:", result)
}
```

Output:

```text
Result: 2.5
```

`divide()` returns two values:

```go
(float64, error)
```

The first value is the result of the calculation.

The second value is information about an error.

If `b` is not zero, the division succeeds:

```go
return a / b, nil
```

Here the real result and `nil` are returned. `nil` means there is no error.

If `b == 0`:

```go
return 0, errors.New("cannot divide by zero")
```

the function does not continue the calculation. It returns `0`, the zero value of the `float64` type, and an error.

There is an important rule here: when an error is returned, the first result itself is usually not reliable. The caller must check `err` first.

## Checking the error

When a function that returns an `error` is called, the first thing usually done is to check the `err` value.

For example:

```go
result, err := divide(10, 0)
if err != nil {
	fmt.Println("Error:", err)
	return
}

fmt.Println(result)
```

Output:

```text
Error: cannot divide by zero
```

Here `divide(10, 0)` returned an error.

That is why the condition:

```go
if err != nil {
```

is `true` and the error is handled.

And thanks to `return`, the rest of the code does not run:

```go
fmt.Println(result)
```

This is good practice, because after an error the main result that came back is usually unusable.

For example, if a file-reading function returned an error, working with the `data` it gave back as usual may be wrong.

That is why, when an error is detected, one of the following decisions is usually made:

* return the error to the calling function;
* show the user a clear message;
* perform the operation again in another way;
* use a separate fallback for a particular kind of error;
* log the error at the boundary of the system.

This does not mean "`err` must be checked in every function". It only means that if a function returns an `error`, the caller must consciously decide what to do with that value.

In some cases an error may even be ignored on purpose. But it is good if the reason for that decision is clear from the code.

For example:

```go
_ = file.Close()
```

Here `_` shows that the error was deliberately discarded. But if an error while closing the resource matters, it may need to be checked too.

## Creating errors

To create a simple error with fixed text, `errors.New()` is used.

For example:

```go
if age < 0 {
	return errors.New("age cannot be negative")
}
```

`errors.New()` creates a new `error` value from the given text.

This approach is convenient when the error text is known in advance.

But sometimes you need to add a value obtained at runtime to the error message. For example, we want to show exactly which age is wrong.

In that case `fmt.Errorf()` is convenient:

```go
func checkAge(age int) error {
	if age < 0 {
		return fmt.Errorf("invalid age: %d", age)
	}
	return nil
}
```

If `age == -5`, the error will look roughly like this:

```text
invalid age: -5
```

The value of `age` was added to the error text with `%d`.

A few small rules are usually followed when writing error text.

The message should be short, but it should explain the cause of the problem.

Error text usually starts with a lower-case letter:

```text
file not found
```

and does not end with a period.

The reason is that the error may be combined with other text in higher layers.

For example:

```text
loading config: file not found
```

If the inner error were written with a capital letter and a period, the chained messages could look less natural.

## Passing an error upward

If a function cannot handle an error itself, it returns it to the caller.

The simplest version:

```go
if err != nil {
	return err
}
```

This works. But the problem is that the upper layer sees only the original error. It may be unclear during which operation the error occurred.

That is why adding context to the error is useful.

In the following example the error is passed upward through several layers:

```go
package main

import (
	"fmt"
	"os"
)

func readFile(name string) ([]byte, error) {
	data, err := os.ReadFile(name)
	if err != nil {
		return nil, fmt.Errorf("reading file %q: %w", name, err)
	}
	return data, nil
}

func loadConfig() ([]byte, error) {
	data, err := readFile("config.json")
	if err != nil {
		return nil, fmt.Errorf("loading config: %w", err)
	}
	return data, nil
}

func run() error {
	data, err := loadConfig()
	if err != nil {
		return err
	}

	fmt.Println(string(data))
	return nil
}

func main() {
	if err := run(); err != nil {
		fmt.Println("The program did not start:", err)
	}
}
```

Let's go through this flow step by step.

First:

```go
loadConfig()
```

is called.

It calls the function:

```go
readFile("config.json")
```

Inside `readFile()`:

```go
os.ReadFile(name)
```

runs.

If `config.json` does not exist, `os.ReadFile()` returns an error.

`readFile()` does not simply pass this error on. It adds extra context:

```go
fmt.Errorf("reading file %q: %w", name, err)
```

As a result, the inner error now comes back together with the operation during which it occurred.

Then `loadConfig()` also adds its own context:

```go
fmt.Errorf("loading config: %w", err)
```

Finally, `main()`, at the top boundary of the system, shows the error to the user.

If `config.json` does not exist, the message will look roughly like this:

```text
The program did not start: loading config: reading file "config.json": open config.json: no such file or directory
```

This message can be read from the inside out:

```text
open config.json: no such file or directory
```

— the original cause at the operating system level.

```text
reading file "config.json"
```

— which operation was being performed.

```text
loading config
```

— which part of a bigger process that operation was.

```text
The program did not start
```

— in which context the error is being shown to the user.

Each layer added only the information that belongs to it.

Another important point: the lower functions do not print the error to the screen and then return it upward again.

For example, `readFile()` does not do this:

```go
fmt.Println(err)
return nil, err
```

If every layer logged the error and then returned it, the same error could be repeated several times in the logs.

A good approach is usually to add context to the error in lower layers and to print or log it once at the top boundary of the system.

### What does `%w` do?

`%w` has a special meaning inside `fmt.Errorf()`:

```go
fmt.Errorf("loading config: %w", err)
```

It wraps the original error inside a new error.

As a result two things happen:

1. extra context is added to the error text;
2. the original error is kept inside the chain.

That is why the inner cause can later be found with `errors.Is()` or `errors.As()`.

If `%v` is used instead of `%w`:

```go
fmt.Errorf("loading config: %v", err)
```

the error text may look almost the same.

But the original `error` is not kept as a chain. This takes away the ability to check the error by its type or cause later.

## Checking the cause with `errors.Is()`

Checking an error by its text is not a good approach.

For example, code like this is considered fragile:

```go
if err.Error() == "file does not exist" {
	// ...
}
```

The error text can change depending on the platform, the library or the context that was added.

To check whether a particular error value is in the chain, `errors.Is()` is used.

```go
package main

import (
	"errors"
	"fmt"
	"os"
)

func readFile(name string) ([]byte, error) {
	data, err := os.ReadFile(name)
	if err != nil {
		return nil, fmt.Errorf("reading file %q: %w", name, err)
	}
	return data, nil
}

func main() {
	_, err := readFile("config.json")
	if errors.Is(err, os.ErrNotExist) {
		fmt.Println("Config file not found")
		return
	}
	if err != nil {
		fmt.Println("Error:", err)
	}
}
```

Here the error from `os.ReadFile()` is wrapped with `fmt.Errorf()` and `%w`:

```go
fmt.Errorf("reading file %q: %w", name, err)
```

Nevertheless:

```go
errors.Is(err, os.ErrNotExist)
```

checks the chain of errors going inward.

If an error matching `os.ErrNotExist` is found in the chain, it returns `true`.

So no matter how much context was added to the error, the program can make a decision based on the original cause.

### Sentinel errors

For a fixed, distinct error case that belongs to the program, an error value can be declared in advance:

```go
var ErrUserNotFound = errors.New("user not found")
```

Such a value is often called a **sentinel error**.

For example, if the caller needs to tell the user-not-found case apart from other errors:

```go
if errors.Is(err, ErrUserNotFound) {
	// special decision
}
```

A sentinel error is not needed for every error.

It is usually useful when the caller needs to detect exactly that case programmatically and respond to it separately.

If the error is only needed to show text to the user, creating a separate sentinel value may be unnecessary.

## Custom errors and `errors.As()`

Sometimes text alone is not enough for an error.

For example, when validating a form, we want to store separately which field is wrong and the cause of the problem.

In such a situation a custom error type can be created.

```go
package main

import (
	"errors"
	"fmt"
)

type ValidationError struct {
	Field   string
	Message string
}

func (e *ValidationError) Error() string {
	return fmt.Sprintf("%s: %s", e.Field, e.Message)
}

func createUser(name string, age int) error {
	if name == "" {
		return &ValidationError{
			Field:   "name",
			Message: "must not be empty",
		}
	}
	if age < 0 {
		return &ValidationError{
			Field:   "age",
			Message: "must not be negative",
		}
	}
	return nil
}

func register(name string, age int) error {
	if err := createUser(name, age); err != nil {
		return fmt.Errorf("registering user: %w", err)
	}
	return nil
}

func main() {
	err := register("", 20)
	if err == nil {
		return
	}

	var validationErr *ValidationError
	if errors.As(err, &validationErr) {
		fmt.Printf("error in field %s: %s\n", validationErr.Field, validationErr.Message)
		return
	}

	fmt.Println("Unexpected error:", err)
}
```

Output:

```text
error in field name: must not be empty
```

First a special struct was created:

```go
type ValidationError struct {
	Field   string
	Message string
}
```

This struct stores two separate pieces of information:

* `Field` — which field the error occurred in;
* `Message` — an explanation of the problem.

Then the `Error()` method was written with a pointer receiver:

```go
func (e *ValidationError) Error() string
```

That is why `*ValidationError` satisfies the `error` interface.

For example:

```go
return &ValidationError{
	Field:   "name",
	Message: "must not be empty",
}
```

can be returned as an ordinary `error`.

In the next layer the error is wrapped:

```go
return fmt.Errorf("registering user: %w", err)
```

So the `err` that reaches `main()` may not be a `*ValidationError` directly. On the outside is the error created by `fmt.Errorf()`.

That is why `errors.As()` is used instead of a plain type assertion:

```go
var validationErr *ValidationError
if errors.As(err, &validationErr) {
```

`errors.As()` checks the chain of errors.

If a `*ValidationError` is found inside, it writes its value into the variable:

```go
validationErr
```

After that, the structured data inside the custom error can be used:

```go
validationErr.Field
validationErr.Message
```

This is much more reliable than parsing only the error text.

### The difference between `errors.Is()` and `errors.As()`

Even though their jobs look similar, their purposes differ.

`errors.Is()`:

```go
errors.Is(err, ErrUserNotFound)
```

checks whether a particular error value or cause exists in the chain.

`errors.As()`:

```go
errors.As(err, &validationErr)
```

finds a particular error type in the chain and lets you get a value of that type.

In short:

* `errors.Is()` — "is this error among the causes?";
* `errors.As()` — "is there an error of this type, and can you give me its data?".

## `defer` and closing resources

When a program opens a file, a socket, a database connection or another resource, closing it at the right time also matters.

In Go, `defer` lets you schedule a function call that should run later.

A deferred call runs before the current function finishes.

This is especially convenient when working with files:

```go
package main

import (
	"fmt"
	"os"
)

func fileSize(name string) (int64, error) {
	file, err := os.Open(name)
	if err != nil {
		return 0, fmt.Errorf("opening file: %w", err)
	}
	defer file.Close()

	info, err := file.Stat()
	if err != nil {
		return 0, fmt.Errorf("getting file info: %w", err)
	}

	return info.Size(), nil
}

func main() {
	size, err := fileSize("config.json")
	if err != nil {
		fmt.Println("Error:", err)
		return
	}
	fmt.Println("File size:", size)
}
```

Here the file is opened first:

```go
file, err := os.Open(name)
```

If opening the file itself fails:

```go
if err != nil {
	return 0, fmt.Errorf("opening file: %w", err)
}
```

the function returns right away.

An important point: `defer file.Close()` is written only after the file has been opened successfully:

```go
defer file.Close()
```

This is correct, because if `os.Open()` returned an error, there is no open `file` resource that can be used.

Then:

```go
info, err := file.Stat()
```

runs.

Even if an error occurs here:

```go
return 0, fmt.Errorf("getting file info: %w", err)
```

the deferred `file.Close()` runs before the function finishes.

Exactly the same happens in the successful case.

That is why `defer` makes it easy to close a resource on every exit path.

Otherwise you might have to write a separate:

```go
file.Close()
```

before every `return`.

### Several `defer`s

A function can have several `defer`s.

They run in **LIFO** order: the `defer` added last runs first.

For example:

```go
defer first()
defer second()
defer third()
```

when the function finishes, the order of execution is:

```text
third
second
first
```

This is convenient for closing resources in reverse order.

For example, if we opened resource A first and then resource B, it is natural to close B first and then A.

### `defer` and long loops

`defer` runs not when the current block ends, but when the **function** ends.

That is why piling up many `defer`s inside a long-running loop requires care.

For example:

```go
for _, name := range names {
	file, err := os.Open(name)
	if err != nil {
		continue
	}
	defer file.Close()
}
```

Here each file is closed not at the end of its iteration, but when the whole function ends.

If there are many files, a lot of resources may be left open at the same time.

In such a situation it may be better to move the loop body into a separate function or to close the resource directly where appropriate.

## `panic` and `recover`

Go has `panic`, but it does not replace returning ordinary errors.

Expected problems should usually be returned through an `error`.

For example:

* the file was not found;
* the user entered a wrong value;
* the network connection dropped;
* the required record was not found in the database.

These belong to the normal error flow.

`panic`, on the other hand, can be used for situations where the program cannot continue normally, or for serious logic mistakes made by the programmer.

When a `panic` occurs, the normal execution of the current function stops and it starts propagating up the stack. During this process deferred functions run.

`recover()` can catch the panic value inside a deferred function.

```go
package main

import "fmt"

func runSafely(fn func()) {
	defer func() {
		if value := recover(); value != nil {
			fmt.Println("Panic caught:", value)
		}
	}()

	fn()
}

func main() {
	runSafely(func() {
		panic("unexpected internal state")
	})
}
```

Output:

```text
Panic caught: unexpected internal state
```

Let's go through the flow step by step.

First:

```go
runSafely(...)
```

is called.

Inside the function, a deferred anonymous function is registered:

```go
defer func() {
	if value := recover(); value != nil {
		fmt.Println("Panic caught:", value)
	}
}()
```

Then:

```go
fn()
```

runs.

Inside the passed function:

```go
panic("unexpected internal state")
```

is called.

Normal execution stops at this point.

Before `runSafely()` finishes, its deferred function runs.

`recover()` gets the value sent with the panic:

```go
"unexpected internal state"
```

and stops the panic from propagating within this goroutine.

There is an important subtlety here.

`recover()` does not continue execution after the line where `panic(...)` was written.

For example:

```go
func test() {
	panic("error")
	fmt.Println("this does not run")
}
```

Even if `recover()` catches the panic in a higher layer:

```go
fmt.Println("this does not run")
```

does not run.

The function where the panic occurred is considered finished. Control can return to the normal flow above after the deferred function that caught the panic has finished.

### Where is `recover()` used?

There is no need to put `recover()` inside every function.

It is usually used at a system boundary.

For example, an HTTP server may not want an unexpected `panic` inside one request handler to stop the whole server process.

At such a boundary, `recover()` can catch the panic, log the error and finish that request with an error.

But this does not mean ordinary business errors should be passed through `panic`.

For example, the following approach is not recommended:

```go
if user == nil {
	panic("user not found")
}
```

if not finding the `user` is a normal, expected case.

In such a situation returning an ordinary `error` is more correct.

## A procedure for working with errors

In practical code the following procedure is useful for working with errors.

1. A function that can fail should return an `error`.

2. If the caller can handle the error meaningfully at its layer, it should make the decision right there.

For example, if a default configuration can be used when the file is not found, this can be handled exactly at that layer.

3. If a layer cannot handle the error, it should add useful context and return it upward.

For example:

```go
return fmt.Errorf("loading config: %w", err)
```

4. If an upper layer needs to respond separately to a particular cause of error, it should use `errors.Is()`.

For example:

```go
if errors.Is(err, os.ErrNotExist) {
	// ...
}
```

5. If structured data needs to be taken from an error, it should use `errors.As()`.

6. Show the error to the user or log it usually once, at the system boundary.

7. Don't use `panic` for expected errors.

This approach keeps the error flow clear. Lower layers do not lose the technical cause, and upper layers can make the right decision for the user or the system.

In one of the later practical lessons we will see writing an error to `stderr` and returning a suitable exit code in a command-line program.

## Examples

### 1. Creating a fixed error

This example shows reusing an error value created in advance.

An empty name is a separate error case:

```go
package main

import (
	"errors"
	"fmt"
)

var ErrEmptyName = errors.New("name must not be empty")

func validateName(name string) error {
	if name == "" {
		return ErrEmptyName
	}
	return nil
}

func main() {
	err := validateName("")
	if err != nil {
		fmt.Println("Error:", err)
	}
}
```

Here:

```go
var ErrEmptyName = errors.New("name must not be empty")
```

creates one error value at package level.

`validateName()` checks the name:

```go
if name == "" {
	return ErrEmptyName
}
```

The empty `string` value:

```go
""
```

is the zero value of the `string` type.

In this example it means the "name not entered" case.

If there is a name:

```go
return nil
```

is returned.

If the name is empty, exactly `ErrEmptyName` is returned.

The benefit of such an error value declared in advance is that the caller can later check it, if needed, with:

```go
errors.Is(err, ErrEmptyName)
```

### 2. Adding a value to the error message

In this example we use `fmt.Errorf()` to add to the message exactly which age value is wrong.

```go
package main

import "fmt"

func validateAge(age int) error {
	if age < 0 {
		return fmt.Errorf("age must not be negative: %d", age)
	}
	return nil
}

func main() {
	if err := validateAge(-4); err != nil {
		fmt.Println("Error:", err)
		return
	}

	fmt.Println("Age accepted")
}
```

The condition inside `validateAge()`:

```go
if age < 0 {
```

rejects only negative values.

For example:

```text
-1
-4
-100
```

are errors.

But `0` is not automatically treated as an error.

That is why:

```go
age < 0
```

is used, not `age <= 0`.

This depends on the business rule. If in the system the age must be `1` or more, the condition could be different.

The place where the error is created:

```go
fmt.Errorf("age must not be negative: %d", age)
```

Here `%d` adds the incoming `int` value to the message.

If `age == -4`:

```text
age must not be negative: -4
```

is produced.

This can be more useful than plain static text for debugging and for explaining the problem to the user.

### 3. Returning an error along with a result

This example shows a function returning a main result and an `error` at the same time.

If more products are requested than are in stock, the operation is not performed.

```go
package main

import (
	"errors"
	"fmt"
)

func remaining(stock, requested int) (int, error) {
	if requested < 1 {
		return 0, errors.New("requested amount must be positive")
	}
	if requested > stock {
		return 0, errors.New("not enough products in stock")
	}
	return stock - requested, nil
}

func main() {
	left, err := remaining(12, 5)
	if err != nil {
		fmt.Println("Error:", err)
		return
	}

	fmt.Println("Left:", left)
}
```

First the requested amount is checked:

```go
if requested < 1 {
```

`requested` must be at least `1`.

Then whether there are enough products in stock is checked:

```go
if requested > stock {
```

If `requested` is greater than `stock`, the calculation makes no sense.

In both error cases:

```go
return 0, ...
```

is returned.

The zero value of the `int` type is `0`.

But the caller first checks:

```go
if err != nil {
```

That is why it does not use the `0` from an error case as a real result.

In the successful case:

```go
return stock - requested, nil
```

runs.

The given values:

```text
stock = 12
requested = 5
```

The calculation:

```text
12 - 5 = 7
```

So the function returns:

```text
7, nil
```

Output:

```text
Left: 7
```

### 4. Wrapping and passing on a sentinel error

This example shows passing a sentinel error to an upper layer with context and then finding the original cause with `errors.Is()`.

```go
package main

import (
	"errors"
	"fmt"
)

var ErrProductNotFound = errors.New("product not found")

func findProduct(id int) error {
	if id != 10 {
		return ErrProductNotFound
	}
	return nil
}

func loadProduct(id int) error {
	if err := findProduct(id); err != nil {
		return fmt.Errorf("loading product with id %d: %w", id, err)
	}
	return nil
}

func main() {
	err := loadProduct(25)
	if errors.Is(err, ErrProductNotFound) {
		fmt.Println("Choose another product")
		return
	}
	fmt.Println("Product loaded")
}
```

The sentinel error:

```go
var ErrProductNotFound = errors.New("product not found")
```

represents a specific business case.

To keep the example simple, only `id == 10` is treated as an existing product:

```go
if id != 10 {
	return ErrProductNotFound
}
```

When `loadProduct(25)` is called, `findProduct(25)` returns an error.

But `loadProduct()` does not pass this error on directly:

```go
return fmt.Errorf("loading product with id %d: %w", id, err)
```

As a result, an error roughly like this is produced:

```text
loading product with id 25: product not found
```

Here `%w` is very important.

It keeps `ErrProductNotFound` as the inner cause.

That is why:

```go
errors.Is(err, ErrProductNotFound)
```

returns `true`.

The caller does not compare the error text. It makes a decision based on the real cause of the error:

```go
fmt.Println("Choose another product")
```

This is a typical example of how sentinel errors and wrapping work together.

### 5. Getting data from a custom error type

In this example the error is not just text; it stores structured data in separate fields.

```go
package main

import (
	"errors"
	"fmt"
)

type FieldError struct {
	Field string
	Value int
}

func (e *FieldError) Error() string {
	return fmt.Sprintf("invalid value in field %s: %d", e.Field, e.Value)
}

func validateCount(count int) error {
	if count < 1 {
		return &FieldError{Field: "count", Value: count}
	}
	return nil
}

func main() {
	err := validateCount(0)
	var fieldErr *FieldError
	if errors.As(err, &fieldErr) {
		fmt.Println("Field:", fieldErr.Field)
		fmt.Println("Value:", fieldErr.Value)
	}
}
```

The custom error type:

```go
type FieldError struct {
	Field string
	Value int
}
```

stores two pieces of information separately.

`Field` tells which field is wrong.

`Value` stores exactly what invalid value came in.

Then the `Error()` method is written:

```go
func (e *FieldError) Error() string
```

That is why `*FieldError` fits the `error` interface.

`count` must be at least `1`:

```go
if count < 1 {
```

In the example `0` is passed:

```go
err := validateCount(0)
```

That is why an error with the content:

```go
&FieldError{
	Field: "count",
	Value: 0,
}
```

is returned.

Then the variable:

```go
var fieldErr *FieldError
```

is declared.

`errors.As()`:

```go
errors.As(err, &fieldErr)
```

checks whether the error matches the `*FieldError` type.

If it matches, the value found is written into `fieldErr`.

After that there is no need to parse the error text:

```go
fieldErr.Field
fieldErr.Value
```

give the required data directly.

### 6. Looking at a chain of wrapped errors

This example shows that errors wrapped with `%w` form a nested chain and that it can be unwrapped with `errors.Unwrap()`.

```go
package main

import (
	"errors"
	"fmt"
)

func prepareReport() error {
	base := errors.New("data not available")
	loadErr := fmt.Errorf("loading data: %w", base)
	return fmt.Errorf("preparing report: %w", loadErr)
}

func main() {
	err := prepareReport()
	for err != nil {
		fmt.Println(err)
		err = errors.Unwrap(err)
	}
}
```

First the innermost error is created:

```go
base := errors.New("data not available")
```

Then it is wrapped:

```go
loadErr := fmt.Errorf("loading data: %w", base)
```

Now the chain looks roughly like this:

```text
loading data
    ↓
data not available
```

Then one more layer is added:

```go
return fmt.Errorf("preparing report: %w", loadErr)
```

As a result, the chain is:

```text
preparing report
    ↓
loading data
    ↓
data not available
```

In `main()` the loop:

```go
for err != nil {
```

keeps running as long as there is an error.

First the current outer error is printed:

```go
fmt.Println(err)
```

Then with:

```go
err = errors.Unwrap(err)
```

we move one inner layer down.

The process is roughly as follows:

```text
1. preparing report: loading data: data not available

2. loading data: data not available

3. data not available

4. nil
```

Because the innermost plain error is not wrapped, after it:

```go
errors.Unwrap(err)
```

returns `nil`.

Then the loop ends.

In practical code there is usually no need to `Unwrap()` a chain by hand. `errors.Is()` and `errors.As()` usually do the required check themselves. But this example is useful for understanding how wrapping is structured.

### 7. Joining several errors

Sometimes you need to perform several independent checks and return all the errors found together.

For this, `errors.Join()` can be used.

```go
package main

import (
	"errors"
	"fmt"
)

var ErrNameRequired = errors.New("name is required")
var ErrPriceInvalid = errors.New("price must be positive")

func validateProduct(name string, price int) error {
	var nameErr error
	var priceErr error

	if name == "" {
		nameErr = ErrNameRequired
	}
	if price < 1 {
		priceErr = ErrPriceInvalid
	}

	return errors.Join(nameErr, priceErr)
}

func main() {
	err := validateProduct("", 0)
	fmt.Println(err)
	fmt.Println(errors.Is(err, ErrNameRequired))
	fmt.Println(errors.Is(err, ErrPriceInvalid))
}
```

The function performs two independent checks:

```go
if name == "" {
```

and:

```go
if price < 1 {
```

The important point is that the function does not return right away when the first error is found.

Instead, the errors are stored in separate variables:

```go
var nameErr error
var priceErr error
```

The zero value of the `error` interface type is `nil`.

So at the start:

```text
nameErr  = nil
priceErr = nil
```

If the name is empty:

```go
nameErr = ErrNameRequired
```

If the price is invalid:

```go
priceErr = ErrPriceInvalid
```

At the end:

```go
return errors.Join(nameErr, priceErr)
```

is called.

`errors.Join()` drops the elements that are `nil` and joins the remaining errors into a single `error` value.

In the example both checks fail:

```go
validateProduct("", 0)
```

That is why both causes are present in the joined error.

As a result:

```go
errors.Is(err, ErrNameRequired)
```

is `true`, and:

```go
errors.Is(err, ErrPriceInvalid)
```

is `true` too.

This is an important property of `errors.Join()`: the causes inside a joined error can be checked with `errors.Is()` and `errors.As()`.

### 8. Running `defer` on an early return

This example shows that `defer` runs even if the function ends early because of an error.

```go
package main

import (
	"errors"
	"fmt"
)

func process(value int) error {
	fmt.Println("Process started")
	defer fmt.Println("Cleanup done")

	if value < 0 {
		return errors.New("value must not be negative")
	}

	fmt.Println("Value:", value)
	return nil
}

func main() {
	if err := process(-1); err != nil {
		fmt.Println("Error:", err)
	}
}
```

First:

```go
fmt.Println("Process started")
```

runs.

Then:

```go
defer fmt.Println("Cleanup done")
```

is registered as a deferred call.

This call does not run at that moment.

Then `value` is checked:

```go
if value < 0 {
```

In the example:

```text
value = -1
```

That is why the function ends early with:

```go
return errors.New("value must not be negative")
```

But before the `return` completes, the deferred call runs:

```text
Cleanup done
```

Only after that does control return to `main()`.

The output is roughly:

```text
Process started
Cleanup done
Error: value must not be negative
```

So `defer` runs not only in the successful `return nil` case, but also when there is an early `return` because of an error.

That is exactly why `defer` is so convenient for cleaning up resources.

### 9. The order of several `defer`s

This example shows the order in which deferred calls run.

```go
package main

import "fmt"

func steps() {
	defer fmt.Println("step 1 closed")
	defer fmt.Println("step 2 closed")
	defer fmt.Println("step 3 closed")

	fmt.Println("Main work done")
}

func main() {
	steps()
}
```

While the function runs, the `defer`s are registered in this order:

```text
step 1 closed
step 2 closed
step 3 closed
```

But they do not run in that order.

`defer`s work in LIFO order, like a stack:

```text
Last In, First Out
```

That is, the call added last runs first.

First the ordinary code runs:

```text
Main work done
```

Then the deferred calls run in the order:

```text
step 3 closed
step 2 closed
step 1 closed
```

The full output:

```text
Main work done
step 3 closed
step 2 closed
step 1 closed
```

This order is useful when working with resources.

For example, if resources were opened in this order:

```text
A
B
C
```

they usually need to be closed in reverse order:

```text
C
B
A
```

The LIFO property of `defer` matches exactly that.

### 10. Turning a `panic` into an error

In this example a function at a system boundary turns an unexpected `panic` value into an ordinary `error`.

```go
package main

import "fmt"

func safeRun(action func()) (err error) {
	defer func() {
		if value := recover(); value != nil {
			err = fmt.Errorf("action stopped: %v", value)
		}
	}()

	action()
	return nil
}

func main() {
	err := safeRun(func() {
		panic("internal state broken")
	})
	if err != nil {
		fmt.Println("Error:", err)
	}
}
```

Pay attention to the function signature in this example:

```go
func safeRun(action func()) (err error)
```

`err` is a named return value.

This means the deferred function can write to the `err` variable.

First the `defer` is registered:

```go
defer func() {
	if value := recover(); value != nil {
		err = fmt.Errorf("action stopped: %v", value)
	}
}()
```

Then:

```go
action()
```

is called.

The passed function runs:

```go
panic("internal state broken")
```

Right away the normal execution of `action()` stops.

The stack starts to unwind and the deferred function of `safeRun()` runs.

`recover()` gets the panic value:

```go
value == "internal state broken"
```

Then this value is turned into an ordinary `error`:

```go
err = fmt.Errorf("action stopped: %v", value)
```

As a result, roughly the following error is returned from `safeRun()`:

```text
action stopped: internal state broken
```

And `main()` handles it as an ordinary `error`:

```go
if err != nil {
	fmt.Println("Error:", err)
}
```

Output:

```text
Error: action stopped: internal state broken
```

This approach should not be used for ordinary checks.

For example, if the user sends a wrong value, instead of:

```go
panic("invalid value")
```

the function should return an `error` directly.

Turning a `panic` into an `error` is used more at the boundaries of servers, workers or other systems, so that an unexpected internal failure does not bring down the whole process.
