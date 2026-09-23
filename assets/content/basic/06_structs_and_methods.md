# Structs and Methods

## Defining a struct

```go
type User struct {
    Name  string
    Email string
    Age   int
}

u := User{Name: "Aziz", Email: "aziz@example.com", Age: 25}
fmt.Println(u.Name)
```

## Methods

```go
func (u User) Greeting() string {
    return "Hi, " + u.Name
}

// Pointer receiver: can modify the struct
func (u *User) Birthday() {
    u.Age++
}
```

## Embedding

```go
type Admin struct {
    User
    Level int
}

a := Admin{User: User{Name: "Root"}, Level: 1}
fmt.Println(a.Greeting()) // promoted method
```

> **Tip:** Use a pointer receiver when the method mutates state or the struct is large.

## Check yourself

```quiz
Why would a method use a pointer receiver `(u *User)`?
- It's required for all methods
+ To modify the struct or avoid copying it
- To make the method private
- To allow calling it on `nil` only
> Value receivers get a copy; pointer receivers share the original.
```
