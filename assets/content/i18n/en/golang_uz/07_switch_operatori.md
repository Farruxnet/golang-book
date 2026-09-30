# switch: choosing one of several cases

`switch` chooses one of several paths based on a value or a condition. For example, you can find the name of a day from
its number, explain an HTTP status code or perform an action that matches a user's role.

The `if` and `else if` from the previous lesson are also used for choosing. But when one value is compared against many
options, `switch` is usually more compact and easier to read.

## Basic syntax

```go
switch expression {
case value1:
	// runs if expression equals value1
case value2:
	// runs if expression equals value2
default:
	// runs if no case matches
}
```

`switch` first evaluates the expression. Then it compares the `case` values from top to bottom. The block of the first
matching `case` runs and the `switch` ends. If none matches, the optional `default` block runs.

> **Info**
>
> In Go there is no need to write `break` at the end of each `case`. After the matching block runs, execution does not
> automatically move on to the next `case`. This feature sets Go apart from languages such as C, Java and JavaScript.

## Finding the day of the week

```go
package main

import "fmt"

func main() {
	var day int

	fmt.Print("Enter the day of the week number (1-7): ")
	_, err := fmt.Scan(&day)
	if err != nil {
		fmt.Println("Error: enter a whole number.")
		return
	}

	switch day {
	case 1:
		fmt.Println("Monday")
	case 2:
		fmt.Println("Tuesday")
	case 3:
		fmt.Println("Wednesday")
	case 4:
		fmt.Println("Thursday")
	case 5:
		fmt.Println("Friday")
	case 6:
		fmt.Println("Saturday")
	case 7:
		fmt.Println("Sunday")
	default:
		fmt.Println("Error: the day number must be from 1 to 7.")
	}
}
```

If `5` is entered:

```text
Enter the day of the week number (1-7): 5
Friday
```

The value of `day` is compared with each `case`. `5` matches only `case 5`. The values `0` or `8` do not match any day,
so `default` prints an error message. If text is entered, the error returned by `fmt.Scan()` is stored in the `err`
variable, the `if` statement checks it and stops the work right there.

## Several values in one `case`

If the same task must be done for several values, you can write the values in one `case`, separated by commas:

```go
package main

import "fmt"

func main() {
	day := "saturday"

	switch day {
	case "saturday", "sunday":
		fmt.Println("Weekend")
	case "monday", "tuesday", "wednesday", "thursday", "friday":
		fmt.Println("Weekday")
	default:
		fmt.Println("Unknown day")
	}
}
```

Output:

```text
Weekend
```

Here the comma means **or**. If the value of `day` is `"saturday"` or `"sunday"`, the first block runs.
The values must be of a type that can be compared with `day`. For example, if the switch works with a `string`, you
cannot write `case 1`, that is, a value of another type.

## `switch` without an expression

You can leave out the expression after `switch`. It then works like `switch true`, and each `case` is a boolean condition:

```go
package main

import "fmt"

func main() {
	temperature := 28

	switch {
	case temperature < -50 || temperature > 60:
		fmt.Println("The temperature is outside the allowed range")
	case temperature < 0:
		fmt.Println("Cold")
	case temperature < 20:
		fmt.Println("Cool")
	case temperature < 30:
		fmt.Println("Warm")
	default:
		fmt.Println("Hot")
	}
}
```

Output:

```text
Warm
```

The conditions are checked from top to bottom. Because `28 < 30` is the first matching condition, `Warm` is printed.
The order matters! If we wrote `temperature < 30` before `temperature < 20`, then, for example, `15` would match it too,
and the `Cool` block would never run.

A `switch` without an expression can be an easy-to-read alternative to a complex `if`–`else if` chain. It is often used
for ranges, validation and mutually exclusive conditions.

## A short statement in `switch`

You can write a short statement before the `switch` expression. The statement and the expression are separated by a
semicolon:

```go
package main

import "fmt"

func main() {
	name := "  Go  "

	switch length := len(name); length {
	case 0:
		fmt.Println("The text is empty")
	case 1, 2, 3:
		fmt.Println("Short text")
	default:
		fmt.Println("Text length:", length)
	}
}
```

Output:

```text
Text length: 6
```

`length := len(name)` runs only once. The `length` variable exists in the `case` and `default` blocks, but is not
visible outside the `switch`. `len()` returns the number of bytes.

## `break` and `fallthrough`

A plain `switch` does not need `break`. But if a block needs to end early, you can use it:

```go
switch status {
case "ready":
	if cancelled {
		break
	}
	fmt.Println("Work started")
}
```

`break` ends the nearest `switch` or `for`. In this example, if `cancelled` is `true`, the printing does not run.

`fallthrough` runs the `case` after the matching block without checking its condition:

```go
package main

import "fmt"

func main() {
	level := 3

	switch level {
	case 3:
		fmt.Println("Core features")
		fallthrough
	case 2:
		fmt.Println("Extra features")
		fallthrough
	case 1:
		fmt.Println("Basic features")
	default:
		fmt.Println("Unknown level")
	}
}
```

Output:

```text
Core features
Extra features
Basic features
```

> **Warning**
>
> `fallthrough` does not check the condition of the next `case`. That is why it is used carefully and rarely.

> **Tip**
>
> `fallthrough` must be the last statement in a block. It cannot be used in the last `case`.

## Which values can be compared?

In a plain `switch`, the expression and the `case` values must be comparable with each other. Numbers, `string`, `bool`,
pointers, channels, and array and struct values made only of comparable fields can work. Slice, map and function values
cannot be compared with plain equality, so they cannot be `case` values.

`case` values do not have to be constants known at compile time. Expressions can be used too. However, repeating a
`case` with the same constant causes a compilation error:

```go
// Wrong: both cases have the same value.
switch num {
case 1:
	fmt.Println("one")
case 1:
	fmt.Println("one again")
}
```

> **Info**
>
> `default` is optional. If it is missing and no `case` matches, the `switch` does nothing. When checking an external
> value, `default` is often useful so that an unknown case is not hidden.

In the next part we will learn the `for` loop, the statement for repetition.

## Examples

### 1. Checking several values in one `case`

```go
package main

import "fmt"

func main() {
	day := "saturday"
	switch day {
	case "saturday", "sunday":
		fmt.Println("Weekend")
	default:
		fmt.Println("Weekday")
	}
}
```

If one of the comma-separated values matches, that `case` runs.

### 2. Checking a range with an expressionless `switch`

```go
package main

import "fmt"

func main() {
	score := 86
	switch {
	case score >= 90:
		fmt.Println("A")
	case score >= 80:
		fmt.Println("B")
	case score >= 70:
		fmt.Println("C")
	default:
		fmt.Println("F")
	}
}
```

When no expression is written after `switch`, each `case` is checked as a boolean condition.

### 3. An initial statement in `switch`

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	switch hour := time.Now().Hour(); {
	case hour < 12:
		fmt.Println("Good morning")
	case hour < 18:
		fmt.Println("Good afternoon")
	default:
		fmt.Println("Good evening")
	}
}
```

`hour` is visible only inside the `switch`. Because the part after the semicolon is empty, the conditional `case`s work.

### 4. Finding the season from the month name

```go
package main

import "fmt"

func main() {
	month := "april"
	switch month {
	case "december", "january", "february":
		fmt.Println("Winter")
	case "march", "april", "may":
		fmt.Println("Spring")
	case "june", "july", "august":
		fmt.Println("Summer")
	case "september", "october", "november":
		fmt.Println("Autumn")
	default:
		fmt.Println("Unknown month")
	}
}
```

Several months belonging to one season are written in one `case`. `default` reports a wrong month name separately.

### 5. Choosing a calculator operation

```go
package main

import "fmt"

func main() {
	a, b := 12, 4
	op := "/"
	switch op {
	case "+":
		fmt.Println(a + b)
	case "-":
		fmt.Println(a - b)
	case "*":
		fmt.Println(a * b)
	case "/":
		fmt.Println(a / b)
	default:
		fmt.Println("Unknown operation")
	}
}
```

`switch` picks the required operator based on the operation symbol. In the division example it is known in advance that `b` is not zero.

### 6. Computed `case` values

```go
package main

import "fmt"

func main() {
	a, b := 2, 3
	result := 6
	switch result {
	case a + b:
		fmt.Println("Sum")
	case a * b:
		fmt.Println("Product")
	default:
		fmt.Println("No match")
	}
}
```

A `case` value can also be computed from variables. Here `6` matches the second `case`.

### 7. Ending a `case` early with `break`

```go
package main

import "fmt"

func main() {
	command, allowed := "delete", false
	switch command {
	case "delete":
		if !allowed {
			fmt.Println("Permission denied")
			break
		}
		fmt.Println("Deleted")
	default:
		fmt.Println("Unknown command")
	}
}
```

Go leaves each `case` automatically. When a block needs to end earlier inside an inner condition, `break` is useful.

### 8. Classifying a character

```go
package main

import "fmt"

func main() {
	char := 'e'
	switch char {
	case 'a', 'e', 'i', 'o', 'u':
		fmt.Println("Vowel")
	default:
		fmt.Println("Consonant or another character")
	}
}
```

`switch` works with `rune` values too.

### 9. Grouping HTTP status codes

```go
package main

import "fmt"

func main() {
	code := 404
	switch code / 100 {
	case 2:
		fmt.Println("Success")
	case 4:
		fmt.Println("Client error")
	case 5:
		fmt.Println("Server error")
	default:
		fmt.Println("Other response")
	}
}
```

Integer division extracts the hundreds digit of the code and checks the statuses of one group together.

### 10. Continuing a shared action with `fallthrough`

```go
package main

import "fmt"

func main() {
	role := "admin"
	switch role {
	case "admin":
		fmt.Println("Manage settings")
		fallthrough
	case "editor":
		fmt.Println("Edit articles")
		fallthrough
	case "reader":
		fmt.Println("Read articles")
	}
}
```

The blocks after `admin` run without conditions. For a permission model, explicit conditions are usually clearer; the example shows how `fallthrough` behaves.
