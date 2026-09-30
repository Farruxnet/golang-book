# The for loop

A process that repeats in the same way is called a loop. Repetition is used a lot in programming, and the `for`
statement is used for it. For example, you need a loop to print the numbers from `1` to `100` or to calculate a
sum.

Go has only one loop statement: `for`. It does the jobs of `for`, `while` and infinite loops in other languages.

## The three-part `for`

The most common form:

```go
for init; condition; update {
	// code to repeat
}
```

- `init` runs once before the loop starts;
- `condition` is checked before each iteration;
- `update` runs at the end of each iteration.

> **Info**
>
> An **iteration** is one execution of the loop body.

```go
package main

import "fmt"

func main() {
	for i := 0; i < 5; i++ {
		fmt.Println(i)
	}
}
```

**Output:**

```text
0
1
2
3
4
```

First `i := 0` runs once. Since `i < 5` is `true`, `i` is printed. Then `i++` increases the value by one and
the condition is checked again. When `i` reaches `5`, the condition becomes `false` and the loop ends.

`i` can only be accessed inside the `for` block. Writing `fmt.Println(i)` after the loop causes a compilation
error.

> **Info**
>
> In Go, `i++` is used only as a separate statement. You cannot write `x := i++` or `if i++ > 2`.

## The conditional `for`

If the init and update parts are moved outside, `for` works like `while` in other languages:

```go
package main

import "fmt"

func main() {
	i := 1
	for i <= 3 {
		fmt.Println(i)
		i++
	}
}
```

Output:

```text
1
2
3
```

In this form `i` is created before the loop, so it can be used after the loop too. Be careful not to forget to
increase `i`: if `i` does not change, `i <= 3` stays `true` forever and the loop never ends.

## The infinite loop

If no condition is written, the loop runs forever:

```go
for {
	// the process continues forever
}
```

Infinite loops are needed in servers, workers and programs that process events. They are controlled not by closing
the terminal but by a `break`, a `return` or a cancellation condition in the program's logic.

> **Info**
>
> The `break` statement stops a loop.

```go
package main

import "fmt"

func main() {
	num := 1

	for {
		if num > 3 {
			break // runs when num is greater than 3, and the loop stops here.
		}

		fmt.Println(num)
		num++
	}
}
```

Output:

```text
1
2
3
```

When `num > 3`, `break` ends the `for` immediately. The rest of the loop body after `break` does not run.

## Skipping an iteration with continue

`continue` is used to skip the rest of the current iteration of a loop and move on to the next iteration.
The following program prints only even numbers:

```go
package main

import "fmt"

func main() {
	for i := 1; i <= 10; i++ {
		if i%2 != 0 {
			continue
		}

		fmt.Println(i)
	}
}
```

Output:

```text
2
4
6
8
10
```

`i%2` gives the remainder of dividing the number by `2`. For an odd number the remainder is not zero, and because of
`continue`, `Println()` does not run. In a three-part `for`, the update part, that is `i++`, runs after `continue`.

If only even numbers are needed, you can also get the result by increasing the loop step by two:

```go
for i := 2; i <= 10; i += 2 {
	fmt.Println(i)
}
```

## Example: summing the entered numbers

We ask the user how many numbers will be entered and calculate their sum:

```go
package main

import "fmt"

func main() {
	var count int

	fmt.Print("Enter how many numbers: ")
	_, err := fmt.Scan(&count)
	if err != nil {
		fmt.Println("Error: enter a whole number.")
		return
	}
	if count < 1 || count > 1000 {
		fmt.Println("Error: the count must be from 1 to 1000.")
		return
	}

	sum := 0
	for i := 1; i <= count; i++ {
		var number int

		fmt.Printf("Enter number %d: ", i)
		_, err = fmt.Scan(&number)
		if err != nil {
			fmt.Println("Error: all values must be whole numbers.")
			return
		}

		sum += number
	}

	fmt.Println("Sum:", sum)
}
```

If `3` is entered, followed by `10`, `20` and `-5`:

```text
Enter how many numbers: 3
Enter number 1: 10
Enter number 2: 20
Enter number 3: -5
Sum: 25
```

Because `count` is an external value, both its type and its allowed range were checked. The loop runs exactly
`count` times. Each value is added to the sum with `sum += number`. Setting an upper bound for `count` prevents a
very long loop from starting.

> **Warning**
>
> Adding too many or very large `int` values can cause an overflow. Go does not stop signed integer overflow as a
> runtime error. When working with financial or untrusted data, check the limits.

## Walking over values with `range`

`range` is used to walk over (iterate) the elements of a string, array, slice, map or channel. In the following string
example, each Unicode character and the byte index where it starts are taken:

```go
package main

import "fmt"

func main() {
	word := "Go‘zal"

	for index, char := range word {
		fmt.Printf("index=%d char=%c\n", index, char)
	}
}
```

Output:

```text
index=0 char=G
index=1 char=o
index=2 char=‘
index=5 char=z
index=6 char=a
index=7 char=l
```

The word `Go‘zal` means "beautiful" in Uzbek. The indexes are `0, 1, 2, 5...` because the `‘` character takes three
bytes in UTF-8. The type of `char` is `rune`. The difference between `byte` and `rune` is covered in more depth in the
next lesson.

If one of the values is not needed, the blank identifier `_` is used:

```go
for _, char := range word {
	fmt.Printf("%c ", char)
}
```

If only the index is needed, there is no need to write the second value:

```go
for index := range word {
	fmt.Println(index)
}
```

## Nested loops and `label break`

You can write a loop inside another loop. A plain `break` ends only the current loop. If the outer loop must end
too, a label is used:

```go
package main

import "fmt"

func main() {
outer:
	for row := 1; row <= 3; row++ {
		for column := 1; column <= 3; column++ {
			if row == 2 && column == 2 {
				break outer
			}
			fmt.Println(row, column)
		}
	}
}
```

Output:

```text
1 1
1 2
1 3
2 1
```

`break outer` ends the outer loop marked with the `outer:` label. Labels are useful in deeply nested control flow, but
when used a lot they make code harder to understand.

## Common mistakes

### Getting a boundary wrong by one

`i < 10` does not include `10`, while `i <= 10` does. This is called an off-by-one error. It is important to check the
first, last and empty-range cases.

### An unintended infinite loop

In a conditional `for`, if the value that affects the condition is not updated, the loop never ends. Even when an
infinite loop is written on purpose, it needs the logic to stop it.

### Mixing up `break` and `continue`

`break` ends the loop completely. `continue` only skips the rest of the current iteration. The program's logic decides
which one is needed.

In later parts the `for` loop will be used again when working with the `array`, `slice` and `map` data types.

## Examples

### 1. Printing the numbers from `1` to `10`

```go
package main

import "fmt"

func main() {
	for i := 1; i <= 10; i++ {
		fmt.Print(i, " ")
	}
	fmt.Println()
}
```

The initial value is `1` and the condition is `i <= 10`. So both bounds are included in the result.

### 2. Printing the numbers from `10` down to `1`

```go
package main

import "fmt"

func main() {
	for i := 10; i >= 1; i-- {
		fmt.Print(i, " ")
	}
	fmt.Println()
}
```

This time the counter decreases by one with `i--`. The condition ends the loop when `i` becomes less than `1`.

### 3. The sum of the numbers from `1` to `10`

```go
package main

import "fmt"

func main() {
	sum := 0
	for i := 1; i <= 10; i++ {
		sum += i
	}
	fmt.Println(sum)
}
```

The result is `55`. The initial value of the sum is `0`, because adding zero to a number does not change its value.

### 4. The product of the numbers from `1` to `10`

```go
package main

import "fmt"

func main() {
	product := 1
	for i := 1; i <= 10; i++ {
		product *= i
	}
	fmt.Println(product)
}
```

The result is `3628800`. The product starts at `1`, because multiplying a number by `1` does not change it. If it started at `0`, the result would always stay zero.

### 5. Printing even numbers

```go
package main

import "fmt"

func main() {
	for i := 2; i <= 20; i += 2 {
		fmt.Print(i, " ")
	}
	fmt.Println()
}
```

The counter is increased by two, not by one. That is why the loop visits only even values.

### 6. The sum of a number's digits

```go
package main

import "fmt"

func main() {
	num := 5832
	sum := 0
	for num > 0 {
		sum += num % 10
		num /= 10
	}
	fmt.Println(sum)
}
```

`num % 10` takes the last digit, and `num /= 10` removes that digit. The result is `18`.

### 7. Reversing a number

```go
package main

import "fmt"

func main() {
	num := 1234
	reversed := 0
	for num > 0 {
		reversed = reversed*10 + num%10
		num /= 10
	}
	fmt.Println(reversed)
}
```

Each new digit is appended to the end of the previous result. The result is `4321`.

### 8. Calculating a factorial

```go
package main

import "fmt"

func main() {
	n := 6
	result := 1
	for i := 2; i <= n; i++ {
		result *= i
	}
	fmt.Println(result)
}
```

The result of `6!` is `720`. The loop starts at `2`, because multiplying by `1` does not change the result.

### 9. Checking for a prime number

```go
package main

import "fmt"

func main() {
	num := 29
	prime := num >= 2
	for i := 2; i*i <= num && prime; i++ {
		if num%i == 0 {
			prime = false
		}
	}
	fmt.Println(prime)
}
```

It is enough to check divisors up to the square root of the number. When a divisor is found, `prime` becomes `false` and the loop stops.

### 10. The Fibonacci sequence

```go
package main

import "fmt"

func main() {
	a, b := 0, 1
	for i := 0; i < 10; i++ {
		fmt.Print(a, " ")
		a, b = b, a+b
	}
	fmt.Println()
}
```

Each new value is the sum of the two previous values. The simultaneous assignment updates `a` and `b` without losing their old values.

### 11. A multiplication table

```go
package main

import "fmt"

func main() {
	for i := 1; i <= 3; i++ {
		for j := 1; j <= 5; j++ {
			fmt.Printf("%d × %d = %d\n", i, j, i*j)
		}
	}
}
```

The outer loop controls the first number and the inner loop the second. For each `i`, `j` starts again from `1`.

### 12. Skipping unneeded values with `continue`

```go
package main

import "fmt"

func main() {
	for i := 1; i <= 20; i++ {
		if i%3 != 0 {
			continue
		}
		fmt.Print(i, " ")
	}
	fmt.Println()
}
```

For values not divisible by `3`, `continue` skips the remaining statements. As a result only the multiples of `3` are printed.
