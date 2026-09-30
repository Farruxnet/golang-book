# Working with generics in Go

Generics let you use the same algorithm with several types. There is no need to write a separate function for each type.

For example, you could write one function to sum `int` values and another function to sum `float64` values. But if both functions work the same way, this leads to duplicated code.

With generics, the type itself can be given as a parameter. Such a parameter is called a **type parameter**.

As a result, one function can work with:

* `int`;
* `int64`;
* `float64`;
* or other types the constraint allows.

The important point is that type information is not lost in this process. The compiler knows which type is being used and can detect values of the wrong type at compile time.

Go supports generics starting from version 1.18.

Even so, not every function needs to be generic. Generics are especially useful when:

* the algorithm is the same;
* only the types being used differ;
* they reduce duplicated code;
* the connection between input and output types must be kept.

If generic code becomes more complex and harder to read than ordinary code, there is no need to use it.

## Why are generics needed?

Imagine we are working with orders in a program.

The quantities of products in an order are stored as `int`:

```go
[]int
```

Prices, on the other hand, may be `float64`:

```go
[]float64
```

We need to sum the values in both slices.

Without generics we could write two separate functions:

```go
func sumInts(values []int) int {
	var total int
	for _, value := range values {
		total += value
	}
	return total
}

func sumFloats(values []float64) float64 {
	var total float64
	for _, value := range values {
		total += value
	}
	return total
}
```

This code works.

The first function:

```go
func sumInts(values []int) int
```

takes only `[]int` and returns an `int`.

The second function:

```go
func sumFloats(values []float64) float64
```

takes `[]float64` and returns a `float64`.

But if we look inside the functions, the algorithm is almost exactly the same:

```go
var total ...
for _, value := range values {
	total += value
}
return total
```

Only the type names changed.

If we now need to work with `int64` too, we have to write a third function. Then if another number type is added, yet another copy appears.

This is where generics help.

The type difference can be expressed not through plain copies of code, but through a type parameter:

```go
package main

import "fmt"

type Number interface {
	~int | ~int64 | ~float64
}

func sum[T Number](values []T) T {
	var total T
	for _, value := range values {
		total += value
	}
	return total
}

func main() {
	quantities := []int{2, 3, 5}
	prices := []float64{12.5, 7.25, 10}

	fmt.Println(sum(quantities))
	fmt.Println(sum(prices))
}
```

Output:

```text
10
29.75
```

Here one `sum()` function worked with two different types.

For the first call:

```go
sum(quantities)
```

the type of `quantities` is:

```go
[]int
```

That is why `T` is determined as `int`.

The function in practice works in the sense of:

```go
func sum(values []int) int
```

For the second call:

```go
sum(prices)
```

`T` is `float64`:

```go
func sum(values []float64) float64
```

The important point is that the function does not return `any`. Whatever type was used on input is also kept in the result.

That is why the connections:

```go
[]int -> int
```

and:

```go
[]float64 -> float64
```

are not lost.

## Type parameter and constraint

Type parameters are written inside `[]` after the name of a generic function.

For example:

```go
func sum[T Number](values []T) T
```

Let's split this into parts.

### `T` — the type parameter

```go
T
```

is not a concrete type here.

It is a name for the type that is determined when the function is called.

For example, in the call:

```go
sum([]int{1, 2, 3})
```

we get:

```text
T = int
```

In the following call:

```go
sum([]float64{1.5, 2.5})
```

we get:

```text
T = float64
```

The name `T` is not mandatory. Another name can be used as well:

```go
func sum[Element Number](values []Element) Element
```

But for short type parameters, names such as `T`, `K`, `V`, `R` are widespread.

### `Number` — the constraint

In the part:

```go
T Number
```

`Number` is the constraint.

A constraint defines which types can be given to a type parameter.

In our example we wrote:

```go
type Number interface {
	~int | ~int64 | ~float64
}
```

So `T` can be:

* `int`;
* `int64`;
* `float64`;
* or a suitable named type that uses one of these types as its underlying type.

A constraint does not only define which types are allowed. It also defines which operations can be performed on `T` values inside the generic function.

For example, we wrote:

```go
total += value
```

In practice this means:

```go
total = total + value
```

All types in the `Number` constraint support the `+` operator. That is why the compiler allows this code.

If the constraint contained a type that does not support the `+` operator, such code could not be written.

### `[]T` — a generic slice

The function parameter is written as:

```go
values []T
```

This means `values` is a slice whose elements are of type `T`.

If:

```text
T = int
```

then:

```go
[]T
```

in practice is:

```go
[]int
```

If:

```text
T = float64
```

then:

```go
[]T
```

in practice is:

```go
[]float64
```

### The last `T` — the return type

The:

```go
T
```

at the end of the function signature means the return type of the function:

```go
func sum[T Number](values []T) T
```

This is very important.

Whatever element type the input slice has, the function's result has exactly that type too.

For example:

```go
total := sum([]int{1, 2, 3})
```

here the type of `total` is:

```go
int
```

And in the following:

```go
total := sum([]float64{1.2, 3.4})
```

the type of `total` is:

```go
float64
```

## Going deeper: `|` and `~` in constraints

For simple generic functions `any` or a ready-made constraint may be enough. The type set syntax below comes in handy when you need to write a custom constraint that also covers named types.

Let's look at the following constraint once more:

```go
type Number interface {
	~int | ~int64 | ~float64
}
```

There are two important symbols here:

* `|`;
* `~`.

### `|` — combining types

The `|` symbol combines several allowed type sets.

For example, if we say:

```go
int | float64
```

the type parameter can be `int` or `float64`.

We have:

```go
~int | ~int64 | ~float64
```

So the constraint accepts values that match these three main type groups.

### `~` — matching the underlying type

`~int` does not mean only the built-in `int` type itself.

It also accepts named types whose underlying type is `int`.

For example:

```go
type Quantity int
```

Here `Quantity` is a new, named type.

It is not exactly the same type as `int`:

```go
int
```

and:

```go
Quantity
```

are two separate types.

But the underlying type of `Quantity` is `int`.

That is why `Quantity` also matches the constraint:

```go
~int
```

If the constraint were:

```go
type Number interface {
	int | float64
}
```

then only exactly the `int` and `float64` types would be allowed.

The following named type:

```go
type Quantity int
```

would not match it.

That is why `~` is very useful in generic constraints when named types also need to be supported.

## Type inference

When calling a generic function, the type argument can be given by hand.

For example:

```go
total := sum[int]([]int{1, 2, 3})
```

Here with:

```go
[int]
```

we ourselves wrote that `T` is exactly `int`.

The full logic:

```text
T = int
values = []int{1, 2, 3}
result type = int
```

But in many cases Go can determine the type argument from the function arguments itself.

That is why it is enough to write:

```go
total := sum([]int{1, 2, 3})
```

The compiler sees the `[]int` argument.

And the function has the form:

```go
func sum[T Number](values []T) T
```

From this it determines that:

```text
[]T = []int
```

So:

```text
T = int
```

must hold.

This process is called **type inference**.

Both forms work with the same `T`:

```go
sum[int]([]int{1, 2, 3})
```

and:

```go
sum([]int{1, 2, 3})
```

But the second variant is usually shorter and more natural.

### Type inference does not always work

Sometimes the compiler does not have enough information to determine `T`.

For example:

```go
func zero[T any]() T {
	var value T
	return value
}
```

This function takes no arguments.

If we write:

```go
zero()
```

the compiler cannot figure out where to learn which type `T` is.

Because the function was given no value indicating:

* `int`;
* `string`;
* `bool`;
* or any other type.

That is why the type argument must be given explicitly:

```go
num := zero[int]()
text := zero[string]()
```

In the first call:

```text
T = int
```

In the second:

```text
T = string
```

## The `any` constraint

`any` is one of the widest constraints in Go.

It allows any type.

`any` is actually an alias for:

```go
interface{}
```

That is, writing:

```go
T any
```

is equal to writing:

```go
T interface{}
```

But in generic code `any` is much shorter and easier to read.

The following function creates a copy of a slice:

```go
package main

import "fmt"

func clone[T any](values []T) []T {
	result := make([]T, len(values))
	copy(result, values)
	return result
}

func main() {
	numbers := clone([]int{10, 20, 30})
	words := clone([]string{"Go", "Generics"})

	fmt.Println(numbers)
	fmt.Println(words)
}
```

Output:

```text
[10 20 30]
[Go Generics]
```

This function performs no type-specific operations on the elements themselves, such as:

* addition;
* subtraction;
* comparison;
* sorting.

It only:

1. creates a new slice of the same length as `[]T`;
2. copies the elements with `copy()`;
3. returns the new `[]T`.

That is why no extra restriction is needed for `T`.

```go
T any
```

is enough.

### `any` does not allow every operator

There is an important difference here.

`any` means:

> any type can be given

But it does not mean:

> any operator can be used

For example:

```go
func add[T any](a, b T) T {
	return a + b
}
```

such a function does not work.

The reason is that `T` can be any type.

For example, for:

```go
struct{}
```

or:

```go
[]int
```

there is no `+` operator.

In the same way:

```go
a > b
```

does not exist for all types either.

That is why with `T any` you can only perform operations that make sense for all types.

### The difference between plain `any` and `T any`

The following two signatures look similar from the outside:

```go
func first(values []any) any
```

and:

```go
func first[T any](values []T) T
```

But they do not mean the same thing.

The first variant:

```go
func first(values []any) any
```

does not keep the connection to the concrete type.

The function takes `any` and returns `any`.

For example, even if the result is actually an `int`, its static type is `any`.

The second variant:

```go
func first[T any](values []T) T
```

keeps the element type of the input slice.

If:

```go
[]int
```

is given, then:

```text
T = int
```

and the result is also an `int`.

If:

```go
[]string
```

is given, the result is a `string`.

This is exactly one of the big advantages of generics: the connection between types is kept at compile time.

## The `comparable` constraint

Some generic functions need to compare values with:

```go
==
```

or:

```go
!=
```

For this Go has a ready-made `comparable` constraint.

For example:

```go
package main

import "fmt"

func contains[T comparable](values []T, target T) bool {
	for _, value := range values {
		if value == target {
			return true
		}
	}
	return false
}

func main() {
	fmt.Println(contains([]string{"go", "rust"}, "go"))
	fmt.Println(contains([]int{10, 20}, 30))
}
```

Output:

```text
true
false
```

The function works like this:

1. it walks through the `values` slice;
2. compares each element with `target`;
3. returns `true` if an equal element is found;
4. returns `false` if the whole slice is checked and no matching value is found.

The important line:

```go
if value == target
```

The `==` operator is used here.

That is why the compiler must know that `T` can be compared with `==`.

For this reason we wrote:

```go
T comparable
```

### What does `comparable` not mean?

`comparable` means values can be compared for equality.

That is, you can use:

```go
==
```

and:

```go
!=
```

But this does not mean values can be compared by order.

For example, `comparable` is not enough for:

```go
a < b
```

or:

```go
a > b
```

Because `comparable` also includes types such as `bool`, and `bool` does not support the `<` operator.

Also, not all Go types are `comparable`.

For example, values of:

* slice;
* map;
* function

types cannot be compared with each other using plain `==`.

That is why they do not match a `comparable` type parameter.

## Several type parameters

A generic function is not limited to one type parameter.

Several type parameters can be used.

For example, when working with a map, the key and value types can differ:

```go
map[string]int
```

Here:

```text
key type = string
value type = int
```

Let's write a generic function that returns the map's keys as a slice:

```go
package main

import "fmt"

func keys[K comparable, V any](items map[K]V) []K {
	result := make([]K, 0, len(items))
	for key := range items {
		result = append(result, key)
	}
	return result
}

func main() {
	ages := map[string]int{
		"Ali":  24,
		"Vali": 31,
	}

	fmt.Println(keys(ages))
}
```

There are two type parameters here:

```go
[K comparable, V any]
```

### `K` — the key type

```go
K comparable
```

`K` expresses the type of the map key.

In Go, map keys must be `comparable`.

The reason is that to find keys in a map, Go must check them for equality.

That is why `K` cannot be `any`. If we said:

```go
K any
```

types that cannot be map keys, such as slices, would theoretically be allowed too.

### `V` — the value type

```go
V any
```

means the type of the map value.

The function performs no type-specific operation on `V` values.

It does not even read the values.

That is why `any` is enough for `V`.

### The result type

The function returns:

```go
[]K
```

That is, whatever type the map keys have, the elements of the resulting slice have that type too.

For example, for:

```go
map[string]int
```

we get:

```text
K = string
V = int
```

The result is:

```go
[]string
```

### About map order

The iteration order of Go map elements is not guaranteed.

That is why the keys obtained through:

```go
for key := range items
```

do not have to come out in the same order every time.

For example, one run may print:

```text
[Ali Vali]
```

Another run may look like:

```text
[Vali Ali]
```

If an exact order is needed, the keys should be sorted separately afterwards.

## Generic types

Type parameters can be used not only in functions but also in `type` declarations.

Such a type is called a **generic type**.

A generic type is useful for using the same data structure with different element types.

For example, let's create a `Stack`.

A stack works on the LIFO principle:

```text
Last In, First Out
```

That is, the last added element is taken first.

The code:

```go
package main

import "fmt"

type Stack[T any] struct {
	items []T
}

func (s *Stack[T]) Push(value T) {
	s.items = append(s.items, value)
}

func (s *Stack[T]) Pop() (T, bool) {
	if len(s.items) == 0 {
		var zero T
		return zero, false
	}

	last := len(s.items) - 1
	value := s.items[last]
	s.items = s.items[:last]
	return value, true
}

func main() {
	var stack Stack[string]
	stack.Push("first")
	stack.Push("second")

	value, ok := stack.Pop()
	if ok {
		fmt.Println(value)
	}
}
```

Output:

```text
second
```

### How does `Stack[T]` work?

The struct is declared as:

```go
type Stack[T any] struct {
	items []T
}
```

Here `T` means the type of the elements stored in the stack.

For example, if:

```go
Stack[string]
```

is created, then:

```text
T = string
```

That is why `items` works as:

```go
[]string
```

If:

```go
Stack[int]
```

is created, then:

```text
T = int
```

### `Push()`

The method:

```go
func (s *Stack[T]) Push(value T) {
	s.items = append(s.items, value)
}
```

accepts only a value of type `T`.

For example, if:

```go
var stack Stack[string]
```

then:

```go
stack.Push("hello")
```

is correct.

But:

```go
stack.Push(10)
```

leads to a compile-time error.

Because for `Stack[string]`, `T` is already `string`.

### `Pop()`

The method:

```go
func (s *Stack[T]) Pop() (T, bool)
```

returns two values:

* the element;
* a `bool` saying whether an element exists.

First it checks whether the stack is empty:

```go
if len(s.items) == 0 {
```

If it is empty, an ordinary value of type `T` must be returned.

But `T` is not known in advance.

That is why a technique widely used in generic code is applied:

```go
var zero T
```

`zero` automatically gets the zero value of type `T`.

For example:

```text
T = int       -> 0
T = string    -> ""
T = bool      -> false
T = *User     -> nil
```

That is why for an empty stack:

```go
return zero, false
```

is returned.

### Taking the last element

If the stack is not empty, the last index is found with:

```go
last := len(s.items) - 1
```

For example, if the slice length is `2`:

```text
len = 2
last = 2 - 1
last = 1
```

The indexes:

```text
0 -> first
1 -> second
```

That is why:

```go
value := s.items[last]
```

takes the last element.

Then:

```go
s.items = s.items[:last]
```

removes that element from the stack.

### The receiver of a generic type

In a method of a generic type, the receiver must also state the type parameter:

```go
func (s *Stack[T]) Push(value T)
```

Here:

```go
Stack[T]
```

says this method belongs to the `Stack` generic type.

There is no need to write the constraint again in the receiver.

For example, if the struct is declared as:

```go
type Stack[T any] struct
```

you do not write in the method:

```go
func (s *Stack[T any]) Push(...)
```

The correct form is:

```go
func (s *Stack[T]) Push(...)
```

## When are generics not needed?

Generics give a powerful capability. But that does not mean they should be used everywhere.

In some cases an ordinary function or interface is much clearer.

### If the code works with only one concrete type

For example, if a function only needs to work with `User`:

```go
func saveUser(user User)
```

there is no benefit in simply making it generic.

A form like:

```go
func save[T User](value T)
```

may make the code more complex without giving any practical benefit.

### If types require different behavior

Generics are convenient when the same algorithm works across different types.

If completely different behavior is needed for each type, many special cases may appear inside the generic function.

In such a situation an ordinary interface may be a better solution for polymorphism.

### If an interface expresses the behavior better

For example, if the function needs:

> any object that can `Write()`

it is more natural to use an interface than to list types in a constraint.

Generics are mainly useful for:

> keeping the compile-time connection between the concrete types of values

An interface, on the other hand, expresses behavior more:

> what an object can do

### If generic code makes reading harder

Sometimes a very complex constraint is written just to reduce duplication slightly.

As a result, instead of simple 5-line code, a hard-to-read generic abstraction may appear.

In such a case repeated simple code is sometimes the better choice.

### Choosing the constraint as narrow as possible

A constraint should match the capabilities the function actually needs.

For example, if only an equality check is needed:

```go
T comparable
```

is enough.

If no type-specific operation is performed:

```go
T any
```

is enough.

If `+` is needed, a suitable type set that supports `+` is needed.

Adding unneeded types to a big constraint makes the function's purpose unclear.

The more precise the constraint, the clearer what the generic function is meant for.

## Examples

### 1. Getting the zero value of any type

This example shows how to get the zero value of type `T` in generic code.

The function takes no arguments. That is why the type itself must be given explicitly at the call.

```go
package main

import "fmt"

func zero[T any]() T {
	var value T
	return value
}

func main() {
	fmt.Println(zero[int]())
	fmt.Printf("%q\n", zero[string]())
	fmt.Println(zero[bool]())
}
```

The main line:

```go
var value T
```

In Go a variable created with `var` and not given an initial value automatically gets the zero value of its type.

This rule also works for a generic type.

For the first call:

```go
zero[int]()
```

we have:

```text
T = int
```

That is why it works like:

```go
var value int
```

The zero value of `int`:

```text
0
```

For the second call:

```go
zero[string]()
```

we have:

```text
T = string
```

The zero value of `string` is empty text:

```text
""
```

For the third call:

```go
zero[bool]()
```

the result is:

```text
false
```

Because the function takes no arguments, writing:

```go
zero()
```

is not enough.

The compiler cannot determine `T` from an argument.

That is why a type argument such as:

```go
[int]
```

or:

```go
[string]
```

must be given explicitly.

The main rule shown in this example: in generic code, to get the zero value of an unknown type `T`, the technique:

```go
var zero T
```

is used.

### 2. Safely taking the first element of a slice

This example shows how to safely handle the empty slice case when taking the first element of a slice.

```go
package main

import "fmt"

func first[T any](values []T) (T, bool) {
	if len(values) == 0 {
		var zero T
		return zero, false
	}

	return values[0], true
}

func main() {
	number, numberOK := first([]int{10, 20, 30})
	word, wordOK := first([]string{})

	fmt.Println(number, numberOK)
	fmt.Printf("%q %t\n", word, wordOK)
}
```

Slice indexes start from `0`.

For example, for:

```go
[]int{10, 20, 30}
```

the indexes are:

```text
0 -> 10
1 -> 20
2 -> 30
```

That is why the first element is taken with:

```go
values[0]
```

But for an empty slice:

```go
[]string{}
```

index `0` does not exist.

If we access:

```go
values[0]
```

without checking, the program panics at runtime.

That is why first:

```go
if len(values) == 0
```

is checked.

If it is empty:

```go
var zero T
return zero, false
```

is returned.

Here `false` means:

> no element found

If an element exists:

```go
return values[0], true
```

is returned.

The result of the first call:

```go
first([]int{10, 20, 30})
```

is:

```text
10 true
```

In the second call the slice is empty:

```go
first([]string{})
```

so it returns:

```text
"" false
```

This technique is similar to the `value, ok` style found in many Go APIs.

### 3. Reversing a slice in place

In this example one generic function reverses the order of a slice of `int`, `string` or any other element type.

```go
package main

import "fmt"

func reverse[T any](values []T) {
	for left, right := 0, len(values)-1; left < right; left, right = left+1, right-1 {
		values[left], values[right] = values[right], values[left]
	}
}

func main() {
	numbers := []int{1, 2, 3, 4}
	words := []string{"one", "two", "three"}

	reverse(numbers)
	reverse(words)

	fmt.Println(numbers)
	fmt.Println(words)
}
```

This algorithm walks from the start and the end of the slice at the same time.

At the beginning:

```go
left := 0
```

means the index of the first element.

```go
right := len(values) - 1
```

means the index of the last element.

For example, for:

```go
numbers := []int{1, 2, 3, 4}
```

we have:

```text
len(numbers) = 4
right = 4 - 1
right = 3
```

The indexes:

```text
0 -> 1
1 -> 2
2 -> 3
3 -> 4
```

In the first iteration:

```text
left = 0
right = 3
```

the following swap happens:

```go
values[left], values[right] = values[right], values[left]
```

The result:

```text
[4 2 3 1]
```

Then:

```text
left = 1
right = 2
```

They swap again:

```text
[4 3 2 1]
```

Then the indexes meet, and the condition:

```go
left < right
```

no longer holds.

The function performs no:

* arithmetic;
* equality check;
* order comparison

on the elements.

It only swaps the positions of elements.

That is why:

```go
T any
```

is enough.

The function does not return a new slice.

It changes the elements of the given slice in place.

### 4. Removing duplicate values

This example shows another important use of the `comparable` constraint.

The values are used as map keys.

```go
package main

import "fmt"

func unique[T comparable](values []T) []T {
	seen := make(map[T]bool)
	result := make([]T, 0, len(values))

	for _, value := range values {
		if !seen[value] {
			seen[value] = true
			result = append(result, value)
		}
	}

	return result
}

func main() {
	fmt.Println(unique([]int{2, 2, 3, 2, 4, 3}))
	fmt.Println(unique([]string{"go", "api", "go"}))
}
```

The `seen` map:

```go
seen := make(map[T]bool)
```

stores the values that have already appeared.

The map key is of type `T`.

Go map keys must be `comparable`.

That is why the function uses the constraint:

```go
T comparable
```

Let's walk through the process for the first slice:

```text
[2, 2, 3, 2, 4, 3]
```

For the first `2`:

```go
seen[2]
```

is still `false`.

That is why:

```go
seen[2] = true
```

is done and `2` is added to the result.

The result:

```text
[2]
```

When the next `2` comes:

```go
seen[2] == true
```

That is why it is not added again.

When `3` comes for the first time, it is added to the result:

```text
[2 3]
```

`4` is added too:

```text
[2 3 4]
```

The last `3` is skipped because it appeared before.

`result` is created like this:

```go
result := make([]T, 0, len(values))
```

Here the length is:

```text
0
```

Because at the start no unique element has been added yet.

The capacity is taken as:

```go
len(values)
```

The reason is that in the worst case all elements may be unique.

For example, for:

```text
[1 2 3 4]
```

the result also consists of 4 elements.

### 5. Choosing the smaller of two values

In this example the generic constraint accepts only certain number types.

The `<` operator is used inside the function.

```go
package main

import "fmt"

type OrderedNumber interface {
	~int | ~int64 | ~float64
}

func min[T OrderedNumber](a, b T) T {
	if a < b {
		return a
	}
	return b
}

func main() {
	fmt.Println(min(8, 3))
	fmt.Println(min(4.5, 7.2))
}
```

The constraint is written as:

```go
type OrderedNumber interface {
	~int | ~int64 | ~float64
}
```

All these types support the `<` operator.

That is why inside the generic function we can write:

```go
if a < b
```

For the first call:

```go
min(8, 3)
```

the compiler determines that:

```text
T = int
```

The check:

```text
8 < 3 -> false
```

That is why:

```text
3
```

is returned.

For the second call:

```go
min(4.5, 7.2)
```

we have:

```text
T = float64
```

The check:

```text
4.5 < 7.2 -> true
```

The result:

```text
4.5
```

Here both arguments have the same type `T`.

The result is also exactly `T`.

That is why the type connection is kept.

`comparable` would not have been enough for this function. The reason is that `comparable` only guarantees `==` and `!=`, not `<`.

### 6. Summing a named number type

This example shows why the `~` symbol in a constraint is needed.

```go
package main

import "fmt"

type Addable interface {
	~int | ~float64
}

type Distance int

func sum[T Addable](values []T) T {
	var total T
	for _, value := range values {
		total += value
	}
	return total
}

func main() {
	distances := []Distance{12, 8, 15}
	prices := []float64{10.5, 4.25}

	fmt.Println(sum(distances))
	fmt.Println(sum(prices))
}
```

Here:

```go
type Distance int
```

creates a new named type.

`Distance` is not exactly `int`.

But its underlying type is `int`.

The constraint says:

```go
~int
```

That is why `Distance` also matches the `Addable` constraint.

If the constraint had the form:

```go
type Addable interface {
	int | float64
}
```

`Distance` would not match.

Inside `sum()` we wrote:

```go
var total T
```

If:

```text
T = Distance
```

then `total` gets the zero value of the `Distance` type.

Because the underlying type of `Distance` is `int`, the zero value is:

```text
0
```

Then the values are added one after another:

```text
0 + 12 = 12
12 + 8 = 20
20 + 15 = 35
```

The result:

```text
35
```

For `prices`:

```text
0 + 10.5 = 10.5
10.5 + 4.25 = 14.75
```

The result:

```text
14.75
```

Starting the sum from `0` is correct, because adding `0` does not change the result.

### 7. Converting slice elements to another type

This example shows how two different type parameters work in one function.

The input element can be of one type, and the result of another.

```go
package main

import "fmt"

func transform[T any, R any](values []T, convert func(T) R) []R {
	result := make([]R, 0, len(values))
	for _, value := range values {
		result = append(result, convert(value))
	}
	return result
}

func main() {
	numbers := []int{3, 5, 8}
	labels := transform(numbers, func(value int) string {
		return fmt.Sprintf("num=%d", value)
	})

	fmt.Println(labels)
}
```

The function takes two type parameters:

```go
[T any, R any]
```

`T` is the input element type.

`R` is the result element type.

In our example we have:

```go
numbers := []int{3, 5, 8}
```

That is why:

```text
T = int
```

The `convert` function has the form:

```go
func(value int) string
```

So:

```text
R = string
```

That is why `transform()` in practice performs the conversion:

```text
[]int -> []string
```

The process:

```text
3 -> "num=3"
5 -> "num=5"
8 -> "num=8"
```

The result:

```text
[num=3 num=5 num=8]
```

The result slice is created with:

```go
result := make([]R, 0, len(values))
```

Its length is `0` at the start, because there are no results yet.

The capacity equals the length of the input slice.

The reason is that one result is created for each input element.

For example, if `values` has 3 elements, the final `result` has 3 elements too.

This pattern is similar to the operation often called `map` or `transform` in other languages.

### 8. Filtering elements that match a condition

In this example the generic function does not check the elements itself.

The checking rule is given through a separate function.

```go
package main

import "fmt"

func filter[T any](values []T, keep func(T) bool) []T {
	result := make([]T, 0, len(values))
	for _, value := range values {
		if keep(value) {
			result = append(result, value)
		}
	}
	return result
}

func main() {
	even := filter([]int{1, 2, 3, 4, 5, 6}, func(value int) bool {
		return value%2 == 0
	})
	long := filter([]string{"Go", "api", "generics"}, func(value string) bool {
		return len(value) >= 3
	})

	fmt.Println(even)
	fmt.Println(long)
}
```

`filter()` itself has no special knowledge about the `T` value.

It only looks at the result of:

```go
keep(value)
```

If it returns `true`, the element is added to the result with:

```go
result = append(result, value)
```

If it returns `false`, the element is skipped.

In the first example:

```go
value%2 == 0
```

detects even numbers.

The values:

```text
1 -> false
2 -> true
3 -> false
4 -> true
5 -> false
6 -> true
```

The result:

```text
[2 4 6]
```

In the second example:

```go
len(value) >= 3
```

checks the string length.

The values:

```text
"Go"       -> 2 -> false
"api"      -> 3 -> true
"generics" -> 8 -> true
```

The result:

```text
[api generics]
```

Note that here:

```go
>= 3
```

is used.

So a value whose length is exactly `3` is also taken.

If:

```go
> 3
```

had been written, `"api"` would not have made it into the result.

Because no type-specific operator is used in `filter()` itself:

```go
T any
```

is enough.

### 9. Storing values of two different types in one struct

A generic type can also have several type parameters.

In this example `Pair` stores two different values together.

```go
package main

import "fmt"

type Pair[K any, V any] struct {
	Key   K
	Value V
}

func main() {
	stock := Pair[string, int]{Key: "notebook", Value: 25}
	point := Pair[int, float64]{Key: 7, Value: 18.5}

	fmt.Println(stock.Key, stock.Value)
	fmt.Println(point.Key, point.Value)
}
```

The struct declaration:

```go
type Pair[K any, V any] struct
```

has two independent type parameters.

`K` and `V` do not have to be the same type.

For the first value:

```go
Pair[string, int]
```

we have:

```text
K = string
V = int
```

That is why it works like:

```go
Key string
Value int
```

For the second value:

```go
Pair[int, float64]
```

we have:

```text
K = int
V = float64
```

This time the struct in practice has the fields:

```go
Key   int
Value float64
```

No:

* equality;
* arithmetic;
* ordering

operations are performed on the values inside the struct.

That is why for both type parameters:

```go
any
```

is enough.

This generic type shows that the same data structure can be reused with different combinations of types.

### 10. Creating a generic queue

In this example a generic `Queue` is created.

A queue works on the FIFO principle:

```text
First In, First Out
```

That is, the first added element is taken first.

```go
package main

import "fmt"

type Queue[T any] struct {
	items []T
}

func (q *Queue[T]) Add(value T) {
	q.items = append(q.items, value)
}

func (q *Queue[T]) Remove() (T, bool) {
	if len(q.items) == 0 {
		var zero T
		return zero, false
	}

	value := q.items[0]
	q.items = q.items[1:]
	return value, true
}

func main() {
	var queue Queue[string]
	queue.Add("first")
	queue.Add("second")

	first, firstOK := queue.Remove()
	second, secondOK := queue.Remove()
	emptyValue, emptyOK := queue.Remove()

	fmt.Println(first, firstOK)
	fmt.Println(second, secondOK)
	fmt.Printf("%q %t\n", emptyValue, emptyOK)
}
```

The queue is created like this:

```go
type Queue[T any] struct {
	items []T
}
```

`T` means the type of the elements stored in the queue.

We wrote:

```go
var queue Queue[string]
```

So:

```text
T = string
```

### Adding an element

```go
func (q *Queue[T]) Add(value T) {
	q.items = append(q.items, value)
}
```

`Add()` adds a new element to the end of the slice.

First:

```go
queue.Add("first")
```

The result:

```text
["first"]
```

Then:

```go
queue.Add("second")
```

The result:

```text
["first", "second"]
```

### Taking an element

A queue must take the oldest element.

The oldest element is at the start of the slice, that is, at index `0`:

```go
value := q.items[0]
```

The first `Remove()`:

```text
value = "first"
```

Then:

```go
q.items = q.items[1:]
```

runs.

This removes the element at index `0` from the new view of the slice.

As a result:

```text
["second"]
```

remains.

The second `Remove()`:

```text
value = "second"
```

Then the queue becomes empty.

### The empty queue case

When:

```go
queue.Remove()
```

is called for the third time:

```go
len(q.items) == 0
```

holds.

That is why:

```go
var zero T
return zero, false
```

runs.

Here:

```text
T = string
```

That is why the zero value of `string` is:

```text
""
```

The result:

```text
"" false
```

`false` means there are no elements in the queue.

Several generics rules appear at once in this example:

* a generic type;
* a method of a generic type;
* writing `Queue[T]` in the receiver;
* getting the zero value of `T`;
* choosing the element type freely through `T any`;
* after `Queue[string]` is created, the methods work only with `string`.

## Testing generic code

A generic function can work with several types. That is why it helps to check the needed type variants separately in tests.

```go
package main

import "testing"

type Number interface {
	~int | ~float64
}

func max[T Number](a, b T) T {
	if a > b {
		return a
	}

	return b
}

func TestMax(t *testing.T) {
	t.Run("int", func(t *testing.T) {
		if got := max(4, 9); got != 9 {
			t.Errorf("max(4, 9) = %d; want 9", got)
		}
	})

	t.Run("float64", func(t *testing.T) {
		if got := max(7.5, 2.5); got != 7.5 {
			t.Errorf("max(7.5, 2.5) = %g; want 7.5", got)
		}
	})
}
```

The two subtests check the same generic function with `int` and `float64` values. The compiler determines the type `T` from the arguments of each call. The tests can be run as usual with the following command:

```bash
go test ./...
```
