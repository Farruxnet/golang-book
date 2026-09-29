# Goroutine

**Goroutine** — Go runtime boshqaradigan yengil bajarilish birligi. Sodda qilib aytganda, goroutine yordamida funksiyani boshqa ishlar bilan bir vaqtda, ya’ni concurrent tarzda bajarish mumkin.

Masalan, backend server bir vaqtning o‘zida ko‘plab HTTP so‘rovlarni kutishi mumkin. CLI dastur bir nechta faylni qayta ishlashi mumkin. Boshqa bir xizmat esa bir nechta tashqi API’dan ma’lumot yig‘ishi mumkin.

Bunday vazifalar bir-biridan mustaqil bo‘lsa, ularni alohida goroutinelarda bajarish qulay.

Bu yerda muhim bir farq bor: goroutine operatsion tizimdagi threadning o‘zi emas.

Go runtime ko‘plab goroutinelarni bir nechta operatsion tizim threadlari ustida rejalashtiradi. Ya’ni dasturchi har bir goroutine uchun alohida OS thread yaratmaydi. Shu sabab goroutine yaratish odatda yangi thread yaratishdan arzonroq.

Lekin bundan goroutine butunlay bepul degan xulosa chiqmaydi. Har bir goroutine:

* stek uchun xotira ishlatadi;
* scheduler tomonidan boshqariladi;
* ayrim resurslarga bog‘lanishi mumkin;
* to‘g‘ri tugatilmasa goroutine leak hosil qilishi mumkin.

Shuning uchun goroutine yaratish oson bo‘lsa ham, uning hayot siklini to‘g‘ri loyihalash dasturchining vazifasi bo‘lib qoladi.

## Goroutine qanday ishga tushiriladi?

Oddiy funksiya chaqiruvida dastur funksiya tugashini kutadi:

```go
work()
```

Bu holatda `work()` tugamaguncha undan keyingi qator bajarilmaydi.

Agar chaqiruv oldiga `go` kalit so‘zi yozilsa:

```go
go work()
```

`work()` yangi goroutine sifatida ishga tushiriladi. Chaqiruvchi goroutine esa uning tugashini kutmasdan keyingi qatorga o‘tadi.

Masalan:

```go
go sendEmail()
fmt.Println("Davom etamiz")
```

Bu kodda `sendEmail()` yakunlanishini kutish shart emas. `fmt.Println()` deyarli darhol bajarilishi mumkin.

Lekin qaysi goroutine birinchi bo‘lib CPU olishini scheduler hal qiladi. Shu sabab:

```go
go sendEmail()
fmt.Println("Davom etamiz")
```

yozilgan bo‘lsa ham, `sendEmail()` ichidagi ayrim kod `fmt.Println()`dan oldin ishlashi mumkin.

`go` operatoridan keyin funksiya yoki metod **chaqiruvi** kelishi kerak.

Masalan, bu to‘g‘ri:

```go
go work()
```

Bu ham to‘g‘ri:

```go
go printer.Print("Salom")
```

Lekin oddiy qiymatni `go` bilan ishlatib bo‘lmaydi.

Yana bir nozik qoida bor: funksiyaga uzatilayotgan argumentlar yangi goroutine ishlashni boshlashidan oldin, chaqiruvchi goroutineda hisoblanadi.

Masalan:

```go
go process(calculate())
```

Bu yerda avval `calculate()` chaqiruvchi goroutineda bajariladi. Uning natijasi tayyor bo‘lgach, `process(...)` yangi goroutine sifatida rejalashtiriladi.

## Birinchi misol

Quyidagi dastur yangi goroutine yaratadi. Bu birinchi misolda yordamchi goroutineni kutish vositasi ataylab
ishlatilmagan:

```go
package main

import "fmt"

func greet(name string) {
	fmt.Println("Salom,", name)
}

func main() {
	go greet("Go")
	fmt.Println("main davom etdi")
}
```

Natijaning mumkin bo‘lgan ko‘rinishlaridan biri:

```text
Salom, Go
main davom etdi
```

Quyidagi satr `greet()` funksiyasini yangi goroutineda ishga tushiradi:

```go
go greet("Go")
```

`main` uning tugashini kutmaydi va keyingi qatorga o‘tadi:

```go
fmt.Println("main davom etdi")
```

Shu sabab quyidagi ikki satrning qaysi biri birinchi chiqishi kafolatlanmaydi:

```text
Salom, Go
main davom etdi
```

Hatto `main()` juda tez tugasa, `Salom, Go` umuman chiqmasligi ham mumkin. Bu xato emas: Go runtime yordamchi
goroutinelarni avtomatik kutmaydi. Hozircha asosiy maqsad `go` kalit so‘zi chaqiruvchini kutdirmasligini ko‘rish.
Keyingi darsda goroutinelarning tugashini `sync.WaitGroup` bilan ishonchli kutish o‘rganiladi.

## `main` ham goroutine sifatida ishlaydi

Go dasturi `main` goroutinesida `main()` funksiyasini bajarishdan boshlanadi.

Ya’ni `main()` ham boshqa goroutinelar kabi goroutine ichida ishlaydi. Faqat uning alohida ahamiyati bor: `main()` tugasa, butun process tugaydi.

Runtime boshqa goroutinelar hali ishlayotgan bo‘lsa ham, ularni avtomatik ravishda kutmaydi.

Quyidagi dastur ataylab ishonchsiz yozilgan:

```go
package main

import "fmt"

func main() {
	go fmt.Println("Bu satr chiqmasligi mumkin")
	fmt.Println("main tugadi")
}
```

Bu dasturda kafolatlangan satr:

```text
main tugadi
```

Quyidagi satr esa chiqishi ham, chiqmasligi ham mumkin:

```text
Bu satr chiqmasligi mumkin
```

Sababi:

```go
go fmt.Println("Bu satr chiqmasligi mumkin")
```

yangi goroutine yaratadi.

Lekin `main()` darhol keyingi qatorni bajarib:

```go
fmt.Println("main tugadi")
```

undan so‘ng tugashi mumkin.

Agar yangi goroutine scheduler tomonidan hali ishga tushirilmagan bo‘lsa, process tugaydi va u o‘z kodini bajarishga ulgurmaydi.

Shuning uchun scheduler tasodifan qanday ishlashiga tayanish mumkin emas.

### Nega `time.Sleep` yechim emas?

Yangi o‘rganuvchilar ko‘pincha quyidagicha kod yozadilar:

```go
go work()
time.Sleep(time.Second)
```

Bu kichik namoyish dasturida ishlashi mumkin. Chunki `main` bir soniya kutib turadi va yordamchi goroutine ishlashga vaqt topadi.

Lekin bu haqiqiy sinxronizatsiya emas.

`time.Sleep` faqat ma’lum vaqt kutadi. U goroutine ishini tugatgan-tugatmaganini bilmaydi.

Masalan, ish odatda 500 millisekund davom etsa, quyidagicha yozish mumkin:

```go
go work()
time.Sleep(time.Second)
```

Bir qarashda bu yetarli ko‘rinadi.

Lekin tashqi API sekinlashib, `work()` 2 soniya davom etsa, `main` bir soniyadan keyin tugaydi. Goroutine esa yarim yo‘lda to‘xtaydi.

Boshqa tomondan, `work()` 10 millisekundda tugasa, dastur qolgan 990 millisekundni bekorga kutadi.

Shuning uchun ish tugashini vaqt taxmini bilan emas, aniq hodisa orqali kutish kerak.

Ko‘p ishlatiladigan vositalar:

* faqat goroutine tugashini kutish uchun `sync.WaitGroup`;
* qiymat yoki xato uzatish uchun channel;
* bekor qilish va timeout uchun `context.Context`.

Keyingi darsda bir nechta goroutinening tugashini `sync.WaitGroup` yordamida qanday kutish ko‘rib chiqiladi.

## Bir nechta goroutine bilan ishlash

Tasavvur qiling, dastur uchta mustaqil xizmatdan ma’lumot olishi kerak:

* profil xizmati;
* buyurtma xizmati;
* to‘lov xizmati.

Agar ularni ketma-ket chaqirsak, har bir xizmatning kutish vaqti bir-biriga qo‘shiladi.

Masalan:

```text
profil:    30 ms
buyurtma:  10 ms
to‘lov:    20 ms
```

Ketma-ket bajarilsa, taxminiy umumiy kutish:

```text
30 + 10 + 20 = 60 ms
```

Agar ular mustaqil bo‘lsa, uchalasini alohida goroutineda boshlash mumkin. Shunda I/O kutish vaqtlarining katta qismi ustma-ust keladi.

Quyidagi misol shu holatni ko‘rsatadi:

```go
package main

import (
	"fmt"
	"time"
)

type result struct {
	service string
	value   string
}

func fetch(service string, delay time.Duration, results chan<- result) {
	time.Sleep(delay)
	results <- result{
		service: service,
		value:   service + " ma’lumoti",
	}
}

func main() {
	services := []string{"profil", "buyurtma", "to‘lov"}
	delays := []time.Duration{
		30 * time.Millisecond,
		10 * time.Millisecond,
		20 * time.Millisecond,
	}
	results := make(chan result, len(services))

	for i, service := range services {
		go fetch(service, delays[i], results)
	}

	values := make(map[string]string, len(services))
	for range services {
		item := <-results
		values[item.service] = item.value
	}

	for _, service := range services {
		fmt.Println(values[service])
	}
}
```

Natija:

```text
profil ma’lumoti
buyurtma ma’lumoti
to‘lov ma’lumoti
```

Avval xizmatlar ro‘yxati berilgan:

```go
services := []string{"profil", "buyurtma", "to‘lov"}
```

Keyin har bir xizmat uchun sun’iy kechikish berilgan:

```go
delays := []time.Duration{
	30 * time.Millisecond,
	10 * time.Millisecond,
	20 * time.Millisecond,
}
```

Bu yerda `time.Sleep` sinxronizatsiya uchun ishlatilmayapti.

U faqat haqiqiy I/O operatsiyasini modellashtiryapti. Masalan, tashqi API’dan javob kutish kabi.

Natijalarni qabul qilish uchun buffered channel yaratilgan:

```go
results := make(chan result, len(services))
```

`len(services)` qiymati `3`.

Demak, channel sig‘imi ham `3`.

Har bir goroutine natijasini channelga yuboradi:

```go
results <- result{
	service: service,
	value:   service + " ma’lumoti",
}
```

Channel buffered bo‘lgani sabab `main` aynan shu onda qabul qilishga tayyor bo‘lmasa ham, goroutine natijani bufferga joylashtira oladi. Albatta, bufferda joy bo‘lishi kerak.

Keyin uchta goroutine ishga tushiriladi:

```go
for i, service := range services {
	go fetch(service, delays[i], results)
}
```

Bu sikl uch marta ishlaydi.

Natijada taxminan quyidagilar parallel ravishda kutishni boshlaydi:

```text
profil    -> 30 ms
buyurtma  -> 10 ms
to‘lov    -> 20 ms
```

Shu sabab channelga birinchi bo‘lib `buyurtma` natijasi kelishi mumkin. Keyin `to‘lov`, undan keyin `profil`.

Lekin dastur natijalarni kelgan tartibda to‘g‘ridan-to‘g‘ri chiqarmaydi.

Avval ular `map`ga joylanadi:

```go
values := make(map[string]string, len(services))

for range services {
	item := <-results
	values[item.service] = item.value
}
```

Dastur aynan uchta goroutine boshlagan. Shu sabab aynan uchta natija kutmoqda.

Keyin natijalar yana `services` slicesi tartibida chiqariladi:

```go
for _, service := range services {
	fmt.Println(values[service])
}
```

Shu sabab goroutinelar qaysi tartibda tugashidan qat’i nazar, ekrandagi tartib barqaror bo‘ladi:

```text
profil ma’lumoti
buyurtma ma’lumoti
to‘lov ma’lumoti
```

Haqiqiy loyihada faqat qiymatni uzatish ko‘pincha yetarli emas.

Masalan, natija quyidagicha bo‘lishi mumkin:

```go
type result struct {
	service string
	value   string
	err     error
}
```

Shunda har bir goroutine o‘z qiymati bilan birga xatosini ham yuborishi mumkin.

Uzoq davom etadigan tashqi so‘rovlarda timeout yoki cancellation ham kerak bo‘ladi. Aks holda bitta xizmat javob bermasa, butun operatsiya cheksiz kutib qolishi mumkin.

Bu misoldagi concurrency avtomatik ravishda parallel CPU hisoblash degani emas.

**Concurrency** — bir nechta ishni bir vaqt oralig‘ida boshqarish.

**Parallelism** esa bir nechta ishning aynan bir vaqtda turli CPU yadrolarida bajarilishini anglatadi.

I/O kutayotgan goroutine bloklanganda runtime boshqa tayyor goroutineni ishlatishi mumkin. Goroutinelarning aynan bir paytda turli CPU yadrolarida bajarilishi esa runtime, `GOMAXPROCS`, mavjud CPU yadrolari va boshqa omillarga bog‘liq.

## Anonim funksiya va argumentlar

Goroutine faqat nomlangan funksiya bilan ishlashi shart emas.

Anonim funksiyani ham goroutine sifatida ishga tushirish mumkin:

```go
go func(id int) {
	fmt.Println("Ish:", id)
}(id)
```

Bu sintaksisni ikki qismga ajratib ko‘rish qulay.

Birinchi qism anonim funksiyani yaratadi:

```go
func(id int) {
	fmt.Println("Ish:", id)
}
```

Keyingi qism esa uni chaqiradi:

```go
(id)
```

Shu sabab umumiy ko‘rinish:

```go
go func(id int) {
	fmt.Println("Ish:", id)
}(id)
```

bo‘ladi.

Oxiridagi `(id)` joriy `id` qiymatini anonim funksiyaning `id int` parametriga uzatadi.

Bu usul goroutine aynan qaysi qiymat bilan ishlashini ochiq ko‘rsatadi.

Masalan:

```go
for id := 1; id <= 3; id++ {
	go func(value int) {
		fmt.Println(value)
	}(id)
}
```

Har bir chaqiruvda joriy `id` qiymati argument sifatida baholanadi va `value` parametriga uzatiladi.

Sikl o‘zgaruvchisini closure ichida tashqi muhitdan to‘g‘ridan-to‘g‘ri ishlatish eski Go versiyalarida keng tarqalgan xatolardan biri edi.

Masalan:

```go
for _, value := range values {
	go func() {
		fmt.Println(value)
	}()
}
```

Eski semantikada closure bir xil sikl o‘zgaruvchisiga murojaat qilishi mumkin edi. Goroutine ishlashga ulgurguncha o‘sha o‘zgaruvchi keyingi qiymatga o‘tib ketardi.

Zamonaviy Go versiyalarida `for` siklidagi iteration o‘zgaruvchilari semantikasi yaxshilangan. Shunga qaramay, qiymatni parametr orqali uzatish ko‘pincha niyatni aniqroq ko‘rsatadi:

```go
go func(value string) {
	fmt.Println(value)
}(value)
```

Bundan tashqari, eski Go versiyasi bilan ishlaydigan modulni o‘qiyotganda ham bunday usul xavfsizroq va tushunarliroq.

## Goroutine ichidan natija qaytarish

Oddiy funksiyada qaytgan qiymatni o‘zgaruvchiga yozish mumkin:

```go
value := calculate()
```

Lekin `go` bilan ishga tushirilgan funksiyadan natijani shu tarzda olib bo‘lmaydi.

Quyidagi yozuv noto‘g‘ri:

```go
// Noto‘g‘ri misol:
// value := go calculate()
```

Bu kod kompilyatsiya qilinmaydi.

Sababi `go calculate()` chaqiruvi `calculate()` tugashini kutmaydi.

Agar `calculate()` natijani 10 millisekunddan keyin tayyorlasa, chaqiruvchi goroutine shu vaqt ichida allaqachon boshqa kodni bajarib ketgan bo‘lishi mumkin.

Demak, natija qachon tayyor bo‘lishi alohida boshqarilishi kerak.

Buning eng tabiiy usullaridan biri channel:

```go
result := make(chan int)

go func() {
	result <- calculate()
}()

value := <-result
```

Bu yerda yordamchi goroutine natijani channelga yuboradi. Chaqiruvchi goroutine esa qiymat kelguncha kutadi.

Yana bir usul natijani umumiy ma’lumot tuzilmasiga yozishdir.

Lekin umumiy xotira bilan ishlaganda ehtiyot bo‘lish kerak.

Agar ikki goroutine bir xil xotira joyiga bir paytda murojaat qilsa va ulardan kamida bittasi yozish bajarsa, sinxronizatsiya bo‘lmasa **data race** yuz berishi mumkin.

Masalan:

```go
counter := 0

go func() {
	counter++
}()

go func() {
	counter++
}()
```

Bu kod tashqi ko‘rinishidan sodda.

Lekin `counter++` bitta atomar amal bo‘lishi shart emas. U qiymatni o‘qish, oshirish va qayta yozish kabi bir nechta bosqichni o‘z ichiga olishi mumkin.

Shu sabab ikki goroutine bir-birining o‘zgarishini yo‘qotib qo‘yishi mumkin.

Bunday kodning testda 100 marta to‘g‘ri ishlashi uning xavfsizligini isbotlamaydi.

Data racelarni aniqlash uchun Go race detectorga ega:

```bash
go test -race ./...
go run -race main.go
```

Birinchi buyruq paketlardagi testlarni race detector bilan ishga tushiradi:

```bash
go test -race ./...
```

Ikkinchisi esa oddiy dasturni race detector bilan bajaradi:

```bash
go run -race main.go
```

Race detector dastur bajarilishi davomida kuzatilgan noto‘g‘ri concurrent memory accesslarni aniqlashga yordam beradi.

Lekin u barcha mumkin bo‘lgan scheduler tartiblarini sinab chiqmaydi.

Shuning uchun:

```text
race detector xato topmadi
```

degani:

```text
kodda hech qachon data race bo‘lmaydi
```

degani emas.

Umumiy xotiraga murojaat to‘g‘ri himoyalanganini kodning o‘zidan ham tekshirish kerak.

Bunda `sync.Mutex`, `sync.RWMutex`, `atomic` operatsiyalar yoki channel orqali ownershipni boshqarish kabi vositalar ishlatilishi mumkin.

## Go runtime goroutineni qanday boshqaradi?

Goroutine yengil bo‘lishining asosiy sabablaridan biri uning stek boshqaruvi bilan bog‘liq.

Har bir goroutine nisbatan kichik stek bilan boshlanadi.

Funksiya chaqiruvlari ko‘payib, ko‘proq stek kerak bo‘lsa, Go runtime uni kengaytirishi mumkin.

Keyinchalik ehtiyoj kamayganda runtime stek hajmini kichraytirishi ham mumkin.

Bu OS threadlari bilan solishtirganda muhim farq.

Threadlar ko‘pincha kattaroq stek rezervi bilan bog‘liq bo‘ladi. Goroutine esa boshlanishida juda katta stek talab qilmaydi.

Shu sabab minglab yoki undan ham ko‘proq goroutine bilan ishlash amaliy jihatdan mumkin.

Lekin aniq boshlang‘ich stek hajmini dastur mantig‘iga bog‘lash kerak emas.

Masalan:

```text
"Har bir goroutine aniq N kilobayt stek oladi"
```

degan taxminga asoslanib dastur yozish noto‘g‘ri.

Bu runtime implementatsiyasining ichki tafsiloti va Go versiyalari orasida o‘zgarishi mumkin.

### Scheduler

Go runtime scheduler goroutinelarni OS threadlari ustida taqsimlaydi.

Sodda tasavvur qilish uchun:

```text
goroutine 1 ─┐
goroutine 2 ─┼──> Go scheduler ───> OS threadlar
goroutine 3 ─┤
goroutine 4 ─┘
```

Agar bir goroutine channel kutayotgan bo‘lsa:

```go
value := <-ch
```

u hozircha davom eta olmaydi.

Shunda runtime boshqa tayyor goroutineni bajarishi mumkin.

Xuddi shunday holat mutex, taymer yoki ayrim I/O operatsiyalarida ham kuzatiladi.

Muhim qoida: scheduler goroutinelarning bajarilish tartibini kafolatlamaydi.

Masalan:

```go
go first()
go second()
```

yozilgan bo‘lsa ham:

```text
first tugaydi
second tugaydi
```

tartibi kafolatlanmaydi.

Hatto `second()` ichidagi kod `first()` ichidagi koddan oldin ishlashi mumkin.

### Goroutine almashinuvi ham bepul emas

Goroutine threadga qaraganda yengilroq bo‘lishi mumkin, lekin uning ham xarajati bor.

Runtime:

* goroutine holatini kuzatadi;
* scheduler navbatlarini boshqaradi;
* steklarni boshqaradi;
* bloklangan va tayyor goroutinelarni kuzatadi;
* ularni OS threadlariga taqsimlaydi.

Shuning uchun har bir juda kichik vazifani alohida goroutinega ajratish doim foydali emas.

Masalan, millionta juda arzimas hisobni millionta goroutinega bo‘lish scheduler xarajatini oshirishi mumkin.

Concurrency faqat ishlar tabiatan mustaqil bo‘lsa yoki kutish vaqtlarini ustma-ust bajarish foyda bersa yaxshi natija beradi.

## Goroutine hayot sikli

Har bir yaratilgan goroutine uchun kamida quyidagi savollarga javob berish kerak:

1. U qachon tugaydi?
2. Natija yoki xato qayerga uzatiladi?
3. Kutish qanday bekor qilinadi?
4. U ishlatayotgan resurslarni kim yopadi?

Bu savollar ayniqsa uzoq ishlaydigan serverlarda muhim.

Bir martalik kichik dastur process tugashi bilan barcha resurslarni OSga qaytarishi mumkin. Lekin haftalab ishlaydigan serverda noto‘g‘ri boshqarilgan goroutinelar asta-sekin yig‘ilib boradi.

Goroutine funksiyasi quyidagi holatlarda tabiiy tugaydi:

* funksiya oxiriga yetganda;
* `return` bajarilganda.

Masalan:

```go
func worker() {
	doWork()
	return
}
```

yoki:

```go
func worker() {
	doWork()
}
```

Ikkala holatda ham funksiya tugashi bilan goroutine ham tugaydi.

Go’da boshqa goroutineni tashqaridan xavfsiz tarzda "o‘ldirish" uchun maxsus operator yo‘q.

Masalan, quyidagiga o‘xshash standart mexanizm mavjud emas:

```text
kill(goroutine)
```

Bekor qilish odatda **cooperative cancellation** tamoyili bilan ishlaydi.

Ya’ni goroutine cancellation signalini oladi va o‘zi `return` qiladi.

Buning uchun ko‘pincha:

* channel;
* `context.Context`

ishlatiladi.

Masalan, konseptual ko‘rinish:

```go
select {
case <-ctx.Done():
	return
case item := <-jobs:
	process(item)
}
```

Bu yerda goroutine `ctx.Done()` yopilsa, cancellation signalini qabul qiladi va o‘zi tugaydi.

### Goroutine leak

**Goroutine leak** — goroutine endi foydali ish bajarmasa ham tugamay, process ichida qolib ketadigan holat.

Masalan:

```go
ch := make(chan int)

go func() {
	value := <-ch
	fmt.Println(value)
}()
```

Agar hech kim `ch` channeliga hech qachon qiymat yubormasa, goroutine:

```go
value := <-ch
```

qatorida abadiy kutib qoladi.

Bu goroutine leak bo‘lishi mumkin.

Shunga o‘xshash holat yuborishda ham yuz beradi:

```go
ch := make(chan int)

go func() {
	ch <- 10
}()
```

Agar channel unbuffered bo‘lsa va hech kim undan qiymat qabul qilmasa, yuboruvchi goroutine bloklanib qoladi.

Uzoq davom etadigan I/O operatsiyasi ham cancellation imkoniyatisiz qolsa, goroutine uzoq vaqt yashab turishi mumkin.

Goroutine foydali ish bajarmayotgan bo‘lsa ham, u hali:

* o‘z stekini;
* unga bog‘langan obyektlarni;
* ayrim ochiq resurslarni

ushlab turishi mumkin.

Shuning uchun server kodida quyidagilarni tekshirish muhim:

* uzoq operatsiya uchun timeout bormi;
* cancellation yo‘li bormi;
* channel yuborish abadiy bloklanib qolmaydimi;
* channel qabul qilish abadiy kutib qolmaydimi;
* request tugaganda unga bog‘liq goroutinelar ham tugaydimi.

Masalan, HTTP request tugaganidan keyin unga tegishli background goroutine hali ham ishlashda davom etsa, bu vaqt o‘tishi bilan leakga aylanishi mumkin.

### Goroutine ichidagi `panic`

`panic` goroutinelar bilan ishlaganda alohida e’tibor talab qiladi.

Agar bir goroutine ichida `panic` yuz bersa va u ushlanmasa, faqat o‘sha goroutine emas, butun dastur to‘xtaydi.

Masalan:

```go
go func() {
	panic("xato")
}()
```

Bu panic recover qilinmasa, process yakunlanadi.

`recover()` faqat panic yuz bergan **o‘sha goroutine** ichidagi deferred funksiya orqali ishlaydi.

Masalan:

```go
func worker() {
	defer func() {
		if value := recover(); value != nil {
			fmt.Println("Panic:", value)
		}
	}()

	panic("xato")
}
```

Bu yerda `recover()` `worker()` bajarilayotgan goroutineda joylashgan.

Boshqa goroutinedagi `recover()` bu panicni ushlay olmaydi.

Masalan, `main` ichida `recover()` qo‘yib, boshqa goroutinedagi panicni tutib bo‘lmaydi.

Har bir joyga `recover()` qo‘yish ham yaxshi yechim emas.

Bu dasturlash xatolarini yashirib yuborishi mumkin.

`recover()` odatda aniq chegaralarda ishlatiladi. Masalan:

* server request handler;
* worker;
* task executor;
* framework tomonidan boshqariladigan task.

Maqsad panicni jim yutish emas.

Odatda panic:

* log qilinadi;
* kerakli resurslar yopiladi;
* boshqariladigan xato javobi qaytariladi yoki task tugatiladi.

## Keng tarqalgan xatolar

### Goroutinelar tartib bilan ishlaydi deb o‘ylash

Quyidagi kod:

```go
go first()
go second()
```

`first()` birinchi yozilgani uchun u albatta oldin tugaydi degani emas.

Scheduler quyidagi tartiblarning istalganini hosil qilishi mumkin:

```text
first boshlanadi
second boshlanadi
second tugaydi
first tugaydi
```

yoki:

```text
second boshlanadi
second tugaydi
first boshlanadi
first tugaydi
```

yoki boshqa tartib.

Agar bajarilish tartibi muhim bo‘lsa, uni kodda aniq ifodalash kerak.

Buning uchun channel, mutex, `WaitGroup` yoki boshqa mos sinxronizatsiya vositasidan foydalaniladi.

Schedulerning "odatda shunday ishlashi"ga tayanish xato.

### Cheksiz goroutine yaratish

Quyidagi pattern xavfli bo‘lishi mumkin:

```go
for item := range items {
	go process(item)
}
```

Agar `items` ichiga juda tez elementlar kelayotgan bo‘lsa, dastur minglab yoki millionlab goroutine yaratishi mumkin.

Bu faqat goroutine xotirasiga ta’sir qilmaydi.

Masalan, `process()` ichida database connection kerak bo‘lsa, goroutinelar soni database connection pooldan tezroq o‘sishi mumkin.

Yoki tashqi API har soniyada 100 ta requestga ruxsat bersa, minglab goroutine birdan so‘rov yuborishi rate limitni buzadi.

Shuning uchun parallel ishlar sonini ko‘pincha cheklash kerak.

Keng tarqalgan yondashuvlar:

* worker pool;
* semaphore;
* bounded queue.

Asosiy fikr: goroutine yaratish arzon bo‘lsa ham, u ishlatadigan tashqi resurslar cheksiz emas.

### Xato va natijani yo‘qotish

Goroutine oddiy `return` orqali chaqiruvchiga natija yoki xato qaytara olmaydi.

Masalan:

```go
go save()
```

agar `save()` `error` qaytarsa, bu xatoni chaqiruvchi to‘g‘ridan-to‘g‘ri qabul qila olmaydi.

Natija va xato alohida uzatilishi kerak.

Masalan:

```go
type result struct {
	value string
	err   error
}
```

So‘ng:

```go
results <- result{
	value: value,
	err:   err,
}
```

Yana bir muhim savol bor: bitta goroutine xato qilsa, qolganlari nima qilishi kerak?

Variantlar turlicha bo‘lishi mumkin:

* qolgan ishlar davom etadi;
* birinchi xatoda hammasi bekor qilinadi;
* barcha natijalar yig‘iladi va oxirida xatolar qaytariladi.

Bu qaror tasodifan yuzaga kelmasligi kerak. Uni oldindan loyihalash kerak.

### `time.Sleep` bilan sinxronlashtirish

Quyidagi kod testlarda ko‘p uchraydigan xato:

```go
go work()
time.Sleep(100 * time.Millisecond)
checkResult()
```

Bu kod `work()` 100 millisekund ichida tugaydi deb taxmin qiladi.

Lekin CI server sekinroq bo‘lishi mumkin. Tashqi I/O uzoqroq davom etishi mumkin. Scheduler boshqacha ishlashi mumkin.

Natijada test ba’zan o‘tadi, ba’zan yiqiladi.

Bunday test **flaky test**ga aylanishi mumkin.

Ish tugashini:

* `WaitGroup`;
* channel

bilan kutish kerak.

Timeout esa alohida maqsad uchun ishlatiladi: operatsiya ruxsat etilgan vaqtdan oshib ketmasligini nazorat qilish.

### Umumiy o‘zgaruvchiga himoyasiz yozish

Bir nechta goroutine bitta ma’lumotni o‘zgartirsa, data race paydo bo‘lishi mumkin.

Masalan:

```go
values := map[string]int{}

go func() {
	values["a"] = 1
}()

go func() {
	values["b"] = 2
}()
```

Go `map`iga bir nechta goroutinedan sinxronizatsiyasiz yozish xavfsiz emas.

Xuddi shunday muammo:

* slice elementlari;
* counter;
* struct fieldlari;
* umumiy pointerlar

bilan ham yuz berishi mumkin.

Muammoni hal qilishning ikki keng tarqalgan yo‘li bor.

Birinchisi, umumiy xotirani mutex bilan himoyalash:

```go
var mu sync.Mutex
```

Ikkinchisi, ma’lumotga ownershipni bitta goroutinega berish va boshqa goroutinelar bilan channel orqali muloqot qilish.

Qaysi yondashuv yaxshiroq ekani vazifaga bog‘liq.

Muhim qoida: bir nechta goroutine umumiy mutable state bilan ishlayotgan bo‘lsa, sinxronizatsiya masalasini albatta tekshirish kerak.

## Interviewda nimalarga e’tibor beriladi?

Goroutine haqida interview savollarida faqat:

```go
go f()
```

sintaksisini bilish yetarli emas.

Quyidagi tushunchalarni aniq farqlash muhim:

* goroutine OS threadi emas, uni Go runtime boshqaradi;
* `go f()` funksiyani yangi goroutine sifatida rejalashtiradi;
* chaqiruvchi goroutine uning tugashini kutmaydi;
* `main()` qaytsa, boshqa goroutinelar avtomatik ravishda kutilmaydi;
* goroutine bajarilish tartibi scheduler sabab kafolatlanmaydi;
* goroutine ichidan natija yoki `error` oddiy `return` bilan chaqiruvchiga uzatilmaydi;
* natija uchun channel yoki boshqa sinxronizatsiya mexanizmi kerak;
* umumiy mutable state data race keltirib chiqarishi mumkin;
* goroutine leak uzoq ishlaydigan dasturlarda jiddiy muammo;
* nazoratsiz fan-out resurslarni tugatishi mumkin;
* goroutineni tashqaridan majburan o‘ldirish o‘rniga cancellation signali bilan hamkorlikda tugatish kerak.

Interviewda yana quyidagi savol berilishi mumkin:

> Goroutine yaratish oson ekan, nega har bir ishni goroutinega ajratmaymiz?

Javob shuki, goroutine yengil bo‘lsa ham uning scheduling va memory xarajati bor. Bundan tashqari, u ishlatadigan database connection, socket, API quota yoki CPU kabi tashqi resurslar cheklangan bo‘lishi mumkin.

Shuning uchun concurrency ham nazorat bilan ishlatiladi.

## Misollar

### 1. Nomlangan funksiyani goroutine sifatida boshlash

Bu misol oddiy nomlangan funksiyani `go` kalit so‘zi bilan concurrent ishga tushirishni ko‘rsatadi.

```go
package main

import (
	"fmt"
	"time"
)

func greet() {
	fmt.Println("Goroutinedan salom")
}

func main() {
	go greet()
	time.Sleep(20 * time.Millisecond)
}
```

Asosiy qator:

```go
go greet()
```

Agar `go` bo‘lmaganida:

```go
greet()
```

`main()` `greet()` tugashini kutardi.

`go` qo‘shilgach, `greet()` alohida goroutine sifatida rejalashtiriladi. `main()` esa darhol keyingi qatorga o‘tadi:

```go
time.Sleep(20 * time.Millisecond)
```

Bu misolda `Sleep()` faqat namoyish uchun ishlatilgan. U yordamchi goroutine ekranga yozishga ulgurishi uchun `main`ni qisqa vaqt ushlab turadi.

Bu production kod uchun ishonchli sinxronizatsiya emas.

Agar `greet()` bajarilishi 20 millisekunddan ko‘proq vaqt olsa, `main()` baribir tugashi mumkin.

Asosiy qoida: `go f()` funksiyani concurrent bajarishga rejalashtiradi, lekin uning tugashini kutmaydi.

### 2. Anonim funksiyani goroutineda bajarish

Bu misolda bir martalik ish uchun alohida nomlangan funksiya yaratish o‘rniga anonim funksiya ishlatiladi.

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	go func() {
		fmt.Println("Anonim goroutine ishladi")
	}()

	time.Sleep(20 * time.Millisecond)
}
```

Anonim funksiya:

```go
func() {
	fmt.Println("Anonim goroutine ishladi")
}
```

ko‘rinishida e’lon qilingan.

Lekin funksiya e’lon qilishning o‘zi uni bajarmaydi.

Shu sabab oxirida:

```go
()
```

yozilgan:

```go
func() {
	fmt.Println("Anonim goroutine ishladi")
}()
```

Bu anonim funksiyani darhol chaqiradi.

`go` esa butun chaqiruv oldida turibdi:

```go
go func() {
	fmt.Println("Anonim goroutine ishladi")
}()
```

Agar bu funksiya faqat shu joyda kerak bo‘lsa, unga alohida nom berish shart emas.

Bu pattern qisqa background tasklarda, closure ishlatishda yoki shu scope ichidagi qiymatlardan foydalanishda ko‘p uchraydi.

### 3. Argumentni goroutinega uzatish

Bu misolda nomlangan funksiyaga argument uzatiladi va har bir goroutine o‘z qiymati bilan ishlaydi.

```go
package main

import (
	"fmt"
	"time"
)

func printNumber(number int) {
	fmt.Println("Son:", number)
}

func main() {
	for number := 1; number <= 3; number++ {
		go printNumber(number)
	}
	time.Sleep(20 * time.Millisecond)
}
```

Sikl:

```go
for number := 1; number <= 3; number++ {
```

`number`ga quyidagi qiymatlarni beradi:

```text
1
2
3
```

Har iteratsiyada:

```go
go printNumber(number)
```

chaqiriladi.

Funksiya argumenti goroutine ish boshlashidan oldin baholanadi.

Shuning uchun har bir chaqiruv o‘sha paytdagi qiymatni oladi.

Natijada uchta goroutine taxminan quyidagilar bilan ishlaydi:

```text
printNumber(1)
printNumber(2)
printNumber(3)
```

Lekin ekrandagi tartib kafolatlanmaydi.

Masalan, natija:

```text
Son: 2
Son: 1
Son: 3
```

bo‘lishi mumkin.

Yoki:

```text
Son: 3
Son: 2
Son: 1
```

bo‘lishi ham mumkin.

Sikl tartibi goroutine tugash tartibini belgilamaydi.

### 4. Anonim funksiyaga qiymatni parametr bilan berish

Bu misolda sikldagi qiymat anonim funksiyaga parametr orqali uzatiladi.

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	words := []string{"Go", "tez", "sodda"}

	for _, word := range words {
		go func(value string) {
			fmt.Println(value)
		}(word)
	}

	time.Sleep(20 * time.Millisecond)
}
```

Siklning har iteratsiyasida `word` navbatdagi qiymatni oladi:

```text
Go
tez
sodda
```

Anonim funksiya esa parametrga ega:

```go
func(value string) {
	fmt.Println(value)
}
```

Oxiridagi:

```go
(word)
```

joriy `word` qiymatini `value` parametriga uzatadi.

Ya’ni mantiqan quyidagiga o‘xshaydi:

```text
value = "Go"
value = "tez"
value = "sodda"
```

har bir goroutine uchun alohida.

Bu yondashuv kodning niyatini aniq ko‘rsatadi: goroutine aynan shu iteratsiyadagi qiymat bilan ishlashi kerak.

Chiqish tartibi sliceda yozilgan tartib bilan bir xil bo‘lishi shart emas.

Masalan:

```text
sodda
Go
tez
```

ham to‘g‘ri natija.

Asosiy qoida: argument qiymati chaqiruv paytida olinadi, lekin goroutinelarning bajarilish tartibi schedulerga bog‘liq.

### 5. Bir funksiyani bir necha goroutineda bajarish

Bu misolda bir xil `download()` funksiyasi turli argumentlar bilan bir necha goroutineda ishlatiladi.

```go
package main

import (
	"fmt"
	"time"
)

func download(file string, delay time.Duration) {
	time.Sleep(delay)
	fmt.Println(file, "yuklandi")
}

func main() {
	go download("small.txt", 10*time.Millisecond)
	go download("large.zip", 40*time.Millisecond)
	time.Sleep(60 * time.Millisecond)
}
```

Birinchi goroutine:

```go
go download("small.txt", 10*time.Millisecond)
```

`10` millisekund kutadi.

Ikkinchi goroutine:

```go
go download("large.zip", 40*time.Millisecond)
```

`40` millisekund kutadi.

Shu sun’iy kechikish sabab `small.txt` odatda oldin chiqadi:

```text
small.txt yuklandi
large.zip yuklandi
```

Lekin real hayotdagi download vaqtini oldindan bilib bo‘lmaydi.

Kichik fayl uzoq serverdan kelishi mumkin. Katta fayl esa juda tez lokal tarmoqdan olinishi mumkin.

Shuning uchun dastur "birinchi boshlangan goroutine albatta birinchi tugaydi" degan taxminga tayanmasligi kerak.

Bu misoldagi `Sleep()` I/O vaqtini modellashtiradi. `main()` oxiridagi `60` millisekundlik `Sleep()` esa faqat demo dastur processni erta tugatmasligi uchun qo‘shilgan.

### 6. `main()` erta tugashini ko‘rish

Bu misol `main()` yordamchi goroutineni avtomatik kutmasligini ko‘rsatadi.

```go
package main

import (
	"fmt"
	"time"
)

func delayedMessage() {
	time.Sleep(100 * time.Millisecond)
	fmt.Println("Bu satr chiqmasligi mumkin")
}

func main() {
	go delayedMessage()
	fmt.Println("main tugadi")
}
```

`main()` yordamchi goroutineni ishga tushiradi:

```go
go delayedMessage()
```

`delayedMessage()` esa darhol:

```go
time.Sleep(100 * time.Millisecond)
```

orqali 100 millisekund kutadi.

Shu paytda `main()` davom etadi:

```go
fmt.Println("main tugadi")
```

va funksiya tugaydi.

`main()` tugashi bilan process yakunlanadi.

Shuning uchun yordamchi goroutine:

```go
fmt.Println("Bu satr chiqmasligi mumkin")
```

qatoriga yetib bormasligi mumkin.

Ko‘p hollarda natija faqat:

```text
main tugadi
```

bo‘ladi.

Bu misol goroutine ishini `main` lifecycle’dan alohida ko‘rish kerakligini ko‘rsatadi.

Yechim "katta `Sleep()` qo‘yish" emas. Aniq kutish uchun `WaitGroup` yoki channel ishlatilishi kerak.

### 7. Goroutinelar sonini kuzatish

Bu misolda `runtime.NumGoroutine()` yordamida ayni paytda mavjud goroutinelar soni olinadi.

```go
package main

import (
	"fmt"
	"runtime"
	"time"
)

func main() {
	fmt.Println("Boshlanishida:", runtime.NumGoroutine())

	go func() {
		time.Sleep(50 * time.Millisecond)
	}()

	time.Sleep(10 * time.Millisecond)
	fmt.Println("Ish paytida:", runtime.NumGoroutine())
}
```

Dastur boshida:

```go
runtime.NumGoroutine()
```

joriy goroutinelar sonini qaytaradi.

Oddiy kichik dasturda bunda ko‘pincha `main` goroutinesi hisobga olinadi.

Keyin yangi goroutine yaratiladi:

```go
go func() {
	time.Sleep(50 * time.Millisecond)
}()
```

Bu goroutine 50 millisekund yashaydi.

`main()` esa 10 millisekund kutadi:

```go
time.Sleep(10 * time.Millisecond)
```

Demak, ikkinchi `NumGoroutine()` chaqirilgan paytda yordamchi goroutine hali tugamagan bo‘lishi ehtimoli yuqori.

Natija taxminan:

```text
Boshlanishida: 1
Ish paytida: 2
```

ko‘rinishida bo‘lishi mumkin.

Lekin aniq raqamga dastur mantig‘ini bog‘lamaslik kerak.

`runtime.NumGoroutine()` faqat o‘sha ondagi snapshotni beradi. Dastur tuzilishi va runtime faoliyatiga qarab qiymat boshqacha bo‘lishi mumkin.

Bu funksiya debugging yoki monitoringda foydali bo‘lishi mumkin. Masalan, goroutine leakdan shubhalanganda vaqt o‘tishi bilan goroutinelar soni o‘sib borayotganini kuzatish mumkin.

### 8. Goroutine ichidagi xatoni qayd etish

Bu misolda goroutine chaqirgan funksiya `error` qaytaradi. Xato goroutinening o‘zida tekshiriladi.

```go
package main

import (
	"errors"
	"fmt"
	"time"
)

func save(name string) error {
	if name == "" {
		return errors.New("nom bo‘sh")
	}
	return nil
}

func main() {
	go func() {
		if err := save(""); err != nil {
			fmt.Println("Saqlash xatosi:", err)
		}
	}()

	time.Sleep(20 * time.Millisecond)
}
```

`save()` quyidagi signature’ga ega:

```go
func save(name string) error
```

Demak, u xato qaytarishi mumkin.

Bo‘sh string uzatilganda:

```go
save("")
```

quyidagi xato qaytadi:

```go
errors.New("nom bo‘sh")
```

Goroutine ichida esa:

```go
if err := save(""); err != nil {
	fmt.Println("Saqlash xatosi:", err)
}
```

xato darhol tekshiriladi.

Natija:

```text
Saqlash xatosi: nom bo‘sh
```

Bu kichik misolda xatoni faqat log qilish yetarli.

Lekin real tizimda chaqiruvchi ham xatoni bilishi kerak bo‘lishi mumkin.

Bunday holatda xatoni channel orqali qaytarish mumkin:

```go
errorsCh <- err
```

yoki natija va `error` bitta struct ichida uzatiladi.

Asosiy qoida: goroutine ichidan `return err` qilish mumkin, lekin `go` chaqiruvini boshlagan kod bu `error`ni oddiy funksiya chaqiruvidagidek avtomatik qabul qilmaydi.

### 9. Goroutine ichidagi panicni o‘sha joyda ushlash

Bu misol `recover()` faqat panic yuz bergan goroutine ichida ishlashini ko‘rsatadi.

```go
package main

import (
	"fmt"
	"time"
)

func riskyWork() {
	defer func() {
		if value := recover(); value != nil {
			fmt.Println("Panic ushlandi:", value)
		}
	}()

	panic("kutilmagan holat")
}

func main() {
	go riskyWork()
	time.Sleep(20 * time.Millisecond)
	fmt.Println("Dastur davom etdi")
}
```

`riskyWork()` boshida deferred funksiya ro‘yxatdan o‘tkaziladi:

```go
defer func() {
	if value := recover(); value != nil {
		fmt.Println("Panic ushlandi:", value)
	}
}()
```

Keyin:

```go
panic("kutilmagan holat")
```

bajariladi.

Panic sabab funksiya normal oqimda davom etmaydi. Lekin stack unwinding paytida deferred funksiya ishga tushadi.

Shu deferred funksiya ichidagi:

```go
recover()
```

panic qiymatini ushlaydi.

Natija taxminan:

```text
Panic ushlandi: kutilmagan holat
Dastur davom etdi
```

bo‘lishi mumkin.

Muhim qoida shuki, `recover()` boshqa goroutinedagi panicni ushlay olmaydi.

Masalan, `main()` ichidagi deferred `recover()` yordamchi goroutine ichidagi panicni tutmaydi.

Shu sabab bu misolda deferred funksiya aynan `riskyWork()` ichiga joylashtirilgan.

Production kodda `recover()`ni har bir funksiyaga qo‘yish tavsiya etilmaydi. U odatda aniq task yoki request chegarasida ishlatiladi.

### 10. Metodni goroutine sifatida chaqirish

Goroutine faqat oddiy funksiyani emas, metod chaqiruvini ham bajarishi mumkin.

```go
package main

import (
	"fmt"
	"time"
)

type Printer struct {
	Prefix string
}

func (printer Printer) Print(message string) {
	fmt.Println(printer.Prefix, message)
}

func main() {
	printer := Printer{Prefix: "LOG:"}
	go printer.Print("xabar tayyor")
	time.Sleep(20 * time.Millisecond)
}
```

Bu yerda:

```go
printer.Print("xabar tayyor")
```

oddiy metod chaqiruvi.

Uning oldiga `go` yozilganda:

```go
go printer.Print("xabar tayyor")
```

metod yangi goroutine sifatida bajariladi.

`Print()` value receiver bilan yozilgan:

```go
func (printer Printer) Print(message string)
```

Demak, metod receiver sifatida `Printer` qiymatini oladi.

Bu misolda `Printer` juda sodda struct:

```go
type Printer struct {
	Prefix string
}
```

`Prefix` qiymati:

```text
LOG:
```

bo‘ladi.

Shuning uchun metod:

```go
fmt.Println(printer.Prefix, message)
```

taxminan quyidagini chiqaradi:

```text
LOG: xabar tayyor
```

Value receiver ishlatilgani sabab metod receiver qiymatining nusxasi bilan ishlaydi.

Lekin value receiver haqida bitta nozik jihatni eslab qolish kerak: structning o‘zi nusxalanadi, ammo uning ichida slice, map yoki pointer kabi qiymatlar bo‘lsa, ular orqali boshqa ma’lumotlarga murojaat qilish semantikasi alohida bo‘lishi mumkin.

Bu misolda esa faqat `string` field bor. Shu sabab receiver nusxasi masalasi oddiy.

Asosiy qoida: metod chaqiruvi ham funksiya chaqiruvi kabi `go` kalit so‘zi bilan yangi goroutine sifatida ishga tushirilishi mumkin.
