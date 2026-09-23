# FizzBuzz and Warm-ups

Solve each exercise before looking at the solution.

## 1. FizzBuzz

Print numbers 1 to 100. For multiples of 3 print `Fizz`, for multiples of 5 print `Buzz`, for both print `FizzBuzz`.

```go
for i := 1; i <= 100; i++ {
    switch {
    case i%15 == 0:
        fmt.Println("FizzBuzz")
    case i%3 == 0:
        fmt.Println("Fizz")
    case i%5 == 0:
        fmt.Println("Buzz")
    default:
        fmt.Println(i)
    }
}
```

## 2. Reverse a string

> **Hint:** Convert to `[]rune` so multi-byte characters stay intact.

```go
func Reverse(s string) string {
    r := []rune(s)
    for i, j := 0, len(r)-1; i < j; i, j = i+1, j-1 {
        r[i], r[j] = r[j], r[i]
    }
    return string(r)
}
```

## 3. Word count

Write `WordCount(s string) map[string]int` that counts each word. Try it yourself!
