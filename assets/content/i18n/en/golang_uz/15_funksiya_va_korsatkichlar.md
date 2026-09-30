# Functions and pointers

Go copies the value of every argument given to a function. Sometimes a function needs to change the original variable
or avoid copying a large value. In such a situation, using a `pointer` parameter is the right choice.

## Value and pointer parameters

```go
package main

import "fmt"

func changeByValue(n int) {
	n = 100
}

func changeByPointer(n *int) {
	*n = 100
}

func main() {
	num := 10
	changeByValue(num)
	fmt.Println("After value:", num)

	changeByPointer(&num)
	fmt.Println("After pointer:", num)
}
```

Output:

```text
After value: 10
After pointer: 100
```

The first function changes a copy of the value of `num`. The second function is given `&num`, that is, the address of
`num`. The pointer `n` is also passed by value, but its copy refers to the same `num` variable. `*n = 100` updates the
value of that variable.

Go has no reference parameters like C++ does. A pointer is also passed to a function by value.

## Handling `nil` safely

A pointer parameter can be `nil`. Depending on what the function requires, in that case it can return an error or
treat `nil` as a special meaning:

```go
package main

import (
	"fmt"
	"strings"
)

func trim(text *string) error {
	if text == nil {
		return fmt.Errorf("text pointer is nil")
	}
	*text = strings.TrimSpace(*text)
	return nil
}

func main() {
	name := "  Go developer  "
	if err := trim(&name); err != nil {
		fmt.Println("Error:", err)
		return
	}
	fmt.Printf("%q\n", name)
}
```

Output:

```text
"Go developer"
```

If `*text` is used without checking for `nil`, a `panic` occurs while the program runs. In a public API, how the
function treats a `nil` value should be documented.

## When is a pointer needed?

Using a pointer can be right in these cases:

- the function must change the value;
- reducing the cost of copying large data matters and measurements confirm it;
- the shared state of one object is managed from several places.

Do not pass a small number, a `bool` or a small struct through a pointer just on the assumption that "pointers are
faster". A pointer introduces a `nil` state and shared mutable data. This can make code harder to understand and to use
concurrently.

To change the elements of a slice or a `map`, you usually don't need `*[]T` or `*map[K]V`. Their values refer to the
underlying data. But if `append` inside a function changes the length or capacity of a slice, returning the updated
slice is the usual and clear approach.

## Returning a pointer

In Go, returning a pointer to a local variable is safe. The compiler makes sure the value is kept for as long as needed:

```go
func newNumber() *int {
	n := 16
	return &n
}
```

The compiler decides with escape analysis whether the value lives on the stack or on the heap. Do not tie the logic of
your code to assumptions about which part of memory a value lives in.

## Examples

### 1. Increasing a value through a pointer

```go
package main

import "fmt"

func increment(num *int) {
	*num++
}

func main() {
	num := 9
	increment(&num)
	fmt.Println(num)
}
```

The function takes the address of a variable. `*num++` is the same as `(*num)++` and increases the value the pointer
refers to by one.

### 2. Swapping two values

```go
package main

import "fmt"

func swap(a, b *string) {
	*a, *b = *b, *a
}

func main() {
	first, second := "left", "right"
	swap(&first, &second)
	fmt.Println(first, second)
}
```

Both pointers refer to variables in the caller. The values are swapped without a separate temporary variable.

### 3. Leaving safely on a `nil` pointer

```go
package main

import "fmt"

func show(num *int) {
	if num == nil {
		fmt.Println("No value given")
		return
	}
	fmt.Println(*num)
}

func main() {
	show(nil)
}
```

`nil` is checked before accessing the value through the pointer. Thanks to the early `return`, `*num` does not run when
`num` is `nil`.

### 4. Providing a default value through a pointer

```go
package main

import "fmt"

func valueOr(p *int, fallback int) int {
	if p == nil {
		return fallback
	}
	return *p
}

func main() {
	num := 0
	fmt.Println(valueOr(nil, 10))
	fmt.Println(valueOr(&num, 10))
}
```

`nil` and `0` are treated as separate cases. The first call returns the default value — `10` — and the second returns
the existing value — `0`.

### 5. A function that returns a pointer

```go
package main

import "fmt"

func newCounter(start int) *int {
	num := start
	return &num
}

func main() {
	p := newCounter(5)
	*p += 3
	fmt.Println(*p)
}
```

Returning a pointer to a local variable is safe in Go. The compiler determines how long the value must be kept.

### 6. Replacing the slice itself through a pointer

```go
package main

import "fmt"

func add(numbers *[]int, num int) {
	*numbers = append(*numbers, num)
}

func main() {
	numbers := []int{1, 2}
	add(&numbers, 3)
	fmt.Println(numbers)
}
```

A slice pointer is not needed to change elements. In this example a pointer is used so the function can also update the
length in the slice descriptor. Returning the updated slice is usually simpler and clearer.

### 7. A map pointer is not needed

```go
package main

import "fmt"

func update(scores map[string]int) {
	scores["Go"] = 100
}

func main() {
	scores := map[string]int{"Go": 80}
	update(scores)
	fmt.Println(scores)
}
```

Even though a `map` is passed to the function by value, the function can update its elements. A `*map` is not needed
for this task.

### 8. Changing an array through a pointer

```go
package main

import "fmt"

func clear(numbers *[3]int) {
	for i := range numbers {
		numbers[i] = 0
	}
}

func main() {
	numbers := [3]int{4, 5, 6}
	clear(&numbers)
	fmt.Println(numbers)
}
```

When an array is passed to a function by value, it is copied completely. An array pointer lets you change the
elements of the original array without creating a copy.

### 9. The pointer parameter itself is copied

```go
package main

import "fmt"

func otherAddress(p *int) {
	other := 99
	p = &other
}

func main() {
	num := 10
	p := &num
	otherAddress(p)
	fmt.Println(*p)
}
```

The result is `10`. The `p` inside the function is a copy of the pointer. Pointing it to another variable does not
change the `p` in the caller.

### 10. Updating an address through a pointer to a pointer

```go
package main

import "fmt"

func repoint(p **int, target *int) {
	*p = target
}

func main() {
	first, second := 10, 20
	p := &first
	repoint(&p, &second)
	fmt.Println(*p)
}
```

The `**int` type denotes a pointer to a pointer of type `*int`. That is why the function can point the caller's `p` to
another variable.
