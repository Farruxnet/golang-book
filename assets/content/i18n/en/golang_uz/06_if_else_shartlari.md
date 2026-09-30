# The if, else if and else statements in Go

A program does not always run the same instructions. Sometimes it has to choose one of several paths depending on
how a value changes. For example, it can let a user log in if they are an adult and refuse otherwise.

Running code in different directions depending on a condition is called branching. In Go, branching is done with `if`,
`else if` and `else`.

## The `if` condition

`if` checks the given boolean expression. If the expression is `true`, the code between `{` and `}` runs. If it is
`false`, that part is skipped.

```go
if booleanExpression {
	// This code runs if the condition is true.
}
```

For example:

```go
package main

import "fmt"

func main() {
	temperature := 32
	isHot := temperature > 30 // mark it as hot if above 30
	if isHot {
		fmt.Println("It's hot today.")
	}
}
```

**Output:**

```text
It's hot today.
```

The result of the comparison `temperature > 30` is `true`, so the message is printed. If `temperature` were `25`, the
`if` block would not run.

> **Info**
>
> In Go, the curly braces of an `if` block are mandatory; they are written even if the block has only one statement.

## The condition must be a `bool`

The expression in an `if` must produce a `bool`, that is, a `true` or `false` value:

```go
age := 20
if age >= 18 {
	fmt.Println("Adult")
}
```

**Output:**

```text
Adult
```

Unlike some languages, Go does not treat `0` as `false` and other numbers as `true`:

```go
num := 1
// if num { } // compilation error: num is not a bool
```

## Checking the user's age

We read an age from the console and print a message if the user is older than 18:

```go
package main

import "fmt"

func main() {
	var age int

	fmt.Print("Enter your age: ")
	_, err := fmt.Scan(&age)
	if err != nil {
		fmt.Println("Error: enter your age as a whole number.")
		return
	}

	if age > 18 {
		fmt.Println("Welcome!")
	}
}
```

If `19` is entered:

```text
Enter your age: 19
Welcome!
```

If `18` is entered, no message is printed. The reason is that the expression `18 > 18` is `false`. If age 18 should
also be allowed, use the greater-than-or-equal operator:

```go
if age >= 18 {
	fmt.Println("Welcome!")
}
```

Choosing the boundaries precisely matters:

- `age > 18` - only 19 and above;
- `age >= 18` - 18 and above;
- `age < 18` - values below 18;
- `age <= 18` - 18 and below.

**Info**

How does `_, err := fmt.Scan(&age)` work?
***
`fmt.Scan(&age)` reads the value entered by the user and returns **two results**:
1. how many values were read successfully;
2. the error that occurred while reading.
```go
_, err := fmt.Scan(&age)
```
Here:
- `_` — means we don't need the first result. In Go, `_` is called the **blank identifier**. It accepts a value but does not store it;
- `err` — stores the error value. If the user enters text instead of an age, `err` will hold an error;
- `:=` — creates the `err` variable and gives it a value;
- `&age` — passes the memory address of `age` to `fmt.Scan` so the entered value can be written into the `age` variable.
For example, if the user enters `25`, `fmt.Scan` returns roughly these results:
```go
1, nil
```
This means `1` value was read successfully and there was no error. Since we don't need the first result, we ignore it with `_`.
If the user enters `twenty`, the value does not match the `int` type and an error appears in `err`:
```go
if err != nil {
    fmt.Println("Error: enter your age as a whole number.")
    return
}
```
In Go, `nil` means there is no error. If `err != nil`, an error occurred while reading the value.

## else: otherwise

If only `if` is used, no code runs when the condition is `false`. Simply writing a message after the `if` block does
not solve the problem either:

```go
if age >= 18 {
	fmt.Println("Welcome!")
}

fmt.Println("Not allowed!")
```

In this code `Not allowed!` is always printed. If the age is `20`, both messages appear, because the second `Println()`
is not inside any condition.

To run exactly one of two paths, `else` is used:

```go
if booleanExpression {
	// Runs if the condition is true.
} else {
	// Runs if the condition is false.
}
```

Let's complete the age example with `else`:

```go
package main

import "fmt"

func main() {
	var age int

	fmt.Print("Enter your age: ")
	_, err := fmt.Scan(&age)
	if err != nil {
		fmt.Println("Error: enter your age as a whole number.")
		return
	}

	if age >= 18 {
		fmt.Println("Welcome!")
	} else {
		fmt.Println("Not allowed!")
	}
}
```

If `15` is entered:

```text
Enter your age: 15
Not allowed!
```

If `18` is entered:

```text
Enter your age: 18
Welcome!
```

Only one of the `if` and `else` blocks runs. If the condition is `true`, `if` runs; otherwise `else` runs.

## else if: several conditions

Sometimes you need to choose one of several cases, not just two. `else if` checks additional conditions one after another:

```go
if firstCondition {
	// Runs if the first condition is true.
} else if secondCondition {
	// Runs if the first is false and the second is true.
} else if thirdCondition {
	// Runs if the previous conditions are false and the third is true.
} else {
	// Runs if none of the conditions is true.
}
```

Go checks the conditions from top to bottom. After the block of the first `true` condition runs, the remaining
`else if` and `else` parts are not checked.

```go
package main

import "fmt"

func main() {
	var age int

	fmt.Print("Enter your age: ")
	_, err := fmt.Scan(&age)
	if err != nil {
		fmt.Println("Error: enter your age as a whole number.")
		return
	}

	if age >= 30 {
		fmt.Println("You are 30 or older.")
	} else if age >= 18 {
		fmt.Println("Welcome!")
	} else {
		fmt.Println("Not allowed!")
	}
}
```

Here the ranges are distributed like this:

|                 Age | Block that runs      |
|--------------------:|----------------------|
|        `30` or more | `if age >= 30`       |
|    `18` through `29` | `else if age >= 18` |
|       less than `18` | `else`              |

There is no need to write `age < 30` in the second condition. If the program has reached that line, the first
condition `age >= 30` has already turned out to be `false`.

## The order of conditions matters

If a broader condition is written first, a later, more specific condition may never run:

```go
if age >= 18 {
	fmt.Println("18 or older")
} else if age >= 30 {
	fmt.Println("30 or older")
}
```

In this code the `age >= 30` block never runs. For example, `35` matches the first condition `age >= 18`, and the
check ends there.

The correct order is to write the more specific condition, or the one with the higher bound, first!

```go
if age >= 30 {
	fmt.Println("30 or older")
} else if age >= 18 {
	fmt.Println("18 to 29")
}
```

## Combining several conditions

With the `&&`, `||` and `!` operators you can combine several checks into one condition.

### `&&`: all conditions must hold

```go
package main

import "fmt"

func main() {
	age := 24
	hasTicket := true

	if age >= 18 && hasTicket {
		fmt.Println("You can enter the event.")
	} else {
		fmt.Println("You need to be old enough and have a ticket to enter.")
	}
}
```

When `&&` is used, both conditions must be `true`.

### `||`: one condition is enough

```go
isWeekend := true
onVacation := false

if isWeekend || onVacation {
	fmt.Println("You can rest today.")
}
```

When `||` is used, the block runs if at least one condition is `true`.

### `!`: negating a value

```go
blocked := false

if !blocked {
	fmt.Println("The user is active.")
}
```

`!blocked` means the same as `blocked == false`, but the negated form is often used because it is shorter.

## Checking a range of values

Checking that a number is within a certain range is very common. For example, an exam score must be from `0` to `100`:

```go
package main

import "fmt"

func main() {
	var score int

	fmt.Print("Enter the score: ")
	_, err := fmt.Scan(&score)
	if err != nil {
		fmt.Println("Error: enter a whole number.")
		return
	}

	if score < 0 || score > 100 {
		fmt.Println("Error: the score must be from 0 to 100.")
	} else if score >= 86 {
		fmt.Println("Excellent")
	} else if score >= 71 {
		fmt.Println("Good")
	} else if score >= 56 {
		fmt.Println("Satisfactory")
	} else {
		fmt.Println("Unsatisfactory")
	}
}
```

First the invalid range was checked. Then the grades were arranged from top to bottom. For example, `90` matches the
first grading condition; `75` does not pass the first one but matches the second.

## Nested `if`

You can write one `if` inside another `if` block. This is called a nested condition (nested `if`):

```go
package main

import "fmt"

func main() {
	loggedIn := true
	admin := false

	if loggedIn {
		fmt.Println("Personal page opened.")

		if admin {
			fmt.Println("Admin panel opened.")
		}
	} else {
		fmt.Println("Log in first.")
	}
}
```

The inner `if admin` is checked only when the outer condition `loggedIn` is `true`.

When nested blocks multiply, the code becomes hard to read. It can be simplified with a logical operator or with
`return`.

## A short statement in `if`

Go lets you write a short statement before the `if` condition. The statement and the condition are separated by a semicolon:

```go
package main

import "fmt"

func main() {
	money := 3

	if balance := money; balance > 5 {
		fmt.Println("Funds:", balance)
	} else {
		fmt.Println("Not enough", balance)
	}
}
```

`balance := money;` runs first, then `balance > 5` is checked.

A variable created in the short statement works only in the `if` and in the `else if` and `else` blocks attached to it:

```go
if num := 10; num > 0 {
	fmt.Println(num)
}

// fmt.Println(num) // num cannot be accessed here
```

This technique is convenient when a temporary result is needed only inside the condition. For example, it is used a lot
to check an `err` returned by a function.

## Scope boundaries

A variable declared inside an `if` cannot be accessed outside that block:

```go
age := 20

if age >= 18 {
	message := "Welcome"
	fmt.Println(message)
}

// fmt.Println(message) // compilation error
```

`message` exists only inside the `{}` block of the `if`. If the value is needed after the block too, the variable must
be declared before the `if`:

```go
message := "Not allowed"

if age >= 18 {
	message = "Welcome"
}

fmt.Println(message)
```

## Simplifying code with `return`

Checking error cases at the start and ending the function right away reduces nested conditions:

```go
package main

import "fmt"

func main() {
	var age int

	fmt.Print("Enter your age: ")
	_, err := fmt.Scan(&age)
	if err != nil {
		fmt.Println("Error: enter a whole number.")
		return
	}

	if age < 0 || age > 150 {
		fmt.Println("Error: the age must be from 0 to 150.")
		return
	}

	if age < 18 {
		fmt.Println("Not allowed!")
		return
	}

	fmt.Println("Welcome!")
}
```

After each invalid case is checked, `return` ends the `main()` function. There is no need for extra `else` blocks
or nested conditions.

## The difference between `if` and `else if`

If several `if` statements are used, several blocks can run:

```go
num := 12

if num > 0 {
	fmt.Println("Positive")
}

if num%2 == 0 {
	fmt.Println("Even")
}
```

As a result both `Positive` and `Even` are printed, because the two conditions are checked separately.

In an `if`–`else if`–`else` chain, only the first matching block runs:

```go
if num < 0 {
	fmt.Println("Negative")
} else if num == 0 {
	fmt.Println("Zero")
} else {
	fmt.Println("Positive")
}
```

Use separate `if`s when several different conditions should be checked at the same time, and `else if` when one of
several mutually exclusive cases should be chosen.

> **Warning**
>
> Not checking the result of `fmt.Scan(&)` can make the program continue with a wrong value when text or an invalid
> format is entered. Always check that a value coming from outside has the right type and meets the allowed conditions.

In the next part we will learn to use the `switch` statement to compare one value against several specific
options.

## Examples

### 1. Finding the sign of a number

```go
package main

import "fmt"

func main() {
	num := -7
	if num > 0 {
		fmt.Println("Positive")
	} else if num < 0 {
		fmt.Println("Negative")
	} else {
		fmt.Println("Zero")
	}
}
```

The three cases are mutually exclusive, so only one of them runs.

### 2. Checking for a leap year

```go
package main

import "fmt"

func main() {
	year := 2024
	leap := year%400 == 0 || year%4 == 0 && year%100 != 0
	if leap {
		fmt.Println("Leap year")
	} else {
		fmt.Println("Common year")
	}
}
```

A year is a leap year if it is divisible by `400`, or divisible by `4` but not by `100`.

### 3. Finding the largest of three numbers

```go
package main

import "fmt"

func main() {
	a, b, c := 12, 27, 19
	largest := a
	if b > largest {
		largest = b
	}
	if c > largest {
		largest = c
	}
	fmt.Println(largest)
}
```

Each independent `if` can update the current largest value.

### 4. Checking whether a triangle exists

```go
package main

import "fmt"

func main() {
	a, b, c := 3, 4, 5
	if a > 0 && b > 0 && c > 0 && a+b > c && a+c > b && b+c > a {
		fmt.Println("The triangle exists")
	} else {
		fmt.Println("The triangle does not exist")
	}
}
```

The sides must be positive, and the sum of any two sides must be greater than the third side.

### 5. A nested check

```go
package main

import "fmt"

func main() {
	login, password := "admin", "go123"
	if login == "admin" {
		if password == "go123" {
			fmt.Println("Logged in successfully")
		} else {
			fmt.Println("Wrong password")
		}
	} else {
		fmt.Println("User not found")
	}
}
```

The inner `if` checks the password only when the login is correct.

### 6. Declaring a variable in `if`

```go
package main

import "fmt"

func main() {
	if num := 42; num%2 == 0 {
		fmt.Println(num, "is even")
	} else {
		fmt.Println(num, "is odd")
	}
}
```

`num` is declared in the initial statement. It is visible only in this `if` and its `else` block.

### 7. Giving an empty value a default name

```go
package main

import "fmt"

func main() {
	name := ""
	if name == "" {
		name = "Guest"
	}
	fmt.Println("Hello,", name)
}
```

For a single conditional change there is no need to write an `else`.

### 8. Choosing a discount level

```go
package main

import "fmt"

func main() {
	purchase := 750_000
	discount := 0
	if purchase >= 1_000_000 {
		discount = 15
	} else if purchase >= 500_000 {
		discount = 10
	} else if purchase >= 100_000 {
		discount = 5
	}
	fmt.Println(discount, "%")
}
```

The check starts from the largest threshold. Otherwise a smaller threshold would match first.

### 9. Checking before dividing by zero

```go
package main

import "fmt"

func main() {
	num, divisor := 20, 0
	if divisor != 0 {
		fmt.Println("Result:", num/divisor)
	} else {
		fmt.Println("Cannot divide by zero")
	}
}
```

The division runs only when the divisor is not zero. This check keeps the program from stopping with an error at runtime.

### 10. Clamping a value to a range

```go
package main

import "fmt"

func main() {
	volume := 120
	if volume < 0 {
		volume = 0
	} else if volume > 100 {
		volume = 100
	}
	fmt.Println(volume)
}
```

The result is `100`. This technique keeps an external value from going beyond the allowed limits.
