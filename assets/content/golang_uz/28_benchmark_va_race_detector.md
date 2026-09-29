# Benchmark

Benchmark dasturdagi ma’lum bir amal qancha vaqt olishini va qancha xotira ajratishini o‘lchashga yordam beradi. Buning uchun o‘lchanayotgan kod ko‘p marta takroran bajariladi.

## Benchmark yozish

Go benchmarklari odatda `_test.go` faylida yoziladi. Benchmark funksiyasining nomi `Benchmark` bilan boshlanadi va u `*testing.B` qabul qiladi:

```go
package text

import (
	"strings"
	"testing"
)

var result string

func BenchmarkJoin(b *testing.B) {
	parts := []string{"go", "lang", "uz"}
	b.ReportAllocs()

	for i := 0; i < b.N; i++ {
		result = strings.Join(parts, "-")
	}
}
```

Bu benchmark `strings.Join()` amalining ishlashini o‘lchaydi.

Muhim qator:

```go
for i := 0; i < b.N; i++ {
```

Bu yerda `b.N` oddiy oldindan belgilangan son emas. Benchmark runner uning qiymatini o‘zi boshqaradi.

Dastlab `b.N` kichik bo‘lishi mumkin. Keyin Go benchmarkni qayta-qayta ishga tushiradi va `b.N`ni kattalashtiradi. Maqsad — o‘lchov yetarlicha uzoq davom etishi va natija nisbatan barqaror bo‘lishi.

Shuning uchun benchmark ichida odatda quyidagi shakl ishlatiladi:

```go
for i := 0; i < b.N; i++ {
	// o‘lchanadigan amal
}
```

Benchmark natijasi package darajasidagi `result` o‘zgaruvchisiga yozilgan:

```go
var result string
```

va:

```go
result = strings.Join(parts, "-")
```

Buning sababi benchmark natijasidan foydalanilayotganini kompilyatorga ko‘rsatishdir. Agar hisoblangan qiymat hech qayerda ishlatilmasa, kompilyator ayrim holatlarda keraksiz hisoblashni optimizatsiya qilib tashlashi mumkin.

Benchmarkni quyidagicha ishga tushirish mumkin:

```bash
go test -bench=.
```

Bu buyruq joriy package ichidagi benchmarklarni ishga tushiradi.

Xotira ajratishlari haqidagi ma’lumotni ham ko‘rish uchun:

```bash
go test -bench=. -benchmem
```

ishlatiladi.

Benchmark natijasida quyidagi ko‘rsatkichlar uchrashi mumkin:

* `ns/op` — bitta amal o‘rtacha necha nanosekund davom etgani;
* `B/op` — bitta amalga o‘rtacha necha bayt xotira ajratilgani;
* `allocs/op` — bitta amal davomida o‘rtacha nechta allocation bo‘lgani.

Masalan, natija quyidagiga o‘xshashi mumkin:

```text
BenchmarkJoin-8    12000000    95.0 ns/op    16 B/op    1 allocs/op
```

Bu yerda aniq sonlar kompyuter, Go versiyasi va muhitga qarab o‘zgaradi.

`b.ReportAllocs()` benchmark natijasiga allocation ma’lumotlarini qo‘shishni so‘raydi:

```go
b.ReportAllocs()
```

Xuddi shu ma’lumotni command line orqali `-benchmem` bilan ham chiqarish mumkin.

Benchmarkda bir martalik tayyorlash kodi ham bo‘lishi mumkin. Masalan, katta slice yaratish yoki test ma’lumotlarini oldindan tayyorlash kerak bo‘lsa, bu vaqt o‘lchanayotgan asosiy amal tarkibiga kirmasligi mumkin.

Bunday holatda tayyorlashni sikldan oldin bajarib, keyin:

```go
b.ResetTimer()
```

chaqirish mumkin.

`ResetTimer()` undan oldin yig‘ilgan vaqt va benchmark statistikalarini tozalaydi. Shundan keyin asosiy o‘lchov boshlanadi.

## Natijani to‘g‘ri talqin qilish

Benchmark natijasini ko‘rish oson. Uni to‘g‘ri talqin qilish esa alohida e’tibor talab qiladi.

Benchmark faqat aynan tekshirilgan:

* kod;
* kirish ma’lumoti;
* kompyuter;
* Go versiyasi;
* operatsion tizim;
* CPU holati;
* boshqa jarayonlar

uchun natija beradi.

Shuning uchun mikrobenchmark natijasidan:

> Bu yechim real serverda ham aynan shuncha tez ishlaydi.

degan xulosa chiqarish to‘g‘ri emas.

Mikrobenchmark odatda juda kichik bir amalni izolyatsiya qilib o‘lchaydi. Real dasturda esa boshqa xarajatlar ham bo‘ladi:

* network I/O;
* database;
* disk;
* locklar;
* scheduler;
* garbage collector;
* boshqa goroutinelar;
* request parsing;
* serialization.

Shu sabab mikrobenchmark ikki implementatsiyani solishtirishda foydali bo‘lishi mumkin, lekin foydalanuvchi ko‘radigan umumiy latency’ni yakka o‘zi isbotlamaydi.

Mikrobenchmarklarda quyidagi xatolar ko‘p uchraydi.

### Kompilyator hisoblashni olib tashlashi mumkin

Agar natija hech qayerda ishlatilmasa, kompilyator ayrim hisoblashlarni keraksiz deb topishi mumkin.

Masalan, faqat qiymat hisoblanib, keyin undan foydalanilmasa, benchmark real ishni o‘lchamasligi ehtimoli bor.

Shu sabab muhim natijani package-level yoki boshqa tashqaridan kuzatiladigan joyga yozish ko‘p benchmarklarda qo‘llanadi.

### Setup asosiy amaldan qimmatroq bo‘lishi mumkin

Tasavvur qiling, siz bitta map lookup’ni o‘lchamoqchisiz. Lekin har takrorlashda ulkan map yaratib olsangiz, natijaning katta qismi map yaratish vaqtini o‘lchaydi.

Bunday benchmark siz o‘ylagan amalni emas, asosan setup xarajatini ko‘rsatadi.

Shuning uchun setup’ni alohida bajarish yoki timer’ni vaqtincha to‘xtatish kerak bo‘lishi mumkin.

### Juda sodda ma’lumot real holatni ifodalamasligi mumkin

Masalan, 3 ta elementli slice ustida ishlaydigan benchmark production’dagi million elementli slice xatti-harakatini to‘liq ifodalamasligi mumkin.

Xuddi shuningdek, doim bir xil string yoki doim cache’da turgan ma’lumot real workload’dan farq qilishi mumkin.

### Kompyuter holati natijaga ta’sir qiladi

Fon jarayonlari, CPU frequency scaling, thermal throttling va scheduler holati benchmark natijasini o‘zgartirishi mumkin.

Shu sabab bitta o‘lchovga tayanish yaxshi fikr emas.

Benchmarklarni taqqoslashda ularni bir necha marta ishga tushirish foydali:

```bash
go test -bench=. -count=5
```

Muhim jihat — oldingi va keyingi natijalarni imkon qadar bir xil muhitda olish.

Avval muammoni o‘lchash kerak. Keyin haqiqatan ham performance uchun ahamiyatli bo‘lgan tor joyni optimallashtirish kerak.

Faqat mikrobenchmarkda bir necha nanosekund yutish har doim real dastur uchun sezilarli foyda bermaydi.

## Misollar

### 1. Butun sonlar yig‘indisini o‘lchash

Bu misol odatiy `_test.go` faylida benchmark yozishni ko‘rsatadi.

Benchmark `1`dan `100`gacha bo‘lgan sonlarni yig‘ish amalini takroran bajaradi.

```go
package benchmark

import "testing"

var sumResult int

func BenchmarkSum(b *testing.B) {
	for i := 0; i < b.N; i++ {
		sum := 0

		for number := 1; number <= 100; number++ {
			sum += number
		}

		sumResult = sum
	}
}
```

Avval:

```go
sum := 0
```

yoziladi.

Yig‘indi `0`dan boshlanishining sababi oddiy:

```text
0 + x = x
```

`0` qo‘shish natijani o‘zgartirmaydi.

Keyingi sikl:

```go
for number := 1; number <= 100; number++ {
	sum += number
}
```

`number` qiymatini bosqichma-bosqich oshiradi:

```text
1
2
3
...
99
100
```

Bu yerda `<= 100` ishlatilgani uchun `100` ham yig‘indiga kiradi.

Hisoblash yakunlangach:

```go
sumResult = sum
```

bajariladi.

`sumResult` global o‘zgaruvchi sifatida e’lon qilingan:

```go
var sumResult int
```

Bu benchmark natijasini tashqarida kuzatiladigan joyga yozadi. Natijada kompilyator butun hisoblashni foydalanilmayotgan kod deb olib tashlash ehtimoli kamayadi.

Bu misoldagi asosiy qoida shuki, benchmark ichidagi asosiy amal `b.N` marta bajariladi.

### 2. Stringlarni `+` bilan birlashtirish sarfi

Bu misolda bir nechta stringni `+` operatori bilan birlashtirish benchmark qilinadi.

```go
package benchmark

import "testing"

var textResult string

func BenchmarkStringPlus(b *testing.B) {
	b.ReportAllocs()

	for i := 0; i < b.N; i++ {
		textResult = "Go" + " " + "dasturlash" + " " + "tili"
	}
}
```

Bu yerda:

```go
b.ReportAllocs()
```

benchmark natijasiga allocation ma’lumotlarini qo‘shadi.

`go test -bench=. -benchmem` buyrug‘i natijada bitta amalga o‘rtacha nechta allocation to‘g‘ri kelganini ko‘rsatadi.

Lekin bu misolda nozik bir holat bor.

Birlashtirilayotgan qismlarning hammasi constant stringlar:

```go
"Go"
" "
"dasturlash"
" "
"tili"
```

Kompilyator bunday ifodani compile time’da oldindan birlashtirishi mumkin.

Ya’ni yozuv manba kodda:

```go
"Go" + " " + "dasturlash" + " " + "tili"
```

ko‘rinishida turgan bo‘lsa ham, runtime’da har safar alohida string concatenation bajarilishi shart emas.

Shuning uchun bu benchmark natijasi:

> Umuman olganda `+` operatori stringlarni birlashtirishda doim shuncha allocation qiladi.

degan umumiy xulosani bermaydi.

U faqat aynan shu kod shaklining xatti-harakatini o‘lchaydi.

### 3. `strings.Builder` uchun sig‘im ajratish

Bu misolda `strings.Builder` yordamida string quriladi.

Builder’ga kerak bo‘ladigan sig‘im `Grow()` orqali oldindan beriladi.

```go
package benchmark

import (
	"strings"
	"testing"
)

var builderResult string

func BenchmarkBuilder(b *testing.B) {
	b.ReportAllocs()

	for i := 0; i < b.N; i++ {
		var builder strings.Builder

		builder.Grow(18)
		builder.WriteString("Go")
		builder.WriteString(" dasturlash tili")

		builderResult = builder.String()
	}
}
```

Avval bo‘sh builder yaratiladi:

```go
var builder strings.Builder
```

Keyin:

```go
builder.Grow(18)
```

chaqiriladi.

Yakuniy string:

```text
Go dasturlash tili
```

bo‘ladi.

Uning uzunligi `18` bayt.

Shuning uchun builder’ga oldindan kamida `18` bayt sig‘im kerakligi aytilmoqda.

Keyin ikki qism yoziladi:

```go
builder.WriteString("Go")
builder.WriteString(" dasturlash tili")
```

Agar oldindan ajratilgan sig‘im yetarli bo‘lsa, builder buffer’ni kattalashtirish uchun qo‘shimcha allocation qilishga muhtoj bo‘lmasligi mumkin.

Yakuniy string:

```go
builderResult = builder.String()
```

orqali olinadi.

Bu misol `Grow()`ning asosiy maqsadini ko‘rsatadi: kerakli hajm oldindan taxmin qilinsa, buffer o‘sishidagi ortiqcha allocationlarni kamaytirish mumkin.

### 4. Setup vaqtini `ResetTimer()` bilan chiqarib tashlash

Bu misolda benchmarkdan oldin slice tayyorlanadi.

Slice yaratish va uni to‘ldirish benchmark qilinayotgan asosiy amal emas. Shu sabab bu vaqt o‘lchovdan chiqarib tashlanadi.

```go
package benchmark

import "testing"

var lastValue int

func BenchmarkLastValue(b *testing.B) {
	numbers := make([]int, 1000)

	for i := range numbers {
		numbers[i] = i
	}

	b.ResetTimer()

	for i := 0; i < b.N; i++ {
		lastValue = numbers[len(numbers)-1]
	}
}
```

Avval:

```go
numbers := make([]int, 1000)
```

orqali uzunligi `1000` bo‘lgan slice yaratiladi.

Uning valid indekslari:

```text
0
1
2
...
998
999
```

bo‘ladi.

Keyin slice indeks qiymatlari bilan to‘ldiriladi:

```go
for i := range numbers {
	numbers[i] = i
}
```

Shundan keyin:

```go
b.ResetTimer()
```

chaqiriladi.

Bu nuqtadan oldingi setup benchmark vaqtiga kiritilmaydi.

Asosiy benchmark amalida:

```go
numbers[len(numbers)-1]
```

ishlatiladi.

`len(numbers)` qiymati:

```text
1000
```

Shuning uchun:

```text
len(numbers) - 1
1000 - 1
999
```

hosil bo‘ladi.

Demak, oxirgi element olinadi.

Bu misoldagi asosiy qoida — benchmarkdan tashqari tayyorlash xarajatini `ResetTimer()` yordamida ajratish.

### 5. Tayyorlashni vaqtincha to‘xtatish

Bu misolda timer qo‘lda to‘xtatiladi va keyin yana yoqiladi.

```go
package benchmark

import "testing"

var lookupResult bool

func BenchmarkLookup(b *testing.B) {
	b.StopTimer()

	values := map[string]int{
		"go":  1,
		"api": 2,
	}

	b.StartTimer()

	for i := 0; i < b.N; i++ {
		_, lookupResult = values["go"]
	}
}
```

Avval:

```go
b.StopTimer()
```

timer’ni vaqtincha to‘xtatadi.

Keyin map yaratiladi:

```go
values := map[string]int{
	"go":  1,
	"api": 2,
}
```

Bu misolda map yaratish o‘lchanayotgan amal emas.

Shuning uchun map tayyor bo‘lgach:

```go
b.StartTimer()
```

bilan benchmark timer’i qayta ishga tushiriladi.

Sikl ichida esa:

```go
_, lookupResult = values["go"]
```

map lookup bajariladi.

Map lookup ikki qiymat qaytarishi mumkin:

```go
value, ok := values["go"]
```

Bu misolda qiymatning o‘zi kerak emas. Shu sabab birinchi natija `_` bilan tashlab yuborilgan.

`lookupResult` esa kalit topilgan yoki topilmaganini saqlaydi.

Bu map’da `"go"` mavjud, shuning uchun u `true` bo‘ladi.

Bu misol setup va asosiy benchmark amalini timer orqali ajratishni ko‘rsatadi.

### 6. Kirish hajmini `SetBytes()` bilan ko‘rsatish

Ba’zi benchmarklarda faqat bitta amal qancha vaqt olgani emas, qancha ma’lumot qayta ishlangani ham muhim.

`SetBytes()` shunday holatlarda ishlatiladi.

```go
package benchmark

import (
	"strings"
	"testing"
)

var containsResult bool

func BenchmarkContains(b *testing.B) {
	text := strings.Repeat("a", 1024)

	b.SetBytes(int64(len(text)))

	for i := 0; i < b.N; i++ {
		containsResult = strings.Contains(text, "z")
	}
}
```

Avval:

```go
text := strings.Repeat("a", 1024)
```

orqali `1024` ta `a` belgidan iborat string hosil qilinadi.

Bu belgilar ASCII bo‘lgani uchun har biri bir bayt egallaydi.

Demak, string hajmi:

```text
1024 bayt
```

bo‘ladi.

`1024` bayt:

```text
1 KiB
```

ga teng.

Keyin:

```go
b.SetBytes(int64(len(text)))
```

benchmark runner’ga har bir operatsiyada taxminan nechta bayt qayta ishlanayotganini bildiradi.

Asosiy amal:

```go
strings.Contains(text, "z")
```

Matnda `z` mavjud emas.

Shu sabab qidiruv mos keluvchi belgini topmaydi va ushbu kirish uchun string bo‘ylab qidirishni davom ettiradi.

`SetBytes()` benchmark natijasida throughput, masalan `MB/s`, ko‘rsatkichini hisoblashga imkon beradi.

Bu ayniqsa parsing, encoding, hashing yoki katta buffer bilan ishlaydigan kodlar uchun foydali.

### 7. Maxsus ko‘rsatkich chiqarish

Go benchmarklari faqat standart `ns/op` yoki allocation ko‘rsatkichlari bilan cheklanmaydi.

`ReportMetric()` orqali o‘zingizga kerakli metric’ni ham chiqarishingiz mumkin.

```go
package benchmark

import "testing"

var productResult int

func BenchmarkProduct(b *testing.B) {
	numbers := []int{2, 3, 4, 5}

	b.ReportMetric(float64(len(numbers)), "elements/op")

	for i := 0; i < b.N; i++ {
		product := 1

		for _, number := range numbers {
			product *= number
		}

		productResult = product
	}
}
```

Bu yerda slice:

```go
numbers := []int{2, 3, 4, 5}
```

to‘rtta elementdan iborat.

Shuning uchun:

```go
len(numbers)
```

natijasi:

```text
4
```

bo‘ladi.

Keyin:

```go
b.ReportMetric(float64(len(numbers)), "elements/op")
```

benchmark natijasiga:

```text
4 elements/op
```

ma’nosidagi metric qo‘shadi.

Ko‘paytma esa:

```go
product := 1
```

dan boshlanadi.

Sababi:

```text
1 × x = x
```

`1` ko‘paytirish uchun neytral qiymatdir.

Hisoblash bosqichlari:

```text
1 × 2 = 2
2 × 3 = 6
6 × 4 = 24
24 × 5 = 120
```

Yakuniy natija:

```text
120
```

bo‘ladi.

Bu misol benchmarkga domen uchun foydali bo‘lgan o‘z metric’ingizni qo‘shish mumkinligini ko‘rsatadi.

### 8. Benchmarkni bir necha marta takrorlash

Bitta benchmark natijasi tasodifan odatdagidan tez yoki sekin chiqishi mumkin.

Shuning uchun performance taqqoslashda benchmarkni bir necha marta ishga tushirish foydali.

```go
package benchmark

import "testing"

var compareResult int

func BenchmarkCalculation(b *testing.B) {
	a, multiplier, extra := 25, 4, 10

	for i := 0; i < b.N; i++ {
		compareResult = (a * multiplier) + extra
	}
}
```

Bu misolda hisoblash:

```go
(25 * 4) + 10
```

bajariladi.

Bosqichma-bosqich:

```text
25 × 4 = 100
100 + 10 = 110
```

Lekin bu misoldagi asosiy fikr hisoblashning o‘zi emas. Asosiy maqsad benchmarkni bir necha marta takrorlashni ko‘rsatishdir.

Haqiqiy `_test.go` benchmarkini quyidagicha besh marta bajarish mumkin:

```bash
go test -bench=. -count=5
```

Bu yerda:

```text
-count=5
```

benchmark run’ini besh marta takrorlaydi.

Nega bu foydali?

Chunki bitta natija vaqtinchalik omillar ta’sirida chiqishi mumkin:

* boshqa process CPU ishlatayotgan bo‘lishi mumkin;
* scheduler boshqacha taqsimlagan bo‘lishi mumkin;
* CPU frequency o‘zgargan bo‘lishi mumkin;
* cache holati farq qilishi mumkin.

Bir nechta o‘lchov natijaning tarqalishini ko‘rishga yordam beradi.

Lekin taqqoslanayotgan benchmarklar imkon qadar bir xil muhitda bajarilishi kerak.

Concurrent koddagi data racelarni aniqlash Race detector darsida alohida ko‘rib chiqiladi.
