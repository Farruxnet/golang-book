# Работа с JSON в Go

JSON — текстовый формат обмена данными. Он используется в веб-API, конфигурационных файлах, при обмене данными между сервисами и во многих других местах.

В Go для работы с JSON есть пакет `encoding/json` из стандартной библиотеки.

Этот пакет работает в двух основных направлениях:

* преобразование JSON-данных в значение Go — **декодирование** (decode);
* преобразование значения Go в JSON — **кодирование** (encode).

Например, с сервера может прийти такой JSON:

```json
{
  "name": "Ali",
  "active": true
}
```

Программа на Go может декодировать эти данные в `struct`, `map`, `slice` или другой подходящий тип.

И наоборот, значение `struct` внутри Go можно преобразовать в JSON и записать в HTTP-ответ или файл.

## Типы JSON и Go

Типы JSON и Go не совпадают. Поэтому `encoding/json` преобразует значение JSON в подходящий тип Go.

Обычно соответствие такое:

| JSON    | Обычный тип в Go                                  |
| ------- | ------------------------------------------------- |
| string  | `string`                                          |
| number  | `int`, `float64` или другой числовой тип          |
| boolean | `bool`                                            |
| array   | slice или массив                                  |
| object  | struct или map                                    |
| null    | `nil` для указателя, slice, map или интерфейса    |

Например, такой JSON:

```json
{
  "name": "Ali",
  "age": 30,
  "active": true,
  "roles": ["editor", "author"]
}
```

может соответствовать такой структуре Go:

```go
type User struct {
	Name   string
	Age    int
	Active bool
	Roles  []string
}
```

Здесь:

* значение JSON `string` записывается в `string`;
* значение JSON `number` — в `int`;
* значение JSON `boolean` — в `bool`;
* а массив JSON — в slice `[]string`.

При декодировании в структуру есть важное правило: используются только **экспортируемые поля**.

В Go поле считается экспортированным, если его имя начинается с заглавной буквы.

Например:

```go
type User struct {
	Name string
	age  int
}
```

В этой структуре `Name` экспортировано, а `age` — нет.

Поэтому `encoding/json` может работать с `Name`, но не может записать значение в поле `age` и не выводит его в JSON.

## Теги структур

Ключи JSON и имена полей Go не обязаны совпадать. Для управления этим используются теги структур (struct tag).

```go
type User struct {
	Name     string   `json:"name"`
	Email    string   `json:"email,omitempty"`
	Password string   `json:"-"`
	Roles    []string `json:"roles"`
}
```

Здесь каждая запись `json:"..."` сообщает пакету `encoding/json`, как работать с полем.

### Задание ключа JSON

```go
Name string `json:"name"`
```

Имя поля Go — `Name`, а ключ в JSON — `name`.

Например:

```go
user := User{Name: "Ali"}
```

при кодировании в JSON выглядит так:

```json
{
  "name": "Ali"
}
```

Если тег не указан, пакет обычно использует собственное имя поля.

### `omitempty`

```go
Email string `json:"email,omitempty"`
```

`omitempty` означает, что поле не включается в результат JSON, если его значение считается пустым.

Например:

```go
user := User{
	Name:  "Ali",
	Email: "",
}
```

при кодировании поля `email` в результате может не быть.

Это удобно, чтобы не отправлять в ответе API лишние пустые поля.

Но при использовании `omitempty` может понадобиться различать нулевое значение и случай «значение не задано».

Например, `false` для `bool` и `0` для `int` тоже считаются пустыми значениями. Если `false` или `0` — реальное бизнес-значение, может понадобиться указатель или другая модель.

### Полное исключение поля

```go
Password string `json:"-"`
```

`json:"-"` полностью исключает поле из работы с JSON.

Это поле:

* не кодируется в JSON;
* не декодируется из JSON.

Это полезно, например, для внутренних или секретных полей.

Но считать безопасность полностью решённой, полагаясь только на `json:"-"`, неправильно. Где и как используются секретные данные, нужно контролировать отдельно.

## `Marshal` и `Unmarshal`

`json.Marshal()` и `json.Unmarshal()` удобны для работы с JSON-данными, полностью находящимися в памяти.

`json.Marshal()` преобразует значение Go в `[]byte` с JSON.

А `json.Unmarshal()` декодирует `[]byte` с JSON в значение Go.

```go
data, err := json.Marshal(User{Name: "Ali", Roles: []string{"editor"}})
if err != nil {
	return err
}

var user User
if err := json.Unmarshal(data, &user); err != nil {
	return err
}
```

Рассмотрим первую часть:

```go
data, err := json.Marshal(User{Name: "Ali", Roles: []string{"editor"}})
```

Здесь значение `User` кодируется в JSON.

Результат возвращается не как `string`, а как `[]byte`.

Получаются примерно такие данные:

```json
{"name":"Ali","roles":["editor"]}
```

Затем:

```go
var user User
```

создаёт новое значение `User`. Пока его поля в состоянии нулевого значения.

Затем:

```go
json.Unmarshal(data, &user)
```

записывает JSON в эту структуру.

Здесь важна причина, по которой передаётся `&user`.

`Unmarshal` должен изменить существующее значение. Поэтому ему передают не саму структуру, а указатель, через который можно записывать.

Так писать неправильно:

```go
json.Unmarshal(data, user)
```

Потому что запись значений в копию `user` не может изменить структуру вызывающего кода.

Правильный вариант:

```go
json.Unmarshal(data, &user)
```

Для небольшого JSON, полностью находящегося в памяти, `Marshal` и `Unmarshal` обычно самое простое решение.

Например:

* небольшой JSON-столбец, полученный из базы данных;
* JSON внутри теста;
* небольшое тело HTTP-ответа, уже прочитанное в `[]byte`.

Для больших потоков лучше могут подойти `Encoder` и `Decoder`.

## `Encoder` и `Decoder`

`json.Encoder` и `json.Decoder` работают с `io.Writer` и `io.Reader`.

Это делает их удобными для работы с потоками.

Например:

```go
if err := json.NewEncoder(os.Stdout).Encode(user); err != nil {
	return err
}
```

Здесь:

```go
json.NewEncoder(os.Stdout)
```

создаёт encoder, пишущий в `os.Stdout`.

`os.Stdout` реализует интерфейс `io.Writer`. Поэтому `Encoder` может записать результат JSON прямо в терминал.

Затем:

```go
Encode(user)
```

преобразует значение `user` в JSON и записывает результат во writer.

При этом не нужно отдельно делать:

```go
data, err := json.Marshal(user)
```

чтобы получить `[]byte`, а потом записать его во writer.

У `Encode` есть ещё одно важное свойство: после значения JSON он добавляет перевод строки.

Например, результат записывается как:

```text
{"name":"Ali","roles":["editor"]}
```

и в конце стоит `\n`.

### `Decoder`

А `Decoder` читает JSON из `io.Reader`.

Например:

```go
dec := json.NewDecoder(r)

var user User
if err := dec.Decode(&user); err != nil {
	return err
}
```

Здесь `r` может быть:

* файлом;
* телом HTTP-запроса;
* TCP-соединением;
* `strings.Reader`;
* другим `io.Reader`.

При работе с потоком, например файлом, терминалом или сетевым соединением, `Encoder` и `Decoder` помогают не создавать лишний промежуточный `[]byte`.

Это особенно удобно, когда данные уже представлены в виде reader или writer.

## Строгое декодирование

Обычный `json.Decoder` обычно игнорирует неизвестные поля внутри объекта JSON.

В некоторых случаях это удобно.

Но в конфигурационных файлах это может быть опасно.

Например, структура конфигурации:

```go
type Config struct {
	Debug bool `json:"debug"`
}
```

а пользователь по ошибке пишет:

```json
{
  "debgu": true
}
```

`debgu` в структуре нет.

Если неизвестные поля игнорируются, программа может работать без ошибки. А пользователь думает, что `debug` включён.

В таком случае полезен `DisallowUnknownFields()`.

Он возвращает ошибку, если внутри объекта JSON встречается поле, не соответствующее структуре.

Нужно также проверить, что после одного значения JSON не идёт другое значение JSON.

```go
func decodeConfig(r io.Reader) (Config, error) {
	var cfg Config
	dec := json.NewDecoder(r)
	dec.DisallowUnknownFields()

	if err := dec.Decode(&cfg); err != nil {
		return Config{}, fmt.Errorf("не удалось прочитать JSON: %w", err)
	}

	if err := dec.Decode(&struct{}{}); err != io.EOF {
		if err == nil {
			return Config{}, errors.New("ожидалось только одно значение JSON")
		}

		return Config{}, fmt.Errorf("лишнее значение JSON: %w", err)
	}

	return cfg, nil
}
```

Для этой функции нужны такие пакеты:

```go
import (
	"encoding/json"
	"errors"
	"fmt"
	"io"
)
```

Теперь разберём функцию по шагам.

Сначала:

```go
dec := json.NewDecoder(r)
```

создаётся decoder, работающий поверх reader.

Затем:

```go
dec.DisallowUnknownFields()
```

включает режим, в котором неизвестные поля JSON считаются ошибкой.

Первый `Decode`:

```go
if err := dec.Decode(&cfg); err != nil {
	return Config{}, fmt.Errorf("не удалось прочитать JSON: %w", err)
}
```

записывает основное значение JSON в `cfg`.

Если синтаксис неверен или значение не соответствует типу структуры, ошибка может вернуться здесь.

Затем выполняется второй `Decode`:

```go
if err := dec.Decode(&struct{}{}); err != io.EOF {
```

Это не для чтения нового бизнес-значения. Цель — проверить, есть ли ещё данные после первого значения JSON.

Если поток закончился, `Decode` возвращает `io.EOF`.

Это нужный случай:

```text
первое значение JSON прочитано
↓
Decode вызван снова
↓
вернулся io.EOF
↓
значит, другого значения JSON нет
```

Но если input такой:

```json
{"debug": true}
{"debug": false}
```

первый `Decode` читает только первый объект.

Второй `Decode` находит второй объект. В результате можно обнаружить, что правило «ожидалось только одно значение JSON» нарушено.

Это особенно важно для строгих входных данных, таких как конфигурация.

## Типы ошибок

`encoding/json` возвращает некоторые ошибки через специальные типы.

Это позволяет точнее определить причину ошибки.

Неверный синтаксис JSON может быть `*json.SyntaxError`.

Например:

```json
{"name":"Ali",
```

Этот JSON не закрыт.

Если значение JSON не соответствует типу поля Go, может вернуться `*json.UnmarshalTypeError`.

Например:

```go
type User struct {
	Age int `json:"age"`
}
```

а JSON:

```json
{
  "age": "тридцать"
}
```

тогда значение `string` нельзя записать в `int`.

Ошибку можно проверить через `errors.As`:

```go
var syntaxErr *json.SyntaxError
var typeErr *json.UnmarshalTypeError

switch {
case errors.As(err, &syntaxErr):
	fmt.Printf("ошибка синтаксиса JSON, offset: %d\n", syntaxErr.Offset)

case errors.As(err, &typeErr):
	fmt.Printf("неверный тип для поля %s\n", typeErr.Field)

default:
	fmt.Println("не удалось прочитать JSON")
}
```

В первом случае:

```go
errors.As(err, &syntaxErr)
```

проверяет, есть ли в цепочке ошибок `*json.SyntaxError`.

Если есть:

```go
syntaxErr.Offset
```

показывает, примерно на какой позиции в байтах потока JSON произошла ошибка.

Во втором случае:

```go
errors.As(err, &typeErr)
```

определяет, что ошибка — `*json.UnmarshalTypeError`.

`typeErr.Field` может дать информацию о поле структуры.

Эта диагностика полезна в логах.

Но возвращать пользователю этот внутренний текст ошибки полностью не всегда хорошо.

Например, в логе могут оказаться:

* пути к файлам;
* внутренние имена структур;
* секретные значения;
* детали реализации.

Поэтому обычно лучше хранить внутреннюю диагностику в логе, а внешнему пользователю возвращать короткое и безопасное сообщение.

Например:

```text
Неверный формат JSON конфигурации.
```

А для API можно вернуть общую ошибку с подходящим HTTP-статусом.

## Пример конфигурации

Следующий пример показывает совместное использование `Decoder` и `DisallowUnknownFields()`.

```go
package main

import (
	"encoding/json"
	"fmt"
	"log"
	"strings"
)

type Config struct {
	Address string `json:"address"`
	Debug   bool   `json:"debug"`
}

func main() {
	input := `{"address":"localhost:8080","debug":true}`

	var cfg Config

	dec := json.NewDecoder(strings.NewReader(input))
	dec.DisallowUnknownFields()

	if err := dec.Decode(&cfg); err != nil {
		log.Fatal("не удалось прочитать конфигурацию: ", err)
	}

	fmt.Printf("Адрес: %s, debug: %t\n", cfg.Address, cfg.Debug)
}
```

Этот пример намеренно не привязан к файлу или HTTP-запросу.

Сначала JSON задан обычной строкой:

```go
input := `{"address":"localhost:8080","debug":true}`
```

Затем:

```go
strings.NewReader(input)
```

позволяет рассматривать эту строку как `io.Reader`.

В результате `json.Decoder` может читать строку так же, как если бы читал файл или сетевой поток.

Следующая строка:

```go
dec.DisallowUnknownFields()
```

запрещает неизвестные поля.

Например, если input написан с ошибкой:

```json
{
  "adress": "localhost:8080",
  "debug": true
}
```

`adress` не соответствует полю `address` в структуре.

Тогда decoder вернёт ошибку.

Основное декодирование:

```go
if err := dec.Decode(&cfg); err != nil {
	log.Fatal("не удалось прочитать конфигурацию: ", err)
}
```

записывает значения JSON в структуру `cfg`.

После декодирования получается примерно такое значение:

```go
Config{
	Address: "localhost:8080",
	Debug:   true,
}
```

В конце:

```go
fmt.Printf("Адрес: %s, debug: %t\n", cfg.Address, cfg.Debug)
```

выводит значения в терминал.

Результат:

```text
Адрес: localhost:8080, debug: true
```

Главное правило этого примера: `Decoder` не ограничен файлами или HTTP.

Ему достаточно передать `io.Reader`.

Поэтому один и тот же код декодирования может работать с разными источниками, например:

* `os.File`;
* `http.Request.Body`;
* `strings.Reader`;
* `bytes.Reader`;
* сетевое соединение.
