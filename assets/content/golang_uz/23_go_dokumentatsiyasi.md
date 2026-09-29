# Go dokumentatsiyasini yozish va o‘qish

Go’da dokumentatsiya odatda manba kodining o‘zida yoziladi. Buning uchun oddiy commentlardan foydalaniladi. `go doc`, `pkg.go.dev` va boshqa Go vositalari shu commentlarni o‘qib, dasturchiga API haqida tushunarli dokumentatsiya ko‘rsatadi.

Shuning uchun dokumentatsiya yozish deganda alohida katta hujjat tayyorlash shart emas. Ko‘p hollarda tur, funksiya, method, konstanta yoki package yoniga to‘g‘ri yozilgan commentning o‘zi yetarli bo‘ladi.

Lekin yaxshi dokumentatsiya faqat nomni boshqa so‘zlar bilan takrorlamaydi.

Masalan, bunday izoh unchalik foydali emas:

```go
// DefaultLimit — DefaultLimit qiymati.
var DefaultLimit = 20
```

Nomning o‘zi ham deyarli shu ma’lumotni berib turibdi.

Foydaliroq izoh esa qiymatning vazifasini tushuntiradi:

```go
// DefaultLimit bitta so‘rovda qaytariladigan elementlarning standart soni.
var DefaultLimit = 20
```

Yaxshi dokumentatsiya imkon qadar chaqiruvchi bilishi kerak bo‘lgan narsalarni tushuntiradi:

* API nima qiladi;
* qanday qiymat qaytaradi;
* muhim cheklovi bormi;
* qaysi holatda `error` qaytaradi;
* alohida qiymatlar qanday ma’noga ega;
* API’dan qanday foydalanish kerak.

## Eksport qilinadigan nomlar izohi

Go’da package-level nom katta harf bilan boshlansa, u **exported**, ya’ni boshqa paketlardan ham foydalanish mumkin bo‘lgan nom hisoblanadi.

Masalan:

```go
type User struct {
	Name string
}
```

`User` katta harf bilan boshlangan. Shuning uchun boshqa package bu turni import orqali ishlata oladi.

Eksport qilinadigan nomlarning dokumentatsiya commenti odatda o‘sha nomning o‘zi bilan boshlanadi:

```go
// User tizim foydalanuvchisini ifodalaydi.
type User struct {
	Name string
}

// NewUser berilgan nom bilan yangi User qaytaradi.
func NewUser(name string) User {
	return User{Name: name}
}

// DisplayName foydalanuvchining ko‘rsatiladigan nomini qaytaradi.
func (u User) DisplayName() string {
	return u.Name
}
```

Bu yerda uchta eksport qilinadigan nom bor:

* `User`;
* `NewUser`;
* `DisplayName`.

Ularning har bir commenti tegishli nom bilan boshlanmoqda:

```text
User ...
NewUser ...
DisplayName ...
```

Bunday yozish usuli `go doc` yoki `pkg.go.dev` orqali dokumentatsiyani o‘qishni qulay qiladi. O‘quvchi izoh qaysi API haqida ekanini darhol ko‘radi.

Commentda faqat kodning o‘zidan aniq ko‘rinadigan implementatsiyani qayta yozishga harakat qilmang.

Masalan:

```go
// DisplayName u.Name qiymatini return qiladi.
func (u User) DisplayName() string {
	return u.Name
}
```

Bu comment kodni deyarli so‘zma-so‘z takrorlamoqda.

Quyidagi variant foydaliroq:

```go
// DisplayName foydalanuvchining ko‘rsatiladigan nomini qaytaradi.
```

Chunki chaqiruvchiga method ichida aynan qaysi field qaytarilayotganidan ko‘ra, methodning tashqi xatti-harakati muhimroq.

Bu API dokumentatsiyasidagi asosiy tamoyillardan biri: **implementatsiyani emas, foydalanuvchi uchun muhim bo‘lgan xatti-harakatni tushuntirish**.

## Package comment

Package ham o‘z dokumentatsiyasiga ega bo‘lishi mumkin.

Package comment `package` deklaratsiyasidan oldin yoziladi. Odatda u `Package <nom>` shaklida boshlanadi:

```go
// Package greeting turli tillarda salomlashish funksiyalarini beradi.
package greeting
```

Bu comment butun `greeting` paketining vazifasini tushuntiradi.

Bu yerda alohida bir funksiya yoki tur haqida emas, package umumiy hisobda nima uchun kerakligi haqida gap ketmoqda.

Masalan, package ichida:

```go
func Hello(name string) string
func HelloEnglish(name string) string
func HelloUzbek(name string) string
```

kabi bir nechta funksiyalar bo‘lishi mumkin.

Package comment esa ularning har birini alohida tushuntirish o‘rniga, paketning umumiy maqsadini aytadi:

```go
// Package greeting turli tillarda salomlashish funksiyalarini beradi.
```

Kichik package uchun comment oddiy `.go` fayllardan birida turishi mumkin.

Masalan:

```text
greeting/
    greeting.go
```

`greeting.go` ichida:

```go
// Package greeting turli tillarda salomlashish funksiyalarini beradi.
package greeting
```

deb yozish yetarli.

Package dokumentatsiyasi kattaroq bo‘lsa, uni alohida `doc.go` faylida saqlash qulay:

```text
greeting/
    doc.go
    greeting.go
    language.go
```

`doc.go` fayli odatda package haqida umumiy va kengroq dokumentatsiyani saqlash uchun ishlatiladi.

Masalan:

```go
// Package greeting turli tillarda salomlashish funksiyalarini beradi.
//
// Paket oddiy salomlashish matnlarini yaratish uchun ishlatiladi.
// Qo‘llab-quvvatlanadigan tillar alohida funksiyalar orqali tanlanadi.
package greeting
```

Bu maxsus majburiy sintaksis emas. Ya’ni Go package comment faqat `doc.go` ichida bo‘lishini talab qilmaydi. `doc.go` — katta dokumentatsiyani tartibli saqlash uchun keng tarqalgan usul.

Bitta package uchun bir-biriga zid bo‘lgan bir nechta package comment yozishdan qochish kerak. Package’ning umumiy vazifasi bitta aniq dokumentatsiyada tushuntirilgani ma’qul.

## `go doc` bilan dokumentatsiyani o‘qish

Go dokumentatsiyasini terminalning o‘zidan ham ko‘rish mumkin.

Buning uchun `go doc` buyrug‘i ishlatiladi:

```bash
go doc fmt
go doc fmt.Println
go doc ./...
```

Birinchi buyruq:

```bash
go doc fmt
```

`fmt` package dokumentatsiyasini ko‘rsatadi.

Unda package tavsifi va eksport qilinadigan API elementlarini ko‘rish mumkin.

Ikkinchi buyruq:

```bash
go doc fmt.Println
```

aniq `Println` funksiyasi haqida ma’lumot beradi.

Bu yondashuv katta package ichidan kerakli bitta funksiya yoki turni tez topishda foydali.

Masalan:

```bash
go doc strings.Contains
```

yoki:

```bash
go doc os.File
```

kabi buyruqlar bilan ham aniq API dokumentatsiyasini ko‘rish mumkin.

Joriy loyiha paketlarini ko‘rib chiqishda package path yoki joriy package bilan ishlash mumkin. Ko‘p paketli loyihalarda Go toolchain buyruqlari bilan `./...` patterni keng ishlatiladi.

`go doc` ayniqsa terminaldan chiqmasdan API qanday ishlashini tez tekshirish kerak bo‘lgan holatda qulay.

Standart kutubxona va ommaviy Go modullarining dokumentatsiyasini `pkg.go.dev` orqali ham o‘qish mumkin.

U yerda odatda quyidagilar ko‘rsatiladi:

* package dokumentatsiyasi;
* eksport qilingan type, function, method, constant va variable’lar;
* dokumentatsiya misollari;
* source code havolalari;
* modul versiyalari;
* package’ni import qiladigan boshqa modullar haqidagi ayrim ma’lumotlar.

Shuning uchun Go kodidagi comment faqat kodni o‘qiyotgan odam uchun emas. U Go dokumentatsiya vositalari orqali ko‘rsatiladigan API dokumentatsiyasining ham bir qismidir.

## Misol funksiyalari

Go dokumentatsiyasining foydali imkoniyatlaridan biri — bajariladigan `Example` funksiyalaridir.

`Example` oddiy matnli kod parchasi emas. U `_test.go` faylida yoziladigan haqiqiy Go funksiyasidir.

Masalan:

```go
package greeting_test

import (
	"fmt"

	"example.com/demo/greeting"
)

func ExampleHello() {
	fmt.Println(greeting.Hello("Ali"))
	// Output: Salom, Ali!
}
```

Bu funksiya `greeting.Hello` API’dan qanday foydalanishni ko‘rsatadi.

Eng muhim qism:

```go
// Output: Salom, Ali!
```

Agar `// Output:` commenti mavjud bo‘lsa, `go test` misolni ishga tushiradi va standard output natijasini commentda yozilgan kutilgan natija bilan solishtiradi.

Bu jarayonni bosqichma-bosqich ko‘rsak:

1. `ExampleHello()` ishga tushadi.
2. `greeting.Hello("Ali")` chaqiriladi.
3. Natija `fmt.Println` orqali stdout’ga chiqariladi.
4. Go hosil bo‘lgan outputni `// Output:` qatoridagi matn bilan solishtiradi.
5. Natijalar mos kelmasa, test muvaffaqiyatsiz tugaydi.

Demak, `Example` ikki vazifani bir vaqtda bajarishi mumkin:

* foydalanuvchiga API’dan qanday foydalanishni ko‘rsatadi;
* misol hali ham to‘g‘ri ishlayotganini test orqali tekshiradi.

`Example` funksiyalarining nomlanishi qaysi API bilan bog‘lanishini belgilaydi.

Package’ning o‘zi uchun umumiy misol:

```go
func Example() {
	// ...
}
```

Aniq funksiya yoki type uchun:

```go
func ExampleHello() {
	// ...
}

func ExampleUser() {
	// ...
}
```

Method uchun:

```go
func ExampleUser_DisplayName() {
	// ...
}
```

Bu yerda:

```text
ExampleUser_DisplayName
```

`User.DisplayName` methodiga tegishli misol sifatida taniladi.

Misol imkon qadar ixcham bo‘lishi va API’dan odatiy foydalanishni ko‘rsatishi kerak.

Masalan, dokumentatsiya misolida tasodifiy natijalarga ehtiyot bo‘lish kerak.

Quyidagilar testni beqaror qilishi mumkin:

* joriy vaqt;
* random qiymatlar;
* tartibi kafolatlanmagan ma’lumotlar;
* tashqi network so‘rovi;
* ishlashi tashqi servisga bog‘liq kod.

Masalan, output ichida hozirgi vaqtni chiqarish:

```go
fmt.Println(time.Now())
```

`// Output:` bilan tekshiriladigan misol uchun yaxshi tanlov emas. Har ishga tushirishda natija o‘zgaradi.

Xuddi shuningdek, map elementlarini to‘g‘ridan-to‘g‘ri aylanib, ularning aniq tartibini `Output` orqali tekshirish ham xavfli. Map iteration tartibiga tayanish kerak emas.

Dokumentatsiya misolining maqsadi murakkab test yaratish emas. U API’dan foydalanishning eng tushunarli va barqaror variantini ko‘rsatishi kerak.

## Misollar

### 1. Bajariladigan paketga izoh yozish

Bu misol `main` package uchun package comment qanday yozilishini ko‘rsatadi.

`main` ham package hisoblanadi. Farqi shundaki, u odatda executable dastur qurish uchun ishlatiladi.

```go
// Package main terminalga salomlashish xabarini chiqaradigan dasturni beradi.
package main

import "fmt"

func main() {
	fmt.Println("Salom, Go!")
}
```

Loyihani ishga tushirish va dokumentatsiyani ko‘rish uchun:

```bash
go mod init example.com/package-comment
go doc .
go run .
```

Birinchi buyruq:

```bash
go mod init example.com/package-comment
```

joriy katalogda yangi Go modul yaratadi.

Keyin:

```bash
go doc .
```

joriy package dokumentatsiyasini ko‘rsatadi.

Package comment:

```go
// Package main terminalga salomlashish xabarini chiqaradigan dasturni beradi.
```

`package main` deklaratsiyasidan bevosita oldin joylashgan.

Muhim jihat shundaki, comment shunchaki:

```text
Dastur "Salom, Go!" chiqaradi.
```

demayapti.

U package’ning umumiy vazifasini tushuntiryapti:

```text
terminalga salomlashish xabarini chiqaradigan dastur
```

Bu dokumentatsiya nuqtai nazaridan foydaliroq. Chunki implementatsiya keyinchalik o‘zgarishi mumkin, lekin package’ning umumiy vazifasi o‘sha holatda qolishi mumkin.

Oxirgi buyruq:

```bash
go run .
```

dasturni ishga tushiradi.

Natija:

```text
Salom, Go!
```

Bu misoldagi asosiy qoida: package comment package nima uchun mavjudligini qisqa va aniq tushuntirishi kerak.

### 2. Funksiya natijasini hujjatlashtirish

Bu misolda eksport qilinadigan funksiya commentida nafaqat funksiyaning umumiy vazifasi, balki alohida input holatining natijasi ham yozilgan.

```go
package main

import "fmt"

// Greeting berilgan ism uchun salomlashish matnini qaytaradi.
// Bo‘sh ism berilsa, "Salom, mehmon!" qaytariladi.
func Greeting(name string) string {
	if name == "" {
		return "Salom, mehmon!"
	}
	return "Salom, " + name + "!"
}

func main() {
	fmt.Println(Greeting("Ali"))
}
```

Buyruqlar:

```bash
go mod init example.com/function-doc
go doc -cmd . Greeting
go run .
```

Commentning birinchi qatori:

```go
// Greeting berilgan ism uchun salomlashish matnini qaytaradi.
```

funksiyaning umumiy vazifasini tushuntiradi.

Ikkinchi qator esa muhim edge case’ni hujjatlashtiradi:

```go
// Bo‘sh ism berilsa, "Salom, mehmon!" qaytariladi.
```

Bu ma’lumotni funksiya signature’idan bilib bo‘lmaydi:

```go
func Greeting(name string) string
```

Signature faqat funksiya `string` qabul qilib, `string` qaytarishini aytadi.

`name == ""` bo‘lganda nima sodir bo‘lishini esa dokumentatsiya tushuntiryapti.

`Greeting("Ali")` chaqirilganda:

```go
if name == ""
```

sharti `false` bo‘ladi.

Shuning uchun:

```go
return "Salom, " + name + "!"
```

ishlaydi.

Natija:

```text
Salom, Ali!
```

Agar:

```go
Greeting("")
```

chaqirilsa, natija:

```text
Salom, mehmon!
```

bo‘ladi.

Bu misoldagi asosiy qoida: dokumentatsiyada oddiy signature’dan bilinmaydigan muhim xatti-harakat va edge case’larni ko‘rsatish foydali.

### 3. Xato holatini izohda ko‘rsatish

Funksiya `error` qaytarsa, chaqiruvchi qaysi holatda xato kutishi kerakligini dokumentatsiyada ko‘rsatish muhim.

```go
package main

import (
	"errors"
	"fmt"
)

// Divide a qiymatini b qiymatiga bo‘ladi.
// b nol bo‘lsa, Divide xato qaytaradi.
func Divide(a, b float64) (float64, error) {
	if b == 0 {
		return 0, errors.New("nolga bo‘lish mumkin emas")
	}
	return a / b, nil
}

func main() {
	result, err := Divide(10, 2)
	if err != nil {
		fmt.Println("Xato:", err)
		return
	}
	fmt.Println(result)
}
```

Buyruqlar:

```bash
go mod init example.com/error-doc
go doc -cmd . Divide
go run .
```

Funksiyaning signature’i:

```go
func Divide(a, b float64) (float64, error)
```

ikki qiymat qaytaradi:

1. hisoblash natijasi;
2. `error`.

`b` nol bo‘lsa:

```go
if b == 0 {
	return 0, errors.New("nolga bo‘lish mumkin emas")
}
```

ishlaydi.

Bu holatda birinchi qaytish qiymati:

```text
0
```

bo‘ladi.

Bu `float64` turning zero value qiymatidir.

Lekin xato holatida chaqiruvchi aynan shu `0` qiymatiga qarab qaror qilmasligi kerak.

Masalan, bu noto‘g‘ri yondashuv bo‘lishi mumkin:

```go
result, _ := Divide(10, 0)
fmt.Println(result)
```

Chunki `0` haqiqiy hisoblash natijasi ham bo‘lishi mumkin.

To‘g‘ri yondashuv:

```go
result, err := Divide(10, 2)
if err != nil {
	fmt.Println("Xato:", err)
	return
}
```

Avval `err` tekshiriladi. Faqat xato bo‘lmaganda `result` haqiqiy natija sifatida ishlatiladi.

`Divide(10, 2)` uchun:

```text
10 / 2 = 5
```

natija chiqadi:

```text
5
```

Bu misoldagi asosiy qoida: API qaysi shartlarda `error` qaytarishi chaqiruvchi uchun muhim bo‘lsa, uni dokumentatsiyada aniq yozish kerak.

### 4. Tur va metodni hujjatlashtirish

Eksport qilinadigan `struct`, uning fieldlari va methodlari alohida ma’no bildirishi mumkin. Shuning uchun ularning har biriga kerakli joyda dokumentatsiya yoziladi.

```go
package main

import "fmt"

// Account foydalanuvchining hisob ma’lumotlarini saqlaydi.
type Account struct {
	// Name hisob egasining ko‘rsatiladigan nomi.
	Name string

	// Balance hisobdagi joriy mablag‘ni bildiradi.
	Balance int
}

// CanPay hisobda berilgan summa uchun mablag‘ yetarliligini bildiradi.
func (a Account) CanPay(amount int) bool {
	return amount >= 0 && a.Balance >= amount
}

func main() {
	account := Account{Name: "Ali", Balance: 100}
	fmt.Println(account.CanPay(60))
}
```

Buyruqlar:

```bash
go mod init example.com/type-doc
go doc -cmd . Account
go doc -cmd . Account.CanPay
go run .
```

`Account` commenti:

```go
// Account foydalanuvchining hisob ma’lumotlarini saqlaydi.
```

turning umumiy vazifasini tushuntiradi.

Field commentlari esa har bir qiymatning semantikasini tushuntiradi:

```go
// Name hisob egasining ko‘rsatiladigan nomi.
Name string
```

va:

```go
// Balance hisobdagi joriy mablag‘ni bildiradi.
Balance int
```

`CanPay()` esa hisobdagi mablag‘ ma’lum summani to‘lashga yetishini tekshiradi:

```go
func (a Account) CanPay(amount int) bool {
	return amount >= 0 && a.Balance >= amount
}
```

Bu yerda ikkita shart bor.

Birinchisi:

```go
amount >= 0
```

Manfiy qiymatni haqiqiy to‘lov summasi deb qabul qilmaslik uchun ishlatiladi.

Ikkinchisi:

```go
a.Balance >= amount
```

hisobdagi mablag‘ so‘ralgan summadan kam emasligini tekshiradi.

Misoldagi qiymatlar:

```text
Balance = 100
amount = 60
```

Birinchi shart:

```text
60 >= 0
true
```

Ikkinchi shart:

```text
100 >= 60
true
```

Ikkala shart ham `true`, shuning uchun:

```text
true
```

chiqadi.

Bu misol dokumentatsiya turning nomini takrorlash bilangina cheklanmasligi kerakligini ko‘rsatadi. Field yoki methodning biznes ma’nosi muhim bo‘lsa, uni alohida tushuntirish foydali.

### 5. Konstantalar guruhini izohlash

Bir mavzuga tegishli konstantalar ko‘pincha `const` guruhida yoziladi.

Bunday holatda umumiy comment guruhning vazifasini, alohida commentlar esa qiymatlar orasidagi farqni tushuntirishi mumkin.

```go
package main

import "fmt"

type Status int

// Buyurtma holatlari qayta ishlash bosqichlarini bildiradi.
const (
	StatusUnknown  Status = iota // StatusUnknown hali holat tanlanmaganini bildiradi.
	StatusAccepted               // StatusAccepted buyurtma qabul qilinganini bildiradi.
	StatusSent                   // StatusSent buyurtma yuborilganini bildiradi.
)

func main() {
	fmt.Println(StatusAccepted)
}
```

Buyruqlar:

```bash
go mod init example.com/const-doc
go doc -cmd . Status
go run .
```

Bu yerda `iota` ishlatilgan:

```go
StatusUnknown Status = iota
```

`iota` ushbu `const` guruhida `0`dan boshlanadi.

Qiymatlar bosqichma-bosqich:

```text
StatusUnknown  = 0
StatusAccepted = 1
StatusSent     = 2
```

`StatusUnknown`ning `0` bo‘lishi foydali tanlov.

Sababi `Status` aslida nomlangan `int` turi:

```go
type Status int
```

Yangi `Status` o‘zgaruvchisiga qiymat berilmasa, uning zero value qiymati `0` bo‘ladi:

```go
var status Status
```

Bu holatda:

```text
status == StatusUnknown
```

bo‘ladi.

Demak, qiymati hali tanlanmagan `Status` tasodifan `StatusAccepted` yoki `StatusSent` kabi haqiqiy biznes holatini anglatib qolmaydi.

Umumiy comment:

```go
// Buyurtma holatlari qayta ishlash bosqichlarini bildiradi.
```

konstantalar nima uchun bir guruhga yig‘ilganini aytadi.

Satr oxiridagi commentlar esa qiymatlarning alohida ma’nosini ko‘rsatadi.

Bu misoldagi asosiy qoida: konstanta nomining o‘zi yetarli bo‘lmasa, uning semantik ma’nosini dokumentatsiyada ko‘rsatish kerak.

### 6. Eksport qilinadigan o‘zgaruvchini izohlash

Package-level exported variable ham dokumentatsiyaga ega bo‘lishi kerak.

```go
package main

import "fmt"

// DefaultLimit bitta so‘rovda qaytariladigan elementlarning standart soni.
var DefaultLimit = 20

func main() {
	fmt.Println("Limit:", DefaultLimit)
}
```

Buyruqlar:

```bash
go mod init example.com/variable-doc
go doc -cmd . DefaultLimit
go run .
```

`DefaultLimit` nomidan bu qandaydir standart limit ekanini tushunish mumkin.

Lekin qaysi limit?

Comment shu savolga javob beradi:

```go
// DefaultLimit bitta so‘rovda qaytariladigan elementlarning standart soni.
```

Demak, bu masalan pagination yoki API response ichidagi elementlar soniga tegishli limit bo‘lishi mumkin.

Qiymat:

```go
var DefaultLimit = 20
```

bo‘lgani uchun dastur:

```text
Limit: 20
```

chiqaradi.

Bu misolda `20` namunaviy standart qiymat sifatida tanlangan.

Muhim nuqta shundaki, yaxshi dokumentatsiya faqat:

```text
DefaultLimit 20 ga teng.
```

demaydi.

Buni kodning o‘zidan ko‘rish mumkin.

Dokumentatsiya qiymat **nimani anglatishini** tushuntiradi.

### 7. Boshqa nomga dokumentatsiya havolasi berish

Go dokumentatsiya commentlarida boshqa identifikatorga havola berish mumkin.

Masalan:

```go
package main

import "fmt"

// Config dastur sozlamalarini saqlaydi.
type Config struct {
	Port int
}

// DefaultConfig yangi [Config] uchun xavfsiz boshlang‘ich qiymatlarni qaytaradi.
func DefaultConfig() Config {
	return Config{Port: 8080}
}

func main() {
	fmt.Println(DefaultConfig().Port)
}
```

Buyruqlar:

```bash
go mod init example.com/doc-link
go doc -cmd . DefaultConfig
go run .
```

Muhim qism:

```go
[Config]
```

Go dokumentatsiya tizimi bunday identifikator havolasini tegishli API nomi bilan bog‘lay oladi.

Natijada dokumentatsiyani qo‘llab-quvvatlaydigan ko‘rinishlarda o‘quvchi `Config` dokumentatsiyasiga o‘tishi mumkin.

Bu ayniqsa bir API boshqa tur yoki funksiyaga bevosita bog‘liq bo‘lganda foydali.

Masalan:

```go
// DefaultConfig yangi [Config] uchun xavfsiz boshlang‘ich qiymatlarni qaytaradi.
```

jumlasi `DefaultConfig()` aynan qanday tur bilan bog‘liq ekanini aniq ko‘rsatadi.

Funksiya:

```go
return Config{Port: 8080}
```

qaytaradi.

Shuning uchun:

```go
DefaultConfig().Port
```

natijasi:

```text
8080
```

bo‘ladi.

Bu yerda `8080` faqat misoldagi standart port. Haqiqiy dasturda standart qiymat loyiha talabi, protocol yoki konfiguratsiya siyosatiga qarab boshqacha bo‘lishi mumkin.

Bu misoldagi asosiy qoida: dokumentatsiya ichida boshqa API nomlarini bog‘lash o‘quvchiga tegishli tushunchalar orasida tez harakatlanishga yordam beradi.

### 8. Izohni sarlavha va ro‘yxatga ajratish

Package dokumentatsiyasi bir nechta mustaqil fikrni tushuntirsa, uni oddiy bitta uzun paragraf qilib yozish shart emas.

Go dokumentatsiya commentlari sarlavha va ro‘yxat kabi tuzilmalarni ham qo‘llab-quvvatlaydi.

```go
// Package main buyurtma holatini terminalga chiqaradi.
//
// # Holatlar
//
// Dastur quyidagi qiymatlardan foydalanadi:
//
//   - new — yangi buyurtma;
//   - sent — yuborilgan buyurtma.
package main

import "fmt"

func main() {
	fmt.Println("new")
}
```

Buyruqlar:

```bash
go mod init example.com/structured-doc
go doc .
go run .
```

Commentni qismlarga ajratib ko‘ramiz.

Birinchi qism:

```go
// Package main buyurtma holatini terminalga chiqaradi.
```

package’ning umumiy vazifasini aytadi.

Keyin bo‘sh comment qatori kelgan:

```go
//
```

Bu alohida paragraflarni ajratishga yordam beradi.

Sarlavha:

```go
// # Holatlar
```

`Holatlar` nomli kichik bo‘lim hosil qiladi.

Keyingi qism:

```go
// Dastur quyidagi qiymatlardan foydalanadi:
```

ro‘yxatga kirish matnidir.

Ro‘yxat:

```go
//   - new — yangi buyurtma;
//   - sent — yuborilgan buyurtma.
```

ikki qiymatning ma’nosini tushuntiradi.

Bunday strukturadan har bir kichik commentda foydalanish shart emas.

Masalan, quyidagi oddiy comment uchun sarlavha yaratish ortiqcha:

```go
// User tizim foydalanuvchisini ifodalaydi.
```

Lekin package dokumentatsiyasi bir nechta alohida mavzuni tushuntirsa, sarlavha, paragraf va ro‘yxatlar o‘qishni ancha qulay qiladi.

Dastur ishga tushirilganda:

```text
new
```

chiqadi.

Bu misoldagi asosiy qoida: uzun dokumentatsiyani oddiy matn devoriga aylantirmasdan, mantiqiy qismlarga ajratish mumkin.

### 9. Eskirgan API’ni belgilash

Ba’zan eski API’ni birdan o‘chirib tashlab bo‘lmaydi.

Sababi boshqa package yoki dasturlar undan hali foydalanayotgan bo‘lishi mumkin.

Bunday vaziyatda eski API saqlanadi, lekin dokumentatsiyada uning o‘rniga qaysi yangi API’dan foydalanish kerakligi ko‘rsatiladi.

```go
package main

import "fmt"

// NewGreeting berilgan ism uchun salomlashish qaytaradi.
func NewGreeting(name string) string {
	return "Salom, " + name
}

// OldGreeting berilgan ism uchun salomlashish qaytaradi.
//
// Deprecated: NewGreeting funksiyasidan foydalaning.
func OldGreeting(name string) string {
	return NewGreeting(name)
}

func main() {
	fmt.Println(OldGreeting("Ali"))
}
```

Buyruqlar:

```bash
go mod init example.com/deprecated-doc
go doc -cmd . OldGreeting
go run .
```

Muhim qism:

```go
// Deprecated: NewGreeting funksiyasidan foydalaning.
```

`Deprecated:` eski API ekanini ko‘rsatish uchun ishlatiladigan maxsus dokumentatsiya shaklidir.

Bu yerda `OldGreeting()` hali ham ishlaydi:

```go
func OldGreeting(name string) string {
	return NewGreeting(name)
}
```

Demak, eski kod:

```go
OldGreeting("Ali")
```

darhol buzilib qolmaydi.

Lekin yangi kod yozayotgan dasturchiga dokumentatsiya:

```text
NewGreeting funksiyasidan foydalaning.
```

deb yo‘l ko‘rsatadi.

Bu migratsiyani bosqichma-bosqich qilishga yordam beradi.

Eski funksiya ichida yangi funksiya chaqirilgani ham muhim:

```go
return NewGreeting(name)
```

Shu tariqa salomlashish logikasi ikki joyda takrorlanmaydi.

Natija:

```text
Salom, Ali
```

bo‘ladi.

Bu misoldagi asosiy qoida: eskirgan API saqlanishi kerak bo‘lsa, foydalanuvchini yangi API tomon aniq yo‘naltirish kerak.

### 10. Dokumentatsiya bilan birga manbani ko‘rish

Ba’zan faqat dokumentatsiya yetarli bo‘lmaydi. API qanday implementatsiya qilinganini ham tez ko‘rish kerak bo‘lishi mumkin.

Bunday holatda `go doc -src` foydali.

```go
package main

import "fmt"

// NormalizeCount manfiy qiymatni nolga almashtiradi.
func NormalizeCount(count int) int {
	if count < 0 {
		return 0
	}
	return count
}

func main() {
	fmt.Println(NormalizeCount(-3))
}
```

Buyruqlar:

```bash
go mod init example.com/source-doc
go doc -src -cmd . NormalizeCount
go run .
```

Oddiy `go doc` API dokumentatsiyasini ko‘rishga yordam beradi.

`-src` flagi esa source code’ni ham ko‘rsatadi:

```bash
go doc -src -cmd . NormalizeCount
```

Bu API qanday e’lon qilingani va uning implementatsiyasini tez tekshirish kerak bo‘lgan holatda qulay.

Funksiyaning ishlashini bosqichma-bosqich ko‘ramiz:

```go
func NormalizeCount(count int) int {
	if count < 0 {
		return 0
	}
	return count
}
```

Agar:

```go
NormalizeCount(-3)
```

chaqirilsa, shart:

```text
-3 < 0
```

ya’ni:

```text
true
```

bo‘ladi.

Shuning uchun:

```go
return 0
```

ishlaydi.

Natija:

```text
0
```

Agar:

```go
NormalizeCount(5)
```

chaqirilsa:

```text
5 < 0
false
```

bo‘ladi va asl qiymat qaytariladi:

```text
5
```

Bu yerda nozik jihat bor.

Shart:

```go
count < 0
```

ko‘rinishida yozilgan.

Demak, faqat manfiy qiymatlar almashtiriladi.

`0` uchun:

```text
0 < 0
false
```

bo‘ladi.

Shuning uchun `0` ham o‘zgarishsiz qaytariladi. Bu to‘g‘ri, chunki nol haqiqiy miqdorni ifodalashi mumkin.

Bu misoldagi asosiy qoida: `go doc -src` dokumentatsiya bilan birga implementatsiyani ham tekshirish kerak bo‘lgan vaziyatlarda foydali.
