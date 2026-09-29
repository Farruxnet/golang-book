# Go’da generics bilan ishlash

Generics bir xil algoritmni bir nechta tur bilan ishlatish imkonini beradi. Bunda har bir tur uchun alohida funksiya yozishga hojat qolmaydi.

Masalan, `int` qiymatlarini jamlash uchun bitta funksiya, `float64` qiymatlarini jamlash uchun yana boshqa funksiya yozish mumkin. Lekin ikkala funksiyaning ishlash mantiqi bir xil bo‘lsa, bu kod takrorlanishiga olib keladi.

Generics yordamida turning o‘zini parametr sifatida berish mumkin. Bunday parametr **tur parametri** yoki `type parameter` deyiladi.

Natijada bitta funksiya:

* `int`;
* `int64`;
* `float64`;
* yoki constraint ruxsat bergan boshqa turlar

bilan ishlashi mumkin.

Muhim tomoni shundaki, bu jarayonda tur haqidagi ma’lumot yo‘qolmaydi. Kompilyator qaysi tur ishlatilayotganini biladi va noto‘g‘ri turdagi qiymatlarni compile time vaqtida aniqlay oladi.

Go generics’ni 1.18 versiyasidan boshlab qo‘llab-quvvatlaydi.

Shunga qaramay, har bir funksiyani generic qilish kerak emas. Generics ayniqsa quyidagi holatda foydali:

* algoritm bir xil bo‘lsa;
* faqat ishlatilayotgan turlar farq qilsa;
* kod takrorlanishini kamaytirsa;
* kiruvchi va chiquvchi turlar orasidagi bog‘lanishni saqlash kerak bo‘lsa.

Agar generic kod oddiy koddan ko‘ra murakkabroq va o‘qilishi qiyinroq bo‘lib qolsa, undan foydalanish shart emas.

## Generics nima uchun kerak?

Tasavvur qiling, dasturda buyurtmalar bilan ishlayapmiz.

Buyurtmadagi mahsulot sonlari `int` ko‘rinishida saqlanadi:

```go
[]int
```

Narxlar esa `float64` bo‘lishi mumkin:

```go
[]float64
```

Har ikkala slice ichidagi qiymatlarni jamlash kerak.

Generics ishlatmasdan ikkita alohida funksiya yozishimiz mumkin:

```go
func intlarniJamlash(values []int) int {
	var total int
	for _, value := range values {
		total += value
	}
	return total
}

func floatlarniJamlash(values []float64) float64 {
	var total float64
	for _, value := range values {
		total += value
	}
	return total
}
```

Bu kod ishlaydi.

Birinchi funksiya:

```go
func intlarniJamlash(values []int) int
```

faqat `[]int` qabul qiladi va `int` qaytaradi.

Ikkinchi funksiya:

```go
func floatlarniJamlash(values []float64) float64
```

esa `[]float64` qabul qiladi va `float64` qaytaradi.

Lekin funksiyalarning ichiga qarasak, algoritm deyarli aynan bir xil:

```go
var total ...
for _, value := range values {
	total += value
}
return total
```

Faqat tur nomlari o‘zgargan.

Endi `int64` bilan ham ishlash kerak bo‘lsa, yana uchinchi funksiya yozishga to‘g‘ri keladi. Keyin boshqa son turi qo‘shilsa, yana yangi nusxa paydo bo‘ladi.

Bu yerda generics foydali.

Tur farqini oddiy kod nusxalari orqali emas, tur parametri orqali ifodalash mumkin:

```go
package main

import "fmt"

type Number interface {
	~int | ~int64 | ~float64
}

func jamlash[T Number](values []T) T {
	var total T
	for _, value := range values {
		total += value
	}
	return total
}

func main() {
	miqdorlar := []int{2, 3, 5}
	narxlar := []float64{12.5, 7.25, 10}

	fmt.Println(jamlash(miqdorlar))
	fmt.Println(jamlash(narxlar))
}
```

Natija:

```text
10
29.75
```

Bu yerda bitta `jamlash()` funksiyasi ikki xil tur bilan ishladi.

Birinchi chaqiruv:

```go
jamlash(miqdorlar)
```

uchun `miqdorlar` turi:

```go
[]int
```

Shuning uchun `T` `int` sifatida aniqlanadi.

Funksiya amalda quyidagi ma’noda ishlaydi:

```go
func jamlash(values []int) int
```

Ikkinchi chaqiruv:

```go
jamlash(narxlar)
```

uchun esa `T` `float64` bo‘ladi:

```go
func jamlash(values []float64) float64
```

Muhim jihat shundaki, funksiya `any` qaytarmayapti. Kirishda qaysi tur ishlatilgan bo‘lsa, natijada ham aynan shu tur saqlanadi.

Shuning uchun:

```go
[]int -> int
```

va:

```go
[]float64 -> float64
```

bog‘lanishi yo‘qolmaydi.

## Tur parametri va constraint

Generic funksiya nomidan keyin `[]` ichida tur parametrlari yoziladi.

Masalan:

```go
func jamlash[T Number](values []T) T
```

Bu yozuvni qismlarga ajratib ko‘ramiz.

### `T` — tur parametri

```go
T
```

bu yerda aniq tur emas.

U funksiyani chaqirish vaqtida aniqlanadigan tur uchun nom hisoblanadi.

Masalan:

```go
jamlash([]int{1, 2, 3})
```

chaqiruvida:

```text
T = int
```

bo‘ladi.

Quyidagi chaqiruvda:

```go
jamlash([]float64{1.5, 2.5})
```

esa:

```text
T = float64
```

bo‘ladi.

`T` nomi majburiy emas. Boshqa nom ishlatish ham mumkin:

```go
func jamlash[Element Number](values []Element) Element
```

Lekin qisqa tur parametrlarida `T`, `K`, `V`, `R` kabi nomlar keng tarqalgan.

### `Number` — constraint

```go
T Number
```

qismidagi `Number` constraint hisoblanadi.

Constraint tur parametriga qanday turlar berilishi mumkinligini belgilaydi.

Bizning misolda:

```go
type Number interface {
	~int | ~int64 | ~float64
}
```

yozilgan.

Demak, `T`:

* `int`;
* `int64`;
* `float64`;
* yoki shu turlardan birini underlying type sifatida ishlatadigan mos nomlangan tur

bo‘lishi mumkin.

Constraint faqat qaysi turlar ruxsat etilganini belgilamaydi. U generic funksiya ichida `T` qiymatlari ustida qaysi amallarni bajarish mumkinligini ham belgilaydi.

Masalan:

```go
total += value
```

yozilgan.

Bu amalda:

```go
total = total + value
```

degan ma’noni beradi.

`Number` constraintidagi barcha turlar `+` operatorini qo‘llab-quvvatlaydi. Shu sabab kompilyator bu kodga ruxsat beradi.

Agar constraint ichida `+` operatorini qo‘llamaydigan tur ham bo‘lganida, bunday kodni yozib bo‘lmas edi.

### `[]T` — generic slice

Funksiya parametri:

```go
values []T
```

deb yozilgan.

Bu `values` — elementlari `T` turida bo‘lgan slice degani.

Agar:

```text
T = int
```

bo‘lsa:

```go
[]T
```

amalda:

```go
[]int
```

bo‘ladi.

Agar:

```text
T = float64
```

bo‘lsa:

```go
[]T
```

amalda:

```go
[]float64
```

bo‘ladi.

### Oxirgi `T` — qaytish turi

Funksiya signature’ining oxiridagi:

```go
T
```

funksiyaning qaytish turini bildiradi:

```go
func jamlash[T Number](values []T) T
```

Bu juda muhim.

Kiruvchi slice qaysi element turida bo‘lsa, funksiya natijasi ham aynan shu turda bo‘ladi.

Masalan:

```go
total := jamlash([]int{1, 2, 3})
```

bu yerda `total` turi:

```go
int
```

bo‘ladi.

Quyidagida esa:

```go
total := jamlash([]float64{1.2, 3.4})
```

`total` turi:

```go
float64
```

bo‘ladi.

## Chuqurlashtirish: constraintdagi `|` va `~`

Oddiy generic funksiyalar uchun `any` yoki tayyor constraint yetarli bo‘lishi mumkin. Quyidagi type set sintaksisi nomlangan turlarni ham qamrab oladigan maxsus constraint yozish kerak bo‘lganda qo‘l keladi.

Quyidagi constraintni yana bir marta ko‘ramiz:

```go
type Number interface {
	~int | ~int64 | ~float64
}
```

Bu yerda ikkita muhim belgi bor:

* `|`;
* `~`.

### `|` — turlarni birlashtirish

`|` belgisi bir nechta ruxsat etilgan type set’larni birlashtiradi.

Masalan:

```go
int | float64
```

deyilsa, tur parametri `int` yoki `float64` bo‘lishi mumkin.

Bizda:

```go
~int | ~int64 | ~float64
```

yozilgan.

Demak, constraint shu uchta asosiy tur guruhiga mos qiymatlarni qabul qiladi.

### `~` — underlying type’ga moslash

`~int` faqat built-in `int` turining o‘zini anglatmaydi.

U underlying type’i `int` bo‘lgan nomlangan turlarni ham qabul qiladi.

Masalan:

```go
type Quantity int
```

Bu yerda `Quantity` yangi, nomlangan tur.

U `int` bilan aynan bir xil tur emas:

```go
int
```

va:

```go
Quantity
```

ikkita alohida tur.

Lekin `Quantity`ning underlying type’i `int`.

Shuning uchun:

```go
~int
```

constraintiga `Quantity` ham mos keladi.

Agar constraint quyidagicha bo‘lsa:

```go
type Number interface {
	int | float64
}
```

unda faqat aynan `int` va `float64` turlariga ruxsat beriladi.

Quyidagi nomlangan tur:

```go
type Quantity int
```

unga mos kelmaydi.

Shuning uchun `~` generic constraintlarda nomlangan turlarni ham qo‘llab-quvvatlash kerak bo‘lganda juda foydali.

## Tur inferensiyasi

Generic funksiyani chaqirishda tur argumentini qo‘lda ko‘rsatish mumkin.

Masalan:

```go
total := jamlash[int]([]int{1, 2, 3})
```

Bu yerda:

```go
[int]
```

orqali `T` aynan `int` ekanini o‘zimiz yozdik.

To‘liq mantiq:

```text
T = int
values = []int{1, 2, 3}
natija turi = int
```

Lekin ko‘p holatda Go tur argumentini funksiya argumentlaridan o‘zi aniqlay oladi.

Shuning uchun quyidagicha yozish yetarli:

```go
total := jamlash([]int{1, 2, 3})
```

Kompilyator `[]int` argumentini ko‘radi.

Funksiya esa:

```go
func jamlash[T Number](values []T) T
```

ko‘rinishida.

Shundan:

```text
[]T = []int
```

ekanini aniqlaydi.

Demak:

```text
T = int
```

bo‘lishi kerak.

Bu jarayon **tur inferensiyasi**, ya’ni `type inference` deyiladi.

Har ikkala yozuv bir xil `T` bilan ishlaydi:

```go
jamlash[int]([]int{1, 2, 3})
```

va:

```go
jamlash([]int{1, 2, 3})
```

Lekin ikkinchi variant odatda qisqaroq va tabiiyroq.

### Tur inferensiyasi har doim ham ishlamaydi

Ba’zan kompilyator `T`ni aniqlashi uchun yetarli ma’lumot bo‘lmaydi.

Masalan:

```go
func zero[T any]() T {
	var value T
	return value
}
```

Bu funksiya hech qanday argument qabul qilmaydi.

Agar shunday yozsak:

```go
zero()
```

kompilyator `T` qaysi tur ekanini qayerdan bilishni aniqlay olmaydi.

Chunki funksiyaga:

* `int`;
* `string`;
* `bool`;
* yoki boshqa turni ko‘rsatuvchi hech qanday qiymat berilmagan.

Shuning uchun tur argumentini aniq ko‘rsatish kerak:

```go
son := zero[int]()
matn := zero[string]()
```

Birinchi chaqiruvda:

```text
T = int
```

bo‘ladi.

Ikkinchisida:

```text
T = string
```

bo‘ladi.

## `any` constrainti

`any` Go’dagi eng keng constraintlardan biri.

U istalgan turga ruxsat beradi.

`any` aslida:

```go
interface{}
```

uchun alias hisoblanadi.

Ya’ni:

```go
T any
```

deb yozish:

```go
T interface{}
```

deganga teng.

Lekin generics kodida `any` ancha qisqa va o‘qilishi oson.

Quyidagi funksiya slice nusxasini yaratadi:

```go
package main

import "fmt"

func nusxalash[T any](values []T) []T {
	result := make([]T, len(values))
	copy(result, values)
	return result
}

func main() {
	sonlar := nusxalash([]int{10, 20, 30})
	sozlar := nusxalash([]string{"Go", "Generics"})

	fmt.Println(sonlar)
	fmt.Println(sozlar)
}
```

Natija:

```text
[10 20 30]
[Go Generics]
```

Bu funksiya elementning o‘zi ustida:

* qo‘shish;
* ayirish;
* taqqoslash;
* tartiblash

kabi turga xos operatsiyalar bajarmaydi.

U faqat:

1. `[]T` uzunligicha yangi slice yaratadi;
2. elementlarni `copy()` orqali nusxalaydi;
3. yangi `[]T`ni qaytaradi.

Shuning uchun `T` uchun qo‘shimcha cheklov kerak emas.

```go
T any
```

yetarli.

### `any` barcha operatorlarga ruxsat bermaydi

Bu yerda muhim bir farq bor.

`any`:

> istalgan tur berish mumkin

degan ma’noni beradi.

Lekin:

> istalgan operatorni ishlatish mumkin

degan ma’noni bermaydi.

Masalan:

```go
func add[T any](a, b T) T {
	return a + b
}
```

bunday funksiya ishlamaydi.

Sababi `T` istalgan tur bo‘lishi mumkin.

Masalan:

```go
struct{}
```

yoki:

```go
[]int
```

uchun `+` operatori mavjud emas.

Xuddi shuningdek:

```go
a > b
```

ham barcha turlar uchun mavjud emas.

Shuning uchun `T any` bilan faqat barcha turlar uchun ma’noli bo‘lgan operatsiyalarni bajarish mumkin.

### Oddiy `any` va `T any` farqi

Quyidagi ikkita signature tashqi ko‘rinishda o‘xshash:

```go
func birinchi(values []any) any
```

va:

```go
func birinchi[T any](values []T) T
```

Lekin ularning ma’nosi bir xil emas.

Birinchi variant:

```go
func birinchi(values []any) any
```

aniq tur haqidagi bog‘lanishni saqlamaydi.

Funksiya `any` qabul qiladi va `any` qaytaradi.

Masalan, natija aslida `int` bo‘lsa ham, statik turi `any` bo‘ladi.

Ikkinchi variant:

```go
func birinchi[T any](values []T) T
```

kiruvchi slice element turini saqlaydi.

Agar:

```go
[]int
```

berilsa:

```text
T = int
```

bo‘ladi va natija ham `int`.

Agar:

```go
[]string
```

berilsa, natija `string`.

Generics’ning katta afzalliklaridan biri aynan shu: turlar orasidagi bog‘lanish compile time’da saqlanadi.

## `comparable` constrainti

Ba’zi generic funksiyalarda qiymatlarni:

```go
==
```

yoki:

```go
!=
```

bilan solishtirish kerak bo‘ladi.

Buning uchun Go’da tayyor `comparable` constrainti mavjud.

Masalan:

```go
package main

import "fmt"

func mavjud[T comparable](values []T, target T) bool {
	for _, value := range values {
		if value == target {
			return true
		}
	}
	return false
}

func main() {
	fmt.Println(mavjud([]string{"go", "rust"}, "go"))
	fmt.Println(mavjud([]int{10, 20}, 30))
}
```

Natija:

```text
true
false
```

Funksiya quyidagicha ishlaydi:

1. `values` slice bo‘ylab yuradi;
2. har bir elementni `target` bilan solishtiradi;
3. teng element topilsa `true` qaytaradi;
4. butun slice tekshirilib, mos qiymat topilmasa `false` qaytaradi.

Muhim qator:

```go
if value == target
```

Bu yerda `==` operatori ishlatilgan.

Shuning uchun kompilyator `T`ning `==` bilan solishtirish mumkinligini bilishi kerak.

Shu sabab:

```go
T comparable
```

yozilgan.

### `comparable` nimani anglatmaydi?

`comparable` qiymatlarni tenglik bo‘yicha solishtirish mumkinligini bildiradi.

Ya’ni:

```go
==
```

va:

```go
!=
```

ishlatish mumkin.

Lekin bu qiymatlarni tartib bo‘yicha solishtirish mumkin degani emas.

Masalan, quyidagiga `comparable` yetarli emas:

```go
a < b
```

yoki:

```go
a > b
```

Chunki `comparable` ichiga `bool` kabi turlar ham kiradi, `bool` esa `<` operatorini qo‘llab-quvvatlamaydi.

Shuningdek, barcha Go turlari `comparable` emas.

Masalan:

* slice;
* map;
* function

qiymatlarini oddiy `==` bilan o‘zaro solishtirib bo‘lmaydi.

Shu sabab ular `comparable` tur parametriga mos kelmaydi.

## Bir nechta tur parametri

Generic funksiya faqat bitta tur parametri bilan cheklanmaydi.

Bir nechta tur parametri ishlatish mumkin.

Masalan, map bilan ishlaganda kalit va qiymat turlari har xil bo‘lishi mumkin:

```go
map[string]int
```

Bu yerda:

```text
kalit turi = string
qiymat turi = int
```

Map kalitlarini slice ko‘rinishida qaytaradigan generic funksiya yozamiz:

```go
package main

import "fmt"

func kalitlar[K comparable, V any](items map[K]V) []K {
	result := make([]K, 0, len(items))
	for key := range items {
		result = append(result, key)
	}
	return result
}

func main() {
	ages := map[string]int{
		"Ali":  24,
		"Vali": 31,
	}

	fmt.Println(kalitlar(ages))
}
```

Bu yerda ikkita tur parametri bor:

```go
[K comparable, V any]
```

### `K` — kalit turi

```go
K comparable
```

`K` map kalitining turini ifodalaydi.

Go’da map kalitlari `comparable` bo‘lishi kerak.

Sababi map ichida kalitlarni topish uchun Go ularni tenglik bo‘yicha tekshirishi kerak.

Shuning uchun `K`ni `any` qilib bo‘lmaydi:

```go
K any
```

desak, slice kabi map kaliti bo‘la olmaydigan turlar ham nazariy jihatdan ruxsat etilgan bo‘lib qolardi.

### `V` — qiymat turi

```go
V any
```

map qiymatining turini bildiradi.

Funksiya `V` qiymatlari ustida hech qanday turga xos amal bajarmaydi.

Hatto qiymatlarni o‘qimaydi ham.

Shuning uchun `V` uchun `any` yetarli.

### Natija turi

Funksiya:

```go
[]K
```

qaytaradi.

Ya’ni map kalitlari qaysi turda bo‘lsa, natijadagi slice elementlari ham shu turda bo‘ladi.

Masalan:

```go
map[string]int
```

uchun:

```text
K = string
V = int
```

bo‘ladi.

Natija:

```go
[]string
```

bo‘ladi.

### Map tartibi haqida

Go map elementlarining iteratsiya tartibi kafolatlanmagan.

Shuning uchun:

```go
for key := range items
```

orqali olingan kalitlar har safar bir xil tartibda chiqishi shart emas.

Masalan, bir ishga tushirishda:

```text
[Ali Vali]
```

chiqishi mumkin.

Boshqa ishga tushirishda:

```text
[Vali Ali]
```

ko‘rinishi ham mumkin.

Agar aniq tartib kerak bo‘lsa, kalitlarni keyin alohida tartiblash kerak.

## Generic type

Tur parametrlarini faqat funksiyalarda emas, `type` e’lonlarida ham ishlatish mumkin.

Bunday tur **generic type** deyiladi.

Generic type bir xil ma’lumot tuzilmasini turli element turlari bilan ishlatish uchun foydali.

Masalan, `Stack` yaratamiz.

Stack LIFO tamoyili bo‘yicha ishlaydi:

```text
Last In, First Out
```

Ya’ni oxirgi qo‘shilgan element birinchi bo‘lib olinadi.

Kod:

```go
package main

import "fmt"

type Stack[T any] struct {
	items []T
}

func (s *Stack[T]) Push(value T) {
	s.items = append(s.items, value)
}

func (s *Stack[T]) Pop() (T, bool) {
	if len(s.items) == 0 {
		var zero T
		return zero, false
	}

	last := len(s.items) - 1
	value := s.items[last]
	s.items = s.items[:last]
	return value, true
}

func main() {
	var stack Stack[string]
	stack.Push("birinchi")
	stack.Push("ikkinchi")

	value, ok := stack.Pop()
	if ok {
		fmt.Println(value)
	}
}
```

Natija:

```text
ikkinchi
```

### `Stack[T]` qanday ishlaydi?

Struct:

```go
type Stack[T any] struct {
	items []T
}
```

deb e’lon qilingan.

Bu yerda `T` stack ichida saqlanadigan element turini bildiradi.

Masalan:

```go
Stack[string]
```

yaratilsa:

```text
T = string
```

bo‘ladi.

Shuning uchun `items`:

```go
[]string
```

sifatida ishlaydi.

Agar:

```go
Stack[int]
```

yaratilsa:

```text
T = int
```

bo‘ladi.

### `Push()`

Metod:

```go
func (s *Stack[T]) Push(value T) {
	s.items = append(s.items, value)
}
```

faqat `T` turidagi qiymat qabul qiladi.

Masalan:

```go
var stack Stack[string]
```

bo‘lsa:

```go
stack.Push("hello")
```

to‘g‘ri.

Lekin:

```go
stack.Push(10)
```

compile time xatoga olib keladi.

Chunki `Stack[string]` uchun `T` allaqachon `string`.

### `Pop()`

Metod:

```go
func (s *Stack[T]) Pop() (T, bool)
```

ikkita qiymat qaytaradi:

* element;
* element mavjud yoki yo‘qligini bildiruvchi `bool`.

Avval stack bo‘shligi tekshiriladi:

```go
if len(s.items) == 0 {
```

Agar bo‘sh bo‘lsa, `T` turidagi oddiy qiymatni qaytarish kerak.

Lekin `T` oldindan aniq emas.

Shuning uchun generic kodda keng ishlatiladigan usuldan foydalaniladi:

```go
var zero T
```

`zero` avtomatik ravishda `T` turning zero value qiymatini oladi.

Masalan:

```text
T = int       -> 0
T = string    -> ""
T = bool      -> false
T = *User     -> nil
```

Shu sabab bo‘sh stack uchun:

```go
return zero, false
```

qaytariladi.

### Oxirgi elementni olish

Stack bo‘sh bo‘lmasa:

```go
last := len(s.items) - 1
```

orqali oxirgi indeks topiladi.

Masalan, slice uzunligi `2` bo‘lsa:

```text
len = 2
last = 2 - 1
last = 1
```

Indekslar:

```text
0 -> birinchi
1 -> ikkinchi
```

Shuning uchun:

```go
value := s.items[last]
```

oxirgi elementni oladi.

Keyin:

```go
s.items = s.items[:last]
```

orqali o‘sha element stackdan chiqariladi.

### Generic type receiveri

Generic type metodida receiver ham tur parametrini ko‘rsatishi kerak:

```go
func (s *Stack[T]) Push(value T)
```

Bu yerdagi:

```go
Stack[T]
```

ushbu metod `Stack` generic type’iga tegishli ekanini bildiradi.

Receiverda constraintni qayta yozish kerak emas.

Masalan, struct:

```go
type Stack[T any] struct
```

deb e’lon qilingan bo‘lsa, metodda:

```go
func (s *Stack[T any]) Push(...)
```

deb yozilmaydi.

To‘g‘ri yozuv:

```go
func (s *Stack[T]) Push(...)
```

bo‘ladi.

## Generics qachon kerak emas?

Generics kuchli imkoniyat beradi. Lekin bu uni barcha joyda ishlatish kerak degani emas.

Ba’zi hollarda oddiy funksiya yoki interface ancha tushunarli bo‘ladi.

### Kod faqat bitta aniq tur bilan ishlasa

Masalan, funksiya faqat `User` bilan ishlashi kerak bo‘lsa:

```go
func saveUser(user User)
```

uni shunchaki generic qilishning foydasi yo‘q.

Quyidagi kabi yozuv:

```go
func save[T User](value T)
```

kodni murakkablashtirishi mumkin, lekin amaliy foyda bermaydi.

### Turlar turli xatti-harakat talab qilsa

Generics bir xil algoritm turli turlarda ishlaganda qulay.

Agar har bir tur uchun butunlay boshqa xatti-harakat kerak bo‘lsa, generic funksiya ichida ko‘plab maxsus holatlar paydo bo‘lishi mumkin.

Bunday vaziyatda polymorphism uchun oddiy interface yaxshiroq yechim bo‘lishi mumkin.

### Interface xatti-harakatni yaxshiroq ifodalasa

Masalan, funksiyaga:

> `Write()` qila oladigan istalgan obyekt

kerak bo‘lsa, tur ro‘yxatini constraintda sanashdan ko‘ra interface ishlatish tabiiyroq.

Generics asosan:

> qiymatlarning konkret turlari orasidagi compile time bog‘lanishni saqlash

uchun foydali.

Interface esa ko‘proq:

> obyekt nima qila oladi

degan xatti-harakatni ifodalaydi.

### Generic kod o‘qishni qiyinlashtirsa

Ba’zan kod takrorlanishini ozgina kamaytirish uchun juda murakkab constraint yoziladi.

Natijada oddiy 5 qatorlik kod o‘rniga o‘qish qiyin generic abstraksiya paydo bo‘lishi mumkin.

Bunday holatda takrorlangan oddiy kod ba’zan yaxshiroq tanlov bo‘ladi.

### Constraintni imkon qadar tor tanlash

Constraint funksiya haqiqatan talab qiladigan imkoniyatlarga mos bo‘lishi kerak.

Masalan, faqat tenglik tekshiruvi kerak bo‘lsa:

```go
T comparable
```

yetarli.

Hech qanday turga xos amal bajarilmasa:

```go
T any
```

yetarli.

Agar `+` kerak bo‘lsa, `+`ni qo‘llab-quvvatlaydigan mos type set kerak.

Keraksiz turlarni katta constraintga qo‘shish funksiyaning maqsadini noaniq qiladi.

Constraint qanchalik aniq bo‘lsa, generic funksiyaning nimaga mo‘ljallangani ham shunchalik ravshan bo‘ladi.

## Misollar

### 1. Istalgan turning nol qiymatini olish

Bu misol generic kodda `T` turning zero value qiymatini qanday olish mumkinligini ko‘rsatadi.

Funksiya argument qabul qilmaydi. Shu sabab turning o‘zini chaqiruv vaqtida aniq ko‘rsatish kerak.

```go
package main

import "fmt"

func zero[T any]() T {
	var value T
	return value
}

func main() {
	fmt.Println(zero[int]())
	fmt.Printf("%q\n", zero[string]())
	fmt.Println(zero[bool]())
}
```

Asosiy qator:

```go
var value T
```

Go’da `var` bilan yaratilgan va boshlang‘ich qiymat berilmagan o‘zgaruvchi avtomatik ravishda o‘z turining zero value qiymatini oladi.

Bu qoida generic tur uchun ham ishlaydi.

Birinchi chaqiruv:

```go
zero[int]()
```

uchun:

```text
T = int
```

Shuning uchun:

```go
var value int
```

kabi ishlaydi.

`int`ning zero value qiymati:

```text
0
```

Ikkinchi chaqiruv:

```go
zero[string]()
```

uchun:

```text
T = string
```

`string`ning zero value qiymati bo‘sh matn:

```text
""
```

Uchinchi chaqiruv:

```go
zero[bool]()
```

uchun natija:

```text
false
```

Funksiya argument qabul qilmagani uchun:

```go
zero()
```

deb yozish yetarli emas.

Kompilyator `T`ni argumentdan aniqlay olmaydi.

Shuning uchun:

```go
[int]
```

yoki:

```go
[string]
```

kabi tur argumentini aniq berish kerak.

Bu misolda ko‘rsatilayotgan asosiy qoida: generic kodda noma’lum `T` turning zero value qiymatini olish uchun:

```go
var zero T
```

usuli ishlatiladi.

### 2. Slice ichidan birinchi elementni xavfsiz olish

Bu misol slice ichidan birinchi elementni olishda bo‘sh slice holatini qanday xavfsiz boshqarish mumkinligini ko‘rsatadi.

```go
package main

import "fmt"

func first[T any](values []T) (T, bool) {
	if len(values) == 0 {
		var zero T
		return zero, false
	}

	return values[0], true
}

func main() {
	number, numberOK := first([]int{10, 20, 30})
	word, wordOK := first([]string{})

	fmt.Println(number, numberOK)
	fmt.Printf("%q %t\n", word, wordOK)
}
```

Slice indekslari `0` dan boshlanadi.

Masalan:

```go
[]int{10, 20, 30}
```

uchun indekslar:

```text
0 -> 10
1 -> 20
2 -> 30
```

Shuning uchun birinchi element:

```go
values[0]
```

orqali olinadi.

Lekin bo‘sh slice:

```go
[]string{}
```

uchun `0` indeks mavjud emas.

Agar tekshirmasdan:

```go
values[0]
```

ga murojaat qilinsa, dastur runtime’da panic qiladi.

Shuning uchun avval:

```go
if len(values) == 0
```

tekshiriladi.

Bo‘sh bo‘lsa:

```go
var zero T
return zero, false
```

qaytariladi.

Bu yerda `false`:

> element topilmadi

degan ma’noni beradi.

Agar element mavjud bo‘lsa:

```go
return values[0], true
```

qaytariladi.

Birinchi chaqiruv:

```go
first([]int{10, 20, 30})
```

natijasi:

```text
10 true
```

Ikkinchi chaqiruvda slice bo‘sh:

```go
first([]string{})
```

shuning uchun:

```text
"" false
```

qaytadi.

Bu usul Go’dagi ko‘plab API’larda uchraydigan `value, ok` uslubiga o‘xshaydi.

### 3. Slice tartibini joyida teskarilash

Bu misolda bitta generic funksiya `int`, `string` yoki boshqa istalgan element turidagi slice tartibini teskarilaydi.

```go
package main

import "fmt"

func reverse[T any](values []T) {
	for left, right := 0, len(values)-1; left < right; left, right = left+1, right-1 {
		values[left], values[right] = values[right], values[left]
	}
}

func main() {
	numbers := []int{1, 2, 3, 4}
	words := []string{"bir", "ikki", "uch"}

	reverse(numbers)
	reverse(words)

	fmt.Println(numbers)
	fmt.Println(words)
}
```

Bu algoritm slice boshidan va oxiridan bir vaqtning o‘zida yuradi.

Boshlanishida:

```go
left := 0
```

birinchi element indeksini bildiradi.

```go
right := len(values) - 1
```

esa oxirgi element indeksini bildiradi.

Masalan:

```go
numbers := []int{1, 2, 3, 4}
```

uchun:

```text
len(numbers) = 4
right = 4 - 1
right = 3
```

Indekslar:

```text
0 -> 1
1 -> 2
2 -> 3
3 -> 4
```

Birinchi aylanishda:

```text
left = 0
right = 3
```

quyidagi almashish bajariladi:

```go
values[left], values[right] = values[right], values[left]
```

Natija:

```text
[4 2 3 1]
```

Keyin:

```text
left = 1
right = 2
```

bo‘ladi.

Yana almashadi:

```text
[4 3 2 1]
```

Keyin indekslar uchrashadi va:

```go
left < right
```

sharti bajarilmaydi.

Funksiya elementlar ustida:

* arifmetik amal;
* tenglik tekshiruvi;
* tartib solishtiruvi

bajarmaydi.

Faqat elementlarning o‘rnini almashtiradi.

Shuning uchun:

```go
T any
```

yetarli.

Funksiya yangi slice qaytarmaydi.

U berilgan slice elementlarini joyida o‘zgartiradi.

### 4. Takrorlangan qiymatlarni olib tashlash

Bu misol `comparable` constraintining yana bir muhim qo‘llanishini ko‘rsatadi.

Qiymatlar map kaliti sifatida ishlatiladi.

```go
package main

import "fmt"

func unique[T comparable](values []T) []T {
	seen := make(map[T]bool)
	result := make([]T, 0, len(values))

	for _, value := range values {
		if !seen[value] {
			seen[value] = true
			result = append(result, value)
		}
	}

	return result
}

func main() {
	fmt.Println(unique([]int{2, 2, 3, 2, 4, 3}))
	fmt.Println(unique([]string{"go", "api", "go"}))
}
```

`seen` map:

```go
seen := make(map[T]bool)
```

allaqachon uchragan qiymatlarni saqlaydi.

Map kaliti `T` turida.

Go map kalitlari `comparable` bo‘lishi kerak.

Shuning uchun funksiya:

```go
T comparable
```

constraintidan foydalanadi.

Jarayonni birinchi slice uchun ko‘ramiz:

```text
[2, 2, 3, 2, 4, 3]
```

Birinchi `2`:

```go
seen[2]
```

hali `false`.

Shuning uchun:

```go
seen[2] = true
```

qilinadi va `2` natijaga qo‘shiladi.

Natija:

```text
[2]
```

Keyingi `2` kelganda:

```go
seen[2] == true
```

bo‘ladi.

Shuning uchun u qayta qo‘shilmaydi.

`3` birinchi marta kelganda natijaga qo‘shiladi:

```text
[2 3]
```

`4` ham qo‘shiladi:

```text
[2 3 4]
```

Oxirgi `3` esa avval uchragani uchun tashlab ketiladi.

`result` quyidagicha yaratilgan:

```go
result := make([]T, 0, len(values))
```

Bu yerda uzunlik:

```text
0
```

Chunki boshida hali hech qanday noyob element qo‘shilmagan.

Capacity esa:

```go
len(values)
```

qilib olinadi.

Sababi eng yomon holatda barcha elementlar noyob bo‘lishi mumkin.

Masalan:

```text
[1 2 3 4]
```

uchun natija ham 4 ta elementdan iborat bo‘ladi.

### 5. Ikki qiymatdan kichigini tanlash

Bu misolda generic constraint faqat ma’lum son turlarini qabul qiladi.

Funksiya ichida `<` operatori ishlatiladi.

```go
package main

import "fmt"

type OrderedNumber interface {
	~int | ~int64 | ~float64
}

func min[T OrderedNumber](a, b T) T {
	if a < b {
		return a
	}
	return b
}

func main() {
	fmt.Println(min(8, 3))
	fmt.Println(min(4.5, 7.2))
}
```

Constraint:

```go
type OrderedNumber interface {
	~int | ~int64 | ~float64
}
```

deb yozilgan.

Bu turlarning barchasi `<` operatorini qo‘llab-quvvatlaydi.

Shuning uchun generic funksiya ichida:

```go
if a < b
```

yozish mumkin.

Birinchi chaqiruv:

```go
min(8, 3)
```

uchun kompilyator:

```text
T = int
```

ekanini aniqlaydi.

Tekshiruv:

```text
8 < 3 -> false
```

Shuning uchun:

```text
3
```

qaytadi.

Ikkinchi chaqiruv:

```go
min(4.5, 7.2)
```

uchun:

```text
T = float64
```

Tekshiruv:

```text
4.5 < 7.2 -> true
```

Natija:

```text
4.5
```

Bu yerda ikkala argument ham bir xil `T` turida.

Natija ham aynan `T`.

Shuning uchun tur bog‘lanishi saqlanadi.

`comparable` bu funksiya uchun yetarli bo‘lmas edi. Sababi `comparable` faqat `==` va `!=` imkoniyatini kafolatlaydi, `<`ni emas.

### 6. Nomlangan son turini jamlash

Bu misol constraintdagi `~` belgisi nima uchun kerakligini ko‘rsatadi.

```go
package main

import "fmt"

type Addable interface {
	~int | ~float64
}

type Distance int

func sum[T Addable](values []T) T {
	var total T
	for _, value := range values {
		total += value
	}
	return total
}

func main() {
	distances := []Distance{12, 8, 15}
	prices := []float64{10.5, 4.25}

	fmt.Println(sum(distances))
	fmt.Println(sum(prices))
}
```

Bu yerda:

```go
type Distance int
```

yangi nomlangan tur yaratilgan.

`Distance` aynan `int` emas.

Lekin uning underlying type’i `int`.

Constraintda:

```go
~int
```

yozilgan.

Shuning uchun `Distance` ham `Addable` constraintiga mos keladi.

Agar constraint:

```go
type Addable interface {
	int | float64
}
```

ko‘rinishida bo‘lganida, `Distance` mos kelmas edi.

`sum()` ichida:

```go
var total T
```

yozilgan.

Agar:

```text
T = Distance
```

bo‘lsa, `total` `Distance` turning zero value qiymatini oladi.

`Distance` underlying type’i `int` bo‘lgani uchun zero value:

```text
0
```

bo‘ladi.

Keyin qiymatlar ketma-ket qo‘shiladi:

```text
0 + 12 = 12
12 + 8 = 20
20 + 15 = 35
```

Natija:

```text
35
```

`prices` uchun:

```text
0 + 10.5 = 10.5
10.5 + 4.25 = 14.75
```

Natija:

```text
14.75
```

Jamlashni `0` dan boshlash to‘g‘ri, chunki `0` qo‘shish natijani o‘zgartirmaydi.

### 7. Slice elementlarini boshqa turga aylantirish

Bu misol ikki xil tur parametri bir funksiyada qanday ishlashini ko‘rsatadi.

Kirish elementi bir turda, natija esa boshqa turda bo‘lishi mumkin.

```go
package main

import "fmt"

func transform[T any, R any](values []T, convert func(T) R) []R {
	result := make([]R, 0, len(values))
	for _, value := range values {
		result = append(result, convert(value))
	}
	return result
}

func main() {
	numbers := []int{3, 5, 8}
	labels := transform(numbers, func(value int) string {
		return fmt.Sprintf("son=%d", value)
	})

	fmt.Println(labels)
}
```

Funksiya ikkita tur parametri qabul qiladi:

```go
[T any, R any]
```

`T` — kiruvchi element turi.

`R` — natija elementi turi.

Bizning misolda:

```go
numbers := []int{3, 5, 8}
```

berilgan.

Shuning uchun:

```text
T = int
```

`convert` funksiyasi:

```go
func(value int) string
```

ko‘rinishida.

Demak:

```text
R = string
```

bo‘ladi.

Shuning uchun `transform()` amalda:

```text
[]int -> []string
```

o‘zgartirishni bajaradi.

Jarayon:

```text
3 -> "son=3"
5 -> "son=5"
8 -> "son=8"
```

Natija:

```text
[son=3 son=5 son=8]
```

Natija slice:

```go
result := make([]R, 0, len(values))
```

bilan yaratiladi.

Uzunligi boshida `0`, chunki hali natija yo‘q.

Capacity esa kiruvchi slice uzunligiga teng.

Sababi har bir kiruvchi element uchun bittadan natija yaratiladi.

Masalan, `values`da 3 ta element bo‘lsa, yakuniy `result`da ham 3 ta element bo‘ladi.

Bu pattern ko‘pincha boshqa tillarda `map` yoki `transform` deb ataladigan operatsiyaga o‘xshaydi.

### 8. Shartga mos elementlarni saralab olish

Bu misolda generic funksiya elementlarni o‘zi tekshirmaydi.

Tekshirish qoidasi alohida funksiya orqali beriladi.

```go
package main

import "fmt"

func filter[T any](values []T, keep func(T) bool) []T {
	result := make([]T, 0, len(values))
	for _, value := range values {
		if keep(value) {
			result = append(result, value)
		}
	}
	return result
}

func main() {
	even := filter([]int{1, 2, 3, 4, 5, 6}, func(value int) bool {
		return value%2 == 0
	})
	long := filter([]string{"Go", "kod", "generics"}, func(value string) bool {
		return len(value) >= 3
	})

	fmt.Println(even)
	fmt.Println(long)
}
```

`filter()`ning o‘zi `T` qiymati haqida hech qanday maxsus bilimga ega emas.

U faqat:

```go
keep(value)
```

natijasiga qaraydi.

Agar `true` qaytsa:

```go
result = append(result, value)
```

orqali element natijaga qo‘shiladi.

Agar `false` qaytsa, element tashlab ketiladi.

Birinchi misolda:

```go
value%2 == 0
```

juft sonlarni aniqlaydi.

Qiymatlar:

```text
1 -> false
2 -> true
3 -> false
4 -> true
5 -> false
6 -> true
```

Natija:

```text
[2 4 6]
```

Ikkinchi misolda:

```go
len(value) >= 3
```

string uzunligini tekshiradi.

Qiymatlar:

```text
"Go"       -> 2 -> false
"kod"      -> 3 -> true
"generics" -> 8 -> true
```

Natija:

```text
[kod generics]
```

Bu yerda:

```go
>= 3
```

ishlatilganiga e’tibor bering.

Demak, uzunligi aynan `3` bo‘lgan qiymat ham olinadi.

Agar:

```go
> 3
```

yozilganida `"kod"` natijaga kirmagan bo‘lardi.

`filter()`ning o‘zida turga xos operator ishlatilmagani uchun:

```go
T any
```

yetarli.

### 9. Ikki xil turdagi qiymatni bitta structda saqlash

Generic type’da bir nechta tur parametri ham bo‘lishi mumkin.

Bu misolda `Pair` ikkita turli qiymatni birga saqlaydi.

```go
package main

import "fmt"

type Pair[K any, V any] struct {
	Key   K
	Value V
}

func main() {
	stock := Pair[string, int]{Key: "daftar", Value: 25}
	point := Pair[int, float64]{Key: 7, Value: 18.5}

	fmt.Println(stock.Key, stock.Value)
	fmt.Println(point.Key, point.Value)
}
```

Struct e’loni:

```go
type Pair[K any, V any] struct
```

ikkita mustaqil tur parametriga ega.

`K` va `V` bir xil tur bo‘lishi shart emas.

Birinchi qiymat:

```go
Pair[string, int]
```

uchun:

```text
K = string
V = int
```

Shuning uchun:

```go
Key string
Value int
```

kabi ishlaydi.

Ikkinchi qiymat:

```go
Pair[int, float64]
```

uchun:

```text
K = int
V = float64
```

bo‘ladi.

Bu safar struct amalda:

```go
Key   int
Value float64
```

maydonlariga ega bo‘ladi.

Struct ichida qiymatlar ustida:

* tenglik;
* arifmetik;
* tartib

amallari bajarilmaydi.

Shuning uchun ikkala tur parametri uchun ham:

```go
any
```

yetarli.

Bu generic type bir xil ma’lumot tuzilmasini turli tur kombinatsiyalari bilan qayta ishlatish mumkinligini ko‘rsatadi.

### 10. Generic navbat yaratish

Bu misolda generic `Queue` yaratiladi.

Queue FIFO tamoyili bo‘yicha ishlaydi:

```text
First In, First Out
```

Ya’ni birinchi qo‘shilgan element birinchi bo‘lib olinadi.

```go
package main

import "fmt"

type Queue[T any] struct {
	items []T
}

func (q *Queue[T]) Add(value T) {
	q.items = append(q.items, value)
}

func (q *Queue[T]) Remove() (T, bool) {
	if len(q.items) == 0 {
		var zero T
		return zero, false
	}

	value := q.items[0]
	q.items = q.items[1:]
	return value, true
}

func main() {
	var queue Queue[string]
	queue.Add("birinchi")
	queue.Add("ikkinchi")

	first, firstOK := queue.Remove()
	second, secondOK := queue.Remove()
	emptyValue, emptyOK := queue.Remove()

	fmt.Println(first, firstOK)
	fmt.Println(second, secondOK)
	fmt.Printf("%q %t\n", emptyValue, emptyOK)
}
```

Queue quyidagicha yaratilgan:

```go
type Queue[T any] struct {
	items []T
}
```

`T` navbat ichida saqlanadigan element turini bildiradi.

Bizda:

```go
var queue Queue[string]
```

deb yozilgan.

Demak:

```text
T = string
```

### Element qo‘shish

```go
func (q *Queue[T]) Add(value T) {
	q.items = append(q.items, value)
}
```

`Add()` yangi elementni slice oxiriga qo‘shadi.

Avval:

```go
queue.Add("birinchi")
```

Natija:

```text
["birinchi"]
```

Keyin:

```go
queue.Add("ikkinchi")
```

Natija:

```text
["birinchi", "ikkinchi"]
```

### Elementni olish

Queue’da eng eski element olinishi kerak.

Eng eski element slice boshida, ya’ni `0`-indeksda turadi:

```go
value := q.items[0]
```

Birinchi `Remove()`:

```text
value = "birinchi"
```

Keyin:

```go
q.items = q.items[1:]
```

bajariladi.

Bu slice’ning `0`-indeksdagi elementini yangi ko‘rinishdan chiqarib tashlaydi.

Natijada:

```text
["ikkinchi"]
```

qoladi.

Ikkinchi `Remove()`:

```text
value = "ikkinchi"
```

bo‘ladi.

Keyin queue bo‘shaydi.

### Bo‘sh queue holati

Uchinchi marta:

```go
queue.Remove()
```

chaqirilganda:

```go
len(q.items) == 0
```

bo‘ladi.

Shuning uchun:

```go
var zero T
return zero, false
```

ishlaydi.

Bu yerda:

```text
T = string
```

Shuning uchun `string`ning zero value qiymati:

```text
""
```

bo‘ladi.

Natija:

```text
"" false
```

`false` queue ichida element yo‘qligini bildiradi.

Bu misolda bir nechta generics qoidasi bir vaqtda ko‘rinadi:

* generic type;
* generic type metodi;
* receiverda `Queue[T]` yozilishi;
* `T`ning zero value qiymatini olish;
* `T any` orqali element turini erkin tanlash;
* `Queue[string]` yaratilgandan keyin metodlar faqat `string` bilan ishlashi.

## Generic kodni testlash

Generic funksiya bir nechta tur bilan ishlashi mumkin. Shu sabab testda kerakli tur variantlarini alohida tekshirish foydali.

```go
package main

import "testing"

type Number interface {
	~int | ~float64
}

func max[T Number](a, b T) T {
	if a > b {
		return a
	}

	return b
}

func TestMax(t *testing.T) {
	t.Run("int", func(t *testing.T) {
		if got := max(4, 9); got != 9 {
			t.Errorf("max(4, 9) = %d; 9 kutilgan", got)
		}
	})

	t.Run("float64", func(t *testing.T) {
		if got := max(7.5, 2.5); got != 7.5 {
			t.Errorf("max(7.5, 2.5) = %g; 7.5 kutilgan", got)
		}
	})
}
```

Ikki subtest bir xil generic funksiyani `int` va `float64` qiymatlar bilan tekshiradi. Kompilyator har bir chaqiruvdagi argumentlardan `T` turini aniqlaydi. Testlarni odatdagidek quyidagi buyruq bilan ishga tushirish mumkin:

```bash
go test ./...
```
