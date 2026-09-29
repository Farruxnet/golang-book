# Goda enum va `iota`

Go dasturlash tilida boshqa ayrim tillardagi kabi alohida:

```text
enum
```

kalit so'zi mavjud emas.

Masalan, Java, C# yoki boshqa tillarda ma'lum bir qiymatlar to'plamini `enum` sifatida e'lon qilish mumkin.

Go'da esa shu vazifa odatda:

* nomlangan tur;
* `const` konstantalari;
* kerak bo'lsa `iota`;

yordamida bajariladi.

Masalan, tizimda buyurtmaning holatlari bo'lsin:

```text
unknown
pending
processing
completed
```

Bularni oddiy `int` sifatida saqlash mumkin:

```go
const (
    StatusUnknown    = 0
    StatusPending    = 1
    StatusProcessing = 2
    StatusCompleted  = 3
)
```

Lekin bunda qiymatlar oddiy `int` bo'lib qoladi.

Go'da buning o'rniga alohida nomlangan tur yaratish yaxshiroq:

```go
type Status int
```

Keyin konstantalarni shu turga bog'lash mumkin:

```go
const (
    StatusUnknown Status = iota
    StatusPending
    StatusProcessing
    StatusCompleted
)
```

Natijada kodda oddiy son bilan emas, ma'nosi aniq bo'lgan `Status` turi bilan ishlaymiz.

`iota` esa bu yerda:

```text
0
1
2
3
```

qiymatlarini qo'lda yozmaslikka yordam beradi.

## Nomlangan tur va konstantalar

Quyidagi misolni ko'ramiz:

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

Natija:

```text
2
false
```

Bu koddagi eng muhim qism:

```go
type Status int
```

Bu yerda `int` asosida yangi `Status` turi yaratildi.

`Status`ning asosiy turi `int`, lekin Go uchun u alohida nomlangan tur hisoblanadi.

Keyin:

```go
const (
    StatusUnknown Status = iota
    StatusPending
    StatusProcessing
    StatusCompleted
)
```

orqali `Status` uchun mumkin bo'lgan asosiy konstantalar e'lon qilindi.

Birinchi qatorda:

```go
StatusUnknown Status = iota
```

yozilgan.

`const` guruhi boshlanganda `iota` qiymati:

```text
0
```

bo'ladi.

Shuning uchun:

```go
StatusUnknown == 0
```

Keyingi qatorda yangi ifoda yozilmagan:

```go
StatusPending
```

Go oldingi ifodani takrorlaydi va `iota` bittaga oshadi.

Natijada:

```go
StatusPending == 1
```

Keyingi qiymatlar:

```go
StatusProcessing == 2
StatusCompleted  == 3
```

bo'ladi.

Shuning uchun:

```go
status := StatusProcessing
fmt.Println(status)
```

natijasi:

```text
2
```

bo'ladi.

Keyin:

```go
status == StatusCompleted
```

tekshirilmoqda.

`status` qiymati:

```text
2
```

`StatusCompleted` esa:

```text
3
```

bo'lgani uchun natija:

```text
false
```

chiqadi.

### Nega oddiy `int` emas, alohida tur ishlatamiz?

Quyidagicha yozish ham mumkin edi:

```go
const (
    StatusUnknown    = 0
    StatusPending    = 1
    StatusProcessing = 2
    StatusCompleted  = 3
)
```

Lekin bu qiymatlar oddiy `int` bo'lib qoladi.

Alohida:

```go
type Status int
```

turini yaratish kodning ma'nosini aniqroq qiladi.

Masalan:

```go
func SetStatus(status Status) {
}
```

funksiyasi ko'rinishidan ham parametr oddiy son emas, aynan tizim holati ekanini tushunish mumkin.

Bu:

```go
func SetStatus(status int) {
}
```

ko'rinishidan ancha tushunarli.

Nomlangan turga keyinchalik metodlar ham qo'shish mumkin:

```go
func (s Status) String() string {
    // ...
}
```

yoki:

```go
func (s Status) Valid() bool {
    // ...
}
```

Shuning uchun nomlangan tur faqat sonlarga boshqa nom berish emas. U ma'lum bir tushunchani alohida tur sifatida ifodalash imkonini beradi.

## Nol qiymatni `Unknown` uchun ishlatish

Go'da har bir turning zero value, ya'ni boshlang'ich qiymati mavjud.

`int` asosidagi tur uchun bu:

```text
0
```

bo'ladi.

Masalan:

```go
var status Status
```

deb yozsak va unga hech qanday qiymat bermasak:

```go
status == 0
```

bo'ladi.

Shuning uchun ko'pincha enumga o'xshash turlarda `0` qiymatini:

```go
StatusUnknown
```

kabi noma'lum yoki hali belgilanmagan holatga ajratish foydali.

Masalan:

```go
const (
    StatusUnknown Status = iota
    StatusPending
    StatusProcessing
    StatusCompleted
)
```

Endi:

```go
var status Status
```

deb e'lon qilingan qiymat avtomatik ravishda:

```go
StatusUnknown
```

holatiga teng bo'ladi.

Bu yaxshi dizayn, chunki zero value tasodifan haqiqiy biznes holatini bildirmaydi.

Agar birinchi qiymatni:

```go
StatusCompleted Status = iota
```

deb qo'ysak, yangi e'lon qilingan:

```go
var status Status
```

tasodifan `Completed` holatini bildirgan bo'lardi.

Ko'p tizimlarda bu xavfli.

Shuning uchun:

```text
0 = Unknown
```

yoki:

```text
0 = Unspecified
```

kabi holat ajratish yaxshi amaliyot hisoblanadi.

## `iota` qanday ishlaydi?

`iota` — faqat `const` deklaratsiyasi ichida ishlatiladigan maxsus identifikator.

U har bir yangi `const` guruhida:

```text
0
```

dan boshlanadi.

Masalan:

```go
const (
    A = iota
    B
    C
)
```

qiymatlar:

```text
A = 0
B = 1
C = 2
```

bo'ladi.

Lekin `iota`ni faqat to'g'ridan-to'g'ri son sifatida ishlatish shart emas.

U formula ichida ham ishlatilishi mumkin.

Masalan:

```go
const (
    A = iota + 1
    B
    C
)
```

Natija:

```text
A = 1
B = 2
C = 3
```

bo'ladi.

Birinchi qatorda:

```go
A = iota + 1
```

`iota`:

```text
0
```

bo'ladi.

Demak:

```text
0 + 1 = 1
```

Keyingi qatorda:

```go
B
```

uchun alohida ifoda yozilmagan.

Go oldingi:

```go
iota + 1
```

ifodasini takrorlaydi.

Bu qatorda `iota`:

```text
1
```

bo'lgani uchun:

```text
1 + 1 = 2
```

hosil bo'ladi.

`C` qatorida esa:

```text
iota = 2
```

Natija:

```text
2 + 1 = 3
```

### Ifoda yozilmagan qator nima qiladi?

Masalan:

```go
const (
    A = iota + 1
    B
    C
)
```

aslida quyidagiga yaqin:

```go
const (
    A = iota + 1
    B = iota + 1
    C = iota + 1
)
```

Lekin har bir qatorga kelganda `iota` qiymati bittaga oshib boradi.

Shuning uchun bir xil formulani qayta-qayta yozish shart emas.

Bu `iota`ning asosiy qulayliklaridan biri.

## `iota` har bir `ConstSpec` qatorida oshadi

Muhim qoida:

`iota` har bir konstanta nomida emas, har bir `ConstSpec` qatorida bittaga oshadi.

Masalan:

```go
const (
    A, B = iota, iota
    C, D = iota, iota
)
```

Birinchi qator davomida ikkala `iota` ham:

```text
0
```

bo'ladi.

Shuning uchun:

```text
A = 0
B = 0
```

Ikkinchi qatorda esa:

```text
iota = 1
```

Shuning uchun:

```text
C = 1
D = 1
```

bo'ladi.

Demak, bitta qatorda nechta `iota` yozilishidan qat'i nazar, ular o'sha qator uchun bir xil qiymatga ega.

Bu keyingi misollarda diapazonlar yaratishda foydali bo'ladi.

## `_` yordamida `iota` qiymatini tashlab ketish

Ba'zan `iota`ning birinchi qiymati kerak bo'lmasligi mumkin.

Masalan, darajalarni:

```text
1
2
3
```

dan boshlamoqchimiz.

Buning bir usuli:

```go
const (
    PriorityLow Priority = iota + 1
    PriorityMedium
    PriorityHigh
)
```

Boshqa usuli esa `_` orqali birinchi qiymatni tashlab ketish:

```go
const (
    _ Priority = iota
    PriorityLow
    PriorityMedium
    PriorityHigh
)
```

Birinchi qatorda:

```text
iota = 0
```

Lekin qiymat:

```go
_
```

ga berilgan.

`_` — blank identifier.

Bu qiymatdan keyinchalik foydalanib bo'lmaydi.

Keyingi qatorda:

```text
iota = 1
```

bo'ladi.

Shuning uchun:

```text
PriorityLow    = 1
PriorityMedium = 2
PriorityHigh   = 3
```

hosil bo'ladi.

## `iota` yordamida o'lcham qiymatlari

`iota` formula bilan ishlashi sabab faqat oddiy:

```text
0, 1, 2, 3
```

ketma-ketligini yaratish uchun emas.

Masalan, fayl o'lchamlarini yaratish mumkin:

```go
type Size uint64

const (
    _ Size = 1 << (10 * iota)
    KB
    MB
    GB
)
```

Bu kod birinchi qarashda murakkab ko'rinishi mumkin.

Bosqichma-bosqich ko'ramiz.

Birinchi qator:

```go
_ Size = 1 << (10 * iota)
```

Bu qatorda:

```text
iota = 0
```

Demak:

```text
1 << (10 * 0)
```

ya'ni:

```text
1 << 0
```

natija:

```text
1
```

Lekin bu qiymat `_`ga berilgan va ishlatilmaydi.

Keyingi qatorda:

```go
KB
```

oldingi ifoda takrorlanadi.

Bu safar:

```text
iota = 1
```

Demak:

```text
1 << (10 * 1)
```

ya'ni:

```text
1 << 10
```

Bu:

```text
1024
```

ga teng.

Shuning uchun:

```text
KB = 1024
```

Keyingi qatorda:

```text
iota = 2
```

Demak:

```text
MB = 1 << 20
```

Natija:

```text
1048576
```

Keyingi qiymat:

```text
GB = 1 << 30
```

Natija:

```text
1073741824
```

Demak:

```text
KB = 1024
MB = 1048576
GB = 1073741824
```

Bu yerda `iota` formula ichidagi o'zgaruvchi kabi ishlatildi.

## Har bir `const` guruhida `iota` qaytadan boshlanadi

`iota` butun dastur bo'yicha bittadan oshib yurmaydi.

Har safar yangi:

```go
const (
    ...
)
```

guruhi ochilganda `iota` yana:

```text
0
```

dan boshlanadi.

Masalan:

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

Natija:

```text
A = 0
B = 1

C = 0
D = 1
```

Ikkinchi `const` guruhi birinchisini davom ettirmaydi.

Bu juda muhim.

Chunki loyihada bir nechta alohida enumga o'xshash turlar bo'lishi mumkin va ularning `iota` qiymatlari bir-biriga ta'sir qilmaydi.

## Matn ko'rinishini berish

Enumga o'xshash qiymatlarning yana bir muammosi bor.

Masalan:

```go
fmt.Println(StatusProcessing)
```

agar hech qanday qo'shimcha metod yozilmagan bo'lsa:

```text
2
```

chiqaradi.

Dastur ichida bu son yetarli bo'lishi mumkin.

Lekin:

* loglarda;
* debugging vaqtida;
* CLI dasturda;
* foydalanuvchiga ko'rsatiladigan natijada;

`2` nimani anglatishini tushunish qiyin.

Shuning uchun nomlangan turga `String()` metodini qo'shish mumkin.

Masalan:

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

Natija:

```text
processing
Status(99)
```

Bu qanday ishlaydi?

`Status` turida:

```go
String() string
```

metodi mavjud:

```go
func (s Status) String() string
```

Bu `fmt.Stringer` interface'iga mos keladi:

```go
type Stringer interface {
    String() string
}
```

Shuning uchun `fmt` paketidagi funksiyalar `Status` qiymatini chiqarayotganda uning `String()` metodidan foydalanishi mumkin.

Masalan:

```go
fmt.Println(StatusProcessing)
```

oddiy:

```text
2
```

o'rniga:

```text
processing
```

chiqaradi.

### `switch` yordamida nomni tanlash

Metod ichida:

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

orqali har bir sonli qiymatga matn berilgan.

Masalan:

```go
StatusProcessing
```

qiymati:

```text
2
```

bo'lsa ham, `String()`:

```text
processing
```

qaytaradi.

### `default` nima uchun kerak?

Metod oxirida:

```go
default:
    return fmt.Sprintf("Status(%d)", s)
```

bor.

Buni yozish muhim.

Chunki Go'dagi enumga o'xshash tur faqat e'lon qilingan konstantalar bilan cheklanmagan.

Masalan:

```go
Status(99)
```

yozish mumkin.

Shuning uchun `String()` faqat:

```go
return "unknown"
```

qilib yuborsa, haqiqiy noma'lum qiymatni yashirib qo'yishi mumkin.

Buning o'rniga:

```text
Status(99)
```

chiqishi debugging va loglarda ancha foydali.

Biz darhol:

> Tizimga kutilmagan 99 qiymati kelibdi

deb ko'ra olamiz.

Katta enumlarda o'nlab yoki yuzlab `case` yozish noqulay bo'lishi mumkin.

Bunday holatlarda `String()` metodini avtomatik generatsiya qiluvchi vositalardan foydalanish mumkin.

Lekin generatsiya qilingan fayllarni loyiha va repozitoriy qoidalariga mos boshqarish kerak.

## Enum yopiq to'plam emas

Go'dagi enumga o'xshash yondashuvning juda muhim farqi bor.

Quyidagicha tur yaratdik:

```go
type Status int
```

va faqat to'rtta konstanta e'lon qildik:

```go
const (
    StatusUnknown Status = iota
    StatusPending
    StatusProcessing
    StatusCompleted
)
```

Bu qiymatlar:

```text
0
1
2
3
```

bo'ladi.

Lekin bu:

> `Status` faqat 0, 1, 2 yoki 3 bo'lishi mumkin

degani emas.

Quyidagi kod ham kompilyatsiyadan o'tadi:

```go
status := Status(99)
```

Bu mutlaqo haqiqiy `Status` qiymati hisoblanadi.

Shuning uchun Go'dagi bu yondashuv boshqa ayrim tillardagi qat'iy enum kabi yopiq to'plam yaratmaydi.

### Nega bu muhim?

Agar qiymatlar faqat o'z kodimiz ichida ishlatilsa, odatda konstantalardan foydalanamiz:

```go
StatusPending
StatusCompleted
```

Lekin tashqi manbadan ma'lumot kelganda vaziyat boshqacha.

Masalan:

* HTTP request;
* JSON;
* database;
* message broker;
* fayl;
* boshqa servis;

orqali:

```text
99
```

kelishi mumkin.

Uni:

```go
Status(99)
```

ga aylantirish texnik jihatdan mumkin.

Lekin u biznes qoidalariga mos kelmasligi mumkin.

Shuning uchun tashqi qiymatlarni validatsiya qilish kerak.

Masalan:

```go
func (s Status) Valid() bool {
    return s >= StatusUnknown && s <= StatusCompleted
}
```

Endi:

```go
status := Status(2)

if !status.Valid() {
    // noto'g'ri status
}
```

deb tekshirish mumkin.

`Status(99)` uchun:

```go
Status(99).Valid()
```

natijasi:

```text
false
```

bo'ladi.

### Har doim diapazon tekshiruvi yetarlimi?

Quyidagi:

```go
return s >= StatusUnknown && s <= StatusCompleted
```

usuli konstantalar ketma-ket bo'lganda yaxshi ishlaydi.

Masalan:

```text
0
1
2
3
```

Lekin qiymatlar:

```text
1
5
10
20
```

kabi bo'lsa, diapazon tekshiruvi noto'g'ri bo'lishi mumkin.

Bunday holatda `switch` ishlatish yaxshiroq:

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

Bu usul faqat haqiqatan e'lon qilingan qiymatlarni qabul qiladi.

## `iota` va tashqi formatlar

`iota` ishlatishda yana bir muhim xavf bor.

Faraz qilamiz:

```go
const (
    StatusUnknown Status = iota
    StatusPending
    StatusProcessing
    StatusCompleted
)
```

qiymatlar:

```text
0
1
2
3
```

bo'ladi.

Endi bu sonlarni database'ga yozdik deb tasavvur qilamiz.

Masalan:

```text
2 = processing
3 = completed
```

Keyinchalik kodga yangi holat qo'shdik:

```go
const (
    StatusUnknown Status = iota
    StatusPending
    StatusWaiting
    StatusProcessing
    StatusCompleted
)
```

Endi qiymatlar:

```text
StatusUnknown    = 0
StatusPending    = 1
StatusWaiting    = 2
StatusProcessing = 3
StatusCompleted  = 4
```

bo'lib qoldi.

Oldingi database'dagi:

```text
2
```

qiymati avval:

```text
processing
```

edi.

Yangi kodda esa:

```text
waiting
```

bo'lib qoldi.

Bu juda jiddiy xatoga olib kelishi mumkin.

Shuning uchun `iota` qiymatlari tashqi tizim bilan bog'langan bo'lsa, ehtiyot bo'lish kerak.

Bunga quyidagilar kiradi:

* database;
* public API;
* protobufga o'xshash protokol;
* fayl formati;
* message broker;
* boshqa servis bilan kelishilgan kodlar.

Bunday holatda ikki xil xavfsizroq yondashuv bor.

### Faqat oxiriga yangi qiymat qo'shish

Masalan:

```go
const (
    StatusUnknown Status = iota
    StatusPending
    StatusProcessing
    StatusCompleted

    StatusCanceled
)
```

Bunda eski qiymatlar o'zgarmaydi.

### Aniq sonlarni yozish

Agar kodlar tashqi shartnoma bo'lsa, yanada aniqroq usul:

```go
const (
    StatusUnknown    Status = 0
    StatusPending    Status = 10
    StatusProcessing Status = 20
    StatusCompleted  Status = 30
)
```

Endi yangi qiymat qo'shish eski qiymatlarni avtomatik siljitmaydi.

## Chuqurlashtirish: bit bayroqlar

Bit bayroqlar bir qiymatda bir nechta mustaqil holatni saqlash kerak bo‘lganda ishlatiladi. Boshlang‘ich bosqichda oddiy `iota` ketma-ketligini tushunish yetarli; ushbu bo‘limga keyinroq qaytishingiz mumkin.

`iota` faqat oddiy enumga o'xshash ketma-ketlik yaratish uchun emas.

U **bit flag**, ya'ni bit bayroqlar yaratishda ham juda qulay.

Masalan, foydalanuvchida quyidagi ruxsatlar bo'lsin:

* o'qish;
* yozish;
* o'chirish.

Oddiy enumda:

```text
Read   = 0
Write  = 1
Delete = 2
```

qilish mumkin.

Lekin bitta foydalanuvchida bir vaqtning o'zida bir nechta ruxsat bo'lishi kerak.

Masalan:

```text
Read + Write
```

Bunday holatda bitmask ishlatish mumkin.

```go
type Permission uint8

const (
    PermissionRead Permission = 1 << iota
    PermissionWrite
    PermissionDelete
)
```

Bu yerda qiymatlar:

```text
PermissionRead   = 1
PermissionWrite  = 2
PermissionDelete = 4
```

bo'ladi.

Nega?

Birinchi qator:

```go
1 << iota
```

uchun:

```text
iota = 0
```

Demak:

```text
1 << 0 = 1
```

Binary ko'rinishda:

```text
00000001
```

Keyingi qator:

```text
iota = 1
```

Demak:

```text
1 << 1 = 2
```

Binary:

```text
00000010
```

Keyingi:

```text
1 << 2 = 4
```

Binary:

```text
00000100
```

Muhim tomoni — har bir qiymatda alohida bit yoqilgan.

## Bit bayroqlarni birlashtirish

Bit flaglarni:

```go
|
```

bitwise OR operatori yordamida birlashtirish mumkin.

Masalan:

```go
permissions := PermissionRead | PermissionWrite
```

Binary ko'rinishda:

```text
PermissionRead  = 00000001
PermissionWrite = 00000010
```

`|` ishlatilganda:

```text
00000001
00000010
--------
00000011
```

hosil bo'ladi.

Bu decimal ko'rinishda:

```text
3
```

Demak:

```go
permissions == 3
```

Lekin bu `3` oddiy ma'noda uchinchi enum qiymati emas.

Uning ichida ikkita bayroq mavjud:

```text
Read
Write
```

## Bayroq mavjudligini tekshirish

Masalan, qiymatda `PermissionRead` mavjudligini tekshirmoqchimiz.

Buning uchun:

```go
value & permission
```

ishlatiladi.

Masalan:

```go
func has(value, permission Permission) bool {
    return value&permission != 0
}
```

Agar:

```go
permissions := PermissionRead | PermissionWrite
```

bo'lsa:

```go
has(permissions, PermissionRead)
```

natija:

```text
true
```

bo'ladi.

Lekin:

```go
has(permissions, PermissionDelete)
```

natija:

```text
false
```

bo'ladi.

Bit flaglar quyidagi holatlarda qulay:

* permissionlar;
* feature flaglar;
* notification sozlamalari;
* fayl rejimlari;
* protokol flaglari;
* bir nechta mustaqil `true/false` holatni bitta son ichida saqlash.

## Misollar

### 1. Hafta kunlarini birdan boshlash

Bu misolda `iota + 1` yordamida hafta kunlariga `1` dan boshlab qiymat beriladi.

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

Birinchi qatorda:

```go
Monday Weekday = iota + 1
```

yozilgan.

Bu qatorda:

```text
iota = 0
```

Demak:

```text
Monday = 0 + 1 = 1
```

Keyingi qatorda alohida ifoda yozilmagan:

```go
Tuesday
```

Go oldingi:

```go
iota + 1
```

ifodasini takrorlaydi.

Bu qatorda:

```text
iota = 1
```

Shuning uchun:

```text
Tuesday = 2
```

Shu tartibda:

```text
Monday    = 1
Tuesday   = 2
Wednesday = 3
Thursday  = 4
Friday    = 5
Saturday  = 6
Sunday    = 7
```

bo'ladi.

Shuning uchun:

```go
fmt.Println(Monday, Wednesday, Sunday)
```

natijasi:

```text
1 3 7
```

bo'ladi.

Bu usul `0` qiymatini hafta kuni sifatida ishlatmaslik kerak bo'lgan vaziyatlarda qulay.

Shuningdek, foydalanuvchi ko'radigan yoki boshqa tizimdagi:

```text
1 = Monday
...
7 = Sunday
```

formatga moslashishni osonlashtirishi mumkin.

### 2. Nol qiymatni noma'lum holat uchun saqlash

Bu misolda turning zero value qiymati alohida `Unknown` holatini bildiradi.

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

Dastlab:

```go
var status DeliveryStatus
```

deb o'zgaruvchi yaratildi.

Unga qiymat berilmagan.

`DeliveryStatus` `int` asosidagi tur bo'lgani uchun uning zero value qiymati:

```text
0
```

bo'ladi.

Bizning konstantalarimizda:

```go
DeliveryUnknown DeliveryStatus = iota
```

ham:

```text
0
```

ga teng.

Shuning uchun:

```go
status == DeliveryUnknown
```

natijasi:

```text
true
```

bo'ladi.

Bu yaxshi dizayn.

Chunki hali delivery holati aniq belgilanmagan bo'lsa:

```text
0 = Unknown
```

deb tushunish mumkin.

Keyin:

```go
status = DeliveryOnTheWay
```

deb haqiqiy holat berildi.

Qiymatlar:

```text
DeliveryUnknown  = 0
DeliveryAccepted = 1
DeliveryOnTheWay = 2
DeliveryArrived  = 3
```

bo'ladi.

Shuning uchun:

```go
fmt.Println(status)
```

natijasi:

```text
2
```

bo'ladi.

Bu yondashuvda haqiqiy biznes holatlari `1` dan boshlanadi, `0` esa "hali noma'lum" degan ma'noda ishlatiladi.

### 3. Keraksiz birinchi qiymatni tashlab ketish

Bu misolda `_` yordamida birinchi `iota` qiymati ishlatilmaydi.

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

Birinchi qatorda:

```go
_ Priority = iota
```

`iota`:

```text
0
```

ga teng.

Lekin qiymat:

```go
_
```

blank identifieriga berilgan.

Shuning uchun bu qiymat uchun alohida konstanta nomi mavjud emas.

Keyingi qatorda:

```text
iota = 1
```

Demak:

```text
PriorityLow = 1
```

Keyingi:

```text
PriorityMedium = 2
```

va:

```text
PriorityHigh = 3
```

bo'ladi.

Natija:

```text
1 2 3
```

Bu usul `0` haqiqiy qiymat bo'lmasligi kerak bo'lgan holatlarda qulay.

Masalan, `0`:

```text
hali priority belgilanmagan
```

degan yashirin holat sifatida qolishi mumkin.

### 4. Qiymatlarni o'n qadam bilan oshirish

`iota` formula ichida ishlatilishi mumkinligini ko'rgan edik.

Quyidagi misolda kodlar:

```text
10
20
30
```

ko'rinishida yaratiladi.

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

Birinchi qatorda:

```go
(iota + 1) * 10
```

formula ishlatilgan.

Bu qatorda:

```text
iota = 0
```

Demak:

```text
(0 + 1) * 10 = 10
```

Shuning uchun:

```text
DepartmentSales = 10
```

Keyingi qator uchun:

```text
iota = 1
```

Demak:

```text
(1 + 1) * 10 = 20
```

Shuning uchun:

```text
DepartmentSupport = 20
```

Keyingi:

```text
(2 + 1) * 10 = 30
```

Demak:

```text
DepartmentWarehouse = 30
```

Natija:

```text
10 20 30
```

Bu usul kodlar orasida joy qoldirish kerak bo'lganda ishlatilishi mumkin.

Lekin agar bu qiymatlar database yoki tashqi API bilan doimiy shartnoma bo'lsa, `iota` o'rniga aniq son yozish ko'pincha xavfsizroq.

### 5. Bir satrda bog'liq qiymatlar yaratish

Bitta `ConstSpec` satrida bir nechta konstanta e'lon qilish mumkin.

Bu qatordagi barcha `iota`lar bir xil qiymatga ega bo'ladi.

Masalan:

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

Birinchi qatorda:

```go
SmallMin, SmallMax = iota * 10, iota*10 + 9
```

`iota`:

```text
0
```

ga teng.

Ikkala ifodadagi `iota` ham bir xil:

```text
0
```

Shuning uchun:

```text
SmallMin = 0 * 10     = 0
SmallMax = 0 * 10 + 9 = 9
```

Natija:

```text
0–9
```

Keyingi qatorda ifoda yozilmagan:

```go
MediumMin, MediumMax
```

Go oldingi ikkita ifodani takrorlaydi.

Bu qatorda:

```text
iota = 1
```

Shuning uchun:

```text
MediumMin = 10
MediumMax = 19
```

Keyingi qatorda:

```text
iota = 2
```

Natija:

```text
LargeMin = 20
LargeMax = 29
```

Demak, uchta diapazon hosil bo'ladi:

```text
Small  = 0–9
Medium = 10–19
Large  = 20–29
```

Bu misol bitta qatorda bir nechta `iota` ishlatilganda ular o'sha qator uchun bir xil qiymat olishini ko'rsatadi.

### 6. Har bir `const` guruhida qayta boshlash

Quyidagi misol `iota` yangi `const` blokida qaytadan `0` bo'lishini ko'rsatadi.

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

Birinchi `const` guruhida:

```go
const (
    North = iota
    East
)
```

qiymatlar:

```text
North = 0
East  = 1
```

bo'ladi.

Keyin yangi:

```go
const (
    Draft = iota
    Published
)
```

guruhi ochildi.

Bu yerda `iota`:

```text
2
```

dan davom etmaydi.

U yana:

```text
0
```

dan boshlanadi.

Shuning uchun:

```text
Draft     = 0
Published = 1
```

bo'ladi.

Natija:

```text
0 1
0 1
```

Har bir alohida `const` guruhi o'z `iota` hisobiga ega.

Bu turli enumga o'xshash guruhlarning bir-biriga ta'sir qilmasligini ta'minlaydi.

### 7. Fayl ruxsatlarini birlashtirish

Bu misolda `iota` bit flag yaratish uchun ishlatiladi.

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

Avval qiymatlarni hisoblaymiz.

Birinchi:

```go
CanRead FilePermission = 1 << iota
```

Bu yerda:

```text
iota = 0
```

Demak:

```text
1 << 0 = 1
```

Shuning uchun:

```text
CanRead = 1
```

Binary:

```text
00000001
```

Keyingi:

```text
CanWrite = 1 << 1 = 2
```

Binary:

```text
00000010
```

Keyingi:

```text
CanExecute = 1 << 2 = 4
```

Binary:

```text
00000100
```

Endi:

```go
permissions := CanRead | CanWrite
```

deyapmiz.

Binary:

```text
00000001  CanRead
00000010  CanWrite
--------
00000011
```

Natijada:

```text
permissions = 3
```

Lekin bu `3` ichida ikkita mustaqil flag mavjud.

Keyin:

```go
permissions&CanRead != 0
```

tekshirilmoqda.

`CanRead` biti yoqilganligi sabab natija:

```text
true
```

bo'ladi.

Keyin:

```go
permissions&CanExecute != 0
```

tekshiriladi.

`CanExecute` biti yoqilmagan.

Shuning uchun natija:

```text
false
```

bo'ladi.

Bu yondashuv bitta qiymatda bir nechta mustaqil ruxsatni saqlash imkonini beradi.

### 8. Bayroqni qiymatdan olib tashlash

Bit flagni faqat qo'shish emas, o'chirish ham mumkin.

Buning uchun Go'da:

```go
&^
```

operatori mavjud.

U **bit clear**, ya'ni ma'lum bitlarni tozalash uchun ishlatiladi.

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

Avval qiymatlar:

```text
NotifyEmail = 1
NotifySMS   = 2
NotifyPush  = 4
```

bo'ladi.

Binary:

```text
NotifyEmail = 001
NotifySMS   = 010
NotifyPush  = 100
```

Keyin:

```go
settings := NotifyEmail | NotifySMS | NotifyPush
```

uchala flag ham birlashtiriladi:

```text
001
010
100
---
111
```

Demak, boshida uchala notification turi yoqilgan.

Keyin:

```go
settings &^= NotifySMS
```

deb yozilgan.

Bu:

> `NotifySMS`ga tegishli bitni tozalab tashla

degan ma'noni anglatadi.

Natijada:

```text
111
```

dan:

```text
101
```

qoladi.

Demak:

```text
Email = yoqilgan
SMS   = o'chirilgan
Push  = yoqilgan
```

Shuning uchun:

```go
settings&NotifyEmail != 0
```

natija:

```text
true
```

```go
settings&NotifySMS != 0
```

natija:

```text
false
```

va:

```go
settings&NotifyPush != 0
```

natija:

```text
true
```

bo'ladi.

Natijalar:

```text
true
false
true
```

### 9. Enum qiymatlarini matnga aylantirish

Son ko'rinishidagi status foydalanuvchiga yoki logga chiqarilganda tushunarsiz bo'lishi mumkin.

Shuning uchun unga matn qaytaradigan metod yozish mumkin.

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
		return "yangi"

	case OrderPaid:
		return "to'langan"

	case OrderSent:
		return "yuborilgan"

	default:
		return "noma'lum"
	}
}

func main() {
	fmt.Println(OrderPaid.Label())
	fmt.Println(OrderStatus(20).Label())
}
```

Qiymatlar:

```text
OrderNew  = 0
OrderPaid = 1
OrderSent = 2
```

bo'ladi.

Keyin:

```go
OrderPaid.Label()
```

chaqirilmoqda.

Metod:

```go
case OrderPaid:
    return "to'langan"
```

qatoriga tushadi.

Natija:

```text
to'langan
```

bo'ladi.

Keyingi:

```go
OrderStatus(20).Label()
```

juda muhim misol.

`20` e'lon qilingan konstantalar ichida yo'q.

Lekin Go:

```go
OrderStatus(20)
```

konvertatsiyasiga ruxsat beradi.

Shuning uchun `switch` ichidagi hech bir asosiy `case` mos kelmaydi va:

```go
default:
    return "noma'lum"
```

ishlaydi.

Natija:

```text
noma'lum
```

bo'ladi.

Bu yana bir bor Go'dagi enumga o'xshash tur yopiq qiymatlar to'plami emasligini ko'rsatadi.

`Label()` metodini ko'proq foydalanuvchi interfeysi uchun ishlatish mumkin.

Agar log va debugging uchun noma'lum sonning o'zini ham ko'rish kerak bo'lsa:

```go
return fmt.Sprintf("noma'lum(%d)", s)
```

kabi yozish foydaliroq bo'lishi mumkin.

### 10. Tashqi format uchun aniq kodlarni saqlash

Har doim `iota` ishlatish shart emas.

Ayniqsa konstantalarning sonli qiymati tashqi tizim bilan kelishilgan bo'lsa, aniq sonlarni yozish xavfsizroq.

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

Bu yerda:

```go
PaymentCreated = 100
```

```go
PaymentApproved = 200
```

va:

```go
PaymentRejected = 400
```

qiymatlari qo'lda aniq belgilangan.

Masalan, bu qiymatlar boshqa API bilan kelishilgan deb tasavvur qilamiz:

```text
100 = payment created
200 = payment approved
400 = payment rejected
```

Bunday vaziyatda:

```go
iota
```

ishlatish xavfliroq bo'lishi mumkin.

Chunki yangi konstanta o'rtaga qo'shilsa, undan keyingi `iota` qiymatlari siljishi mumkin.

Aniq sonlar bilan:

```go
const (
    PaymentCreated  PaymentCode = 100
    PaymentApproved PaymentCode = 200
    PaymentRejected PaymentCode = 400
)
```

yozilganda esa konstantalarni qayta tartiblash yoki orasiga yangi qiymat qo'shish mavjud kodlarni avtomatik o'zgartirmaydi.

Masalan:

```go
const (
    PaymentCreated  PaymentCode = 100
    PaymentPending  PaymentCode = 150
    PaymentApproved PaymentCode = 200
    PaymentRejected PaymentCode = 400
)
```

deb yangi holat qo'shsak ham:

```text
PaymentCreated  = 100
PaymentApproved = 200
PaymentRejected = 400
```

o'zgarishsiz qoladi.

Bu ayniqsa:

* public API;
* database;
* boshqa servis bilan integratsiya;
* message broker;
* fayl formati;
* uzoq vaqt saqlanadigan ma'lumot;

uchun muhim.

Shuning uchun `iota`ni shunchaki kodni qisqartirish uchun ishlatishdan oldin sonlarning o'zi tashqi ma'no kasb etadimi yoki yo'qmi, shuni hisobga olish kerak.
