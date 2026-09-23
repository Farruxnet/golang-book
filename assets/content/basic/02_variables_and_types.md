# Variables and Types

Go is **statically typed**: every variable has a type known at compile time.

## Declaring variables

```go
var name string = "Gopher"
var age = 13          // type inferred as int
city := "Tashkent"    // short declaration, only inside functions
```

## Zero values

Variables declared without a value get a *zero value*:

```go
var i int     // 0
var f float64 // 0
var b bool    // false
var s string  // ""
```

## Constants

```go
const Pi = 3.14159

const (
    StatusOK       = 200
    StatusNotFound = 404
)
```

## Basic types

- `bool`
- `string`
- `int`, `int8`, `int16`, `int32`, `int64`
- `uint`, `uint8` (`byte`), ... `uint64`
- `float32`, `float64`
- `rune` (alias for `int32`, a Unicode code point)

> **Note:** Go never converts types implicitly. Use `float64(x)` to convert explicitly.

## Check yourself

```quiz
What is printed?

~~~go
var s string
var n int
fmt.Println(len(s), n)
~~~
- `nil 0`
+ `0 0`
- `"" 0`
- It doesn't compile
> Zero values: `""` for strings (length 0) and `0` for ints.
```

```quiz
Where can you use the short declaration `x := 5`?
- Anywhere, including package level
+ Only inside functions
- Only inside `for` loops
- Only for constants
> At package level you must use `var`.
```
