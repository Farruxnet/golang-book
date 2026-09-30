# Интерфейсы в Go

**Интерфейс** (interface) определяет не то, какие данные хранит тип, а то, какое поведение он может выполнять.

Иначе говоря, внутри интерфейса не пишутся поля структуры. Вместо этого указывается, какие методы должны быть у типа.

Например, пусть нам нужен тип, который умеет отправлять сообщение.

Для этого то, как тип:

* хранит адрес email;
* где хранит номер телефона;
* использует ли HTTP API;
* использует ли SMTP;

может быть для нас неважно.

Нам нужно только одно:

```go
Send(message string) error
```

чтобы этот метод существовал.

Тогда можно объявить такой интерфейс:

```go
type Sender interface {
    Send(message string) error
}
```

Теперь любой тип, у которого есть метод `Send(string) error`, подходит под интерфейс `Sender`.

В Go для этого не нужно писать, как в языках вроде Java или C#, ключевое слово:

```text
implements
```

Например, так не пишут:

```text
EmailSender implements Sender
```

Go в этом не нуждается.

Если у типа `EmailSender` есть все методы, которые требует интерфейс, Go автоматически считает, что он реализует этот интерфейс.

Это называется **неявной реализацией интерфейса** (implicit interface implementation).

Одна из главных польз интерфейса — не привязывать код к одной конкретной структуре.

Например, следующая функция:

```go
func Notify(sender Sender, message string) error
```

не требует `EmailSender`, `SMSSender`, `TelegramSender` или другой конкретный тип.

Она требует только интерфейс:

```go
Sender
```

Значит, значение, передаваемое в функцию, должно отвечать не на требование:

> «Какая ты структура?»

а на требование:

> «Умеешь ли ты выполнять метод `Send()`?»

Это одна из самых важных идей интерфейсов.

## Объявление и реализация интерфейса

Рассмотрим следующий пример:

```go
package main

import "fmt"

type Sender interface {
	Send(message string) error
}

type EmailSender struct {
	Address string
}

func (e EmailSender) Send(message string) error {
	if e.Address == "" {
		return fmt.Errorf("адрес email пуст")
	}

	fmt.Printf("Кому %s: %s\n", e.Address, message)
	return nil
}

func Notify(sender Sender, message string) error {
	return sender.Send(message)
}

func main() {
	email := EmailSender{
		Address: "user@example.com",
	}

	if err := Notify(email, "Заказ готов"); err != nil {
		fmt.Println("Ошибка:", err)
	}
}
```

Результат:

```text
Кому user@example.com: Заказ готов
```

Рассмотрим важные части кода по отдельности.

Сначала интерфейс:

```go
type Sender interface {
    Send(message string) error
}
```

Этот код выражает требование:

> у типа, который хочет быть `Sender`, должен быть метод `Send(string) error`

Затем есть тип `EmailSender`:

```go
type EmailSender struct {
    Address string
}
```

Это обычная структура.

В ней хранится адрес email.

Затем для неё написан метод:

```go
func (e EmailSender) Send(message string) error
```

Сигнатура этого метода точно такая же, как у метода в интерфейсе:

```go
Send(message string) error
```

Поэтому:

```go
EmailSender
```

автоматически реализует интерфейс `Sender`.

Мы нигде отдельно не указали:

```text
EmailSender реализует интерфейс Sender
```

Go определяет это сам, глядя на набор методов.

Поэтому следующий код работает:

```go
email := EmailSender{
    Address: "user@example.com",
}

Notify(email, "Заказ готов")
```

А функция `Notify()` написана так:

```go
func Notify(sender Sender, message string) error {
    return sender.Send(message)
}
```

Эта функция ничего не знает о `EmailSender`.

Она не знает и о поле:

```go
Address
```

Ей неважно и то, как отправляется email.

Функция знает только одно:

```go
sender.Send(message)
```

можно вызвать.

Поэтому позже мы можем написать другой тип:

```go
type SMSSender struct {
    Phone string
}
```

и если добавим ему метод:

```go
func (s SMSSender) Send(message string) error {
    // отправка SMS
    return nil
}
```

`SMSSender` тоже автоматически подойдёт под `Sender`.

А функцию `Notify()` менять не нужно:

```go
Notify(emailSender, "Привет")
Notify(smsSender, "Привет")
```

Оба варианта могут работать.

### Проверка реализации интерфейса во время компиляции

Иногда полезно явно проверить в самом коде, что определённый тип реализует интерфейс.

Для этого в Go часто используют такой приём:

```go
var _ Sender = EmailSender{}
```

Здесь `_` — пустой идентификатор (blank identifier).

Само значение нам не нужно.

Этой записью мы говорим компилятору:

> проверь, что значение `EmailSender` можно использовать как `Sender`

Если `EmailSender` не подходит под интерфейс `Sender`, код не скомпилируется.

Например, если метод написан неправильно:

```go
func (e EmailSender) Send(message string) {
}
```

он не подходит под интерфейс `Sender`.

Причина в том, что интерфейс требует метод:

```go
Send(message string) error
```

А наш метод получился таким:

```go
Send(message string)
```

Значит, одного совпадения имени метода недостаточно.

Должно совпадать всё следующее:

* имя метода;
* количество параметров;
* типы параметров;
* порядок параметров;
* возвращаемые значения;
* типы возвращаемых значений.

Например:

```go
Send(string) error
```

и:

```go
Send([]byte) error
```

— две разные сигнатуры метода.

Поэтому второй не реализует интерфейс, требующий первый.

## Маленькие интерфейсы

В Go обычно предпочитают **маленькие интерфейсы**.

То есть в интерфейс по возможности записывают только действительно нужные методы.

Например, если функции нужно только читать данные, не обязательно давать ей такой большой интерфейс:

```go
type Storage interface {
    Read()
    Write()
    Delete()
    Update()
    Close()
    Backup()
    Restore()
}
```

Если функция только читает, ей может хватить одного метода:

```go
type Reader interface {
    Read([]byte) (int, error)
}
```

У этого есть несколько преимуществ.

Во-первых, маленький интерфейс легко реализовать.

Если интерфейс требует один метод:

```go
type Sender interface {
    Send(string) error
}
```

новому типу достаточно добавить только этот метод.

Если интерфейс требует десять методов, чтобы реализовать его, у типа должно быть десять методов.

Во-вторых, маленький интерфейс упрощает написание тестов.

Например, в тесте вместо настоящего сервиса email можно создать маленький тестовый тип:

```go
type FakeSender struct{}

func (FakeSender) Send(message string) error {
    return nil
}
```

`FakeSender` подходит под интерфейс `Sender`.

Поэтому в тесте не нужно отправлять настоящий email.

В-третьих, маленький интерфейс удобнее переиспользовать.

Один из самых известных примеров в стандартной библиотеке Go — интерфейс:

```go
io.Reader
```

Он требует только один метод:

```go
Read(p []byte) (n int, err error)
```

Несмотря на это, как `io.Reader` можно использовать очень многие типы:

* файл;
* тело HTTP-ответа;
* буфер;
* TCP-соединение;
* поток сжатых данных;
* строку в памяти.

Их внутреннее устройство разное.

Но если все они могут отдавать данные через:

```go
Read(...)
```

код, работающий с `io.Reader`, может их использовать.

### Интерфейс часто объявляет сторона, которая его использует

Один из важных практических принципов в Go:

> Интерфейс часто объявляет не тип, который его реализует, а код, который им пользуется.

Например, самому пакету `EmailSender` не обязательно объявлять большой интерфейс:

```go
Sender
```

Если другому пакету нужен только:

```go
Send(string) error
```

этот пакет может создать свой маленький интерфейс.

Это меньше связывает компоненты друг с другом.

## Встраивание одного интерфейса в другой

В Go один интерфейс можно поместить внутрь другого.

Это называется **встраиванием интерфейсов** (interface embedding).

Например:

```go
type Reader interface {
    Read([]byte) (int, error)
}

type Writer interface {
    Write([]byte) (int, error)
}
```

Здесь два отдельных интерфейса.

`Reader` обозначает тип, который умеет читать данные.

`Writer` обозначает тип, который умеет записывать данные.

Теперь их можно объединить:

```go
type ReadWriter interface {
    Reader
    Writer
}
```

Смысл этой записи:

> Чтобы быть `ReadWriter`, нужно выполнять требования и `Reader`, и `Writer`.

То есть на практике `ReadWriter` равен:

```go
type ReadWriter interface {
    Read([]byte) (int, error)
    Write([]byte) (int, error)
}
```

Но через встраивание можно собрать новый интерфейс из уже существующих маленьких интерфейсов.

Например, если у типа есть только:

```go
Read(...)
```

он реализует `Reader`.

Если есть только:

```go
Write(...)
```

он реализует `Writer`.

Если есть оба:

```go
Read(...)
Write(...)
```

он реализует и `ReadWriter`.

Этот приём помогает создавать более крупное поведение, объединяя маленькие интерфейсы.

## Динамический тип и динамическое значение

Чтобы правильно понимать интерфейсы, важно знать, как внутри них хранится значение.

Значение интерфейса упрощённо можно представить как две части:

* **динамический тип** (dynamic type);
* **динамическое значение** (dynamic value).

### Что такое динамический тип?

Динамический тип — конкретный тип значения, которое сейчас хранится в интерфейсе.

Например:

```go
var value any = 15
```

Здесь статический тип переменной:

```go
any
```

а конкретный тип значения внутри неё:

```go
int
```

Значит, динамический тип:

```text
int
```

### Что такое динамическое значение?

Динамическое значение — настоящее значение, хранящееся в интерфейсе.

В примере выше:

```go
var value any = 15
```

динамический тип:

```text
int
```

динамическое значение:

```text
15
```

Рассмотрим следующий пример:

```go
package main

import "fmt"

func main() {
	var value any = 15

	fmt.Printf("Тип: %T, значение: %v\n", value, value)

	value = "Go"

	fmt.Printf("Тип: %T, значение: %v\n", value, value)
}
```

Результат:

```text
Тип: int, значение: 15
Тип: string, значение: Go
```

Сначала, когда:

```go
var value any = 15
```

в интерфейсе хранится:

```text
dynamic type  = int
dynamic value = 15
```

Затем мы заменили значение:

```go
value = "Go"
```

Теперь в интерфейсе хранится:

```text
dynamic type  = string
dynamic value = "Go"
```

Сама переменная-интерфейс по-прежнему имеет тип:

```go
any
```

Но конкретный тип внутри неё может меняться во время выполнения.

### Что такое `any`?

В Go:

```go
any
```

— это псевдоним (alias) для:

```go
interface{}
```

То есть:

```go
any
```

и:

```go
interface{}
```

означают одно и то же.

Пустой интерфейс:

```go
interface{}
```

не требует никаких методов.

Все типы в Go удовлетворяют как минимум условию «требуется ноль методов».

Поэтому `any` может хранить значение любого типа:

```go
var value any

value = 15
value = "Go"
value = true
value = []int{1, 2, 3}
value = struct{}{}
```

Всё это возможно.

Но в этом же и недостаток `any`.

Например, если написать:

```go
func process(value any)
```

функция заранее не знает, что можно делать с `value`.

Это может быть `int`.

Может быть `string`.

Может быть структура или slice.

Поэтому там, где возможно, вместо:

```go
any
```

лучше использовать конкретный интерфейс, выражающий нужное поведение.

Например:

```go
type Sender interface {
    Send(string) error
}
```

Это даёт гораздо более сильное требование, чем `any`.

Внутри функции мы знаем, что как минимум можно вызвать:

```go
sender.Send(...)
```

В некоторых случаях лучшую типобезопасность, чем интерфейс, могут дать и generics.

Но интерфейсы и generics выполняют не одну и ту же задачу.

Интерфейс больше про поведение. Он отвечает на вопрос:

> «Что умеет это значение?»

## Ловушка `nil`-интерфейса

Одна из самых запутанных тем при работе с интерфейсами — `nil`.

С обычным указателем ситуация понятна:

```go
var pointer *MyError
```

Если ему не присвоено значение:

```go
pointer == nil
```

результат:

```text
true
```

Интерфейс работает немного иначе.

Мы представляли интерфейс как две части:

```text
(dynamic type, dynamic value)
```

Интерфейс равен `nil` только тогда, когда обе части отсутствуют.

То есть настоящий `nil`-интерфейс выглядит примерно так:

```text
(nil, nil)
```

Рассмотрим следующий пример:

```go
package main

import "fmt"

type MyError struct{}

func (e *MyError) Error() string {
	return "ошибка"
}

func main() {
	var pointer *MyError

	var err error = pointer

	fmt.Println(pointer == nil)
	fmt.Println(err == nil)
	fmt.Printf("%T %v\n", err, err)
}
```

Результат:

```text
true
false
*main.MyError ошибка
```

На первый взгляд это может показаться странным.

У нас есть:

```go
var pointer *MyError
```

Ему не присвоено никакого значения.

Значит, результат:

```go
pointer == nil
```

равен:

```text
true
```

Это правильно.

Затем мы поместили указатель в интерфейс `error`:

```go
var err error = pointer
```

`MyError` реализует интерфейс `error`, потому что у него есть метод:

```go
Error() string
```

Но теперь внутри `err` есть информация.

Его состояние можно представить так:

```text
dynamic type  = *MyError
dynamic value = nil
```

То есть:

```text
(*MyError, nil)
```

А чтобы интерфейс был полностью `nil`, должно было быть:

```text
(nil, nil)
```

Но у нас есть динамический тип:

```text
*MyError
```

Поэтому результат:

```go
err == nil
```

равен:

```text
false
```

Это одна из ситуаций, называемых проблемой **typed nil**.

### Проблема typed nil в функции, возвращающей `error`

Такой код может быть опасным:

```go
func doSomething() error {
    var err *MyError

    return err
}
```

Разработчик может подумать:

> указатель `err` равен `nil`, значит, функция возвращает `nil`

Но функция возвращает тип-интерфейс:

```go
error
```

Когда указатель `*MyError` помещается в интерфейс `error`, динамический тип сохраняется.

В результате возвращённый интерфейс имеет вид:

```text
(*MyError, nil)
```

Поэтому возникает ситуация:

```go
if err != nil {
    // этот блок может выполниться
}
```

В случае успеха функция, возвращающая `error`, должна напрямую возвращать:

```go
return nil
```

Например:

```go
func doSomething() error {
    // всё прошло успешно

    return nil
}
```

В этом случае интерфейс действительно равен:

```text
(nil, nil)
```

## Утверждение типа (type assertion)

Может понадобиться получить, значение какого именно типа хранится в интерфейсе.

Для этого используется **утверждение типа** (type assertion).

Например:

```go
var value any = "Go"
```

Мы хотим узнать, является ли значение внутри `value` строкой `string`.

Можно написать:

```go
text := value.(string)
```

Это означает:

> если динамический тип внутри `value` — `string`, возьми его значение

Если `value` действительно хранит:

```go
"Go"
```

то после:

```go
text := value.(string)
```

получаем:

```go
text == "Go"
```

Но у этого приёма есть опасная сторона.

Если:

```go
var value any = 15
```

и мы напишем:

```go
text := value.(string)
```

программа вызовет `panic`.

Причина в том, что динамический тип:

```text
int
```

а мы требуем:

```text
string
```

### Форма `comma ok`

Чтобы использовать утверждение типа безопаснее, обычно применяют форму:

```go
value, ok := interfaceValue.(Type)
```

Например:

```go
var value any = "Go"

text, ok := value.(string)
```

Если динамический тип — `string`, получаем:

```text
text = "Go"
ok   = true
```

Если:

```go
var value any = 15
```

то после:

```go
text, ok := value.(string)
```

получаем:

```text
text = ""
ok   = false
```

Программа не вызывает `panic`.

`text` получает нулевое значение типа `string`:

```text
""
```

Поэтому при проверке типа внутри интерфейса часто безопаснее способ:

```go
v, ok := value.(string)
```

## Переключатель типов (type switch)

Если значение внутри интерфейса может быть одним из нескольких типов, писать много утверждений типа подряд неудобно.

Например:

```go
if v, ok := value.(int); ok {
    ...
}

if v, ok := value.(string); ok {
    ...
}

if v, ok := value.(bool); ok {
    ...
}
```

Для такого случая в Go есть **type switch**.

Пример:

```go
package main

import "fmt"

func describe(value any) {
	switch v := value.(type) {
	case int:
		fmt.Println("Целое число:", v)

	case string:
		fmt.Println("Строка:", v)

	default:
		fmt.Printf("Другой тип: %T\n", v)
	}
}

func main() {
	describe(15)
	describe("Go")
}
```

Результат:

```text
Целое число: 15
Строка: Go
```

Основная часть type switch:

```go
switch v := value.(type) {
```

В обычном утверждении типа мы пишем конкретный тип:

```go
value.(string)
```

В type switch же используется особая форма:

```go
value.(type)
```

Затем нужные типы проверяются через `case`:

```go
case int:
```

Если динамический тип — `int`, выполняется этот блок.

```go
case string:
```

Если динамический тип — `string`, выполняется этот блок.

Например, при вызове:

```go
describe(15)
```

получаем:

```text
dynamic type = int
```

Поэтому выбирается:

```go
case int:
```

Внутри этого блока тип `v` тоже:

```go
int
```

Поэтому его можно использовать напрямую:

```go
fmt.Println("Целое число:", v)
```

При вызове `describe("Go")` `v` будет `string`.

Если ни один `case` не подходит, выполняется блок:

```go
default:
```

Type switch особенно полезен в коде, работающем с `any`.

Но злоупотреблять им тоже не стоит.

Если для работы функции нужен определённый метод, написать конкретный интерфейс часто понятнее, чем принимать `any` и потом проверять тип.

## Как pointer receiver влияет на интерфейс

В теме о методах мы видели понятие **набора методов** (method set).

Оно особенно важно при работе с интерфейсами.

Предположим:

```go
type Counter struct {
    Value int
}
```

и метод:

```go
func (c *Counter) Increment() {
    c.Value++
}
```

Получатель этого метода:

```go
*Counter
```

То есть pointer receiver.

Теперь пусть интерфейс будет:

```go
type Incrementer interface {
    Increment()
}
```

Вопрос: реализует ли интерфейс

```go
Counter
```

Нет.

Но:

```go
*Counter
```

реализует.

Причина — правило набора методов.

Упрощённо, в набор методов:

```text
T
```

входят методы, написанные с value receiver.

А в набор методов:

```text
*T
```

входят:

* методы с получателем `T`;
* методы с получателем `*T`.

Поскольку у нас:

```go
func (c *Counter) Increment()
```

`Increment()` входит в набор методов `*Counter`.

Поэтому:

```go
var i Incrementer = &counter
```

работает.

А:

```go
var i Incrementer = counter
```

не компилируется.

Здесь не нужно путать правило интерфейсов с тем, что Go автоматически добавляет `&` при вызове методов.

Например:

```go
counter.Increment()
```

может работать.

Go видит, что адрес `counter` можно взять, и на практике приводит вызов к виду:

```go
(&counter).Increment()
```

Но при присваивании интерфейсу:

```go
var i Incrementer = counter
```

Go не делает автоматически:

```go
&counter
```

Соответствие интерфейсу проверяется по реальному набору методов типа.

## Примеры

### 1. Разные фигуры через маленький интерфейс

```go
package main

import "fmt"

type Shape interface {
	Area() float64
}

type Square struct {
	Side float64
}

type Rectangle struct {
	Width  float64
	Height float64
}

func (s Square) Area() float64 {
	return s.Side * s.Side
}

func (r Rectangle) Area() float64 {
	return r.Width * r.Height
}

func printArea(s Shape) {
	fmt.Println(s.Area())
}

func main() {
	printArea(Square{
		Side: 4,
	})

	printArea(Rectangle{
		Width:  3,
		Height: 5,
	})
}
```

В этом примере:

```go
type Shape interface {
    Area() float64
}
```

интерфейс требует только один метод:

```go
Area() float64
```

У `Square` есть метод:

```go
func (s Square) Area() float64
```

У `Rectangle` тоже есть метод:

```go
func (r Rectangle) Area() float64
```

Поэтому оба типа автоматически реализуют интерфейс `Shape`.

Мы нигде не писали:

```text
Square implements Shape
```

или:

```text
Rectangle implements Shape
```

Достаточно совпадения методов.

Функция `printArea()`:

```go
func printArea(s Shape)
```

не требует конкретно `Square` или `Rectangle`.

Она хочет только иметь возможность вызвать метод:

```go
Area()
```

Поэтому работает и:

```go
printArea(Square{Side: 4})
```

и:

```go
printArea(Rectangle{Width: 3, Height: 5})
```

Для функции неважно, какие поля внутри фигуры.

Ей нужна только способность вычислить площадь.

### 2. Slice интерфейсов

```go
package main

import "fmt"

type Named interface {
	Name() string
}

type City string

type Language string

func (c City) Name() string {
	return string(c)
}

func (l Language) Name() string {
	return string(l)
}

func main() {
	values := []Named{
		City("Ташкент"),
		Language("Go"),
	}

	for _, value := range values {
		fmt.Println(value.Name())
	}
}
```

Обычный slice, как правило, хранит значения одного типа.

Например:

```go
[]string
```

хранит только `string`.

```go
[]int
```

хранит только `int`.

Но в этом примере использован slice интерфейсов:

```go
[]Named
```

`City` и `Language` — два разных конкретных типа:

```go
type City string
type Language string
```

Но у обоих есть метод:

```go
Name() string
```

Поэтому оба реализуют интерфейс:

```go
Named
```

В результате в одном slice можно хранить вместе значения:

```go
City("Ташкент")
```

и:

```go
Language("Go")
```

Внутри цикла:

```go
for _, value := range values {
    fmt.Println(value.Name())
}
```

коду неважно, является ли значение:

```go
City
```

или:

```go
Language
```

Он просто вызывает метод `Name()`.

Это одна из простых форм полиморфизма.

Разные конкретные типы используются через одно общее поведение.

### 3. Маленький интерфейс в параметре функции

```go
package main

import "fmt"

type Validator interface {
	Valid() bool
}

type Score int

func (s Score) Valid() bool {
	return s >= 0 && s <= 100
}

func check(v Validator) bool {
	return v.Valid()
}

func main() {
	fmt.Println(check(Score(86)))
}
```

Здесь:

```go
type Validator interface {
    Valid() bool
}
```

очень маленький интерфейс.

Он требует только метод:

```go
Valid() bool
```

У типа `Score` есть метод:

```go
func (s Score) Valid() bool
```

Поэтому `Score` автоматически подходит под `Validator`.

Функция `check()`:

```go
func check(v Validator) bool
```

не привязана к конкретному типу `Score`.

Для неё неважно, что это за значение.

Ей нужно только иметь возможность вызвать:

```go
v.Valid()
```

Если позже мы создадим другой тип:

```go
type Age int
```

и напишем для него метод:

```go
func (a Age) Valid() bool {
    return a >= 0 && a <= 150
}
```

`Age` тоже можно будет передать в эту функцию:

```go
check(Age(29))
```

Функцию `check()` менять не нужно.

Это одна из главных польз маленьких интерфейсов.

### 4. Утверждение типа для пустого интерфейса

```go
package main

import "fmt"

func main() {
	var value any = "Go"

	text, ok := value.(string)

	fmt.Println(text, ok)
}
```

Здесь после:

```go
var value any = "Go"
```

в интерфейсе хранится:

```text
dynamic type  = string
dynamic value = "Go"
```

Затем выполнено утверждение типа:

```go
text, ok := value.(string)
```

Это проверка:

> является ли конкретный тип внутри `value` строкой `string`?

Поскольку это действительно `string`:

```text
text = "Go"
ok   = true
```

Результат примерно такой:

```text
Go true
```

Если бы значение было:

```go
var value any = 15
```

результат:

```go
text, ok := value.(string)
```

был бы:

```text
text = ""
ok   = false
```

Самое важное — программа не вызывает `panic`.

Если бы использовалась форма:

```go
text := value.(string)
```

и динамический тип не был бы `string`, произошёл бы `panic` во время выполнения.

Поэтому там, где тип может не совпасть, форма `comma ok` безопаснее.

### 5. Разделение значений с помощью type switch

```go
package main

import "fmt"

func show(value any) {
	switch v := value.(type) {
	case int:
		fmt.Println("Целое число:", v)

	case string:
		fmt.Println("Текст:", v)

	case bool:
		fmt.Println("Логическое значение:", v)

	default:
		fmt.Println("Неизвестный тип")
	}
}

func main() {
	show(15)
	show("Go")
}
```

Эта функция принимает:

```go
any
```

Значит, в неё можно передавать разные типы.

Например:

```go
show(15)
show("Go")
show(true)
```

Внутри функции:

```go
switch v := value.(type)
```

проверяет динамический тип.

Если значение:

```go
15
```

динамический тип:

```text
int
```

Поэтому выполняется блок:

```go
case int:
```

Внутри этого блока `v` тоже имеет тип `int`.

Если вызвать:

```go
show("Go")
```

выбирается:

```go
case string:
```

На этот раз `v` имеет тип:

```go
string
```

Если вызвать:

```go
show(true)
```

срабатывает:

```go
case bool:
```

Если ни один `case` не подходит, выполняется:

```go
default:
```

Type switch удобен, чтобы упорядоченно проверить несколько возможных конкретных типов внутри одного интерфейса.

### 6. Состояние `nil` у интерфейса

```go
package main

import "fmt"

func main() {
	var value any

	fmt.Println(value == nil)

	value = 0

	fmt.Println(value == nil)
}
```

Сначала интерфейс объявлен так:

```go
var value any
```

Ему не присвоено никакого значения.

Упрощённо его можно представить как:

```text
dynamic type  = nil
dynamic value = nil
```

Поэтому результат:

```go
value == nil
```

равен:

```text
true
```

Затем мы написали:

```go
value = 0
```

Иногда `0` может казаться «пустым значением».

Но `0` — настоящее значение `int`.

Теперь в интерфейсе хранится:

```text
dynamic type  = int
dynamic value = 0
```

Поэтому результат:

```go
value == nil
```

равен:

```text
false
```

То, что значение внутри интерфейса — нулевое значение, не означает, что сам интерфейс равен `nil`.

Например, все следующие значения интерфейса — не `nil`:

```go
var a any = 0
var b any = ""
var c any = false
```

Их динамические значения — нулевые значения своих типов.

Но динамический тип присутствует.

### 7. Ловушка typed nil указателя

```go
package main

import "fmt"

type Named interface {
	Name() string
}

type Person struct {
	FirstName string
}

func (p *Person) Name() string {
	if p == nil {
		return "неизвестно"
	}

	return p.FirstName
}

func main() {
	var person *Person

	var named Named = person

	fmt.Println(named == nil, named.Name())
}
```

В этом примере объявлен:

```go
var person *Person
```

Ему не присвоено значение.

Поэтому:

```go
person == nil
```

Но затем указатель помещён в интерфейс:

```go
var named Named = person
```

`*Person` реализует интерфейс `Named`, потому что у него есть метод:

```go
Name() string
```

Теперь состояние интерфейса `named` можно представить как:

```text
dynamic type  = *Person
dynamic value = nil
```

Поскольку динамический тип присутствует, результат:

```go
named == nil
```

равен:

```text
false
```

Затем вызывается:

```go
named.Name()
```

Указатель в исходном получателе равен `nil`.

Но в начале метода есть проверка:

```go
if p == nil {
    return "неизвестно"
}
```

Поэтому метод безопасно обрабатывает `nil`-получатель и возвращает:

```text
неизвестно
```

Этот пример хорошо показывает ситуацию typed nil в интерфейсах.

### 8. Pointer receiver и набор методов

```go
package main

import "fmt"

type Incrementer interface {
	Increment()
}

type Counter struct {
	Value int
}

func (c *Counter) Increment() {
	c.Value++
}

func main() {
	c := Counter{}

	var inc Incrementer = &c

	inc.Increment()

	fmt.Println(c.Value)
}
```

Интерфейс:

```go
type Incrementer interface {
    Increment()
}
```

требует метод `Increment()`.

В `Counter` метод записан в виде:

```go
func (c *Counter) Increment()
```

Получатель:

```go
*Counter
```

то есть pointer receiver.

Поэтому интерфейс `Incrementer` реализует:

```go
*Counter
```

По этой причине следующий код правильный:

```go
var inc Incrementer = &c
```

Тип `&c`:

```go
*Counter
```

А следующий не работает:

```go
var inc Incrementer = c
```

Причина в том, что в собственном наборе методов `Counter` нет `Increment()`, написанного с pointer receiver.

Это отличается от обычного вызова метода.

Следующее может работать:

```go
c.Increment()
```

Потому что Go автоматически приводит его к виду:

```go
(&c).Increment()
```

Но при присваивании интерфейсу такое автоматическое взятие адреса не выполняется.

Соответствие интерфейсу проверяется через набор методов.

### 9. Встраивание одного интерфейса в другой

```go
package main

import "fmt"

type Named interface {
	Name() string
}

type Detailed interface {
	Named
	Description() string
}

type Product struct {
	Title string
}

func (p Product) Name() string {
	return p.Title
}

func (p Product) Description() string {
	return "Товар: " + p.Title
}

func main() {
	var value Detailed = Product{
		Title: "Книга",
	}

	fmt.Println(
		value.Name(),
		value.Description(),
	)
}
```

Сначала есть интерфейс:

```go
type Named interface {
    Name() string
}
```

Затем создан новый интерфейс:

```go
type Detailed interface {
    Named
    Description() string
}
```

Здесь интерфейс:

```go
Named
```

встроен в `Detailed`.

Значит, `Detailed` требует следующие методы:

```go
Name() string
Description() string
```

Если записать полностью, его можно представить равным:

```go
type Detailed interface {
    Name() string
    Description() string
}
```

У типа `Product` есть оба метода:

```go
func (p Product) Name() string
```

и:

```go
func (p Product) Description() string
```

Поэтому `Product` реализует интерфейс:

```go
Detailed
```

Кроме того, он реализует и интерфейс:

```go
Named
```

Встраивание интерфейсов позволяет собирать большие интерфейсы из маленьких и понятных.

Например:

```go
type Reader interface {
    Read(...)
}

type Writer interface {
    Write(...)
}

type Closer interface {
    Close() error
}
```

а затем, объединив их, можно создать такой интерфейс:

```go
type ReadWriteCloser interface {
    Reader
    Writer
    Closer
}
```

### 10. Передача значения интерфейса в параметр-интерфейс

```go
package main

import "fmt"

type Stringer interface {
	String() string
}

type Code int

func (c Code) String() string {
	return fmt.Sprintf("CODE-%d", c)
}

func printIt(s Stringer) {
	fmt.Println(s.String())
}

func main() {
	var s Stringer = Code(15)

	printIt(s)
}
```

Здесь есть интерфейс:

```go
type Stringer interface {
    String() string
}
```

Для типа `Code`:

```go
type Code int
```

написан метод:

```go
func (c Code) String() string
```

Поэтому `Code` реализует интерфейс `Stringer`.

Затем создано значение интерфейса:

```go
var s Stringer = Code(15)
```

В этот момент `s` можно представить так:

```text
статический тип = Stringer
dynamic type    = Code
dynamic value   = Code(15)
```

Затем вызывается:

```go
printIt(s)
```

`printIt()` тоже принимает:

```go
Stringer
```

в качестве параметра:

```go
func printIt(s Stringer)
```

Поэтому существующее значение интерфейса можно передать ей напрямую.

Внутри функции при вызове:

```go
s.String()
```

поскольку динамический тип внутри интерфейса:

```go
Code
```

выполняется метод `Code.String()`.

То есть вызывается:

```go
func (c Code) String() string {
    return fmt.Sprintf("CODE-%d", c)
}
```

В результате выводится:

```text
CODE-15
```

Передача значения интерфейса в другое место не теряет конкретное значение внутри него.

В этом примере и после передачи остаётся:

```text
dynamic type  = Code
dynamic value = Code(15)
```

А функции не нужно знать конкретный тип `Code`.

Она использует только метод:

```go
String() string
```
