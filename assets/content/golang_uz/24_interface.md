# Goda interface

**Interface** — tur qanday ma'lumot saqlashini emas, u qanday xatti-harakatni bajara olishini belgilaydi.

Boshqacha aytganda, interface ichida struct maydonlari yozilmaydi. Uning o'rniga turda qaysi metodlar bo'lishi kerakligi 
ko'rsatiladi.

Masalan, bizga xabar yubora oladigan tur kerak bo'lsin.

Buning uchun turning:

* email manzilini qanday saqlashi;
* telefon raqamini qayerda saqlashi;
* HTTP API ishlatishi;
* SMTP ishlatishi;

biz uchun muhim bo'lmasligi mumkin.

Bizga faqat bitta narsa kerak:

```go
Send(message string) error
```

metodi mavjud bo'lishi.

Shunda quyidagicha interface e'lon qilish mumkin:

```go
type Sender interface {
    Send(message string) error
}
```

Endi `Send(string) error` metodiga ega bo'lgan har qanday tur `Sender` interface'iga mos keladi.

Go'da buning uchun Java yoki C# kabi tillardagi:

```text
implements
```

kalit so'zini yozish kerak emas.

Masalan, quyidagicha yozilmaydi:

```text
EmailSender implements Sender
```

Go bunga ehtiyoj sezmaydi.

Agar `EmailSender` turida interface talab qilayotgan barcha metodlar mavjud bo'lsa, Go uni avtomatik ravishda shu interface'ni bajaradi deb hisoblaydi.

Bu **implicit interface implementation**, ya'ni interface'ni yashirin bajarish deyiladi.

Interface'ning asosiy foydalaridan biri — kodni aniq bir structga bog'lab qo'ymaslik.

Masalan, quyidagi funksiya:

```go
func Notify(sender Sender, message string) error
```

`EmailSender`, `SMSSender`, `TelegramSender` yoki boshqa aniq turni talab qilmaydi.

U faqat:

```go
Sender
```

interface'ini talab qiladi.

Demak, funksiyaga beriladigan qiymat:

> "Sen qaysi structsan?"

degan talabga emas:

> "Sen `Send()` metodini bajara olasanmi?"

degan talabga javob berishi kerak.

Bu interface'larning eng muhim g'oyalaridan biridir.

## Interface e'lon qilish va bajarish

Quyidagi misolni ko'ramiz:

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
		return fmt.Errorf("email manzili bo'sh")
	}

	fmt.Printf("%s manziliga: %s\n", e.Address, message)
	return nil
}

func Notify(sender Sender, message string) error {
	return sender.Send(message)
}

func main() {
	email := EmailSender{
		Address: "user@example.com",
	}

	if err := Notify(email, "Buyurtma tayyor"); err != nil {
		fmt.Println("Xato:", err)
	}
}
```

Natija:

```text
user@example.com manziliga: Buyurtma tayyor
```

Kodning muhim qismlarini alohida ko'rib chiqamiz.

Avval interface:

```go
type Sender interface {
    Send(message string) error
}
```

Bu kod:

> `Sender` bo'lishni istagan turda `Send(string) error` metodi bo'lishi kerak

degan talabni bildiradi.

Keyin `EmailSender` turi bor:

```go
type EmailSender struct {
    Address string
}
```

Bu oddiy struct.

Uning ichida email manzili saqlanadi.

Keyin unga metod yozilgan:

```go
func (e EmailSender) Send(message string) error
```

Bu metodning signature'i interface ichidagi metod bilan aynan bir xil:

```go
Send(message string) error
```

Shuning uchun:

```go
EmailSender
```

`Sender` interface'ini avtomatik bajaradi.

Biz hech qayerda:

```text
EmailSender Sender interface'ini bajaradi
```

deb alohida ko'rsatmadik.

Go metodlar to'plamiga qarab buni o'zi aniqlaydi.

Shuning uchun quyidagi kod ishlaydi:

```go
email := EmailSender{
    Address: "user@example.com",
}

Notify(email, "Buyurtma tayyor")
```

`Notify()` funksiyasi esa quyidagicha yozilgan:

```go
func Notify(sender Sender, message string) error {
    return sender.Send(message)
}
```

Bu funksiya `EmailSender` haqida hech narsa bilmaydi.

U:

```go
Address
```

maydonini ham bilmaydi.

Unga email qanday yuborilishi ham muhim emas.

Funksiya faqat bitta narsani biladi:

```go
sender.Send(message)
```

chaqirish mumkin.

Shuning uchun keyinchalik boshqa tur yozishimiz mumkin:

```go
type SMSSender struct {
    Phone string
}
```

va unga:

```go
func (s SMSSender) Send(message string) error {
    // SMS yuborish
    return nil
}
```

metodini qo'shsak, `SMSSender` ham avtomatik ravishda `Sender`ga mos keladi.

`Notify()` funksiyasini esa o'zgartirish shart emas:

```go
Notify(emailSender, "Salom")
Notify(smsSender, "Salom")
```

Ikkalasi ham ishlashi mumkin.

### Interface bajarilishini kompilyatsiya vaqtida tekshirish

Ba'zan ma'lum bir tur interface'ni bajarishini kodning o'zida aniq tekshirib qo'yish foydali bo'ladi.

Buning uchun Go'da quyidagi usul ko'p ishlatiladi:

```go
var _ Sender = EmailSender{}
```

Bu yerda `_` — blank identifier.

Bizga qiymatning o'zi kerak emas.

Bu yozuv orqali kompilyatorga:

> `EmailSender` qiymatini `Sender` sifatida ishlatish mumkinligini tekshir

deyapmiz.

Agar `EmailSender` `Sender` interface'iga mos kelmasa, kod kompilyatsiyadan o'tmaydi.

Masalan, metod noto'g'ri yozilgan bo'lsa:

```go
func (e EmailSender) Send(message string) {
}
```

bu `Sender` interface'iga mos kelmaydi.

Sababi interface:

```go
Send(message string) error
```

metodini talab qiladi.

Bizning metod esa:

```go
Send(message string)
```

bo'lib qolgan.

Demak, faqat metod nomining bir xil bo'lishi yetarli emas.

Quyidagilarning barchasi mos kelishi kerak:

* metod nomi;
* parametrlar soni;
* parametrlarning turlari;
* parametrlar tartibi;
* qaytariladigan qiymatlar;
* qaytariladigan qiymatlarning turlari.

Masalan:

```go
Send(string) error
```

va:

```go
Send([]byte) error
```

ikki xil metod signature hisoblanadi.

Shuning uchun ikkinchisi birinchisini talab qiladigan interface'ni bajarmaydi.

## Kichik interface'lar

Go'da odatda **kichik interface'lar** afzal ko'riladi.

Ya'ni interface ichiga imkon qadar faqat haqiqatan kerak bo'lgan metodlar yoziladi.

Masalan, funksiyaga faqat ma'lumot o'qish kerak bo'lsa, unga quyidagicha katta interface berish shart emas:

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

Agar funksiya faqat o'qisa, unga bitta metod yetarli bo'lishi mumkin:

```go
type Reader interface {
    Read([]byte) (int, error)
}
```

Buning bir nechta foydasi bor.

Birinchidan, kichik interface'ni bajarish oson.

Agar interface bitta metod talab qilsa:

```go
type Sender interface {
    Send(string) error
}
```

yangi turga faqat shu metodni qo'shish yetarli.

Agar interface o'nta metod talab qilsa, uni bajarish uchun turning o'nta metodga ega bo'lishi kerak.

Ikkinchidan, kichik interface test yozishni osonlashtiradi.

Masalan, testda haqiqiy email servis o'rniga kichik test turi yaratish mumkin:

```go
type FakeSender struct{}

func (FakeSender) Send(message string) error {
    return nil
}
```

`FakeSender` `Sender` interface'iga mos keladi.

Shuning uchun testda haqiqiy email yuborishga hojat qolmaydi.

Uchinchidan, kichik interface qayta ishlatishga qulayroq.

Go standart kutubxonasidagi eng mashhur misollardan biri:

```go
io.Reader
```

interface'idir.

U faqat bitta metod talab qiladi:

```go
Read(p []byte) (n int, err error)
```

Shunga qaramay, juda ko'p tur `io.Reader` sifatida ishlatilishi mumkin:

* fayl;
* HTTP response body;
* buffer;
* TCP ulanish;
* siqilgan ma'lumot oqimi;
* xotiradagi satr.

Bularning ichki tuzilishi turlicha.

Lekin barchasi:

```go
Read(...)
```

orqali ma'lumot bera olsa, `io.Reader` bilan ishlaydigan kod ulardan foydalanishi mumkin.

### Interface'ni ko'pincha undan foydalanuvchi tomon e'lon qiladi

Go'da muhim amaliy tamoyillardan biri:

> Interface'ni ko'pincha uni amalga oshiruvchi tur emas, undan foydalanuvchi kod e'lon qiladi.

Masalan, `EmailSender` paketining o'zi katta:

```go
Sender
```

interface e'lon qilishi shart emas.

Agar boshqa paketga faqat:

```go
Send(string) error
```

kerak bo'lsa, o'sha paket o'zining kichik interface'ini yaratishi mumkin.

Bu komponentlarni bir-biriga kamroq bog'laydi.

## Interface ichiga boshqa interface'ni joylash

Go'da bitta interface ichiga boshqa interface'ni joylashtirish mumkin.

Bu **interface embedding** deyiladi.

Masalan:

```go
type Reader interface {
    Read([]byte) (int, error)
}

type Writer interface {
    Write([]byte) (int, error)
}
```

Bu yerda ikkita alohida interface bor.

`Reader` ma'lumot o'qiy oladigan turni bildiradi.

`Writer` esa ma'lumot yoza oladigan turni bildiradi.

Endi ikkalasini birlashtirish mumkin:

```go
type ReadWriter interface {
    Reader
    Writer
}
```

Bu yozuvning ma'nosi:

> `ReadWriter` bo'lish uchun ham `Reader`, ham `Writer` talablarini bajarish kerak.

Ya'ni amalda `ReadWriter` quyidagiga teng:

```go
type ReadWriter interface {
    Read([]byte) (int, error)
    Write([]byte) (int, error)
}
```

Lekin interface'larni embedding qilish orqali mavjud kichik interface'lardan yangi interface tuzish mumkin.

Masalan, bir turda faqat:

```go
Read(...)
```

bo'lsa, u `Reader`ni bajaradi.

Agar faqat:

```go
Write(...)
```

bo'lsa, u `Writer`ni bajaradi.

Agar ikkalasi ham bo'lsa:

```go
Read(...)
Write(...)
```

u `ReadWriter`ni ham bajaradi.

Bu usul kichik interface'larni birlashtirib kattaroq xatti-harakat yaratishga yordam beradi.

## Dynamic type va dynamic value

Interface'ni to'g'ri tushunish uchun uning ichida qiymat qanday saqlanishini bilish muhim.

Interface qiymatini soddalashtirib ikki qism orqali tasavvur qilish mumkin:

* **dynamic type**;
* **dynamic value**.

### Dynamic type nima?

Dynamic type — interface ichida hozir saqlanayotgan qiymatning aniq turi.

Masalan:

```go
var value any = 15
```

Bu yerda o'zgaruvchining statik turi:

```go
any
```

lekin uning ichidagi qiymatning aniq turi:

```go
int
```

Demak, dynamic type:

```text
int
```

bo'ladi.

### Dynamic value nima?

Dynamic value esa interface ichida saqlanayotgan haqiqiy qiymat.

Yuqoridagi misolda:

```go
var value any = 15
```

dynamic type:

```text
int
```

dynamic value:

```text
15
```

bo'ladi.

Quyidagi misolni ko'ramiz:

```go
package main

import "fmt"

func main() {
	var value any = 15

	fmt.Printf("Tur: %T, qiymat: %v\n", value, value)

	value = "Go"

	fmt.Printf("Tur: %T, qiymat: %v\n", value, value)
}
```

Natija:

```text
Tur: int, qiymat: 15
Tur: string, qiymat: Go
```

Avval:

```go
var value any = 15
```

bo'lganda interface ichida:

```text
dynamic type  = int
dynamic value = 15
```

saqlanadi.

Keyin:

```go
value = "Go"
```

deb qiymatni almashtirdik.

Endi interface ichida:

```text
dynamic type  = string
dynamic value = "Go"
```

saqlanadi.

Interface o'zgaruvchisining o'zi hamon:

```go
any
```

turida.

Lekin uning ichidagi aniq tur runtime davomida o'zgarishi mumkin.

### `any` nima?

Go'da:

```go
any
```

quyidagining aliasidir:

```go
interface{}
```

Ya'ni:

```go
any
```

va:

```go
interface{}
```

bir xil ma'noni anglatadi.

Bo'sh interface:

```go
interface{}
```

hech qanday metod talab qilmaydi.

Go'dagi barcha turlar hech bo'lmaganda "nol dona metod talab qilish" shartiga mos keladi.

Shuning uchun `any` istalgan turdagi qiymatni saqlashi mumkin:

```go
var value any

value = 15
value = "Go"
value = true
value = []int{1, 2, 3}
value = struct{}{}
```

Bularning barchasi mumkin.

Lekin `any`ning kamchiligi ham shunda.

Masalan:

```go
func process(value any)
```

deb yozsak, funksiya `value` bilan nima qilish mumkinligini oldindan bilmaydi.

U `int` bo'lishi ham mumkin.

`string` bo'lishi ham mumkin.

Struct yoki slice bo'lishi ham mumkin.

Shuning uchun imkon bo'lgan joyda:

```go
any
```

o'rniga kerakli xatti-harakatni bildiradigan aniq interface ishlatish yaxshiroq.

Masalan:

```go
type Sender interface {
    Send(string) error
}
```

Bu `any`dan ancha kuchliroq talab beradi.

Funksiya ichida kamida:

```go
sender.Send(...)
```

chaqirish mumkinligini bilamiz.

Ayrim holatlarda interface o'rniga generics ham yaxshiroq type safety berishi mumkin.

Lekin interface va generics bir xil vazifani bajarmaydi.

Interface ko'proq xatti-harakatga:

> "Bu qiymat nima qila oladi?"

degan savolga javob beradi.

## `nil` interface tuzog'i

Interface bilan ishlaganda eng ko'p chalkashlik tug'diradigan mavzulardan biri — `nil`.

Oddiy pointerda vaziyat tushunarli:

```go
var pointer *MyError
```

Unga qiymat berilmagan bo'lsa:

```go
pointer == nil
```

natija:

```text
true
```

bo'ladi.

Interface esa biroz boshqacha ishlaydi.

Interface'ni quyidagi ikki qism orqali tasavvur qilgan edik:

```text
(dynamic type, dynamic value)
```

Interface faqat ikkala qism ham mavjud bo'lmaganda `nil` hisoblanadi.

Ya'ni haqiqiy `nil` interface taxminan:

```text
(nil, nil)
```

ko'rinishida bo'ladi.

Quyidagi misolni ko'ramiz:

```go
package main

import "fmt"

type MyError struct{}

func (e *MyError) Error() string {
	return "xato"
}

func main() {
	var pointer *MyError

	var err error = pointer

	fmt.Println(pointer == nil)
	fmt.Println(err == nil)
	fmt.Printf("%T %v\n", err, err)
}
```

Natija:

```text
true
false
*main.MyError xato
```

Birinchi qarashda bu g'alati ko'rinishi mumkin.

Bizda:

```go
var pointer *MyError
```

bor.

Unga hech qanday qiymat berilmagan.

Demak:

```go
pointer == nil
```

natijasi:

```text
true
```

Bu to'g'ri.

Keyin:

```go
var err error = pointer
```

deb pointer'ni `error` interface'iga joyladik.

`MyError` `error` interface'ini bajaradi, chunki unda:

```go
Error() string
```

metodi bor.

Lekin `err` ichida endi ma'lumot mavjud.

Uning holatini quyidagicha tasavvur qilish mumkin:

```text
dynamic type  = *MyError
dynamic value = nil
```

Ya'ni:

```text
(*MyError, nil)
```

Interface butunlay `nil` bo'lishi uchun esa:

```text
(nil, nil)
```

bo'lishi kerak edi.

Lekin bizda dynamic type mavjud:

```text
*MyError
```

Shuning uchun:

```go
err == nil
```

natijasi:

```text
false
```

bo'ladi.

Bu **typed nil** muammosi deb ataladigan holatlardan biri.

### `error` qaytaruvchi funksiyada typed nil muammosi

Quyidagi kabi kod xavfli bo'lishi mumkin:

```go
func doSomething() error {
    var err *MyError

    return err
}
```

Dasturchi:

> `err` pointer `nil`, demak funksiya `nil` qaytaradi

deb o'ylashi mumkin.

Lekin funksiya qaytarayotgan turi:

```go
error
```

interface.

`*MyError` pointer `error` interface'iga joylanganda dynamic type saqlanadi.

Natijada qaytgan interface:

```text
(*MyError, nil)
```

ko'rinishiga ega bo'ladi.

Shuning uchun:

```go
if err != nil {
    // bu blok bajarilishi mumkin
}
```

holati yuz beradi.

Muvaffaqiyat holatida `error` qaytaruvchi funksiya to'g'ridan-to'g'ri:

```go
return nil
```

qaytarishi kerak.

Masalan:

```go
func doSomething() error {
    // hammasi muvaffaqiyatli

    return nil
}
```

Bu holatda interface haqiqatan:

```text
(nil, nil)
```

bo'ladi.

## Type assertion

Interface ichida aniq qaysi turdagi qiymat saqlanayotganini olish kerak bo'lishi mumkin.

Buning uchun **type assertion** ishlatiladi.

Masalan:

```go
var value any = "Go"
```

Biz `value` ichidagi qiymat `string` ekanini bilmoqchimiz.

Quyidagicha yozish mumkin:

```go
text := value.(string)
```

Bu:

> `value` ichidagi dynamic type `string` bo'lsa, uning qiymatini ol

degan ma'noni anglatadi.

Agar `value` haqiqatan:

```go
"Go"
```

saqlayotgan bo'lsa:

```go
text := value.(string)
```

natijada:

```go
text == "Go"
```

bo'ladi.

Lekin bu usulning xavfli tomoni bor.

Agar:

```go
var value any = 15
```

bo'lsa va:

```go
text := value.(string)
```

deb yozsak, dastur `panic` qiladi.

Sababi dynamic type:

```text
int
```

lekin biz:

```text
string
```

deb talab qilyapmiz.

### `comma ok` shakli

Type assertion'ni xavfsizroq ishlatish uchun odatda:

```go
value, ok := interfaceValue.(Type)
```

ko'rinishi ishlatiladi.

Masalan:

```go
var value any = "Go"

text, ok := value.(string)
```

Agar dynamic type `string` bo'lsa:

```text
text = "Go"
ok   = true
```

bo'ladi.

Agar:

```go
var value any = 15
```

bo'lsa:

```go
text, ok := value.(string)
```

natijada:

```text
text = ""
ok   = false
```

bo'ladi.

Dastur `panic` qilmaydi.

`text`ga `string` turning zero value qiymati beriladi:

```text
""
```

Shuning uchun interface ichidagi turni tekshirishda ko'pincha:

```go
v, ok := value.(string)
```

usuli xavfsizroq.

## Type switch

Agar interface ichidagi qiymat bir nechta turdan biri bo'lishi mumkin bo'lsa, ketma-ket ko'p type assertion yozish noqulay.

Masalan:

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

Bunday holat uchun Go'da **type switch** mavjud.

Misol:

```go
package main

import "fmt"

func describe(value any) {
	switch v := value.(type) {
	case int:
		fmt.Println("Butun son:", v)

	case string:
		fmt.Println("Satr:", v)

	default:
		fmt.Printf("Boshqa tur: %T\n", v)
	}
}

func main() {
	describe(15)
	describe("Go")
}
```

Natija:

```text
Butun son: 15
Satr: Go
```

Type switch'ning asosiy qismi:

```go
switch v := value.(type) {
```

Oddiy type assertion'da:

```go
value.(string)
```

deb aniq turni yozamiz.

Type switch'da esa maxsus:

```go
value.(type)
```

ko'rinishi ishlatiladi.

Keyin kerakli turlar `case` orqali tekshiriladi:

```go
case int:
```

Agar dynamic type `int` bo'lsa, shu blok bajariladi.

```go
case string:
```

Agar dynamic type `string` bo'lsa, shu blok bajariladi.

Masalan:

```go
describe(15)
```

chaqirilganda:

```text
dynamic type = int
```

Shuning uchun:

```go
case int:
```

tanlanadi.

Bu blok ichida `v`ning turi ham:

```go
int
```

bo'ladi.

Shuning uchun:

```go
fmt.Println("Butun son:", v)
```

deb to'g'ridan-to'g'ri ishlatish mumkin.

`describe("Go")` chaqirilganda esa `v` `string` bo'ladi.

Agar hech bir `case` mos kelmasa:

```go
default:
```

bloki bajariladi.

Type switch ayniqsa `any` bilan ishlaydigan kodlarda foydali.

Lekin uni keragidan ortiq ishlatish ham yaxshi emas.

Agar funksiyaning ishlashi uchun ma'lum bir metod kerak bo'lsa, `any` olib keyin tur tekshirishdan ko'ra aniq interface yozish ko'pincha tushunarliroq.

## Pointer receiverning interface'ga ta'siri

Oldingi metodlar mavzusida **method set** tushunchasini ko'rgan edik.

Bu interface bilan ishlaganda ayniqsa muhim.

Faraz qilamiz:

```go
type Counter struct {
    Value int
}
```

va metod:

```go
func (c *Counter) Increment() {
    c.Value++
}
```

Bu metodning receiveri:

```go
*Counter
```

Ya'ni pointer receiver.

Endi interface:

```go
type Incrementer interface {
    Increment()
}
```

bo'lsin.

Savol:

```go
Counter
```

interface'ni bajaradimi?

Yo'q.

Lekin:

```go
*Counter
```

bajaradi.

Sababi method set qoidasi.

Soddalashtirib:

```text
T
```

method setiga value receiver bilan yozilgan metodlar kiradi.

```text
*T
```

method setiga esa:

* `T` receiverli metodlar;
* `*T` receiverli metodlar;

kiradi.

Bizda:

```go
func (c *Counter) Increment()
```

bo'lganligi sabab `Increment()` `*Counter` method setiga kiradi.

Shuning uchun:

```go
var i Incrementer = &counter
```

ishlaydi.

Lekin:

```go
var i Incrementer = counter
```

kompilyatsiyadan o'tmaydi.

Bu joyda Go'ning metod chaqirishdagi avtomatik `&` qo'shishi bilan interface qoidasini aralashtirmaslik kerak.

Masalan:

```go
counter.Increment()
```

ishlashi mumkin.

Go `counter`ning manzilini olish mumkinligini ko'rib, chaqiruvni amalda:

```go
(&counter).Increment()
```

ko'rinishiga moslashtiradi.

Lekin:

```go
var i Incrementer = counter
```

degan interface assignment vaqtida Go avtomatik:

```go
&counter
```

qilib bermaydi.

Interface'ga moslik turning haqiqiy method seti asosida tekshiriladi.

## Misollar

### 1. Kichik interface orqali turli shakllar

```go
package main

import "fmt"

type Yuzali interface {
	Yuza() float64
}

type Kvadrat struct {
	Tomon float64
}

type Tortburchak struct {
	Eni  float64
	Boyi float64
}

func (k Kvadrat) Yuza() float64 {
	return k.Tomon * k.Tomon
}

func (t Tortburchak) Yuza() float64 {
	return t.Eni * t.Boyi
}

func chiqar(y Yuzali) {
	fmt.Println(y.Yuza())
}

func main() {
	chiqar(Kvadrat{
		Tomon: 4,
	})

	chiqar(Tortburchak{
		Eni:  3,
		Boyi: 5,
	})
}
```

Bu misolda:

```go
type Yuzali interface {
    Yuza() float64
}
```

interface faqat bitta metod talab qilmoqda:

```go
Yuza() float64
```

`Kvadrat`da ham:

```go
func (k Kvadrat) Yuza() float64
```

metodi mavjud.

`Tortburchak`da ham:

```go
func (t Tortburchak) Yuza() float64
```

metodi mavjud.

Shuning uchun ikkala tur ham `Yuzali` interface'ini avtomatik bajaradi.

Biz hech qayerda:

```text
Kvadrat implements Yuzali
```

yoki:

```text
Tortburchak implements Yuzali
```

deb yozmadik.

Metodlar mosligi yetarli.

`chiqar()` funksiyasi:

```go
func chiqar(y Yuzali)
```

aniq `Kvadrat` yoki `Tortburchak`ni talab qilmaydi.

U faqat:

```go
Yuza()
```

metodini chaqira olishni xohlaydi.

Shuning uchun:

```go
chiqar(Kvadrat{Tomon: 4})
```

ham:

```go
chiqar(Tortburchak{Eni: 3, Boyi: 5})
```

ham ishlaydi.

Funksiya uchun shaklning ichida qanday maydonlar borligi muhim emas.

Unga faqat yuzani hisoblash qobiliyati kerak.

### 2. Interface'lar slice'i

```go
package main

import "fmt"

type Nomli interface {
	Nom() string
}

type Shahar string

type Til string

func (s Shahar) Nom() string {
	return string(s)
}

func (t Til) Nom() string {
	return string(t)
}

func main() {
	qiymatlar := []Nomli{
		Shahar("Toshkent"),
		Til("Go"),
	}

	for _, qiymat := range qiymatlar {
		fmt.Println(qiymat.Nom())
	}
}
```

Oddiy slice odatda bitta turdagi qiymatlarni saqlaydi.

Masalan:

```go
[]string
```

faqat `string` saqlaydi.

```go
[]int
```

faqat `int` saqlaydi.

Lekin bu misolda:

```go
[]Nomli
```

interface slice ishlatilgan.

`Shahar` va `Til` ikki xil aniq tur:

```go
type Shahar string
type Til string
```

Lekin ikkalasida ham:

```go
Nom() string
```

metodi bor.

Shuning uchun ikkalasi ham:

```go
Nomli
```

interface'ini bajaradi.

Natijada bitta slice ichida:

```go
Shahar("Toshkent")
```

va:

```go
Til("Go")
```

qiymatlarini birga saqlash mumkin.

Sikl:

```go
for _, qiymat := range qiymatlar {
    fmt.Println(qiymat.Nom())
}
```

ichida kod qiymatning:

```go
Shahar
```

yoki:

```go
Til
```

ekaniga qiziqmaydi.

U faqat `Nom()` metodini chaqiradi.

Bu polymorphismning sodda ko'rinishlaridan biridir.

Turli aniq turlar bitta umumiy xatti-harakat orqali ishlatilmoqda.

### 3. Funksiya parametrida kichik interface

```go
package main

import "fmt"

type Tekshiruvchi interface {
	Togri() bool
}

type Ball int

func (b Ball) Togri() bool {
	return b >= 0 && b <= 100
}

func tekshir(t Tekshiruvchi) bool {
	return t.Togri()
}

func main() {
	fmt.Println(tekshir(Ball(86)))
}
```

Bu yerda:

```go
type Tekshiruvchi interface {
    Togri() bool
}
```

juda kichik interface.

U faqat:

```go
Togri() bool
```

metodini talab qiladi.

`Ball` turida:

```go
func (b Ball) Togri() bool
```

metodi bor.

Shuning uchun `Ball` avtomatik ravishda `Tekshiruvchi`ga mos keladi.

`tekshir()` funksiyasi:

```go
func tekshir(t Tekshiruvchi) bool
```

aniq `Ball` turiga bog'lanmagan.

Uning uchun qiymatning nima ekanligi muhim emas.

U faqat:

```go
t.Togri()
```

chaqira olishi kerak.

Keyinchalik boshqa tur yaratsak:

```go
type Yosh int
```

va unga:

```go
func (y Yosh) Togri() bool {
    return y >= 0 && y <= 150
}
```

metodini yozsak, `Yosh` ham shu funksiyaga berilishi mumkin:

```go
tekshir(Yosh(29))
```

`tekshir()` funksiyasini o'zgartirish shart emas.

Bu kichik interface'larning asosiy foydalaridan biri.

### 4. Bo'sh interface'da type assertion

```go
package main

import "fmt"

func main() {
	var qiymat any = "Go"

	matn, ok := qiymat.(string)

	fmt.Println(matn, ok)
}
```

Bu yerda:

```go
var qiymat any = "Go"
```

interface ichida:

```text
dynamic type  = string
dynamic value = "Go"
```

saqlanmoqda.

Keyin:

```go
matn, ok := qiymat.(string)
```

type assertion bajarildi.

Bu:

> `qiymat` ichidagi aniq tur `string`mi?

degan tekshiruv.

Haqiqatan `string` bo'lganligi sabab:

```text
matn = "Go"
ok   = true
```

bo'ladi.

Natija taxminan:

```text
Go true
```

bo'ladi.

Agar qiymat:

```go
var qiymat any = 15
```

bo'lganida:

```go
matn, ok := qiymat.(string)
```

natijasi:

```text
matn = ""
ok   = false
```

bo'lardi.

Eng muhim jihati — dastur `panic` qilmaydi.

Agar:

```go
matn := qiymat.(string)
```

ko'rinishidan foydalanilganida va dynamic type `string` bo'lmaganida, runtime `panic` yuz berardi.

Shuning uchun tur mos kelmasligi mumkin bo'lgan joylarda `comma ok` shakli xavfsizroq.

### 5. Type switch bilan qiymatlarni ajratish

```go
package main

import "fmt"

func chiqar(qiymat any) {
	switch v := qiymat.(type) {
	case int:
		fmt.Println("Butun son:", v)

	case string:
		fmt.Println("Matn:", v)

	case bool:
		fmt.Println("Mantiqiy qiymat:", v)

	default:
		fmt.Println("Noma'lum tur")
	}
}

func main() {
	chiqar(15)
	chiqar("Go")
}
```

Bu funksiya:

```go
any
```

qabul qiladi.

Demak, unga turli turlarni berish mumkin.

Masalan:

```go
chiqar(15)
chiqar("Go")
chiqar(true)
```

Funksiya ichidagi:

```go
switch v := qiymat.(type)
```

dynamic type'ni tekshiradi.

Agar qiymat:

```go
15
```

bo'lsa, dynamic type:

```text
int
```

bo'ladi.

Shuning uchun:

```go
case int:
```

bloki bajariladi.

Bu blok ichidagi `v` ham `int` turiga ega.

Agar:

```go
chiqar("Go")
```

chaqirilsa:

```go
case string:
```

tanlanadi.

Bu safar `v`:

```go
string
```

turida bo'ladi.

Agar:

```go
chiqar(true)
```

chaqirilsa:

```go
case bool:
```

ishlaydi.

Hech bir `case` mos kelmasa:

```go
default:
```

bajariladi.

Type switch bir interface ichidagi bir nechta ehtimoliy aniq turni tartibli tekshirish uchun qulay.

### 6. Interface'ning `nil` holati

```go
package main

import "fmt"

func main() {
	var qiymat any

	fmt.Println(qiymat == nil)

	qiymat = 0

	fmt.Println(qiymat == nil)
}
```

Avval:

```go
var qiymat any
```

deb interface e'lon qilindi.

Unga hech qanday qiymat berilmadi.

Uni soddalashtirib:

```text
dynamic type  = nil
dynamic value = nil
```

deb tasavvur qilish mumkin.

Shuning uchun:

```go
qiymat == nil
```

natijasi:

```text
true
```

bo'ladi.

Keyin:

```go
qiymat = 0
```

deb yozdik.

Ba'zan `0` "bo'sh qiymat"dek ko'rinishi mumkin.

Lekin `0` — haqiqiy `int` qiymat.

Endi interface ichida:

```text
dynamic type  = int
dynamic value = 0
```

saqlanmoqda.

Shuning uchun:

```go
qiymat == nil
```

natijasi:

```text
false
```

bo'ladi.

Interface ichidagi qiymatning zero value bo'lishi interface'ning o'zi `nil` degani emas.

Masalan, quyidagilarning barchasi `nil` bo'lmagan interface qiymatlaridir:

```go
var a any = 0
var b any = ""
var c any = false
```

Ularning dynamic qiymatlari o'z turlarining zero value qiymati.

Lekin dynamic type mavjud.

### 7. Typed nil pointer tuzog'i

```go
package main

import "fmt"

type Nomli interface {
	Nom() string
}

type Shaxs struct {
	Ism string
}

func (s *Shaxs) Nom() string {
	if s == nil {
		return "noma'lum"
	}

	return s.Ism
}

func main() {
	var shaxs *Shaxs

	var nomli Nomli = shaxs

	fmt.Println(nomli == nil, nomli.Nom())
}
```

Bu misolda:

```go
var shaxs *Shaxs
```

e'lon qilingan.

Unga qiymat berilmagan.

Shuning uchun:

```go
shaxs == nil
```

bo'ladi.

Lekin keyin:

```go
var nomli Nomli = shaxs
```

deb pointer interface ichiga joylandi.

`*Shaxs` `Nomli` interface'ini bajaradi, chunki unda:

```go
Nom() string
```

metodi mavjud.

Endi `nomli` interface'ining holatini:

```text
dynamic type  = *Shaxs
dynamic value = nil
```

deb tasavvur qilish mumkin.

Dynamic type mavjud bo'lganligi uchun:

```go
nomli == nil
```

natija:

```text
false
```

bo'ladi.

Keyin:

```go
nomli.Nom()
```

chaqirilmoqda.

Asl receiver ichidagi pointer `nil`.

Lekin metod boshida:

```go
if s == nil {
    return "noma'lum"
}
```

tekshiruvi bor.

Shuning uchun metod `nil` receiverni xavfsiz boshqaradi va:

```text
noma'lum
```

qaytaradi.

Bu misol interface'dagi typed nil holatini yaxshi ko'rsatadi.

### 8. Pointer receiver va method set

```go
package main

import "fmt"

type Oshuvchi interface {
	Oshirish()
}

type Hisoblagich struct {
	Son int
}

func (h *Hisoblagich) Oshirish() {
	h.Son++
}

func main() {
	h := Hisoblagich{}

	var oshuvchi Oshuvchi = &h

	oshuvchi.Oshirish()

	fmt.Println(h.Son)
}
```

Interface:

```go
type Oshuvchi interface {
    Oshirish()
}
```

`Oshirish()` metodini talab qiladi.

`Hisoblagich`da metod:

```go
func (h *Hisoblagich) Oshirish()
```

ko'rinishida yozilgan.

Receiver:

```go
*Hisoblagich
```

ya'ni pointer receiver.

Shuning uchun `Oshuvchi` interface'ini:

```go
*Hisoblagich
```

bajaradi.

Shu sabab quyidagi kod to'g'ri:

```go
var oshuvchi Oshuvchi = &h
```

`&h`ning turi:

```go
*Hisoblagich
```

bo'ladi.

Lekin quyidagisi ishlamaydi:

```go
var oshuvchi Oshuvchi = h
```

Sababi `Hisoblagich`ning o'z method setida pointer receiver bilan yozilgan `Oshirish()` mavjud emas.

Bu holat oddiy metod chaqiruvidan farq qiladi.

Quyidagisi ishlashi mumkin:

```go
h.Oshirish()
```

Chunki Go uni avtomatik:

```go
(&h).Oshirish()
```

ko'rinishiga moslashtiradi.

Lekin interface assignment vaqtida bunday avtomatik manzil olish bajarilmaydi.

Interface'ga moslik method set orqali tekshiriladi.

### 9. Bir interface'ni boshqasiga joylash

```go
package main

import "fmt"

type Nomli interface {
	Nom() string
}

type Tafsilotli interface {
	Nomli
	Tavsif() string
}

type Mahsulot struct {
	Nomi string
}

func (m Mahsulot) Nom() string {
	return m.Nomi
}

func (m Mahsulot) Tavsif() string {
	return "Mahsulot: " + m.Nomi
}

func main() {
	var qiymat Tafsilotli = Mahsulot{
		Nomi: "Kitob",
	}

	fmt.Println(
		qiymat.Nom(),
		qiymat.Tavsif(),
	)
}
```

Avval:

```go
type Nomli interface {
    Nom() string
}
```

interface mavjud.

Keyin:

```go
type Tafsilotli interface {
    Nomli
    Tavsif() string
}
```

deb yangi interface yaratildi.

Bu yerda:

```go
Nomli
```

interface `Tafsilotli` ichiga embedding qilingan.

Demak, `Tafsilotli` quyidagi metodlarni talab qiladi:

```go
Nom() string
Tavsif() string
```

Buni to'liq yozganda quyidagiga teng deb tasavvur qilish mumkin:

```go
type Tafsilotli interface {
    Nom() string
    Tavsif() string
}
```

`Mahsulot` turida ikkala metod ham mavjud:

```go
func (m Mahsulot) Nom() string
```

va:

```go
func (m Mahsulot) Tavsif() string
```

Shuning uchun `Mahsulot`:

```go
Tafsilotli
```

interface'ini bajaradi.

Bundan tashqari, u:

```go
Nomli
```

interface'ini ham bajaradi.

Interface embedding katta interface'larni kichik va tushunarli interface'lardan yig'ish imkonini beradi.

Masalan:

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

keyin ularni birlashtirib:

```go
type ReadWriteCloser interface {
    Reader
    Writer
    Closer
}
```

kabi interface yaratish mumkin.

### 10. Interface qiymatini boshqa interface parametriga uzatish

```go
package main

import "fmt"

type Stringer interface {
	String() string
}

type Kod int

func (k Kod) String() string {
	return fmt.Sprintf("KOD-%d", k)
}

func chopEt(s Stringer) {
	fmt.Println(s.String())
}

func main() {
	var s Stringer = Kod(15)

	chopEt(s)
}
```

Bu yerda:

```go
type Stringer interface {
    String() string
}
```

interface mavjud.

`Kod` turi:

```go
type Kod int
```

va unga:

```go
func (k Kod) String() string
```

metodi yozilgan.

Shuning uchun `Kod` `Stringer` interface'ini bajaradi.

Keyin:

```go
var s Stringer = Kod(15)
```

deb interface qiymati yaratildi.

Bu paytda `s`ni quyidagicha tasavvur qilish mumkin:

```text
statik tur     = Stringer
dynamic type   = Kod
dynamic value  = Kod(15)
```

Keyin:

```go
chopEt(s)
```

chaqirilmoqda.

`chopEt()` ham:

```go
Stringer
```

qabul qiladi:

```go
func chopEt(s Stringer)
```

Shuning uchun mavjud interface qiymatini unga to'g'ridan-to'g'ri berish mumkin.

Funksiya ichida:

```go
s.String()
```

chaqirilganda interface ichidagi dynamic type:

```go
Kod
```

ekanligi sabab `Kod.String()` metodi ishlaydi.

Ya'ni:

```go
func (k Kod) String() string {
    return fmt.Sprintf("KOD-%d", k)
}
```

chaqiriladi.

Natijada:

```text
KOD-15
```

chiqariladi.

Interface qiymatini boshqa joyga uzatish uning ichidagi aniq qiymatni yo'qotmaydi.

Bu misolda uzatilgandan keyin ham:

```text
dynamic type  = Kod
dynamic value = Kod(15)
```

bo'lib qoladi.

Funksiya esa aniq `Kod` turini bilishi shart emas.

U faqat:

```go
String() string
```

metodidan foydalanadi.
