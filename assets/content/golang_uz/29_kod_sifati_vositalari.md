# Go kodini tekshirish vositalari

Go loyihasida kodni tekshirish faqat testlarni ishga tushirishdan iborat emas. Turli vositalar kodning turli jihatlarini tekshiradi.

Masalan:

* formatlash vositalari kodning yozilish uslubini bir xil qiladi;
* statik tahlil vositalari shubhali konstruksiyalarni kod ishlamasidan oldin topishga harakat qiladi;
* testlar dastur kutilganidek ishlashini tekshiradi;
* race detector concurrent koddagi data race holatlarini izlaydi.

Bu tekshiruvlarning vazifasi bir-biridan farq qiladi. Shu sabab bittasi muvaffaqiyatli tugagani qolganlarini bajarish shart emas degani emas.

Amaliyotda ularni bir xil tartibda ketma-ket bajarish foydali. Bu review oldidan ham, kodni release qilishdan oldin ham xatolarni erta aniqlashga yordam beradi.

## Formatlash

Go’da kodni standart uslubga keltirish uchun asosiy vosita `gofmt` hisoblanadi.

Bitta faylni formatlash:

```bash
gofmt -w main.go
```

Bu yerda `-w` flagi muhim.

`gofmt` kodni formatlaydi, `-w` esa hosil bo‘lgan natijani yana shu faylning o‘ziga yozadi. Ya’ni buyruq faqat qanday o‘zgarish kerakligini ko‘rsatib qo‘ymaydi, balki `main.go` faylini amalda o‘zgartiradi.

Masalan, noto‘g‘ri chekinishlar, ortiqcha bo‘sh joylar yoki Go standartiga mos kelmaydigan ayrim joylashuvlar avtomatik tuzatiladi.

Butun moduldagi paketlarni Go buyrug‘i orqali formatlash uchun:

```bash
go fmt ./...
```

`go fmt` avval paketlarni tanlaydi. Keyin shu paketlardagi Go fayllari uchun `gofmt`ni ishga tushiradi.

Bu buyruqdagi:

```text
./...
```

joriy modul ichidagi joriy paket va uning ostidagi paketlarni ham tanlash uchun ishlatiladi.

Formatlashning vazifasi kodning ko‘rinishini standartlashtirishdir. Masalan, ikki dasturchi bir xil kodni turlicha chekinish bilan yozgan bo‘lsa, `gofmt` ikkalasini ham bir xil ko‘rinishga keltiradi.

Lekin bu yerda muhim cheklov bor.

Formatlash biznes mantiqni tekshirmaydi.

Masalan:

```go
total := price - tax
```

aslida:

```go
total := price + tax
```

bo‘lishi kerak bo‘lsa, `gofmt` buni aniqlamaydi. Chunki ikkala kod ham sintaktik va format jihatdan to‘g‘ri.

Shuning uchun formatlashni kod sifati tekshiruvining birinchi bosqichi deb ko‘rish kerak, lekin to‘liq tekshiruv deb emas.

## Statik tahlil

`go vet` kodni ishga tushirmasdan tahlil qiladi.

U kompilyator qabul qilishi mumkin bo‘lgan, lekin amalda xato yoki shubhali bo‘lishi ehtimoli yuqori ayrim konstruksiyalarni izlaydi.

Butun modulni tekshirish:

```bash
go vet ./...
```

Masalan, `go vet` quyidagi turdagi muammolarni aniqlashi mumkin:

* `fmt.Printf` kabi funksiyalarda format satri argument turiga mos kelmasligi;
* nusxalanmasligi kerak bo‘lgan ayrim sinxronizatsiya qiymatlarining copy qilinishi;
* standart analizatorlar aniqlay oladigan boshqa shubhali konstruksiyalar.

Masalan:

```go
count := "uchta"
fmt.Printf("%d\n", count)
```

Bu kod kompilyatsiyadan o‘tishi mumkin. Lekin `%d` butun son uchun mo‘ljallangan, `count` esa `string`.

`go vet` bunday mos kelmaslikni oldindan ko‘rsatishi mumkin.

Bu statik tahlilning asosiy foydasi: muammoni dastur ishlayotgan paytda emas, undan oldin topish.

Lekin `go vet` ham barcha turdagi xatolarni topmaydi.

Masalan, biznes qoidasi noto‘g‘ri yozilgan bo‘lsa:

```go
if age > 18 {
	allow()
}
```

talab aslida `age >= 18` bo‘lishi kerak bo‘lsa, `go vet` buni bilmaydi. Chunki buning uchun dastur talablarini tushunish kerak.

Shu sabab `go vet` testning o‘rnini bosmaydi.

## Test va race tekshiruvi

Butun moduldagi testlarni bajarish uchun:

```bash
go test ./...
```

`go test` tanlangan paketlarni kompilyatsiya qiladi va ulardagi testlarni bajaradi.

Agar testlar yozilgan bo‘lsa, ular kodning kutilgan xatti-harakatini tekshiradi.

Masalan, quyidagi funksiya bo‘lsa:

```go
func Add(a, b int) int {
	return a + b
}
```

test uning `2 + 3` uchun `5` qaytarishini tekshirishi mumkin.

Bu yerda test faqat kod ishlaydimi, degan savolga emas, kod talab qilingan natijani beradimi, degan savolga javob beradi.

Concurrent kod uchun esa qo‘shimcha tekshiruv kerak bo‘lishi mumkin:

```bash
go test -race ./...
```

`-race` flagi race detectorni yoqadi.

Oddiy test kutilgan xatti-harakatni tekshiradi. Race detector esa testlar bajargan concurrent kod yo‘llarida data race alomatlarini kuzatadi. Ularning vazifasi bir xil emas.

Data race ta’rifi, amaliy misollar va detector cheklovlari Race detector darsida batafsil tushuntirilgan.

## Tavsiya etilgan ketma-ketlik

Kichik Go loyihasi uchun quyidagi tekshiruvlar yaxshi boshlang‘ich ish jarayoni bo‘la oladi:

```bash
go fmt ./...
go vet ./...
go test ./...
go test -race ./...
```

Bu tartibning ma’nosi quyidagicha.

Avval:

```bash
go fmt ./...
```

kod standart formatga keltiriladi.

Keyin:

```bash
go vet ./...
```

statik tahlil bajariladi.

So‘ng:

```bash
go test ./...
```

odatdagi testlar ishga tushiriladi.

Oxirida:

```bash
go test -race ./...
```

testlar race detector bilan yana bajariladi.

Formatlash fayllarni o‘zgartirishi mumkin. Ayniqsa `go fmt` yoki `gofmt -w` ishlatilgan bo‘lsa, repository ichidagi fayllarda real o‘zgarish paydo bo‘ladi.

Shuning uchun tekshiruvlardan keyin:

```bash
git diff
```

buyrug‘ini ko‘rish foydali.

Bu formatlash yoki boshqa ishlar natijasida qaysi satrlar o‘zgarganini tekshirish imkonini beradi.

Maqsad — faqat kutilgan o‘zgarishlarni commit qilish.

Race tekshiruvi odatiy testdan sekinroq ishlaydi. Buning sababi race detector xotiraga murojaatlarni kuzatish uchun qo‘shimcha instrumentation va runtime tekshiruvlardan foydalanadi.

Shu sabab har bir juda tez lokal iteratsiyada `-race` ishlatish har doim ham qulay bo‘lmasligi mumkin.

Lekin concurrent kod ko‘p bo‘lgan loyihalarda uni CI yoki release oldidan ishlatish juda foydali.

Katta loyihalarda bu buyruqlar odatda CI pipeline ichida ham bajariladi.

Masalan, lokal muhitda:

```bash
go vet ./...
go test ./...
```

ishlatilib, CI’da butunlay boshqa buyruqlar bajarilsa, dasturchi lokalda ko‘rmagan muammo faqat pushdan keyin paydo bo‘lishi mumkin.

Lokal va CI bir xil yoki juda yaqin tekshiruvlardan foydalansa, muammo odatda ertaroq aniqlanadi.

Bu review jarayonini ham soddalashtiradi. Reviewer format yoki oddiy statik muammolarga vaqt sarflash o‘rniga kodning arxitekturasi va mantiqiga ko‘proq e’tibor bera oladi.

## Vositalar chegarasi

Har bir vositaning aniq vazifasi bor.

* formatlash kod uslubini birxillashtiradi;
* `go vet` ma’lum shubhali konstruksiyalarni topadi;
* test talab qilingan xatti-harakatni tekshiradi;
* race detector bajarilgan kod yo‘llaridagi data racelarni qidiradi.

Bu vositalardan birining muvaffaqiyatli tugashi boshqasini keraksiz qilmaydi.

Masalan:

```text
go fmt muvaffaqiyatli
```

bo‘lishi kodning biznes mantiqi to‘g‘ri degani emas.

Xuddi shuningdek:

```text
go test muvaffaqiyatli
```

bo‘lishi race mavjud emas degani emas.

`go vet` hech qanday muammo topmasa ham, noto‘g‘ri algoritm yoki talabga mos kelmaydigan biznes qoidasi qolishi mumkin.

Bundan tashqari, bu vositalar performance muammolarini to‘liq tahlil qilish uchun mo‘ljallanmagan.

Performance uchun boshqa vositalar kerak bo‘ladi.

Masalan:

* benchmark;
* CPU profiling;
* memory profiling;
* execution trace.

Shuning uchun kodni tekshirish jarayonida "bitta universal vosita" yo‘q. Har bir vosita alohida turdagi muammoni aniqlaydi.

## Misollar

### 1. `gofmt -d` bilan farqni ko‘rish

Bu misol `gofmt` formatlash natijasini faylga yozmasdan ko‘rish usulini ko‘rsatadi.

```go
package main

import "fmt"

func main() {
	numbers := []int{3, 1, 4}
	fmt.Println(numbers)
}
```

Agar `main.go` fayli ataylab noto‘g‘ri chekinish yoki joylashuv bilan yozilgan bo‘lsa, quyidagi buyruqni bajarish mumkin:

```bash
gofmt -d main.go
```

`-d` flagi "diff ko‘rsat" degan ma’noda ishlatiladi.

U faylni o‘zgartirmaydi.

Buning o‘rniga joriy kod bilan `gofmt` tavsiya qiladigan kod orasidagi farqni chiqaradi.

Masalan, chiqishda qaysi satr olib tashlanishi va qaysi ko‘rinish bilan almashtirilishi kerakligi diff formatida ko‘rinadi.

Bu ayniqsa CI yoki review oldidan tekshirishda foydali. Chunki faylga tegmasdan turib uning format talabiga mos yoki mos emasligini ko‘rish mumkin.

Yuqoridagi kod bloki esa `gofmt`dan keyingi standart ko‘rinishni ko‘rsatadi.

Asosiy qoida: `gofmt -d` format farqini ko‘rsatadi, lekin faylni o‘zgartirmaydi.

### 2. `gofmt -w` bilan faylni formatlash

Bu misolda `map` literalining standart joylashuvi ko‘rsatiladi.

```go
package main

import "fmt"

func main() {
	ports := map[string]int{
		"http":  80,
		"https": 443,
	}
	fmt.Println(ports)
}
```

Faylni avtomatik formatlash uchun:

```bash
gofmt -w main.go
```

Bu safar `-w` ishlatilmoqda.

Demak, `gofmt` hosil qilgan natija bevosita `main.go` ichiga yoziladi.

`ports` — `string` key va `int` qiymatdan iborat `map`.

Unda:

```go
"http": 80
```

va:

```go
"https": 443
```

qiymatlari bor.

`80` odatda HTTP porti sifatida, `443` esa HTTPS porti sifatida ishlatiladi. Bu misolda ular formatlash natijasini ko‘rsatish uchun tanlangan.

`gofmt` quyidagi qismlarni o‘qish qulay bo‘lishi uchun tekislaydi:

```go
"http":  80,
"https": 443,
```

Bu faqat formatlash.

`gofmt` `80` yoki `443` haqiqatan ham shu protokollar uchun to‘g‘ri port ekanini tekshirmaydi.

Agar siz:

```go
"http": 9999
```

deb yozsangiz ham, `gofmt` kodni bemalol formatlaydi.

Demak, formatlash sintaktik ko‘rinishni tartibga soladi, lekin qiymatlarning biznes yoki texnik ma’nosini tekshirmaydi.

### 3. Formatlanmagan fayllarni ro‘yxatlash

Bu misolda `struct` qiymati standart formatda yozilgan.

```go
package main

import "fmt"

type Server struct {
	Host string
	Port int
}

func main() {
	server := Server{
		Host: "localhost",
		Port: 8080,
	}
	fmt.Println(server)
}
```

Joriy katalogdagi format talab qiladigan Go fayllarini ko‘rish uchun:

```bash
gofmt -l .
```

`-l` flagi fayl nomlarini list qiladi.

U fayllarni o‘zgartirmaydi.

Masalan, agar `main.go` standart `gofmt` ko‘rinishida bo‘lmasa, chiqishda:

```text
main.go
```

ko‘rinishi mumkin.

Agar hech qanday fayl nomi chiqmasa, `gofmt` tekshirgan fayllarda formatlash talab qiladigan farq topmagan.

Koddagi:

```go
type Server struct {
	Host string
	Port int
}
```

qismi `Server` nomli `struct`ni e’lon qiladi.

Keyin:

```go
server := Server{
	Host: "localhost",
	Port: 8080,
}
```

orqali uning qiymati yaratiladi.

`8080` lokal development muhitlarida tez-tez uchraydigan muqobil HTTP porti sifatida tanlangan. Bu qiymat misolning formatlash maqsadiga ta’sir qilmaydi.

Asosiy qoida: `gofmt -l` qaysi fayllarni formatlash kerakligini ko‘rsatadi, lekin ularni o‘zgartirmaydi.

### 4. `gofmt -s` bilan sodda yozuvga o‘tish

Bu misolda slice kesmasi ataylab uzunroq shaklda yozilgan.

```go
package main

import "fmt"

func main() {
	values := []int{10, 20, 30, 40}
	last := values[2:len(values)]
	fmt.Println(last)
}
```

Bu yerda:

```go
values[2:len(values)]
```

slice’ning `2` indeksidan oxirigacha bo‘lgan qismini oladi.

Go’da indekslar `0`dan boshlanadi:

```text
index 0 -> 10
index 1 -> 20
index 2 -> 30
index 3 -> 40
```

Demak, `2` indeksidan boshlash uchinchi elementdan boshlash degani.

Yuqori chegara:

```go
len(values)
```

ya’ni `4`.

Slice kesmasida yuqori chegara natijaga kirmaydi.

Shuning uchun:

```go
values[2:4]
```

quyidagi qiymatlarni beradi:

```text
[30 40]
```

Lekin Go’da slice oxirigacha kesishda yuqori chegarani yozmaslik mumkin.

Shu sabab:

```go
values[2:len(values)]
```

o‘rniga:

```go
values[2:]
```

yozish yetarli.

Quyidagi buyruq:

```bash
gofmt -s -d main.go
```

shu soddalashtirishni diff ko‘rinishida taklif qilishi mumkin.

Bu yerda `-s` "simplify" rejimini yoqadi, `-d` esa farqni ko‘rsatadi.

Asosiy qoida: `gofmt -s` ayrim sintaktik konstruksiyalarni ma’nosini o‘zgartirmasdan sodda shaklga keltirishi mumkin.

### 5. Butun modulni `go fmt` bilan tekshirish

Bu misolda kichik hisoblash funksiyasi mavjud.

```go
package main

import "fmt"

func Total(prices []int) int {
	total := 0
	for _, price := range prices {
		total += price
	}
	return total
}

func main() {
	fmt.Println(Total([]int{12, 8, 5}))
}
```

Modul ildizida:

```bash
go fmt ./...
```

bajarilsa, joriy moduldagi tegishli paketlar tanlanadi va formatlanadi.

Endi kodning o‘zini ko‘ramiz.

Funksiya:

```go
func Total(prices []int) int
```

`[]int` qabul qiladi va `int` qaytaradi.

Yig‘indi:

```go
total := 0
```

dan boshlanadi.

Sababi hali hech qanday narx yig‘indiga qo‘shilmagan.

Keyin:

```go
for _, price := range prices {
	total += price
}
```

orqali barcha qiymatlar navbatma-navbat qo‘shiladi.

Hisob bosqichma-bosqich:

```text
boshlanish: 0
0 + 12 = 12
12 + 8 = 20
20 + 5 = 25
```

Natija:

```text
25
```

bo‘ladi.

Lekin `go fmt` buni tekshirmaydi.

U faqat kod formatini ko‘radi.

Agar kod xato qilib:

```go
total -= price
```

deb yozilsa ham, bu satr format jihatdan to‘g‘ri bo‘lishi mumkin.

Natijaning haqiqatan `25` bo‘lishini test tekshirishi kerak.

Asosiy qoida: `go fmt ./...` butun moduldagi paketlarni formatlashga yordam beradi, lekin funksional to‘g‘rilikni tekshirmaydi.

### 6. `go vet` bilan format satri xatosini topish

Bu misol `go vet`ning amaliy foydasini ko‘rsatadi.

```go
package main

import "fmt"

func main() {
	count := "uchta"
	fmt.Printf("Fayllar soni: %d\n", count)
}
```

Bu koddagi muammo:

```go
%d
```

format specifierida.

`%d` butun sonni chiqarish uchun mo‘ljallangan.

Lekin:

```go
count := "uchta"
```

sabab `count` turi `string`.

Demak, format va argument turi bir-biriga mos emas.

`go run` bajarilganda `fmt` bu holatni maxsus diagnostika matni bilan ko‘rsatishi mumkin.

Lekin muammoni kodni ishga tushirishdan oldin topish yaxshiroq.

Shu sabab:

```bash
go vet ./...
```

ishlatiladi.

`go vet` `Printf` oilasidagi funksiyalar uchun format string va argumentlarning mosligini tekshira oladi.

To‘g‘ri variant:

```go
fmt.Printf("Fayllar soni: %s\n", count)
```

Bu yerda `%s` `string` uchun mos.

Yoki agar `count` haqiqatan son bo‘lishi kerak bo‘lsa:

```go
count := 3
fmt.Printf("Fayllar soni: %d\n", count)
```

deb yozish mumkin.

Bu misol `go vet` kompilyator qabul qilishi mumkin bo‘lgan ayrim shubhali konstruksiyalarni oldindan aniqlashini ko‘rsatadi.

### 7. `go test` bilan paketlarning kompilyatsiyasini tekshirish

Bu misolda alohida test fayli yo‘q.

```go
package main

import "fmt"

func average(total, count int) int {
	if count == 0 {
		return 0
	}
	return total / count
}

func main() {
	fmt.Println(average(30, 3))
}
```

Shunga qaramay:

```bash
go test ./...
```

bajarilganda paketlar baribir kompilyatsiya qilinadi.

Agar paketda test funksiyalari bo‘lmasa, Go quyidagiga o‘xshash xabar chiqarishi mumkin:

```text
[no test files]
```

Bu "paket umuman tekshirilmadi" degani emas.

Paket test jarayonining bir qismi sifatida kompilyatsiyadan o‘tgan bo‘ladi.

Funksiyaning o‘ziga qaraymiz:

```go
func average(total, count int) int
```

Avval:

```go
if count == 0 {
	return 0
}
```

tekshiriladi.

Bu nolga bo‘lishning oldini oladi.

Agar bu tekshiruv bo‘lmasa:

```go
total / count
```

qismida `count == 0` holati runtime panicga olib kelishi mumkin.

Misolda:

```text
30 / 3 = 10
```

bo‘ladi.

Aynan bo‘linadigan sonlar tanlangani uchun integer division bilan bog‘liq qo‘shimcha kasr qismi muammosi yo‘q.

Masalan:

```text
10 / 3
```

`int` bilan hisoblanganda `3` bo‘lardi, `3.333...` emas.

Bu misolning asosiy qoidasi: `go test ./...` test fayli bo‘lmagan paketlarni ham kompilyatsiya qiladi.

Lekin `[no test files]` chiqishi biznes xatti-harakati test bilan tekshirilgan degani emas.

### 8. Race tekshiruvini butun modulga qo‘llash

Bu misolda slice ketma-ket to‘ldiriladi.

```go
package main

import "fmt"

func main() {
	values := make([]int, 3)
	for index := range values {
		values[index] = (index + 1) * 10
	}
	fmt.Println(values)
}
```

Avval:

```go
values := make([]int, 3)
```

bajariladi.

Bu uzunligi `3` bo‘lgan `[]int` yaratadi.

`int`ning zero value qiymati `0`.

Shuning uchun boshlang‘ich holatni shunday tasavvur qilish mumkin:

```text
[0 0 0]
```

Keyin:

```go
for index := range values
```

indekslar bo‘yicha yuradi.

Indekslar:

```text
0
1
2
```

bo‘ladi.

Hisob:

```go
values[index] = (index + 1) * 10
```

orqali bajariladi.

Bosqichma-bosqich:

```text
index = 0
(0 + 1) * 10 = 10

index = 1
(1 + 1) * 10 = 20

index = 2
(2 + 1) * 10 = 30
```

Natija:

```text
[10 20 30]
```

bo‘ladi.

Bu kodning o‘zida goroutine yo‘q. Shuning uchun ko‘rsatilgan oqim ketma-ket bajariladi va umumiy xotiraga concurrent murojaat mavjud emas.

Butun modul uchun:

```bash
go test -race ./...
```

ishlatilganda race detector testlar bajargan kod yo‘llarini kuzatadi.

Bu yerda muhim farq shuki, `-race` flagini ishlatish avtomatik ravishda barcha kodni concurrent qilib qo‘ymaydi.

U mavjud concurrent koddagi xavfli xotira murojaatlarini qidiradi.

Asosiy qoida: race detector faqat amalda bajarilgan kod yo‘llarini kuzatadi. Muammoli yo‘l testda ishlamasa, u aniqlanmasligi mumkin.

### 9. Coverage va test muvaffaqiyatini alohida baholash

Bu misolda ikkita mantiqiy yo‘lga ega kichik funksiya bor.

```go
package main

import "fmt"

func discount(total int) int {
	if total < 100 {
		return 0
	}
	return 10
}

func main() {
	fmt.Println(discount(100))
}
```

Funksiyada shart:

```go
if total < 100
```

deb yozilgan.

Demak:

```text
total = 99  -> 0
total = 100 -> 10
total = 101 -> 10
```

Ayniqsa `100` bu yerda chegara qiymati.

Sababi operator:

```go
<
```

ya’ni "kichik".

Agar shart:

```go
total <= 100
```

bo‘lganida, `100` uchun natija boshqacha bo‘lardi.

Shuning uchun boundary value — chegara qiymatlarni test qilish muhim.

Testlar yozilgandan keyin coverage ko‘rish uchun:

```bash
go test -cover ./...
```

ishlatish mumkin.

Coverage test vaqtida kodning qanchasi bajarilganini ko‘rsatadi.

Masalan, funksiyaning ikkala branchi ham testdan o‘tsa, coverage oshishi mumkin.

Lekin yuqori coverage avtomatik ravishda yaxshi test degani emas.

Masalan, test:

```go
discount(100)
```

ni chaqirishi mumkin, lekin noto‘g‘ri natijani kutishi mumkin.

Yoki funksiyaning barcha statementlari bajarilishi mumkin, lekin biznes talabdagi muhim holat umuman assert qilinmasligi mumkin.

Demak, ikki narsani alohida ko‘rish kerak:

* kod yo‘llari bajarildimi;
* bajarilgan yo‘llardagi natijalar to‘g‘rimi.

Asosiy qoida: coverage test qamrovini ko‘rsatadi, lekin testlarning sifatini o‘zi kafolatlamaydi.

### 10. Tekshiruvlarni bitta tartibda bajarish

Bu misol asosiy tekshiruv vositalaridan o‘ta oladigan kichik dastur ko‘rsatadi.

```go
package main

import (
	"fmt"
	"strings"
)

func normalize(words []string) string {
	cleaned := make([]string, 0, len(words))
	for _, word := range words {
		cleaned = append(cleaned, strings.TrimSpace(word))
	}
	return strings.Join(cleaned, ", ")
}

func main() {
	words := []string{" Go ", " test ", " vet "}
	fmt.Println(normalize(words))
}
```

Tekshiruvlarni quyidagi tartibda bajarish mumkin:

```bash
go fmt ./...
go vet ./...
go test ./...
go test -race ./...
```

Endi kod qanday ishlashini ko‘ramiz.

Funksiya:

```go
func normalize(words []string) string
```

stringlardan iborat slice qabul qiladi va bitta `string` qaytaradi.

Avval:

```go
cleaned := make([]string, 0, len(words))
```

orqali yangi slice yaratiladi.

Bu yerda uzunlik:

```text
0
```

chunki hali natijaga hech qanday so‘z qo‘shilmagan.

Capacity esa:

```go
len(words)
```

ga teng.

Misolda `words` ichida uchta element bor:

```text
" Go "
" test "
" vet "
```

Demak, `cleaned` uchun boshidan uchta element sig‘adigan joy ajratish mumkin.

Bu yondashuvning sababi oddiy: har bir kirish elementi uchun bittadan tozalangan natija kutilmoqda.

Keyin:

```go
for _, word := range words {
	cleaned = append(cleaned, strings.TrimSpace(word))
}
```

har bir element bo‘yicha yuradi.

`strings.TrimSpace` stringning boshi va oxiridagi whitespace belgilarini olib tashlaydi.

Shuning uchun:

```text
" Go "   -> "Go"
" test " -> "test"
" vet "  -> "vet"
```

hosil bo‘ladi.

Natijada `cleaned`:

```text
["Go", "test", "vet"]
```

mazmuniga ega bo‘ladi.

Oxirida:

```go
return strings.Join(cleaned, ", ")
```

elementlarni `", "` bilan birlashtiradi.

Natija:

```text
Go, test, vet
```

bo‘ladi.

Bu dasturda har bir tekshiruv boshqa vazifani bajaradi.

`go fmt ./...` kod formatini tekshiradi va kerak bo‘lsa o‘zgartiradi.

`go vet ./...` statik jihatdan shubhali konstruksiyalarni qidiradi.

`go test ./...` paketlarni kompilyatsiya qiladi va mavjud testlarni bajaradi.

`go test -race ./...` esa testlar bajargan kod yo‘llarida data race holatlarini ham izlaydi.

Shu sabab bu buyruqlarni bitta umumiy "kod tekshiruvi" sifatida ko‘rish mumkin, lekin ularning har biri alohida vazifani bajarishini unutmaslik kerak.
