# Generics

Since Go 1.18 functions and types can have **type parameters**.

```go
func Map[T, U any](items []T, f func(T) U) []U {
    out := make([]U, 0, len(items))
    for _, it := range items {
        out = append(out, f(it))
    }
    return out
}

lengths := Map([]string{"go", "gopher"}, func(s string) int { return len(s) })
```

## Constraints

```go
type Number interface {
    ~int | ~int64 | ~float64
}

func Sum[T Number](nums []T) T {
    var total T
    for _, n := range nums {
        total += n
    }
    return total
}
```

## Generic types

```go
type Stack[T any] struct {
    items []T
}

func (s *Stack[T]) Push(v T) { s.items = append(s.items, v) }

func (s *Stack[T]) Pop() (T, bool) {
    var zero T
    if len(s.items) == 0 {
        return zero, false
    }
    v := s.items[len(s.items)-1]
    s.items = s.items[:len(s.items)-1]
    return v, true
}
```

## Check yourself

```quiz
What does `~int` mean in a constraint?
- Any type except `int`
+ `int` or any type whose underlying type is `int`
- A pointer to `int`
- An approximate integer
> The tilde allows named types such as `type ID int`.
```
