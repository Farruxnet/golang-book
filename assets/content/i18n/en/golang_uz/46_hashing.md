# Working with hashing and Base64 in Go

Hashing is the process of producing a fixed-length hash value, i.e. a **digest**, from data of arbitrary length.

Put simply, a hash function takes data and computes a short, fixed-length value from it.

For example, hashes are used for tasks such as:

* checking that a downloaded file is not corrupted;
* creating a cache key;
* detecting whether data has changed;
* checking message integrity;
* authenticating a message through HMAC.

There are several concepts here that look similar but have completely different purposes. It is important not to mix them up:

* a **hash** — usually a one-way transformation;
* **Base64** — a reversible text encoding;
* **encryption** — protection that is reversible with a key;
* **HMAC** — a way to check a message's integrity and authenticity using a secret key.

For example, data encoded with Base64 cannot be considered secret. Anyone can decode it. In the same way, a plain SHA-256 digest does not prove who sent a message.

## The main properties of a hash function

A good cryptographic hash function has several important properties.

First, the same input always gives the same digest.

For example:

```text
"hello" -> the same digest
"hello" -> that same digest again
```

This property makes it possible to check whether a file or text has changed later.

Second, a very small change in the input changes the digest drastically. For example, changing just one letter to uppercase can give a completely different result.

Third, recovering the original data from the digest must be practically hard. A hash is not encryption, so there is no key to "decrypt" it.

Fourth, finding the same digest for two different inputs must be hard. Such a case is called a **collision**.

For example:

```text
data A -> abc123...
data B -> abc123...
```

If `A` and `B` are different but the digest is the same, a collision has occurred.

A cryptographic hash algorithm is required to make deliberately creating such a collision very hard.

The digest length does not depend on the input size.

For example, SHA-256:

* for empty text;
* for short text like `"hello"`;
* for a file of several gigabytes

always gives a 256-bit digest.

256 bits means:

```text
256 / 8 = 32 bytes
```

That is why the SHA-256 result is always 32 bytes.

> **Attention**
>
> A hash value does not hide the data.
>
> If the input values are easy to guess, an attacker can hash likely values themselves and compare them with the digests.
>
> For example, if the password is `"123456"`, an attacker can compute a list of common passwords through SHA-256. That is why plain SHA-256 is not suitable for storing passwords.

## A first example with SHA-256

The `crypto/sha256` package from the Go standard library makes it possible to compute a SHA-256 digest.

In the following example we compute the SHA-256 value of the text `"hello world"`:

```go
package main

import (
	"crypto/sha256"
	"encoding/hex"
	"fmt"
)

func main() {
	data := []byte("hello world")
	sum := sha256.Sum256(data)

	fmt.Println("Number of bytes:", len(sum))
	fmt.Println("SHA-256:", hex.EncodeToString(sum[:]))
}
```

Result:

```text
Number of bytes: 32
SHA-256: b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9
```

Now let's look at the important lines one by one.

```go
data := []byte("hello world")
```

SHA-256 works not with text but with bytes. That is why the `string` was first converted to `[]byte`.

Then:

```go
sum := sha256.Sum256(data)
```

`sha256.Sum256()` takes a `[]byte` and returns a `[32]byte` value.

This is not a `slice` but an array whose length is known at compile time:

```go
[32]byte
```

The 32 bytes come exactly from the 256-bit length of a SHA-256 digest:

```text
256 bits / 8 = 32 bytes
```

In the next line:

```go
len(sum)
```

the result is `32`.

The digest itself consists of binary bytes. To make it convenient to read in the terminal, it is often converted to hexadecimal form:

```go
hex.EncodeToString(sum[:])
```

Here:

```go
sum[:]
```

creates a `[]byte` slice from the `[32]byte` array.

`hex.EncodeToString()` writes each byte as two hexadecimal characters.

For example, a single byte:

```text
255
```

in hexadecimal form is:

```text
ff
```

Because SHA-256 is 32 bytes, the hexadecimal string length is:

```text
32 × 2 = 64 characters
```

That is why when you see a SHA-256 digest in hex format, you usually see 64 characters.

If you hash the same text again, the result does not change. But even the smallest difference in the input changes the digest.

For example:

```text
hello
Hello
hello 
```

even though these three texts look very similar to the eye, their bytes are not the same. As a result the digests also come out different.

This rule matters when working with Unicode too. Texts that look the same can sometimes be expressed through different Unicode code points. A hash is computed not on the visible characters but on exactly the sequence of bytes.

You do not have to use the `encoding/hex` package to print a SHA-256 digest. `fmt` can also show bytes in hexadecimal format:

```go
sum := sha256.Sum256([]byte("go-lang.uz"))
fmt.Printf("%x\n", sum)
```

Here:

```text
%x
```

prints the bytes in lowercase hexadecimal format.

This approach is very convenient when you only need to display the digest.

If the hex string must later be used as a separate variable, `hex.EncodeToString()` fits better.

## Hashing large data as a stream

Hashing a small text or a small file once with `sha256.Sum256()` is convenient.

But when working with a large file, loading it fully into RAM is not a good approach.

For example, reading a 10 GB file like this:

```go
data, err := os.ReadFile("big-file.iso")
```

tries to take the whole file into memory.

Computing a hash does not need that. A hash algorithm can take data piece by piece.

In Go, `sha256.New()` is used for this. It returns an object that implements the `hash.Hash` interface.

```go
package main

import (
	"crypto/sha256"
	"fmt"
	"io"
	"log"
	"strings"
)

func main() {
	source := strings.NewReader("data coming from a large file")
	hasher := sha256.New()

	if _, err := io.Copy(hasher, source); err != nil {
		log.Fatal(err)
	}

	fmt.Printf("%x\n", hasher.Sum(nil))
}
```

The result is a 64-character SHA-256 digest:

```text
bf295d670f1f6902e79ffa87ae61538a22d609cdece5b16c116bfad8d8515fad
```

In this example:

```go
source := strings.NewReader("data coming from a large file")
```

creates a source that acts as an `io.Reader`.

In a real program this is often a file:

```go
file, err := os.Open("big-file.iso")
```

Then:

```go
hasher := sha256.New()
```

creates a new hasher that computes SHA-256.

The result of `sha256.New()` implements the `hash.Hash` interface. And `hash.Hash` can also work as an `io.Writer`.

That is why the following code is possible:

```go
io.Copy(hasher, source)
```

`io.Copy()` reads data from `source` in pieces and writes it to `hasher`.

The process goes roughly like this:

```text
source
  ↓
first piece
  ↓
hasher.Write(...)

source
  ↓
second piece
  ↓
hasher.Write(...)

source
  ↓
following pieces
  ↓
hasher.Write(...)
```

The hasher updates its internal state each time a piece arrives.

There is an important point here:

```go
hasher.Write(data)
```

does not return the digest immediately.

It only updates the internal state of the computation.

At the end:

```go
hasher.Sum(nil)
```

returns the digest of all data written so far.

`Sum(nil)` does not reset the hasher state.

For example:

```go
hasher.Write([]byte("hello"))
sum1 := hasher.Sum(nil)

hasher.Write([]byte(" world"))
sum2 := hasher.Sum(nil)
```

`sum2` is not just for `" world"`. It is the digest computed for:

```text
"hello world"
```

If a new, independent hash computation must be started, there are two variants:

```go
hasher.Reset()
```

or creating a new hasher:

```go
hasher = sha256.New()
```

The main benefit of the streaming approach is that memory usage is not directly tied to the file size.

For example, hashing a 10 GB file does not need 10 GB of RAM. The file is read in small pieces and the digest is computed step by step.

## Why are MD5 and SHA-1 not secure?

MD5 and SHA-1 are old hash algorithms.

MD5 gives a:

```text
128 bit = 16 byte
```

digest.

SHA-1 gives a:

```text
160 bit = 20 byte
```

digest.

The problem is not only that the digest is shorter than SHA-256's. The most important problem is that practical collision attacks exist for these algorithms.

That is, an attacker can produce the same digest for two different specially prepared files.

If a security system relies on the assumption:

```text
same digest -> same file
```

such a collision causes a big problem.

That is why MD5 and SHA-1 are not recommended for new security solutions.

MD5 may sometimes appear for compatibility with a legacy system or in old checksum formats unrelated to security.

Computing MD5 in Go is technically very easy:

```go
package main

import (
	"crypto/md5"
	"fmt"
)

func main() {
	sum := md5.Sum([]byte("hello world"))
	fmt.Printf("%x\n", sum)
}
```

Result:

```text
5eb63bbbe01eeed093cb22bb8f5acdc3
```

The MD5 result is 16 bytes:

```text
128 bits / 8 = 16 bytes
```

Because each byte turns into two characters in hexadecimal form:

```text
16 × 2 = 32 characters
```

come out.

The code works correctly. The problem is not in the API but in the security properties of the algorithm.

Do not use MD5 for the following tasks:

* storing passwords;
* checking digital signature security;
* certificate-related security decisions;
* checking the authenticity of a file an attacker can change.

If a legacy protocol requires exactly MD5, you may have to use it. But that situation does not mean MD5 is a good choice for a new security design.

## A plain hash does not provide authentication

SHA-256 helps detect that data has changed.

For example, suppose a server gave a digest for a file:

```text
file.zip
SHA-256: abc123...
```

After downloading the file, you can compute SHA-256 and compare the result with the expected digest.

This detects accidental corruption well.

But there is an important limitation here.

If an attacker:

* can change the message;
* can also change the digest,

they compute a new SHA-256 digest for the new message themselves.

For example:

```text
original message:
amount=150000

original digest:
SHA256(amount=150000)
```

The attacker can replace both:

```text
new message:
amount=1

new digest:
SHA256(amount=1)
```

If the receiver checks through plain SHA-256, the digest comes out correct.

So a plain hash does not prove **who sent** the message.

HMAC is used for this.

HMAC uses, together with a hash function, a secret key known only to the trusted parties.

```go
package main

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/hex"
	"fmt"
)

func sign(message, key []byte) []byte {
	mac := hmac.New(sha256.New, key)
	mac.Write(message)
	return mac.Sum(nil)
}

func main() {
	message := []byte("order_id=42&amount=150000")
	key := []byte("server-secret-key")

	signature := sign(message, key)
	fmt.Println("Signature:", hex.EncodeToString(signature))
	fmt.Println("Match:", hmac.Equal(signature, sign(message, key)))
	fmt.Println("Changed message:", hmac.Equal(signature, sign([]byte("order_id=42&amount=1"), key)))
}
```

Result:

```text
Signature: babc8e66e258fc5c0b4ed823d4bbbf7c3989e2bb84b2e884c6ae6e1d51270b9c
Match: true
Changed message: false
```

First let's look at the `sign()` function:

```go
func sign(message, key []byte) []byte {
	mac := hmac.New(sha256.New, key)
	mac.Write(message)
	return mac.Sum(nil)
}
```

Here:

```go
hmac.New(sha256.New, key)
```

creates an HMAC based on SHA-256.

The first argument:

```go
sha256.New
```

is a function that creates the hash function.

The second argument:

```go
key
```

is the secret key.

Then:

```go
mac.Write(message)
```

adds the message to be signed to the HMAC computation.

At the end:

```go
mac.Sum(nil)
```

returns the HMAC result.

In HMAC the result depends not only on the message but also on the key.

That is why:

```text
same message + same key -> same HMAC
```

but:

```text
different message + same key -> different HMAC
```

and:

```text
same message + different key -> different HMAC
```

The main idea is that if the attacker does not know the secret key, they cannot compute the correct HMAC value for a changed message.

For checking:

```go
hmac.Equal(signature, calculatedSignature)
```

is used.

In the example:

```go
hmac.Equal(signature, sign(message, key))
```

returns `true`, because both the message and the key are the same.

But:

```go
hmac.Equal(
	signature,
	sign([]byte("order_id=42&amount=1"), key),
)
```

returns `false`, because the message has changed.

Why are a plain `==` or a plain string comparison not used?

When comparing security-related values, information may leak through the execution time. `hmac.Equal()` is specially written for such a check.

That is why when checking an HMAC signature:

```go
hmac.Equal(a, b)
```

must be used.

Using a plain:

```go
a == b
```

or `==` on hex strings is not good practice from a security standpoint.

In the example the secret key is written in the code:

```go
key := []byte("server-secret-key")
```

This is only for explanation.

In a real production project do not keep secrets in source code.

The key is usually obtained through:

* an environment variable;
* a secret manager;
* a container secret;
* a Kubernetes Secret;
* other protected configuration.

## Base64 is not a hash

Because Base64 often appears next to security topics, it is easy to confuse it with hashing or encryption.

In fact Base64 is an **encoding** method.

It expresses binary data using only text characters.

For example, if binary data must be carried inside:

* JSON;
* XML;
* email;
* a URL;
* another text protocol,

Base64 may be useful.

But Base64 gives no secrecy at all.

Anyone can decode the encoded data again.

In the following example we first encode text through Base64 and then restore it:

```go
package main

import (
	"encoding/base64"
	"fmt"
)

func main() {
	data := []byte("hello world")
	encoded := base64.StdEncoding.EncodeToString(data)

	decoded, err := base64.StdEncoding.DecodeString(encoded)
	if err != nil {
		fmt.Println("Decode error:", err)
		return
	}

	fmt.Println("Encoded:", encoded)
	fmt.Println("Restored:", string(decoded))
}
```

Result:

```text
Encoded: aGVsbG8gd29ybGQ=
Restored: hello world
```

The encoding line:

```go
encoded := base64.StdEncoding.EncodeToString(data)
```

turns the bytes inside `data` into Base64 text.

Result:

```text
aGVsbG8gd29ybGQ=
```

This value is not encrypted. No secret key is needed to decode it.

The next line:

```go
decoded, err := base64.StdEncoding.DecodeString(encoded)
```

turns the Base64 string back into the original bytes.

If the string is not in valid Base64 format, `DecodeString()` returns an error.

For example, if there is an invalid character or wrong padding:

```go
decoded, err := base64.StdEncoding.DecodeString("###")
```

`err` is not `nil`.

Base64 also increases the data size somewhat.

The main rule:

```text
3 bytes -> 4 Base64 characters
```

For example:

```text
24 bits of input
↓
4 × 6 bits
↓
4 Base64 characters
```

That is why the result is usually about a third larger than the original data.

More precisely, the length is usually rounded up to 4-byte blocks.

The character seen at the end of Base64:

```text
=
```

is **padding**, i.e. a filler character.

It helps show that the last block was not a full 3 bytes.

## Standard and URL-safe Base64

Base64 has several variants.

The most commonly used ones in Go are:

```go
base64.StdEncoding
base64.URLEncoding
base64.RawURLEncoding
```

Their difference is especially important inside URLs.

The standard Base64 alphabet has the characters:

```text
+
/
```

Inside a URL these characters may have a special meaning or require extra escaping.

That is why the URL-safe variant uses the substitution:

```text
+ -> -
/ -> _
```

The following example shows the difference:

```go
package main

import (
	"encoding/base64"
	"fmt"
)

func main() {
	data := []byte{251, 255, 239}

	fmt.Println(base64.StdEncoding.EncodeToString(data))
	fmt.Println(base64.RawURLEncoding.EncodeToString(data))
}
```

Result:

```text
+//v
-__v
```

The first result:

```text
+//v
```

was produced by `StdEncoding`.

The second result:

```text
-__v
```

was produced by `RawURLEncoding`.

Here:

```text
+ -> -
/ -> _
```

were substituted.

The `Raw` in the name `RawURLEncoding` means padding is not used.

For example, the ordinary URL-safe variant:

```go
base64.URLEncoding
```

may work with padding.

The raw variant:

```go
base64.RawURLEncoding
```

does not write the trailing `=` padding characters.

The raw URL-safe format is common in URL tokens, JWT parts or values suitable for file names.

It is important to use the same variant during encoding and decoding.

For example, if the value was created with:

```go
base64.RawURLEncoding.EncodeToString(data)
```

it should usually be decoded with:

```go
base64.RawURLEncoding.DecodeString(value)
```

If another encoding is used, the alphabet or the padding rule may not match and `DecodeString()` returns an error.

## How should passwords be stored?

SHA-256 and SHA-512 are strong cryptographic hash algorithms.

But this does not automatically make them good for storing passwords.

The problem is that SHA-256 works very fast.

When checking file integrity this is an advantage:

```text
a lot of data -> a fast digest
```

But for passwords exactly this speed creates a danger.

If password hashes leak from the database, an attacker may try to check millions or billions of likely passwords quickly.

For example:

```text
123456
password
qwerty
admin
...
```

Computing SHA-256 for each guess is very cheap.

That is why special **password hashing** algorithms are used for passwords.

Common variants:

* Argon2id;
* scrypt;
* bcrypt;
* PBKDF2, if an organization or standard requires it.

These algorithms are deliberately designed to be slower and resource-demanding.

The goal is not to slow down login. The goal is to raise the attacker's cost of checking a huge number of guesses.

Password hashing usually also works with a **salt**.

A salt is a separate random value created for each password.

For example, suppose two users have the same password:

```text
user A: secret123
user B: secret123
```

If no salt is used:

```text
hash(secret123) == hash(secret123)
```

If the database leaks, identical digests show that the users may have the same password.

With a salt:

```text
hash(secret123 + saltA)
hash(secret123 + saltB)
```

give different results.

An important point: the salt does not have to be secret.

It is usually stored in the database together with the password hash.

The salt's job:

* not turning identical passwords into identical digests;
* reducing the usefulness of large precomputed hash tables.

Algorithms like Argon2id, scrypt and bcrypt also have a **cost** parameter that controls the computation expense.

For example, if the server is more powerful, the algorithm can be tuned to be more expensive.

In the Go ecosystem, practical implementations of these algorithms are available in the `golang.org/x/crypto` module.

When choosing the algorithm and parameters, the following are considered:

* the security requirements;
* the server's CPU capacity;
* memory;
* the login traffic volume;
* current security recommendations.

Do not create a homemade scheme like:

```text
SHA-256(password + salt)
```

Even with a salt added, SHA-256 still remains a very fast algorithm.

For password hashing, an algorithm created exactly for this task must be used.

## Checking a file checksum

SHA-256 is very useful for checking that a file is not corrupted.

For example, if you are downloading a software distribution, the official site may give a digest like:

```text
SHA256:
6b7e...
```

You compute SHA-256 for the downloaded file and compare it with the expected value.

If the digests are the same, it is highly likely that the file bytes match the expected file.

But here it matters **where the digest came from**.

If both the file and the digest come from the same untrusted server, an attacker may replace both.

For example:

```text
original file      -> malicious file
original SHA-256   -> the new SHA-256 value of the malicious file
```

When you check, the digest matches, because the attacker updated it too.

That is why for a checksum to be useful for security, the expected digest must be taken from a trusted source.

For example:

* a trusted HTTPS page;
* a signed release manifest;
* a separately verified source.

It is also useful to check the digest text's format before comparing it.

A SHA-256 digest must be:

```text
32 bytes
```

and in hexadecimal format:

```text
64 characters
```

For example, a value from an external source may look like:

```text
ABCDEF...
```

or:

```text
abcdef...
```

In hexadecimal digits, uppercase and lowercase do not change the value.

That is why, rather than comparing strings as plain strings, the expected digest can first be decoded into bytes:

```go
expected, err := hex.DecodeString(expectedHex)
```

Then you can check that it is 32 bytes:

```go
if len(expected) != sha256.Size {
	// wrong SHA-256 length
}
```

The value of `sha256.Size` equals:

```text
32
```

After that, it can be compared with the computed digest in byte form.

This approach helps handle format issues more precisely.

## Common mistakes

### Treating Base64 as encryption

Base64 does not hide data.

For example:

```text
aGVsbG8gd29ybGQ=
```

may look unintelligible to the eye. But no secret or key is needed to decode it.

With an ordinary Base64 decoder this value turns back into:

```text
hello world
```

That is why do not use Base64 to protect secret data.

### Applying plain SHA-256 to a password

SHA-256 is a strong hash function, but it is too fast for passwords.

An attacker can check a huge number of password guesses in a short time.

For passwords, choose a password hashing algorithm such as:

* Argon2id;
* scrypt;
* bcrypt;
* PBKDF2 when required.

### Using MD5 or SHA-1 for a security decision

Practical collision attacks are known for MD5 and SHA-1.

That is why do not rely on these algorithms to check the security of data an attacker can control.

Legacy compatibility is a different matter. But a new security design should use a modern algorithm.

### Creating a homemade scheme for message authentication

Sometimes code like the following appears:

```text
SHA-256(key || message)
```

or:

```text
SHA-256(message || key)
```

This is not a standard scheme that replaces HMAC.

Building cryptographic constructions by hand can lead to subtle mistakes.

For message authentication use standard HMAC:

```go
hmac.New(sha256.New, key)
```

### Taking a large file fully into RAM

The following code is convenient for small files:

```go
data, err := os.ReadFile(path)
```

But for a very large file it loads the whole file into RAM.

Computing a hash does not need that.

Instead, use a streaming approach such as:

```go
file, err := os.Open(path)
```

and:

```go
io.Copy(hasher, file)
```

### Comparing a security signature with a plain `==`

When checking security values like HMAC:

```go
hmac.Equal(a, b)
```

must be used.

This function is meant exactly for comparing MAC values safely.

### Thinking that text that looks the same also has the same bytes

A hash is computed not on the image of the characters but on the bytes.

For example, in Unicode, text that looks the same to the user may be expressed with different sequences of code points.

That is why a protocol must clearly define how text is encoded and, if needed, how Unicode normalization is performed.

Otherwise two systems may compute different digests for text that looks the same.

## What is looked at in interviews?

In an interview, knowing only the `sha256.Sum256()` syntax may not be enough. It is usually important to be able to distinguish the concepts correctly.

### The difference between hashing, encoding, encryption and HMAC

The following must be clearly distinguished:

```text
Hash:
data -> digest
usually not reversible

Base64:
data -> text encoding
easily decoded

Encryption:
data + key -> ciphertext
reversible with the key

HMAC:
message + secret key -> authentication code
```

Calling Base64 encryption is a technical mistake.

### The concepts of collision and preimage

A **collision** is finding the same digest for two different inputs:

```text
hash(A) == hash(B)
A != B
```

The **preimage** problem is about finding an input matching a given digest:

```text
a digest is given
↓
find an input matching it
```

In a cryptographic hash function such computations must be practically very hard.

### The digest length does not depend on the input

For SHA-256:

```text
1 byte input  -> 32 byte digest
1 MB input    -> 32 byte digest
10 GB input   -> 32 byte digest
```

The digest size does not grow with the input size.

### Why is SHA-256 not suitable for passwords?

The reason is not that SHA-256 is a weak algorithm.

The reason is that it works **very fast**.

Speed is useful in file hashing. But in checking password guesses it also benefits the attacker.

That is why password hashing algorithms deliberately work more expensively.

### The difference between `sha256.Sum256()` and `sha256.New()`

`sha256.Sum256()` is convenient for a one-time computation:

```go
sum := sha256.Sum256(data)
```

It returns:

```go
[32]byte
```

`sha256.New()` is used for streaming computation:

```go
h := sha256.New()
```

It returns an object that implements the `hash.Hash` interface.

Then data is written to it in pieces:

```go
h.Write(part1)
h.Write(part2)
h.Write(part3)
```

At the end the digest is obtained through:

```go
sum := h.Sum(nil)
```

### Base64 size

In Base64 the rule:

```text
3 bytes -> 4 characters
```

applies.

That is why the result is usually about 33% larger than the original.

Because of padding, the exact length is filled up to 4-character blocks.

### Base64 variants

The main variants:

```go
base64.StdEncoding
base64.URLEncoding
base64.RawURLEncoding
```

`StdEncoding` uses the characters:

```text
+
/
```

`URLEncoding` uses the characters:

```text
-
_
```

`RawURLEncoding` is also URL-safe, but does not write padding.

### Why `hmac.Equal()` is used for HMAC

When checking an HMAC signature:

```go
hmac.Equal(expected, actual)
```

must be used.

This is a special function for comparing MAC values safely.

Using this API for HMAC instead of comparing plain strings or bytes with `==` is considered the correct practice.
