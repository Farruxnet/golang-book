# Operators in Go

An operator is a symbol or group of symbols that performs a specific operation on values.

For example:

* `+` adds two numbers;
* `==` checks whether two values are equal or not;
* `&&` combines several logical conditions.

The values an operator works on are called **operands**.

For example:

```go
a + b
```

In this expression:

* `+` is the operator;
* `a` is the first operand;
* `b` is the second operand.

In Go, operators are used for many tasks, such as arithmetic, comparing values, checking conditions, working with bits and updating the values of variables.

## Arithmetic operators

Arithmetic operators perform mathematical operations on numbers.

| Operator | Operation      | Example  | Result |
| -------- | -------------- | -------- | -----: |
| `+`      | addition       | `10 + 3` |   `13` |
| `-`      | subtraction    | `10 - 3` |    `7` |
| `*`      | multiplication | `10 * 3` |   `30` |
| `/`      | division       | `10 / 3` |    `3` |
| `%`      | remainder      | `10 % 3` |    `1` |

The following program shows all the basic arithmetic operators:

```go
package main

import "fmt"

func main() {
    a := 10
    b := 3

    fmt.Println("Addition:", a+b)
    fmt.Println("Subtraction:", a-b)
    fmt.Println("Multiplication:", a*b)
    fmt.Println("Division:", a/b)
    fmt.Println("Remainder:", a%b)
}
```

Output:

```text
Addition: 13
Subtraction: 7
Multiplication: 30
Division: 3
Remainder: 1
```

Here `a` and `b` are both integers of type `int`.

That is why the expression:

```go
a / b
```

is also performed as integer division.

Even though `10 / 3` is `3.333...` mathematically, Go keeps only the whole part here. The result is `3`.

### Dividing integers and floating-point numbers

In Go, the type of a division result depends on the types of the operands.

If both operands are integers, the result is an integer too. The fractional part is dropped:

```go
result := 10 / 3 // 3
```

This calculation works like this:

```text
10 / 3 = 3.333...
```

But because both operands are `int`, the fractional part is not kept:

```text
result = 3
```

If you need a fractional result, the operands must be converted to a floating-point type such as `float32` or `float64`.

For example:

```go
package main

import "fmt"

func main() {
    total := 10
    people := 3
    perPerson := float64(total) / float64(people)

    fmt.Printf("Per person: %.2f\n", perPerson)
}
```

Output:

```text
Per person: 3.33
```

Here:

```go
float64(total)
```

converts the value of `total` from `int` to `float64`.

Likewise:

```go
float64(people)
```

converts the value of `people` to `float64`.

After that the calculation is performed as:

```text
10.0 / 3.0
```

and the fractional part is kept.

In `fmt.Printf`:

```go
%.2f
```

prints the result with two digits after the decimal point.

**Warning**

You cannot divide by zero.

````
Dividing an integer by `0` causes an error at runtime.

For example, the following code is dangerous:

```go
divisor := 0
result := 10 / divisor
```

Because the value of `divisor` is `0` at runtime, the program panics while it runs.
````

### The remainder operator

The `%` operator returns the remainder left after division.

For example:

```go
17 % 5
```

Let's go through the calculation step by step:

```text
17 / 5 = 3
3 * 5 = 15
17 - 15 = 2
```

So:

```text
17 % 5 = 2
```

The remainder operator is useful in many places.

For example:

* checking whether a number is even or odd;
* splitting time into hours, minutes and seconds;
* periodic calculations;
* cycling through indexes.

An important point: in Go, `%` works with integers.

## Incrementing and decrementing by one

The `++` operator increases a value by one.

The `--` operator decreases a value by one.

For example:

```go
package main

import "fmt"

func main() {
    count := 5
    count++
    fmt.Println(count)

    count--
    fmt.Println(count)
}
```

Output:

```text
6
5
```

At the start of the program:

```text
count = 5
```

Then:

```go
count++
```

runs:

```text
count = 6
```

Next:

```go
count--
```

runs:

```text
count = 5
```

Unlike in some other programming languages, these operators are not expressions.

In Go, `count++` and `count--` are separate statements.

That is why they cannot be placed inside another expression:

```go
// result := count++ // compilation error
```

For example, the form:

```text
x = y++
```

which you may see in C or JavaScript, does not exist in Go.

This rule makes code clearer. When a value is incremented or decremented is clearly visible on its own line.

## Assignment operators

The `=` operator assigns the value on the right to the existing variable on the left.

For example:

```go
num := 10
num = 20
```

On the first line:

```go
num := 10
```

a new variable `num` is created and given the value `10`.

On the second line:

```go
num = 20
```

no new variable is created. The value of the existing `num` variable is changed to `20`.

In Go, an arithmetic operation and an assignment can be written with one short operator:

| Short form  | Full form       |
| ----------- | --------------- |
| `num += 5`  | `num = num + 5` |
| `num -= 5`  | `num = num - 5` |
| `num *= 5`  | `num = num * 5` |
| `num /= 5`  | `num = num / 5` |
| `num %= 5`  | `num = num % 5` |

For example:

```go
package main

import "fmt"

func main() {
    balance := 100
    balance += 50
    balance -= 20

    fmt.Println("Balance:", balance)
}
```

Output:

```text
Balance: 130
```

Let's go through the calculation step by step.

Initial value:

```text
balance = 100
```

Then:

```go
balance += 50
```

actually means:

```go
balance = balance + 50
```

Result:

```text
balance = 150
```

Then:

```go
balance -= 20
```

is the same as:

```go
balance = balance - 20
```

Result:

```text
balance = 130
```

It is important to remember the difference between `:=` and `=` here.

`:=` is usually used to declare a new local variable and give it an initial value.

`=` assigns a new value to an existing variable.

## Comparison operators

Comparison operators compare two values.

The result of a comparison is always of type `bool`:

```text
true
```

or:

```text
false
```

The main comparison operators:

| Operator | Meaning                  | Example    | Result  |
| -------- | ------------------------ | ---------- | ------- |
| `==`     | equal                    | `10 == 10` | `true`  |
| `!=`     | not equal                | `10 != 3`  | `true`  |
| `>`      | greater than             | `10 > 3`   | `true`  |
| `<`      | less than                | `10 < 3`   | `false` |
| `>=`     | greater than or equal to | `10 >= 10` | `true`  |
| `<=`     | less than or equal to    | `3 <= 10`  | `true`  |

For example:

```go
package main

import "fmt"

func main() {
    age := 20
    minAge := 18

    fmt.Println("Equal:", age == minAge)
    fmt.Println("Not equal:", age != minAge)
    fmt.Println("Allowed:", age >= minAge)
}
```

Output:

```text
Equal: false
Not equal: true
Allowed: true
```

The first comparison:

```go
age == minAge
```

is:

```text
20 == 18
```

This is false, so the result is:

```text
false
```

The second comparison:

```go
20 != 18
```

This is true:

```text
true
```

The third condition:

```go
20 >= 18
```

is also true. So the minimum age requirement is met.

**Info**

`=` and `==` are not the same operator.

````
`=` assigns a value:

```go
age = 20
```

`==` checks for equality:

```go
age == 20
```
````

## Logical operators

Logical operators work with `bool` values.

They are used to combine several conditions or to get the opposite of a condition.

| Operator | Name | When is it `true`?                        |
| -------- | ---- | ----------------------------------------- |
| `&&`     | AND  | when both conditions are `true`           |
| `\|\|`   | OR   | when at least one condition is `true`     |
| `!`      | NOT  | when the operand is `false`               |

**Info**

Ordering comparisons such as `<` or `>` are not used with `bool` values.

```
To compare `bool` values for equality, you can use the `==` and `!=` operators.
```

For example:

```go
package main

import "fmt"

func main() {
    age := 22
    hasTicket := true
    banned := false

    canEnter := age >= 18 && hasTicket && !banned
    fmt.Println("Can enter:", canEnter)
}
```

Output:

```text
Can enter: true
```

Let's split this expression into separate parts:

```go
age >= 18
```

Result:

```text
22 >= 18
true
```

The next value:

```go
hasTicket
```

already has the value:

```text
true
```

Then:

```go
!banned
```

The value of `banned` is:

```text
false
```

The `!` operator flips it to the opposite:

```text
!false = true
```

So the whole expression becomes:

```text
true && true && true
```

Result:

```text
true
```

So the user is old enough, has a ticket and is not banned from entering.

**Truth table:**

| `a`     | `b`     | `a && b` | `a \|\| b` |
| ------- | ------- | -------- | ---------- |
| `false` | `false` | `false`  | `false`    |
| `false` | `true`  | `false`  | `true`     |
| `true`  | `false` | `false`  | `true`     |
| `true`  | `true`  | `true`   | `true`     |

With the `&&` operator, both sides must be `true`.

For example:

```text
true && false = false
```

With the `||` operator, it is enough for at least one side to be `true`:

```text
true || false = true
```

The `!` operator flips a value to its opposite:

```text
!true  = false
!false = true
```

### Short-circuit evaluation

The `&&` and `||` operators do not always evaluate all their operands.

If the result is already known, Go does not check the rest of the expression.

This is called **short-circuit evaluation**.

For example:

```go
divisor := 0
safe := divisor != 0 && 10/divisor > 1
```

Let's go through this expression step by step.

The first condition:

```go
divisor != 0
```

The value of `divisor` is `0`, so:

```text
0 != 0
false
```

For the result of `&&` to be `true`, both sides must be `true`.

The first side is already `false`.

So the overall result is definitely `false`.

That is why Go does not evaluate the second part:

```go
10 / divisor > 1
```

If this part had run:

```go
10 / 0
```

a division by zero would have happened.

But thanks to short-circuiting, this calculation is not performed at all.

A similar rule works for the `||` operator.

For example:

```go
ready := true || expensiveCheck()
```

Because the first operand is `true`, the overall result is already `true`.

So `expensiveCheck()` is not called.

## Bitwise operators

Bitwise operators work on the binary representation of integers.

For example, the decimal number:

```text
6
```

in binary is:

```text
110
```

Bitwise operators can come up in tasks like these:

* storing several permissions in one value;
* working with bit flags and bitmasks;
* processing protocols or file formats;
* low-level calculations;
* turning specific bits on or off.

The main bitwise operators:

| Operator | Operation                                                    |
| -------- | ------------------------------------------------------------ |
| `&`      | bitwise AND                                                  |
| `\|`     | bitwise OR                                                   |
| `^`      | bitwise XOR, or bitwise NOT when used as a unary operator    |
| `&^`     | bit clear — AND NOT                                          |
| `<<`     | left shift                                                   |
| `>>`     | right shift                                                  |

Example:

```go
package main

import "fmt"

func main() {
    a := 6 // binary: 110
    b := 3 // binary: 011

    fmt.Println(a & b)  // 010, i.e. 2
    fmt.Println(a | b)  // 111, i.e. 7
    fmt.Println(a ^ b)  // 101, i.e. 5
    fmt.Println(a << 1) // 1100, i.e. 12
}
```

Output:

```text
2
7
5
12
```

Now let's see how these results are produced.

`a`:

```text
6 = 110
```

`b`:

```text
3 = 011
```

For convenience, we write them with the same length:

```text
a = 110
b = 011
```

### `&` — bitwise AND

```text
110
011
---
010
```

Each pair of bits is checked.

A `1` remains in the result only if both bits are `1`.

```text
1 & 0 = 0
1 & 1 = 1
0 & 1 = 0
```

Result:

```text
010 = 2
```

### `|` — bitwise OR

```text
110
011
---
111
```

If at least one of them is `1`, the result bit is `1`.

Result:

```text
111 = 7
```

### `^` — XOR

With the binary `^` operator, bits that differ give `1` and bits that are the same give `0`:

```text
110
011
---
101
```

Result:

```text
101 = 5
```

When `^` is applied to a single integer as a unary operator, it flips all its bits. The result then depends on the bit width of the type.

### `<<` — left shift

The following expression:

```go
a << 1
```

shifts the bits of `a` one position to the left.

Initial value:

```text
110
```

One bit to the left:

```text
1100
```

In decimal this is equal to:

```text
12
```

For now it is enough to understand the main job of these operators. In the examples below we will see how they are used in practice with bit flags.

## Operator precedence

When several operators appear in one expression, Go evaluates them in a specific order of precedence.

For example:

```go
first := 2 + 3*4
```

This expression looks like:

```text
2 + 3 * 4
```

The `*` operator has higher precedence than `+`.

So first:

```text
3 * 4 = 12
```

is calculated.

Then:

```text
2 + 12 = 14
```

Result:

```text
14
```

If we use parentheses:

```go
second := (2 + 3) * 4
```

the expression inside the parentheses is evaluated first:

```text
2 + 3 = 5
```

Then:

```text
5 * 4 = 20
```

Result:

```text
20
```

The simplified order of precedence, from highest to lowest, is:

1. `*`, `/`, `%`, `<<`, `>>`, `&`, `&^`;
2. `+`, `-`, `|`, `^`;
3. `==`, `!=`, `<`, `<=`, `>`, `>=`;
4. `&&`;
5. `||`.

Operators in the same group have the same precedence.

When an expression gets complicated, you don't have to rely on operator precedence alone.

Using parentheses often shows the intent of the code more clearly.

For example:

```go
price - price*discount/100
```

may be technically correct.

But:

```go
price - (price*discount)/100
```

shows the reader more clearly how the calculation is grouped.

In the next part we will use operators to perform simple mathematical calculations.

## Examples

### 1. Checking whether a number is even or odd

This example shows how to check whether a number is even or odd using the `%` operator.

```go
package main

import "fmt"

func main() {
    num := 17
    fmt.Println(num%2 == 0)
}
```

`num % 2` calculates the remainder of dividing the number by `2`.

For `17`:

```text
17 % 2 = 1
```

Then:

```go
num%2 == 0
```

actually becomes:

```text
1 == 0
```

Result:

```text
false
```

If a number is even, the remainder of dividing it by `2` is `0`.

For example:

```text
18 % 2 = 0
```

That is why `% 2 == 0` is a common way to check for an even number.

### 2. Checking that a value is in a range

This example checks that a value lies between two bounds.

```go
package main

import "fmt"

func main() {
    age := 24
    workingAge := age >= 18 && age <= 60
    fmt.Println(workingAge)
}
```

Let's split the expression into two parts:

```go
age >= 18
```

and:

```go
age <= 60
```

The value of `age` is `24`.

So:

```text
24 >= 18 = true
24 <= 60 = true
```

Then `&&` does its work:

```text
true && true = true
```

Result:

```text
true
```

`&&` is used here because the age must meet both requirements at the same time.

### 3. Updating a value step by step

In this example the short forms of the assignment operators and the `--` operator are used together.

```go
package main

import "fmt"

func main() {
    num := 10
    num += 5
    num *= 2
    num--
    fmt.Println(num)
}
```

Initial value:

```text
num = 10
```

The first operation:

```go
num += 5
```

is the same as:

```text
10 + 5 = 15
```

Now:

```text
num = 15
```

Then:

```go
num *= 2
```

is the same as:

```text
15 * 2 = 30
```

Now:

```text
num = 30
```

Finally:

```go
num--
```

decreases the value by one:

```text
30 - 1 = 29
```

Result:

```text
29
```

This example shows changing a value step by step through several operations.

### 4. Short-circuit evaluation

This example shows how the short-circuit property of the `&&` operator prevents a division by zero.

```go
package main

import "fmt"

func main() {
    divisor := 0
    safe := divisor != 0 && 10/divisor > 1
    fmt.Println(safe)
}
```

First:

```go
divisor != 0
```

is checked.

The value:

```text
divisor = 0
```

So:

```text
0 != 0 = false
```

If the left side of `&&` is `false`, the whole expression is definitely `false`.

Go does not evaluate the right side:

```go
10 / divisor > 1
```

That is why the operation:

```text
10 / 0
```

is not performed and no division-by-zero error occurs.

Result:

```text
false
```

This technique is often used to check a required condition before performing a dangerous operation.

### 5. Splitting time with the remainder

This example uses the `/` and `%` operators to split a total number of seconds into hours, minutes and seconds.

```go
package main

import "fmt"

func main() {
    totalSeconds := 3672
    hours := totalSeconds / 3600
    minutes := totalSeconds % 3600 / 60
    seconds := totalSeconds % 60
    fmt.Println(hours, minutes, seconds)
}
```

Initial value:

```text
totalSeconds = 3672
```

First we find the hours:

```go
hours := totalSeconds / 3600
```

Calculation:

```text
3672 / 3600 = 1
```

So:

```text
hours = 1
```

Now we find how many seconds remain after the full hours:

```text
3672 % 3600 = 72
```

From these `72` seconds we find the minutes:

```text
72 / 60 = 1
```

So:

```text
minutes = 1
```

Finally, we find the seconds remaining after the full minutes:

```text
3672 % 60 = 12
```

So:

```text
seconds = 12
```

Result:

```text
1 1 12
```

That is:

```text
1 hour, 1 minute, 12 seconds
```

Here `/` gets the number of whole units, while `%` separates the remaining part for the next step.

### 6. Setting a flag with bits

This example shows adding a new permission to an existing value with a bit flag.

```go
package main

import "fmt"

func main() {
    const write = 1 << 1
    perm := 1
    perm |= write
    fmt.Printf("%03b\n", perm)
}
```

First:

```go
const write = 1 << 1
```

is calculated.

The binary form of `1`:

```text
001
```

We shift it one bit to the left:

```text
001 << 1 = 010
```

So:

```text
write = 2
```

Then:

```go
perm := 1
```

In binary:

```text
perm = 001
```

The following operator:

```go
perm |= write
```

actually means:

```go
perm = perm | write
```

Calculation:

```text
001
010
---
011
```

Result:

```text
011
```

`|` turns on the required bit and keeps the other bits that are already on.

That is why this operator is very convenient for adding a new permission to a set of bit flags.

### 7. Checking a flag with bits

This example checks whether a specific bit is on or not.

```go
package main

import "fmt"

func main() {
    const write = 1 << 1
    perm := 0b011
    fmt.Println(perm&write != 0)
}
```

The value of `write`:

```text
010
```

And `perm`:

```text
011
```

Now we apply the `&` operator:

```text
011
010
---
010
```

The result is not `0`:

```text
010 != 000
```

So:

```text
true
```

is printed.

The meaning of this check: is the `write` bit on in the `perm` value?

`&` keeps only the bits that are `1` in both values.

If the required bit is not present, the result is `0`.

### 8. Clearing a bit

In this example a specific flag is turned off with the `&^` operator.

```go
package main

import "fmt"

func main() {
    const write = 1 << 1
    perm := 0b111
    perm &^= write
    fmt.Printf("%03b\n", perm)
}
```

Initial value:

```text
perm = 111
```

The `write` flag:

```text
010
```

The following form:

```go
perm &^= write
```

actually means:

```go
perm = perm &^ write
```

The `&^` operator clears from the left operand the bits that are `1` in the right operand.

So:

```text
111
010
---
101
```

Result:

```text
101
```

That is, the middle bit was turned off, while the other bits stayed unchanged.

### 9. Swapping values with exclusive OR

This example shows that the `^` operator can swap the values of two integers without a temporary variable.

```go
package main

import "fmt"

func main() {
    a, b := 5, 9
    a ^= b
    b ^= a
    a ^= b
    fmt.Println(a, b)
}
```

At the start:

```text
a = 5
b = 9
```

The first operation:

```go
a ^= b
```

actually means:

```go
a = a ^ b
```

The following operations use a property of XOR to recover the old values and swap their places.

At the end:

```text
a = 9
b = 5
```

Result:

```text
9 5
```

This example shows an interesting property of the `^` operator.

But in practical Go code this technique is usually not recommended, because Go has a much clearer form:

```go
a, b = b, a
```

This version is shorter, easier to read and shows the intent of the code right away.

### 10. Clarifying precedence with parentheses

This example demonstrates operator precedence and how parentheses make the intent of a calculation clear.

```go
package main

import "fmt"

func main() {
    discounted := 100_000 - (100_000*15)/100
    fmt.Println(discounted)
}
```

Here the initial price is:

```text
100000
```

The discount:

```text
15%
```

First the discount amount is calculated:

```text
100000 * 15 = 1500000
```

Then:

```text
1500000 / 100 = 15000
```

So the discount amount is:

```text
15000
```

We subtract the discount from the base value:

```text
100000 - 15000 = 85000
```

Result:

```text
85000
```

The parentheses:

```go
(100_000 * 15)
```

show more clearly which part of the calculation should be read together.

The `_` in `100_000` only makes the number easier to read.

The following two forms have the same value:

```go
100000
```

and:

```go
100_000
```

The underscore `_` does not affect the value of the number. It makes large numbers easier to read by grouping the digits visually.
