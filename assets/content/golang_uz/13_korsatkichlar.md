# Ko'rsatkichlar (pointers)

Ko'rsatkich (pointer) o'zgaruvchining xotiradagi manziliga murojaat qilish imkonini beradi. U bitta qiymatni turli 
joydan o'zgartirish, katta tuzilmani nusxalamasdan uzatish imkonini beradi.

## `&` va `*` operatorlari

- `&x` — `x` o'zgaruvchisining manzilini oladi.
- `*p` — `p` murojaat qilayotgan qiymatni o'qish yoki o'zgartirish imkonini beradi.
- `*int` — `int` turidagi qiymatga ko'rsatkich turini bildiradi.

```go
package main

import "fmt"

func main() {
	x := 10
	p := &x

	fmt.Println("Qiymat:", x)
	fmt.Println("Ko'rsatkich orqali:", *p)
	*p = 20
	fmt.Println("Yangi qiymat:", x)
}
```

Natija:

```text
Qiymat: 10
Ko'rsatkich orqali: 10
Yangi qiymat: 20
```

`p`ning turi `*int`. `*p = 20` yangi ko'rsatkich yaratmaydi. Bu amal `p` murojaat qilayotgan `x` qiymatini o'zgartiradi. 
Manzilni `&p` bilan chiqarish mumkin, ammo uning aniq qiymati dastur har ishga tushirilganda o'zgarishi mumkin. Dastur 
mantig'ini bu manzilga bog'lamaslik kerak.

## Ko'rsatkich orqali qiymatni o'zgartirish

Oddiy o'zgaruvchiga yangi qiymat berilganda faqat o'sha o'zgaruvchining qiymati o'zgaradi:

```go
package main

import "fmt"

func main() {
	son := 10
	nusxa := son

	nusxa++

	fmt.Println("son:", son)
	fmt.Println("nusxa:", nusxa)
}
```

Natija:

```text
son: 10
nusxa: 11
```

`nusxa := son` yozilganda `son`ning qiymati boshqa o'zgaruvchiga nusxalanadi. Shundan keyin `nusxa` va `son` ikkita 
alohida o'zgaruvchi hisoblanadi. `nusxa`ni o'zgartirish `son`ga ta'sir qilmaydi.

Ko'rsatkich bilan esa boshqa o'zgaruvchining o'ziga murojaat qilish mumkin:

```go
package main

import "fmt"

func main() {
	son := 10
	p := &son

	*p++

	fmt.Println(son)
}
```

Natija:

```text
11
```

`p := &son` yozuvi `son` o'zgaruvchisining manzilini `p`ga saqlaydi. `*p` esa shu manzilda turgan qiymatga murojaat
qiladi.

Shuning uchun:

```go
*p++
```

yozuvi:

```go
(*p)++
```

bilan bir xil ma'noni anglatadi. Ya'ni `p` murojaat qilayotgan qiymat bittaga oshiriladi.

Bu yerda muhim farq bor:

```go
son := 10
nusxa := son
```

qiymatni nusxalaydi.

Quyidagi kod esa:

```go
son := 10
p := &son
```

`son`ning o'ziga murojaat qilish imkonini beradi.

Ko'rsatkich har doim ham kerak emas. Agar ikkita mustaqil qiymat kerak bo'lsa, oddiy nusxa tushunarliroq. Ko'rsatkich 
bir xil qiymatni boshqa joydan ko'rish yoki o'zgartirish zarur bo'lganda foydali bo'ladi, bu bilan ortiqcha xotira 
ajratilmaydi.

## Ko'rsatkich va qiymatning yashash muddati

Ko'rsatkich mavjud ekan, u murojaat qilayotgan qiymat ham yaroqli bo'lishi kerak.

Masalan:

```go
package main

import "fmt"

func main() {
	var p *int

	{
		son := 13
		p = &son
	}

	fmt.Println(*p)
}
```

Natija:

```text
13
```

`son` ichki blok ichida yaratilgan bo'lsa ham, uning manzili `p` orqali tashqarida ishlatilmoqda.

Go kompilyatori qiymat qancha vaqt saqlanishi kerakligini aniqlaydi. Zarur bo'lsa, qiymatning yashash muddati undan 
foydalanayotgan ko'rsatkichga mos ravishda boshqariladi.

Dasturchi bunday xotirani C tilidagidek qo'lda bo'shatmaydi. Go xotirani avtomatik boshqaradi.

Bu xususiyat:

```go
p = &son
```

kabi kodni xavfsiz ishlatish imkonini beradi.

## Ko'rsatkichlarning tengligi

Ikki ko'rsatkich bir xil o'zgaruvchiga murojaat qilsa, ular teng bo'ladi:

```go
package main

import "fmt"

func main() {
	x := 5

	p1 := &x
	p2 := &x

	y := 5
	p3 := &y

	fmt.Println(p1 == p2)
	fmt.Println(p1 == p3)
}
```

Natija:

```text
true
false
```

`p1` va `p2` bir xil `x` o'zgaruvchisining manzilini saqlaydi. Shu sabab:

```go
p1 == p2
```

natijasi `true`.

`x` va `y`ning qiymatlari bir xil:

```go
x == y
```

lekin ular xotirada ikkita alohida o'zgaruvchi.

Shuning uchun:

```go
p1 == p3
```

natijasi `false`.

Bu yerda ko'rsatkichlarning tengligi ular murojaat qilayotgan **qiymatlarning tengligini emas**, balki bir xil joyga 
murojaat qilayotganini bildiradi.

Ko'rsatkichni mos turdagi boshqa ko'rsatkich yoki `nil` bilan taqqoslash mumkin.

## `nil` ko'rsatkich

Ko'rsatkichning nol qiymati `nil`.

Masalan:

```go
package main

import "fmt"

func main() {
	var p *int

	fmt.Println(p)
	fmt.Println(p == nil)
}
```

Natija:

```text
<nil>
true
```

Quyidagi qism:

```go
var p *int
```

`p`ni `*int` turidagi ko'rsatkich sifatida e'lon qiladi, ammo unga hali hech qanday `int` o'zgaruvchisining manzili berilmagan.

Shuning uchun uning qiymati:

```go
nil
```

bo'ladi.

Keyinchalik unga yaroqli manzil berish mumkin:

```go
package main

import "fmt"

func main() {
	var p *int

	son := 13
	p = &son

	fmt.Println(p == nil)
	fmt.Println(*p)
}
```

Natija:

```text
false
13
```

`nil` ko'rsatkich orqali qiymatga murojaat qilish mumkin emas.

Masalan:

```go
var p *int
fmt.Println(*p)
```

dastur ishlayotgan vaqtda `panic` keltirib chiqaradi.

```shell
panic: runtime error: invalid memory address or nil pointer dereference
[signal 0xc0000005 code=0x0 addr=0x0 pc=0x7ff781d44b96]
```

Shu sabab ko'rsatkich `nil` bo'lishi mumkin bo'lgan holatda avval uni tekshirish kerak:

```go
if p != nil {
    fmt.Println(*p)
}
```

`nil` ko'rsatkich "hozircha hech qanday qiymatga murojaat qilmayapman" degan holatni ifodalash imkonini beradi.

## `new` orqali ko'rsatkich yaratish

`new(T)` `T` turining nol qiymatiga ega yangi o'zgaruvchi yaratib, unga `*T` turidagi ko'rsatkich beradi.

Masalan:

```go
package main

import "fmt"

func main() {
	p := new(int)

	fmt.Println(*p)

	*p = 13

	fmt.Println(*p)
}
```

Natija:

```text
0
13
```

`int` turining nol qiymati `0` bo'ladi.

Shuning uchun:

```go
p := new(int)
```

yozilganidan keyin:

```go
*p
```

qiymati `0` bo'ladi.

Keyin:

```go
*p = 13
```

orqali shu qiymat o'zgartirildi.

`new`ning natijasi oddiy qiymat emas, ko'rsatkich:

```go
p := new(int)
```

bu yerda `p`ning turi:

```go
*int
```

Ko'pincha oddiy lokal o'zgaruvchi yaratib, uning manzilini olish tushunarliroq:

```go
x := 0
p := &x
```

Bu kod:

```go
p := new(int)
```

bilan o'xshash natija beradi.

`new` va `make` bir xil vazifani bajarmaydi.

`new(T)`:

```text
*T
```

turidagi ko'rsatkich beradi.

`make` esa faqat:

* slice;
* map;
* channel

uchun ishlatiladi va foydalanishga tayyor qiymat yaratadi.

## Goda pointer arifmetikasi yo'q

C va C++ kabi ayrim tillarda ko'rsatkich manzilini arifmetik amallar yordamida o'zgartirish mumkin.

Masalan, Goda odatiy ko'rsatkich bilan quyidagilarni yozib bo'lmaydi:

```go
p++
```

yoki:

```go
p + 1
```

Go odatiy kodda pointer arifmetikasiga ruxsat bermaydi.

Bu cheklov xotira manzillari bilan noto'g'ri ishlash natijasida yuzaga kelishi mumkin bo'lgan ayrim xatolarning oldini 
oladi.

Past darajadagi maxsus vazifalar uchun Go'da `unsafe` paketi mavjud. Ammo kundalik dasturlarda undan foydalanish kerak 
emas.

Ko'rsatkich ishlatilgani qiymat albatta `heap` xotirada saqlanadi degani ham emas.

Go kompilyatori **escape analysis** orqali qiymat qayerda saqlanishini aniqlaydi. Qiymat vaziyatga qarab stackda qolishi 
yoki `heap`ga joylashtirilishi mumkin.

Shuning uchun:

> "Pointer ishlatsam, kod albatta tezroq ishlaydi"

degan fikr to'g'ri emas.

Ko'rsatkichni tanlashda birinchi navbatda muamo hisobga olinadi. Ishlash tezligi muhim bo'lgan joyda esa taxmin qilish 
o'rniga o'lchash to'g'ri bo'ladi.

## Slice, map va ko'rsatkich

Slice oddiy massivning o'zi emas. U asosiy massivdagi ma'lumotlarga murojaat qiluvchi tavsifni saqlaydi.

Masalan:

```go
package main

import "fmt"

func main() {
	sonlar := []int{10, 20, 30}
	boshqa := sonlar

	boshqa[0] = 100

	fmt.Println(sonlar)
	fmt.Println(boshqa)
}
```

Natija:

```text
[100 20 30]
[100 20 30]
```

`boshqa := sonlar` yozilganda slice tavsifi nusxalanadi. Ammo ikkala `slice` ham bir xil asosiy massivdagi elementlarga 
murojaat qiladi.

Shuning uchun:

```go
boshqa[0] = 100
```

o'zgarishi `sonlar` orqali ham ko'rinadi. Shu sababli `slice` elementlarini o'zgartirish uchun odatda `*[]int` kabi 
`slice` ko'rsatkichi kerak emas.

`map`da ham shunga o'xshash holat mavjud:

```go
package main

import "fmt"

func main() {
	lugat := map[string]int{
		"go": 2009,
	}

	boshqa := lugat
	boshqa["python"] = 1991

	fmt.Println(lugat)
}
```

`lugat` va `boshqa` bir xil map ma'lumotlariga murojaat qiladi. Shuning uchun `boshqa` orqali qo'shilgan element `lugat` 
orqali ham ko'rinadi.

Slice bilan `append` ishlatilganda esa alohida jihat bor:

```go
package main

import "fmt"

func main() {
	sonlar := []int{10, 20, 30}

	sonlar = append(sonlar, 40)

	fmt.Println(sonlar)
}
```

`append` natijasida yangi slice qiymati olinadi. Yetarli sig'im bo'lmasa, Go yangi asosiy massiv ham ajratishi mumkin.

Shu sabab slice bilan ishlashda uning yangi holatini:

```go
sonlar = append(sonlar, 40)
```

ko'rinishida saqlab olish odatiy usul hisoblanadi.

`slice` yoki `map`ning o'z imkoniyatlari yetarli bo'lgan joyda ularga qo'shimcha ko'rsatkich ishlatish kodni keraksiz 
murakkablashtirishi mumkin.

## Qachon ko'rsatkich ishlatmaslik kerak?

Ko'rsatkich imkoniyat beradi, ammo har bir qiymat uchun undan foydalanish shart emas.

Quyidagi holatlarda oddiy qiymat yetarli bo'lishi mumkin:

* qiymat kichik va uni nusxalash arzon bo'lsa.
* ikkita mustaqil qiymat kerak bo'lsa.
* asl qiymatni boshqa joydan o'zgartirish zarur bo'lmasa.
* `nil` holati kodga keraksiz murakkablik olib kirsa.
* `slice`, `map` yoki `channel`ning o'z xususiyati kerakli murojaat semantikasini bersa.

Masalan:

```go
x := 10
y := x
```

agar `x` va `y` mustaqil o'zgarishi kerak bo'lsa, kerakli usul.

Ammo:

```go
x := 10
p := &x
```

yozilganda `p` orqali `x`ning o'zini o'zgartirish mumkin.

Har bir o'zgaruvchini ko'rsatkichga aylantirish kodni avtomatik ravishda tezlashtirmaydi. Aksincha, bir xil qiymat bir 
nechta joydan o'zgartirilishi mumkin bo'lsa, ma'lumot qayerda o'zgarganini kuzatish qiyinlashadi. Shuning uchun 
ko'rsatkichni shunchaki "pointer ishlatish yaxshi" degan fikr bilan emas, uning imkoniyati kerak bo'lganda ishlatish 
kerak.

## Misollar

### 1. Ikki qiymatni pointer orqali almashtirish

```go
package main

import "fmt"

func main() {
	x, y := 10, 20

	px := &x
	py := &y

	*px, *py = *py, *px

	fmt.Println(x, y)
}
```

Natija:

```text
20 10
```

`px` `x`ga, `py` esa `y`ga murojaat qiladi.

Quyidagi yozuv:

```go
*px, *py = *py, *px
```

ko'rsatkichlar murojaat qilayotgan ikkita qiymatni o'zaro almashtiradi.

Ko'rsatkichlarning o'zi almashtirilmaydi. O'zgarayotgan narsa ular murojaat qilayotgan `x` va `y` qiymatlaridir.

### 2. Ikki natijani ko'rsatkichlar orqali saqlash

```go
package main

import "fmt"

func main() {
	a, b := 17, 5

	var bolinma int
	var qoldiq int

	pBolinma := &bolinma
	pQoldiq := &qoldiq

	*pBolinma = a / b
	*pQoldiq = a % b

	fmt.Println(bolinma, qoldiq)
}
```

Natija:

```text
3 2
```

`pBolinma` va `pQoldiq` ikkita alohida o'zgaruvchiga murojaat qiladi.

```go
*pBolinma = a / b
```

`bolinma`ning qiymatini o'zgartiradi.

```go
*pQoldiq = a % b
```

esa `qoldiq`ning qiymatini o'zgartiradi.

Bu misol bir nechta ko'rsatkich turli qiymatlarga murojaat qilib, ularni alohida o'zgartira olishini ko'rsatadi.

### 3. Ixtiyoriy qiymatni `nil` bilan ifodalash

Ba'zan `0` qiymati va "qiymat umuman belgilanmagan" holatini bir-biridan ajratish kerak bo'lishi mumkin.

```go
package main

import "fmt"

func main() {
	var chegirma *int

	if chegirma == nil {
		fmt.Println("Chegirma belgilanmagan")
	}

	nol := 0
	chegirma = &nol

	if chegirma != nil {
		fmt.Println("Chegirma:", *chegirma)
	}
}
```

Natija:

```text
Chegirma belgilanmagan
Chegirma: 0
```

Birinchi holatda:

```go
chegirma == nil
```

ya'ni chegirma qiymati umuman belgilanmagan.

Ikkinchi holatda esa ko'rsatkich mavjud va u `0` qiymatiga murojaat qilmoqda.

Demak:

```text
nil
```

va:

```text
0
```

bir xil holat emas.

Ko'rsatkich "qiymat yo'q" va "qiymat bor, uning qiymati nol" holatlarini bir-biridan ajratish imkonini beradi.

### 4. `new` bilan turli qiymatlar yaratish

```go
package main

import "fmt"

func main() {
	faol := new(bool)
	nom := new(string)

	fmt.Println(*faol)
	fmt.Println(*nom)

	*faol = true
	*nom = "Go"

	fmt.Println(*faol, *nom)
}
```

Dastlab:

```go
new(bool)
```

`false` qiymatiga ega `bool` uchun ko'rsatkich yaratadi.

```go
new(string)
```

esa bo'sh satr qiymatiga ega `string` uchun ko'rsatkich yaratadi.

Keyin:

```go
*faol = true
*nom = "Go"
```

orqali ko'rsatkichlar murojaat qilayotgan qiymatlar o'zgartiriladi.

### 5. Pointer nusxasi bir xil qiymatga qaraydi

```go
package main

import "fmt"

func main() {
	son := 5

	birinchi := &son
	ikkinchi := birinchi

	*ikkinchi = 25

	fmt.Println(*birinchi, son)
}
```

Natija:

```text
25 25
```

Quyidagi yozuv:

```go
ikkinchi := birinchi
```

`son`ning qiymatini nusxalamaydi.

Bu yerda ko'rsatkichning qiymati, ya'ni manzil nusxalanadi.

Natijada:

```go
birinchi
```

va:

```go
ikkinchi
```

bir xil `son` o'zgaruvchisiga murojaat qiladi.

Shuning uchun:

```go
*ikkinchi = 25
```

yozilgandan keyin `*birinchi` orqali ham `25` ko'rinadi.

### 6. Pointerlar bir obyektga qarashini tekshirish

```go
package main

import "fmt"

func main() {
	son := 13

	a := &son
	b := a

	c := new(int)
	*c = 13

	fmt.Println(a == b)
	fmt.Println(a == c)
}
```

Natija:

```text
true
false
```

`a` va `b` bir xil `son` o'zgaruvchisiga murojaat qiladi.

Shuning uchun:

```go
a == b
```

natijasi `true`.

`c` ham `13` qiymatiga murojaat qiladi, ammo bu boshqa o'zgaruvchi.

Shuning uchun:

```go
a == c
```

natijasi `false`.

Pointerlarning tengligi ular murojaat qilayotgan qiymatlar tengligini emas, bir xil obyektga murojaat qilayotganini 
tekshiradi.

### 7. Slice elementiga pointer olish

```go
package main

import "fmt"

func main() {
	sonlar := []int{10, 20, 30}

	p := &sonlar[1]

	*p = 99

	fmt.Println(sonlar)
}
```

Natija:

```text
[10 99 30]
```

Quyidagi yozuv:

```go
p := &sonlar[1]
```

slice ichidagi ikkinchi elementning manzilini oladi.

Keyin:

```go
*p = 99
```

shu elementning asl qiymatini o'zgartiradi.

Shuning uchun o'zgarish `sonlar` slice'ida ham ko'rinadi.

Bu yerda muhim jihat bor. Keyinchalik `append` ishlatilganda slice uchun yangi asosiy massiv ajratilishi mumkin:

```go
sonlar = append(sonlar, 40, 50, 60)
```

Agar yangi massiv yaratilsa, `sonlar` yangi massivga murojaat qila boshlaydi. Oldin olingan `p` esa avvalgi massivdagi 
elementga murojaat qilishda davom etishi mumkin.

Shuning uchun slice elementlariga uzoq muddat saqlanadigan ko'rsatkich olishda uning keyinchalik qanday o'zgarishini 
ham hisobga olish kerak.

### 8. Bog'langan ro'yxat tuguni

Ko'rsatkichlar yordamida bir obyekt boshqasiga murojaat qiladigan ma'lumot tuzilmalarini yaratish mumkin.

Masalan:

```go
package main

import "fmt"

type Tugun struct {
	Qiymat  int
	Keyingi *Tugun
}

func main() {
	uchinchi := &Tugun{
		Qiymat: 30,
	}

	ikkinchi := &Tugun{
		Qiymat:  20,
		Keyingi: uchinchi,
	}

	birinchi := &Tugun{
		Qiymat:  10,
		Keyingi: ikkinchi,
	}

	fmt.Println(birinchi.Qiymat)
	fmt.Println(birinchi.Keyingi.Qiymat)
	fmt.Println(birinchi.Keyingi.Keyingi.Qiymat)
	fmt.Println(birinchi.Keyingi.Keyingi.Keyingi)
}
```

Natija:

```text
10
20
30
<nil>
```

Har bir `Tugun` o'z qiymatidan tashqari keyingi tugunga ko'rsatkich saqlaydi:

```go
Keyingi *Tugun
```

`birinchi.Keyingi` `ikkinchi` tugunga murojaat qiladi.

`ikkinchi.Keyingi` esa `uchinchi` tugunga murojaat qiladi.

`uchinchi` tugunda `Keyingi` qiymati berilmagan. `*Tugun` ko'rsatkichining nol qiymati `nil` bo'lgani uchun:

```go
uchinchi.Keyingi
```

qiymati `nil`.

Shu tarzda bir obyekt boshqasiga ko'rsatkich orqali ulanadi. Bog'langan ro'yxat kabi ma'lumot tuzilmalarining asosiy 
g'oyalaridan biri ham shundan iborat.
