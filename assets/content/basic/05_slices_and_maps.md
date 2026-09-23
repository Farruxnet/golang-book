# Slices and Maps

## Arrays vs slices

Arrays have a fixed size. **Slices** are dynamic views over arrays and are what you'll use 99% of the time.

```go
arr := [3]int{1, 2, 3}      // array
nums := []int{1, 2, 3}      // slice
nums = append(nums, 4, 5)

fmt.Println(len(nums), cap(nums))
fmt.Println(nums[1:3])      // [2 3]
```

## make

```go
buf := make([]byte, 0, 1024) // len 0, cap 1024
```

## Maps

```go
ages := map[string]int{
    "alice": 31,
    "bob":   27,
}

ages["carol"] = 22

if age, ok := ages["dave"]; !ok {
    fmt.Println("dave not found", age)
}

delete(ages, "bob")
```

> **Warning:** Map iteration order is random. Sort the keys if you need a stable order.

## Check yourself

```quiz
What does `nums[1:3]` return for `nums := []int{1, 2, 3, 4}`?
- `[1 2 3]`
+ `[2 3]`
- `[2 3 4]`
- `[1 2]`
> The low bound is inclusive, the high bound is exclusive.
```

```quiz
How do you check whether a key exists in a map?
- `if m.has(k)`
- `if m[k] != nil`
+ `if v, ok := m[k]; ok`
- `if exists(m, k)`
> The "comma ok" form tells missing keys apart from zero values.
```
