# Introduction to Go

Go (often called **Golang**) is an open-source programming language created at Google in 2007 by Robert Griesemer, Rob Pike and Ken Thompson. It was designed to be **simple**, **fast to compile** and **great at concurrency**.

## Why Go?

- **Simplicity** — a small language you can hold in your head.
- **Performance** — compiles to native machine code.
- **Concurrency** — goroutines and channels are built into the language.
- **Great tooling** — `go fmt`, `go test`, `go vet` ship with Go.

> **Tip:** Go is used to build Docker, Kubernetes, Terraform and many cloud services.

## Your first program

Create a file named `main.go`:

```go
package main

import "fmt"

func main() {
    fmt.Println("Hello, Gopher!")
}
```

Run it from the terminal:

```bash
go run main.go
```

## Anatomy of the program

| Part | Meaning |
|------|---------|
| `package main` | Declares an executable program |
| `import "fmt"` | Imports the formatting package |
| `func main()` | Entry point of the program |

## Summary

You wrote and ran your first Go program. Next, we'll learn about variables and types.

## Check yourself

```quiz
Which command compiles and runs a Go file in one step?
- `go build main.go`
+ `go run main.go`
- `go exec main.go`
- `go start main.go`
> `go run` compiles to a temporary binary and runs it; `go build` only compiles.
```

```quiz
What must an executable Go program declare?
- `package app` and `func start()`
+ `package main` and `func main()`
- `package main` and `func init()`
- Any package with a `main` file
> The entry point is always `func main()` inside `package main`.
```
