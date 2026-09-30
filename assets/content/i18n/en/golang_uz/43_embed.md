# Embedding files into a Go program: `embed`

The `embed` package makes it possible to place files and directories inside the Go program's executable — i.e. the binary — at compile time.

In the ordinary case, the HTML templates, SQL migrations, configuration or static files a program needs are stored separately on disk. While the program runs, it reads these files from disk.

When `embed` is used, these files are added into the binary at build time.

As a result you do not have to ship separate files along with the program.

For example, suppose a CLI program needs a help text. You could write it directly into the Go code as a long `string`, but this is inconvenient:

* editing the text gets harder;
* the code grows more than needed;
* the text and the program logic get mixed together.

Instead, the help text can be kept in a `help.txt` file. Then that file is embedded into the binary through `//go:embed`.

This way, editing the file separately stays convenient. And it is enough to give the user a single binary.

Go added the `embed` package to the standard library in Go 1.16. That is why Go 1.16 or newer is needed to use the code in this article.

## How does `go:embed` work?

`//go:embed` is not an ordinary comment. It is a special directive meant for the Go compiler.

For example:

```go
//go:embed hello.txt
var hello string
```

Here the compiler works as follows:

1. it sees the `//go:embed hello.txt` directive.
2. it reads the `hello.txt` file at build time.
3. it adds the file contents into the binary.
4. it gives the `hello` variable the file's contents as its initial value.

This process happens with `go build`, `go run` and other cases where the package is compiled.

The directive can give a value only to one of the following package-level types:

* `string` — for a single text file;
* `[]byte` — for a single text or binary file;
* `embed.FS` — for one or more files and directories.

There is an important difference here.

Embedded files are not read from disk at runtime. They are already placed inside the binary in advance.

For example, if you change the `hello.txt` file after the program was built, the text inside the old binary does not change.

To get the new file contents into the binary, the program must be rebuilt.

**Attention**

The directive must be written exactly as `//go:embed`.

The following is wrong:

```go
// go:embed hello.txt
```

There must be no space before `go:embed`.

The directive belongs to a single package-level variable declaration. It cannot be applied to a local variable inside `func main()` or another function.

## Embedding a single text file as a `string`

Let's start with the simplest case.

Let the following two files be in one directory:

```text
.
├── hello.txt
└── main.go
```

The contents of the `hello.txt` file:

```text
Hello, world!
```

Now we embed this file as a `string` inside `main.go`:

```go
package main

import (
	_ "embed"
	"fmt"
)

//go:embed hello.txt
var hello string

func main() {
	fmt.Print(hello)
}
```

We run the program in the directory where the files are:

```bash
go run .
```

Result:

```text
Hello, world!
```

In this code `hello` is declared at package level:

```go
var hello string
```

The directive before it:

```go
//go:embed hello.txt
```

tells the compiler that the contents of `hello.txt` must be placed into `hello`.

That is why code like the following is not executed at runtime:

```go
os.ReadFile("hello.txt")
```

Reading the file has already been done at build time.

### Why is `_ "embed"` imported?

The code does not use the `embed.FS` type directly.

Despite that, a Go file that uses the `//go:embed` directive must import the `embed` package.

That is why the blank import:

```go
_ "embed"
```

is used.

A blank import makes it possible to import a package without using the package name in the code.

If `embed.FS` is used, the blank import is not needed:

```go
import "embed"
```

is imported in the ordinary way.

### Why is `fmt.Print()` used?

The code uses:

```go
fmt.Print(hello)
```

The reason is that the `hello.txt` file may have a newline character at the end.

If:

```go
fmt.Println(hello)
```

is used, `Println()` adds a newline itself too.

As a result the line breaks twice, and an extra empty line may appear.

`embed` does not change the bytes in the file. The file is taken into the `string` exactly as it is.

## Embedding a binary file as `[]byte`

Not every file is text.

For example:

* a PNG or JPEG image;
* a certificate;
* a PDF;
* audio;
* other binary formats

are stored as sequences of bytes.

It is convenient to embed such a file into the `[]byte` type:

```go
package main

import (
	_ "embed"
	"fmt"
)

//go:embed logo.png
var logo []byte

func main() {
	fmt.Printf("Image size: %d bytes\n", len(logo))
}
```

There must be a `logo.png` in the same directory as this program.

For example, if the file size is `4821` bytes, the result is as follows:

```text
Image size: 4821 bytes
```

The `logo` variable does not store the file path.

That is, it does not contain the name:

```text
logo.png
```

It stores the bytes of the `logo.png` file itself.

That is why these bytes can later be:

* written to an HTTP response;
* used to compute a hash;
* passed to a parser;
* used to detect the format;
* given to another function.

For example, `len(logo)` returns the number of bytes in the file.

### `[]byte` is mutable

A `string` is immutable, i.e. you cannot directly change an individual byte inside it.

A `[]byte`, on the other hand, is a slice, so its elements can be changed:

```go
logo[0] = 0
```

But this change affects only the `logo` slice inside the current process.

It:

* does not change the `logo.png` file on disk;
* does not rewrite the binary file itself;
* does not permanently change the embedded data for the next run.

If the program is restarted, the embedded data is again taken from its initial state inside the binary.

> **Info**
>
> For `string` and `[]byte`, the pattern in the `//go:embed` directive must match exactly one file.
>
> If several files or a directory are needed, `embed.FS` is used.

## `embed.FS` for several files

Several files cannot be put into a single `string` or `[]byte`.

In such a case `embed.FS` is used.

`embed.FS` is a virtual file system meant for reading only.

The files inside it can be accessed through paths similar to files on disk.

Take the following structure:

```text
.
├── main.go
└── texts
    ├── file1.txt
    ├── file2.txt
    └── notes
        └── file3.txt
```

Let the file contents be as follows:

```text
texts/file1.txt -> First file
texts/file2.txt -> Second file
texts/notes/file3.txt -> Third file
```

Now we embed the whole `texts` directory:

```go
package main

import (
	"embed"
	"fmt"
	"io/fs"
	"log"
)

//go:embed texts
var textFiles embed.FS

func main() {
	err := fs.WalkDir(textFiles, "texts", func(path string, entry fs.DirEntry, walkErr error) error {
		if walkErr != nil {
			return walkErr
		}
		if entry.IsDir() {
			return nil
		}

		data, err := textFiles.ReadFile(path)
		if err != nil {
			return err
		}
		fmt.Printf("%s: %s\n", path, data)
		return nil
	})
	if err != nil {
		log.Fatal(err)
	}
}
```

Result:

```text
texts/file1.txt: First file
texts/file2.txt: Second file
texts/notes/file3.txt: Third file
```

In this example:

```go
//go:embed texts
var textFiles embed.FS
```

adds the whole `texts` directory to the embedded file system.

Both the regular files inside the directory and the subdirectories are taken into account.

### What does `fs.WalkDir()` do?

The following line:

```go
fs.WalkDir(textFiles, "texts", ...)
```

walks the tree in the `textFiles` file system starting from the `texts` directory.

`WalkDir()` calls the callback function for every file and directory:

```go
func(path string, entry fs.DirEntry, walkErr error) error
```

What these parameters do:

* `path` — the path of the current file or directory;
* `entry` — information about the current object;
* `walkErr` — an error that occurred during the walk.

First, through:

```go
if walkErr != nil {
	return walkErr
}
```

the error passed by `WalkDir()` is checked.

This is important. Because if some files cannot be accessed or another problem occurs, ignoring the error would hide the problem.

Then, through:

```go
if entry.IsDir() {
	return nil
}
```

directories are not read.

The goal here is to print only the contents of the files.

If the current element is a file:

```go
data, err := textFiles.ReadFile(path)
```

its contents are read.

`ReadFile()` returns `[]byte`.

Then:

```go
fmt.Printf("%s: %s\n", path, data)
```

prints the file path and its contents.

### In what order are the files walked?

`fs.WalkDir()` walks the names inside a directory in sorted order.

That is why the result usually appears in name order.

### `embed.FS` and `io/fs`

`embed.FS` implements the `io/fs.FS` interface.

This is a very useful property.

Because many packages in the standard library can work with `io/fs.FS`.

For example:

* `fs.WalkDir`;
* `fs.ReadFile`;
* `fs.ReadDir`;
* `html/template`;
* `text/template`;
* `net/http`.

So you do not have to learn a separate special API to work with embedded files. In many cases the functions of the ordinary `io/fs` ecosystem are enough.

## Rules for writing patterns

The value written after the `//go:embed` directive is called a pattern.

For example:

```go
//go:embed templates/*.html
```

here:

```text
templates/*.html
```

is the pattern.

It is very important to understand where the pattern is resolved from.

It is resolved not relative to the module root, but relative to the package directory that the Go file containing the directive belongs to.

For example:

```text
project/
├── go.mod
└── cmd
    └── app
        ├── main.go
        └── templates
            └── index.html
```

If `main.go` contains:

```go
//go:embed templates/*.html
```

the pattern works relative to the `cmd/app` directory.

Even on Windows, `/` is used as the path separator when writing patterns.

For example:

```go
//go:embed templates/*.html static/css/*.css
var content embed.FS
```

Here there are two patterns in one directive:

```text
templates/*.html
static/css/*.css
```

The files found by both patterns are placed into `content`.

The same thing can also be written with two directives:

```go
//go:embed templates/*.html
//go:embed static/css/*.css
var content embed.FS
```

Both variants mean the same thing.

### Important pattern rules

Although `go:embed` patterns look like ordinary file system paths, they have some restrictions.

#### You cannot go outside the package

The following are not allowed:

```text
/static
../static
C:/static
```

The reason is that embedded files must not go outside the scope of the current package.

In particular, moving to a parent directory through:

```text
../
```

is not allowed.

#### `.` is not used as a pattern

For the current directory you cannot write:

```go
//go:embed .
```

Instead, a pattern matching the needed files is used.

For example:

```go
//go:embed *
```

But `*` does not in all cases mean taking the full recursive contents of a directory. Directory embedding rules work separately.

#### Every pattern must match at least one object

For example, if you write:

```go
//go:embed templates/*.html
```

at least one `.html` file must exist at build time.

If nothing is found, the build stops with an error.

This is a good property. Because it does not produce a binary that works in a situation where a needed resource has accidentally gone missing.

#### Some directories and files are not embedded

Referring to the following through a pattern is restricted:

* symbolic links;
* `.git`;
* `vendor`;
* directories of other modules that contain their own `go.mod`.

These restrictions help keep the build context clear and controlled.

#### If a file name contains a space

The pattern can be written in double quotes:

```go
//go:embed "docs/user guide.txt"
var guide string
```

Here the double quotes are not part of the pattern. They are used to express correctly that there is a space inside.

### The difference between a directory name and `*`

There is a subtle difference here that beginners often get confused by.

The following directive:

```go
//go:embed assets
var assets embed.FS
```

embeds the `assets` directory recursively.

But it usually skips files and directories whose names start with `.` or `_`.

For example:

```text
assets/
├── main.css
├── .hidden
└── _internal
```

with the plain:

```go
//go:embed assets
```

`.hidden` and `_internal` may not be included.

If such files are needed too, the `all:` prefix is used:

```go
//go:embed all:assets
var assets embed.FS
```

`all:` means that hidden objects and objects starting with an underscore are also taken into account.

Now let's see the difference with:

```go
//go:embed assets/*
```

`assets/*` matches the first-level objects inside `assets` as a pattern.

That is why it may also match a hidden file at the first level.

But when recursing into a subdirectory, hidden files in that directory are again subject to the special rules.

That is why if the whole directory is needed:

```go
//go:embed assets
```

is usually the clearer form.

If hidden files are needed fully too, using:

```go
//go:embed all:assets
```

is clearer.

## A practical example with an HTML template

In backend programs it is very convenient to embed HTML templates into the binary.

Otherwise, during deployment:

* the binary;
* the `templates` directory;
* all the needed `.html` files

have to be shipped together.

When `embed` is used, the templates are inside the binary.

Let the following structure exist:

```text
.
├── main.go
└── templates
    └── welcome.html
```

The template:

```html
<h1>Hello, {{.Name}}!</h1>
```

Now the Go program:

```go
package main

import (
	"embed"
	"html/template"
	"log"
	"os"
)

//go:embed templates/*.html
var templateFiles embed.FS

type PageData struct {
	Name string
}

func main() {
	tmpl, err := template.ParseFS(templateFiles, "templates/*.html")
	if err != nil {
		log.Fatal(err)
	}

	err = tmpl.ExecuteTemplate(os.Stdout, "welcome.html", PageData{Name: "Aziza"})
	if err != nil {
		log.Fatal(err)
	}
}
```

Result:

```text
<h1>Hello, Aziza!</h1>
```

Here first, through:

```go
//go:embed templates/*.html
var templateFiles embed.FS
```

all `.html` templates were placed into the embedded file system.

Then:

```go
tmpl, err := template.ParseFS(templateFiles, "templates/*.html")
```

was called.

`template.ParseFS()` reads the templates not from disk, but from the embedded file system inside `templateFiles`.

This is one of the main differences from `template.ParseFiles()`.

### How does `ExecuteTemplate()` work?

The following code:

```go
tmpl.ExecuteTemplate(
	os.Stdout,
	"welcome.html",
	PageData{Name: "Aziza"},
)
```

executes the `welcome.html` template.

The template has:

```html
{{.Name}}
```

And `PageData` is passed with the value:

```go
PageData{Name: "Aziza"}
```

That is why in place of:

```html
{{.Name}}
```

the following is written:

```text
Aziza
```

The result is:

```html
<h1>Hello, Aziza!</h1>
```

`html/template` also performs escaping suited to the HTML context. This is safer for building web pages than the plain `text/template`.

### Why are errors checked?

If the template syntax is wrong:

```go
template.ParseFS(...)
```

returns an error.

For example, if the template has an unclosed template expression, the program cannot parse it.

That is why the check:

```go
if err != nil {
	log.Fatal(err)
}
```

is needed.

`ExecuteTemplate()` may also return an error.

For example:

* a wrong template name;
* an error while writing;
* another problem during execution

may occur.

In a real HTTP server, instead of:

```go
os.Stdout
```

usually an `http.ResponseWriter` is given.

For example:

```go
func handler(w http.ResponseWriter, r *http.Request) {
	err := tmpl.ExecuteTemplate(w, "welcome.html", PageData{
		Name: "Aziza",
	})
	if err != nil {
		http.Error(w, "template error", http.StatusInternalServerError)
	}
}
```

Here the generated HTML is written directly to the HTTP response.

### Serving static files over HTTP

When working with static files, it may be convenient to strip the top directory prefix in the embedded file system.

For example:

```go
staticFS, err := fs.Sub(templateFiles, "static")
if err != nil {
	return err
}

handler := http.FileServer(http.FS(staticFS))
```

This snippet is not a separate complete program.

Here:

```go
fs.Sub(templateFiles, "static")
```

returns a file system that shows the `static` directory inside `templateFiles` as the new root.

For example, if the original embedded path is:

```text
static/css/main.css
```

in the file system after `fs.Sub()` it appears as:

```text
css/main.css
```

Then:

```go
http.FS(staticFS)
```

wraps the `io/fs.FS` interface into an adapter that `net/http` understands.

Then:

```go
http.FileServer(...)
```

can serve these files over HTTP.

In practical code, an `embed.FS` in which the `static` directory has actually been embedded should be used in place of `templateFiles`.

For example:

```go
//go:embed static
var staticFiles embed.FS
```

and then writing:

```go
staticFS, err := fs.Sub(staticFiles, "static")
```

is clearer.

## `embed.FS` is read-only

`embed.FS` is a read-only file system, i.e. meant only for reading.

It has the following methods:

```go
Open
ReadFile
ReadDir
```

But there are no methods for the following operations:

```text
WriteFile
Create
Remove
Rename
```

The reason is that embedded data is placed into the binary contents at build time.

At runtime it cannot be permanently changed like in an ordinary file system.

For example, an initial configuration can be embedded into the binary:

```text
default-config.yaml
```

When the program runs for the first time, it can use this configuration as default values.

But if the user later changes the configuration, it cannot be written back into the `embed.FS`.

Such mutable data must be stored in:

* a disk;
* a database;
* object storage;
* another external storage system.

In the same way, `embed` is very convenient for SQL migrations.

Migration files usually come with the application version and are not changed at runtime.

But user-uploaded files, like:

```text
uploads/
```

cannot be added into an `embed.FS`.

Because `embed.FS` is not runtime file storage.

## Common mistakes

### Not importing the `embed` package

A file that uses `//go:embed` must import the `embed` package.

The following code is wrong:

```go
// Wrong: "embed" is not imported in this file.
//go:embed message.txt
var message string
```

At build time an error roughly like the following is obtained:

```text
go:embed requires import "embed"
```

If the embedded value is a `string` or `[]byte`:

```go
import _ "embed"
```

can be used.

For example:

```go
import (
	_ "embed"
	"fmt"
)
```

If `embed.FS` is used, the package name is needed in the code:

```go
import "embed"

//go:embed files
var files embed.FS
```

That is why in this case an ordinary import is used, not a blank import.

### Separating the directive from the variable

`//go:embed` belongs to one specific variable declaration.

The following code is wrong:

```go
// A wrong example.
//go:embed message.txt
const defaultName = "Go"

var message string
```

Here the declaration after the directive has become:

```go
const defaultName = "Go"
```

And `go:embed` should have belonged to the `message` variable.

That is why writing the directive directly above the variable is the clearest way:

```go
//go:embed message.txt
var message string
```

An empty line or some comments may be allowed grammatically, but they make the code confusing.

In practical code it is a good habit to write the directive and the variable close to each other.

### Expecting an external file to update at runtime

This is one of the most important concepts when working with `embed`.

Suppose a program embedded the following template:

```text
templates/welcome.html
```

Then the binary was built:

```bash
go build -o app
```

After that, the file on disk:

```text
templates/welcome.html
```

was changed.

The old:

```text
app
```

binary does not see this change.

The reason is that the template is not read from disk at runtime. It is already inside the binary.

To use the new template:

```bash
go build -o app
```

must be run again.

This can be useful in production.

Because the deployed binary and its resources stay consistent with each other.

But if the template must be changed while the program is running, `embed` may not fit.

In such a case you need to:

* read the file from disk;
* use external storage;
* or rebuild and redeploy after the change.

### Ignoring errors

Even if the embedded file exists at build time, a wrong path can be written in runtime code.

For example, if the embedded file is:

```text
texts/file1.txt
```

then:

```go
data, err := textFiles.ReadFile("texts/file1.txt")
```

is correct.

But:

```go
data, err := textFiles.ReadFile("file1.txt")
```

may be wrong.

The reason is that inside `embed.FS` the path is stored exactly according to the embedded structure.

That is why the errors returned by:

* `ReadFile`;
* `ReadDir`;
* `ParseFS`;
* `fs.Sub`;
* `Open`

must be checked.

For example:

```go
data, err := textFiles.ReadFile("texts/file1.txt")
if err != nil {
	return err
}
```

Ignoring the error makes it harder to find a wrong path or wrong pattern problem.

## Size, memory and security

Embedded files increase the binary size.

For example, if the binary is initially:

```text
8 MB
```

and:

```text
20 MB
```

of static assets are added to it, the final binary also grows noticeably.

For a few small:

* HTML templates;
* SQL migrations;
* CLI help texts;
* small CSS;
* small JavaScript;
* default configuration

this is usually not a problem.

But for hundreds of megabytes of:

* video;
* large archives;
* large datasets;
* frequently updated content

`embed` may not be a good choice.

A large binary:

* may take longer to build;
* transfers more data over the network;
* increases the container image size;
* takes more space in artifact storage.

Such content is often better stored in external storage.

### An embedded file is not secret

This is a very important security rule.

`embed` places data inside the binary, but does not encrypt it.

That is why embedding the following into a binary is not considered safe:

* an API key;
* a password;
* a private key;
* an access token;
* a database credential.

A user who can access the binary file can extract the data inside it with various tools.

That is why for secret values you should use:

* environment variables;
* a secret manager;
* orchestrator secrets;
* dedicated credential storage.

`embed` is a packaging tool. It is not a secret protection tool.

### Reproducibility of the build result

`embed` helps keep a program and its static resources as a single artifact.

For example:

```text
app binary
+ templates
+ migrations
+ static files
```

are not deployed separately.

All of them are inside a single binary.

This simplifies the deployment process and reduces mismatches such as "the binary is new, the template is old".

If an embedded file changes, the Go build system takes the change into account.

The corresponding package is rebuilt and a new binary is created.

That is why an embedded resource is also treated as part of the source dependencies.

## Important points for interviews

* `//go:embed` gives an initial value only to a package-level `string`, `[]byte` or `embed.FS` variable.
* `string` and `[]byte` work with a single pattern matching one file.
* `embed.FS` can work with several files, directories and patterns.
* A pattern is resolved not relative to the module root, but relative to the package directory that the Go file containing the directive belongs to.
* `embed.FS` implements the `io/fs.FS` interface.
* That is why it can be used with standard APIs like `fs.WalkDir`, `template.ParseFS` and `http.FS`.
* `embed.FS` is meant for reading only.
* Embedded files are not taken from disk at runtime.
* If the original file on disk changes, the copy inside the old binary does not change.
* For an embedded resource to update, the program must be rebuilt.
* `embed` increases the binary size.
* `embed` does not protect secret data.
* `embed` is very convenient for small, static resources.
* For large content that changes at runtime, external storage fits better.
