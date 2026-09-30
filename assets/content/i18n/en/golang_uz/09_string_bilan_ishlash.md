# Working with `string` in Go

`string` is the type that holds text and arbitrary sequences of bytes. Values such as user names, URLs, file paths and
JSON are often used in programs as `string`s.

To work with strings correctly, it is important to tell three concepts apart:

* **bytes** - how the text is stored in memory;
* **Unicode code points** - the value assigned to each character;
* **user-visible characters** - a letter, digit or symbol that appears on screen as a single character.

The counts of these three are not always the same. For example, a plain English letter usually takes one byte.
Letters with accents, Cyrillic letters or emoji may consist of several bytes.

## String literals and immutability

In Go, text can be written in two ways.

A string written in double quotes is called an **interpreted string literal**. In it, special sequences such as `\n`,
`\t` and `\"` have a special meaning:

```go
text := "Hello\nWorld"
```

Here `\n` means moving to a new line.

A string written in backquotes is called a **raw string literal**. The text in it is stored almost exactly as written.
Special sequences are not interpreted, and the text can span several lines:

```go
text := `Hello\nWorld`
```

In this case `\n` is not a new line but is stored as two ordinary characters.

```go
package main

import "fmt"

func main() {
	line := "First line\nSecond line"
	path := `C:\temp\main.go`

	fmt.Println(line)
	fmt.Println(path)
}
```

**Output:**

```text
First line
Second line
C:\temp\main.go
```

`'A'` in single quotes is not a string but a `rune` literal. A `rune` represents a single Unicode code point and is
another name for the `int32` type.

In Go, strings are immutable. You cannot replace a byte inside a string that has been created:

```go
text := "Go"
// text[0] = 'N' // compilation error: cannot assign to a string element
```

`text = "No"`, on the other hand, is allowed. It does not change the old string; it gives the `text` variable a
different string value.

## String, `byte` and `rune`

A string can hold arbitrary bytes. Go usually uses UTF-8 for text, but a `string` value itself does not guarantee
that the bytes inside it are valid UTF-8.

- `byte` represents a single byte and is another name for the `uint8` type;
- `rune` represents a Unicode code point and is another name for the `int32` type;
- ASCII characters take one byte in UTF-8, while other characters take several bytes.

```go
package main

import (
	"fmt"
	"unicode/utf8"
)

func main() {
	text := "Go is fun 😊"

	fmt.Println("Bytes:", len(text))
	fmt.Println("Rune count:", utf8.RuneCountInString(text))
	for index, char := range text {
		fmt.Printf("%2d: %c\n", index, char)
	}
}
```

Output (beginning):

```text
Bytes: 14
Rune count: 11
 0: G
 1: o
 2: (space)
 3: i
```

`len(text)` counts bytes, not characters. `utf8.RuneCountInString()` counts Unicode code points. Each time, `range`
gives one UTF-8 encoded rune, and the index is the byte position where that rune starts.

> **Info**
>
> The number of runes is not always equal to the number of characters the user sees. Some characters are made of several
> Unicode code points. The Go standard library has no general function that counts such multi-code-point characters.

## Getting bytes by index

`text[i]` returns the byte at index `i` as a `byte`:

```go
package main

import "fmt"

func main() {
	text := "Go"
	first := text[0]

	fmt.Println(first)
	fmt.Printf("%c\n", first)
}
```

**Output:**

```text
71
G
```

`71` is the byte value of `G` in UTF-8 and ASCII. `%c` prints that value as a character. If the index is negative or
equal to or greater than `len(text)`, the program fails at runtime (panic).

Taking only one byte of a multi-byte character does not give the whole character. To process Unicode text by
characters, `range` or `[]rune` is used:

```go
package main

import "fmt"

func main() {
	text := "naïve"
	runes := []rune(text)

	fmt.Printf("First rune: %c\n", runes[0])
	fmt.Printf("Third rune: %c\n", runes[2])
}
```

Output:

```text
First rune: n
Third rune: ï
```

`[]rune(text)` creates a new rune slice and the memory for it. If the text only needs to be read once in sequence,
`range` usually uses less memory.

## Joining and comparing strings

A small number of strings can be joined with `+`. `==` and `!=` check whether the byte sequences are equal. `<`,
`>`, `<=` and `>=` compare lexicographically, that is, in the order of byte values.

```go
package main

import "fmt"

func main() {
	firstName := "Ali"
	lastName := "Valiyev"
	fullName := firstName + " " + lastName

	fmt.Println(fullName)
	fmt.Println(fullName == "Ali Valiyev")
	fmt.Println("Go" < "Rust")
}
```

Output:

```text
Ali Valiyev
true
true
```

## Building a string with `strings.Builder`

Adding a few small strings with the `+` operator is convenient in simple cases:

```go
text := "Hello, " + "world!"
```

But adding strings again and again with `+` inside a large loop can be inefficient. Because Go strings are immutable,
each addition may create a new string and allocate extra memory.

To collect many pieces of text, `strings.Builder` is used:

```go
package main

import (
	"fmt"
	"strings"
)

func main() {
	var builder strings.Builder

	for i := 1; i <= 3; i++ {
		if i > 1 {
			builder.WriteString(", ")
		}

		fmt.Fprint(&builder, i)
	}

	fmt.Println(builder.String())
}
```

Output:

```text
1, 2, 3
```

In this code:

* `var builder strings.Builder` - creates a builder for collecting pieces of text;
* `builder.WriteString(", ")` - writes a comma and a space into the builder;
* `fmt.Fprint(&builder, i)` - writes the number into the builder as text;
* `builder.String()` - turns the collected result into an ordinary `string` value.

The condition `if i > 1` is used so that the comma goes only between numbers, not before the first number.

`strings.Builder` collects the pieces in an internal buffer. The finished result is obtained with `String()`.

## Getting part of a string

`text[start:end]` returns the range of bytes from index `start` up to index `end`, but not including `end` itself:

```go
package main

import "fmt"

func main() {
	text := "Hello, world!"

	fmt.Println(text[:5])
	fmt.Println(text[7:12])
	fmt.Println(text[7:])
}
```

**Output:**

```text
Hello
world
world!
```

The bounds are byte indexes. If `0 <= start <= end <= len(text)` does not hold, the program fails. Cutting in the
middle of a UTF-8 character can produce a wrong result.

If you need to cut by Unicode code points, convert to `[]rune` first:

```go
runes := []rune("Gopher")
part := string(runes[:3]) // "Gop"
```

## Copying part of a string

When a small part is taken from a large string, the resulting string may in some cases keep using the memory where
the original string is stored.

For example:

```go
bigText := "a very large amount of text..."
part := bigText[:4]
```

Here, even though `part` represents only a small piece of text, it may cause the big text to stay in memory longer.

If you need a copy of the small part that is completely independent of the original string, `strings.Clone` is used:

```go
part := strings.Clone(bigText[:4])
```

`strings.Clone` creates a new copy of the given string. After that, `part` no longer depends on the memory of the
original big string.

However, `strings.Clone` does not always need to be used, because it allocates new memory and copies the string data.
It makes sense mainly in these cases:

* the small part was taken from a very large string;
* this part is kept for a long time;
* a copy of the string is required.

In simple, short-lived operations, the part of a string can be used directly.

## The `strings` package

The `strings` package of the standard library provides functions for searching, splitting, joining, replacing and
changing case.

### Searching and checking

```go
package main

import (
	"fmt"
	"strings"
)

func main() {
	text := "Go programming language"

	fmt.Println(strings.Contains(text, "Go"))
	fmt.Println(strings.Count(text, "a"))
	fmt.Println(strings.HasPrefix(text, "Go"))
	fmt.Println(strings.HasSuffix(text, "language"))
	fmt.Println(strings.Index(text, "program"))
	fmt.Println(strings.Index(text, "Python"))
}
```

Output:

```text
true
3
true
true
3
-1
```

`Contains()` checks whether a substring exists, and `Count()` counts how many times it occurs. `Index()` returns the
byte index of the first match, or `-1` if nothing is found. Before using the result as an index, check that it is not
`-1`.

`strings.ContainsAny(text, "abc")` checks whether at least one of the runes in the second argument is present. To
search for a whole substring, use `Contains()`.

### Splitting and rejoining a string

In Go, `strings.Split()` and `strings.Fields()` are used to split a string into parts, and `strings.Join()` to join
the parts back together.

```go
package main

import (
	"fmt"
	"strings"
)

func main() {
	line := " go, backend ,api "
	parts := strings.Split(line, ",")

	for i := range parts {
		parts[i] = strings.TrimSpace(parts[i])
	}

	fmt.Println(parts)
	fmt.Println(strings.Join(parts, " | "))
	fmt.Println(strings.Fields("  Go\tbackend\nAPI  "))
}
```

Output:

```text
[go backend api]
go | backend | api
[Go backend API]
```

`strings.Split(line, ",")` splits the string at every comma:

```go
parts := strings.Split(line, ",")
```

The result is the following slice:

```go
[" go" " backend " "api "]
```

Spaces may remain at the start or end of the elements. That is why the extra spaces are removed inside the loop with
`strings.TrimSpace()`:

```go
for i := range parts {
	parts[i] = strings.TrimSpace(parts[i])
}
```

`strings.Join()` joins the strings in a slice into one string using the given separator:

```go
strings.Join(parts, " | ")
```

Output:

```text
go | backend | api
```

`strings.Fields()` splits a string by whitespace:

```go
strings.Fields("  Go\tbackend\nAPI  ")
```

Along with ordinary spaces, this function also treats tabs (`\t`), newlines (`\n`) and other Unicode whitespace
characters as separators. Consecutive whitespace counts as a single separator, and no empty elements are added to
the result.

The main difference:

* `Split()` splits only by the given separator;
* `Split()` keeps empty elements in some cases;
* `Fields()` treats any run of whitespace as a separator;
* `Fields()` does not add empty elements to the result;
* `Join()` joins slice elements into one string.

It is useful to show with a separate example how `Split()` produces empty elements:

```go
fmt.Println(strings.Split("go,,api", ","))
// [go  api]
```

### Replacing and repeating text in a string

In Go, the `strings.Replace()` and `strings.ReplaceAll()` functions are used to replace some text in a string with
other text. To repeat the same text several times, `strings.Repeat()` is used.

```go
package main

import (
	"fmt"
	"strings"
)

func main() {
	text := "Go is fast, Go is simple"

	fmt.Println(strings.Replace(text, "Go", "Golang", 1))
	fmt.Println(strings.ReplaceAll(text, "Go", "Golang"))
	fmt.Printf("%q\n", strings.Repeat("Go! ", 3))
}
```

Output:

```text
Golang is fast, Go is simple
Golang is fast, Golang is simple
"Go! Go! Go! "
```

`strings.Replace()` replaces old text in a string with new text:

```go
strings.Replace(text, "Go", "Golang", 1)
```

Here:

* `text` — the string to change;
* `"Go"` — the old text to search for;
* `"Golang"` — the new text written in its place;
* `1` — how many occurrences to replace.

So only the first `"Go"` is replaced:

```text
Golang is fast, Go is simple
```

To replace all occurrences, you can pass `-1`:

```go
strings.Replace(text, "Go", "Golang", -1)
```

But for this purpose `strings.ReplaceAll()` is clearer and easier to read:

```go
strings.ReplaceAll(text, "Go", "Golang")
```

As a result, every `"Go"` in the string is replaced:

```text
Golang is fast, Golang is simple
```

`strings.Repeat()` repeats the given string the specified number of times:

```go
strings.Repeat("Go! ", 3)
```

Output:

```text
Go! Go! Go! 
```

Because the example uses the `%q` formatting verb, the result is printed in quotes. This helps you see the space at
the end of the string too.

If `Repeat()` is given a negative count, or the string to create would be too large, the program may `panic`. So if
the count comes from the user or an external source, check it first:

```go
if count >= 0 && count <= 100 {
	result := strings.Repeat("Go! ", count)
	fmt.Println(result)
}
```

### Removing characters from the start and end of a string

In Go, the `Trim` functions of the `strings` package are used to remove unwanted spaces, prefixes, suffixes and other
characters from the start or end of a string.

```go
package main

import (
	"fmt"
	"strings"
)

func main() {
	value := "\t Go programming language \n"
	url := "https://go-lang.uz/"

	fmt.Printf("%q\n", strings.TrimSpace(value))
	fmt.Println(strings.TrimPrefix(url, "https://"))
	fmt.Println(strings.TrimSuffix(url, "/"))
	fmt.Println(strings.Trim("...Go...", "."))
}
```

Output:

```text
"Go programming language"
go-lang.uz/
https://go-lang.uz
Go
```

`strings.TrimSpace()` removes whitespace characters from the start and end of a string:

```go
strings.TrimSpace(value)
```

Along with ordinary spaces, this function also removes tabs (`\t`), newlines (`\n`) and other Unicode whitespace
characters. It does not touch spaces inside the string.

`strings.TrimPrefix()` removes an exact prefix from the start of a string:

```go
strings.TrimPrefix(url, "https://")
```

Output:

```text
go-lang.uz/
```

`strings.TrimSuffix()` removes an exact suffix from the end of a string:

```go
strings.TrimSuffix(url, "/")
```

Output:

```text
https://go-lang.uz
```

If the given prefix or suffix is not in the string, `TrimPrefix()` and `TrimSuffix()` return the original string
unchanged.

`strings.Trim()`, on the other hand, takes its second argument not as a whole piece of text but as a set of characters
to remove:

```go
strings.Trim("...Go...", ".")
```

Here all the dots at the start and end of the string are removed:

```text
Go
```

For example:

```go
fmt.Println(strings.Trim("!?Go?!", "!?"))
```

Output:

```text
Go
```

Because `Trim()` removes the `!` and `?` characters from both edges of the string for as long as it finds them. The
characters in the middle of the string are kept.

### Converting case and comparing without regard to case

In Go, the `strings.ToLower()` and `strings.ToUpper()` functions are used to convert the letters of a string to lower
or upper case. To compare two strings without regard to case, `strings.EqualFold()` is used.

```go
package main

import (
	"fmt"
	"strings"
)

func main() {
	value := "Go Programming"

	fmt.Println(strings.ToLower(value))
	fmt.Println(strings.ToUpper(value))
	fmt.Println(strings.EqualFold("GO", "go"))
}
```

Output:

```text
go programming
GO PROGRAMMING
true
```

`strings.ToLower()` converts the letters of a string to lower case:

```go
strings.ToLower("Go Programming")
```

Output:

```text
go programming
```

`strings.ToUpper()` converts the letters to upper case:

```go
strings.ToUpper("Go Programming")
```

Output:

```text
GO PROGRAMMING
```

These functions return a new string. The original string does not change, because strings in Go are immutable values.

`strings.EqualFold()` compares two strings without regard to upper and lower case:

```go
strings.EqualFold("GO", "go")
```

Output:

```text
true
```

If you only need to check equality without regard to case, using `EqualFold()` is better than converting both strings
with `ToLower()` and comparing them:

```go
// Works, but the intent is not very clear
strings.ToLower(a) == strings.ToLower(b)

// Expresses the intent more clearly
strings.EqualFold(a, b)
```

`EqualFold()` uses the Unicode rules for comparing letters. That is why it also suits working with writing systems
other than plain English letters.

From its name, you might think `strings.ToTitle()` capitalizes only the first letter of each word, but it does not work
that way. This function converts every letter of the string to `title case` according to the Unicode rules:

```go
fmt.Println(strings.ToTitle("go programming"))
```

The result is usually:

```text
GO PROGRAMMING
```

That is why `ToTitle()` is not meant for formatting headings in natural language. For example, the rules for
capitalizing only the first letter of each word in a name or heading differ between languages and must be handled
with separate logic.

### Changing characters with `strings.Map()`

`strings.Map()` processes every Unicode character of a string, that is, every `rune`, with the given function and
produces a new string.

If the function:

* returns the rune, that character is added to the result;
* returns another rune, the character is replaced;
* returns `-1`, the character is removed from the result.

In the following example only letters are kept, while digits, dots and spaces are removed:

```go
package main

import (
	"fmt"
	"strings"
	"unicode"
)

func main() {
	value := "Go 1.22"

	onlyLetters := strings.Map(func(char rune) rune {
		if unicode.IsLetter(char) {
			return char
		}

		return -1
	}, value)

	fmt.Println(onlyLetters)
}
```

Output:

```text
Go
```

`strings.Map()` passes the runes of the string one by one to the `char` variable:

```go
func(char rune) rune
```

`unicode.IsLetter(char)` checks whether the rune is a letter. If it is, it is returned unchanged:

```go
return char
```

If the rune is not a letter, `-1` is returned and it is not added to the new string:

```go
return -1
```

`strings.Map()` can be used not only to remove characters but also to replace them. For example, replacing all
whitespace with a dash:

```go
result := strings.Map(func(char rune) rune {
	if unicode.IsSpace(char) {
		return '-'
	}

	return char
}, "Go programming language")

fmt.Println(result)
```

Output:

```text
Go-programming-language
```

This technique is useful for cleaning text, normalizing it or keeping only allowed characters.

However, validation and cleaning text are not the same task. Silently removing invalid characters when they are
entered can hide the user's mistake. If an entered value must follow strict rules, it is better to return a clear error
message to the user than to delete the invalid characters.

## Checking that a string is valid UTF-8

In Go, a `string` is really a sequence of bytes. That is why a string does not always have to contain valid UTF-8 text.
Invalid bytes can appear especially when data comes from a file, the network, a database or another external source.

In the following example, the byte `0xff` does not follow the UTF-8 rules:

```go
package main

import (
	"fmt"
	"unicode/utf8"
)

func main() {
	value := string([]byte{0xff, 'G', 'o'})

	fmt.Println(utf8.ValidString(value))
	fmt.Printf("%q\n", value)
}
```

Output:

```text
false
"\xffGo"
```

`utf8.ValidString()` checks whether the bytes in a string form a valid UTF-8 sequence:

```go
utf8.ValidString(value)
```

If the string is valid UTF-8, the function returns `true`, otherwise `false`.

In the example, `value` is created from these bytes:

```go
[]byte{0xff, 'G', 'o'}
```

The bytes `'G'` and `'o'` are valid UTF-8 characters, but `0xff` is not a valid byte in UTF-8 text. That is why the
result is `false`.

The `%q` format prints the string with quotes and escape sequences:

```go
fmt.Printf("%q\n", value)
```

That is why the invalid byte is shown in the output as `\xff`:

```text
"\xffGo"
```

If a `range` loop is used over an invalid UTF-8 string, Go returns the value `utf8.RuneError` in place of the invalid
sequence. It usually appears on screen as the `�` character:

```go
for _, char := range value {
	fmt.Printf("%c\n", char)
}
```

Approximate output:

```text
�
G
o
```

If the protocol or file format you are using accepts only UTF-8 text, check the value before processing it:

```go
if !utf8.ValidString(value) {
	fmt.Println("Error: the text is not valid UTF-8")
	return
}
```

This check helps keep badly encoded data from passing to later stages.

## Common mistakes

### Thinking the result of `len()` is the number of characters

In Go, `len()` returns the number of bytes in a string, not the number of characters.

With ASCII characters, one character usually takes one byte. That is why for plain English text the result of `len()`
seems equal to the number of characters:

```go
text := "Go"

fmt.Println(len(text)) // 2
```

With Unicode characters, one character can consist of several bytes:

```go
text := "Go😊"

fmt.Println(len(text))                    // 6 bytes
fmt.Println(utf8.RuneCountInString(text)) // 3 runes
```

To find the number of code points, that is runes, `utf8.RuneCountInString()` is used.

However, the number of characters the user sees on screen is not always equal to the number of runes either. For
example, some emoji or diacritical marks can be made of several runes. In such cases a special solution that counts
grapheme clusters is needed.

### Cutting a string at the wrong byte boundary

When a string is cut like this, the indexes mean bytes, not characters:

```go
part := text[a:b]
```

If a Unicode character consists of several bytes, cutting it in the middle can produce an invalid UTF-8 string.

For example:

```go
text := "Go😊"
part := text[:3]

fmt.Printf("%q\n", part)
```

This cut may take only the first byte of the emoji, and the result will be invalid UTF-8.

If you need to cut by runes, you can convert the string to `[]rune`:

```go
text := "Go😊"
runes := []rune(text)

part := string(runes[:3])

fmt.Println(part) // Go😊
```

This approach is clear, but it needs extra memory because it creates a new slice and string.

### Thinking `strings.Trim()` removes a substring

`strings.Trim()` takes its second argument not as a whole substring but as a set of runes to remove.

For example:

```go
result := strings.Trim("abba", "ab")

fmt.Printf("%q\n", result)
```

Output:

```text
""
```

The reason is that the function removes all `a` and `b` runes from the start and end of the string.

If you need to remove the exact `"ab"` part from the start of the string, use `TrimPrefix()`:

```go
fmt.Println(strings.TrimPrefix("abba", "ab"))
// ba
```

For an exact part at the end of the string, use `TrimSuffix()`:

```go
fmt.Println(strings.TrimSuffix("abba", "ba"))
// ab
```

### Thinking case conversion solves every text problem

Converting text with `ToLower()` or `ToUpper()` does not always fully match the rules of natural language. Unicode
case rules and the text formatting requirements of different languages can be complex.

If you only need to check technical equality without regard to case, use `strings.EqualFold()`:

```go
fmt.Println(strings.EqualFold("GO", "go"))
// true
```

But for formatting user names, sorting by local language rules or creating headings, plain `ToLower()` and `ToUpper()`
may not be enough. Such tasks need a clear product requirement and a special library suited to the language.

## Examples

### 1. Collecting text with `strings.Builder`

```go
package main

import (
	"fmt"
	"strings"
)

func main() {
	var builder strings.Builder
	for i := 1; i <= 3; i++ {
		builder.WriteString(fmt.Sprintf("Line %d\n", i))
	}
	fmt.Print(builder.String())
}
```

When joining many pieces one after another, `Builder` reduces how often a new string is created. The finished result is
obtained with `String()`.

### 2. Cleaning up extra spaces between words

```go
package main

import (
	"fmt"
	"strings"
)

func main() {
	text := "  We are\t learning   Go\n"
	clean := strings.Join(strings.Fields(text), " ")
	fmt.Println(clean)
}
```

`Fields()` treats consecutive spaces, tabs and newlines as separators. `Join()` joins the words back with a single
space.

### 3. Splitting by several separators

```go
package main

import (
	"fmt"
	"strings"
)

func main() {
	parts := strings.FieldsFunc("apple,pomegranate;grape pear", func(r rune) bool {
		return r == ',' || r == ';' || r == ' '
	})
	fmt.Println(parts)
}
```

`FieldsFunc()` lets you decide with a function which runes are separators.

### 4. Removing a prefix only if it is present

```go
package main

import (
	"fmt"
	"strings"
)

func main() {
	address := "https://go.dev"
	address = strings.TrimPrefix(address, "https://")
	fmt.Println(address)
}
```

`TrimPrefix()` removes the prefix only if it matches completely. `Trim()`, in contrast, removes the given set of
characters from both edges.

### 5. Splitting a string at a separator

```go
package main

import (
	"fmt"
	"strings"
)

func main() {
	before, after, found := strings.Cut("lang=uz", "=")
	fmt.Println(before, after, found)
}
```

`Cut()` splits a string into the part before the first separator and the part after it. The third value tells
whether the separator was found.

### 6. Counting how many times a substring occurs

```go
package main

import (
	"fmt"
	"strings"
)

func main() {
	text := "go test, go build, go run"
	fmt.Println(strings.Count(text, "go"))
}
```

The result is `3`. `Count()` counts non-overlapping occurrences.

### 7. Replacing only the first occurrence

```go
package main

import (
	"fmt"
	"strings"
)

func main() {
	text := "error: error: file not found"
	fmt.Println(strings.Replace(text, "error", "warning", 1))
}
```

The last argument sets how many occurrences to replace. Because `1` is passed, only the first occurrence is replaced.
If `-1` is passed, all occurrences are replaced.

### 8. Reversing text by Unicode code points

```go
package main

import "fmt"

func main() {
	runes := []rune("naïve")
	for left, right := 0, len(runes)-1; left < right; left, right = left+1, right-1 {
		runes[left], runes[right] = runes[right], runes[left]
	}
	fmt.Println(string(runes))
}
```

Reversing a string by bytes can break multi-byte UTF-8 characters. `[]rune` keeps the character boundaries.

### 9. Checking the first letter of each word

```go
package main

import (
	"fmt"
	"strings"
	"unicode"
)

func main() {
	for _, word := range strings.Fields("Go Programming Language") {
		for _, first := range word {
			fmt.Println(word, unicode.IsUpper(first))
			break
		}
	}
}
```

The inner `range` safely takes the first Unicode rune of the word. `break` stops checking the remaining runes, and
`unicode.IsUpper()` determines whether the rune taken is an upper-case letter.

### 10. Getting an independent copy of a string

```go
package main

import (
	"fmt"
	"strings"
)

func main() {
	big := strings.Repeat("a", 1000) + "final"
	small := strings.Clone(big[len(big)-5:])
	fmt.Println(small)
}
```

A substring can sometimes keep the memory taken by a large source occupied. `strings.Clone()` creates an independent
copy of the substring.
