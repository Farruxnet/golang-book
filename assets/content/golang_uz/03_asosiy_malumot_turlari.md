# Go’da asosiy ma'lumot turlari

Ma'lumot turi qiymat nimani ifodalashini va u bilan qanday amallar bajarish mumkinligini belgilaydi.

Masalan:

* `int` — butun sonlarni;
* `string` — matnni;
* `bool` — `true` yoki `false` ko‘rinishidagi mantiqiy holatni

ifodalaydi.

Tasavvur qiling, dastur foydalanuvchining ismi, yoshi va tizimga kirgan yoki kirmaganini saqlashi kerak. Bu qiymatlarning vazifasi bir-biridan farq qiladi. Shuning uchun ularning turlari ham boshqa bo‘ladi:

```go
package main

import "fmt"

func main() {
    ism := "Ali"         // string
    yosh := 25           // int
    tizimgaKirdi := true // bool

    fmt.Println(ism, yosh, tizimgaKirdi)
}
```

Natija:

```text
Ali 25 true
```

Bu yerda:

* `ism` — matn, shuning uchun uning turi `string`;
* `yosh` — butun son, shuning uchun uning turi `int`;
* `tizimgaKirdi` — ha yoki yo‘q ko‘rinishidagi holat, shuning uchun uning turi `bool`.

Turlar faqat qiymat qanday saqlanishini emas, u bilan qanday amallar bajarish mumkinligini ham belgilaydi.

Masalan, `yosh` bilan arifmetik amal bajarish mumkin:

```go
yosh := 25
keyingiYosh := yosh + 1
```

`ism` esa matn sifatida ishlatiladi:

```go
ism := "Ali"
xabar := "Salom, " + ism
```

`tizimgaKirdi` kabi `bool` qiymat esa shartni tekshirishda foydali:

```go
if tizimgaKirdi {
    // foydalanuvchi tizimga kirgan
}
```

## Ma'lumot turi nima uchun kerak?

Go — statik turli dasturlash tili. Bu degani, har bir o‘zgaruvchining turi kod kompilyatsiya qilinayotgan paytda ma'lum bo‘ladi.

Bu xususiyat kompilyatorga ko‘plab noto‘g‘ri amallarni dastur ishga tushishidan oldin aniqlashga yordam beradi.

Masalan, butun son saqlash uchun yaratilgan o‘zgaruvchiga keyin matn qiymatini berib bo‘lmaydi:

```go
var yosh int = 25

// yosh = "yigirma besh"
// string qiymatni int o'zgaruvchiga berib bo'lmaydi
```

`yosh` o‘zgaruvchisi `int` sifatida e'lon qilingan. Shu sababli unga `"yigirma besh"` kabi `string` qiymatni berishga urinish compile time xatosiga olib keladi.

Go ko‘p hollarda turni boshlang‘ich qiymatga qarab o‘zi ham aniqlay oladi:

```go
ism := "Ali" // string
yosh := 25   // int
narx := 19.5 // float64
```

Bu yerda tur nomlarini qo‘lda yozmadik. Lekin o‘zgaruvchilar baribir aniq turga ega:

* `"Ali"` matn literali bo‘lgani uchun `ism` — `string`;
* `25` butun son literali bo‘lgani uchun `yosh` — `int`;
* `19.5` kasrli son literali bo‘lgani uchun `narx` — `float64`.

Demak, `:=` ishlatilgani o‘zgaruvchining turi yo‘q degani emas. Kompilyator turini boshlang‘ich qiymatdan aniqlaydi.

O‘zgaruvchining turini `%T` formatlash belgisi yordamida ko‘rish mumkin:

```go
package main

import "fmt"

func main() {
    qiymat := 97
    fmt.Printf("Qiymat: %v, turi: %T\n", qiymat, qiymat)
}
```

Natija:

```text
Qiymat: 97, turi: int
```

Bu yerda:

* `%v` — qiymatni odatiy ko‘rinishda chiqaradi;
* `%T` — qiymatning Go’dagi turini chiqaradi.

Bu usul ayniqsa Go qaysi turni avtomatik tanlaganini tekshirishda qulay.

## Butun sonlar

Butun sonlarda kasr qismi bo‘lmaydi.

Masalan:

```text
-12
0
25
```

Kundalik hisob-kitoblarda ko‘pincha `int` turi ishlatiladi:

```go
var yosh int = 25
var harorat int = -5
var talabalarSoni = 30
```

Oxirgi qatorda tur alohida yozilmagan:

```go
var talabalarSoni = 30
```

Go boshlang‘ich qiymatga qarab bu o‘zgaruvchini `int` deb aniqlaydi.

`int` turi platforma arxitekturasiga qarab 32 yoki 64 bit o‘lchamga ega bo‘ladi. Amalda oddiy hisoblar, yosh, mahsulotlar soni, indekslar va sanagichlar uchun odatda `int` tanlanadi.

### Aniq o‘lchamdagi ishorali sonlar

Ba'zan turning aynan necha bit bo‘lishi muhim. Bunday holatda `int8`, `int16`, `int32` va `int64` turlaridan foydalanish mumkin.

Ular **ishorali**, ya'ni signed turlardir. Shuning uchun musbat sonlar bilan birga manfiy sonlar va nolni ham saqlay oladi.

| Tur     | O‘lchami |                                             Qiymatlar oralig‘i |
| ------- | -------: | -------------------------------------------------------------: |
| `int8`  |    8 bit |                                             -128 dan 127 gacha |
| `int16` |   16 bit |                                       -32 768 dan 32 767 gacha |
| `int32` |   32 bit |                         -2 147 483 648 dan 2 147 483 647 gacha |
| `int64` |   64 bit | -9 223 372 036 854 775 808 dan 9 223 372 036 854 775 807 gacha |

Masalan, `int8` faqat 256 ta turli qiymatni ifodalay oladi:

```text
-128 ... -1, 0, 1 ... 127
```

Shu sababli `128` qiymati `int8` oralig‘iga sig‘maydi.

### Ishorasiz butun sonlar

Go’da unsigned, ya'ni ishorasiz butun son turlari ham mavjud.

Ular manfiy qiymatlarni saqlamaydi:

| Tur      | O‘lchami |                     Qiymatlar oralig‘i |
| -------- | -------: | -------------------------------------: |
| `uint8`  |    8 bit |                        0 dan 255 gacha |
| `uint16` |   16 bit |                     0 dan 65 535 gacha |
| `uint32` |   32 bit |              0 dan 4 294 967 295 gacha |
| `uint64` |   64 bit | 0 dan 18 446 744 073 709 551 615 gacha |

Masalan, `uint8` uchun:

```text
0 ... 255
```

oraliq mavjud.

`uint` turi ham `int` kabi platforma arxitekturasiga qarab 32 yoki 64 bit bo‘ladi.

Oddiy hisob-kitoblarda ko‘pincha `int` qulayroq. Sababi Go turli son turlarini avtomatik aralashtirmaydi.

Masalan, `int` bilan `uint` qiymatini to‘g‘ridan-to‘g‘ri qo‘shib bo‘lmaydi:

```go
var a int = 10
var b uint = 20

// jami := a + b // compile time xatosi
```

Bunday holatda turlardan birini aniq konvertatsiya qilish kerak.

**Diqqat**

Tur sig‘dira oladigan qiymatlar oralig‘idan chiqish `overflow` deb ataladi.

```
Son uchun juda kichik tur tanlansa, qiymat unga sig‘masligi mumkin. Shuning uchun ma'lumotning mumkin bo‘lgan eng katta va eng kichik qiymatini hisobga olib tur tanlash muhim.
```

Masalan:

```go
package main

import "fmt"

func main() {
    var son int8 = 128
    fmt.Println(son)
}
```

Bu kod kompilyatsiyadan o‘tmaydi. Sababi `int8` uchun eng katta qiymat `127`, lekin biz `128` bermoqdamiz.

Natija taxminan quyidagicha bo‘ladi:

```text
.\main.go:6:17: cannot use 128 (untyped int constant)
as int8 value in variable declaration (overflows)
```

Kompilyator bu xatoni dastur ishga tushmasidan oldin aniqlaydi.

Bu yerda `128` hali aniq bir integer turiga bog‘lanmagan constant. Lekin uni `int8` o‘zgaruvchisiga joylashtirish so‘ralganda kompilyator qiymat oralig‘ini tekshiradi va u sig‘masligini ko‘radi.

## Kasrli sonlar

Kasr qismi mavjud sonlar uchun Go’da `float32` va `float64` turlari ishlatiladi:

```go
var harorat float64 = 36.6
var masofa float32 = 12.5
```

Ularning asosiy farqlaridan biri aniqlik va xotira hajmidir:

| Tur       | O‘lchami |     Taxminiy aniqligi |
| --------- | -------: | --------------------: |
| `float32` |   32 bit |   6–7 ta o‘nlik raqam |
| `float64` |   64 bit | 15–16 ta o‘nlik raqam |

Go kasrli son literalining turini avtomatik aniqlaganda odatda `float64` tanlaydi:

```go
narx := 12.5
```

Bu yerda `narx` turi `float64` bo‘ladi.

Shu sababli umumiy hisob-kitoblarda `float64` ko‘proq uchraydi.

Masalan:

```go
package main

import "fmt"

func main() {
    narx := 12.5
    miqdor := 3.0
    jami := narx * miqdor

    fmt.Printf("Jami: %.2f\n", jami)
}
```

Hisob quyidagicha bajariladi:

```text
narx   = 12.5
miqdor = 3.0

12.5 × 3.0 = 37.5
```

Natija:

```text
Jami: 37.50
```

`%.2f` formatlash belgisi kasrli sonni verguldan keyin ikki xona bilan chiqaradi.

Qiymatning o‘zi `37.5` bo‘lsa ham, ekranga:

```text
37.50
```

ko‘rinishida chiqariladi.

**Ma'lumot**

`float32` va `float64` ayrim o‘nli kasrlarni ikkilik formatda mutlaqo aniq saqlay olmaydi.

```
Masalan, `0.1` kabi qiymat ichki xotirada unga juda yaqin bo‘lgan son sifatida saqlanishi mumkin. Ko‘pchilik oddiy hisoblarda bu muammo sezilmaydi, lekin pul bilan ishlaganda kichik yaxlitlash xatolari muhim bo‘lishi mumkin.

Pul qiymatlarini saqlashda ko‘pincha eng kichik pul birligidan foydalanish qulay. Masalan, `12.50` qiymatni `1250` kabi butun son ko‘rinishida saqlash mumkin. Bu holatda hisob-kitob integer qiymatlar bilan bajariladi.
```

## Mantiqiy tur: `bool`

`bool` faqat ikki qiymatdan birini saqlaydi:

```text
true
false
```

Bu tur ha yoki yo‘q ko‘rinishidagi holatlarni ifodalash uchun ishlatiladi.

Masalan:

```go
var faol bool = true
var bloklangan bool = false
```

Bu yerda:

* `faol` — `true`, ya'ni foydalanuvchi faol;
* `bloklangan` — `false`, ya'ni foydalanuvchi bloklanmagan.

Taqqoslash operatorlarining natijasi ham `bool` turida bo‘ladi.

Masalan:

```go
package main

import "fmt"

func main() {
    yosh := 20
    voyagaYetgan := yosh >= 18

    fmt.Println("Voyaga yetganmi?", voyagaYetgan)
}
```

Bu yerda quyidagi taqqoslash bajariladi:

```go
yosh >= 18
```

Qiymatlarni qo‘yib ko‘rsak:

```text
20 >= 18
```

Bu shart rost. Shuning uchun:

```go
voyagaYetgan := true
```

bo‘ladi.

Natija:

```text
Voyaga yetganmi? true
```

Keyingi darslarda `bool` qiymatlarni `if` kabi shart operatorlari bilan ko‘p ishlatamiz.

## Matn turi: `string`

`string` matn saqlash uchun ishlatiladi.

Texnik jihatdan `string` — baytlar ketma-ketligi. Odatda bu baytlar UTF-8 formatidagi matnni ifodalaydi.

String literal qo‘shtirnoq ichida yoziladi:

```go
ism := "Dilshod"
xabar := "Go'ni o'rganamiz"
boshMatn := ""
```

Bu yerda:

* `"Dilshod"` — oddiy matn;
* `"Go'ni o'rganamiz"` — boshqa matn;
* `""` — uzunligi nol bo‘lgan bo‘sh string.

Ikki matnni `+` operatori yordamida birlashtirish mumkin:

```go
package main

import "fmt"

func main() {
    ism := "Dilshod"
    xabar := "Salom, " + ism + "!"

    fmt.Println(xabar)
}
```

Birlashtirish jarayoni quyidagicha:

```text
"Salom, " + "Dilshod" + "!"
```

Natijada yangi string hosil bo‘ladi:

```text
Salom, Dilshod!
```

Go source code odatda UTF-8 formatida yoziladi. Stringlar esa baytlar ketma-ketligini saqlaydi. UTF-8 matn bilan ishlaganda o‘zbekcha harflar, emoji va boshqa Unicode belgilarini saqlash mumkin.

Lekin bu yerda muhim bir noziklik bor: bitta ko‘rinadigan Unicode belgi har doim bitta bayt degani emas.

Shuning uchun `string` bilan ishlaganda **bayt soni** va **Unicode code point soni** bir-biridan farq qilishi mumkin.

### `byte` va `rune`

Go’da matn bilan ishlaganda `byte` va `rune` turlarini ko‘p uchratamiz.

`byte` — `uint8` turining boshqa nomi:

```go
type byte = uint8
```

U ko‘pincha bitta bayt qiymatini ifodalash uchun ishlatiladi.

Masalan:

```go
var qiymat byte = 65
```

`rune` esa `int32` turining boshqa nomi:

```go
type rune = int32
```

U odatda bitta Unicode code pointni ifodalash uchun ishlatiladi.

Rune literal bittalik tirnoq ichida yoziladi:

```go
var harf rune = 'O'
var maxsusHarf rune = '‘'
```

Bu yerda `"O"` string emas. `'O'` — bitta rune literal.

`string` uzunligini `len()` bilan olsak, Unicode belgilar soni emas, baytlar soni qaytadi.

Masalan:

```go
package main

import "fmt"

func main() {
    matn := "Go😊"

    fmt.Println("Baytlar:", len(matn))
    fmt.Println("Belgilar:", len([]rune(matn)))
}
```

Natija:

```text
Baytlar: 6
Belgilar: 3
```

Nega `len(matn)` `6` chiqardi?

Matn:

```text
Go😊
```

uchta ko‘rinadigan belgidan iborat:

```text
G
o
😊
```

Lekin UTF-8 formatida ularning bayt hajmi bir xil emas:

```text
G   -> 1 bayt
o   -> 1 bayt
😊  -> 4 bayt
```

Jami:

```text
1 + 1 + 4 = 6 bayt
```

Shuning uchun:

```go
len(matn)
```

natijasi:

```text
6
```

bo‘ladi.

Quyidagi ifoda esa:

```go
[]rune(matn)
```

stringni Unicode code pointlar ketma-ketligiga aylantiradi.

Natijada uchta rune hosil bo‘ladi:

```text
'G'
'o'
'😊'
```

Shuning uchun:

```go
len([]rune(matn))
```

natijasi `3` bo‘ladi.

Bu farq Unicode matnlarni indekslash va uzunligini hisoblashda muhim. `byte`, `rune` va UTF-8 bilan ishlashni keyingi darslarda batafsil ko‘ramiz.

## Kompleks sonlar

Go kompleks sonlar uchun ham alohida turlarga ega:

```text
complex64
complex128
```

Kompleks son ikki qismdan tashkil topadi:

* haqiqiy qism;
* mavhum qism.

Masalan:

```go
var z complex128 = complex(2, 3)
```

Bu qiymat matematik ko‘rinishda:

```text
2 + 3i
```

degan ma'noni anglatadi.

`complex()` funksiyasi ikkita qiymatni olib, kompleks son yaratadi:

```go
complex(2, 3)
```

Bu yerda:

```text
2 -> haqiqiy qism
3 -> mavhum qism
```

Kompleks sonlar ilmiy, matematik va muhandislik hisoblarida ishlatiladi.

Oddiy web dasturlar, CLI dasturlar yoki kundalik biznes logikasida ular kam uchraydi. Shu sababli hozircha ularning mavjudligini va asosiy vazifasini bilish yetarli.

## Turlarni o‘zgartirish

Go son turlarini avtomatik ravishda bir-biriga o‘girmaydi.

Masalan, `int` va `float64` alohida turlar hisoblanadi. Ularni bitta arifmetik ifodada ishlatish uchun kerakli qiymatni aniq konvertatsiya qilishimiz kerak.

Misol:

```go
package main

import "fmt"

func main() {
    var dona int = 5
    var narx float64 = 12.5

    jami := float64(dona) * narx
    fmt.Println(jami)
}
```

Bu yerda:

```go
dona
```

`int` turida.

`narx` esa:

```go
float64
```

turida.

Quyidagicha yozish mumkin emas:

```go
// jami := dona * narx
```

Sababi `int` va `float64` turidagi qiymatlar to‘g‘ridan-to‘g‘ri ko‘paytirilmaydi.

Shuning uchun:

```go
float64(dona)
```

deb `dona` qiymatini hisob davomida `float64`ga konvertatsiya qilamiz.

Hisob:

```text
dona = 5
float64(dona) = 5.0

5.0 × 12.5 = 62.5
```

Muhim jihat shundaki, konvertatsiya asl o‘zgaruvchining turini o‘zgartirmaydi.

Ya'ni:

```go
dona
```

hali ham `int`.

Faqat:

```go
float64(dona)
```

ifodasi yangi `float64` qiymat hosil qiladi.

Kasrli sonni butun songa aylantirish ham mumkin:

```go
kasr := 9.8
son := int(kasr)
```

Natijada:

```text
son = 9
```

bo‘ladi.

Bu **yaxlitlash emas**.

`float64` qiymati `int`ga konvertatsiya qilinganda kasr qismi tashlab yuboriladi va qiymat nol tomonga qisqartiriladi.

Masalan:

```text
9.8  -> 9
9.2  -> 9
-9.8 -> -9
-9.2 -> -9
```

Demak, `int(9.8)` natijasi `10` bo‘lmaydi.

Agar haqiqiy yaxlitlash kerak bo‘lsa, buning uchun boshqa usullardan foydalaniladi.

**Diqqat**

Katta sonni kichik oraliqli turga runtime qiymati sifatida konvertatsiya qilish natijani o‘zgartirib yuborishi mumkin.

Masalan:

```go
qiymat := 300
kichik := uint8(qiymat)
```

`uint8` faqat:

```text
0 ... 255
```

oralig‘ini saqlaydi.

`300` bu oraliqqa sig‘maydi. Konvertatsiyadan keyin yuqori bitlar tashlab yuboriladi va natija:

```text
44
```

bo‘ladi.

Buni quyidagicha tasavvur qilish mumkin:

```text
300 = 256 + 44
```

`uint8` faqat pastki 8 bitni saqlay olgani uchun `44` qoladi.

Lekin constant uchun qoida boshqacha.

Masalan:

```go
// var x = uint8(300)
```

kompilyatsiyadan o‘tmaydi. Sababi compiler constant qiymat `uint8` oralig‘iga sig‘masligini oldindan ko‘ra oladi.

Shuning uchun runtime qiymatni kichikroq turga konvertatsiya qilishdan oldin uning yangi tur oralig‘iga sig‘ishini tekshirish muhim.

Sonni matnga yoki matnni songa aylantirish oddiy son turlari orasidagi konvertatsiyadan farq qiladi.

Masalan:

```text
"123" -> 123
```

uchun odatda `strconv` paketidan foydalaniladi.

Bu mavzuni keyingi darslarda, paketlar va ma'lumot kiritish bilan ishlaganda batafsil ko‘ramiz.

## Nol qiymatlar

Go’da boshlang‘ich qiymat berilmagan o‘zgaruvchi tasodifiy qiymat olmaydi.

U avtomatik ravishda o‘z turining **zero value**, ya'ni nol qiymatini oladi.

Asosiy turlar uchun nol qiymatlar quyidagicha:

| Tur                    | Nol qiymat |
| ---------------------- | ---------- |
| butun va kasrli sonlar | `0`        |
| kompleks sonlar        | `0+0i`     |
| `bool`                 | `false`    |
| `string`               | `""`       |

Masalan:

```go
package main

import "fmt"

func main() {
    var son int
    var narx float64
    var faol bool
    var xabar string

    fmt.Printf("son=%d, narx=%.1f, faol=%t, xabar=%q\n", son, narx, faol, xabar)
}
```

Bu o‘zgaruvchilarning hech biriga boshlang‘ich qiymat bermadik:

```go
var son int
var narx float64
var faol bool
var xabar string
```

Shunga qaramay, ular ma'lum qiymatlarga ega:

```text
son   -> 0
narx  -> 0.0
faol  -> false
xabar -> ""
```

Natija:

```text
son=0, narx=0.0, faol=false, xabar=""
```

Bu Go’ning muhim xususiyatlaridan biri.

Masalan:

```go
var faol bool
```

yozsak, `faol` avtomatik ravishda `false` bo‘ladi.

Yoki:

```go
var xabar string
```

yozsak, `xabar` `nil` emas, bo‘sh string:

```go
""
```

bo‘ladi.

Zero value tushunchasi keyingi mavzularda struct, pointer, slice, map va interface bilan ishlaganda ham muhim bo‘ladi.

## Qaysi turni tanlash kerak?

Yangi boshlaganda quyidagi oddiy qoidalar yetarli:

* butun son uchun `int`;
* kasrli son uchun `float64`;
* matn uchun `string`;
* ha yoki yo‘q holati uchun `bool`;
* bitta Unicode code point uchun `rune`.

Masalan:

```go
yosh := 25            // int
narx := 19.99         // float64
ism := "Ali"          // string
faol := true          // bool
belgi := 'A'          // rune
```

Aniq o‘lchamdagi `int32`, `uint16` yoki `float32` kabi turlarni esa bunga haqiqiy ehtiyoj bo‘lganda tanlash ma'qul.

Masalan:

* binary format bilan ishlaganda;
* network protocol aniq bit o‘lchamini talab qilganda;
* fayl formatida maydon hajmi qat'iy belgilangan bo‘lsa;
* tashqi API yoki database ustuni bilan aniq tur mosligi kerak bo‘lsa.

Array, slice, map, struct, pointer, function, interface va channel ham Go’dagi turlardir.

Ular oddiy `int` yoki `string`dan murakkabroq vazifalarni bajaradi. Masalan:

* slice — qiymatlar ketma-ketligini saqlaydi;
* map — kalit va qiymat bog‘lanishini saqlaydi;
* struct — bir nechta fieldni bitta qiymatga birlashtiradi;
* pointer — boshqa qiymatning xotiradagi manziliga murojaat qiladi;
* function — funksiyaning o‘zi ham qiymat bo‘lishi mumkin;
* interface — turning qanday xatti-harakatga ega bo‘lishini ifodalaydi;
* channel — goroutinelar orasida qiymat uzatish uchun ishlatiladi.

Ularni keyingi qismlarda alohida ko‘rib chiqamiz.

**Ma'lumot**

`nil` alohida ma'lumot turi emas.

```
U pointer, slice, map, channel, function va interface kabi ayrim turlarda qiymat yoki obyekt mavjud emasligini bildirish uchun ishlatiladigan maxsus qiymat.
```

## Misollar

### 1. Butun son turining chegarasi

Bu misol `int8` turi qaysi oraliqdagi sonlarni saqlay olishini ko‘rsatadi.

`math` paketida ayrim son turlarining minimal va maksimal qiymatlarini ifodalovchi constantlar mavjud:

```go
package main

import (
    "fmt"
    "math"
)

func main() {
    fmt.Println(math.MinInt8, math.MaxInt8)
}
```

Natija:

```text
-128 127
```

Demak, `int8` turi:

```text
-128 ... 127
```

oralig‘idagi qiymatlarni saqlaydi.

Masalan:

```go
var a int8 = -128
var b int8 = 127
```

to‘g‘ri.

Lekin:

```go
// var c int8 = 128
```

xato.

Agar bundan kattaroq yoki kichikroq qiymatlar kerak bo‘lsa, `int16`, `int32`, `int64` yoki vazifaga mos boshqa tur tanlanadi.

Bu misol son turini tanlashda uning sig‘imini hisobga olish kerakligini ko‘rsatadi.

### 2. Ishorasiz butun son

Bu misol manfiy bo‘la olmaydigan kichik qiymatni `uint8` turida saqlashni ko‘rsatadi:

```go
package main

import "fmt"

func main() {
    var qizil uint8 = 255
    fmt.Println(qizil)
}
```

Natija:

```text
255
```

`uint8` oralig‘i:

```text
0 ... 255
```

bo‘lgani uchun `255` bu turga sig‘adi.

Masalan:

```go
var qizil uint8 = 255
```

RGB rang modelidagi rang kanalini ifodalash uchun tabiiy ko‘rinishi mumkin, chunki rang komponentlari ko‘pincha `0` dan `255` gacha bo‘ladi.

Lekin manfiy qiymatni to‘g‘ridan-to‘g‘ri constant sifatida berish mumkin emas:

```go
// var qizil uint8 = -1
```

Bu compile time xatosiga olib keladi.

Bu misol signed va unsigned integer turlarining asosiy farqini ko‘rsatadi.

### 3. Tur o‘zgartirish

Bu misol Go son turlarini yashirin ravishda aralashtirmasligini ko‘rsatadi:

```go
package main

import "fmt"

func main() {
    soni := 3
    narx := 12.5

    jami := float64(soni) * narx
    fmt.Println(jami)
}
```

Bu yerda:

```go
soni := 3
```

`int` turida.

```go
narx := 12.5
```

esa `float64` turida.

Shuning uchun:

```go
float64(soni)
```

orqali `soni` qiymatini hisob uchun `float64`ga o‘tkazamiz.

Keyin:

```text
3.0 × 12.5 = 37.5
```

Natija:

```text
37.5
```

Agar konvertatsiya yozilmasa:

```go
// jami := soni * narx
```

kompilyator `int` va `float64` bir-biriga mos emasligini bildiradi.

Bu misol Go’da son turlari orasidagi konvertatsiya aniq yozilishi kerakligini ko‘rsatadi.

### 4. Butun songa o‘tkazishda kasr qismi

Bu misol `float64` qiymatini `int`ga konvertatsiya qilganda nima bo‘lishini ko‘rsatadi:

```go
package main

import "fmt"

func main() {
    musbat, manfiy := 8.9, -8.9
    fmt.Println(int(musbat), int(manfiy))
}
```

Natija:

```text
8 -8
```

Bu yerda:

```text
8.9  -> 8
-8.9 -> -8
```

Kasr qismi tashlab yuborildi.

Muhim jihat: bu matematik yaxlitlash emas.

Masalan:

```text
8.9
```

eng yaqin butun songa yaxlitlansa `9` bo‘lishi mumkin edi.

Lekin:

```go
int(8.9)
```

natijasi `8`.

Manfiy qiymatda ham son nol tomonga qisqartiriladi:

```go
int(-8.9)
```

natijasi:

```text
-8
```

bo‘ladi.

Bu misol floating-point sondan integer turiga konvertatsiya qilishning xatti-harakatini ko‘rsatadi.

### 5. `byte` turida belgi saqlash

Bu misol `byte` aslida `uint8` uchun boshqa nom ekanini ko‘rsatadi:

```go
package main

import "fmt"

func main() {
    var belgi byte = 'G'
    fmt.Printf("%d %c %T\n", belgi, belgi, belgi)
}
```

Natija:

```text
71 G uint8
```

Bu yerda `'G'` rune literal.

`G` Unicode va ASCII jadvalida decimal ko‘rinishda:

```text
71
```

qiymatiga ega.

U `byte`ga sig‘gani uchun:

```go
var belgi byte = 'G'
```

yozish mumkin.

Formatlash belgilariga qarasak:

```text
%d -> son ko‘rinishi
%c -> belgi ko‘rinishi
%T -> tur
```

Shuning uchun bitta qiymat uch xil ko‘rinishda chiqariladi:

```text
71
G
uint8
```

`byte` — `uint8` turining aliasi. Shu sababli `%T` natijada `uint8`ni ko‘rsatadi.

Bu tur binary ma'lumot, fayl, network ma'lumoti yoki UTF-8 stringning alohida baytlari bilan ishlashda ko‘p uchraydi.

### 6. `rune` bilan Unicode belgi

Bu misol bitta Unicode code pointni `rune` sifatida saqlashni ko‘rsatadi:

```go
package main

import "fmt"

func main() {
    belgi := '‘'
    fmt.Printf("%c %U %T\n", belgi, belgi, belgi)
}
```

`belgi` qiymati bittalik tirnoq ichida yozilgan:

```go
'‘'
```

Shuning uchun u string emas, rune literal hisoblanadi.

`rune` esa `int32` turining aliasi.

Formatlash belgilarining vazifasi:

```text
%c -> belgining o‘zi
%U -> Unicode code point
%T -> Go turi
```

Shuning uchun natija taxminan quyidagicha bo‘ladi:

```text
‘ U+2018 int32
```

Bu yerda:

```text
U+2018
```

— chap egri bittalik qo‘shtirnoqning Unicode code pointi.

Bu misol `rune` faqat ASCII belgilar uchun emas, Unicode belgilar bilan ishlash uchun ham mos ekanini ko‘rsatadi.

### 7. Ilmiy yozuvdagi kasrli son

Juda katta yoki juda kichik floating-point qiymatlarni ilmiy yozuvda yozish mumkin:

```go
package main

import "fmt"

func main() {
    yoruglikTezligi := 3e8
    kichikQiymat := 1.5e-3

    fmt.Println(yoruglikTezligi, kichikQiymat)
}
```

`e` yozuvi 10 ning darajasini bildiradi.

Masalan:

```text
3e8
```

quyidagini anglatadi:

```text
3 × 10⁸
```

ya'ni:

```text
300000000
```

`1.5e-3` esa:

```text
1.5 × 10⁻³
```

ya'ni:

```text
0.0015
```

degani.

Tur aniq yozilmagani uchun ikkala qiymat ham odatda `float64` sifatida aniqlanadi:

```go
yoruglikTezligi := 3e8
kichikQiymat := 1.5e-3
```

Ilmiy hisoblarda bu yozuv juda katta yoki juda kichik sonlarni ancha ixcham ko‘rsatishga yordam beradi.

### 8. Xom matn literali

Go’da stringni oddiy qo‘shtirnoq bilan emas, teskari qo‘shtirnoq bilan ham yozish mumkin.

Bunday string **raw string literal**, ya'ni xom matn literali deyiladi:

```go
package main

import "fmt"

func main() {
    yol := `C:\Users\Ali\main.go`
    fmt.Println(yol)
}
```

Natija:

```text
C:\Users\Ali\main.go
```

Oddiy stringda `\` belgisi escape sequence boshlanishini bildirishi mumkin.

Masalan:

```go
"xabar\nkeyingi qator"
```

Bu yerda `\n` yangi qatorni bildiradi.

Raw string ichida esa `\` o‘z holicha saqlanadi:

```go
`C:\Users\Ali\main.go`
```

Shuning uchun Windows fayl yo‘llari yoki backslash ko‘p ishlatiladigan matnlarda raw string qulay bo‘lishi mumkin.

Raw string ko‘p qatorli matn uchun ham ishlatiladi:

```go
matn := `birinchi qator
ikkinchi qator
uchinchi qator`
```

Bu misol string literalni yozishning ikki xil usuli borligini ko‘rsatadi.

### 9. Kompleks son

Bu misol Go’da kompleks son yaratish va uning qismlarini alohida olishni ko‘rsatadi:

```go
package main

import "fmt"

func main() {
    z := complex(3.0, 4.0)

    fmt.Println(z, real(z), imag(z))
}
```

Quyidagi chaqiruv:

```go
complex(3.0, 4.0)
```

kompleks son yaratadi:

```text
3 + 4i
```

Bu yerda:

```text
3 -> haqiqiy qism
4 -> mavhum qism
```

`real()` haqiqiy qismni oladi:

```go
real(z)
```

natijasi:

```text
3
```

`imag()` esa mavhum qismni oladi:

```go
imag(z)
```

natijasi:

```text
4
```

Natija odatda quyidagiga o‘xshaydi:

```text
(3+4i) 3 4
```

Bu misol `complex()`, `real()` va `imag()` funksiyalarining asosiy vazifasini ko‘rsatadi.

### 10. Turini format orqali ko‘rish

Bu misol tashqi ko‘rinishi o‘xshash qiymatlar har xil turga ega bo‘lishi mumkinligini ko‘rsatadi:

```go
package main

import "fmt"

func main() {
    butun := 26
    kasr := 26.5
    matn := "26.5"

    fmt.Printf("%T %T %T\n", butun, kasr, matn)
}
```

Bu yerda:

```go
butun := 26
```

— `int`.

```go
kasr := 26.5
```

— `float64`.

```go
matn := "26.5"
```

— `string`.

`26.5` va `"26.5"` ko‘zga o‘xshash ko‘rinadi, lekin Go uchun ular mutlaqo boshqa qiymatlar.

Birinchisi son:

```go
26.5
```

Ikkinchisi esa belgilar ketma-ketligi:

```go
"26.5"
```

`%T` yordamida ularning turini ko‘rsak:

```text
int float64 string
```

natijasi chiqadi.

Bu misol qiymatning ekrandagi ko‘rinishi bilan uning Go’dagi turi bir xil tushuncha emasligini ko‘rsatadi.
