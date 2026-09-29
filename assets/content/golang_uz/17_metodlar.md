# Goda metodlar

**Metod** — ma'lum bir turga bog'langan funksiya.

Oddiy funksiya alohida ishlaydi. Metod esa ma'lum bir qiymat yoki tur ustida amal bajaradi.

Masalan, bizda `Rectangle` turi bo'lsa, uning yuzasini hisoblash uchun `Area()` metodini yozishimiz mumkin:

```go
rectangle.Area()
```

Bu yerda `Area()` aynan `Rectangle` turiga tegishli metod hisoblanadi.

Metodning oddiy funksiyadan asosiy farqi — funksiya nomidan oldin **qabul qiluvchi (receiver)** yoziladi.

Masalan:

```go
func (r Rectangle) Area() float64 {
    return r.Width * r.Height
}
```

Bu yerda:

* `Area` — metod nomi;
* `Rectangle` — metod bog'langan tur;
* `r` — receiver, ya'ni metod ishlayotgan qiymat.

Receiver yordamida metod qaysi turga tegishli ekanini bilamiz.

## Value receiver

Avval oddiy misolni ko'ramiz:

```go
package main

import "fmt"

type Rectangle struct {
	Width  float64
	Height float64
}

func (r Rectangle) Area() float64 {
	return r.Width * r.Height
}

func main() {
	rectangle := Rectangle{Width: 5, Height: 3}
	fmt.Println("Yuza:", rectangle.Area())
}
```

Natija:

```text
Yuza: 15
```

Bu kodda:

```go
func (r Rectangle) Area() float64
```

qismidagi:

```go
(r Rectangle)
```

receiver hisoblanadi.

Bu metod `Rectangle` turiga tegishli ekanini bildiradi.

Shuning uchun metodni quyidagicha chaqira olamiz:

```go
rectangle.Area()
```

Bu yerda `rectangle` qiymati metod ichidagi `r` receiveriga uzatiladi.

Lekin muhim jihat bor: `Rectangle` pointer emas.

```go
(r Rectangle)
```

Bu **value receiver** deyiladi.

Value receiver ishlatilganda metod receiver qiymatining nusxasi bilan ishlaydi.

Masalan:

```go
func (r Rectangle) Area() float64 {
    return r.Width * r.Height
}
```

`Area()` faqat `Width` va `Height` qiymatlarini o'qiyapti. U `Rectangle` ichidagi ma'lumotlarni o'zgartirmayapti.

Shuning uchun bu yerda value receiver ishlatish qulay.

Odatda value receiver quyidagi holatlarda mos keladi:

* metod qiymatni faqat o'qisa;
* qiymatni o'zgartirish kerak bo'lmasa;
* tur kichik bo'lsa;
* turni nusxalash katta xarajat talab qilmasa.

Metodni istalgan turga biriktirib bo'lmaydi.

Go'da metod faqat **shu paketning o'zida e'lon qilingan nomlangan turga** biriktirilishi mumkin.

Masalan, boshqa paketda joylashgan:

```go
time.Time
```

turiga o'z paketimizdan turib yangi metod qo'sha olmaymiz.

Ya'ni bunday qilish mumkin emas:

```go
func (t time.Time) MyMethod() {
}
```

Sababi `time.Time` turi bizning paketimizda e'lon qilinmagan.

## Oddiy turga metod qo'shish

Metod faqat `struct` uchun yozilmaydi.

O'z paketimizda e'lon qilingan boshqa nomlangan turlarga ham metod biriktirish mumkin.

Masalan:

```go
package main

import "fmt"

type Celsius float64

func (c Celsius) Fahrenheit() float64 {
	return float64(c)*9/5 + 32
}

func main() {
	temperature := Celsius(25)
	fmt.Println(temperature.Fahrenheit())
}
```

Natija:

```text
77
```

Bu yerda:

```go
type Celsius float64
```

orqali yangi `Celsius` turi yaratildi.

Uning asosida `float64` yotadi, lekin `Celsius` Go uchun alohida nomlangan tur hisoblanadi.

Shuning uchun unga metod qo'shish mumkin:

```go
func (c Celsius) Fahrenheit() float64 {
    return float64(c)*9/5 + 32
}
```

Endi `Celsius` qiymatida:

```go
temperature.Fahrenheit()
```

deb metod chaqira olamiz.

Bu juda qulay.

Masalan, oddiy:

```go
float64
```

qiymati faqat son ekanini bildiradi.

Lekin:

```go
Celsius
```

deb alohida tur yaratish orqali bu qiymat **harorat** ekanini ham ifodaladik.

Bundan tashqari, unga harorat bilan bog'liq metodlarni ham qo'shishimiz mumkin.

Lekin quyidagi yozuv bilan adashtirmaslik kerak:

```go
type Celsius = float64
```

Bu yangi tur yaratmaydi.

Bu faqat `float64` uchun boshqa nom, ya'ni **alias** yaratadi.

Shuning uchun aliasga alohida metod biriktirib bo'lmaydi.

Farq:

```go
type Celsius float64
```

yangi tur yaratadi.

```go
type Celsius = float64
```

esa faqat `float64` uchun boshqa nom yaratadi.

## Pointer receiver

Ba'zi metodlar qiymatni faqat o'qimaydi. Ular asl qiymatni o'zgartirishi kerak bo'ladi.

Bunday holatda **pointer receiver** ishlatiladi.

Masalan:

```go
package main

import "fmt"

type Account struct {
	Balance int64
}

func (a *Account) Deposit(amount int64) error {
	if a == nil {
		return fmt.Errorf("account nil")
	}

	if amount <= 0 {
		return fmt.Errorf("amount musbat bo'lishi kerak")
	}

	a.Balance += amount
	return nil
}

func main() {
	account := Account{Balance: 100_000}

	if err := account.Deposit(25_000); err != nil {
		fmt.Println("Xato:", err)
		return
	}

	fmt.Println(account.Balance)
}
```

Natija:

```text
125000
```

Bu yerda metod receiveriga e'tibor bering:

```go
func (a *Account) Deposit(amount int64) error
```

Receiver:

```go
(a *Account)
```

ko'rinishida yozilgan.

`*Account` bu `Account` qiymatiga pointer degani.

Demak, `Deposit()` metodiga `Account` qiymatining nusxasi emas, uning manzili bilan bog'liq pointer beriladi.

Shuning uchun metod asl `Account` qiymatini o'zgartira oladi:

```go
a.Balance += amount
```

Dastlab balans:

```text
100000
```

edi.

Metod chaqirildi:

```go
account.Deposit(25_000)
```

Natijada asl `account` ichidagi balans o'zgardi:

```text
125000
```

Agar bu metod value receiver bilan yozilganida:

```go
func (a Account) Deposit(amount int64)
```

`a` faqat `account`ning nusxasi bo'lar edi.

Metod ichidagi o'zgarish asl `account` qiymatiga ta'sir qilmas edi.

Pointer receiverda yana bir qulaylik bor.

Biz:

```go
a.Balance
```

deb yozdik.

Aslida `a` pointer:

```go
*Account
```

turida.

Nazariy jihatdan maydonga quyidagicha murojaat qilish mumkin:

```go
(*a).Balance
```

Lekin Go buni avtomatik bajaradi.

Shuning uchun:

```go
a.Balance
```

deb yozishning o'zi yetarli.

Go pointer orqali struct maydoniga murojaat qilayotganimizni tushunadi.

Yana bir qiziq joy:

```go
account.Deposit(25_000)
```

Bu yerda `account` pointer emas.

U oddiy:

```go
Account
```

qiymati.

Lekin metod:

```go
*Account
```

receiver talab qilyapti.

Go ko'p holatda buni ham avtomatik hal qiladi.

Agar qiymatning manzilini olish mumkin bo'lsa:

```go
account.Deposit(25_000)
```

chaqiruvi amalda quyidagiga moslashtiriladi:

```go
(&account).Deposit(25_000)
```

Shuning uchun har safar qo'lda `&account` yozish shart emas.

### `nil` pointer receiver

Pointer receiverning yana bir xususiyati bor: receiver `nil` bo'lishi mumkin.

Masalan:

```go
var account *Account
```

Bu yerda `account`:

```go
nil
```

qiymatga ega.

Shunga qaramasdan pointer receiverli metodni chaqirish texnik jihatdan mumkin:

```go
account.Deposit(1000)
```

Shuning uchun metod ichida kerak bo'lsa `nil`ni tekshirish kerak:

```go
if a == nil {
    return fmt.Errorf("account nil")
}
```

Yuqoridagi `Deposit()` metodida aynan shunday qilingan.

Agar receiver `nil` bo'lsa, metod struct maydonlariga murojaat qilmaydi va xato qaytaradi.

Bu dasturda `nil pointer dereference` kabi runtime xatoning oldini oladi.

## Metod orqali holatni boshqarish

Metodlarning muhim foydalaridan biri — ma'lumotni o'zgartirish qoidalarini bitta joyda saqlash.

Masalan, bank hisobini tasavvur qilamiz.

Biz balansni quyidagicha ochiq saqlashimiz mumkin:

```go
type Account struct {
    Balance int64
}
```

Bunday holatda tashqi kod istalgan qiymatni yozishi mumkin:

```go
account.Balance = -999999
```

Bu esa biznes qoidalariga mos kelmasligi mumkin.

Buning o'rniga maydonni paket tashqarisidan yopib, uni metodlar orqali boshqarish mumkin:

```go
package main

import (
	"errors"
	"fmt"
)

type Account struct {
	balance int64
}

func (a *Account) Deposit(amount int64) error {
	if amount <= 0 {
		return errors.New("summa musbat bo'lishi kerak")
	}

	a.balance += amount
	return nil
}

func (a Account) Balance() int64 {
	return a.balance
}

func main() {
	account := Account{}

	if err := account.Deposit(50_000); err != nil {
		fmt.Println("Xato:", err)
		return
	}

	fmt.Println(account.Balance())
}
```

Natija:

```text
50000
```

Bu yerda:

```go
balance int64
```

kichik harf bilan boshlangan.

Go'da kichik harf bilan boshlangan nomlar paket tashqarisiga export qilinmaydi.

Demak, boshqa paketdagi kod:

```go
account.balance
```

deb qiymatga bevosita murojaat qila olmaydi.

Balansni o'zgartirish uchun:

```go
account.Deposit(...)
```

metodidan foydalanish kerak.

Metod ichida esa tekshiruv bor:

```go
if amount <= 0 {
    return errors.New("summa musbat bo'lishi kerak")
}
```

Shuning uchun noto'g'ri qiymat kiritilishining oldini bitta joyda olish mumkin.

Balansni o'qish uchun esa:

```go
account.Balance()
```

metodi ishlatiladi.

Natijada:

* qiymatni qanday o'zgartirish kerakligi `Deposit()` ichida saqlanadi;
* qiymatni qanday olish kerakligi `Balance()` orqali belgilanadi;
* biznes qoidalarini dasturning turli joylarida takrorlash kerak bo'lmaydi.

Bu yondashuv kodni boshqarishni osonlashtiradi.

## Metodni chaqirish usullari

Metodlarni bir necha xil usulda ishlatish mumkin.

Eng oddiy usul — qiymat orqali metodni chaqirish.

Masalan:

```go
area := rectangle.Area()
```

Bu odatda eng ko'p ishlatiladigan ko'rinish.

Lekin Go metodni **funksiya qiymati** sifatida ham olish imkonini beradi.

Buning ikki muhim ko'rinishi bor:

* method value;
* method expression.

### Method value

Quyidagi misolni ko'ramiz:

```go
package main

import "fmt"

type Counter struct {
	value int
}

func (c *Counter) Add(n int) {
	c.value += n
}

func main() {
	counter := &Counter{}

	add := counter.Add

	add(3)
	add(2)

	fmt.Println(counter.value)
}
```

Natija:

```text
5
```

Oddiy holatda metodni:

```go
counter.Add(3)
```

deb chaqirishimiz mumkin.

Lekin bu misolda:

```go
add := counter.Add
```

deb metodni o'zgaruvchiga saqladik.

Bu **method value** deyiladi.

Muhim jihati shundaki, `counter` qiymati metod bilan birga saqlanadi.

Ya'ni:

```go
add
```

o'zgaruvchisi qaysi `Counter` ustida ishlashi kerakligini allaqachon biladi.

Shuning uchun:

```go
add(3)
```

deb chaqirganda `counter`ni yana argument sifatida berish shart emas.

Keyin:

```go
add(2)
```

chaqirilganda ham aynan shu `counter` o'zgartiriladi.

Natijada:

```text
5
```

hosil bo'ladi.

### Method expression

Method expression boshqacha ishlaydi.

Masalan:

```go
add := (*Counter).Add
add(counter, 5)
```

Bu yerda:

```go
(*Counter).Add
```

metodni ma'lum bir `counter` qiymatiga bog'lamaydi.

Aksincha, metod oddiy funksiyaga o'xshash ko'rinishda olinadi.

Shuning uchun receiverni o'zimiz birinchi argument sifatida beramiz:

```go
add(counter, 5)
```

Bu yerda:

```go
counter
```

receiver.

```go
5
```

esa `Add()` metodining `n` argumenti.

Method expression bir xil metodni turli qiymatlar bilan ishlatish kerak bo'lgan holatlarda foydali.

Masalan:

```go
counter1 := &Counter{}
counter2 := &Counter{}

add := (*Counter).Add

add(counter1, 5)
add(counter2, 10)
```

Bu yerda bitta `add` funksiyasi ikki xil `Counter` bilan ishlatilmoqda.

## Avtomatik manzil olish va ochish

Go metodlarni chaqirishda pointer bilan ishlashni biroz soddalashtiradi.

Masalan, quyidagi ikki chaqiruv ko'p holatda bir xil ishlaydi:

```go
account := Account{}

account.Deposit(1000)
(&account).Deposit(1000)
```

`Deposit()` pointer receiver bilan yozilgan deb tasavvur qilamiz:

```go
func (a *Account) Deposit(amount int64)
```

Birinchi chaqiruvda:

```go
account.Deposit(1000)
```

`account` oddiy `Account` qiymati.

Metod esa:

```go
*Account
```

receiver talab qiladi.

Lekin `account` o'zgaruvchisining manzilini olish mumkin.

Shuning uchun Go avtomatik ravishda:

```go
&account
```

ko'rinishiga moslashtiradi.

Natijada biz har safar:

```go
(&account).Deposit(1000)
```

deb yozishimiz shart emas.

Oddiy:

```go
account.Deposit(1000)
```

yetarli.

Buning teskarisi ham mavjud.

Faraz qilamiz, `Balance()` value receiver bilan yozilgan:

```go
func (a Account) Balance() int64 {
    return a.balance
}
```

Bizda esa pointer bor:

```go
accountPointer := &account
```

Shunga qaramay:

```go
fmt.Println(accountPointer.Balance())
```

deb chaqirish mumkin.

Go pointer ichidagi qiymatni avtomatik ochadi va metodni chaqiradi.

Bu yerda Go biz uchun kerakli `*` yoki `&` amalini avtomatik bajarib beradi.

Lekin muhim bir narsani ajratish kerak:

> Metod chaqirilayotganda Go'ning avtomatik `&` yoki `*` ishlatishi `Account` va `*Account` turlarining metodlar to'plami bir xil degani emas.

Bu farq ayniqsa interface bilan ishlaganda muhim bo'ladi.

## Receiver tanlash

Metod yozayotganda ko'p uchraydigan savollardan biri:

> Value receiver ishlatish kerakmi yoki pointer receiver?

Bunga bitta universal qoida bilan javob berib bo'lmaydi.

Lekin bir nechta amaliy qoidalar bor.

### Pointer receiver qachon ishlatiladi?

Quyidagi holatlarda pointer receiver tanlash odatda to'g'ri bo'ladi.

#### Metod qiymatni o'zgartirsa

Masalan:

```go
func (a *Account) Deposit(amount int64) {
    a.Balance += amount
}
```

Bu metod asl `Account` qiymatini o'zgartirishi kerak.

Shuning uchun pointer receiver kerak.

#### Struct katta bo'lsa

Value receiver ishlatilganda struct qiymati nusxalanadi.

Kichik structlar uchun bu odatda muammo emas.

Lekin struct juda katta bo'lsa, har bir metod chaqirig'ida uni nusxalash ortiqcha xarajat bo'lishi mumkin.

Bunday holatda pointer receiver ishlatish qulay.

#### Struct nusxalanmasligi kerak bo'lgan maydon saqlasa

Masalan:

```go
sync.Mutex
```

kabi qiymatlarni ishlatayotgan structlarni nusxalash tavsiya etilmaydi.

Shuning uchun bunday turlarda odatda pointer receiver ishlatiladi.

#### Boshqa metodlar pointer receiver ishlatsa

Bir turda juda ko'p metodlar bo'lsa, receiver tanlashda izchillik foydali.

Masalan:

```go
func (a *Account) Deposit(...)
func (a *Account) Withdraw(...)
func (a *Account) Balance(...)
```

Bir metod pointer receiver, boshqasi value receiver bo'lib ketishi ba'zan kodni tushunishni qiyinlashtiradi.

Shuning uchun bir tur uchun receiver tanlovini imkon qadar izchil qilish yaxshi amaliyot.

### Value receiver qachon ishlatiladi?

Value receiver kichik va qiymatga o'xshash turlar uchun qulay.

Masalan:

```go
type Celsius float64
```

Bu qiymat kichik va uni o'zgartirish shart emas.

Shuning uchun:

```go
func (c Celsius) Fahrenheit() float64
```

value receiver uchun yaxshi misol.

Lekin value receiver haqida bitta muhim jihat bor.

Faraz qilamiz, struct ichida:

```go
map
```

yoki:

```go
slice
```

bor.

Structning o'zi nusxalansa ham, `map` yoki slice ichidagi asosiy ma'lumot boshqa joyda saqlanishi mumkin.

Shuning uchun value receiver ishlatilgan metod ham `map` yoki slice ichidagi ma'lumotlarni o'zgartira olishi mumkin.

Masalan, faqat:

> "Metod nimanidir o'zgartirsa pointer receiver ishlataman"

degan qoida har doim yetarli emas.

Receiver tanlashda turning qanday ma'lumot saqlayotgani va uning semantikasi ham hisobga olinadi.

## Method set va interface bilan bog'lanish

Go'da har bir turda **method set**, ya'ni metodlar to'plami mavjud.

Bu ayniqsa interface bilan ishlaganda juda muhim.

Faraz qilamiz, bizda:

```go
type T struct{}
```

turi bor.

Agar metod value receiver bilan yozilsa:

```go
func (t T) Method()
```

bu metod `T`ning method setiga kiradi.

`*T` esa value receiver metodlarini ham ishlata oladi.

Ya'ni soddaroq qilib aytganda:

* `T` method setida `T` receiverli metodlar bor;
* `*T` method setida `T` va `*T` receiverli metodlar bor.

Bu interface bajarilishiga ta'sir qiladi.

Masalan:

```go
package main

import "fmt"

type Incrementer interface {
	Increment()
}

type Counter int

func (c *Counter) Increment() {
	*c++
}

func run(value Incrementer) {
	value.Increment()
}

func main() {
	var counter Counter

	run(&counter)

	fmt.Println(counter)
}
```

Natija:

```text
1
```

Bu yerda interface:

```go
type Incrementer interface {
    Increment()
}
```

`Increment()` metodiga ega bo'lgan tur kerakligini bildiradi.

`Counter` uchun metod quyidagicha yozilgan:

```go
func (c *Counter) Increment()
```

Receiver:

```go
*Counter
```

ekaniga e'tibor bering.

Demak, `Increment()` pointer receiverli metod.

Shuning uchun:

```go
*Counter
```

`Incrementer` interface'ni bajaradi.

Quyidagi kod ishlaydi:

```go
run(&counter)
```

Chunki:

```go
&counter
```

turi:

```go
*Counter
```

bo'ladi.

Lekin:

```go
run(counter)
```

kompilyatsiyadan o'tmaydi.

Sababi `Counter`ning o'z method setida:

```go
Increment()
```

yo'q.

Metod faqat:

```go
*Counter
```

uchun e'lon qilingan.

Bu yerda yana bir muhim farqni eslab qolish kerak.

Oldingi bo'limda quyidagicha chaqiruv ishlashini ko'rdik:

```go
counter.Increment()
```

Agar `counter`ning manzilini olish mumkin bo'lsa, Go metod chaqirilayotganda avtomatik ravishda:

```go
(&counter).Increment()
```

ko'rinishiga moslashtirishi mumkin.

Lekin interface tekshiruvida bunday avtomatik o'zgartirish amalga oshirilmaydi.

Interface'ga moslik turning **method seti** asosida kompilyatsiya vaqtida tekshiriladi.

Shuning uchun quyidagi ikki vaziyatni aralashtirmaslik kerak:

```go
counter.Increment()
```

va:

```go
run(counter)
```

Birinchisida Go metod chaqirig'ini avtomatik moslashtirishi mumkin.

Ikkinchisida esa `Counter` turi interface'ni bajaradimi yoki yo'qmi method set orqali tekshiriladi.

## Receiver nomini tanlash

Receiver ham oddiy o'zgaruvchi kabi nomga ega bo'ladi.

Masalan:

```go
func (a Account) Balance() int64
```

Bu yerda receiver nomi:

```go
a
```

Yoki:

```go
func (c *Counter) Increment()
```

bu yerda receiver:

```go
c
```

Go kodida receiver nomi odatda tur nomining bir yoki ikki harfidan olinadi.

Masalan:

```go
type Account struct{}
```

uchun:

```go
a
```

ishlatilishi mumkin.

```go
type Counter struct{}
```

uchun:

```go
c
```

ishlatilishi mumkin.

Go'da boshqa ayrim tillardagi kabi:

```text
this
```

yoki:

```text
self
```

nomlarini ishlatish odatiy emas.

Masalan, quyidagidan ko'ra:

```go
func (this Account) Balance() int64
```

quyidagi ko'rinish Go uslubiga yaqinroq:

```go
func (a Account) Balance() int64
```

Yana bir tavsiya — bir turga tegishli barcha metodlarda bir xil receiver nomidan foydalanish.

Masalan:

```go
func (a *Account) Deposit(amount int64) {}
func (a *Account) Withdraw(amount int64) {}
func (a *Account) Balance() int64 {}
```

Bir metodda `a`, boshqasida `acc`, yana boshqasida `account` ishlatish mumkin, lekin bir xil nomdan foydalanish kodni tezroq o'qishga yordam beradi.

## Misollar

### 1. Value receiver bilan hisoblash

```go
package main

import "fmt"

type Tortburchak struct {
	Eni  float64
	Boyi float64
}

func (t Tortburchak) Yuza() float64 {
	return t.Eni * t.Boyi
}

func main() {
	t := Tortburchak{
		Eni:  8,
		Boyi: 5,
	}

	fmt.Println(t.Yuza())
}
```

Bu misolda:

```go
func (t Tortburchak) Yuza() float64
```

value receiver ishlatilgan.

`Yuza()` metodi `Tortburchak` ichidagi qiymatlarni o'zgartirmaydi.

U faqat:

```go
t.Eni
```

va:

```go
t.Boyi
```

qiymatlarini o'qib, yuzani hisoblaydi.

Shuning uchun bu yerda pointer receiver kerak emas.

Metod chaqirilganda `Tortburchak` qiymati receiverga nusxa sifatida uzatiladi:

```go
t.Yuza()
```

### 2. Pointer receiver bilan qiymatni yangilash

```go
package main

import "fmt"

type Hisoblagich struct {
	Qiymat int
}

func (h *Hisoblagich) Oshirish() {
	h.Qiymat++
}

func main() {
	h := Hisoblagich{}

	h.Oshirish()
	h.Oshirish()

	fmt.Println(h.Qiymat)
}
```

Bu yerda `Oshirish()` metodining vazifasi `Hisoblagich` ichidagi qiymatni o'zgartirish.

Shuning uchun receiver:

```go
(h *Hisoblagich)
```

ko'rinishida yozilgan.

Bu pointer receiver.

Metod ichidagi:

```go
h.Qiymat++
```

asl `h` qiymatini o'zgartiradi.

Birinchi chaqiruvdan keyin:

```text
1
```

ikkinchi chaqiruvdan keyin:

```text
2
```

bo'ladi.

Biz metodni:

```go
h.Oshirish()
```

deb chaqirdik.

Aslida metod `*Hisoblagich` receiver talab qiladi.

Lekin `h` o'zgaruvchisining manzilini olish mumkinligi uchun Go buni avtomatik ravishda:

```go
(&h).Oshirish()
```

ko'rinishiga moslashtiradi.

### 3. Oddiy nomlangan turga metod qo'shish

```go
package main

import "fmt"

type Celsius float64

func (c Celsius) Fahrenheit() float64 {
	return float64(c)*9/5 + 32
}

func main() {
	harorat := Celsius(25)

	fmt.Println(harorat.Fahrenheit())
}
```

Metod faqat `struct` uchun yozilishi shart emas.

Bu misolda:

```go
type Celsius float64
```

orqali `float64` asosida yangi `Celsius` turi yaratildi.

Endi `Celsius` uchun alohida metod yozish mumkin:

```go
func (c Celsius) Fahrenheit() float64
```

Metod Celsius qiymatini Fahrenheitga aylantiradi.

Shuning uchun:

```go
harorat.Fahrenheit()
```

ko'rinishidagi kod tushunarli o'qiladi.

Bu usul oddiy qiymatlarga ham ma'no va ularga tegishli xatti-harakatlarni biriktirish imkonini beradi.

### 4. Metod orqali qiymatni tekshirish

```go
package main

import "fmt"

type Yosh int

func (y Yosh) Togri() bool {
	return y >= 0 && y <= 150
}

func main() {
	yosh := Yosh(24)

	fmt.Println(yosh.Togri())
}
```

Bu misolda:

```go
type Yosh int
```

orqali yosh uchun alohida tur yaratildi.

Keyin yosh qiymati to'g'ri oraliqda ekanini tekshiradigan metod yozildi:

```go
func (y Yosh) Togri() bool {
    return y >= 0 && y <= 150
}
```

Endi dasturning har bir joyida:

```go
yosh >= 0 && yosh <= 150
```

deb tekshiruv yozish shart emas.

Buning o'rniga:

```go
yosh.Togri()
```

deb chaqirish mumkin.

Tekshiruv qoidasi turning o'z metodida saqlanadi.

Agar keyinchalik qoida o'zgarsa, faqat bitta metodni o'zgartirish kifoya qiladi.

### 5. Metod orqali boshqariladigan yangilanish

```go
package main

import "fmt"

type Hisob struct {
	Balans int
}

func (h *Hisob) Yechish(summa int) bool {
	if summa <= 0 || summa > h.Balans {
		return false
	}

	h.Balans -= summa
	return true
}

func main() {
	h := Hisob{Balans: 100}

	fmt.Println(h.Yechish(30), h.Balans)
}
```

Bu misolda hisobdan pul yechish uchun `Yechish()` metodi yozilgan.

Metod avval berilgan summani tekshiradi:

```go
if summa <= 0 || summa > h.Balans {
    return false
}
```

Ikki holatda pul yechilmaydi:

* summa `0` yoki undan kichik bo'lsa;
* summa balansdan katta bo'lsa.

Agar qiymat to'g'ri bo'lsa:

```go
h.Balans -= summa
```

orqali balans kamaytiriladi.

So'ng:

```go
true
```

qaytariladi.

Shuning uchun metodning natijasidan operatsiya bajarilgan yoki bajarilmaganini bilish mumkin.

Eng muhim jihati — noto'g'ri summa berilsa, `Hisob` holati o'zgarmaydi.

### 6. `nil` receiverni tekshirish

```go
package main

import "fmt"

type Tugun struct {
	Qiymat int
}

func (t *Tugun) QiymatYokiNol() int {
	if t == nil {
		return 0
	}

	return t.Qiymat
}

func main() {
	var tugun *Tugun

	fmt.Println(tugun.QiymatYokiNol())
}
```

Bu misolda:

```go
var tugun *Tugun
```

deb pointer e'lon qilingan.

Lekin unga hech qanday qiymat berilmagan.

Shuning uchun:

```go
tugun == nil
```

bo'ladi.

Shunga qaramay:

```go
tugun.QiymatYokiNol()
```

metodini chaqirish mumkin.

Sababi metod pointer receiver bilan yozilgan:

```go
func (t *Tugun) QiymatYokiNol() int
```

Metod ichida receiver avval tekshiriladi:

```go
if t == nil {
    return 0
}
```

Shundan keyingina:

```go
t.Qiymat
```

maydoniga murojaat qilinadi.

Agar `nil` tekshiruvisiz darhol:

```go
return t.Qiymat
```

deb yozilganida, `nil` pointer sabab runtime xatosi yuz berishi mumkin edi.

### 7. Method value

```go
package main

import "fmt"

type Kopaytirgich int

func (k Kopaytirgich) Hisobla(son int) int {
	return int(k) * son
}

func main() {
	ikki := Kopaytirgich(2)

	hisobla := ikki.Hisobla

	fmt.Println(hisobla(7))
}
```

Bu yerda:

```go
ikki := Kopaytirgich(2)
```

qiymati yaratildi.

Keyin:

```go
hisobla := ikki.Hisobla
```

deb metod o'zgaruvchiga saqlandi.

Bu **method value** hisoblanadi.

Muhim jihati shundaki, `hisobla` ichida `ikki` receiveri ham saqlanadi.

Shuning uchun:

```go
hisobla(7)
```

chaqirilganda `ikki`ni yana uzatish kerak emas.

Go uni quyidagi ma'noda ishlatadi:

```go
ikki.Hisobla(7)
```

`ikki`ning qiymati `2`, argument esa `7`.

Natijada:

```text
14
```

hosil bo'ladi.

### 8. Method expression

```go
package main

import "fmt"

type Son int

func (s Son) Kvadrat() int {
	return int(s * s)
}

func main() {
	kvadrat := Son.Kvadrat

	fmt.Println(kvadrat(Son(9)))
}
```

Bu safar:

```go
kvadrat := Son.Kvadrat
```

deb metod olindi.

Bu **method expression** hisoblanadi.

Method valuedan farqli ravishda, bu yerda metod ma'lum bir receiver qiymatiga bog'lanmagan.

Shuning uchun receiver chaqiruv vaqtida birinchi argument sifatida beriladi:

```go
kvadrat(Son(9))
```

Bu deyarli quyidagiga teng:

```go
Son(9).Kvadrat()
```

Method expression yordamida bitta metodni turli receiver qiymatlari bilan ishlatish mumkin.

Masalan:

```go
kvadrat(Son(5))
kvadrat(Son(10))
kvadrat(Son(20))
```

Har bir chaqiruvda birinchi argument receiver sifatida ishlatiladi.

### 9. Slice elementlarida pointer receiver

```go
package main

import "fmt"

type Mahsulot struct {
	Narx int
}

func (m *Mahsulot) Chegirma(foiz int) {
	m.Narx -= m.Narx * foiz / 100
}

func main() {
	mahsulotlar := []Mahsulot{
		{Narx: 100},
		{Narx: 200},
	}

	for i := range mahsulotlar {
		mahsulotlar[i].Chegirma(10)
	}

	fmt.Println(mahsulotlar)
}
```

Bu misolda `Mahsulot` uchun narxni o'zgartiradigan metod yozilgan:

```go
func (m *Mahsulot) Chegirma(foiz int)
```

Narx o'zgarishi kerakligi sabab pointer receiver ishlatilgan.

Slice:

```go
mahsulotlar := []Mahsulot{
    {Narx: 100},
    {Narx: 200},
}
```

ikki elementdan iborat.

Loop:

```go
for i := range mahsulotlar {
    mahsulotlar[i].Chegirma(10)
}
```

har bir elementga 10 foiz chegirma qo'llaydi.

Bu yerda muhim qism:

```go
mahsulotlar[i]
```

indeks orqali olinmoqda.

Slice elementi indeks orqali olinganda uning manzilini olish mumkin.

Shuning uchun Go:

```go
mahsulotlar[i].Chegirma(10)
```

chaqiruvini pointer receiver uchun moslashtira oladi.

Natijada slice ichidagi asl elementlarning `Narx` qiymati o'zgaradi.

Birinchi mahsulot:

```text
100
```

dan:

```text
90
```

ga tushadi.

Ikkinchi mahsulot:

```text
200
```

dan:

```text
180
```

ga tushadi.

### 10. Bir tur uchun izchil receiver tanlash

```go
package main

import "fmt"

type Savat struct {
	Soni int
}

func (s *Savat) Qosh(soni int) {
	s.Soni += soni
}

func (s *Savat) Boshmi() bool {
	return s.Soni == 0
}

func main() {
	s := Savat{}

	fmt.Println(s.Boshmi())

	s.Qosh(3)

	fmt.Println(s.Boshmi())
}
```

Bu misolda `Savat` uchun ikkita metod bor:

```go
func (s *Savat) Qosh(soni int)
```

va:

```go
func (s *Savat) Boshmi() bool
```

`Qosh()` metodi savat holatini o'zgartiradi:

```go
s.Soni += soni
```

Shuning uchun bu metodda pointer receiver kerak.

`Boshmi()` esa faqat qiymatni tekshiradi:

```go
return s.Soni == 0
```

Texnik jihatdan uni value receiver bilan ham yozish mumkin edi:

```go
func (s Savat) Boshmi() bool {
    return s.Soni == 0
}
```

Lekin shu turdagi boshqa metodlar pointer receiver ishlatayotgani uchun `Boshmi()` ham pointer receiver bilan yozilgan:

```go
func (s *Savat) Boshmi() bool
```

Bu bir tur metodlarida receiver tanlovini izchil saqlaydi.

Natijada `Savat` bilan ishlaganda qaysi metod pointer, qaysi metod value receiver ishlatishini alohida eslab yurish kamroq kerak bo'ladi.
