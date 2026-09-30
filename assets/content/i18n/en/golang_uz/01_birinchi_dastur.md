# Our first program

In this lesson we write our first Go program, one that prints information to the terminal as text.

With this simple example we will look at several important things:

* how a Go program is structured;
* where a program starts running;
* how to use a function from another package;
* how `go run` runs the code;
* how the compiler checks the code;
* how an executable file is built.

Create a folder named `first-program` on your computer. If you created it in the previous lesson, open it in your code editor.

Inside the folder, create a file named `main.go`.

The name `main.go` is not a requirement of the Go compiler. You could also call the file, for example, `hello.go`. What matters is that the file has the `.go` extension and the code inside it is written correctly.

In this lesson we use the name `main.go`, because it is very common in small Go programs.

**Warning**

Some operating systems hide file extensions.

```
So check that the file has not accidentally become `main.go.txt`. `main.go.txt` is not a Go source file, because its real extension is `.txt`.
```

## The first program

Write the following code in `main.go`:

```go
package main

import "fmt"

func main() {
	fmt.Println("Hello, world!")
}
```

Save the file.

Then open a terminal and go to the folder that contains `main.go`. Run the program with this command:

```bash
go run main.go
```

`go run` checks the Go code, compiles it and runs the temporary program it produces.

If the code is correct, the terminal shows this result:

```text
Hello, world!
```

This output comes from the following line of code:

```go
fmt.Println("Hello, world!")
```

`"Hello, world!"` is the value passed to the `Println()` function.

`Println()` writes that value to the terminal. Then it automatically adds a newline character as well.

That is why the next terminal output starts on a new line.

## How does the code work?

Now let's go through the program line by line.

### `package main`

The first line:

```go
package main
```

says which package the Go file belongs to.

A **package** is a way of grouping Go files that belong to one task.

For example, if a folder contains several `.go` files, they usually use the same package name.

Here the package name is:

```go
main
```

`main` is a package name with a special meaning: it is used to build an executable program.

In general, Go packages can be used for two kinds of jobs:

* packages that provide functions and types for other code to use;
* the `main` package, which builds a program that runs directly.

For example, `fmt` provides ready-made functions for other programs to use. The `main` package, on the other hand, is used to build an executable program.

But writing only:

```go
package main
```

is not enough.

A program that runs must also have a `main()` function:

```go
func main() {
}
```

This function takes no parameters and returns no value.

So the basic shape of an executable Go program is:

```go
package main

func main() {
}
```

If the `main` package does not have the required `main()` function, the executable program has no entry point.

### `import "fmt"`

The next line:

```go
import "fmt"
```

lets us use ready-made code from another package.

`import` is how you bring another package into the current Go file so you can use it.

Here:

```go
"fmt"
```

is the import path of the `fmt` package from the Go standard library.

Go comes with many ready-made packages. Together they are called the **standard library**.

The `fmt` package is used for tasks like these:

* printing values to the terminal;
* formatting text;
* printing several values together;
* in some cases, reading data from the terminal.

In this lesson we only use the function:

```go
fmt.Println()
```

In Go, an imported package must be used.

For example, in this code:

```go
package main

import "fmt"

func main() {
}
```

`fmt` is imported but never used.

In this case the compiler reports an error.

This is one of Go's important rules. It keeps unnecessary imports from piling up in the code.

### `func main()`

The following line:

```go
func main() {
```

declares a function named `main`.

`func` is the keyword used to declare a function in Go.

We will study functions in detail in later lessons. For now, you can think of a function as a block of code that performs a specific task.

Here the function name is:

```text
main
```

The `main()` function of the `main` package is the **entry point** of an executable program.

Put simply, when the program starts, the main code begins running from exactly this function.

The Go runtime prepares the program to start and then runs the `main.main` function.

The following curly braces:

```go
{
}
```

mark the boundaries of the function body.

For example, in this code:

```go
func main() {
	fmt.Println("Hello, world!")
}
```

the line:

```go
fmt.Println("Hello, world!")
```

is inside the body of the `main()` function.

In this example the function contains only one statement.

Statements in Go code are usually executed from top to bottom.

So in this program the flow can be pictured simply like this:

```text
main() starts
       ↓
fmt.Println(...) runs
       ↓
main() ends
       ↓
the program ends
```

There is one more subtle rule here.

When the `main()` function ends, the whole program ends too. If other goroutines are still running, `main()` does not wait for them automatically.

We will study goroutines separately in later lessons. For now it is enough to remember that `main()` defines the main life cycle of an executable Go program.

### `fmt.Println("Hello, world!")`

Now let's look at the main statement:

```go
fmt.Println("Hello, world!")
```

On this line we call the `Println()` function from the `fmt` package.

The dot:

```text
fmt.Println
   ^
```

means we are referring to a name inside the package on the left.

Here:

* `fmt` is the package;
* `Println` is a function inside that package.

The function is given this value:

```go
"Hello, world!"
```

This is a **string** value in Go.

A string is data in the form of text.

The double quotes:

```text
"Hello, world!"
```

mark where the string starts and where it ends.

The quotes themselves are not printed.

That is why the code:

```go
fmt.Println("Hello, world!")
```

prints:

```text
Hello, world!
```

and not:

```text
"Hello, world!"
```

The value `"Hello, world!"` is passed to the `Println()` function as an **argument**.

An argument is a value given to a function when it is called.

You can picture this process simply like this:

```text
"Hello, world!"
       ↓
fmt.Println(...)
       ↓
printed to the terminal
       ↓
a newline is added
```

You can remember the `ln` part of `Println()` as "line". After printing its values, the function adds a newline at the end.

If a newline should not be added automatically, you can use the `fmt.Print()` function.

For example:

```go
fmt.Print("Hello, ")
fmt.Print("world!")
```

These two calls can write on a single line:

```text
Hello, world!
```

For now, though, `fmt.Println()` will be more convenient in our lessons.

### Semicolons

In many programming languages a semicolon is written at the end of a statement:

```text
;
```

Go's syntax has the idea of a semicolon too.

But Go programmers usually do not write `;` at the end of every line.

For example, we write:

```go
fmt.Println("Hello")
fmt.Println("World")
```

not:

```go
fmt.Println("Hello");
fmt.Println("World");
```

The reason is that the Go lexer automatically inserts semicolons in many places according to the syntax rules.

That is why `;` is almost never written in everyday Go code.

But this does not mean "you can break code onto a new line anywhere".

For example, the placement of curly braces matters in some cases.

The usual way to write it in Go:

```go
func main() {
	fmt.Println("Hello")
}
```

Moving the opening `{` brace to another line can cause a compilation error.

One of the reasons for this is exactly the automatic semicolon insertion rules.

That is why it is important to write Go code in the standard style and format it with `gofmt`.

## `go run`

We ran the program with this command:

```bash
go run main.go
```

This command goes through several stages.

Let's look at the process step by step.

### 1. The file is read

First, the Go tools read the file:

```text
main.go
```

### 2. The code is checked

The compiler checks that the code is correct.

For example:

* is the syntax correct;
* do the names used exist;
* are the imports correct;
* do the types match each other;
* are the declarations written correctly.

If an error is found at this stage, compilation does not continue.

### 3. The code is compiled

Code that passes the checks is compiled into a form the computer can execute.

### 4. A temporary program is run

`go run` automatically runs the temporary executable program it produced.

The whole process:

```text
main.go
   ↓
check
   ↓
compile
   ↓
temporary executable program
   ↓
run
   ↓
Hello, world!
```

If compilation fails, the `main()` function does not run at all.

There is an important distinction here.

For example, if the terminal shows:

```text
Hello, world!
```

our program printed it with:

```go
fmt.Println("Hello, world!")
```

If a message about a syntax error appears, it is printed not by our program but by the Go compiler or the Go tools.

So:

```text
compilation message → comes from the Go tools

program output      → comes from the code we wrote
```

This distinction will become very important later when analyzing errors.

## Building an executable file

`go run` is convenient for trying code out quickly.

But sometimes you need to build the program as a separate executable file.

For that we use `go build`:

```bash
go build -o hello main.go
```

Let's split the command into parts.

`go build`:

```bash
go build
```

compiles the Go code.

The `-o` flag:

```bash
-o hello
```

sets the name of the executable file to produce.

`main.go`:

```bash
main.go
```

is the source file to compile.

So the command:

```bash
go build -o hello main.go
```

creates an executable program named `hello` in the current folder.

On Windows the file usually looks like:

```text
hello.exe
```

On macOS and Linux it may look like:

```text
hello
```

On macOS and Linux, run the program like this:

```bash
./hello
```

Here:

```text
./
```

means the file in the current folder should be run.

In PowerShell you use the command:

```powershell
.\hello.exe
```

In both cases the program gives the same result:

```text
Hello, world!
```

The main difference between `go run` and `go build` can be remembered like this.

`go run`:

```text
code
 ↓
compile
 ↓
run right away
```

This is convenient for lessons and quick experiments.

`go build`:

```text
code
 ↓
compile
 ↓
save the executable file
```

This is convenient for running the program later.

To run a finished executable Go program, the computer usually does not need to have the Go compiler installed.

The reason is that compilation has already been done.

There is one small caveat: an executable built for a different operating system or processor architecture may not run on the current system. For example, an executable built for Linux usually does not run directly on Windows.

## Comments

A **comment** is text written to give additional explanation to the person reading the code.

For example, a comment can explain:

* what the code does;
* why it is written exactly this way;
* the reason for a complex decision;
* what needs to change later.

The compiler does not execute a comment as a program statement.

### Single-line comments

A single-line comment starts with:

```text
//
```

For example:

```go
// Prints "Hello, world!" to the screen.
fmt.Println("Hello, world!")
```

The first line is a comment:

```go
// Prints "Hello, world!" to the screen.
```

It is not executed.

The next line is ordinary Go code:

```go
fmt.Println("Hello, world!")
```

and it is executed.

Everything from the `//` sign to the end of the line is a comment.

A comment can also be written after code:

```go
fmt.Println("Hello") // prints text to the terminal
```

But comments should not multiply too much. If the code itself is clear, there is no need to comment every simple line.

### Multi-line comments

A multi-line comment starts with:

```text
/*
```

and ends with:

```text
*/
```

For example:

```go
/*
This comment
can span several lines.
*/
```

The text between `/*` and `*/` is not executed by the compiler as a program statement.

In Go code, `//` is usually used more often for everyday comments.

`//` is especially common in documentation comments for packages, functions, types and other declarations.

## Common mistakes

Even though the first program is very small, it has a few mistakes that beginners often run into.

### Mixing up upper and lower case

The following call is wrong:

```go
// fmt.println("Hello, world!") // error: the fmt package has no println
```

Go distinguishes between upper-case and lower-case letters.

So:

```text
Println
```

and:

```text
println
```

are not the same name.

The correct function we need is:

```go
fmt.Println
```

In real projects too, a difference of a single letter in a package, function, variable or type name means referring to a completely different name.

If no such name exists, the compiler reports an error.

### Not closing a quote or a parenthesis

The following code is wrong:

```go
fmt.Println("Hello, world!) // error: missing closing quote
```

If a string starts with:

```text
"
```

it must be closed with another:

```text
"
```

in the right place.

The correct version:

```go
fmt.Println("Hello, world!")
```

The same rule applies to parentheses and curly braces.

For example, this code:

```go
fmt.Println("Hello"
```

is missing the closing:

```text
)
```

And this code:

```go
func main() {
	fmt.Println("Hello")
```

is missing the closing:

```text
}
```

The compiler detects such syntax problems and prints an error message.

Sometimes the error message appears not on the line where the mistake starts, but on a later line. The reason is that the compiler may notice the incorrect syntax later.

### Running the command in the wrong folder

If the terminal is not in the folder that contains `main.go`, the command:

```bash
go run main.go
```

may not find the file.

On macOS and Linux you can check the current folder with:

```bash
pwd
```

The files in the folder are shown by:

```bash
ls
```

In PowerShell you can check the current folder with:

```powershell
Get-Location
```

And the files are shown by:

```powershell
Get-ChildItem
```

For example, the folder should show this file:

```text
main.go
```

If the file is in another folder, first move the terminal to that folder.

### Forgetting `package main` or `main()`

An executable Go program must have the package:

```go
package main
```

That package must also contain the function:

```go
func main() {
}
```

For example, the following code has no `main()`:

```go
package main

import "fmt"

func hello() {
	fmt.Println("Hello")
}
```

`hello()` is an ordinary function. It does not automatically become the starting point of the program.

An executable program needs `main.main`.

Conversely, even if there is a `main()` but the package has a different name, no executable `main` program is produced.

So both conditions are needed together:

```text
package main
+
func main()
```

## Formatting program code

`gofmt` is used to bring Go code to the standard style.

Run the following command in the terminal:

```bash
gofmt -w main.go
```

`gofmt` adjusts the appearance of the code to Go's standards.

For example, it brings:

* indentation;
* spacing;
* line layout;
* some syntax formats

to a consistent style.

The `-w` flag:

```text
-w
```

means the formatted result is written back to the `main.go` file itself.

If the code is already formatted correctly, there may be no visible change.

An important point: `gofmt` does not check the program's logic.

For example, the following code is correct in terms of syntax and formatting:

```go
fmt.Println("Goodbye, world!")
```

But if the task is to print `"Hello, world!"`, this may be a logically wrong result.

`gofmt` does not fix that.

Run the formatted file again:

```bash
go run main.go
```

The result is the same again:

```text
Hello, world!
```

This is natural. Formatting changes how the code looks, not its purpose or how it works.

## Key ideas

Even though this first program is small, it contains several core ideas that will come up again and again in later lessons.

* `package main` is used to build an executable program.
* `main()` is the main entry point of an executable Go program.
* `import` lets you use code from another package.
* `fmt.Println()` prints values to the terminal and adds a newline at the end.
* Go distinguishes between upper-case and lower-case letters.
* An imported package must be used.
* `go run` compiles the code and immediately runs a temporary program.
* `go build` builds an executable file and keeps it.
* `gofmt` brings code to the standard Go format, but does not fix logical errors.
* A compilation message and the output of the program must be told apart.

In the next lesson we will learn about variables, which store values under a name so they can be used again.
