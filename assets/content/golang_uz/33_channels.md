# Go’da channel bilan ishlash

Channel — goroutinelar orasida ma’lum turdagi qiymatlarni uzatish vositasi. U faqat ma’lumot yuborish uchun emas, goroutinelarning ishini bir-biri bilan sinxronlashtirish uchun ham ishlatiladi.

Oddiy qilib aytganda, bir goroutine channelga qiymat yuboradi, boshqa goroutine esa shu qiymatni qabul qiladi.

Masalan, bir nechta goroutine turli tashqi APIlardan ma’lumot olayotgan bo‘lsin. Har bir goroutine o‘z natijasini umumiy `map`ga yozishi mumkin. Lekin bir nechta goroutine bitta `map`ga bir vaqtda yozsa, alohida sinxronizatsiya kerak bo‘ladi.

Buning o‘rniga har bir goroutine o‘z natijasini channel orqali bitta yig‘uvchi goroutinega yuborishi mumkin. Shunda umumiy ma’lumotga bir nechta goroutine bir vaqtda yozishi zarurati kamayadi.

Bu yerda muhim bir nozik joy bor. Channel orqali pointer, slice, map yoki boshqa reference xususiyatiga ega qiymatlarni ham yuborish mumkin. Channel bunday qiymatning yuborilishi va qabul qilinishini sinxronlashtiradi.

Lekin channel yuborilgan obyektning ichidagi ma’lumotni avtomatik himoya qilmaydi.

Masalan, channel orqali bir obyektga pointer yuborildi. Keyin yuboruvchi goroutine ham, qabul qiluvchi goroutine ham o‘sha obyektni bir vaqtda o‘zgartirsa, `data race` yuz berishi mumkin.

Demak:

* channel qiymat uzatishni sinxronlashtiradi;
* lekin yuborilgan obyektning keyingi concurrent mutation holatini avtomatik himoya qilmaydi.

## Channel yaratish

Channel turi `chan` kalit so‘zi va channel orqali uzatiladigan element turi bilan yoziladi:

```go
var ch chan int
```

Bu yerda `ch` o‘zgaruvchisining turi `chan int`.

Bu shuni anglatadiki, channel orqali `int` qiymatlar yuboriladi va qabul qilinadi.

Lekin yuqoridagi kod hali ishlaydigan channel yaratmaydi. `ch`ning qiymati `nil` bo‘ladi.

Amalda ishlatiladigan channel odatda `make` yordamida yaratiladi:

```go
ch := make(chan int)
```

Bu kod `int` qiymatlar bilan ishlaydigan bufersiz channel yaratadi.

`chan int` faqat `int` qiymatlarni qabul qiladi. Masalan, quyidagi kod compile time xatosiga olib keladi:

```go
ch := make(chan int)

// ch <- "salom" // compile error
```

Sababi `"salom"` qiymati `string` turida, channel esa `int` qiymatlarni kutmoqda.

Demak, channel tur xavfsiz. Qaysi tur ko‘rsatilgan bo‘lsa, faqat shu turdagi qiymatlar yuboriladi.

Channel yaratish uchun hech qanday alohida paket import qilish kerak emas. `make` — Go tilining built-in funksiyasi.

## Yuborish va qabul qilish

Channel bilan ishlashda `<-` operatori ishlatiladi.

Qiymat yuborish:

```go
ch <- value
```

Bu yerda `value` qiymati `ch` channeliga yuboriladi.

Qiymat qabul qilish:

```go
value := <-ch
```

Bu yerda `ch` channelidan qiymat olinib, `value` o‘zgaruvchisiga yoziladi.

`<-` belgisi qiymat qaysi tomonga oqayotganini ko‘rsatadi.

Quyidagi kodda:

```go
ch <- value
```

qiymat `value`dan channel tomonga ketmoqda.

Quyidagi kodda esa:

```go
value := <-ch
```

qiymat channeldan `value` tomon kelmoqda.

Yuborish va qabul qilish operatsiyalari bloklovchi bo‘lishi mumkin.

Ayniqsa bufersiz channelda send va receive bir-birini kutadi.

Masalan, goroutine quyidagi qatorga keldi:

```go
ch <- 10
```

Agar shu paytda hech bir goroutine `ch`dan qiymat olishga tayyor bo‘lmasa, yuboruvchi goroutine shu qatorda kutadi.

Xuddi shuningdek:

```go
value := <-ch
```

qatori bajarilganda hali hech kim qiymat yubormagan bo‘lsa, qabul qiluvchi goroutine kutadi.

Bufersiz channelda send va receive bir nuqtada uchrashganda qiymat uzatiladi. Shundan keyin ikkala goroutine ham davom etishi mumkin.

Shu sabab channel faqat ma’lumot uzatmaydi. U goroutinelar orasida sinxronizatsiya ham hosil qiladi.

## Birinchi misol

Quyidagi misolda alohida goroutine sonning kvadratini hisoblaydi va natijani channel orqali `main` goroutinega yuboradi:

```go
package main

import "fmt"

func square(number int, results chan<- int) {
	results <- number * number
}

func main() {
	results := make(chan int)

	go square(6, results)
	value := <-results

	fmt.Println("Natija:", value)
}
```

Natija:

```text
Natija: 36
```

Kod qanday ishlashini bosqichma-bosqich ko‘ramiz.

Avval `main` ichida channel yaratiladi:

```go
results := make(chan int)
```

Bu bufersiz `int` channel.

Keyin `square` funksiyasi yangi goroutineda ishga tushiriladi:

```go
go square(6, results)
```

`square` funksiyasining ikkinchi parametri quyidagicha yozilgan:

```go
results chan<- int
```

`chan<- int` — faqat qiymat yuborishga ruxsat berilgan channel turi.

Ya’ni `square` funksiyasi `results` channeliga qiymat yubora oladi:

```go
results <- number * number
```

Lekin shu parametr orqali qiymat qabul qilishga ruxsat yo‘q.

Bu yo‘nalishli channel ishlatishning foydasi shundaki, funksiya channel bilan qanday ishlashi kerakligi signature’ning o‘zida ko‘rinib turadi.

`6 * 6` hisoblangach, `36` qiymati channelga yuboriladi.

Bu vaqtda `main` goroutine quyidagi qatorda kutmoqda:

```go
value := <-results
```

`main` channelga qiymat kelmaguncha davom etmaydi.

`square` goroutine qiymat yuborishga kelganda send va receive bir-biri bilan uchrashadi:

```text
square goroutine:

results <- 36
       |
       | qiymat uzatiladi
       v
main goroutine:

value := <-results
```

Natijada `value` qiymati `36` bo‘ladi.

Keyin:

```go
fmt.Println("Natija:", value)
```

quyidagini chiqaradi:

```text
Natija: 36
```

Bu misolda alohida `WaitGroup` kerak emas.

Sababi `main` natijani channeldan olish uchun baribir kutmoqda. Natijaning qabul qilinishi `square` goroutine natijani hisoblab, channelga yuborish bosqichigacha yetib kelganini kafolatlaydi.

Demak, channelning o‘zi bu yerda kerakli sinxronizatsiyani ta’minlayapti.

## Bir nechta natijani yig‘ish

Endi bir nechta goroutine bir vaqtda ishlaydigan misolni ko‘ramiz.

Quyidagi dastur uchta son uchun kvadrat hisoblaydi. Har bir hisob alohida goroutineda bajariladi.

Natijalar bitta channelga yuboriladi:

```go
package main

import (
	"fmt"
	"sync"
)

type result struct {
	number int
	square int
}

func calculate(number int, results chan<- result, wg *sync.WaitGroup) {
	defer wg.Done()

	results <- result{
		number: number,
		square: number * number,
	}
}

func main() {
	numbers := []int{2, 3, 4}
	results := make(chan result)

	var wg sync.WaitGroup

	for _, number := range numbers {
		wg.Add(1)
		go calculate(number, results, &wg)
	}

	go func() {
		wg.Wait()
		close(results)
	}()

	values := make(map[int]int, len(numbers))

	for item := range results {
		values[item.number] = item.square
	}

	for _, number := range numbers {
		fmt.Printf("%d ning kvadrati: %d\n", number, values[number])
	}
}
```

Natija:

```text
2 ning kvadrati: 4
3 ning kvadrati: 9
4 ning kvadrati: 16
```

Avval natijani ifodalovchi `result` struct yaratilgan:

```go
type result struct {
	number int
	square int
}
```

Har bir natijada ikkita ma’lumot saqlanadi:

* qaysi son hisoblangan;
* uning kvadrati nechaga teng.

Masalan:

```go
result{
	number: 3,
	square: 9,
}
```

`calculate` funksiyasi bitta sonni qabul qiladi:

```go
func calculate(number int, results chan<- result, wg *sync.WaitGroup)
```

`results chan<- result` bu funksiya `result` qiymatlarini faqat channelga yuborishini bildiradi.

`wg *sync.WaitGroup` esa ish tugaganini `main`ga bildirish uchun ishlatiladi.

Funksiya boshida:

```go
defer wg.Done()
```

yozilgan.

Bu `calculate` funksiyasi tugaganda `wg.Done()` chaqirilishini kafolatlaydi.

Keyin natija hisoblanib, channelga yuboriladi:

```go
results <- result{
	number: number,
	square: number * number,
}
```

`main` ichida:

```go
numbers := []int{2, 3, 4}
```

uchta son bor.

Loop har biri uchun goroutine ishga tushiradi:

```go
for _, number := range numbers {
	wg.Add(1)
	go calculate(number, results, &wg)
}
```

Har bir goroutine boshlanishidan oldin:

```go
wg.Add(1)
```

chaqiriladi.

Demak, `WaitGroup` uchta ish tugashini kutadi.

Bu yerda muhim bir savol paydo bo‘ladi: `results` channelini kim va qachon yopadi?

Channelni barcha ishchilar tugagandan keyin yopish kerak.

Shu sabab alohida goroutine yaratilgan:

```go
go func() {
	wg.Wait()
	close(results)
}()
```

Bu goroutine:

1. barcha `calculate` goroutinelari tugashini kutadi;
2. keyin `results` channelini yopadi.

Asosiy `main` goroutine esa shu vaqtda natijalarni qabul qiladi:

```go
for item := range results {
	values[item.number] = item.square
}
```

`range` channel yopilmaguncha va undagi barcha qiymatlar olinmaguncha ishlashda davom etadi.

Masalan, natijalar channelga quyidagi tartibda kelishi mumkin:

```text
4 -> 16
2 -> 4
3 -> 9
```

yoki:

```text
3 -> 9
4 -> 16
2 -> 4
```

Goroutinelarning qaysi biri birinchi tugashiga kafolat yo‘q.

Shuning uchun natijalar `map`ga yig‘iladi:

```go
values[item.number] = item.square
```

Keyin chiqarishda `numbers` slice tartibidan foydalaniladi:

```go
for _, number := range numbers {
	fmt.Printf("%d ning kvadrati: %d\n", number, values[number])
}
```

Shu sabab channelga natijalar turli tartibda kelgan bo‘lsa ham, ekrandagi natija doim quyidagi tartibda chiqadi:

```text
2 ning kvadrati: 4
3 ning kvadrati: 9
4 ning kvadrati: 16
```

Bu misolda juda muhim deadlock holati ham bor.

Agar quyidagicha yozilganida:

```go
wg.Wait()

for item := range results {
	// ...
}
```

muammo yuz berishi mumkin edi.

Sababni bosqichma-bosqich ko‘ramiz.

`results` bufersiz channel:

```go
results := make(chan result)
```

Har bir worker:

```go
results <- result{...}
```

qatorida qiymat yuborishga harakat qiladi.

Lekin bufersiz channelda send ishlashi uchun bir vaqtning o‘zida receiver ham kerak.

Agar `main` avval:

```go
wg.Wait()
```

qilib tursa, u natijalarni qabul qilishni hali boshlamaydi.

Shunda holat quyidagicha bo‘ladi:

```text
worker goroutinelar:
    results <- ...
    qabul qiluvchini kutmoqda

main:
    wg.Wait()
    workerlar tugashini kutmoqda
```

Workerlar qiymat yubora olmagani uchun `Done()`gacha yetib bormaydi.

`main` esa workerlar `Done()` qilishini kutmoqda.

Natijada ular bir-birini kutib qoladi.

Shu sabab `wg.Wait()` va `close(results)` alohida goroutineda bajarilgan.

Bu vaqtning o‘zida `main` `range` orqali qiymatlarni qabul qilib turadi.

## Channelni yopish

Channelni quyidagicha yopish mumkin:

```go
close(ch)
```

`close(ch)`ning ma’nosi:

> Bu channel orqali boshqa yangi qiymat yuborilmaydi.

Channelni yopish uni xotiradan o‘chirib tashlamaydi.

Shuningdek, `close` qabul qiluvchi goroutinelarni "to‘xtat" degan buyruq ham emas.

U faqat channelga boshqa send bo‘lmasligini bildiradi.

Channelni odatda qiymat ishlab chiqaruvchi tomon yopadi.

Masalan:

```text
producer -> channel -> consumer
```

Bu holatda producer boshqa qiymat yubormasligini biladi. Shuning uchun channelni yopish mas’uliyati odatda producer tomonda bo‘ladi.

Agar bir nechta producer bo‘lsa:

```text
producer 1 \
producer 2  -> channel -> consumer
producer 3 /
```

alohida muvofiqlashtiruvchi goroutine ularning barchasi tugaganini kutib, keyin channelni yopishi mumkin.

Oldingi misoldagi:

```go
go func() {
	wg.Wait()
	close(results)
}()
```

aynan shu vazifani bajargan.

Consumer odatda channelni yopmasligi kerak.

Sababi consumer boshqa producerlar hali qiymat yuboradimi yoki yo‘qmi, har doim ham bilmaydi.

Agar consumer channelni erta yopsa va producer keyin:

```go
ch <- value
```

qilsa, dastur panic qiladi.

Yopilgan channel bilan ishlashda bir nechta muhim qoida bor.

### Buferda qolgan qiymatlar olinadi

Agar buferli channel yopilsa, undagi qiymatlar yo‘qolmaydi.

Masalan:

```go
ch := make(chan int, 2)

ch <- 10
ch <- 20
close(ch)
```

Channel yopilgan bo‘lsa ham:

```go
fmt.Println(<-ch)
fmt.Println(<-ch)
```

avval:

```text
10
20
```

qiymatlarini beradi.

### Qiymatlar tugagach zero value qaytadi

Channel yopilgan va unda boshqa qiymat qolmagan bo‘lsa, receive bloklanmaydi.

U element turining `zero value` qiymatini darhol qaytaradi.

Masalan, `chan int` uchun zero value:

```text
0
```

`chan string` uchun:

```text
""
```

`chan bool` uchun:

```text
false
```

### Yopiq channelga yuborish panic qiladi

Quyidagi kod noto‘g‘ri:

```go
ch := make(chan int)
close(ch)

ch <- 10
```

`ch` allaqachon yopilgan. Unga yana qiymat yuborish runtime panic keltiradi.

### Channelni ikkinchi marta yopish panic qiladi

Quyidagi kod ham noto‘g‘ri:

```go
ch := make(chan int)

close(ch)
close(ch)
```

Bir channel faqat bir marta yopilishi mumkin.

Ikkinchi `close(ch)` panic keltiradi.

### `nil` channelni yopish panic qiladi

Masalan:

```go
var ch chan int

close(ch)
```

Bu yerda `ch == nil`.

`nil` channelni yopishga urinish panic keltiradi.

### Channel yopilganini qanday aniqlash mumkin?

Muammo shundaki, yopilgan channel receive operatsiyasida zero value qaytaradi.

Masalan:

```go
value := <-ch
```

`value == 0` chiqdi deb tasavvur qilamiz.

Bu ikkita narsadan biri bo‘lishi mumkin:

1. channel orqali haqiqatan `0` yuborilgan;
2. channel yopilgan va qiymatlar tugagan.

Shu ikki holatni ajratish uchun ikki qiymatli receive ishlatiladi:

```go
value, ok := <-ch
```

Masalan:

```go
value, ok := <-ch
if !ok {
	// Channel yopilgan va unda boshqa qiymat yo‘q.
}
```

Bu yerda `ok` channel holatini bildiradi.

Agar:

```text
ok == true
```

bo‘lsa, `value` haqiqiy channel qiymati.

Agar:

```text
ok == false
```

bo‘lsa, channel yopilgan va unda olinadigan boshqa qiymat yo‘q.

Bu holatda `value` element turining zero value qiymati bo‘ladi.

Masalan:

```go
value, ok := <-ch
```

natijasi:

```text
value = 0
ok = false
```

bo‘lishi mumkin.

Shuning uchun faqat:

```go
if value == 0 {
	// channel yopilgan
}
```

deb tekshirish noto‘g‘ri.

Chunki `0` haqiqiy ma’lumot sifatida ham yuborilgan bo‘lishi mumkin.

## `range` bilan qabul qilish

Channeldan qiymatlarni ketma-ket olish uchun `range` juda qulay:

```go
for value := range ch {
	fmt.Println(value)
}
```

Bu sikl channel orqali kelgan qiymatlarni bittadan qabul qiladi.

Masalan:

```go
ch <- 10
ch <- 20
ch <- 30
close(ch)
```

bo‘lsa, `range`:

```text
10
20
30
```

qiymatlarini oladi.

Channel yopilib, undagi barcha qiymatlar tugagach sikl avtomatik tugaydi.

Bu aslida `value, ok := <-ch` yordamida yoziladigan siklning qulayroq ko‘rinishiga o‘xshaydi.

Mantiqan quyidagiga yaqin:

```go
for {
	value, ok := <-ch
	if !ok {
		break
	}

	fmt.Println(value)
}
```

Bu yerda muhim bir nozik joy bor.

`range` ishlatilayotgan channel yopilmasa, sikl keyingi qiymatni kutishda davom etishi mumkin.

Masalan:

```go
for value := range ch {
	fmt.Println(value)
}
```

channelga barcha qiymatlar yuborildi, lekin `close(ch)` qilinmadi.

Sikl "boshqa qiymat bo‘lmaydi" degan signalni olmaydi. Shuning uchun keyingi receive’da kutib qoladi.

Lekin bundan "har bir channelni albatta yopish kerak" degan qoida kelib chiqmaydi.

Channelni faqat qabul qiluvchi oqim tugaganini bilishi kerak bo‘lganda yopish zarur.

Masalan, channel dastur davomida doimiy ishlatiladigan event oqimi bo‘lsa, uni ma’lum bir nuqtada yopish shart bo‘lmasligi mumkin.

## `nil` channel

Channel turining zero value qiymati `nil`.

Masalan:

```go
var ch chan int
```

Bu yerda:

```go
ch == nil
```

bo‘ladi.

`nil` channel ishlaydigan, lekin bo‘sh channel emas.

Bu ikki holatni aralashtirmaslik kerak.

Quyidagi channel haqiqiy channel:

```go
ch := make(chan int)
```

Hozir unda qiymat bo‘lmasa ham, boshqa goroutine paydo bo‘lib send yoki receive qilsa, operatsiya davom etishi mumkin.

Lekin:

```go
var ch chan int
```

bilan yaratilgan `nil` channelda send va receive doimiy bloklanadi.

Masalan:

```go
var ch chan int

ch <- 10
```

Bu send hech qachon muvaffaqiyatli tugamaydi.

Chunki `nil` channelning qarshi tomonida receive ishlashi mumkin bo‘lgan real channel strukturasining o‘zi yo‘q.

Xuddi shuningdek:

```go
var ch chan int

value := <-ch
```

receive ham doimiy bloklanadi.

Noto‘g‘ri misol:

```go
// Noto‘g‘ri misol: hech qachon davom etmaydi.
// var ch chan int
// ch <- 10
```

Bu xatti-harakat ba’zan ataylab ishlatiladi.

Masalan, `select` ichida ma’lum bir case’ni vaqtincha o‘chirish uchun channel o‘zgaruvchisini `nil` qilish mumkin.

Sababi `nil` channelga send yoki receive hech qachon tayyor holatga kelmaydi.

Bu usul `select` mavzusida batafsil ko‘rib chiqiladi.

## Channel va xotira sinxronizatsiyasi

Channelning muhim vazifalaridan biri xotira ko‘rinishini sinxronlashtirishdir.

Oddiy ma’noda, bir goroutine senddan oldin biror ma’lumotni yozgan bo‘lsa va boshqa goroutine shu sendga mos receive’ni bajarsa, receive tugagandan keyin u oldingi yozuvlarni ko‘rishi mumkin.

Masalan:

```go
data := 0
ch := make(chan struct{})

go func() {
	data = 42
	ch <- struct{}{}
}()

<-ch
fmt.Println(data)
```

Bu yerda worker avval:

```go
data = 42
```

qiladi.

Keyin:

```go
ch <- struct{}{}
```

orqali signal yuboradi.

`main` esa:

```go
<-ch
```

signalni qabul qiladi.

Channel orqali yuz bergan sinxronizatsiya sabab receive tugaganidan keyin workerning senddan oldingi yozuvlari qabul qiluvchi tomonda ko‘rinadigan bo‘ladi.

Bu yerda channel orqali `42`ning o‘zi yuborilmagan. Faqat signal yuborilgan.

Shunga qaramay, send va receive goroutinelar o‘rtasida kerakli synchronization point yaratadi.

Lekin bundan bitta obyektni keyinchalik ikki goroutine bir paytda o‘zgartirishi mumkin degan xulosa chiqmaydi.

Masalan:

```go
items := []int{1, 2, 3}
ch := make(chan []int)

go func() {
	ch <- items
}()
```

Slice channel orqali yuborildi.

Lekin slice butun backing arrayni chuqur nusxalab yubormaydi. Yuboruvchi va qabul qiluvchi bir xil backing arrayga murojaat qilishi mumkin.

Agar keyin ikkala goroutine bir paytda:

```go
items[0] = ...
```

kabi yozuv qilsa, `data race` yuz berishi mumkin.

Shuning uchun amaliy qoida sifatida quyidagi yondashuv foydali:

> Qiymat channel orqali yuborilgandan keyin uning egaligini qabul qiluvchiga topshiring.

Ya’ni sender yuborgandan keyin o‘sha mutable ma’lumotni qayta o‘zgartirmasin.

Agar ma’lumot bir nechta goroutine tomonidan umumiy ishlatilishi kerak bo‘lsa, concurrent mutationni `mutex` yoki boshqa mos sinxronizatsiya vositasi bilan himoya qilish kerak.

## Deadlockka olib keladigan holat

Quyidagi dasturda bufersiz channel yaratilgan:

```go
package main

func main() {
	ch := make(chan int)
	ch <- 10
}
```

Kod compile bo‘ladi.

Lekin runtime vaqtida dastur davom eta olmaydi.

Runtime odatda quyidagiga o‘xshash xabar chiqaradi:

```text
fatal error: all goroutines are asleep - deadlock!
```

Sababni bosqichma-bosqich ko‘ramiz.

Avval channel yaratiladi:

```go
ch := make(chan int)
```

Bu bufersiz channel.

Keyin:

```go
ch <- 10
```

bajariladi.

Bufersiz channeldagi send uchun boshqa tomonda receive kerak.

Masalan:

```go
value := <-ch
```

Lekin dasturda boshqa goroutine yo‘q.

`main`ning o‘zi send qatorida bloklangan.

Holat quyidagicha:

```text
main goroutine:
    ch <- 10
    |
    +-- receiver kutmoqda

boshqa runnable goroutine:
    yo‘q
```

Dasturda davom eta oladigan boshqa goroutine qolmagani uchun Go runtime deadlockni aniqlaydi.

Lekin bu xabarni barcha deadlock holatlarida albatta ko‘ramiz deb o‘ylash kerak emas.

Masalan, real serverda ba’zi goroutinelar:

* network socket;
* timer;
* tashqi I/O;
* boshqa runtime event

kutayotgan bo‘lishi mumkin.

Dastur mantiqan biror joyda tiqilib qolgan bo‘lsa ham, runtime barcha goroutinelar to‘liq uxlab qolgan deb hisoblamasligi mumkin.

Shuning uchun mantiqiy deadlock har doim ham darhol:

```text
fatal error: all goroutines are asleep - deadlock!
```

xabariga olib kelmaydi.

## Keng tarqalgan xatolar

### Channelni noto‘g‘ri tomon yopishi

Channelni kim yopishi oldindan aniq bo‘lishi kerak.

Odatda channelni qiymat yuboruvchi tomon yopadi.

Agar receiver channelni o‘zi yopib yuborsa, boshqa sender hali ishlayotgan bo‘lishi mumkin.

Masalan:

```text
sender 1 ----\
sender 2 -----> channel ---> receiver
sender 3 ----/
```

Receiver channelni yopdi deb tasavvur qilamiz.

Shu vaqtda `sender 3` hali:

```go
ch <- value
```

qilishga ulgurmagan bo‘lishi mumkin.

Channel yopilganidan keyin sender qiymat yuborsa, panic yuz beradi.

Shuning uchun yopish mas’uliyatini:

* yagona sender;
* yoki barcha senderlar tugaganini biladigan coordinator

tomonida saqlash ma’qul.

### Har bir channelni majburan yopish

Yangi boshlovchilar ba’zan har bir `make(chan T)`dan keyin qayerdadir `close` bo‘lishi kerak deb o‘ylashadi.

Bu to‘g‘ri emas.

Channelni xotirani bo‘shatish uchun yopish shart emas.

Garbage collector foydalanilmaydigan channelni va unga tegishli xotirani yig‘a oladi.

`close`ning asosiy vazifasi boshqa:

> Receiverga boshqa yangi qiymat kelmasligini bildirish.

Masalan, `for range` orqali oqimning tugashini bildirish uchun `close` kerak bo‘lishi mumkin.

Lekin channel faqat bir marta signal yuborish uchun ishlatilgan va undan keyin unga hech kim murojaat qilmasa, uni alohida yopish har doim ham zarur emas.

### Yopiq channeldan cheksiz receive qilish

Yopiq channeldan oddiy receive qilish bloklanmaydi.

Masalan:

```go
ch := make(chan int)
close(ch)

fmt.Println(<-ch)
fmt.Println(<-ch)
fmt.Println(<-ch)
```

Bu receive’lar `chan int`ning zero value qiymatini qaytarishda davom etadi:

```text
0
0
0
```

Shuning uchun oqim tugaganini bilish kerak bo‘lsa:

```go
value, ok := <-ch
```

ishlatiladi.

Yoki:

```go
for value := range ch {
	// ...
}
```

ishlatish mumkin.

`range` channel yopilib, barcha qiymatlar tugagach avtomatik yakunlanadi.

### Channel data raceni butunlay yo‘q qiladi deb o‘ylash

Channel ishlatilgani bilan dastur avtomatik ravishda `data race`lardan holi bo‘lib qolmaydi.

Masalan:

```go
type User struct {
	Name string
}
```

Pointer channel orqali yuborildi:

```go
users := make(chan *User)
```

Bu pointerning o‘zi xavfsiz tarzda bir goroutinedan boshqasiga uzatilishi mumkin.

Lekin keyin sender va receiver bir paytda:

```go
user.Name = ...
```

qilsa, ular bir xil `User` obyektini o‘zgartiryapti.

Channel bu keyingi yozuvlarni avtomatik himoya qilmaydi.

Xuddi shu holat slice va map uchun ham muhim.

Masalan, slice yuborilganda slice header nusxalanishi mumkin, lekin uning backing arrayi umumiy bo‘lib qoladi.

Map esa o‘z ichki ma’lumot strukturasiga reference orqali ishlaydi.

Shuning uchun channel bilan ishlaganda ownership haqida o‘ylash foydali:

```text
sender -- qiymat yuboradi --> receiver
sender -- endi o‘zgartirmaydi
receiver -- qiymatning egasi bo‘ladi
```

Agar ownership topshirib bo‘lmasa va ma’lumot umumiy bo‘lib qolsa, concurrent mutationni alohida sinxronlashtirish kerak.

## Interviewda nimalarga e’tibor beriladi?

Channel haqida interview savollarida faqat sintaksisni bilish yetarli emas. Uning bloklanish va sinxronizatsiya xatti-harakatlarini ham tushunish muhim.

Quyidagi jihatlarga e’tibor bering:

* bufersiz channelda send va receive bir-birini kutishi mumkin;
* channel qiymat uzatish bilan birga goroutinelar orasida sinxronizatsiya ham hosil qiladi;
* `ch <- value` qiymat yuboradi;
* `<-ch` qiymat qabul qiladi;
* `chan<- T` faqat yuborishga ruxsat berilgan channel turini bildiradi;
* yopiq channelga send qilish panic keltiradi;
* yopiq channeldan receive avval qolgan qiymatlarni beradi;
* qiymatlar tugagach receive element turining zero value qiymatini qaytaradi;
* `value, ok := <-ch` orqali haqiqiy qiymatni channel yopilishidan ajratish mumkin;
* `ok == false` channel yopilganini va unda boshqa qiymat qolmaganini bildiradi;
* channelni odatda sender yoki barcha senderlar tugaganini biladigan coordinator yopadi;
* `nil` channelga send ham, receive ham doimiy bloklanadi;
* `nil` channel bilan `make` qilingan, lekin hozircha bo‘sh channel bir xil emas;
* channel orqali pointer, slice yoki map yuborish ichki ma’lumotni avtomatik himoya qilmaydi;
* yuborilgan mutable obyekt keyinchalik bir nechta goroutine tomonidan parallel o‘zgartirilsa, `data race` yuz berishi mumkin;
* channel bilan ishlaganda kim yuborishi, kim qabul qilishi, kim yopishi va qabul qiluvchi qachon to‘xtashi oldindan aniq bo‘lishi kerak.

Channelning keyingi muhim qismi bufersiz va buferli channel orasidagi farqdir. Shuningdek, channelni faqat yuborish yoki faqat qabul qilish uchun cheklash ham mumkin. Bu xususiyatlar goroutinelar o‘rtasidagi traffic va synchronization qanday ishlashiga bevosita ta’sir qiladi.
