# Variables and constants

A variable is a piece of memory used to store a value under a name. While the program runs, you can read the value in a variable and change it if needed.

For example, a weather program may need to store a city name and its temperature. Instead of simply writing these values separately all over the code, we give them clear names:

```text
city
temperature
```

These names show what the value means inside the code.

For example, someone looking at the following code may not immediately understand what the number `28` means:

```go
fmt.Println(28)
```

But when the value has a name, the meaning becomes clearer:

```go
temperature := 28
fmt.Println(temperature)
```

That is the main job of variables: to store a value and refer to it by a clear name.

## Declaring a variable

A variable must be declared before it is used.

Declaring means giving Go the following information:

* what the variable's name is;
* what type of value it holds;
* if needed, what its initial value is.

For example:

```go
var age int = 25
```

Let's split this line into parts:

* `var` is the keyword used to declare a variable;
* `age` is the variable's name;
* `int` is the variable's type;
* `25` is the initial value.

`int` is one of the types used to store whole numbers.

So the line:

```go
var age int = 25
```

means "create an `int` variable named `age` and give it the value `25`".

A complete program looks like this:

```go
package main

import "fmt"

func main() {
	var age int = 25
	var temperature float64 = 36.6

	fmt.Println("Age:", age)
	fmt.Println("Temperature:", temperature)
}
```

There are two variables here:

```go
var age int = 25
```

and:

```go
var temperature float64 = 36.6
```

`age` is of type `int`.

`temperature` is of type `float64`. `float64` is commonly used to store numbers with a fractional part.

Output:

```text
Age: 25
Temperature: 36.6
```

You can pass several arguments to `fmt.Println()`, separated by commas.

For example:

```go
fmt.Println("Age:", age)
```

Two arguments are passed here:

1. `"Age:"`
2. `age`

When printing them to the terminal, `Println()` puts a suitable space between them.

You can also pass more values on one line:

```go
package main

import "fmt"

func main() {
	var age int = 25
	var temperature float64 = 36.6

	fmt.Println("Age:", age, "Temperature:", temperature)
}
```

The output will look roughly like this:

```text
Age: 25 Temperature: 36.6
```

## Changing a value

As the name suggests, a variable's value can change while the program runs.

For example:

```go
var count int = 10
count = 15
fmt.Println(count)
```

At first:

```text
count = 10
```

Then the line:

```go
count = 15
```

runs.

As a result, the new value `15` is stored in place of the old value `10`.

The terminal shows:

```text
15
```

Here the `=` operator does not create a new variable.

It gives an existing variable a new value.

For example:

```go
var count int = 10
```

declares the variable.

The next line:

```go
count = 15
```

updates the value of the already existing `count` variable.

The new value must match the variable's type.

For example:

```go
var age int = 25

// age = "twenty-five"
```

Here `age` is of type `int`.

`"twenty-five"` is a `string`, that is, a text value.

A `string` value cannot be assigned directly to an `int` variable. So if the comment is removed, a compilation error occurs.

Go is a statically typed language. This means a variable's type is known at compile time, and it does not "turn into" another type later.

## Type inference

You don't always have to write a variable's type by hand.

If there is an initial value, Go can often work out the type from that value.

For example:

```go
var name = "Aziza"
var age = 24
var price = 19.5
```

Here Go concludes:

```text
name  → string
age   → int
price → float64
```

This process is called **type inference**, that is, working out the type automatically from the value.

For example, in the line:

```go
var name = "Aziza"
```

`string` is not written explicitly.

But because `"Aziza"` is a string value, Go infers the type of `name` as `string`.

In the same way, for:

```go
var age = 24
```

the default type is `int`.

The important point is that once a type has been determined, it does not change.

For example:

```go
var age = 24

// age = "twenty-four"
```

in this code `age` was first inferred as `int`.

After that, it cannot be given a `string` value.

Type inference shortens the code, but it does not remove Go's type checking.

## Short declaration: `:=`

Inside a function there is a short way to declare a variable:

```go
name := "Aziza"
```

This syntax uses the `:=` operator.

For example:

```go
package main

import "fmt"

func main() {
	name := "Aziza"
	age := 24

	fmt.Println(name, age)
}
```

Here:

```go
name := "Aziza"
```

does two things at once:

1. declares a new variable named `name`;
2. gives it the initial value `"Aziza"`.

Go infers the type itself from the value.

Likewise, in the line:

```go
age := 24
```

`age` is inferred as `int`.

`:=` is used only inside functions.

For example, this form is correct:

```go
func main() {
	num := 10
	fmt.Println(num)
}
```

But the short declaration syntax cannot be used at package level.

At package level you use `var`:

```go
var num = 10
```

`=` and `:=` are not the same.

Look at the following code:

```go
num := 10
num = 20
```

The first line:

```go
num := 10
```

creates a new variable.

The second line:

```go
num = 20
```

changes the value of the existing variable.

You can remember it like this:

```text
:=  → declare + assign a value
=   → assign a value to an existing variable
```

For beginners, it is convenient to declare variables whose initial value is known right away with `:=` inside functions.

For example:

```go
name := "Ali"
age := 30
```

If the type needs to be stated explicitly in advance, or the value is assigned later, `var` is more convenient:

```go
var age int
age = 30
```

## A variable without an initial value

With `var` you can also declare a variable without an initial value:

```go
var num int
var text string
var active bool
```

Such variables do not stay "valueless" or in an unknown state.

Go gives every type a standard initial value.

This value is called the **zero value**.

For the basic types:

| Type         | Zero value           |
| ------------ | -------------------- |
| number types | `0`                  |
| `string`     | `""` — empty string  |
| `bool`       | `false`              |

For example:

```go
package main

import "fmt"

func main() {
	var attempts int
	var message string
	var ready bool

	fmt.Printf("attempts=%d, message=%q, ready=%t\n", attempts, message, ready)
}
```

Output:

```text
attempts=0, message="", ready=false
```

Here we did not give any of the variables an initial value.

But Go automatically gave them the values:

```text
attempts → 0
message  → ""
ready    → false
```

This is an important feature of Go.

When a local variable is declared with `var`, it does not get a random value from memory. It gets the zero value of its type.

This example uses `fmt.Printf()`:

```go
fmt.Printf("attempts=%d, message=%q, ready=%t\n", attempts, message, ready)
```

`Printf()` prints values according to the given format.

Here:

* `%d` — a whole number;
* `%q` — prints a string in quotes;
* `%t` — a `bool` value;
* `\n` — the newline character.

Because `%q` is used, even the empty string is clearly visible:

```text
message=""
```

Otherwise the empty string would be invisible in the terminal.

## Declaring several variables

In Go you can declare several variables on one line.

For example:

```go
var width, height int = 800, 600
```

Here:

```text
width  → 800
height → 600
```

both are of type `int`.

The values are given to the names on the left in order.

That is:

```go
var width, height int = 800, 600
```

is practically the same as:

```go
var width int = 800
var height int = 600
```

Inside a function you can also create several variables with a short declaration:

```go
name, city := "Ali", "Samarkand"
```

Here:

```text
name → "Ali"
city → "Samarkand"
```

The values on the left and right are matched by position.

Writing several values on one line can make the code compact.

But if the declaration becomes too long or hard to understand, it is better to split it into separate lines:

```go
name := "Ali"
city := "Samarkand"
```

The goal is not just to write fewer lines. Code that is easy to read matters too.

## Accessing variables

A variable cannot be used anywhere in the code.

Every variable has a **scope**.

Scope defines from which parts of the code a variable can be accessed.

In Go, blocks are delimited by `{` and `}`.

For example:

```go
package main

import "fmt"

func main() {
	city := "Tashkent"

	if true {
		temperature := 28
		fmt.Println(city, temperature)
	}

	// fmt.Println(temperature)
}
```

Here:

```go
city := "Tashkent"
```

is declared in the block of the `main()` function.

That is why `city` is also visible in the inner `if` block:

```go
fmt.Println(city, temperature)
```

But:

```go
temperature := 28
```

is declared inside the `if` block.

So it is visible only in that inner block and in blocks nested inside it.

After leaving the `if` block:

```go
// fmt.Println(temperature)
```

does not work.

If the comment is removed, the compiler cannot find the name `temperature` at that point.

You can picture it simply like this:

```text
main block
├── city is visible
│
└── if block
    ├── city is visible
    └── temperature is visible

after if ends:
city is visible
temperature is not visible
```

In large programs, scope helps keep names from getting mixed up with each other.

## Naming variables

A variable's name should show its purpose as clearly as possible.

For example, from the code:

```go
x := 25
```

you cannot immediately tell what `x` means.

If the value represents an age:

```go
age := 25
```

is much clearer.

Likewise:

```go
price := 15000
numberOfUsers := 120
```

these names show what the values mean.

In real projects identifiers are usually named in English, and this is often recommended. Especially in international teams, it makes it easier to work on the code with others.

For example:

```go
userCount := 120
totalPrice := 50000
```

The basic syntax rules for variable names:

* a name can start with a letter or `_`;
* the following characters can be letters and digits;
* spaces are not allowed;
* the `-` sign cannot be used as a normal part of a name;
* Go keywords such as `var`, `func` and `package` cannot be used as names;
* upper-case and lower-case letters are distinguished.

For example:

```text
age
Age
```

are two different names for Go.

Names made of several words are usually written in camelCase:

```go
numberOfUsers
totalAmount
maximumSpeed
```

In real Go code, shorter names like these are more common:

```go
userCount
totalPrice
maxSpeed
```

You should not use very short or meaningless names where they are not needed.

But short names like `i`, `j` and `x` can be fine in some small, local contexts. For example, `i` is widely used for the index inside a short `for` loop.

What matters is that a name does not make the code harder to understand.

## Unused variables

Go treats a variable that is declared inside a function but never used as an error.

For example:

```go
func main() {
	age := 25
}
```

Here:

```go
age := 25
```

creates a variable.

But `age` is not used anywhere afterwards.

Such code causes a compilation error.

For example, you can use the variable:

```go
func main() {
	age := 25
	fmt.Println(age)
}
```

Or, if it is not needed at all, remove it.

This rule helps find unnecessary variables that were accidentally left in the code.

In this respect it is similar to the rule about unused imports.

The Go compiler makes you keep the code relatively clean.

## Constants: `const`

Some values must not change while the program runs.

For example:

* the number of hours in a day;
* a mathematical coefficient;
* a fixed piece of text;
* a compile-time value in the configuration that never changes.

`const` is used for such values.

A **constant** is a named value that cannot be given a new value later.

For example:

```go
package main

import "fmt"

func main() {
	const hoursPerDay = 24
	const greeting string = "Hello"

	fmt.Println(greeting, hoursPerDay)
}
```

There are two constants here:

```go
const hoursPerDay = 24
```

and:

```go
const greeting string = "Hello"
```

In the first one the type is not written.

In the second one the `string` type is stated explicitly.

A constant cannot be given a new value later.

For example:

```go
const pi = 3.14

// pi = 3.1415
```

If the second line is uncommented, a compilation error occurs.

The reason is that `pi` is not a variable but a constant.

The main difference between `var` and `const` can be remembered like this:

```text
var   → the value can change later
const → the value cannot be reassigned
```

Go constants can hold compile-time constant values such as numbers, strings and `bool`.

A constant's value must be known at compile time.

For example:

```go
const minute = 60
const hour = 60 * minute
```

This is correct.

The compiler can calculate the value of `hour`.

But the result of an ordinary function call cannot be a constant.

For example:

```go
// const now = time.Now()
```

`time.Now()` calculates the current time at runtime.

This value is not known in advance at compile time.

So it cannot be a `const` value.

Thinking of `const` as "just a variable that cannot be changed" is not entirely accurate.

Constants in Go are a compile-time concept with their own rules for types and expressions.

If you need to create a sequence of constant values, you can use `iota`.

This feature is explained separately in the lesson on enums and iota.

In the next lesson we will look at Go's basic data types and the operations you can perform on them.

## Examples

### 1. Swapping values at once

This example shows that in Go you can swap the values of two variables without creating a temporary third variable.

```go
package main

import "fmt"

func main() {
	a, b := 10, 20

	a, b = b, a

	fmt.Println(a, b)
}
```

At first:

```text
a = 10
b = 20
```

Then the line:

```go
a, b = b, a
```

runs.

The important point is that the values on the right side are taken first.

That is, Go first prepares the values:

```text
b → 20
a → 10
```

Then they are given to the left side in the matching order:

```text
a ← 20
b ← 10
```

Output:

```text
20 10
```

In other languages such a swap may require a temporary variable:

```text
temp = a
a = b
b = temp
```

In Go, thanks to multiple assignment, it can be done in a single line.

### 2. Declaring several variables at once

This example shows creating several variables with a single `:=` operator.

```go
package main

import "fmt"

func main() {
	name, age, active := "Ali", 24, true

	fmt.Println(name, age, active)
}
```

Three new variables are created here:

```text
name   → "Ali"
age    → 24
active → true
```

The values are given to the names on the left in order.

Go determines the type of each variable separately:

```text
name   → string
age    → int
active → bool
```

So the variables in one short declaration do not have to be of the same type.

Output:

```text
Ali 24 true
```

The main rule in this example: `:=` can declare several new variables at the same time.

### 3. The zero value of a variable

This example shows what value variables get when they are not given an initial value.

```go
package main

import "fmt"

func main() {
	var num int
	var text string
	var active bool

	fmt.Printf("num=%d, text=%q, active=%t\n", num, text, active)
}
```

We did not give values to these variables:

```go
var num int
var text string
var active bool
```

Go automatically gives them their zero values.

Step by step:

```text
int    → 0
string → ""
bool   → false
```

That is why the output is:

```text
num=0, text="", active=false
```

The main rule in this example: a variable declared with `var` does not stay without an initial value. It gets the zero value of its type.

### 4. Updating an existing variable in a short declaration

`:=` does not require all names to be new.

If there is at least one new variable on the left side, an existing variable in the same scope can be used alongside it.

For example:

```go
package main

import "fmt"

func main() {
	num := 8

	num, square := num+1, num*num

	fmt.Println(num, square)
}
```

The first line:

```go
num := 8
```

creates `num`.

Then we come to the line:

```go
num, square := num+1, num*num
```

On the left side:

* `num` is an existing variable;
* `square` is a new variable.

Because there is a new `square`, `:=` can be used.

The important point: the expressions on the right side are evaluated before the assignment happens.

The old value of `num`:

```text
8
```

So:

```text
num + 1 = 8 + 1 = 9
num * num = 8 * 8 = 64
```

Then the values are written:

```text
num    ← 9
square ← 64
```

Output:

```text
9 64
```

The calculation of `square` uses the old `num = 8`, not the new `num = 9`.

The main rule in this example: in a multiple assignment the expressions on the right are evaluated first, and then written to the variables on the left.

### 5. The scope of a variable

This example shows that an inner block can create a new variable with the same name as an outer one.

```go
package main

import "fmt"

func main() {
	message := "outer"

	{
		message := "inner"
		fmt.Println(message)
	}

	fmt.Println(message)
}
```

First, in the outer block:

```go
message := "outer"
```

is created.

Then an inner block opens:

```go
{
	message := "inner"
	fmt.Println(message)
}
```

The inner:

```go
message := "inner"
```

does not change the outer `message`.

It creates another, new variable for this inner block.

Inside the inner block, the `message` from the nearest scope is used:

```text
inner
```

When the block ends, the inner `message` goes out of scope.

After that, the outer:

```go
message := "outer"
```

is visible again.

Output:

```text
inner
outer
```

This is called **shadowing**.

Shadowing can sometimes be useful, but when it happens by accident it can lead to bugs. The programmer may think they are updating the outer variable while actually creating a new inner one.

### 6. A package-level variable

A variable can be declared not only inside a function but also at package level.

For example:

```go
package main

import "fmt"

var visits int

func main() {
	visits++
	visits++

	fmt.Println(visits)
}
```

Here:

```go
var visits int
```

is not inside any function.

It is declared at package level.

Because no initial value is given:

```text
visits = 0
```

Then:

```go
visits++
```

increases the value by one:

```text
0 → 1
```

After running:

```go
visits++
```

once more:

```text
1 → 2
```

Output:

```text
2
```

A package-level name is visible from the functions in that package.

In this example the `main()` function can access `visits`.

But using mutable package-level variables more than necessary can make code harder to understand and test, because several functions may end up changing the value.

### 7. Declaring with an explicit type

Sometimes a variable's value is assigned later.

In that case you can state the type in advance:

```go
package main

import "fmt"

func main() {
	var distance float64

	distance = 12

	fmt.Printf("%.1f km\n", distance)
}
```

First:

```go
var distance float64
```

is declared.

Because no initial value is given, the `float64` zero value is:

```text
0
```

Then:

```go
distance = 12
```

runs.

Here `12` is an untyped integer constant. Because its value can be represented as a `float64`, it is converted to the `float64` variable in the assignment.

As a result, the value in `distance` is stored as a `float64`.

The following in `Printf()`:

```text
%.1f
```

prints the number with one digit after the decimal point.

Output:

```text
12.0 km
```

The main rule in this example: if a variable's type was set at declaration, later assignments must match that type.

### 8. Grouped declarations

Related variables can be grouped inside a `var` block.

For example:

```go
package main

import "fmt"

func main() {
	var (
		product  = "book"
		quantity = 3
		price    = 25000
	)

	fmt.Println(product, quantity*price)
}
```

This syntax:

```go
var (
	...
)
```

lets you write several `var` declarations in one block.

The values:

```text
product  → "book"
quantity → 3
price    → 25000
```

Then:

```go
quantity * price
```

is calculated:

```text
3 * 25000 = 75000
```

Output:

```text
book 75000
```

A grouped declaration can make reading easier, especially when showing settings for one task or closely related values in one place.

But you don't have to gather unrelated variables into one block just to make the syntax shorter.

### 9. Evaluating a constant expression

A constant's value can also be defined by an expression made of other constants.

For example:

```go
package main

import "fmt"

const (
	second = 1
	minute = 60 * second
	hour   = 60 * minute
)

func main() {
	fmt.Println(hour)
}
```

Now let's see step by step how the values are produced.

First:

```text
second = 1
```

Then:

```go
minute = 60 * second
```

is calculated:

```text
60 * 1 = 60
```

So:

```text
minute = 60
```

Then:

```go
hour = 60 * minute
```

is calculated:

```text
60 * 60 = 3600
```

So:

```text
hour = 3600
```

Output:

```text
3600
```

These calculations do not have to be repeated at runtime each time. Because the expressions are made of constants, their values can be determined at compile time.

Named constants like these reduce the need to write numbers with unclear meaning directly in the code.

For example, instead of:

```go
timeout := 3600
```

depending on the context:

```go
timeout := hour
```

can show the meaning of the code more clearly.
