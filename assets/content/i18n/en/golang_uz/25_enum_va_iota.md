# Enums and `iota` in Go

Unlike some other languages, the Go programming language has no separate keyword:

```text
enum
```

For example, in Java, C# or other languages a certain set of values can be declared as an `enum`.

In Go the same job is usually done with the help of:

* a named type;
* `const` constants;
* `iota`, if needed.

For example, let the system have order statuses:

```text
unknown
pending
processing
completed
```

They can be stored as ordinary `int` values:

```go
const (
    StatusUnknown    = 0
    StatusPending    = 1
    StatusProcessing = 2
    StatusCompleted  = 3
)
```

But then the values remain ordinary `int` values.

In Go it is better to create a separate named type instead:

```go
type Status int
```

Then the constants can be tied to this type:

```go
const (
    StatusUnknown Status = iota
    StatusPending
    StatusProcessing
    StatusCompleted
)
```

As a result, in the code we work not with a plain number but with a `Status` type whose meaning is clear.

And `iota` here helps us avoid writing the values:

```text
0
1
2
3
```

by hand.

## A named type and constants

Let's look at the following example:

```go
package main

import "fmt"

type Status int

const (
	StatusUnknown Status = iota
	StatusPending
	StatusProcessing
	StatusCompleted
)

func main() {
	status := StatusProcessing

	fmt.Println(status)
	fmt.Println(status == StatusCompleted)
}
```

Output:

```text
2
false
```

The most important part of this code:

```go
type Status int
```

Here a new `Status` type was created based on `int`.

The underlying type of `Status` is `int`, but for Go it is a separate named type.

Then, with:

```go
const (
    StatusUnknown Status = iota
    StatusPending
    StatusProcessing
    StatusCompleted
)
```

the main possible constants for `Status` were declared.

The first line says:

```go
StatusUnknown Status = iota
```

When a `const` group starts, the value of `iota` is:

```text
0
```

That is why:

```go
StatusUnknown == 0
```

On the next line no new expression is written:

```go
StatusPending
```

Go repeats the previous expression, and `iota` increases by one.

As a result:

```go
StatusPending == 1
```

The next values are:

```go
StatusProcessing == 2
StatusCompleted  == 3
```

That is why the result of:

```go
status := StatusProcessing
fmt.Println(status)
```

is:

```text
2
```

Then:

```go
status == StatusCompleted
```

is checked.

The value of `status` is:

```text
2
```

and `StatusCompleted` is:

```text
3
```

so the result is:

```text
false
```

### Why use a separate type instead of plain `int`?

We could also have written:

```go
const (
    StatusUnknown    = 0
    StatusPending    = 1
    StatusProcessing = 2
    StatusCompleted  = 3
)
```

But these values remain ordinary `int` values.

Creating a separate:

```go
type Status int
```

type makes the meaning of the code clearer.

For example, from the look of the function:

```go
func SetStatus(status Status) {
}
```

you can already tell that the parameter is not a plain number but exactly a system status.

This is much clearer than:

```go
func SetStatus(status int) {
}
```

Methods can also be added to a named type later:

```go
func (s Status) String() string {
    // ...
}
```

or:

```go
func (s Status) Valid() bool {
    // ...
}
```

That is why a named type is not just another name for numbers. It lets you express a particular concept as a separate type.

## Using the zero value for `Unknown`

In Go every type has a zero value, that is, an initial value.

For an `int`-based type it is:

```text
0
```

For example, if we write:

```go
var status Status
```

and give it no value, then:

```go
status == 0
```

That is why in enum-like types it is often useful to reserve the value `0` for an unknown or not-yet-set state such as:

```go
StatusUnknown
```

For example:

```go
const (
    StatusUnknown Status = iota
    StatusPending
    StatusProcessing
    StatusCompleted
)
```

Now a value declared as:

```go
var status Status
```

is automatically equal to the state:

```go
StatusUnknown
```

This is good design, because the zero value does not accidentally mean a real business state.

If we set the first value to:

```go
StatusCompleted Status = iota
```

a newly declared:

```go
var status Status
```

would accidentally mean the `Completed` state.

In many systems this is dangerous.

That is why reserving a state such as:

```text
0 = Unknown
```

or:

```text
0 = Unspecified
```

is considered good practice.

## How does `iota` work?

`iota` is a special identifier used only inside a `const` declaration.

In every new `const` group it starts from:

```text
0
```

For example:

```go
const (
    A = iota
    B
    C
)
```

the values are:

```text
A = 0
B = 1
C = 2
```

But `iota` does not have to be used only as a plain number.

It can also be used inside a formula.

For example:

```go
const (
    A = iota + 1
    B
    C
)
```

The result is:

```text
A = 1
B = 2
C = 3
```

On the first line:

```go
A = iota + 1
```

`iota` is:

```text
0
```

So:

```text
0 + 1 = 1
```

On the next line no separate expression is written for:

```go
B
```

Go repeats the previous expression:

```go
iota + 1
```

On this line `iota` is:

```text
1
```

so we get:

```text
1 + 1 = 2
```

On the `C` line:

```text
iota = 2
```

The result:

```text
2 + 1 = 3
```

### What does a line without an expression do?

For example:

```go
const (
    A = iota + 1
    B
    C
)
```

is actually close to the following:

```go
const (
    A = iota + 1
    B = iota + 1
    C = iota + 1
)
```

But on every line the value of `iota` increases by one.

That is why there is no need to write the same formula again and again.

This is one of the main conveniences of `iota`.

## `iota` increases on every `ConstSpec` line

An important rule:

`iota` increases by one not on every constant name, but on every `ConstSpec` line.

For example:

```go
const (
    A, B = iota, iota
    C, D = iota, iota
)
```

Throughout the first line both `iota` values are:

```text
0
```

That is why:

```text
A = 0
B = 0
```

On the second line:

```text
iota = 1
```

That is why:

```text
C = 1
D = 1
```

So no matter how many `iota` are written on one line, they have the same value for that line.

This will be useful for creating ranges in later examples.

## Skipping an `iota` value with `_`

Sometimes the first value of `iota` may not be needed.

For example, we want the levels to start from:

```text
1
2
3
```

One way to do this:

```go
const (
    PriorityLow Priority = iota + 1
    PriorityMedium
    PriorityHigh
)
```

Another way is to skip the first value with `_`:

```go
const (
    _ Priority = iota
    PriorityLow
    PriorityMedium
    PriorityHigh
)
```

On the first line:

```text
iota = 0
```

But the value is given to:

```go
_
```

`_` is the blank identifier.

This value cannot be used later.

On the next line:

```text
iota = 1
```

That is why we get:

```text
PriorityLow    = 1
PriorityMedium = 2
PriorityHigh   = 3
```

## Size values with `iota`

Because `iota` works with formulas, it is not only for creating the plain sequence:

```text
0, 1, 2, 3
```

For example, file sizes can be created:

```go
type Size uint64

const (
    _ Size = 1 << (10 * iota)
    KB
    MB
    GB
)
```

This code may look complex at first glance.

Let's go step by step.

The first line:

```go
_ Size = 1 << (10 * iota)
```

On this line:

```text
iota = 0
```

So:

```text
1 << (10 * 0)
```

that is:

```text
1 << 0
```

the result is:

```text
1
```

But this value is given to `_` and is not used.

On the next line:

```go
KB
```

the previous expression is repeated.

This time:

```text
iota = 1
```

So:

```text
1 << (10 * 1)
```

that is:

```text
1 << 10
```

This equals:

```text
1024
```

That is why:

```text
KB = 1024
```

On the next line:

```text
iota = 2
```

So:

```text
MB = 1 << 20
```

The result:

```text
1048576
```

The next value:

```text
GB = 1 << 30
```

The result:

```text
1073741824
```

So:

```text
KB = 1024
MB = 1048576
GB = 1073741824
```

Here `iota` was used like a variable inside a formula.

## `iota` restarts in every `const` group

`iota` does not keep increasing across the whole program.

Every time a new:

```go
const (
    ...
)
```

group is opened, `iota` starts again from:

```text
0
```

For example:

```go
const (
    A = iota
    B
)

const (
    C = iota
    D
)
```

The result:

```text
A = 0
B = 1

C = 0
D = 1
```

The second `const` group does not continue the first.

This is very important.

Because a project can have several separate enum-like types, and their `iota` values do not affect each other.

## Giving a text representation

Enum-like values have another problem.

For example:

```go
fmt.Println(StatusProcessing)
```

if no additional method is written, prints:

```text
2
```

Inside the program this number may be enough.

But:

* in logs;
* while debugging;
* in a CLI program;
* in results shown to the user;

it is hard to understand what `2` means.

That is why a `String()` method can be added to the named type.

For example:

```go
package main

import "fmt"

type Status int

const (
	StatusUnknown Status = iota
	StatusPending
	StatusProcessing
	StatusCompleted
)

func (s Status) String() string {
	switch s {
	case StatusUnknown:
		return "unknown"

	case StatusPending:
		return "pending"

	case StatusProcessing:
		return "processing"

	case StatusCompleted:
		return "completed"

	default:
		return fmt.Sprintf("Status(%d)", s)
	}
}

func main() {
	fmt.Println(StatusProcessing)
	fmt.Println(Status(99))
}
```

Output:

```text
processing
Status(99)
```

How does this work?

The `Status` type has the method:

```go
String() string
```

namely:

```go
func (s Status) String() string
```

This matches the `fmt.Stringer` interface:

```go
type Stringer interface {
    String() string
}
```

That is why functions in the `fmt` package can use the `String()` method when printing a `Status` value.

For example:

```go
fmt.Println(StatusProcessing)
```

instead of the plain:

```text
2
```

prints:

```text
processing
```

### Choosing the name with `switch`

Inside the method, with:

```go
switch s {
case StatusUnknown:
    return "unknown"

case StatusPending:
    return "pending"

case StatusProcessing:
    return "processing"

case StatusCompleted:
    return "completed"
}
```

each numeric value is given a text.

For example, even though the value of:

```go
StatusProcessing
```

is:

```text
2
```

`String()` returns:

```text
processing
```

### Why is `default` needed?

At the end of the method there is:

```go
default:
    return fmt.Sprintf("Status(%d)", s)
```

Writing this is important.

Because an enum-like type in Go is not limited to the declared constants.

For example, you can write:

```go
Status(99)
```

That is why if `String()` just did:

```go
return "unknown"
```

it could hide the real unknown value.

Instead, printing:

```text
Status(99)
```

is much more useful for debugging and logs.

We can immediately see:

> An unexpected value 99 came into the system

In large enums, writing dozens or hundreds of `case` lines can be inconvenient.

In such cases tools that generate the `String()` method automatically can be used.

But generated files should be managed according to the project and repository rules.

## An enum is not a closed set

The enum-like approach in Go has one very important difference.

We created a type like this:

```go
type Status int
```

and declared only four constants:

```go
const (
    StatusUnknown Status = iota
    StatusPending
    StatusProcessing
    StatusCompleted
)
```

These values are:

```text
0
1
2
3
```

But this does not mean:

> `Status` can only be 0, 1, 2 or 3

The following code also compiles:

```go
status := Status(99)
```

This is a completely valid `Status` value.

That is why this approach in Go does not create a closed set like a strict enum in some other languages.

### Why does this matter?

If the values are used only inside our own code, we usually use the constants:

```go
StatusPending
StatusCompleted
```

But when data comes from an external source, the situation is different.

For example, through:

* an HTTP request;
* JSON;
* a database;
* a message broker;
* a file;
* another service;

the value:

```text
99
```

may arrive.

Converting it to:

```go
Status(99)
```

is technically possible.

But it may not match the business rules.

That is why external values should be validated.

For example:

```go
func (s Status) Valid() bool {
    return s >= StatusUnknown && s <= StatusCompleted
}
```

Now you can check:

```go
status := Status(2)

if !status.Valid() {
    // invalid status
}
```

For `Status(99)`:

```go
Status(99).Valid()
```

the result is:

```text
false
```

### Is a range check always enough?

The technique:

```go
return s >= StatusUnknown && s <= StatusCompleted
```

works well when the constants are consecutive.

For example:

```text
0
1
2
3
```

But if the values are like:

```text
1
5
10
20
```

a range check may be wrong.

In such a case it is better to use a `switch`:

```go
func (s Status) Valid() bool {
    switch s {
    case StatusUnknown,
        StatusPending,
        StatusProcessing,
        StatusCompleted:
        return true

    default:
        return false
    }
}
```

This technique accepts only the values that were actually declared.

## `iota` and external formats

There is another important danger when using `iota`.

Suppose:

```go
const (
    StatusUnknown Status = iota
    StatusPending
    StatusProcessing
    StatusCompleted
)
```

the values are:

```text
0
1
2
3
```

Now imagine we wrote these numbers to a database.

For example:

```text
2 = processing
3 = completed
```

Later we added a new status to the code:

```go
const (
    StatusUnknown Status = iota
    StatusPending
    StatusWaiting
    StatusProcessing
    StatusCompleted
)
```

Now the values have become:

```text
StatusUnknown    = 0
StatusPending    = 1
StatusWaiting    = 2
StatusProcessing = 3
StatusCompleted  = 4
```

The value in the earlier database:

```text
2
```

used to be:

```text
processing
```

In the new code, however, it has become:

```text
waiting
```

This can lead to a very serious bug.

That is why you should be careful if `iota` values are tied to an external system.

This includes:

* a database;
* a public API;
* a protocol similar to protobuf;
* a file format;
* a message broker;
* codes agreed with another service.

In such a case there are two safer approaches.

### Adding new values only at the end

For example:

```go
const (
    StatusUnknown Status = iota
    StatusPending
    StatusProcessing
    StatusCompleted

    StatusCanceled
)
```

Here the old values do not change.

### Writing explicit numbers

If the codes are an external contract, an even more explicit way:

```go
const (
    StatusUnknown    Status = 0
    StatusPending    Status = 10
    StatusProcessing Status = 20
    StatusCompleted  Status = 30
)
```

Now adding a new value does not automatically shift the old values.

## Going deeper: bit flags

Bit flags are used when several independent states need to be stored in one value. At the beginner stage, understanding the plain `iota` sequence is enough; you can come back to this section later.

`iota` is not only for creating plain enum-like sequences.

It is also very convenient for creating **bit flags**.

For example, let a user have the following permissions:

* read;
* write;
* delete.

With a plain enum you could do:

```text
Read   = 0
Write  = 1
Delete = 2
```

But one user needs to have several permissions at the same time.

For example:

```text
Read + Write
```

In such a case a bitmask can be used.

```go
type Permission uint8

const (
    PermissionRead Permission = 1 << iota
    PermissionWrite
    PermissionDelete
)
```

Here the values are:

```text
PermissionRead   = 1
PermissionWrite  = 2
PermissionDelete = 4
```

Why?

For the first line:

```go
1 << iota
```

we have:

```text
iota = 0
```

So:

```text
1 << 0 = 1
```

In binary:

```text
00000001
```

The next line:

```text
iota = 1
```

So:

```text
1 << 1 = 2
```

Binary:

```text
00000010
```

The next:

```text
1 << 2 = 4
```

Binary:

```text
00000100
```

The important point is that each value has a separate bit set.

## Combining bit flags

Bit flags can be combined with the:

```go
|
```

bitwise OR operator.

For example:

```go
permissions := PermissionRead | PermissionWrite
```

In binary:

```text
PermissionRead  = 00000001
PermissionWrite = 00000010
```

When `|` is used, we get:

```text
00000001
00000010
--------
00000011
```

In decimal this is:

```text
3
```

So:

```go
permissions == 3
```

But this `3` is not the third enum value in the ordinary sense.

It contains two flags:

```text
Read
Write
```

## Checking whether a flag is present

For example, we want to check whether the value contains `PermissionRead`.

For that:

```go
value & permission
```

is used.

For example:

```go
func has(value, permission Permission) bool {
    return value&permission != 0
}
```

If:

```go
permissions := PermissionRead | PermissionWrite
```

then:

```go
has(permissions, PermissionRead)
```

gives:

```text
true
```

But:

```go
has(permissions, PermissionDelete)
```

gives:

```text
false
```

Bit flags are convenient in the following cases:

* permissions;
* feature flags;
* notification settings;
* file modes;
* protocol flags;
* storing several independent `true/false` states in one number.

## Examples

### 1. Starting weekdays from one

In this example `iota + 1` gives the weekdays values starting from `1`.

```go
package main

import "fmt"

type Weekday int

const (
	Monday Weekday = iota + 1
	Tuesday
	Wednesday
	Thursday
	Friday
	Saturday
	Sunday
)

func main() {
	fmt.Println(Monday, Wednesday, Sunday)
}
```

The first line says:

```go
Monday Weekday = iota + 1
```

On this line:

```text
iota = 0
```

So:

```text
Monday = 0 + 1 = 1
```

On the next line no separate expression is written:

```go
Tuesday
```

Go repeats the previous expression:

```go
iota + 1
```

On this line:

```text
iota = 1
```

That is why:

```text
Tuesday = 2
```

In the same way:

```text
Monday    = 1
Tuesday   = 2
Wednesday = 3
Thursday  = 4
Friday    = 5
Saturday  = 6
Sunday    = 7
```

That is why the result of:

```go
fmt.Println(Monday, Wednesday, Sunday)
```

is:

```text
1 3 7
```

This technique is convenient in situations where the value `0` should not be used as a weekday.

It can also make it easier to match a format seen by the user or used in another system:

```text
1 = Monday
...
7 = Sunday
```

### 2. Reserving the zero value for an unknown state

In this example the type's zero value means a separate `Unknown` state.

```go
package main

import "fmt"

type DeliveryStatus int

const (
	DeliveryUnknown DeliveryStatus = iota
	DeliveryAccepted
	DeliveryOnTheWay
	DeliveryArrived
)

func main() {
	var status DeliveryStatus

	fmt.Println(status == DeliveryUnknown)

	status = DeliveryOnTheWay

	fmt.Println(status)
}
```

First a variable was created with:

```go
var status DeliveryStatus
```

It was not given a value.

Because `DeliveryStatus` is an `int`-based type, its zero value is:

```text
0
```

In our constants:

```go
DeliveryUnknown DeliveryStatus = iota
```

also equals:

```text
0
```

That is why the result of:

```go
status == DeliveryUnknown
```

is:

```text
true
```

This is good design.

Because if the delivery status has not been set yet, it can be understood as:

```text
0 = Unknown
```

Then a real status was given with:

```go
status = DeliveryOnTheWay
```

The values are:

```text
DeliveryUnknown  = 0
DeliveryAccepted = 1
DeliveryOnTheWay = 2
DeliveryArrived  = 3
```

That is why the result of:

```go
fmt.Println(status)
```

is:

```text
2
```

In this approach the real business states start from `1`, and `0` is used to mean "not known yet".

### 3. Skipping an unneeded first value

In this example the first `iota` value is not used, thanks to `_`.

```go
package main

import "fmt"

type Priority int

const (
	_ Priority = iota
	PriorityLow
	PriorityMedium
	PriorityHigh
)

func main() {
	fmt.Println(
		PriorityLow,
		PriorityMedium,
		PriorityHigh,
	)
}
```

On the first line:

```go
_ Priority = iota
```

`iota` equals:

```text
0
```

But the value is given to the:

```go
_
```

blank identifier.

That is why there is no separate constant name for this value.

On the next line:

```text
iota = 1
```

So:

```text
PriorityLow = 1
```

The next:

```text
PriorityMedium = 2
```

and:

```text
PriorityHigh = 3
```

The result:

```text
1 2 3
```

This technique is convenient when `0` should not be a real value.

For example, `0` can remain as a hidden state meaning:

```text
priority not set yet
```

### 4. Increasing values in steps of ten

We saw that `iota` can be used inside a formula.

In the following example the codes are created in the form:

```text
10
20
30
```

```go
package main

import "fmt"

type DepartmentCode int

const (
	DepartmentSales DepartmentCode = (iota + 1) * 10
	DepartmentSupport
	DepartmentWarehouse
)

func main() {
	fmt.Println(
		DepartmentSales,
		DepartmentSupport,
		DepartmentWarehouse,
	)
}
```

On the first line the formula:

```go
(iota + 1) * 10
```

is used.

On this line:

```text
iota = 0
```

So:

```text
(0 + 1) * 10 = 10
```

That is why:

```text
DepartmentSales = 10
```

For the next line:

```text
iota = 1
```

So:

```text
(1 + 1) * 10 = 20
```

That is why:

```text
DepartmentSupport = 20
```

The next:

```text
(2 + 1) * 10 = 30
```

So:

```text
DepartmentWarehouse = 30
```

The result:

```text
10 20 30
```

This technique can be used when you need to leave gaps between codes.

But if these values are a permanent contract with a database or an external API, writing explicit numbers instead of `iota` is often safer.

### 5. Creating related values on one line

Several constants can be declared on one `ConstSpec` line.

All `iota` on that line have the same value.

For example:

```go
package main

import "fmt"

const (
	SmallMin, SmallMax = iota * 10, iota*10 + 9
	MediumMin, MediumMax
	LargeMin, LargeMax
)

func main() {
	fmt.Println(SmallMin, SmallMax)
	fmt.Println(MediumMin, MediumMax)
	fmt.Println(LargeMin, LargeMax)
}
```

On the first line:

```go
SmallMin, SmallMax = iota * 10, iota*10 + 9
```

`iota` equals:

```text
0
```

The `iota` in both expressions is the same:

```text
0
```

That is why:

```text
SmallMin = 0 * 10     = 0
SmallMax = 0 * 10 + 9 = 9
```

The result:

```text
0–9
```

On the next line no expression is written:

```go
MediumMin, MediumMax
```

Go repeats the previous two expressions.

On this line:

```text
iota = 1
```

That is why:

```text
MediumMin = 10
MediumMax = 19
```

On the next line:

```text
iota = 2
```

The result:

```text
LargeMin = 20
LargeMax = 29
```

So three ranges are formed:

```text
Small  = 0–9
Medium = 10–19
Large  = 20–29
```

This example shows that when several `iota` are used on one line, they get the same value for that line.

### 6. Restarting in every `const` group

The following example shows that `iota` becomes `0` again in a new `const` block.

```go
package main

import "fmt"

const (
	North = iota
	East
)

const (
	Draft = iota
	Published
)

func main() {
	fmt.Println(North, East)
	fmt.Println(Draft, Published)
}
```

In the first `const` group:

```go
const (
    North = iota
    East
)
```

the values are:

```text
North = 0
East  = 1
```

Then a new group was opened:

```go
const (
    Draft = iota
    Published
)
```

Here `iota` does not continue from:

```text
2
```

It starts again from:

```text
0
```

That is why:

```text
Draft     = 0
Published = 1
```

The result:

```text
0 1
0 1
```

Each separate `const` group has its own `iota` count.

This ensures that different enum-like groups do not affect each other.

### 7. Combining file permissions

In this example `iota` is used to create bit flags.

```go
package main

import "fmt"

type FilePermission uint8

const (
	CanRead FilePermission = 1 << iota
	CanWrite
	CanExecute
)

func main() {
	permissions := CanRead | CanWrite

	fmt.Println(permissions)

	fmt.Println(permissions&CanRead != 0)
	fmt.Println(permissions&CanExecute != 0)
}
```

First we calculate the values.

The first:

```go
CanRead FilePermission = 1 << iota
```

Here:

```text
iota = 0
```

So:

```text
1 << 0 = 1
```

That is why:

```text
CanRead = 1
```

Binary:

```text
00000001
```

The next:

```text
CanWrite = 1 << 1 = 2
```

Binary:

```text
00000010
```

The next:

```text
CanExecute = 1 << 2 = 4
```

Binary:

```text
00000100
```

Now we write:

```go
permissions := CanRead | CanWrite
```

Binary:

```text
00000001  CanRead
00000010  CanWrite
--------
00000011
```

As a result:

```text
permissions = 3
```

But this `3` contains two independent flags.

Then:

```go
permissions&CanRead != 0
```

is checked.

Because the `CanRead` bit is set, the result is:

```text
true
```

Then:

```go
permissions&CanExecute != 0
```

is checked.

The `CanExecute` bit is not set.

That is why the result is:

```text
false
```

This approach lets one value store several independent permissions.

### 8. Removing a flag from a value

Bit flags can not only be added but also removed.

For this Go has the:

```go
&^
```

operator.

It is used for **bit clear**, that is, clearing certain bits.

```go
package main

import "fmt"

type Notification uint8

const (
	NotifyEmail Notification = 1 << iota
	NotifySMS
	NotifyPush
)

func main() {
	settings := NotifyEmail | NotifySMS | NotifyPush

	settings &^= NotifySMS

	fmt.Println(settings&NotifyEmail != 0)
	fmt.Println(settings&NotifySMS != 0)
	fmt.Println(settings&NotifyPush != 0)
}
```

First the values are:

```text
NotifyEmail = 1
NotifySMS   = 2
NotifyPush  = 4
```

Binary:

```text
NotifyEmail = 001
NotifySMS   = 010
NotifyPush  = 100
```

Then:

```go
settings := NotifyEmail | NotifySMS | NotifyPush
```

combines all three flags:

```text
001
010
100
---
111
```

So at first all three notification types are enabled.

Then we write:

```go
settings &^= NotifySMS
```

This means:

> clear the bit belonging to `NotifySMS`

As a result, from:

```text
111
```

what remains is:

```text
101
```

So:

```text
Email = enabled
SMS   = disabled
Push  = enabled
```

That is why:

```go
settings&NotifyEmail != 0
```

gives:

```text
true
```

```go
settings&NotifySMS != 0
```

gives:

```text
false
```

and:

```go
settings&NotifyPush != 0
```

gives:

```text
true
```

The results:

```text
true
false
true
```

### 9. Turning enum values into text

A status in numeric form can be unclear when shown to the user or written to a log.

That is why a method returning text can be written for it.

```go
package main

import "fmt"

type OrderStatus int

const (
	OrderNew OrderStatus = iota
	OrderPaid
	OrderSent
)

func (s OrderStatus) Label() string {
	switch s {
	case OrderNew:
		return "new"

	case OrderPaid:
		return "paid"

	case OrderSent:
		return "sent"

	default:
		return "unknown"
	}
}

func main() {
	fmt.Println(OrderPaid.Label())
	fmt.Println(OrderStatus(20).Label())
}
```

The values are:

```text
OrderNew  = 0
OrderPaid = 1
OrderSent = 2
```

Then:

```go
OrderPaid.Label()
```

is called.

The method lands on the line:

```go
case OrderPaid:
    return "paid"
```

The result is:

```text
paid
```

The next one:

```go
OrderStatus(20).Label()
```

is a very important example.

`20` is not among the declared constants.

But Go allows the conversion:

```go
OrderStatus(20)
```

That is why none of the main `case` values in the `switch` matches, and:

```go
default:
    return "unknown"
```

runs.

The result is:

```text
unknown
```

This shows once again that an enum-like type in Go is not a closed set of values.

The `Label()` method can be used mainly for the user interface.

If for logs and debugging you also need to see the unknown number itself, writing something like:

```go
return fmt.Sprintf("unknown(%d)", s)
```

can be more useful.

### 10. Keeping explicit codes for an external format

It is not always necessary to use `iota`.

Especially if the numeric values of constants are agreed with an external system, writing explicit numbers is safer.

```go
package main

import "fmt"

type PaymentCode int

const (
	PaymentCreated  PaymentCode = 100
	PaymentApproved PaymentCode = 200
	PaymentRejected PaymentCode = 400
)

func main() {
	codes := []PaymentCode{
		PaymentCreated,
		PaymentApproved,
		PaymentRejected,
	}

	for _, code := range codes {
		fmt.Println(code)
	}
}
```

Here the values:

```go
PaymentCreated = 100
```

```go
PaymentApproved = 200
```

and:

```go
PaymentRejected = 400
```

are set explicitly by hand.

For example, imagine these values are agreed with another API:

```text
100 = payment created
200 = payment approved
400 = payment rejected
```

In such a situation using:

```go
iota
```

can be riskier.

Because if a new constant is added in the middle, the `iota` values after it can shift.

When written with explicit numbers:

```go
const (
    PaymentCreated  PaymentCode = 100
    PaymentApproved PaymentCode = 200
    PaymentRejected PaymentCode = 400
)
```

reordering the constants or adding a new value between them does not automatically change the existing codes.

For example, even if we add a new status:

```go
const (
    PaymentCreated  PaymentCode = 100
    PaymentPending  PaymentCode = 150
    PaymentApproved PaymentCode = 200
    PaymentRejected PaymentCode = 400
)
```

the values:

```text
PaymentCreated  = 100
PaymentApproved = 200
PaymentRejected = 400
```

stay unchanged.

This is especially important for:

* a public API;
* a database;
* integration with another service;
* a message broker;
* a file format;
* data stored for a long time.

That is why, before using `iota` just to shorten the code, you should consider whether the numbers themselves carry an external meaning.
