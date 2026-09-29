# Goda funksiyalar

Funksiya ma'lum vazifani bajaradigan nomlangan kod bloki. Takrorlanadigan kodni bir joyga yig'ish, dasturni kichik 
qismlarga ajratish va har bir qismni alohida testlash imkonini beradi.

## E'lon qilish va chaqirish

```go
func nom(parametr tur) qaytishTuri {
	return qiymat
}
```

**Parametr** — funksiya e'lonida ko'rsatilgan o'zgaruvchi. **Argument** esa funksiya chaqirilganda parametrga 
beriladigan aniq qiymat.

```go
package main

import "fmt"

func salomlash(ism string) string {
	return "Salom, " + ism + "!"
}

func main() {
	xabar := salomlash("Ali")
	fmt.Println(xabar)
}
```

Natija:

```text
Salom, Ali!
```

`salomlash` bitta `string` parametrni qabul qiladi va `string` qaytaradi. `return` funksiya ishini yakunlab, qiymatni 
qaytaradi. Hech qanday qiymat qaytarmaydigan funksiyaga e'lon qilishda qaytish turi yozilmaydi.

Bir xil turdagi ketma-ket parametrlar qisqa yozilishi mumkin: `func qo'sh(a, b int) int`.

## Bir nechta qiymat qaytarish

Go funksiyasi bir nechta qiymat qaytara oladi. Bu imkoniyat natija bilan birga xatoni ham qaytarishda ko'p ishlatiladi:

```go
package main

import "fmt"

func bolish(a, b float64) (float64, error) {
	if b == 0 {
		return 0, fmt.Errorf("nolga bo'lish mumkin emas")
	}
	return a / b, nil
}

func main() {
	natija, err := bolish(10, 4)
	if err != nil {
		fmt.Println("Xato:", err)
		return
	}
	fmt.Println("Natija:", natija)
}
```

Natija:

```text
Natija: 2.5
```

`b` nol bo'lsa, bo'lish bajarilmaydi va xato qaytariladi. API, fayl yoki ma'lumotlar bazasi bilan ishlaydigan kodda 
xatoni alohida qiymat sifatida qaytarish ko'p qo'llanadi. Qaytgan qiymatlardan biri kerak bo'lmasa, uni `_` yordamida
e'tiborsiz qoldirish mumkin.

## Argumentlar qiymat sifatida uzatiladi

Goda barcha argumentlar qiymat bo'yicha uzatiladi. Funksiya argument qiymatining nusxasini oladi:

```go
package main

import "fmt"

func oshir(n int) {
	n++
}

func main() {
	son := 10
	oshir(son)
	fmt.Println(son)
}
```

Natija:

```text
10
```

`slice`, `map`, `channel` va `pointer` ham qiymat bo'yicha uzatiladi. Ammo ularning nusxasi ham o'sha asosiy ma'lumotga 
murojaat qilishi mumkin. Shu sabab argument nusxalanishi funksiya ichidagi o'zgarishlar chaqiruvchiga hech qachon 
ta'sir qilmaydi degani emas.

## Variadik funksiya

Ba'zan funksiyaga nechta argument berilishini oldindan aniq bilmaymiz.

Masalan, bir nechta sonning yig'indisini hisoblaydigan funksiya yozmoqchimiz. Oddiy parametrlar bilan yozsak, 
argumentlar sonini oldindan belgilashimiz kerak:

```go
func yigindi(a, b int) int {
	return a + b
}
```

Bu funksiya faqat ikkita son qabul qiladi:

```go
yigindi(10, 20)
```

Agar uchta, to'rtta yoki undan ko'p son uzatmoqchi bo'lsak, bunday funksiya yetarli bo'lmaydi. Shunday holatlarda 
**variadik funksiya** ishlatiladi. Variadik parametr quyidagi ko'rinishda yoziladi:

```go
sonlar ...int
```

Bu yozuv:

> `sonlar` parametriga nol yoki undan ko'p `int` qiymat uzatish mumkin

degan ma'noni anglatadi.

Masalan:

```go
package main

import "fmt"

func yigindi(sonlar ...int) int {
	natija := 0

	for _, son := range sonlar {
		natija += son
	}

	return natija
}

func main() {
	fmt.Println(yigindi(1, 2, 3, 4))
}
```

Natija:

```text
10
```

Bu yerda:

```go
yigindi(1, 2, 3, 4)
```

funksiyaga to'rtta alohida `int` argument uzatmoqda.

Funksiya ichida esa:

```go
sonlar ...int
```

parametri `[]int` kabi ishlaydi.

Ya'ni yuqoridagi chaqiruvda funksiya ichidagi `sonlar`ni taxminan quyidagicha tasavvur qilish mumkin:

```go
[]int{1, 2, 3, 4}
```

Shuning uchun uning elementlarini `range` yordamida aylanib chiqish mumkin:

```go
for _, son := range sonlar {
	natija += son
}
```

Variadik funksiyaga argumentlar soni turlicha bo'lishi mumkin:

```go
fmt.Println(yigindi())
fmt.Println(yigindi(10))
fmt.Println(yigindi(10, 20))
fmt.Println(yigindi(10, 20, 30, 40))
```

Masalan:

```go
yigindi()
```

ham to'g'ri chaqiruv hisoblanadi, chunki variadik parametr **nol yoki undan ko'p** argument qabul qiladi.

### Sliceni variadik funksiyaga uzatish

Endi bizda tayyor slice bor deb tasavvur qilamiz:

```go
sonlar := []int{5, 6, 7}
```

Uni quyidagicha yozib bo'lmaydi:

```go
yigindi(sonlar)
```

Chunki `yigindi` alohida `int` argumentlarni kutmoqda, `sonlar` esa bitta `[]int` qiymat.

Bunday holatda slice nomidan keyin `...` yoziladi:

```go
yigindi(sonlar...)
```

To'liq misol:

```go
package main

import "fmt"

func yigindi(sonlar ...int) int {
	natija := 0

	for _, son := range sonlar {
		natija += son
	}

	return natija
}

func main() {
	sonlar := []int{5, 6, 7}

	fmt.Println(yigindi(sonlar...))
}
```

Natija:

```text
18
```

Quyidagi yozuv:

```go
yigindi(sonlar...)
```

slice ichidagi elementlarni funksiyaga alohida argumentlar sifatida uzatadi.

Uni mazmunan quyidagiga o'xshatish mumkin:

```go
yigindi(5, 6, 7)
```

Demak, `...` ikki joyda uchrashi mumkin va ularning vazifasi biroz farq qiladi.

Funksiya parametrida:

```go
func yigindi(sonlar ...int)
```

`...int`:

> bu parametr istalgan miqdordagi `int` argumentlarni qabul qiladi

degan ma'noni bildiradi.

Funksiyani chaqirishda:

```go
yigindi(sonlar...)
```

`sonlar...`:

> slice ichidagi elementlarni alohida argumentlarga yoyib uzat

degan ma'noni bildiradi.

### Variadik parametr oxirgi bo'lishi kerak

Funksiyada oddiy parametrlar ham, variadik parametr ham bo'lishi mumkin:

```go
func xabar(prefix string, sonlar ...int) {
	// ...
}
```

Bunda funksiya quyidagicha chaqirilishi mumkin:

```go
xabar("Natija:", 10, 20, 30)
```

Ammo variadik parametr har doim parametrlar ro'yxatining **oxirida** kelishi kerak.

Masalan, quyidagicha yozish mumkin emas:

```go
func xabar(sonlar ...int, prefix string) {
	// ...
}
```

Sababi, `sonlar` nechta argument qabul qilishini oldindan bilib bo'lmaydi. Agar undan keyin yana parametr bo'lsa, qaysi 
argument variadik parametrga, qaysi biri keyingi parametrga tegishli ekanini aniqlash noaniq bo'lib qoladi.

Shuning uchun to'g'ri ko'rinish:

```go
func xabar(prefix string, sonlar ...int) {
	// ...
}
```

Qisqacha:

```go
func yigindi(sonlar ...int)
```

— funksiya istalgan miqdordagi `int` argument qabul qiladi.

```go
yigindi(1, 2, 3)
```

— uchta alohida argument uzatiladi.

```go
sonlar := []int{1, 2, 3}
yigindi(sonlar...)
```

— slice elementlari alohida argumentlar sifatida uzatiladi.

Funksiya ichida esa `sonlar` `[]int` sifatida ishlatiladi.

## Funksiya qiymati va anonim funksiya

Goda funksiya ham qiymat sifatida ishlatiladi. Uni o'zgaruvchiga saqlash yoki boshqa funksiyaga argument sifatida 
uzatish mumkin.

```go
package main

import "fmt"

func hisobla(a, b int, amal func(int, int) int) int {
	return amal(a, b)
}

func main() {
	kopaytir := func(a, b int) int {
		return a * b
	}

	fmt.Println(hisobla(4, 5, kopaytir))
}
```

Natija:

```text
20
```

Anonim funksiya tashqi ko'lamdagi (scope) o'zgaruvchidan foydalansa, closure hosil bo'ladi. Closure o'sha o'zgaruvchiga 
murojaatni saqlaydi, shu sabab uning holati keyingi chaqiruvlarda ham saqlanib qolishi mumkin. Bu usul callback, 
middleware va konfiguratsiya funksiyalarida uchraydi.

## Rekursiya

Funksiyaning o'zini chaqirishi rekursiya deyiladi. Rekursiv funksiya albatta to'xtash shartiga ega bo'lishi kerak:

```go
package main

import "fmt"

func faktorial(n uint64) uint64 {
	if n <= 1 {
		return 1
	}
	return n * faktorial(n-1)
}

func main() {
	fmt.Println(faktorial(5))
}
```

Natija:

```text
120
```

Har bir chaqiruv stackda qo'shimcha joy ishlatadi. Juda chuqur rekursiya resurs sarfini oshiradi. Oddiy ketma-ket 
hisoblarda sikldan foydalanish tushunarliroq bo'lishi mumkin. Faktorial natijasi `uint64` sig'imidan oshsa, overflow yuz 
beradi. Shuning uchun bu misol katta sonlarni hisoblash uchun mo'ljallanmagan.

## Misollar

### 1. Sonning juftligini qaytarish

```go
package main

import "fmt"

func juftmi(son int) bool {
	return son%2 == 0
}

func main() {
	fmt.Println(juftmi(18))
}
```

Funksiya hisoblangan `bool` qiymatni bevosita `return` orqali qaytaradi. Bu misolning natijasi `true` bo'ladi.

### 2. Nomlangan qaytish qiymati

```go
package main

import "fmt"

func tortburchak(eni, boyi int) (yuza int, perimetr int) {
	yuza = eni * boyi
	perimetr = 2 * (eni + boyi)
	return
}

func main() {
	yuza, perimetr := tortburchak(8, 5)
	fmt.Println(yuza, perimetr)
}
```

Nomlangan qaytish qiymatlari funksiya ichida oddiy o'zgaruvchi kabi ishlaydi. Qiymatsiz `return` ularning joriy 
qiymatini qaytaradi.

### 3. Erta `return` bilan tekshiruv

```go
package main

import "fmt"

func bol(a, b float64) (float64, bool) {
	if b == 0 {
		return 0, false
	}
	return a / b, true
}

func main() {
	natija, bajarildi := bol(20, 4)
	fmt.Println(natija, bajarildi)
}
```

Nolga bo'lish holati avval tekshiriladi. Ikkinchi qaytish qiymati bo'lish muvaffaqiyatli bajarilganini bildiradi.

### 4. Variadik yig'indi

```go
package main

import "fmt"

func yigindi(sonlar ...int) int {
	natija := 0
	for _, son := range sonlar {
		natija += son
	}
	return natija
}

func main() {
	fmt.Println(yigindi(2, 4, 6, 8))
}
```

`...int` funksiya nol yoki undan ko'p `int` argument qabul qilishini bildiradi. Funksiya ichida `sonlar` slice sifatida 
ishlaydi.

### 5. Slice'ni variadik argument sifatida uzatish

```go
package main

import "fmt"

func engKatta(sonlar ...int) int {
	katta := sonlar[0]
	for _, son := range sonlar[1:] {
		if son > katta {
			katta = son
		}
	}
	return katta
}

func main() {
	sonlar := []int{7, 12, 4, 19}
	fmt.Println(engKatta(sonlar...))
}
```

`sonlar...` slice elementlarini alohida argumentlar sifatida uzatadi. Misolda slice bo'sh emasligi oldindan ma'lum.

### 6. Funksiyani argument sifatida uzatish

```go
package main

import "fmt"

func hisobla(a, b int, amal func(int, int) int) int {
	return amal(a, b)
}

func main() {
	kopaytir := func(a, b int) int { return a * b }
	fmt.Println(hisobla(6, 7, kopaytir))
}
```

`amal` parametrining turi ikkita `int` qabul qilib, bitta `int` qaytaradigan funksiyani bildiradi.

### 7. Closure ichida holat saqlash

```go
package main

import "fmt"

func hisoblagich() func() int {
	son := 0
	return func() int {
		son++
		return son
	}
}

func main() {
	keyingi := hisoblagich()
	fmt.Println(keyingi(), keyingi(), keyingi())
}
```

Qaytarilgan anonim funksiya tashqi `son` o'zgaruvchisiga murojaatni saqlaydi. Shu sabab ketma-ket chaqiruvlar natijasi 
`1 2 3` bo'ladi.

### 8. Funksiyalar map'i

```go
package main

import "fmt"

func main() {
	amallar := map[string]func(int, int) int{
		"+": func(a, b int) int { return a + b },
		"-": func(a, b int) int { return a - b },
	}
	fmt.Println(amallar["+"](10, 3))
}
```

Funksiya ham `map` qiymati bo'la oladi. Avval funksiya kalit orqali olinadi, keyin argumentlar bilan chaqiriladi.

### 9. Rekursiya bilan raqamlar yig'indisi

```go
package main

import "fmt"

func raqamlarYigindisi(son int) int {
	if son == 0 {
		return 0
	}
	return son%10 + raqamlarYigindisi(son/10)
}

func main() {
	fmt.Println(raqamlarYigindisi(5832))
}
```

Har bir chaqiruv sonning oxirgi raqamini ajratadi. `son == 0` sharti rekursiyani to'xtatadi.

### 10. Funksiyani shartga qarab qaytarish

```go
package main

import "fmt"

func amalniTanla(nom string) func(int, int) int {
	if nom == "kopaytir" {
		return func(a, b int) int { return a * b }
	}
	return func(a, b int) int { return a + b }
}

func main() {
	amal := amalniTanla("kopaytir")
	fmt.Println(amal(5, 4))
}
```

Funksiya natija sifatida boshqa funksiyani qaytarishi mumkin. Qaytgan qiymat keyin oddiy funksiya kabi chaqiriladi.
