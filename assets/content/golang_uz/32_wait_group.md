# `sync.WaitGroup` bilan goroutinelarni kutish

`sync.WaitGroup` — bir guruh goroutine ishini tugatishini kutish uchun ishlatiladigan sinxronizatsiya vositasi.

Uning vazifasi oddiy: nechta ish hali tugamaganini hisoblab boradi. Bu son nolga tushganda barcha ro‘yxatga olingan ishlar tugagan deb hisoblanadi va kutayotgan goroutine davom etadi.

Oldingi mavzularda muhim bir holatni ko‘rdik: `main()` funksiyasi tugasa, dastur ham tugaydi. Go boshqa goroutinelarning tugashini avtomatik kutmaydi.

Masalan, goroutine ishga tushirib, keyin `main()` darhol qaytsa, yordamchi goroutine o‘z ishini tugatishga ulgurmasligi mumkin.

Ba’zan buning oldini olish uchun `time.Sleep` ishlatiladi:

```go
time.Sleep(time.Second)
```

Lekin bu ishonchli yechim emas.

Agar ish bir soniyadan uzoq davom etsa, dastur baribir erta tugashi mumkin. Agar ish 10 millisekundda tugasa, dastur qolgan vaqtni bekorga kutadi.

`WaitGroup` esa vaqtni taxmin qilmaydi. U ishning haqiqatan tugaganini kuzatadi.

## `WaitGroup` qanday ishlaydi?

`WaitGroup` bilan ishlashning klassik usulida asosan uchta metod ishlatiladi:

* `Add(n)` — tugallanmagan ishlar hisoblagichiga `n` qo‘shadi;
* `Done()` — hisoblagichni bittaga kamaytiradi;
* `Wait()` — hisoblagich nol bo‘lguncha joriy goroutineni kutdiradi.

Oddiy ish jarayoni quyidagicha:

1. Avval bajariladigan ish hisoblagichga qo‘shiladi.
2. Keyin goroutine ishga tushiriladi.
3. Goroutine o‘z ishini tugatganda `Done()` chaqiradi.
4. Kutuvchi kod `Wait()` orqali barcha ishlar tugashini kutadi.
5. Hisoblagich nolga tushganda `Wait()` qaytadi.

Masalan, uchta goroutine ishlashi kerak bo‘lsa, mantiqan hisoblagich quyidagicha o‘zgaradi:

```text
Boshlanish:
counter = 0

Add(3):
counter = 3

1-goroutine Done():
counter = 2

2-goroutine Done():
counter = 1

3-goroutine Done():
counter = 0

Wait() davom etadi
```

`WaitGroup`ning zero value qiymati ishlatishga tayyor.

Shuning uchun alohida konstruktor chaqirish kerak emas:

```go
var wg sync.WaitGroup
```

Bu yozuvdan keyin `wg.Add()`, `wg.Done()` va `wg.Wait()` metodlarini darhol ishlatish mumkin.

## Go 1.25 va yangi versiyalarda `WaitGroup.Go()`

Go 1.25dan boshlab `WaitGroup`da `Go()` metodi ham mavjud. U hisoblagichni oshiradi, yangi goroutine ishga tushiradi va funksiya tugagach hisoblagichni avtomatik kamaytiradi.

```go
package main

import (
	"fmt"
	"sync"
)

func main() {
	var wg sync.WaitGroup

	for i := 1; i <= 5; i++ {
		id := i
		wg.Go(func() {
			fmt.Println("Salom!", id)
		})
	}

	wg.Wait()
	fmt.Println("Barcha goroutine yakunlandi")
}
```

Bu usulda `wg.Add(1)`, `go` va `wg.Done()`ni alohida yozish shart emas. `Go()`ga berilgan funksiya ichida yana `Done()` chaqirmang, aks holda hisoblagich ortiqcha kamayadi. Bu funksiya panic qilmasligi kerak.

`Add()` va `Done()` metodlarini bilish baribir muhim. Ular Go 1.24 va undan eski versiyalardagi kodlarda hamda ish allaqachon boshqa joyda boshlangan holatlarda uchraydi. Keyingi misollarda klassik usulni ham ko‘rib chiqamiz.

## Birinchi misol

Quyidagi dastur beshta goroutine ishga tushiradi. `main()` esa ularning barchasi tugashini kutadi.

```go
package main

import (
	"fmt"
	"sync"
)

func greet(id int, wg *sync.WaitGroup) {
	defer wg.Done()
	fmt.Println("Salom!", id)
}

func main() {
	var wg sync.WaitGroup

	for i := 1; i <= 5; i++ {
		wg.Add(1)
		go greet(i, &wg)
	}

	wg.Wait()
	fmt.Println("Barcha goroutine yakunlandi")
}
```

Natijaning mumkin bo‘lgan ko‘rinishlaridan biri:

```text
Salom! 5
Salom! 1
Salom! 2
Salom! 3
Salom! 4
Barcha goroutine yakunlandi
```

Endi kodni bosqichma-bosqich ko‘ramiz.

Avval `WaitGroup` yaratiladi:

```go
var wg sync.WaitGroup
```

Hisoblagich dastlab `0`.

Siklning har bir aylanishida:

```go
wg.Add(1)
```

chaqiriladi.

Bu yangi tugallanmagan ish borligini bildiradi.

Birinchi aylanishdan keyin:

```text
counter = 1
```

Ikkinchi aylanishdan keyin:

```text
counter = 2
```

Beshinchi aylanishdan keyin esa:

```text
counter = 5
```

Shundan keyin goroutine ishga tushiriladi:

```go
go greet(i, &wg)
```

Bu yerda `&wg` ishlatilganiga e’tibor bering. Funksiyaga `WaitGroup`ning nusxasi emas, uning pointeri uzatilmoqda.

Shuning uchun barcha goroutinelar aynan bitta `WaitGroup` bilan ishlaydi.

`greet()` ichida:

```go
defer wg.Done()
```

yozilgan.

`Done()` hisoblagichni bittaga kamaytiradi.

Masalan:

```text
5 -> 4 -> 3 -> 2 -> 1 -> 0
```

`defer` sabab `Done()` funksiya tugashidan oldin bajariladi.

`main()` ichidagi:

```go
wg.Wait()
```

esa hisoblagich nolga tushmaguncha kutadi.

Faqat barcha beshta goroutine `Done()` chaqirgandan keyin quyidagi qator bajariladi:

```go
fmt.Println("Barcha goroutine yakunlandi")
```

Salomlashuv satrlarining tartibi kafolatlanmaydi.

Masalan, quyidagicha ham chiqishi mumkin:

```text
Salom! 3
Salom! 2
Salom! 5
Salom! 1
Salom! 4
Barcha goroutine yakunlandi
```

Buning sababi goroutinelarni Go scheduler rejalashtiradi. Qaysi goroutine birinchi CPU vaqtini olishi oldindan kafolatlanmaydi.

Ammo bitta narsa kafolatlangan: `"Barcha goroutine yakunlandi"` satri barcha `greet()` chaqiruvlari tugagandan keyin chiqadi.

## Nega `Done()` odatda `defer` bilan yoziladi?

`Done()` amalda hisoblagichni bittaga kamaytiradi.

Quyidagi ikki operatsiya mazmunan bir xil:

```go
wg.Done()
```

va:

```go
wg.Add(-1)
```

Lekin amaliy kodda `Done()` ishlatish ancha tushunarli.

Uni funksiya oxirida oddiy chaqirish ham mumkin:

```go
func work(wg *sync.WaitGroup) {
	doSomething()
	wg.Done()
}
```

Bu kod ishlaydi.

Muammo funksiya bir nechta joydan qaytishi mumkin bo‘lganda boshlanadi.

Masalan:

```go
func work(value int, wg *sync.WaitGroup) {
	if value < 0 {
		return
	}

	wg.Done()
}
```

Bu yerda `value < 0` bo‘lsa, funksiya `wg.Done()`ga yetib bormaydi.

Natijada `WaitGroup` hisoblagichi kamaymay qoladi.

Shuning uchun odatda quyidagicha yoziladi:

```go
func work(wg *sync.WaitGroup) {
	defer wg.Done()

	// Funksiya qaysi return yo‘lidan chiqmasin,
	// Done funksiya qaytishidan oldin chaqiriladi.
}
```

`defer` chaqiruvni funksiya tugashigacha kechiktiradi.

Shuning uchun funksiya oddiy `return` bilan qayerdan chiqishidan qat’i nazar, `Done()` bajariladi.

Bu ayniqsa bir nechta `return` mavjud funksiyalarda foydali.

Lekin bu yerda bir nozik holat bor.

Agar funksiya umuman qaytmasa, masalan abadiy bloklanib qolsa, deferred `Done()` ham bajarilmaydi.

Misol:

```go
func work(wg *sync.WaitGroup) {
	defer wg.Done()

	select {}
}
```

`select {}` abadiy bloklanadi. Funksiya tugamaydi. Demak, `Done()` ham chaqirilmaydi.

Yana bir holat — `panic`.

Agar funksiya ichida `panic` yuz bersa, stack unwind jarayonida deferred funksiyalar bajariladi. Demak, `wg.Done()` chaqirilishi mumkin.

Ammo `panic` recover qilinmasa, undan keyin dastur baribir to‘xtaydi.

## `Add`ni goroutine boshlanishidan oldin chaqiring

`WaitGroup` bilan ishlaganda eng muhim qoidalardan biri:

> Musbat `Add` chaqiruvini goroutine ishga tushirilishidan oldin bajarish kerak.

Quyidagi yozuv noto‘g‘ri:

```go
// Noto‘g‘ri misol:
// go func() {
//     wg.Add(1)
//     defer wg.Done()
//     work()
// }()
// wg.Wait()
```

Birinchi qarashda bu kod mantiqli ko‘rinishi mumkin.

Goroutine ishga tushadi, o‘zini hisoblagichga qo‘shadi, ishni bajaradi va `Done()` chaqiradi.

Lekin goroutinelar qachon bajarilishini scheduler hal qiladi.

Quyidagi ketma-ketlik yuz berishi mumkin:

```text
1. main yangi goroutineni yaratadi.
2. Yangi goroutine hali CPU olmaydi.
3. main wg.Wait()ni chaqiradi.
4. WaitGroup hisoblagichi hali 0.
5. Wait() darhol qaytadi.
6. main davom etadi yoki dastur tugaydi.
7. Yangi goroutine keyinroq Add(1)ni bajarishi mumkin.
```

Demak, `Wait()` yangi ish hisoblagichga qo‘shilmasidan oldin qaytib ketishi mumkin.

To‘g‘ri yozuv:

```go
wg.Add(1)

go func() {
	defer wg.Done()
	work()
}()
```

Bu yerda avval:

```go
wg.Add(1)
```

bajariladi.

Shundan keyingina goroutine yaratiladi.

Endi scheduler qanday tartibda ishlashidan qat’i nazar, `Wait()` kamida bitta tugallanmagan ish borligini ko‘radi.

Masalan:

```text
counter = 0

wg.Add(1)
counter = 1

goroutine ishga tushiriladi

wg.Wait()
counter hali 1 bo‘lsa, Wait kutadi

goroutine Done()
counter = 0

Wait qaytadi
```

Musbat `Add` chaqiruvi hisoblagich nol holatda turganida, tegishli `Wait()`dan oldin bajarilishi kerak.

## Hisoblagich mos kelmasa nima bo‘ladi?

`WaitGroup`ning ishlashi hisoblagichning to‘g‘ri boshqarilishiga bog‘liq.

Har bir ro‘yxatga olingan ish oxir-oqibat hisoblagichdan ayrilishi kerak.

Masalan, ikkita goroutine ishlatilsa, hisoblagichni birdan `2`ga oshirish mumkin:

```go
package main

import (
	"fmt"
	"sync"
)

func main() {
	var wg sync.WaitGroup
	wg.Add(2)

	for i := 1; i <= 2; i++ {
		go func(id int) {
			defer wg.Done()
			fmt.Println("Ish tugadi:", id)
		}(i)
	}

	wg.Wait()
	fmt.Println("Barcha ish tugadi")
}
```

Natijaning mumkin bo‘lgan ko‘rinishi:

```text
Ish tugadi: 2
Ish tugadi: 1
Barcha ish tugadi
```

Bu yerda:

```go
wg.Add(2)
```

ikkita tugallanmagan ish borligini bildiradi.

Boshlang‘ich holat:

```text
counter = 0
```

`Add(2)`dan keyin:

```text
counter = 2
```

Birinchi goroutine tugaganda:

```text
counter = 1
```

Ikkinchi goroutine tugaganda:

```text
counter = 0
```

Shundan keyin `Wait()` qaytadi.

Birinchi ikki satrning tartibi o‘zgarishi mumkin. Lekin:

```text
Barcha ish tugadi
```

doimo ishchi goroutinelardan keyin chiqadi.

Hisoblagich va `Done()` chaqiruvlari bir-biriga mos kelmasa, ikki asosiy xato yuz beradi.

### `Done()` yetarli chaqirilmasa

Misol:

```go
wg.Add(2)
wg.Done()
wg.Wait()
```

Hisoblagich quyidagicha o‘zgaradi:

```text
0 -> 2 -> 1
```

Lekin hech qachon `0`ga tushmaydi.

Shuning uchun:

```go
wg.Wait()
```

kutishda davom etadi.

Agar dasturda boshqa davom eta oladigan goroutine bo‘lmasa, runtime deadlock aniqlashi mumkin.

Ataylab noto‘g‘ri misol:

```go
// Hisoblagich nolga tushmaydi:
// wg.Add(2)
// wg.Done()
// wg.Wait() // Yana bitta Done bo‘lmagani uchun kutib qoladi.
```

### `Done()` ortiqcha chaqirilsa

Endi boshqa xatoni ko‘ramiz:

```go
wg.Add(1)
wg.Done()
wg.Done()
```

Hisoblagich:

```text
0 -> 1 -> 0 -> -1
```

`WaitGroup` hisoblagichi manfiy bo‘lishi mumkin emas.

Shuning uchun runtime panic chiqaradi:

```text
panic: sync: negative WaitGroup counter
```

Ataylab noto‘g‘ri misol:

```go
// Hisoblagich manfiy bo‘ladi:
// wg.Add(1)
// wg.Done()
// wg.Done() // panic: sync: negative WaitGroup counter
```

Muhim jihat shuki, `Add(n)`dagi `n` albatta goroutinelar soni bo‘lishi shart emas.

U mantiqiy tugallanmagan ishlar sonini ifodalaydi.

Lekin odatiy kodda bitta goroutine bitta mantiqiy ish bajarsa, quyidagi juftlik tushunarli va xavfsizroq:

```go
wg.Add(1)

go func() {
	defer wg.Done()
	// ish
}()
```

Bunday usulda `Add` va `Done`ning bir-biriga mos kelishini ko‘rish osonroq.

## Amaliy misol: fayllar hajmini parallel hisoblash

Endi `WaitGroup`ni natija yig‘ish bilan birga ishlatadigan misolni ko‘ramiz.

Quyidagi dastur bir nechta faylga oid vazifani alohida goroutinelarga bo‘ladi.

Misol haqiqiy fayl tizimiga bog‘lanib qolmasligi uchun fayl nomlari va hajmlari oldindan berilgan.

```go
package main

import (
	"fmt"
	"sync"
)

type file struct {
	name string
	size int64
}

func main() {
	files := []file{
		{name: "users.json", size: 1200},
		{name: "orders.json", size: 3400},
		{name: "report.csv", size: 800},
	}

	sizes := make([]int64, len(files))
	var wg sync.WaitGroup

	for i, item := range files {
		wg.Add(1)
		go func(index int, current file) {
			defer wg.Done()
			sizes[index] = current.size
		}(i, item)
	}

	wg.Wait()

	var total int64
	for i, item := range files {
		fmt.Printf("%s: %d bayt\n", item.name, sizes[i])
		total += sizes[i]
	}
	fmt.Println("Jami:", total, "bayt")
}
```

Natija:

```text
users.json: 1200 bayt
orders.json: 3400 bayt
report.csv: 800 bayt
Jami: 5400 bayt
```

Bu misolda bir nechta muhim jihat bor.

Avval natijalarni saqlash uchun slice yaratiladi:

```go
sizes := make([]int64, len(files))
```

`files`da uchta element bor. Demak, `sizes` ham uchta elementga ega bo‘ladi:

```text
[0 0 0]
```

Keyin har bir fayl uchun goroutine yaratiladi:

```go
for i, item := range files {
	wg.Add(1)

	go func(index int, current file) {
		defer wg.Done()
		sizes[index] = current.size
	}(i, item)
}
```

Har bir goroutine `sizes` slicening boshqa indeksiga yozadi.

Masalan:

```text
goroutine 1 -> sizes[0]
goroutine 2 -> sizes[1]
goroutine 3 -> sizes[2]
```

Shuning uchun ikki goroutine aynan bir elementga yozmayapti.

Bundan tashqari, slice uzunligi oldindan belgilangan.

Bu yerda:

```go
append(sizes, ...)
```

ishlatilmayapti.

Bu muhim, chunki bir nechta goroutine bir xil slicega concurrent `append` qilsa, slice header yoki uning underlying arrayi ustida data race yuz berishi mumkin.

Anonim funksiyaga indeks va qiymat argument sifatida uzatilgan:

```go
}(i, item)
```

va parametrlar quyidagicha qabul qilinadi:

```go
func(index int, current file)
```

Bu har bir goroutine qaysi indeks va qaysi fayl bilan ishlayotganini aniq qiladi.

Keyin:

```go
wg.Wait()
```

chaqiriladi.

`main` natijalarni faqat barcha goroutinelar tugagandan keyin o‘qiydi:

```go
for i, item := range files {
	fmt.Printf("%s: %d bayt\n", item.name, sizes[i])
	total += sizes[i]
}
```

Shu sabab worker goroutinelarning yozuvi bilan `main`ning o‘qishi bir vaqtning o‘zida sodir bo‘lmaydi.

Natijalar goroutinelar qaysi tartibda tugaganiga qarab chiqarilmaydi.

Ular `files` slice tartibida chiqariladi:

```text
users.json
orders.json
report.csv
```

Shu sabab yakuniy chiqish deterministik.

Haqiqiy dasturda esa `current.size`ni tayyor qiymatdan olish o‘rniga goroutine masalan `os.Stat` chaqirishi mumkin.

Bunday real kodda qo‘shimcha masalalar paydo bo‘ladi:

* faylni tekshirishda yuz bergan xatoni saqlash;
* bir paytda juda ko‘p fayl ochilishini cheklash;
* operatsiyani cancellation orqali to‘xtatish;
* timeout qo‘llash.

`WaitGroup` bu vazifalarning hech birini o‘zi bajarmaydi.

## `WaitGroup` nimani bajarmaydi?

`WaitGroup`ning vazifasi tor va aniq:

> U faqat ro‘yxatga olingan ishlarning tugashini kutadi.

U quyidagi vazifalarni bajarmaydi:

* goroutinedan natija qaytarmaydi;
* xatolarni avtomatik yig‘maydi;
* xatolarni boshqa goroutinega uzatmaydi;
* goroutinelarni bekor qilmaydi;
* timeout bermaydi;
* bir paytda ishlaydigan goroutinelar sonini cheklamaydi;
* umumiy `map`, slice yoki boshqa xotirani concurrent yozishdan himoya qilmaydi.

Masalan, ikkita goroutine bir xil `map`ga yozsa:

```go
var wg sync.WaitGroup
m := map[string]int{}

wg.Add(2)

go func() {
	defer wg.Done()
	m["a"] = 1
}()

go func() {
	defer wg.Done()
	m["b"] = 2
}()

wg.Wait()
```

bu yerda `WaitGroup` mavjud bo‘lsa ham, `map`ga concurrent yozish xavfsiz bo‘lib qolmaydi.

`WaitGroup` faqat ikki goroutine tugashini kutadi.

Umumiy ma’lumotni himoya qilish uchun boshqa vosita kerak bo‘ladi. Masalan:

* `sync.Mutex`;
* channel;
* goroutine ownership modeli.

Natija yoki xatoni uzatish uchun ko‘pincha channel ishlatiladi.

Bekor qilish va timeout uchun odatda:

```go
context.Context
```

ishlatiladi.

Bir vaqtning o‘zida ishlaydigan goroutinelar sonini cheklash uchun esa worker pool yoki semaphore kabi yondashuv qo‘llanadi.

> **Diqqat**
>
> `WaitGroup` ishlatilishi kodni data racedan avtomatik himoya qilmaydi. U faqat `Wait()` qaytishidan oldin ro‘yxatga olingan ishlar tugashini ta’minlaydi. Agar bir nechta goroutine bir xil xotiraga concurrent yozsa, alohida sinxronizatsiya kerak.

## Xotira ko‘rinishi va sinxronizatsiya

`WaitGroup` faqat "kutish" vositasi emas. U tegishli xotira sinxronizatsiyasi kafolatlarini ham beradi.

Soddalashtirib aytganda:

> Goroutine `Done()`dan oldin yozgan ma’lumotlar, tegishli `Wait()` qaytgach kutayotgan goroutine uchun ko‘rinadi.

Oldingi misolni eslaymiz:

```go
go func(index int, current file) {
	defer wg.Done()
	sizes[index] = current.size
}(i, item)
```

Goroutine avval:

```go
sizes[index] = current.size
```

yozuvini bajaradi.

Keyin funksiya tugayotganida:

```go
wg.Done()
```

bajariladi.

`main` esa:

```go
wg.Wait()
```

qaytgandan keyingina `sizes`ni o‘qiydi.

Oqim quyidagicha:

```text
worker:
sizes[index] = value
        |
        v
     Done()

        sinxronizatsiya

        |
        v
main:
Wait() qaytadi
        |
        v
sizes[index] o‘qiladi
```

Bu sababli `Wait()`dan keyingi o‘qish workerning oldingi yozuvini ko‘radi.

Agar `main` `sizes`ni `Wait()`dan oldin o‘qisa, boshqa vaziyat yuz beradi.

Masalan:

```go
go func() {
	sizes[0] = 10
	wg.Done()
}()

fmt.Println(sizes[0]) // juda erta o‘qilishi mumkin
wg.Wait()
```

Bu yerda `main`ning o‘qishi va workerning yozishi bir vaqtga to‘g‘ri kelishi mumkin.

Natijada data race yuz berishi ehtimoli bor.

Muhim farq:

`WaitGroup` workerlar bilan kutuvchi goroutine orasida kerakli sinxronizatsiyani beradi.

Lekin bu worker goroutinelarning o‘zaro concurrent yozuvlarini avtomatik xavfsiz qilmaydi.

Masalan:

```text
goroutine A -> x ga yozadi
goroutine B -> x ga yozadi
```

ikkalasi bir vaqtda bitta qiymatga yozsa, `WaitGroup` buning oldini olmaydi.

Bunday holatda mutex, channel yoki boshqa mos sinxronizatsiya kerak.

## `WaitGroup`ni nusxalamang

`WaitGroup` ishlatila boshlagach uni nusxalamaslik kerak.

Bu qoidaning sababini tushunish muhim.

Tasavvur qiling, `main` ichida bitta `WaitGroup` bor:

```go
var wg sync.WaitGroup
wg.Add(1)
```

Keyin uni funksiyaga qiymat sifatida yuboramiz:

```go
work(wg)
```

Agar funksiya imzosi quyidagicha bo‘lsa:

```go
func work(wg sync.WaitGroup)
```

funksiya asl `WaitGroup` bilan emas, uning nusxasi bilan ishlaydi.

Noto‘g‘ri misol:

```go
// Noto‘g‘ri: WaitGroup qiymat sifatida nusxalanadi.
// func work(wg sync.WaitGroup) {
//     defer wg.Done()
// }
```

Bu holatda taxminan quyidagi vaziyat yuz beradi:

```text
main wg:
counter = 1

work() ichidagi nusxa:
counter = 1
```

Worker:

```go
wg.Done()
```

chaqirganda faqat nusxaning hisoblagichi o‘zgaradi:

```text
worker nusxasi:
1 -> 0
```

Lekin `main`dagi asl obyekt:

```text
main wg:
counter = 1
```

holatida qoladi.

Natijada:

```go
wg.Wait()
```

qaytmay qolishi mumkin.

To‘g‘ri variant pointer qabul qiladi:

```go
func work(wg *sync.WaitGroup) {
	defer wg.Done()
}
```

Chaqirish:

```go
go work(&wg)
```

Endi `work()` ham, `main()` ham aynan bitta `WaitGroup` bilan ishlaydi.

`go vet` ayrim `WaitGroup` nusxalash holatlarini topishga yordam beradi:

```bash
go vet ./...
```

`go vet` oddiy kompilyatsiyadan o‘tadigan, lekin shubhali bo‘lishi mumkin bo‘lgan kod konstruksiyalarini statik tahlil qiladi.

Shuning uchun `WaitGroup` kabi nusxalanmasligi kerak bo‘lgan turlar bilan ishlaganda `go vet` foydali tekshiruv hisoblanadi.

## `WaitGroup`ni qayta ishlatish

Bitta `WaitGroup`ni faqat bir marta ishlatish shart emas.

Bir guruh ishlar to‘liq tugagach, uni yangi mustaqil guruh uchun qayta ishlatish mumkin.

Masalan:

```go
wg.Add(1)

go func() {
	defer wg.Done()
	// birinchi ish
}()

wg.Wait()
```

Bu yerda birinchi guruh to‘liq tugadi.

Shundan keyin:

```go
wg.Add(1)

go func() {
	defer wg.Done()
	// ikkinchi ish
}()

wg.Wait()
```

deb yana ishlatish mumkin.

Muhim shart shuki, oldingi guruhning `Wait()` chaqiruvlari hali kutayotgan paytda yangi mustaqil guruh uchun musbat `Add`larni boshlamaslik kerak.

Mantiqan guruhlar quyidagicha ajratilgan bo‘lishi kerak:

```text
1-guruh:
Add
goroutine
Done
Wait qaytadi

2-guruh:
Add
goroutine
Done
Wait qaytadi
```

Quyidagidek hayot sikli esa tushunishni qiyinlashtiradi:

```text
1-guruh Wait hali kutmoqda
        |
        +--> yangi mustaqil guruh uchun Add
```

Amaliy kodda ko‘pincha har bir alohida operatsiya uchun lokal `WaitGroup` yaratish osonroq.

Masalan:

```go
func processBatch() {
	var wg sync.WaitGroup
	// ...
}
```

Bu yondashuv `WaitGroup`ning qayerda yaratilgani va qayerda tugashini aniq ko‘rsatadi.

Uni global o‘zgaruvchi qilish yoki bir-biriga bog‘liq bo‘lmagan ishlar orasida uzoq vaqt saqlash kodning hayot siklini tushunishni qiyinlashtirishi mumkin.

## Keng tarqalgan xatolar

### `Add`ni goroutine ichida chaqirish

Noto‘g‘ri yondashuv:

```go
go func() {
	wg.Add(1)
	defer wg.Done()
	work()
}()

wg.Wait()
```

Bu yerda `Wait()` hisoblagich oshirilishidan oldin bajarilishi mumkin.

Natijada `Wait()` hisoblagichni `0` deb ko‘rib, darhol qaytadi.

To‘g‘ri yondashuv:

```go
wg.Add(1)

go func() {
	defer wg.Done()
	work()
}()
```

Asosiy qoida:

> Ishni hisoblagichga avval qo‘shing, goroutineni keyin ishga tushiring.

### `Done`ni unutish

Agar:

```go
wg.Add(1)
```

chaqirilgan bo‘lsa, tegishli ish oxir-oqibat hisoblagichni kamaytirishi kerak.

Aks holda:

```go
wg.Wait()
```

qaytmay qoladi.

Shuning uchun worker funksiyaning boshida odatda:

```go
defer wg.Done()
```

yoziladi.

Bu ayniqsa bir nechta `return` mavjud funksiyalarda foydali.

### `WaitGroup`ni qiymat sifatida uzatish

Noto‘g‘ri:

```go
func work(wg sync.WaitGroup)
```

Bu alohida nusxa yaratishi mumkin.

To‘g‘ri:

```go
func work(wg *sync.WaitGroup)
```

va:

```go
go work(&wg)
```

Ishlatila boshlangan `WaitGroup`ni nusxalamang.

### `WaitGroup` natijalarni himoya qiladi deb o‘ylash

`WaitGroup` faqat ishlarning tugashini kutadi.

Masalan, bir nechta goroutine bitta umumiy `map`ga yozsa, `WaitGroup`ning mavjudligi bu operatsiyani xavfsiz qilmaydi.

Quyidagi fikr noto‘g‘ri:

```text
WaitGroup bor -> demak concurrent yozish xavfsiz
```

To‘g‘ri tushuncha:

```text
WaitGroup bor -> barcha ro‘yxatga olingan ishlarning tugashini kutish mumkin
```

Umumiy xotirani himoya qilish uchun alohida sinxronizatsiya kerak.

### `Add` va `Done` sonini taxmin qilish

Hisoblagichni bajarilayotgan ishlar sonidan uzilib qolgan joyda boshqarish xatoga olib kelishi mumkin.

Masalan:

```go
wg.Add(10)

for _, job := range jobs {
	go ...
}
```

Agar keyinchalik `jobs` soni `10`dan farq qilsa, hisoblagich va haqiqiy ishlar soni mos kelmay qoladi.

Ko‘pincha quyidagicha yozish xavfsizroq:

```go
wg.Add(len(jobs))
```

yoki har bir ish bilan bir joyda:

```go
for _, job := range jobs {
	wg.Add(1)

	go func() {
		defer wg.Done()
		// ...
	}()
}
```

Shunda kod o‘zgarsa, hisoblagichning ishlar sonidan ajralib qolish ehtimoli kamayadi.

## Interviewda nimalarga e’tibor beriladi?

`sync.WaitGroup` haqida savol berilganda faqat uning sintaksisini bilish yetarli emas.

Quyidagi jihatlarni tushunish muhim:

* `WaitGroup` ichki hisoblagichni boshqaradi;
* `Add(n)` hisoblagichni oshiradi;
* `Done()` hisoblagichni bittaga kamaytiradi;
* hisoblagich nol bo‘lganda `Wait()` qaytadi;
* musbat `Add(1)` goroutine ishga tushirilishidan oldin bajarilishi kerak;
* `Done()` odatda `defer` bilan yoziladi;
* `Done()` yetarli bo‘lmasa `Wait()` qaytmay qolishi mumkin;
* `Done()` ortiqcha bo‘lsa hisoblagich manfiy bo‘lib, runtime panic yuz beradi;
* `WaitGroup` ishlatila boshlagach nusxalanmasligi kerak;
* helper funksiyaga odatda `*sync.WaitGroup` uzatiladi;
* `WaitGroup` natijalarni qaytarmaydi;
* u xatolarni boshqarmaydi;
* u cancellation bermaydi;
* u concurrency limitini belgilamaydi;
* u umumiy xotirani data racedan himoya qilmaydi;
* `Done()`dan oldingi yozuvlar tegishli `Wait()` qaytgach kutuvchi goroutinega ko‘rinadi;
* worker goroutinelar bir xil xotiraga concurrent yozsa, alohida sinxronizatsiya baribir talab qilinadi.

## Misollar

### 1. Bitta goroutineni kutish

Bu misol `WaitGroup`ning eng oddiy holatini ko‘rsatadi.

Bitta yordamchi goroutine ishga tushiriladi. `main()` esa uning tugashini kutadi.

```go
package main

import (
	"fmt"
	"sync"
)

func main() {
	var wg sync.WaitGroup
	wg.Add(1)

	go func() {
		defer wg.Done()
		fmt.Println("Ish bajarildi")
	}()

	wg.Wait()
	fmt.Println("main yakunlandi")
}
```

Avval:

```go
var wg sync.WaitGroup
```

orqali zero value `WaitGroup` yaratiladi.

Keyin:

```go
wg.Add(1)
```

bitta tugallanmagan ishni ro‘yxatga oladi.

Hisoblagich:

```text
0 -> 1
```

bo‘ladi.

Goroutine ichida:

```go
defer wg.Done()
```

yozilgan.

Goroutine tugaganda hisoblagich:

```text
1 -> 0
```

ga tushadi.

`main()` esa:

```go
wg.Wait()
```

orqali aynan shu holatni kutadi.

Shundan keyingina:

```text
main yakunlandi
```

chiqadi.

Bu misolning asosiy qoidasi: `Add(1)` ish boshlanishidan oldin, `Done()` esa ish tugaganda bajariladi.

### 2. Har bir ishni siklda ro‘yxatga olish

Bu misolda uchta goroutine yaratiladi.

Har bir goroutine boshlanishidan oldin tegishli ish `WaitGroup`ga qo‘shiladi.

```go
package main

import (
	"fmt"
	"sync"
)

func main() {
	var wg sync.WaitGroup

	for id := 1; id <= 3; id++ {
		wg.Add(1)

		go func(workerID int) {
			defer wg.Done()
			fmt.Println("Ishchi:", workerID)
		}(id)
	}

	wg.Wait()
}
```

Sikl uch marta ishlaydi:

```text
id = 1
id = 2
id = 3
```

Har bir aylanishda:

```go
wg.Add(1)
```

bajariladi.

Shuning uchun uchta goroutine yaratilgach hisoblagich mantiqan `3` bo‘ladi.

Har bir goroutine bir marta `Done()` chaqiradi:

```text
3 -> 2 -> 1 -> 0
```

`id` qiymati anonim funksiyaga argument sifatida uzatilgan:

```go
}(id)
```

va:

```go
func(workerID int)
```

orqali qabul qilinadi.

Bu har bir goroutine qaysi worker ID bilan ishlashini ochiq ko‘rsatadi.

`Ishchi:` satrlarining chiqish tartibi kafolatlanmaydi. Masalan, `3`, `1`, `2` tartibida chiqishi mumkin.

Bu misoldagi asosiy qoida: `Add(1)` goroutine ichida emas, `go` chaqiruvidan oldin bajariladi.

### 3. Ishlar sonini birdan qo‘shish

Har bir sikl aylanishida `Add(1)` chaqirish shart emas.

Agar ishlar soni oldindan aniq bo‘lsa, ularni birdan hisoblagichga qo‘shish mumkin.

```go
package main

import (
	"fmt"
	"sync"
)

func main() {
	files := []string{"a.txt", "b.txt", "c.txt"}

	var wg sync.WaitGroup
	wg.Add(len(files))

	for _, file := range files {
		go func(name string) {
			defer wg.Done()
			fmt.Println("Tekshirildi:", name)
		}(file)
	}

	wg.Wait()
}
```

Bu yerda:

```go
len(files)
```

qiymati:

```text
3
```

Shuning uchun:

```go
wg.Add(len(files))
```

aslida:

```go
wg.Add(3)
```

bilan bir xil natija beradi.

Hisoblagich uchta ishni kutadi.

Har bir goroutine bir marta `Done()` chaqirishi kerak.

Agar keyinchalik `files` ro‘yxatiga yangi element qo‘shilsa:

```go
files := []string{"a.txt", "b.txt", "c.txt", "d.txt"}
```

`len(files)` avtomatik ravishda `4` bo‘ladi.

Bu qattiq yozilgan:

```go
wg.Add(3)
```

dan xavfsizroq.

Bu misolning asosiy qoidasi: ishlar soni ma’lum bo‘lsa, hisoblagichni shu manbadan hisoblash mumkin.

### 4. `WaitGroup`ni helper funksiyaga pointer bilan uzatish

Bu misolda worker logikasi alohida `process()` funksiyasiga chiqarilgan.

```go
package main

import (
	"fmt"
	"sync"
)

func process(name string, wg *sync.WaitGroup) {
	defer wg.Done()
	fmt.Println("Qayta ishlandi:", name)
}

func main() {
	var wg sync.WaitGroup
	items := []string{"rasm", "video"}

	for _, item := range items {
		wg.Add(1)
		go process(item, &wg)
	}

	wg.Wait()
}
```

`process()` funksiyasi:

```go
wg *sync.WaitGroup
```

qabul qiladi.

Bu `WaitGroup` qiymat sifatida nusxalanmayotganini bildiradi.

Chaqirishda:

```go
go process(item, &wg)
```

ishlatiladi.

`&wg` — `main()` ichidagi asl `WaitGroup`ning manzili.

Shuning uchun `process()` ichidagi:

```go
wg.Done()
```

aynan `main()` kutayotgan hisoblagichni kamaytiradi.

Agar funksiya quyidagicha yozilganida:

```go
func process(name string, wg sync.WaitGroup)
```

`wg` nusxalanishi mumkin edi va worker asl hisoblagichni o‘zgartirmagan bo‘lardi.

Bu misolning asosiy qoidasi: ishlatila boshlangan `WaitGroup`ni helper funksiyaga pointer orqali uzating.

### 5. Erta qaytishda ham `Done()`ni bajarish

Bu misol `defer wg.Done()` nima uchun foydali ekanini ko‘rsatadi.

Ba’zi qiymatlar tekshiruvdan o‘tmaydi va funksiya erta `return` qiladi.

```go
package main

import (
	"fmt"
	"sync"
)

func validate(value int, wg *sync.WaitGroup) {
	defer wg.Done()

	if value < 0 {
		fmt.Println("Manfiy qiymat o‘tkazib yuborildi:", value)
		return
	}

	fmt.Println("Qabul qilindi:", value)
}

func main() {
	values := []int{5, -2, 8}

	var wg sync.WaitGroup
	wg.Add(len(values))

	for _, value := range values {
		go validate(value, &wg)
	}

	wg.Wait()
}
```

Qiymatlar:

```text
5
-2
8
```

`-2` uchun quyidagi shart bajariladi:

```go
if value < 0
```

va funksiya:

```go
return
```

bilan erta tugaydi.

Lekin `Done()` oldindan `defer` qilingan:

```go
defer wg.Done()
```

Shuning uchun erta `return` bo‘lsa ham `Done()` chaqiriladi.

Agar `Done()` faqat funksiya oxirida yozilganida:

```go
func validate(value int, wg *sync.WaitGroup) {
	if value < 0 {
		return
	}

	wg.Done()
}
```

manfiy qiymat yo‘lida u umuman bajarilmas edi.

Natijada hisoblagich nolga tushmay qolishi mumkin edi.

Bu misolning asosiy qoidasi: worker funksiyada `defer wg.Done()` erta `return` holatlarini xavfsizroq boshqaradi.

### 6. Natijalarni turli slice elementlariga yozish

Bu misolda bir nechta goroutine parallel hisob-kitob bajaradi.

Har biri natijani oldindan yaratilgan slicening boshqa indeksiga yozadi.

```go
package main

import (
	"fmt"
	"sync"
)

func main() {
	numbers := []int{2, 3, 4}
	results := make([]int, len(numbers))

	var wg sync.WaitGroup
	wg.Add(len(numbers))

	for index, number := range numbers {
		go func(i, value int) {
			defer wg.Done()
			results[i] = value * value
		}(index, number)
	}

	wg.Wait()
	fmt.Println(results)
}
```

Boshlang‘ich qiymatlar:

```text
numbers = [2 3 4]
results = [0 0 0]
```

Goroutinelar taxminan quyidagi ishlarni bajaradi:

```text
results[0] = 2 * 2
results[1] = 3 * 3
results[2] = 4 * 4
```

Natijada:

```text
[4 9 16]
```

hosil bo‘ladi.

Bu yerda har bir goroutine boshqa indeksga yozmoqda:

```text
goroutine A -> results[0]
goroutine B -> results[1]
goroutine C -> results[2]
```

`results` uzunligi oldindan belgilangan:

```go
make([]int, len(numbers))
```

Shuning uchun concurrent `append` bajarilmaydi.

`main()` esa:

```go
wg.Wait()
```

qaytmaguncha natijalarni o‘qimaydi.

Bu workerlarning yozuvi va `main`ning o‘qishini bir vaqtda bajarilishidan saqlaydi.

Bu misolning asosiy qoidasi: `WaitGroup` natijalarni o‘zi saqlamaydi, lekin barcha workerlar tugagandan keyin natijalarni o‘qish vaqtini aniqlashga yordam beradi.

### 7. `WaitGroup`ni ketma-ket bosqichlarda qayta ishlatish

Bu misolda bitta `WaitGroup` ikkita mustaqil bosqich uchun ketma-ket ishlatiladi.

```go
package main

import (
	"fmt"
	"sync"
)

func main() {
	var wg sync.WaitGroup

	wg.Add(1)
	go func() {
		defer wg.Done()
		fmt.Println("Birinchi bosqich")
	}()
	wg.Wait()

	wg.Add(1)
	go func() {
		defer wg.Done()
		fmt.Println("Ikkinchi bosqich")
	}()
	wg.Wait()
}
```

Birinchi bosqichda:

```text
Add(1)
counter = 1
```

Goroutine tugaganda:

```text
Done()
counter = 0
```

Birinchi:

```go
wg.Wait()
```

qaytadi.

Shu paytda birinchi guruh to‘liq tugagan.

Keyin ikkinchi bosqich boshlanadi:

```go
wg.Add(1)
```

Hisoblagich yana:

```text
0 -> 1
```

bo‘ladi.

Ikkinchi goroutine tugaganda:

```text
1 -> 0
```

va ikkinchi `Wait()` qaytadi.

Muhim jihat: yangi guruh birinchi guruh to‘liq tugagandan keyin boshlanmoqda.

Bu misolning asosiy qoidasi: `WaitGroup`ni qayta ishlatish mumkin, lekin oldingi guruhning kutish sikli tugagan bo‘lishi kerak.

### 8. Bir guruhni bir nechta joydan kutish

Bir nechta goroutine bitta `WaitGroup`ning `Wait()` metodini chaqirishi mumkin.

Quyidagi misolda ikki kuzatuvchi bitta worker tugashini kutadi.

```go
package main

import (
	"fmt"
	"sync"
)

func main() {
	var workers sync.WaitGroup
	var observers sync.WaitGroup

	workers.Add(1)

	go func() {
		defer workers.Done()
		fmt.Println("Asosiy ish tugadi")
	}()

	observers.Add(2)

	for id := 1; id <= 2; id++ {
		go func(observerID int) {
			defer observers.Done()

			workers.Wait()
			fmt.Println("Kuzatuvchi xabardor bo‘ldi:", observerID)
		}(id)
	}

	observers.Wait()
}
```

Bu yerda ikkita alohida `WaitGroup` bor.

Birinchisi:

```go
workers
```

asosiy worker ishini kuzatadi.

Ikkinchisi:

```go
observers
```

ikki kuzatuvchi goroutinenining tugashini kuzatadi.

Asosiy worker uchun:

```go
workers.Add(1)
```

bajariladi.

Ikki kuzatuvchi esa:

```go
workers.Wait()
```

chaqiradi.

Hisoblagich nolga tushganda ikkala `Wait()` ham davom eta oladi.

Keyin har bir kuzatuvchi:

```go
fmt.Println("Kuzatuvchi xabardor bo‘ldi:", observerID)
```

qatorini chiqaradi.

`main()` esa:

```go
observers.Wait()
```

orqali ikkala kuzatuvchi ham tugashini kutadi.

Chiqish taxminan quyidagicha bo‘lishi mumkin:

```text
Asosiy ish tugadi
Kuzatuvchi xabardor bo‘ldi: 2
Kuzatuvchi xabardor bo‘ldi: 1
```

Kuzatuvchilar tartibi kafolatlanmaydi.

Bu misolning asosiy qoidasi: bitta `WaitGroup`ni bir nechta goroutine kutishi mumkin.

### 9. Har bir tashqi ish uchun ichki guruh yaratish

Ba’zan parallel ishning o‘zi ham bir nechta parallel kichik ishga bo‘linadi.

Bunday holatda tashqi va ichki `WaitGroup`lardan foydalanish mumkin.

```go
package main

import (
	"fmt"
	"sync"
)

func section(name string, outer *sync.WaitGroup) {
	defer outer.Done()

	var inner sync.WaitGroup
	inner.Add(2)

	for part := 1; part <= 2; part++ {
		go func(number int) {
			defer inner.Done()
			fmt.Println(name, "qism", number)
		}(part)
	}

	inner.Wait()
}

func main() {
	var outer sync.WaitGroup

	outer.Add(2)

	go section("A", &outer)
	go section("B", &outer)

	outer.Wait()
}
```

`main()` ikkita tashqi ish yaratadi:

```text
section A
section B
```

Shuning uchun:

```go
outer.Add(2)
```

chaqiriladi.

Har bir `section()` ichida esa alohida lokal:

```go
var inner sync.WaitGroup
```

yaratiladi.

Muhim jihat: `A` va `B` sectionlarining `inner` qiymatlari bir-biridan mustaqil.

Har bir section ichida ikkita qism bor:

```go
inner.Add(2)
```

Keyin:

```text
A qism 1
A qism 2

B qism 1
B qism 2
```

uchun alohida goroutinelar yaratiladi.

Har bir `section()`:

```go
inner.Wait()
```

orqali o‘zining ichki ikki goroutinesini kutadi.

Faqat ular tugagach `section()` funksiyasi qaytadi.

Funksiya qaytayotganda:

```go
defer outer.Done()
```

bajariladi.

Demak, `outer` faqat section ichidagi barcha ishlar to‘liq tugagandan keyin kamayadi.

Mantiqiy tuzilma quyidagicha:

```text
outer
├── section A
│   ├── part 1
│   └── part 2
│
└── section B
    ├── part 1
    └── part 2
```

Bu misolning asosiy qoidasi: har bir yuqori darajadagi ish o‘zining lokal `WaitGroup`i orqali ichki goroutinelarni kutishi mumkin.

### 10. Bo‘sh ishlar ro‘yxatini xavfsiz kutish

`WaitGroup` zero value bilan ishlaydi. Shu sabab bajariladigan ishlar bo‘lmasa ham alohida maxsus shart yozish shart emas.

```go
package main

import (
	"fmt"
	"sync"
)

func main() {
	jobs := []string{}

	var wg sync.WaitGroup
	wg.Add(len(jobs))

	for _, job := range jobs {
		go func(name string) {
			defer wg.Done()
			fmt.Println(name)
		}(job)
	}

	wg.Wait()
	fmt.Println("Bajariladigan ish yo‘q")
}
```

Bu yerda:

```go
jobs := []string{}
```

bo‘sh slice.

Demak:

```go
len(jobs)
```

qiymati:

```text
0
```

bo‘ladi.

Shuning uchun:

```go
wg.Add(len(jobs))
```

aslida:

```go
wg.Add(0)
```

bilan teng.

Hisoblagich o‘zgarmaydi:

```text
counter = 0
```

Sikl:

```go
for _, job := range jobs
```

bir marta ham ishlamaydi.

Keyingi:

```go
wg.Wait()
```

hisoblagich allaqachon nol bo‘lgani uchun darhol qaytadi.

Natija:

```text
Bajariladigan ish yo‘q
```

Buning uchun alohida:

```go
if len(jobs) == 0 {
	// ...
}
```

tekshiruvi shart emas.

Bu misolning asosiy qoidasi: `WaitGroup` bo‘sh guruh bilan ham tabiiy ishlaydi. Hisoblagich nol bo‘lsa, `Wait()` darhol qaytadi.
