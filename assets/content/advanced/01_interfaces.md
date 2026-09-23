# Interfaces

An interface is a set of method signatures. A type satisfies an interface **implicitly** — no `implements` keyword.

```go
type Shape interface {
    Area() float64
}

type Rect struct{ W, H float64 }
type Circle struct{ R float64 }

func (r Rect) Area() float64   { return r.W * r.H }
func (c Circle) Area() float64 { return math.Pi * c.R * c.R }

func total(shapes ...Shape) float64 {
    sum := 0.0
    for _, s := range shapes {
        sum += s.Area()
    }
    return sum
}
```

## Type switches

```go
func describe(v any) string {
    switch x := v.(type) {
    case int:
        return fmt.Sprintf("int %d", x)
    case string:
        return "string " + x
    default:
        return "unknown"
    }
}
```

> **Go proverb:** "The bigger the interface, the weaker the abstraction."

## Check yourself

```quiz
How does a type implement an interface in Go?
- With the `implements` keyword
- By embedding the interface
+ By having all of its methods
- By registering it with `interface.Add`
> Interfaces are satisfied implicitly — no declaration needed.
```

```quiz
What does `any` mean?
- A generic type parameter
+ An alias for `interface{}`
- A special runtime type
> `any` accepts values of every type.
```
