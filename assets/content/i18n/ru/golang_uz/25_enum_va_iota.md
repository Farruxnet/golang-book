# Перечисления (enum) и `iota` в Go

В языке программирования Go, в отличие от некоторых других языков, нет отдельного ключевого слова:

```text
enum
```

Например, в Java, C# или других языках определённый набор значений можно объявить как `enum`.

В Go эта задача обычно решается с помощью:

* именованного типа;
* констант `const`;
* при необходимости — `iota`.

Например, пусть в системе есть статусы заказа:

```text
unknown
pending
processing
completed
```

Их можно хранить как обычные `int`:

```go
const (
    StatusUnknown    = 0
    StatusPending    = 1
    StatusProcessing = 2
    StatusCompleted  = 3
)
```

Но тогда значения остаются обычными `int`.

В Go вместо этого лучше создать отдельный именованный тип:

```go
type Status int
```

Затем константы можно привязать к этому типу:

```go
const (
    StatusUnknown Status = iota
    StatusPending
    StatusProcessing
    StatusCompleted
)
```

В результате в коде мы работаем не с простым числом, а с типом `Status`, смысл которого понятен.

А `iota` здесь помогает не писать значения:

```text
0
1
2
3
```

вручную.

## Именованный тип и константы

Рассмотрим следующий пример:

```go
package main

import "fmt"

type Status int

const (
	StatusUnknown Status = iota
	StatusPending
	StatusProcessing
	StatusCompleted
)

func main() {
	status := StatusProcessing

	fmt.Println(status)
	fmt.Println(status == StatusCompleted)
}
```

Результат:

```text
2
false
```

Самая важная часть этого кода:

```go
type Status int
```

Здесь на основе `int` создан новый тип `Status`.

Базовый тип `Status` — `int`, но для Go это отдельный именованный тип.

Затем через:

```go
const (
    StatusUnknown Status = iota
    StatusPending
    StatusProcessing
    StatusCompleted
)
```

объявлены основные возможные константы для `Status`.

В первой строке написано:

```go
StatusUnknown Status = iota
```

Когда начинается группа `const`, значение `iota`:

```text
0
```

Поэтому:

```go
StatusUnknown == 0
```

В следующей строке новое выражение не написано:

```go
StatusPending
```

Go повторяет предыдущее выражение, и `iota` увеличивается на единицу.

В результате:

```go
StatusPending == 1
```

Следующие значения:

```go
StatusProcessing == 2
StatusCompleted  == 3
```

Поэтому результат:

```go
status := StatusProcessing
fmt.Println(status)
```

равен:

```text
2
```

Затем проверяется:

```go
status == StatusCompleted
```

Значение `status`:

```text
2
```

а `StatusCompleted`:

```text
3
```

поэтому результат:

```text
false
```

### Почему отдельный тип, а не обычный `int`?

Можно было написать и так:

```go
const (
    StatusUnknown    = 0
    StatusPending    = 1
    StatusProcessing = 2
    StatusCompleted  = 3
)
```

Но эти значения остаются обычными `int`.

Создание отдельного типа:

```go
type Status int
```

делает смысл кода понятнее.

Например, уже по виду функции:

```go
func SetStatus(status Status) {
}
```

можно понять, что параметр — не просто число, а именно статус системы.

Это гораздо понятнее, чем:

```go
func SetStatus(status int) {
}
```

К именованному типу позже можно добавить и методы:

```go
func (s Status) String() string {
    // ...
}
```

или:

```go
func (s Status) Valid() bool {
    // ...
}
```

Поэтому именованный тип — не просто другое имя для чисел. Он позволяет выразить определённое понятие отдельным типом.

## Нулевое значение для `Unknown`

В Go у каждого типа есть нулевое значение (zero value), то есть начальное значение.

Для типа на основе `int` это:

```text
0
```

Например, если написать:

```go
var status Status
```

и не присвоить значение, то:

```go
status == 0
```

Поэтому в типах, похожих на enum, часто полезно отвести значение `0` под неизвестное или ещё не заданное состояние, например:

```go
StatusUnknown
```

Например:

```go
const (
    StatusUnknown Status = iota
    StatusPending
    StatusProcessing
    StatusCompleted
)
```

Теперь значение, объявленное как:

```go
var status Status
```

автоматически равно состоянию:

```go
StatusUnknown
```

Это хороший дизайн, потому что нулевое значение случайно не обозначает реальное бизнес-состояние.

Если бы первым значением было:

```go
StatusCompleted Status = iota
```

то только что объявленный:

```go
var status Status
```

случайно обозначал бы состояние `Completed`.

Во многих системах это опасно.

Поэтому выделение состояния вроде:

```text
0 = Unknown
```

или:

```text
0 = Unspecified
```

считается хорошей практикой.

## Как работает `iota`?

`iota` — особый идентификатор, который используется только внутри объявления `const`.

В каждой новой группе `const` он начинается с:

```text
0
```

Например:

```go
const (
    A = iota
    B
    C
)
```

значения:

```text
A = 0
B = 1
C = 2
```

Но `iota` не обязательно использовать только как простое число.

Его можно использовать и внутри формулы.

Например:

```go
const (
    A = iota + 1
    B
    C
)
```

Результат:

```text
A = 1
B = 2
C = 3
```

В первой строке:

```go
A = iota + 1
```

`iota` равен:

```text
0
```

Значит:

```text
0 + 1 = 1
```

В следующей строке для:

```go
B
```

отдельное выражение не написано.

Go повторяет предыдущее выражение:

```go
iota + 1
```

В этой строке `iota` равен:

```text
1
```

поэтому получается:

```text
1 + 1 = 2
```

В строке `C`:

```text
iota = 2
```

Результат:

```text
2 + 1 = 3
```

### Что делает строка без выражения?

Например:

```go
const (
    A = iota + 1
    B
    C
)
```

на самом деле близко к следующему:

```go
const (
    A = iota + 1
    B = iota + 1
    C = iota + 1
)
```

Но на каждой строке значение `iota` увеличивается на единицу.

Поэтому не нужно писать одну и ту же формулу снова и снова.

Это одно из главных удобств `iota`.

## `iota` увеличивается на каждой строке `ConstSpec`

Важное правило:

`iota` увеличивается на единицу не на каждом имени константы, а на каждой строке `ConstSpec`.

Например:

```go
const (
    A, B = iota, iota
    C, D = iota, iota
)
```

В пределах первой строки оба `iota` равны:

```text
0
```

Поэтому:

```text
A = 0
B = 0
```

Во второй строке:

```text
iota = 1
```

Поэтому:

```text
C = 1
D = 1
```

Значит, сколько бы `iota` ни было записано в одной строке, для этой строки у них одинаковое значение.

Это пригодится для создания диапазонов в следующих примерах.

## Пропуск значения `iota` с помощью `_`

Иногда первое значение `iota` может быть не нужно.

Например, мы хотим, чтобы уровни начинались с:

```text
1
2
3
```

Один способ:

```go
const (
    PriorityLow Priority = iota + 1
    PriorityMedium
    PriorityHigh
)
```

Другой способ — пропустить первое значение через `_`:

```go
const (
    _ Priority = iota
    PriorityLow
    PriorityMedium
    PriorityHigh
)
```

В первой строке:

```text
iota = 0
```

Но значение присвоено:

```go
_
```

`_` — пустой идентификатор (blank identifier).

Это значение потом нельзя использовать.

В следующей строке:

```text
iota = 1
```

Поэтому получается:

```text
PriorityLow    = 1
PriorityMedium = 2
PriorityHigh   = 3
```

## Значения размеров с помощью `iota`

Поскольку `iota` работает с формулами, он нужен не только для создания простой последовательности:

```text
0, 1, 2, 3
```

Например, можно создать размеры файлов:

```go
type Size uint64

const (
    _ Size = 1 << (10 * iota)
    KB
    MB
    GB
)
```

На первый взгляд этот код может показаться сложным.

Разберём по шагам.

Первая строка:

```go
_ Size = 1 << (10 * iota)
```

В этой строке:

```text
iota = 0
```

Значит:

```text
1 << (10 * 0)
```

то есть:

```text
1 << 0
```

результат:

```text
1
```

Но это значение присвоено `_` и не используется.

В следующей строке:

```go
KB
```

повторяется предыдущее выражение.

На этот раз:

```text
iota = 1
```

Значит:

```text
1 << (10 * 1)
```

то есть:

```text
1 << 10
```

Это равно:

```text
1024
```

Поэтому:

```text
KB = 1024
```

В следующей строке:

```text
iota = 2
```

Значит:

```text
MB = 1 << 20
```

Результат:

```text
1048576
```

Следующее значение:

```text
GB = 1 << 30
```

Результат:

```text
1073741824
```

Значит:

```text
KB = 1024
MB = 1048576
GB = 1073741824
```

Здесь `iota` использован как переменная внутри формулы.

## В каждой группе `const` `iota` начинается заново

`iota` не увеличивается на протяжении всей программы.

Каждый раз, когда открывается новая группа:

```go
const (
    ...
)
```

`iota` снова начинается с:

```text
0
```

Например:

```go
const (
    A = iota
    B
)

const (
    C = iota
    D
)
```

Результат:

```text
A = 0
B = 1

C = 0
D = 1
```

Вторая группа `const` не продолжает первую.

Это очень важно.

Потому что в проекте может быть несколько отдельных типов, похожих на enum, и их значения `iota` не влияют друг на друга.

## Текстовое представление

У значений, похожих на enum, есть ещё одна проблема.

Например:

```go
fmt.Println(StatusProcessing)
```

если не написан никакой дополнительный метод, выводит:

```text
2
```

Внутри программы этого числа может быть достаточно.

Но:

* в логах;
* при отладке;
* в CLI-программе;
* в результатах, показываемых пользователю;

трудно понять, что означает `2`.

Поэтому к именованному типу можно добавить метод `String()`.

Например:

```go
package main

import "fmt"

type Status int

const (
	StatusUnknown Status = iota
	StatusPending
	StatusProcessing
	StatusCompleted
)

func (s Status) String() string {
	switch s {
	case StatusUnknown:
		return "unknown"

	case StatusPending:
		return "pending"

	case StatusProcessing:
		return "processing"

	case StatusCompleted:
		return "completed"

	default:
		return fmt.Sprintf("Status(%d)", s)
	}
}

func main() {
	fmt.Println(StatusProcessing)
	fmt.Println(Status(99))
}
```

Результат:

```text
processing
Status(99)
```

Как это работает?

У типа `Status` есть метод:

```go
String() string
```

а именно:

```go
func (s Status) String() string
```

Это соответствует интерфейсу `fmt.Stringer`:

```go
type Stringer interface {
    String() string
}
```

Поэтому функции пакета `fmt` при выводе значения `Status` могут использовать его метод `String()`.

Например:

```go
fmt.Println(StatusProcessing)
```

вместо простого:

```text
2
```

выводит:

```text
processing
```

### Выбор имени через `switch`

Внутри метода через:

```go
switch s {
case StatusUnknown:
    return "unknown"

case StatusPending:
    return "pending"

case StatusProcessing:
    return "processing"

case StatusCompleted:
    return "completed"
}
```

каждому числовому значению сопоставлен текст.

Например, хотя значение:

```go
StatusProcessing
```

равно:

```text
2
```

`String()` возвращает:

```text
processing
```

### Зачем нужен `default`?

В конце метода есть:

```go
default:
    return fmt.Sprintf("Status(%d)", s)
```

Писать это важно.

Потому что тип, похожий на enum, в Go не ограничен объявленными константами.

Например, можно написать:

```go
Status(99)
```

Поэтому, если бы `String()` просто делал:

```go
return "unknown"
```

он мог бы скрыть настоящее неизвестное значение.

Вместо этого вывод:

```text
Status(99)
```

гораздо полезнее для отладки и логов.

Мы сразу видим:

> В систему пришло неожиданное значение 99

В больших перечислениях писать десятки или сотни `case` может быть неудобно.

В таких случаях можно использовать инструменты, которые автоматически генерируют метод `String()`.

Но сгенерированными файлами нужно управлять по правилам проекта и репозитория.

## Enum — не закрытое множество

У похожего на enum подхода в Go есть очень важное отличие.

Мы создали такой тип:

```go
type Status int
```

и объявили только четыре константы:

```go
const (
    StatusUnknown Status = iota
    StatusPending
    StatusProcessing
    StatusCompleted
)
```

Эти значения:

```text
0
1
2
3
```

Но это не означает:

> `Status` может быть только 0, 1, 2 или 3

Следующий код тоже компилируется:

```go
status := Status(99)
```

Это вполне допустимое значение `Status`.

Поэтому этот подход в Go не создаёт закрытое множество, как строгий enum в некоторых других языках.

### Почему это важно?

Если значения используются только внутри нашего кода, мы обычно используем константы:

```go
StatusPending
StatusCompleted
```

Но когда данные приходят из внешнего источника, ситуация другая.

Например, через:

* HTTP-запрос;
* JSON;
* базу данных;
* брокер сообщений;
* файл;
* другой сервис;

может прийти значение:

```text
99
```

Превратить его в:

```go
Status(99)
```

технически возможно.

Но оно может не соответствовать бизнес-правилам.

Поэтому внешние значения нужно валидировать.

Например:

```go
func (s Status) Valid() bool {
    return s >= StatusUnknown && s <= StatusCompleted
}
```

Теперь можно проверить:

```go
status := Status(2)

if !status.Valid() {
    // неверный статус
}
```

Для `Status(99)`:

```go
Status(99).Valid()
```

результат:

```text
false
```

### Всегда ли достаточно проверки диапазона?

Приём:

```go
return s >= StatusUnknown && s <= StatusCompleted
```

хорошо работает, когда константы идут подряд.

Например:

```text
0
1
2
3
```

Но если значения такие:

```text
1
5
10
20
```

проверка диапазона может быть неправильной.

В таком случае лучше использовать `switch`:

```go
func (s Status) Valid() bool {
    switch s {
    case StatusUnknown,
        StatusPending,
        StatusProcessing,
        StatusCompleted:
        return true

    default:
        return false
    }
}
```

Этот приём принимает только действительно объявленные значения.

## `iota` и внешние форматы

При использовании `iota` есть ещё одна важная опасность.

Предположим:

```go
const (
    StatusUnknown Status = iota
    StatusPending
    StatusProcessing
    StatusCompleted
)
```

значения:

```text
0
1
2
3
```

Теперь представим, что мы записали эти числа в базу данных.

Например:

```text
2 = processing
3 = completed
```

Позже мы добавили в код новый статус:

```go
const (
    StatusUnknown Status = iota
    StatusPending
    StatusWaiting
    StatusProcessing
    StatusCompleted
)
```

Теперь значения стали такими:

```text
StatusUnknown    = 0
StatusPending    = 1
StatusWaiting    = 2
StatusProcessing = 3
StatusCompleted  = 4
```

Значение в прежней базе данных:

```text
2
```

раньше было:

```text
processing
```

А в новом коде стало:

```text
waiting
```

Это может привести к очень серьёзной ошибке.

Поэтому нужно быть осторожным, если значения `iota` связаны с внешней системой.

Сюда относятся:

* база данных;
* публичный API;
* протокол, похожий на protobuf;
* формат файла;
* брокер сообщений;
* коды, согласованные с другим сервисом.

В таком случае есть два более безопасных подхода.

### Добавлять новые значения только в конец

Например:

```go
const (
    StatusUnknown Status = iota
    StatusPending
    StatusProcessing
    StatusCompleted

    StatusCanceled
)
```

Здесь старые значения не меняются.

### Писать явные числа

Если коды — внешний контракт, ещё более явный способ:

```go
const (
    StatusUnknown    Status = 0
    StatusPending    Status = 10
    StatusProcessing Status = 20
    StatusCompleted  Status = 30
)
```

Теперь добавление нового значения не сдвигает старые значения автоматически.

## Углубление: битовые флаги

Битовые флаги используются, когда в одном значении нужно хранить несколько независимых состояний. На начальном этапе достаточно понимать простую последовательность `iota`; к этому разделу можно вернуться позже.

`iota` нужен не только для создания простых последовательностей, похожих на enum.

Он также очень удобен для создания **битовых флагов** (bit flags).

Например, пусть у пользователя есть следующие права:

* чтение;
* запись;
* удаление.

В простом enum можно сделать:

```text
Read   = 0
Write  = 1
Delete = 2
```

Но у одного пользователя должно быть несколько прав одновременно.

Например:

```text
Read + Write
```

В таком случае можно использовать битовую маску (bitmask).

```go
type Permission uint8

const (
    PermissionRead Permission = 1 << iota
    PermissionWrite
    PermissionDelete
)
```

Здесь значения:

```text
PermissionRead   = 1
PermissionWrite  = 2
PermissionDelete = 4
```

Почему?

Для первой строки:

```go
1 << iota
```

имеем:

```text
iota = 0
```

Значит:

```text
1 << 0 = 1
```

В двоичном виде:

```text
00000001
```

Следующая строка:

```text
iota = 1
```

Значит:

```text
1 << 1 = 2
```

В двоичном виде:

```text
00000010
```

Следующая:

```text
1 << 2 = 4
```

В двоичном виде:

```text
00000100
```

Важно, что в каждом значении установлен отдельный бит.

## Объединение битовых флагов

Битовые флаги можно объединять оператором побитового ИЛИ:

```go
|
```

Например:

```go
permissions := PermissionRead | PermissionWrite
```

В двоичном виде:

```text
PermissionRead  = 00000001
PermissionWrite = 00000010
```

При использовании `|` получается:

```text
00000001
00000010
--------
00000011
```

В десятичном виде это:

```text
3
```

Значит:

```go
permissions == 3
```

Но это `3` — не третье значение enum в обычном смысле.

В нём два флага:

```text
Read
Write
```

## Проверка наличия флага

Например, мы хотим проверить, есть ли в значении `PermissionRead`.

Для этого используется:

```go
value & permission
```

Например:

```go
func has(value, permission Permission) bool {
    return value&permission != 0
}
```

Если:

```go
permissions := PermissionRead | PermissionWrite
```

то:

```go
has(permissions, PermissionRead)
```

даёт:

```text
true
```

А:

```go
has(permissions, PermissionDelete)
```

даёт:

```text
false
```

Битовые флаги удобны в следующих случаях:

* права доступа;
* feature flags;
* настройки уведомлений;
* режимы файлов;
* флаги протоколов;
* хранение нескольких независимых состояний `true/false` в одном числе.

## Примеры

### 1. Дни недели начиная с единицы

В этом примере `iota + 1` даёт дням недели значения начиная с `1`.

```go
package main

import "fmt"

type Weekday int

const (
	Monday Weekday = iota + 1
	Tuesday
	Wednesday
	Thursday
	Friday
	Saturday
	Sunday
)

func main() {
	fmt.Println(Monday, Wednesday, Sunday)
}
```

В первой строке написано:

```go
Monday Weekday = iota + 1
```

В этой строке:

```text
iota = 0
```

Значит:

```text
Monday = 0 + 1 = 1
```

В следующей строке отдельное выражение не написано:

```go
Tuesday
```

Go повторяет предыдущее выражение:

```go
iota + 1
```

В этой строке:

```text
iota = 1
```

Поэтому:

```text
Tuesday = 2
```

Так же:

```text
Monday    = 1
Tuesday   = 2
Wednesday = 3
Thursday  = 4
Friday    = 5
Saturday  = 6
Sunday    = 7
```

Поэтому результат:

```go
fmt.Println(Monday, Wednesday, Sunday)
```

равен:

```text
1 3 7
```

Этот приём удобен в ситуациях, когда значение `0` не должно использоваться как день недели.

Также он может упростить соответствие формату, который видит пользователь или который используется в другой системе:

```text
1 = Monday
...
7 = Sunday
```

### 2. Нулевое значение для неизвестного состояния

В этом примере нулевое значение типа обозначает отдельное состояние `Unknown`.

```go
package main

import "fmt"

type DeliveryStatus int

const (
	DeliveryUnknown DeliveryStatus = iota
	DeliveryAccepted
	DeliveryOnTheWay
	DeliveryArrived
)

func main() {
	var status DeliveryStatus

	fmt.Println(status == DeliveryUnknown)

	status = DeliveryOnTheWay

	fmt.Println(status)
}
```

Сначала создана переменная:

```go
var status DeliveryStatus
```

Ей не присвоено значение.

Поскольку `DeliveryStatus` — тип на основе `int`, его нулевое значение:

```text
0
```

В наших константах:

```go
DeliveryUnknown DeliveryStatus = iota
```

тоже равно:

```text
0
```

Поэтому результат:

```go
status == DeliveryUnknown
```

равен:

```text
true
```

Это хороший дизайн.

Потому что если статус доставки ещё не задан, его можно понимать как:

```text
0 = Unknown
```

Затем задан реальный статус:

```go
status = DeliveryOnTheWay
```

Значения:

```text
DeliveryUnknown  = 0
DeliveryAccepted = 1
DeliveryOnTheWay = 2
DeliveryArrived  = 3
```

Поэтому результат:

```go
fmt.Println(status)
```

равен:

```text
2
```

В этом подходе реальные бизнес-состояния начинаются с `1`, а `0` используется в смысле «пока неизвестно».

### 3. Пропуск ненужного первого значения

В этом примере первое значение `iota` не используется благодаря `_`.

```go
package main

import "fmt"

type Priority int

const (
	_ Priority = iota
	PriorityLow
	PriorityMedium
	PriorityHigh
)

func main() {
	fmt.Println(
		PriorityLow,
		PriorityMedium,
		PriorityHigh,
	)
}
```

В первой строке:

```go
_ Priority = iota
```

`iota` равен:

```text
0
```

Но значение присвоено пустому идентификатору:

```go
_
```

Поэтому для этого значения нет отдельного имени константы.

В следующей строке:

```text
iota = 1
```

Значит:

```text
PriorityLow = 1
```

Следующее:

```text
PriorityMedium = 2
```

и:

```text
PriorityHigh = 3
```

Результат:

```text
1 2 3
```

Этот приём удобен, когда `0` не должен быть реальным значением.

Например, `0` может оставаться скрытым состоянием, означающим:

```text
приоритет ещё не задан
```

### 4. Увеличение значений с шагом десять

Мы видели, что `iota` можно использовать внутри формулы.

В следующем примере коды создаются в виде:

```text
10
20
30
```

```go
package main

import "fmt"

type DepartmentCode int

const (
	DepartmentSales DepartmentCode = (iota + 1) * 10
	DepartmentSupport
	DepartmentWarehouse
)

func main() {
	fmt.Println(
		DepartmentSales,
		DepartmentSupport,
		DepartmentWarehouse,
	)
}
```

В первой строке использована формула:

```go
(iota + 1) * 10
```

В этой строке:

```text
iota = 0
```

Значит:

```text
(0 + 1) * 10 = 10
```

Поэтому:

```text
DepartmentSales = 10
```

Для следующей строки:

```text
iota = 1
```

Значит:

```text
(1 + 1) * 10 = 20
```

Поэтому:

```text
DepartmentSupport = 20
```

Следующее:

```text
(2 + 1) * 10 = 30
```

Значит:

```text
DepartmentWarehouse = 30
```

Результат:

```text
10 20 30
```

Этот приём можно использовать, когда между кодами нужно оставить промежутки.

Но если эти значения — постоянный контракт с базой данных или внешним API, вместо `iota` часто безопаснее писать явные числа.

### 5. Связанные значения в одной строке

В одной строке `ConstSpec` можно объявить несколько констант.

Все `iota` в этой строке имеют одинаковое значение.

Например:

```go
package main

import "fmt"

const (
	SmallMin, SmallMax = iota * 10, iota*10 + 9
	MediumMin, MediumMax
	LargeMin, LargeMax
)

func main() {
	fmt.Println(SmallMin, SmallMax)
	fmt.Println(MediumMin, MediumMax)
	fmt.Println(LargeMin, LargeMax)
}
```

В первой строке:

```go
SmallMin, SmallMax = iota * 10, iota*10 + 9
```

`iota` равен:

```text
0
```

`iota` в обоих выражениях одинаков:

```text
0
```

Поэтому:

```text
SmallMin = 0 * 10     = 0
SmallMax = 0 * 10 + 9 = 9
```

Результат:

```text
0–9
```

В следующей строке выражение не написано:

```go
MediumMin, MediumMax
```

Go повторяет два предыдущих выражения.

В этой строке:

```text
iota = 1
```

Поэтому:

```text
MediumMin = 10
MediumMax = 19
```

В следующей строке:

```text
iota = 2
```

Результат:

```text
LargeMin = 20
LargeMax = 29
```

Значит, образуются три диапазона:

```text
Small  = 0–9
Medium = 10–19
Large  = 20–29
```

Этот пример показывает, что когда в одной строке используется несколько `iota`, они получают одинаковое значение для этой строки.

### 6. Перезапуск в каждой группе `const`

Следующий пример показывает, что `iota` снова становится `0` в новом блоке `const`.

```go
package main

import "fmt"

const (
	North = iota
	East
)

const (
	Draft = iota
	Published
)

func main() {
	fmt.Println(North, East)
	fmt.Println(Draft, Published)
}
```

В первой группе `const`:

```go
const (
    North = iota
    East
)
```

значения:

```text
North = 0
East  = 1
```

Затем открыта новая группа:

```go
const (
    Draft = iota
    Published
)
```

Здесь `iota` не продолжает с:

```text
2
```

Он снова начинается с:

```text
0
```

Поэтому:

```text
Draft     = 0
Published = 1
```

Результат:

```text
0 1
0 1
```

У каждой отдельной группы `const` свой счётчик `iota`.

Это гарантирует, что разные группы, похожие на enum, не влияют друг на друга.

### 7. Объединение прав на файл

В этом примере `iota` используется для создания битовых флагов.

```go
package main

import "fmt"

type FilePermission uint8

const (
	CanRead FilePermission = 1 << iota
	CanWrite
	CanExecute
)

func main() {
	permissions := CanRead | CanWrite

	fmt.Println(permissions)

	fmt.Println(permissions&CanRead != 0)
	fmt.Println(permissions&CanExecute != 0)
}
```

Сначала вычислим значения.

Первое:

```go
CanRead FilePermission = 1 << iota
```

Здесь:

```text
iota = 0
```

Значит:

```text
1 << 0 = 1
```

Поэтому:

```text
CanRead = 1
```

В двоичном виде:

```text
00000001
```

Следующее:

```text
CanWrite = 1 << 1 = 2
```

В двоичном виде:

```text
00000010
```

Следующее:

```text
CanExecute = 1 << 2 = 4
```

В двоичном виде:

```text
00000100
```

Теперь пишем:

```go
permissions := CanRead | CanWrite
```

В двоичном виде:

```text
00000001  CanRead
00000010  CanWrite
--------
00000011
```

В результате:

```text
permissions = 3
```

Но в этом `3` содержатся два независимых флага.

Затем проверяется:

```go
permissions&CanRead != 0
```

Поскольку бит `CanRead` установлен, результат:

```text
true
```

Затем проверяется:

```go
permissions&CanExecute != 0
```

Бит `CanExecute` не установлен.

Поэтому результат:

```text
false
```

Этот подход позволяет хранить в одном значении несколько независимых прав.

### 8. Удаление флага из значения

Битовые флаги можно не только добавлять, но и удалять.

Для этого в Go есть оператор:

```go
&^
```

Он используется для **очистки битов** (bit clear), то есть для сброса определённых битов.

```go
package main

import "fmt"

type Notification uint8

const (
	NotifyEmail Notification = 1 << iota
	NotifySMS
	NotifyPush
)

func main() {
	settings := NotifyEmail | NotifySMS | NotifyPush

	settings &^= NotifySMS

	fmt.Println(settings&NotifyEmail != 0)
	fmt.Println(settings&NotifySMS != 0)
	fmt.Println(settings&NotifyPush != 0)
}
```

Сначала значения:

```text
NotifyEmail = 1
NotifySMS   = 2
NotifyPush  = 4
```

В двоичном виде:

```text
NotifyEmail = 001
NotifySMS   = 010
NotifyPush  = 100
```

Затем:

```go
settings := NotifyEmail | NotifySMS | NotifyPush
```

объединяет все три флага:

```text
001
010
100
---
111
```

Значит, сначала включены все три типа уведомлений.

Затем пишем:

```go
settings &^= NotifySMS
```

Это означает:

> сбрось бит, относящийся к `NotifySMS`

В результате из:

```text
111
```

остаётся:

```text
101
```

Значит:

```text
Email = включено
SMS   = выключено
Push  = включено
```

Поэтому:

```go
settings&NotifyEmail != 0
```

даёт:

```text
true
```

```go
settings&NotifySMS != 0
```

даёт:

```text
false
```

и:

```go
settings&NotifyPush != 0
```

даёт:

```text
true
```

Результаты:

```text
true
false
true
```

### 9. Преобразование значений enum в текст

Статус в числовом виде может быть непонятен при выводе пользователю или в лог.

Поэтому для него можно написать метод, возвращающий текст.

```go
package main

import "fmt"

type OrderStatus int

const (
	OrderNew OrderStatus = iota
	OrderPaid
	OrderSent
)

func (s OrderStatus) Label() string {
	switch s {
	case OrderNew:
		return "новый"

	case OrderPaid:
		return "оплачен"

	case OrderSent:
		return "отправлен"

	default:
		return "неизвестно"
	}
}

func main() {
	fmt.Println(OrderPaid.Label())
	fmt.Println(OrderStatus(20).Label())
}
```

Значения:

```text
OrderNew  = 0
OrderPaid = 1
OrderSent = 2
```

Затем вызывается:

```go
OrderPaid.Label()
```

Метод попадает в строку:

```go
case OrderPaid:
    return "оплачен"
```

Результат:

```text
оплачен
```

Следующее:

```go
OrderStatus(20).Label()
```

— очень важный пример.

`20` нет среди объявленных констант.

Но Go разрешает преобразование:

```go
OrderStatus(20)
```

Поэтому ни один из основных `case` в `switch` не подходит, и выполняется:

```go
default:
    return "неизвестно"
```

Результат:

```text
неизвестно
```

Это ещё раз показывает, что тип, похожий на enum, в Go — не закрытое множество значений.

Метод `Label()` можно использовать в основном для пользовательского интерфейса.

Если для логов и отладки нужно видеть и само неизвестное число, полезнее написать что-то вроде:

```go
return fmt.Sprintf("неизвестно(%d)", s)
```

### 10. Явные коды для внешнего формата

Использовать `iota` не всегда обязательно.

Особенно если числовые значения констант согласованы с внешней системой, писать явные числа безопаснее.

```go
package main

import "fmt"

type PaymentCode int

const (
	PaymentCreated  PaymentCode = 100
	PaymentApproved PaymentCode = 200
	PaymentRejected PaymentCode = 400
)

func main() {
	codes := []PaymentCode{
		PaymentCreated,
		PaymentApproved,
		PaymentRejected,
	}

	for _, code := range codes {
		fmt.Println(code)
	}
}
```

Здесь значения:

```go
PaymentCreated = 100
```

```go
PaymentApproved = 200
```

и:

```go
PaymentRejected = 400
```

заданы явно вручную.

Например, представим, что эти значения согласованы с другим API:

```text
100 = payment created
200 = payment approved
400 = payment rejected
```

В такой ситуации использование:

```go
iota
```

может быть рискованнее.

Потому что если новая константа добавится в середину, значения `iota` после неё могут сдвинуться.

А при записи явными числами:

```go
const (
    PaymentCreated  PaymentCode = 100
    PaymentApproved PaymentCode = 200
    PaymentRejected PaymentCode = 400
)
```

переупорядочивание констант или добавление нового значения между ними не меняет существующие коды автоматически.

Например, даже если добавить новый статус:

```go
const (
    PaymentCreated  PaymentCode = 100
    PaymentPending  PaymentCode = 150
    PaymentApproved PaymentCode = 200
    PaymentRejected PaymentCode = 400
)
```

значения:

```text
PaymentCreated  = 100
PaymentApproved = 200
PaymentRejected = 400
```

остаются без изменений.

Это особенно важно для:

* публичного API;
* базы данных;
* интеграции с другим сервисом;
* брокера сообщений;
* формата файла;
* данных, хранящихся долгое время.

Поэтому, прежде чем использовать `iota` просто для сокращения кода, нужно учесть, несут ли сами числа внешний смысл.
