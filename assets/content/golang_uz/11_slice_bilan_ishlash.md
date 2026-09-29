# Goda slice bilan ishlash

**Slice** bir xil turdagi elementlar bilan ishlash uchun mo'ljallangan ma'lumot turi. Massivdan farqi slice uzunligini 
kerak bo'lganda oshirish yoki kamaytirish mumkin. Shu sabab elementlar soni oldindan noma'lum bo'lgan holatlarda ko'p
ishlatiladi. Masalan, APIdan olingan natija, fayldan o'qilgan satrlar yoki bazadan olingan ma'lumotlarni `slice`da 
saqlash qulay.

Slice elementlarni o'zida saqlaydigan alohida tur emas. Elementlar xotiradagi asosiy massivda (array)
turadi. Slice esa shu massivning ma'lum qismiga murojaat qiladi. U qayerdan boshlanishi, nechta elementi bo'lishi va
yana qancha joydan foydalanishi mumkinligi haqidagi ma'lumotlarni saqlaydi.

- `len` - ayni payda `slice`da mavjud elementlar soni.
- `cap` - `slice` boshlangan joydan asosiy massiv oxirigacha foydalanish mumkin bo'lgan joy.

## Slice yaratish

Slice turi `[]elementTuri` ko'rinishida yoziladi. Kvadrat qavs ichida son yozilmaydi. Masalan, `[]int` - `int`
elementlaridan iborat `slice`, `[3]int` esa uchta elementli massiv hisoblanadi.

```go
package main

import "fmt"

func main() {
	var bosh []int
	mevalar := []string{"olma", "anor", "uzum"}
	sonlar := make([]int, 3, 5)

	fmt.Println(bosh, len(bosh), cap(bosh), bosh == nil)
	fmt.Println(mevalar)
	fmt.Println(sonlar, len(sonlar), cap(sonlar))
}
```

**Natija:**

```text
[] 0 0 true
[olma anor uzum]
[0 0 0] 3 5
```

`Slice`ni uch xil usulda yaratish mumkin:

- `var bosh []int` - hali asosiy massivga bog'lanmagan `nil` slice;
- `[]string{"olma", "anor", "uzum"}` - qiymatlari bilan e'lon qilingan slice;
- `make([]int, 3, 5)` - uzunligi `3`, sig'imi `5` bo'lgan slice.

`nil` slice bo'sh bo'ladi. U bilan `slice`ning `len`, `cap`, `range` va `append` kabi funksiyalaridan xavfsiz
foydalanish mumkin. `make` bilan yaratilgan `sonlar` `slice`ining uchta elementi esa dastlab `int` turining nol qiymati 
`0` bilan to'ldiriladi.

> **Ma'lumot**
>
> `nil` slice va `[]int{}` ikkalasi ham bo'sh, ya'ni uzunligi `0`. Ularni `nil` bilan taqqoslash mumkin, ammo faqat
> birinchisi `nil`ga teng bo'ladi. Masalan, ular JSON formatiga o'tkazilganda biri `null`, ikkinchisi esa `[]`
> ko'rinishida chiqadi.

## slice qismini olish

`Slice`dan ma'lum oraliqni olish uchun kesish ifodasi ishlatiladi. `s[boshi:oxiri]` yozuvida `boshi`
indeksdagi element natijaga kiradi, `oxiri` indeksdagi element esa kirmaydi:

```go
package main

import "fmt"

func main() {
	sonlar := []int{10, 20, 30, 40, 50}
	qism := sonlar[1:4]

	fmt.Println(qism)
	qism[0] = 99
	fmt.Println(sonlar)
}
```

Natija:

```text
[20 30 40]
[10 99 30 40 50]
```

`sonlar[1:4]` ifodasi `1`, `2` va `3` indekslardagi elementlarni oladi. Natijada `[20 30 40]` hosil bo'ladi.

Bu amal elementlardan nusxa olmaydi. `boshi` va `oxiri` bir xil asosiy massiv manzillariga biriktiriladi. `qism[0]` 
aslida `sonlar[1]` turgan joy. Shu sabab unga `99` yozilganda `sonlar` ham o'zgaradi, agar alohida nusxa kerak bo'lsa 
`copy` funksiyasi ishlatiladi.

## `append`, uzunlik va sig'im

`append` slice oxiriga yangi element qo'shadi. U dastlabki `slice`ni emas, yangilangan `slice` qiymatini qaytaradi. 
Shuning uchun natijani o'zgaruvchiga qayta saqlash kerak bo'ladi:

```go
package main

import "fmt"

func main() {
	sonlar := make([]int, 0, 2)

	sonlar = append(sonlar, 10, 20)
	fmt.Println(sonlar, len(sonlar), cap(sonlar))

	sonlar = append(sonlar, 30)
	fmt.Println(sonlar, len(sonlar), cap(sonlar))
}
```

Avval `slice` sig'imiga mos ikkita element qo'shiladi, uchinchi element uchun esa mavjud sig'im yetmaydi shuning uchun 
natija quyidagicha bo'ladi:

```text
[10 20] 2 2
[10 20 30] 3 4
```

Sig'im yetarli bo'lsa, `append` mavjud asosiy massivdagi bo'sh joydan foydalanadi. Sig'im yetmasa, Go kattaroq massiv
yaratadi, eski elementlarni unga ko'chiradi va yangi massivga murojaat qiluvchi `slice`ni qaytaradi.

Yangi sig'im aynan `4` bo'lishi shart emas. Uning qanchaga oshishi Go runtime qaroriga bog'liq. Faqat
sig'im uzunlikdan kam bo'lmasligi kerak. Shu sabab sastur mantig'ini sig'imning qanchaga o'sishiga bog'lamaslik kerak.

> **Diqqat**
>
> Faqat `append(sonlar, 30)` deb yozish yetarli emas. `append` yangi asosiy massiv yaratishi mumkin va qaytargan slice 
> shu massivga murojaat qiladi. Doim natijani o'zgaruvchiga biriktirish kerak: `sonlar = append(sonlar, 30)`.

## Slicelar orasidagi bog'lanish

Asosiy massivga bog'langan `slice`lar bir-birining elementlariga ta'sir qilishi mumkin. Odatda bu holat `append`
ishlatilganda yuz beradi:

```go
package main

import "fmt"

func main() {
	asl := []int{1, 2, 3, 4}
	qism := asl[:2]
	qism = append(qism, 99)

	fmt.Println("Asl:", asl)
	fmt.Println("Qism:", qism)
}
```

Natija:

```text
Asl: [1 2 99 4]
Qism: [1 2 99]
```

`qism` dastlab `asl`ning birinchi ikkita elementlarini xotira manzillarini oladi. Uning uzunligi `2`, lekin asosiy 
massivda yana bo'sh sig'im bor. Shu sabab `append` yangi massiv yaratmaydi. U `99` qiymatini asosiy massivdagi keyingi 
joyga, ya'ni `asl[2]`ustiga yozadi.

`Slice`lardan birini mustaqil o'zgartirish kerak bo'lsa, avval uning alohida nusxasini boshqa o'zgaruvchiga olish 
to'g'ri bo'ladi.

## Nusxa olish

`copy` elementlarni asosiy slicedan boshqa slice o'zgaruvchisiga ko'chiradi. Qabul yangi slice oldindan kerakli 
uzunlikda e'lon qilinishi lozim. `copy` ko'chirilgan elementlar sonini ham qaytaradi:

```go
package main

import "fmt"

func main() {
	asl := []int{1, 2, 3}
	nusxa := make([]int, len(asl))
	kochirilgan := copy(nusxa, asl)
	nusxa[0] = 99

	fmt.Println("Ko'chirildi:", kochirilgan)
	fmt.Println("Asl:", asl)
	fmt.Println("Nusxa:", nusxa)
}
```

Natija:

```text
Ko'chirildi: 3
Asl: [1 2 3]
Nusxa: [99 2 3]
```

`nusxa` uchun alohida asosiy massiv yaratilgan. Shu sabab `nusxa[0]`ga `99` yozish `asl`ga ta'sir qilmaydi.

`copy` faqat ikkala `slice` uzunligiga sig'adigan elementlarni ko'chiradi. Masalan, asosiy `slice`da beshta, yangi 
sliceda uchta joy bo'lsa, faqat uchta element ko'chiriladi. 

`Slice`larni nusxalashda `nusxa := append([]int(nil), asl...)` yoki `nusxa := slices.Clone(asl)` usullardan ham
foydalanish mumkin.

## Element o'chirish

`Slice` elementini o'chiradigan alohida `delete` funksiyasi yo'q. Slice elementlari tartibini saqlab qolish uchun 
o'chiriladigan elementdan oldingi va keyingi qismlar `append` bilan birlashtiriladi:

```go
package main

import "fmt"

func main() {
	sonlar := []int{10, 20, 30, 40}
	indeks := 1
	sonlar = append(sonlar[:indeks], sonlar[indeks+1:]...)

	fmt.Println(sonlar)
}
```

Natija:

```text
[10 30 40]
```

`sonlar[:indeks]` qismi o'chiriladigan elementdan oldingi qismini oladi. Bu misolda `indeks` qiymati `1`, shuning 
uchun natija `[10]` bo'ladi. `sonlar[indeks+1:]` esa o'chiriladigan elementdan keyingi barcha elementlarni oladi. Bu 
qismning natijasi `[30 40]`. `append()` funksiyasi birinchi qismga ikkinchi qism elementlarini qo'shadi. `...` operatori 
`[30 40]` qismni alohida elementlarga ajratib, `append()` funksiyasiga uzatadi. Shu tariqa `20` elementi yangi 
qismga qo'shilmaydi va natijada `[10 30 40]` hosil bo'ladi.

`indeks` qiymati foydalanuvchi yoki boshqa tashqi manbadan kelsa, avval `0 <= indeks && indeks < len(sonlar)` shartini
tekshirish kerak. Aks holda qismni olish vaqtida `panic` xatosi sodir bo'ladi.

## Qo'shimcha misollar

### 1. Slice sig'imini oldindan ajratish

```go
package main

import "fmt"

func main() {
	sonlar := make([]int, 0, 5)
	for i := 1; i <= 5; i++ {
		sonlar = append(sonlar, i*i)
	}
	fmt.Println(sonlar, len(sonlar), cap(sonlar))
}
```

Elementlar soni taxminan ma'lum bo'lsa, sig'imni oldindan ajratish `append` paytida yangi massiv yaratishlar sonini
kamaytiradi. Slice yaratilgan paytda uning uzunligi `0`, chunki unga hali element qo'shilmagan. Sig'imi esa `5`, shuning
uchun dastlabki beshta element uchun joy tayyor.

### 2. Bir nechta elementni birdan qo'shish

```go
package main

import "fmt"

func main() {
	sonlar := []int{1, 2}
	sonlar = append(sonlar, 3, 4, 5)
	fmt.Println(sonlar)
}
```

`append` bitta chaqiruvda bir nechta elementni qabul qiladi. Misolda `3`, `4` va `5` qiymatlari ketma-ket qo'shiladi.
Natija `[1 2 3 4 5]` bo'ladi.

### 3. Boshqa slice elementlarini qo'shish

```go
package main

import "fmt"

func main() {
	birinchi := []int{1, 2}
	ikkinchi := []int{3, 4}
	birlashgan := append(birinchi, ikkinchi...)
	fmt.Println(birlashgan)
}
```

`...` belgisi `ikkinchi` slice'idagi elementlarni `append`ga alohida qiymatlar sifatida uzatadi. Natijada ikkala slice
elementlaridan `[1 2 3 4]` hosil bo'ladi.

> **Diqqat**
>
> `append` sig'im yetarli bo'lsa, `birinchi`ning asosiy massividan foydalanishi mumkin. `birlashgan` butunlay mustaqil
> bo'lishi kerak bo'lsa, avval nusxa yarating.

### 4. Slice'ni joyida teskari qilish

```go
package main

import "fmt"

func main() {
	sonlar := []int{1, 2, 3, 4, 5}
	for chap, ong := 0, len(sonlar)-1; chap < ong; chap, ong = chap+1, ong-1 {
		sonlar[chap], sonlar[ong] = sonlar[ong], sonlar[chap]
	}
	fmt.Println(sonlar)
}
```

`chap` indeks boshidan, `ong` indeks esa oxiridan markazga qarab yuradi. Har qadamda shu indekslardagi elementlar o'zaro
almashtiriladi. O'zgartirish mavjud sliceda bajarilgani uchun qo'shimcha slice yaratilmaydi.

### 5. Shartga mos elementlarni filtrlash

```go
package main

import "fmt"

func main() {
	sonlar := []int{1, 2, 3, 4, 5, 6}
	juftlar := make([]int, 0, len(sonlar))
	for _, son := range sonlar {
		if son%2 == 0 {
			juftlar = append(juftlar, son)
		}
	}
	fmt.Println(juftlar)
}
```

Sikl faqat juft sonlarni `juftlar` slice'iga qo'shadi. Natija uchun alohida slice yaratilgani sababli `sonlar`
o'zgarmaydi. Juft elementlar soni manba uzunligidan oshmaydi. Shu sabab manba uzunligicha sig'im oldindan ajratilgan.

### 6. Qo'shimcha xotirasiz filtrlash

```go
package main

import "fmt"

func main() {
	sonlar := []int{1, 2, 3, 4, 5, 6}
	juftlar := sonlar[:0]
	for _, son := range sonlar {
		if son%2 == 0 {
			juftlar = append(juftlar, son)
		}
	}
	fmt.Println(juftlar)
}
```

`sonlar[:0]` uzunligi nol bo'lgan slice hosil qiladi, lekin yangi asosiy massiv yaratmaydi. `append` tanlangan juft
sonlarni `sonlar`ning asosiy massiviga boshidan boshlab yozadi. Natijada qo'shimcha asosiy massiv ajratilmaydi, ammo
manbadagi elementlar ham o'zgaradi.

### 7. Elementni tartibni saqlamasdan o'chirish

```go
package main

import "fmt"

func main() {
	sonlar := []int{10, 20, 30, 40}
	indeks := 1
	sonlar[indeks] = sonlar[len(sonlar)-1]
	sonlar = sonlar[:len(sonlar)-1]
	fmt.Println(sonlar)
}
```

O'chiriladigan `20` o'rniga oxirgi element - `40` yoziladi. Keyin slice uzunligi bittaga qisqartiriladi. Natija
`[10 40 30]` bo'ladi. Tartib muhim bo'lmasa, bu usul qolgan elementlarni siljitishni talab qilmaydi.

### 8. Slice'ni aniq uzunlikka kengaytirish

```go
package main

import "fmt"

func main() {
	sonlar := make([]int, 2, 5)
	sonlar[0], sonlar[1] = 10, 20
	sonlar = sonlar[:4]
	sonlar[2], sonlar[3] = 30, 40
	fmt.Println(sonlar)
}
```

Yangi uzunlik sig'imdan oshmasa, slice'ni qayta kesish orqali kengaytirish mumkin. Misolda uzunlik `2` dan `4` ga
oshiriladi. Yangi ko'ringan elementlar dastlab `0` qiymatiga ega bo'ladi, keyin ularga `30` va `40` yoziladi.

### 9. Ikki o'lchamli slice yaratish

```go
package main

import "fmt"

func main() {
	qatorlar, ustunlar := 2, 3
	jadval := make([][]int, qatorlar)
	for i := range jadval {
		jadval[i] = make([]int, ustunlar)
		jadval[i][0] = i + 1
	}
	fmt.Println(jadval)
}
```

`[][]int` - elementlari ham `[]int` bo'lgan slice. Avval qatorlar uchun tashqi slice yaratiladi. Keyin siklda har bir
qator uchun alohida ichki slice ajratiladi. Shu sabab qatorlar bir xil yoki turli uzunlikda bo'lishi mumkin.

### 10. Slice'larni tenglik bo'yicha solishtirish

```go
package main

import (
	"fmt"
	"slices"
)

func main() {
	a := []int{1, 2, 3}
	b := []int{1, 2, 3}
	fmt.Println(slices.Equal(a, b))
}
```

Slice'larni bir-biri bilan `==` orqali taqqoslab bo'lmaydi. Faqat slice'ning `nil` ekanini `slice == nil` shaklida
tekshirish mumkin.

Elementlar taqqoslanadigan turda bo'lsa, `slices.Equal` avval uzunliklarni, keyin bir xil indeksdagi elementlarni
solishtiradi. Misoldagi ikkala slice bir xil bo'lgani uchun dastur `true` chiqardi.

> **Maslahat**
>
> - Slice uzunligi o'zgarishi mumkin bo'lgan ketma-ket ma'lumotlar uchun ishlatiladi.
> - `len` ayni paytda sliceda mavjud elementlar sonini, `cap` esa asosiy massivdagi foydalanish mumkin bo'lgan joyni 
>     bildiradi.
> - Kesib olingan slice odatda asosiy slice bilan bir xil asosiy massivga bog'lanadi. Biridagi o'zgarish ikkinchisida ham
>     ta'sir qiladi.
> - `append` qaytargan slice doim o'zgaruvchiga berilishi kerak. Agar sig'im yetmasa yangi asosiy massiv yaratadi.
