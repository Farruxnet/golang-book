# Reading input from the console

In the previous parts we wrote the values a program uses inside the code. Most programs, however, ask the user to
type in a name, a number or other data by hand.

In this part we will learn to do that in the terminal and store the value in a variable.

To get data from the terminal, the `fmt` package has the `fmt.Scan()` function. Values can be read with this
function.

```go
package main

import "fmt"

func main() {
	var age int

	fmt.Print("Enter your age: ")
	if _, err := fmt.Scan(&age); err != nil {
		fmt.Println("Could not read the age:", err)
		return
	}

	fmt.Println("The age you entered:", age)
}
```

Run the program:

```bash
go run main.go
```

After the prompt appears in the terminal, type `25` and press `Enter`:

The result should look like this:

```text
Enter your age: 25
The age you entered: 25
```

> **Info**
>
> `fmt.Print()` prints text but does not add a newline. That is why the user types the value next to the prompt.
> `fmt.Println()`, on the other hand, would add a newline after the output.

Now let's try to understand the program above:

`var age int` creates the variable and gives it the zero value `0`. `fmt.Scan(&age)` reads a value from the terminal and
writes it into that variable. `Scan()` returns how many values were read and any error that occurred. In this example
the number of values is not needed, so `_` was used, and the error was checked through `err`. If there is an error, the
program prints the reason and ends its work with `return`.

The `if` used here runs the code in its block when the condition holds. `err != nil` checks whether there is an error.
Conditional statements and error handling were explained in detail in earlier lessons.

`&age` is the address of the `age` variable in memory. `Scan()` accepts the memory address of a variable as its
argument.

> **Warning**
>
> You write `fmt.Scan(&age)`, not `fmt.Scan(age)`. Without `&`, `Scan()` cannot write a new value into the variable and
> returns an error.

> **Info**
>
> You can read about memory addresses in the article [> Computers and operating systems](https://farruxnet.uz/blog/2026/06/01/kompyuter-va-operatsion-tizim/) (in Uzbek).
> For now it is enough to understand `&` as an instruction meaning **write the value to the address where this variable lives**. Memory addresses and pointers
> are explained in detail in a separate later part.

## Reading several values

You can give `Scan()` the addresses of several variables. In the terminal the values are separated by spaces or
newlines:

```go
package main

import "fmt"

func main() {
	var width float64
	var height float64

	fmt.Print("Enter the rectangle's width and height: ")
	if _, err := fmt.Scan(&width, &height); err != nil {
		fmt.Println("Could not read the sizes:", err)
		return
	}
	area := width * height
	fmt.Printf("Area: %.2f\n", area)
}
```

**Output:**

```text
Enter the rectangle's width and height: 5.5 3
Area: 16.50
```

**The values can also be entered on separate lines:**

```text
Enter the rectangle's width and height: 5.5
3
Area: 16.50
```

When reading text, `fmt.Scan()` reads up to a space. That is, a single word:

```go
package main

import "fmt"

func main() {
	var name string

	fmt.Print("Enter your first and last name: ")
	if _, err := fmt.Scan(&name); err != nil {
		fmt.Println("Could not read the name:", err)
		return
	}

	fmt.Printf("Hello, %s!\n", name)
}
```

Output:

```text
Enter your first and last name: Ali
Hello, Ali!
```

If the user enters `Ali Valiyev`, only `Ali` is written to `name`. For a whole line you need to use a different
function.

A full name or longer text can be read as one line with `bufio.Reader`:

```go
package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

func main() {
	reader := bufio.NewReader(os.Stdin)
	fmt.Print("Enter your first and last name: ")

	name, err := reader.ReadString('\n')
	if err != nil {
		fmt.Println("Could not read the name:", err)
		return
	}
	name = strings.TrimSpace(name)

	fmt.Printf("Hello, %s!\n", name)
}
```

Output:

```text
Enter your first and last name: Ali Valiyev
Hello, Ali Valiyev!
```

In this program:

- `os.Stdin` stands for the stream of data coming from the terminal;
- `bufio.NewReader()` creates a reader for that stream;
- `ReadString('\n')` reads up to the newline character that comes when `Enter` is pressed;
- `strings.TrimSpace()` removes spaces and the newline character from the start and end of the text.

> **Info**
>
> `reader.ReadString('\n')` returns two values: the text the user entered and any error that occurred while
> reading. The text is stored in `name` and the error in `err`. If `err != nil`, the program prints the cause of the
> error and ends its work with `return`. Functions and error handling were studied in detail in earlier parts.

In the next lesson we will look at command-line programs that work with arguments, standard streams and exit
codes.

## Examples

### 1. Reading two numbers from one line

```go
package main

import "fmt"

func main() {
	var a, b int
	fmt.Print("Enter two numbers: ")
	if _, err := fmt.Scan(&a, &b); err != nil {
		fmt.Println("Could not read the numbers:", err)
		return
	}
	fmt.Println("Sum:", a+b)
}
```

`fmt.Scan()` reads values separated by spaces or newlines. `&a` and `&b` show where the entered values should be written.

### 2. Reading a floating-point number

```go
package main

import "fmt"

func main() {
	var price float64
	fmt.Print("Price: ")
	if _, err := fmt.Scan(&price); err != nil {
		fmt.Println("Could not read the price:", err)
		return
	}
	fmt.Printf("Price: %.2f\n", price)
}
```

For a `float64`, the decimal separator is written as a dot: `12.5`.

### 3. Reading a yes-or-no value

```go
package main

import "fmt"

func main() {
	var active bool
	fmt.Print("Active? (true/false): ")
	if _, err := fmt.Scan(&active); err != nil {
		fmt.Println("Could not read the value:", err)
		return
	}
	fmt.Println(active)
}
```

The text `true` or `false` is read directly into a `bool` variable.

### 4. Choosing the input source with `Fscan`

```go
package main

import (
	"fmt"
	"os"
)

func main() {
	var num int
	fmt.Fscan(os.Stdin, &num)
	fmt.Println(num * num)
}
```

`Fscan()` takes the data source as a separate argument. Here the source is `os.Stdin`, which stands for the terminal.

### 5. Reading a whole line

```go
package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

func main() {
	reader := bufio.NewReader(os.Stdin)
	fmt.Print("Address: ")
	address, _ := reader.ReadString('\n')
	fmt.Println(strings.TrimSpace(address))
}
```

`ReadString()` keeps text with spaces too, up to the end of the line.

### 6. Reading a line with `Scanner`

```go
package main

import (
	"bufio"
	"fmt"
	"os"
)

func main() {
	scanner := bufio.NewScanner(os.Stdin)
	fmt.Print("Comment: ")
	scanner.Scan()
	fmt.Println("Received:", scanner.Text())
}
```

`Scanner.Text()` does not include the `\n` character at the end of the line.

### 7. Reading the first Unicode character

```go
package main

import (
	"bufio"
	"fmt"
	"os"
)

func main() {
	reader := bufio.NewReader(os.Stdin)
	fmt.Print("One character: ")
	char, size, _ := reader.ReadRune()
	fmt.Printf("Character: %c, UTF-8 size: %d bytes\n", char, size)
}
```

`ReadRune()` reads a single Unicode character. The second result tells how many bytes that character takes in UTF-8 encoding.

### 8. Reading one line with `Scanln`

```go
package main

import "fmt"

func main() {
	var firstName, lastName string
	fmt.Print("First and last name: ")
	fmt.Scanln(&firstName, &lastName)
	fmt.Println("Hello,", firstName, lastName)
}
```

`Scanln()` reads values only up to the end of the current line. In this example the first and last names are written to separate variables.

### 9. Reading comma-separated numbers

```go
package main

import "fmt"

func main() {
	var a, b int
	fmt.Print("a,b: ")
	fmt.Scanf("%d,%d", &a, &b)
	fmt.Println(a + b)
}
```

`Scanf()` lets you define the input format. In this example the comma is a required separator.

### 10. Checking how many values were entered

```go
package main

import "fmt"

func main() {
	var width, height int
	n, err := fmt.Scan(&width, &height)
	fmt.Println("Values read:", n)
	fmt.Println("Error:", err)
	fmt.Println("Area:", width*height)
}
```

`Scan()` also returns how many values were read successfully and any error that occurred. In the examples above we checked these results with `if`.
