# Arrays in Go

An array is a data type for storing elements of the same type with a fixed size. For example, the temperature for each
day of the week always needs seven values, and these values can be stored in an array.

In Go, the length of an array is part of its type. That is why `[3]int` and `[4]int` are considered different types.
Another property of arrays is that once an array has been created, you cannot add room for a new element or shrink
its size.

## Declaring an array

An array type is declared in the form `[length]elementType`:

```go
package main

import "fmt"

func main() {
	var scores [4]int
	scores[0] = 78
	scores[1] = 91

	fmt.Println(scores)
	fmt.Println("Length:", len(scores))
}
```

**Output:**

```text
[78 91 0 0]
Length: 4
```

> **Info**
>
> The size of an array is found with `len`.

The line `var scores [4]int` reserves space for four `int` values. Elements that were not given a value are `0` at
first, because `0` is the zero value of the `int` type. The zero value is the initial value Go gives automatically when
a variable is created.

Each element in an array is selected by its index, that is, its position number. Array indexes start at `0`. So the
indexes of a four-element array are `0`, `1`, `2` and `3`. In the example above, the first two elements were given
values, and the other two elements stayed `0`.

> **Warning**
>
> In the example above you cannot access an element as `scores[4]`, because this array has no index `4`.
> If a constant index is out of range, the compiler reports an error. But if the index is computed while the program
> runs and goes out of range, the program stops with a `panic`.

## Not stating the length when declaring an array

There are cases where you don't want to count the length of an array by hand while writing the program, and Go's
compiler has a feature for that too. When declaring the array, it is enough to write its size as `[...]`.

```go
package main

import "fmt"

func main() {
	colors := [3]string{"red", "green", "blue"}
	numbers := [...]int{10, 20, 30, 40}

	fmt.Println(colors)
	fmt.Println(numbers, len(numbers))
}
```

**Output:**

```text
[red green blue]
[10 20 30 40] 4
```

In `[3]string` the array length is stated explicitly. The `...` in `[...]int` leaves it to the compiler to work out the
length from the number of given elements. Because `numbers` has four elements, its type is `[4]int`.

## Walking over an array (iteration)

To read all the elements of an array one after another, `range` is used. On each iteration of the loop it gives the
index and value of an element.

> **Info**
>
> An iteration is one execution of the loop body.

```go
package main

import "fmt"

func main() {
	scores := [4]int{78, 91, 85, 88}
	sum := 0

	for index, score := range scores {
		fmt.Printf("index %d: %d\n", index, score)
		sum += score
	}

	fmt.Println("Average:", float64(sum)/float64(len(scores)))
}
```

Output:

```text
index 0: 78
index 1: 91
index 2: 85
index 3: 88
Average: 85.5
```

The loop adds each `score` value to the `sum` variable. To calculate the average, the sum is divided by the number of
elements. Before the division both values are converted to `float64`, because dividing two `int` values in Go drops
the fractional part of the result.

## Copying an array

When an array is assigned to another variable, Go makes a separate copy of all its elements. Changing an element in
the copy does not affect the original array:

```go
package main

import "fmt"

func main() {
	original := [3]int{1, 2, 3}
	copied := original
	copied[0] = 99

	fmt.Println("Original:", original)
	fmt.Println("Copy:", copied)
}
```

**Output:**

```text
Original: [1 2 3]
Copy: [99 2 3]
```

In the example, `original` and `copied` are two independent arrays made of the same values. That is why, when
`copied[0]` was changed, `original[0]` kept its previous value.

> **Info**
>
> An array is also copied completely when it is passed to a function as an argument. Passing a large array to functions
> again and again can create unnecessary copies. In such cases a slice is usually used.

## Comparing arrays

Arrays can be compared with the `==` and `!=` operators, but this depends on the type of the array's elements. If the
element type is comparable, the arrays themselves are comparable too.

For example, the `int` type is comparable, so arrays made of `int` elements can be compared as well:

```go
a := [3]int{1, 2, 3}
b := [3]int{1, 2, 3}
c := [3]int{1, 2, 4}

fmt.Println(a == b) // true
fmt.Println(a == c) // false
```

Go compares arrays element by element. If all corresponding elements are equal, the result is `true`.

If the element type of an array is not comparable, the array itself cannot be checked with `==` or `!=` either. For
example, a `slice` is not comparable:

```go
a := [2][]int{
	{1, 2},
	{3, 4},
}

b := [2][]int{
	{1, 2},
	{3, 4},
}

// fmt.Println(a == b)
// Error: arrays with slice elements cannot be compared.
```

## When are arrays used?

When the number of elements is known in advance and does not change, an array is convenient. For example, an IPv4
address always consists of four bytes. It can be represented with the `[4]byte` type.

If the number of elements can grow or shrink while the program runs, a `slice` is usually used. So the choice between
an `array` and a `slice` depends first of all on whether the number of elements changes.

## More examples

### 1. Letting the compiler work out the length

```go
package main

import "fmt"

func main() {
	colors := [...]string{"red", "green", "blue"}
	fmt.Printf("%T, length: %d\n", colors, len(colors))
}
```

**Output:**

```text
[3]string, length: 3
```

The `...` notation lets you avoid typing the array length by hand. The compiler sees that there are three colors and
sets the type of `colors` to `[3]string`.

### 2. An indexed array literal

```go
package main

import "fmt"

func main() {
	numbers := [6]int{1: 10, 4: 40}
	fmt.Println(numbers)
}
```

**Output:**

```text
[0 10 0 0 40 0]
```

In an array literal you can also give values only to the indexes you need. In this example `10` is written to index
`1` and `40` to index `4`. The remaining elements are filled with the zero value of the `int` type — `0`.

### 3. Comparing arrays for equality

```go
package main

import "fmt"

func main() {
	a := [3]int{1, 2, 3}
	b := [3]int{1, 2, 3}
	fmt.Println(a == b)
}
```

**Output:**

```text
true
```

`a` and `b` have the same type `[3]int`. The values at their corresponding indexes are also equal. That is why the
program prints `true`.

### 4. Changing a copy of an array

```go
package main

import "fmt"

func main() {
	original := [3]int{2, 4, 6}
	copied := original
	for i := range copied {
		copied[i] *= 2
	}
	fmt.Println("Original:", original)
	fmt.Println("Copy:", copied)
}
```

**Output:**

```text
Original: [2 4 6]
Copy: [4 8 12]
```

`copied := original` copies all the elements. The loop doubles only the elements of `copied`. As a result `original`
stays as it was.

### 5. Calculating the sum of an array

```go
package main

import "fmt"

func main() {
	numbers := [5]int{4, 7, 2, 9, 3}
	sum := 0
	for _, num := range numbers {
		sum += num
	}
	fmt.Println(sum)
}
```

**Output:**

```text
25
```

`range` returns an index and a value. In this example the index is not needed, so the blank identifier `_` is written
in its place. Each value is added to `sum`, and the program prints the number `25`.

### 6. Finding the index of the largest element

```go
package main

import "fmt"

func main() {
	numbers := [5]int{4, 17, 8, 17, 3}
	largest := 0
	for i := 1; i < len(numbers); i++ {
		if numbers[i] > numbers[largest] {
			largest = i
		}
	}
	fmt.Println(largest, numbers[largest])
}
```

**Output:**

```text
1 17
```

The `largest` variable stores not the value but the index of the largest element. At first the element at index `0`
is taken as the largest. The loop compares the remaining elements with the value `numbers[largest]`.

The comparison uses `>`. So if the largest value occurs several times, its first index is kept. In this array `17`
occurs twice, but the result shows its first index — `1`.

### 7. A two-dimensional array

```go
package main

import "fmt"

func main() {
	matrix := [2][3]int{{1, 2, 3}, {4, 5, 6}}
	for row := range matrix {
		for column := range matrix[row] {
			fmt.Print(matrix[row][column], " ")
		}
		fmt.Println()
	}
}
```

**Output:**

```text
1 2 3
4 5 6
```

`[2][3]int` is an array with two rows and three columns. Each row is itself a `[3]int` array of three elements. To get
an element, the row index is written first, then the column index: `matrix[row][column]`.

### 8. The main diagonal of a matrix

```go
package main

import "fmt"

func main() {
	matrix := [3][3]int{{1, 2, 3}, {4, 5, 6}, {7, 8, 9}}
	sum := 0
	for i := range matrix {
		sum += matrix[i][i]
	}
	fmt.Println(sum)
}
```

**Output:**

```text
15
```

The elements on the main diagonal have the same row and column indexes: `[0][0]`, `[1][1]` and `[2][2]`.
The loop adds the values `1`, `5` and `9`. That is why the result is `15`.

### 9. Digit frequency

```go
package main

import "fmt"

func main() {
	num := 120221
	var counts [10]int
	for num > 0 {
		counts[num%10]++
		num /= 10
	}
	fmt.Println(counts)
}
```

**Output:**

```text
[1 2 3 0 0 0 0 0 0 0]
```

In this example the array index stands for the digit itself. The value at the index stores how many times that digit
occurs. For example, the value `counts[2]` shows how many times the digit `2` appears in the number. In the number
`120221`, `1` appears twice and `2` three times.

In the decimal system there are always ten digits, from `0` to `9`. Because the number of elements does not change,
a `[10]int` array suits this task.

> **Info**
>
> In this simple example `num` is assumed to be positive. If the value of `num` is exactly `0`, the loop does not run
> and the digit zero is not counted. In a program that works with external data, this case must be checked separately.

### 10. Reversing an array in place

```go
package main

import "fmt"

func main() {
	arr := [5]int{10, 20, 30, 40, 50}
	for left, right := 0, len(arr)-1; left < right; left, right = left+1, right-1 {
		arr[left], arr[right] = arr[right], arr[left]
	}
	fmt.Println(arr)
}
```

**Output:**

```text
[50 40 30 20 10]
```

The `left` index moves from the start of the array and `right` from the end. On each iteration the values at these
indexes are swapped. When the indexes meet, the loop ends. Because the change is made in the array itself, no extra
array is needed.

In the next lesson we will learn to work with slices, whose number of elements can change, their length and capacity,
and the `append()` function.
