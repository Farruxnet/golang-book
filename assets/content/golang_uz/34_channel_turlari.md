# Bufersiz, buferli va yo‘nalishli channellar

Go’da barcha channellar bir xil asosiy vazifani bajaradi: bir goroutine qiymat yuboradi, boshqa goroutine esa shu qiymatni qabul qiladi.

Lekin channel qanday yaratilganiga qarab uning ishlash tartibi farq qiladi.

Asosan uchta muhim holat bor:

* **bufersiz channel** — yuboruvchi va qabul qiluvchi qiymat almashish paytida bir-birini kutadi;
* **buferli channel** — qiymatlar vaqtincha saqlanadigan cheklangan navbatga ega;
* **yo‘nalishli channel** — funksiya channel orqali faqat yuborishi yoki faqat qabul qilishi mumkinligini type darajasida belgilaydi.

Bu farqlar faqat sintaksis masalasi emas. Ular goroutinelarning qachon bloklanishiga, yuklama qanday boshqarilishiga va API qanday tuzilishiga bevosita ta’sir qiladi.

## Bufersiz channel

Channel yaratilayotganda sig‘im ko‘rsatilmasa, bufersiz channel hosil bo‘ladi:

```go
ch := make(chan int)
```

Sig‘imni aniq `0` qilib berish ham xuddi shu natijani beradi:

```go
other := make(chan int, 0)
```

Demak, quyidagi ikki channelning ishlash semantikasi bir xil:

```go
ch := make(chan int)
other := make(chan int, 0)
```

Bufersiz channel qiymatlarni vaqtincha saqlab turadigan navbatga ega emas.

Shuning uchun send va receive bir-biriga to‘g‘ridan-to‘g‘ri bog‘lanadi:

* send qilayotgan goroutine mos receive tayyor bo‘lguncha kutadi;
* receive qilayotgan goroutine mos send tayyor bo‘lguncha kutadi;
* ikkala tomon tayyor bo‘lganda qiymat uzatiladi.

Bu paytda ikki goroutine o‘rtasida sinxronizatsiya yuz beradi.

Boshqacha aytganda, bufersiz channelda qiymatni shunchaki “channel ichiga tashlab ketish” mumkin emas. Qiymat aynan boshqa tomon qabul qilishga tayyor bo‘lgan paytda uzatiladi.

### Misol: ish tugaganini signal qilish

Quyidagi misolda channel foydali ma’lumot tashish uchun emas, ish tugaganini bildirish uchun ishlatiladi.

```go
package main

import "fmt"

func prepare(done chan<- struct{}) {
	fmt.Println("Ma’lumot tayyorlandi")
	done <- struct{}{}
}

func main() {
	done := make(chan struct{})

	go prepare(done)
	<-done

	fmt.Println("Dastur davom etdi")
}
```

Natija:

```text
Ma’lumot tayyorlandi
Dastur davom etdi
```

Bu yerda `done` — bufersiz channel:

```go
done := make(chan struct{})
```

`prepare` alohida goroutine ichida ishlaydi:

```go
go prepare(done)
```

`main` esa quyidagi qatorda kutadi:

```go
<-done
```

Bu receive amali.

Lekin `done` bufersiz bo‘lgani uchun `main` shu joyda signal kelguncha bloklanadi.

`prepare` funksiyasi avval:

```go
fmt.Println("Ma’lumot tayyorlandi")
```

qatorini bajaradi.

Shundan keyin:

```go
done <- struct{}{}
```

orqali signal yuboradi.

`struct{}{}` bu yerda hech qanday foydali ma’lumot saqlamaydi. Uning vazifasi faqat “ish tugadi” degan signalni yetkazish.

Signal yuborilgach, `main`dagi:

```go
<-done
```

receive yakunlanadi va dastur davom etadi:

```go
fmt.Println("Dastur davom etdi")
```

Shu sabab natijada avval:

```text
Ma’lumot tayyorlandi
```

keyin esa:

```text
Dastur davom etdi
```

chiqadi.

Bufersiz channel ayniqsa quyidagi holatlarda foydali:

* ishni boshqa goroutinega topshirib, u qabul qilganini kutish;
* bajarilish tugaganini signal qilish;
* javob kelguncha kutish;
* ikki goroutine orasida aniq sinxronizatsiya nuqtasi yaratish.

### Qabul qiluvchisiz send

Bufersiz channelga qiymat yuborish uchun receive tomoni ham mavjud bo‘lishi kerak.

Masalan:

```go
package main

func main() {
	ch := make(chan int)
	ch <- 10
}
```

Bu dastur muvaffaqiyatli tugamaydi.

`ch` bufersiz:

```go
ch := make(chan int)
```

Keyin `main` quyidagi sendni bajarishga urinadi:

```go
ch <- 10
```

Lekin hech qayerda:

```go
<-ch
```

yoki unga teng receive amali mavjud emas.

Shuning uchun `main` sendda bloklanadi.

Dasturdagi yagona goroutine ham bloklangani uchun Go runtime deadlock holatini aniqlaydi va dastur xato bilan tugaydi.

Bu yerda muhim qoida shunday:

> Bufersiz channelga send mos receive tayyor bo‘lmaguncha tugamaydi.

## Buferli channel

Channelga musbat sig‘im berilsa, buferli channel hosil bo‘ladi:

```go
ch := make(chan int, 3)
```

Bu yerda `3` — channel buferining sig‘imi.

Demak, channel vaqtincha uchta qiymatni navbatda saqlay oladi.

Buferli channelda send va receive quyidagicha ishlaydi:

* buferda bo‘sh joy bo‘lsa, send qabul qiluvchini kutmasdan tugashi mumkin;
* bufer to‘lsa, keyingi send joy bo‘shaguncha bloklanadi;
* buferda qiymat bo‘lsa, receive uni darhol olishi mumkin;
* bufer bo‘sh bo‘lsa, receive yangi qiymat kelguncha bloklanadi.

Shuning uchun bufer yuboruvchi va qabul qiluvchining ishlash tezligini ma’lum chegaragacha bir-biridan ajratadi.

Lekin bu ajratish cheksiz emas. Bufer sig‘imi qancha bo‘lsa, faqat shuncha qiymat vaqtincha navbatda turishi mumkin.

### Eng kichik misol

```go
package main

import "fmt"

func main() {
	ch := make(chan int, 2)

	ch <- 10
	ch <- 20

	fmt.Println(<-ch)
	fmt.Println(<-ch)
}
```

Natija:

```text
10
20
```

Channelning sig‘imi `2`:

```go
ch := make(chan int, 2)
```

Birinchi send:

```go
ch <- 10
```

qiymatni buferga joylaydi.

Bufer holati:

```text
[10]
```

Keyingi send:

```go
ch <- 20
```

ham tugaydi, chunki buferda hali bitta bo‘sh joy bor.

Bufer holati:

```text
[10, 20]
```

Endi bufer to‘la.

Keyin birinchi receive bajariladi:

```go
fmt.Println(<-ch)
```

Channel eng oldingi qiymatni qaytaradi:

```text
10
```

Bufer holati:

```text
[20]
```

Ikkinchi receive esa:

```text
20
```

qiymatini oladi.

Channel ichidagi qiymatlar FIFO tartibida olinadi.

**FIFO — First In, First Out**, ya’ni avval kirgan qiymat avval chiqadi.

Bu yerda muhim bir nozik jihat bor.

FIFO channelga muvaffaqiyatli yuborilgan qiymatlar tartibiga tegishli. Agar bir nechta goroutine bir paytda send qilishga urinayotgan bo‘lsa, aynan qaysi goroutine birinchi bo‘lib sendni yakunlashi schedulerga bog‘liq bo‘lishi mumkin.

Masalan, ikkita goroutine bir vaqtda:

```go
ch <- 10
```

va:

```go
ch <- 20
```

bajarayotgan bo‘lsa, Go “har doim `10` birinchi kiradi” deb kafolat bermaydi.

Lekin agar `10` channelga muvaffaqiyatli birinchi yuborilgan bo‘lsa, receive ham undan oldin `20`ni olib ketmaydi.

Channel qabul qilish tartibini muvaffaqiyatli sendlar tartibiga mos saqlaydi.

Agar bufer to‘la bo‘lsa, yangi send bloklanadi.

Masalan:

```go
// ch := make(chan int, 2)
// ch <- 10
// ch <- 20
// ch <- 30 // Bufer to‘la va qabul qiluvchi yo‘q: deadlock.
```

Bosqichma-bosqich:

```text
ch <- 10
bufer: [10]

ch <- 20
bufer: [10, 20]

ch <- 30
bufer to‘la
receive yo‘q
send bloklanadi
```

Agar boshqa goroutine bitta qiymatni olsa, masalan:

```go
<-ch
```

buferda joy ochiladi va uchinchi send davom etishi mumkin.

## Amaliy misol: cheklangan navbat

Buferli channelning eng foydali ishlatilishlaridan biri — producer va consumer orasida cheklangan navbat yaratish.

Quyidagi misolda `produce` ishlarni yaratadi, `main` esa ularni qabul qiladi.

```go
package main

import "fmt"

func produce(jobs chan<- int) {
	for job := 1; job <= 5; job++ {
		jobs <- job
	}
	close(jobs)
}

func main() {
	jobs := make(chan int, 2)

	go produce(jobs)

	for job := range jobs {
		fmt.Println("Qabul qilindi:", job)
	}
}
```

Natija:

```text
Qabul qilindi: 1
Qabul qilindi: 2
Qabul qilindi: 3
Qabul qilindi: 4
Qabul qilindi: 5
```

Bu yerda:

```go
jobs := make(chan int, 2)
```

ikki elementli bufer yaratadi.

`produce` alohida goroutine sifatida ishga tushiriladi:

```go
go produce(jobs)
```

U quyidagi siklda beshta ish yaratadi:

```go
for job := 1; job <= 5; job++ {
	jobs <- job
}
```

Buferda joy bo‘lsa, producer qabul qiluvchini kutmasdan qiymat yuborishni davom ettira oladi.

Masalan, consumer hali ishlashni boshlamagan deb tasavvur qilamiz.

Birinchi qiymat:

```text
1
```

buferga tushadi:

```text
[1]
```

Ikkinchi qiymat:

```text
2
```

ham joylashadi:

```text
[1, 2]
```

Endi bufer to‘la.

Producer:

```go
jobs <- 3
```

ga yetganda vaqtincha bloklanadi.

Consumer:

```go
for job := range jobs
```

orqali channeldan qiymat ola boshlaydi.

Bitta qiymat olingach, buferda joy ochiladi va producer yana davom etadi.

Shu tariqa producer va consumer bir-birini to‘liq kutib turmaydi, lekin ular orasidagi farq ham cheksiz oshib ketmaydi.

`produce` barcha qiymatlarni yuborgach:

```go
close(jobs)
```

orqali channelni yopadi.

Bu juda muhim.

`range`:

```go
for job := range jobs
```

channel yopilmaguncha va undagi barcha qolgan qiymatlar olinmaguncha ishlashda davom etadi.

Channel yopilganda bufer ichida qiymatlar qolgan bo‘lishi mumkin.

Masalan:

```text
[4, 5]
```

Channel yopilgan bo‘lsa ham, `range` bu ikki qiymatni olib bo‘ladi.

Faqat:

1. channel yopilgan;
2. bufer bo‘shagan

holatda `range` tugaydi.

### Backpressure

Bufer producer va consumerning tezligini vaqtincha ajratadi.

Masalan, producer soniyasiga 100 ta ish yaratayotgan, consumer esa soniyasiga 80 ta ishni qayta ishlayotgan bo‘lsin.

Dastlab bufer farqni vaqtincha yutishi mumkin.

Lekin consumer doim producerdan sekin bo‘lsa, navbat tobora to‘ladi.

Bufer sig‘imi tugagach producer yangi qiymat yubora olmaydi va bloklanadi.

Bu holat **backpressure**, ya’ni teskari bosim deb ataladi.

Oddiy ma’noda:

> Tizimning sekinroq qismi tezroq qismga “endi kut” degan bosim beradi.

Bu foydali xususiyat.

Aks holda producer cheksiz tezlikda yangi ish yaratishda davom etsa, ular xotirada cheksiz yig‘ilib borishi mumkin.

Cheklangan bufer esa navbat uchun aniq limit belgilaydi.

## Sig‘imni qanday tanlash kerak?

Bufer hajmini shunchaki katta tasodifiy son qilib tanlash to‘g‘ri yondashuv emas.

Masalan:

```go
jobs := make(chan Job, 100000)
```

yozish muammoni avtomatik hal qilmaydi.

Bufer sig‘imi aslida tizimda bir paytda navbatda qancha tugallanmagan ish bo‘lishiga ruxsat berilishini belgilaydi.

Shuning uchun sig‘imni tanlashda bir nechta savolga javob berish kerak.

### Iste’molchi qancha ishni qayta ishlay oladi?

Agar consumer yoki workerlar bir paytda faqat 10 ta ish bilan samarali ishlay olsa, juda katta navbat har doim ham foydali emas.

Navbatdagi minglab ishlar baribir kutadi.

### Yuklama vaqtincha qanchaga oshishi mumkin?

Ba’zan producer tezligi faqat qisqa vaqtga oshadi.

Masalan, odatda soniyasiga 100 ta request keladi, lekin qisqa vaqt ichida 150 taga chiqishi mumkin.

Bunday holatda bufer qisqa burstni yutish uchun foydali bo‘lishi mumkin.

### Har bir qiymat qancha xotira egallaydi?

Channel buferidagi qiymatlar xotirada saqlanadi.

Agar channel ichida kichik `int`lar bo‘lsa, masala uncha katta bo‘lmasligi mumkin.

Lekin har bir qiymat katta `struct`, slice yoki boshqa yirik obyektlarga reference saqlasa, katta bufer xotira sarfini sezilarli oshirishi mumkin.

### Navbatda uzoq turish natijani eskirtiradimi?

Ba’zi ishlar uchun eski ma’lumot foydasiz bo‘lib qoladi.

Masalan, real-time metrika yoki foydalanuvchi interfeysini yangilash hodisalari uzoq navbatda tursa, ular qayta ishlanguncha allaqachon eskirishi mumkin.

Bunday holatda katta navbat latency muammosini yashiradi, xolos.

### Tizim sekinlashganda yuboruvchi bloklanishi kerakmi?

Ba’zan producerning bloklanishi aynan kerakli xatti-harakat bo‘ladi.

Masalan, downstream servis ulgurmayotgan bo‘lsa, upstream ham tezlikni kamaytirishi kerak.

Bu backpressure’ning asosiy maqsadlaridan biri.

Juda kichik bufer esa teskari muammo tug‘dirishi mumkin.

Producer va consumer tezligi deyarli teng bo‘lsa ham, kichik navbat sabab ular keragidan ortiq ko‘p bloklanishi mumkin.

Juda katta bufer esa:

* muammoni kechroq ko‘rsatadi;
* xotira sarfini oshiradi;
* latency’ni kattalashtiradi;
* eski ishlarni uzoq vaqt navbatda ushlab turadi.

Shuning uchun avval kerakli semantikani aniqlash muhim.

Keyin haqiqiy workload bilan o‘lchash kerak.

Bufer sig‘imi performance haqidagi taxmin bilan emas, benchmark, profiling va load test natijalari bilan tekshirilgani ma’qul.

## `len` va `cap`

Channel uchun `len` va `cap` built-in funksiyalaridan foydalanish mumkin.

`cap(ch)` channel buferining umumiy sig‘imini qaytaradi.

`len(ch)` esa hozir bufer ichida nechta qiymat turganini qaytaradi.

Masalan:

```go
package main

import "fmt"

func main() {
	ch := make(chan string, 3)
	ch <- "bir"
	ch <- "ikki"

	fmt.Println("Uzunlik:", len(ch))
	fmt.Println("Sig‘im:", cap(ch))
}
```

Natija:

```text
Uzunlik: 2
Sig‘im: 3
```

Channel:

```go
ch := make(chan string, 3)
```

sabab:

```go
cap(ch)
```

natijasi:

```text
3
```

bo‘ladi.

Ikki qiymat yuborilgan:

```go
ch <- "bir"
ch <- "ikki"
```

Shuning uchun hozir buferda ikkita qiymat turibdi:

```text
["bir", "ikki"]
```

Demak:

```go
len(ch)
```

natijasi:

```text
2
```

bo‘ladi.

Bufersiz channel uchun:

```go
ch := make(chan int)
```

`cap(ch)` doim `0`.

Bu yerda `len(ch)` bilan bog‘liq muhim concurrency nozikligi bor.

Masalan:

```go
if len(ch) < cap(ch) {
	ch <- value
}
```

birinchi qarashda xavfsiz ko‘rinishi mumkin.

Go‘yoki dastur:

1. buferda joy borligini tekshiradi;
2. keyin send qiladi.

Lekin bu ikki amal atomar emas.

`len(ch)` tekshirilganidan keyin boshqa goroutine channelga qiymat yuborishi mumkin.

Masalan:

```text
1. Goroutine A: len(ch) = 1, cap(ch) = 2
2. A hali send qilmagan
3. Goroutine B channelga qiymat yuboradi
4. Bufer to‘ladi
5. Goroutine A send qiladi
6. A bloklanadi
```

Shuning uchun:

```go
if len(ch) < cap(ch)
```

keyingi send albatta bloklanmaydi degan kafolat bermaydi.

`len(ch)` faqat o‘sha aniq ondagi holatni ko‘rsatadi.

Concurrency mavjud bo‘lsa, bu ma’lumot darhol eskirishi mumkin.

Shu sabab dastur mantig‘ini odatda `len(ch)`ga bog‘lash kerak emas.

Agar bloklamaydigan send yoki receive kerak bo‘lsa, buning uchun `select` va `default` ishlatiladi.

Bu mavzu keyingi darsda ko‘rib chiqiladi.

## Yo‘nalishli channel turlari

Oddiy:

```go
chan T
```

ikki tomonlama channel hisoblanadi.

Masalan:

```go
chan int
```

uchun quyidagi ikkala amal ham mumkin:

```go
ch <- 10
```

va:

```go
value := <-ch
```

Lekin funksiya channel bilan faqat bitta yo‘nalishda ishlashi kerak bo‘lsa, type orqali bu huquqni cheklash mumkin.

Masalan:

```go
func send(out chan<- int) {
	out <- 10
}

func receive(in <-chan int) int {
	return <-in
}
```

Bu yerda:

```go
chan<- int
```

faqat send qilish mumkin bo‘lgan channel turi.

`<-` belgisi `chan`dan keyin turibdi:

```go
chan<- int
```

ya’ni qiymat channel tomonga yuboriladi.

`receive` funksiyasida esa:

```go
<-chan int
```

ishlatilgan.

Bu faqat receive qilish mumkin bo‘lgan channel.

Bu sintaksisni shunday eslab qolish mumkin:

```go
chan<- T
```

qiymat channelga qarab ketadi.

```go
<-chan T
```

qiymat channeldan tashqariga keladi.

Asosiy turlar:

* `chan<- int` — faqat yuborish uchun;
* `<-chan int` — faqat qabul qilish uchun;
* `chan int` — yuborish ham, qabul qilish ham mumkin.

Ikki tomonlama channelni yo‘nalishli parametrga uzatish mumkin.

Masalan:

```go
ch := make(chan int, 1)
send(ch)
fmt.Println(receive(ch))
```

`ch`ning turi:

```go
chan int
```

Lekin `send` funksiyasi faqat:

```go
chan<- int
```

qabul qiladi.

Go bu yerda ikki tomonlama channelni faqat yuborish huquqiga ega ko‘rinishga avtomatik toraytiradi.

Xuddi shu channel keyin:

```go
receive(ch)
```

orqali faqat receive qiluvchi parametrga ham uzatilishi mumkin.

Buning foydasi — funksiya faqat kerakli amalni bajara oladi.

Masalan:

```go
func send(out chan<- int) {
	out <- 10
}
```

ichida quyidagi kodni yozib bo‘lmaydi:

```go
value := <-out
```

Bu compile-time xato bo‘ladi.

Xuddi shunday:

```go
func receive(in <-chan int) int
```

ichida:

```go
in <- 10
```

yozib bo‘lmaydi.

Bu xatoni runtime’da emas, compile time’da aniqlash imkonini beradi.

Yo‘nalishli channel API niyatini ham aniq ko‘rsatadi.

Masalan:

```go
func produce(out chan<- Job)
```

signature’ni ko‘rgan dasturchi funksiya `out`dan qiymat o‘qimasligini darhol tushunadi.

### Channelni yopish va yo‘nalish

Faqat receive qilish uchun berilgan channelni yopib bo‘lmaydi.

Masalan, quyidagi funksiya ichida:

```go
func consume(in <-chan int) {
	close(in) // compile-time xato
}
```

`close(in)` ruxsat etilmaydi.

Sababi `in` faqat receive uchun berilgan.

Channelni yopish esa yuboruvchi tomonning mas’uliyatiga tegishli amal.

Shuning uchun `close` uchun send qilish huquqiga ega channel kerak:

```go
chan T
```

yoki:

```go
chan<- T
```

Odatda channelni yangi qiymat boshqa yuborilmasligini biladigan producer yopadi.

## Qaysi channel turini tanlash kerak?

Quyidagi jadval asosiy holatlarni umumlashtiradi.

| Holat                                                                 | Mos tanlov          |
| --------------------------------------------------------------------- | ------------------- |
| Yuboruvchi va qabul qiluvchi aynan almashuv paytida uchrashishi kerak | Bufersiz channel    |
| Qisqa yuklama sakrashini cheklangan navbatda ushlash kerak            | Buferli channel     |
| Funksiya faqat qiymat ishlab chiqaradi                                | `chan<- T` parametr |
| Funksiya faqat qiymat iste’mol qiladi                                 | `<-chan T` parametr |

Bu yerda “bufersiz channel sekin, buferli channel tez” degan umumiy qoida yo‘q.

Buferli channel ba’zi workloadlarda throughputni yaxshilashi mumkin.

Boshqa holatda esa u faqat ortiqcha navbat, latency va xotira sarfi keltirib chiqarishi mumkin.

Bufersiz channelning aniq sinxronizatsiyasi esa ba’zi algoritmlarda aynan kerakli semantika bo‘lishi mumkin.

Shuning uchun tanlovni faqat performance taxmini asosida qilish kerak emas.

Avval savol quyidagicha bo‘lishi kerak:

> Bu yerda yuboruvchi va qabul qiluvchi o‘rtasida qanday semantika kerak?

Keyin:

> Navbat kerakmi?

> Agar kerak bo‘lsa, qancha hajmda?

> Yuboruvchi qachon bloklanishi kerak?

Performance farqi esa aniq workload bilan benchmark orqali o‘lchanishi kerak.

## Keng tarqalgan xatolar

### Bufer deadlockni butunlay yo‘q qiladi deb o‘ylash

Bufer sendni receive’dan faqat o‘z sig‘imigacha ajratadi.

Masalan:

```go
ch := make(chan int, 2)

ch <- 1
ch <- 2
ch <- 3
```

birinchi ikkita send tugashi mumkin.

Lekin uchinchi send:

```go
ch <- 3
```

buferda joy yo‘qligi sabab bloklanadi.

Agar receive qiluvchi hech qachon ishlamasa, dastur deadlockka tushishi mumkin.

Demak, bufer deadlock muammosini avtomatik yo‘q qilmaydi.

Goroutinelarning hayot sikli, channel yopilishi va send/receive oqimi baribir to‘g‘ri tashkil qilinishi kerak.

### Buferni cheksiz kattalashtirish

Katta bufer sekin consumer muammosini tuzatmaydi.

U faqat muammo ko‘rinadigan vaqtni kechiktiradi.

Masalan, consumer producerdan doim sekin bo‘lsa:

```text
producer tezligi > consumer tezligi
```

navbat baribir to‘lib boradi.

Farq faqat shunda:

* kichik bufer tezroq to‘ladi;
* katta bufer keyinroq to‘ladi.

Katta bufer shu vaqt ichida ko‘proq xotira ishlatadi va ishlarning navbatda kutish vaqtini oshiradi.

Shuning uchun tizimga mos aniq limit va backpressure mexanizmi belgilash kerak.

### FIFO global bajarilish tartibini beradi deb o‘ylash

Channel FIFO bo‘lsa ham, bu barcha goroutinelar global qat’iy tartibda ishlaydi degani emas.

Masalan:

```go
go func() {
	ch <- 1
}()

go func() {
	ch <- 2
}()
```

bu kodda aynan qaysi goroutine birinchi send qilishini scheduler hal qiladi.

Natija ba’zi ishga tushirishlarda:

```text
1
2
```

bo‘lishi mumkin.

Boshqa safar:

```text
2
1
```

bo‘lishi ham mumkin.

FIFO shuni kafolatlaydi:

> Qaysi qiymat channelga oldin muvaffaqiyatli yuborilgan bo‘lsa, u oldin qabul qilinadi.

Lekin turli goroutinelarning qaysi biri birinchi send qilishini channel kafolatlamaydi.

### `len(ch)` bilan sinxronizatsiya qilish

Quyidagi yondashuv xavfsiz sinxronizatsiya emas:

```go
if len(ch) > 0 {
	value := <-ch
	_ = value
}
```

`len(ch)` tekshiruvdan keyin boshqa goroutine channeldan qiymatni olib ketishi mumkin.

Shunda bu goroutine:

```go
<-ch
```

amalida bloklanishi mumkin.

Xuddi shu muammo send tomonida ham bor.

Shuning uchun `len` natijasiga qarab keyingi channel amali bloklanmaydi deb xulosa qilish kerak emas.

Bunday qarorni `select` orqali bitta channel amali sifatida ifodalash kerak.

### Funksiya parametrida ortiqcha huquq berish

Agar funksiya faqat send qilsa:

```go
func produce(ch chan int)
```

deb yozish texnik jihatdan mumkin.

Lekin bu funksiya ichida receive qilishga ham ruxsat beradi.

Masalan:

```go
value := <-ch
```

kompilyatsiyadan o‘tadi.

Agar funksiya aslida faqat producer bo‘lsa, to‘g‘riroq signature:

```go
func produce(ch chan<- int)
```

bo‘ladi.

Xuddi shunday consumer uchun:

```go
func consume(ch <-chan int)
```

yozish ma’qul.

Bu APIga eng tor kerakli huquqni beradi va tasodifiy noto‘g‘ri foydalanishning oldini oladi.

## Interviewda nimalarga e’tibor beriladi?

Interview savollarida ko‘pincha sintaksisdan ko‘ra channelning bloklanish semantikasini tushunish muhimroq bo‘ladi.

Quyidagi nuqtalarni aniq bilish kerak:

* bufersiz send mos receive tayyor bo‘lguncha bloklanadi;
* bufersiz receive mos send tayyor bo‘lguncha bloklanadi;
* buferli send faqat buferda joy boricha qabul qiluvchisiz davom etishi mumkin;
* bufer to‘lsa, send yana bloklanadi;
* bufer bo‘sh bo‘lsa, receive yangi qiymat kelguncha bloklanadi;
* channel FIFO tartibini saqlaydi;
* FIFO turli goroutinelarning scheduler tartibini kafolatlamaydi;
* bufer cheklangan navbat yaratish va backpressure hosil qilish vositasi;
* `len(ch)` faqat o‘sha ondagi holatni ko‘rsatadi va sinxronizatsiya kafolati bermaydi;
* `chan<- T` faqat yuborish uchun;
* `<-chan T` faqat qabul qilish uchun;
* faqat receive channelni `close` qilib bo‘lmaydi;
* channel sig‘imi shunchaki “tezroq ishlasin” degan taxmin bilan tanlanmaydi;
* sig‘im kerakli semantika, xotira limiti, latency talabi va real o‘lchov asosida tanlanadi.

Keyingi mavzuda bir nechta send va receive amallari orasidan ayni paytda bajarishga tayyorini tanlash uchun `select` operatori ishlatiladi.
