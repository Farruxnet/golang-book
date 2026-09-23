# Functions

## Basics

```go
func add(a, b int) int {
    return a + b
}
```

## Multiple return values

```go
func divide(a, b float64) (float64, error) {
    if b == 0 {
        return 0, errors.New("division by zero")
    }
    return a / b, nil
}
```

## Variadic functions

```go
func sum(nums ...int) int {
    total := 0
    for _, n := range nums {
        total += n
    }
    return total
}

sum(1, 2, 3) // 6
```

## Closures

```go
func counter() func() int {
    count := 0
    return func() int {
        count++
        return count
    }
}
```

## defer

`defer` schedules a call to run when the function returns — perfect for cleanup:

```go
f, err := os.Open("data.txt")
if err != nil {
    return err
}
defer f.Close()
```

## Check yourself

```quiz
When does a `defer`red call run?
- Immediately
- At the end of the current block
+ When the surrounding function returns
- When the program exits
> Deferred calls run in LIFO order right before the function returns.
```

```quiz
What is printed?

~~~go
c := counter()
c()
c()
fmt.Println(c())
~~~
- `1`
- `2`
+ `3`
- `0`
> The closure keeps its own `count` variable between calls.
```
