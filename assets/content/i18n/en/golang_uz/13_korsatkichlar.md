# Pointers

A pointer lets you refer to the address of a variable in memory. It makes it possible to change one value from
different places and to pass a large structure without copying it.

## The `&` and `*` operators

- `&x` — takes the address of the variable `x`.
- `*p` — lets you read or change the value that `p` refers to.
- `*int` — denotes the type of a pointer to a value of type `int`.

```go
package main

import "fmt"

func main() {
	x := 10
	p := &x

	fmt.Println("Value:", x)
	fmt.Println("Through the pointer:", *p)
	*p = 20
	fmt.Println("New value:", x)
}
```

Output:

```text
Value: 10
Through the pointer: 10
New value: 20
```

The type of `p` is `*int`. `*p = 20` does not create a new pointer. This operation changes the value of `x`, which `p`
refers to. An address can be printed with `&p`, but its exact value may change every time the program runs. Program
logic should not depend on this address.

## Changing a value through a pointer

When an ordinary variable is given a new value, only that variable's value changes:

```go
package main

import "fmt"

func main() {
	num := 10
	copied := num

	copied++

	fmt.Println("num:", num)
	fmt.Println("copied:", copied)
}
```

Output:

```text
num: 10
copied: 11
```

When `copied := num` is written, the value of `num` is copied into another variable. After that, `copied` and `num` are
two separate variables. Changing `copied` does not affect `num`.

With a pointer, however, you can refer to the other variable itself:

```go
package main

import "fmt"

func main() {
	num := 10
	p := &num

	*p++

	fmt.Println(num)
}
```

Output:

```text
11
```

`p := &num` stores the address of the variable `num` in `p`. `*p` refers to the value stored at that address.

That is why:

```go
*p++
```

means the same as:

```go
(*p)++
```

That is, the value that `p` refers to is increased by one.

There is an important difference here:

```go
num := 10
copied := num
```

copies the value.

The following code, on the other hand:

```go
num := 10
p := &num
```

lets you refer to `num` itself.

A pointer is not always needed. If you need two independent values, a plain copy is clearer. A pointer is useful when
the same value must be seen or changed from another place, and it does so without allocating extra memory.

## Pointers and the lifetime of a value

As long as a pointer exists, the value it refers to must also stay valid.

For example:

```go
package main

import "fmt"

func main() {
	var p *int

	{
		num := 13
		p = &num
	}

	fmt.Println(*p)
}
```

Output:

```text
13
```

Even though `num` was created inside an inner block, its address is used outside through `p`.

The Go compiler determines how long a value must be kept. When needed, the lifetime of a value is managed to match the
pointer that uses it.

The programmer does not free such memory by hand as in C. Go manages memory automatically.

This feature makes code like:

```go
p = &num
```

safe to use.

## Equality of pointers

Two pointers are equal if they refer to the same variable:

```go
package main

import "fmt"

func main() {
	x := 5

	p1 := &x
	p2 := &x

	y := 5
	p3 := &y

	fmt.Println(p1 == p2)
	fmt.Println(p1 == p3)
}
```

Output:

```text
true
false
```

`p1` and `p2` store the address of the same variable `x`. That is why:

```go
p1 == p2
```

is `true`.

The values of `x` and `y` are the same:

```go
x == y
```

but they are two separate variables in memory.

That is why:

```go
p1 == p3
```

is `false`.

Here the equality of pointers means not that **the values they refer to are equal**, but that they refer to the same
place.

A pointer can be compared with another pointer of a matching type or with `nil`.

## The `nil` pointer

The zero value of a pointer is `nil`.

For example:

```go
package main

import "fmt"

func main() {
	var p *int

	fmt.Println(p)
	fmt.Println(p == nil)
}
```

Output:

```text
<nil>
true
```

The following part:

```go
var p *int
```

declares `p` as a pointer of type `*int`, but it has not yet been given the address of any `int` variable.

That is why its value is:

```go
nil
```

Later it can be given a valid address:

```go
package main

import "fmt"

func main() {
	var p *int

	num := 13
	p = &num

	fmt.Println(p == nil)
	fmt.Println(*p)
}
```

Output:

```text
false
13
```

You cannot access a value through a `nil` pointer.

For example:

```go
var p *int
fmt.Println(*p)
```

causes a `panic` while the program runs.

```shell
panic: runtime error: invalid memory address or nil pointer dereference
[signal 0xc0000005 code=0x0 addr=0x0 pc=0x7ff781d44b96]
```

That is why, when a pointer may be `nil`, check it first:

```go
if p != nil {
    fmt.Println(*p)
}
```

A `nil` pointer lets you express the state "I don't refer to any value yet".

## Creating a pointer with `new`

`new(T)` creates a new variable with the zero value of type `T` and gives a pointer of type `*T` to it.

For example:

```go
package main

import "fmt"

func main() {
	p := new(int)

	fmt.Println(*p)

	*p = 13

	fmt.Println(*p)
}
```

Output:

```text
0
13
```

The zero value of the `int` type is `0`.

That is why, after writing:

```go
p := new(int)
```

the value of:

```go
*p
```

is `0`.

Then with:

```go
*p = 13
```

that value was changed.

The result of `new` is not a plain value but a pointer:

```go
p := new(int)
```

here the type of `p` is:

```go
*int
```

It is often clearer to create an ordinary local variable and take its address:

```go
x := 0
p := &x
```

This code gives a similar result to:

```go
p := new(int)
```

`new` and `make` do not do the same job.

`new(T)` gives a pointer of type:

```text
*T
```

`make` is used only for:

* slices;
* maps;
* channels

and creates a value that is ready to use.

## Go has no pointer arithmetic

In some languages, such as C and C++, a pointer's address can be changed with arithmetic operations.

For example, in Go you cannot write the following with an ordinary pointer:

```go
p++
```

or:

```go
p + 1
```

Go does not allow pointer arithmetic in ordinary code.

This restriction prevents some bugs that can arise from working with memory addresses incorrectly.

For special low-level tasks, Go has the `unsafe` package. But it should not be used in everyday programs.

Using a pointer also does not mean the value is necessarily stored in `heap` memory.

The Go compiler determines where a value is stored through **escape analysis**. Depending on the situation, a value may
stay on the stack or be placed on the `heap`.

That is why the idea:

> "If I use a pointer, the code will definitely run faster"

is not correct.

When choosing a pointer, the problem at hand comes first. Where performance matters, it is right to measure instead of
guessing.

## Slices, maps and pointers

A slice is not a plain array itself. It stores a descriptor that refers to the data in an underlying array.

For example:

```go
package main

import "fmt"

func main() {
	numbers := []int{10, 20, 30}
	other := numbers

	other[0] = 100

	fmt.Println(numbers)
	fmt.Println(other)
}
```

Output:

```text
[100 20 30]
[100 20 30]
```

When `other := numbers` is written, the slice descriptor is copied. But both `slice`s refer to the elements in the same
underlying array.

That is why the change:

```go
other[0] = 100
```

is visible through `numbers` too. So to change the elements of a `slice`, you usually do not need a pointer to a
`slice` such as `*[]int`.

A similar situation exists with a `map`:

```go
package main

import "fmt"

func main() {
	dict := map[string]int{
		"go": 2009,
	}

	other := dict
	other["python"] = 1991

	fmt.Println(dict)
}
```

`dict` and `other` refer to the same map data. That is why an element added through `other` is visible through `dict`
too.

When `append` is used with a slice, there is a special point:

```go
package main

import "fmt"

func main() {
	numbers := []int{10, 20, 30}

	numbers = append(numbers, 40)

	fmt.Println(numbers)
}
```

`append` gives a new slice value. If there is not enough capacity, Go may also allocate a new underlying array.

That is why, when working with a slice, saving its new state in the form:

```go
numbers = append(numbers, 40)
```

is the usual approach.

Where the built-in behavior of a `slice` or a `map` is enough, adding an extra pointer to them can make the code
unnecessarily complex.

## When should you not use a pointer?

A pointer gives you a capability, but you don't have to use it for every value.

In the following cases a plain value may be enough:

* the value is small and cheap to copy;
* you need two independent values;
* the original value does not need to be changed from another place;
* the `nil` state brings unnecessary complexity into the code;
* the built-in behavior of a `slice`, `map` or `channel` already gives the reference semantics you need.

For example:

```go
x := 10
y := x
```

is the right way if `x` and `y` must change independently.

But when you write:

```go
x := 10
p := &x
```

you can change `x` itself through `p`.

Turning every variable into a pointer does not automatically make code faster. On the contrary, if the same value can
be changed from several places, it becomes hard to track where the data changed. That is why a pointer should be used
when its capability is needed, not just because of the idea that "using pointers is good".

## Examples

### 1. Swapping two values through pointers

```go
package main

import "fmt"

func main() {
	x, y := 10, 20

	px := &x
	py := &y

	*px, *py = *py, *px

	fmt.Println(x, y)
}
```

Output:

```text
20 10
```

`px` refers to `x` and `py` refers to `y`.

The following statement:

```go
*px, *py = *py, *px
```

swaps the two values the pointers refer to.

The pointers themselves are not swapped. What changes are the values of `x` and `y` they refer to.

### 2. Storing two results through pointers

```go
package main

import "fmt"

func main() {
	a, b := 17, 5

	var quotient int
	var remainder int

	pQuotient := &quotient
	pRemainder := &remainder

	*pQuotient = a / b
	*pRemainder = a % b

	fmt.Println(quotient, remainder)
}
```

Output:

```text
3 2
```

`pQuotient` and `pRemainder` refer to two separate variables.

```go
*pQuotient = a / b
```

changes the value of `quotient`.

```go
*pRemainder = a % b
```

changes the value of `remainder`.

This example shows that several pointers can refer to different values and change them separately.

### 3. Representing an optional value with `nil`

Sometimes you need to tell the value `0` apart from the state "the value is not set at all".

```go
package main

import "fmt"

func main() {
	var discount *int

	if discount == nil {
		fmt.Println("Discount not set")
	}

	zero := 0
	discount = &zero

	if discount != nil {
		fmt.Println("Discount:", *discount)
	}
}
```

Output:

```text
Discount not set
Discount: 0
```

In the first case:

```go
discount == nil
```

that is, the discount value is not set at all.

In the second case the pointer exists, and it refers to the value `0`.

So:

```text
nil
```

and:

```text
0
```

are not the same state.

A pointer lets you tell apart the states "there is no value" and "there is a value, and it is zero".

### 4. Creating values of different types with `new`

```go
package main

import "fmt"

func main() {
	active := new(bool)
	name := new(string)

	fmt.Println(*active)
	fmt.Println(*name)

	*active = true
	*name = "Go"

	fmt.Println(*active, *name)
}
```

At first:

```go
new(bool)
```

creates a pointer to a `bool` with the value `false`.

```go
new(string)
```

creates a pointer to a `string` with the empty string value.

Then with:

```go
*active = true
*name = "Go"
```

the values the pointers refer to are changed.

### 5. A copy of a pointer looks at the same value

```go
package main

import "fmt"

func main() {
	num := 5

	first := &num
	second := first

	*second = 25

	fmt.Println(*first, num)
}
```

Output:

```text
25 25
```

The following statement:

```go
second := first
```

does not copy the value of `num`.

Here the value of the pointer, that is, the address, is copied.

As a result:

```go
first
```

and:

```go
second
```

refer to the same variable `num`.

That is why, after writing:

```go
*second = 25
```

`25` is visible through `*first` too.

### 6. Checking whether pointers look at one object

```go
package main

import "fmt"

func main() {
	num := 13

	a := &num
	b := a

	c := new(int)
	*c = 13

	fmt.Println(a == b)
	fmt.Println(a == c)
}
```

Output:

```text
true
false
```

`a` and `b` refer to the same variable `num`.

That is why:

```go
a == b
```

is `true`.

`c` also refers to the value `13`, but it is a different variable.

That is why:

```go
a == c
```

is `false`.

Pointer equality checks not whether the values they refer to are equal, but whether they refer to the same object.

### 7. Taking a pointer to a slice element

```go
package main

import "fmt"

func main() {
	numbers := []int{10, 20, 30}

	p := &numbers[1]

	*p = 99

	fmt.Println(numbers)
}
```

Output:

```text
[10 99 30]
```

The following statement:

```go
p := &numbers[1]
```

takes the address of the second element in the slice.

Then:

```go
*p = 99
```

changes the original value of that element.

That is why the change is visible in the `numbers` slice too.

There is an important point here. When `append` is used later, a new underlying array may be allocated for the slice:

```go
numbers = append(numbers, 40, 50, 60)
```

If a new array is created, `numbers` starts referring to the new array. But the earlier `p` may keep referring to the
element in the previous array.

That is why, when taking long-lived pointers to slice elements, you must also consider how the slice may change later.

### 8. A linked list node

With pointers you can build data structures in which one object refers to another.

For example:

```go
package main

import "fmt"

type Node struct {
	Value int
	Next  *Node
}

func main() {
	third := &Node{
		Value: 30,
	}

	second := &Node{
		Value: 20,
		Next:  third,
	}

	first := &Node{
		Value: 10,
		Next:  second,
	}

	fmt.Println(first.Value)
	fmt.Println(first.Next.Value)
	fmt.Println(first.Next.Next.Value)
	fmt.Println(first.Next.Next.Next)
}
```

Output:

```text
10
20
30
<nil>
```

Besides its own value, each `Node` stores a pointer to the next node:

```go
Next *Node
```

`first.Next` refers to the `second` node.

`second.Next` refers to the `third` node.

In the `third` node, `Next` is not given a value. Because the zero value of the `*Node` pointer is `nil`:

```go
third.Next
```

is `nil`.

In this way one object is connected to another through a pointer. This is also one of the main ideas behind data
structures such as a linked list.
