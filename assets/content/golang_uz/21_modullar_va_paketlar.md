# Go’da modullar va paketlar

Go loyihasida **paket** va **modul** bir-biriga bog‘liq tushunchalar, lekin ularning vazifasi har xil.

Paket kodni mantiqiy qismlarga ajratadi. Masalan, hisob-kitob bilan bog‘liq kodni `hisob` paketiga, HTTP bilan bog‘liq kodni boshqa paketga joylashtirish mumkin.

Modul esa bir yoki bir nechta paketni bitta versiyalanadigan birlik sifatida boshqaradi. Modul dependencylarni boshqarish va paketlarning to‘liq import yo‘lini aniqlashda ishlatiladi.

Bu farqni tushunish muhim. Chunki Go loyihasida quyidagi savollarga aynan paket va modul tushunchalari javob beradi:

* kod qaysi qismga tegishli;
* boshqa paketdagi funksiyani qanday import qilish kerak;
* dependency qaysi versiyada ishlatiladi;
* qaysi kod tashqi paketlardan ko‘rinadi;
* loyiha qaysi modulga tegishli.

## Paket nima?

**Paket** — odatda bitta katalogda joylashgan va bir xil `package` nomiga ega Go fayllari to‘plami.

Masalan:

```text
hisob/
├── qoshish.go
├── ayirish.go
└── kvadrat.go
```

Agar bu uchala fayl:

```go
package hisob
```

qatori bilan boshlansa, ular bir xil `hisob` paketiga tegishli bo‘ladi.

Paket bir nechta vazifani bajaradi:

* kodni mantiqiy qismlarga ajratadi;
* identifikatorlar uchun nomlar sohasini hosil qiladi;
* boshqa paketlardan qaysi nomlar ko‘rinishini belgilaydi;
* kompilyatsiya birligi sifatida ishlaydi;
* kodni boshqa paketlarda qayta ishlatishga imkon beradi.

Asosiy qoidalar:

* har bir `.go` fayl `package <nom>` qatori bilan boshlanadi;
* bitta katalogdagi oddiy `.go` fayllar odatda bitta paketga tegishli bo‘ladi;
* import qilinadigan paket nomi kodda boshqa paket nomlari bilan to‘qnashmasligi kerak;
* `package main` va `func main()` birga bajariladigan dastur kirish nuqtasini hosil qiladi.

Bu yerda bir nozik holat bor.

Test fayllari odatiy `.go` fayllardan biroz farq qilishi mumkin. Masalan, `hisob` paketining testlari quyidagi ikki usuldan birida yozilishi mumkin:

```go
package hisob
```

yoki:

```go
package hisob_test
```

Birinchi variant testni paketning o‘zida ishlatadi. Shu sabab test paket ichidagi eksport qilinmagan nomlarni ham ko‘ra oladi.

Ikkinchi variant esa tashqi paket kabi ishlaydi. Bunda test faqat eksport qilingan API orqali `hisob` paketidan foydalanadi.

## `main` paketi

Go’da bajariladigan dastur yaratish uchun paket nomi `main` bo‘lishi kerak.

Quyidagi to‘liq dastur bajariladigan paket yaratadi:

```go
package main

import "fmt"

func main() {
	fmt.Println("Go paketi bilan ishlash!")
}
```

Uni quyidagicha ishga tushirish mumkin:

```bash
go run main.go
```

Natija:

```text
Go paketi bilan ishlash!
```

Bu yerda ikkita alohida qoida ishlayapti.

Birinchisi:

```go
package main
```

Go’ga bu paket bajariladigan dastur bo‘lishi mumkinligini bildiradi.

Ikkinchisi:

```go
func main()
```

dastur boshlanadigan funksiyani belgilaydi.

Demak, faqat `main()` nomli funksiya yozish yetarli emas. U aynan `main` paketida bo‘lishi kerak.

Masalan:

```go
package yangi_nom

func main() {
}
```

Bu kodda `main()` mavjud. Lekin paket `main` emas. Shu sabab u bajariladigan dastur kirish nuqtasi sifatida qabul qilinmaydi.

Uni buyruq sifatida ishga tushirishga urinish quyidagiga o‘xshash xato berishi mumkin:

```text
package command-line-arguments is not a main package
```

Demak, `main()` funksiyasining maxsus ma’nosi faqat `package main` ichida paydo bo‘ladi.

Agar `main()` boshqa paket ichida yozilsa, u maxsus kirish nuqtasi emas. U shunchaki `main` nomli oddiy funksiya bo‘lib qoladi.

> **Ma'lumot**
>
> Kutubxona paketida `main()` bo‘lishi shart emas. Kutubxona paketining vazifasi boshqa paketlar import qilishi mumkin bo‘lgan funksiyalar, turlar, konstantalar va o‘zgaruvchilarni taqdim etishdir.

## Modul nima?

**Modul** — `go.mod` fayli bilan belgilangan paketlar to‘plami.

Oddiy qilib aytganda, paket kodni ichki qismlarga ajratadi. Modul esa shu paketlarning qaysi loyiha va qaysi versiyalanadigan birlikka tegishli ekanini belgilaydi.

Yangi loyiha yaratamiz:

```bash
mkdir mening-loyiham
cd mening-loyiham
go mod init example.com/mening-loyiham
```

`go mod init` joriy katalogda `go.mod` faylini yaratadi.

Natija taxminan quyidagicha bo‘ladi:

```text
module example.com/mening-loyiham

go 1.xx
```

Bu yerda:

```text
module example.com/mening-loyiham
```

modulning **kanonik yo‘li**ni belgilaydi.

Keyinchalik modul ichidagi paketlar import qilinganda shu yo‘l importning boshlanishi bo‘ladi.

Masalan, modul ichida `hisob` katalogi bo‘lsa:

```text
mening-loyiham/
├── go.mod
└── hisob/
    └── hisob.go
```

uning import yo‘li odatda:

```text
example.com/mening-loyiham/hisob
```

bo‘ladi.

`go.mod` ichidagi:

```text
go 1.xx
```

qatori esa modulning Go versiyasi bilan bog‘liq talabini bildiradi.

Bu qator Go’ni kompyuterga o‘rnatmaydi. U modul semantikasi, til xususiyatlari va toolchain qanday qoidalarni qo‘llashi kerakligi uchun muhim.

Aniq versiya qiymati `go mod init` ishlatilgan muhitdagi Go toolchain’iga bog‘liq.

## Lokal paket yaratish

Endi modul ichida alohida lokal paket yaratamiz.

Loyiha strukturasi:

```text
mening-loyiham/
├── go.mod
├── main.go
└── hisob/
    └── hisob.go
```

`hisob/hisob.go` fayli:

```go
package hisob

func Qosh(a, b int) int {
	return a + b
}

func Kvadrat(n int) int {
	return n * n
}

func ayir(a, b int) int {
	return a - b
}
```

Bu fayl:

```go
package hisob
```

deb boshlangani uchun `hisob` paketiga tegishli.

Paket ichida uchta funksiya bor:

```go
Qosh
Kvadrat
ayir
```

Keyin `main.go` yozamiz:

```go
package main

import (
	"fmt"

	"example.com/mening-loyiham/hisob"
)

func main() {
	fmt.Println(hisob.Kvadrat(3))
	fmt.Println(hisob.Qosh(3, 2))
}
```

Loyiha ildizida dasturni ishga tushiramiz:

```bash
go run .
```

Natija:

```text
9
5
```

Endi import yo‘li qanday hosil bo‘lganini bosqichma-bosqich ko‘ramiz.

`go.mod` ichida modul yo‘li:

```text
example.com/mening-loyiham
```

Paket esa:

```text
hisob/
```

katalogida joylashgan.

Shu sabab to‘liq import yo‘li:

```text
example.com/mening-loyiham
+
/hisob
=
example.com/mening-loyiham/hisob
```

bo‘ladi.

Go import paytida `.go` faylning o‘zini ko‘rsatmaydi.

Masalan, bunday yozilmaydi:

```go
import "example.com/mening-loyiham/hisob/hisob.go"
```

Buning o‘rniga paket joylashgan katalog import qilinadi:

```go
import "example.com/mening-loyiham/hisob"
```

`go run .` buyrug‘idagi `.` joriy katalogni bildiradi. Go joriy katalogdagi `main` paketini build qiladi va ishga tushiradi.

`Kvadrat()` funksiyasiga ham e’tibor bering:

```go
func Kvadrat(n int) int {
	return n * n
}
```

Bu yerda `math.Pow` ishlatish shart emas.

Masalan, `math.Pow` bilan yozilsa, odatda `float64` bilan ishlash kerak bo‘ladi:

```go
math.Pow(float64(n), 2)
```

Biz esa `int` sonning kvadratini hisoblayapmiz. Shu sabab:

```go
n * n
```

soddaroq va aniqroq.

Bundan tashqari, ortiqcha `int -> float64 -> int` konvertatsiyasi kerak bo‘lmaydi.

> **Diqqat**
>
> Juda katta `int` qiymatlarda `n * n` integer overflow keltirib chiqarishi mumkin. Ushbu misolda kichik qiymat ishlatilgani uchun bunday muammo yo‘q.

## Eksport qilinadigan nomlar

Go’da paket chegarasidan tashqarida ko‘rinadigan identifikatorlar **eksport qilinadigan nomlar** deyiladi.

Asosiy qoida juda sodda:

> Identifikator bosh harf bilan boshlansa, u eksport qilinadi.

Oldingi misolda:

```go
func Qosh(a, b int) int
```

va:

```go
func Kvadrat(n int) int
```

bosh harf bilan boshlangan.

Shu sabab boshqa paket ularni ishlata oladi:

```go
hisob.Qosh(3, 2)
hisob.Kvadrat(3)
```

Lekin:

```go
func ayir(a, b int) int
```

kichik harf bilan boshlangan.

Shu sabab `ayir` faqat `hisob` paketining o‘zida ko‘rinadi.

Masalan, boshqa paket ichida quyidagi kod kompilyatsiya bo‘lmaydi:

```go
// Bu kod boshqa paket ichida kompilyatsiya bo‘lmaydi:
// fmt.Println(hisob.ayir(5, 2))
```

Kompilyator xatosi `hisob.ayir` eksport qilinmaganini bildiradi.

Bu qoida faqat funksiyalarga tegishli emas. U quyidagilarga ham tegishli:

* type;
* struct field;
* method;
* variable;
* constant;
* function.

Masalan:

```go
type User struct {
	Name string
	age  int
}
```

Bu yerda `User` va `Name` eksport qilinadi. `age` esa faqat paket ichida ko‘rinadi.

Lekin faqat nomni bosh harf bilan yozish yaxshi API yaratish uchun yetarli emas.

Masalan:

```go
func X(a int) int
```

eksport qilingan funksiya bo‘lishi mumkin. Ammo `X` nomidan uning nima qilishi tushunilmaydi.

Shu sabab eksport qilinadigan API uchun:

* tushunarli nom;
* aniq vazifa;
* kerakli dokumentatsiya;
* barqaror xulq

ham muhim.

Paket nomlari uchun ham o‘xshash qoida bor.

Odatda paket nomini:

* qisqa;
* kichik harfli;
* tushunarli;
* birlik shaklida

tanlash ma’qul.

Masalan:

```text
http
json
user
config
```

`utils`, `common` yoki `helpers` kabi juda umumiy nomlar esa ehtiyotkorlik bilan ishlatilishi kerak.

Sababi bunday paketlar vaqt o‘tishi bilan bir-biriga aloqasi bo‘lmagan funksiyalar to‘planadigan joyga aylanib qolishi mumkin. Natijada paketning aniq mas’uliyati yo‘qoladi.

## Import qanday topiladi?

Go import yo‘lini tushunish uchun uchta asosiy qadamni ajratish foydali.

### 1. Joriy modul yo‘li aniqlanadi

Go avval `go.mod` fayliga qaraydi.

Masalan:

```text
module example.com/mening-loyiham
```

bo‘lsa, joriy modulning asosiy yo‘li:

```text
example.com/mening-loyiham
```

bo‘ladi.

### 2. Modul ichidagi katalog aniqlanadi

Masalan, quyidagi paket:

```text
mening-loyiham/
└── hisob/
```

uchun qolgan qism:

```text
/hisob
```

bo‘ladi.

Shunday qilib import:

```go
import "example.com/mening-loyiham/hisob"
```

hosil bo‘ladi.

### 3. Tashqi modul bo‘lsa, uning versiyasi tanlanadi

Agar import joriy modulga tegishli bo‘lmasa, Go dependency modullarni tekshiradi.

Masalan:

```go
import "example.com/boshqa-modul/client"
```

uchun `example.com/boshqa-modul` tashqi modul bo‘lishi mumkin.

Bunda Go modul grafigi orqali qaysi versiya buildga kiritilishini aniqlaydi.

### Import yo‘li va paket nomi

Ko‘p hollarda katalog nomi va paket nomi bir xil bo‘ladi.

Masalan:

```text
hisob/
```

ichida:

```go
package hisob
```

yoziladi.

Lekin bu qat’iy majburiy qoida emas.

Masalan, katalog:

```text
hisob/
```

bo‘lsa ham, fayl ichida boshqa paket nomi e’lon qilinishi mumkin:

```go
package calculator
```

Import yo‘li baribir katalog asosida qoladi:

```go
import "example.com/mening-loyiham/hisob"
```

Lekin kodda paketning e’lon qilingan nomi ishlatiladi:

```go
calculator.Qosh(...)
```

Amalda katalog nomi va paket nomini bir xil yoki ma’nosi aniq bog‘langan holda saqlash kodni tushunishni osonlashtiradi.

### Import alias

Ba’zan ikkita paketning nomi bir xil bo‘lishi mumkin.

Yoki paketga kod ichida boshqa, tushunarliroq nom bilan murojaat qilish kerak bo‘ladi.

Bunday paytda importga lokal alias berish mumkin:

```go
import hisoblash "example.com/mening-loyiham/hisob"
```

Endi paket:

```go
hisoblash.Qosh(...)
```

shaklida ishlatiladi.

Muhim jihat: alias import yo‘lini o‘zgartirmaydi.

Paket hali ham:

```text
example.com/mening-loyiham/hisob
```

yo‘lidan import qilinmoqda.

Faqat joriy faylda unga `hisoblash` nomi bilan murojaat qilinadi.

Aliasni har bir importga berish shart emas. Uni asosan:

* nomlar to‘qnashganda;
* paketning odatiy nomi shu kontekstda chalkash bo‘lganda

ishlatish ma’qul.

## `go.mod` direktivalari

Go modul tizimining asosiy fayli `go.mod`.

Unda bir nechta direktiva uchrashi mumkin.

### `module`

Joriy modul yo‘lini belgilaydi:

```text
module example.com/mening-loyiham
```

Bu qiymat modul ichidagi lokal paketlar import yo‘lining boshlanishi bo‘ladi.

### `go`

Modulning Go versiyasi bilan bog‘liq talabini belgilaydi:

```text
go 1.xx
```

Bu direktiva kompyuterga Go o‘rnatmaydi. U modul uchun ishlatiladigan til va toolchain semantikasiga ta’sir qiladi.

### `require`

Tashqi dependency va uning kerakli versiyasini ko‘rsatadi.

Masalan:

```text
require example.com/lib v1.2.3
```

Bu joriy modul `example.com/lib` moduliga bog‘liq ekanini bildiradi.

### `replace`

Dependency manbasini boshqa yo‘l yoki versiyaga almashtiradi.

Bu ayniqsa lokal development paytida qulay.

Masalan:

```text
replace example.com/shared => ../shared
```

Bunda Go `example.com/shared` modulini internetdan olish o‘rniga lokal:

```text
../shared
```

katalogidan foydalanadi.

Bu vaziyatni tasavvur qilamiz:

```text
projects/
├── app/
│   └── go.mod
└── shared/
    └── go.mod
```

`app` ustida ishlayotganda `shared` modulining hali publish qilinmagan lokal versiyasini tekshirish kerak bo‘lishi mumkin.

Shunda:

```text
replace example.com/shared => ../shared
```

qulay yechim bo‘ladi.

> **Diqqat**
>
> Lokal katalogga yozilgan `replace` boshqa kompyuterda ishlamasligi mumkin. Masalan, boshqa developerda `../shared` katalogi mavjud bo‘lmasligi ehtimoli bor. Shu sabab bunday `replace`ni commit qilishdan oldin jamoa va CI muhiti shu yo‘lni topa olishiga ishonch hosil qiling.

### `exclude`

Ma’lum modul versiyasini tanlashdan chiqarib tashlash uchun ishlatiladi.

Masalan, dependency’ning ma’lum versiyasida jiddiy muammo bo‘lsa, u `exclude` orqali build ro‘yxatidan chiqarilishi mumkin.

`go.sum`, dependency versiyalarini tanlash, modul grafigi va ular bilan ishlaydigan buyruqlar
Tashqi kutubxonalar va dependency management darsida batafsil
tushuntiriladi. Bu darsda esa lokal paketlar va modul tuzilishiga e’tibor qaratamiz.

## `internal` paketlar

Ba’zi paketlar faqat loyiha ichida ishlatilishi kerak.

Masalan, konfiguratsiyani yuklash yoki ichki servis implementatsiyasi tashqi foydalanuvchilar import qilishi kerak bo‘lmagan kod bo‘lishi mumkin.

Bunday holat uchun Go’da `internal` katalogi mavjud.

Masalan:

```text
mening-loyiham/
├── go.mod
├── internal/
│   └── config/
└── main.go
```

Bu yerda:

```text
internal/config
```

oddiy katalog nomi emas. `internal` Go toolchain uchun maxsus ma’noga ega.

Go `internal` ichidagi paketni faqat ruxsat etilgan ota katalog daraxti ichidagi kod import qilishiga yo‘l qo‘yadi.

Masalan, yuqoridagi:

```text
mening-loyiham/internal/config
```

paketi odatda shu loyiha daraxti ichidagi kod uchun mavjud bo‘ladi.

Lekin tashqi modul undan to‘g‘ridan-to‘g‘ri foydalanishga urinsa, Go importni rad etadi.

Bu katta loyihalarda foydali.

Masalan, sizda:

```text
public API
```

va:

```text
ichki implementatsiya
```

bo‘lishi mumkin.

Agar ichki implementatsiyani oddiy eksport qilingan paket sifatida qoldirsangiz, boshqa loyihalar tasodifan unga bog‘lanib qolishi mumkin.

Keyinchalik implementatsiyani o‘zgartirish qiyinlashadi.

`internal` esa bu chegarani faqat dokumentatsiya bilan emas, Go toolchain darajasida himoya qiladi.

## Keng tarqalgan xatolar

### Nisbiy import ishlatish

Go modul rejimida lokal paketni quyidagicha import qilish to‘g‘ri yondashuv emas:

```go
import "./hisob"
```

Buning o‘rniga modul yo‘lidan foydalaning:

```go
import "example.com/mening-loyiham/hisob"
```

Bu usulning afzalligi shundaki, import katalogning diskdagi tasodifiy joylashuviga emas, modulning kanonik yo‘liga bog‘lanadi.

Masalan, loyiha boshqa katalogga ko‘chirilsa ham:

```text
/home/user/projects/mening-loyiham
```

yoki:

```text
/work/src/mening-loyiham
```

import yo‘li o‘zgarmaydi:

```go
import "example.com/mening-loyiham/hisob"
```

### Import cycle yaratish

Go cyclic import’ga ruxsat bermaydi.

Masalan:

```text
a -> b
b -> a
```

ko‘rinishidagi dependency hosil bo‘lsa, build muvaffaqiyatsiz tugaydi.

Tasavvur qilamiz:

```go
// package a
import "example.com/project/b"
```

va:

```go
// package b
import "example.com/project/a"
```

Bu yerda `a` paketini build qilish uchun `b` kerak.

Lekin `b`ni build qilish uchun yana `a` kerak.

Natijada dependency aylana hosil qiladi.

Bunday vaziyatda odatda arxitekturani qayta ko‘rib chiqish kerak.

Masalan:

```text
a -> shared
b -> shared
```

ko‘rinishida umumiy turlar yoki funksiyalarni uchinchi kichik paketga ajratish mumkin.

Yana bir yechim — dependency yo‘nalishini qayta loyihalash.

Masalan, `a` paketining `b`ga va `b` paketining `a`ga bir vaqtning o‘zida bog‘lanishi o‘rniga, yuqori darajadagi kod bu ikki paketni birlashtirishi mumkin.

### Faylni alohida ishga tushirish

Tasavvur qilamiz, `main` paketi ikkita fayldan iborat:

```text
app/
├── main.go
└── helper.go
```

`main.go` ichida `helper.go`da e’lon qilingan funksiya ishlatilishi mumkin.

Agar:

```bash
go run main.go
```

deb ishga tushirsangiz, Go aynan ko‘rsatilgan fayl asosida ishlaydi. Shu sabab boshqa fayldagi kerakli kod chetda qolishi mumkin.

Bunday vaziyatda ko‘pincha:

```bash
go run .
```

to‘g‘riroq.

Bu buyruq joriy katalogdagi butun paketni build qiladi.

### Har katalogga alohida modul yaratish

Har bir Go paketiga alohida `go.mod` kerak emas.

Masalan:

```text
shop/
├── go.mod
├── cmd/
├── user/
├── order/
└── payment/
```

strukturadagi `user`, `order` va `payment` paketlari uchun alohida `go.mod` yaratish shart emas.

Ularning barchasi bitta:

```text
shop
```

modulining paketlari bo‘lishi mumkin.

Alohida modul faqat haqiqiy modul chegarasi kerak bo‘lganda foydali.

Masalan:

* komponent mustaqil versiyalanishi kerak;
* alohida release qilinadi;
* boshqa loyihalar uni mustaqil dependency sifatida ishlatadi;
* dependency lifecycle’i asosiy repozitoriydan ajralishi kerak.

Aks holda har katalogga modul yaratish dependency boshqaruvini keraksiz murakkablashtiradi.

## Interviewda nimalarga e’tibor beriladi?

Paket va modullar mavzusida interview paytida quyidagi farqlarni aniq tushuntira olish foydali.

* **Paket** kodni tashkil qilish, kompilyatsiya va nomlar sohasi birligidir.
* **Modul** esa paketlar to‘plamining versiyalash va dependency boshqaruv chegarasidir.
* Eksport qilinadigan nomlar bosh harf bilan boshlanadi. Bu qoida paket chegarasiga taalluqli.
* `go.mod` modul yo‘li va dependency versiyasi talablarini saqlaydi.
* `go.sum` dependency kontentining nazorat summalarini saqlaydi.
* Go import cycle’ga ruxsat bermaydi.
* `v2` va undan katta major versiyalar odatda modul hamda import yo‘lida `/v2`, `/v3` kabi suffix ishlatadi.
* Har bir paket uchun alohida modul yaratish shart emas.
* `internal` katalogi ichki implementatsiyani import darajasida cheklash uchun ishlatiladi.

Keyingi darsda modulga tashqi kutubxona qo‘shish, undan keyin esa eksport qilinadigan API uchun Go dokumentatsiyasini yozishni ko‘ramiz.

## Misollar

Quyidagi misollar paket va modul bilan ishlashning turli jihatlarini alohida ko‘rsatadi.

Har bir misolni mustaqil kichik loyiha sifatida ko‘rish qulay. Agar ularni amalda sinab ko‘rsangiz, har biri uchun alohida katalog yarating. Aks holda bir katalogda qayta-qayta `go mod init` ishlatish `go.mod already exists` kabi holatlarga olib kelishi mumkin.

### 1. Eng kichik modul yaratish

Bu misolda bitta bajariladigan paket uchun yangi modul boshlanadi.

`main.go`:

```go
package main

import "fmt"

func main() {
	fmt.Println("Birinchi modul ishladi")
}
```

Loyiha yaratish va ishga tushirish:

```bash
mkdir birinchi-modul
cd birinchi-modul
go mod init example.com/birinchi-modul
go run .
```

Buyruqlarni bosqichma-bosqich ko‘ramiz.

```bash
mkdir birinchi-modul
```

yangi katalog yaratadi.

```bash
cd birinchi-modul
```

shu katalogga o‘tadi.

Keyin:

```bash
go mod init example.com/birinchi-modul
```

joriy katalogda `go.mod` yaratadi.

Unda taxminan:

```text
module example.com/birinchi-modul
```

yozuvi paydo bo‘ladi.

Bu yerda:

```text
example.com/birinchi-modul
```

modul yo‘li.

Koddagi:

```go
package main
```

esa bu bajariladigan paket ekanini bildiradi.

Nihoyat:

```bash
go run .
```

joriy katalogdagi `main` paketini build qiladi va ishga tushiradi.

Natija:

```text
Birinchi modul ishladi
```

Bu misoldagi asosiy qoida:

> Modul `go.mod` bilan aniqlanadi, bajariladigan paket esa `package main` va `func main()` bilan aniqlanadi.

### 2. Paket darajasidagi nomlardan foydalanish

Bu misolda o‘zgaruvchi va funksiya `main` paketining paket darajasidagi nomlar sohasida e’lon qilinadi.

```go
package main

import "fmt"

var greeting = "Salom"

func message(name string) string {
	return greeting + ", " + name
}

func main() {
	fmt.Println(message("Go"))
}
```

Ishga tushirish:

```bash
go mod init example.com/package-scope
go run .
```

Bu kodda:

```go
var greeting = "Salom"
```

funksiyadan tashqarida e’lon qilingan.

Shu sabab `greeting` paket darajasidagi o‘zgaruvchi hisoblanadi.

Xuddi shunday:

```go
func message(name string) string
```

ham paket darajasida e’lon qilingan funksiya.

`main()` ichida:

```go
message("Go")
```

chaqirilganda `message()`:

```go
return greeting + ", " + name
```

qatoriga keladi.

Bu yerda:

```text
greeting = "Salom"
name = "Go"
```

Shu sabab natija:

```text
Salom, Go
```

bo‘ladi.

`greeting` va `message` kichik harf bilan boshlangan.

Demak, ular shu paket ichida ko‘rinadi, lekin boshqa paketga eksport qilinmaydi.

Muhim jihat:

```text
example.com/package-scope
```

modul yo‘li paket ichidagi nomlar sohasini o‘zgartirmaydi.

Modul dependency va import chegarasini belgilaydi. Paket esa identifikatorlarning kod ichidagi ko‘rinish chegarasiga ta’sir qiladi.

### 3. Eksport qilinadigan va ichki nomlarni ajratish

Bu misolda bosh harfli va kichik harfli funksiyalar aynan bir paket ichida ishlatiladi.

```go
package main

import "fmt"

func PublicMessage() string {
	return "eksport qilinadigan nom"
}

func privateMessage() string {
	return "faqat paket ichidagi nom"
}

func main() {
	fmt.Println(PublicMessage())
	fmt.Println(privateMessage())
}
```

Ishga tushirish:

```bash
go mod init example.com/export-demo
go run .
```

Kodda:

```go
func PublicMessage() string
```

bosh harf bilan boshlangan.

Shu sabab `PublicMessage` eksport qilinadigan nom.

Lekin:

```go
func privateMessage() string
```

kichik harf bilan boshlangan.

Shu sabab u eksport qilinmaydi.

Bir qarashda savol tug‘ilishi mumkin: nega `main()` ikkala funksiyani ham chaqira olyapti?

Sababi uchala funksiya ham bir xil:

```go
package main
```

ichida joylashgan.

Paketning o‘zida eksport qoidasi ichki foydalanishni cheklamaydi.

Eksport faqat paket tashqarisidan ko‘rinishga ta’sir qiladi.

Demak:

```go
PublicMessage()
privateMessage()
```

ikkalasi ham shu paket ichida ishlaydi.

Ammo boshqa paket bu paketni import qilsa, faqat:

```go
PublicMessage()
```

dan foydalana oladi.

Natija:

```text
eksport qilinadigan nom
faqat paket ichidagi nom
```

Bu misoldagi asosiy qoida:

> Bosh harf paket tashqarisiga eksportni belgilaydi. U paket ichidagi foydalanishni cheklamaydi.

### 4. `init()` va `main()` bajarilish tartibi

Bu misolda paket tayyorlanayotganda `init()`, undan keyin `main()` ishga tushadi.

```go
package main

import "fmt"

var status = "boshlanmadi"

func init() {
	status = "tayyor"
	fmt.Println("init:", status)
}

func main() {
	fmt.Println("main:", status)
}
```

Ishga tushirish:

```bash
go mod init example.com/init-demo
go run .
```

Jarayonni bosqichma-bosqich ko‘ramiz.

Avval paket darajasidagi o‘zgaruvchi boshlang‘ich qiymatini oladi:

```go
var status = "boshlanmadi"
```

Demak, dastlab:

```text
status = "boshlanmadi"
```

Keyin `init()` bajariladi:

```go
func init() {
	status = "tayyor"
	fmt.Println("init:", status)
}
```

Bu yerda `status`:

```text
"tayyor"
```

qiymatiga o‘zgaradi.

Shundan keyin ekranga:

```text
init: tayyor
```

chiqariladi.

Keyin `main()` ishga tushadi:

```go
func main() {
	fmt.Println("main:", status)
}
```

`status` allaqachon `init()` tomonidan o‘zgartirilgan.

Shu sabab natija:

```text
init: tayyor
main: tayyor
```

bo‘ladi.

`init()`ni odatda kod ichidan bevosita chaqirmaysiz. Go uni paket initialization jarayonining bir qismi sifatida o‘zi bajaradi.

Bu misoldagi asosiy qoida:

> `main` paketida paket initialization tugagandan keyingina `main()` ishga tushadi.

### 5. Importga lokal nom berish

Bu misolda `fmt` paketi lokal `format` nomi bilan import qilinadi.

```go
package main

import format "fmt"

func main() {
	format.Println("Paket alias orqali chaqirildi")
}
```

Ishga tushirish:

```bash
go mod init example.com/import-alias
go run .
```

Oddiy holatda:

```go
import "fmt"
```

yozilsa, kodda:

```go
fmt.Println(...)
```

ishlatiladi.

Bu misolda esa:

```go
import format "fmt"
```

yozilgan.

Bu sintaksisda:

```text
format
```

lokal alias.

```text
"fmt"
```

esa haqiqiy import yo‘li.

Shu sabab kodda:

```go
format.Println(...)
```

ishlatiladi.

Muhim jihat: import qilinayotgan paket o‘zgarmadi.

Paket hali ham standart kutubxonadagi:

```text
fmt
```

paketi.

Faqat shu faylda unga:

```text
format
```

nomi berildi.

Alias odatda:

* bir xil nomli paketlar to‘qnashganda;
* joriy kontekstda boshqa nom aniqroq bo‘lganda

foydali.

Lekin oddiy holatda `fmt`ni `fmt` sifatida qoldirish o‘qishni osonlashtiradi.

Natija:

```text
Paket alias orqali chaqirildi
```

### 6. Bir nechta paketni guruhlab import qilish

Bu misolda ikkita standart paket import qilinadi.

```go
package main

import (
	"errors"
	"fmt"
)

func main() {
	err := errors.New("namunaviy xato")
	fmt.Println(err)
}
```

Ishga tushirish:

```bash
go mod init example.com/grouped-imports
go run .
```

Bir nechta import bo‘lsa, Go’da ularni qavs ichida guruhlash odatiy usul:

```go
import (
	"errors"
	"fmt"
)
```

`errors` paketi:

```go
errors.New("namunaviy xato")
```

orqali yangi `error` qiymatini yaratadi.

Bu qiymat:

```go
err := errors.New("namunaviy xato")
```

qatorida `err` o‘zgaruvchisiga beriladi.

Keyin:

```go
fmt.Println(err)
```

xatoni ekranga chiqaradi.

Natija:

```text
namunaviy xato
```

`gofmt` importlarni standart ko‘rinishda formatlashga yordam beradi.

Masalan, lokal loyiha paketlari va standart kutubxona paketlari orasidagi guruhlar `gofmt` yoki `goimports` kabi vositalar orqali tartibli saqlanishi mumkin.

Bu misoldagi asosiy qoida:

> Bir nechta paketni `import (...)` bloki ichida guruhlash Go kodida standart va o‘qilishi qulay usul hisoblanadi.

### 7. Joriy modul yo‘lini ko‘rish

Bu misolda modul yaratilib, uning kanonik yo‘li Go buyrug‘i orqali tekshiriladi.

```go
package main

import "fmt"

func main() {
	fmt.Println("Modul yo‘li go.mod faylida saqlanadi")
}
```

Buyruqlar:

```bash
go mod init example.com/module-path
go list -m
go run .
```

Avval:

```bash
go mod init example.com/module-path
```

`go.mod` yaratadi.

Unda:

```text
module example.com/module-path
```

yozuvi bo‘ladi.

Keyin:

```bash
go list -m
```

joriy asosiy modulning yo‘lini chiqaradi.

Natija:

```text
example.com/module-path
```

bo‘ladi.

Bu qiymat faqat ma’lumot uchun emas.

Keyinchalik modul ichida yangi paket yaratsak:

```text
client/
```

uning import yo‘li:

```text
example.com/module-path/client
```

bo‘lishi mumkin.

Demak, `go list -m` orqali ko‘rilgan modul yo‘li lokal paket importlarining boshlanish qismi sifatida ishlatiladi.

So‘ng:

```bash
go run .
```

dastur ishga tushiriladi.

Natija:

```text
Modul yo‘li go.mod faylida saqlanadi
```

### 8. Joriy paket haqidagi ma’lumotni olish

Bu misolda `go list` joriy katalogdagi paket nomi va import yo‘lini ko‘rsatadi.

```go
package main

import "fmt"

func main() {
	fmt.Println("Joriy paket: main")
}
```

Buyruqlar:

```bash
go mod init example.com/package-info
go list -f "{{.Name}} {{.ImportPath}}" .
go run .
```

Bu yerda asosiy buyruq:

```bash
go list -f "{{.Name}} {{.ImportPath}}" .
```

`go list` paket haqida turli metadata ma’lumotlarini bera oladi.

`-f` flag’i natija formatini template orqali belgilaydi.

Template ichidagi:

```text
.Name
```

paket nomini bildiradi.

Bizning kodda:

```go
package main
```

bo‘lgani uchun:

```text
.Name = main
```

bo‘ladi.

Template ichidagi:

```text
.ImportPath
```

paketning import yo‘lini bildiradi.

Modul:

```text
example.com/package-info
```

va paket modul ildizida joylashgani uchun import yo‘li:

```text
example.com/package-info
```

bo‘ladi.

Natija:

```text
main example.com/package-info
```

ko‘rinishida chiqadi.

Keyin:

```bash
go run .
```

dastur ishga tushiriladi.

Natija:

```text
Joriy paket: main
```

Bu misoldagi asosiy qoida:

> Paket nomi va import yo‘li bir xil tushuncha emas. `.Name` paket deklaratsiyasidan, `.ImportPath` esa modul va katalog joylashuvidan kelib chiqadi.

### 9. Modul faylini tartibga keltirish

Bu misolda `go mod tidy` kod importlari bilan modul fayllarini moslashtiradi.

```go
package main

import "fmt"

func main() {
	values := []int{2, 4, 6}
	fmt.Println("Qiymatlar:", values)
}
```

Buyruqlar:

```bash
go mod init example.com/tidy-demo
go mod tidy
go run .
```

Kod faqat:

```go
import "fmt"
```

dan foydalanadi.

`fmt` Go standart kutubxonasining bir qismi.

Standart kutubxona paketlari `go.mod` ichida tashqi modul dependency sifatida `require` yozuvini talab qilmaydi.

Shu sabab:

```bash
go mod tidy
```

ishlatilgandan keyin tashqi dependency paydo bo‘lmaydi.

Bu xato emas.

Aksincha, dependency ro‘yxatining bo‘sh bo‘lishi aynan shu dastur uchun to‘g‘ri holat.

`go mod tidy`ning vazifasi shunchaki dependency qo‘shish emas.

U koddagi importlarga qarab modul fayllarini kerakli holatga keltiradi.

Masalan, kelajakda tashqi paket ishlatila boshlasa, `tidy` kerakli dependency yozuvlarini moslashtirishi mumkin.

Agar dependency endi ishlatilmasa, ortiqcha yozuvlarni ham olib tashlashi mumkin.

Dastur natijasi:

```text
Qiymatlar: [2 4 6]
```

Bu misoldagi asosiy qoida:

> `go mod tidy` dependency yaratish uchun emas, kod importlari va modul metadata’sini bir-biriga mos saqlash uchun ishlatiladi.

### 10. Moduldan bajariladigan fayl qurish

Bu misolda `go build` joriy `main` paketidan bajariladigan fayl yaratadi.

```go
package main

import "fmt"

func main() {
	fmt.Println("Build qilingan dastur")
}
```

Buyruqlar:

```bash
go mod init example.com/build-demo
go build -o build-demo .
```

Bu yerda:

```bash
go build
```

kodni kompilyatsiya qiladi.

`go run`dan farqli ravishda, asosiy maqsad dasturni darhol ishga tushirish emas. `go build` build natijasini yaratadi.

Flag:

```bash
-o build-demo
```

natija faylining nomini aniq belgilaydi.

Demak, Unix-ga o‘xshash tizimlarda katalogda taxminan:

```text
build-demo
```

nomli executable paydo bo‘ladi.

Windows’da executable nomlash va kengaytma bilan bog‘liq xulq platformaga moslashadi.

Buyruq oxiridagi:

```bash
.
```

joriy katalogdagi paketni bildiradi.

Bu katalogda:

```go
package main
```

va:

```go
func main()
```

mavjud bo‘lgani uchun bajariladigan dastur quriladi.

Agar joriy katalog oddiy kutubxona paketi bo‘lsa, u `main` executable sifatida qurilmaydi.

Masalan:

```go
package hisob
```

paketi kutubxona vazifasini bajarsa, `go build` uni kompilyatsiya qilib tekshirishi mumkin, lekin undan `main` dasturidagi kabi executable yaratish maqsad qilinmaydi.

Build qilingan dastur ishga tushirilganda natija:

```text
Build qilingan dastur
```

bo‘ladi.

Bu misoldagi asosiy qoida:

> `go run` build qilib vaqtincha ishga tushiradi, `go build` esa paketni kompilyatsiya qilish uchun ishlatiladi va `main` paketidan executable yaratishi mumkin.
