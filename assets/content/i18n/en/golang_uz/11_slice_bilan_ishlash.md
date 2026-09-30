# Working with slices in Go

A **slice** is a data type for working with elements of the same type. Unlike an array, a slice's length can be
increased or decreased when needed. That is why slices are used a lot when the number of elements is not known in
advance. For example, results from an API, lines read from a file or data from a database are convenient to store in
a `slice`.

A slice is not a separate type that holds the elements itself. The elements live in an underlying array in memory.
The slice refers to a certain part of that array. It stores where it starts, how many elements it has and how much
more room it can use.

- `len` - the number of elements currently in the `slice`.
- `cap` - the room available from where the `slice` starts to the end of the underlying array.

## Creating a slice

A slice type is written as `[]elementType`. No number is written inside the square brackets. For example, `[]int` is a
`slice` of `int` elements, while `[3]int` is an array of three elements.

```go
package main

import "fmt"

func main() {
	var empty []int
	fruits := []string{"apple", "pomegranate", "grape"}
	numbers := make([]int, 3, 5)

	fmt.Println(empty, len(empty), cap(empty), empty == nil)
	fmt.Println(fruits)
	fmt.Println(numbers, len(numbers), cap(numbers))
}
```

**Output:**

```text
[] 0 0 true
[apple pomegranate grape]
[0 0 0] 3 5
```

A `slice` can be created in three ways:

- `var empty []int` - a `nil` slice not yet tied to an underlying array;
- `[]string{"apple", "pomegranate", "grape"}` - a slice declared with its values;
- `make([]int, 3, 5)` - a slice with length `3` and capacity `5`.

A `nil` slice is empty. Functions such as `len`, `cap`, `range` and `append` can be used with it safely. The three
elements of the `numbers` slice created with `make` are filled at first with `0`, the zero value of the `int` type.

> **Info**
>
> A `nil` slice and `[]int{}` are both empty, that is, their length is `0`. Both can be compared with `nil`, but only
> the first is equal to `nil`. For example, when they are converted to JSON, one comes out as `null` and the other as
> `[]`.

## Getting part of a slice

To take a range from a `slice`, a slice expression is used. In `s[low:high]`, the element at index `low` is included in
the result, but the element at index `high` is not:

```go
package main

import "fmt"

func main() {
	numbers := []int{10, 20, 30, 40, 50}
	part := numbers[1:4]

	fmt.Println(part)
	part[0] = 99
	fmt.Println(numbers)
}
```

Output:

```text
[20 30 40]
[10 99 30 40 50]
```

The expression `numbers[1:4]` takes the elements at indexes `1`, `2` and `3`. The result is `[20 30 40]`.

This operation does not copy the elements. Both slices point into the same underlying array. `part[0]` is actually the
place where `numbers[1]` is. That is why writing `99` to it also changes `numbers`. If a separate copy is needed, the
`copy` function is used.

## `append`, length and capacity

`append` adds new elements to the end of a slice. It returns not the original `slice` but an updated `slice` value.
That is why the result must be stored back in the variable:

```go
package main

import "fmt"

func main() {
	numbers := make([]int, 0, 2)

	numbers = append(numbers, 10, 20)
	fmt.Println(numbers, len(numbers), cap(numbers))

	numbers = append(numbers, 30)
	fmt.Println(numbers, len(numbers), cap(numbers))
}
```

First two elements that fit the `slice`'s capacity are added, but for the third element the existing capacity is not
enough, so the result is:

```text
[10 20] 2 2
[10 20 30] 3 4
```

If the capacity is enough, `append` uses the free room in the existing underlying array. If not, Go creates a larger
array, copies the old elements into it and returns a `slice` that refers to the new array.

The new capacity does not have to be exactly `4`. How much it grows is up to the Go runtime. The only rule is that the
capacity must not be less than the length. That is why program logic should not depend on how much the capacity grows.

> **Warning**
>
> Writing only `append(numbers, 30)` is not enough. `append` may create a new underlying array, and the slice it returns
> refers to that array. Always assign the result to the variable: `numbers = append(numbers, 30)`.

## Links between slices

Slices tied to the same underlying array can affect each other's elements. This usually happens when `append` is used:

```go
package main

import "fmt"

func main() {
	original := []int{1, 2, 3, 4}
	part := original[:2]
	part = append(part, 99)

	fmt.Println("Original:", original)
	fmt.Println("Part:", part)
}
```

Output:

```text
Original: [1 2 99 4]
Part: [1 2 99]
```

At first `part` refers to the first two elements of `original`. Its length is `2`, but the underlying array still has
free capacity. That is why `append` does not create a new array. It writes the value `99` to the next place in the
underlying array, that is, over `original[2]`.

If one of the `slice`s needs to be changed independently, it is right to first take a separate copy of it into another
variable.

## Copying

`copy` copies elements from one slice into another slice variable. The destination slice must be created in advance
with the required length. `copy` also returns the number of elements copied:

```go
package main

import "fmt"

func main() {
	original := []int{1, 2, 3}
	copied := make([]int, len(original))
	n := copy(copied, original)
	copied[0] = 99

	fmt.Println("Copied:", n)
	fmt.Println("Original:", original)
	fmt.Println("Copy:", copied)
}
```

Output:

```text
Copied: 3
Original: [1 2 3]
Copy: [99 2 3]
```

A separate underlying array was created for `copied`. That is why writing `99` to `copied[0]` does not affect
`original`.

`copy` copies only as many elements as fit in the length of both `slice`s. For example, if the source `slice` has five
places and the destination has three, only three elements are copied.

When copying `slice`s you can also use `copied := append([]int(nil), original...)` or `copied := slices.Clone(original)`.

## Deleting an element

There is no separate `delete` function for removing a `slice` element. To keep the order of the elements, the parts
before and after the element being deleted are joined with `append`:

```go
package main

import "fmt"

func main() {
	numbers := []int{10, 20, 30, 40}
	index := 1
	numbers = append(numbers[:index], numbers[index+1:]...)

	fmt.Println(numbers)
}
```

Output:

```text
[10 30 40]
```

The part `numbers[:index]` takes everything before the element being deleted. In this example the value of `index` is
`1`, so the result is `[10]`. `numbers[index+1:]` takes all the elements after the element being deleted. The result of
this part is `[30 40]`. The `append()` function adds the elements of the second part to the first part. The `...`
operator splits the `[30 40]` part into separate elements and passes them to `append()`. This way the element `20` is
not added to the new part, and the result is `[10 30 40]`.

If the value of `index` comes from the user or another external source, first check the condition
`0 <= index && index < len(numbers)`. Otherwise a `panic` occurs when taking the part.

## More examples

### 1. Allocating slice capacity in advance

```go
package main

import "fmt"

func main() {
	numbers := make([]int, 0, 5)
	for i := 1; i <= 5; i++ {
		numbers = append(numbers, i*i)
	}
	fmt.Println(numbers, len(numbers), cap(numbers))
}
```

If the number of elements is roughly known, allocating the capacity in advance reduces how many new arrays are created
during `append`. When the slice is created, its length is `0` because no elements have been added yet. Its capacity is
`5`, so room for the first five elements is ready.

### 2. Adding several elements at once

```go
package main

import "fmt"

func main() {
	numbers := []int{1, 2}
	numbers = append(numbers, 3, 4, 5)
	fmt.Println(numbers)
}
```

`append` accepts several elements in one call. In the example the values `3`, `4` and `5` are added one after another.
The result is `[1 2 3 4 5]`.

### 3. Adding the elements of another slice

```go
package main

import "fmt"

func main() {
	first := []int{1, 2}
	second := []int{3, 4}
	joined := append(first, second...)
	fmt.Println(joined)
}
```

The `...` passes the elements of the `second` slice to `append` as separate values. As a result, `[1 2 3 4]` is made from
the elements of both slices.

> **Warning**
>
> If the capacity is enough, `append` may use the underlying array of `first`. If `joined` must be completely
> independent, make a copy first.

### 4. Reversing a slice in place

```go
package main

import "fmt"

func main() {
	numbers := []int{1, 2, 3, 4, 5}
	for left, right := 0, len(numbers)-1; left < right; left, right = left+1, right-1 {
		numbers[left], numbers[right] = numbers[right], numbers[left]
	}
	fmt.Println(numbers)
}
```

The `left` index moves from the start and the `right` index from the end toward the middle. At each step the elements
at these indexes are swapped. Because the change is made in the existing slice, no extra slice is created.

### 5. Filtering elements that match a condition

```go
package main

import "fmt"

func main() {
	numbers := []int{1, 2, 3, 4, 5, 6}
	evens := make([]int, 0, len(numbers))
	for _, num := range numbers {
		if num%2 == 0 {
			evens = append(evens, num)
		}
	}
	fmt.Println(evens)
}
```

The loop adds only even numbers to the `evens` slice. Because a separate slice is created for the result, `numbers`
does not change. The number of even elements cannot exceed the length of the source. That is why a capacity equal to
the source length was allocated in advance.

### 6. Filtering without extra memory

```go
package main

import "fmt"

func main() {
	numbers := []int{1, 2, 3, 4, 5, 6}
	evens := numbers[:0]
	for _, num := range numbers {
		if num%2 == 0 {
			evens = append(evens, num)
		}
	}
	fmt.Println(evens)
}
```

`numbers[:0]` makes a slice of length zero but does not create a new underlying array. `append` writes the selected
even numbers into the underlying array of `numbers`, starting from the beginning. As a result no extra underlying array
is allocated, but the elements in the source also change.

### 7. Deleting an element without keeping the order

```go
package main

import "fmt"

func main() {
	numbers := []int{10, 20, 30, 40}
	index := 1
	numbers[index] = numbers[len(numbers)-1]
	numbers = numbers[:len(numbers)-1]
	fmt.Println(numbers)
}
```

The last element, `40`, is written in place of the `20` being deleted. Then the slice length is reduced by one. The
result is `[10 40 30]`. If the order does not matter, this technique does not need to shift the remaining elements.

### 8. Extending a slice to a specific length

```go
package main

import "fmt"

func main() {
	numbers := make([]int, 2, 5)
	numbers[0], numbers[1] = 10, 20
	numbers = numbers[:4]
	numbers[2], numbers[3] = 30, 40
	fmt.Println(numbers)
}
```

If the new length does not exceed the capacity, a slice can be extended by re-slicing it. In the example the length is
increased from `2` to `4`. The newly visible elements have the value `0` at first, and then `30` and `40` are written
to them.

### 9. Creating a two-dimensional slice

```go
package main

import "fmt"

func main() {
	rows, columns := 2, 3
	table := make([][]int, rows)
	for i := range table {
		table[i] = make([]int, columns)
		table[i][0] = i + 1
	}
	fmt.Println(table)
}
```

`[][]int` is a slice whose elements are also `[]int`. First an outer slice for the rows is created. Then in the loop a
separate inner slice is allocated for each row. That is why the rows can have the same or different lengths.

### 10. Comparing slices for equality

```go
package main

import (
	"fmt"
	"slices"
)

func main() {
	a := []int{1, 2, 3}
	b := []int{1, 2, 3}
	fmt.Println(slices.Equal(a, b))
}
```

Slices cannot be compared with each other using `==`. You can only check whether a slice is `nil`, in the form
`slice == nil`.

If the elements are of a comparable type, `slices.Equal` first compares the lengths and then the elements at the same
indexes. Because both slices in the example are the same, the program printed `true`.

> **Tip**
>
> - Slices are used for sequential data whose length can change.
> - `len` is the number of elements currently in the slice, and `cap` is the room available in the underlying
>     array.
> - A slice cut from another usually shares the same underlying array as the original. A change in one also
>     affects the other.
> - The slice returned by `append` must always be assigned to a variable. If the capacity is not enough, it creates a new underlying array.
