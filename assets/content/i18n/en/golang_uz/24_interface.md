# Interfaces in Go

An **interface** defines not what data a type stores, but what behavior it can perform.

In other words, struct fields are not written inside an interface. Instead, it states which methods a type must have.

For example, suppose we need a type that can send a message.

For that, whether the type:

* stores an email address;
* keeps a phone number somewhere;
* uses an HTTP API;
* uses SMTP;

may not matter to us.

We need only one thing:

```go
Send(message string) error
```

that this method exists.

Then an interface can be declared like this:

```go
type Sender interface {
    Send(message string) error
}
```

Now any type that has a `Send(string) error` method matches the `Sender` interface.

In Go there is no need to write, as in languages like Java or C#, the keyword:

```text
implements
```

For example, you don't write:

```text
EmailSender implements Sender
```

Go has no need for it.

If the `EmailSender` type has all the methods the interface requires, Go automatically considers it to implement that interface.

This is called **implicit interface implementation**.

One of the main benefits of an interface is not tying code to one specific struct.

For example, the following function:

```go
func Notify(sender Sender, message string) error
```

does not require `EmailSender`, `SMSSender`, `TelegramSender` or any other concrete type.

It requires only the:

```go
Sender
```

interface.

So the value passed to the function must answer not the requirement:

> "Which struct are you?"

but the requirement:

> "Can you perform the `Send()` method?"

This is one of the most important ideas of interfaces.

## Declaring and implementing an interface

Let's look at the following example:

```go
package main

import "fmt"

type Sender interface {
	Send(message string) error
}

type EmailSender struct {
	Address string
}

func (e EmailSender) Send(message string) error {
	if e.Address == "" {
		return fmt.Errorf("the email address is empty")
	}

	fmt.Printf("To %s: %s\n", e.Address, message)
	return nil
}

func Notify(sender Sender, message string) error {
	return sender.Send(message)
}

func main() {
	email := EmailSender{
		Address: "user@example.com",
	}

	if err := Notify(email, "The order is ready"); err != nil {
		fmt.Println("Error:", err)
	}
}
```

Output:

```text
To user@example.com: The order is ready
```

Let's look at the important parts of the code separately.

First the interface:

```go
type Sender interface {
    Send(message string) error
}
```

This code expresses the requirement:

> a type that wants to be a `Sender` must have a `Send(string) error` method

Then there is the `EmailSender` type:

```go
type EmailSender struct {
    Address string
}
```

This is an ordinary struct.

It stores an email address.

Then a method is written for it:

```go
func (e EmailSender) Send(message string) error
```

The signature of this method is exactly the same as the method inside the interface:

```go
Send(message string) error
```

That is why:

```go
EmailSender
```

automatically implements the `Sender` interface.

Nowhere did we separately state:

```text
EmailSender implements the Sender interface
```

Go determines this itself by looking at the method set.

That is why the following code works:

```go
email := EmailSender{
    Address: "user@example.com",
}

Notify(email, "The order is ready")
```

And the `Notify()` function is written like this:

```go
func Notify(sender Sender, message string) error {
    return sender.Send(message)
}
```

This function knows nothing about `EmailSender`.

It does not know about the:

```go
Address
```

field either.

How the email is sent does not matter to it either.

The function knows only one thing:

```go
sender.Send(message)
```

can be called.

That is why later we can write another type:

```go
type SMSSender struct {
    Phone string
}
```

and if we add the method:

```go
func (s SMSSender) Send(message string) error {
    // send an SMS
    return nil
}
```

to it, `SMSSender` also automatically matches `Sender`.

And the `Notify()` function does not need to change:

```go
Notify(emailSender, "Hello")
Notify(smsSender, "Hello")
```

Both can work.

### Checking interface implementation at compile time

Sometimes it helps to explicitly check in the code itself that a certain type implements an interface.

In Go the following technique is often used for this:

```go
var _ Sender = EmailSender{}
```

Here `_` is the blank identifier.

We don't need the value itself.

With this line we tell the compiler:

> check that an `EmailSender` value can be used as a `Sender`

If `EmailSender` does not match the `Sender` interface, the code does not compile.

For example, if the method is written incorrectly:

```go
func (e EmailSender) Send(message string) {
}
```

it does not match the `Sender` interface.

The reason is that the interface requires the method:

```go
Send(message string) error
```

But our method turned out to be:

```go
Send(message string)
```

So having the same method name alone is not enough.

All of the following must match:

* the method name;
* the number of parameters;
* the parameter types;
* the parameter order;
* the return values;
* the types of the return values.

For example:

```go
Send(string) error
```

and:

```go
Send([]byte) error
```

are two different method signatures.

That is why the second does not implement an interface that requires the first.

## Small interfaces

In Go **small interfaces** are usually preferred.

That is, as far as possible only the methods that are really needed are written inside an interface.

For example, if a function only needs to read data, there is no need to give it a big interface like this:

```go
type Storage interface {
    Read()
    Write()
    Delete()
    Update()
    Close()
    Backup()
    Restore()
}
```

If the function only reads, one method may be enough for it:

```go
type Reader interface {
    Read([]byte) (int, error)
}
```

This has several benefits.

First, a small interface is easy to implement.

If an interface requires one method:

```go
type Sender interface {
    Send(string) error
}
```

adding just that method to a new type is enough.

If an interface requires ten methods, a type must have ten methods to implement it.

Second, a small interface makes writing tests easier.

For example, in a test you can create a small test type instead of a real email service:

```go
type FakeSender struct{}

func (FakeSender) Send(message string) error {
    return nil
}
```

`FakeSender` matches the `Sender` interface.

That is why there is no need to send a real email in the test.

Third, a small interface is more convenient to reuse.

One of the best-known examples in the Go standard library is the:

```go
io.Reader
```

interface.

It requires only one method:

```go
Read(p []byte) (n int, err error)
```

Even so, a great many types can be used as an `io.Reader`:

* a file;
* an HTTP response body;
* a buffer;
* a TCP connection;
* a compressed data stream;
* a string in memory.

Their internal structure differs.

But if all of them can provide data through:

```go
Read(...)
```

code that works with `io.Reader` can use them.

### The interface is often declared by the side that uses it

One of the important practical principles in Go:

> An interface is often declared not by the type that implements it, but by the code that uses it.

For example, the `EmailSender` package itself does not have to declare a big:

```go
Sender
```

interface.

If another package needs only:

```go
Send(string) error
```

that package can create its own small interface.

This couples components to each other less.

## Embedding an interface in another interface

In Go you can place one interface inside another interface.

This is called **interface embedding**.

For example:

```go
type Reader interface {
    Read([]byte) (int, error)
}

type Writer interface {
    Write([]byte) (int, error)
}
```

There are two separate interfaces here.

`Reader` means a type that can read data.

`Writer` means a type that can write data.

Now both can be combined:

```go
type ReadWriter interface {
    Reader
    Writer
}
```

The meaning of this code:

> To be a `ReadWriter`, you must meet the requirements of both `Reader` and `Writer`.

That is, in practice `ReadWriter` equals:

```go
type ReadWriter interface {
    Read([]byte) (int, error)
    Write([]byte) (int, error)
}
```

But by embedding interfaces you can build a new interface out of existing small interfaces.

For example, if a type has only:

```go
Read(...)
```

it implements `Reader`.

If it has only:

```go
Write(...)
```

it implements `Writer`.

If it has both:

```go
Read(...)
Write(...)
```

it also implements `ReadWriter`.

This technique helps create larger behavior by combining small interfaces.

## Dynamic type and dynamic value

To understand interfaces correctly, it is important to know how a value is stored inside them.

An interface value can be pictured, in simplified form, as two parts:

* the **dynamic type**;
* the **dynamic value**.

### What is the dynamic type?

The dynamic type is the concrete type of the value currently stored in the interface.

For example:

```go
var value any = 15
```

Here the static type of the variable is:

```go
any
```

but the concrete type of the value inside it is:

```go
int
```

So the dynamic type is:

```text
int
```

### What is the dynamic value?

The dynamic value is the actual value stored in the interface.

In the example above:

```go
var value any = 15
```

the dynamic type is:

```text
int
```

and the dynamic value is:

```text
15
```

Let's look at the following example:

```go
package main

import "fmt"

func main() {
	var value any = 15

	fmt.Printf("Type: %T, value: %v\n", value, value)

	value = "Go"

	fmt.Printf("Type: %T, value: %v\n", value, value)
}
```

Output:

```text
Type: int, value: 15
Type: string, value: Go
```

At first, when we have:

```go
var value any = 15
```

the interface stores:

```text
dynamic type  = int
dynamic value = 15
```

Then we replaced the value with:

```go
value = "Go"
```

Now the interface stores:

```text
dynamic type  = string
dynamic value = "Go"
```

The interface variable itself is still of type:

```go
any
```

But the concrete type inside it can change at runtime.

### What is `any`?

In Go:

```go
any
```

is an alias of:

```go
interface{}
```

That is:

```go
any
```

and:

```go
interface{}
```

mean the same thing.

The empty interface:

```go
interface{}
```

requires no methods.

Every type in Go satisfies at least the condition of "requiring zero methods".

That is why `any` can hold a value of any type:

```go
var value any

value = 15
value = "Go"
value = true
value = []int{1, 2, 3}
value = struct{}{}
```

All of these are possible.

But that is also the drawback of `any`.

For example, if we write:

```go
func process(value any)
```

the function does not know in advance what can be done with `value`.

It may be an `int`.

It may be a `string`.

It may be a struct or a slice.

That is why, where possible, instead of:

```go
any
```

it is better to use a specific interface that expresses the needed behavior.

For example:

```go
type Sender interface {
    Send(string) error
}
```

This gives a much stronger requirement than `any`.

Inside the function we know that at least:

```go
sender.Send(...)
```

can be called.

In some cases generics can also give better type safety than an interface.

But interfaces and generics do not do the same job.

An interface is more about behavior. It answers the question:

> "What can this value do?"

## The `nil` interface trap

One of the most confusing topics when working with interfaces is `nil`.

With an ordinary pointer the situation is clear:

```go
var pointer *MyError
```

If it is not given a value:

```go
pointer == nil
```

the result is:

```text
true
```

An interface works a bit differently.

We pictured an interface as the following two parts:

```text
(dynamic type, dynamic value)
```

An interface is `nil` only when both parts are absent.

That is, a real `nil` interface looks roughly like:

```text
(nil, nil)
```

Let's look at the following example:

```go
package main

import "fmt"

type MyError struct{}

func (e *MyError) Error() string {
	return "error"
}

func main() {
	var pointer *MyError

	var err error = pointer

	fmt.Println(pointer == nil)
	fmt.Println(err == nil)
	fmt.Printf("%T %v\n", err, err)
}
```

Output:

```text
true
false
*main.MyError error
```

At first glance this may look strange.

We have:

```go
var pointer *MyError
```

It was not given any value.

So the result of:

```go
pointer == nil
```

is:

```text
true
```

That is correct.

Then we placed the pointer into the `error` interface with:

```go
var err error = pointer
```

`MyError` implements the `error` interface, because it has the method:

```go
Error() string
```

But now `err` contains information.

Its state can be pictured like this:

```text
dynamic type  = *MyError
dynamic value = nil
```

That is:

```text
(*MyError, nil)
```

For the interface to be entirely `nil`, it would have had to be:

```text
(nil, nil)
```

But we have a dynamic type:

```text
*MyError
```

That is why the result of:

```go
err == nil
```

is:

```text
false
```

This is one of the situations called the **typed nil** problem.

### The typed nil problem in a function returning `error`

Code like the following can be dangerous:

```go
func doSomething() error {
    var err *MyError

    return err
}
```

A developer may think:

> the `err` pointer is `nil`, so the function returns `nil`

But the type the function returns is the:

```go
error
```

interface.

When a `*MyError` pointer is placed into the `error` interface, the dynamic type is kept.

As a result, the returned interface has the form:

```text
(*MyError, nil)
```

That is why the situation:

```go
if err != nil {
    // this block may run
}
```

occurs.

In the success case, a function returning `error` should directly return:

```go
return nil
```

For example:

```go
func doSomething() error {
    // everything succeeded

    return nil
}
```

In this case the interface really is:

```text
(nil, nil)
```

## Type assertion

You may need to get exactly which type of value is stored inside an interface.

**Type assertion** is used for this.

For example:

```go
var value any = "Go"
```

We want to know whether the value inside `value` is a `string`.

We can write:

```go
text := value.(string)
```

This means:

> if the dynamic type inside `value` is `string`, take its value

If `value` really holds:

```go
"Go"
```

then after:

```go
text := value.(string)
```

we get:

```go
text == "Go"
```

But this technique has a dangerous side.

If:

```go
var value any = 15
```

and we write:

```go
text := value.(string)
```

the program will `panic`.

The reason is that the dynamic type is:

```text
int
```

but we are demanding:

```text
string
```

### The `comma ok` form

To use type assertion more safely, the form:

```go
value, ok := interfaceValue.(Type)
```

is usually used.

For example:

```go
var value any = "Go"

text, ok := value.(string)
```

If the dynamic type is `string`, we get:

```text
text = "Go"
ok   = true
```

If:

```go
var value any = 15
```

then after:

```go
text, ok := value.(string)
```

we get:

```text
text = ""
ok   = false
```

The program does not `panic`.

`text` gets the zero value of the `string` type:

```text
""
```

That is why, when checking the type inside an interface, the technique:

```go
v, ok := value.(string)
```

is often safer.

## Type switch

If the value inside an interface can be one of several types, writing many type assertions one after another is inconvenient.

For example:

```go
if v, ok := value.(int); ok {
    ...
}

if v, ok := value.(string); ok {
    ...
}

if v, ok := value.(bool); ok {
    ...
}
```

For such a case Go has the **type switch**.

Example:

```go
package main

import "fmt"

func describe(value any) {
	switch v := value.(type) {
	case int:
		fmt.Println("Integer:", v)

	case string:
		fmt.Println("String:", v)

	default:
		fmt.Printf("Another type: %T\n", v)
	}
}

func main() {
	describe(15)
	describe("Go")
}
```

Output:

```text
Integer: 15
String: Go
```

The main part of the type switch:

```go
switch v := value.(type) {
```

In an ordinary type assertion we write the concrete type:

```go
value.(string)
```

In a type switch, however, the special form:

```go
value.(type)
```

is used.

Then the needed types are checked through `case`:

```go
case int:
```

If the dynamic type is `int`, this block runs.

```go
case string:
```

If the dynamic type is `string`, this block runs.

For example, when:

```go
describe(15)
```

is called:

```text
dynamic type = int
```

That is why:

```go
case int:
```

is chosen.

Inside this block the type of `v` is also:

```go
int
```

That is why it can be used directly:

```go
fmt.Println("Integer:", v)
```

When `describe("Go")` is called, `v` is a `string`.

If no `case` matches, the:

```go
default:
```

block runs.

A type switch is especially useful in code that works with `any`.

But overusing it is not good either.

If a function needs a certain method to work, writing a specific interface is often clearer than taking `any` and then checking the type.

## How a pointer receiver affects interfaces

In the earlier topic on methods we saw the concept of a **method set**.

It is especially important when working with interfaces.

Suppose:

```go
type Counter struct {
    Value int
}
```

and the method:

```go
func (c *Counter) Increment() {
    c.Value++
}
```

The receiver of this method is:

```go
*Counter
```

That is, a pointer receiver.

Now let the interface be:

```go
type Incrementer interface {
    Increment()
}
```

The question: does

```go
Counter
```

implement the interface?

No.

But:

```go
*Counter
```

does.

The reason is the method set rule.

In simplified form, the method set of:

```text
T
```

includes the methods written with a value receiver.

The method set of:

```text
*T
```

includes:

* methods with a `T` receiver;
* methods with a `*T` receiver.

Because we have:

```go
func (c *Counter) Increment()
```

`Increment()` belongs to the method set of `*Counter`.

That is why:

```go
var i Incrementer = &counter
```

works.

But:

```go
var i Incrementer = counter
```

does not compile.

Here you should not confuse the interface rule with Go automatically adding `&` in method calls.

For example:

```go
counter.Increment()
```

can work.

Go sees that the address of `counter` can be taken and in practice adjusts the call to the form:

```go
(&counter).Increment()
```

But during an interface assignment such as:

```go
var i Incrementer = counter
```

Go does not automatically do:

```go
&counter
```

Matching an interface is checked based on the type's actual method set.

## Examples

### 1. Different shapes through a small interface

```go
package main

import "fmt"

type Shape interface {
	Area() float64
}

type Square struct {
	Side float64
}

type Rectangle struct {
	Width  float64
	Height float64
}

func (s Square) Area() float64 {
	return s.Side * s.Side
}

func (r Rectangle) Area() float64 {
	return r.Width * r.Height
}

func printArea(s Shape) {
	fmt.Println(s.Area())
}

func main() {
	printArea(Square{
		Side: 4,
	})

	printArea(Rectangle{
		Width:  3,
		Height: 5,
	})
}
```

In this example:

```go
type Shape interface {
    Area() float64
}
```

the interface requires only one method:

```go
Area() float64
```

`Square` has the method:

```go
func (s Square) Area() float64
```

`Rectangle` also has the method:

```go
func (r Rectangle) Area() float64
```

That is why both types automatically implement the `Shape` interface.

Nowhere did we write:

```text
Square implements Shape
```

or:

```text
Rectangle implements Shape
```

Matching methods are enough.

The `printArea()` function:

```go
func printArea(s Shape)
```

does not require a concrete `Square` or `Rectangle`.

It only wants to be able to call the:

```go
Area()
```

method.

That is why both:

```go
printArea(Square{Side: 4})
```

and:

```go
printArea(Rectangle{Width: 3, Height: 5})
```

work.

For the function it does not matter which fields are inside the shape.

It needs only the ability to calculate the area.

### 2. A slice of interfaces

```go
package main

import "fmt"

type Named interface {
	Name() string
}

type City string

type Language string

func (c City) Name() string {
	return string(c)
}

func (l Language) Name() string {
	return string(l)
}

func main() {
	values := []Named{
		City("Tashkent"),
		Language("Go"),
	}

	for _, value := range values {
		fmt.Println(value.Name())
	}
}
```

An ordinary slice usually stores values of one type.

For example:

```go
[]string
```

stores only `string` values.

```go
[]int
```

stores only `int` values.

But this example uses an interface slice:

```go
[]Named
```

`City` and `Language` are two different concrete types:

```go
type City string
type Language string
```

But both have the method:

```go
Name() string
```

That is why both implement the:

```go
Named
```

interface.

As a result, in one slice we can store together the values:

```go
City("Tashkent")
```

and:

```go
Language("Go")
```

Inside the loop:

```go
for _, value := range values {
    fmt.Println(value.Name())
}
```

the code does not care whether the value is a:

```go
City
```

or a:

```go
Language
```

It just calls the `Name()` method.

This is one of the simple forms of polymorphism.

Different concrete types are used through one common behavior.

### 3. A small interface as a function parameter

```go
package main

import "fmt"

type Validator interface {
	Valid() bool
}

type Score int

func (s Score) Valid() bool {
	return s >= 0 && s <= 100
}

func check(v Validator) bool {
	return v.Valid()
}

func main() {
	fmt.Println(check(Score(86)))
}
```

Here:

```go
type Validator interface {
    Valid() bool
}
```

is a very small interface.

It requires only the method:

```go
Valid() bool
```

The `Score` type has the method:

```go
func (s Score) Valid() bool
```

That is why `Score` automatically matches `Validator`.

The `check()` function:

```go
func check(v Validator) bool
```

is not tied to the concrete `Score` type.

For it, what the value is does not matter.

It just needs to be able to call:

```go
v.Valid()
```

If later we create another type:

```go
type Age int
```

and write the method:

```go
func (a Age) Valid() bool {
    return a >= 0 && a <= 150
}
```

for it, `Age` can also be passed to this function:

```go
check(Age(29))
```

The `check()` function does not need to change.

This is one of the main benefits of small interfaces.

### 4. Type assertion on an empty interface

```go
package main

import "fmt"

func main() {
	var value any = "Go"

	text, ok := value.(string)

	fmt.Println(text, ok)
}
```

Here, after:

```go
var value any = "Go"
```

the interface stores:

```text
dynamic type  = string
dynamic value = "Go"
```

Then the type assertion:

```go
text, ok := value.(string)
```

was performed.

This is the check:

> is the concrete type inside `value` a `string`?

Because it really is a `string`:

```text
text = "Go"
ok   = true
```

The output is roughly:

```text
Go true
```

If the value had been:

```go
var value any = 15
```

the result of:

```go
text, ok := value.(string)
```

would be:

```text
text = ""
ok   = false
```

The most important point is that the program does not `panic`.

If the form:

```go
text := value.(string)
```

had been used and the dynamic type were not `string`, a runtime `panic` would occur.

That is why the `comma ok` form is safer in places where the type may not match.

### 5. Separating values with a type switch

```go
package main

import "fmt"

func show(value any) {
	switch v := value.(type) {
	case int:
		fmt.Println("Integer:", v)

	case string:
		fmt.Println("Text:", v)

	case bool:
		fmt.Println("Boolean:", v)

	default:
		fmt.Println("Unknown type")
	}
}

func main() {
	show(15)
	show("Go")
}
```

This function accepts:

```go
any
```

So different types can be passed to it.

For example:

```go
show(15)
show("Go")
show(true)
```

Inside the function:

```go
switch v := value.(type)
```

checks the dynamic type.

If the value is:

```go
15
```

the dynamic type is:

```text
int
```

That is why the:

```go
case int:
```

block runs.

Inside this block `v` also has the `int` type.

If:

```go
show("Go")
```

is called:

```go
case string:
```

is chosen.

This time `v` is of type:

```go
string
```

If:

```go
show(true)
```

is called:

```go
case bool:
```

runs.

If no `case` matches:

```go
default:
```

runs.

A type switch is convenient for checking several possible concrete types inside one interface in an orderly way.

### 6. The `nil` state of an interface

```go
package main

import "fmt"

func main() {
	var value any

	fmt.Println(value == nil)

	value = 0

	fmt.Println(value == nil)
}
```

First an interface was declared with:

```go
var value any
```

It was not given any value.

In simplified form it can be pictured as:

```text
dynamic type  = nil
dynamic value = nil
```

That is why the result of:

```go
value == nil
```

is:

```text
true
```

Then we wrote:

```go
value = 0
```

Sometimes `0` may look like an "empty value".

But `0` is a real `int` value.

Now the interface stores:

```text
dynamic type  = int
dynamic value = 0
```

That is why the result of:

```go
value == nil
```

is:

```text
false
```

The value inside an interface being a zero value does not mean the interface itself is `nil`.

For example, all of the following are non-`nil` interface values:

```go
var a any = 0
var b any = ""
var c any = false
```

Their dynamic values are the zero values of their types.

But a dynamic type is present.

### 7. The typed nil pointer trap

```go
package main

import "fmt"

type Named interface {
	Name() string
}

type Person struct {
	FirstName string
}

func (p *Person) Name() string {
	if p == nil {
		return "unknown"
	}

	return p.FirstName
}

func main() {
	var person *Person

	var named Named = person

	fmt.Println(named == nil, named.Name())
}
```

In this example:

```go
var person *Person
```

was declared.

It was not given a value.

That is why:

```go
person == nil
```

holds.

But then the pointer was placed inside an interface with:

```go
var named Named = person
```

`*Person` implements the `Named` interface, because it has the method:

```go
Name() string
```

Now the state of the `named` interface can be pictured as:

```text
dynamic type  = *Person
dynamic value = nil
```

Because a dynamic type is present, the result of:

```go
named == nil
```

is:

```text
false
```

Then:

```go
named.Name()
```

is called.

The pointer in the original receiver is `nil`.

But at the start of the method there is the check:

```go
if p == nil {
    return "unknown"
}
```

That is why the method handles the `nil` receiver safely and returns:

```text
unknown
```

This example shows the typed nil situation in interfaces well.

### 8. Pointer receiver and method set

```go
package main

import "fmt"

type Incrementer interface {
	Increment()
}

type Counter struct {
	Value int
}

func (c *Counter) Increment() {
	c.Value++
}

func main() {
	c := Counter{}

	var inc Incrementer = &c

	inc.Increment()

	fmt.Println(c.Value)
}
```

The interface:

```go
type Incrementer interface {
    Increment()
}
```

requires the `Increment()` method.

In `Counter` the method is written as:

```go
func (c *Counter) Increment()
```

The receiver is:

```go
*Counter
```

that is, a pointer receiver.

That is why the `Incrementer` interface is implemented by:

```go
*Counter
```

For this reason the following code is correct:

```go
var inc Incrementer = &c
```

The type of `&c` is:

```go
*Counter
```

But the following does not work:

```go
var inc Incrementer = c
```

The reason is that the method set of `Counter` itself does not contain `Increment()`, which is written with a pointer receiver.

This differs from an ordinary method call.

The following can work:

```go
c.Increment()
```

Because Go automatically adjusts it to the form:

```go
(&c).Increment()
```

But during an interface assignment such automatic address-taking does not happen.

Matching an interface is checked through the method set.

### 9. Embedding one interface in another

```go
package main

import "fmt"

type Named interface {
	Name() string
}

type Detailed interface {
	Named
	Description() string
}

type Product struct {
	Title string
}

func (p Product) Name() string {
	return p.Title
}

func (p Product) Description() string {
	return "Product: " + p.Title
}

func main() {
	var value Detailed = Product{
		Title: "Book",
	}

	fmt.Println(
		value.Name(),
		value.Description(),
	)
}
```

First there is the interface:

```go
type Named interface {
    Name() string
}
```

Then a new interface was created:

```go
type Detailed interface {
    Named
    Description() string
}
```

Here the:

```go
Named
```

interface is embedded into `Detailed`.

So `Detailed` requires the following methods:

```go
Name() string
Description() string
```

Written out in full, it can be pictured as equal to:

```go
type Detailed interface {
    Name() string
    Description() string
}
```

The `Product` type has both methods:

```go
func (p Product) Name() string
```

and:

```go
func (p Product) Description() string
```

That is why `Product` implements the:

```go
Detailed
```

interface.

Besides that, it also implements the:

```go
Named
```

interface.

Interface embedding lets you assemble large interfaces from small, clear interfaces.

For example:

```go
type Reader interface {
    Read(...)
}

type Writer interface {
    Write(...)
}

type Closer interface {
    Close() error
}
```

and then, by combining them, you can create an interface such as:

```go
type ReadWriteCloser interface {
    Reader
    Writer
    Closer
}
```

### 10. Passing an interface value to another interface parameter

```go
package main

import "fmt"

type Stringer interface {
	String() string
}

type Code int

func (c Code) String() string {
	return fmt.Sprintf("CODE-%d", c)
}

func printIt(s Stringer) {
	fmt.Println(s.String())
}

func main() {
	var s Stringer = Code(15)

	printIt(s)
}
```

Here there is the interface:

```go
type Stringer interface {
    String() string
}
```

The `Code` type:

```go
type Code int
```

has the method:

```go
func (c Code) String() string
```

written for it.

That is why `Code` implements the `Stringer` interface.

Then an interface value was created with:

```go
var s Stringer = Code(15)
```

At this point `s` can be pictured like this:

```text
static type    = Stringer
dynamic type   = Code
dynamic value  = Code(15)
```

Then:

```go
printIt(s)
```

is called.

`printIt()` also accepts a:

```go
Stringer
```

as its parameter:

```go
func printIt(s Stringer)
```

That is why the existing interface value can be passed to it directly.

Inside the function, when:

```go
s.String()
```

is called, because the dynamic type inside the interface is:

```go
Code
```

the `Code.String()` method runs.

That is:

```go
func (c Code) String() string {
    return fmt.Sprintf("CODE-%d", c)
}
```

is called.

As a result:

```text
CODE-15
```

is printed.

Passing an interface value somewhere else does not lose the concrete value inside it.

In this example, even after being passed, it remains:

```text
dynamic type  = Code
dynamic value = Code(15)
```

And the function does not need to know the concrete `Code` type.

It only uses the method:

```go
String() string
```
