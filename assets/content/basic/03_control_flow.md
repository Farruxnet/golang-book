# Control Flow

## if / else

```go
if score := 87; score >= 90 {
    fmt.Println("A")
} else if score >= 80 {
    fmt.Println("B")
} else {
    fmt.Println("Keep going!")
}
```

## for — the only loop

```go
for i := 0; i < 3; i++ {
    fmt.Println(i)
}

// while-style
n := 1
for n < 100 {
    n *= 2
}

// ranging over a slice
for index, value := range []string{"a", "b", "c"} {
    fmt.Println(index, value)
}
```

## switch

```go
switch day := "sat"; day {
case "sat", "sun":
    fmt.Println("Weekend")
default:
    fmt.Println("Weekday")
}
```

> **Tip:** Go's `switch` does not fall through by default — no `break` needed.

## Check yourself

```quiz
How do you write a `while` loop in Go?
- `while n < 10 { }`
+ `for n < 10 { }`
- `loop n < 10 { }`
- `do { } while n < 10`
> Go has only `for`; with just a condition it behaves like `while`.
```

```quiz
Does a Go `switch` case fall through to the next case by default?
- Yes, like in C
+ No, each case breaks automatically
- Only for string cases
> Use the explicit `fallthrough` keyword if you really need it.
```
