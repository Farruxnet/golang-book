# External libraries and dependency management

When Go is installed, many standard packages such as `fmt`, `strings` and `net/http` come with it. Simple tasks and many practical ones can be solved with these packages alone.

But real projects also meet tasks that have no ready-made solution in the standard library. For example:

* generating a UUID;
* working with a particular database;
* reading a special configuration format;
* working with a particular protocol;
* using a ready-made client for an external service.

In such cases you can use a package created by another developer or organization. Such a package is an **external package**.

Once external code is added to a project, it becomes your project's **dependency**.

Dependency management is not only about downloading a package. It includes several tasks:

* determining which module is needed;
* choosing which version to use;
* downloading the module;
* updating the version;
* removing dependencies that are no longer needed;
* making sure exactly matching dependencies are used on another computer or in a CI environment too.

In Go this process is managed mainly through `go.mod`, `go.sum` and the module-related commands of the `go` tool.

## Package, module and library

The terms `package`, `module` and `library` are close to each other. That is why beginners may think they are the same concept.

But they mean different things.

* **Package (`package`)** — a set of Go files usually inside one directory with the same `package` name.
* **Module (`module`)** — a versioned unit defined by a `go.mod` file. One module can contain one or many packages.
* **Library (`library`)** — a general term used for code written to be reused in other programs. The Go tools themselves, however, work mostly with the concepts of `package` and `module`.

For example:

```text
github.com/google/uuid
```

In this case `github.com/google/uuid` can be both the module path and the import path of the package at the module root.

But the module path and the package path are not always exactly the same.

For example, let's imagine the following module:

```text
example.com/project
```

It can contain several packages:

```text
example.com/project/client
example.com/project/server
example.com/project/config
```

So a **module is a larger unit**, while a package can be a particular part of the code inside that module.

Go packages are not stored in one central database. Package documentation can be searched on [pkg.go.dev](https://pkg.go.dev/).

The module's actual source code usually lives in a Git repository identified by its module path.

For example, the path:

```text
github.com/google/uuid
```

also points to the module's source on GitHub.

## Why do you need an external package?

The biggest benefit of an external package is the chance to reuse code that was written before and has often been tested in practice.

For example, if the program needs a UUID, there is no need to implement the UUID format from scratch. You can use a ready-made package.

In the same way you can use external dependencies such as:

* a driver for working with PostgreSQL;
* a client for working with an API;
* a package for data validation;
* a configuration parser;
* an implementation of a special protocol.

But adding an external dependency also brings new responsibility.

For example:

* the package API may change in a new version;
* the dependency may in turn depend on other modules;
* the license may not fit your project's requirements;
* a bug inside the dependency also affects your program;
* if a security problem appears, you may also need to update the dependency version.

That is why searching for an external package right away for every small task is not the right approach.

It helps to first check whether the Go standard library can solve the task.

If an external dependency really is needed, at least the following should be reviewed:

* the package documentation;
* its license;
* its latest updates;
* API stability;
* release history;
* whether the project is still maintained.

## Preparing the project

In Go, external dependencies are usually managed inside a module.

First we create a new directory:

```bash
mkdir uuid-demo
cd uuid-demo
```

Then we start a new Go module:

```bash
go mod init example.com/uuid-demo
```

This command creates a `go.mod` file in the current directory.

`example.com/uuid-demo` is the module path we chose.

If you are only practicing locally, such an artificial name is enough.

But if the module is placed in a real public repository, its real address is usually used. For example:

```text
github.com/username/uuid-demo
```

After `go mod init` runs, a file roughly like the following is created:

```text
module example.com/uuid-demo

go 1.xx
```

The first line:

```text
module example.com/uuid-demo
```

sets the path of the current module.

The `go` directive stores a value that affects the Go-version-related semantics and toolchain behavior for the project.

For example, it may be a value such as:

```text
go 1.25
```

This value may differ depending on the installed Go toolchain and the project setting. There is no need to force it to match the value in the lesson.

Modules may be covered more deeply in later lessons. For now, what matters for working with dependencies is that `go.mod` exists.

## The first external package

To generate a UUID we use the `github.com/google/uuid` package.

Create a `main.go` file:

```go
package main

import (
	"fmt"

	"github.com/google/uuid"
)

func main() {
	id := uuid.New()
	fmt.Println("UUID:", id)
}
```

Two packages are imported here:

```go
"fmt"
```

is a package from the standard library.

The following one is an external package:

```go
"github.com/google/uuid"
```

Inside `main()`:

```go
id := uuid.New()
```

generates a new UUID.

The next line:

```go
fmt.Println("UUID:", id)
```

prints it to the terminal.

Now we bring the dependencies in line with the project state:

```bash
go mod tidy
```

Then we run the program:

```bash
go run .
```

The result will be roughly:

```text
UUID: 550e8400-e29b-41d4-a716-446655440000
```

But don't expect exactly this UUID to appear.

`uuid.New()` creates a new value every time it is called. That is why a different UUID appears on the next run.

Here `go mod tidy` does an important job.

It analyzes the imports in the project. It sees that the code imports:

```go
"github.com/google/uuid"
```

and adds the needed module to `go.mod` as a dependency.

If needed, it also downloads the module and writes the related checksum data to the `go.sum` file.

A dependency can also be added with an explicit command:

```bash
go get github.com/google/uuid@latest
```

In this command:

```text
github.com/google/uuid
```

is the module path.

```text
@latest
```

asks to choose the newest suitable version.

It is wrong to think of `go get` as simply "installing a package on the computer".

This command changes the dependency graph of the current Go module. The chosen version is tied to the project through `go.mod`.

In everyday work the following flow is often convenient:

1. `import` the needed package in the code;
2. run `go mod tidy`;
3. run the build or the tests.

**Info**

Installing a CLI program on the computer is a different action from adding a dependency.

For example:

```bash
go install example.com/cmd/tool@version
```

`go install` installs the specified command.

It does not add a dependency to the current project's `go.mod` file.

So managing module dependencies with `go get` and installing a CLI tool with `go install` are not the same task.

## Direct and indirect dependencies

Dependencies can be divided into two main kinds:

* direct dependencies;
* indirect dependencies.

A module your code imports directly is a **direct dependency**.

For example, if you have:

```go
import "github.com/google/uuid"
```

then `github.com/google/uuid` is a direct dependency of your project.

But if `github.com/google/uuid` itself requires another module, that module may not be imported directly in your code.

Such a dependency is an **indirect dependency**.

To see all modules in the module graph, you can use the command:

```bash
go list -m all
```

There is an important rule here: if you see an indirect dependency, don't delete it by hand just because you didn't import it yourself.

Another module may need it.

To bring the dependency state in line with the imports and the module graph:

```bash
go mod tidy
```

is used.

This command determines which dependencies are needed based on Go module rules.

## Choosing and updating a version

Managing dependency versions is important for reproducible builds.

For example, you can choose an exact version:

```bash
go get github.com/google/uuid@v1.6.0
```

Here:

```text
@v1.6.0
```

means the exact version of the dependency.

As a result, the project is set to use exactly this version for `github.com/google/uuid`.

The `v1.6.0` value in this lesson is used to show the command syntax.

In a real project, however, you should not choose a version just by its number.

It helps to check:

* release notes;
* the changelog;
* API changes;
* bug fixes;
* security fixes;
* compatibility with the Go version you use.

Commonly used commands when working with dependencies:

```bash
go list -m -u all
go get example.com/module@v1.2.3
go get example.com/module@latest
go mod tidy
```

Let's look at them one by one.

```bash
go list -m -u all
```

checks whether newer versions exist for the dependencies in the current module graph.

The goal of this command is not to update dependencies automatically. It helps you see the available updates.

The following command chooses an exact version:

```bash
go get example.com/module@v1.2.3
```

And the following asks for the newest suitable version:

```bash
go get example.com/module@latest
```

But using `@latest` does not mean the new version will necessarily work with your code.

After a dependency is updated, the following should be run again:

* tests;
* the build;
* static analysis;
* integration tests, if needed.

Under Semantic Versioning rules, versions are usually written like this:

```text
MAJOR.MINOR.PATCH
```

For example, when moving from:

```text
v1.4.0
```

to:

```text
v1.5.0
```

API compatibility is expected to be preserved.

But this expectation also depends on the dependency's author following Semantic Versioning rules correctly.

A major version such as `v2`, on the other hand, may contain incompatible changes.

In Go modules, major versions `v2` and above often become part of the module and import path:

```go
import "example.com/lib/v2"
```

This is very important.

For example, `example.com/lib` and:

```text
example.com/lib/v2
```

are different module paths from Go's point of view.

That is why, when moving to a higher major version, you may need to change not only `go.mod` but also the `import` lines.

## `go.mod` and `go.sum`

Two files are very important for managing dependencies in a Go module:

```text
go.mod
go.sum
```

Their jobs are not the same.

### `go.mod`

`go.mod` stores the main information about the current module.

For example, it can contain:

* the module path;
* the `go` directive;
* the required dependencies;
* their chosen versions.

A simplified example:

```text
module example.com/app

go 1.xx

require github.com/google/uuid v1.6.0
```

Here:

```text
require github.com/google/uuid v1.6.0
```

means the project depends on the chosen version of that module.

### `go.sum`

`go.sum` stores cryptographic checksums for module files.

One of its main jobs is to help verify dependency content.

For example, if a dependency was first obtained with certain content, and later unexpected different content is served under exactly the same version name, the checksum check helps detect this.

But there are several important subtleties about `go.sum`.

`go.sum`:

* does not prove that the dependency code is safe;
* does not prove that the dependency has no bugs;
* does not mean that every listed module is currently imported directly;
* does not replace a security audit.

It is mainly part of the mechanism for verifying the integrity of the obtained module content.

The `go.mod` and `go.sum` files should usually be committed to the Git repository.

This helps other developers and CI environments restore the same dependency state.

But the module cache is a different thing.

Modules downloaded by Go are usually stored in the local module cache. This cache should not be committed to the repository.

## Common mistakes

### Using `go get` without creating a module

Dependencies are managed in the context of the project module.

That is why, when starting a new project, you must first create a module:

```bash
go mod init example.com/project
```

If you are working inside an existing project, `go.mod` does not have to be in exactly the current directory. It can be in one of the directories above.

To see which `go.mod` file Go is using, you can use the command:

```bash
go env GOMOD
```

If the result does not lead to the project file you expect, you are probably working in the wrong directory.

### Writing a repository page instead of the import path

An `import` in Go code needs the correct **package import path**.

For example:

```go
import "github.com/google/uuid"
```

This value should not be confused with a random GitHub directory URL opened in the browser.

Not every directory inside a repository is a Go package.

Also, a package's import path does not always have to look the same as the page URL in the browser.

The most reliable source is the package's official documentation and the import path it gives.

### Hiding the problem by deleting `go.sum`

Sometimes, when a dependency-related checksum error appears, a beginner may try to make the problem go away with:

```bash
rm go.sum
```

Deleting the file without understanding the cause of the problem is not a good approach.

With a checksum error you should check:

* the dependency source;
* the module version;
* the proxy setting;
* the corporate proxy or private repository configuration;
* whether there is a difference between the content obtained earlier and now.

A checksum error can sometimes show exactly that the dependency content changed unexpectedly.

That is why it is important to find the cause before making the error go away.

### Not checking a dependency update

If the new version compiles successfully, that does not mean everything is right.

Even if the API signature did not change, the dependency's behavior may have changed.

For example:

* default values changed;
* when errors are returned changed;
* timeout behavior changed;
* old deprecated functions were removed;
* performance characteristics changed.

That is why after updating a dependency you should read the changelog or release notes.

Then it helps to run the project checks:

```bash
go test ./...
go vet ./...
```

If the project uses other builds or integration tests, those should be run too.

## Examples

The following examples use version `v1.6.0` of the `github.com/google/uuid` module.

The examples are independent of each other. That is why it is convenient to run each one in a separate empty directory.

This way the `go.mod`, `go.sum` or dependency state of one example does not affect another example.

### 1. Pinning the dependency version

In this example we choose an exact version of the external module and generate a new UUID.

Code:

```go
package main

import (
	"fmt"

	"github.com/google/uuid"
)

func main() {
	fmt.Println("UUID:", uuid.NewString())
}
```

Preparing and running the project:

```bash
go mod init example.com/pinned-uuid
go get github.com/google/uuid@v1.6.0
go run .
```

The first command:

```bash
go mod init example.com/pinned-uuid
```

creates a new module.

The next command:

```bash
go get github.com/google/uuid@v1.6.0
```

chooses exactly version `v1.6.0` of the `github.com/google/uuid` module.

In the code:

```go
uuid.NewString()
```

generates a new UUID on every call and returns it as a string.

The result may look like, for example:

```text
UUID: 550e8400-e29b-41d4-a716-446655440000
```

But a different value appears on the next run.

The main rule in this example is pinning the dependency version.

Choosing an exact version helps make sure exactly the same dependency version is used in different environments.

### 2. Using `go mod tidy` after an import

This example shows the process of bringing dependency data in line with the imports in the code.

Code:

```go
package main

import (
	"fmt"

	"github.com/google/uuid"
)

func main() {
	id := uuid.New()
	fmt.Println(id.String())
}
```

Commands:

```bash
go mod init example.com/tidy-uuid
go get github.com/google/uuid@v1.6.0
go mod tidy
go run .
```

First:

```bash
go get github.com/google/uuid@v1.6.0
```

chooses the needed exact version.

Then:

```bash
go mod tidy
```

brings the imports and the module dependency state in line with each other.

`go mod tidy` is not limited to adding dependencies. It can also remove unneeded dependency entries.

In the code:

```go
id := uuid.New()
```

creates a UUID value.

Then:

```go
id.String()
```

turns the UUID into its string form.

So two separate concepts appear in this example:

1. the dependency version is chosen with `go get`;
2. the module files are brought in line with the real imports in the code with `go mod tidy`.

### 3. Seeing the chosen module version

Sometimes, rather than opening `go.mod` by hand, it is convenient to see through a command exactly which module version Go chose.

In this example a UUID is parsed from text and the dependency version is also checked.

Code:

```go
package main

import (
	"fmt"

	"github.com/google/uuid"
)

func main() {
	id, err := uuid.Parse("550e8400-e29b-41d4-a716-446655440000")
	if err != nil {
		fmt.Println("Error:", err)
		return
	}

	fmt.Println(id)
}
```

Commands:

```bash
go mod init example.com/list-version
go get github.com/google/uuid@v1.6.0
go list -m github.com/google/uuid
go run .
```

The following command:

```bash
go list -m github.com/google/uuid
```

prints the version chosen for `github.com/google/uuid` in the module graph.

In this example a result roughly like:

```text
github.com/google/uuid v1.6.0
```

is expected.

In the code:

```go
uuid.Parse(...)
```

tries to turn a UUID in string form into a `uuid.UUID` value.

The function returns two values:

```go
id, err := uuid.Parse(...)
```

`id` is the successfully parsed UUID.

`err` is the error information if an error occurs.

That is why:

```go
if err != nil {
	fmt.Println("Error:", err)
	return
}
```

checks the error first.

Besides checking the dependency version, this example also shows the usual way of handling errors in Go.

### 4. Getting the list of available versions

Before moving to a new version, you can see which versions exist for a module.

In this example the program checks the UUID format, and the list of module versions is obtained in the terminal.

Code:

```go
package main

import (
	"fmt"

	"github.com/google/uuid"
)

func main() {
	value := "550e8400-e29b-41d4-a716-446655440000"
	if err := uuid.Validate(value); err != nil {
		fmt.Println("Invalid UUID:", err)
		return
	}

	fmt.Println("The UUID format is valid")
}
```

Commands:

```bash
go mod init example.com/uuid-versions
go get github.com/google/uuid@v1.6.0
go list -m -versions github.com/google/uuid
go run .
```

The following command:

```bash
go list -m -versions github.com/google/uuid
```

shows the versions found for the module.

An important point: this command does not update the dependency.

It only gives information about the available versions.

Then you choose which version to move to yourself. For that, release notes and API compatibility should be checked.

In the code:

```go
uuid.Validate(value)
```

checks whether the given string matches the UUID format.

If the value is valid, `Validate()` returns:

```go
nil
```

Then the code does not enter the `if`, and:

```text
The UUID format is valid
```

is printed.

### 5. Checking why a dependency is needed

In a larger project, seeing a dependency in `go.mod` or in the module graph, the question:

> Why is this module needed?

sometimes comes up.

`go mod why` helps with that.

Code:

```go
package main

import (
	"fmt"

	"github.com/google/uuid"
)

func main() {
	id := uuid.MustParse("550e8400-e29b-41d4-a716-446655440000")
	users := map[uuid.UUID]string{
		id: "Ali",
	}

	fmt.Println(users[id])
}
```

Commands:

```bash
go mod init example.com/why-uuid
go get github.com/google/uuid@v1.6.0
go mod why -m github.com/google/uuid
go run .
```

The following command:

```bash
go mod why -m github.com/google/uuid
```

shows the path of packages leading from the main module to this dependency.

That is, Go helps explain why this module is in the dependency graph.

In the code:

```go
id := uuid.MustParse(...)
```

turns a UUID string known in advance into a `uuid.UUID` value.

Unlike the ordinary `Parse()`, `MustParse()` panics instead of returning an `error` when it gets an invalid value.

That is why it is not a good choice for unknown values entered by users.

In this example, however, the value is written in the code in advance and we know it is valid. That is why `MustParse()` was used.

The next part:

```go
users := map[uuid.UUID]string{
	id: "Ali",
}
```

uses `uuid.UUID` as a `map` key.

This is possible because `uuid.UUID` is a comparable type.

Then:

```go
fmt.Println(users[id])
```

gets the value belonging to that UUID key:

```text
Ali
```

### 6. Seeing the graph of module relations

Dependencies may not consist of just one level.

One module can depend on another module, which in turn depends on yet another module.

These relations between modules form a **dependency graph**.

Code:

```go
package main

import (
	"fmt"

	"github.com/google/uuid"
)

func main() {
	id, err := uuid.NewV7()
	if err != nil {
		fmt.Println("UUID was not created:", err)
		return
	}

	fmt.Println(id)
}
```

Commands:

```bash
go mod init example.com/uuid-graph
go get github.com/google/uuid@v1.6.0
go mod graph
go run .
```

The following command:

```bash
go mod graph
```

prints the dependency relations between modules.

Each line shows a relation roughly like:

```text
requiring-module required-module
```

In a small project and a module with few dependencies the result may be short.

In a larger project, however, the graph is much bigger.

In the code:

```go
id, err := uuid.NewV7()
```

tries to create a version 7 UUID.

This function returns an `error` along with the UUID.

That is why:

```go
if err != nil {
	fmt.Println("UUID was not created:", err)
	return
}
```

checks the error.

Only after the operation succeeds is:

```go
fmt.Println(id)
```

run.

### 7. Downloading and verifying dependencies in advance

Sometimes it helps to download all the needed modules before the build starts.

For example, in a CI pipeline or an environment where network use has to be controlled in advance.

Code:

```go
package main

import (
	"fmt"

	"github.com/google/uuid"
)

func main() {
	data := make([]byte, 16)
	id, err := uuid.FromBytes(data)
	if err != nil {
		fmt.Println("Error:", err)
		return
	}

	fmt.Println(id)
}
```

Commands:

```bash
go mod init example.com/verify-uuid
go get github.com/google/uuid@v1.6.0
go mod download
go mod verify
go run .
```

The following command:

```bash
go mod download
```

is used to download the module dependencies into the local module cache.

The next command:

```bash
go mod verify
```

checks whether the dependency content in the cache matches the checksums recorded earlier.

This does not audit the security of the dependency code.

Its job is different: to check that the downloaded module files match the expected content.

Now let's look at the code.

```go
data := make([]byte, 16)
```

creates a `[]byte` of length `16`.

All elements of a byte slice created with `make` initially get the zero value:

```text
0
```

That is why, conceptually, the value equals:

```text
[0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]
```

Because a UUID consists of `16` bytes:

```go
uuid.FromBytes(data)
```

can create a `uuid.UUID` from this slice.

Because the function also returns an `error`, it is always checked.

### 8. Checking for updates separately

Checking whether a new version of a dependency exists and updating it are two different actions.

In this example only the availability of an update is checked.

Code:

```go
package main

import (
	"fmt"

	"github.com/google/uuid"
)

func main() {
	first := uuid.NewString()
	second := uuid.NewString()

	fmt.Println("Same:", first == second)
}
```

Commands:

```bash
go mod init example.com/check-version
go get github.com/google/uuid@v1.6.0
go list -m -u github.com/google/uuid
go run .
```

First:

```bash
go get github.com/google/uuid@v1.6.0
```

chooses an exact version.

Then:

```bash
go list -m -u github.com/google/uuid
```

checks whether a newer version exists for this module.

If an update exists, the command may show information about the chosen and the new version.

An important point:

```bash
go list -m -u
```

does not update `go.mod`.

It only gives information.

Before updating a dependency, the following should be checked:

* release notes;
* the changelog;
* the chance of breaking changes;
* test results.

In the code:

```go
first := uuid.NewString()
second := uuid.NewString()
```

two separate new UUIDs are created.

Then:

```go
first == second
```

compares them.

In the ordinary case they are different. That is why the result is expected to be:

```text
Same: false
```

### 9. Removing an unused dependency

A dependency may once have been needed and later removed from the code.

In such a case there is no need to always clean up `go.mod` by hand.

`go mod tidy` can bring the dependency state in line with the real imports in the code.

Final code:

```go
package main

import "fmt"

func main() {
	fmt.Println("No external dependency is needed")
}
```

Commands:

```bash
go mod init example.com/remove-dependency
go get github.com/google/uuid@v1.6.0
go mod tidy
go run .
```

Here, first:

```bash
go get github.com/google/uuid@v1.6.0
```

adds `github.com/google/uuid` as a dependency.

But if we look at the program code, it has no:

```go
import "github.com/google/uuid"
```

The code uses only the standard package:

```go
import "fmt"
```

After that, when:

```bash
go mod tidy
```

runs, Go analyzes the imports.

It determines that `github.com/google/uuid` is no longer needed and removes its unneeded `require` entry from `go.mod`.

The main rule here is that the dependency list should be kept in sync with the real state of the code as much as possible.

That is why, instead of editing dependency lines by hand for no reason, using:

```bash
go mod tidy
```

is usually safer and more convenient.

### 10. Collecting dependencies into a `vendor` directory

Normally Go manages dependencies through the module cache.

But some projects may require copying the dependency packages needed for the build into the project itself.

The `vendor` directory can be used for this.

Code:

```go
package main

import (
	"fmt"

	"github.com/google/uuid"
)

func main() {
	id := uuid.MustParse("550e8400-e29b-41d4-a716-446655440000")
	fmt.Println("UUID version:", id.Version())
}
```

Commands:

```bash
go mod init example.com/vendor-uuid
go get github.com/google/uuid@v1.6.0
go mod vendor
go run -mod=vendor .
```

First the dependency is added with an exact version:

```bash
go get github.com/google/uuid@v1.6.0
```

Then the command:

```bash
go mod vendor
```

places the dependency packages needed for the build into the project's:

```text
vendor/
```

directory.

For example, the project structure may look roughly like this:

```text
example-project/
├── go.mod
├── go.sum
├── main.go
└── vendor/
```

The next command:

```bash
go run -mod=vendor .
```

explicitly tells Go to use the dependencies from the `vendor` directory.

In the code:

```go
id := uuid.MustParse("550e8400-e29b-41d4-a716-446655440000")
```

parses a UUID known in advance.

Then:

```go
id.Version()
```

returns the version of the UUID.

The result is printed depending on the UUID value.

Using a `vendor` directory is not mandatory for every project.

Whether to commit it to the Git repository also depends on the project's policy.

For example, some teams use `vendor` to:

* keep all dependency code together with the build;
* reduce dependence on the external network;
* follow a special build policy.

In other projects the ordinary Go module cache and `go.mod`/`go.sum` are enough.

The important point is that even when a `vendor` directory is used:

```text
go.mod
go.sum
```

remain the main module files that manage the choice of dependencies.
