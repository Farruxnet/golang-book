# Generating random values in Go

Random values are needed in many places in programming. For example, random numbers can be used to pick a random move in games, to run simulations, to generate test data or to shuffle slice elements.

Random values are also needed in security-related tasks. For example:

* generating a session ID;
* generating a password reset token;
* generating an API key;
* generating a one-time confirmation code.

But a single random generator cannot be used for all these tasks.

Go has two main packages for working with random values:

* `math/rand` — for fast pseudorandom values;
* `crypto/rand` — for cryptographically secure values that are hard to predict.

Both packages use the name `rand`. But their purpose and security properties are not the same.

For example, `math/rand` fits a random number inside a game. But using `math/rand` for a session ID or a password reset token is dangerous. Such values need `crypto/rand`.

## What is a pseudorandom number?

`math/rand` does not produce real physical randomness. It generates values using a **pseudorandom number generator**, i.e. a PRNG.

A PRNG computes a sequence of numbers from a certain initial state. This initial value is usually called the **seed**.

The produced numbers look random from the outside. But they are computed by an algorithm.

The important property is that if the same generator is given the same seed, the same sequence of calls gives the same results.

For example, if a generator gives the sequence:

```text
42 -> 5, 87, 68, ...
```

then the same generator, created again with the seed `42`, may reproduce the same sequence.

This property is very useful in tests.

Imagine a simulation fails only with a certain random sequence. If the seed at which the failure happened is saved, exactly that sequence can be recreated later.

But for security-related values the opposite is needed.

For example, an attacker must not be able to predict the next value of a session token. If the generator state or the seed can be determined and the following values can be computed, such a generator is unfit for security.

## Working with `math/rand`

The `math/rand` package is convenient for generating ordinary pseudorandom values.

In modern Go versions, the initial state of the package-level `math/rand` functions is prepared automatically. That is why in an ordinary program you do not need to write code like:

```go
rand.Seed(time.Now().UnixNano())
```

every time for the global generator.

Generating a simple random number:

```go
package main

import (
	"fmt"
	"math/rand"
)

func main() {
	n := rand.Intn(100)
	fmt.Println("Random number:", n)
}
```

A possible result:

```text
Random number: 57
```

The main line here:

```go
n := rand.Intn(100)
```

`rand.Intn(n)` returns an `int` value from the following range:

```text
[0, n)
```

This is called a **half-open interval**.

`[` means the left bound is included, and `)` means the right bound is not included.

That is why:

```go
rand.Intn(100)
```

may return one of the following values:

```text
0, 1, 2, ..., 98, 99
```

But `100` is not returned.

So:

```text
smallest value = 0
largest value  = 99
```

Because the generator works randomly, another number may come out when the program is run again.

**Attention**

For `rand.Intn(n)`, `n` must be positive.

If a value such as:

```go
rand.Intn(0)
```

or:

```go
rand.Intn(-5)
```

is passed, the program panics.

If the upper bound comes from the user, the configuration or an external API, it must be checked before calling `Intn()`.

### Getting a number from an arbitrary range

`rand.Intn()` always gives a result starting from `0`.

But in practice another range is often needed.

For example, suppose a random number:

```text
from 10 to 15
```

is needed.

Here both bounds must be included in the result:

```text
10, 11, 12, 13, 14, 15
```

Let's count how many values there are in such a range:

```text
max - min + 1
```

In our example:

```text
15 - 10 + 1 = 6
```

So first a value can be taken from the range `[0, 6)`:

```text
0, 1, 2, 3, 4, 5
```

Then `min`, i.e. `10`, is added to it:

```text
0 + 10 = 10
1 + 10 = 11
2 + 10 = 12
3 + 10 = 13
4 + 10 = 14
5 + 10 = 15
```

That is why the formula is as follows:

```go
min + rand.Intn(max-min+1)
```

A complete example:

```go
package main

import (
	"errors"
	"fmt"
	"math/rand"
)

func randomBetween(min, max int) (int, error) {
	if min > max {
		return 0, errors.New("min must not be greater than max")
	}

	return min + rand.Intn(max-min+1), nil
}

func main() {
	n, err := randomBetween(10, 15)
	if err != nil {
		fmt.Println("Error:", err)
		return
	}

	fmt.Println(n)
}
```

A possible result:

```text
13
```

`randomBetween(10, 15)` may return one of the following values:

```text
10
11
12
13
14
15
```

Here the check:

```go
if min > max {
	return 0, errors.New("min must not be greater than max")
}
```

is important.

If `min > max`, the following expression may produce a wrong range:

```go
max - min + 1
```

As a result `rand.Intn()` may be given `0` or a negative number, and the program may panic.

That is why the function detects the wrong bound in advance and returns an `error`.

There is one more subtle case.

The following calculation:

```go
max - min + 1
```

is performed in the `int` type.

If `min` and `max` are close to very large extreme `int` values, the subtraction or the `+1` may overflow.

For example, if very large bounds come from untrusted external data, the `min <= max` check alone may not be enough.

In ordinary small ranges this is usually not a problem. But when working with external input or large numbers, the allowed limits of the range must be checked before computing it.

## A local generator for reproducible results

In some cases the random result does not need to change every time.

A test is a good example of this.

In a test it is useful to be able to use the same random sequence over and over. Because if the test fails, exactly that state can be reproduced again.

For this, creating a separate local generator instead of changing the global generator is considered a good approach.

```go
package main

import (
	"fmt"
	"math/rand"
)

func main() {
	first := rand.New(rand.NewSource(42))
	second := rand.New(rand.NewSource(42))

	for i := 0; i < 3; i++ {
		fmt.Println(first.Intn(100) == second.Intn(100))
	}
}
```

Result:

```text
true
true
true
```

Now let's go through this code step by step.

The first generator:

```go
first := rand.New(rand.NewSource(42))
```

The second generator:

```go
second := rand.New(rand.NewSource(42))
```

Both `rand.NewSource()` calls take the same seed:

```text
42
```

So the initial state of both generators is the same.

Then in the loop the methods:

```go
first.Intn(100)
second.Intn(100)
```

are called in the same order.

That is why the values in the first call are the same. The values in the second call are also the same. The third call is the same too.

As a result:

```text
true
```

is printed three times.

What matters here is not only the seed. **The order in which the generator methods are called matters too.**

For example, if one extra random value is taken for `first`:

```go
first.Intn(100)
```

its internal state moves one step forward.

And `second` stays in the previous state.

After that, the next results of the two generators may no longer match each other.

The package-level approach:

```go
rand.Seed(...)
```

is considered deprecated.

If a deterministic, i.e. reproducible, stream is needed, using:

```go
rand.New(rand.NewSource(seed))
```

is clearer.

It has another advantage too: a local generator does not affect the global `math/rand` state that other code uses.

> **Attention**
>
> The `Source` returned by `rand.NewSource()` and the `*rand.Rand` created from it are not safe for use by several goroutines at the same time.
>
> For example, if several goroutines call one local `*rand.Rand` in parallel, the generator's internal state is accessed at the same time.
>
> In such a situation you can:
>
> - create a separate generator for each goroutine;
> - or protect access to the shared generator with `sync.Mutex`.
>
> The package-level `math/rand` functions, on the other hand, are suitable for concurrent use.

## Shuffling elements

Randomness is not only for picking numbers.

Sometimes the order of elements inside a slice must be changed randomly.

The `math/rand` package has the `Shuffle()` function for this.

```go
package main

import (
	"fmt"
	"math/rand"
)

func main() {
	names := []string{"Ali", "Vali", "Aziza", "Madina"}

	rand.Shuffle(len(names), func(i, j int) {
		names[i], names[j] = names[j], names[i]
	})

	fmt.Println(names)
}
```

A possible result:

```text
[Aziza Ali Madina Vali]
```

The main call:

```go
rand.Shuffle(len(names), func(i, j int) {
	names[i], names[j] = names[j], names[i]
})
```

`rand.Shuffle()` is given the number of elements as the first argument:

```go
len(names)
```

The second argument is a callback function that swaps the elements at indexes `i` and `j`.

In our case:

```go
names[i], names[j] = names[j], names[i]
```

swaps the places of two elements.

The important point is that no new slice is created.

The elements inside the `names` slice itself are swapped. That is, the operation is performed in place on the slice.

For example, the initial order:

```text
[Ali Vali Aziza Madina]
```

may turn into:

```text
[Aziza Ali Madina Vali]
```

or another order.

The result may be different on each run.

`Shuffle()` is convenient for tasks such as:

* shuffling test data;
* randomly setting the players' turn order;
* changing the order of questions;
* creating a random order unrelated to security.

But if a random order that matters for security is needed, relying on the pseudorandom generator of `math/rand` is not right.

## Getting a secure number with `crypto/rand`

For security-related values, the main requirement is not only "looking random".

An attacker must also be unable to predict the result in advance.

For such tasks Go has the `crypto/rand` package.

`crypto/rand` uses the cryptographic randomness source provided by the operating system.

When working with this package, the user does not give:

```go
Seed(...)
```

A simple example:

```go
package main

import (
	"crypto/rand"
	"fmt"
	"math/big"
)

func main() {
	max := big.NewInt(101)

	n, err := rand.Int(rand.Reader, max)
	if err != nil {
		fmt.Println("Error:", err)
		return
	}

	fmt.Println("Random number:", n)
}
```

A possible result:

```text
Random number: 16
```

Here:

```go
max := big.NewInt(101)
```

creates the upper bound.

Then:

```go
n, err := rand.Int(rand.Reader, max)
```

gets a cryptographically secure random number.

`crypto/rand.Int()` returns a value from the following range:

```text
[0, max)
```

That is, here too the upper bound is not included in the result.

Because we gave:

```go
big.NewInt(101)
```

the possible values are:

```text
0..100
```

`crypto/rand.Int()` returns the result as a `*big.Int`.

This is not an `int`. The reason is that the function can also work with big numbers not limited to the ordinary machine `int` range.

Another important property is that the values in the range `[0, max)` are chosen with equal probability.

> **Attention**
>
> For `crypto/rand.Int()`, `max` must be positive.
>
> If the upper bound is `0` or negative, the function panics.
>
> That is why if `max` comes from the user or another external source, it must be checked before being given to `rand.Int()`.

### Distinguishing same-named packages with an alias

Sometimes both `crypto/rand` and `math/rand` may be needed in one file.

The problem is that the standard import name of both packages is:

```text
rand
```

Go does not allow using two imports with exactly the same name in one scope.

In such a case import aliases are used:

```go
import (
	cryptorand "crypto/rand"
	mathrand "math/rand"
)
```

Now the packages are clearly distinguished in the code:

```go
cryptorand.Int(...)
```

and:

```go
mathrand.Intn(...)
```

For example:

```go
cryptorand.Int(cryptorand.Reader, max)
```

refers to the cryptographic generator.

```go
mathrand.Intn(100)
```

uses the `math/rand` pseudorandom generator.

This import snippet is not a standalone working program. It only shows how to distinguish two packages with the same name.

## Generating a secure token

One of the common ways to generate a token is to generate random bytes and then encode them as text.

For example, let's take 16 bytes of random data:

```go
package main

import (
	"crypto/rand"
	"encoding/hex"
	"fmt"
)

func main() {
	data := make([]byte, 16)

	if _, err := rand.Read(data); err != nil {
		fmt.Println("Error:", err)
		return
	}

	token := hex.EncodeToString(data)
	fmt.Println("Token length:", len(token))
}
```

Result:

```text
Token length: 32
```

The first important line:

```go
data := make([]byte, 16)
```

This creates a 16-byte slice.

For now these bytes are not random. The slice has just been allocated.

Then:

```go
rand.Read(data)
```

fills the slice with cryptographically random bytes using `crypto/rand`.

Let's count how many bits 16 bytes are:

```text
1 byte = 8 bits
16 × 8 = 128 bits
```

So 128 bits of random data are obtained here.

Then:

```go
token := hex.EncodeToString(data)
```

turns the bytes into hexadecimal text.

In hexadecimal format each byte is written with two characters.

For example:

```text
0x0A -> "0a"
0xFF -> "ff"
```

That is why:

```text
16 bytes × 2 characters = 32 characters
```

The resulting token length is always:

```text
32
```

The token itself changes on every call.

For example, a real token may look roughly like this:

```text
6ac97ce51a7197f45e85c023034c3812
```

But in this example the program prints not the token itself, only its length.

In newer Go versions `crypto/rand.Read()` fills the given slice entirely with random bytes.

Despite that, checking the error in the form:

```go
if _, err := rand.Read(data); err != nil {
	...
}
```

is good practice.

This code is also compatible with older Go versions and shows clearly in the code itself that getting random data may fail.

Ignoring the error in security-related code is an especially bad idea. If the needed cryptographic randomness cannot be obtained, the operation must be stopped instead of continuing to generate the token.

## What is modulo bias?

One of the common mistakes when bringing a cryptographic random number into a small range is misusing the `%` operator.

For example, imagine a single random byte was obtained.

A byte can take one of the following values:

```text
0..255
```

So there are:

```text
256
```

values in total.

Now, to get a random digit from the range `0..9`, writing:

```go
digit := randomByte % 10
```

seems correct at first glance.

But `256` is not evenly divisible by `10`:

```text
256 / 10 = 25, remainder 6
```

That is why some results come out more often than others.

Let's see it step by step.

The following values give `0` when taken `% 10`:

```text
0
10
20
...
250
```

Similarly, for the remainders `1`, `2`, `3`, `4`, `5` there is one extra value each.

But for the remainders `6`, `7`, `8`, `9` there is no such extra value.

As a result the values `0..5` appear with slightly higher probability than `6..9`.

This is called **modulo bias**.

For cryptographic code the following approach is wrong:

```go
// A wrong approach for cryptographic code:
digit := randomByte % 10
```

In an ordinary game or code unrelated to security, a very small bias may not matter.

But in cases such as:

* a one-time confirmation code;
* a secure index;
* picking part of a token;
* a cryptographic random value

a uniform distribution is important.

`crypto/rand.Int()` solves this problem correctly.

It rejects the extra values that do not distribute evenly into the needed range and takes a new random value.

As a result the values in the range `[0, n)` are chosen with equal probability.

That is why when generating a secure random index or confirmation code, `crypto/rand.Int()` should be used instead of `% n`.

## Which package should be chosen?

`math/rand` and `crypto/rand` do not fully replace each other.

Which package is chosen depends on the task.

| Task                                         | Package                           | Reason                                                   |
| -------------------------------------------- | --------------------------------- | -------------------------------------------------------- |
| Reproducing a test                           | a local `math/rand` generator     | The same seed gives the same stream                      |
| Simulation or a game                         | `math/rand`                       | Fast and convenient                                      |
| Shuffling a slice unrelated to security      | `math/rand`                       | `Shuffle()` exists                                       |
| Session ID or reset token                    | `crypto/rand`                     | The result is hard to predict                            |
| Cryptographic key                            | `crypto/rand`                     | Gives secure random bytes                                |
| One-time confirmation code                   | `crypto/rand`                     | A uniform distribution and resistance to guessing needed |

The main rule here is simple:

If someone else predicting the next value of the result poses no danger, `math/rand` is usually enough.

If the value is used in authentication, a token, a key or another security mechanism, `crypto/rand` must be chosen.

## Common mistakes

### Using `math/rand` for a security token

For example:

```go
tokenNumber := rand.Intn(1_000_000)
```

may not be a problem for an ordinary test or game.

But if this value is a password reset code or part of a session token, `math/rand` does not fit.

`math/rand` is a pseudorandom generator. If its seed or internal state is determined, it may become possible to predict the following values.

For security-related randomness, `crypto/rand` is used.

### Creating a new time seed before every call

Another old approach is seeding a new generator with the time every time a random number is needed.

For example, conceptually, creating:

```go
rand.New(rand.NewSource(time.Now().UnixNano()))
```

on every call.

This is not a good approach.

Generators created very close in time may risk getting very close or, in some environments, identical initial values.

Besides that, constantly creating a new generator is itself unnecessary.

Usually one generator is created and reused where needed.

In modern Go, when using the ordinary package-level `math/rand` functions, manually providing a time seed for the global generator is not needed at all.

### Thinking `Intn()` also includes the upper bound

The following call:

```go
rand.Intn(10)
```

is not from `0` to `10`.

It gives a value from the range:

```text
[0, 10)
```

That is, the possible results are:

```text
0
1
2
3
4
5
6
7
8
9
```

`10` does not come out.

If the range `1..10` is needed, a shift is required, for example:

```go
1 + rand.Intn(10)
```

### Not checking the `n <= 0` case

The following calls are dangerous:

```go
rand.Intn(n)
```

and:

```go
rand.Int(rand.Reader, max)
```

If the bound comes from outside and gets a wrong value, the function may panic.

That is why the bound must be checked in advance.

For example, a check like:

```go
if n <= 0 {
	return errors.New("n must be positive")
}
```

is useful.

### Writing an exact test for a random result

For a random function, a test like the following may be a wrong approach:

```go
if got != 57 {
	t.Fatal("unexpected value")
}
```

If the generator was not made deterministic, there is no guarantee that `57` comes out.

When testing a random result, usually its **invariants**, i.e. conditions that must always hold, are checked.

For example:

```go
if n < 0 || n >= max {
	t.Fatalf("value out of range: %d", n)
}
```

Here not an exact result but the range is checked.

If exactly the same sequence is needed in a test, an explicit seed can be given to a local generator:

```go
r := rand.New(rand.NewSource(42))
```

Then the test becomes reproducible.

## What is looked at in interviews?

On the topic of random values, knowing only the `rand.Intn()` syntax is usually not enough.

It is important to understand the following differences.

### The difference between pseudorandom and cryptographic generators

`math/rand` is a pseudorandom generator.

It is fast, convenient and makes it possible to create a deterministic stream in tests.

But it is not meant for security tokens.

`crypto/rand`, on the other hand, is used for security-related random values. This package is chosen for values such as tokens, keys and confirmation codes.

### The range `[0, n)`

`rand.Intn(n)` gives a value from the range:

```text
[0, n)
```

That is, for:

```go
rand.Intn(10)
```

the largest result is:

```text
9
```

If `n <= 0`, the function panics.

### A local generator for reproducible tests

If an exact random stream is needed in a test, creating a local `*rand.Rand` with:

```go
rand.New(rand.NewSource(seed))
```

instead of changing the global state is a good approach.

This generator does not affect other code and makes it easier to reproduce the test.

### A local `rand.Source` and concurrency

It is not safe for several goroutines to use at the same time a source obtained from `rand.NewSource()` and the `*rand.Rand` created from it.

If one generator is shared, access to it must be synchronized.

Or each goroutine can have its own generator.

### Modulo bias

Bringing a cryptographic random value into a range through:

```go
value % n
```

does not always give a uniform distribution.

If the number of source values is not evenly divisible by `n`, some results appear more often than others.

This is called modulo bias.

In security-related tasks, a method that preserves a uniform distribution for the needed range, such as `crypto/rand.Int()`, must be used.
