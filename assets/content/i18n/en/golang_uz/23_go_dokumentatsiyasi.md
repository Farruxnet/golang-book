# Writing and reading Go documentation

In Go, documentation is usually written in the source code itself. Ordinary comments are used for this. `go doc`, `pkg.go.dev` and other Go tools read these comments and show the developer clear documentation about the API.

That is why writing documentation does not have to mean preparing a separate large document. In many cases a well-written comment next to a type, function, method, constant or package is enough.

But good documentation does not just repeat the name in other words.

For example, a comment like this is not very useful:

```go
// DefaultLimit is the DefaultLimit value.
var DefaultLimit = 20
```

The name itself already gives almost the same information.

A more useful comment explains the purpose of the value:

```go
// DefaultLimit is the default number of items returned in one request.
var DefaultLimit = 20
```

Good documentation explains, as far as possible, what the caller needs to know:

* what the API does;
* what value it returns;
* whether it has important limitations;
* in which cases it returns an `error`;
* what special values mean;
* how the API should be used.

## Comments on exported names

In Go, if a package-level name starts with a capital letter, it is **exported**, that is, a name that other packages can use too.

For example:

```go
type User struct {
	Name string
}
```

`User` starts with a capital letter. That is why another package can use this type through an import.

The doc comment of an exported name usually starts with that name itself:

```go
// User represents a user of the system.
type User struct {
	Name string
}

// NewUser returns a new User with the given name.
func NewUser(name string) User {
	return User{Name: name}
}

// DisplayName returns the user's display name.
func (u User) DisplayName() string {
	return u.Name
}
```

There are three exported names here:

* `User`;
* `NewUser`;
* `DisplayName`.

Each of their comments starts with the corresponding name:

```text
User ...
NewUser ...
DisplayName ...
```

This way of writing makes documentation easy to read through `go doc` or `pkg.go.dev`. The reader immediately sees which API the comment is about.

Don't try to just rewrite in the comment the implementation that is obvious from the code itself.

For example:

```go
// DisplayName returns the value of u.Name.
func (u User) DisplayName() string {
	return u.Name
}
```

This comment repeats the code almost word for word.

The following version is more useful:

```go
// DisplayName returns the user's display name.
```

Because for the caller the method's external behavior matters more than exactly which field is returned inside the method.

This is one of the main principles of API documentation: **explain not the implementation, but the behavior that matters to the user**.

## Package comment

A package can also have its own documentation.

A package comment is written before the `package` declaration. It usually starts in the form `Package <name>`:

```go
// Package greeting provides greeting functions in different languages.
package greeting
```

This comment explains the purpose of the whole `greeting` package.

Here it is not about one particular function or type, but about why the package is needed as a whole.

For example, the package may contain several functions such as:

```go
func Hello(name string) string
func HelloEnglish(name string) string
func HelloUzbek(name string) string
```

The package comment, instead of explaining each of them separately, states the general goal of the package:

```go
// Package greeting provides greeting functions in different languages.
```

For a small package the comment can sit in one of the ordinary `.go` files.

For example:

```text
greeting/
    greeting.go
```

Inside `greeting.go`, writing:

```go
// Package greeting provides greeting functions in different languages.
package greeting
```

is enough.

If the package documentation is bigger, it is convenient to keep it in a separate `doc.go` file:

```text
greeting/
    doc.go
    greeting.go
    language.go
```

The `doc.go` file is usually used to keep general, wider documentation about the package.

For example:

```go
// Package greeting provides greeting functions in different languages.
//
// The package is used to create simple greeting texts.
// Supported languages are chosen through separate functions.
package greeting
```

This is not special mandatory syntax. That is, Go does not require the package comment to be only inside `doc.go`. `doc.go` is a widespread way to keep large documentation tidy.

You should avoid writing several contradicting package comments for one package. It is best to explain the general purpose of the package in one clear piece of documentation.

## Reading documentation with `go doc`

Go documentation can also be viewed right from the terminal.

The `go doc` command is used for this:

```bash
go doc fmt
go doc fmt.Println
go doc ./...
```

The first command:

```bash
go doc fmt
```

shows the documentation of the `fmt` package.

In it you can see the package description and the exported API elements.

The second command:

```bash
go doc fmt.Println
```

gives information about exactly the `Println` function.

This approach is useful for quickly finding one needed function or type inside a large package.

For example, with commands like:

```bash
go doc strings.Contains
```

or:

```bash
go doc os.File
```

you can see the documentation of a specific API.

When reviewing the current project's packages, you can work with a package path or the current package. In multi-package projects the `./...` pattern is widely used with Go toolchain commands.

`go doc` is especially convenient when you need to quickly check how an API works without leaving the terminal.

Documentation for the standard library and public Go modules can also be read on `pkg.go.dev`.

It usually shows:

* package documentation;
* exported types, functions, methods, constants and variables;
* documentation examples;
* source code links;
* module versions;
* some information about other modules that import the package.

That is why a comment in Go code is not only for the person reading the code. It is also part of the API documentation shown through the Go documentation tools.

## Example functions

One of the useful features of Go documentation is runnable `Example` functions.

An `Example` is not a plain text code snippet. It is a real Go function written in a `_test.go` file.

For example:

```go
package greeting_test

import (
	"fmt"

	"example.com/demo/greeting"
)

func ExampleHello() {
	fmt.Println(greeting.Hello("Ali"))
	// Output: Hello, Ali!
}
```

This function shows how to use the `greeting.Hello` API.

The most important part:

```go
// Output: Hello, Ali!
```

If an `// Output:` comment is present, `go test` runs the example and compares the standard output with the expected result written in the comment.

Looking at this process step by step:

1. `ExampleHello()` runs.
2. `greeting.Hello("Ali")` is called.
3. The result is printed to stdout through `fmt.Println`.
4. Go compares the produced output with the text in the `// Output:` line.
5. If the results do not match, the test fails.

So an `Example` can do two jobs at the same time:

* show the user how to use the API;
* check through a test that the example still works correctly.

The naming of `Example` functions determines which API they are tied to.

A general example for the package itself:

```go
func Example() {
	// ...
}
```

For a specific function or type:

```go
func ExampleHello() {
	// ...
}

func ExampleUser() {
	// ...
}
```

For a method:

```go
func ExampleUser_DisplayName() {
	// ...
}
```

Here:

```text
ExampleUser_DisplayName
```

is recognized as an example belonging to the `User.DisplayName` method.

An example should be as compact as possible and show typical use of the API.

For example, in a documentation example you should be careful with random results.

The following can make a test unstable:

* the current time;
* random values;
* data whose order is not guaranteed;
* an external network request;
* code whose work depends on an external service.

For example, printing the current time in the output:

```go
fmt.Println(time.Now())
```

is not a good choice for an example checked with `// Output:`. The result changes on every run.

In the same way, looping directly over map elements and checking their exact order through `Output` is also risky. You should not rely on map iteration order.

The goal of a documentation example is not to create a complex test. It should show the clearest and most stable way to use the API.

## Examples

### 1. Writing a comment for an executable package

This example shows how a package comment is written for the `main` package.

`main` is also a package. The difference is that it is usually used to build an executable program.

```go
// Package main provides a program that prints a greeting message to the terminal.
package main

import "fmt"

func main() {
	fmt.Println("Hello, Go!")
}
```

To run the project and view the documentation:

```bash
go mod init example.com/package-comment
go doc .
go run .
```

The first command:

```bash
go mod init example.com/package-comment
```

creates a new Go module in the current directory.

Then:

```bash
go doc .
```

shows the documentation of the current package.

The package comment:

```go
// Package main provides a program that prints a greeting message to the terminal.
```

is placed directly before the `package main` declaration.

The important point is that the comment does not just say:

```text
The program prints "Hello, Go!".
```

It explains the general purpose of the package:

```text
a program that prints a greeting message to the terminal
```

This is more useful from the documentation point of view. The implementation may change later, but the general purpose of the package can stay the same.

The last command:

```bash
go run .
```

runs the program.

Output:

```text
Hello, Go!
```

The main rule in this example: a package comment should briefly and clearly explain why the package exists.

### 2. Documenting a function's result

In this example the comment of an exported function describes not only the general purpose of the function but also the result for a special input.

```go
package main

import "fmt"

// Greeting returns a greeting text for the given name.
// If the name is empty, "Hello, guest!" is returned.
func Greeting(name string) string {
	if name == "" {
		return "Hello, guest!"
	}
	return "Hello, " + name + "!"
}

func main() {
	fmt.Println(Greeting("Ali"))
}
```

Commands:

```bash
go mod init example.com/function-doc
go doc -cmd . Greeting
go run .
```

The first line of the comment:

```go
// Greeting returns a greeting text for the given name.
```

explains the general purpose of the function.

The second line documents an important edge case:

```go
// If the name is empty, "Hello, guest!" is returned.
```

This information cannot be learned from the function signature:

```go
func Greeting(name string) string
```

The signature only says the function takes a `string` and returns a `string`.

What happens when `name == ""` is explained by the documentation.

When `Greeting("Ali")` is called, the condition:

```go
if name == ""
```

is `false`.

That is why:

```go
return "Hello, " + name + "!"
```

runs.

Output:

```text
Hello, Ali!
```

If:

```go
Greeting("")
```

is called, the result is:

```text
Hello, guest!
```

The main rule in this example: in documentation it helps to point out important behavior and edge cases that cannot be seen from the plain signature.

### 3. Describing the error case in the comment

If a function returns an `error`, it is important for the documentation to show in which case the caller should expect an error.

```go
package main

import (
	"errors"
	"fmt"
)

// Divide divides a by b.
// If b is zero, Divide returns an error.
func Divide(a, b float64) (float64, error) {
	if b == 0 {
		return 0, errors.New("cannot divide by zero")
	}
	return a / b, nil
}

func main() {
	result, err := Divide(10, 2)
	if err != nil {
		fmt.Println("Error:", err)
		return
	}
	fmt.Println(result)
}
```

Commands:

```bash
go mod init example.com/error-doc
go doc -cmd . Divide
go run .
```

The function signature:

```go
func Divide(a, b float64) (float64, error)
```

returns two values:

1. the result of the calculation;
2. an `error`.

If `b` is zero:

```go
if b == 0 {
	return 0, errors.New("cannot divide by zero")
}
```

runs.

In this case the first return value is:

```text
0
```

This is the zero value of the `float64` type.

But in the error case the caller should not make decisions based on that `0`.

For example, this can be a wrong approach:

```go
result, _ := Divide(10, 0)
fmt.Println(result)
```

Because `0` can also be a real calculation result.

The right approach:

```go
result, err := Divide(10, 2)
if err != nil {
	fmt.Println("Error:", err)
	return
}
```

First `err` is checked. Only when there is no error is `result` used as the real result.

For `Divide(10, 2)`:

```text
10 / 2 = 5
```

the result is printed:

```text
5
```

The main rule in this example: if the conditions under which an API returns an `error` matter to the caller, they should be written clearly in the documentation.

### 4. Documenting a type and a method

An exported `struct`, its fields and methods can each have their own meaning. That is why documentation is written for each of them where needed.

```go
package main

import "fmt"

// Account stores a user's account data.
type Account struct {
	// Name is the account owner's display name.
	Name string

	// Balance is the current amount of money in the account.
	Balance int
}

// CanPay reports whether the account has enough money for the given amount.
func (a Account) CanPay(amount int) bool {
	return amount >= 0 && a.Balance >= amount
}

func main() {
	account := Account{Name: "Ali", Balance: 100}
	fmt.Println(account.CanPay(60))
}
```

Commands:

```bash
go mod init example.com/type-doc
go doc -cmd . Account
go doc -cmd . Account.CanPay
go run .
```

The `Account` comment:

```go
// Account stores a user's account data.
```

explains the general purpose of the type.

The field comments explain the semantics of each value:

```go
// Name is the account owner's display name.
Name string
```

and:

```go
// Balance is the current amount of money in the account.
Balance int
```

`CanPay()` checks whether the money in the account is enough to pay a certain amount:

```go
func (a Account) CanPay(amount int) bool {
	return amount >= 0 && a.Balance >= amount
}
```

There are two conditions here.

The first:

```go
amount >= 0
```

is used so that a negative value is not accepted as a real payment amount.

The second:

```go
a.Balance >= amount
```

checks that the money in the account is not less than the requested amount.

The values in the example:

```text
Balance = 100
amount = 60
```

The first condition:

```text
60 >= 0
true
```

The second condition:

```text
100 >= 60
true
```

Both conditions are `true`, so:

```text
true
```

is printed.

This example shows that documentation should not be limited to repeating the type's name. If the business meaning of a field or method matters, it helps to explain it separately.

### 5. Commenting a group of constants

Constants related to one topic are often written in a `const` group.

In such a case a general comment can explain the purpose of the group, and separate comments the difference between the values.

```go
package main

import "fmt"

type Status int

// Order statuses represent the processing stages.
const (
	StatusUnknown  Status = iota // StatusUnknown means no status has been chosen yet.
	StatusAccepted               // StatusAccepted means the order was accepted.
	StatusSent                   // StatusSent means the order was sent.
)

func main() {
	fmt.Println(StatusAccepted)
}
```

Commands:

```bash
go mod init example.com/const-doc
go doc -cmd . Status
go run .
```

`iota` is used here:

```go
StatusUnknown Status = iota
```

`iota` starts from `0` in this `const` group.

The values step by step:

```text
StatusUnknown  = 0
StatusAccepted = 1
StatusSent     = 2
```

Having `StatusUnknown` be `0` is a useful choice.

The reason is that `Status` is actually a named `int` type:

```go
type Status int
```

If a new `Status` variable is not given a value, its zero value is `0`:

```go
var status Status
```

In this case:

```text
status == StatusUnknown
```

holds.

So a `Status` whose value has not been chosen yet does not accidentally mean a real business state such as `StatusAccepted` or `StatusSent`.

The general comment:

```go
// Order statuses represent the processing stages.
```

says why the constants are gathered into one group.

The comments at the end of the lines show the separate meaning of each value.

The main rule in this example: if a constant's name alone is not enough, its semantic meaning should be shown in the documentation.

### 6. Commenting an exported variable

A package-level exported variable should also have documentation.

```go
package main

import "fmt"

// DefaultLimit is the default number of items returned in one request.
var DefaultLimit = 20

func main() {
	fmt.Println("Limit:", DefaultLimit)
}
```

Commands:

```bash
go mod init example.com/variable-doc
go doc -cmd . DefaultLimit
go run .
```

From the name `DefaultLimit` you can understand that this is some kind of default limit.

But which limit?

The comment answers that question:

```go
// DefaultLimit is the default number of items returned in one request.
```

So this may be, for example, a limit related to pagination or the number of items in an API response.

Because the value is:

```go
var DefaultLimit = 20
```

the program prints:

```text
Limit: 20
```

In this example `20` was chosen as a sample default value.

The important point is that good documentation does not just say:

```text
DefaultLimit equals 20.
```

That can be seen from the code itself.

Documentation explains **what the value means**.

### 7. Linking to another name in documentation

In Go doc comments you can link to another identifier.

For example:

```go
package main

import "fmt"

// Config stores the program settings.
type Config struct {
	Port int
}

// DefaultConfig returns safe initial values for a new [Config].
func DefaultConfig() Config {
	return Config{Port: 8080}
}

func main() {
	fmt.Println(DefaultConfig().Port)
}
```

Commands:

```bash
go mod init example.com/doc-link
go doc -cmd . DefaultConfig
go run .
```

The important part:

```go
[Config]
```

The Go documentation system can connect such an identifier link to the corresponding API name.

As a result, in views that support documentation, the reader can jump to the `Config` documentation.

This is especially useful when one API depends directly on another type or function.

For example, the sentence:

```go
// DefaultConfig returns safe initial values for a new [Config].
```

shows exactly which type `DefaultConfig()` is related to.

The function returns:

```go
return Config{Port: 8080}
```

That is why the result of:

```go
DefaultConfig().Port
```

is:

```text
8080
```

Here `8080` is only the default port in the example. In a real program the default value may differ depending on project requirements, the protocol or the configuration policy.

The main rule in this example: linking other API names inside documentation helps the reader move quickly between related concepts.

### 8. Splitting a comment into headings and lists

If package documentation explains several independent ideas, it does not have to be written as one long paragraph.

Go doc comments also support structures such as headings and lists.

```go
// Package main prints the order status to the terminal.
//
// # Statuses
//
// The program uses the following values:
//
//   - new — a new order;
//   - sent — a sent order.
package main

import "fmt"

func main() {
	fmt.Println("new")
}
```

Commands:

```bash
go mod init example.com/structured-doc
go doc .
go run .
```

Let's split the comment into parts.

The first part:

```go
// Package main prints the order status to the terminal.
```

states the general purpose of the package.

Then comes an empty comment line:

```go
//
```

This helps separate paragraphs.

The heading:

```go
// # Statuses
```

creates a small section named `Statuses`.

The next part:

```go
// The program uses the following values:
```

is the introductory text of the list.

The list:

```go
//   - new — a new order;
//   - sent — a sent order.
```

explains the meaning of two values.

There is no need to use such structure in every small comment.

For example, creating a heading for the following simple comment would be excessive:

```go
// User represents a user of the system.
```

But if package documentation explains several separate topics, headings, paragraphs and lists make reading much easier.

When the program runs:

```text
new
```

is printed.

The main rule in this example: long documentation can be split into logical parts instead of turning into a wall of plain text.

### 9. Marking a deprecated API

Sometimes an old API cannot be removed all at once.

The reason is that other packages or programs may still be using it.

In such a situation the old API is kept, but the documentation shows which new API should be used instead.

```go
package main

import "fmt"

// NewGreeting returns a greeting for the given name.
func NewGreeting(name string) string {
	return "Hello, " + name
}

// OldGreeting returns a greeting for the given name.
//
// Deprecated: Use NewGreeting instead.
func OldGreeting(name string) string {
	return NewGreeting(name)
}

func main() {
	fmt.Println(OldGreeting("Ali"))
}
```

Commands:

```bash
go mod init example.com/deprecated-doc
go doc -cmd . OldGreeting
go run .
```

The important part:

```go
// Deprecated: Use NewGreeting instead.
```

`Deprecated:` is a special documentation form used to mark an old API.

Here `OldGreeting()` still works:

```go
func OldGreeting(name string) string {
	return NewGreeting(name)
}
```

So old code:

```go
OldGreeting("Ali")
```

does not break right away.

But for a developer writing new code, the documentation points the way:

```text
Use NewGreeting instead.
```

This helps do the migration step by step.

It also matters that the new function is called inside the old one:

```go
return NewGreeting(name)
```

This way the greeting logic is not duplicated in two places.

The result is:

```text
Hello, Ali
```

The main rule in this example: if a deprecated API has to be kept, the user should be clearly directed toward the new API.

### 10. Viewing the source together with the documentation

Sometimes documentation alone is not enough. You may also need to quickly see how an API is implemented.

In such a case `go doc -src` is useful.

```go
package main

import "fmt"

// NormalizeCount replaces a negative value with zero.
func NormalizeCount(count int) int {
	if count < 0 {
		return 0
	}
	return count
}

func main() {
	fmt.Println(NormalizeCount(-3))
}
```

Commands:

```bash
go mod init example.com/source-doc
go doc -src -cmd . NormalizeCount
go run .
```

Plain `go doc` helps view the API documentation.

The `-src` flag also shows the source code:

```bash
go doc -src -cmd . NormalizeCount
```

This is convenient when you need to quickly check how an API is declared and how it is implemented.

Let's look at how the function works step by step:

```go
func NormalizeCount(count int) int {
	if count < 0 {
		return 0
	}
	return count
}
```

If:

```go
NormalizeCount(-3)
```

is called, the condition:

```text
-3 < 0
```

is:

```text
true
```

That is why:

```go
return 0
```

runs.

Output:

```text
0
```

If:

```go
NormalizeCount(5)
```

is called:

```text
5 < 0
false
```

and the original value is returned:

```text
5
```

There is a subtlety here.

The condition is written as:

```go
count < 0
```

So only negative values are replaced.

For `0`:

```text
0 < 0
false
```

That is why `0` is also returned unchanged. This is correct, because zero can represent a real quantity.

The main rule in this example: `go doc -src` is useful when you need to check the implementation together with the documentation.
