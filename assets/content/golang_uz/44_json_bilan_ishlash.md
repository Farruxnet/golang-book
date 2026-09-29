# Go’da JSON bilan ishlash

JSON — matn ko‘rinishidagi ma’lumot almashish formati. U web API, konfiguratsiya fayllari, servislar orasidagi ma’lumot almashinuvi va boshqa ko‘plab joylarda ishlatiladi.

Go’da JSON bilan ishlash uchun standart kutubxonadagi `encoding/json` paketi mavjud.

Bu paket ikki asosiy yo‘nalishda ishlaydi:

* JSON ma’lumotini Go qiymatiga aylantirish — **decode** qilish;
* Go qiymatini JSON ko‘rinishiga aylantirish — **encode** qilish.

Masalan, serverdan quyidagi JSON kelishi mumkin:

```json
{
  "name": "Ali",
  "active": true
}
```

Go dasturi bu ma’lumotni `struct`, `map`, `slice` yoki boshqa mos turga dekodlashi mumkin.

Aksincha, Go ichidagi `struct` qiymatini JSON ko‘rinishiga aylantirib, HTTP response yoki faylga yozish ham mumkin.

## JSON va Go turlari

JSON va Go turlari bir xil emas. Shuning uchun `encoding/json` JSON qiymatini mos Go turiga aylantiradi.

Odatda moslik quyidagicha bo‘ladi:

| JSON    | Go’da odatiy tur                               |
| ------- | ---------------------------------------------- |
| string  | `string`                                       |
| number  | `int`, `float64` yoki boshqa son turi          |
| boolean | `bool`                                         |
| array   | slice yoki array                               |
| object  | struct yoki map                                |
| null    | pointer, slice, map yoki interface uchun `nil` |

Masalan, quyidagi JSON:

```json
{
  "name": "Ali",
  "age": 30,
  "active": true,
  "roles": ["editor", "author"]
}
```

quyidagi Go structiga mos kelishi mumkin:

```go
type User struct {
	Name   string
	Age    int
	Active bool
	Roles  []string
}
```

Bu yerda:

* JSON `string` qiymati `string`ga;
* JSON `number` qiymati `int`ga;
* JSON `boolean` qiymati `bool`ga;
* JSON array esa `[]string` slicega yoziladi.

Struct orqali dekodlashda muhim qoida bor: faqat **export qilinadigan fieldlar** ishlatiladi.

Go’da field nomi katta harf bilan boshlansa, u export qilingan hisoblanadi.

Masalan:

```go
type User struct {
	Name string
	age  int
}
```

Bu structda `Name` eksport qilingan, `age` esa eksport qilinmagan.

Shuning uchun `encoding/json` `Name` bilan ishlay oladi, lekin `age` fieldiga qiymat yoza olmaydi va uni JSON’ga ham chiqarmaydi.

## Struct tag

JSON kalitlari bilan Go field nomlari bir xil bo‘lishi shart emas. Buni boshqarish uchun struct tag ishlatiladi.

```go
type User struct {
	Name     string   `json:"name"`
	Email    string   `json:"email,omitempty"`
	Password string   `json:"-"`
	Roles    []string `json:"roles"`
}
```

Bu yerda har bir `json:"..."` yozuvi `encoding/json` paketiga field bilan qanday ishlash kerakligini aytadi.

### JSON kalitini belgilash

```go
Name string `json:"name"`
```

Go fieldining nomi `Name`, JSON ichidagi kalit esa `name` bo‘ladi.

Masalan:

```go
user := User{Name: "Ali"}
```

JSON’ga kodlanganda:

```json
{
  "name": "Ali"
}
```

ko‘rinishida chiqadi.

Struct tag yozilmasa, paket odatda fieldning o‘z nomidan foydalanadi.

### `omitempty`

```go
Email string `json:"email,omitempty"`
```

`omitempty` fieldning qiymati bo‘sh hisoblanganda uni JSON natijasiga kiritmaslikni bildiradi.

Masalan:

```go
user := User{
	Name:  "Ali",
	Email: "",
}
```

kodlanganda `email` fieldi natijada bo‘lmasligi mumkin.

Bu API response ichida keraksiz bo‘sh fieldlarni yubormaslik uchun qulay.

Lekin `omitempty`ni ishlatishda zero value bilan “qiymat berilmagan” holatni ajratish kerak bo‘lishi mumkin.

Masalan, `bool` uchun `false`, `int` uchun `0` ham bo‘sh qiymat hisoblanadi. Agar `false` yoki `0` haqiqiy biznes qiymati bo‘lsa, pointer yoki boshqa model kerak bo‘lishi mumkin.

### Fieldni butunlay chiqarib tashlash

```go
Password string `json:"-"`
```

`json:"-"` fieldni JSON bilan ishlashdan butunlay chiqaradi.

Bu field:

* JSON’ga kodlanmaydi;
* JSON’dan dekodlanmaydi.

Bu, masalan, ichki yoki maxfiy fieldlar uchun foydali.

Lekin faqat `json:"-"`ga tayanib xavfsizlikni to‘liq hal qilingan deb hisoblash to‘g‘ri emas. Maxfiy ma’lumot qayerda va qanday ishlatilayotganini alohida nazorat qilish kerak.

## `Marshal` va `Unmarshal`

`json.Marshal()` va `json.Unmarshal()` xotirada to‘liq mavjud bo‘lgan JSON ma’lumoti bilan ishlash uchun qulay.

`json.Marshal()` Go qiymatini JSON ko‘rinishidagi `[]byte`ga aylantiradi.

`json.Unmarshal()` esa JSON saqlangan `[]byte`ni Go qiymatiga dekodlaydi.

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

Birinchi qismni ko‘ramiz:

```go
data, err := json.Marshal(User{Name: "Ali", Roles: []string{"editor"}})
```

Bu yerda `User` qiymati JSON’ga kodlanadi.

Natija `string` emas, `[]byte` ko‘rinishida qaytadi.

Taxminan quyidagi ma’lumot hosil bo‘ladi:

```json
{"name":"Ali","roles":["editor"]}
```

Keyin:

```go
var user User
```

yangi `User` qiymati yaratiladi. Hozircha uning fieldlari zero value holatida.

So‘ng:

```go
json.Unmarshal(data, &user)
```

JSON shu struct ichiga yoziladi.

Bu yerda `&user` berilishining sababi muhim.

`Unmarshal` mavjud qiymatni o‘zgartirishi kerak. Shuning uchun unga structning o‘zi emas, yozish mumkin bo‘lgan pointer beriladi.

Bunday yozish noto‘g‘ri:

```go
json.Unmarshal(data, user)
```

Chunki `user`ning nusxasiga qiymat yozish orqali chaqiruvchidagi structni o‘zgartirib bo‘lmaydi.

To‘g‘ri variant:

```go
json.Unmarshal(data, &user)
```

Kichik va to‘liq xotirada mavjud JSON uchun `Marshal` va `Unmarshal` odatda eng sodda yechim bo‘ladi.

Masalan:

* database’dan olingan kichik JSON ustuni;
* test ichidagi JSON;
* kichik HTTP response tanasi oldindan `[]byte`ga o‘qilgan bo‘lsa.

Katta oqimlarda esa `Encoder` va `Decoder` ko‘proq mos kelishi mumkin.

## `Encoder` va `Decoder`

`json.Encoder` va `json.Decoder` `io.Writer` hamda `io.Reader` bilan ishlaydi.

Bu ularni oqimlar bilan ishlashga qulay qiladi.

Masalan:

```go
if err := json.NewEncoder(os.Stdout).Encode(user); err != nil {
	return err
}
```

Bu yerda:

```go
json.NewEncoder(os.Stdout)
```

`os.Stdout`ga yozadigan encoder yaratadi.

`os.Stdout` `io.Writer` interface’ini bajaradi. Shuning uchun `Encoder` JSON natijasini bevosita terminalga yozishi mumkin.

Keyin:

```go
Encode(user)
```

`user` qiymatini JSON’ga aylantirib, natijani writerga yozadi.

Bunda alohida:

```go
data, err := json.Marshal(user)
```

qilib `[]byte` hosil qilish va keyin uni writerga yozish shart emas.

`Encode` yana bitta muhim xususiyatga ega: JSON qiymatidan keyin yangi qator qo‘shadi.

Masalan, natija:

```text
{"name":"Ali","roles":["editor"]}
```

ko‘rinishida yozilib, oxirida `\n` bo‘ladi.

### `Decoder`

`Decoder` esa `io.Reader`dan JSON o‘qiydi.

Masalan:

```go
dec := json.NewDecoder(r)

var user User
if err := dec.Decode(&user); err != nil {
	return err
}
```

Bu yerda `r`:

* fayl;
* HTTP request body;
* TCP connection;
* `strings.Reader`;
* boshqa `io.Reader`

bo‘lishi mumkin.

Fayl, terminal yoki tarmoq ulanishi kabi oqim bilan ishlaganda `Encoder` va `Decoder` ortiqcha oraliq `[]byte` yaratmaslikka yordam beradi.

Bu ayniqsa ma’lumot allaqachon reader yoki writer ko‘rinishida bo‘lsa qulay.

## Qat’iy dekodlash

Oddiy `json.Decoder` JSON object ichidagi noma’lum fieldlarni odatda e’tiborsiz qoldiradi.

Ba’zi holatlarda bu qulay.

Lekin konfiguratsiya fayllarida bu xavfli bo‘lishi mumkin.

Masalan, konfiguratsiya structi:

```go
type Config struct {
	Debug bool `json:"debug"`
}
```

foydalanuvchi esa xato qilib:

```json
{
  "debgu": true
}
```

yozsa, `debgu` structda mavjud emas.

Agar noma’lum fieldlar e’tiborsiz qoldirilsa, dastur xato bermasdan ishlashi mumkin. Foydalanuvchi esa `debug` yoqildi deb o‘ylaydi.

Bunday holatda `DisallowUnknownFields()` foydali.

U JSON object ichida structga mos kelmaydigan field uchrasa, xato qaytaradi.

Bitta JSON qiymatidan keyin yana boshqa JSON qiymati kelmaganini ham tekshirish kerak.

```go
func decodeConfig(r io.Reader) (Config, error) {
	var cfg Config
	dec := json.NewDecoder(r)
	dec.DisallowUnknownFields()

	if err := dec.Decode(&cfg); err != nil {
		return Config{}, fmt.Errorf("JSON o‘qilmadi: %w", err)
	}

	if err := dec.Decode(&struct{}{}); err != io.EOF {
		if err == nil {
			return Config{}, errors.New("faqat bitta JSON qiymati kutilgan")
		}

		return Config{}, fmt.Errorf("ortiqcha JSON qiymati: %w", err)
	}

	return cfg, nil
}
```

Bu funksiya uchun quyidagi paketlar kerak:

```go
import (
	"encoding/json"
	"errors"
	"fmt"
	"io"
)
```

Endi funksiyani bosqichma-bosqich ko‘ramiz.

Avval:

```go
dec := json.NewDecoder(r)
```

reader ustida ishlaydigan decoder yaratiladi.

Keyin:

```go
dec.DisallowUnknownFields()
```

noma’lum JSON fieldlarini xato qilish rejimi yoqiladi.

Birinchi `Decode`:

```go
if err := dec.Decode(&cfg); err != nil {
	return Config{}, fmt.Errorf("JSON o‘qilmadi: %w", err)
}
```

asosiy JSON qiymatini `cfg` ichiga yozadi.

Agar sintaksis noto‘g‘ri bo‘lsa yoki qiymat struct turiga mos kelmasa, shu yerda xato qaytishi mumkin.

Keyin ikkinchi `Decode` bajariladi:

```go
if err := dec.Decode(&struct{}{}); err != io.EOF {
```

Bu yangi biznes qiymatini o‘qish uchun emas. Maqsad — birinchi JSON qiymatidan keyin yana ma’lumot bor-yo‘qligini tekshirish.

Agar oqim tugagan bo‘lsa, `Decode` `io.EOF` qaytaradi.

Bu kerakli holat:

```text
birinchi JSON qiymati o‘qildi
↓
yana Decode qilindi
↓
io.EOF qaytdi
↓
demak boshqa JSON qiymati yo‘q
```

Lekin input quyidagicha bo‘lsa:

```json
{"debug": true}
{"debug": false}
```

birinchi `Decode` faqat birinchi objectni o‘qiydi.

Ikkinchi `Decode` esa ikkinchi objectni topadi. Natijada “faqat bitta JSON qiymati kutilgan” qoidasi buzilganini aniqlash mumkin.

Bu ayniqsa konfiguratsiya kabi qat’iy inputlarda muhim.

## Xato turlari

`encoding/json` ayrim xatolarni maxsus turlar orqali qaytaradi.

Bu xatoning sababini aniqroq aniqlash imkonini beradi.

Noto‘g‘ri JSON sintaksisi `*json.SyntaxError` bo‘lishi mumkin.

Masalan:

```json
{"name":"Ali",
```

Bu JSON yopilmagan.

JSON qiymati Go field turiga mos kelmasa, `*json.UnmarshalTypeError` qaytishi mumkin.

Masalan:

```go
type User struct {
	Age int `json:"age"`
}
```

lekin JSON:

```json
{
  "age": "o'ttiz"
}
```

bo‘lsa, `string` qiymatini `int`ga yozib bo‘lmaydi.

Xatoni `errors.As` orqali tekshirish mumkin:

```go
var syntaxErr *json.SyntaxError
var typeErr *json.UnmarshalTypeError

switch {
case errors.As(err, &syntaxErr):
	fmt.Printf("JSON sintaksisi xato, offset: %d\n", syntaxErr.Offset)

case errors.As(err, &typeErr):
	fmt.Printf("%s field uchun tur noto‘g‘ri\n", typeErr.Field)

default:
	fmt.Println("JSON o‘qilmadi")
}
```

Birinchi holatda:

```go
errors.As(err, &syntaxErr)
```

xato zanjiri ichida `*json.SyntaxError` bor-yo‘qligini tekshiradi.

Agar bo‘lsa:

```go
syntaxErr.Offset
```

xato JSON oqimining taxminan qaysi byte pozitsiyasida yuz berganini ko‘rsatadi.

Ikkinchi holatda:

```go
errors.As(err, &typeErr)
```

xato `*json.UnmarshalTypeError` ekanini aniqlaydi.

`typeErr.Field` struct fieldi haqida ma’lumot berishi mumkin.

Bu diagnostika loglarda foydali.

Lekin foydalanuvchiga aynan shu ichki xato matnini to‘liq qaytarish har doim ham yaxshi emas.

Masalan, log ichida:

* fayl yo‘li;
* ichki struct nomlari;
* maxfiy qiymatlar;
* implementation tafsilotlari

paydo bo‘lishi mumkin.

Shuning uchun ichki diagnostikani logda saqlab, tashqi foydalanuvchiga qisqa va xavfsiz xabar qaytarish odatda yaxshiroq.

Masalan:

```text
Konfiguratsiya JSON formati noto‘g‘ri.
```

API uchun esa mos HTTP status bilan umumiy xato qaytarilishi mumkin.

## Konfiguratsiya misoli

Quyidagi misol `Decoder` va `DisallowUnknownFields()`ni birgalikda ishlatishni ko‘rsatadi.

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
		log.Fatal("konfiguratsiya o‘qilmadi: ", err)
	}

	fmt.Printf("Manzil: %s, debug: %t\n", cfg.Address, cfg.Debug)
}
```

Bu misol ataylab fayl yoki HTTP requestga bog‘lanmagan.

Avval JSON oddiy string sifatida berilgan:

```go
input := `{"address":"localhost:8080","debug":true}`
```

Keyin:

```go
strings.NewReader(input)
```

shu stringni `io.Reader` sifatida ko‘rish imkonini beradi.

Natijada `json.Decoder` stringni xuddi fayl yoki tarmoq oqimini o‘qigandek o‘qiy oladi.

Keyingi qator:

```go
dec.DisallowUnknownFields()
```

noma’lum fieldlarni taqiqlaydi.

Masalan, input xato yozilsa:

```json
{
  "adress": "localhost:8080",
  "debug": true
}
```

`adress` structdagi `address` fieldiga mos kelmaydi.

Shunda decoder xato qaytaradi.

Asosiy dekodlash:

```go
if err := dec.Decode(&cfg); err != nil {
	log.Fatal("konfiguratsiya o‘qilmadi: ", err)
}
```

JSON qiymatlarini `cfg` structiga yozadi.

Dekodlashdan keyin taxminan quyidagi qiymat hosil bo‘ladi:

```go
Config{
	Address: "localhost:8080",
	Debug:   true,
}
```

Oxirida:

```go
fmt.Printf("Manzil: %s, debug: %t\n", cfg.Address, cfg.Debug)
```

qiymatlar terminalga chiqariladi.

Natija:

```text
Manzil: localhost:8080, debug: true
```

Bu misoldagi asosiy qoida shuki, `Decoder` faqat fayl yoki HTTP bilan cheklanmaydi.

Unga `io.Reader` berilsa kifoya.

Shuning uchun bir xil dekodlash kodi:

* `os.File`;
* `http.Request.Body`;
* `strings.Reader`;
* `bytes.Reader`;
* network connection

kabi turli manbalar bilan ishlashi mumkin.
