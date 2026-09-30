# Functions in Go

A function is a named block of code that performs a specific task. It lets you gather repeated code in one place, split
a program into small parts and test each part separately.

## Declaring and calling

```go
func name(parameter ParamType) ReturnType {
	return value
}
```

A **parameter** is a variable listed in the function declaration. An **argument** is the concrete value given to a
parameter when the function is called.

```go
package main

import "fmt"

func greet(name string) string {
	return "Hello, " + name + "!"
}

func main() {
	message := greet("Ali")
	fmt.Println(message)
}
```

Output:

```text
Hello, Ali!
```

`greet` takes one `string` parameter and returns a `string`. `return` finishes the function's work and returns the
value. For a function that returns no value, no return type is written in the declaration.

Consecutive parameters of the same type can be written in short form: `func add(a, b int) int`.

## Returning several values

A Go function can return several values. This feature is used a lot to return an error together with the result:

```go
package main

import "fmt"

func divide(a, b float64) (float64, error) {
	if b == 0 {
		return 0, fmt.Errorf("cannot divide by zero")
	}
	return a / b, nil
}

func main() {
	result, err := divide(10, 4)
	if err != nil {
		fmt.Println("Error:", err)
		return
	}
	fmt.Println("Result:", result)
}
```

Output:

```text
Result: 2.5
```

If `b` is zero, the division is not performed and an error is returned. Returning the error as a separate value is
common in code that works with APIs, files or databases. If one of the returned values is not needed, it can be ignored
with `_`.

## Arguments are passed by value

In Go all arguments are passed by value. The function gets a copy of the argument's value:

```go
package main

import "fmt"

func increment(n int) {
	n++
}

func main() {
	num := 10
	increment(num)
	fmt.Println(num)
}
```

Output:

```text
10
```

`slice`, `map`, `channel` and `pointer` values are also passed by value. But their copies may refer to the same
underlying data. So copying an argument does not mean that changes inside the function never affect the caller.

## Variadic functions

Sometimes we don't know in advance how many arguments will be passed to a function.

For example, we want to write a function that calculates the sum of several numbers. With ordinary parameters we would
have to fix the number of arguments in advance:

```go
func sum(a, b int) int {
	return a + b
}
```

This function accepts only two numbers:

```go
sum(10, 20)
```

If we want to pass three, four or more numbers, such a function is not enough. In such cases a **variadic function** is
used. A variadic parameter is written like this:

```go
numbers ...int
```

This notation means:

> zero or more `int` values can be passed to the `numbers` parameter

For example:

```go
package main

import "fmt"

func sum(numbers ...int) int {
	result := 0

	for _, num := range numbers {
		result += num
	}

	return result
}

func main() {
	fmt.Println(sum(1, 2, 3, 4))
}
```

Output:

```text
10
```

Here:

```go
sum(1, 2, 3, 4)
```

passes four separate `int` arguments to the function.

Inside the function, the parameter:

```go
numbers ...int
```

works like a `[]int`.

That is, in the call above you can picture `numbers` inside the function roughly as:

```go
[]int{1, 2, 3, 4}
```

That is why its elements can be iterated over with `range`:

```go
for _, num := range numbers {
	result += num
}
```

A variadic function can receive different numbers of arguments:

```go
fmt.Println(sum())
fmt.Println(sum(10))
fmt.Println(sum(10, 20))
fmt.Println(sum(10, 20, 30, 40))
```

For example:

```go
sum()
```

is also a valid call, because a variadic parameter accepts **zero or more** arguments.

### Passing a slice to a variadic function

Now imagine we have a ready-made slice:

```go
numbers := []int{5, 6, 7}
```

You cannot write it like this:

```go
sum(numbers)
```

Because `sum` expects separate `int` arguments, while `numbers` is a single `[]int` value.

In such a case `...` is written after the slice name:

```go
sum(numbers...)
```

A complete example:

```go
package main

import "fmt"

func sum(numbers ...int) int {
	result := 0

	for _, num := range numbers {
		result += num
	}

	return result
}

func main() {
	numbers := []int{5, 6, 7}

	fmt.Println(sum(numbers...))
}
```

Output:

```text
18
```

The following form:

```go
sum(numbers...)
```

passes the elements of the slice to the function as separate arguments.

In meaning, it is similar to:

```go
sum(5, 6, 7)
```

So `...` can appear in two places, and its job differs slightly.

In a function parameter:

```go
func sum(numbers ...int)
```

`...int` means:

> this parameter accepts any number of `int` arguments

When calling the function:

```go
sum(numbers...)
```

`numbers...` means:

> spread the elements of the slice into separate arguments

### The variadic parameter must be last

A function can have both ordinary parameters and a variadic parameter:

```go
func message(prefix string, numbers ...int) {
	// ...
}
```

Then the function can be called like this:

```go
message("Result:", 10, 20, 30)
```

But the variadic parameter must always come at the **end** of the parameter list.

For example, you cannot write:

```go
func message(numbers ...int, prefix string) {
	// ...
}
```

The reason is that you cannot know in advance how many arguments `numbers` takes. If there were another parameter after
it, it would be ambiguous which arguments belong to the variadic parameter and which to the next parameter.

So the correct form is:

```go
func message(prefix string, numbers ...int) {
	// ...
}
```

In short:

```go
func sum(numbers ...int)
```

— the function accepts any number of `int` arguments.

```go
sum(1, 2, 3)
```

— three separate arguments are passed.

```go
numbers := []int{1, 2, 3}
sum(numbers...)
```

— the slice elements are passed as separate arguments.

Inside the function, `numbers` is used as a `[]int`.

## Function values and anonymous functions

In Go a function is also used as a value. It can be stored in a variable or passed to another function as an argument.

```go
package main

import "fmt"

func calculate(a, b int, op func(int, int) int) int {
	return op(a, b)
}

func main() {
	multiply := func(a, b int) int {
		return a * b
	}

	fmt.Println(calculate(4, 5, multiply))
}
```

Output:

```text
20
```

If an anonymous function uses a variable from the outer scope, a closure is formed. The closure keeps a reference to
that variable, so its state can persist across later calls. This technique shows up in callbacks, middleware and
configuration functions.

## Recursion

A function calling itself is called recursion. A recursive function must have a stopping condition:

```go
package main

import "fmt"

func factorial(n uint64) uint64 {
	if n <= 1 {
		return 1
	}
	return n * factorial(n-1)
}

func main() {
	fmt.Println(factorial(5))
}
```

Output:

```text
120
```

Each call uses extra space on the stack. Very deep recursion increases resource usage. For simple sequential
calculations, a loop may be clearer. If the factorial result exceeds the capacity of `uint64`, an overflow occurs. So
this example is not meant for calculating large numbers.

## Examples

### 1. Returning whether a number is even

```go
package main

import "fmt"

func isEven(num int) bool {
	return num%2 == 0
}

func main() {
	fmt.Println(isEven(18))
}
```

The function returns the computed `bool` value directly with `return`. The result of this example is `true`.

### 2. Named return values

```go
package main

import "fmt"

func rectangle(width, height int) (area int, perimeter int) {
	area = width * height
	perimeter = 2 * (width + height)
	return
}

func main() {
	area, perimeter := rectangle(8, 5)
	fmt.Println(area, perimeter)
}
```

Named return values work like ordinary variables inside the function. A bare `return` returns their current values.

### 3. Checking with an early `return`

```go
package main

import "fmt"

func div(a, b float64) (float64, bool) {
	if b == 0 {
		return 0, false
	}
	return a / b, true
}

func main() {
	result, ok := div(20, 4)
	fmt.Println(result, ok)
}
```

The division-by-zero case is checked first. The second return value tells whether the division succeeded.

### 4. A variadic sum

```go
package main

import "fmt"

func sum(numbers ...int) int {
	result := 0
	for _, num := range numbers {
		result += num
	}
	return result
}

func main() {
	fmt.Println(sum(2, 4, 6, 8))
}
```

`...int` means the function accepts zero or more `int` arguments. Inside the function, `numbers` works as a slice.

### 5. Passing a slice as variadic arguments

```go
package main

import "fmt"

func largest(numbers ...int) int {
	max := numbers[0]
	for _, num := range numbers[1:] {
		if num > max {
			max = num
		}
	}
	return max
}

func main() {
	numbers := []int{7, 12, 4, 19}
	fmt.Println(largest(numbers...))
}
```

`numbers...` passes the slice elements as separate arguments. In the example it is known in advance that the slice is
not empty.

### 6. Passing a function as an argument

```go
package main

import "fmt"

func calculate(a, b int, op func(int, int) int) int {
	return op(a, b)
}

func main() {
	multiply := func(a, b int) int { return a * b }
	fmt.Println(calculate(6, 7, multiply))
}
```

The type of the `op` parameter denotes a function that takes two `int`s and returns one `int`.

### 7. Keeping state in a closure

```go
package main

import "fmt"

func counter() func() int {
	count := 0
	return func() int {
		count++
		return count
	}
}

func main() {
	next := counter()
	fmt.Println(next(), next(), next())
}
```

The returned anonymous function keeps a reference to the outer `count` variable. That is why consecutive calls give
`1 2 3`.

### 8. A map of functions

```go
package main

import "fmt"

func main() {
	ops := map[string]func(int, int) int{
		"+": func(a, b int) int { return a + b },
		"-": func(a, b int) int { return a - b },
	}
	fmt.Println(ops["+"](10, 3))
}
```

A function can also be a `map` value. First the function is taken by its key, then it is called with arguments.

### 9. The sum of digits with recursion

```go
package main

import "fmt"

func digitSum(num int) int {
	if num == 0 {
		return 0
	}
	return num%10 + digitSum(num/10)
}

func main() {
	fmt.Println(digitSum(5832))
}
```

Each call separates the last digit of the number. The condition `num == 0` stops the recursion.

### 10. Returning a function based on a condition

```go
package main

import "fmt"

func chooseOp(name string) func(int, int) int {
	if name == "multiply" {
		return func(a, b int) int { return a * b }
	}
	return func(a, b int) int { return a + b }
}

func main() {
	op := chooseOp("multiply")
	fmt.Println(op(5, 4))
}
```

A function can return another function as its result. The returned value is then called like an ordinary function.
