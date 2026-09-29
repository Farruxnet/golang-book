# O‘zgaruvchilar va o‘zgarmaslar

O‘zgaruvchi — qiymatni nom bilan saqlash uchun ishlatiladigan xotira qismi. Dastur ishlashi davomida o‘zgaruvchidagi qiymatni o‘qish va kerak bo‘lsa o‘zgartirish mumkin.

Masalan, ob-havo dasturi shahar nomi va uning haroratini saqlashi kerak bo‘lishi mumkin. Kodda bu qiymatlarni shunchaki alohida yozib yurish o‘rniga ularga tushunarli nom beramiz:

```text
shahar
harorat
```

Bu nomlar qiymatning kod ichida nimani anglatishini ko‘rsatadi.

Masalan, quyidagi kodni ko‘rgan odam `28` soni nimani bildirishini darhol tushunmasligi mumkin:

```go
fmt.Println(28)
```

Lekin qiymatga nom berilsa, ma’no aniqroq bo‘ladi:

```go
harorat := 28
fmt.Println(harorat)
```

O‘zgaruvchilarning asosiy vazifasi ham shu: qiymatni saqlash va unga tushunarli nom orqali murojaat qilish.

## O‘zgaruvchini e’lon qilish

O‘zgaruvchidan foydalanishdan oldin uni e’lon qilish kerak.

E’lon qilish — Go’ga quyidagi ma’lumotlarni berish degani:

* o‘zgaruvchining nomi nima;
* u qanday turdagi qiymat saqlaydi;
* agar kerak bo‘lsa, boshlang‘ich qiymati nima.

Masalan:

```go
var yosh int = 25
```

Bu qatorni qismlarga ajratamiz:

* `var` — o‘zgaruvchi e’lon qilish uchun ishlatiladigan kalit so‘z;
* `yosh` — o‘zgaruvchining nomi;
* `int` — o‘zgaruvchining turi;
* `25` — boshlang‘ich qiymat.

`int` butun sonlarni saqlash uchun ishlatiladigan turlardan biridir.

Demak:

```go
var yosh int = 25
```

qatori “`yosh` nomli `int` o‘zgaruvchi yarat va unga `25` qiymatini ber” degan ma’noni anglatadi.

To‘liq dastur quyidagicha ko‘rinadi:

```go
package main

import "fmt"

func main() {
	var yosh int = 25
	var harorat float64 = 36.6

	fmt.Println("Yosh:", yosh)
	fmt.Println("Harorat:", harorat)
}
```

Bu yerda ikkita o‘zgaruvchi bor:

```go
var yosh int = 25
```

va:

```go
var harorat float64 = 36.6
```

`yosh` `int` turida.

`harorat` esa `float64` turida. `float64` kasr qismi bor sonlarni saqlash uchun ko‘p ishlatiladi.

Natija:

```text
Yosh: 25
Harorat: 36.6
```

`fmt.Println()` funksiyasiga vergul bilan bir nechta argument berish mumkin.

Masalan:

```go
fmt.Println("Yosh:", yosh)
```

Bu yerda ikkita argument berilgan:

1. `"Yosh:"`
2. `yosh`

`Println()` ularni terminalga chiqarayotganda orasiga mos bo‘sh joy qo‘yadi.

Bir qatorda ko‘proq qiymat ham berish mumkin:

```go
package main

import "fmt"

func main() {
	var yosh int = 25
	var harorat float64 = 36.6

	fmt.Println("Yosh:", yosh, "Harorat:", harorat)
}
```

Natija taxminan quyidagicha bo‘ladi:

```text
Yosh: 25 Harorat: 36.6
```

## Qiymatni o‘zgartirish

O‘zgaruvchi nomidan ma’lumki, uning qiymatini dastur davomida o‘zgartirish mumkin.

Masalan:

```go
var hisob int = 10
hisob = 15
fmt.Println(hisob)
```

Dastlab:

```text
hisob = 10
```

bo‘ladi.

Keyin:

```go
hisob = 15
```

qatori bajariladi.

Natijada eski `10` qiymati o‘rniga yangi `15` qiymati saqlanadi.

Terminalda:

```text
15
```

chiqadi.

Bu yerda `=` operatori yangi o‘zgaruvchi yaratmaydi.

U mavjud o‘zgaruvchiga yangi qiymat beradi.

Masalan:

```go
var hisob int = 10
```

o‘zgaruvchini e’lon qiladi.

Keyingi qator:

```go
hisob = 15
```

esa allaqachon mavjud `hisob` o‘zgaruvchisining qiymatini yangilaydi.

Yangi qiymat o‘zgaruvchining turiga mos bo‘lishi kerak.

Masalan:

```go
var yosh int = 25

// yosh = "yigirma besh"
```

Bu yerda `yosh` `int` turida.

`"yigirma besh"` esa `string`, ya’ni matn qiymati.

`string` qiymatni `int` o‘zgaruvchiga to‘g‘ridan-to‘g‘ri berib bo‘lmaydi. Shu sabab izoh olib tashlansa, kompilyatsiya xatosi yuz beradi.

Go statik turlangan til. Ya’ni o‘zgaruvchining turi kompilyatsiya vaqtida ma’lum bo‘ladi va keyin u boshqa turga “aylanib qolmaydi”.

## Turini aniqlash

Har doim o‘zgaruvchi turini qo‘lda yozish shart emas.

Agar boshlang‘ich qiymat mavjud bo‘lsa, Go ko‘pincha uning turini shu qiymatga qarab aniqlay oladi.

Masalan:

```go
var ism = "Aziza"
var yosh = 24
var narx = 19.5
```

Bu yerda Go quyidagicha xulosa qiladi:

```text
ism  → string
yosh → int
narx → float64
```

Bunday jarayon **type inference**, ya’ni turni qiymatdan avtomatik aniqlash deyiladi.

Masalan:

```go
var ism = "Aziza"
```

qatorida `string` alohida yozilmagan.

Lekin `"Aziza"` string qiymati bo‘lgani uchun Go `ism` turini `string` deb aniqlaydi.

Xuddi shunday:

```go
var yosh = 24
```

uchun odatiy tur `int` bo‘ladi.

Muhim jihat shuki, tur bir marta aniqlangandan keyin o‘zgarmaydi.

Masalan:

```go
var yosh = 24

// yosh = "yigirma to‘rt"
```

bu kodda `yosh` dastlab `int` sifatida aniqlangan.

Keyin unga `string` qiymat berib bo‘lmaydi.

Type inference turni yozishni qisqartiradi, lekin Go’dagi tur tekshiruvini yo‘q qilmaydi.

## Qisqa e’lon: `:=`

Funksiya ichida o‘zgaruvchini e’lon qilishning qisqa usuli mavjud:

```go
ism := "Aziza"
```

Bu sintaksis `:=` operatoridan foydalanadi.

Masalan:

```go
package main

import "fmt"

func main() {
	ism := "Aziza"
	yosh := 24

	fmt.Println(ism, yosh)
}
```

Bu yerda:

```go
ism := "Aziza"
```

ikkita ishni bir vaqtning o‘zida bajaradi:

1. `ism` nomli yangi o‘zgaruvchini e’lon qiladi;
2. unga `"Aziza"` boshlang‘ich qiymatini beradi.

Go turning o‘zini qiymatdan aniqlaydi.

Xuddi shunday:

```go
yosh := 24
```

qatorida `yosh` `int` sifatida aniqlanadi.

`:=` faqat funksiya ichida ishlatiladi.

Masalan, quyidagi ko‘rinish to‘g‘ri:

```go
func main() {
	son := 10
	fmt.Println(son)
}
```

Lekin package darajasida qisqa e’lon sintaksisidan foydalanib bo‘lmaydi.

Package darajasida `var` ishlatiladi:

```go
var son = 10
```

`=` va `:=` bir xil emas.

Quyidagi kodga e’tibor bering:

```go
son := 10
son = 20
```

Birinchi qator:

```go
son := 10
```

yangi o‘zgaruvchi yaratadi.

Ikkinchi qator:

```go
son = 20
```

esa mavjud o‘zgaruvchining qiymatini o‘zgartiradi.

Buni quyidagicha eslab qolish mumkin:

```text
:=  → e’lon qilish + qiymat berish
=   → mavjud o‘zgaruvchiga qiymat berish
```

Yangi boshlovchilar uchun funksiya ichida boshlang‘ich qiymati darhol ma’lum bo‘lgan o‘zgaruvchilarni `:=` bilan e’lon qilish qulay.

Masalan:

```go
ism := "Ali"
yosh := 30
```

Agar turini oldindan aniq ko‘rsatish kerak bo‘lsa yoki qiymat keyin berilsa, `var` qulayroq:

```go
var yosh int
yosh = 30
```

## Boshlang‘ich qiymatsiz o‘zgaruvchi

`var` yordamida o‘zgaruvchini boshlang‘ich qiymatsiz ham e’lon qilish mumkin:

```go
var son int
var matn string
var faol bool
```

Bunday o‘zgaruvchilar “qiymatsiz” yoki noma’lum holatda qolmaydi.

Go har bir tur uchun standart boshlang‘ich qiymat beradi.

Bu qiymat **zero value**, ya’ni nol qiymat deyiladi.

Asosiy turlarda:

| Tur         | Zero value          |
| ----------- | ------------------- |
| son turlari | `0`                 |
| `string`    | `""` — bo‘sh string |
| `bool`      | `false`             |

Masalan:

```go
package main

import "fmt"

func main() {
	var urinishlar int
	var xabar string
	var tayyor bool

	fmt.Printf("urinishlar=%d, xabar=%q, tayyor=%t\n", urinishlar, xabar, tayyor)
}
```

Natija:

```text
urinishlar=0, xabar="", tayyor=false
```

Bu yerda biz hech bir o‘zgaruvchiga boshlang‘ich qiymat bermadik.

Lekin Go avtomatik ravishda:

```text
urinishlar → 0
xabar      → ""
tayyor     → false
```

qiymatlarini berdi.

Bu Go’dagi muhim xususiyat.

Mahalliy o‘zgaruvchi `var` bilan e’lon qilingan bo‘lsa, u tasodifiy xotira qiymatini olmaydi. Unga turning zero value qiymati beriladi.

Bu misolda `fmt.Printf()` ishlatilgan:

```go
fmt.Printf("urinishlar=%d, xabar=%q, tayyor=%t\n", urinishlar, xabar, tayyor)
```

`Printf()` berilgan format asosida qiymatlarni chiqaradi.

Bu yerda:

* `%d` — butun son;
* `%q` — stringni qo‘shtirnoq bilan chiqarish;
* `%t` — `bool` qiymat;
* `\n` — yangi qator belgisi.

`%q` ishlatilgani uchun bo‘sh string ham aniq ko‘rinadi:

```text
xabar=""
```

Aks holda bo‘sh string terminalda ko‘zga ko‘rinmas edi.

## Bir nechta o‘zgaruvchini e’lon qilish

Go’da bir nechta o‘zgaruvchini bitta qatorda e’lon qilish mumkin.

Masalan:

```go
var kenglik, balandlik int = 800, 600
```

Bu yerda:

```text
kenglik   → 800
balandlik → 600
```

ikkalasi ham `int` turida.

Qiymatlar chap tomondagi nomlarga o‘z tartibida beriladi.

Ya’ni:

```go
var kenglik, balandlik int = 800, 600
```

amaliy jihatdan quyidagiga o‘xshaydi:

```go
var kenglik int = 800
var balandlik int = 600
```

Funksiya ichida qisqa e’lon bilan ham bir nechta o‘zgaruvchi yaratish mumkin:

```go
ism, shahar := "Ali", "Samarqand"
```

Bu yerda:

```text
ism    → "Ali"
shahar → "Samarqand"
```

bo‘ladi.

Chap va o‘ng tomondagi qiymatlar tartib bo‘yicha moslashtiriladi.

Bir nechta qiymatni bitta qatorda yozish kodni ixcham qilishi mumkin.

Lekin e’lon juda uzunlashib yoki tushunish qiyinlashib ketsa, ularni alohida qatorlarga bo‘lish yaxshiroq:

```go
ism := "Ali"
shahar := "Samarqand"
```

Maqsad faqat kamroq qator yozish emas. Kodni o‘qish oson bo‘lishi ham muhim.

## O‘zgaruvchilarga murojaat qilish

O‘zgaruvchini kodning istalgan joyida ishlatib bo‘lmaydi.

Har bir o‘zgaruvchining **scope**, ya’ni ko‘rinish sohasi mavjud.

Scope — o‘zgaruvchiga kodning qaysi qismidan murojaat qilish mumkinligini belgilaydi.

Go’da bloklar `{` va `}` bilan chegaralanadi.

Masalan:

```go
package main

import "fmt"

func main() {
	shahar := "Toshkent"

	if true {
		harorat := 28
		fmt.Println(shahar, harorat)
	}

	// fmt.Println(harorat)
}
```

Bu yerda:

```go
shahar := "Toshkent"
```

`main()` funksiyasining blokida e’lon qilingan.

Shu sabab `shahar` ichkaridagi `if` blokida ham ko‘rinadi:

```go
fmt.Println(shahar, harorat)
```

Lekin:

```go
harorat := 28
```

`if` blokining ichida e’lon qilingan.

Shu sabab u faqat shu ichki blok va undan ichkaridagi bloklarda ko‘rinadi.

`if` blokidan chiqqandan keyin:

```go
// fmt.Println(harorat)
```

ishlamaydi.

Agar izoh olib tashlansa, kompilyator `harorat` nomini bu joyda topa olmaydi.

Buni sodda ko‘rinishda shunday tasavvur qilish mumkin:

```text
main bloki
├── shahar ko‘rinadi
│
└── if bloki
    ├── shahar ko‘rinadi
    └── harorat ko‘rinadi

if tugagach:
shahar ko‘rinadi
harorat ko‘rinmaydi
```

Scope katta dasturlarda nomlarning bir-biriga aralashib ketishining oldini olishga yordam beradi.

## O‘zgaruvchilarni nomlash

O‘zgaruvchi nomi uning vazifasini imkon qadar aniq ko‘rsatishi kerak.

Masalan:

```go
x := 25
```

kodidan `x` nimani anglatishini darhol bilib bo‘lmaydi.

Agar qiymat yoshni bildirsa:

```go
yosh := 25
```

ancha tushunarli.

Xuddi shunday:

```go
narx := 15000
foydalanuvchiSoni := 120
```

nomlari qiymatlarning ma’nosini ko‘rsatadi.

Real loyihalarda identifikatorlarni ingliz tilida nomlash ko‘p uchraydi va ko‘pincha tavsiya qilinadi. Ayniqsa xalqaro jamoalarda bu kodni boshqalar bilan ishlashni osonlashtiradi.

Masalan:

```go
userCount := 120
totalPrice := 50000
```

O‘zgaruvchi nomlari uchun asosiy sintaktik qoidalar:

* nom harf yoki `_` bilan boshlanishi mumkin;
* keyingi belgilarda harf va raqam ishlatilishi mumkin;
* probel ishlatilmaydi;
* `-` belgisi nomning oddiy qismi sifatida ishlatilmaydi;
* `var`, `func`, `package` kabi Go kalit so‘zlarini nom sifatida ishlatib bo‘lmaydi;
* katta va kichik harflar farqlanadi.

Masalan:

```text
yosh
Yosh
```

Go uchun ikki xil nom.

Bir nechta so‘zdan tuzilgan nomlar odatda camelCase ko‘rinishida yoziladi:

```go
foydalanuvchiSoni
umumiyNarx
maksimalTezlik
```

Real Go kodida inglizcha nomlar bilan:

```go
userCount
totalPrice
maxSpeed
```

ko‘rinishi ko‘proq uchraydi.

Juda qisqa yoki ma’nosiz nomlardan keraksiz joyda foydalanmaslik kerak.

Lekin `i`, `j`, `x` kabi qisqa nomlar ham ayrim kichik va mahalliy kontekstlarda normal bo‘lishi mumkin. Masalan, qisqa `for` loop ichidagi indeks uchun `i` keng tarqalgan.

Muhimi, nom kodni tushunishni qiyinlashtirmasligi kerak.

## Ishlatilmagan o‘zgaruvchi

Go funksiya ichida e’lon qilingan, lekin ishlatilmagan o‘zgaruvchini xato deb hisoblaydi.

Masalan:

```go
func main() {
	yosh := 25
}
```

Bu yerda:

```go
yosh := 25
```

o‘zgaruvchi yaratadi.

Lekin `yosh` keyin hech qayerda ishlatilmagan.

Bunday kod kompilyatsiya xatosiga olib keladi.

Masalan, o‘zgaruvchini ishlatish mumkin:

```go
func main() {
	yosh := 25
	fmt.Println(yosh)
}
```

Yoki u umuman kerak bo‘lmasa, olib tashlash kerak.

Bu qoida kod ichida tasodifan qolib ketgan keraksiz o‘zgaruvchilarni aniqlashga yordam beradi.

Shu jihatdan u ishlatilmagan importlar qoidasiga o‘xshaydi.

Go kompilyatori kodni nisbatan toza saqlashga majbur qiladi.

## O‘zgarmaslar: `const`

Ba’zi qiymatlar dastur davomida o‘zgarmasligi kerak.

Masalan:

* bir sutkadagi soatlar soni;
* matematik koeffitsiyent;
* doimiy matn;
* konfiguratsiyadagi o‘zgarmaydigan compile-time qiymat.

Bunday qiymatlar uchun `const` ishlatiladi.

**Constant**, ya’ni o‘zgarmas — nomlangan, lekin keyin yangi qiymat berib bo‘lmaydigan qiymat.

Masalan:

```go
package main

import "fmt"

func main() {
	const kunlikSoat = 24
	const salomlashuv string = "Salom"

	fmt.Println(salomlashuv, kunlikSoat)
}
```

Bu yerda ikkita constant mavjud:

```go
const kunlikSoat = 24
```

va:

```go
const salomlashuv string = "Salom"
```

Birinchisida tur alohida yozilmagan.

Ikkinchisida esa `string` turi aniq ko‘rsatilgan.

Constantga keyin yangi qiymat berib bo‘lmaydi.

Masalan:

```go
const pi = 3.14

// pi = 3.1415
```

Agar ikkinchi qator izohdan chiqarilsa, kompilyatsiya xatosi yuz beradi.

Sababi `pi` o‘zgaruvchi emas, constant.

`var` va `const` orasidagi asosiy farqni quyidagicha eslab qolish mumkin:

```text
var   → qiymat keyin o‘zgarishi mumkin
const → qiymat qayta tayinlanmaydi
```

Go constantlari son, string va `bool` kabi compile-time constant qiymatlar bilan ishlashi mumkin.

Constantning qiymati kompilyatsiya vaqtida aniqlanishi kerak.

Masalan:

```go
const daqiqa = 60
const soat = 60 * daqiqa
```

Bu to‘g‘ri.

Kompilyator `soat` qiymatini hisoblay oladi.

Lekin oddiy funksiya chaqiruvi natijasini constant qilish mumkin emas.

Masalan:

```go
// const vaqt = time.Now()
```

`time.Now()` runtime paytida joriy vaqtni hisoblaydi.

Bu qiymat kompilyatsiya vaqtida oldindan ma’lum emas.

Shu sabab u `const` qiymati bo‘la olmaydi.

Bu yerda `const`ni “faqat o‘zgartirib bo‘lmaydigan variable” deb tasavvur qilish to‘liq to‘g‘ri emas.

Go’dagi constantlar compile-time tushunchasi bo‘lib, ularning o‘ziga xos tur va ifoda qoidalari mavjud.

Ketma-ket constant qiymatlar yaratish kerak bo‘lsa, `iota`dan foydalanish mumkin.

Bu imkoniyat Enum va iota darsida alohida tushuntiriladi.

Keyingi darsda Go’dagi asosiy ma’lumot turlari va ular bilan bajariladigan amallarni ko‘rib chiqamiz.

## Misollar

### 1. Qiymatlarni bir vaqtda almashtirish

Bu misol Go’da ikki o‘zgaruvchining qiymatini vaqtinchalik uchinchi o‘zgaruvchi yaratmasdan almashtirish mumkinligini ko‘rsatadi.

```go
package main

import "fmt"

func main() {
	a, b := 10, 20

	a, b = b, a

	fmt.Println(a, b)
}
```

Dastlab:

```text
a = 10
b = 20
```

Keyin:

```go
a, b = b, a
```

qatori bajariladi.

Muhim jihat shuki, o‘ng tomondagi qiymatlar avval olinadi.

Ya’ni Go avval:

```text
b → 20
a → 10
```

qiymatlarini tayyorlaydi.

Keyin ular chap tomonga mos tartibda beriladi:

```text
a ← 20
b ← 10
```

Natija:

```text
20 10
```

Boshqa tillarda bunday almashtirish uchun vaqtinchalik o‘zgaruvchi kerak bo‘lishi mumkin:

```text
temp = a
a = b
b = temp
```

Go’da esa ko‘p qiymatli assignment sabab bu ishni bitta qatorda bajarish mumkin.

### 2. Bir nechta o‘zgaruvchini bir vaqtda e’lon qilish

Bu misol bitta `:=` operatori bilan bir nechta o‘zgaruvchi yaratishni ko‘rsatadi.

```go
package main

import "fmt"

func main() {
	ism, yosh, faol := "Ali", 24, true

	fmt.Println(ism, yosh, faol)
}
```

Bu yerda uchta yangi o‘zgaruvchi yaratiladi:

```text
ism   → "Ali"
yosh  → 24
faol  → true
```

Qiymatlar chap tomondagi nomlarga tartib bo‘yicha beriladi.

Go har bir o‘zgaruvchining turini alohida aniqlaydi:

```text
ism   → string
yosh  → int
faol  → bool
```

Demak, bitta qisqa e’lon ichidagi o‘zgaruvchilar bir xil turda bo‘lishi shart emas.

Natija:

```text
Ali 24 true
```

Bu misolda asosiy qoida: `:=` bir nechta yangi o‘zgaruvchini bir vaqtning o‘zida e’lon qila oladi.

### 3. O‘zgaruvchining nol qiymati

Bu misol boshlang‘ich qiymat berilmagan o‘zgaruvchilar qanday qiymat olishini ko‘rsatadi.

```go
package main

import "fmt"

func main() {
	var son int
	var matn string
	var faol bool

	fmt.Printf("son=%d, matn=%q, faol=%t\n", son, matn, faol)
}
```

Biz quyidagi o‘zgaruvchilarga qiymat bermadik:

```go
var son int
var matn string
var faol bool
```

Go ularga avtomatik ravishda zero value beradi.

Bosqichma-bosqich:

```text
int    → 0
string → ""
bool   → false
```

Shu sabab natija:

```text
son=0, matn="", faol=false
```

bo‘ladi.

Bu misoldagi asosiy qoida: `var` bilan e’lon qilingan o‘zgaruvchi boshlang‘ich qiymatsiz qolmaydi. U o‘z turining zero value qiymatini oladi.

### 4. Qisqa e’londa mavjud o‘zgaruvchini yangilash

`:=` faqat barcha nomlar yangi bo‘lishini talab qilmaydi.

Agar chap tomonda kamida bitta yangi o‘zgaruvchi bo‘lsa, shu scope ichida mavjud o‘zgaruvchi ham birga ishlatilishi mumkin.

Masalan:

```go
package main

import "fmt"

func main() {
	son := 8

	son, kvadrat := son+1, son*son

	fmt.Println(son, kvadrat)
}
```

Birinchi qator:

```go
son := 8
```

`son`ni yaratadi.

Keyin:

```go
son, kvadrat := son+1, son*son
```

qatoriga kelamiz.

Chap tomonda:

* `son` — mavjud o‘zgaruvchi;
* `kvadrat` — yangi o‘zgaruvchi.

Yangi `kvadrat` borligi sabab `:=` ishlatish mumkin.

Muhim jihat: o‘ng tomondagi ifodalar assignment bajarilishidan oldin hisoblanadi.

Eski `son` qiymati:

```text
8
```

Shu sabab:

```text
son + 1 = 8 + 1 = 9
son * son = 8 * 8 = 64
```

Keyin qiymatlar yoziladi:

```text
son      ← 9
kvadrat  ← 64
```

Natija:

```text
9 64
```

`kvadrat` hisobida yangi `son = 9` emas, eski `son = 8` ishlatiladi.

Bu misoldagi asosiy qoida: ko‘p qiymatli assignmentda o‘ng tomondagi ifodalar avval hisoblanadi, keyin chap tomondagi o‘zgaruvchilarga yoziladi.

### 5. O‘zgaruvchining ko‘rinish sohasi

Bu misol ichki blokda tashqi o‘zgaruvchi bilan bir xil nomli yangi o‘zgaruvchi yaratish mumkinligini ko‘rsatadi.

```go
package main

import "fmt"

func main() {
	xabar := "tashqi"

	{
		xabar := "ichki"
		fmt.Println(xabar)
	}

	fmt.Println(xabar)
}
```

Dastlab tashqi blokda:

```go
xabar := "tashqi"
```

yaratiladi.

Keyin ichki blok ochiladi:

```go
{
	xabar := "ichki"
	fmt.Println(xabar)
}
```

Ichkaridagi:

```go
xabar := "ichki"
```

tashqi `xabar`ni o‘zgartirmaydi.

U shu ichki blok uchun boshqa yangi o‘zgaruvchi yaratadi.

Ichki blokda eng yaqin scope’dagi `xabar` ishlatiladi:

```text
ichki
```

Blok tugagach, ichki `xabar` scope’dan chiqadi.

Shundan keyin tashqi:

```go
xabar := "tashqi"
```

yana ko‘rinadi.

Natija:

```text
ichki
tashqi
```

Bu holat **shadowing**, ya’ni nomni soyalash deyiladi.

Shadowing ba’zan foydali bo‘lishi mumkin, lekin tasodifan yuz bersa xatoga olib kelishi mumkin. Chunki dasturchi tashqi o‘zgaruvchini yangilayapman deb o‘ylab, aslida yangi ichki o‘zgaruvchi yaratib qo‘yishi mumkin.

### 6. Paket darajasidagi o‘zgaruvchi

O‘zgaruvchini faqat funksiya ichida emas, package darajasida ham e’lon qilish mumkin.

Masalan:

```go
package main

import "fmt"

var tashriflar int

func main() {
	tashriflar++
	tashriflar++

	fmt.Println(tashriflar)
}
```

Bu yerda:

```go
var tashriflar int
```

hech qaysi funksiya ichida emas.

U package darajasida e’lon qilingan.

Boshlang‘ich qiymat berilmaganligi sabab:

```text
tashriflar = 0
```

bo‘ladi.

Keyin:

```go
tashriflar++
```

qiymatni bittaga oshiradi:

```text
0 → 1
```

Yana bir marta:

```go
tashriflar++
```

bajarilgach:

```text
1 → 2
```

bo‘ladi.

Natija:

```text
2
```

Package darajasidagi nom shu package ichidagi funksiyalardan ko‘rinadi.

Bu misolda `main()` funksiyasi `tashriflar`ga murojaat qila oladi.

Lekin package darajasidagi mutable o‘zgaruvchilarni keragidan ortiq ishlatish kodni tushunish va testlashni qiyinlashtirishi mumkin. Chunki qiymatni bir nechta funksiya o‘zgartirishi ehtimoli paydo bo‘ladi.

### 7. Turini aniq ko‘rsatib e’lon qilish

Ba’zan o‘zgaruvchining qiymati keyinroq beriladi.

Bunday holatda turning o‘zini oldindan ko‘rsatish mumkin:

```go
package main

import "fmt"

func main() {
	var masofa float64

	masofa = 12

	fmt.Printf("%.1f km\n", masofa)
}
```

Avval:

```go
var masofa float64
```

e’lon qilinadi.

Boshlang‘ich qiymat berilmaganligi sabab `float64` zero value:

```text
0
```

bo‘ladi.

Keyin:

```go
masofa = 12
```

bajariladi.

Bu yerda `12` yozuvi untyped integer constant hisoblanadi. Uning qiymati `float64` uchun ifodalash mumkin bo‘lgani sabab assignmentda `float64` o‘zgaruvchiga moslashtiriladi.

Natijada `masofa` ichidagi qiymat `float64` sifatida saqlanadi.

`Printf()`dagi:

```text
%.1f
```

sonni kasrdan keyin bitta raqam bilan chiqaradi.

Natija:

```text
12.0 km
```

Bu misoldagi asosiy qoida: o‘zgaruvchining turi e’lon paytida aniqlangan bo‘lsa, keyingi assignmentlar shu turga mos bo‘lishi kerak.

### 8. Guruhlab e’lon qilish

Bir-biriga tegishli o‘zgaruvchilarni `var` bloki ichida guruhlash mumkin.

Masalan:

```go
package main

import "fmt"

func main() {
	var (
		mahsulot = "kitob"
		soni     = 3
		narx     = 25000
	)

	fmt.Println(mahsulot, soni*narx)
}
```

Bu sintaksis:

```go
var (
	...
)
```

bir nechta `var` e’lonini bitta blokda yozish imkonini beradi.

Qiymatlar:

```text
mahsulot → "kitob"
soni     → 3
narx     → 25000
```

Keyin:

```go
soni * narx
```

hisoblanadi:

```text
3 * 25000 = 75000
```

Natija:

```text
kitob 75000
```

Guruhlangan e’lon ayniqsa bir vazifaga tegishli sozlamalar yoki bir-biriga yaqin qiymatlarni bir joyda ko‘rsatishda o‘qishni osonlashtirishi mumkin.

Lekin faqat sintaksis qisqa bo‘lishi uchun aloqasiz o‘zgaruvchilarni bitta blokka yig‘ish shart emas.

### 9. O‘zgarmas ifodani hisoblash

Constant qiymat boshqa constantlardan tashkil topgan ifoda orqali ham aniqlanishi mumkin.

Masalan:

```go
package main

import "fmt"

const (
	soniya = 1
	daqiqa = 60 * soniya
	soat   = 60 * daqiqa
)

func main() {
	fmt.Println(soat)
}
```

Endi qiymatlar qanday hosil bo‘lishini bosqichma-bosqich ko‘ramiz.

Avval:

```text
soniya = 1
```

Keyin:

```go
daqiqa = 60 * soniya
```

hisoblanadi:

```text
60 * 1 = 60
```

Demak:

```text
daqiqa = 60
```

Keyin:

```go
soat = 60 * daqiqa
```

hisoblanadi:

```text
60 * 60 = 3600
```

Shunday qilib:

```text
soat = 3600
```

bo‘ladi.

Natija:

```text
3600
```

Bu hisoblar runtime paytida har safar qayta bajarilishi shart emas. Ifodalar constantlardan tashkil topganligi sabab ularning qiymati compile time’da aniqlanishi mumkin.

Bunday nomlangan constantlar kodda ma’nosi tushunarsiz sonlarni to‘g‘ridan-to‘g‘ri yozish ehtiyojini kamaytiradi.

Masalan:

```go
timeout := 3600
```

o‘rniga kontekstga qarab:

```go
timeout := soat
```

ko‘rinishi kodning ma’nosini aniqroq ko‘rsatishi mumkin.
