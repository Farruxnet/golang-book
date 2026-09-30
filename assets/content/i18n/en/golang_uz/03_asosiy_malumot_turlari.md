# Basic data types in Go

A data type defines what a value represents and which operations can be performed on it.

For example:

* `int` represents whole numbers;
* `string` represents text;
* `bool` represents a logical state in the form of `true` or `false`.

Imagine a program needs to store a user's name, age and whether they are logged in. These values serve different purposes. That is why their types are different too:

```go
package main

import "fmt"

func main() {
    name := "Ali"      // string
    age := 25          // int
    loggedIn := true   // bool

    fmt.Println(name, age, loggedIn)
}
```

Output:

```text
Ali 25 true
```

Here:

* `name` is text, so its type is `string`;
* `age` is a whole number, so its type is `int`;
* `loggedIn` is a yes-or-no state, so its type is `bool`.

Types define not only how a value is stored, but also which operations can be performed on it.

For example, you can do arithmetic with `age`:

```go
age := 25
nextAge := age + 1
```

`name`, on the other hand, is used as text:

```go
name := "Ali"
message := "Hello, " + name
```

And a `bool` value like `loggedIn` is useful for checking a condition:

```go
if loggedIn {
    // the user is logged in
}
```

## Why do we need data types?

Go is a statically typed programming language. This means the type of every variable is known while the code is being compiled.

This feature helps the compiler catch many wrong operations before the program runs.

For example, a variable created to store a whole number cannot later be given a text value:

```go
var age int = 25

// age = "twenty-five"
// a string value cannot be assigned to an int variable
```

The `age` variable is declared as `int`. So trying to give it a `string` value like `"twenty-five"` causes a compile-time error.

In many cases Go can also work out the type by itself from the initial value:

```go
name := "Ali" // string
age := 25     // int
price := 19.5 // float64
```

We did not write the type names by hand here. But the variables still have exact types:

* `name` is a `string` because `"Ali"` is a text literal;
* `age` is an `int` because `25` is an integer literal;
* `price` is a `float64` because `19.5` is a floating-point literal.

So using `:=` does not mean the variable has no type. The compiler infers the type from the initial value.

You can see a variable's type with the `%T` formatting verb:

```go
package main

import "fmt"

func main() {
    value := 97
    fmt.Printf("Value: %v, type: %T\n", value, value)
}
```

Output:

```text
Value: 97, type: int
```

Here:

* `%v` prints the value in its default form;
* `%T` prints the value's Go type.

This is especially handy for checking which type Go chose automatically.

## Integers

Integers have no fractional part.

For example:

```text
-12
0
25
```

In everyday calculations the `int` type is used most often:

```go
var age int = 25
var temperature int = -5
var studentCount = 30
```

In the last line the type is not written:

```go
var studentCount = 30
```

Go infers this variable as `int` from its initial value.

The `int` type is 32 or 64 bits wide depending on the platform architecture. In practice, `int` is usually chosen for ordinary calculations, ages, product counts, indexes and counters.

### Signed integers of an exact size

Sometimes the exact number of bits in a type matters. In that case you can use the `int8`, `int16`, `int32` and `int64` types.

These are **signed** types. So along with positive numbers, they can also hold negative numbers and zero.

| Type    |   Size |                                                       Value range |
| ------- | -----: | ----------------------------------------------------------------: |
| `int8`  |  8 bit |                                                   -128 to 127     |
| `int16` | 16 bit |                                             -32 768 to 32 767     |
| `int32` | 32 bit |                             -2 147 483 648 to 2 147 483 647       |
| `int64` | 64 bit | -9 223 372 036 854 775 808 to 9 223 372 036 854 775 807           |

For example, `int8` can represent only 256 different values:

```text
-128 ... -1, 0, 1 ... 127
```

So the value `128` does not fit in the `int8` range.

### Unsigned integers

Go also has unsigned integer types.

They do not hold negative values:

| Type     |   Size |                          Value range |
| -------- | -----: | -----------------------------------: |
| `uint8`  |  8 bit |                             0 to 255 |
| `uint16` | 16 bit |                          0 to 65 535 |
| `uint32` | 32 bit |                   0 to 4 294 967 295 |
| `uint64` | 64 bit |      0 to 18 446 744 073 709 551 615 |

For example, `uint8` has the range:

```text
0 ... 255
```

Like `int`, the `uint` type is 32 or 64 bits depending on the platform architecture.

For ordinary calculations `int` is usually more convenient. The reason is that Go does not mix different number types automatically.

For example, an `int` value and a `uint` value cannot be added directly:

```go
var a int = 10
var b uint = 20

// total := a + b // compile-time error
```

In this case one of the types must be converted explicitly.

**Warning**

Going outside the range of values a type can hold is called `overflow`.

```
If a type that is too small is chosen for a number, the value may not fit in it. That is why it is important to choose a type with the largest and smallest possible values of the data in mind.
```

For example:

```go
package main

import "fmt"

func main() {
    var num int8 = 128
    fmt.Println(num)
}
```

This code does not compile. The reason is that the largest value for `int8` is `127`, but we are giving it `128`.

The output will look roughly like this:

```text
.\main.go:6:17: cannot use 128 (untyped int constant)
as int8 value in variable declaration (overflows)
```

The compiler catches this error before the program runs.

Here `128` is a constant that is not yet tied to a specific integer type. But when it is asked to be placed into an `int8` variable, the compiler checks the value range and sees that it does not fit.

## Floating-point numbers

For numbers with a fractional part, Go uses the `float32` and `float64` types:

```go
var temperature float64 = 36.6
var distance float32 = 12.5
```

One of their main differences is precision and memory size:

| Type      |   Size | Approximate precision |
| --------- | -----: | --------------------: |
| `float32` | 32 bit |      6–7 decimal digits |
| `float64` | 64 bit |    15–16 decimal digits |

When Go infers the type of a floating-point literal automatically, it usually chooses `float64`:

```go
price := 12.5
```

Here the type of `price` is `float64`.

That is why `float64` is more common in general calculations.

For example:

```go
package main

import "fmt"

func main() {
    price := 12.5
    quantity := 3.0
    total := price * quantity

    fmt.Printf("Total: %.2f\n", total)
}
```

The calculation goes like this:

```text
price    = 12.5
quantity = 3.0

12.5 × 3.0 = 37.5
```

Output:

```text
Total: 37.50
```

The `%.2f` formatting verb prints a floating-point number with two digits after the decimal point.

Even though the value itself is `37.5`, it is printed to the screen as:

```text
37.50
```

**Info**

`float32` and `float64` cannot store some decimal fractions exactly in binary format.

```
For example, a value like `0.1` may be stored internally as a number very close to it. In most ordinary calculations this problem is not noticeable, but when working with money, small rounding errors can matter.

When storing money values, it is often convenient to use the smallest currency unit. For example, the value `12.50` can be stored as a whole number like `1250`. In this case the calculations are done with integer values.
```

## The logical type: `bool`

`bool` holds only one of two values:

```text
true
false
```

This type is used to represent yes-or-no states.

For example:

```go
var active bool = true
var blocked bool = false
```

Here:

* `active` is `true`, meaning the user is active;
* `blocked` is `false`, meaning the user is not blocked.

The result of comparison operators is also of type `bool`.

For example:

```go
package main

import "fmt"

func main() {
    age := 20
    isAdult := age >= 18

    fmt.Println("Is adult?", isAdult)
}
```

The following comparison is performed here:

```go
age >= 18
```

If we substitute the values:

```text
20 >= 18
```

This condition is true. Therefore:

```go
isAdult := true
```

Output:

```text
Is adult? true
```

In later lessons we will use `bool` values a lot with conditional statements such as `if`.

## The text type: `string`

`string` is used to store text.

Technically, a `string` is a sequence of bytes. Usually these bytes represent text in UTF-8 format.

A string literal is written in double quotes:

```go
name := "Dilshod"
message := "Let's learn Go"
empty := ""
```

Here:

* `"Dilshod"` is ordinary text;
* `"Let's learn Go"` is another piece of text;
* `""` is an empty string of length zero.

Two pieces of text can be joined with the `+` operator:

```go
package main

import "fmt"

func main() {
    name := "Dilshod"
    message := "Hello, " + name + "!"

    fmt.Println(message)
}
```

The joining process looks like this:

```text
"Hello, " + "Dilshod" + "!"
```

The result is a new string:

```text
Hello, Dilshod!
```

Go source code is usually written in UTF-8. Strings store sequences of bytes. When working with UTF-8 text, you can store letters of any alphabet, emoji and other Unicode characters.

But there is an important subtlety here: one visible Unicode character is not always one byte.

That is why, when working with a `string`, the **number of bytes** and the **number of Unicode code points** can differ.

### `byte` and `rune`

When working with text in Go, we often come across the `byte` and `rune` types.

`byte` is another name for the `uint8` type:

```go
type byte = uint8
```

It is often used to represent a single byte value.

For example:

```go
var value byte = 65
```

`rune` is another name for the `int32` type:

```go
type rune = int32
```

It is usually used to represent a single Unicode code point.

A rune literal is written in single quotes:

```go
var letter rune = 'O'
var specialLetter rune = '‘'
```

Here `"O"` would be a string. `'O'` is a single rune literal.

If we get the length of a `string` with `len()`, it returns the number of bytes, not the number of Unicode characters.

For example:

```go
package main

import "fmt"

func main() {
    text := "Go😊"

    fmt.Println("Bytes:", len(text))
    fmt.Println("Characters:", len([]rune(text)))
}
```

Output:

```text
Bytes: 6
Characters: 3
```

Why did `len(text)` print `6`?

The text:

```text
Go😊
```

consists of three visible characters:

```text
G
o
😊
```

But in UTF-8 their byte sizes are not the same:

```text
G   -> 1 byte
o   -> 1 byte
😊  -> 4 bytes
```

In total:

```text
1 + 1 + 4 = 6 bytes
```

That is why the result of:

```go
len(text)
```

is:

```text
6
```

The following expression:

```go
[]rune(text)
```

converts the string into a sequence of Unicode code points.

The result is three runes:

```text
'G'
'o'
'😊'
```

That is why the result of:

```go
len([]rune(text))
```

is `3`.

This difference matters when indexing Unicode text and calculating its length. We will look at working with `byte`, `rune` and UTF-8 in detail in later lessons.

## Complex numbers

Go also has separate types for complex numbers:

```text
complex64
complex128
```

A complex number consists of two parts:

* a real part;
* an imaginary part.

For example:

```go
var z complex128 = complex(2, 3)
```

In mathematical notation this value means:

```text
2 + 3i
```

The `complex()` function takes two values and creates a complex number:

```go
complex(2, 3)
```

Here:

```text
2 -> real part
3 -> imaginary part
```

Complex numbers are used in scientific, mathematical and engineering calculations.

They are rare in ordinary web applications, CLI programs or everyday business logic. So for now it is enough to know that they exist and what they are for.

## Converting types

Go does not automatically convert number types into one another.

For example, `int` and `float64` are separate types. To use them in one arithmetic expression, we must explicitly convert the value we need.

Example:

```go
package main

import "fmt"

func main() {
    var pieces int = 5
    var price float64 = 12.5

    total := float64(pieces) * price
    fmt.Println(total)
}
```

Here:

```go
pieces
```

is of type `int`.

And `price` is of type:

```go
float64
```

You cannot write:

```go
// total := pieces * price
```

The reason is that values of types `int` and `float64` cannot be multiplied directly.

So we write:

```go
float64(pieces)
```

to convert the value of `pieces` to `float64` for the calculation.

The calculation:

```text
pieces = 5
float64(pieces) = 5.0

5.0 × 12.5 = 62.5
```

The important point is that a conversion does not change the type of the original variable.

That is:

```go
pieces
```

is still an `int`.

Only the expression:

```go
float64(pieces)
```

produces a new `float64` value.

You can also convert a floating-point number to an integer:

```go
fraction := 9.8
num := int(fraction)
```

The result is:

```text
num = 9
```

This is **not rounding**.

When a `float64` value is converted to `int`, the fractional part is dropped and the value is truncated toward zero.

For example:

```text
9.8  -> 9
9.2  -> 9
-9.8 -> -9
-9.2 -> -9
```

So the result of `int(9.8)` is not `10`.

If real rounding is needed, other methods are used for it.

**Warning**

Converting a large number to a type with a smaller range as a runtime value can change the result.

For example:

```go
value := 300
small := uint8(value)
```

`uint8` holds only the range:

```text
0 ... 255
```

`300` does not fit in this range. After the conversion the high bits are dropped and the result is:

```text
44
```

You can picture it like this:

```text
300 = 256 + 44
```

Since `uint8` can hold only the lowest 8 bits, `44` remains.

But the rule is different for constants.

For example:

```go
// var x = uint8(300)
```

does not compile. The reason is that the compiler can see in advance that the constant value does not fit in the `uint8` range.

That is why, before converting a runtime value to a smaller type, it is important to check that it fits in the range of the new type.

Converting a number to text or text to a number is different from conversion between ordinary number types.

For example, for:

```text
"123" -> 123
```

the `strconv` package is usually used.

We will look at this topic in detail in later lessons, when we work with packages and input.

## Zero values

In Go, a variable without an initial value does not get a random value.

It automatically gets the **zero value** of its type.

The zero values for the basic types are:

| Type                            | Zero value |
| ------------------------------- | ---------- |
| integers and floating-point numbers | `0`    |
| complex numbers                 | `0+0i`     |
| `bool`                          | `false`    |
| `string`                        | `""`       |

For example:

```go
package main

import "fmt"

func main() {
    var num int
    var price float64
    var active bool
    var message string

    fmt.Printf("num=%d, price=%.1f, active=%t, message=%q\n", num, price, active, message)
}
```

We did not give an initial value to any of these variables:

```go
var num int
var price float64
var active bool
var message string
```

Nevertheless, they have definite values:

```text
num     -> 0
price   -> 0.0
active  -> false
message -> ""
```

Output:

```text
num=0, price=0.0, active=false, message=""
```

This is one of Go's important features.

For example, if we write:

```go
var active bool
```

`active` is automatically `false`.

Or if we write:

```go
var message string
```

`message` is not `nil`, but an empty string:

```go
""
```

The idea of the zero value will also matter in later topics, when we work with structs, pointers, slices, maps and interfaces.

## Which type should you choose?

When you are just starting out, these simple rules are enough:

* `int` for a whole number;
* `float64` for a fractional number;
* `string` for text;
* `bool` for a yes-or-no state;
* `rune` for a single Unicode code point.

For example:

```go
age := 25             // int
price := 19.99        // float64
name := "Ali"         // string
active := true        // bool
symbol := 'A'         // rune
```

Types of an exact size such as `int32`, `uint16` or `float32` are best chosen when there is a real need for them.

For example:

* when working with a binary format;
* when a network protocol requires an exact bit size;
* when a field's size is strictly defined in a file format;
* when an exact type match is needed with an external API or a database column.

Arrays, slices, maps, structs, pointers, functions, interfaces and channels are also types in Go.

They do more complex jobs than a simple `int` or `string`. For example:

* a slice stores a sequence of values;
* a map stores associations between keys and values;
* a struct combines several fields into one value;
* a pointer refers to the address of another value in memory;
* a function can itself be a value;
* an interface describes what behavior a type has;
* a channel is used to pass values between goroutines.

We will look at them separately in later parts.

**Info**

`nil` is not a separate data type.

```
It is a special value used by some types, such as pointers, slices, maps, channels, functions and interfaces, to indicate that there is no value or object.
```

## Examples

### 1. The limits of an integer type

This example shows which range of numbers the `int8` type can hold.

The `math` package has constants for the minimum and maximum values of some number types:

```go
package main

import (
    "fmt"
    "math"
)

func main() {
    fmt.Println(math.MinInt8, math.MaxInt8)
}
```

Output:

```text
-128 127
```

So the `int8` type holds values in the range:

```text
-128 ... 127
```

For example:

```go
var a int8 = -128
var b int8 = 127
```

is correct.

But:

```go
// var c int8 = 128
```

is an error.

If larger or smaller values are needed, `int16`, `int32`, `int64` or another type suited to the task is chosen.

This example shows that you should take a number type's capacity into account when choosing it.

### 2. An unsigned integer

This example shows storing a small value that cannot be negative in the `uint8` type:

```go
package main

import "fmt"

func main() {
    var red uint8 = 255
    fmt.Println(red)
}
```

Output:

```text
255
```

Because the range of `uint8` is:

```text
0 ... 255
```

`255` fits in this type.

For example:

```go
var red uint8 = 255
```

can look natural for representing a color channel in the RGB color model, because color components usually range from `0` to `255`.

But a negative value cannot be given directly as a constant:

```go
// var red uint8 = -1
```

This causes a compile-time error.

This example shows the main difference between signed and unsigned integer types.

### 3. Type conversion

This example shows that Go does not mix number types implicitly:

```go
package main

import "fmt"

func main() {
    count := 3
    price := 12.5

    total := float64(count) * price
    fmt.Println(total)
}
```

Here:

```go
count := 3
```

is of type `int`.

```go
price := 12.5
```

is of type `float64`.

So with:

```go
float64(count)
```

we convert the value of `count` to `float64` for the calculation.

Then:

```text
3.0 × 12.5 = 37.5
```

Output:

```text
37.5
```

If the conversion is not written:

```go
// total := count * price
```

the compiler reports that `int` and `float64` do not match.

This example shows that in Go, conversion between number types must be written explicitly.

### 4. The fractional part when converting to an integer

This example shows what happens when a `float64` value is converted to `int`:

```go
package main

import "fmt"

func main() {
    positive, negative := 8.9, -8.9
    fmt.Println(int(positive), int(negative))
}
```

Output:

```text
8 -8
```

Here:

```text
8.9  -> 8
-8.9 -> -8
```

The fractional part was dropped.

The important point: this is not mathematical rounding.

For example:

```text
8.9
```

rounded to the nearest whole number would be `9`.

But the result of:

```go
int(8.9)
```

is `8`.

For a negative value the number is also truncated toward zero:

```go
int(-8.9)
```

gives:

```text
-8
```

This example shows the behavior of converting a floating-point number to an integer type.

### 5. Storing a character in a `byte`

This example shows that `byte` is really another name for `uint8`:

```go
package main

import "fmt"

func main() {
    var char byte = 'G'
    fmt.Printf("%d %c %T\n", char, char, char)
}
```

Output:

```text
71 G uint8
```

Here `'G'` is a rune literal.

In the Unicode and ASCII tables, `G` has the decimal value:

```text
71
```

Because it fits in a `byte`, you can write:

```go
var char byte = 'G'
```

Looking at the formatting verbs:

```text
%d -> as a number
%c -> as a character
%T -> the type
```

That is why the same value is printed in three different forms:

```text
71
G
uint8
```

`byte` is an alias for the `uint8` type. That is why `%T` shows `uint8` in the output.

This type is common when working with binary data, files, network data or the individual bytes of a UTF-8 string.

### 6. A Unicode character with `rune`

This example shows storing a single Unicode code point as a `rune`:

```go
package main

import "fmt"

func main() {
    char := '‘'
    fmt.Printf("%c %U %T\n", char, char, char)
}
```

The value of `char` is written in single quotes:

```go
'‘'
```

So it is not a string but a rune literal.

And `rune` is an alias for the `int32` type.

What the formatting verbs do:

```text
%c -> the character itself
%U -> the Unicode code point
%T -> the Go type
```

So the output will look roughly like this:

```text
‘ U+2018 int32
```

Here:

```text
U+2018
```

is the Unicode code point of the left single quotation mark.

This example shows that `rune` is suitable not only for ASCII characters but for working with any Unicode characters.

### 7. A floating-point number in scientific notation

Very large or very small floating-point values can be written in scientific notation:

```go
package main

import "fmt"

func main() {
    speedOfLight := 3e8
    smallValue := 1.5e-3

    fmt.Println(speedOfLight, smallValue)
}
```

The `e` notation means a power of 10.

For example:

```text
3e8
```

means:

```text
3 × 10⁸
```

that is:

```text
300000000
```

And `1.5e-3` means:

```text
1.5 × 10⁻³
```

that is:

```text
0.0015
```

Because the type is not written, both values are usually inferred as `float64`:

```go
speedOfLight := 3e8
smallValue := 1.5e-3
```

In scientific calculations this notation helps show very large or very small numbers much more compactly.

### 8. Raw string literals

In Go a string can be written not only with double quotes but also with backquotes.

Such a string is called a **raw string literal**:

```go
package main

import "fmt"

func main() {
    path := `C:\Users\Ali\main.go`
    fmt.Println(path)
}
```

Output:

```text
C:\Users\Ali\main.go
```

In an ordinary string, the `\` character can mark the start of an escape sequence.

For example:

```go
"message\nnext line"
```

Here `\n` means a new line.

Inside a raw string, `\` is kept as is:

```go
`C:\Users\Ali\main.go`
```

That is why raw strings can be convenient for Windows file paths or text that uses many backslashes.

Raw strings are also used for multi-line text:

```go
text := `first line
second line
third line`
```

This example shows that there are two ways to write a string literal.

### 9. A complex number

This example shows creating a complex number in Go and getting its parts separately:

```go
package main

import "fmt"

func main() {
    z := complex(3.0, 4.0)

    fmt.Println(z, real(z), imag(z))
}
```

The following call:

```go
complex(3.0, 4.0)
```

creates the complex number:

```text
3 + 4i
```

Here:

```text
3 -> real part
4 -> imaginary part
```

`real()` gets the real part:

```go
real(z)
```

result:

```text
3
```

`imag()` gets the imaginary part:

```go
imag(z)
```

result:

```text
4
```

The output usually looks like this:

```text
(3+4i) 3 4
```

This example shows the main job of the `complex()`, `real()` and `imag()` functions.

### 10. Seeing the type through formatting

This example shows that values that look alike can have different types:

```go
package main

import "fmt"

func main() {
    whole := 26
    fraction := 26.5
    text := "26.5"

    fmt.Printf("%T %T %T\n", whole, fraction, text)
}
```

Here:

```go
whole := 26
```

is an `int`.

```go
fraction := 26.5
```

is a `float64`.

```go
text := "26.5"
```

is a `string`.

`26.5` and `"26.5"` look similar, but to Go they are completely different values.

The first is a number:

```go
26.5
```

The second is a sequence of characters:

```go
"26.5"
```

If we look at their types with `%T`:

```text
int float64 string
```

is printed.

This example shows that how a value looks on screen and its type in Go are not the same thing.
