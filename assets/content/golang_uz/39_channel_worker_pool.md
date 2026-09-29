# Worker pool

Worker pool — ko‘p vazifani cheklangan sondagi ishchi goroutinelar yordamida bajarish usuli.

Bu yondashuvda barcha vazifalar birdaniga alohida goroutine’da ishga tushirilmaydi. Buning o‘rniga oldindan ma’lum sondagi worker goroutine yaratiladi. Vazifalar navbatga qo‘yiladi. Qaysi worker bo‘shasa, navbatdagi vazifani o‘sha worker oladi.

Masalan, 1000 ta faylni qayta ishlash kerak bo‘lsin. Eng sodda variantda har bir fayl uchun bittadan goroutine yaratish mumkin. Lekin bu har doim ham yaxshi yechim emas.

Bir paytda juda ko‘p goroutine ish boshlasa:

* juda ko‘p fayl bir vaqtning o‘zida ochilishi mumkin;
* xotira sarfi oshishi mumkin;
* database connection pool limiti tugashi mumkin;
* tashqi API rate limit’dan oshib ketish mumkin;
* serverga yoki boshqa tashqi resursga ortiqcha yuk tushishi mumkin.

Worker pool bir vaqtda nechta vazifa bajarilishini cheklaydi.

Masalan, 1000 ta vazifa bor, lekin faqat 10 ta worker ishlayotgan bo‘lsa, bir paytda ko‘pi bilan 10 ta vazifa bajariladi. Worker bittasini tugatgach, navbatdagi vazifani oladi.

Buni taksi xizmati bilan tasavvur qilish mumkin. Mijozlar — bajarilishi kerak bo‘lgan vazifalar. Haydovchilar esa workerlar.

Mijozlar soni haydovchilar sonidan ko‘p bo‘lishi mumkin. Lekin bir haydovchi bir vaqtda faqat bitta mijozga xizmat qiladi. Haydovchi bo‘shagach, navbatdagi mijozni oladi.

Worker pool’da ham asosiy g‘oya aynan shu.

## Tuzilishning asosiy qismlari

Oddiy worker pool odatda to‘rtta asosiy qismdan iborat:

* producer vazifalarni yaratadi va `jobs` kanaliga yuboradi;
* bir nechta worker `jobs` kanalidan vazifalarni oladi;
* workerlar bajarilgan ish natijasini `results` kanaliga yuboradi;
* coordinator barcha worker tugashini kutadi va `results` kanalini yopadi.

Bu qismlarning vazifasini alohida ko‘rib chiqamiz.

**Producer** yangi ishlarni yaratadi. Masalan, fayl nomlari, URL’lar, database yozuvlari yoki hisoblanishi kerak bo‘lgan qiymatlar producer tomonidan `jobs` kanaliga yuborilishi mumkin.

**Worker** `jobs` kanalidan bitta vazifa oladi, uni bajaradi va kerak bo‘lsa natijani `results` kanaliga yuboradi.

**Coordinator** barcha workerlarning qachon tugaganini kuzatadi. Buning uchun ko‘pincha `sync.WaitGroup` ishlatiladi.

Bu yerda kanalni kim yopishi ham muhim.

`jobs` kanalini boshqa vazifa yuborilmasligini aniq biladigan tomon yopishi kerak. Odatda bu producer bo‘ladi.

`results` kanalini esa barcha worker tugaganini aniq biladigan tomon yopishi kerak. Odatda bu `WaitGroup`ni kutayotgan coordinator bo‘ladi.

Bir nechta workerning o‘zi `results` kanalini yopishga harakat qilmasligi kerak.

Sababi bir worker kanalni yopganidan keyin boshqa worker hali natija yuborishga urinishi mumkin:

```go
results <- result
```

Yopilgan kanalga yuborish esa panic keltirib chiqaradi:

```text
send on closed channel
```

Shuning uchun worker pool’da kanalning egasi va yopilish tartibi oldindan aniq bo‘lishi kerak.

## Birinchi ishlaydigan misol

Quyidagi misolda 5 ta ish va 3 ta worker bor:

```go
package main

import (
	"fmt"
	"sync"
)

type Result struct {
	JobID  int
	Worker int
	Value  int
}

func worker(id int, jobs <-chan int, results chan<- Result, wg *sync.WaitGroup) {
	defer wg.Done()

	for job := range jobs {
		results <- Result{
			JobID:  job,
			Worker: id,
			Value:  job * 2,
		}
	}
}

func main() {
	const jobCount = 5
	const workerCount = 3

	jobs := make(chan int, jobCount)
	results := make(chan Result, jobCount)

	var wg sync.WaitGroup
	wg.Add(workerCount)

	for id := 1; id <= workerCount; id++ {
		go worker(id, jobs, results, &wg)
	}

	go func() {
		for job := 1; job <= jobCount; job++ {
			jobs <- job
		}
		close(jobs)
	}()

	go func() {
		wg.Wait()
		close(results)
	}()

	for result := range results {
		fmt.Printf(
			"ish=%d worker=%d natija=%d\n",
			result.JobID,
			result.Worker,
			result.Value,
		)
	}
}
```

Natijaning mumkin bo‘lgan ko‘rinishi:

```text
ish=1 worker=1 natija=2
ish=2 worker=2 natija=4
ish=3 worker=3 natija=6
ish=4 worker=1 natija=8
ish=5 worker=2 natija=10
```

Bu natija faqat mumkin bo‘lgan variantlardan biri.

Workerlar concurrent ishlaydi. Shu sabab qaysi ishni qaysi worker olishi oldindan aniq emas.

Masalan, boshqa ishga tushirishda quyidagicha natija chiqishi mumkin:

```text
ish=2 worker=2 natija=4
ish=1 worker=1 natija=2
ish=4 worker=2 natija=8
ish=3 worker=3 natija=6
ish=5 worker=1 natija=10
```

Bu xato emas.

Muhim narsa natijalarning tartibi emas. Muhim kafolat shuki, `jobs` kanaliga yuborilgan har bir ish bir worker tomonidan olinadi va worker kodida boshqa xato bo‘lmasa, uning natijasi `results` kanaliga yuboriladi.

Endi kodning asosiy qismlarini ko‘rib chiqamiz.

### Yo‘nalishli kanallar

Worker funksiyasining signature’i:

```go
func worker(
	id int,
	jobs <-chan int,
	results chan<- Result,
	wg *sync.WaitGroup,
)
```

Bu yerda:

```go
jobs <-chan int
```

`jobs` kanalini faqat o‘qish mumkinligini bildiradi.

Worker quyidagini qila oladi:

```go
job := <-jobs
```

Lekin quyidagini qila olmaydi:

```go
jobs <- 10
```

Chunki `jobs` worker uchun receive-only channel.

Natija kanali esa:

```go
results chan<- Result
```

ko‘rinishida berilgan.

Bu send-only channel. Worker unga qiymat yuborishi mumkin:

```go
results <- result
```

Lekin undan qiymat o‘qiy olmaydi.

Yo‘nalishli kanallar runtime optimizatsiyasi uchun emas, API va compile-time xavfsizligi uchun foydali.

Funksiya qaysi kanal bilan nima qilishi mumkinligini uning signature’idan ko‘rish mumkin. Agar worker tasodifan noto‘g‘ri amal qilsa, kompilyator xatoni ushlaydi.

### Workerning ish sikli

Worker ichida:

```go
for job := range jobs {
	// ...
}
```

ishlatilgan.

Channel ustida `range` qilish kanal yopilguncha qiymatlarni qabul qilishni anglatadi.

Producer:

```go
close(jobs)
```

qilganda, worker darhol sikldan chiqib ketmaydi.

Agar channel bufferida hali vazifalar bo‘lsa, ular avval olinadi. Buffer bo‘shagach va boshqa qiymat kelmasligi aniq bo‘lgach, `range` tugaydi.

Demak, yopilgan channel ichidagi eski qiymatlar yo‘qolib ketmaydi.

### `WaitGroup` nima uchun kerak?

Har bir worker boshida:

```go
defer wg.Done()
```

yozilgan.

`main` esa workerlarni ishga tushirishdan oldin:

```go
wg.Add(workerCount)
```

chaqiradi.

Agar `workerCount == 3` bo‘lsa, `WaitGroup` hisoblagichi 3 ga o‘rnatiladi.

Har bir worker tugaganda:

```go
wg.Done()
```

hisoblagichni bittaga kamaytiradi.

Jarayon quyidagicha:

```text
Boshlanish:
WaitGroup = 3

1-worker tugadi:
WaitGroup = 2

2-worker tugadi:
WaitGroup = 1

3-worker tugadi:
WaitGroup = 0
```

`wg.Wait()` hisoblagich `0` bo‘lguncha kutadi.

Coordinator:

```go
go func() {
	wg.Wait()
	close(results)
}()
```

orqali barcha worker tugashini kutmoqda.

Faqat shundan keyin:

```go
close(results)
```

qilinadi.

Bu juda muhim. Chunki `results` kanali workerlar hali unga qiymat yuborayotgan paytda yopilsa, `send on closed channel` panici yuz beradi.

### Natijalarni qabul qilish

`main` quyidagi sikl bilan natijalarni yig‘adi:

```go
for result := range results {
	fmt.Printf(
		"ish=%d worker=%d natija=%d\n",
		result.JobID,
		result.Worker,
		result.Value,
	)
}
```

Bu sikl `results` kanali yopilguncha ishlaydi.

Tartib quyidagicha:

```text
producer
   |
   v
jobs
   |
   +------> worker 1 ----+
   +------> worker 2 ----+----> results ----> main
   +------> worker 3 ----+
              |
              v
          WaitGroup
              |
              v
       close(results)
```

Shu tartib bir nechta keng tarqalgan muammoning oldini oladi:

* workerlar `jobs` kanalini abadiy kutib qolmaydi;
* `results` workerlar tugashidan oldin yopilmaydi;
* `main` kanal yopilgach `range` siklidan chiqadi;
* natijalar qabul qilinmay qolib workerlar bloklanib qolmaydi.

## Buffer va qarshi bosim

Yuqoridagi misolda kanallar quyidagicha yaratilgan:

```go
jobs := make(chan int, jobCount)
results := make(chan Result, jobCount)
```

`jobCount == 5` bo‘lsa, har ikkala kanal ham 5 ta qiymat saqlay oladi.

Kichik misolda bu kodni tushunishni osonlashtiradi. Lekin real loyihada barcha vazifalarni sig‘dira oladigan juda katta buffer yaratish har doim ham yaxshi emas.

Masalan, tizimga bir millionta vazifa kelishi mumkin bo‘lsa:

```go
jobs := make(chan Job, 1_000_000)
```

qilish katta navbatni xotirada saqlashga olib kelishi mumkin.

Workerlar vazifalarni ishlab ulgurmayotgan bo‘lsa, navbat yana ham o‘sadi.

Shu sabab buffer ko‘pincha cheklangan hajmda bo‘ladi.

Masalan:

```go
jobs := make(chan Job, 100)
```

Bu holda producer 100 tagacha vazifani navbatga qo‘ya oladi. Buffer to‘lsa, keyingi yuborish bloklanadi:

```go
jobs <- job
```

Producer workerlardan biri channel’dan qiymat olguncha shu qatorda kutadi.

Bu hodisa **backpressure**, ya’ni qarshi bosim deyiladi.

Oddiy qilib aytganda, iste’molchilar vazifalarni yetarlicha tez bajara olmayotgan bo‘lsa, ishlab chiqaruvchi ham sekinlashishga majbur bo‘ladi.

Bu juda foydali xususiyat.

Aks holda producer cheksiz tezlikda yangi ish yaratib, ularni xotirada yig‘ishi mumkin.

### Buffersiz channel

Agar:

```go
jobs := make(chan Job)
```

yozilsa, channel buffersiz bo‘ladi.

Producer:

```go
jobs <- job
```

qilganda, worker shu qiymatni qabul qilishga tayyor bo‘lguncha yuborish tugamaydi.

Ya’ni producer va worker bevosita sinxronlashadi.

### Bufferli channel

Agar:

```go
jobs := make(chan Job, 100)
```

yozilsa, producer bufferda bo‘sh joy bor ekan, worker shu zahoti qiymatni olmagan bo‘lsa ham davom etishi mumkin.

Masalan:

```text
buffer sig‘imi = 3

producer -> job1
producer -> job2
producer -> job3
```

Endi buffer to‘lgan.

Producer `job4`ni yubormoqchi bo‘lsa:

```text
producer -> job4
```

worker kamida bitta oldingi ishni channel’dan olmaguncha producer bloklanadi.

### Buffer hajmi worker soniga teng bo‘lishi shart emas

Masalan, 10 ta worker bo‘lsa:

```go
const workerCount = 10
```

channel bufferi ham aynan `10` bo‘lishi shart emas.

Quyidagi variantlarning barchasi texnik jihatdan mumkin:

```go
jobs := make(chan Job)
```

```go
jobs := make(chan Job, 10)
```

```go
jobs := make(chan Job, 100)
```

```go
jobs := make(chan Job, 1000)
```

Qaysi qiymat to‘g‘ri ekanini faqat worker soniga qarab aniqlab bo‘lmaydi.

Buffer hajmini tanlashda quyidagilarni hisobga olish kerak:

* vazifalar qanchalik tez keladi;
* bitta vazifa qancha vaqt bajariladi;
* vaqtinchalik yuklama sakrashlari bo‘ladimi;
* navbatda qancha ish saqlash mumkin;
* xotira sarfi qancha bo‘lishi mumkin;
* eski vazifaning navbatda uzoq kutishi qabul qilinadimi.

Demak, worker soni concurrency’ni boshqaradi. Channel bufferi esa navbat sig‘imini boshqaradi.

Bu ikkalasi bir xil tushuncha emas.

## Xato va bekor qilishni boshqarish

Real tizimda har bir vazifa muvaffaqiyatli tugamaydi.

Masalan:

* HTTP request xato qaytarishi mumkin;
* faylni ochib bo‘lmasligi mumkin;
* database query muvaffaqiyatsiz tugashi mumkin;
* kiruvchi qiymat yaroqsiz bo‘lishi mumkin.

Shu sabab natija ichida qiymat bilan birga xatoni ham uzatish foydali.

Masalan:

```go
type Result struct {
	JobID int
	Value int
	Err   error
}
```

Bu struct natijaning uchta muhim qismini saqlaydi:

* `JobID` — qaysi ish bajarilganini;
* `Value` — muvaffaqiyatli natijani;
* `Err` — bajarish vaqtida yuz bergan xatoni.

Ba’zi tizimlarda bitta ish xato qilsa ham qolgan vazifalarni davom ettirish kerak.

Boshqa tizimlarda esa birinchi jiddiy xatodan keyin butun poolni to‘xtatish kerak bo‘ladi.

Ikkinchi holatda `context.Context` yordam beradi.

Quyidagi misol manfiy qiymat uchrasa worker pool’ni bekor qiladi:

```go
package main

import (
	"context"
	"errors"
	"fmt"
	"sync"
)

type Job struct {
	ID    int
	Value int
}

type Result struct {
	JobID int
	Value int
	Err   error
}

func process(job Job) (int, error) {
	if job.Value < 0 {
		return 0, errors.New("manfiy qiymatga ruxsat berilmaydi")
	}

	return job.Value * job.Value, nil
}

func worker(
	ctx context.Context,
	jobs <-chan Job,
	results chan<- Result,
	wg *sync.WaitGroup,
) {
	defer wg.Done()

	for {
		select {
		case <-ctx.Done():
			return

		case job, ok := <-jobs:
			if !ok {
				return
			}

			value, err := process(job)

			result := Result{
				JobID: job.ID,
				Value: value,
				Err:   err,
			}

			select {
			case results <- result:
			case <-ctx.Done():
				return
			}
		}
	}
}

func main() {
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	jobs := make(chan Job)
	results := make(chan Result)

	var wg sync.WaitGroup

	const workerCount = 2

	wg.Add(workerCount)

	for id := 1; id <= workerCount; id++ {
		go worker(ctx, jobs, results, &wg)
	}

	go func() {
		defer close(jobs)

		input := []int{2, 3, -1, 4, 5}

		for id, value := range input {
			select {
			case jobs <- Job{
				ID:    id + 1,
				Value: value,
			}:
			case <-ctx.Done():
				return
			}
		}
	}()

	go func() {
		wg.Wait()
		close(results)
	}()

	for result := range results {
		if result.Err != nil {
			fmt.Printf(
				"ish=%d xato: %v\n",
				result.JobID,
				result.Err,
			)

			cancel()
			continue
		}

		fmt.Printf(
			"ish=%d natija=%d\n",
			result.JobID,
			result.Value,
		)
	}
}
```

Natija tartibi oldindan kafolatlanmaydi.

Masalan, quyidagi xato albatta yuz beradi:

```text
ish=3 xato: manfiy qiymatga ruxsat berilmaydi
```

Lekin bu xatodan oldin yoki undan keyin boshqa qaysi natijalar chiqishi scheduling’ga bog‘liq.

Masalan, quyidagicha bo‘lishi mumkin:

```text
ish=1 natija=4
ish=2 natija=9
ish=3 xato: manfiy qiymatga ruxsat berilmaydi
```

Yoki boshqa worker `4`-ishni allaqachon olib ulgurgan bo‘lsa, uning natijasi ham chiqishi mumkin.

### Worker bekor qilishni qanday kuzatadi?

Worker ichida:

```go
select {
case <-ctx.Done():
	return

case job, ok := <-jobs:
	// ...
}
```

bor.

Demak, worker bir vaqtning o‘zida ikkita hodisani kutmoqda:

* yangi ish kelishi;
* context bekor qilinishi.

Agar:

```go
cancel()
```

chaqirilsa, `ctx.Done()` kanali tayyor holatga keladi.

Worker undan signal olib:

```go
return
```

qilishi mumkin.

### `ok` nima uchun tekshiriladi?

Channel’dan quyidagicha o‘qilyapti:

```go
job, ok := <-jobs
```

Agar `jobs` ochiq bo‘lsa va qiymat kelsa:

```text
ok == true
```

bo‘ladi.

Agar channel yopilgan va ichida boshqa qiymat qolmagan bo‘lsa:

```text
ok == false
```

bo‘ladi.

Shu sabab:

```go
if !ok {
	return
}
```

workerga boshqa ish yo‘qligini bildiradi.

### Natija yuborishda ham context tekshiriladi

Kodda natija shunchaki:

```go
results <- result
```

qilinmagan.

Buning o‘rniga:

```go
select {
case results <- result:
case <-ctx.Done():
	return
}
```

ishlatilgan.

Bu muhim.

Tasavvur qiling, consumer natijalarni qabul qilishni to‘xtatdi. `results` esa buffersiz yoki bufferi to‘lgan.

Agar worker:

```go
results <- result
```

qatorida tursa, u boshqa tomon natijani qabul qilmaguncha bloklanadi.

Context bekor qilingan bo‘lsa ham, oddiy send operatsiyasi buni avtomatik sezmaydi.

`select` ishlatilganda worker ikkita imkoniyatga ega:

* natijani yuborish;
* context bekor qilingan bo‘lsa chiqish.

Shu sabab bekor qilish signali faqat `jobs`ni kutishda emas, potensial bloklanadigan boshqa joylarda ham tekshirilishi kerak.

### Producer ham context’ni kuzatadi

Producer:

```go
select {
case jobs <- Job{
	ID:    id + 1,
	Value: value,
}:
case <-ctx.Done():
	return
}
```

qiladi.

Bu ham xuddi shu sababga ko‘ra kerak.

Agar workerlar bekor qilish sababli to‘xtab qolgan bo‘lsa, producer oddiy:

```go
jobs <- job
```

qatorida abadiy kutib qolmasligi kerak.

### `cancel()` darhol hamma narsani to‘xtatmaydi

Bu yerda muhim nozik joy bor.

Context cancellation — signal.

U ishlayotgan goroutine’ni operatsion tizim darajasida majburan to‘xtatadigan buyruq emas.

Masalan:

```go
value, err := process(job)
```

chaqirilgan bo‘lsin.

Agar `process` uzoq vaqt ishlasa:

```go
func process(job Job) (int, error) {
	// 30 soniyalik ish
}
```

shu paytda boshqa goroutine:

```go
cancel()
```

qilgan bo‘lsa ham, `process` o‘z-o‘zidan to‘xtamaydi.

Agar uzoq davom etadigan operatsiyani ham bekor qilish kerak bo‘lsa, `context` unga ham uzatilishi kerak:

```go
func process(ctx context.Context, job Job) (int, error) {
	// ctx.Done()ni kerakli joylarda tekshirish
}
```

HTTP, database va boshqa ko‘plab standard API’larda ham context’li metodlar aynan shu maqsadda ishlatiladi.

### `select` tanlovi ham deterministik emas

Agar bir vaqtning o‘zida:

```go
ctx.Done()
```

ham tayyor bo‘lsa va:

```go
jobs
```

kanalida ham qiymat bo‘lsa, `select` tayyor case’lardan birini tanlaydi.

Shu sabab `cancel()` chaqirilgandan keyin hech bir yangi ish boshlanmaydi, deb qat’iy kafolat berib bo‘lmaydi.

Ba’zi workerlar allaqachon tayyor bo‘lgan vazifani olib ulgurgan bo‘lishi mumkin.

Bekor qilishni “imkon qadar tez to‘xtash” deb tushunish to‘g‘riroq.

## Natijalar tartibini saqlash

Worker pool bajarilish tartibini kafolatlamaydi.

Masalan, quyidagi ishlar yuborilgan bo‘lsin:

```text
1
2
3
4
```

`1`-ish 500 ms davom etishi mumkin.

`2`-ish esa 20 ms’da tugashi mumkin.

Shunda natija:

```text
2
1
```

tartibida kelishi tabiiy.

Concurrent bajarilishning foydasi ham shunda: bitta sekin ish qolgan ishlarni to‘liq ushlab turmaydi.

Lekin ba’zan natijalarni aynan kirish tartibida qaytarish talab qilinadi.

Bunday holatda har bir ishga indeks berish mumkin.

Masalan:

```go
ordered := make([]int, jobCount)

for result := range results {
	ordered[result.JobID-1] = result.Value
}
```

Agar:

```text
JobID = 1
```

bo‘lsa:

```go
ordered[0] = result.Value
```

yoziladi.

Agar:

```text
JobID = 5
```

bo‘lsa:

```go
ordered[4] = result.Value
```

yoziladi.

Natijalar channel’dan istalgan tartibda kelishi mumkin, lekin slice ichida original indeks bo‘yicha joylashtiriladi.

Masalan, natijalar quyidagicha kelsin:

```text
JobID=3 Value=30
JobID=1 Value=10
JobID=2 Value=20
```

Yig‘ilgandan keyin:

```text
ordered[0] = 10
ordered[1] = 20
ordered[2] = 30
```

bo‘ladi.

Natijada:

```text
[10 20 30]
```

tartibi tiklanadi.

Bu usulning kamchiligi ham bor.

Barcha natijalar xotirada saqlanadi:

```go
ordered := make([]int, jobCount)
```

Agar millionlab katta natijalar bo‘lsa, bu sezilarli xotira talab qilishi mumkin.

Bunday vaziyatda tartibni tiklaydigan alohida collector bosqichi kerak bo‘lishi mumkin.

Masalan, collector keyingi kutilayotgan indeksni saqlaydi. Undan oldin kelgan kelajak natijalarni esa cheklangan vaqtinchalik bufferda ushlab turadi.

Agar tartib umuman talab qilinmasa, natijani kelishi bilan qayta ishlash odatda yaxshiroq.

Bu:

* kamroq xotira ishlatadi;
* birinchi natijani tezroq qayta ishlash imkonini beradi;
* barcha ishlar tugashini kutish zaruratini kamaytiradi.

## Worker sonini tanlash

Worker pool’dagi eng muhim savollardan biri — nechta worker yaratish kerakligi.

Bu yerda universal son yo‘q.

“Worker qancha ko‘p bo‘lsa, dastur shuncha tez ishlaydi” degan qoida noto‘g‘ri.

Ko‘p worker ba’zan foyda beradi. Ba’zan esa aksincha, tizimni sekinlashtiradi yoki tashqi resurslarni haddan tashqari yuklaydi.

### CPU-bound ishlar

CPU-bound vazifa vaqtining asosiy qismini hisoblashga sarflaydi.

Masalan:

* katta matematik hisob;
* rasmni qayta ishlash;
* compression;
* hashing;
* encoding;
* katta hajmdagi parsing.

Bunday vazifalarda worker sonini mavjud parallelizmga yaqin tutish ko‘pincha yaxshi boshlang‘ich nuqta bo‘ladi.

Juda ko‘p worker yaratish CPU’ni ko‘paytirmaydi.

Aksincha:

* scheduling xarajati oshadi;
* goroutinelar ko‘proq navbatda turadi;
* cache samaradorligi pasayishi mumkin;
* context switching ko‘payishi mumkin.

Shuning uchun CPU-bound ishda “mingta worker” avtomatik ravishda “tezroq” degani emas.

### I/O-bound ishlar

I/O-bound vazifalar vaqtining katta qismini tashqi operatsiyani kutishga sarflaydi.

Masalan:

* HTTP request;
* diskdan o‘qish;
* database query;
* network socket;
* tashqi servis javobi.

Bunday holatda workerlar soni CPU sonidan ko‘proq bo‘lishi mumkin.

Sababi ko‘p goroutine bir vaqtda CPU ishlatayotgan bo‘lmaydi. Ularning ko‘pi I/O javobini kutadi.

Masalan, 100 ta worker bo‘lishi mumkin, lekin istalgan paytda ulardan faqat bir nechtasi real CPU ishini bajarayotgan bo‘lishi mumkin.

Lekin bu ham “qancha ko‘p bo‘lsa, shuncha yaxshi” degani emas.

Tashqi tizim limitlari hisobga olinishi kerak.

### Database bilan ishlash

Database uchun worker soni connection pool bilan bog‘liq bo‘lishi mumkin.

Masalan:

```text
worker = 100
DB max connections = 10
```

bo‘lsa, barcha worker bir vaqtda query bajara olmaydi.

Ko‘pchilik worker connection kutib qoladi.

Bunday pool ba’zan foydasiz navbat va timeout’larni ko‘paytirishi mumkin.

### Tashqi API bilan ishlash

API quyidagi limitni qo‘ygan bo‘lishi mumkin:

```text
sekundiga 20 request
```

Agar siz 500 ta worker ishga tushirsangiz, dastur ichki jihatdan tez request yubora olishi mumkin, lekin tashqi xizmat:

```text
429 Too Many Requests
```

qaytarishi mumkin.

Shuning uchun worker soni quyidagilar bilan birga tanlanadi:

* API rate limit;
* serverning tavsiya etilgan concurrency limiti;
* timeout;
* retry strategiyasi;
* network bandwidth.

### Eng yaxshi qiymat o‘lchanadi

Worker sonini faqat nazariy taxmin bilan tanlash yetarli emas.

Amaliyotda:

* benchmark;
* profiling;
* latency metrikalari;
* throughput;
* CPU;
* xotira;
* connection soni;
* error rate

kabi ko‘rsatkichlarni kuzatish kerak.

Masalan, worker sonini:

```text
10 -> 20 -> 50 -> 100
```

oshirib ko‘rish mumkin.

Agar throughput `50` workerdan keyin deyarli oshmasa, lekin xotira va latency yomonlashsa, yana worker qo‘shish foydasiz bo‘lishi mumkin.

### Worker soni `0` bo‘lsa

Bu edge case’ni unutmaslik kerak.

Masalan:

```go
const workerCount = 0
```

bo‘lsa, birorta worker yaratilmaydi.

Producer esa:

```go
jobs <- job
```

qilishga urinadi.

Agar channel’ni hech kim o‘qimasa, producer bloklanadi.

Shu sabab umumiy worker pool API yaratilganda:

```go
workerCount > 0
```

sharti tekshirilishi kerak.

Masalan:

```go
if workerCount <= 0 {
	return errors.New("workerCount musbat bo‘lishi kerak")
}
```

### Juda katta navbat ham muammo

Concurrency cheklangan bo‘lsa ham, navbat juda katta bo‘lishi mumkin.

Masalan:

```text
worker = 10
jobs buffer = 1 000 000
```

Bu bir paytda faqat 10 ta ish bajarilishini ta’minlaydi. Lekin bir milliontagacha ish xotirada navbatda turishi mumkin.

Natijada:

* xotira ko‘p ishlatiladi;
* eski vazifalar juda uzoq kutadi;
* foydalanuvchi bekor qilgan ishlar ham navbatda qolishi mumkin;
* tizim overload holatini kech sezadi.

Shuning uchun concurrency limiti va queue limiti alohida boshqariladi.

## Panic va resurslarni tozalash

Workerlarda ko‘pincha:

```go
defer wg.Done()
```

ishlatiladi.

Bu yaxshi amaliyot.

Worker funksiyasi quyidagi kabi oddiy yo‘llardan qaysi biri bilan tugashidan qat’i nazar:

```go
return
```

yoki sikl yakunlanishi orqali chiqsa, `wg.Done()` bajariladi.

Masalan:

```go
func worker(wg *sync.WaitGroup) {
	defer wg.Done()

	// ish
}
```

Bu `WaitGroup` hisoblagichini unutib kamaytirmaslikka yordam beradi.

Lekin panic alohida masala.

Agar worker ichida panic yuz bersa va hech qayerda `recover` qilinmasa, odatda butun Go dasturi to‘xtaydi.

Masalan:

```go
func worker() {
	panic("kutilmagan xato")
}
```

Goroutine’da yuz bergan unrecovered panic faqat shu goroutine’ni jim tugatmaydi. Runtime stack trace chiqarib, process’ni yakunlaydi.

Ba’zi server yoki task-processing tizimlarida worker chegarasida `recover` ishlatish kerak bo‘lishi mumkin.

Lekin panic’ni shunchaki:

```go
recover()
```

bilan yutib yuborish ham yaxshi yechim emas.

Panic sodir bo‘lsa, odatda kamida:

* panic qiymatini loglash;
* stack trace saqlash;
* uni xato natijasiga aylantirish kerakmi, aniqlash;
* tizim holati buzilganmi, tekshirish

kerak bo‘ladi.

Masalan, worker bajarilgan operatsiyaning yarmini yozib, keyin panic qilgan bo‘lsa, ishni oddiy retry qilish ham xavfli bo‘lishi mumkin.

### Har bir ish ochgan resurs yopilishi kerak

Workerlar ko‘p vazifa bajargani uchun resource leak tez kattalashishi mumkin.

Masalan, har bir vazifa fayl ochadi:

```go
file, err := os.Open(name)
```

Fayl yopilmasa, ko‘p vazifadan keyin process file descriptor limitiga yetishi mumkin.

Yoki HTTP response:

```go
resp, err := client.Do(req)
```

olinsa, kerakli holatda:

```go
resp.Body.Close()
```

qilinishi kerak.

Bu database row, transaction, socket va boshqa resurslarga ham tegishli.

Worker pool concurrency’ni boshqaradi. Lekin u worker ichidagi resurslarni avtomatik tozalab bermaydi.

## Keng tarqalgan xatolar

### `jobs` kanalini yopmaslik

Worker:

```go
for job := range jobs {
	// ...
}
```

ishlatayotgan bo‘lsa, channel yopilmaguncha yangi qiymat kutishda davom etadi.

Producer barcha vazifalarni yuborib bo‘lgach ham:

```go
close(jobs)
```

qilmasa, workerlar sikldan chiqmaydi.

Natijada:

```go
wg.Wait()
```

ham tugamasligi mumkin.

### Kanalni bir nechta workerdan yopish

Masalan, har bir worker oxirida:

```go
close(results)
```

qilsa, bu noto‘g‘ri.

Birinchi tugagan worker kanalni yopadi.

Keyingi worker:

```go
results <- result
```

qilsa:

```text
panic: send on closed channel
```

yuz beradi.

Kanalni yopish qoidasi oddiy:

> Kanalni boshqa qiymat yuborilmasligini aniq biladigan tomon yopishi kerak.

Ko‘p yuboruvchili channel’da buni bitta worker odatda bilmaydi.

### `results`ni workerlar tugashidan oldin yopish

Masalan:

```go
close(results)
wg.Wait()
```

tartibi noto‘g‘ri.

To‘g‘ri tartib:

```go
wg.Wait()
close(results)
```

Avval barcha yuboruvchi workerlar tugaydi. Keyin kanal yopiladi.

### Natijalarni hech kim qabul qilmasligi

Tasavvur qiling:

```go
results := make(chan Result, 10)
```

bor.

Workerlar natija yubormoqda, lekin hech kim:

```go
<-results
```

qilmayapti.

Birinchi 10 ta qiymat bufferga tushishi mumkin.

Keyingi worker:

```go
results <- result
```

qatorida bloklanadi.

Worker tugamagani uchun:

```go
wg.Done()
```

ham chaqirilmaydi.

Coordinator esa:

```go
wg.Wait()
```

qatorida kutadi.

Shunday qilib deadlockga o‘xshash holat yuzaga keladi.

### Natijalar kirish tartibida keladi deb hisoblash

Concurrent workerlar bir xil tezlikda ishlamaydi.

Shuning uchun:

```text
job1
job2
job3
```

yuborilgan bo‘lsa, natija:

```text
job2
job3
job1
```

tartibida kelishi mumkin.

Tartib talab qilinsa, uni alohida tiklash kerak.

### Har bir ish uchun yana nazoratsiz goroutine yaratish

Masalan, 10 ta worker concurrency’ni `10` bilan cheklash uchun yaratilgan bo‘lsin.

Lekin worker ichida:

```go
for job := range jobs {
	go process(job)
}
```

qilinsa, poolning chegarasi amalda buziladi.

Workerning o‘zi tezda barcha vazifalarni olib, har biri uchun yangi goroutine yaratishi mumkin.

Natijada:

```text
workerCount = 10
```

bo‘lsa ham, yuzlab yoki minglab `process` goroutine bir vaqtda ishlashi mumkin.

Agar ichki goroutine’lar ham kerak bo‘lsa, ular uchun alohida concurrency nazorati bo‘lishi kerak.

### `WaitGroup.Add`ni goroutine ishga tushgandan keyin chaqirish

Quyidagi tartibdan qochish kerak:

```go
go worker(&wg)
wg.Add(1)
```

Worker juda tez tugab:

```go
wg.Done()
```

ni `Add`dan oldin chaqirishi mumkin.

Shuning uchun hisoblagich goroutine ishga tushirilishidan oldin oshiriladi:

```go
wg.Add(1)
go worker(&wg)
```

Ko‘p worker uchun:

```go
wg.Add(workerCount)

for i := 0; i < workerCount; i++ {
	go worker(&wg)
}
```

ko‘rinishi aniq va xavfsiz.

### Ishlatilgan `WaitGroup`ni nusxalash

`sync.WaitGroup` birinchi ishlatilgandan keyin nusxalanmasligi kerak.

Masalan, funksiyaga qiymat sifatida uzatish noto‘g‘ri dizaynga olib keladi:

```go
func worker(wg sync.WaitGroup) {
	// ...
}
```

Bu yerda worker `WaitGroup`ning nusxasi bilan ishlashi mumkin.

Odatda pointer uzatiladi:

```go
func worker(wg *sync.WaitGroup) {
	defer wg.Done()
}
```

Shu sabab yuqoridagi worker pool misollarida ham:

```go
wg *sync.WaitGroup
```

ishlatilgan.

## Interviewda muhim nuqtalar

Worker pool haqida savol berilganda bir nechta tushunchani bir-biridan aniq ajratish kerak.

Birinchidan, worker pool concurrency’ni boshqaradi.

Masalan:

```text
1000 ta ish
10 ta worker
```

bo‘lsa, worker pool bir paytda ko‘pi bilan taxminan 10 ta worker darajasidagi ish bajarilishini ta’minlaydi.

Channel bufferi esa boshqa narsani boshqaradi.

Masalan:

```text
10 ta worker
100 ta buffer
```

bo‘lsa, 10 ta ish bajarilayotgan, yana 100 tagacha ish channel navbatida turgan bo‘lishi mumkin.

Demak:

```text
worker soni != queue hajmi
```

Ikkinchidan, channel’ni yopish qiymatlarni o‘chirib yubormaydi.

Agar bufferda:

```text
job1
job2
job3
```

turgan paytda:

```go
close(jobs)
```

qilinsa, receiverlar avval shu qiymatlarni olishi mumkin.

Faqat buffer tugagach, receive operatsiyasida:

```go
value, ok := <-jobs
```

uchun:

```text
ok == false
```

bo‘ladi.

Uchinchidan, worker pool natijalar tartibini kafolatlamaydi.

Concurrent bajarilishda tez tugagan ishning natijasi oldin keladi.

To‘rtinchidan, `sync.WaitGroup` faqat goroutinelarning tugashini kutadi.

U:

* xatoni uzatmaydi;
* context yaratmaydi;
* bekor qilish signalini yubormaydi;
* kanalni avtomatik yopmaydi;
* panic’ni boshqarmaydi.

Bu vazifalar uchun alohida mexanizm kerak.

Beshinchidan, bekor qilish faqat workerning boshida tekshirilishi yetarli emas.

Agar producer yuborishda bloklanishi mumkin bo‘lsa, u ham context’ni kuzatishi kerak.

Agar worker natija yuborishda bloklanishi mumkin bo‘lsa, u yerda ham context tekshirilishi kerak.

Agar `process` uzoq davom etsa, u ham bekor qilish signalini tushunishi kerak.

Shu sabab to‘liq cancellation flow taxminan quyidagicha ko‘rinadi:

```text
cancel()
   |
   v
context
   |
   +----> producer to‘xtaydi
   |
   +----> jobs kutayotgan worker to‘xtaydi
   |
   +----> result yuborayotgan worker to‘xtaydi
   |
   +----> context’ni qabul qiladigan uzoq process ham to‘xtashi mumkin
```

Ishonchli worker pool yozishda faqat worker goroutinelarini yaratish yetarli emas. Vazifalar navbati, kanal egasi, yopilish tartibi, natijalarni qabul qilish, backpressure, xato, cancellation va tashqi resurs limitlari bir-biri bilan birga ko‘rib chiqiladi.
