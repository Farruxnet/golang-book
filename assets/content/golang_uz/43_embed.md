# Go’da fayllarni dastur ichiga joylash: `embed`

`embed` paketi fayl va kataloglarni kompilyatsiya vaqtida Go dasturining bajariluvchi fayli — ya’ni binary — ichiga joylash imkonini beradi.

Oddiy holatda dasturga kerak bo‘lgan HTML shablon, SQL migratsiya, konfiguratsiya yoki statik fayllar diskda alohida saqlanadi. Dastur ishlayotganda shu fayllarni diskdan o‘qiydi.

`embed` ishlatilganda esa bu fayllar build vaqtida binary ichiga qo‘shiladi.

Natijada dastur bilan birga alohida fayllarni ko‘chirish shart bo‘lmaydi.

Masalan, CLI dasturga yordam matni kerak bo‘lsin. Uni uzun `string` sifatida to‘g‘ridan-to‘g‘ri Go kodiga yozish mumkin, lekin bu noqulay:

* matnni tahrirlash qiyinlashadi;
* kod keragidan ortiq kattalashadi;
* matn va dastur logikasi bir joyga aralashib ketadi.

Buning o‘rniga yordam matnini `help.txt` faylida saqlash mumkin. Keyin `//go:embed` orqali shu fayl binary ichiga joylanadi.

Bu usulda faylni alohida tahrirlash qulay qoladi. Foydalanuvchiga esa faqat bitta binary berish yetarli bo‘ladi.

Go `embed` paketini standart kutubxonaga Go 1.16 versiyasida qo‘shgan. Shu sababli maqoladagi kodlarni ishlatish uchun Go 1.16 yoki undan yangi versiya kerak.

## `go:embed` qanday ishlaydi?

`//go:embed` — bu oddiy comment emas. U Go kompilyatoriga mo‘ljallangan maxsus direktiva.

Masalan:

```go
//go:embed hello.txt
var hello string
```

Bu yerda kompilyator quyidagicha ishlaydi:

1. `//go:embed hello.txt` direktivasini ko‘radi.
2. `hello.txt` faylini build vaqtida o‘qiydi.
3. Fayl tarkibini binary ichiga qo‘shadi.
4. `hello` o‘zgaruvchisiga shu fayl mazmunini boshlang‘ich qiymat sifatida beradi.

Bu jarayon `go build`, `go run` va paket kompilyatsiya qilinadigan boshqa holatlarda sodir bo‘ladi.

Direktiva faqat paket darajasidagi quyidagi turlardan biriga qiymat bera oladi:

* `string` — bitta matnli fayl uchun;
* `[]byte` — bitta matnli yoki binary fayl uchun;
* `embed.FS` — bir yoki bir nechta fayl va katalog uchun.

Bu yerda muhim farq bor.

Embedded fayllar runtime vaqtida diskdan o‘qilmaydi. Ular oldindan binary ichiga joylangan bo‘ladi.

Masalan, dastur build qilingandan keyin `hello.txt` faylini o‘zgartirsangiz, eski binary ichidagi matn o‘zgarmaydi.

Yangi fayl tarkibini binary ichiga olish uchun dasturni qayta build qilish kerak.

**Diqqat**

Direktiva aynan `//go:embed` ko‘rinishida yozilishi kerak.

Quyidagi yozuv noto‘g‘ri:

```go
// go:embed hello.txt

`go:embed` oldidan bo‘sh joy bo‘lishi mumkin emas.

Direktiva paket darajasidagi bitta o‘zgaruvchi deklaratsiyasiga tegishli bo‘ladi. Uni `func main()` yoki boshqa funksiya ichidagi lokal o‘zgaruvchiga qo‘llab bo‘lmaydi.
```

## Bitta matnli faylni `string` sifatida joylash

Eng sodda holatdan boshlaymiz.

Quyidagi ikki fayl bir katalogda tursin:

```text
.
├── hello.txt
└── main.go
```

`hello.txt` faylining mazmuni:

```text
Salom, dunyo!
```

Endi `main.go` ichida shu faylni `string` sifatida embed qilamiz:

```go
package main

import (
	_ "embed"
	"fmt"
)

//go:embed hello.txt
var hello string

func main() {
	fmt.Print(hello)
}
```

Dasturni fayllar joylashgan katalogda ishga tushiramiz:

```bash
go run .
```

Natija:

```text
Salom, dunyo!
```

Bu kodda `hello` paket darajasida e’lon qilingan:

```go
var hello string
```

Undan oldingi direktiva:

```go
//go:embed hello.txt
```

kompilyatorga `hello.txt` tarkibini `hello` ichiga joylash kerakligini bildiradi.

Shuning uchun runtime vaqtida quyidagiga o‘xshash kod bajarilmaydi:

```go
os.ReadFile("hello.txt")
```

Faylni o‘qish build vaqtida allaqachon bajarilgan bo‘ladi.

### Nega `_ "embed"` import qilingan?

Kod `embed.FS` turidan bevosita foydalanmayapti.

Shunga qaramay, `//go:embed` direktivasidan foydalanilgan Go faylida `embed` paketi import qilingan bo‘lishi shart.

Shu sababli:

```go
_ "embed"
```

blank import ishlatilgan.

Blank import paket nomini kod ichida ishlatmasdan, paketni import qilish imkonini beradi.

Agar `embed.FS` ishlatilsa, blank import kerak bo‘lmaydi:

```go
import "embed"
```

deb oddiy import qilinadi.

### Nega `fmt.Print()` ishlatilgan?

Kodda:

```go
fmt.Print(hello)
```

ishlatilgan.

Buning sababi `hello.txt` fayli oxirida yangi qator belgisi bo‘lishi mumkin.

Agar:

```go
fmt.Println(hello)
```

ishlatilsa, `Println()` o‘zi ham yangi qator qo‘shadi.

Natijada ikki marta qator tashlanib, ortiqcha bo‘sh qator paydo bo‘lishi mumkin.

`embed` fayldagi baytlarni o‘zgartirmaydi. Fayl qanday bo‘lsa, `string` ichiga ham shunday olinadi.

## Binary faylni `[]byte` sifatida joylash

Hamma fayl ham matn emas.

Masalan:

* PNG yoki JPEG rasm;
* sertifikat;
* PDF;
* audio;
* boshqa binary formatlar

baytlar ketma-ketligi sifatida saqlanadi.

Bunday faylni `[]byte` turiga embed qilish qulay:

```go
package main

import (
	_ "embed"
	"fmt"
)

//go:embed logo.png
var logo []byte

func main() {
	fmt.Printf("Rasm hajmi: %d bayt\n", len(logo))
}
```

Bu dastur bilan bir katalogda `logo.png` bo‘lishi kerak.

Masalan, fayl hajmi `4821` bayt bo‘lsa, natija quyidagicha bo‘ladi:

```text
Rasm hajmi: 4821 bayt
```

`logo` o‘zgaruvchisi fayl yo‘lini saqlamaydi.

Ya’ni uning ichida:

```text
logo.png
```

degan nom yo‘q.

U `logo.png` faylining o‘z baytlarini saqlaydi.

Shu sababli bu baytlarni keyinchalik:

* HTTP javobiga yozish;
* xesh hisoblash;
* parserga uzatish;
* formatni aniqlash;
* boshqa funksiyaga berish

mumkin.

Masalan, `len(logo)` fayldagi baytlar sonini qaytaradi.

### `[]byte` o‘zgaruvchan

`string` immutable, ya’ni uning ichidagi alohida baytni to‘g‘ridan-to‘g‘ri o‘zgartirib bo‘lmaydi.

`[]byte` esa slice bo‘lgani uchun uning elementlarini o‘zgartirish mumkin:

```go
logo[0] = 0
```

Lekin bu o‘zgarish faqat joriy process ichidagi `logo` slice’iga ta’sir qiladi.

U:

* diskdagi `logo.png` faylini o‘zgartirmaydi;
* binary faylning o‘zini qayta yozmaydi;
* keyingi ishga tushirish uchun embedded ma’lumotni doimiy ravishda o‘zgartirmaydi.

Dastur qayta ishga tushirilsa, embedded ma’lumot yana binary ichidagi dastlabki holatdan olinadi.

> **Ma'lumot**
>
> `string` va `[]byte` uchun `//go:embed` direktivasidagi pattern faqat bitta faylga mos kelishi kerak.
>
> Bir nechta fayl yoki katalog kerak bo‘lsa, `embed.FS` ishlatiladi.

## Bir nechta fayl uchun `embed.FS`

Bir nechta faylni bitta `string` yoki `[]byte` ichiga joylab bo‘lmaydi.

Bunday holatda `embed.FS` ishlatiladi.

`embed.FS` — faqat o‘qish uchun mo‘ljallangan virtual fayl tizimi.

Uning ichidagi fayllarga diskdagi fayllarga o‘xshash yo‘llar orqali murojaat qilish mumkin.

Quyidagi tuzilmani olaylik:

```text
.
├── main.go
└── texts
    ├── file1.txt
    ├── file2.txt
    └── notes
        └── file3.txt
```

Fayllar mazmuni quyidagicha bo‘lsin:

```text
texts/file1.txt -> Birinchi fayl
texts/file2.txt -> Ikkinchi fayl
texts/notes/file3.txt -> Uchinchi fayl
```

Endi butun `texts` katalogini embed qilamiz:

```go
package main

import (
	"embed"
	"fmt"
	"io/fs"
	"log"
)

//go:embed texts
var textFiles embed.FS

func main() {
	err := fs.WalkDir(textFiles, "texts", func(path string, entry fs.DirEntry, walkErr error) error {
		if walkErr != nil {
			return walkErr
		}
		if entry.IsDir() {
			return nil
		}

		data, err := textFiles.ReadFile(path)
		if err != nil {
			return err
		}
		fmt.Printf("%s: %s\n", path, data)
		return nil
	})
	if err != nil {
		log.Fatal(err)
	}
}
```

Natija:

```text
texts/file1.txt: Birinchi fayl
texts/file2.txt: Ikkinchi fayl
texts/notes/file3.txt: Uchinchi fayl
```

Bu misolda:

```go
//go:embed texts
var textFiles embed.FS
```

butun `texts` katalogini embedded fayl tizimiga qo‘shadi.

Katalog ichidagi oddiy fayllar ham, ichki kataloglar ham hisobga olinadi.

### `fs.WalkDir()` nima qiladi?

Quyidagi qator:

```go
fs.WalkDir(textFiles, "texts", ...)
```

`textFiles` fayl tizimidagi `texts` katalogidan boshlab daraxtni aylanadi.

`WalkDir()` har bir fayl va katalog uchun callback funksiyani chaqiradi:

```go
func(path string, entry fs.DirEntry, walkErr error) error
```

Bu parametrlarning vazifasi:

* `path` — joriy fayl yoki katalog yo‘li;
* `entry` — joriy obyekt haqida ma’lumot;
* `walkErr` — yurish paytida yuz bergan xato.

Avval:

```go
if walkErr != nil {
	return walkErr
}
```

orqali `WalkDir()` uzatgan xato tekshiriladi.

Bu muhim. Chunki ayrim fayllarga kira olinmasa yoki boshqa muammo yuz bersa, xatoni e’tiborsiz qoldirish muammoni yashirib yuboradi.

Keyin:

```go
if entry.IsDir() {
	return nil
}
```

orqali kataloglar o‘qilmaydi.

Bu yerda maqsad faqat fayllarning mazmunini chiqarish.

Agar joriy element fayl bo‘lsa:

```go
data, err := textFiles.ReadFile(path)
```

uning tarkibi o‘qiladi.

`ReadFile()` `[]byte` qaytaradi.

So‘ng:

```go
fmt.Printf("%s: %s\n", path, data)
```

fayl yo‘li va uning mazmuni chiqariladi.

### Fayllar qanday tartibda yuriladi?

`fs.WalkDir()` katalog ichidagi nomlarni tartiblangan holda aylanadi.

Shuning uchun natija odatda nomlar tartibida ko‘rinadi.

### `embed.FS` va `io/fs`

`embed.FS` `io/fs.FS` interfeysini amalga oshiradi.

Bu juda foydali xususiyat.

Chunki standart kutubxonadagi ko‘plab paketlar `io/fs.FS` bilan ishlay oladi.

Masalan:

* `fs.WalkDir`;
* `fs.ReadFile`;
* `fs.ReadDir`;
* `html/template`;
* `text/template`;
* `net/http`.

Demak, embedded fayllar bilan ishlash uchun alohida maxsus API o‘rganish shart emas. Ko‘p hollarda oddiy `io/fs` ekotizimidagi funksiyalar yetadi.

## Pattern yozish qoidalari

`//go:embed` direktivasidan keyin yozilgan qiymat pattern deb ataladi.

Masalan:

```go
//go:embed templates/*.html
```

bu yerda:

```text
templates/*.html
```

pattern hisoblanadi.

Pattern qayerdan boshlab hisoblanishini tushunish juda muhim.

U modul root’iga nisbatan emas, direktiva joylashgan Go fayli tegishli bo‘lgan paket katalogiga nisbatan hisoblanadi.

Masalan:

```text
project/
├── go.mod
└── cmd
    └── app
        ├── main.go
        └── templates
            └── index.html
```

Agar `main.go` ichida:

```go
//go:embed templates/*.html
```

yozilsa, pattern `cmd/app` katalogiga nisbatan ishlaydi.

Windows’da ham pattern yozishda path separator sifatida `/` ishlatiladi.

Masalan:

```go
//go:embed templates/*.html static/css/*.css
var content embed.FS
```

Bu yerda bitta direktivada ikkita pattern bor:

```text
templates/*.html
static/css/*.css
```

Ikkala pattern bo‘yicha topilgan fayllar ham `content` ichiga joylanadi.

Xuddi shu narsani ikkita direktiva bilan ham yozish mumkin:

```go
//go:embed templates/*.html
//go:embed static/css/*.css
var content embed.FS
```

Bu ikkala variantning ma’nosi bir xil.

### Muhim pattern qoidalari

`go:embed` patternlari oddiy fayl tizimi yo‘liga o‘xshasa ham, ayrim cheklovlarga ega.

#### Paket tashqarisiga chiqib bo‘lmaydi

Quyidagilar ruxsat etilmaydi:

```text
/static
../static
C:/static
```

Sababi embedded fayllar joriy paket doirasidan tashqariga chiqmasligi kerak.

Ayniqsa:

```text
../
```

orqali parent katalogga o‘tishga ruxsat berilmaydi.

#### `.` pattern sifatida ishlatilmaydi

Joriy katalog uchun:

```go
//go:embed .
```

yozib bo‘lmaydi.

Buning o‘rniga kerakli fayllarga mos pattern ishlatiladi.

Masalan:

```go
//go:embed *
```

Lekin `*` barcha holatda katalogning to‘liq rekursiv mazmunini olish degani emas. Katalog embedding qoidalari alohida ishlaydi.

#### Har bir pattern kamida bitta obyektga mos kelishi kerak

Masalan:

```go
//go:embed templates/*.html
```

deb yozilgan bo‘lsa, build vaqtida kamida bitta `.html` fayl mavjud bo‘lishi kerak.

Agar hech narsa topilmasa, build xato bilan to‘xtaydi.

Bu yaxshi xususiyat. Chunki dastur kerakli resurs tasodifan yo‘q bo‘lib qolgan holatda ishlaydigan binary yaratib yubormaydi.

#### Ayrim katalog va fayllar embed qilinmaydi

Pattern orqali quyidagilarga murojaat qilish cheklangan:

* symbolic link;
* `.git`;
* `vendor`;
* ichida alohida `go.mod` bo‘lgan boshqa modul kataloglari.

Bu cheklovlar build kontekstini aniq va nazorat qilinadigan holda saqlashga yordam beradi.

#### Fayl nomida bo‘sh joy bo‘lsa

Patternni qo‘shtirnoq ichida yozish mumkin:

```go
//go:embed "docs/user guide.txt"
var guide string
```

Bu yerda qo‘shtirnoq patternning bir qismi emas. U ichida bo‘sh joy borligini to‘g‘ri ifodalash uchun ishlatilgan.

### Katalog nomi va `*` o‘rtasidagi farq

Bu yerda yangi boshlovchilar ko‘p adashadigan nozik farq bor.

Quyidagi direktiva:

```go
//go:embed assets
var assets embed.FS
```

`assets` katalogini rekursiv tarzda embed qiladi.

Lekin nomi `.` yoki `_` bilan boshlanadigan fayl va kataloglarni odatda tashlab ketadi.

Masalan:

```text
assets/
├── main.css
├── .hidden
└── _internal
```

oddiy:

```go
//go:embed assets
```

holatida `.hidden` va `_internal` kiritilmasligi mumkin.

Agar bunday fayllar ham kerak bo‘lsa, `all:` prefiksi ishlatiladi:

```go
//go:embed all:assets
var assets embed.FS
```

`all:` yashirin va underscore bilan boshlanadigan obyektlarni ham hisobga olishni bildiradi.

Endi:

```go
//go:embed assets/*
```

bilan farqni ko‘ramiz.

`assets/*` `assets` ichidagi birinchi darajadagi obyektlarga pattern sifatida mos keladi.

Shu sababli birinchi darajadagi yashirin faylga ham mos kelishi mumkin.

Lekin ichki katalog ichiga rekursiv kirilganda o‘sha katalogdagi yashirin fayllar yana maxsus qoidalarga bo‘ysunadi.

Shu sababli butun katalog kerak bo‘lsa:

```go
//go:embed assets
```

odatda aniqroq yozuv hisoblanadi.

Agar yashirin fayllar ham to‘liq kerak bo‘lsa:

```go
//go:embed all:assets
```

ishlatish tushunarliroq.

## HTML shablon bilan amaliy misol

Backend dasturlarda HTML shablonlarni binary ichiga embed qilish juda qulay.

Aks holda deploy paytida:

* binary;
* `templates` katalogi;
* kerakli barcha `.html` fayllar

birga ko‘chirilishi kerak bo‘ladi.

`embed` ishlatilganda esa shablonlar binary ichida bo‘ladi.

Quyidagi tuzilma mavjud bo‘lsin:

```text
.
├── main.go
└── templates
    └── welcome.html
```

Shablon:

```html
<h1>Salom, {{.Name}}!</h1>
```

Endi Go dasturi:

```go
package main

import (
	"embed"
	"html/template"
	"log"
	"os"
)

//go:embed templates/*.html
var templateFiles embed.FS

type PageData struct {
	Name string
}

func main() {
	tmpl, err := template.ParseFS(templateFiles, "templates/*.html")
	if err != nil {
		log.Fatal(err)
	}

	err = tmpl.ExecuteTemplate(os.Stdout, "welcome.html", PageData{Name: "Aziza"})
	if err != nil {
		log.Fatal(err)
	}
}
```

Natija:

```text
<h1>Salom, Aziza!</h1>
```

Bu yerda avval:

```go
//go:embed templates/*.html
var templateFiles embed.FS
```

orqali barcha `.html` shablonlar embedded fayl tizimiga joylandi.

Keyin:

```go
tmpl, err := template.ParseFS(templateFiles, "templates/*.html")
```

chaqirildi.

`template.ParseFS()` shablonlarni diskdan emas, `templateFiles` ichidagi embedded fayl tizimidan o‘qiydi.

Bu `template.ParseFiles()`dan asosiy farqlardan biri.

### `ExecuteTemplate()` qanday ishlaydi?

Quyidagi kod:

```go
tmpl.ExecuteTemplate(
	os.Stdout,
	"welcome.html",
	PageData{Name: "Aziza"},
)
```

`welcome.html` shablonini bajaradi.

Shablonda:

```html
{{.Name}}
```

bor.

`PageData` esa:

```go
PageData{Name: "Aziza"}
```

qiymati bilan uzatilgan.

Shuning uchun:

```html
{{.Name}}
```

o‘rniga:

```text
Aziza
```

yoziladi.

Natija:

```html
<h1>Salom, Aziza!</h1>
```

bo‘ladi.

`html/template` HTML kontekstiga mos escaping ham bajaradi. Bu oddiy `text/template`ga qaraganda web sahifalar yaratishda xavfsizroq.

### Nega xatolar tekshirilgan?

Shablon sintaksisi noto‘g‘ri bo‘lsa:

```go
template.ParseFS(...)
```

xato qaytaradi.

Masalan, shablonda yopilmagan template expression bo‘lsa, dastur uni parse qila olmaydi.

Shu sababli:

```go
if err != nil {
	log.Fatal(err)
}
```

tekshiruvi kerak.

`ExecuteTemplate()` ham xato qaytarishi mumkin.

Masalan:

* noto‘g‘ri template nomi;
* yozish vaqtida xato;
* bajarish paytida boshqa muammo

yuz berishi mumkin.

Real HTTP serverda:

```go
os.Stdout
```

o‘rniga odatda `http.ResponseWriter` beriladi.

Masalan:

```go
func handler(w http.ResponseWriter, r *http.Request) {
	err := tmpl.ExecuteTemplate(w, "welcome.html", PageData{
		Name: "Aziza",
	})
	if err != nil {
		http.Error(w, "template error", http.StatusInternalServerError)
	}
}
```

Bu yerda generatsiya qilingan HTML to‘g‘ridan-to‘g‘ri HTTP javobiga yoziladi.

### Statik fayllarni HTTP orqali tarqatish

Statik fayllar bilan ishlaganda embedded fayl tizimidagi yuqori katalog prefiksini olib tashlash qulay bo‘lishi mumkin.

Masalan:

```go
staticFS, err := fs.Sub(templateFiles, "static")
if err != nil {
	return err
}

handler := http.FileServer(http.FS(staticFS))
```

Bu parcha alohida to‘liq dastur emas.

Bu yerda:

```go
fs.Sub(templateFiles, "static")
```

`templateFiles` ichidagi `static` katalogini yangi root sifatida ko‘rsatadigan fayl tizimini qaytaradi.

Masalan, asl embedded yo‘l:

```text
static/css/main.css
```

bo‘lsa, `fs.Sub()`dan keyingi fayl tizimida u:

```text
css/main.css
```

sifatida ko‘rinadi.

Keyin:

```go
http.FS(staticFS)
```

`io/fs.FS` interfeysini `net/http` tushunadigan adapterga o‘raydi.

So‘ng:

```go
http.FileServer(...)
```

shu fayllarni HTTP orqali tarqatishi mumkin.

Amaliy kodda `templateFiles` o‘rnida `static` katalogi haqiqatan ham embed qilingan `embed.FS` ishlatilishi kerak.

Masalan:

```go
//go:embed static
var staticFiles embed.FS
```

va keyin:

```go
staticFS, err := fs.Sub(staticFiles, "static")
```

deyish aniqroq bo‘ladi.

## `embed.FS` faqat o‘qish uchun

`embed.FS` read-only, ya’ni faqat o‘qish uchun mo‘ljallangan fayl tizimi.

Unda quyidagi metodlar bor:

```go
Open
ReadFile
ReadDir
```

Lekin quyidagi amallar uchun metodlar yo‘q:

```text
WriteFile
Create
Remove
Rename
```

Buning sababi embedded ma’lumot binary tarkibiga build vaqtida joylangan.

Runtime vaqtida uni oddiy fayl tizimidagi kabi doimiy ravishda o‘zgartirib bo‘lmaydi.

Masalan, boshlang‘ich konfiguratsiyani binary ichiga embed qilish mumkin:

```text
default-config.yaml
```

Dastur birinchi marta ishga tushganda shu konfiguratsiyadan default qiymat sifatida foydalanishi mumkin.

Lekin foydalanuvchi keyin konfiguratsiyani o‘zgartirsa, uni `embed.FS` ichiga qayta yozib bo‘lmaydi.

Bunday o‘zgaruvchan ma’lumot:

* disk;
* database;
* object storage;
* boshqa tashqi saqlash tizimi

ichida saqlanishi kerak.

Xuddi shunday, SQL migratsiyalar uchun `embed` juda qulay.

Migratsiya fayllari odatda ilova versiyasi bilan birga keladi va runtime vaqtida o‘zgartirilmaydi.

Ammo foydalanuvchi yuklagan fayllarni:

```text
uploads/
```

kabi `embed.FS` ichiga qo‘shib bo‘lmaydi.

Chunki `embed.FS` runtime fayl storage emas.

## Keng tarqalgan xatolar

### `embed` paketini import qilmaslik

`//go:embed` ishlatilgan faylda `embed` paketi import qilingan bo‘lishi shart.

Quyidagi kod noto‘g‘ri:

```go
// Noto‘g‘ri: bu faylda "embed" import qilinmagan.
//go:embed message.txt
var message string
```

Build vaqtida taxminan quyidagi xato olinadi:

```text
go:embed requires import "embed"
```

Agar embedded qiymat `string` yoki `[]byte` bo‘lsa:

```go
import _ "embed"
```

ishlatish mumkin.

Masalan:

```go
import (
	_ "embed"
	"fmt"
)
```

Agar `embed.FS` ishlatilsa, paket nomi kod ichida kerak bo‘ladi:

```go
import "embed"

//go:embed files
var files embed.FS
```

Shuning uchun bu holatda blank import emas, oddiy import ishlatiladi.

### Direktiva bilan o‘zgaruvchini ajratib yuborish

`//go:embed` bitta aniq o‘zgaruvchi deklaratsiyasiga tegishli.

Quyidagi kod noto‘g‘ri:

```go
// Noto‘g‘ri misol.
//go:embed message.txt
const defaultName = "Go"

var message string
```

Bu yerda direktivadan keyingi deklaratsiya:

```go
const defaultName = "Go"
```

bo‘lib qolgan.

`go:embed` esa `message` o‘zgaruvchisiga tegishli bo‘lishi kerak edi.

Shu sababli direktivani bevosita o‘zgaruvchi ustiga yozish eng tushunarli usul:

```go
//go:embed message.txt
var message string
```

Bo‘sh qator yoki ayrim commentlar grammatik jihatdan ruxsat etilishi mumkin, lekin ular kodni chalkashtiradi.

Amaliy kodda direktiva bilan o‘zgaruvchini bir-biriga yaqin yozish yaxshi odat.

### Runtime vaqtida tashqi fayl yangilanishini kutish

Bu `embed` bilan ishlashdagi eng muhim tushunchalardan biri.

Faraz qilaylik, dastur quyidagi shablonni embed qildi:

```text
templates/welcome.html
```

Keyin binary build qilindi:

```bash
go build -o app
```

Shundan keyin diskdagi:

```text
templates/welcome.html
```

o‘zgartirildi.

Eski:

```text
app
```

binary bu o‘zgarishni ko‘rmaydi.

Sababi shablon runtime vaqtida diskdan o‘qilmayapti. U allaqachon binary ichida.

Yangi shablonni ishlatish uchun:

```bash
go build -o app
```

yana bajarilishi kerak.

Bu production’da foydali bo‘lishi mumkin.

Chunki deploy qilingan binary bilan uning resurslari bir-biriga mos qoladi.

Lekin agar shablonni dastur ishlayotgan paytda o‘zgartirish talab qilinsa, `embed` mos kelmasligi mumkin.

Bunday holatda:

* faylni diskdan o‘qish;
* tashqi storage ishlatish;
* yoki o‘zgarishdan keyin qayta build va deploy qilish

kerak bo‘ladi.

### Xatolarni e’tiborsiz qoldirish

Embedded fayl build vaqtida mavjud bo‘lsa ham, runtime kodda noto‘g‘ri yo‘l yozish mumkin.

Masalan, embed qilingan fayl:

```text
texts/file1.txt
```

bo‘lsa:

```go
data, err := textFiles.ReadFile("texts/file1.txt")
```

to‘g‘ri.

Lekin:

```go
data, err := textFiles.ReadFile("file1.txt")
```

noto‘g‘ri bo‘lishi mumkin.

Sababi `embed.FS` ichida yo‘l aynan embedded struktura bo‘yicha saqlanadi.

Shu sababli:

* `ReadFile`;
* `ReadDir`;
* `ParseFS`;
* `fs.Sub`;
* `Open`

qaytargan xatolarni tekshirish kerak.

Masalan:

```go
data, err := textFiles.ReadFile("texts/file1.txt")
if err != nil {
	return err
}
```

Xatoni e’tiborsiz qoldirish noto‘g‘ri path yoki noto‘g‘ri pattern muammosini topishni qiyinlashtiradi.

## Hajm, xotira va xavfsizlik

Embedded fayllar binary hajmini oshiradi.

Masalan, binary dastlab:

```text
8 MB
```

bo‘lsa va unga:

```text
20 MB
```

statik asset qo‘shilsa, yakuniy binary ham sezilarli kattalashadi.

Bir nechta kichik:

* HTML shablon;
* SQL migratsiya;
* CLI help matni;
* kichik CSS;
* kichik JavaScript;
* default konfiguratsiya

uchun bu ko‘pincha muammo emas.

Lekin yuzlab megabayt:

* video;
* katta arxiv;
* katta dataset;
* tez-tez yangilanadigan kontent

uchun `embed` yaxshi tanlov bo‘lmasligi mumkin.

Katta binary:

* uzoqroq build qilinishi mumkin;
* tarmoq orqali ko‘proq ma’lumot uzatadi;
* container image hajmini oshiradi;
* artifact storage’da ko‘proq joy oladi.

Bunday kontent ko‘pincha tashqi storage’da saqlangani ma’qul.

### Embedded fayl maxfiy emas

Bu juda muhim xavfsizlik qoidasi.

`embed` ma’lumotni binary ichiga joylaydi, lekin uni shifrlamaydi.

Shuning uchun quyidagilarni binary ichiga embed qilish xavfsiz hisoblanmaydi:

* API key;
* parol;
* private key;
* access token;
* database credential.

Binary faylga kira olgan foydalanuvchi ichidagi ma’lumotni turli vositalar bilan ajratib olishi mumkin.

Shuning uchun secret qiymatlar uchun:

* environment variable;
* secret manager;
* orchestrator secret;
* maxsus credential storage

ishlatish kerak.

`embed` — packaging vositasi. U secret protection vositasi emas.

### Build natijasining takrorlanuvchanligi

`embed` dastur va uning statik resurslarini bitta artifact sifatida saqlashga yordam beradi.

Masalan:

```text
app binary
+ templates
+ migrations
+ static files
```

alohida-alohida deploy qilinmaydi.

Bularning hammasi bitta binary ichida bo‘ladi.

Bu deploy jarayonini soddalashtiradi va "binary yangi, template eski" kabi nomuvofiqliklarni kamaytiradi.

Agar embedded fayl o‘zgarsa, Go build tizimi bu o‘zgarishni hisobga oladi.

Tegishli paket qayta build qilinadi va yangi binary yaratiladi.

Shu sabab embedded resurs ham source dependency’ning bir qismi sifatida qaraladi.

## Interviewda muhim nuqtalar

* `//go:embed` faqat paket darajasidagi `string`, `[]byte` yoki `embed.FS` o‘zgaruvchisiga boshlang‘ich qiymat beradi.
* `string` va `[]byte` bitta faylga mos keladigan bitta pattern bilan ishlaydi.
* `embed.FS` bir nechta fayl, katalog va pattern bilan ishlay oladi.
* Pattern modul root’iga emas, direktiva joylashgan Go fayli tegishli bo‘lgan paket katalogiga nisbatan hisoblanadi.
* `embed.FS` `io/fs.FS` interfeysini amalga oshiradi.
* Shu sababli uni `fs.WalkDir`, `template.ParseFS`, `http.FS` kabi standart APIlar bilan ishlatish mumkin.
* `embed.FS` faqat o‘qish uchun mo‘ljallangan.
* Embedded fayllar runtime vaqtida diskdan olinmaydi.
* Diskdagi original fayl o‘zgarsa, eski binary ichidagi nusxa o‘zgarmaydi.
* Embedded resurs yangilanishi uchun dastur qayta build qilinishi kerak.
* `embed` binary hajmini oshiradi.
* `embed` maxfiy ma’lumotni himoya qilmaydi.
* Kichik va statik resurslar uchun `embed` juda qulay.
* Runtime vaqtida o‘zgaradigan katta kontent uchun tashqi storage ko‘proq mos keladi.
