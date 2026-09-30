# Working with directories in Go

A directory is a file system object that groups and stores files and other directories. In Go programs, directories are often used to keep configuration files, logs, caches, user-uploaded files and temporary data in order.

But working with directories is not only about creating a new folder. A real program must take several important situations into account:

* file paths do not look the same on Linux, macOS and Windows;
* directory and file permissions differ depending on the operating system;
* a symbolic link behaves differently from an ordinary directory or file;
* a path that comes from outside may be dangerous;
* if recursive deletion is called with a wrong path, a lot of data can be lost.

In the Go standard library, mainly the `os` and `path/filepath` packages are used to work with directories.

The `os` package performs file system operations such as creating, reading, deleting and renaming directories. `path/filepath` helps build and analyze file paths suited to the local operating system.

## How is a file path structured?

A file path, i.e. a **path**, denotes the address of a file or directory in the file system.

A path can be of two kinds:

* an **absolute path**;
* a **relative path**.

An absolute path denotes an exact place in the file system.

On Unix-family systems it usually starts from the `/` root:

```text
/home/user/project/data.json
```

On Windows it may start, for example, with a drive letter:

```text
C:\Users\user\project\data.json
```

A relative path, on the other hand, is resolved relative to the current working directory:

```text
data/reports/daily.json
```

There is an important difference here. **The current working directory does not mean the directory where the executable is located.**

For example, the executable may be located in `/usr/local/bin/app`. But if you run it from the `/home/user/project` directory, relative paths are usually resolved relative to `/home/user/project`.

The current working directory can be obtained through `os.Getwd()`.

Joining path parts by hand with `"/"` or `"\\"` separators is not recommended. Instead, `filepath.Join` is used. It picks the separator suited to the current operating system and also cleans up redundant separators.

```go
package main

import (
	"fmt"
	"os"
	"path/filepath"
)

func main() {
	path := filepath.Join("data", "reports", "daily.json")
	absPath, err := filepath.Abs(path)
	if err != nil {
		fmt.Println("getting the absolute path:", err)
		return
	}

	fmt.Println("file name:", filepath.Base(path))
	fmt.Println("directory:", filepath.Dir(path))
	fmt.Println("extension:", filepath.Ext(path))
	fmt.Println("absolute path:", absPath)
	fmt.Println("is absolute:", filepath.IsAbs(absPath))
	fmt.Println("separator:", string(os.PathSeparator))
}
```

Now let's look at the functions in the code one by one.

```go
path := filepath.Join("data", "reports", "daily.json")
```

`filepath.Join` joins the given path parts in a form suited to the operating system.

On a Unix system the result is roughly:

```text
data/reports/daily.json
```

On Windows it may look like:

```text
data\reports\daily.json
```

The next line:

```go
absPath, err := filepath.Abs(path)
```

turns a relative path into an absolute path.

For example, if the program was run inside `/home/farrux/project`:

```text
data/reports/daily.json
```

may turn into an absolute path like:

```text
/home/farrux/project/data/reports/daily.json
```

`filepath.Base(path)` returns the last part of the path:

```text
daily.json
```

`filepath.Dir(path)` returns its parent directory:

```text
data/reports
```

`filepath.Ext(path)` returns the last file extension:

```text
.json
```

`filepath.IsAbs(absPath)` checks whether the path is absolute or relative.

And `os.PathSeparator` gives the directory separator used by the current operating system.

The exact values of the absolute path and the separator depend on which operating system and which directory you run the program from. That is why the full output of this example is not the same on all platforms.

> **Info**
>
> `path/filepath` is used for local file system paths.
>
> Paths inside URLs follow different rules. In URL paths the separator is always `/`. For them the `path` or `net/url` package should be used.
>
> For example, treating a Windows file path as a URL or building a URL path with `filepath.Join` may lead to a wrong result.

## Creating a single directory

`os.Mkdir` is used to create a single directory.

An important rule: `os.Mkdir` creates only the given directory itself. Its parent directory must already exist.

For example:

```go
package main

import (
	"errors"
	"fmt"
	"os"
)

func main() {
	err := os.Mkdir("mydir", 0o755)
	switch {
	case err == nil:
		fmt.Println("the directory was created")
	case errors.Is(err, os.ErrExist):
		fmt.Println("the directory already exists")
	default:
		fmt.Println("the directory was not created:", err)
	}
}
```

This code tries to create a new directory named `mydir` inside the current working directory.

```go
os.Mkdir("mydir", 0o755)
```

Here:

* `"mydir"` — the path of the directory to create;
* `0o755` — the permission bits.

`0o755` is a permission value written in the octal number system.

On Unix-family systems it is usually interpreted as:

```text
owner:   rwx
group:   r-x
others:  r-x
```

For a directory, `x`, the execute bit, does not mean running a file.

The `x` bit on a directory allows accessing the names inside it. For example, `x` permission is needed to access a file inside the directory or to enter a subdirectory.

The `r` bit, on the other hand, helps read the list of names inside the directory.

That is why understanding directory permissions in exactly the same sense as file permissions is wrong.

Another important point: `0o755` does not always guarantee that the directory is created with exactly `755` permissions. On Unix systems the process's `umask` value may affect the final permission.

The permission model on Windows differs from Unix. That is why Unix permission bits may not work in exactly the same sense there.

The check in the code:

```go
errors.Is(err, os.ErrExist)
```

detects that the path already exists.

But from this check you cannot conclude:

> "so there is a directory at this path"

For example, even if an ordinary file named `mydir` exists, `os.Mkdir` returns an error and it may match `os.ErrExist`.

If it matters that the existing object is exactly a directory, it must be checked separately through `os.Stat` and `IsDir()`.

## Creating nested directories

To create several nested directories, `os.MkdirAll` is more convenient.

For example, we want to create the following path:

```text
cache/images/thumbnails
```

If `cache` and `images` do not exist yet, with a plain `os.Mkdir` you would have to create every step separately.

`os.MkdirAll` creates the missing parent directories by itself too.

```go
package main

import (
	"fmt"
	"os"
	"path/filepath"
)

func main() {
	dir := filepath.Join(os.TempDir(), "go-dirs-lesson", "cache", "images")
	if err := os.MkdirAll(dir, 0o755); err != nil {
		fmt.Println("creating the directories:", err)
		return
	}
	defer os.RemoveAll(filepath.Join(os.TempDir(), "go-dirs-lesson"))

	fmt.Println("last directory:", filepath.Base(dir))
}
```

Result:

```text
last directory: images
```

First:

```go
os.TempDir()
```

gives the operating system's standard temporary directory.

Then:

```go
filepath.Join(
	os.TempDir(),
	"go-dirs-lesson",
	"cache",
	"images",
)
```

joins the path parts.

As a result a path roughly like the following may be produced:

```text
/tmp/go-dirs-lesson/cache/images
```

On Windows another temporary directory may be used.

The next line:

```go
os.MkdirAll(dir, 0o755)
```

creates all directories in the path that do not exist.

For example, if the directories:

```text
go-dirs-lesson
go-dirs-lesson/cache
go-dirs-lesson/cache/images
```

do not exist, all three are created.

`MkdirAll` has another convenient property: if the directories already exist, it does not return an error just for that reason.

That is why calling code like the following several times usually causes no problems:

```go
os.MkdirAll(dir, 0o755)
```

When repeating the same operation does not break the result, the property is called **idempotent**.

The line in the example:

```go
defer os.RemoveAll(filepath.Join(os.TempDir(), "go-dirs-lesson"))
```

deletes the directory tree created for the example when the program is finishing.

This is convenient in a test or a teaching example.

But such code must not be used blindly for persistent data in a real program. `os.RemoveAll` may delete a whole directory tree.

## Reading directory contents

`os.ReadDir` is used to get the list of files and subdirectories inside a directory.

`os.ReadDir` returns only the entries **directly inside** the given directory. It does not automatically go into subdirectories.

For example:

```text
root/
├── config.json
└── images/
    └── logo.png
```

If `os.ReadDir(root)` is called:

```text
config.json
images
```

are returned.

But `images/logo.png` is not returned automatically.

```go
package main

import (
	"fmt"
	"os"
	"path/filepath"
)

func main() {
	root, err := os.MkdirTemp("", "read-dir-*")
	if err != nil {
		fmt.Println("creating a temporary directory:", err)
		return
	}
	defer os.RemoveAll(root)

	if err := os.Mkdir(filepath.Join(root, "images"), 0o755); err != nil {
		fmt.Println("creating a subdirectory:", err)
		return
	}
	if err := os.WriteFile(filepath.Join(root, "config.json"), []byte("{}\n"), 0o644); err != nil {
		fmt.Println("creating a file:", err)
		return
	}

	entries, err := os.ReadDir(root)
	if err != nil {
		fmt.Println("reading the directory:", err)
		return
	}

	for _, entry := range entries {
		kind := "FILE"
		if entry.IsDir() {
			kind = "DIR"
		}
		fmt.Printf("[%s] %s\n", kind, entry.Name())
	}
}
```

Result:

```text
[FILE] config.json
[DIR] images
```

The first part:

```go
root, err := os.MkdirTemp("", "read-dir-*")
```

creates a temporary directory.

Then inside it the directory:

```go
images
```

and the file:

```text
config.json
```

are created.

After that:

```go
entries, err := os.ReadDir(root)
```

reads the entries inside the directory.

`os.ReadDir` returns the result sorted by name.

Each element is an `os.DirEntry` value.

Through a `DirEntry`, for example:

```go
entry.Name()
```

you can get the entry's name.

```go
entry.IsDir()
```

determines whether it is a directory or not.

`os.DirEntry` deliberately gives relatively lightweight information. If the file size, modification time or other full metadata is needed:

```go
info, err := entry.Info()
```

can be called.

But `Info()` may perform an extra file system operation and may also return an error. That is why it is useful to call it only when needed.

There is another important point.

`os.ReadDir` takes all entries in the directory into memory as a slice.

For ordinary directories this is not a problem. But if a directory has millions of entries, taking all of them into memory at once may be expensive.

In such a case the directory can be opened with:

```go
file, err := os.Open(path)
```

and then read in parts with:

```go
file.ReadDir(n)
```

For example, reading 1000 entries at a time helps limit memory usage.

When a directory is opened with `os.Open`, an `*os.File` is returned. It must be closed after use:

```go
defer file.Close()
```

## Walking a directory tree

Sometimes you need to see not just one directory level, but all directories and files inside it.

`filepath.WalkDir` is used for this.

For example, suppose there is the following tree:

```text
root/
└── docs/
    └── readme.txt
```

`WalkDir` may walk the paths:

1. `root`;
2. `root/docs`;
3. `root/docs/readme.txt`.

```go
package main

import (
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
)

func main() {
	root, err := os.MkdirTemp("", "walk-dir-*")
	if err != nil {
		fmt.Println("creating a temporary directory:", err)
		return
	}
	defer os.RemoveAll(root)

	docs := filepath.Join(root, "docs")
	if err := os.Mkdir(docs, 0o755); err != nil {
		fmt.Println("creating a directory:", err)
		return
	}
	if err := os.WriteFile(filepath.Join(docs, "readme.txt"), []byte("Hello\n"), 0o644); err != nil {
		fmt.Println("creating a file:", err)
		return
	}

	err = filepath.WalkDir(root, func(path string, entry fs.DirEntry, walkErr error) error {
		if walkErr != nil {
			return walkErr
		}

		rel, err := filepath.Rel(root, path)
		if err != nil {
			return err
		}
		kind := "FILE"
		if entry.IsDir() {
			kind = "DIR"
		}
		fmt.Printf("[%s] %s\n", kind, rel)
		return nil
	})
	if err != nil {
		fmt.Println("walking the directory:", err)
	}
}
```

On a Unix system the result looks roughly like this:

```text
[DIR] .
[DIR] docs
[FILE] docs/readme.txt
```

On Windows the last path may come out as:

```text
docs\readme.txt
```

A callback function is given to `WalkDir`:

```go
func(path string, entry fs.DirEntry, walkErr error) error
```

This callback is called for every entry found.

`path` is the path of the current entry.

`entry` is an `fs.DirEntry` about the current file or directory.

`walkErr` denotes the error that occurred while visiting exactly this path.

Here it is important to check `walkErr` first:

```go
if walkErr != nil {
	return walkErr
}
```

The reason is that when there is an error, using `entry` may not be safe. Calling `entry` methods without the check may cause a panic in some situations.

Then:

```go
rel, err := filepath.Rel(root, path)
```

produces a shorter path relative to `root` instead of the absolute or long temporary path.

For example, instead of:

```text
/tmp/walk-dir-123456/docs/readme.txt
```

it prints:

```text
docs/readme.txt
```

`filepath.WalkDir` can usually be more efficient than the older `filepath.Walk`. The reason is that the callback is given an `os.DirEntry` rather than an `os.FileInfo`. Because of that, an extra `os.Lstat` call may not be needed for some files.

### Skipping a directory

Sometimes while walking a tree you do not want to go into certain directories at all.

For example, directories like:

```text
.git
node_modules
cache
```

may need to be skipped.

If a directory's callback returns:

```go
return filepath.SkipDir
```

`WalkDir` does not go inside that directory.

To skip a single ordinary file, usually no special signal is needed. The callback returns `nil` and moves on to the next entry.

`fs.SkipAll` has a different meaning: it is used to stop the whole walk. That is why using `fs.SkipAll` to skip a single file is wrong.

Another subtle case: `WalkDir` usually does not automatically follow a symbolic link into the directory it points to.

For example, if:

```text
root/link -> /other/data
```

`link` may appear as an entry. But the whole tree inside `/other/data` is not walked automatically.

This behavior reduces the risk of an unexpected loop or escaping into another directory tree because of a symbolic link.

## Relative and absolute paths

The `path/filepath` package has several important functions for computing paths.

`filepath.Abs` brings a relative path to absolute form relative to the current working directory.

For example, for:

```text
data/config.json
```

if the current working directory is:

```text
/home/user/app
```

the result may be roughly:

```text
/home/user/app/data/config.json
```

`filepath.Rel(base, target)` computes the relative path to get from `base` to `target`.

For example, for:

```text
base:   /home/user/app
target: /home/user/app/data/config.json
```

the result may be:

```text
data/config.json
```

The important point: `filepath.Abs` and `filepath.Rel` mainly compute the path **logically**. By themselves they do not check whether the file or directory exists in the real file system.

### `filepath.Clean`

`filepath.Clean` normalizes path syntax.

For example:

```text
data/./reports/../config.json
```

may be simplified to:

```text
data/config.json
```

It:

* removes `.` parts;
* resolves `..` parts as far as possible;
* cleans up redundant separators.

But there is a very important security rule here:

> `filepath.Clean` is not a security check.

For example:

```go
filepath.Clean("uploads/../../config")
```

normalizes the path, but it does not forbid it from going outside the `uploads` directory.

So `Clean` performs the task:

> "tidy up the path syntax"

It does not enforce the security policy:

> "the user must stay only inside this directory"

### Checking that a path stays inside a base directory

A file name that came over HTTP, a URL parameter or a CLI argument may be untrusted.

For example, the user may send the path:

```text
../../config.json
```

If the program blindly joins it with:

```go
filepath.Join("uploads", name)
```

and then opens the file, the user may try to escape to files outside the allowed `uploads` directory.

This leads to a vulnerability called **path traversal**.

In the following example we check that the path stays inside the base directory:

```go
package main

import (
	"fmt"
	"path/filepath"
	"strings"
)

func safeJoin(base, name string) (string, error) {
	if filepath.IsAbs(name) {
		return "", fmt.Errorf("absolute paths are not allowed")
	}

	baseAbs, err := filepath.Abs(base)
	if err != nil {
		return "", fmt.Errorf("base path: %w", err)
	}
	target := filepath.Join(baseAbs, name)
	rel, err := filepath.Rel(baseAbs, target)
	if err != nil {
		return "", fmt.Errorf("relative path: %w", err)
	}
	if rel == ".." || strings.HasPrefix(rel, ".."+string(filepath.Separator)) {
		return "", fmt.Errorf("the path escaped the base directory")
	}
	return target, nil
}

func main() {
	for _, name := range []string{"images/logo.png", "../../config.json"} {
		path, err := safeJoin("uploads", name)
		if err != nil {
			fmt.Printf("%s: rejected\n", name)
			continue
		}
		fmt.Printf("%s: allowed (%s)\n", name, filepath.Base(path))
	}
}
```

Result:

```text
images/logo.png: allowed (logo.png)
../../config.json: rejected
```

Now let's look at the check step by step.

First:

```go
if filepath.IsAbs(name) {
	return "", fmt.Errorf("absolute paths are not allowed")
}
```

checks that the user did not send an absolute path directly.

For example, a path like:

```text
/etc/passwd
```

may be rejected immediately.

Then:

```go
baseAbs, err := filepath.Abs(base)
```

gets the absolute path of the base directory.

For example:

```text
uploads
```

may turn into:

```text
/home/app/uploads
```

Then:

```go
target := filepath.Join(baseAbs, name)
```

joins the name the user sent with the base path.

Then:

```go
rel, err := filepath.Rel(baseAbs, target)
```

computes the relative path from `baseAbs` to `target`.

In the normal case:

```text
images/logo.png
```

is produced.

But for a path that escapes outside, a value like:

```text
../../config.json
```

or something similar starting with `..` may be produced.

That is why the check:

```go
if rel == ".." || strings.HasPrefix(rel, ".."+string(filepath.Separator))
```

detects that the path goes up into a parent directory.

Here using a plain check like:

```go
strings.HasPrefix(target, base)
```

is not enough.

For example, if:

```text
base   = /data/app
target = /data/app-old/file.txt
```

`target` as a string starts with `/data/app`.

But `/data/app-old` is not inside the `/data/app` directory.

So in file system paths a plain string prefix does not correctly express a directory boundary.

> **Attention**
>
> The `safeJoin` above performs a lexical check, i.e. one based on the path text. It does not fully stop escaping outside the base directory through a symbolic link.
>
> For example, if the user can create a symbolic link inside `uploads` that points to an outside directory, the path may still look like it is inside `uploads` as text.
>
> If such a risk exists, you may need to check symbolic links with `os.Lstat`, determine the real path through `filepath.EvalSymlinks`, or use the operating system's safer APIs that work relative to a directory descriptor.
>
> Another problem is the time between the check and actually opening the file. If an outside process changes the file system in the meantime, a race condition may occur. This can lead to problems of the **TOCTOU** type, i.e. "time-of-check to time-of-use".

## Renaming and moving a directory

To rename a file or directory:

```go
os.Rename(oldPath, newPath)
```

is used.

For example:

```go
err := os.Rename("reports", "archive")
```

tries to rename the `reports` directory to `archive`.

`os.Rename` is used not only for renaming, but in some cases also for moving an object to another directory.

For example:

```go
os.Rename(
	"uploads/file.txt",
	"archive/file.txt",
)
```

may move a file to another directory within the same file system.

A `Rename` within one file system usually works fast. The reason is that often the whole file or directory contents do not have to be copied again. The metadata in the file system is changed.

But between different disks or different mount points the situation is different.

For example, when moving from:

```text
/mnt/disk1/data
```

to:

```text
/mnt/disk2/data
```

`os.Rename` may return an error.

In such a case the following process is usually needed:

1. copy the source contents to the new place;
2. keep the needed permissions and other metadata;
3. check that the copy fully succeeded;
4. only after that delete the old copy.

This is much more complex than a plain `Rename`.

Another important point: what happens if `newPath` already exists may depend on the operating system and the object type.

On Linux and Windows, especially, the rules for replacing files that are open are not the same.

That is why if a cross-platform program is written, important scenarios involving `Rename` must be tested not only on one operating system, but on all supported platforms.

## Deleting a directory

`os.Remove` can be used to delete an empty directory.

For example:

```go
err := os.Remove("empty-dir")
```

If there are files or other directories inside the directory, `os.Remove` usually returns an error.

To recursively delete a whole directory tree, `os.RemoveAll` is used:

```go
if err := os.RemoveAll(cacheDir); err != nil {
	return fmt.Errorf("deleting the cache directory: %w", err)
}
```

This snippet is not a standalone complete program.

It must be written inside a function that returns an `error`. Also, because `fmt.Errorf` is used, the `fmt` package must be imported.

`os.RemoveAll(cacheDir)` may fully delete a tree like:

```text
cache/
├── images/
│   ├── a.jpg
│   └── b.jpg
└── metadata.json
```

That is, not only the `cache` directory, but all files and directories inside it are deleted too.

**Attention**

`os.RemoveAll` is a very powerful operation.

If called with a wrong path, it may delete a large amount of data irreversibly.

The following values can be especially dangerous:

```text
.
```

or a wrongly computed broad directory path.

Before `RemoveAll` you must clearly check that the path is exactly a directory the program manages.

Do not pass a path that the user sent over HTTP, CLI or another external source directly to `os.RemoveAll` without any check.

If `os.RemoveAll` is called on a path that does not exist, it usually returns `nil`.

This makes it convenient in cleanup processes. For example, even if the directory was deleted earlier, no error arises again just for that reason.

There is also important behavior with symbolic links.

If the path points to the symbolic link itself, `RemoveAll` usually deletes the link. It does not automatically go into the outside directory tree the symbolic link points to and delete it recursively.

But this does not remove all risks.

If outside processes can change the file system between your check and the delete operation, a simple path check may not be enough.

In security-sensitive programs such race conditions must be considered separately.

## Temporary directories

Some directories are needed only for a short time.

For example:

* during a test;
* while converting a file;
* when temporarily extracting an archive;
* when splitting a large file into parts;
* when storing temporary intermediate results.

In such situations `os.MkdirTemp` can be used.

```go
dir, err := os.MkdirTemp("", "report-*")
if err != nil {
	return err
}
defer os.RemoveAll(dir)
```

If the first argument:

```go
""
```

is an empty string, the operating system's standard temporary directory is used.

The second argument:

```text
report-*
```

is a pattern for the directory name.

The `*` part is replaced with a random value.

As a result a directory roughly like:

```text
/tmp/report-184729153
```

may be created.

The important point: `MkdirTemp` does not just suggest a unique name and return. It **creates the directory itself** and then returns the path.

This is important from a security standpoint.

A wrong approach could look like this:

1. find a random name;
2. check that this name is free;
3. then create the directory.

Between step 2 and step 3 another process could take that name.

`MkdirTemp` helps prevent such a "check, then create" race condition.

The line in the example:

```go
defer os.RemoveAll(dir)
```

cleans up the temporary directory when the function ends.

In short-running functions or tests this is very convenient.

But in a long-running server you must not forget when `defer` runs.

If `defer` is written in a very long-lived function like `main`, the temporary directory may not be deleted while the server runs for hours or days.

That is why in a real server it must be determined in advance:

* how long a temporary directory lives;
* when it is cleaned up;
* what happens if the program crashes;
* who deletes old directories and when.

## Common mistakes

### Joining paths through strings

Building a path like this is not recommended:

```go
path := base + "/" + name
```

At first glance this looks like a simple and working solution.

But there are several problems:

* Windows may use another separator;
* if `base` ends with a separator, two separators may appear;
* `name` may come in an unexpected form;
* path normalization issues are not taken into account.

For local file system paths it is better to use:

```go
filepath.Join(base, name)
```

But `filepath.Join` by itself does not make a path from outside safe. If there is a path traversal risk, the base directory boundary must be checked separately.

### Treating `Mkdir` and `MkdirAll` as the same

Although these two functions look similar, their job is not the same.

`Mkdir`:

```go
os.Mkdir(path, perm)
```

creates only the last directory.

For example, for:

```text
data/cache/images
```

if `data/cache` does not exist, a plain `Mkdir` fails.

`MkdirAll`, on the other hand:

```go
os.MkdirAll(path, perm)
```

creates the missing parent directories too.

Another difference: if the needed directory tree already exists, `MkdirAll` does not return an error just for that reason.

### Thinking `os.ReadDir` also reads the inner tree

`os.ReadDir` returns only one directory level.

For example, for:

```text
root/
├── a.txt
└── sub/
    └── b.txt
```

the result of:

```go
os.ReadDir(root)
```

is:

```text
a.txt
sub
```

`sub/b.txt` is not returned automatically.

If the whole directory tree must be viewed recursively:

```go
filepath.WalkDir(...)
```

is used.

### Treating `filepath.Clean` as a security tool

`filepath.Clean` normalizes a path syntactically.

For example, it may bring:

```text
a/./b/../c
```

to the form:

```text
a/c
```

But it does not answer the question:

> "is this path inside the directory the user is allowed to access?"

That is why:

* normalizing the path;
* checking the allowed directory boundary;
* taking symbolic links into account

are separate tasks.

### Misunderstanding the execute bit in directory permissions

On a Unix system, the `x` bit for a directory has a different meaning from the `x` bit on an ordinary executable file.

On a directory the `x` bit allows accessing the entries inside it.

For example, if you know there is `file.txt` inside a directory, `x` permission on the directory may be needed to access it.

The `r` bit, on the other hand, is related to listing the names inside the directory.

That is why if a directory has:

```text
r
```

but not:

```text
x
```

even if you can see the names inside the directory, using them may be restricted.

When working with permissions, do not mix up the meaning of the `r`, `w` and `x` bits on a directory with their meaning on a file.

## What is looked at in interviews?

When asked about directories and file paths in Go, knowing only the function names may not be enough. It is important to be able to explain their job and their limits too.

* The `path` package is used for general slash paths with a `/` separator, such as URLs. `path/filepath` is meant for the local operating system's file paths.

* `os.Mkdir` creates one directory and requires the parent directory to exist. `os.MkdirAll` also creates the missing directories in the path.

* `MkdirAll` does not return an error just because the directory tree already exists. That is why it is convenient to use in an idempotent way.

* `os.ReadDir` reads only one directory level. It does not automatically go inside subdirectories.

* `filepath.WalkDir` is used for recursive walking.

* `WalkDir` usually does not automatically follow a symbolic link into the directory it points to. The symbolic link itself appears as an entry.

* `filepath.Clean` normalizes path syntax. But it does not check a security boundary.

* To prevent path traversal, it is checked separately that the path given by the user does not go outside the base directory.

* A plain `strings.HasPrefix(target, base)` check is not enough to determine a directory boundary.

* If symbolic links exist, a purely text-based path check does not close all risks.

* `os.Remove` can delete an empty directory. `os.RemoveAll` recursively deletes a whole directory tree.

* `os.RemoveAll` is a powerful and dangerous operation. Its argument must be checked at the trust boundary.

* `os.MkdirTemp` creates a unique temporary directory in a safer way. It reduces the race condition of checking a directory name in advance and then creating it.

* `os.Rename` usually works fast within one file system. But between different disks or mount points it may return an error.

In the next lesson we will learn how to use the `embed` package to add files to a Go program at compile time.
