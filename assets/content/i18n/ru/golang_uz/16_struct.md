# `struct` в Go

`struct` объединяет связанные между собой значения разных типов в один тип. Например, название товара может быть
`string`, цена — `int64`, а наличие на складе — `bool`. Если хранить эти данные не в отдельных переменных, а в одном
значении `Product`, код становится понятнее.

## Объявление типа и присваивание значений

```go
package main

import "fmt"

type User struct {
	Name  string
	Age   int
	Email string
}

func main() {
	user := User{
		Name:  "Али",
		Age:   25,
		Email: "ali@example.com",
	}

	fmt.Println(user.Name, user.Age, user.Email)
}
```

Результат:

```text
Али 25 ali@example.com
```

Через `type User struct` объявляется новый тип структуры с именем `User`. А `Name`, `Age` и `Email` — поля этой
структуры.

В Go, если тип или поле нужно использовать в другом пакете, его имя должно начинаться с заглавной буквы. Например,
`User` и `Name` можно использовать из других пакетов, а `user` или `name` — только внутри пакета, где они объявлены.

Значение структуры рекомендуется создавать с указанием имён полей:

```go
User{
    Name:  "Али",
    Age:   25,
    Email: "ali@example.com",
}
```

При таком способе порядок записи полей не важен.

Go поддерживает и такую короткую запись:

```go
User{"Али", 25, "ali@example.com"}
```

Но здесь значения зависят от порядка полей внутри `struct`. Если в структуру добавить новое поле или изменить порядок
полей, такой код может привести к ошибке.

Поэтому на практике запись с именами полей понятнее и уменьшает вероятность ошибок.

## Нулевое значение

В нулевом значении `struct` каждое поле получает нулевое значение своего типа:

```go
package main

import "fmt"

type Product struct {
	Name  string
	Price int64
	Stock int
}

func main() {
	var product Product
	fmt.Printf("%q %d %d\n", product.Name, product.Price, product.Stock)
}
```

Результат:

```text
"" 0 0
```

## Вложенные `struct`

```go
package main

import "fmt"

type Address struct {
	City   string
	Street string
}

type Customer struct {
	Name    string
	Address Address
}

func main() {
	customer := Customer{
		Name: "Лола",
		Address: Address{
			City:   "Ташкент",
			Street: "Амир Темур",
		},
	}

	fmt.Println(customer.Name, customer.Address.City)
}
```

Результат:

```text
Лола Ташкент
```

В Go нет наследования. Сложные типы обычно строятся путём объединения более простых.

## Встраивание (embedding)

Если внутри структуры тип записан без имени поля, он становится встроенным полем (embedded field):

```go
package main

import "fmt"

type Audit struct {
	CreatedBy string
}

type Order struct {
	ID int
	Audit
}

func main() {
	order := Order{ID: 19, Audit: Audit{CreatedBy: "admin"}}
	fmt.Println(order.ID, order.CreatedBy)
}
```

Результат:

```text
19 admin
```

Запись `order.CreatedBy` — короткая форма `order.Audit.CreatedBy`. Встраивание — не наследование: `Order` и `Audit`
остаются отдельными типами. Если имена полей совпадают, к нужному полю обращаются по полному пути.

## Семантика значений, указатели и сравнение

При присваивании `struct` другой переменной её поля копируются. Но скопированное поле типа `slice`, `map` или
`pointer` может по-прежнему ссылаться на те же базовые данные. Значит, это не глубокая копия. Если нужно изменить
поля исходной `struct`, используют `pointer`.

Значения `struct`, все поля которых сравнимы, можно сравнивать через `==`. Структуру с полем типа `slice`, `map` или
`функция` напрямую сравнить нельзя.

## Примеры

### 1. Создание значения с именованными полями

```go
package main

import "fmt"

type Product struct {
	Name  string
	Price int
}

func main() {
	book := Product{Name: "Книга по Go", Price: 85_000}
	fmt.Println(book)
}
```

Литерал с именами полей не зависит от их порядка. Неуказанные поля получают нулевое значение своего типа.

### 2. Обновление поля структуры

```go
package main

import "fmt"

type Account struct {
	Owner   string
	Balance int
}

func main() {
	account := Account{Owner: "Али", Balance: 100_000}
	account.Balance += 25_000
	fmt.Println(account)
}
```

К полю структуры обращаются через точку. При обновлении поля `Balance` поле `Owner` не меняется.

### 3. Нулевое значение структуры

```go
package main

import "fmt"

type Result struct {
	Score  int
	Passed bool
	Note   string
}

func main() {
	var result Result
	fmt.Printf("%+v\n", result)
}
```

Каждое поле получает нулевое значение своего типа. `%+v` выводит и имена полей.

### 4. Сравнение структур

```go
package main

import "fmt"

type Point struct {
	X int
	Y int
}

func main() {
	a := Point{X: 2, Y: 3}
	b := Point{X: 2, Y: 3}
	fmt.Println(a == b)
}
```

Значения структур, все поля которых сравнимы, сравниваются через `==` поле за полем.

### 5. Независимое изменение копии структуры

```go
package main

import "fmt"

type Size struct {
	Width  int
	Height int
}

func main() {
	original := Size{Width: 10, Height: 5}
	copied := original
	copied.Width = 20
	fmt.Println(original, copied)
}
```

При присваивании структуры другой переменной её значение копируется. Изменение обычного поля в копии не влияет на
исходную структуру.

### 6. Изменение структуры через указатель

```go
package main

import "fmt"

type User struct {
	Name   string
	Active bool
}

func activate(u *User) {
	u.Active = true
}

func main() {
	user := User{Name: "Вали"}
	activate(&user)
	fmt.Println(user)
}
```

Указатель на структуру позволяет функции изменять поля исходной структуры. Go разрешает писать `(*u).Active` в короткой
форме `u.Active`.

### 7. Вложенная структура

```go
package main

import "fmt"

type Address struct {
	City  string
	House int
}

type Person struct {
	Name    string
	Address Address
}

func main() {
	person := Person{Name: "Али", Address: Address{City: "Ташкент", House: 12}}
	fmt.Println(person.Address.City)
}
```

К полю внутренней структуры обращаются, записывая точки одну за другой.

### 8. Продвижение поля через встраивание

```go
package main

import "fmt"

type Address struct {
	City string
}

type Organization struct {
	Name string
	Address
}

func main() {
	o := Organization{Name: "Центр Go", Address: Address{City: "Самарканд"}}
	fmt.Println(o.City)
}
```

Если внутренний тип записан без имени поля, это называется встраиванием. Поэтому вместо `o.Address.City` можно
использовать короткую запись `o.City`.

### 9. Срез из структур

```go
package main

import "fmt"

type Student struct {
	Name  string
	Score int
}

func main() {
	students := []Student{{Name: "Али", Score: 86}, {Name: "Вали", Score: 92}}
	for _, student := range students {
		fmt.Println(student.Name, student.Score)
	}
}
```

Элементом среза может быть структура. В этом примере `range` на каждой итерации даёт копию очередного значения
структуры.

### 10. Структура как ключ map

```go
package main

import "fmt"

type Coordinate struct {
	X int
	Y int
}

func main() {
	colors := map[Coordinate]string{{X: 1, Y: 2}: "синий"}
	fmt.Println(colors[Coordinate{X: 1, Y: 2}])
}
```

Структура со сравнимыми полями может быть ключом map. Так две координаты объединяются в один ключ.
