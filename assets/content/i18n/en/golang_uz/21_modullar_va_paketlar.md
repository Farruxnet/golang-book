# Modules and packages in Go

In a Go project, a **package** and a **module** are related concepts, but they do different jobs.

A package splits code into logical parts. For example, code related to calculations can be placed in a `calc` package, and code related to HTTP in another package.

A module manages one or more packages as a single versioned unit. A module is used to manage dependencies and to determine the full import path of packages.

Understanding this difference matters, because in a Go project it is exactly the concepts of package and module that answer questions such as:

* which part the code belongs to;
* how to import a function from another package;
* which version of a dependency is used;
* which code is visible from outside packages;
* which module the project belongs to.

## What is a package?

A **package** is a set of Go files that usually live in one directory and have the same `package` name.

For example:

```text
calc/
├── add.go
├── subtract.go
└── square.go
```

If all three of these files start with the line:

```go
package calc
```

they belong to the same `calc` package.

A package does several jobs:

* splits code into logical parts;
* creates a namespace for identifiers;
* decides which names are visible from other packages;
* works as a unit of compilation;
* lets code be reused in other packages.

The main rules:

* every `.go` file starts with a `package <name>` line;
* ordinary `.go` files in one directory usually belong to one package;
* the name of an imported package must not collide with other package names in the code;
* `package main` and `func main()` together form the entry point of an executable program.

There is a subtlety here.

Test files can differ a little from ordinary `.go` files. For example, the tests of the `calc` package can be written in one of two ways:

```go
package calc
```

or:

```go
package calc_test
```

The first version runs the test inside the package itself. That is why the test can also see the unexported names inside the package.

The second version works like an external package. Here the test uses the `calc` package only through its exported API.

## The `main` package

In Go, to build an executable program the package name must be `main`.

The following complete program creates an executable package:

```go
package main

import "fmt"

func main() {
	fmt.Println("Working with a Go package!")
}
```

It can be run like this:

```bash
go run main.go
```

Output:

```text
Working with a Go package!
```

Two separate rules are at work here.

The first:

```go
package main
```

tells Go that this package can be an executable program.

The second:

```go
func main()
```

marks the function where the program starts.

So writing a function named `main()` alone is not enough. It must be in the `main` package.

For example:

```go
package new_name

func main() {
}
```

This code has a `main()`. But the package is not `main`. That is why it is not accepted as the entry point of an executable program.

Trying to run it as a command may give an error like this:

```text
package command-line-arguments is not a main package
```

So the special meaning of the `main()` function appears only inside `package main`.

If `main()` is written in another package, it is not a special entry point. It is just an ordinary function named `main`.

> **Info**
>
> A library package does not need a `main()`. The job of a library package is to provide functions, types, constants and variables that other packages can import.

## What is a module?

A **module** is a set of packages defined by a `go.mod` file.

Put simply, a package splits code into internal parts. A module defines which project and which versioned unit those packages belong to.

Let's create a new project:

```bash
mkdir my-project
cd my-project
go mod init example.com/my-project
```

`go mod init` creates a `go.mod` file in the current directory.

The result will look roughly like this:

```text
module example.com/my-project

go 1.xx
```

Here:

```text
module example.com/my-project
```

sets the **canonical path** of the module.

Later, when packages inside the module are imported, this path becomes the start of the import.

For example, if the module contains a `calc` directory:

```text
my-project/
├── go.mod
└── calc/
    └── calc.go
```

its import path is usually:

```text
example.com/my-project/calc
```

The line in `go.mod`:

```text
go 1.xx
```

expresses the module's requirement related to the Go version.

This line does not install Go on the computer. It matters for which rules the module semantics, language features and toolchain should apply.

The exact version value depends on the Go toolchain in the environment where `go mod init` was run.

## Creating a local package

Now let's create a separate local package inside the module.

Project structure:

```text
my-project/
├── go.mod
├── main.go
└── calc/
    └── calc.go
```

The `calc/calc.go` file:

```go
package calc

func Add(a, b int) int {
	return a + b
}

func Square(n int) int {
	return n * n
}

func subtract(a, b int) int {
	return a - b
}
```

Because this file starts with:

```go
package calc
```

it belongs to the `calc` package.

The package contains three functions:

```go
Add
Square
subtract
```

Then we write `main.go`:

```go
package main

import (
	"fmt"

	"example.com/my-project/calc"
)

func main() {
	fmt.Println(calc.Square(3))
	fmt.Println(calc.Add(3, 2))
}
```

We run the program at the project root:

```bash
go run .
```

Output:

```text
9
5
```

Now let's see step by step how the import path was formed.

The module path in `go.mod`:

```text
example.com/my-project
```

And the package lives in the directory:

```text
calc/
```

That is why the full import path is:

```text
example.com/my-project
+
/calc
=
example.com/my-project/calc
```

When importing, Go does not point to the `.go` file itself.

For example, you don't write:

```go
import "example.com/my-project/calc/calc.go"
```

Instead, the directory where the package lives is imported:

```go
import "example.com/my-project/calc"
```

The `.` in the `go run .` command means the current directory. Go builds and runs the `main` package in the current directory.

Pay attention to the `Square()` function too:

```go
func Square(n int) int {
	return n * n
}
```

There is no need to use `math.Pow` here.

For example, if it were written with `math.Pow`, you would usually have to work with `float64`:

```go
math.Pow(float64(n), 2)
```

But we are calculating the square of an `int`. That is why:

```go
n * n
```

is simpler and more precise.

Besides that, no extra `int -> float64 -> int` conversion is needed.

> **Warning**
>
> With very large `int` values, `n * n` can cause an integer overflow. This example uses a small value, so there is no such problem.

## Exported names

In Go, identifiers visible outside the package boundary are called **exported names**.

The main rule is very simple:

> If an identifier starts with a capital letter, it is exported.

In the previous example:

```go
func Add(a, b int) int
```

and:

```go
func Square(n int) int
```

start with a capital letter.

That is why another package can use them:

```go
calc.Add(3, 2)
calc.Square(3)
```

But:

```go
func subtract(a, b int) int
```

starts with a lower-case letter.

That is why `subtract` is visible only inside the `calc` package itself.

For example, the following code does not compile inside another package:

```go
// This code does not compile inside another package:
// fmt.Println(calc.subtract(5, 2))
```

The compiler error says that `calc.subtract` is not exported.

This rule does not apply only to functions. It also applies to:

* types;
* struct fields;
* methods;
* variables;
* constants;
* functions.

For example:

```go
type User struct {
	Name string
	age  int
}
```

Here `User` and `Name` are exported. `age` is visible only inside the package.

But writing a name with a capital letter is not enough to create a good API.

For example:

```go
func X(a int) int
```

may be an exported function. But from the name `X` you cannot tell what it does.

That is why, for an exported API:

* a clear name;
* a precise purpose;
* the necessary documentation;
* stable behavior

also matter.

There is a similar rule for package names.

It is usually best to choose a package name that is:

* short;
* lower-case;
* clear;
* singular.

For example:

```text
http
json
user
config
```

Very general names such as `utils`, `common` or `helpers` should be used with care.

The reason is that over time such packages can turn into a place where unrelated functions pile up. As a result the package loses a clear responsibility.

## How is an import found?

To understand Go import paths, it helps to separate three main steps.

### 1. The current module path is determined

Go first looks at the `go.mod` file.

For example, if it says:

```text
module example.com/my-project
```

the base path of the current module is:

```text
example.com/my-project
```

### 2. The directory inside the module is determined

For example, for the following package:

```text
my-project/
└── calc/
```

the remaining part is:

```text
/calc
```

This way the import:

```go
import "example.com/my-project/calc"
```

is formed.

### 3. For an external module, its version is chosen

If the import does not belong to the current module, Go checks the dependency modules.

For example, for:

```go
import "example.com/other-module/client"
```

`example.com/other-module` may be an external module.

In this case Go determines through the module graph which version is included in the build.

### Import path and package name

In most cases the directory name and the package name are the same.

For example, inside:

```text
calc/
```

you write:

```go
package calc
```

But this is not a strict mandatory rule.

For example, even if the directory is:

```text
calc/
```

a different package name can be declared inside the file:

```go
package calculator
```

The import path still stays based on the directory:

```go
import "example.com/my-project/calc"
```

But in the code the declared name of the package is used:

```go
calculator.Add(...)
```

In practice, keeping the directory name and the package name the same, or clearly related in meaning, makes code easier to understand.

### Import alias

Sometimes two packages may have the same name.

Or you may need to refer to a package in the code by a different, clearer name.

In such cases you can give the import a local alias:

```go
import mathops "example.com/my-project/calc"
```

Now the package is used in the form:

```go
mathops.Add(...)
```

An important point: the alias does not change the import path.

The package is still imported from the path:

```text
example.com/my-project/calc
```

Only in the current file is it referred to by the name `mathops`.

There is no need to give every import an alias. It is best used mainly:

* when names collide;
* when the package's usual name is confusing in the given context.

## `go.mod` directives

The main file of Go's module system is `go.mod`.

Several directives can appear in it.

### `module`

Sets the current module path:

```text
module example.com/my-project
```

This value becomes the start of the import path of local packages inside the module.

### `go`

Sets the module's requirement related to the Go version:

```text
go 1.xx
```

This directive does not install Go on the computer. It affects the language and toolchain semantics used for the module.

### `require`

Lists an external dependency and its required version.

For example:

```text
require example.com/lib v1.2.3
```

This means the current module depends on the `example.com/lib` module.

### `replace`

Replaces the source of a dependency with another path or version.

This is especially convenient during local development.

For example:

```text
replace example.com/shared => ../shared
```

Here, instead of getting the `example.com/shared` module from the internet, Go uses the local directory:

```text
../shared
```

Let's picture this situation:

```text
projects/
├── app/
│   └── go.mod
└── shared/
    └── go.mod
```

While working on `app`, you may need to test a local version of the `shared` module that has not been published yet.

Then:

```text
replace example.com/shared => ../shared
```

is a convenient solution.

> **Warning**
>
> A `replace` pointing to a local directory may not work on another computer. For example, another developer may not have the `../shared` directory. That is why, before committing such a `replace`, make sure the team and the CI environment can find that path.

### `exclude`

Is used to exclude a particular module version from selection.

For example, if a particular version of a dependency has a serious problem, it can be removed from the build list with `exclude`.

`go.sum`, choosing dependency versions, the module graph and the commands that work with them are explained in detail
in the lesson on external libraries and dependency management. In this lesson we focus on local packages and module
structure.

## `internal` packages

Some packages should be used only inside the project.

For example, loading configuration or the implementation of an internal service may be code that outside users should not import.

For such cases Go has the `internal` directory.

For example:

```text
my-project/
├── go.mod
├── internal/
│   └── config/
└── main.go
```

Here:

```text
internal/config
```

is not an ordinary directory name. `internal` has a special meaning for the Go toolchain.

Go allows a package inside `internal` to be imported only by code within the permitted parent directory tree.

For example, the package above:

```text
my-project/internal/config
```

is usually available to code inside this project's tree.

But if an external module tries to use it directly, Go rejects the import.

This is useful in large projects.

For example, you may have a:

```text
public API
```

and an:

```text
internal implementation
```

If you leave the internal implementation as an ordinary exported package, other projects may accidentally come to depend on it.

Later, changing the implementation becomes hard.

`internal`, on the other hand, protects this boundary not only with documentation but at the level of the Go toolchain.

## Common mistakes

### Using relative imports

In Go module mode, importing a local package like this is not the right approach:

```go
import "./calc"
```

Instead, use the module path:

```go
import "example.com/my-project/calc"
```

The advantage of this approach is that the import is tied not to the directory's random location on disk, but to the module's canonical path.

For example, even if the project is moved to another directory:

```text
/home/user/projects/my-project
```

or:

```text
/work/src/my-project
```

the import path does not change:

```go
import "example.com/my-project/calc"
```

### Creating an import cycle

Go does not allow cyclic imports.

For example, if a dependency of the form:

```text
a -> b
b -> a
```

appears, the build fails.

Let's imagine:

```go
// package a
import "example.com/project/b"
```

and:

```go
// package b
import "example.com/project/a"
```

Here building package `a` requires `b`.

But building `b` requires `a` again.

As a result, the dependency forms a cycle.

In such a situation the architecture usually needs to be reconsidered.

For example, shared types or functions can be moved into a third, small package, in the form:

```text
a -> shared
b -> shared
```

Another solution is to redesign the direction of dependencies.

For example, instead of package `a` depending on `b` and package `b` depending on `a` at the same time, higher-level code can bring the two packages together.

### Running a single file

Let's imagine the `main` package consists of two files:

```text
app/
├── main.go
└── helper.go
```

`main.go` may use a function declared in `helper.go`.

If you run:

```bash
go run main.go
```

Go works based on exactly the file you named. That is why the needed code in the other file may be left out.

In such a situation this is usually more correct:

```bash
go run .
```

This command builds the whole package in the current directory.

### Creating a separate module for every directory

Not every Go package needs its own `go.mod`.

For example, in the structure:

```text
shop/
├── go.mod
├── cmd/
├── user/
├── order/
└── payment/
```

there is no need to create separate `go.mod` files for the `user`, `order` and `payment` packages.

All of them can be packages of the single module:

```text
shop
```

A separate module is useful only when a real module boundary is needed.

For example:

* the component must be versioned independently;
* it is released separately;
* other projects use it as an independent dependency;
* its dependency lifecycle must be separated from the main repository.

Otherwise, creating a module for every directory makes dependency management unnecessarily complex.

## What do interviews focus on?

On the topic of packages and modules, it is useful to be able to explain the following differences clearly in an interview.

* A **package** is a unit of code organization, compilation and namespacing.
* A **module** is the versioning and dependency-management boundary of a set of packages.
* Exported names start with a capital letter. This rule applies at the package boundary.
* `go.mod` stores the module path and the dependency version requirements.
* `go.sum` stores checksums of dependency contents.
* Go does not allow import cycles.
* Major versions `v2` and above usually use a suffix like `/v2`, `/v3` in the module and import path.
* There is no need to create a separate module for every package.
* The `internal` directory is used to restrict internal implementation at the import level.

In the next lesson we will see adding an external library to a module, and after that writing Go documentation for an exported API.

## Examples

The following examples show different aspects of working with packages and modules separately.

It is convenient to treat each example as an independent small project. If you try them out in practice, create a separate directory for each. Otherwise running `go mod init` again and again in one directory can lead to situations like `go.mod already exists`.

### 1. Creating the smallest module

In this example a new module is started for a single executable package.

`main.go`:

```go
package main

import "fmt"

func main() {
	fmt.Println("The first module works")
}
```

Creating and running the project:

```bash
mkdir first-module
cd first-module
go mod init example.com/first-module
go run .
```

Let's go through the commands step by step.

```bash
mkdir first-module
```

creates a new directory.

```bash
cd first-module
```

moves into that directory.

Then:

```bash
go mod init example.com/first-module
```

creates `go.mod` in the current directory.

Roughly the line:

```text
module example.com/first-module
```

appears in it.

Here:

```text
example.com/first-module
```

is the module path.

The line in the code:

```go
package main
```

says this is an executable package.

Finally:

```bash
go run .
```

builds and runs the `main` package in the current directory.

Output:

```text
The first module works
```

The main rule in this example:

> A module is defined by `go.mod`, and an executable package by `package main` and `func main()`.

### 2. Using package-level names

In this example a variable and a function are declared in the package-level namespace of the `main` package.

```go
package main

import "fmt"

var greeting = "Hello"

func message(name string) string {
	return greeting + ", " + name
}

func main() {
	fmt.Println(message("Go"))
}
```

Running:

```bash
go mod init example.com/package-scope
go run .
```

In this code:

```go
var greeting = "Hello"
```

is declared outside any function.

That is why `greeting` is a package-level variable.

Likewise:

```go
func message(name string) string
```

is also a function declared at package level.

When:

```go
message("Go")
```

is called inside `main()`, `message()` reaches the line:

```go
return greeting + ", " + name
```

Here:

```text
greeting = "Hello"
name = "Go"
```

That is why the result is:

```text
Hello, Go
```

`greeting` and `message` start with lower-case letters.

So they are visible inside this package, but are not exported to other packages.

An important point: the module path:

```text
example.com/package-scope
```

does not change the namespace inside the package.

A module defines the dependency and import boundary. A package affects the visibility boundary of identifiers in code.

### 3. Separating exported and internal names

In this example functions with a capital and a lower-case first letter are used inside the same package.

```go
package main

import "fmt"

func PublicMessage() string {
	return "an exported name"
}

func privateMessage() string {
	return "a package-only name"
}

func main() {
	fmt.Println(PublicMessage())
	fmt.Println(privateMessage())
}
```

Running:

```bash
go mod init example.com/export-demo
go run .
```

In the code:

```go
func PublicMessage() string
```

starts with a capital letter.

That is why `PublicMessage` is an exported name.

But:

```go
func privateMessage() string
```

starts with a lower-case letter.

That is why it is not exported.

At first glance a question may arise: why can `main()` call both functions?

The reason is that all three functions are inside the same:

```go
package main
```

Within the package itself, the export rule does not restrict internal use.

Exporting only affects visibility from outside the package.

So:

```go
PublicMessage()
privateMessage()
```

both work inside this package.

But if another package imports this package, it can use only:

```go
PublicMessage()
```

Output:

```text
an exported name
a package-only name
```

The main rule in this example:

> A capital letter marks export outside the package. It does not restrict use inside the package.

### 4. The order of `init()` and `main()`

In this example `init()` runs while the package is being prepared, and `main()` runs after it.

```go
package main

import "fmt"

var status = "not started"

func init() {
	status = "ready"
	fmt.Println("init:", status)
}

func main() {
	fmt.Println("main:", status)
}
```

Running:

```bash
go mod init example.com/init-demo
go run .
```

Let's go through the process step by step.

First the package-level variable gets its initial value:

```go
var status = "not started"
```

So at first:

```text
status = "not started"
```

Then `init()` runs:

```go
func init() {
	status = "ready"
	fmt.Println("init:", status)
}
```

Here `status` changes to the value:

```text
"ready"
```

After that:

```text
init: ready
```

is printed.

Then `main()` starts:

```go
func main() {
	fmt.Println("main:", status)
}
```

`status` has already been changed by `init()`.

That is why the result is:

```text
init: ready
main: ready
```

You usually don't call `init()` directly from code. Go runs it itself as part of the package initialization process.

The main rule in this example:

> In the `main` package, `main()` starts only after package initialization has finished.

### 5. Giving an import a local name

In this example the `fmt` package is imported with the local name `format`.

```go
package main

import format "fmt"

func main() {
	format.Println("Called through a package alias")
}
```

Running:

```bash
go mod init example.com/import-alias
go run .
```

Normally, if you write:

```go
import "fmt"
```

the code uses:

```go
fmt.Println(...)
```

In this example, however:

```go
import format "fmt"
```

is written.

In this syntax:

```text
format
```

is the local alias.

```text
"fmt"
```

is the real import path.

That is why the code uses:

```go
format.Println(...)
```

An important point: the imported package did not change.

It is still the standard library's:

```text
fmt
```

package.

Only in this file was it given the name:

```text
format
```

An alias is usually useful:

* when packages with the same name collide;
* when another name is clearer in the current context.

But in the ordinary case, leaving `fmt` as `fmt` makes reading easier.

Output:

```text
Called through a package alias
```

### 6. Importing several packages in a group

In this example two standard packages are imported.

```go
package main

import (
	"errors"
	"fmt"
)

func main() {
	err := errors.New("sample error")
	fmt.Println(err)
}
```

Running:

```bash
go mod init example.com/grouped-imports
go run .
```

When there are several imports, grouping them in parentheses is the usual way in Go:

```go
import (
	"errors"
	"fmt"
)
```

The `errors` package creates a new `error` value with:

```go
errors.New("sample error")
```

This value is given to the `err` variable on the line:

```go
err := errors.New("sample error")
```

Then:

```go
fmt.Println(err)
```

prints the error.

Output:

```text
sample error
```

`gofmt` helps format imports in the standard way.

For example, the groups between local project packages and standard library packages can be kept tidy with tools such as `gofmt` or `goimports`.

The main rule in this example:

> Grouping several packages inside an `import (...)` block is the standard, readable way in Go code.

### 7. Seeing the current module path

In this example a module is created and its canonical path is checked with a Go command.

```go
package main

import "fmt"

func main() {
	fmt.Println("The module path is stored in go.mod")
}
```

Commands:

```bash
go mod init example.com/module-path
go list -m
go run .
```

First:

```bash
go mod init example.com/module-path
```

creates `go.mod`.

It contains the line:

```text
module example.com/module-path
```

Then:

```bash
go list -m
```

prints the path of the current main module.

The result is:

```text
example.com/module-path
```

This value is not just for information.

If we later create a new package inside the module:

```text
client/
```

its import path can be:

```text
example.com/module-path/client
```

So the module path seen through `go list -m` is used as the beginning of local package imports.

Then:

```bash
go run .
```

runs the program.

Output:

```text
The module path is stored in go.mod
```

### 8. Getting information about the current package

In this example `go list` shows the package name and import path in the current directory.

```go
package main

import "fmt"

func main() {
	fmt.Println("Current package: main")
}
```

Commands:

```bash
go mod init example.com/package-info
go list -f "{{.Name}} {{.ImportPath}}" .
go run .
```

The main command here:

```bash
go list -f "{{.Name}} {{.ImportPath}}" .
```

`go list` can give various metadata about a package.

The `-f` flag sets the output format through a template.

In the template:

```text
.Name
```

means the package name.

Because our code has:

```go
package main
```

we get:

```text
.Name = main
```

In the template:

```text
.ImportPath
```

means the package's import path.

Because the module is:

```text
example.com/package-info
```

and the package lives at the module root, the import path is:

```text
example.com/package-info
```

The output comes out as:

```text
main example.com/package-info
```

Then:

```bash
go run .
```

runs the program.

Output:

```text
Current package: main
```

The main rule in this example:

> The package name and the import path are not the same concept. `.Name` comes from the package declaration, and `.ImportPath` from the module and the directory location.

### 9. Tidying the module file

In this example `go mod tidy` brings the module files in line with the code's imports.

```go
package main

import "fmt"

func main() {
	values := []int{2, 4, 6}
	fmt.Println("Values:", values)
}
```

Commands:

```bash
go mod init example.com/tidy-demo
go mod tidy
go run .
```

The code uses only:

```go
import "fmt"
```

`fmt` is part of the Go standard library.

Standard library packages do not require a `require` entry in `go.mod` as an external module dependency.

That is why, after running:

```bash
go mod tidy
```

no external dependency appears.

This is not an error.

On the contrary, an empty dependency list is exactly the right state for this program.

The job of `go mod tidy` is not simply to add dependencies.

It brings the module files to the required state based on the imports in the code.

For example, if an external package starts being used in the future, `tidy` can adjust the required dependency entries.

If a dependency is no longer used, it can also remove the extra entries.

Program output:

```text
Values: [2 4 6]
```

The main rule in this example:

> `go mod tidy` is used not to create dependencies but to keep the code's imports and the module metadata consistent with each other.

### 10. Building an executable from a module

In this example `go build` creates an executable file from the current `main` package.

```go
package main

import "fmt"

func main() {
	fmt.Println("A built program")
}
```

Commands:

```bash
go mod init example.com/build-demo
go build -o build-demo .
```

Here:

```bash
go build
```

compiles the code.

Unlike `go run`, the main goal is not to run the program right away. `go build` produces a build result.

The flag:

```bash
-o build-demo
```

sets the name of the output file explicitly.

So on Unix-like systems an executable named roughly:

```text
build-demo
```

appears in the directory.

On Windows, the behavior related to executable naming and extensions adapts to the platform.

The part at the end of the command:

```bash
.
```

means the package in the current directory.

Because this directory contains:

```go
package main
```

and:

```go
func main()
```

an executable program is built.

If the current directory is an ordinary library package, it is not built as a `main` executable.

For example, if the package:

```go
package calc
```

serves as a library, `go build` can compile it to check it, but the goal is not to create an executable from it as with a `main` program.

When the built program is run, the output is:

```text
A built program
```

The main rule in this example:

> `go run` builds and runs temporarily, while `go build` is used to compile a package and can create an executable from a `main` package.
