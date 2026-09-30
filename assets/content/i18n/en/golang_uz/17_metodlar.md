# Methods in Go

A **method** is a function bound to a particular type.

An ordinary function works on its own. A method, on the other hand, performs an operation on a specific value or type.

For example, if we have a `Rectangle` type, we can write an `Area()` method to calculate its area:

```go
rectangle.Area()
```

Here `Area()` is a method that belongs specifically to the `Rectangle` type.

The main difference between a method and an ordinary function is that a **receiver** is written before the function
name.

For example:

```go
func (r Rectangle) Area() float64 {
    return r.Width * r.Height
}
```

Here:

* `Area` is the method name;
* `Rectangle` is the type the method is bound to;
* `r` is the receiver, that is, the value the method works on.

The receiver tells us which type the method belongs to.

## Value receivers

First let's look at a simple example:

```go
package main

import "fmt"

type Rectangle struct {
	Width  float64
	Height float64
}

func (r Rectangle) Area() float64 {
	return r.Width * r.Height
}

func main() {
	rectangle := Rectangle{Width: 5, Height: 3}
	fmt.Println("Area:", rectangle.Area())
}
```

Output:

```text
Area: 15
```

In this code, in the part:

```go
func (r Rectangle) Area() float64
```

the piece:

```go
(r Rectangle)
```

is the receiver.

It says that this method belongs to the `Rectangle` type.

That is why we can call the method like this:

```go
rectangle.Area()
```

Here the `rectangle` value is passed to the `r` receiver inside the method.

But there is an important point: `Rectangle` is not a pointer.

```go
(r Rectangle)
```

This is called a **value receiver**.

When a value receiver is used, the method works with a copy of the receiver value.

For example:

```go
func (r Rectangle) Area() float64 {
    return r.Width * r.Height
}
```

`Area()` only reads the `Width` and `Height` values. It does not change the data inside `Rectangle`.

That is why a value receiver is convenient here.

A value receiver usually fits in these cases:

* the method only reads the value;
* the value does not need to change;
* the type is small;
* copying the type is not expensive.

A method cannot be attached to just any type.

In Go, a method can only be attached to **a named type declared in the same package**.

For example, from our own package we cannot add a new method to the type:

```go
time.Time
```

which lives in another package.

That is, you cannot do this:

```go
func (t time.Time) MyMethod() {
}
```

The reason is that the `time.Time` type is not declared in our package.

## Adding a method to a simple type

Methods are not written only for `struct`s.

Methods can also be attached to other named types declared in our own package.

For example:

```go
package main

import "fmt"

type Celsius float64

func (c Celsius) Fahrenheit() float64 {
	return float64(c)*9/5 + 32
}

func main() {
	temperature := Celsius(25)
	fmt.Println(temperature.Fahrenheit())
}
```

Output:

```text
77
```

Here, with:

```go
type Celsius float64
```

a new `Celsius` type was created.

Its underlying type is `float64`, but for Go `Celsius` is a separate named type.

That is why a method can be added to it:

```go
func (c Celsius) Fahrenheit() float64 {
    return float64(c)*9/5 + 32
}
```

Now on a `Celsius` value we can call the method:

```go
temperature.Fahrenheit()
```

This is very convenient.

For example, a plain:

```go
float64
```

value only says that it is a number.

But by creating a separate type:

```go
Celsius
```

we also expressed that this value is a **temperature**.

Besides that, we can add methods related to temperature to it.

But do not confuse this with the following form:

```go
type Celsius = float64
```

This does not create a new type.

It only creates another name, that is, an **alias**, for `float64`.

That is why a separate method cannot be attached to an alias.

The difference:

```go
type Celsius float64
```

creates a new type.

```go
type Celsius = float64
```

only creates another name for `float64`.

## Pointer receivers

Some methods do not just read a value. They need to change the original value.

In such cases a **pointer receiver** is used.

For example:

```go
package main

import "fmt"

type Account struct {
	Balance int64
}

func (a *Account) Deposit(amount int64) error {
	if a == nil {
		return fmt.Errorf("account is nil")
	}

	if amount <= 0 {
		return fmt.Errorf("amount must be positive")
	}

	a.Balance += amount
	return nil
}

func main() {
	account := Account{Balance: 100_000}

	if err := account.Deposit(25_000); err != nil {
		fmt.Println("Error:", err)
		return
	}

	fmt.Println(account.Balance)
}
```

Output:

```text
125000
```

Note the method's receiver here:

```go
func (a *Account) Deposit(amount int64) error
```

The receiver is written as:

```go
(a *Account)
```

`*Account` means a pointer to an `Account` value.

So the `Deposit()` method is given not a copy of the `Account` value, but a pointer to its address.

That is why the method can change the original `Account` value:

```go
a.Balance += amount
```

At first the balance was:

```text
100000
```

The method was called:

```go
account.Deposit(25_000)
```

As a result, the balance inside the original `account` changed:

```text
125000
```

If this method had been written with a value receiver:

```go
func (a Account) Deposit(amount int64)
```

`a` would only be a copy of `account`.

The change inside the method would not affect the original `account` value.

Pointer receivers have another convenience.

We wrote:

```go
a.Balance
```

In fact `a` is a pointer of type:

```go
*Account
```

In theory, the field could be accessed like this:

```go
(*a).Balance
```

But Go does this automatically.

That is why writing:

```go
a.Balance
```

is enough.

Go understands that we are accessing a struct field through a pointer.

Another interesting point:

```go
account.Deposit(25_000)
```

Here `account` is not a pointer.

It is an ordinary:

```go
Account
```

value.

But the method requires a receiver of type:

```go
*Account
```

Go handles this automatically in most cases too.

If the value's address can be taken, the call:

```go
account.Deposit(25_000)
```

is effectively adjusted to:

```go
(&account).Deposit(25_000)
```

That is why there is no need to write `&account` by hand every time.

### The `nil` pointer receiver

A pointer receiver has another property: the receiver can be `nil`.

For example:

```go
var account *Account
```

Here `account` has the value:

```go
nil
```

Nevertheless, calling a method with a pointer receiver is technically possible:

```go
account.Deposit(1000)
```

That is why, if needed, check for `nil` inside the method:

```go
if a == nil {
    return fmt.Errorf("account is nil")
}
```

This is exactly what the `Deposit()` method above does.

If the receiver is `nil`, the method does not access the struct's fields and returns an error.

This prevents a runtime error such as a `nil pointer dereference` in the program.

## Managing state through methods

One of the important benefits of methods is keeping the rules for changing data in one place.

For example, imagine a bank account.

We could keep the balance open like this:

```go
type Account struct {
    Balance int64
}
```

In that case outside code can write any value:

```go
account.Balance = -999999
```

This may not match the business rules.

Instead, the field can be hidden from outside the package and managed through methods:

```go
package main

import (
	"errors"
	"fmt"
)

type Account struct {
	balance int64
}

func (a *Account) Deposit(amount int64) error {
	if amount <= 0 {
		return errors.New("amount must be positive")
	}

	a.balance += amount
	return nil
}

func (a Account) Balance() int64 {
	return a.balance
}

func main() {
	account := Account{}

	if err := account.Deposit(50_000); err != nil {
		fmt.Println("Error:", err)
		return
	}

	fmt.Println(account.Balance())
}
```

Output:

```text
50000
```

Here:

```go
balance int64
```

starts with a lower-case letter.

In Go, names that start with a lower-case letter are not exported outside the package.

So code in another package cannot access the value directly with:

```go
account.balance
```

To change the balance, the method:

```go
account.Deposit(...)
```

must be used.

And the method contains a check:

```go
if amount <= 0 {
    return errors.New("amount must be positive")
}
```

That is why invalid values can be stopped in one place.

To read the balance, the method:

```go
account.Balance()
```

is used.

As a result:

* how the value may change is kept inside `Deposit()`;
* how the value is read is defined by `Balance()`;
* there is no need to repeat the business rules in different parts of the program.

This approach makes code easier to manage.

## Ways to call a method

Methods can be used in several ways.

The simplest way is to call the method on a value.

For example:

```go
area := rectangle.Area()
```

This is usually the most common form.

But Go also lets you take a method as a **function value**.

There are two important forms of this:

* method value;
* method expression.

### Method value

Let's look at the following example:

```go
package main

import "fmt"

type Counter struct {
	value int
}

func (c *Counter) Add(n int) {
	c.value += n
}

func main() {
	counter := &Counter{}

	add := counter.Add

	add(3)
	add(2)

	fmt.Println(counter.value)
}
```

Output:

```text
5
```

Normally we could call the method as:

```go
counter.Add(3)
```

But in this example, with:

```go
add := counter.Add
```

we stored the method in a variable.

This is called a **method value**.

The important point is that the `counter` value is stored together with the method.

That is, the variable:

```go
add
```

already knows which `Counter` it should work on.

That is why, when calling:

```go
add(3)
```

there is no need to pass `counter` as an argument again.

Then, when:

```go
add(2)
```

is called, the same `counter` is changed.

As a result:

```text
5
```

is produced.

### Method expression

A method expression works differently.

For example:

```go
add := (*Counter).Add
add(counter, 5)
```

Here:

```go
(*Counter).Add
```

does not bind the method to a specific `counter` value.

Instead, the method is taken in a form similar to an ordinary function.

That is why we pass the receiver ourselves as the first argument:

```go
add(counter, 5)
```

Here:

```go
counter
```

is the receiver.

```go
5
```

is the `n` argument of the `Add()` method.

A method expression is useful when the same method needs to be used with different values.

For example:

```go
counter1 := &Counter{}
counter2 := &Counter{}

add := (*Counter).Add

add(counter1, 5)
add(counter2, 10)
```

Here one `add` function is used with two different `Counter`s.

## Automatic address-taking and dereferencing

Go makes working with pointers a little simpler when calling methods.

For example, the following two calls work the same in most cases:

```go
account := Account{}

account.Deposit(1000)
(&account).Deposit(1000)
```

Imagine `Deposit()` is written with a pointer receiver:

```go
func (a *Account) Deposit(amount int64)
```

In the first call:

```go
account.Deposit(1000)
```

`account` is an ordinary `Account` value.

The method requires a receiver of type:

```go
*Account
```

But the address of the `account` variable can be taken.

That is why Go automatically adjusts it to:

```go
&account
```

As a result we don't have to write:

```go
(&account).Deposit(1000)
```

every time.

A simple:

```go
account.Deposit(1000)
```

is enough.

The reverse also exists.

Suppose `Balance()` is written with a value receiver:

```go
func (a Account) Balance() int64 {
    return a.balance
}
```

And we have a pointer:

```go
accountPointer := &account
```

Nevertheless, you can call:

```go
fmt.Println(accountPointer.Balance())
```

Go automatically dereferences the pointer and calls the method.

Here Go performs the required `*` or `&` operation for us automatically.

But one important thing must be kept apart:

> Go automatically applying `&` or `*` when calling a method does not mean the method sets of `Account` and `*Account` are the same.

This difference matters especially when working with interfaces.

## Choosing a receiver

One of the most common questions when writing a method is:

> Should I use a value receiver or a pointer receiver?

There is no single universal rule that answers this.

But there are a few practical rules.

### When is a pointer receiver used?

In the following cases choosing a pointer receiver is usually right.

#### The method changes the value

For example:

```go
func (a *Account) Deposit(amount int64) {
    a.Balance += amount
}
```

This method must change the original `Account` value.

That is why a pointer receiver is needed.

#### The struct is large

When a value receiver is used, the struct value is copied.

For small structs this is usually not a problem.

But if a struct is very large, copying it on every method call can be an unnecessary cost.

In such cases a pointer receiver is convenient.

#### The struct holds a field that must not be copied

For example, copying structs that use values such as:

```go
sync.Mutex
```

is not recommended.

That is why such types usually use pointer receivers.

#### Other methods use pointer receivers

If a type has many methods, consistency in choosing the receiver is useful.

For example:

```go
func (a *Account) Deposit(...)
func (a *Account) Withdraw(...)
func (a *Account) Balance(...)
```

When one method has a pointer receiver and another a value receiver, it can sometimes make the code harder to
understand.

That is why keeping the receiver choice for one type as consistent as possible is good practice.

### When is a value receiver used?

A value receiver is convenient for small, value-like types.

For example:

```go
type Celsius float64
```

This value is small and does not need to change.

That is why:

```go
func (c Celsius) Fahrenheit() float64
```

is a good example of a value receiver.

But there is one important point about value receivers.

Suppose a struct contains a:

```go
map
```

or a:

```go
slice
```

Even when the struct itself is copied, the underlying data of the `map` or slice may be stored elsewhere.

That is why a method with a value receiver can also change the data inside a `map` or slice.

For example, the rule:

> "If a method changes something, I use a pointer receiver"

is not always enough on its own.

When choosing a receiver, what data the type holds and its semantics are also taken into account.

## Method sets and interfaces

In Go every type has a **method set**.

This matters a lot, especially when working with interfaces.

Suppose we have the type:

```go
type T struct{}
```

If a method is written with a value receiver:

```go
func (t T) Method()
```

this method belongs to the method set of `T`.

`*T` can also use value-receiver methods.

That is, put simply:

* the method set of `T` contains the methods with a `T` receiver;
* the method set of `*T` contains the methods with `T` and `*T` receivers.

This affects whether an interface is satisfied.

For example:

```go
package main

import "fmt"

type Incrementer interface {
	Increment()
}

type Counter int

func (c *Counter) Increment() {
	*c++
}

func run(value Incrementer) {
	value.Increment()
}

func main() {
	var counter Counter

	run(&counter)

	fmt.Println(counter)
}
```

Output:

```text
1
```

Here the interface:

```go
type Incrementer interface {
    Increment()
}
```

says that a type with an `Increment()` method is needed.

The method for `Counter` is written like this:

```go
func (c *Counter) Increment()
```

Note that the receiver is:

```go
*Counter
```

So `Increment()` is a method with a pointer receiver.

That is why:

```go
*Counter
```

satisfies the `Incrementer` interface.

The following code works:

```go
run(&counter)
```

Because the type of:

```go
&counter
```

is:

```go
*Counter
```

But:

```go
run(counter)
```

does not compile.

The reason is that the method set of `Counter` itself does not contain:

```go
Increment()
```

The method is declared only for:

```go
*Counter
```

There is another important difference to remember here.

In the previous section we saw that the following call works:

```go
counter.Increment()
```

If the address of `counter` can be taken, Go can automatically adjust the method call to:

```go
(&counter).Increment()
```

But no such automatic adjustment is made when checking an interface.

Satisfying an interface is checked at compile time based on the type's **method set**.

That is why the following two situations must not be confused:

```go
counter.Increment()
```

and:

```go
run(counter)
```

In the first, Go can adjust the method call automatically.

In the second, whether the `Counter` type satisfies the interface is checked through its method set.

## Choosing the receiver name

A receiver has a name, just like an ordinary variable.

For example:

```go
func (a Account) Balance() int64
```

Here the receiver name is:

```go
a
```

Or:

```go
func (c *Counter) Increment()
```

here the receiver is:

```go
c
```

In Go code the receiver name is usually one or two letters taken from the type name.

For example, for:

```go
type Account struct{}
```

you might use:

```go
a
```

For:

```go
type Counter struct{}
```

you might use:

```go
c
```

In Go, using names like:

```text
this
```

or:

```text
self
```

as in some other languages, is not customary.

For example, rather than:

```go
func (this Account) Balance() int64
```

the following form is closer to Go style:

```go
func (a Account) Balance() int64
```

Another recommendation is to use the same receiver name in all methods of one type.

For example:

```go
func (a *Account) Deposit(amount int64) {}
func (a *Account) Withdraw(amount int64) {}
func (a *Account) Balance() int64 {}
```

You could use `a` in one method, `acc` in another and `account` in yet another, but using the same name helps read the code faster.

## Examples

### 1. Calculating with a value receiver

```go
package main

import "fmt"

type Box struct {
	Width  float64
	Height float64
}

func (b Box) Area() float64 {
	return b.Width * b.Height
}

func main() {
	b := Box{
		Width:  8,
		Height: 5,
	}

	fmt.Println(b.Area())
}
```

In this example:

```go
func (b Box) Area() float64
```

uses a value receiver.

The `Area()` method does not change the values inside `Box`.

It only reads the values:

```go
b.Width
```

and:

```go
b.Height
```

and calculates the area.

That is why a pointer receiver is not needed here.

When the method is called, the `Box` value is passed to the receiver as a copy:

```go
b.Area()
```

### 2. Updating a value with a pointer receiver

```go
package main

import "fmt"

type Tally struct {
	Count int
}

func (t *Tally) Inc() {
	t.Count++
}

func main() {
	t := Tally{}

	t.Inc()
	t.Inc()

	fmt.Println(t.Count)
}
```

Here the job of the `Inc()` method is to change the value inside `Tally`.

That is why the receiver is written as:

```go
(t *Tally)
```

This is a pointer receiver.

Inside the method:

```go
t.Count++
```

changes the original `t` value.

After the first call it is:

```text
1
```

and after the second call:

```text
2
```

We called the method as:

```go
t.Inc()
```

The method actually requires a `*Tally` receiver.

But because the address of the `t` variable can be taken, Go automatically adjusts it to:

```go
(&t).Inc()
```

### 3. Adding a method to a simple named type

```go
package main

import "fmt"

type Celsius float64

func (c Celsius) Fahrenheit() float64 {
	return float64(c)*9/5 + 32
}

func main() {
	temperature := Celsius(25)

	fmt.Println(temperature.Fahrenheit())
}
```

A method does not have to be written only for a `struct`.

In this example, with:

```go
type Celsius float64
```

a new `Celsius` type was created on top of `float64`.

Now a separate method can be written for `Celsius`:

```go
func (c Celsius) Fahrenheit() float64
```

The method converts a Celsius value to Fahrenheit.

That is why code of the form:

```go
temperature.Fahrenheit()
```

reads clearly.

This technique lets you attach meaning, and behavior that belongs to it, even to simple values.

### 4. Validating a value through a method

```go
package main

import "fmt"

type Age int

func (a Age) Valid() bool {
	return a >= 0 && a <= 150
}

func main() {
	age := Age(24)

	fmt.Println(age.Valid())
}
```

In this example, with:

```go
type Age int
```

a separate type for age was created.

Then a method was written that checks whether the age is in the valid range:

```go
func (a Age) Valid() bool {
    return a >= 0 && a <= 150
}
```

Now there is no need to write the check:

```go
age >= 0 && age <= 150
```

in every part of the program.

Instead, you can call:

```go
age.Valid()
```

The validation rule is kept in the type's own method.

If the rule changes later, it is enough to change only one method.

### 5. An update controlled by a method

```go
package main

import "fmt"

type Wallet struct {
	Balance int
}

func (w *Wallet) Withdraw(amount int) bool {
	if amount <= 0 || amount > w.Balance {
		return false
	}

	w.Balance -= amount
	return true
}

func main() {
	w := Wallet{Balance: 100}

	fmt.Println(w.Withdraw(30), w.Balance)
}
```

In this example, a `Withdraw()` method is written for taking money out of the wallet.

The method first checks the given amount:

```go
if amount <= 0 || amount > w.Balance {
    return false
}
```

In two cases no money is withdrawn:

* the amount is `0` or less;
* the amount is greater than the balance.

If the value is valid, the balance is reduced with:

```go
w.Balance -= amount
```

Then:

```go
true
```

is returned.

That is why the method's result tells whether the operation was performed.

The most important point is that if an invalid amount is given, the `Wallet` state does not change.

### 6. Checking for a `nil` receiver

```go
package main

import "fmt"

type Node struct {
	Value int
}

func (n *Node) ValueOrZero() int {
	if n == nil {
		return 0
	}

	return n.Value
}

func main() {
	var node *Node

	fmt.Println(node.ValueOrZero())
}
```

In this example a pointer is declared with:

```go
var node *Node
```

But it was not given any value.

That is why:

```go
node == nil
```

Nevertheless, the method:

```go
node.ValueOrZero()
```

can be called.

The reason is that the method is written with a pointer receiver:

```go
func (n *Node) ValueOrZero() int
```

Inside the method the receiver is checked first:

```go
if n == nil {
    return 0
}
```

Only after that is the field:

```go
n.Value
```

accessed.

If it had been written directly as:

```go
return n.Value
```

without the `nil` check, a runtime error could have occurred because of the `nil` pointer.

### 7. Method value

```go
package main

import "fmt"

type Multiplier int

func (m Multiplier) Apply(num int) int {
	return int(m) * num
}

func main() {
	two := Multiplier(2)

	apply := two.Apply

	fmt.Println(apply(7))
}
```

Here the value:

```go
two := Multiplier(2)
```

was created.

Then with:

```go
apply := two.Apply
```

the method was stored in a variable.

This is a **method value**.

The important point is that the receiver `two` is also stored inside `apply`.

That is why, when:

```go
apply(7)
```

is called, there is no need to pass `two` again.

Go uses it in the sense of:

```go
two.Apply(7)
```

The value of `two` is `2`, and the argument is `7`.

As a result:

```text
14
```

is produced.

### 8. Method expression

```go
package main

import "fmt"

type Number int

func (n Number) Square() int {
	return int(n * n)
}

func main() {
	square := Number.Square

	fmt.Println(square(Number(9)))
}
```

This time the method was taken with:

```go
square := Number.Square
```

This is a **method expression**.

Unlike a method value, here the method is not bound to a specific receiver value.

That is why the receiver is given as the first argument at call time:

```go
square(Number(9))
```

This is almost the same as:

```go
Number(9).Square()
```

With a method expression, one method can be used with different receiver values.

For example:

```go
square(Number(5))
square(Number(10))
square(Number(20))
```

In each call the first argument is used as the receiver.

### 9. Pointer receivers on slice elements

```go
package main

import "fmt"

type Product struct {
	Price int
}

func (p *Product) Discount(percent int) {
	p.Price -= p.Price * percent / 100
}

func main() {
	products := []Product{
		{Price: 100},
		{Price: 200},
	}

	for i := range products {
		products[i].Discount(10)
	}

	fmt.Println(products)
}
```

In this example a method that changes the price is written for `Product`:

```go
func (p *Product) Discount(percent int)
```

Because the price has to change, a pointer receiver is used.

The slice:

```go
products := []Product{
    {Price: 100},
    {Price: 200},
}
```

consists of two elements.

The loop:

```go
for i := range products {
    products[i].Discount(10)
}
```

applies a 10 percent discount to each element.

The important part here is that:

```go
products[i]
```

is taken by index.

When a slice element is taken by index, its address can be taken.

That is why Go can adjust the call:

```go
products[i].Discount(10)
```

for the pointer receiver.

As a result, the `Price` values of the original elements in the slice change.

The first product drops from:

```text
100
```

to:

```text
90
```

The second product drops from:

```text
200
```

to:

```text
180
```

### 10. Choosing receivers consistently for one type

```go
package main

import "fmt"

type Cart struct {
	Count int
}

func (c *Cart) Add(n int) {
	c.Count += n
}

func (c *Cart) IsEmpty() bool {
	return c.Count == 0
}

func main() {
	c := Cart{}

	fmt.Println(c.IsEmpty())

	c.Add(3)

	fmt.Println(c.IsEmpty())
}
```

In this example `Cart` has two methods:

```go
func (c *Cart) Add(n int)
```

and:

```go
func (c *Cart) IsEmpty() bool
```

The `Add()` method changes the cart's state:

```go
c.Count += n
```

That is why this method needs a pointer receiver.

`IsEmpty()` only checks the value:

```go
return c.Count == 0
```

Technically it could also be written with a value receiver:

```go
func (c Cart) IsEmpty() bool {
    return c.Count == 0
}
```

But because the other methods of this type use pointer receivers, `IsEmpty()` is also written with a pointer receiver:

```go
func (c *Cart) IsEmpty() bool
```

This keeps the receiver choice consistent across the methods of one type.

As a result, when working with `Cart`, you need to remember less about which method uses a pointer and which a value receiver.
