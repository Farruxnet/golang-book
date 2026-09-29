# Goda `map` ma'lumot turi

`map` ma'lumotlarni kalit-qiymat juftligi ko'rinishida saqlaydi. `Slice` va `Array`da elemenlarga `0`, `1`, `2` kabi 
indexlar orqali murojaat qilamiz. `map`da esa qiymatga o'zimiz belgilagan kalit orqali murojaat qilamiz. Masalan, 
mahsulot narxini uning nomi, foydalanuvchini esa ID raqami orqali olish mumkin.

`map`dagi barcha kalitlar bir xil turda bo'lishi kerak. Qiymatlar uchun ham bitta umumiy tur belgilanadi. Har bir 
kalit faqat bir marta uchraydi. Ammo turli kalitlarda bir xil qiymat saqlanishi mumkin.

## `map` yaratish

`map` turi `map[KalitTuri]QiymatTuri` ko'rinishida yoziladi. Masalan, `map[string]int`da kalit `string`, qiymat esa 
`int` turida bo'ladi. `map`ni tayyor qiymatlar bilan yoki `make` yordamida ham yaratish mumkin:

```go
package main

import "fmt"

func main() {
	narxlar := map[string]int{
		"non":    4_000,
		"sut":    12_000,
		"guruch": 18_000,
	}

	ombor := make(map[string]int)
	ombor["non"] = 25

	fmt.Println("Sut narxi:", narxlar["sut"])
	fmt.Println("Non miqdori:", ombor["non"])
}
```

Natija:

```text
Sut narxi: 12000
Non miqdori: 25
```

`narxlar` tayyor kalit-qiymat juftlari bilan yaratilgan. Qiymatni olish uchun kalit kvadrat qavs ichida yoziladi: 
`narxlar["sut"]`.

`make(map[string]int)` esa qiymat yozish mumkin bo'lgan bo'sh `map` yaratadi. Keyin `ombor["non"] = 25` qatori unga 
yangi juftlik qo'shadi.

`make`ga taxminiy elementlar sonini ham berish mumkin: `make(map[string]int, 100)`. Bu son `map` uzunligini `100` qilib 
qo'ymaydi. U Go runtime'iga xotirani oldindan rejalash uchun ko'rsatma beradi. `map` yaratilgan paytda baribir bo'sh 
bo'ladi.

## `nil` va bo'sh `map`

E'lon qilingan, ammo hali yaratilmagan `map`ning nol qiymati `nil` bo'ladi:

```go
package main

import "fmt"

func main() {
	var nilMap map[string]int
	boshMap := make(map[string]int)

	fmt.Println(len(nilMap), nilMap == nil)
	fmt.Println(len(boshMap), boshMap == nil)
	fmt.Println(nilMap["yo'q"])
}
```

Natija:

```text
0 true
0 false
0
```

`nilMap` va `boshMap` ikkalasi ham bo'sh, shuning uchun ularning uzunligi `0`. Farqi shundaki, `nilMap` hali ishlash 
uchun yaratilmagan va `nil`ga teng. `boshMap` esa `make` bilan yaratilgan va unga qiymat yozish mumkin.

`nil` map'dan qiymat o'qish, uning uzunligini olish, u bo'ylab `range` bilan yurish va `delete` yordamida kalit 
o'chirish xavfsiz. Mavjud bo'lmagan kaliti o'qilganda `int` turining nol(`0`) qiymati qaytadi.

Ammo `nil` map'ga qiymat yozib bo'lmaydi. Bunday urinish `panic: assignment to entry in nil map` xatosiga olib keladi. 
Qiymat yozishdan oldin `map`ni **literal** yoki `make` bilan yaratish kerak.

## Kalit mavjudligini tekshirish

Mavjud bo'lmagan kalitga murojaat qilinganda turining nol qiymati qaytadi. Masalan, `map[string]int` uchun bu qiymat 
`0`. Lekin `0` natijasiga qarab kalit mavjud yoki mavjud emasligini aniqlab bo'lmaydi. Chunki `0` `map`da saqlangan 
qiymat ham bo'lishi mumkin.

Bu ikki holatni ajratish uchun "vergul, ok" (`comma ok`) shakli ishlatiladi:

```go
package main

import "fmt"

func main() {
	ballar := map[string]int{"Ali": 0}

	ball, bor := ballar["Ali"]
	fmt.Println("Ali:", ball, bor)

	ball, bor = ballar["Vali"]
	fmt.Println("Vali:", ball, bor)
}
```

Natija:

```text
Ali: 0 true
Vali: 0 false
```

`ball` o'zgaruvchisi qiymatni oladi, `bor` esa kalit mavjud bo'lsa `true`, mavjud bo'lmasa `false` bo'ladi. Misolda 
`Ali` kaliti bor va uning qiymati `0`. `Vali` kaliti esa yo'q, shu sabab ikkala holatda qiymat `0` bo'lsa ham `bor` 
natijasi farq qiladi.

> **Eslab qoling**
>
> Qiymatning o'zi kerak bo'lmasa, uni `_` bilan tashlab ketish mumkin: `_, bor := ballar["Ali"]`. Shunda faqat kalit 
> bor yoki yo'qligi tekshiriladi, o'zgeruvchini qiymati esa e'tiborsiz qoldiriladi. `_` bilan e'tiborsiz qoldirish 
> **Go**ning kompilatsiya xatosini ham oldini oladi, sababi o'zgaruvchi e'lon qilinib undan foydalanilmasa 
> kompilatsiyadan o'tmaydi.

## Qiymatni yangilash va o'chirish

Yangi kalitga qiymat berish `map`ga element qo'shish hisoblanadi. Mavjud kalitga qiymat berish esa uning eski qiymatini 
almashtiradi. Elementni o'chirish uchun `delete(mapNomi, kalit)` ishlatiladi. Kalit mavjud bo'lmasa ham `delete`xato 
bermaydi.

```go
package main

import "fmt"

func main() {
	foydalanuvchi := map[string]string{"ism": "Sardor", "shahar": "Toshkent"}
	foydalanuvchi["ism"] = "Elbek"
	delete(foydalanuvchi, "shahar")

	fmt.Println(foydalanuvchi["ism"])
	_, bor := foydalanuvchi["shahar"]
	fmt.Println("Shahar mavjud:", bor)
}
```

Natija:

```text
Elbek
Shahar mavjud: false
```

Misolda `ism` kalitining `Sardor` qiymati `Elbek` bilan almashtirildi. `shahar` kaliti o'chirildi. Keyingi `value, ok` 
tekshiruvi uning endi mavjud emasligini ko'rsatdi.

## Qaysi turlar kalit bo'la oladi?

`map` ichidan kerakli qiymatni topish uchun kalitlarni taqqoslaydi. Shu sabab kalit turi `==` va `!=` operatorlari 
bilan taqqoslanadigan turda bo'lishi kerak.

Sonlar, `string`, `bool`, pointer va channel turlari kalit bo'la oladi. Elementlari taqqoslanadigan massiv hamda barcha 
maydonlari taqqoslanadigan struct ham kalit sifatida ishlatiladi. `slice`, `map` va funksiya taqqoslanmaydi, shuning 
uchun ular kalit bo'la olmaydi.

`float64` ham texnik jihatdan kalit bo'la oladi. Ammo `NaN` qiymati o'ziga ham teng bo'lmaydi. Shu sabab kasrli sonni 
kalit sifatida ishlatishda ehtiyot bo'lish kerak.

## `range` va tartib

`map` elementlarining saqlanish tartibiga tayanib bo'lmaydi. `range` bilan `map` iteratsiya qilinganda ya'ni dastur har 
safar ishga tushganda elementlar har xil tartibda bo'ladi. 

Natijani doim alifbo tartibida olish uchun kalitlarni alohida saralash kerak bo'ladi:

```go
package main

import (
	"fmt"
	"sort"
)

func main() {
	yoshlar := map[string]int{"Ali": 24, "Vali": 31, "Lola": 27}
	kalitlar := make([]string, 0, len(yoshlar))

	for ism := range yoshlar {
		kalitlar = append(kalitlar, ism)
	}
	sort.Strings(kalitlar)

	for _, ism := range kalitlar {
		fmt.Println(ism, yoshlar[ism])
	}
}
```

Natija:

```text
Ali 24
Lola 27
Vali 31
```

Avval barcha kalitlar `kalitlar` `slice`iga yig'ildi. `sort.Strings` ularni alifbo tartibida saraladi. Keyingi sikl 
saralangan kalitlar orqali `map`dagi qiymatlarni oldi.

Test, log yoki foydalanuvchiga ko'rsatiladigan ro'yxat doim bir xil tartibda chiqishi kerak bo'lsa, shu usuldan 
foydalansa bo'ladi. `map`ning `range` bilan interatsiya tartibiga ishonish har doim ham to'g'ri bo'lmaydi.

## Tayinlash, funksiyaga uzatish va parallel ishlash

> **Eslab qoling**
>
> `b := a` ko'rinishda `map` elementlaridan nusxa olmaydi. `a` va `b` bir xil ma'lumotga murojaat qiladi. `b` orqali 
> kiritilgan o'zgarish `a` ga ham ta'sor qiladi. To'liq bir-biridan mustaqil nusxa olish kerak bo'lsa, yangi `map` 
> yaratib, har bir kalit-qiymat juftligini unga ko'chirish kerak.

> **Eslab qoling**
>
> Oddiy `map`ga bir nechta `goroutine` bir vaqtda yozishi xavfsiz emas. Bir `goroutine` yozayotgan paytda boshqasining 
> o'qishi ham xavfli. Bunday holatda ma'lumotga kirishni muvofiqlashtirish kerak. Buning uchun `sync.Mutex`, 
> `sync.RWMutex`, `channel` orqali yagona egalik yoki vazifaga mos bo'lsa `sync.Map` ishlatiladi.
> Bir nechta `goroutine` faqat o'qisa va hech biri `map`ni o'zgartirmasa, bir vaqtda o'qish mumkin. Parallel ishlash
> usullari `concurrency` qismida batafsil ko'rib chiqiladi.

## Qo'shimcha misollar

### 1. So'zlar chastotasini hisoblash

```go
package main

import (
	"fmt"
	"strings"
)

func main() {
	sanoq := make(map[string]int)
	for _, soz := range strings.Fields("go tez go sodda go") {
		sanoq[soz]++
	}
	fmt.Println(sanoq)
}
```

`strings.Fields` matnni alohida so'zlarga ajratadi. Har bir so'z map'da kalit sifatida ishlatiladi. Mavjud bo'lmagan 
kalit uchun `int` turining nol qiymati — `0` qaytadi. Shu sabab so'z birinchi marta uchraganda ham `sanoq[soz]++` 
to'g'ri ishlaydi. `go` so'zi uch marta uchragani uchun uning qiymati `3` bo'ladi.

### 2. Elementlarni guruhlash

```go
package main

import "fmt"

func main() {
	sonlar := []int{1, 2, 3, 4, 5, 6}
	guruhlar := make(map[string][]int)
	for _, son := range sonlar {
		kalit := "toq"
		if son%2 == 0 {
			kalit = "juft"
		}
		guruhlar[kalit] = append(guruhlar[kalit], son)
	}
	fmt.Println(guruhlar)
}
```

`map` qiymatining turi slice ham bo'lishi mumkin. Juft sonlar `"juft"`, toq sonlar esa `"toq"` kalitidagi slice'ga 
qo'shiladi. Mavjud bo'lmagan kalit uchun `nil` slice qaytadi. `nil` slice'ga `append` orqali element qo'shish xavfsiz, 
shuning uchun har bir guruhni oldindan yaratish shart emas.

### 3. Set ko'rinishidagi map

```go
package main

import "fmt"

func main() {
	noyob := make(map[string]bool)
	for _, ism := range []string{"Ali", "Vali", "Ali"} {
		noyob[ism] = true
	}
	fmt.Println(len(noyob))
}
```

Ba'zan faqat qiymatning to'plamda bor yoki yo'qligini bilish kerak. Go'da alohida set turi yo'q, lekin `map[string]bool` 
shu vazifani bajarishi mumkin. Kalit to'plamdagi elementni, `true` esa uning borligini bildiradi. `Ali` kaliti qayta 
yozilganda yangi element qo'shilmaydi. Shu sabab `len` natijasi `2` bo'ladi.

### 4. Takrorlarni olib tashlash

```go
package main

import "fmt"

func main() {
	sonlar := []int{3, 1, 3, 2, 1}
	korilgan := make(map[int]bool)
	natija := make([]int, 0, len(sonlar))
	for _, son := range sonlar {
		if !korilgan[son] {
			korilgan[son] = true
			natija = append(natija, son)
		}
	}
	fmt.Println(natija)
}
```

`korilgan` map'i son oldin uchragan yoki uchramaganini saqlaydi. Son birinchi marta uchrasa, u `korilgan`ga yoziladi va
`natija`ga qo'shiladi. Keyingi uchrashuvlarda shart bajarilmaydi. Natijada `[3 1 2]` hosil bo'ladi va sonlarning 
birinchi uchrashuv tartibi saqlanadi.

### 5. Map'ni mustaqil nusxalash

```go
package main

import "fmt"

func main() {
	asl := map[string]int{"olma": 2, "anor": 3}
	nusxa := make(map[string]int, len(asl))
	for kalit, qiymat := range asl {
		nusxa[kalit] = qiymat
	}
	nusxa["olma"] = 10
	fmt.Println(asl["olma"], nusxa["olma"])
}
```

Sikl har bir juftlikni yangi `map`ga ko'chiradi. Shu sabab `nusxa`ga kalit qo'shish yoki undagi `int` qiymatni 
o'zgartirish `asl`ga ta'sir qilmaydi. Dastur `2 10` natijasini chiqaradi.

Bu yerda qiymatlar `int` bo'lgani uchun oddiy ko'chirish yetarli. Qiymat turi slice, `map` yoki pointer kabi boshqa
ma'lumotga murojaat qilsa, to'liq mustaqil nusxa uchun ichki qiymatlarni ham alohida nusxalash kerak.

### 6. Ichma-ich map

```go
package main

import "fmt"

func main() {
	ballar := make(map[string]map[string]int)
	ballar["Ali"] = make(map[string]int)
	ballar["Ali"]["Go"] = 95
	fmt.Println(ballar["Ali"]["Go"])
}
```

Tashqi `map`dagi har bir qiymatning o'zi ham `map`. `ballar["Ali"]` ichki map'iga qiymat yozishdan oldin uni `make` 
bilan yaratish kerak. Aks holda dastur `nil` map'ga yozishga urinadi va `panic` yuz beradi.

### 7. Massiv kalitidan foydalanish

```go
package main

import "fmt"

func main() {
	ranglar := map[[2]int]string{{2, 3}: "qizil"}
	fmt.Println(ranglar[[2]int{2, 3}])
}
```

`int` elementlaridan tuzilgan massiv taqqoslanadigan tur hisoblanadi. Shu sabab `[2]int` ikki koordinatani bitta `map` 
kalitida birlashtira oladi. Misolda `[2]int{2, 3}` kaliti uchun `qizil` qiymati olinadi.

### 8. Kalitlarni tartiblab chiqarish

```go
package main

import (
	"fmt"
	"sort"
)

func main() {
	narxlar := map[string]int{"uzum": 20, "anor": 15, "olma": 10}
	kalitlar := make([]string, 0, len(narxlar))
	for kalit := range narxlar {
		kalitlar = append(kalitlar, kalit)
	}
	sort.Strings(kalitlar)
	for _, kalit := range kalitlar {
		fmt.Println(kalit, narxlar[kalit])
	}
}
```

`map` bo'ylab aylanish tartibi kafolatlanmaydi. Avval kalitlar slice'ga yig'iladi, so'ng `sort.Strings` yordamida 
saralanadi. Oxirgi sikl narxlarni `anor`, `olma`, `uzum` tartibida chiqaradi.

### 9. Ikki map qiymatlarini solishtirish

```go
package main

import (
	"fmt"
	"maps"
)

func main() {
	a := map[string]int{"a": 1, "b": 2}
	b := map[string]int{"b": 2, "a": 1}
	fmt.Println(maps.Equal(a, b))
}
```

`map` qiymatini boshqa `map` bilan `==` orqali taqqoslab bo'lmaydi. Uni faqat `nil` bilan to'g'ridan-to'g'ri taqqoslash
mumkin.

Qiymat turi taqqoslanadigan bo'lsa, `maps.Equal` ikki map'dagi kalit-qiymat juftlarini tekshiradi. Juftliklarning kodda 
yozilish tartibi muhim emas. Misoldagi `a` va `b` bir xil juftliklarga ega, shuning uchun natija `true` bo'ladi.

### 10. Kalit mavjud bo'lsa yangilash

```go
package main

import "fmt"

func main() {
	zaxira := map[string]int{"kitob": 5}
	if soni, bor := zaxira["kitob"]; bor {
		zaxira["kitob"] = soni - 1
	} else {
		fmt.Println("Mahsulot topilmadi")
	}
	fmt.Println(zaxira)
}
```

`if` ichidagi `soni, bor := zaxira["kitob"]` yozuvi qiymatni olish va kalit mavjudligini tekshirishni birlashtiradi. 
Kalit bor bo'lsa, kitob soni bittaga kamaytiriladi. Kalit yo'q bo'lsa, xabar chiqariladi.

Keyingi qismda qiymatning xotiradagi manziliga murojaat qilish imkonini beruvchi ko'rsatkichlarni ko'rib chiqamiz.
