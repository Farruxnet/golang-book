# The `map` data type in Go

A `map` stores data as key-value pairs. In a `Slice` or an `Array` we access elements by indexes such as `0`, `1`,
`2`. In a `map`, we access a value by a key we choose ourselves. For example, you can get a product's price by its
name, or a user by their ID number.

All keys in a `map` must be of the same type. A single common type is also set for the values. Each key appears only
once. But the same value can be stored under different keys.

## Creating a `map`

A `map` type is written as `map[KeyType]ValueType`. For example, in `map[string]int` the key is a `string` and the
value is an `int`. A `map` can be created with ready-made values or with `make`:

```go
package main

import "fmt"

func main() {
	prices := map[string]int{
		"bread": 4_000,
		"milk":  12_000,
		"rice":  18_000,
	}

	stock := make(map[string]int)
	stock["bread"] = 25

	fmt.Println("Milk price:", prices["milk"])
	fmt.Println("Bread in stock:", stock["bread"])
}
```

Output:

```text
Milk price: 12000
Bread in stock: 25
```

`prices` was created with ready-made key-value pairs. To get a value, the key is written in square brackets:
`prices["milk"]`.

`make(map[string]int)` creates an empty `map` that values can be written to. Then the line `stock["bread"] = 25` adds a
new pair to it.

You can also give `make` an approximate number of elements: `make(map[string]int, 100)`. This number does not set the
`map`'s length to `100`. It gives the Go runtime a hint for planning memory in advance. The `map` is still empty when it
is created.

## A `nil` and an empty `map`

The zero value of a `map` that has been declared but not yet created is `nil`:

```go
package main

import "fmt"

func main() {
	var nilMap map[string]int
	emptyMap := make(map[string]int)

	fmt.Println(len(nilMap), nilMap == nil)
	fmt.Println(len(emptyMap), emptyMap == nil)
	fmt.Println(nilMap["missing"])
}
```

Output:

```text
0 true
0 false
0
```

`nilMap` and `emptyMap` are both empty, so their length is `0`. The difference is that `nilMap` has not yet been
created for use and is equal to `nil`. `emptyMap` was created with `make`, and values can be written to it.

Reading a value from a `nil` map, getting its length, walking over it with `range` and deleting a key with `delete`
are all safe. When a missing key is read, the zero value of the `int` type (`0`) is returned.

But you cannot write a value to a `nil` map. Such an attempt causes the error `panic: assignment to entry in nil map`.
Before writing values, the `map` must be created with a **literal** or with `make`.

## Checking whether a key exists

When a missing key is accessed, the zero value of the type is returned. For example, for `map[string]int` this value is
`0`. But from a `0` result you cannot tell whether the key exists or not, because `0` can also be a value stored in the
`map`.

To tell these two cases apart, the "comma ok" form is used:

```go
package main

import "fmt"

func main() {
	scores := map[string]int{"Ali": 0}

	score, ok := scores["Ali"]
	fmt.Println("Ali:", score, ok)

	score, ok = scores["Vali"]
	fmt.Println("Vali:", score, ok)
}
```

Output:

```text
Ali: 0 true
Vali: 0 false
```

The `score` variable gets the value, and `ok` is `true` if the key exists and `false` if it does not. In the example,
the key `Ali` exists and its value is `0`. The key `Vali` does not exist, so even though the value is `0` in both cases,
the `ok` result differs.

> **Remember**
>
> If the value itself is not needed, it can be discarded with `_`: `_, ok := scores["Ali"]`. Then only the existence of
> the key is checked, and the variable's value is ignored. Ignoring with `_` also avoids a compilation error in **Go**,
> because a program with a declared but unused variable does not compile.

## Updating and deleting values

Giving a value to a new key adds an element to the `map`. Giving a value to an existing key replaces its old value.
To delete an element, `delete(mapName, key)` is used. `delete` does not report an error even if the key does not
exist.

```go
package main

import "fmt"

func main() {
	user := map[string]string{"name": "Sardor", "city": "Tashkent"}
	user["name"] = "Elbek"
	delete(user, "city")

	fmt.Println(user["name"])
	_, ok := user["city"]
	fmt.Println("City exists:", ok)
}
```

Output:

```text
Elbek
City exists: false
```

In the example, the value `Sardor` of the `name` key was replaced with `Elbek`. The `city` key was deleted. The
following `value, ok` check showed that it no longer exists.

## Which types can be keys?

A `map` compares keys to find the value it needs. That is why the key type must be comparable with the `==` and `!=`
operators.

Numbers, `string`, `bool`, pointers and channels can be keys. Arrays of comparable elements and structs whose fields
are all comparable are also used as keys. `slice`, `map` and functions are not comparable, so they cannot be keys.

`float64` can technically be a key too. But a `NaN` value is not even equal to itself. So be careful when using
floating-point numbers as keys.

## `range` and order

You cannot rely on the order in which `map` elements are stored. When a `map` is iterated with `range`, the elements can
come in a different order each time the program runs.

To always get the result in alphabetical order, the keys must be sorted separately:

```go
package main

import (
	"fmt"
	"sort"
)

func main() {
	ages := map[string]int{"Ali": 24, "Vali": 31, "Lola": 27}
	keys := make([]string, 0, len(ages))

	for name := range ages {
		keys = append(keys, name)
	}
	sort.Strings(keys)

	for _, name := range keys {
		fmt.Println(name, ages[name])
	}
}
```

Output:

```text
Ali 24
Lola 27
Vali 31
```

First all the keys were collected in the `keys` `slice`. `sort.Strings` sorted them in alphabetical order. The next
loop got the values from the `map` through the sorted keys.

This technique can be used when a test, a log or a list shown to the user must always come out in the same order.
Relying on the order of `range` iteration over a `map` is not always correct.

## Assignment, passing to functions and concurrent use

> **Remember**
>
> `b := a` does not copy the elements of a `map`. `a` and `b` refer to the same data. A change made through `b` also
> affects `a`. If you need a completely independent copy, create a new `map` and copy each key-value pair into it.

> **Remember**
>
> It is not safe for several `goroutine`s to write to an ordinary `map` at the same time. Reading while another
> `goroutine` is writing is dangerous too. In such cases access to the data must be coordinated. For that,
> `sync.Mutex`, `sync.RWMutex`, single ownership through a `channel` or, when it suits the task, `sync.Map` is used.
> If several `goroutine`s only read and none of them changes the `map`, they can read at the same time. Ways of working
> concurrently are covered in detail in the `concurrency` part.

## More examples

### 1. Counting word frequency

```go
package main

import (
	"fmt"
	"strings"
)

func main() {
	counts := make(map[string]int)
	for _, word := range strings.Fields("go fast go simple go") {
		counts[word]++
	}
	fmt.Println(counts)
}
```

`strings.Fields` splits the text into separate words. Each word is used as a key in the map. For a missing key, the
zero value of the `int` type — `0` — is returned. That is why `counts[word]++` works correctly even the first time a
word appears. The word `go` appears three times, so its value is `3`.

### 2. Grouping elements

```go
package main

import "fmt"

func main() {
	numbers := []int{1, 2, 3, 4, 5, 6}
	groups := make(map[string][]int)
	for _, num := range numbers {
		key := "odd"
		if num%2 == 0 {
			key = "even"
		}
		groups[key] = append(groups[key], num)
	}
	fmt.Println(groups)
}
```

The value type of a `map` can also be a slice. Even numbers are added to the slice under the `"even"` key and odd
numbers to the one under `"odd"`. For a missing key a `nil` slice is returned. Adding elements to a `nil` slice with
`append` is safe, so there is no need to create each group in advance.

### 3. A map used as a set

```go
package main

import "fmt"

func main() {
	unique := make(map[string]bool)
	for _, name := range []string{"Ali", "Vali", "Ali"} {
		unique[name] = true
	}
	fmt.Println(len(unique))
}
```

Sometimes you only need to know whether a value is in a set or not. Go has no separate set type, but `map[string]bool`
can do that job. The key represents an element of the set, and `true` means it is present. When the key `Ali` is
written again, no new element is added. That is why the result of `len` is `2`.

### 4. Removing duplicates

```go
package main

import "fmt"

func main() {
	numbers := []int{3, 1, 3, 2, 1}
	seen := make(map[int]bool)
	result := make([]int, 0, len(numbers))
	for _, num := range numbers {
		if !seen[num] {
			seen[num] = true
			result = append(result, num)
		}
	}
	fmt.Println(result)
}
```

The `seen` map stores whether a number has appeared before. When a number appears for the first time, it is written to
`seen` and added to `result`. On later occurrences the condition does not hold. The result is `[3 1 2]`, and the order
in which the numbers first appeared is kept.

### 5. Making an independent copy of a map

```go
package main

import "fmt"

func main() {
	original := map[string]int{"apple": 2, "pomegranate": 3}
	copied := make(map[string]int, len(original))
	for key, value := range original {
		copied[key] = value
	}
	copied["apple"] = 10
	fmt.Println(original["apple"], copied["apple"])
}
```

The loop copies each pair into the new `map`. That is why adding a key to `copied` or changing an `int` value in it
does not affect `original`. The program prints `2 10`.

Here the values are `int`s, so a simple copy is enough. If the value type refers to other data, such as a slice, a
`map` or a pointer, the inner values must also be copied separately for a fully independent copy.

### 6. A nested map

```go
package main

import "fmt"

func main() {
	scores := make(map[string]map[string]int)
	scores["Ali"] = make(map[string]int)
	scores["Ali"]["Go"] = 95
	fmt.Println(scores["Ali"]["Go"])
}
```

Each value in the outer `map` is itself a `map`. Before writing a value to the inner map `scores["Ali"]`, it must be
created with `make`. Otherwise the program tries to write to a `nil` map and a `panic` occurs.

### 7. Using an array as a key

```go
package main

import "fmt"

func main() {
	colors := map[[2]int]string{{2, 3}: "red"}
	fmt.Println(colors[[2]int{2, 3}])
}
```

An array of `int` elements is a comparable type. That is why `[2]int` can combine two coordinates into a single `map`
key. In the example, the value `red` is taken for the key `[2]int{2, 3}`.

### 8. Printing the keys in order

```go
package main

import (
	"fmt"
	"sort"
)

func main() {
	prices := map[string]int{"grape": 20, "pomegranate": 15, "apple": 10}
	keys := make([]string, 0, len(prices))
	for key := range prices {
		keys = append(keys, key)
	}
	sort.Strings(keys)
	for _, key := range keys {
		fmt.Println(key, prices[key])
	}
}
```

The order of iterating over a `map` is not guaranteed. First the keys are collected into a slice, then sorted with
`sort.Strings`. The last loop prints the prices in the order `apple`, `grape`, `pomegranate`.

### 9. Comparing the values of two maps

```go
package main

import (
	"fmt"
	"maps"
)

func main() {
	a := map[string]int{"a": 1, "b": 2}
	b := map[string]int{"b": 2, "a": 1}
	fmt.Println(maps.Equal(a, b))
}
```

A `map` value cannot be compared with another `map` using `==`. It can only be compared directly with `nil`.

If the value type is comparable, `maps.Equal` checks the key-value pairs of the two maps. The order in which the pairs
are written in the code does not matter. `a` and `b` in the example have the same pairs, so the result is `true`.

### 10. Updating only if the key exists

```go
package main

import "fmt"

func main() {
	stock := map[string]int{"book": 5}
	if count, ok := stock["book"]; ok {
		stock["book"] = count - 1
	} else {
		fmt.Println("Product not found")
	}
	fmt.Println(stock)
}
```

The statement `count, ok := stock["book"]` in the `if` combines getting the value and checking whether the key exists.
If the key exists, the number of books is decreased by one. If it does not, a message is printed.

In the next part we will look at pointers, which let you refer to a value's address in memory.
