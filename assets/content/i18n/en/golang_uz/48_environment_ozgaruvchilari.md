# Working with environment variables

An environment variable is configuration that the operating system passes to a program's process in the form of a name and a value.

For example, which port the program runs on, whether it starts in `development` or `production` mode, and where the database or another external service is located can be given through environment variables.

The main benefit of this is separating configuration from code.

For example, the port can be written as a constant in the code:

```go
port := "8080"
```

But then moving to another environment requires changing the code. If an environment variable is used, the code does not change. Only the value in the environment the program runs in is changed.

That is why environment variables are used a lot in server programs, CLI programs, containers and deployment configurations.

## The `os` package

Go works with environment variables through the standard `os` package.

Mainly two functions are used to read an environment variable:

- `os.Getenv`;
- `os.LookupEnv`.

`os.Getenv` returns only the variable's value.

`os.LookupEnv`, on the other hand, gives two pieces of information:

1. the variable's value;
2. whether the variable exists at all.

For example:

```go
package main

import (
	"fmt"
	"os"
)

func main() {
	port, ok := os.LookupEnv("APP_PORT")
	if !ok || port == "" {
		port = "8080"
	}

	fmt.Println("Server port:", port)
}
```

Let's go through this code step by step.

```go
port, ok := os.LookupEnv("APP_PORT")
```

`LookupEnv` returns two values.

The value of `APP_PORT` goes into `port`.

And `ok` shows whether the variable exists:

```text
ok = true
```

means `APP_PORT` exists in the environment.

```text
ok = false
```

means no such environment variable was given at all.

The next check:

```go
if !ok || port == "" {
	port = "8080"
}
```

checks two cases:

- `APP_PORT` does not exist at all;
- `APP_PORT` exists, but its value is an empty string.

In both cases the program uses the default value `8080`.

You can set the `APP_PORT` value through PowerShell and then run the program:

```powershell
$env:APP_PORT = "9000"
go run main.go
```

Result:

```text
Server port: 9000
```

This time `LookupEnv` returns a result close to the following:

```text
port = "9000"
ok   = true
```

That is why the default value `8080` is not used.

If the variable is not given or its value is empty, the program prints:

```text
Server port: 8080
```

The difference between `LookupEnv` and `Getenv` matters here.

For example, the environment may contain the following value:

```text
APP_MODE=
```

In this case `APP_MODE` exists, but its value is an empty string.

`os.Getenv("APP_MODE")` returns only:

```text
""
```

But even if the variable does not exist at all, `Getenv` returns exactly the same empty string.

That is why if you need to distinguish the cases "the variable does not exist" and "the variable exists but its value is empty", `os.LookupEnv` is used.

## Checking a value and converting its type

The values of environment variables come to the program as text, i.e. as a `string`.

For example, if:

```text
APP_PORT=8080
```

is written, Go does not automatically turn this value into an `int`.

The value the program gets is a `string` of the form:

```go
"8080"
```

If the program needs a number, the value must be explicitly converted to the needed type.

Besides that, converting alone is not enough. You must also check that the value is logically within the allowed range.

For example, a TCP or HTTP server port needs a number from `1` to `65535`.

```go
package main

import (
	"fmt"
	"os"
	"strconv"
)

func main() {
	raw := os.Getenv("APP_PORT")
	if raw == "" {
		raw = "8080"
	}

	port, err := strconv.Atoi(raw)
	if err != nil || port < 1 || port > 65535 {
		fmt.Fprintln(os.Stderr, "APP_PORT must be an integer from 1 to 65535")
		os.Exit(1)
	}

	fmt.Printf("The server starts at :%d\n", port)
}
```

In this code `APP_PORT` is first taken as text:

```go
raw := os.Getenv("APP_PORT")
```

If the value is empty:

```go
if raw == "" {
	raw = "8080"
}
```

the default value is used.

This value is still a `string`:

```text
"8080"
```

Then, through:

```go
port, err := strconv.Atoi(raw)
```

the text is converted to the `int` type.

For example:

```text
"8080" -> 8080
```

If the user gave:

```text
APP_PORT=abc
```

`strconv.Atoi` cannot turn this text into an integer and returns `err`.

That is why the check:

```go
if err != nil || port < 1 || port > 65535 {
```

catches several invalid cases.

For example:

```text
APP_PORT=abc
```

is not a number.

```text
APP_PORT=0
```

is syntactically a number, but is not in the port range we defined.

```text
APP_PORT=70000
```

is also an integer, but greater than `65535`.

That is why these values do not get into the server configuration.

When an error is found:

```go
fmt.Fprintln(os.Stderr, "APP_PORT must be an integer from 1 to 65535")
```

writes the message to the standard error stream, i.e. `stderr`.

Then:

```go
os.Exit(1)
```

tells the operating system that the program ended in a failed state.

There is an important rule here: an environment variable counts as data coming from outside.

That is why you should not assume its value is correct. Before using it, it is good practice to:

- convert it to the needed type;
- check the conversion error;
- check the allowed range.

The same rule applies to boolean values.

For example, to turn the value:

```text
DEBUG=true
```

into a `bool`, `strconv.ParseBool` can be used.

In real projects, instead of reading environment variables over and over in different parts of the code, it is convenient to read the configuration once while the program is starting.

For example, the checked values can be kept in a separate `Config` struct:

```go
type Config struct {
	Port int
}
```

Then the rest of the program works not with raw `string` values, but with configuration that has already been checked.

This also simplifies error handling. If there is a problem in the configuration, it is detected right at the start of the program.

## Setting and removing a value

A Go program does not have to only read environment variables.

A value can be set through `os.Setenv`.

And `os.Unsetenv` removes an existing variable.

```go
package main

import (
	"fmt"
	"os"
)

func main() {
	if err := os.Setenv("APP_MODE", "development"); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	fmt.Println(os.Getenv("APP_MODE"))

	if err := os.Unsetenv("APP_MODE"); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}
```

First:

```go
os.Setenv("APP_MODE", "development")
```

creates the `APP_MODE` value in the current process environment or replaces an existing value.

After that:

```go
os.Getenv("APP_MODE")
```

returns the following value:

```text
development
```

Then:

```go
os.Unsetenv("APP_MODE")
```

removes `APP_MODE` from the current process environment.

`Setenv` and `Unsetenv` may return an error. That is why `err` is checked in the example.

There is an important point about these functions.

They do not change the permanent configuration of the terminal or the operating system.

For example, calling inside the program:

```go
os.Setenv("APP_MODE", "development")
```

does not change a permanent setting in PowerShell or another terminal window.

The value exists mainly in the current process environment.

If this Go program later starts another child process, that process can usually also inherit the value based on the current environment.

So `os.Setenv` is not a tool for editing the global, permanent environment setting of the operating system.

## What is a `.env` file?

`.env` is a widely used plain text file for writing environment configuration in the `KEY=value` form.

For example:

```text
APP_PORT=8080
APP_MODE=development
```

In this file:

```text
APP_PORT
```

and:

```text
APP_MODE
```

are key names.

And the values on their right-hand side are configuration values.

The important point here is that `.env` is not a special file format of the Go language.

It is also not a universal automatic environment format of the operating system.

It is simply a widespread convention.

The Go standard library does not see a `.env` file and automatically make the value:

```text
APP_PORT=8080
```

available through `os.Getenv("APP_PORT")`.

The values must be loaded into the program's environment another way.

For example:

- exporting them to the environment with shell tools;
- reading the `.env` file with a dedicated external package.

That is why merely having the following file in the project is not enough:

```text
APP_PORT=8080
APP_MODE=development
```

If it has not been loaded into the environment:

```go
os.Getenv("APP_PORT")
```

does not see this value.

**Attention**

Do not commit secret values such as passwords, tokens and API keys to the repository.

If `.env` is used for local development, adding it to the `.gitignore` file is the usual practice.

At the same time it is useful to document which environment names the project expects. For this a `.env.example` file without secret values can be created.

For example:

```text
APP_PORT=8080
APP_MODE=development
API_TOKEN=
```

This file shows the needed variable names but does not store the real secret values.

In a production environment, it is preferable to use a `secret manager` instead of storing secret data in a plain `.env` file.

## Common mistakes

Although working with environment variables looks simple, there are several subtle cases.

- Always treating the empty string returned by `os.Getenv` as "the variable does not exist".

  `os.Getenv` may return `""` both when the variable does not exist at all and when it exists with an empty value.

  If the difference between these two cases matters, use `os.LookupEnv`:

  ```go
  value, ok := os.LookupEnv("APP_MODE")
  ```

  Here `ok` separately shows whether the variable exists.

- Using numeric and boolean values without checking them.

  All values in the environment come as text.

  For example:

  ```text
  APP_PORT=abc
  ```

  is also an ordinary text value from the environment's point of view.

  If you want to use it as a number, the `strconv.Atoi` error must be checked.

  In the same way, for a `bool` value the error returned by `strconv.ParseBool` must not be ignored either.

- Printing a secret value to the log.

  For example, if `API_TOKEN` in the configuration is invalid, writing the token itself into the error message is dangerous:

  ```text
  invalid API_TOKEN: abc123-secret-token
  ```

  Instead, showing the variable name is usually enough:

  ```text
  the API_TOKEN configuration is invalid
  ```

  Logs are often sent to separate monitoring systems. That is why printing secret data to the log may lead to it spreading.

- Thinking that if an external environment value changes while the program is running, the program's configuration updates automatically.

  A process usually starts with its own environment.

  For example, later writing in a shell:

  ```powershell
  $env:APP_PORT = "9001"
  ```

  does not automatically change the environment of another process that is already running.

  That is why many programs read the configuration once at startup and then keep the checked values in memory.

  If the program needs to update its configuration at runtime, a separate mechanism is needed for that. For example, re-reading a configuration file, receiving a signal or using an external configuration service.
