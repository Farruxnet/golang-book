# Working with regular expressions in Go

A regular expression, **regex** for short, is a pattern that describes a certain shape in text. It describes not a specific piece of text, but what structure the text should have.

With a regex you can:

* search for needed values in text;
* check whether a value matches a certain format;
* extract certain parts of text;
* replace the matched parts with other text.

For example, you can find a date in a log line, check the format of a username, or replace consecutive extra spaces with a single space.

But a regex is not the best tool for every text-processing task. For a plain substring search `strings.Contains()`, for checking a prefix `strings.HasPrefix()`, for working with URLs `net/url`, and for dates and times `time.Parse()` are often simpler and more reliable.

That is why it is better to use a regex when you need to describe a **shape** in text.

## The first pattern

From the following text we find the part that looks like a date in the `YYYY-MM-DD` form:

```text
Today's date: 2025-08-31
```

The following regex can be used for this:

```text
\d{4}-\d{2}-\d{2}
```

Let's break this pattern into parts:

* `\d` — matches an ASCII digit, i.e. from `0` to `9`;
* `{4}` — means the element before it must repeat exactly four times;
* `-` — an ordinary hyphen character;
* `\d{2}` — exactly two digits.

So:

```text
\d{4}
```

finds four digits.

The next:

```text
-
```

matches the hyphen character.

Then:

```text
\d{2}
```

finds two digits.

The full pattern:

```text
\d{4}-\d{2}-\d{2}
```

matches the following form:

```text
2025-08-31
```

There is an important limitation here. A regex only checks the **shape** of a value. It does not prove the value is a real date.

For example:

```text
9999-99-99
```

also matches this regex.

But it is not a real date.

That is why when working with dates, two steps are usually needed:

1. the part with the needed shape is found through a regex;
2. the found value is checked as a real date through `time.Parse()`.

For example:

```go
time.Parse("2006-01-02", value)
```

This approach separates the job of the regex from the job of semantic validation.

## The main symbols

In regex syntax some characters have a special meaning.

| Symbol   | Meaning                              | Example    | Matching value        |
| -------- | ------------------------------------ | ---------- | --------------------- |
| `.`      | Any one character except newline    | `c.t`      | `cat`, `cut`          |
| `\d`     | ASCII digit                          | `\d{2}`    | `12`                  |
| `\w`     | ASCII letter, digit or `_`           | `\w+`      | `go_123`              |
| `\s`     | Whitespace character                 | `a\s+b`    | `a b`, `a\tb`         |
| `+`      | One or more times                    | `a+`       | `a`, `aaa`            |
| `*`      | Zero or more times                   | `ba*`      | `b`, `baa`            |
| `?`      | Zero or one time                     | `colou?r`  | `color`, `colour`     |
| `{n}`    | Exactly `n` times                    | `\d{4}`    | `2025`                |
| `{n,m}`  | From `n` to `m` times                | `\d{2,4}`  | `12`, `2025`          |
| `^`      | Start of text                        | `^hello`   | `hello` at the start  |
| `$`      | End of text                          | `world$`   | `world` at the end    |
| `[abc]`  | One character from the set           | `[abc]`    | `a`, `b` or `c`       |
| `[^0-9]` | A character not in the set           | `[^0-9]`   | any non-digit         |
| `a\|b`   | Left or right alternative            | `cat\|dog` | `cat` or `dog`        |
| `()`     | Grouping and capturing the result    | `(ab)+`    | `ab`, `abab`          |

When using these symbols, it is important to know some properties of Go regex.

For example, Perl-style classes like `\d`, `\w` and `\b` are based on ASCII rules.

`\w` roughly covers the following:

```text
A-Z
a-z
0-9
_
```

That is why `\w` does not automatically cover all the Unicode letters found in writing such as Uzbek `o‘`, `g‘` or Cyrillic letters.

To work with Unicode, classes of the form `\p{...}` are used.

For example:

```text
\p{L}
```

matches characters considered letters in Unicode.

```text
\p{N}
```

matches Unicode digits.

If you need to search for a special character itself, you usually have to escape it with `\`.

For example:

```text
.
```

in a regex means any single character.

To find an ordinary dot itself:

```text
\.
```

is written.

In the same way, `+` is a repetition operator in a regex. To match an ordinary `+` character:

```text
\+
```

is written.

## Compiling a regex in Go

The Go standard library has the `regexp` package for working with regexes.

A regex is usually used in two steps:

1. the text pattern is compiled;
2. the resulting `*regexp.Regexp` object is used for searching or checking.

Example:

```go
package main

import (
	"fmt"
	"regexp"
)

func main() {
	re := regexp.MustCompile(`\d{4}-\d{2}-\d{2}`)
	date := re.FindString("Order date: 2025-08-31")

	fmt.Println(date)
}
```

Result:

```text
2025-08-31
```

Let's go through this code step by step.

First:

```go
re := regexp.MustCompile(`\d{4}-\d{2}-\d{2}`)
```

compiles the pattern.

As a result the `re` variable holds a `*regexp.Regexp` value.

The next line:

```go
date := re.FindString("Order date: 2025-08-31")
```

searches the given text for the first part matching the pattern.

As a result:

```text
2025-08-31
```

is found.

The pattern is written with backticks:

```go
`\d{4}-\d{2}-\d{2}`
```

This is a raw string literal in Go.

Inside a raw string, the `\` character is not separately escaped by Go string syntax. That is why backticks are often convenient when writing regexes.

If an ordinary double-quoted Go string is used, you have to write:

```go
"\\d{4}-\\d{2}-\\d{2}"
```

The reason is that in this case the first `\` is the escape for the Go string, and the second is the real `\` character that reaches the regex.

`regexp.MustCompile()` panics if the pattern is invalid.

This is convenient for constant patterns known in advance and written in the code.

For example:

```go
var phonePattern = regexp.MustCompile(`^\+998[0-9]{9}$`)
```

This pattern is written by the developer and hardly changes before the program runs. If it has a syntax error, it is useful to see it right away during development or testing.

## The difference between searching and full validation

One of the most common mistakes when working with regexes is thinking searching and full validation are the same.

`MatchString()` may return `true` if a match is found in any part of the string.

If the whole value must match a certain format, the start and end of the string must also be marked.

For this:

```text
^
```

marks the start of the string,

and:

```text
$
```

marks the end of the string.

An example that checks a phone number:

```go
package main

import (
	"fmt"
	"regexp"
)

var phonePattern = regexp.MustCompile(`^\+998[0-9]{9}$`)

func main() {
	fmt.Println(phonePattern.MatchString("+998901234567"))
	fmt.Println(phonePattern.MatchString("Phone: +998901234567"))
	fmt.Println(phonePattern.MatchString("+99890123456"))
}
```

Result:

```text
true
false
false
```

Let's break the pattern:

```text
^\+998[0-9]{9}$
```

into parts.

`^`:

```text
^
```

means the match must start exactly at the beginning of the string.

The next:

```text
\+998
```

requires the plain character sequence `+998`.

Here, because `+` is a regex operator, it is escaped as:

```text
\+
```

The next part:

```text
[0-9]{9}
```

requires exactly nine ASCII digits after the country code.

The final:

```text
$
```

means the match must end at the end of the string.

That is why:

```text
+998901234567
```

matches.

But:

```text
Phone: +998901234567
```

does not match. Because `+998...` does not start at the beginning of the string.

If `^` and `$` were not written, the regex could find a small matching part inside the string and return `true` in the second case too.

There is another important difference here.

The regex checks:

> Does the phone number look like the needed syntactic format?

But it does not determine:

* whether this number has actually been assigned;
* whether the number is active;
* whether it fits an operator's range;
* whether the user owns this number.

These are checked not by a regex but by separate business rules.

## Finding all matches

Sometimes you need not just the first match in a text, but all matching parts.

`FindAllString()` is used for this.

Example:

```go
package main

import (
	"fmt"
	"regexp"
)

func main() {
	re := regexp.MustCompile(`[0-9]+`)
	prices := re.FindAllString("Apples 12000, pears 18000, total 30000", -1)

	fmt.Println(prices)
}
```

Result:

```text
[12000 18000 30000]
```

Here the pattern:

```text
[0-9]+
```

matches a sequence of one or more digits.

The second argument of `FindAllString()` sets the maximum number of results.

Here:

```go
-1
```

is given.

`-1` means returning all matches.

That is why three numbers are found:

```text
12000
18000
30000
```

If you write:

```go
re.FindAllString(text, 2)
```

only the first two matches are returned.

For example:

```text
[12000 18000]
```

If there is no match at all, the method returns a `nil` slice.

In this example the found values are not `int` yet. They are returned as `string`.

For example:

```go
"12000"
```

If arithmetic must be done with this value, it must be converted to a numeric type.

Usually:

```go
strconv.Atoi()
```

is used.

For example:

```go
value, err := strconv.Atoi("12000")
```

Here the conversion error must also be checked.

A regex finds the needed parts of a text. Converting the found data into the needed Go type in the next step is a separate task.

## Extracting parts through groups

In a regex, parentheses:

```text
(...)
```

not only group elements, but also create a **capturing group**, i.e. a group taken separately in the result.

For example, there is the following value:

```text
order-42
```

We want to take the parts:

* `order`;
* `42`

separately from it.

For this:

```go
package main

import (
	"fmt"
	"regexp"
)

func main() {
	re := regexp.MustCompile(`^([a-z]+)-([0-9]+)$`)
	parts := re.FindStringSubmatch("order-42")
	if parts == nil {
		fmt.Println("The format does not match")
		return
	}

	fmt.Println("Full:", parts[0])
	fmt.Println("Type:", parts[1])
	fmt.Println("ID:", parts[2])
}
```

Result:

```text
Full: order-42
Type: order
ID: 42
```

The pattern:

```text
^([a-z]+)-([0-9]+)$
```

has two capturing groups.

The first group:

```text
([a-z]+)
```

matches one or more lowercase ASCII letters.

The second group:

```text
([0-9]+)
```

matches one or more digits.

Between them there is an ordinary hyphen:

```text
-
```

`FindStringSubmatch()` returns the result as a slice.

In this slice:

```go
parts[0]
```

always denotes the full match.

In this example:

```text
order-42
```

The next element:

```go
parts[1]
```

is the value of the first capturing group:

```text
order
```

And `parts[2]` is the value of the second capturing group:

```text
42
```

Here the check:

```go
if parts == nil {
	fmt.Println("The format does not match")
	return
}
```

is very important.

If the pattern does not match, `FindStringSubmatch()` may return `nil`.

After that, if an index such as:

```go
parts[0]
```

is accessed, the program panics.

That is why when working with submatch methods, you must first check that a result exists.

Sometimes grouping is needed, but taking the result separately is not.

In such a case a non-capturing group is used:

```text
(?:...)
```

For example:

```text
(?:ab)+
```

groups the `ab` part, but does not keep it as a separate capturing result.

Go regex also has named groups.

The syntax:

```text
(?P<name>...)
```

For example:

```text
(?P<type>[a-z]+)
```

Later the group names can be obtained through:

```go
SubexpNames()
```

This makes indexes like `parts[1]` and `parts[2]` easier to read, especially in large patterns with several groups.

## Replacing text

A regex is not only for searching. The matched parts can also be replaced with other text.

`ReplaceAllString()` is used for this.

For example, let's collapse consecutive whitespace into a single space:

```go
package main

import (
	"fmt"
	"regexp"
	"strings"
)

func main() {
	re := regexp.MustCompile(`\s+`)
	cleaned := re.ReplaceAllString("  Go\tworks\n with   regex  ", " ")

	fmt.Println(strings.TrimSpace(cleaned))
}
```

Result:

```text
Go works with regex
```

The pattern:

```text
\s+
```

matches one or more whitespace characters.

This is not only an ordinary space. For example, characters such as:

* a space;
* a `\t` tab;
* a `\n` newline

may also match.

In the initial text:

```text
  Go\tworks\n with   regex  
```

each consecutive whitespace group is replaced with:

```text
" "
```

But spaces may also remain at the start and end of the string.

That is why:

```go
strings.TrimSpace(cleaned)
```

is used.

It removes the whitespace characters at the start and end of the string.

A regex can be used in this example, but if the task is only normalizing spaces in text, there is another simple solution too:

```go
strings.Fields()
```

`strings.Fields()` splits text into parts by whitespace. Then they can be joined with a single space.

For example:

```go
strings.Join(strings.Fields(text), " ")
```

If replacement with more complex rules is needed, a regex is more useful.

Capturing groups can also be used in the replacement text of `ReplaceAllString()`.

For example:

```text
$1
```

denotes the value of the first capturing group.

For a named group:

```text
${name}
```

can be used.

There is a subtle point here. `$` in the replacement string has a special meaning.

That is why if an ordinary dollar sign must be added, the replacement syntax of `ReplaceAllString()` must be taken into account.

In complex cases:

```go
ReplaceAllStringFunc()
```

may be more convenient to use.

This method makes it possible to call a Go function for each match found.

## A pattern that comes from outside

`MustCompile()` is convenient for patterns known in advance.

But if the pattern comes from the configuration, an HTTP request or the user, the situation is different.

If an invalid pattern is given to:

```go
regexp.MustCompile(pattern)
```

a panic occurs.

In a server program, the whole process panicking because of a user mistake is usually not desired.

In such a case `regexp.Compile()` is used.

Example:

```go
package main

import (
	"fmt"
	"regexp"
)

func main() {
	pattern := `[a-z+`

	re, err := regexp.Compile(pattern)
	if err != nil {
		fmt.Println("Invalid pattern:", err)
		return
	}

	fmt.Println(re.MatchString("go"))
}
```

Here the pattern:

```text
[a-z+
```

is invalid.

The reason is that the character class started with `[` is not closed.

`regexp.Compile()` does not panic.

It returns two values:

```go
re, err := regexp.Compile(pattern)
```

If the pattern is valid:

* `re` is a regex ready to use;
* `err == nil`.

If the pattern is wrong:

* `err` gives information about the error.

The resulting error text may differ slightly depending on the Go version:

```text
Invalid pattern: error parsing regexp: missing closing ]: `[a-z+`
```

This approach is safer for patterns given by the user.

For example, if a user sends an invalid regex to a web API, the server may return a response such as:

```text
400 Bad Request
```

But printing the internal parser error in full to the client is not always good.

In practice it is better to give the user a clearer validation message.

For example:

```text
The regex pattern is invalid.
```

And the internal technical error can be written to the log.

## Email and URL validation

An email can be checked with a regex, but care is needed in this task.

The following pattern checks common email forms in a simplified way:

```text
(?i)^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$
```

Let's break this pattern into parts.

```text
(?i)
```

turns on case-insensitive mode.

So the difference between uppercase and lowercase letters is not taken into account.

The next:

```text
^[a-z0-9._%+-]+
```

checks the allowed characters in the part before the `@` sign.

Then:

```text
@
```

an ordinary `@` sign must come.

The domain part is checked through:

```text
[a-z0-9.-]+
```

At the end:

```text
\.[a-z]{2,}$
```

requires a dot and a suffix of at least two letters.

For example:

```text
user@example.com
```

may match.

But this pattern does not express all cases of the email standard.

Email syntax is in practice much more complex.

Besides that, a regex cannot determine:

* whether the domain really exists;
* whether the mailbox exists;
* whether the user owns this email;
* whether mail reaches the email.

That is why in a process such as account registration, the most reliable final check is usually sending a confirmation email.

The same principle works for URLs.

Instead of fully validating a URL with a very large regex, it is better to use:

```go
net/url.ParseRequestURI()
```

or another parser suited to the task.

A parser splits the URL into parts.

For example, parts such as:

* scheme;
* host;
* path;
* query;
* escaping

are obtained in a structured form.

A regex may be useful for URLs only to additionally check a narrow format required by the project.

For example, a project rule like:

> Only URLs starting with `https://` are accepted.

can be checked with a regex or with additional validation after the parser.

## Properties of the Go regex engine

The Go `regexp` package is based on the RE2 syntax.

This is not only a difference in syntax. Its execution model matters too.

Go regex is designed to keep matching time linear in the input size.

Put simply, in some backtracking regex engines a badly constructed pattern can lead to a huge computational cost.

This phenomenon is often called **catastrophic backtracking**.

The RE2 design aims to limit this situation.

This is important for systems where text comes from users, such as web servers. Because a very heavy regex can tie up CPU resources for a long time.

But in exchange for this safer execution model, some regex features are not supported.

The Go `regexp` package does not have:

* backreferences: `\1`, `\k<name>`;
* lookahead: `(?=...)`, `(?!...)`;
* lookbehind: `(?<=...)`;
* conditional patterns;
* recursive patterns.

For example, take the following task:

> Find two identical words written side by side.

In some regex engines the first word can be taken through a capturing group, and then the same value can be required again with a backreference.

Go regex has no backreferences.

That is why the needed parts must first be extracted through a regex, and then compared in Go code.

There is an important practical rule here.

If a pattern does not change, it does not have to be recompiled every time.

For example, writing it like this:

```go
func ValidatePhone(value string) bool {
	re := regexp.MustCompile(`^\+998[0-9]{9}$`)
	return re.MatchString(value)
}
```

recompiles the regex every time it is called.

It is better to prepare a constant pattern once at package level:

```go
var phonePattern = regexp.MustCompile(`^\+998[0-9]{9}$`)

func ValidatePhone(value string) bool {
	return phonePattern.MatchString(value)
}
```

The reason is that a `*regexp.Regexp` can be reused after compilation.

It can also be used safely by several goroutines concurrently.

This is especially useful in server code. Because recreating the regex on every request increases CPU and allocation costs.

## Unicode and byte indexes

Go strings consist of UTF-8 encoded bytes.

A regex, on the other hand, works by viewing text as Unicode code points, i.e. runes.

For example:

```text
.
```

usually matches one rune.

In ASCII text this makes no big difference. Because each ASCII character is one byte in UTF-8.

But a Unicode character may consist of several bytes.

That is why there is a subtle point in regex methods that return indexes.

For example:

```go
FindStringIndex()
```

returns not rune indexes but **byte offsets**.

This matches Go's string indexing rules.

If the text has `o‘`, `g‘`, Cyrillic letters or other multi-byte Unicode characters, the byte offset and the rune position may not be the same.

For working with Uzbek and other Unicode letters, Unicode classes like `\p{L}` are useful.

Example:

```go
package main

import (
	"fmt"
	"regexp"
)

func main() {
	re := regexp.MustCompile(`^\p{L}+(?:[’']\p{L}+)*$`)

	fmt.Println(re.MatchString("g‘alaba"))
	fmt.Println(re.MatchString("o'zbek"))
	fmt.Println(re.MatchString("go123"))
}
```

Result:

```text
true
true
false
```

Let's break the pattern:

```text
^\p{L}+(?:[’']\p{L}+)*$
```

into parts.

The first part:

```text
^\p{L}+
```

requires one or more Unicode letters starting from the beginning of the string.

`\p{L}` covers not only ASCII but characters considered letters in Unicode.

The next part:

```text
(?:[’']\p{L}+)*
```

optionally allows an apostrophe followed by more letters.

```text
[’']
```

accepts two apostrophe variants:

* the typographic apostrophe: `’`;
* the plain apostrophe: `'`.

That is why:

```text
g‘alaba
```

matches.

```text
o'zbek
```

also matches.

But:

```text
go123
```

does not match.

The reason is that digits are not in the `\p{L}` group.

This pattern should not be taken as real name validation.

Real names may contain:

* hyphens;
* spaces;
* several words;
* different apostrophe characters;
* different writing systems.

That is why name validation is defined by separate business rules depending on the project's requirements.

## Common mistakes

Several mistakes come up frequently when working with regexes.

* Forgetting `^` and `$` in a validation pattern. Then `MatchString()` may return `true` even if only a small part of the string matches. If the whole value is being checked, the boundaries must be written explicitly.

* Mixing up raw string and ordinary Go string escaping. `\` is used a lot in regexes. That is why a raw string written with backticks often makes the pattern easier to read.

* Using `MustCompile()` with a pattern that comes from the user. An invalid pattern may cause a panic. For an external pattern, `regexp.Compile()` and `error` handling are used.

* Recompiling the same regex on every request. It is better to compile a constant pattern once and reuse the ready `*regexp.Regexp`.

* Indexing the result of `FindStringSubmatch()` without checking for `nil`. If there is no match, the slice may be `nil`, and accessing an index panics.

* Thinking `\w` covers all Unicode letters. In Go regex, `\w` works on an ASCII basis. For Unicode letters, classes like `\p{L}` must be used.

* Equating a regex match with the validity of the data. `2025-99-99` may look like the date format, but it is not a real date. For email, URL, phone and other values, semantic validation is needed separately too.

* Solving a simple task with a complex regex. Sometimes `strings`, `strconv`, `time`, `net/url` or another dedicated parser makes the code much clearer and more reliable.

## What is looked at in interviews?

In a Go interview on the regex topic, not only the syntax but also the properties of the `regexp` package may be asked about.

One of the important points is that `MatchString()` accepts partial matches.

For example:

```go
re := regexp.MustCompile(`[0-9]+`)
fmt.Println(re.MatchString("ID: 42"))
```

here the result may be `true` because only the `42` part of the string matched.

That is why if the whole value is being validated, you must understand the importance of the boundaries:

```text
^
```

and:

```text
$
```

The difference between `Compile()` and `MustCompile()` is also important.

`MustCompile()`:

* panics if the pattern is invalid;
* is convenient for constant patterns known in advance.

`Compile()`:

* returns the error as an `error`;
* fits external or dynamic patterns better.

That Go regex is based on RE2 is also an important technical point.

This approach is designed to keep matching time linear in the input size and limits the catastrophic backtracking problem.

Because of this design, some features are not available in Go regex:

* backreferences;
* lookahead;
* lookbehind.

You should also be able to distinguish the jobs of the standard methods:

```go
FindString()
```

finds the first match.

```go
FindAllString()
```

returns several or all matches.

```go
FindStringSubmatch()
```

returns the capturing groups together with the full match.

```go
ReplaceAllString()
```

replaces the matched parts.

When working with Unicode, it is useful to know the difference between `\w` and `\p{L}`.

Also, do not forget that the result of methods that return indexes is not a rune index but a byte offset.

One more practical rule:

```go
*regexp.Regexp
```

can be reused after compilation and is safe to use concurrently by several goroutines.

That is why compiling the same pattern over and over inside a request is usually unnecessary.
