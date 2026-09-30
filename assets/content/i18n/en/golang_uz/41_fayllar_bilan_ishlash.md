# Working with files in Go

A file is one of the ways to keep data even after a program ends. Ordinary variables in program memory disappear when the program ends. Data written to a file, on the other hand, stays on disk and can be read again on the next run.

Configuration, logs, JSON documents, images, reports and many other kinds of data can be stored as files.

When working with files in Go, errors are a normal occurrence. For example:

* the file may not exist;
* the program may not have permission to read or write the file;
* the disk may have run out of free space;
* the file may be in use by another process;
* the given path may be wrong.

That is why almost every operation that works with files returns an `error`. Continuing without checking these errors may lead to a wrong result or even a `panic`.

## The main packages

Several packages from the Go standard library come up often when working with files:

* `os` — for creating, opening, reading, writing and deleting files and getting metadata;
* `io` — gives general interfaces and helper functions for reading and writing data streams;
* `bufio` — for buffered reading and writing, convenient for reading a file line by line, among other things;
* `path/filepath` — for building and analyzing file paths suited to the operating system;
* `encoding/json` — for converting JSON data to Go values and Go values to JSON.

In older Go code you may also see the `io/ioutil` package. Many of its functions were later moved to the `os` and `io` packages.

For example, new code usually uses functions such as:

* `os.ReadFile`;
* `os.WriteFile`;
* `os.CreateTemp`;
* `io.ReadAll`.

This does not mean old code does not work. You may see existing code written with `io/ioutil`. But when writing new code, it is better to use the modern `os` and `io` functions.

## Writing to a file and reading from it

To write a small file in one operation, `os.WriteFile` is very convenient.

Its main behavior is as follows:

1. if the file does not exist, it creates a new file;
2. if the file exists, it truncates its old contents;
3. it writes the given data from the beginning of the file.

In the following example text is first written to a file, and then the same file is read back:

```go
package main

import (
	"fmt"
	"log"
	"os"
)

func main() {
	path := "message.txt"
	content := []byte("Go reads files as a sequence of bytes.\n")

	if err := os.WriteFile(path, content, 0o644); err != nil {
		log.Fatal("could not write the file: ", err)
	}

	data, err := os.ReadFile(path)
	if err != nil {
		log.Fatal("could not read the file: ", err)
	}

	fmt.Print(string(data))
}
```

Result:

```text
Go reads files as a sequence of bytes.
```

Let's go through this code step by step.

First the file path is set:

```go
path := "message.txt"
```

This is a relative path. So the file is usually found or created relative to the current directory the program runs in.

Then the text is converted to `[]byte`:

```go
content := []byte("Go reads files as a sequence of bytes.\n")
```

`os.WriteFile` takes the data as `[]byte`.

At the basic level the file system has no concept of "text", "JSON" or "image". A file stores a sequence of bytes. The file format determines how those bytes should be interpreted.

For example:

```go
[]byte("Go")
```

converts a string value into a UTF-8 encoded sequence of bytes.

Then the file is written:

```go
if err := os.WriteFile(path, content, 0o644); err != nil {
	log.Fatal("could not write the file: ", err)
}
```

There are three arguments here:

```text
path
content
0o644
```

`path` is the file name.

`content` is the bytes to write.

`0o644` is the file mode used when a new file is created.

Then the file is read back:

```go
data, err := os.ReadFile(path)
```

`os.ReadFile` also returns `[]byte`. That is why when printing, the `[]byte` value is converted to a `string` with:

```go
fmt.Print(string(data))
```

### What does `0o644` mean?

`0o644` is a file mode written in the base-8, i.e. octal, number system.

On Unix-family systems it roughly means the following permissions:

```text
owner:   read + write
group:   read
others:  read
```

In symbolic form:

```text
rw-r--r--
```

This value can be seen as three parts:

```text
6 4 4
```

`6`:

```text
4 + 2 = read + write
```

`4`:

```text
read
```

The other `4` too:

```text
read
```

But there is an important subtlety here. The real final permission of a new file also depends on the process's `umask` setting.

So even if `0o644` is given, the operating system may remove some permissions from it.

Windows, on the other hand, does not interpret Unix permission bits exactly the way Unix systems do.

> **Attention**
>
> `os.WriteFile` replaces the contents of an existing file. If the old data is needed, save it first or open the file in `os.O_APPEND` mode.

### When should `os.ReadFile` be used?

`os.ReadFile` loads the whole contents of a file into memory at once.

For example, for a 20 KiB configuration file this is very convenient:

```go
data, err := os.ReadFile("config.json")
```

The code is simple and clear.

But if the file is several gigabytes, the situation changes. For example, if you try to read a 4 GiB log file with `os.ReadFile`, the program may take up a very large amount of memory.

That is why for large files it is better to process data as a stream. Then the whole file is not taken into memory at once. It is read in small pieces.

For such tasks tools like `bufio.Scanner`, `bufio.Reader`, `file.Read` or `io.Copy` are used.

## Appending to a file

Sometimes new data must be added to the end of an existing file without losing its contents.

A log file is a good example of this:

```text
server started
request received
a new user logged in
```

Each new log entry must be added to the end of the file without replacing the old data.

`os.OpenFile` can be used for this:

```go
package main

import (
	"fmt"
	"os"
)

func appendLine(path, line string) error {
	file, err := os.OpenFile(path, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0o644)
	if err != nil {
		return fmt.Errorf("opening the file: %w", err)
	}

	if _, err := file.WriteString(line + "\n"); err != nil {
		_ = file.Close()
		return fmt.Errorf("writing to the file: %w", err)
	}

	if err := file.Close(); err != nil {
		return fmt.Errorf("closing the file: %w", err)
	}
	return nil
}

func main() {
	path := "app.log"
	if err := os.Remove(path); err != nil && !os.IsNotExist(err) {
		fmt.Println("deleting the old file:", err)
		return
	}

	if err := appendLine(path, "server started"); err != nil {
		fmt.Println("error:", err)
		return
	}
	if err := appendLine(path, "request received"); err != nil {
		fmt.Println("error:", err)
		return
	}

	data, err := os.ReadFile(path)
	if err != nil {
		fmt.Println("error:", err)
		return
	}
	fmt.Print(string(data))
}
```

Result:

```text
server started
request received
```

The main line:

```go
file, err := os.OpenFile(
	path,
	os.O_APPEND|os.O_CREATE|os.O_WRONLY,
	0o644,
)
```

In the original code this is written on one line. The meaning is the same: several flags are combined into one value.

Here `|` is the bitwise OR operator.

The flags do the following:

* `os.O_APPEND` — adds writes to the end of the file;
* `os.O_CREATE` — creates the file if it does not exist;
* `os.O_WRONLY` — opens the file for writing only.

Combining them:

```go
os.O_APPEND | os.O_CREATE | os.O_WRONLY
```

tells `os.OpenFile` that three behaviors are needed at the same time.

### Why was the `Close` error checked?

In the writing code, closing the file is also checked separately:

```go
if err := file.Close(); err != nil {
	return fmt.Errorf("closing the file: %w", err)
}
```

At first glance this may seem unnecessary. After all, `WriteString` finished successfully.

But during writing, the data does not have to reach the physical disk right away. The operating system may keep the data in a buffer temporarily.

Some errors may be detected during:

* `Write`;
* `Sync`;
* `Close`.

That is why for important writes it is useful to check the `Close` error too.

For files opened for reading only, on the other hand:

```go
defer file.Close()
```

is often enough. Because whether the read result is successfully kept does not depend on `Close`.

### What happens if several goroutines write to one file?

Several goroutines or several processes may write to one file at the same time.

In such a situation the writes may:

* arrive in an unexpected order;
* interleave with each other;
* break the logical record boundaries the program expected.

Do not assume that using `O_APPEND` automatically makes any complex write fully atomic.

For example, if one log entry is made of several `Write` calls, another writer may write its own data between them.

That is why for parallel writing to a shared file one of the following is usually used:

* a single writer goroutine;
* `sync.Mutex`;
* a dedicated logging library;
* an external log system.

## Reading a file line by line

When reading a large text file, you do not have to load all of it into memory at once.

For example, a log file can be processed one line at a time.

`bufio.Scanner` is convenient for this:

```go
package main

import (
	"bufio"
	"fmt"
	"os"
)

func main() {
	file, err := os.Open("app.log")
	if err != nil {
		fmt.Println("opening the file:", err)
		return
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	scanner.Buffer(make([]byte, 64*1024), 1024*1024)

	lineNumber := 1
	for scanner.Scan() {
		fmt.Printf("%d: %s\n", lineNumber, scanner.Text())
		lineNumber++
	}

	if err := scanner.Err(); err != nil {
		fmt.Println("reading the file:", err)
	}
}
```

First the file is opened:

```go
file, err := os.Open("app.log")
```

`os.Open` opens the file in read-only mode.

After it opens successfully:

```go
defer file.Close()
```

is written.

This ensures the file is closed when the function ends.

Then a `Scanner` is created:

```go
scanner := bufio.NewScanner(file)
```

`bufio.NewScanner` takes an `io.Reader`. And `*os.File` implements the `io.Reader` interface. That is why the file can be given to the `Scanner` directly.

The loop:

```go
for scanner.Scan() {
	fmt.Printf("%d: %s\n", lineNumber, scanner.Text())
	lineNumber++
}
```

reads the next token on each iteration.

By default the `Scanner` works by lines. That is why here a token is one line.

`scanner.Scan()` returns:

* `true` if there is a next line;
* `false` when the file ends;
* `false` also when a read error occurs.

The current line is obtained through:

```go
scanner.Text()
```

`Text()` does not return the `\n` character at the end of the line.

### Why is `scanner.Err()` checked after the loop?

The problem is that `Scan()` may return `false` in two different situations:

1. the file ended normally;
2. an error occurred during reading.

That is why after leaving the loop:

```go
if err := scanner.Err(); err != nil {
	fmt.Println("reading the file:", err)
}
```

is checked.

If `scanner.Err()` is `nil`, reading usually ended normally.

If there is an error, a problem occurred while reading the file.

### Why is `Scanner.Buffer` needed?

`Scanner` puts a limit on the size of one token.

If a very long line appears, the default limit may not be enough.

In the example:

```go
scanner.Buffer(make([]byte, 64*1024), 1024*1024)
```

sets the maximum token size to 1 MiB.

Here:

```text
64 * 1024
```

is used for the initial buffer.

```text
1024 * 1024
```

sets the maximum token size to 1 MiB.

If a single line in the file is even longer, the `Scanner` may return an error.

When working with very long records, large blocks or binary data not split into lines, the following may be better:

* `bufio.Reader`;
* `file.Read`;
* `io.Copy`.

## `os.File` and the file cursor

When `os.Open` or `os.OpenFile` finishes successfully, it returns an `*os.File`.

Although `*os.File` looks like an ordinary Go struct value, behind it there is an open file resource in the operating system.

An open file has a current position. This is often called the file cursor or offset.

For example, imagine the file contains the data:

```text
abcdef
```

If the program reads the first three bytes:

```text
abc
```

the file cursor moves to the next position:

```text
abc|def
```

The next `Read` usually starts from the position where `d` is.

`Read` and `Write` usually work from the current position and move the cursor forward after the operation.

`Seek`, on the other hand, lets you move the cursor elsewhere.

For example, conceptually:

```text
start   -> offset 0
middle  -> a certain offset
end     -> the file size
```

This is useful for random access, i.e. jumping to any part of the file to work with it.

### Why must a file be closed?

An open file does not only take up space in Go memory.

The operating system keeps a limited resource for each open file, usually a file descriptor or handle.

If a program opens files and does not close them, this limit may run out over time.

On Unix systems in such a situation an error like the following may appear:

```text
too many open files
```

This is a serious problem especially in a long-running backend program.

**Attention**

Opening thousands of files in a loop and writing `defer file.Close()` each time can also cause problems. `defer` calls run when the function ends. So all the files may stay open until the big loop finishes.

For example, this approach requires care:

```go
for _, path := range paths {
    file, err := os.Open(path)
    if err != nil {
        continue
    }
    defer file.Close()

    // ...
}
```

If `paths` has thousands of files, all of them may stay open until the outer function ends.

Instead, the work with one file can be split into a separate function:

```go
func processFile(path string) error {
    file, err := os.Open(path)
    if err != nil {
        return err
    }
    defer file.Close()

    // ...
    return nil
}
```

In this case the corresponding file is closed when each `processFile` call finishes.

Or the file can be closed explicitly with `Close` at the end of the iteration.

## Checking whether a file exists and its type

`os.Stat` is used to get metadata about a file or directory.

If it succeeds, it returns an `os.FileInfo`.

Example:

```go
package main

import (
	"errors"
	"fmt"
	"os"
)

func main() {
	info, err := os.Stat("message.txt")
	switch {
	case err == nil:
		fmt.Println("name:", info.Name())
		fmt.Println("size:", info.Size(), "bytes")
		fmt.Println("directory:", info.IsDir())
		fmt.Println("mode:", info.Mode())
	case errors.Is(err, os.ErrNotExist):
		fmt.Println("the file does not exist")
	default:
		fmt.Println("could not get information about the file:", err)
	}
}
```

Three cases are separated here.

The first case:

```go
case err == nil:
```

`os.Stat` worked successfully. So the metadata exists.

The second case:

```go
case errors.Is(err, os.ErrNotExist):
```

the given path does not exist.

The third case:

```go
default:
```

another kind of error occurred.

For example:

* insufficient permission;
* part of the path cannot be accessed;
* a file-system-related I/O error.

That is why concluding "it is not `IsNotExist`, so the file exists" is wrong.

### `os.FileInfo` methods

Commonly used methods of `os.FileInfo` are:

* `Name()` — returns the base name of the file or directory;
* `Size()` — returns the size of a regular file in bytes;
* `Mode()` — returns the file type and permission bits;
* `ModTime()` — returns the last modification time;
* `IsDir()` — returns `true` if the object is a directory;
* `Sys()` — gives extra operating-system-specific metadata.

For example:

```go
info.Size()
```

returns the size in bytes for a regular file.

But the `Size()` value for a directory should not be understood simply as "the total size of the files inside the directory". The semantics of directory metadata depend on the file system.

### Why is `errors.Is` used?

The following code:

```go
errors.Is(err, os.ErrNotExist)
```

can check not only whether the error is `os.ErrNotExist` itself, but whether it matches even if wrapped inside other errors.

For example, the error may have been wrapped through:

```go
fmt.Errorf("could not open config: %w", err)
```

That is why in new Go code `errors.Is` is very convenient for checking errors by cause.

### Is it safe to `Stat` first and then `Open`?

The following idea seems logical at first glance:

```text
1. check whether the file exists;
2. if it exists, open it.
```

But between these two operations another process may delete the file, replace it or change its permissions.

For example:

```text
Stat -> the file exists
        another process deletes the file
Open -> error
```

That is why checking in advance with `Stat` does not replace checking the error returned by `Open`.

Often the most correct approach is:

1. perform the needed operation;
2. handle the `error` returned by exactly that operation.

## Deleting a file

`os.Remove` is used to delete a single file or an empty directory:

```go
if err := os.Remove("message.txt"); err != nil && !errors.Is(err, os.ErrNotExist) {
	return fmt.Errorf("deleting the file: %w", err)
}
```

This snippet is not a complete program.

To use it, the packages:

```go
"errors"
"fmt"
```

must be imported.

Also, the code must be written inside a function that can return an `error`.

The logic of the code is as follows.

First:

```go
os.Remove("message.txt")
```

tries to delete the file.

If there is no error:

```text
err == nil
```

nothing is done.

If the file does not exist:

```go
errors.Is(err, os.ErrNotExist)
```

is `true`.

In the example this case is also accepted as success. Because the goal is for the file not to exist at the end of the operation.

But other errors, such as:

* insufficient permission;
* a file system error;
* a wrong path

are returned upward.

### Safety when deleting

`os.Remove` deletes the file. It does not guarantee moving it to a "trash" or "recycle bin".

That is why before the call:

```go
os.Remove(path)
```

it is important to be sure that `path` refers to exactly the right file.

This is especially important when `path` comes from the user, an HTTP request or another external source.

For example, the user may send a path like:

```text
../../secret.txt
```

This danger is looked at again in the `Path safety` section.

## Working with a JSON file

The `encoding/json` package is used to convert JSON data into Go values and Go values into JSON.

The following program:

1. writes a JSON document to a file;
2. opens the file;
3. reads the JSON through a stream;
4. puts the result into a `Person` struct.

```go
package main

import (
	"encoding/json"
	"fmt"
	"os"
)

type Person struct {
	Name   string   `json:"name"`
	Age    int      `json:"age"`
	Skills []string `json:"skills"`
}

func main() {
	const document = `{
  "name": "Ali",
  "age": 25,
  "skills": ["Go", "PostgreSQL"]
}`

	if err := os.WriteFile("person.json", []byte(document), 0o644); err != nil {
		fmt.Println("writing the JSON file:", err)
		return
	}

	file, err := os.Open("person.json")
	if err != nil {
		fmt.Println("opening the JSON file:", err)
		return
	}
	defer file.Close()

	var person Person
	decoder := json.NewDecoder(file)
	decoder.DisallowUnknownFields()
	if err := decoder.Decode(&person); err != nil {
		fmt.Println("reading the JSON file:", err)
		return
	}

	fmt.Println("Name:", person.Name)
	fmt.Println("Age:", person.Age)
	fmt.Println("Skills:", person.Skills)
}
```

Result:

```text
Name: Ali
Age: 25
Skills: [Go PostgreSQL]
```

`os.WriteFile()` writes the JSON text to the `person.json` file. Because the `*os.File` value returned by `os.Open()` implements the `io.Reader`
interface, it can be given to `json.NewDecoder()` directly. `Decode(&person)` writes the read
values into the existing `person` variable.

The matching between JSON and Go types, struct tags, `Marshal`, `Unmarshal` and strict decoding are explained in detail in the lesson on working with JSON in Go.

## Atomically replacing an important file

Rewriting some files directly with a plain `os.WriteFile` can be dangerous.

For example, the `config.txt` file contains:

```text
port=8080
```

While updating it, the program:

1. truncates the old file;
2. starts writing the new data;
3. the process stops before the write finishes.

As a result only part of the file may remain.

For an important configuration file this is a bad situation.

The practical approach is as follows:

1. write the new contents to a temporary file;
2. sync the written data;
3. close the file;
4. `Rename` the finished temporary file to the main name.

Example:

```go
package main

import (
	"fmt"
	"os"
	"path/filepath"
)

func writeAtomic(path string, data []byte, perm os.FileMode) error {
	dir := filepath.Dir(path)
	temp, err := os.CreateTemp(dir, ".update-*")
	if err != nil {
		return fmt.Errorf("creating a temporary file: %w", err)
	}
	tempName := temp.Name()
	defer os.Remove(tempName)

	if err := temp.Chmod(perm); err != nil {
		_ = temp.Close()
		return fmt.Errorf("setting permissions: %w", err)
	}
	if _, err := temp.Write(data); err != nil {
		_ = temp.Close()
		return fmt.Errorf("writing to the temporary file: %w", err)
	}
	if err := temp.Sync(); err != nil {
		_ = temp.Close()
		return fmt.Errorf("flushing the file to disk: %w", err)
	}
	if err := temp.Close(); err != nil {
		return fmt.Errorf("closing the temporary file: %w", err)
	}
	if err := os.Rename(tempName, path); err != nil {
		return fmt.Errorf("replacing the main file: %w", err)
	}
	return nil
}

func main() {
	if err := writeAtomic("config.txt", []byte("port=8080\n"), 0o600); err != nil {
		fmt.Println("error:", err)
		return
	}

	data, err := os.ReadFile("config.txt")
	if err != nil {
		fmt.Println("error:", err)
		return
	}
	fmt.Print(string(data))
}
```

Result:

```text
port=8080
```

Now let's go through the `writeAtomic` function step by step.

### 1. Determining the main file's directory

```go
dir := filepath.Dir(path)
```

For example, if:

```text
path = /app/config/config.txt
```

then:

```text
dir = /app/config
```

### 2. Creating a temporary file in the same directory

```go
temp, err := os.CreateTemp(dir, ".update-*")
```

This creates the temporary file exactly inside the directory where the main file is.

For example, a name like:

```text
/app/config/.update-123456
```

may be produced.

Why exactly this directory?

Because `Rename` is used later. A `Rename` within one file system often gives the needed atomicity properties better.

If the temporary file is created on another file system, the rename may stop being a simple name change or may not work at all.

### 3. Saving the temporary file name

```go
tempName := temp.Name()
```

This name is needed later for `Rename`.

### 4. Cleaning up the temporary file on error

```go
defer os.Remove(tempName)
```

If one of the following steps ends with an error, an attempt to delete the temporary file is scheduled so it does not stay on disk.

If `Rename` succeeds, the old `tempName` no longer exists. In that case `os.Remove(tempName)` may return an error, but its result is deliberately not used here.

### 5. Setting permissions

```go
if err := temp.Chmod(perm); err != nil {
	_ = temp.Close()
	return fmt.Errorf("setting permissions: %w", err)
}
```

The temporary file is given the needed permissions.

In the example:

```go
0o600
```

is given.

On Unix systems this usually means:

```text
rw-------
```

that is, only the file's owner can read and write it.

### 6. Writing the data to the temporary file

```go
if _, err := temp.Write(data); err != nil {
	_ = temp.Close()
	return fmt.Errorf("writing to the temporary file: %w", err)
}
```

The main file is not changed yet.

The new data is first written to the temporary file.

That is why if an error occurs during writing, the old main configuration is still kept.

### 7. `Sync`

```go
if err := temp.Sync(); err != nil {
	_ = temp.Close()
	return fmt.Errorf("flushing the file to disk: %w", err)
}
```

`Sync` asks the operating system to pass the file's writes to the storage device.

This is needed to reduce the assumption "Write returned, so the data definitely reached the physical disk".

But the exact durability guarantees of `Sync` depend on the operating system, the file system and the storage device.

### 8. Closing the temporary file

```go
if err := temp.Close(); err != nil {
	return fmt.Errorf("closing the temporary file: %w", err)
}
```

The `Close` error is checked here too.

This is useful when writing an important file.

### 9. Replacing the main name with the finished file

```go
if err := os.Rename(tempName, path); err != nil {
	return fmt.Errorf("replacing the main file: %w", err)
}
```

Up to this step the old main file has been kept.

Now the fully written temporary file is moved to the `path` name.

The conceptual flow:

```text
config.txt
    |
    | the old file is still in use
    |
.update-123
    |
    | the new data is fully written
    | Sync
    | Close
    v
Rename
    |
    v
config.txt
```

### Does `Rename` always work the same way?

No.

The semantics of `Rename` replacing an existing file may depend on the operating system.

Especially when working with:

* Windows;
* a situation where several processes hold one file open;
* different file systems;
* a network filesystem

the behavior must be tested separately.

Besides that, this approach does not mean "there is an absolute guarantee even if the power suddenly goes out".

If a strong durability guarantee is needed, on some platforms extra measures such as syncing the directory metadata too may be required.

So this approach is practical and important, but its exact guarantees depend on the file system and the operating system.

## Path safety

If a file path comes from an external source, trusting it as a plain string is dangerous.

For example, a program gets a file name from the user:

```text
report.txt
```

and opens it inside the following directory:

```text
/app/files/
```

In the normal case:

```text
/app/files/report.txt
```

is produced.

But the user may send the following:

```text
../../secret.txt
```

As a result the built path may go outside the allowed directory.

This is called **path traversal**, a vulnerability of escaping out through the directory tree.

### Is `filepath.Clean` enough?

For example:

```go
clean := filepath.Clean(userPath)
```

normalizes the path.

For example:

```text
a/../b
```

may be brought to roughly the form:

```text
b
```

But `filepath.Clean` does not check whether the path is safe.

For example:

```text
../../secret.txt
```

may remain a path that goes outside the base directory even after cleaning.

That is why the trust boundary must be checked separately.

`filepath.Rel` or another explicit check against a trusted base directory can be used for this.

The conceptual requirement:

```text
user path
      |
      v
join with the base directory
      |
      v
normalization
      |
      v
is the final path inside the base directory?
      |
   +--+--+
   |     |
  yes    no
   |     |
 allow  reject
```

### Symbolic links matter too

Checking only the string form of a path is also not enough in some cases.

For example, inside the allowed directory:

```text
/app/files/link
```

may be a symbolic link leading to the outside directory:

```text
/etc/
```

Then from the outside the path:

```text
link/passwd
```

looks like it is inside the allowed directory, but the real file may be elsewhere.

That is why, when working with file names controlled by the user, path traversal and symbolic link issues are part of the security design.

This is especially important for:

* HTTP handlers;
* file upload or download endpoints;
* programs that extract archives;
* CLI utilities;
* file servers.

Directory paths and checking them safely are covered in detail in the next lesson.

## Common mistakes

### Continuing execution after an error

For example:

```go
file, err := os.Open("data.txt")
if err != nil {
	fmt.Println(err)
}

defer file.Close()
```

This code is dangerous.

If `os.Open` returns an error, `file` is usually not a usable `*os.File`.

Despite that, the code continues:

```go
defer file.Close()
```

This may later lead to a `panic`.

The correct approach:

```go
file, err := os.Open("data.txt")
if err != nil {
	fmt.Println(err)
	return
}
defer file.Close()
```

Or, if the function returns an `error`:

```go
file, err := os.Open("data.txt")
if err != nil {
	return fmt.Errorf("opening the file: %w", err)
}
defer file.Close()
```

The main rule is simple:

> If the following code depends on a successful result, do not continue execution after an error.

### Loading any file fully into memory

`os.ReadFile` is very convenient:

```go
data, err := os.ReadFile(path)
```

But it takes the whole file into memory.

If the file size is not controlled, memory usage may also get out of control.

For example, if:

```text
file size: 5 GiB
```

taking it into a single `[]byte` requires a lot of memory.

That is why for large or externally sourced files the following can be used:

* `bufio.Scanner`;
* `bufio.Reader`;
* `file.Read`;
* `io.Copy`;
* an explicit size limit.

Which method is chosen depends on the file format.

For example, `Scanner` is convenient for a line-by-line log. `io.Copy` may be better for copying a large binary stream from one place to another.

### Ignoring the number of bytes in the write result

`Write` returns two values:

```go
n, err := file.Write(data)
```

Here:

* `n` — how many bytes were written;
* `err` — the error.

In the ideal case:

```text
n == len(data)
err == nil
```

But if:

```text
n < len(data)
```

not all the data was written.

Even if `n < len(data)` and `err == nil`, this counts as a short write.

That is why the write result should not be carelessly thrown away.

For example, a check like:

```go
n, err := file.Write(data)
if err != nil {
	return err
}
if n != len(data) {
	return io.ErrShortWrite
}
```

may be required.

Helper functions like `io.WriteString` and `io.Copy` also return a result and an error. In important I/O code they must be checked.

### Relying too much on a separate existence check

The following sequence is common:

```text
1. does the file exist?
2. if it exists, use it.
```

But another process may change the situation between the first and second operations.

For example:

```text
Stat -> exists
        |
        | another process deletes the file
        v
Open -> error
```

Or:

```text
Stat -> exists
        |
        | the permissions change
        v
Open -> permission denied
```

This is called **TOCTOU** — a time-of-check to time-of-use race condition.

That is why checking in advance does not replace checking the error of the main operation.

For example, if you need to open a file, do:

```go
file, err := os.Open(path)
```

and handle exactly the error returned by `Open`.

## What is looked at in interviews?

Interview questions on files often check not just knowing the `os.Open` syntax, but understanding I/O semantics.

Important points:

* `os.ReadFile` takes the whole file into memory. Streaming reads make it possible to limit memory usage.
* `defer file.Close()` is convenient for reading. For important writes the `Close` error may need to be checked separately.
* The `O_CREATE`, `O_APPEND`, `O_TRUNC`, `O_RDONLY` and `O_WRONLY` flags determine the mode a file is opened in.
* `O_APPEND` keeps the existing data and directs writes to the end of the file.
* `O_TRUNC` truncates the contents of an existing file. If used wrongly, old data may be lost.
* The "file does not exist" case in `os.Stat` must be distinguished from permission or other I/O errors.
* `errors.Is(err, os.ErrNotExist)` also works with wrapped errors.
* The "check first, then use" approach does not remove the TOCTOU race condition.
* `bufio.Scanner` is convenient for line-by-line reading, but it has a token size limit.
* `*os.File` is tied to an operating system resource. Not closing files in time may lead to hitting the file descriptor limit.
* When updating an important file, an atomic replacement approach using a temporary file, `Sync`, `Close` and `Rename` can be used.
* Atomicity and durability are not the same concept. `Rename` may be atomic, but the guarantee of surviving a power failure depends on the file system and the operating system.
* For file paths that come from outside, path traversal and symbolic link risks must be taken into account.

In the next lesson we will learn how to create a directory, read its contents, walk a directory tree and build file paths safely.
