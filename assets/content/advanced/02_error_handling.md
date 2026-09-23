# Error Handling

In Go, errors are **values**. Functions return an `error` as their last result.

```go
data, err := os.ReadFile("config.json")
if err != nil {
    return fmt.Errorf("read config: %w", err)
}
```

## Sentinel errors

```go
var ErrNotFound = errors.New("not found")

if errors.Is(err, ErrNotFound) {
    // handle missing item
}
```

## Custom error types

```go
type ValidationError struct {
    Field string
}

func (e *ValidationError) Error() string {
    return "invalid " + e.Field
}

var ve *ValidationError
if errors.As(err, &ve) {
    fmt.Println("bad field:", ve.Field)
}
```

> **Tip:** Wrap errors with `%w` to add context while keeping the original error inspectable.

## Check yourself

```quiz
Which verb wraps an error so `errors.Is` can still find it?
- `%v`
- `%s`
+ `%w`
- `%e`
> `fmt.Errorf("...: %w", err)` keeps the original error in the chain.
```

```quiz
What is `errors.As` used for?
- Comparing two errors for equality
+ Extracting an error of a specific type from the chain
- Converting an error to a string
> Use `errors.Is` for sentinel values and `errors.As` for types.
```
