# Buyruq qatori dasturlari va standart oqimlar

Buyruq qatori interfeysi, ya’ni **CLI** (`Command Line Interface`) — terminal orqali boshqariladigan dastur.

Bunday dastur odatda:

* terminaldan argument qabul qiladi;
* kerak bo‘lsa `stdin` orqali qo‘shimcha ma’lumot o‘qiydi;
* natijani `stdout`ga chiqaradi;
* xato va diagnostika xabarlarini `stderr`ga yozadi;
* ish tugaganda exit code qaytaradi.

Go’da kichik va o‘rta CLI dasturlarini tashqi kutubxonalarsiz ham yozish mumkin. Buning uchun standard library ichidagi `os`, `flag`, `fmt`, `bufio` va `io` kabi paketlar yetarli bo‘ladi.

Masalan, quyidagi buyruqda:

```bash
go run main.go olma anor
```

`olma` va `anor` — dasturga berilgan argumentlar.

Yoki:

```bash
go run main.go -name Dilshod -count 2
```

bu yerda `-name` va `-count` — nomlangan parametrlar, ya’ni flaglar.

Endi bu ma’lumotlar Go dasturi ichida qanday olinishi va ishlatilishini bosqichma-bosqich ko‘ramiz.

## `os.Args` bilan argument olish

Go dasturiga buyruq qatori orqali berilgan barcha argumentlar `os.Args` ichida saqlanadi.

`os.Args` turi:

```go
[]string
```

ya’ni bu `string` qiymatlardan iborat slice.

Muhim qoida shuki, `os.Args[0]` foydalanuvchi bergan birinchi argument emas. Birinchi element odatda ishga tushirilgan dastur nomi yoki uning yo‘lini saqlaydi.

Masalan:

```go
package main

import (
	"fmt"
	"os"
)

func main() {
	fmt.Println("Dastur:", os.Args[0])
	fmt.Println("Argumentlar:", os.Args[1:])
}
```

Dasturni quyidagicha ishga tushiramiz:

```bash
go run main.go olma anor
```

Bu yerda taxminan quyidagi holat hosil bo‘ladi:

```text
os.Args[0]    -> bajarilayotgan dastur yo‘li
os.Args[1]    -> "olma"
os.Args[2]    -> "anor"
os.Args[1:]   -> ["olma", "anor"]
```

`os.Args[1:]` slice expression hisoblanadi. U `0`-indeksdagi dastur nomini tashlab, foydalanuvchi bergan argumentlarni qaytaradi.

`go run` bilan ishlaganda yana bir nozik jihat bor. Go avval vaqtinchalik executable fayl yaratib, keyin uni ishga tushiradi. Shu sabab:

```go
os.Args[0]
```

qiymati `main.go` bo‘lishi shart emas. U vaqtinchalik executable fayl yo‘li bo‘lishi mumkin.

Shuning uchun dastur mantig‘ini `os.Args[0]`ning aniq qiymatiga bog‘lash yaxshi yondashuv emas.

Masalan, bunday tekshiruvdan qochish kerak:

```go
if os.Args[0] == "main.go" {
	// ...
}
```

Chunki compiled binary yoki `go run` holatida bu qiymat boshqacha bo‘lishi mumkin.

`os.Args` oddiy pozitsion argumentlar uchun juda qulay. Lekin `-name`, `-count`, `-quiet` kabi nomlangan parametrlar ko‘payganda ularni qo‘lda tahlil qilish noqulaylashadi. Bunday vaziyatda `flag` paketi foydali.

## `flag` paketi

`flag` paketi buyruq qatori flaglarini e’lon qilish va tahlil qilishni soddalashtiradi.

Masalan:

```go
name := flag.String("name", "mehmon", "foydalanuvchi nomi")
count := flag.Int("count", 1, "takrorlash soni")
quiet := flag.Bool("quiet", false, "natijani chiqarmaslik")
flag.Parse()
```

Bu yerda uchta flag e’lon qilindi:

```text
-name
-count
-quiet
```

Ularni quyidagicha ishlatish mumkin:

```bash
go run main.go -name Dilshod -count 3 -quiet
```

Har bir e’lonni alohida ko‘ramiz.

```go
name := flag.String("name", "mehmon", "foydalanuvchi nomi")
```

`flag.String()` uchta asosiy argument oladi:

```text
"name"                -> flag nomi
"mehmon"              -> standart qiymat
"foydalanuvchi nomi"  -> yordam matni
```

Natijada funksiya `*string`, ya’ni `string`ga pointer qaytaradi.

Shu sabab keyin qiymatni olish uchun:

```go
*name
```

deb yoziladi.

Xuddi shu qoida `flag.Int()` va `flag.Bool()` uchun ham amal qiladi:

```go
count := flag.Int("count", 1, "takrorlash soni")
quiet := flag.Bool("quiet", false, "natijani chiqarmaslik")
```

Bu qiymatlarning turlari:

```text
name  -> *string
count -> *int
quiet -> *bool
```

Lekin flaglarni faqat e’lon qilish yetarli emas.

```go
flag.Parse()
```

chaqirilganda `flag` paketi haqiqiy buyruq qatori argumentlarini tahlil qiladi va tegishli qiymatlarni yangilaydi.

Masalan:

```bash
go run main.go -name Ali -count 5
```

bo‘lsa, `flag.Parse()`dan keyin:

```text
*name  == "Ali"
*count == 5
*quiet == false
```

bo‘ladi.

`quiet` buyruqda berilmagani uchun uning standart qiymati `false` saqlanadi.

### Pozitsion argumentlar va `flag.Args()`

Flaglar bilan birga oddiy argumentlar ham ishlatilishi mumkin.

Masalan:

```bash
go run main.go -name Ali fayl1.txt fayl2.txt
```

`flag.Parse()`dan keyin flag bo‘lmagan qolgan argumentlarni:

```go
flag.Args()
```

orqali olish mumkin.

Taxminan:

```text
flag.Args() -> ["fayl1.txt", "fayl2.txt"]
```

Bu usul flaglar va pozitsion argumentlarni birgalikda ishlatadigan CLI dasturlarda foydali.

## Standart oqimlar

Operatsion tizim ishga tushirilgan jarayon uchun odatda uchta standart oqim taqdim etadi:

* `os.Stdin` — standart kirish;
* `os.Stdout` — standart chiqish;
* `os.Stderr` — standart xato oqimi.

Bu uchta oqim bir-biridan alohida.

Oddiy holatda terminalda ularning natijasi bir joyda ko‘rinishi mumkin. Lekin shell orqali ularni alohida fayllarga yoki boshqa jarayonlarga yo‘naltirish mumkin.

### `os.Stdin`

`os.Stdin` dasturga kiruvchi ma’lumot oqimi.

Masalan, foydalanuvchi terminalda matn yozishi mumkin. Yoki boshqa dastur `pipe` orqali ma’lumot yuborishi mumkin.

Go’da undan quyidagicha o‘qish mumkin:

```go
fmt.Fscan(os.Stdin, &value)
```

yoki satrma-satr o‘qish uchun:

```go
scanner := bufio.NewScanner(os.Stdin)
```

### `os.Stdout`

`os.Stdout` odatiy natijalar uchun ishlatiladi.

Masalan:

```go
fmt.Fprintln(os.Stdout, "Natija tayyor")
```

`fmt.Println()` ham odatda stdout’ga yozadi.

Shuning uchun:

```go
fmt.Println("Salom")
```

va:

```go
fmt.Fprintln(os.Stdout, "Salom")
```

oddiy holatda terminalda bir xil natija beradi.

Ikkinchi variantning afzalligi shuki, qaysi `io.Writer`ga yozilayotgani aniq ko‘rinadi. Bu test yozishda ham qulay.

### `os.Stderr`

`os.Stderr` xato va diagnostika xabarlari uchun ishlatiladi.

Masalan:

```go
fmt.Fprintln(os.Stderr, "Xato: qiymat noto‘g‘ri")
```

Nega xatoni oddiy `stdout`ga yozmaymiz?

Sababi `stdout` va `stderr`ni shell orqali alohida boshqarish mumkin.

Masalan, dastur natijasini faylga yozib:

```bash
./app > result.txt
```

xato xabarlarini esa terminalda qoldirish mumkin.

Yoki xatolarni alohida faylga yuborish mumkin:

```bash
./app 2> errors.txt
```

Bu ayniqsa scriptlar, serverlar va boshqa dasturlar bilan ulanadigan CLI vositalarida muhim.

Dastur muvaffaqiyatli natijani `stdout`ga, xatoni esa `stderr`ga yozsa, tashqi dastur ularni bir-biridan farqlay oladi.

Masalan:

```go
fmt.Fprintln(os.Stdout, "Natija tayyor")
fmt.Fprintln(os.Stderr, "Xato: qiymat noto‘g‘ri")
```

Bu ikkala yozuv terminalda ko‘rinishi mumkin, lekin ular turli oqimlarga yozilgan.

## Exit code

CLI dastur faqat matn chiqarmaydi. Jarayon tugaganda operatsion tizimga raqamli **exit code** ham qaytaradi.

Odatda:

```text
0 -> muvaffaqiyat
0 dan boshqa qiymat -> qandaydir xato
```

Masalan, shell script quyidagi buyruq muvaffaqiyatli tugagan-tugamaganini exit code orqali aniqlashi mumkin.

Go’da jarayonni ma’lum code bilan tugatish uchun:

```go
os.Exit(code)
```

ishlatiladi.

Masalan:

```go
os.Exit(0)
```

muvaffaqiyatli tugashni, quyidagisi esa:

```go
os.Exit(1)
```

xatoni bildirishi mumkin.

Aniq non-zero qiymatlarning ma’nosini dastur muallifi belgilaydi.

Masalan:

```text
1 -> foydalanuvchi noto‘g‘ri qiymat berdi
2 -> flag sintaksisi noto‘g‘ri
```

kabi kelishuv qilish mumkin.

### `os.Exit()` va `defer`

Bu yerda muhim bir nozik holat bor.

**Diqqat**

`os.Exit()` chaqirilganda `defer` orqali rejalashtirilgan funksiyalar bajarilmaydi.

Masalan:

```go
func main() {
    defer fmt.Println("Tozalash")

    os.Exit(1)
}
```

Bu yerda:

```text
Tozalash
```

chiqishi kutilgandek ko‘rinishi mumkin. Lekin `os.Exit()` jarayonni darhol tugatadi. Shu sabab `defer` ishlamaydi.

Bu file yopish, buffer flush qilish, temporary resurslarni tozalash yoki boshqa cleanup ishlari uchun muammo tug‘dirishi mumkin.

Shuning uchun keng tarqalgan yondashuv quyidagicha:

```go
func run() int {
    // Asosiy ishlar.
    // defer ishlatish mumkin.

    return 0
}

func main() {
    os.Exit(run())
}
```

Bu yerda barcha asosiy ishlar `run()` ichida bajariladi.

`run()` oddiy funksiya bo‘lgani uchun undan chiqishda `defer`lar normal ishlaydi.

Faqat eng oxirida `main()`:

```go
os.Exit(...)
```

orqali jarayonning exit codeni belgilaydi.

## Ishlaydigan CLI misoli

Endi argumentlar, flaglar, `stdout`, `stderr` va exit codelarni bitta dastur ichida birlashtiramiz.

```go
package main

import (
	"errors"
	"flag"
	"fmt"
	"io"
	"os"
)

func run(args []string, stdout, stderr io.Writer) int {
	fs := flag.NewFlagSet("salom", flag.ContinueOnError)
	fs.SetOutput(stderr)
	name := fs.String("name", "", "salomlashiladigan ism")
	count := fs.Int("count", 1, "takrorlash soni")
	quiet := fs.Bool("quiet", false, "natijani chiqarmaslik")

	if err := fs.Parse(args); err != nil {
		return 2
	}
	if *name == "" {
		fmt.Fprintln(stderr, errors.New("-name parametri kerak"))
		return 1
	}
	if *count < 1 {
		fmt.Fprintln(stderr, "xato: -count musbat bo‘lishi kerak")
		return 1
	}
	if *quiet {
		return 0
	}
	for i := 0; i < *count; i++ {
		fmt.Fprintf(stdout, "Salom, %s!\n", *name)
	}
	return 0
}

func main() {
	os.Exit(run(os.Args[1:], os.Stdout, os.Stderr))
}
```

Dasturni quyidagicha ishga tushiramiz:

```bash
go run main.go -name Dilshod -count 2
```

Natija:

```text
Salom, Dilshod!
Salom, Dilshod!
```

Bu misolda bir nechta muhim qaror bor.

Birinchisi:

```go
func run(args []string, stdout, stderr io.Writer) int
```

`run()` global `os.Args`, `os.Stdout` va `os.Stderr`ga to‘g‘ridan-to‘g‘ri bog‘lanmagan.

U argumentlarni parametr orqali oladi:

```go
args []string
```

Chiqish oqimlari ham parametr orqali uzatiladi:

```go
stdout io.Writer
stderr io.Writer
```

Bu test yozishni ancha osonlashtiradi. Test vaqtida haqiqiy terminal o‘rniga `bytes.Buffer` berish mumkin.

Masalan, `stdout` o‘rniga xotiradagi buffer berib, dastur aynan qanday matn yozganini tekshirish mumkin.

Keyingi muhim qism:

```go
fs := flag.NewFlagSet("salom", flag.ContinueOnError)
```

Bu global `flag` paketidagi default flaglar o‘rniga alohida `FlagSet` yaratadi.

`flag.ContinueOnError` flag parsing vaqtida xato bo‘lsa, jarayonni avtomatik tugatib yubormaydi. Xato `fs.Parse()`dan qaytadi:

```go
if err := fs.Parse(args); err != nil {
	return 2
}
```

Bu CLI dasturga xato qanday boshqarilishini o‘zi nazorat qilish imkonini beradi.

Keyin:

```go
fs.SetOutput(stderr)
```

`FlagSet` tomonidan chiqariladigan xato va yordam matnlarini biz bergan `stderr` oqimiga yo‘naltiradi.

`-name` uchun standart qiymat bo‘sh string:

```go
name := fs.String("name", "", "salomlashiladigan ism")
```

Shuning uchun keyin uning berilgan-berilmaganini tekshirish mumkin:

```go
if *name == "" {
	fmt.Fprintln(stderr, errors.New("-name parametri kerak"))
	return 1
}
```

`count` qiymati ham tekshiriladi:

```go
if *count < 1 {
	fmt.Fprintln(stderr, "xato: -count musbat bo‘lishi kerak")
	return 1
}
```

Bu yerda flag sintaksisi to‘g‘ri bo‘lishi mumkin, lekin qiymat biznes qoidasi uchun noto‘g‘ri bo‘lishi mumkin.

Masalan:

```bash
go run main.go -name Ali -count -5
```

`-5` `int` sifatida o‘qilishi mumkin. Lekin dastur talabi bo‘yicha takrorlash soni kamida `1` bo‘lishi kerak. Shu sabab bu alohida validatsiya qilinadi.

`quiet` yoqilgan bo‘lsa:

```go
if *quiet {
	return 0
}
```

dastur hech qanday salomlashish chiqarmaydi, lekin muvaffaqiyatli tugaydi.

Aks holda sikl:

```go
for i := 0; i < *count; i++ {
	fmt.Fprintf(stdout, "Salom, %s!\n", *name)
}
```

`count` marta natija chiqaradi.

Oxirida:

```go
return 0
```

muvaffaqiyatni bildiradi.

`main()` esa:

```go
os.Exit(run(os.Args[1:], os.Stdout, os.Stderr))
```

orqali uchta haqiqiy qiymatni `run()`ga uzatadi:

```text
os.Args[1:] -> foydalanuvchi argumentlari
os.Stdout   -> odatiy chiqish
os.Stderr   -> xato oqimi
```

`run()` qaytargan son esa jarayonning exit code’iga aylanadi.

Bu strukturada:

```text
flag sintaksisi xatosi -> 2
noto‘g‘ri qiymat       -> 1
muvaffaqiyat            -> 0
```

qaytariladi.

## Misollar

### 1. Birinchi pozitsion argumentni olish

Bu misol `os.Args` orqali foydalanuvchi bergan birinchi pozitsion argumentni olishni ko‘rsatadi.

Dastur argumentni ism sifatida ishlatadi.

```go
package main

import (
	"fmt"
	"os"
)

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Foydalanish: dastur ISM")
		return
	}

	name := os.Args[1]
	fmt.Println("Salom,", name)
}
```

Bu yerda eng muhim qism:

```go
if len(os.Args) < 2 {
```

`os.Args` ichida kamida bitta element deyarli har doim mavjud bo‘ladi:

```text
os.Args[0]
```

u dastur nomi yoki yo‘li.

Foydalanuvchi argument bergan bo‘lsa, u:

```text
os.Args[1]
```

da turadi.

Shuning uchun `os.Args[1]`ga murojaat qilishdan oldin slice uzunligi kamida `2` ekanini tekshiramiz.

Agar bu tekshiruv bo‘lmasa va foydalanuvchi argument bermasa:

```go
name := os.Args[1]
```

mavjud bo‘lmagan indeksga murojaat qiladi va dastur runtime vaqtida panic qilishi mumkin.

Argument berilganda:

```bash
go run main.go Ali
```

natija:

```text
Salom, Ali
```

bo‘ladi.

Bu misolning asosiy qoidasi: `os.Args[0]` dasturga tegishli, foydalanuvchining birinchi argumenti esa `os.Args[1]`da turadi.

### 2. Barcha pozitsion argumentlarni ko‘rish

Bu misol foydalanuvchi bergan barcha pozitsion argumentlarni tartib raqami bilan chiqaradi.

```go
package main

import (
	"fmt"
	"os"
)

func main() {
	args := os.Args[1:]
	if len(args) == 0 {
		fmt.Println("Argument berilmadi")
		return
	}

	for index, value := range args {
		fmt.Printf("%d: %s\n", index+1, value)
	}
}
```

Avval:

```go
args := os.Args[1:]
```

orqali dastur nomini tashlab yuboramiz.

Masalan:

```bash
go run main.go olma anor uzum
```

bo‘lsa:

```text
args == ["olma", "anor", "uzum"]
```

bo‘ladi.

Keyin:

```go
if len(args) == 0 {
```

orqali foydalanuvchi umuman argument berganmi yoki yo‘qmi, tekshiriladi.

Argumentlar bo‘lsa:

```go
for index, value := range args {
```

slice elementlari bo‘ylab yuriladi.

`range`dagi `index` `0`dan boshlanadi:

```text
0 -> olma
1 -> anor
2 -> uzum
```

Lekin foydalanuvchiga tartib raqamini odatda `1`dan boshlab ko‘rsatish qulayroq. Shu sabab:

```go
index + 1
```

ishlatiladi.

Natija:

```text
1: olma
2: anor
3: uzum
```

bo‘ladi.

Bu misolda slice indeksi bilan foydalanuvchiga ko‘rsatiladigan tartib raqami bir xil narsa emasligini ko‘rish mumkin.

### 3. Flag uchun standart qiymat belgilash

Bu misolda `-name` va `-count` flaglari uchun standart qiymatlar belgilanadi.

Agar foydalanuvchi flaglarni bermasa, dastur shu qiymatlarni ishlatadi.

```go
package main

import (
	"flag"
	"fmt"
)

func main() {
	name := flag.String("name", "mehmon", "foydalanuvchi nomi")
	count := flag.Int("count", 1, "takrorlash soni")
	flag.Parse()

	for i := 0; i < *count; i++ {
		fmt.Println("Salom,", *name)
	}
}
```

Bu yerda:

```go
name := flag.String("name", "mehmon", "foydalanuvchi nomi")
```

`-name` berilmasa:

```text
*name == "mehmon"
```

bo‘ladi.

Xuddi shunday:

```go
count := flag.Int("count", 1, "takrorlash soni")
```

sababli `-count` berilmasa:

```text
*count == 1
```

bo‘ladi.

Shu sabab:

```bash
go run main.go
```

natijasi:

```text
Salom, mehmon
```

bo‘ladi.

Agar:

```bash
go run main.go -name Ali -count 3
```

deb ishga tushirilsa, natija:

```text
Salom, Ali
Salom, Ali
Salom, Ali
```

bo‘ladi.

Siklni ko‘ramiz:

```go
for i := 0; i < *count; i++ {
```

Agar `count = 3` bo‘lsa:

```text
i = 0 -> ishlaydi
i = 1 -> ishlaydi
i = 2 -> ishlaydi
i = 3 -> i < 3 noto‘g‘ri, sikl tugaydi
```

Natijada kod aynan uch marta bajariladi.

`count`ning standart qiymati `1` bo‘lishi bu misolda mantiqan qulay. Foydalanuvchi hech narsa bermasa ham dastur kamida bir marta salomlashadi.

### 4. Mantiqiy flag va qolgan argumentlar

Bu misolda `bool` flag va undan tashqari qolgan pozitsion argumentlarni olish ko‘rsatiladi.

```go
package main

import (
	"flag"
	"fmt"
)

func main() {
	upper := flag.Bool("upper", false, "katta harf rejimini yoqish")
	flag.Parse()

	fmt.Println("Katta harf rejimi:", *upper)
	fmt.Println("Qolgan argumentlar:", flag.Args())
}
```

`upper` uchun standart qiymat:

```go
false
```

Bu rejim odatda o‘chiq ekanini bildiradi.

Agar foydalanuvchi:

```bash
go run main.go
```

deb ishga tushirsa:

```text
Katta harf rejimi: false
Qolgan argumentlar: []
```

ko‘rinishidagi natija hosil bo‘ladi.

Agar:

```bash
go run main.go -upper olma anor
```

deb ishga tushirilsa:

```text
*upper == true
```

bo‘ladi.

`flag.Parse()` `-upper`ni flag sifatida tahlil qiladi.

Qolgan:

```text
olma
anor
```

argumentlari esa:

```go
flag.Args()
```

orqali olinadi.

Natija taxminan:

```text
Katta harf rejimi: true
Qolgan argumentlar: [olma anor]
```

bo‘ladi.

Bu misol flaglar va pozitsion argumentlarni bitta CLI ichida qanday ajratish mumkinligini ko‘rsatadi.

### 5. Qiymatni mavjud o‘zgaruvchiga yozish

`flag.String()` yangi `*string` qiymat qaytaradi.

Ba’zan esa qiymatni oldindan e’lon qilingan o‘zgaruvchiga yozish qulayroq bo‘ladi. Buning uchun `flag.StringVar()` mavjud.

```go
package main

import (
	"flag"
	"fmt"
)

func main() {
	var city string
	flag.StringVar(&city, "city", "Toshkent", "shahar nomi")
	flag.Parse()

	fmt.Println("Shahar:", city)
}
```

Avval:

```go
var city string
```

yoziladi.

`string` turning zero value’i bo‘sh string:

```text
""
```

Keyin:

```go
flag.StringVar(&city, "city", "Toshkent", "shahar nomi")
```

chaqiriladi.

Bu yerda `&city` — `city` o‘zgaruvchisining manzili.

`flag` paketi parsing vaqtida qiymatni shu o‘zgaruvchining o‘ziga yozadi.

Agar foydalanuvchi:

```bash
go run main.go
```

deb ishga tushirsa, standart qiymat ishlatiladi:

```text
Shahar: Toshkent
```

Agar:

```bash
go run main.go -city Samarqand
```

bo‘lsa:

```text
Shahar: Samarqand
```

chiqadi.

`flag.String()` bilan yozilganda:

```go
city := flag.String(...)
```

va keyin:

```go
*city
```

ishlatish kerak bo‘lardi.

`StringVar()` esa mavjud o‘zgaruvchini yangilaydi. Shu sabab keyin to‘g‘ridan-to‘g‘ri:

```go
city
```

ishlatiladi.

### 6. Faqat aniq berilgan flaglarni ko‘rish

Ba’zan dasturda qaysi flaglar foydalanuvchi tomonidan haqiqatan ham yozilganini bilish kerak bo‘ladi.

Standart qiymat mavjud bo‘lishi flag buyruqda berilganini anglatmaydi.

Bunday vaziyatda `flag.Visit()` ishlatiladi.

```go
package main

import (
	"flag"
	"fmt"
)

func main() {
	flag.String("name", "mehmon", "foydalanuvchi nomi")
	flag.Int("count", 1, "takrorlash soni")
	flag.Bool("quiet", false, "jim rejim")
	flag.Parse()

	fmt.Println("Aniq berilgan flaglar:")
	flag.Visit(func(item *flag.Flag) {
		fmt.Printf("-%s=%s\n", item.Name, item.Value.String())
	})
}
```

Bu dasturda uchta flag mavjud:

```text
-name
-count
-quiet
```

Lekin `flag.Visit()` ularning barchasini emas, faqat foydalanuvchi buyruqda aniq yozganlarini ko‘radi.

Masalan:

```bash
go run main.go -name Ali -quiet
```

bo‘lsa:

```text
-name=Ali
-quiet=true
```

chiqariladi.

`count` esa:

```text
1
```

standart qiymatga ega bo‘lsa ham, buyruqda yozilmagan. Shu sabab `flag.Visit()` ichiga kirmaydi.

Bu farq konfiguratsiya tizimlarida foydali bo‘lishi mumkin.

Masalan, dasturga qiymat config fayldan, environment variable’dan va CLI flagdan kelishi mumkin. Shunda foydalanuvchi CLI orqali flagni aniq berganmi yoki standart qiymat ishlatilganmi, bilish muhim bo‘lishi mumkin.

### 7. Standart kirishdan bitta qiymat o‘qish

Bu misolda `fmt.Fscan()` orqali `stdin`dan bitta qiymat o‘qiladi.

```go
package main

import (
	"fmt"
	"os"
)

func main() {
	var product string
	fmt.Fprint(os.Stdout, "Mahsulot nomi: ")

	if _, err := fmt.Fscan(os.Stdin, &product); err != nil {
		fmt.Fprintln(os.Stderr, "Xato: nom o‘qilmadi")
		return
	}

	fmt.Fprintln(os.Stdout, "Qabul qilindi:", product)
}
```

Avval:

```go
var product string
```

orqali bo‘sh `string` yaratiladi.

Keyin:

```go
fmt.Fprint(os.Stdout, "Mahsulot nomi: ")
```

foydalanuvchiga prompt chiqaradi.

Asosiy o‘qish:

```go
fmt.Fscan(os.Stdin, &product)
```

orqali bajariladi.

Bu yerda `&product` berilishining sababi muhim.

`Fscan()` o‘qilgan qiymatni `product` o‘zgaruvchisiga yozishi kerak. Buning uchun unga o‘zgaruvchining manzili kerak.

Agar o‘qish muvaffaqiyatsiz bo‘lsa:

```go
if _, err := fmt.Fscan(...); err != nil {
```

sharti bajariladi va xato:

```go
fmt.Fprintln(os.Stderr, "Xato: nom o‘qilmadi")
```

orqali `stderr`ga yoziladi.

Muvaffaqiyatli holatda:

```go
fmt.Fprintln(os.Stdout, "Qabul qilindi:", product)
```

ishlaydi.

Bu dasturga ma’lumotni terminaldan qo‘lda kiritish mumkin.

Lekin `stdin` faqat klaviatura degani emas.

Masalan:

```bash
echo daftar | go run main.go
```

buyrug‘ida `echo` chiqishi pipe orqali keyingi dastur `stdin`iga uzatiladi.

Oqim taxminan shunday:

```text
echo
  |
  v
"daftar"
  |
  v
stdin
  |
  v
fmt.Fscan()
  |
  v
product
```

Natijada `product` qiymati:

```text
daftar
```

bo‘ladi.

### 8. Standart kirishni satrma-satr o‘qish

Ko‘p qatorli input bilan ishlaganda `bufio.Scanner` qulay.

Bu misolda `stdin`dan kelgan har bir satr tartib raqami bilan chiqariladi.

```go
package main

import (
	"bufio"
	"fmt"
	"os"
)

func main() {
	scanner := bufio.NewScanner(os.Stdin)
	lineNumber := 1

	for scanner.Scan() {
		fmt.Fprintf(os.Stdout, "%d: %s\n", lineNumber, scanner.Text())
		lineNumber++
	}

	if err := scanner.Err(); err != nil {
		fmt.Fprintln(os.Stderr, "O‘qish xatosi:", err)
	}
}
```

Avval:

```go
scanner := bufio.NewScanner(os.Stdin)
```

orqali `stdin` bilan ishlaydigan scanner yaratiladi.

Standart holatda `Scanner` inputni satrlar bo‘yicha ajratadi.

Keyin:

```go
lineNumber := 1
```

birinchi ko‘rsatiladigan satr raqamini belgilaydi.

Sikl:

```go
for scanner.Scan() {
```

har safar keyingi satrni o‘qishga harakat qiladi.

Agar keyingi token, bu holatda satr mavjud bo‘lsa:

```go
scanner.Scan()
```

`true` qaytaradi.

Keyingi satr matni:

```go
scanner.Text()
```

orqali olinadi.

Masalan, input:

```text
olma
anor
uzum
```

bo‘lsa, chiqish:

```text
1: olma
2: anor
3: uzum
```

bo‘ladi.

Har iteratsiyadan keyin:

```go
lineNumber++
```

satr raqamini bittaga oshiradi.

Siklning tugashi har doim xato degani emas.

Input odatiy tarzda tugasa ham `Scan()` `false` qaytaradi.

Shuning uchun sikldan keyin:

```go
if err := scanner.Err(); err != nil {
```

orqali scanner xato sababli to‘xtaganmi, tekshiriladi.

Bu muhim, chunki faqat `Scan() == false`ga qarab input tugadimi yoki o‘qish xatosi yuz berdimi, farqlab bo‘lmaydi.

> **Eslatma**
>
> `bufio.Scanner` juda katta tokenlar uchun standart limitga ega. Juda uzun satrlarni o‘qish kerak bo‘lsa, scanner bufferini kattalashtirish yoki `bufio.Reader` kabi boshqa usuldan foydalanish kerak bo‘lishi mumkin.

### 9. Natija va xatoni alohida oqimlarga yozish

Bu misol `stdout`, `stderr` va exit codeni birga ishlatishni ko‘rsatadi.

Argument mavjud bo‘lsa natija `stdout`ga yoziladi.

Argument bo‘lmasa foydalanish xabari `stderr`ga yoziladi va non-zero exit code qaytariladi.

```go
package main

import (
	"fmt"
	"os"
)

func run(args []string) int {
	if len(args) == 0 {
		fmt.Fprintln(os.Stderr, "Foydalanish: dastur MATN")
		return 1
	}

	fmt.Fprintln(os.Stdout, "Natija:", args[0])
	return 0
}

func main() {
	os.Exit(run(os.Args[1:]))
}
```

`main()`:

```go
os.Args[1:]
```

orqali dastur nomini chiqarib tashlaydi.

Shuning uchun `run()` faqat foydalanuvchi argumentlarini oladi.

Agar:

```go
len(args) == 0
```

bo‘lsa, foydalanuvchi kerakli argumentni bermagan.

Shunda:

```go
fmt.Fprintln(os.Stderr, "Foydalanish: dastur MATN")
```

xato yoki foydalanish xabarini `stderr`ga yozadi.

Keyin:

```go
return 1
```

xato holatini bildiradi.

Agar argument mavjud bo‘lsa:

```go
fmt.Fprintln(os.Stdout, "Natija:", args[0])
```

oddiy natijani `stdout`ga chiqaradi.

So‘ng:

```go
return 0
```

muvaffaqiyatni bildiradi.

Masalan:

```bash
go run main.go salom
```

chiqishi:

```text
Natija: salom
```

bo‘ladi.

Bu misolda uchta kanal aniq ajratilgan:

```text
odatiy natija -> stdout
xato xabari   -> stderr
holat         -> exit code
```

CLI dasturlarda bu ajratish foydali. Chunki boshqa dastur stdout’dagi ma’lumotni qayta ishlashi, stderr’dagi diagnostikani esa alohida ko‘rsatishi mumkin.

### 10. Alohida `FlagSet` bilan CLI yozish

Bu misolda global `flag` holatidan foydalanmaymiz.

Argumentlarni tahlil qilish uchun alohida `FlagSet` yaratiladi. Argumentlar va chiqish oqimlari esa `run()` funksiyasiga parametr sifatida beriladi.

```go
package main

import (
	"flag"
	"fmt"
	"io"
	"os"
)

func run(args []string, stdout, stderr io.Writer) int {
	fs := flag.NewFlagSet("greet", flag.ContinueOnError)
	fs.SetOutput(stderr)
	name := fs.String("name", "mehmon", "foydalanuvchi nomi")

	if err := fs.Parse(args); err != nil {
		return 2
	}

	fmt.Fprintln(stdout, "Salom,", *name)
	return 0
}

func main() {
	code := run(os.Args[1:], os.Stdout, os.Stderr)
	os.Exit(code)
}
```

Asosiy qism:

```go
fs := flag.NewFlagSet("greet", flag.ContinueOnError)
```

Bu yangi va mustaqil `FlagSet` yaratadi.

Global:

```go
flag.String(...)
flag.Parse()
```

o‘rniga endi:

```go
fs.String(...)
fs.Parse(...)
```

ishlatiladi.

Bu yondashuv ayniqsa testlarda va bir nechta commandga ega dasturlarda qulay.

Masalan, katta CLI ichida:

```text
app create
app delete
app list
```

kabi subcommandlar bo‘lsa, har biri uchun alohida `FlagSet` yaratish mumkin.

Keyingi qator:

```go
fs.SetOutput(stderr)
```

`FlagSet`ning diagnostika va parsing xabarlarini biz bergan `stderr` oqimiga yo‘naltiradi.

`name` flagi:

```go
name := fs.String("name", "mehmon", "foydalanuvchi nomi")
```

standart qiymat sifatida:

```text
mehmon
```

dan foydalanadi.

Shuning uchun:

```bash
go run main.go
```

ham xato emas.

Natija:

```text
Salom, mehmon
```

bo‘ladi.

Agar:

```bash
go run main.go -name Ali
```

deb ishga tushirilsa:

```text
Salom, Ali
```

chiqadi.

Parsing vaqtida xato yuz bersa:

```go
if err := fs.Parse(args); err != nil {
	return 2
}
```

ishlaydi.

`flag.ContinueOnError` tanlanganligi sabab `FlagSet` jarayonni o‘zi tugatmaydi. U xatoni `Parse()` orqali qaytaradi.

Shu sabab `run()` xato holatini exit code sifatida boshqara oladi.

Oxirida:

```go
code := run(os.Args[1:], os.Stdout, os.Stderr)
os.Exit(code)
```

yoziladi.

Bu strukturada `main()` juda kichik.

Uning vazifasi faqat real operatsion tizim resurslarini `run()`ga ulash:

```text
os.Args[1:] -> argumentlar
os.Stdout   -> stdout
os.Stderr   -> stderr
```

va qaytgan exit codeni jarayon natijasiga aylantirish.

Asosiy dastur mantig‘i esa `run()` ichida qoladi. Shu sabab uni alohida test qilish osonlashadi.
