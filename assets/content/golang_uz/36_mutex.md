# Mutex

Mutex — bir nechta goroutine bir xil umumiy ma’lumot bilan ishlaganda, shu ma’lumotga kirishni boshqaradigan sinxronizatsiya vositasi.

Go’da mutex `sync.Mutex` turi orqali ishlatiladi.

Oddiy qilib aytganda, mutex ma’lumot atrofida qulf yaratadi. Bir goroutine qulfni olsa, boshqa goroutinelar o‘sha qulf bo‘shatilguncha kutadi.

Masalan, ikkita goroutine bir xil `counter` qiymatini bir vaqtda o‘zgartirmoqchi bo‘lsa, mutex yordamida ularning yozish amallarini ketma-ket bajarish mumkin.

Bir nechta goroutine faqat bir xil ma’lumotni o‘qisa, odatda muammo bo‘lmaydi. Ammo ulardan kamida bittasi shu xotira joyiga yozsa, murojaatlarni muvofiqlashtirish kerak.

Aks holda:

* qiymat noto‘g‘ri chiqishi;
* bir yozish ikkinchisini bosib ketishi;
* data race yuz berishi

mumkin.

Bank hisobini tasavvur qilamiz.

Hisobda `1000` so‘m bor. Bankomat `800` so‘m yechmoqchi. Shu paytda mobil ilova ham `700` so‘m yechishga urinmoqda.

Agar ikkala operatsiya bir vaqtda eski balansni o‘qisa, ikkalasi ham:

```text
Balans = 1000
```

qiymatini ko‘rishi mumkin.

Bankomat:

```text
1000 >= 800
```

deb tekshiradi.

Mobil ilova esa:

```text
1000 >= 700
```

deb tekshiradi.

Ikkala tekshiruv ham alohida qaralganda to‘g‘ri. Ammo hisobdagi jami pul ikkala yechishni bajarishga yetmaydi.

Shu sabab balansni tekshirish va undan pul kamaytirish alohida-alohida emas, bitta himoyalangan mantiqiy amal sifatida bajarilishi kerak.

Mutex aynan shunday holatlarda ishlatiladi.

## Data race va race condition

**Data race** bir nechta goroutine bir xil xotira joyiga yetarli sinxronizatsiyasiz murojaat qilganda va murojaatlardan kamida bittasi yozish bo‘lganda yuz beradi. **Race condition** esa dastur natijasi amallar tartibiga noto‘g‘ri bog‘lanib qolgan kengroq mantiqiy muammodir.

Mutex umumiy xotiraga concurrent murojaatdan keladigan data racening oldini olishga yordam beradi. Buning uchun shu ma’lumotga kiradigan barcha kod bir xil mutex va qulflash qoidasiga amal qilishi kerak.

Data race ta’rifi, `-race` buyrug‘i va detector cheklovlari Race detector darsida batafsil tushuntirilgan.

## Nima uchun `counter++` xavfsiz emas?

Quyidagi kod juda oddiy ko‘rinadi:

```go
counter++
```

Manba kodida bu bitta qator.

Lekin concurrent dasturlash nuqtayi nazaridan uni avtomatik ravishda atomar amal deb hisoblash mumkin emas.

Mantiqan `counter++` uchta bosqichdan iborat:

1. `counter` qiymatini o‘qish;
2. qiymatni `1` ga oshirish;
3. yangi qiymatni xotiraga yozish.

Masalan, boshlang‘ich qiymat:

```text
counter = 10
```

bo‘lsin.

Ikki goroutine bir paytda ishlasa, quyidagi holat yuz berishi mumkin:

```text
Goroutine A: counter qiymatini o‘qiydi -> 10
Goroutine B: counter qiymatini o‘qiydi -> 10

Goroutine A: 10 + 1 -> 11
Goroutine B: 10 + 1 -> 11

Goroutine A: counter = 11
Goroutine B: counter = 11
```

Ikki marta oshirish bajarildi. Ammo yakuniy qiymat:

```text
11
```

bo‘lib qoldi.

Kutilgan natija esa:

```text
12
```

edi.

Demak, oshirishlardan biri yo‘qolib ketdi.

Quyidagi dastur ataylab noto‘g‘ri yozilgan:

```go
package main

import (
	"fmt"
	"sync"
)

func main() {
	var wg sync.WaitGroup
	counter := 0

	for i := 0; i < 1000; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			counter++ // Noto‘g‘ri: umumiy qiymat himoyalanmagan.
		}()
	}

	wg.Wait()
	fmt.Println("Hisoblagich:", counter)
}
```

Bu yerda `1000` ta goroutine yaratilmoqda.

Har bir goroutine:

```go
counter++
```

amalini bajaradi.

Nazariy jihatdan:

```text
0 + 1000 = 1000
```

bo‘lishi kerak.

Ammo `counter` umumiy o‘zgaruvchi. Barcha goroutinelar bir xil xotira joyiga yozmoqda.

Shuning uchun natija ba’zan:

```text
Hisoblagich: 1000
```

bo‘lishi mumkin.

Boshqa ishga tushirishda esa, masalan:

```text
Hisoblagich: 987
```

yoki boshqa qiymat chiqishi mumkin.

Muhim joyi shundaki, bir marta `1000` chiqishi kod xavfsiz ekanini isbotlamaydi.

Concurrent kodning haqiqiy bajarilish tartibiga quyidagilar ta’sir qiladi:

* Go scheduler;
* CPU yadrolari soni;
* operatsion tizim scheduler’i;
* boshqa goroutinelarning ishlashi;
* optimizatsiyalar;
* dastur ishga tushgan paytdagi umumiy yuklama.

Shuning uchun data race mavjud kod ba’zan "to‘g‘ri" ishlayotgandek ko‘rinishi mumkin.

Bunday kodni `go run -race main.go` bilan tekshirish mumkin. Buyruq va uning natijasini talqin qilish Race detector darsida, performance o‘lchovi esa Benchmark darsida alohida ko‘rib chiqiladi.

## `Mutex` qanday ishlatiladi?

`sync.Mutex`ning ikkita asosiy metodi bor:

* `Lock()` — qulfni olish;
* `Unlock()` — olingan qulfni bo‘shatish.

Oddiy ko‘rinishi:

```go
mu.Lock()

// Himoyalangan kod.

mu.Unlock()
```

Agar `Lock()` chaqirilgan paytda mutex bo‘sh bo‘lsa, goroutine qulfni oladi va ishlashda davom etadi.

Agar qulf boshqa goroutine tomonidan ushlab turilgan bo‘lsa, yangi goroutine `Lock()` ichida kutadi.

Qulf bo‘shatilgandan keyin kutayotgan goroutinelardan biri ishlashda davom etishi mumkin.

`Lock()` va `Unlock()` orasidagi kod **kritik bo‘lim** yoki **critical section** deyiladi.

Masalan:

```go
mu.Lock()
counter++
mu.Unlock()
```

Bu yerda faqat:

```go
counter++
```

amali mutex bilan himoyalangan.

Natijada bir vaqtda faqat bitta goroutine shu kritik bo‘lim ichida bo‘lishi mumkin.

### `Mutex`ning zero value qiymati

`sync.Mutex` ishlatish uchun alohida konstruktor kerak emas.

Quyidagi kodning o‘zi yetarli:

```go
var mu sync.Mutex
```

`sync.Mutex`ning zero value qiymati foydalanishga tayyor mutex hisoblanadi.

Shuning uchun, masalan, bunday yozish shart emas:

```go
mu := NewMutex()
```

Go standard library’da `sync.Mutex` uchun bunday konstruktor ham yo‘q.

Endi oldingi hisoblagich misolini mutex bilan to‘g‘rilaymiz:

```go
package main

import (
	"fmt"
	"sync"
)

func main() {
	var (
		wg      sync.WaitGroup
		mu      sync.Mutex
		counter int
	)

	for i := 0; i < 1000; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()

			mu.Lock()
			counter++
			mu.Unlock()
		}()
	}

	wg.Wait()
	fmt.Println("Hisoblagich:", counter)
}
```

Natija:

```text
Hisoblagich: 1000
```

Endi har bir goroutine `counter`ni oshirishdan oldin:

```go
mu.Lock()
```

chaqiradi.

Agar boshqa goroutine ayni paytda `counter`ni o‘zgartirayotgan bo‘lsa, yangi goroutine kutadi.

Birinchi goroutine:

```go
mu.Unlock()
```

qilgandan keyingina boshqa goroutine kritik bo‘limga kira oladi.

Natijada oshirish amallari bir-birining ustiga tushmaydi.

Bu misolda `WaitGroup` va `Mutex` birga ishlatilgan. Lekin ular turli vazifani bajaradi.

`WaitGroup`:

```go
wg.Wait()
```

orqali `main` funksiyasini barcha goroutinelar tugaguncha kutdiradi.

`Mutex` esa:

```go
mu.Lock()
counter++
mu.Unlock()
```

orqali umumiy `counter` qiymatini himoya qiladi.

Demak:

> `WaitGroup` goroutinelarning tugashini kutadi. `Mutex` esa umumiy xotiraga kirishni muvofiqlashtiradi.

`WaitGroup`ning o‘zi `counter`ni data racedan himoya qilmaydi.

Xuddi shuningdek, `Mutex` goroutinelarning hammasi tugashini kutmaydi.

## `defer` bilan qulfni bo‘shatish

Oddiy holatda mutex quyidagicha ishlatilishi mumkin:

```go
mu.Lock()
counter++
mu.Unlock()
```

Lekin funksiya ichida bir nechta `return` yo‘li bo‘lsa, `Unlock()`ni unutish oson.

Masalan:

```go
mu.Lock()

if someCondition {
	return
}

mu.Unlock()
```

Bu kodda `someCondition` rost bo‘lsa, funksiya `Unlock()`ga yetmasdan qaytadi.

Natijada mutex qulflangan holatda qoladi.

Keyingi:

```go
mu.Lock()
```

chaqiruvlari kutib qolishi mumkin.

Shuning uchun ko‘p hollarda qulf olingandan keyin darhol `defer` ishlatiladi:

```go
mu.Lock()
defer mu.Unlock()
```

`defer` sabab `mu.Unlock()` joriy funksiya qaytishidan oldin avtomatik chaqiriladi.

Masalan:

```go
func update() {
	mu.Lock()
	defer mu.Unlock()

	if someCondition {
		return
	}

	// Boshqa ishlar.
}
```

Bu yerda qaysi `return` orqali chiqilishidan qat’i nazar, mutex bo‘shatiladi.

`defer` panic paytida stack unwinding, ya’ni stek ochilishi jarayonida ham ishga tushadi.

Shuning uchun:

```go
defer mu.Unlock()
```

panic paytida ham qulfni bo‘shatishga yordam beradi.

Ammo bu panicni "davolamaydi".

Agar panic ushlanmasa, deferred funksiyalar bajarilgandan keyin dastur baribir to‘xtashi mumkin.

**Diqqat**

`defer mu.Unlock()`ni faqat `Lock()` muvaffaqiyatli chaqirilgandan keyin yozing.

Masalan:

```go
mu.Lock()
defer mu.Unlock()

to‘g‘ri tartib.

Qulf olinmagan mutexga:

```

```go
mu.Unlock()

chaqirish runtime xatosiga olib keladi.

Juda kichik va juda tez-tez chaqiriladigan kritik bo‘limlarda `defer`ning ozgina qo‘shimcha xarajati bo‘lishi mumkin.

Shunday holatda:

```

```go
mu.Lock()
counter++
mu.Unlock()
```

ko‘rinishidagi bevosita `Unlock()` biroz arzonroq bo‘lishi mumkin.

Lekin bu yerda amaliy qoida muhim:

> Avval kodning to‘g‘ri ishlashini ta’minlang. Keyin benchmark bilan performance muammosi borligini tekshiring.

Faqat taxmin asosida `defer`dan voz kechish `Unlock()` unutib ketiladigan xatolarni ko‘paytirishi mumkin.

## Bank hisobini xavfsiz boshqarish

Endi mutexni realroq misolda ko‘ramiz.

Umumiy ma’lumot bilan uni himoya qiladigan mutexni bitta tur ichida saqlash yaxshi amaliyot hisoblanadi.

Masalan, bank hisobi:

```go
package main

import (
	"errors"
	"fmt"
	"sync"
)

var (
	errInvalidAmount     = errors.New("miqdor musbat bo‘lishi kerak")
	errInsufficientFunds = errors.New("hisobda mablag‘ yetarli emas")
)

type Account struct {
	mu      sync.Mutex
	balance int
}

func NewAccount(initialBalance int) (*Account, error) {
	if initialBalance < 0 {
		return nil, errors.New("boshlang‘ich balans manfiy bo‘lishi mumkin emas")
	}

	return &Account{balance: initialBalance}, nil
}

func (a *Account) Withdraw(amount int) error {
	if amount <= 0 {
		return errInvalidAmount
	}

	a.mu.Lock()
	defer a.mu.Unlock()

	if a.balance < amount {
		return errInsufficientFunds
	}

	a.balance -= amount
	return nil
}

func (a *Account) Balance() int {
	a.mu.Lock()
	defer a.mu.Unlock()

	return a.balance
}

func main() {
	account, err := NewAccount(1000)
	if err != nil {
		fmt.Println("Hisob yaratilmadi:", err)
		return
	}

	requests := []struct {
		name   string
		amount int
	}{
		{name: "Bankomat", amount: 800},
		{name: "Mobil ilova", amount: 700},
	}

	var wg sync.WaitGroup
	results := make([]error, len(requests))

	for i, request := range requests {
		wg.Add(1)
		go func(index int, amount int) {
			defer wg.Done()
			results[index] = account.Withdraw(amount)
		}(i, request.amount)
	}

	wg.Wait()

	for i, request := range requests {
		if results[i] != nil {
			fmt.Printf("%s: %v\n", request.name, results[i])
			continue
		}
		fmt.Printf("%s: %d so‘m yechildi\n", request.name, request.amount)
	}

	fmt.Println("Yakuniy balans:", account.Balance())
}
```

Natijaning mumkin bo‘lgan ko‘rinishi:

```text
Bankomat: 800 so‘m yechildi
Mobil ilova: hisobda mablag‘ yetarli emas
Yakuniy balans: 200
```

Bu misolni bosqichma-bosqich ko‘rib chiqamiz.

### `Account` ichidagi mutex

```go
type Account struct {
	mu      sync.Mutex
	balance int
}
```

`balance` — bir nechta goroutine foydalanishi mumkin bo‘lgan umumiy holat.

`mu` esa shu holatni himoya qiladi.

Mutexni aynan himoyalanadigan maydon yonida saqlash kodning qaysi qulf qaysi ma’lumot uchun ishlatilishini tushunishni osonlashtiradi.

### Boshlang‘ich balansni tekshirish

```go
func NewAccount(initialBalance int) (*Account, error) {
	if initialBalance < 0 {
		return nil, errors.New("boshlang‘ich balans manfiy bo‘lishi mumkin emas")
	}

	return &Account{balance: initialBalance}, nil
}
```

Bu yerda hisob manfiy balans bilan yaratilishiga yo‘l qo‘yilmaydi.

Bu tekshiruv hali obyekt concurrent ishlatilishidan oldin bajariladi. Shu sabab bu joyda mutex kerak emas.

### `Withdraw` ichidagi oddiy tekshiruv

```go
if amount <= 0 {
	return errInvalidAmount
}
```

`amount` funksiyaga argument sifatida kelgan lokal qiymat.

Bu tekshiruv `Account`ning umumiy `balance` maydoniga murojaat qilmaydi.

Shuning uchun uni mutexdan oldin bajarish mumkin.

Buning foydasi shundaki, noto‘g‘ri `amount` kelganida mutexni umuman olish shart bo‘lmaydi.

Bu kritik bo‘limni qisqartiradi.

### Balansni himoyalash

Keyin:

```go
a.mu.Lock()
defer a.mu.Unlock()
```

bilan qulf olinadi.

Shundan keyingi kod:

```go
if a.balance < amount {
	return errInsufficientFunds
}

a.balance -= amount
```

bitta kritik bo‘lim ichida bajariladi.

Bu juda muhim.

Balansni tekshirish:

```go
a.balance < amount
```

va balansni kamaytirish:

```go
a.balance -= amount
```

bir-biriga bog‘liq amallar.

Ularni bitta mantiqiy amal deb qarash kerak.

Masalan, bunday yozish noto‘g‘ri bo‘lishi mumkin:

```go
if a.balance < amount {
	return errInsufficientFunds
}

a.mu.Lock()
a.balance -= amount
a.mu.Unlock()
```

Sababi tekshiruv bilan yozish orasida boshqa goroutine balansni o‘zgartirib yuborishi mumkin.

Masalan:

```text
Boshlang‘ich balans = 1000

Goroutine A tekshiradi:
1000 >= 800 -> ha

Goroutine B tekshiradi:
1000 >= 700 -> ha
```

Keyin ikkala goroutine ham pul yechishga urinishi mumkin.

Shu sabab mutex faqat:

```go
a.balance -= amount
```

qatorini emas, butun invariantni himoya qilishi kerak.

Bu misoldagi asosiy invariant:

> Hisob balansi pul yechish natijasida manfiy bo‘lib qolmasligi kerak.

Shuning uchun balansni tekshirish va o‘zgartirish bitta qulf ostida bajariladi.

### Qaysi so‘rov birinchi bajariladi?

Ikki goroutine yaratilgan:

```go
account.Withdraw(800)
```

va:

```go
account.Withdraw(700)
```

Lekin qaysi goroutine mutexni birinchi olishi kafolatlanmaydi.

Agar bankomat birinchi bo‘lsa:

```text
1000 - 800 = 200
```

bo‘ladi.

Keyin mobil ilova `700` so‘m yechishga urinadi:

```text
200 < 700
```

bo‘lgani sabab operatsiya rad etiladi.

Natija:

```text
Bankomat: 800 so‘m yechildi
Mobil ilova: hisobda mablag‘ yetarli emas
Yakuniy balans: 200
```

Agar mobil ilova birinchi ishlasa:

```text
1000 - 700 = 300
```

bo‘ladi.

Keyin bankomat uchun:

```text
300 < 800
```

bo‘ladi.

Bunday bajarilishda yakuniy balans:

```text
300
```

chiqadi.

Demak, muvaffaqiyatli operatsiya qaysi biri bo‘lishi scheduler tartibiga bog‘liq.

Ammo ikkala holatda ham muhim invariant saqlanadi:

* faqat bitta yechish muvaffaqiyatli tugaydi;
* balans manfiy bo‘lmaydi.

Mutex aynan shuni kafolatlash uchun ishlatilmoqda.

### `Balance` ham mutex ishlatadi

```go
func (a *Account) Balance() int {
	a.mu.Lock()
	defer a.mu.Unlock()

	return a.balance
}
```

Bir qarashda `Balance` faqat o‘qiyapti. Shuning uchun:

> Nima uchun o‘qish ham qulflanmoqda?

degan savol tug‘ilishi mumkin.

Sababi boshqa goroutine ayni paytda:

```go
a.balance -= amount
```

orqali shu qiymatga yozayotgan bo‘lishi mumkin.

Yozish bilan bir paytdagi himoyasiz o‘qish ham data race hisoblanadi.

Shuning uchun umumiy qoida:

> Agar bir ma’lumot mutex bilan himoyalansa, unga kiradigan barcha tegishli o‘qish va yozishlar bir xil sinxronizatsiya qoidasiga amal qilishi kerak.

### `results` slice haqida

Kodda:

```go
results := make([]error, len(requests))
```

yaratilgan.

Keyin har bir goroutine:

```go
results[index] = account.Withdraw(amount)
```

orqali faqat o‘z indeksiga yozadi.

Masalan:

```text
Goroutine 0 -> results[0]
Goroutine 1 -> results[1]
```

Slice header umumiy bo‘lsa ham, bu yerda uning uzunligi yoki sig‘imi o‘zgartirilmayapti.

Har bir goroutine oldindan mavjud alohida elementga yozmoqda.

`main` esa natijalarni faqat:

```go
wg.Wait()
```

dan keyin o‘qiydi.

Shu sabab ushbu aniq tuzilishda `results` uchun alohida mutex kerak emas.

## Mutexni ma’lumot bilan birga saqlash

Mutex odatda o‘zi himoya qiladigan ma’lumot bilan bir struct ichida saqlanadi.

Masalan:

```go
type Cache struct {
	mu    sync.Mutex
	items map[string]string
}
```

Bu tuzilishdan kodni o‘qiyotgan odam darhol quyidagi ma’noni tushunishi mumkin:

```text
mu -> items maydonini himoya qiladi
```

Masalan, metodlar quyidagicha yozilishi mumkin:

```go
func (c *Cache) Set(key, value string) {
	c.mu.Lock()
	defer c.mu.Unlock()

	c.items[key] = value
}
```

Bu yondashuv qulfning egasini aniq ko‘rsatadi.

### Nima uchun pointer receiver ishlatiladi?

Mutex saqlaydigan struct metodlari odatda pointer receiver bilan yoziladi:

```go
func (c *Cache) Set(...)
```

Buning sababi faqat `items`ni o‘zgartirish emas.

Yana muhim sabab bor:

> `sync.Mutex` nusxalanmasligi kerak.

Agar value receiver ishlatilsa:

```go
func (c Cache) Set(...)
```

receiver sifatida `Cache`ning nusxasi hosil bo‘lishi mumkin.

U bilan birga:

```go
c.mu
```

mutex ham nusxalanadi.

Bu juda xavfli.

Masalan, ikki goroutine aslida bir xil umumiy ma’lumot bilan ishlayotgandek ko‘rinadi. Lekin ular turli mutex nusxalarini qulflayotgan bo‘lishi mumkin.

Bunday holatda qulf real umumiy kirishni muvofiqlashtirmaydi.

Shu sabab `sync.Mutex` haqida muhim qoida bor:

> Mutex birinchi ishlatilgandan keyin nusxalanmasligi kerak.

Bu faqat receiver bilan bog‘liq emas.

Mutexli structni:

* funksiyaga qiymat sifatida uzatish;
* qiymat receiver orqali ishlatish;
* assignment orqali nusxalash;
* boshqa struct ichiga qiymat sifatida ko‘chirish

ham muammo tug‘dirishi mumkin.

Masalan:

```go
original := Cache{}
copy := original
```

agar mutex allaqachon ishlatilgan bo‘lsa, bunday nusxalash noto‘g‘ri dizaynga olib kelishi mumkin.

`go vet` ayrim mutex nusxalash holatlarini aniqlay oladi:

```bash
go vet ./...
```

Bu sabab `go vet` concurrent kod yozilganda foydali tekshiruvlardan biri hisoblanadi.

## Mutexning xotira kafolati

Mutex faqat:

> Bir goroutine kirsin, boshqasi kutsin.

degan mexanizm emas.

U Go memory modeli nuqtayi nazaridan xotira ko‘rinishini ham sinxronlashtiradi.

Masalan, bir goroutine quyidagicha ishlaydi:

```go
mu.Lock()
value = 42
mu.Unlock()
```

Keyinchalik boshqa goroutine shu mutexni olsa:

```go
mu.Lock()
fmt.Println(value)
mu.Unlock()
```

to‘g‘ri sinxronizatsiya tufayli oldingi goroutine qulfni bo‘shatishdan oldin qilgan yozuvlar keyingi goroutinega ko‘rinadi.

Sodda qilib aytganda:

> Bir goroutine mutex ostida ma’lumotni yangilab, keyin `Unlock()` qilsa, shu mutexni keyin muvaffaqiyatli `Lock()` qilgan boshqa goroutine o‘sha yangilanishlarni ko‘rishi mumkin.

Bu yerda asosiy shart:

* bir xil mutex ishlatilishi;
* qulf to‘g‘ri olinishi;
* ma’lumotga murojaat qilishda shu sinxronizatsiya tartibiga rioya qilinishi

kerak.

Agar bir goroutine `mu` bilan yozib, boshqa goroutine mutexsiz o‘qisa, bu kafolatdan foydalangan bo‘lmaydi.

## Kritik bo‘limni qisqa saqlash

Mutex ushlab turilgan paytda boshqa goroutinelar o‘sha mutexni ola olmaydi.

Masalan:

```go
mu.Lock()

// Uzoq davom etadigan ish.

mu.Unlock()
```

bo‘lsa, boshqa goroutinelar shu ish tugaguncha kutadi.

Shu sabab kritik bo‘lim imkon qadar faqat umumiy holatni tekshirish va o‘zgartirish uchun zarur kodni o‘z ichiga olishi kerak.

Qulf ichida quyidagi sekin yoki bloklanishi mumkin bo‘lgan amallarni bajarishda ehtiyot bo‘ling:

* tarmoq so‘rovi;
* database chaqiruvi;
* fayl o‘qish;
* fayl yozish;
* uzoq hisoblash;
* channelga bloklanuvchi yuborish;
* tashqi callback chaqirish;
* qancha vaqt ishlashi noma’lum metodni chaqirish.

Masalan:

```go
mu.Lock()

resp, err := http.Get(url)

mu.Unlock()
```

kabi kod xavfli performance xususiyatiga ega.

HTTP so‘rovi:

* bir necha millisekund;
* bir necha soniya;
* timeoutgacha

davom etishi mumkin.

Shu vaqt davomida boshqa goroutinelar `mu`ni ololmaydi.

Natijada contention, ya’ni bitta qulf uchun raqobat va kutish ko‘payadi.

Ko‘p hollarda yaxshiroq yondashuv:

1. mutexni olish;
2. kerakli umumiy ma’lumotni o‘qish yoki nusxalash;
3. mutexni bo‘shatish;
4. sekin operatsiyani tashqarida bajarish.

Masalan, konseptual ko‘rinishda:

```go
mu.Lock()
localValue := sharedValue
mu.Unlock()

doSlowOperation(localValue)
```

Lekin bu usul har doim ham to‘g‘ri emas.

Agar:

```text
tekshirish -> uzoq amal -> yangilash
```

jarayonining o‘rtasida umumiy holat o‘zgarishi mumkin bo‘lmasa, shunchaki mutexni erta bo‘shatish biznes mantiqini buzishi mumkin.

Bunday holatda algoritmni qayta loyihalash kerak bo‘lishi mumkin.

Shuning uchun asosiy maqsad:

> Mutexni imkon qadar qisqa ushlash kerak, lekin ma’lumot invariantini buzish hisobiga emas.

## Deadlock va qayta qulflash

**Deadlock** — goroutinelar bir-biridan hech qachon kelmaydigan qulf yoki signalni kutib qoladigan holat.

Bunday vaziyatda dasturdagi ayrim goroutinelar endi oldinga siljiy olmaydi.

Mutex bilan bog‘liq deadlocklarning keng tarqalgan sabablaridan ikkitasi:

* bir mutexni qayta qulflash;
* bir nechta mutexni turli tartibda olish.

### Bir mutexni qayta qulflash

Go’dagi `sync.Mutex` **reentrant** mutex emas.

Reentrant qulf deganda, bir xil execution egasi allaqachon olgan qulfini yana olishiga ruxsat beradigan mexanizm tushuniladi.

`sync.Mutex` bunday ishlamaydi.

Bir goroutine:

```go
mu.Lock()
```

qilib, `Unlock()` qilmasdan yana:

```go
mu.Lock()
```

qilsa, ikkinchi `Lock()` bo‘sh qulfni kutadi.

Ammo qulfni bo‘shatishi kerak bo‘lgan goroutine ham aynan o‘zi.

Natijada goroutine o‘zini o‘zi kutib qoladi.

Masalan:

```go
// Noto‘g‘ri misol: update mu qulfini olib, value metodini chaqiradi.
// value ham o‘sha mu qulfini olishga urinadi.
func (s *Store) update() {
	s.mu.Lock()
	defer s.mu.Unlock()

	_ = s.value()
}
```

Tasavvur qilamiz, `value()` ham shunday yozilgan:

```go
func (s *Store) value() int {
	s.mu.Lock()
	defer s.mu.Unlock()

	return s.someValue
}
```

Bajarilish tartibi:

```text
update()
    |
    +-- s.mu.Lock() -> qulf olindi
    |
    +-- s.value()
            |
            +-- s.mu.Lock() -> shu qulf yana so‘ralmoqda
```

Lekin mutex hali `update()` tomonidan ushlab turilgan.

`update()` esa `value()` tugashini kutmoqda.

`value()` esa mutex bo‘shashini kutmoqda.

Natijada deadlock.

Bunday holatda ko‘pincha qulf talab qilmaydigan ichki yordamchi metod ajratiladi.

Masalan, konseptual yondashuv:

```go
func (s *Store) valueLocked() int {
	return s.someValue
}
```

Bu metod mutexni o‘zi olmaydi.

Uning contract’i:

> Chaqiruvchi kerakli mutexni allaqachon olgan bo‘lishi kerak.

Tashqi metod esa:

```go
func (s *Store) value() int {
	s.mu.Lock()
	defer s.mu.Unlock()

	return s.valueLocked()
}
```

kabi ishlashi mumkin.

Shunda qulf qayerda olinishi aniq boshqariladi.

### Qulflarni turli tartibda olish

Bir operatsiya bir nechta mutex olishi kerak bo‘lsa, deadlockning yana bir turi yuz berishi mumkin.

Masalan, ikkita mutex bor:

```text
muA
muB
```

Birinchi goroutine:

```text
muA.Lock()
muB.Lock()
```

tartibida oladi.

Ikkinchi goroutine esa:

```text
muB.Lock()
muA.Lock()
```

tartibida oladi.

Yomon bajarilish quyidagicha bo‘lishi mumkin:

```text
Goroutine 1:
muA ni oldi

Goroutine 2:
muB ni oldi

Goroutine 1:
muB ni kutmoqda

Goroutine 2:
muA ni kutmoqda
```

Endi:

* Goroutine 1 `muB`ni kutadi;
* Goroutine 2 `muA`ni kutadi.

Lekin hech biri o‘zidagi qulfni bo‘shata olmaydi, chunki keyingi qadamga o‘tishni kutmoqda.

Bu klassik deadlock.

Shuning uchun bir nechta qulf ishlatilsa, barcha kodda ularni bir xil global tartibda olish kerak.

Masalan, qoida:

```text
Har doim avval muA, keyin muB.
```

bo‘lishi mumkin.

Imkon qadar bitta operatsiyada ko‘p mutexni bir paytda ushlab turishni kamaytirish ham foydali.

`defer`:

```go
defer mu.Unlock()
```

qulfni unutib qo‘yishdan himoya qiladi.

Lekin `defer` noto‘g‘ri qulflash tartibini avtomatik tuzatmaydi.

## `RWMutex`: o‘qish va yozishni ajratish

Ba’zi ma’lumotlar juda ko‘p o‘qiladi, lekin kam o‘zgartiriladi.

Oddiy `sync.Mutex` ishlatilsa, hatto ikkita goroutine faqat o‘qiyotgan bo‘lsa ham ular bir-birini kutadi.

Masalan:

```text
Reader A -> Lock
Reader B -> kutadi
```

Aslida ikkala goroutine ham faqat o‘qiyotgan bo‘lsa, ularning bir vaqtda ishlashi xavfsiz bo‘lishi mumkin.

Shunday holatlar uchun Go’da `sync.RWMutex` mavjud.

`RWMutex` ikki turdagi qulf beradi.

Yozuvchi uchun:

```go
Lock()
Unlock()
```

O‘quvchi uchun:

```go
RLock()
RUnlock()
```

Bir nechta o‘quvchi bir vaqtning o‘zida `RLock()` ushlab turishi mumkin.

Yozuvchi esa eksklyuziv kirishni talab qiladi.

Masalan:

```go
package main

import (
	"fmt"
	"sync"
)

type Scores struct {
	mu     sync.RWMutex
	values map[string]int
}

func NewScores() *Scores {
	return &Scores{values: make(map[string]int)}
}

func (s *Scores) Set(name string, score int) {
	s.mu.Lock()
	defer s.mu.Unlock()

	s.values[name] = score
}

func (s *Scores) Get(name string) (int, bool) {
	s.mu.RLock()
	defer s.mu.RUnlock()

	score, ok := s.values[name]
	return score, ok
}

func main() {
	scores := NewScores()
	scores.Set("Ali", 95)

	score, ok := scores.Get("Ali")
	if !ok {
		fmt.Println("Natija topilmadi")
		return
	}

	fmt.Println("Ali:", score)
}
```

Natija:

```text
Ali: 95
```

### `Set` nima uchun `Lock` ishlatadi?

`Set` metodi:

```go
s.values[name] = score
```

orqali `map`ga yozmoqda.

Shu sabab u eksklyuziv qulf oladi:

```go
s.mu.Lock()
defer s.mu.Unlock()
```

Yozuvchi ishlayotgan paytda boshqa o‘quvchi yoki yozuvchi himoyalangan qismga kira olmaydi.

### `Get` nima uchun `RLock` ishlatadi?

`Get`:

```go
score, ok := s.values[name]
```

orqali faqat o‘qiydi.

Shu sabab:

```go
s.mu.RLock()
defer s.mu.RUnlock()
```

ishlatadi.

Agar boshqa yozuvchi yo‘q bo‘lsa, bir nechta `Get` chaqiruvi bir vaqtda o‘qishi mumkin.

Bu ko‘p concurrent o‘qish mavjud tizimlarda foydali bo‘lishi mumkin.

### Oddiy `map` concurrent ishlatish uchun avtomatik xavfsiz emas

Go’dagi oddiy:

```go
map[string]int
```

concurrent yozish uchun avtomatik ravishda xavfsiz emas.

Shuningdek, bir goroutine mapga yozayotgan paytda boshqa goroutine shu mapdan mutexsiz o‘qishi ham muammo keltirib chiqarishi mumkin.

`RWMutex` bu murojaatlarni muvofiqlashtiradi.

### `RWMutex` har doim tezroq emas

`RWMutex` ko‘proq imkoniyat beradi. Lekin bundan:

> `RWMutex` har doim `Mutex`dan tezroq.

degan xulosa kelib chiqmaydi.

`RWMutex`ning o‘z boshqaruv xarajati mavjud.

Agar:

* kritik bo‘lim juda qisqa bo‘lsa;
* goroutinelar soni kam bo‘lsa;
* yozish tez-tez sodir bo‘lsa;
* parallel o‘qishning foydasi kichik bo‘lsa

oddiy `Mutex` yaxshiroq yoki kamida bir xil natija berishi mumkin.

Shuning uchun `RWMutex` odatda:

* concurrent o‘qishlar ko‘p;
* yozishlar kam

bo‘lgan holatlarda ko‘rib chiqiladi.

Amaliy tanlov benchmark bilan tekshirilishi kerak.

### `RLock`dan `Lock`ga upgrade yo‘q

`RWMutex`da yana bir nozik joy bor.

Masalan, quyidagi fikr tug‘ilishi mumkin:

1. avval `RLock()` bilan o‘qiymiz;
2. o‘zgartirish kerakligini bilsak;
3. shu qulfni `Lock()`ga aylantiramiz.

Go’ning `sync.RWMutex` turi bunday upgrade mexanizmini qo‘llab-quvvatlamaydi.

Ya’ni `RLock`ni ushlab turgan holatda uni to‘g‘ridan-to‘g‘ri `Lock`ga ko‘tarish mumkin emas.

Agar:

```go
RUnlock()
Lock()
```

qilinsa, shu ikkita amal orasida boshqa goroutine umumiy holatni o‘zgartirib yuborishi mumkin.

Shuning uchun yozish qarori ma’lumotning joriy holatiga bog‘liq bo‘lsa, odatda:

1. eksklyuziv `Lock()` olinadi;
2. shart qayta tekshiriladi;
3. kerak bo‘lsa o‘zgarish bajariladi.

Muhim qoida:

> Qulf turi o‘zgarganda oldingi tekshiruv natijasi hali ham to‘g‘ri deb taxmin qilmaslik kerak.

## Mutex, channel yoki `atomic`?

Go concurrent dasturlashda bir nechta sinxronizatsiya vositasi mavjud.

Masalan:

* `sync.Mutex`;
* `sync.RWMutex`;
* channel;
* `sync/atomic`.

Ularning vazifalari o‘xshash ko‘rinishi mumkin, lekin foydalanish modeli turlicha.

### `sync.Mutex`

Bir obyektning kichik umumiy holatini bir nechta goroutine o‘qib yoki o‘zgartirsa, `sync.Mutex` ko‘pincha eng tushunarli tanlov bo‘ladi.

Masalan:

```go
type Account struct {
	mu      sync.Mutex
	balance int
}
```

Bu yerda muammo:

> Barcha goroutinelar bir xil `balance` qiymatiga murojaat qilmoqda.

Shuning uchun shu ma’lumotni qulf bilan himoya qilish tabiiy.

### `sync.RWMutex`

Agar:

* o‘qishlar juda ko‘p;
* yozishlar kam;
* concurrent o‘qish real foyda bersa

`sync.RWMutex` foydali bo‘lishi mumkin.

Lekin bu tanlovni taxmin asosida emas, o‘lchov asosida qilish yaxshiroq.

### Channel

Channel ko‘proq ish yoki ma’lumot egaligini goroutinelar orasida uzatishga mos keladi.

Masalan:

```text
worker -> result channel -> collector
```

Bu modelda bir goroutine ma’lumot ishlab chiqaradi, boshqasi esa uni qabul qiladi.

Ammo channel ishlatilgani obyektni avtomatik concurrent-safe qilmaydi.

Masalan, channel orqali pointer yuborildi:

```go
ch <- account
```

Keyin bir nechta goroutine shu `account` pointeri orqali obyektni o‘zgartirsa, umumiy xotira yana paydo bo‘ladi.

Bunday holatda alohida sinxronizatsiya kerak bo‘lishi mumkin.

Demak:

> Channel orqali pointer uzatish pointer ko‘rsatgan obyektni avtomatik ravishda himoyalamaydi.

### `sync/atomic`

`sync/atomic` oddiy alohida qiymatlar ustidagi atomar amallar uchun foydali.

Masalan:

* counter;
* flag;
* oddiy statistik qiymat.

Lekin `atomic` bir nechta bog‘liq maydonni qamrab oladigan invariantni avtomatik himoya qilmaydi.

Bank hisobi misolini olaylik.

Bizga:

1. balans yetarliligini tekshirish;
2. balansni kamaytirish

kerak.

Bu ikki amal o‘zaro bog‘liq.

Faqat bitta atomar `Load` va keyin bitta atomar `Store` ishlatishning o‘zi barcha mantiqiy muammoni avtomatik yechmaydi.

Bunday invariantlar uchun mutex ko‘pincha ancha tushunarli va xatosizroq dizayn beradi.

Sinxronizatsiya vositasini tanlashda asosiy savol:

> Ma’lumot qanday oqmoqda va qaysi invariantni himoya qilish kerak?

Faqat "qaysi vosita tezroq?" degan savolga qarab tanlash noto‘g‘ri bo‘lishi mumkin.

## Keng tarqalgan xatolar

Mutex bilan ishlaganda yangi boshlovchilar va hatto tajribali dasturchilar ham ayrim xatolarga tez-tez duch keladi.

### Faqat yozishni qulflab, o‘qishni qulflamaslik

Masalan:

```go
func (s *Store) Set(v int) {
	s.mu.Lock()
	defer s.mu.Unlock()

	s.value = v
}

func (s *Store) Get() int {
	return s.value
}
```

`Set` qulflangan.

Lekin `Get` himoyasiz o‘qiyapti.

Agar `Set` va `Get` bir vaqtda bajarilsa, yozish bilan concurrent o‘qish data race keltirib chiqarishi mumkin.

Shuning uchun bir xil umumiy ma’lumotga kirish qoidasi izchil bo‘lishi kerak.

### Bir xil ma’lumot uchun turli mutexlardan foydalanish

Masalan, bitta goroutine:

```go
muA.Lock()
shared++
muA.Unlock()
```

qilsa, boshqasi:

```go
muB.Lock()
shared++
muB.Unlock()
```

qilsa, ikkala mutex bir-biridan mustaqil.

`muA` qulflangan bo‘lsa ham, `muB` bo‘sh bo‘lishi mumkin.

Demak, ikkala goroutine bir vaqtning o‘zida `shared`ga kira oladi.

Bir xil ma’lumot uchun bir xil sinxronizatsiya mexanizmi ishlatilishi kerak.

### `Unlock()`ni unutish

Masalan:

```go
mu.Lock()

if err != nil {
	return
}

mu.Unlock()
```

`err != nil` bo‘lsa, mutex bo‘shatilmaydi.

Natijada keyingi `Lock()`lar uzoq yoki abadiy kutib qolishi mumkin.

Ko‘p holatda:

```go
mu.Lock()
defer mu.Unlock()
```

xavfsizroq.

### Qulf olinmagan mutexni `Unlock()` qilish

`Unlock()` faqat oldin muvaffaqiyatli qulflangan mutex uchun chaqirilishi kerak.

Qulf olinmagan mutexni:

```go
mu.Unlock()
```

qilish runtime xatosi bilan tugaydi.

### Mutexli structni nusxalash

`sync.Mutex` birinchi ishlatilgandan keyin nusxalanmasligi kerak.

Mutexli structni value sifatida ko‘chirish alohida qulf nusxasini yaratishi mumkin.

Bu esa bir xil umumiy ma’lumotni turli qulflar bilan "himoya qilish" holatiga olib keladi.

Shuning uchun bunday structlarda pointer receiver ishlatish odatda to‘g‘ri yondashuv.

### Qulf ichida sekin I/O bajarish

Masalan:

```go
mu.Lock()
readFromDatabase()
mu.Unlock()
```

Database so‘rovi sekin ishlasa, boshqa goroutinelar mutex uchun uzoq kutadi.

Bu contentionni oshiradi.

Faqat umumiy holat bilan bog‘liq zarur kodni mutex ostida saqlashga harakat qilish kerak.

### Bir mutexni o‘sha goroutineda qayta olish

`sync.Mutex` reentrant emas.

Shuning uchun:

```go
mu.Lock()
mu.Lock()
```

kabi holat o‘z-o‘zini kutishga olib kelishi mumkin.

Bu ko‘pincha qulf olgan metod ichidan shu mutexni yana oladigan boshqa metodni chaqirishda sodir bo‘ladi.

### `RWMutex` doim tezroq deb hisoblash

`RWMutex` parallel o‘qishga ruxsat beradi.

Lekin uning boshqaruv mexanizmi oddiy `Mutex`ga qaraganda murakkabroq.

Shuning uchun real foyda workloadga bog‘liq.

Tanlovni benchmark bilan tekshirish kerak.

### Race detector barcha muammoni topadi deb o‘ylash

`-race` foydali vosita, lekin u to‘g‘ri concurrent dizaynning o‘rnini bosmaydi. Detector qanday ishlashi va nimalarni aniqlay olmasligi Race detector darsida batafsil tushuntirilgan.

## Interviewda nimalarga e’tibor beriladi?

Mutex mavzusi bo‘yicha interviewda faqat:

> `Lock()` va `Unlock()` nima qiladi?

degan savol bilan cheklanmasligi mumkin.

Quyidagi nozik jihatlarni tushunish muhim.

### `Mutex`ning zero value qiymati ishlatishga tayyor

Quyidagining o‘zi yetarli:

```go
var mu sync.Mutex
```

Alohida konstruktor kerak emas.

### `Mutex` birinchi ishlatilgandan keyin nusxalanmasligi kerak

Ayniqsa mutex saqlovchi structlar uchun bu muhim.

Shu sabab bunday structlar ko‘pincha pointer orqali ishlatiladi.

### Kritik bo‘lim imkon qadar qisqa bo‘lishi kerak

Qulf qancha uzoq ushlansa, boshqa goroutinelarning kutish vaqti shuncha oshadi.

Lekin kritik bo‘limni qisqartirish ma’lumot invariantini buzmasligi kerak.

### `sync.Mutex` reentrant emas

Bir goroutine allaqachon olgan mutexini `Unlock()` qilmasdan qayta `Lock()` qilsa, o‘zini kutib qolishi mumkin.

### `sync.Mutex` goroutine egasini kuzatmaydi

Mutexni "falon goroutineniki" deb tasavvur qilish to‘liq model emas.

Go’dagi `sync.Mutex` reentrant locklardagidek goroutine identifikatori orqali ownership modelini taqdim etmaydi.

Kod dizayni qulfni kim va qayerda olishi haqidagi aniq qoidalarga tayanishi kerak.

### `WaitGroup` va `Mutex` turli vazifani bajaradi

`WaitGroup`:

```text
Barcha goroutinelar tugadimi?
```

degan muammoni hal qiladi.

`Mutex`:

```text
Umumiy xotiraga bir paytda kim kirishi mumkin?
```

degan muammoni hal qiladi.

Ularni bir-birining o‘rnida ishlatib bo‘lmaydi.

### `RWMutex` ko‘p o‘quvchiga ruxsat beradi

`RLock()` bilan bir nechta reader bir vaqtda ishlashi mumkin.

Writer esa:

```go
Lock()
```

orqali eksklyuziv qulf oladi.

Ammo `RWMutex` faqat workload shunga mos bo‘lsa foyda beradi.

### To‘g‘ri sinxronizatsiya barcha race conditionlarni avtomatik hal qilmaydi

Mutex data raceni yo‘qotishi mumkin.

Ammo biznes mantiqi noto‘g‘ri bo‘lsa, race condition qolishi mumkin.

Masalan, dastur ikkita to‘g‘ri sinxronlashtirilgan hodisadan qaysi biri oldin kelishiga noto‘g‘ri tayansa, data race bo‘lmasligi mumkin.

Lekin natija baribir bajarilish tartibiga bog‘liq bo‘lib qoladi.

Shuning uchun concurrent dasturlashda ikki narsani alohida tekshirish kerak:

1. xotiraga murojaat texnik jihatdan xavfsizmi;
2. bajarilish tartibi o‘zgarsa, biznes mantiqi baribir to‘g‘ri qoladimi.
