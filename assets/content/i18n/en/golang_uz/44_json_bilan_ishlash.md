# Working with JSON in Go

JSON is a text-based data exchange format. It is used in web APIs, configuration files, data exchange between services and many other places.

In Go, the `encoding/json` package from the standard library is available for working with JSON.

This package works in two main directions:

* turning JSON data into a Go value — **decoding**;
* turning a Go value into JSON — **encoding**.

For example, the following JSON may come from a server:

```json
{
  "name": "Ali",
  "active": true
}
```

A Go program can decode this data into a `struct`, `map`, `slice` or another suitable type.

Conversely, a `struct` value inside Go can be turned into JSON and written to an HTTP response or a file.

## JSON and Go types

JSON and Go types are not the same. That is why `encoding/json` turns a JSON value into a suitable Go type.

The usual mapping is as follows:

| JSON    | Usual type in Go                                 |
| ------- | ------------------------------------------------ |
| string  | `string`                                         |
| number  | `int`, `float64` or another numeric type         |
| boolean | `bool`                                           |
| array   | slice or array                                   |
| object  | struct or map                                    |
| null    | `nil` for a pointer, slice, map or interface     |

For example, the following JSON:

```json
{
  "name": "Ali",
  "age": 30,
  "active": true,
  "roles": ["editor", "author"]
}
```

may match the following Go struct:

```go
type User struct {
	Name   string
	Age    int
	Active bool
	Roles  []string
}
```

Here:

* the JSON `string` value goes into a `string`;
* the JSON `number` value goes into an `int`;
* the JSON `boolean` value goes into a `bool`;
* and the JSON array goes into a `[]string` slice.

There is an important rule when decoding through a struct: only **exported fields** are used.

In Go, if a field name starts with an uppercase letter, it is considered exported.

For example:

```go
type User struct {
	Name string
	age  int
}
```

In this struct `Name` is exported, while `age` is not exported.

That is why `encoding/json` can work with `Name`, but it cannot write a value to the `age` field and does not output it to JSON either.

## Struct tags

JSON keys and Go field names do not have to be the same. Struct tags are used to control this.

```go
type User struct {
	Name     string   `json:"name"`
	Email    string   `json:"email,omitempty"`
	Password string   `json:"-"`
	Roles    []string `json:"roles"`
}
```

Here each `json:"..."` entry tells the `encoding/json` package how to work with the field.

### Setting the JSON key

```go
Name string `json:"name"`
```

The Go field's name is `Name`, and the key inside JSON is `name`.

For example:

```go
user := User{Name: "Ali"}
```

when encoded to JSON it comes out as:

```json
{
  "name": "Ali"
}
```

If no struct tag is written, the package usually uses the field's own name.

### `omitempty`

```go
Email string `json:"email,omitempty"`
```

`omitempty` means not including the field in the JSON result when its value is considered empty.

For example:

```go
user := User{
	Name:  "Ali",
	Email: "",
}
```

when encoded, the `email` field may be missing from the result.

This is convenient for not sending unnecessary empty fields in an API response.

But when using `omitempty`, you may need to distinguish a zero value from the "no value given" case.

For example, `false` for `bool` and `0` for `int` are also considered empty values. If `false` or `0` is a real business value, a pointer or another model may be needed.

### Excluding a field entirely

```go
Password string `json:"-"`
```

`json:"-"` excludes the field from JSON processing entirely.

This field:

* is not encoded to JSON;
* is not decoded from JSON.

This is useful, for example, for internal or secret fields.

But relying only on `json:"-"` and considering security fully solved is not right. Where and how secret data is used must be controlled separately.

## `Marshal` and `Unmarshal`

`json.Marshal()` and `json.Unmarshal()` are convenient for working with JSON data that is fully present in memory.

`json.Marshal()` turns a Go value into a JSON `[]byte`.

`json.Unmarshal()` decodes a `[]byte` holding JSON into a Go value.

```go
data, err := json.Marshal(User{Name: "Ali", Roles: []string{"editor"}})
if err != nil {
	return err
}

var user User
if err := json.Unmarshal(data, &user); err != nil {
	return err
}
```

Let's look at the first part:

```go
data, err := json.Marshal(User{Name: "Ali", Roles: []string{"editor"}})
```

Here the `User` value is encoded to JSON.

The result is returned not as a `string` but as a `[]byte`.

Roughly the following data is produced:

```json
{"name":"Ali","roles":["editor"]}
```

Then:

```go
var user User
```

creates a new `User` value. For now its fields are in their zero value state.

Then:

```go
json.Unmarshal(data, &user)
```

writes the JSON into this struct.

The reason `&user` is given here is important.

`Unmarshal` must change an existing value. That is why it is given not the struct itself but a pointer it can write through.

Writing it like this is wrong:

```go
json.Unmarshal(data, user)
```

Because writing values into a copy of `user` cannot change the caller's struct.

The correct variant:

```go
json.Unmarshal(data, &user)
```

For small JSON fully present in memory, `Marshal` and `Unmarshal` are usually the simplest solution.

For example:

* a small JSON column taken from a database;
* JSON inside a test;
* a small HTTP response body already read into a `[]byte`.

For large streams, `Encoder` and `Decoder` may fit better.

## `Encoder` and `Decoder`

`json.Encoder` and `json.Decoder` work with `io.Writer` and `io.Reader`.

This makes them convenient for working with streams.

For example:

```go
if err := json.NewEncoder(os.Stdout).Encode(user); err != nil {
	return err
}
```

Here:

```go
json.NewEncoder(os.Stdout)
```

creates an encoder that writes to `os.Stdout`.

`os.Stdout` implements the `io.Writer` interface. That is why the `Encoder` can write the JSON result directly to the terminal.

Then:

```go
Encode(user)
```

turns the `user` value into JSON and writes the result to the writer.

In this case you do not have to separately do:

```go
data, err := json.Marshal(user)
```

to produce a `[]byte` and then write it to the writer.

`Encode` has one more important property: it adds a newline after the JSON value.

For example, the result is written as:

```text
{"name":"Ali","roles":["editor"]}
```

with `\n` at the end.

### `Decoder`

A `Decoder`, on the other hand, reads JSON from an `io.Reader`.

For example:

```go
dec := json.NewDecoder(r)

var user User
if err := dec.Decode(&user); err != nil {
	return err
}
```

Here `r` may be:

* a file;
* an HTTP request body;
* a TCP connection;
* a `strings.Reader`;
* another `io.Reader`.

When working with a stream such as a file, the terminal or a network connection, `Encoder` and `Decoder` help avoid creating an unnecessary intermediate `[]byte`.

This is especially convenient when the data is already in reader or writer form.

## Strict decoding

A plain `json.Decoder` usually ignores unknown fields inside a JSON object.

In some cases this is convenient.

But in configuration files it can be dangerous.

For example, the configuration struct is:

```go
type Config struct {
	Debug bool `json:"debug"`
}
```

and the user mistakenly writes:

```json
{
  "debgu": true
}
```

`debgu` does not exist in the struct.

If unknown fields are ignored, the program may run without an error. And the user thinks `debug` has been turned on.

In such a case `DisallowUnknownFields()` is useful.

It returns an error if a field that does not match the struct appears inside a JSON object.

It must also be checked that no other JSON value comes after the single JSON value.

```go
func decodeConfig(r io.Reader) (Config, error) {
	var cfg Config
	dec := json.NewDecoder(r)
	dec.DisallowUnknownFields()

	if err := dec.Decode(&cfg); err != nil {
		return Config{}, fmt.Errorf("could not read the JSON: %w", err)
	}

	if err := dec.Decode(&struct{}{}); err != io.EOF {
		if err == nil {
			return Config{}, errors.New("only one JSON value was expected")
		}

		return Config{}, fmt.Errorf("extra JSON value: %w", err)
	}

	return cfg, nil
}
```

This function needs the following packages:

```go
import (
	"encoding/json"
	"errors"
	"fmt"
	"io"
)
```

Now let's go through the function step by step.

First:

```go
dec := json.NewDecoder(r)
```

creates a decoder working on top of the reader.

Then:

```go
dec.DisallowUnknownFields()
```

turns on the mode that treats unknown JSON fields as errors.

The first `Decode`:

```go
if err := dec.Decode(&cfg); err != nil {
	return Config{}, fmt.Errorf("could not read the JSON: %w", err)
}
```

writes the main JSON value into `cfg`.

If the syntax is wrong or the value does not match the struct type, an error may be returned here.

Then the second `Decode` runs:

```go
if err := dec.Decode(&struct{}{}); err != io.EOF {
```

This is not for reading a new business value. The goal is to check whether there is more data after the first JSON value.

If the stream has ended, `Decode` returns `io.EOF`.

This is the desired case:

```text
the first JSON value was read
↓
Decode was called again
↓
io.EOF was returned
↓
so there is no other JSON value
```

But if the input is:

```json
{"debug": true}
{"debug": false}
```

the first `Decode` reads only the first object.

The second `Decode` finds the second object. As a result you can detect that the "only one JSON value was expected" rule was broken.

This is especially important for strict inputs such as configuration.

## Error types

`encoding/json` returns some errors through special types.

This makes it possible to determine the cause of the error more precisely.

Invalid JSON syntax may be a `*json.SyntaxError`.

For example:

```json
{"name":"Ali",
```

This JSON is not closed.

If a JSON value does not match the Go field type, a `*json.UnmarshalTypeError` may be returned.

For example:

```go
type User struct {
	Age int `json:"age"`
}
```

but the JSON is:

```json
{
  "age": "thirty"
}
```

then a `string` value cannot be written into an `int`.

The error can be checked through `errors.As`:

```go
var syntaxErr *json.SyntaxError
var typeErr *json.UnmarshalTypeError

switch {
case errors.As(err, &syntaxErr):
	fmt.Printf("JSON syntax error, offset: %d\n", syntaxErr.Offset)

case errors.As(err, &typeErr):
	fmt.Printf("wrong type for the %s field\n", typeErr.Field)

default:
	fmt.Println("could not read the JSON")
}
```

In the first case:

```go
errors.As(err, &syntaxErr)
```

checks whether there is a `*json.SyntaxError` in the error chain.

If there is:

```go
syntaxErr.Offset
```

shows roughly at which byte position of the JSON stream the error occurred.

In the second case:

```go
errors.As(err, &typeErr)
```

determines that the error is a `*json.UnmarshalTypeError`.

`typeErr.Field` may give information about the struct field.

This diagnostic information is useful in logs.

But returning exactly this internal error text to the user in full is not always good.

For example, the log may contain:

* file paths;
* internal struct names;
* secret values;
* implementation details.

That is why it is usually better to keep the internal diagnostics in the log and return a short, safe message to the external user.

For example:

```text
The configuration JSON format is invalid.
```

For an API, a general error with a suitable HTTP status may be returned.

## A configuration example

The following example shows using `Decoder` and `DisallowUnknownFields()` together.

```go
package main

import (
	"encoding/json"
	"fmt"
	"log"
	"strings"
)

type Config struct {
	Address string `json:"address"`
	Debug   bool   `json:"debug"`
}

func main() {
	input := `{"address":"localhost:8080","debug":true}`

	var cfg Config

	dec := json.NewDecoder(strings.NewReader(input))
	dec.DisallowUnknownFields()

	if err := dec.Decode(&cfg); err != nil {
		log.Fatal("could not read the configuration: ", err)
	}

	fmt.Printf("Address: %s, debug: %t\n", cfg.Address, cfg.Debug)
}
```

This example is deliberately not tied to a file or an HTTP request.

First the JSON is given as a plain string:

```go
input := `{"address":"localhost:8080","debug":true}`
```

Then:

```go
strings.NewReader(input)
```

makes it possible to treat this string as an `io.Reader`.

As a result `json.Decoder` can read the string just as if it were reading a file or a network stream.

The next line:

```go
dec.DisallowUnknownFields()
```

forbids unknown fields.

For example, if the input is misspelled:

```json
{
  "adress": "localhost:8080",
  "debug": true
}
```

`adress` does not match the `address` field in the struct.

Then the decoder returns an error.

The main decoding:

```go
if err := dec.Decode(&cfg); err != nil {
	log.Fatal("could not read the configuration: ", err)
}
```

writes the JSON values into the `cfg` struct.

After decoding, roughly the following value is produced:

```go
Config{
	Address: "localhost:8080",
	Debug:   true,
}
```

At the end:

```go
fmt.Printf("Address: %s, debug: %t\n", cfg.Address, cfg.Debug)
```

prints the values to the terminal.

Result:

```text
Address: localhost:8080, debug: true
```

The main rule in this example is that a `Decoder` is not limited to files or HTTP.

It is enough to give it an `io.Reader`.

That is why the same decoding code can work with various sources such as:

* `os.File`;
* `http.Request.Body`;
* `strings.Reader`;
* `bytes.Reader`;
* a network connection.
