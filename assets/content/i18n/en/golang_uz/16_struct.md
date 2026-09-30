# `struct` in Go

A `struct` combines related values of different types into a single type. For example, a product's name can be a
`string`, its price an `int64` and its stock status a `bool`. Storing this data in one `Product` value rather than in
separate variables makes the code easier to understand.

## Declaring the type and giving values

```go
package main

import "fmt"

type User struct {
	Name  string
	Age   int
	Email string
}

func main() {
	user := User{
		Name:  "Ali",
		Age:   25,
		Email: "ali@example.com",
	}

	fmt.Println(user.Name, user.Age, user.Email)
}
```

Output:

```text
Ali 25 ali@example.com
```

`type User struct` declares a new struct type named `User`. `Name`, `Age` and `Email` are the fields of this struct.

In Go, if a type or field needs to be used from another package, its name must start with a capital letter. For
example, `User` and `Name` can be used from other packages, while `user` or `name` can only be used inside the package
where they are declared.

It is recommended to create a struct value with the field names written out:

```go
User{
    Name:  "Ali",
    Age:   25,
    Email: "ali@example.com",
}
```

With this form, the order in which the fields are written does not matter.

Go also supports the following short form:

```go
User{"Ali", 25, "ali@example.com"}
```

But here the values depend on the order of the fields in the `struct`. If a new field is added to the struct or the
order of the fields changes, such code can lead to bugs.

That is why, in practice, writing the field names is clearer and reduces the chance of mistakes.

## The zero value

In the zero value of a `struct`, each field gets the zero value of its own type:

```go
package main

import "fmt"

type Product struct {
	Name  string
	Price int64
	Stock int
}

func main() {
	var product Product
	fmt.Printf("%q %d %d\n", product.Name, product.Price, product.Stock)
}
```

Output:

```text
"" 0 0
```

## Nested `struct`s

```go
package main

import "fmt"

type Address struct {
	City   string
	Street string
}

type Customer struct {
	Name    string
	Address Address
}

func main() {
	customer := Customer{
		Name: "Lola",
		Address: Address{
			City:   "Tashkent",
			Street: "Amir Temur",
		},
	}

	fmt.Println(customer.Name, customer.Address.City)
}
```

Output:

```text
Lola Tashkent
```

Go has no inheritance. Complex types are usually built by combining smaller types.

## Embedding

If a type is written inside a struct without a field name, it becomes an embedded field:

```go
package main

import "fmt"

type Audit struct {
	CreatedBy string
}

type Order struct {
	ID int
	Audit
}

func main() {
	order := Order{ID: 19, Audit: Audit{CreatedBy: "admin"}}
	fmt.Println(order.ID, order.CreatedBy)
}
```

Output:

```text
19 admin
```

`order.CreatedBy` is a short form of `order.Audit.CreatedBy`. Embedding is not inheritance: `Order` and `Audit` remain
separate types. If field names collide, the field you need is accessed through its full path.

## Value semantics, pointers and comparison

When a `struct` is assigned to another variable, its fields are copied. But a copied field of type `slice`, `map` or
`pointer` may still refer to the same underlying data. So this is not a deep copy. If the fields of the original
`struct` need to be changed, a `pointer` is used.

`struct` values whose fields are all comparable can be compared with `==`. A struct with a field of type `slice`, `map`
or `function` cannot be compared directly.

## Examples

### 1. Creating a value with named fields

```go
package main

import "fmt"

type Product struct {
	Name  string
	Price int
}

func main() {
	book := Product{Name: "Go book", Price: 85_000}
	fmt.Println(book)
}
```

A literal with field names does not depend on the order of the fields. Fields that are not mentioned get the zero value
of their type.

### 2. Updating a struct field

```go
package main

import "fmt"

type Account struct {
	Owner   string
	Balance int
}

func main() {
	account := Account{Owner: "Ali", Balance: 100_000}
	account.Balance += 25_000
	fmt.Println(account)
}
```

A struct field is accessed with a dot. When the `Balance` field is updated, the `Owner` field does not change.

### 3. The zero value of a struct

```go
package main

import "fmt"

type Result struct {
	Score  int
	Passed bool
	Note   string
}

func main() {
	var result Result
	fmt.Printf("%+v\n", result)
}
```

Each field gets the zero value of its type. `%+v` also prints the field names.

### 4. Comparing structs

```go
package main

import "fmt"

type Point struct {
	X int
	Y int
}

func main() {
	a := Point{X: 2, Y: 3}
	b := Point{X: 2, Y: 3}
	fmt.Println(a == b)
}
```

Struct values whose fields are all comparable are compared field by field with `==`.

### 5. Changing a copy of a struct independently

```go
package main

import "fmt"

type Size struct {
	Width  int
	Height int
}

func main() {
	original := Size{Width: 10, Height: 5}
	copied := original
	copied.Width = 20
	fmt.Println(original, copied)
}
```

When a struct is assigned to another variable, its value is copied. Changing a plain field in the copy does not affect
the original struct.

### 6. Changing a struct through a pointer

```go
package main

import "fmt"

type User struct {
	Name   string
	Active bool
}

func activate(u *User) {
	u.Active = true
}

func main() {
	user := User{Name: "Vali"}
	activate(&user)
	fmt.Println(user)
}
```

A struct pointer lets a function change the fields of the original struct. Go allows you to write `(*u).Active` in the
short form `u.Active`.

### 7. A nested struct

```go
package main

import "fmt"

type Address struct {
	City  string
	House int
}

type Person struct {
	Name    string
	Address Address
}

func main() {
	person := Person{Name: "Ali", Address: Address{City: "Tashkent", House: 12}}
	fmt.Println(person.Address.City)
}
```

A field of an inner struct is accessed by writing the dots one after another.

### 8. Promoting a field through embedding

```go
package main

import "fmt"

type Address struct {
	City string
}

type Organization struct {
	Name string
	Address
}

func main() {
	o := Organization{Name: "Go center", Address: Address{City: "Samarkand"}}
	fmt.Println(o.City)
}
```

When an inner type is written without a field name, it is called embedding. That is why the short form `o.City` can be
used instead of `o.Address.City`.

### 9. Building a slice of structs

```go
package main

import "fmt"

type Student struct {
	Name  string
	Score int
}

func main() {
	students := []Student{{Name: "Ali", Score: 86}, {Name: "Vali", Score: 92}}
	for _, student := range students {
		fmt.Println(student.Name, student.Score)
	}
}
```

A slice element can be a struct. In this example, on each iteration `range` gives a copy of the next struct value.

### 10. Using a struct as a map key

```go
package main

import "fmt"

type Coordinate struct {
	X int
	Y int
}

func main() {
	colors := map[Coordinate]string{{X: 1, Y: 2}: "blue"}
	fmt.Println(colors[Coordinate{X: 1, Y: 2}])
}
```

A struct whose fields are comparable can be a map key. This way two coordinates are combined into a single key.
