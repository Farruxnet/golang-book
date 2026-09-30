# Math functions in Go

Simple mathematical operations such as addition, subtraction, multiplication and division can be done with Go's operators.

For example:

```go
a + b
a - b
a * b
a / b
```

But more complex calculations, such as finding a square root, raising a number to a power, computing a sine or cosine, or rounding numbers, need ready-made functions.

In Go's standard library, such functions live in the `math` package.

In this part we will look at:

* adding the `math` package to a program;
* using mathematical constants;
* calculating roots and powers;
* rounding numbers;
* trigonometric functions;
* logarithms and the exponential function;
* `NaN` and infinite values.

## Importing the `math` package

To use the functions and constants of the `math` package, you first need to `import` the package.

For example:

```go
package main

import "math"
import "fmt"

func main() {
    fmt.Println(math.Pi)
}
```

Output:

```text
3.141592653589793
```

Here `math.Pi` is the value of π that the Go standard library provides ready-made.

The important point is that `Pi` is not a function. It is a constant.

That is why you write:

```go
math.Pi
```

No parentheses are needed.

In contrast, `math.Sqrt()` and `fmt.Println()` are functions:

```go
math.Sqrt(81)
fmt.Println("Hello")
```

Parentheses are used to pass arguments to a function.

In the first example, `fmt.Println()` prints the value of `math.Pi` in its default form:

```text
3.141592653589793
```

If only two digits after the decimal point should be shown, you can use `fmt.Printf()` with the `%.2f` format:

```go
package main

import (
    "fmt"
    "math"
)

func main() {
    fmt.Printf("Pi: %.2f\n", math.Pi)
}
```

Output:

```text
Pi: 3.14
```

Here:

```text
%.2f
```

means printing a `float` number with two digits after the decimal point.

For example:

* `%.2f` — two digits;
* `%.3f` — three digits;
* `%.4f` — four digits.

There is an important distinction: formatting only changes the result shown on screen.

The value of `math.Pi` itself does not change.

For example, `math.Pi` still holds approximately:

```text
3.141592653589793
```

We are only printing it as `3.14`.

**Tip**

If you need several packages, you can write them with separate `import` statements. But Go code usually uses a single `import` block:

````
```go
import (
    "fmt"
    "math"
)
```
````

## Commonly used math functions

Most functions in the `math` package work with `float64` values.

In most cases a function:

1. takes a `float64` argument;
2. performs a calculation;
3. returns a `float64` value.

The following table lists the most commonly used functions:

| Function or constant    | Purpose                                                            |
| ----------------------- | ------------------------------------------------------------------ |
| `math.Abs(x)`           | returns the absolute value of `x`, i.e. its non-negative value     |
| `math.Sqrt(x)`          | calculates the square root of `x`                                  |
| `math.Cbrt(x)`          | calculates the cube root of `x`                                    |
| `math.Pow(x, y)`        | raises `x` to the power `y`                                        |
| `math.Pow10(n)`         | calculates 10 to the power `n`                                     |
| `math.Min(x, y)`        | returns the smaller of two numbers                                 |
| `math.Max(x, y)`        | returns the larger of two numbers                                  |
| `math.Mod(x, y)`        | calculates the remainder of division for floating-point numbers    |
| `math.Floor(x)`         | rounds down toward the nearest smaller whole value                 |
| `math.Ceil(x)`          | rounds up toward the nearest larger whole value                    |
| `math.Round(x)`         | rounds to the nearest whole value                                  |
| `math.Sin(x)`           | calculates the sine of `x` given in radians                        |
| `math.Cos(x)`           | calculates the cosine of `x` given in radians                      |
| `math.Tan(x)`           | calculates the tangent of `x` given in radians                     |
| `math.Asin(x)`          | returns the arcsine of `x` in radians                              |
| `math.Acos(x)`          | returns the arccosine of `x` in radians                            |
| `math.Atan(x)`          | returns the arctangent of `x` in radians                           |
| `math.Exp(x)`           | raises the number `e` to the power `x`                             |
| `math.Log(x)`           | calculates the natural logarithm of `x`                            |
| `math.Log10(x)`         | calculates the base-10 logarithm of `x`                            |
| `math.Hypot(x, y)`      | calculates the hypotenuse of a triangle with legs `x` and `y`      |
| `math.Pi`               | the mathematical constant π                                        |
| `math.E`                | the mathematical constant e                                        |

In the following sections we will look at the important ones among these functions with separate examples.

## Absolute value, roots and powers

The absolute value is the size of a number without regard to its sign.

For example:

```text
|-12.5| = 12.5
```

In Go the absolute value can be calculated with `math.Abs()`.

`math.Sqrt()` is used for the square root and `math.Cbrt()` for the cube root.

For raising to a power there is `math.Pow()`.

```go
package main

import (
    "fmt"
    "math"
)

func main() {
    num := -12.5

    fmt.Println("Absolute value:", math.Abs(num))
    fmt.Println("Square root of 81:", math.Sqrt(81))
    fmt.Println("Cube root of 27:", math.Cbrt(27))
    fmt.Println("2 to the power of 5:", math.Pow(2, 5))
    fmt.Println("10 to the power of 3:", math.Pow10(3))
}
```

Output:

```text
Absolute value: 12.5
Square root of 81: 9
Cube root of 27: 3
2 to the power of 5: 32
10 to the power of 3: 1000
```

Now let's look at each calculation separately.

```go
math.Abs(-12.5)
```

gives:

```text
12.5
```

Because the absolute value removes the minus sign.

```go
math.Sqrt(81)
```

calculates the square root of `81`:

```text
9 × 9 = 81
```

So the result is `9`.

```go
math.Cbrt(27)
```

finds the cube root:

```text
3 × 3 × 3 = 27
```

The result is `3`.

`math.Pow()` takes two arguments:

```go
math.Pow(2, 5)
```

Here:

* `2` is the base;
* `5` is the exponent.

The calculation:

```text
2 × 2 × 2 × 2 × 2 = 32
```

Both arguments of `math.Pow()` are used as `float64` in the calculation, and the result is a `float64` too.

`math.Pow10(3)` is meant for a special case:

```text
10³ = 1000
```

That is, if you only need to calculate a power of 10, `math.Pow10()` is more convenient.

## Calculating the area of a circle

The area of a circle is found with the following formula:

```text
S = πr²
```

Here:

* `S` is the area of the circle;
* `π` is the number pi;
* `r` is the radius.

We read the radius from the user and calculate the area of the circle with `math.Pi` and `math.Pow()`:

```go
package main

import (
    "fmt"
    "math"
)

func main() {
    var radius float64

    fmt.Print("Enter the circle's radius: ")
    fmt.Scan(&radius)

    area := math.Pi * math.Pow(radius, 2)

    fmt.Printf("Circle area: %.2f\n", area)
}
```

This program works step by step like this.

First a `float64` variable named `radius` is created:

```go
var radius float64
```

Then the value entered by the user is read:

```go
fmt.Scan(&radius)
```

For example, if the user enters `5`:

```text
radius = 5
```

Then:

```go
math.Pow(radius, 2)
```

calculates:

```text
5² = 25
```

Next:

```text
math.Pi * 25
```

is calculated.

Approximately:

```text
3.141592653589793 × 25 = 78.539816...
```

Because the result is printed with `%.2f`, the screen shows:

```text
78.54
```

The full output:

```text
Enter the circle's radius: 5
Circle area: 78.54
```

The square of the radius can also be calculated without `math.Pow()`:

```go
radius * radius
```

For example:

```go
area := math.Pi * radius * radius
```

For squaring specifically, this approach is simple and clear.

`math.Pow()` is especially useful when the exponent is not known in advance or when working with an arbitrary exponent.

## Calculating the hypotenuse

According to the Pythagorean theorem, the hypotenuse of a right triangle is calculated with the following formula:

```text
c = √(a² + b²)
```

Here `a` and `b` are the legs.

For example, if `a = 3` and `b = 4`:

```text
a² = 9
b² = 16

9 + 16 = 25

√25 = 5
```

In Go this calculation can be done in two ways:

```go
package main

import (
    "fmt"
    "math"
)

func main() {
    a := 3.0
    b := 4.0

    simple := math.Sqrt(a*a + b*b)
    withHypot := math.Hypot(a, b)

    fmt.Println("With Sqrt:", simple)
    fmt.Println("With Hypot:", withHypot)
}
```

Output:

```text
With Sqrt: 5
With Hypot: 5
```

The first approach writes the formula directly:

```go
math.Sqrt(a*a + b*b)
```

Here:

```text
a * a = 3 * 3 = 9
b * b = 4 * 4 = 16
9 + 16 = 25
sqrt(25) = 5
```

The second approach:

```go
math.Hypot(a, b)
```

is made exactly for this task.

With ordinary values both approaches give the same result.

But `math.Hypot()` performs the calculation in a more numerically stable way when working with very large or very small numbers. With the plain `a*a + b*b` calculation, problems related to the limits of `float64` can occur for some extreme values.

That is why `math.Hypot()` is convenient for calculations such as a hypotenuse or the distance between two coordinates.

## Rounding numbers

The `math` package has several functions for bringing floating-point numbers to whole values.

The most commonly used ones:

* `math.Floor()`;
* `math.Ceil()`;
* `math.Round()`.

Although they look similar, they do not work the same way.

```go
package main

import (
    "fmt"
    "math"
)

func main() {
    num := 3.7

    fmt.Println("Floor:", math.Floor(num))
    fmt.Println("Ceil:", math.Ceil(num))
    fmt.Println("Round:", math.Round(num))
}
```

Output:

```text
Floor: 3
Ceil: 4
Round: 4
```

Let's look at each function separately.

```go
math.Floor(3.7)
```

returns the nearest whole value that is less than or equal to the number.

So:

```text
3.7 → 3
```

`math.Ceil()` works in the upward direction:

```go
math.Ceil(3.7)
```

result:

```text
3.7 → 4
```

`math.Round()` picks the nearest whole value:

```go
math.Round(3.7)
```

The number `3.7` is closer to `4` than to `3`. So the result is:

```text
4
```

These functions return a `float64` value.

For example:

```go
rounded := math.Floor(3.7)
fmt.Printf("Value: %v, type: %T\n", rounded, rounded)
```

The output will look roughly like:

```text
Value: 3, type: float64
```

Even though it shows as `3` on screen, the variable's type is not `int`.

It is still of type:

```go
float64
```

With negative numbers, you need to pay special attention to the results of `Floor` and `Ceil`.

For example:

```go
math.Floor(-3.2)
```

gives:

```text
-4
```

At first glance it may seem it should be `-3`. But `Floor` always moves toward the smaller side on the number line.

On the number line:

```text
-4 < -3.2 < -3
```

So the smaller whole number is `-4`.

Conversely:

```go
math.Ceil(-3.2)
```

gives:

```text
-3
```

## Rounding to a given number of decimal places

Sometimes you need to round a number mathematically not to a whole number but, for example, to two decimal places.

Example:

```text
12.3456
```

we want to turn this value into:

```text
12.35
```

To do this, you can first multiply the value by `100`, then round it, and then divide it by `100` again.

```go
package main

import (
    "fmt"
    "math"
)

func main() {
    num := 12.3456
    rounded := math.Round(num*100) / 100

    fmt.Println(rounded)
}
```

Output:

```text
12.35
```

Let's go through the calculation step by step.

Initial value:

```text
12.3456
```

First it is multiplied by `100`:

```text
12.3456 × 100 = 1234.56
```

Then:

```go
math.Round(1234.56)
```

gives:

```text
1235
```

Next it is divided by `100` again:

```text
1235 / 100 = 12.35
```

As a result, the value itself is rounded mathematically to two decimal places.

This technique should not be confused with:

```go
fmt.Printf("%.2f", num)
```

`fmt.Printf("%.2f", num)` only formats the form printed on screen to two digits.

The technique with `math.Round()` also tries to round the value used in later calculations.

**Warning**

`float64` cannot store all decimal fractions exactly in memory.

```
For example, the binary form of some numbers such as `0.1` and `0.2` goes on forever. That is why the computer stores them as the nearest `float64` value.

In financial calculations, plain `float64` and `math.Round()` may not always be enough.

When working with money values, it is often more convenient to store money as a whole number in its smallest unit.

For example, instead of `125.50` dollars, a whole number based on the smallest unit (cents) can be stored.

In complex financial systems, special **decimal** types or libraries are also used.
```

## The smallest and largest value

`math.Min()` is used to find the smaller of two `float64` values and `math.Max()` to find the larger one.

```go
package main

import (
    "fmt"
    "math"
)

func main() {
    first := 17.5
    second := 12.8

    fmt.Println("Smaller:", math.Min(first, second))
    fmt.Println("Larger:", math.Max(first, second))
}
```

Output:

```text
Smaller: 12.8
Larger: 17.5
```

Here:

```go
math.Min(17.5, 12.8)
```

compares both numbers and returns the value:

```text
12.8
```

```go
math.Max(17.5, 12.8)
```

returns the value:

```text
17.5
```

These functions are useful for tasks such as keeping a value from exceeding a certain limit or choosing the larger of two sizes.

**Info**

`math.Min()` and `math.Max()` work with `float64` values.

````
When working with plain `int` values, in modern Go versions you can use the language's built-in `min()` and `max()` functions.

For example:

```go
smaller := min(10, 20)
larger := max(10, 20)
```

In this case there is no need to convert `int` values to `float64`.
````

## Degrees and radians

In trigonometry there are several ways to measure an angle.

In everyday mathematics degrees are usually used:

```text
30°
45°
90°
180°
```

But Go's:

```go
math.Sin()
math.Cos()
math.Tan()
```

functions take the angle not in degrees but in **radians**.

That is why degrees must first be converted to radians.

The formula:

```text
radians = degrees × π / 180
```

For example, for `30°`:

```text
30 × π / 180
```

Simplified, this becomes:

```text
π / 6
```

In Go:

```go
package main

import (
    "fmt"
    "math"
)

func main() {
    degrees := 30.0
    radians := degrees * math.Pi / 180

    fmt.Printf("sin(30°) = %.2f\n", math.Sin(radians))
    fmt.Printf("cos(30°) = %.2f\n", math.Cos(radians))
}
```

Output:

```text
sin(30°) = 0.50
cos(30°) = 0.87
```

The important line in the code:

```go
radians := degrees * math.Pi / 180
```

This converts the value `30°` to radians.

Then:

```go
math.Sin(radians)
```

and:

```go
math.Cos(radians)
```

calculate the correct values.

**Warning**

The following code:

````
```go
math.Sin(30)
```

does not calculate the sine of `30°`.

Here the value `30` is taken as **30 radians**.

That is why mixing up degrees and radians is one of the most common mistakes in trigonometric calculations.
````

## Inverse trigonometric functions

Ordinary trigonometric functions find a trigonometric value from an angle.

For example:

```text
sin(30°) = 0.5
```

Inverse trigonometric functions do the opposite.

If:

```text
sin(x) = 0.5
```

then `math.Asin()` is used to find the angle `x`.

For `math.Asin()` and `math.Acos()` the argument should usually be in the range:

```text
-1 ≤ x ≤ 1
```

The result is returned in radians.

If you need the result in degrees, the following formula is used:

```text
degrees = radians × 180 / π
```

Example:

```go
package main

import (
    "fmt"
    "math"
)

func main() {
    value := 0.5
    radians := math.Asin(value)
    degrees := radians * 180 / math.Pi

    fmt.Printf("asin(%.1f) = %.0f°\n", value, degrees)
}
```

Output:

```text
asin(0.5) = 30°
```

The code works step by step like this.

First:

```go
math.Asin(0.5)
```

is calculated.

The result is approximately:

```text
0.523598...
```

radians.

Then it is converted to degrees with:

```go
radians * 180 / math.Pi
```

The result is:

```text
30
```

**Warning**

For `math.Asin()` and `math.Acos()`, the argument must be from `-1` to `1` within the real numbers.

````
For example:

```go
math.Asin(2.5)
```

or:

```go
math.Acos(2.5)
```

has no result defined as a real number.

In this case Go returns the value `NaN`.
````

**Info**

`NaN` stands for **Not a Number**, a special `float64` value.

```
This value is used to represent the result of an invalid mathematical operation or one that is undefined for real numbers.
```

## Logarithms and the exponential function

`math.Exp(x)` and `math.Log(x)` are mathematical operations that are the inverse of each other.

`math.Exp(x)` calculates the value:

```text
eˣ
```

Here `e` is a mathematical constant approximately equal to:

```text
2.718281828...
```

`math.Log(x)` calculates the natural logarithm.

Example:

```go
package main

import (
    "fmt"
    "math"
)

func main() {
    x := 2.0
    ePower := math.Exp(x)

    fmt.Printf("e^%.0f = %.4f\n", x, ePower)
    fmt.Printf("log(%.4f) = %.4f\n", ePower, math.Log(ePower))
    fmt.Println("Base-10 logarithm:", math.Log10(1000))
}
```

Output:

```text
e^2 = 7.3891
log(7.3891) = 2.0000
Base-10 logarithm: 3
```

First:

```go
math.Exp(2)
```

is calculated:

```text
e² ≈ 7.389056...
```

The result is stored in the `ePower` variable.

Then:

```go
math.Log(ePower)
```

is calculated.

Because `Log` and `Exp` are inverse operations, the result is again approximately:

```text
2
```

`math.Log10()` calculates the base-10 logarithm:

```go
math.Log10(1000)
```

because:

```text
10³ = 1000
```

the result is:

```text
3
```

For `math.Log(x)` it is important that the argument is positive.

For example:

```go
math.Log(0)
```

returns negative infinity.

The natural logarithm of a negative number does not exist within the real numbers.

That is why a calculation such as:

```go
math.Log(-5)
```

returns `NaN`.

## `NaN` and infinity

Some mathematical operations have no result in the set of real numbers.

For example:

```text
√-1
```

is not a real number.

In Go, when:

```go
math.Sqrt(-1)
```

runs, the program does not stop right away.

Instead, the `math` package returns the special value `NaN`.

```go
package main

import (
    "fmt"
    "math"
)

func main() {
    result := math.Sqrt(-1)

    fmt.Println(result)
    fmt.Println("Is it NaN?", math.IsNaN(result))
}
```

Output:

```text
NaN
Is it NaN? true
```

Here:

```go
math.IsNaN(result)
```

checks whether the value is `NaN`.

Because the result is `NaN`, the function returns:

```text
true
```

Checking for `NaN` with ordinary equality is not the right approach. `math.IsNaN()` is used exactly for this.

For checking infinite values there is:

```go
math.IsInf()
```

For example, the result of a mathematical calculation can be positive or negative infinity.

In practical programs, it is often better to check that a function's argument is in the allowed range before the calculation.

For example, if a square root is only needed for non-negative values:

```go
if x < 0 {
    fmt.Println("Cannot take a real square root of a negative number")
    return
}

result := math.Sqrt(x)
```

This approach keeps a wrong result from being passed on to later calculations.

## Seeing the functions in one program

In the following example, most of the basic `math` functions covered above are gathered in one program:

```go
package main

import (
    "fmt"
    "math"
)

func main() {
    x := 2.5
    y := 3.0
    trigValue := 0.5

    fmt.Printf("math.Abs(-%v) = %v\n", x, math.Abs(-x))
    fmt.Printf("math.Sin(%v) = %.4f\n", x, math.Sin(x))
    fmt.Printf("math.Cos(%v) = %.4f\n", x, math.Cos(x))
    fmt.Printf("math.Tan(%v) = %.4f\n", x, math.Tan(x))
    fmt.Printf("math.Asin(%v) = %.4f\n", trigValue, math.Asin(trigValue))
    fmt.Printf("math.Acos(%v) = %.4f\n", trigValue, math.Acos(trigValue))
    fmt.Printf("math.Atan(%v) = %.4f\n", x, math.Atan(x))
    fmt.Printf("math.Exp(%v) = %.4f\n", x, math.Exp(x))
    fmt.Printf("math.Log(%v) = %.4f\n", x, math.Log(x))
    fmt.Printf("math.Pow(%v, %v) = %.4f\n", x, y, math.Pow(x, y))
    fmt.Printf("math.Pow10(3) = %.4f\n", math.Pow10(3))
    fmt.Printf("math.Sqrt(%v) = %.4f\n", x, math.Sqrt(x))
    fmt.Printf("math.Floor(%v) = %.4f\n", x, math.Floor(x))
    fmt.Printf("math.Ceil(%v) = %.4f\n", x, math.Ceil(x))
    fmt.Printf("math.Round(%v) = %.4f\n", x, math.Round(x))
    fmt.Printf("math.Pi = %.4f\n", math.Pi)
    fmt.Printf("math.E = %.4f\n", math.E)
    fmt.Printf("math.Min(%v, %v) = %.4f\n", x, y, math.Min(x, y))
    fmt.Printf("math.Max(%v, %v) = %.4f\n", x, y, math.Max(x, y))
    fmt.Printf("math.Mod(%v, %v) = %.4f\n", x, y, math.Mod(x, y))
}
```

Output:

```text
math.Abs(-2.5) = 2.5
math.Sin(2.5) = 0.5985
math.Cos(2.5) = -0.8011
math.Tan(2.5) = -0.7470
math.Asin(0.5) = 0.5236
math.Acos(0.5) = 1.0472
math.Atan(2.5) = 1.1903
math.Exp(2.5) = 12.1825
math.Log(2.5) = 0.9163
math.Pow(2.5, 3) = 15.6250
math.Pow10(3) = 1000.0000
math.Sqrt(2.5) = 1.5811
math.Floor(2.5) = 2.0000
math.Ceil(2.5) = 3.0000
math.Round(2.5) = 3.0000
math.Pi = 3.1416
math.E = 2.7183
math.Min(2.5, 3) = 2.5000
math.Max(2.5, 3) = 3.0000
math.Mod(2.5, 3) = 2.5000
```

Here `x`:

```go
x := 2.5
```

is used for most of the simple math functions.

`y`:

```go
y := 3.0
```

is used in functions that need two arguments, such as `math.Pow()`, `math.Min()`, `math.Max()` and `math.Mod()`.

For the inverse trigonometric functions, a separate value:

```go
trigValue := 0.5
```

was chosen.

The reason is that for `math.Asin()` and `math.Acos()` the value must be between `-1` and `1`.

For example:

```go
math.Asin(0.5)
```

is a valid argument.

The result comes out in radians, around:

```text
0.5236
```

`math.Mod(x, y)` calculates the remainder of division.

In this example:

```go
math.Mod(2.5, 3)
```

is being calculated.

Because `2.5` is smaller than `3`, `3` does not fit into it even once. So the remainder is:

```text
2.5
```

Most numbers in the output are formatted with:

```text
%.4f
```

That is why they are shown with four digits after the decimal point.

The next part is about if, else if and else conditions in Go.

## Examples

In the following examples we will see how simple arithmetic operators and the functions of the `math` package are used in practical tasks.

### 1. Area and perimeter of a rectangle

In this example the area and perimeter of a rectangle are calculated.

The area formula:

```text
S = width × height
```

The perimeter formula:

```text
P = 2 × (width + height)
```

Code:

```go
package main

import "fmt"

func main() {
    width, height := 8.0, 5.0

    fmt.Println("Area:", width*height)
    fmt.Println("Perimeter:", 2*(width+height))
}
```

Let's go through the calculation step by step.

Area:

```text
8 × 5 = 40
```

Perimeter:

```text
8 + 5 = 13
2 × 13 = 26
```

Output:

```text
Area: 40
Perimeter: 26
```

This example does not need a special `math` function. Ordinary multiplication and addition operators are enough.

### 2. Circumference and area of a circle

In this example the circumference and area of a circle are calculated from its radius.

Circumference:

```text
L = 2πr
```

Area of the circle:

```text
S = πr²
```

Code:

```go
package main

import (
    "fmt"
    "math"
)

func main() {
    radius := 3.0

    fmt.Printf("Circumference: %.2f\n", 2*math.Pi*radius)
    fmt.Printf("Area: %.2f\n", math.Pi*radius*radius)
}
```

Here `radius` is equal to:

```text
3
```

The circumference is approximately:

```text
2 × 3.14159 × 3 ≈ 18.85
```

And the area of the circle is:

```text
3.14159 × 3 × 3 ≈ 28.27
```

`math.Pi` gives the ready-made value of π from the Go standard library. Using `math.Pi` is more accurate than writing `3.14` by hand.

### 3. The average of three numbers

The arithmetic mean is found by adding all the numbers and dividing by how many there are.

```go
package main

import "fmt"

func main() {
    a, b, c := 7.0, 8.0, 10.0

    average := (a + b + c) / 3

    fmt.Printf("%.2f\n", average)
}
```

The calculation:

```text
7 + 8 + 10 = 25
25 / 3 = 8.3333...
```

`fmt.Printf("%.2f", ...)` shows the result to two decimal places:

```text
8.33
```

Because the values `a`, `b` and `c` are `float64`, the division does not lose the fractional part.

If the calculation were done with integers, you would need to pay attention to the rules of integer division.

### 4. Calculating a percentage

In this example a discount is applied to a product's price.

```go
package main

import "fmt"

func main() {
    price := 240_000.0
    discountPercent := 15.0

    discount := price * discountPercent / 100

    fmt.Println("New price:", price-discount)
}
```

First `15%` of `240 000` is calculated:

```text
240000 × 15 / 100 = 36000
```

So the discount is:

```text
36000
```

Then the discount is subtracted from the original price:

```text
240000 - 36000 = 204000
```

Output:

```text
New price: 204000
```

This formula can be used for percentages, taxes, commissions and other relative calculations.

### 5. Converting temperature

The formula for converting a temperature from Celsius to Fahrenheit:

```text
°F = °C × 9 / 5 + 32
```

Code:

```go
package main

import "fmt"

func main() {
    celsius := 25.0
    fahrenheit := celsius*9/5 + 32

    fmt.Printf("%.1f °F\n", fahrenheit)
}
```

The calculation:

```text
25 × 9 = 225
225 / 5 = 45
45 + 32 = 77
```

Output:

```text
77.0 °F
```

Here the value of `celsius` is written as `25.0`.

So it is a `float64`.

As a result, the calculations in the expression are also done with floating-point numbers, and the fractional part is kept if needed.

### 6. The distance between two points

On a coordinate plane, the distance between two points is calculated with the following formula:

```text
d = √((x₂ - x₁)² + (y₂ - y₁)²)
```

`math.Hypot()` performs exactly the calculation:

```text
√(a² + b²)
```

So we can pass it the differences of the coordinates:

```go
package main

import (
    "fmt"
    "math"
)

func main() {
    x1, y1 := 1.0, 2.0
    x2, y2 := 4.0, 6.0

    distance := math.Hypot(x2-x1, y2-y1)

    fmt.Println(distance)
}
```

First the differences between the coordinates are found:

```text
x2 - x1 = 4 - 1 = 3
y2 - y1 = 6 - 2 = 4
```

Then:

```text
√(3² + 4²)
```

is calculated:

```text
3² = 9
4² = 16
9 + 16 = 25
√25 = 5
```

Output:

```text
5
```

This is the Pythagorean theorem applied to coordinates.

### 7. Dividing and rounding up

Sometimes elements need to be split into groups of a certain capacity.

For example:

* there are `23` products;
* each box holds `5` products.

Ordinary integer division:

```text
23 / 5 = 4
```

gives this result.

But `4` boxes hold only:

```text
4 × 5 = 20
```

products.

`3` more products remain.

So in fact `5` boxes are needed.

The following formula is a common way to round integer division up:

```go
package main

import "fmt"

func main() {
    products, boxSize := 23, 5

    boxes := (products + boxSize - 1) / boxSize

    fmt.Println(boxes)
}
```

The calculation:

```text
23 + 5 - 1 = 27
27 / 5 = 5
```

In integer division the fractional part is dropped.

So the result is:

```text
5
```

This formula is useful for positive integers:

```text
(n + d - 1) / d
```

Here:

* `n` is the number of elements;
* `d` is the capacity of one group.

### 8. Keeping a number within a range

Sometimes a value must not go beyond a certain lower and upper bound.

For example, a percentage must not be less than:

```text
0
```

and not greater than:

```text
100
```

But imagine the program receives the value:

```text
135
```

To keep it within the `0..100` range, you can use `math.Min()` and `math.Max()` together:

```go
package main

import (
    "fmt"
    "math"
)

func main() {
    percent := 135.0

    percent = math.Max(0, math.Min(percent, 100))

    fmt.Println(percent)
}
```

The calculation goes from the inside out.

First:

```go
math.Min(135, 100)
```

is calculated.

Result:

```text
100
```

Because `100` is smaller.

Then:

```go
math.Max(0, 100)
```

is calculated.

The result is again:

```text
100
```

So:

```text
135 → 100
```

is clamped.

If the value had been `-20`:

```text
math.Min(-20, 100) = -20
math.Max(0, -20) = 0
```

So:

```text
-20 → 0
```

This technique is used to keep a value within a certain interval.

### 9. Comparing floating-point numbers

Comparing `float64` values directly with `==` may not always give the expected result.

The reason is that many decimal fractions cannot be represented exactly in binary.

That is why a number may be stored in memory with a very small error.

If the difference between two values is very small, they can be considered equal for practical purposes.

```go
package main

import (
    "fmt"
    "math"
)

func main() {
    a := 0.1 + 0.2
    b := 0.3

    equal := math.Abs(a-b) < 1e-9

    fmt.Println(equal)
}
```

Here:

```go
a - b
```

calculates the difference between the two values.

The difference can also be negative. So with:

```go
math.Abs(a - b)
```

its absolute value is taken.

Then:

```go
< 1e-9
```

checks that it is smaller than a very small allowed threshold.

`1e-9` in scientific notation means:

```text
0.000000001
```

If the difference is smaller than this:

```go
equal = true
```

This technique is an example of an approach called **comparing with an epsilon**.

In a practical program, choosing the epsilon value depends on the scale of the calculation and the required precision.

### 10. Compound interest

With compound interest, the interest in each new period is added not only to the initial amount but also to the interest accumulated in previous periods.

The simplified formula:

```text
A = P × (1 + r)ⁿ
```

Here:

* `P` is the initial amount;
* `r` is the interest rate per period;
* `n` is the number of periods;
* `A` is the final amount.

In Go the power can be calculated with `math.Pow()`:

```go
package main

import (
    "fmt"
    "math"
)

func main() {
    principal := 1_000_000.0
    annualRate := 12.0
    years := 3.0

    result := principal * math.Pow(1+annualRate/100, years)

    fmt.Printf("%.2f\n", result)
}
```

First the percentage is converted to a fraction:

```text
12 / 100 = 0.12
```

Then:

```text
1 + 0.12 = 1.12
```

For three years:

```text
1.12³
```

is calculated.

Step by step:

```text
1.12 × 1.12 = 1.2544
1.2544 × 1.12 = 1.404928
```

Then it is multiplied by the initial amount:

```text
1 000 000 × 1.404928 = 1 404 928
```

The result is:

```text
1404928.00
```

Here `math.Pow()` lets you calculate through a power instead of repeating the same multiplication by hand for every year.
