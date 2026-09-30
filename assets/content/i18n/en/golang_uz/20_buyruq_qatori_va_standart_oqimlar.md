# Command-line programs and standard streams

A command-line interface, or **CLI** (`Command Line Interface`), is a program controlled through the terminal.

Such a program usually:

* takes arguments from the terminal;
* reads extra data through `stdin` if needed;
* prints its result to `stdout`;
* writes errors and diagnostic messages to `stderr`;
* returns an exit code when it finishes.

In Go, small and medium CLI programs can be written without external libraries. Packages from the standard library such as `os`, `flag`, `fmt`, `bufio` and `io` are enough for that.

For example, in the following command:

```bash
go run main.go apple pomegranate
```

`apple` and `pomegranate` are the arguments given to the program.

Or:

```bash
go run main.go -name Dilshod -count 2
```

here `-name` and `-count` are named parameters, that is, flags.

Now let's see step by step how this data is obtained and used inside a Go program.

## Getting arguments with `os.Args`

All the arguments given to a Go program on the command line are stored in `os.Args`.

The type of `os.Args` is:

```go
[]string
```

that is, a slice of `string` values.

An important rule is that `os.Args[0]` is not the first argument given by the user. The first element usually holds the name or path of the program that was run.

For example:

```go
package main

import (
	"fmt"
	"os"
)

func main() {
	fmt.Println("Program:", os.Args[0])
	fmt.Println("Arguments:", os.Args[1:])
}
```

We run the program like this:

```bash
go run main.go apple pomegranate
```

Here roughly the following situation arises:

```text
os.Args[0]    -> path of the running program
os.Args[1]    -> "apple"
os.Args[2]    -> "pomegranate"
os.Args[1:]   -> ["apple", "pomegranate"]
```

`os.Args[1:]` is a slice expression. It drops the program name at index `0` and returns the arguments given by the user.

There is another subtlety when working with `go run`. Go first builds a temporary executable file and then runs it. That is why:

```go
os.Args[0]
```

does not have to be `main.go`. It may be the path of the temporary executable file.

That is why tying program logic to the exact value of `os.Args[0]` is not a good approach.

For example, avoid a check like this:

```go
if os.Args[0] == "main.go" {
	// ...
}
```

Because with a compiled binary or with `go run` this value can be different.

`os.Args` is very convenient for simple positional arguments. But when named parameters such as `-name`, `-count` and `-quiet` multiply, parsing them by hand becomes awkward. In such a situation the `flag` package is useful.

## The `flag` package

The `flag` package makes declaring and parsing command-line flags simpler.

For example:

```go
name := flag.String("name", "guest", "user name")
count := flag.Int("count", 1, "number of repetitions")
quiet := flag.Bool("quiet", false, "don't print the result")
flag.Parse()
```

Three flags were declared here:

```text
-name
-count
-quiet
```

They can be used like this:

```bash
go run main.go -name Dilshod -count 3 -quiet
```

Let's look at each declaration separately.

```go
name := flag.String("name", "guest", "user name")
```

`flag.String()` takes three main arguments:

```text
"name"       -> flag name
"guest"      -> default value
"user name"  -> help text
```

As a result the function returns a `*string`, that is, a pointer to a `string`.

That is why, to get the value later, you write:

```go
*name
```

The same rule applies to `flag.Int()` and `flag.Bool()`:

```go
count := flag.Int("count", 1, "number of repetitions")
quiet := flag.Bool("quiet", false, "don't print the result")
```

The types of these values:

```text
name  -> *string
count -> *int
quiet -> *bool
```

But just declaring flags is not enough.

When:

```go
flag.Parse()
```

is called, the `flag` package parses the real command-line arguments and updates the corresponding values.

For example, with:

```bash
go run main.go -name Ali -count 5
```

after `flag.Parse()`:

```text
*name  == "Ali"
*count == 5
*quiet == false
```

Because `quiet` was not given in the command, its default value `false` is kept.

### Positional arguments and `flag.Args()`

Ordinary arguments can also be used together with flags.

For example:

```bash
go run main.go -name Ali file1.txt file2.txt
```

After `flag.Parse()`, the remaining arguments that are not flags can be obtained with:

```go
flag.Args()
```

Roughly:

```text
flag.Args() -> ["file1.txt", "file2.txt"]
```

This approach is useful in CLI programs that use flags and positional arguments together.

## Standard streams

The operating system usually provides three standard streams for a running process:

* `os.Stdin` — standard input;
* `os.Stdout` — standard output;
* `os.Stderr` — the standard error stream.

These three streams are separate from each other.

In the ordinary case their output may appear in the same place in the terminal. But through the shell they can be redirected to separate files or to other processes.

### `os.Stdin`

`os.Stdin` is the stream of data coming into the program.

For example, the user may type text in the terminal. Or another program may send data through a `pipe`.

In Go you can read from it like this:

```go
fmt.Fscan(os.Stdin, &value)
```

or, to read line by line:

```go
scanner := bufio.NewScanner(os.Stdin)
```

### `os.Stdout`

`os.Stdout` is used for normal results.

For example:

```go
fmt.Fprintln(os.Stdout, "Result ready")
```

`fmt.Println()` also usually writes to stdout.

That is why:

```go
fmt.Println("Hello")
```

and:

```go
fmt.Fprintln(os.Stdout, "Hello")
```

give the same result in the terminal in the ordinary case.

The advantage of the second version is that it is clear which `io.Writer` is being written to. This is also convenient when writing tests.

### `os.Stderr`

`os.Stderr` is used for errors and diagnostic messages.

For example:

```go
fmt.Fprintln(os.Stderr, "Error: invalid value")
```

Why don't we write the error to ordinary `stdout`?

The reason is that `stdout` and `stderr` can be controlled separately through the shell.

For example, you can write the program's result to a file:

```bash
./app > result.txt
```

and keep the error messages in the terminal.

Or you can send the errors to a separate file:

```bash
./app 2> errors.txt
```

This matters especially for scripts, servers and CLI tools that are connected with other programs.

If a program writes its successful result to `stdout` and its errors to `stderr`, an external program can tell them apart.

For example:

```go
fmt.Fprintln(os.Stdout, "Result ready")
fmt.Fprintln(os.Stderr, "Error: invalid value")
```

Both of these lines may appear in the terminal, but they were written to different streams.

## Exit code

A CLI program does not only print text. When the process finishes, it also returns a numeric **exit code** to the operating system.

Usually:

```text
0 -> success
any value other than 0 -> some kind of error
```

For example, a shell script can find out through the exit code whether the command before it finished successfully.

In Go, to end the process with a particular code:

```go
os.Exit(code)
```

is used.

For example:

```go
os.Exit(0)
```

can mean a successful finish, while:

```go
os.Exit(1)
```

can mean an error.

The meaning of specific non-zero values is decided by the program's author.

For example, you can agree on a convention such as:

```text
1 -> the user gave an invalid value
2 -> the flag syntax is wrong
```

### `os.Exit()` and `defer`

There is an important subtlety here.

**Warning**

When `os.Exit()` is called, the functions scheduled with `defer` do not run.

For example:

```go
func main() {
    defer fmt.Println("Cleanup")

    os.Exit(1)
}
```

Here you might expect:

```text
Cleanup
```

to be printed. But `os.Exit()` ends the process immediately. That is why the `defer` does not run.

This can cause problems for closing files, flushing buffers, cleaning up temporary resources or other cleanup work.

That is why the common approach is:

```go
func run() int {
    // The main work.
    // defer can be used.

    return 0
}

func main() {
    os.Exit(run())
}
```

Here all the main work is done inside `run()`.

Because `run()` is an ordinary function, the `defer`s run normally when it returns.

Only at the very end does `main()` set the process exit code with:

```go
os.Exit(...)
```

## A working CLI example

Now let's combine arguments, flags, `stdout`, `stderr` and exit codes in one program.

```go
package main

import (
	"errors"
	"flag"
	"fmt"
	"io"
	"os"
)

func run(args []string, stdout, stderr io.Writer) int {
	fs := flag.NewFlagSet("hello", flag.ContinueOnError)
	fs.SetOutput(stderr)
	name := fs.String("name", "", "name to greet")
	count := fs.Int("count", 1, "number of repetitions")
	quiet := fs.Bool("quiet", false, "don't print the result")

	if err := fs.Parse(args); err != nil {
		return 2
	}
	if *name == "" {
		fmt.Fprintln(stderr, errors.New("the -name parameter is required"))
		return 1
	}
	if *count < 1 {
		fmt.Fprintln(stderr, "error: -count must be positive")
		return 1
	}
	if *quiet {
		return 0
	}
	for i := 0; i < *count; i++ {
		fmt.Fprintf(stdout, "Hello, %s!\n", *name)
	}
	return 0
}

func main() {
	os.Exit(run(os.Args[1:], os.Stdout, os.Stderr))
}
```

We run the program like this:

```bash
go run main.go -name Dilshod -count 2
```

Output:

```text
Hello, Dilshod!
Hello, Dilshod!
```

There are several important decisions in this example.

The first:

```go
func run(args []string, stdout, stderr io.Writer) int
```

`run()` is not tied directly to the global `os.Args`, `os.Stdout` and `os.Stderr`.

It gets the arguments through a parameter:

```go
args []string
```

The output streams are also passed as parameters:

```go
stdout io.Writer
stderr io.Writer
```

This makes writing tests much easier. In a test, a `bytes.Buffer` can be passed instead of the real terminal.

For example, by passing an in-memory buffer instead of `stdout`, you can check exactly what text the program wrote.

The next important part:

```go
fs := flag.NewFlagSet("hello", flag.ContinueOnError)
```

This creates a separate `FlagSet` instead of the default flags of the global `flag` package.

With `flag.ContinueOnError`, an error during flag parsing does not end the process automatically. The error is returned from `fs.Parse()`:

```go
if err := fs.Parse(args); err != nil {
	return 2
}
```

This lets the CLI program itself control how errors are handled.

Then:

```go
fs.SetOutput(stderr)
```

redirects the error and help texts printed by the `FlagSet` to the `stderr` stream we passed.

The default value for `-name` is an empty string:

```go
name := fs.String("name", "", "name to greet")
```

That is why we can later check whether it was given:

```go
if *name == "" {
	fmt.Fprintln(stderr, errors.New("the -name parameter is required"))
	return 1
}
```

The `count` value is checked too:

```go
if *count < 1 {
	fmt.Fprintln(stderr, "error: -count must be positive")
	return 1
}
```

Here the flag syntax may be correct, while the value is wrong for the business rule.

For example:

```bash
go run main.go -name Ali -count -5
```

`-5` can be read as an `int`. But by the program's requirement the number of repetitions must be at least `1`. That is why this is validated separately.

If `quiet` is enabled:

```go
if *quiet {
	return 0
}
```

the program prints no greeting, but finishes successfully.

Otherwise the loop:

```go
for i := 0; i < *count; i++ {
	fmt.Fprintf(stdout, "Hello, %s!\n", *name)
}
```

prints the result `count` times.

At the end:

```go
return 0
```

means success.

And `main()` passes three real values to `run()` with:

```go
os.Exit(run(os.Args[1:], os.Stdout, os.Stderr))
```

```text
os.Args[1:] -> the user's arguments
os.Stdout   -> normal output
os.Stderr   -> the error stream
```

The number returned by `run()` becomes the process exit code.

In this structure:

```text
flag syntax error -> 2
invalid value     -> 1
success           -> 0
```

is returned.

## Examples

### 1. Getting the first positional argument

This example shows getting the first positional argument given by the user through `os.Args`.

The program uses the argument as a name.

```go
package main

import (
	"fmt"
	"os"
)

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Usage: program NAME")
		return
	}

	name := os.Args[1]
	fmt.Println("Hello,", name)
}
```

The most important part here:

```go
if len(os.Args) < 2 {
```

`os.Args` almost always contains at least one element:

```text
os.Args[0]
```

which is the program's name or path.

If the user gave an argument, it is in:

```text
os.Args[1]
```

That is why, before accessing `os.Args[1]`, we check that the slice length is at least `2`.

If there were no such check and the user gave no argument:

```go
name := os.Args[1]
```

would access a missing index, and the program could panic at runtime.

When an argument is given:

```bash
go run main.go Ali
```

the output is:

```text
Hello, Ali
```

The main rule of this example: `os.Args[0]` belongs to the program, and the user's first argument is in `os.Args[1]`.

### 2. Looking at all positional arguments

This example prints all the positional arguments given by the user with their position numbers.

```go
package main

import (
	"fmt"
	"os"
)

func main() {
	args := os.Args[1:]
	if len(args) == 0 {
		fmt.Println("No arguments given")
		return
	}

	for index, value := range args {
		fmt.Printf("%d: %s\n", index+1, value)
	}
}
```

First, with:

```go
args := os.Args[1:]
```

we drop the program name.

For example, with:

```bash
go run main.go apple pomegranate grape
```

we get:

```text
args == ["apple", "pomegranate", "grape"]
```

Then:

```go
if len(args) == 0 {
```

checks whether the user gave any arguments at all.

If there are arguments:

```go
for index, value := range args {
```

walks over the slice elements.

The `index` in `range` starts at `0`:

```text
0 -> apple
1 -> pomegranate
2 -> grape
```

But it is usually more convenient to show position numbers to the user starting from `1`. That is why:

```go
index + 1
```

is used.

Output:

```text
1: apple
2: pomegranate
3: grape
```

This example shows that a slice index and the position number shown to the user are not the same thing.

### 3. Setting a default value for a flag

In this example default values are set for the `-name` and `-count` flags.

If the user does not give the flags, the program uses these values.

```go
package main

import (
	"flag"
	"fmt"
)

func main() {
	name := flag.String("name", "guest", "user name")
	count := flag.Int("count", 1, "number of repetitions")
	flag.Parse()

	for i := 0; i < *count; i++ {
		fmt.Println("Hello,", *name)
	}
}
```

Here, because of:

```go
name := flag.String("name", "guest", "user name")
```

if `-name` is not given:

```text
*name == "guest"
```

Likewise, because of:

```go
count := flag.Int("count", 1, "number of repetitions")
```

if `-count` is not given:

```text
*count == 1
```

That is why the output of:

```bash
go run main.go
```

is:

```text
Hello, guest
```

If it is run as:

```bash
go run main.go -name Ali -count 3
```

the output is:

```text
Hello, Ali
Hello, Ali
Hello, Ali
```

Let's look at the loop:

```go
for i := 0; i < *count; i++ {
```

If `count = 3`:

```text
i = 0 -> runs
i = 1 -> runs
i = 2 -> runs
i = 3 -> i < 3 is false, the loop ends
```

As a result the code runs exactly three times.

A default value of `1` for `count` makes sense in this example. Even if the user gives nothing, the program greets at least once.

### 4. A boolean flag and the remaining arguments

This example shows getting a `bool` flag and the remaining positional arguments besides it.

```go
package main

import (
	"flag"
	"fmt"
)

func main() {
	upper := flag.Bool("upper", false, "enable upper-case mode")
	flag.Parse()

	fmt.Println("Upper-case mode:", *upper)
	fmt.Println("Remaining arguments:", flag.Args())
}
```

The default value for `upper` is:

```go
false
```

This means the mode is off by default.

If the user runs:

```bash
go run main.go
```

the output looks like:

```text
Upper-case mode: false
Remaining arguments: []
```

If it is run as:

```bash
go run main.go -upper apple pomegranate
```

then:

```text
*upper == true
```

`flag.Parse()` parses `-upper` as a flag.

The remaining arguments:

```text
apple
pomegranate
```

are obtained with:

```go
flag.Args()
```

The output is roughly:

```text
Upper-case mode: true
Remaining arguments: [apple pomegranate]
```

This example shows how flags and positional arguments can be separated in one CLI.

### 5. Writing a value into an existing variable

`flag.String()` returns a new `*string` value.

But sometimes it is more convenient to write the value into a variable declared in advance. For that there is `flag.StringVar()`.

```go
package main

import (
	"flag"
	"fmt"
)

func main() {
	var city string
	flag.StringVar(&city, "city", "Tashkent", "city name")
	flag.Parse()

	fmt.Println("City:", city)
}
```

First:

```go
var city string
```

is written.

The zero value of the `string` type is the empty string:

```text
""
```

Then:

```go
flag.StringVar(&city, "city", "Tashkent", "city name")
```

is called.

Here `&city` is the address of the `city` variable.

During parsing, the `flag` package writes the value into that variable itself.

If the user runs:

```bash
go run main.go
```

the default value is used:

```text
City: Tashkent
```

With:

```bash
go run main.go -city Samarkand
```

the output is:

```text
City: Samarkand
```

With `flag.String()` you would write:

```go
city := flag.String(...)
```

and then have to use:

```go
*city
```

`StringVar()`, on the other hand, updates an existing variable. That is why afterwards you use it directly:

```go
city
```

### 6. Seeing only the flags that were explicitly given

Sometimes a program needs to know which flags the user actually wrote.

Having a default value does not mean the flag was given in the command.

In such a situation `flag.Visit()` is used.

```go
package main

import (
	"flag"
	"fmt"
)

func main() {
	flag.String("name", "guest", "user name")
	flag.Int("count", 1, "number of repetitions")
	flag.Bool("quiet", false, "quiet mode")
	flag.Parse()

	fmt.Println("Explicitly given flags:")
	flag.Visit(func(item *flag.Flag) {
		fmt.Printf("-%s=%s\n", item.Name, item.Value.String())
	})
}
```

This program has three flags:

```text
-name
-count
-quiet
```

But `flag.Visit()` sees not all of them, only the ones the user explicitly wrote in the command.

For example, with:

```bash
go run main.go -name Ali -quiet
```

the output is:

```text
-name=Ali
-quiet=true
```

`count`, even though it has the default value:

```text
1
```

was not written in the command. That is why it does not appear in `flag.Visit()`.

This difference can be useful in configuration systems.

For example, a value may come to the program from a config file, an environment variable or a CLI flag. Then it may matter whether the user explicitly gave the flag through the CLI or the default value was used.

### 7. Reading one value from standard input

In this example one value is read from `stdin` with `fmt.Fscan()`.

```go
package main

import (
	"fmt"
	"os"
)

func main() {
	var product string
	fmt.Fprint(os.Stdout, "Product name: ")

	if _, err := fmt.Fscan(os.Stdin, &product); err != nil {
		fmt.Fprintln(os.Stderr, "Error: could not read the name")
		return
	}

	fmt.Fprintln(os.Stdout, "Received:", product)
}
```

First, with:

```go
var product string
```

an empty `string` is created.

Then:

```go
fmt.Fprint(os.Stdout, "Product name: ")
```

prints a prompt for the user.

The main reading is done with:

```go
fmt.Fscan(os.Stdin, &product)
```

The reason for passing `&product` here matters.

`Fscan()` must write the value it reads into the `product` variable. For that it needs the variable's address.

If reading fails, the condition:

```go
if _, err := fmt.Fscan(...); err != nil {
```

holds and the error is written to `stderr` with:

```go
fmt.Fprintln(os.Stderr, "Error: could not read the name")
```

In the successful case:

```go
fmt.Fprintln(os.Stdout, "Received:", product)
```

runs.

Data can be typed into this program by hand in the terminal.

But `stdin` does not mean only the keyboard.

For example, in the command:

```bash
echo notebook | go run main.go
```

the output of `echo` is passed through a pipe to the `stdin` of the next program.

The flow is roughly:

```text
echo
  |
  v
"notebook"
  |
  v
stdin
  |
  v
fmt.Fscan()
  |
  v
product
```

As a result the value of `product` is:

```text
notebook
```

### 8. Reading standard input line by line

When working with multi-line input, `bufio.Scanner` is convenient.

In this example each line coming from `stdin` is printed with its line number.

```go
package main

import (
	"bufio"
	"fmt"
	"os"
)

func main() {
	scanner := bufio.NewScanner(os.Stdin)
	lineNumber := 1

	for scanner.Scan() {
		fmt.Fprintf(os.Stdout, "%d: %s\n", lineNumber, scanner.Text())
		lineNumber++
	}

	if err := scanner.Err(); err != nil {
		fmt.Fprintln(os.Stderr, "Read error:", err)
	}
}
```

First, with:

```go
scanner := bufio.NewScanner(os.Stdin)
```

a scanner that works with `stdin` is created.

By default a `Scanner` splits the input into lines.

Then:

```go
lineNumber := 1
```

sets the first line number to show.

The loop:

```go
for scanner.Scan() {
```

tries to read the next line each time.

If the next token, in this case a line, exists:

```go
scanner.Scan()
```

returns `true`.

The text of the line is obtained with:

```go
scanner.Text()
```

For example, if the input is:

```text
apple
pomegranate
grape
```

the output is:

```text
1: apple
2: pomegranate
3: grape
```

After each iteration:

```go
lineNumber++
```

increases the line number by one.

The end of the loop does not always mean an error.

`Scan()` also returns `false` when the input ends normally.

That is why after the loop:

```go
if err := scanner.Err(); err != nil {
```

checks whether the scanner stopped because of an error.

This matters because from `Scan() == false` alone you cannot tell whether the input ended or a read error occurred.

> **Note**
>
> `bufio.Scanner` has a default limit for very large tokens. If you need to read very long lines, you may need to enlarge the scanner's buffer or use another approach such as `bufio.Reader`.

### 9. Writing the result and errors to separate streams

This example shows using `stdout`, `stderr` and an exit code together.

If there is an argument, the result is written to `stdout`.

If there is no argument, a usage message is written to `stderr` and a non-zero exit code is returned.

```go
package main

import (
	"fmt"
	"os"
)

func run(args []string) int {
	if len(args) == 0 {
		fmt.Fprintln(os.Stderr, "Usage: program TEXT")
		return 1
	}

	fmt.Fprintln(os.Stdout, "Result:", args[0])
	return 0
}

func main() {
	os.Exit(run(os.Args[1:]))
}
```

`main()` drops the program name with:

```go
os.Args[1:]
```

That is why `run()` gets only the user's arguments.

If:

```go
len(args) == 0
```

the user did not give the required argument.

Then:

```go
fmt.Fprintln(os.Stderr, "Usage: program TEXT")
```

writes the error or usage message to `stderr`.

Then:

```go
return 1
```

signals the error state.

If there is an argument:

```go
fmt.Fprintln(os.Stdout, "Result:", args[0])
```

prints the normal result to `stdout`.

Then:

```go
return 0
```

signals success.

For example, the output of:

```bash
go run main.go hello
```

is:

```text
Result: hello
```

In this example three channels are clearly separated:

```text
normal result -> stdout
error message -> stderr
status        -> exit code
```

This separation is useful in CLI programs, because another program can process the data on stdout and show the diagnostics on stderr separately.

### 10. Writing a CLI with a separate `FlagSet`

In this example we don't use the global `flag` state.

A separate `FlagSet` is created to parse the arguments. The arguments and output streams are given to the `run()` function as parameters.

```go
package main

import (
	"flag"
	"fmt"
	"io"
	"os"
)

func run(args []string, stdout, stderr io.Writer) int {
	fs := flag.NewFlagSet("greet", flag.ContinueOnError)
	fs.SetOutput(stderr)
	name := fs.String("name", "guest", "user name")

	if err := fs.Parse(args); err != nil {
		return 2
	}

	fmt.Fprintln(stdout, "Hello,", *name)
	return 0
}

func main() {
	code := run(os.Args[1:], os.Stdout, os.Stderr)
	os.Exit(code)
}
```

The main part:

```go
fs := flag.NewFlagSet("greet", flag.ContinueOnError)
```

This creates a new, independent `FlagSet`.

Instead of the global:

```go
flag.String(...)
flag.Parse()
```

we now use:

```go
fs.String(...)
fs.Parse(...)
```

This approach is especially convenient in tests and in programs with several commands.

For example, if a large CLI has subcommands like:

```text
app create
app delete
app list
```

a separate `FlagSet` can be created for each.

The next line:

```go
fs.SetOutput(stderr)
```

redirects the `FlagSet`'s diagnostic and parsing messages to the `stderr` stream we passed.

The `name` flag:

```go
name := fs.String("name", "guest", "user name")
```

uses as its default value:

```text
guest
```

That is why:

```bash
go run main.go
```

is not an error either.

The output is:

```text
Hello, guest
```

If it is run as:

```bash
go run main.go -name Ali
```

the output is:

```text
Hello, Ali
```

If an error occurs during parsing:

```go
if err := fs.Parse(args); err != nil {
	return 2
}
```

runs.

Because `flag.ContinueOnError` was chosen, the `FlagSet` does not end the process itself. It returns the error through `Parse()`.

That is why `run()` can handle the error state as an exit code.

At the end:

```go
code := run(os.Args[1:], os.Stdout, os.Stderr)
os.Exit(code)
```

is written.

In this structure `main()` is very small.

Its only job is to connect the real operating system resources to `run()`:

```text
os.Args[1:] -> arguments
os.Stdout   -> stdout
os.Stderr   -> stderr
```

and turn the returned exit code into the process result.

The main program logic stays inside `run()`. That is why it becomes easier to test separately.
