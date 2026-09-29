# Birinchi dasturimiz

Bu darsda terminalga matn ko‘rinishida ma’lumot chiqaradigan birinchi Go dasturimizni yozamiz.

Shu oddiy misol orqali bir nechta muhim narsani ko‘rib chiqamiz:

* Go dasturi qanday tuziladi;
* dastur qayerdan ish boshlaydi;
* boshqa paketdagi funksiyadan qanday foydalaniladi;
* `go run` kodni qanday ishga tushiradi;
* kompilyator kodni qanday tekshiradi;
* bajariladigan fayl qanday yaratiladi.

Kompyuteringizda `birinchi-dastur` nomli papka yarating. Agar oldingi darsda shu papkani yaratgan bo‘lsangiz, uni kod muharririda oching.

Papka ichida `main.go` nomli fayl yarating.

`main.go` nomi Go kompilyatorining majburiy talabi emas. Faylni, masalan, `salom.go` deb ham nomlash mumkin. Muhimi, fayl `.go` kengaytmasiga ega bo‘lishi va uning ichidagi kod to‘g‘ri yozilgan bo‘lishidir.

Bu darsda `main.go` nomidan foydalanamiz, chunki kichik Go dasturlarida bu nom juda ko‘p uchraydi.

**Diqqat**

Ayrim operatsion tizimlar fayl kengaytmasini yashirib ko‘rsatadi.

```
Shu sabab fayl tasodifan `main.go.txt` bo‘lib qolmaganini tekshiring. `main.go.txt` Go manba fayli emas, chunki uning haqiqiy kengaytmasi `.txt`.
```

## Birinchi dastur

`main.go` fayliga quyidagi kodni yozing:

```go
package main

import "fmt"

func main() {
	fmt.Println("Salom, dunyo!")
}
```

Faylni saqlang.

Keyin terminalni oching va `main.go` joylashgan papkaga o‘ting. Dasturni quyidagi buyruq bilan ishga tushiring:

```bash
go run main.go
```

`go run` Go kodini tekshiradi, kompilyatsiya qiladi va hosil bo‘lgan vaqtinchalik dasturni ishga tushiradi.

Agar kod to‘g‘ri bo‘lsa, terminalda quyidagi natija chiqadi:

```text
Salom, dunyo!
```

Bu natija koddagi quyidagi qator sababli chiqdi:

```go
fmt.Println("Salom, dunyo!")
```

`"Salom, dunyo!"` — `Println()` funksiyasiga berilgan qiymat.

`Println()` shu qiymatni terminalga yozadi. Keyin avtomatik ravishda yangi qator belgisini ham qo‘shadi.

Shu sabab keyingi terminal chiqishi yangi qatordan boshlanadi.

## Kod qanday ishlaydi?

Endi dasturni qatorma-qator ko‘rib chiqamiz.

### `package main`

Birinchi qator:

```go
package main
```

Go fayli qaysi paketga tegishli ekanini bildiradi.

**Package** — bir vazifaga tegishli Go fayllarini bir guruhga birlashtirish usuli.

Masalan, bitta papkada bir nechta `.go` fayl bo‘lsa, ular odatda bir xil package nomidan foydalanadi.

Bu yerda package nomi:

```go
main
```

`main` — bajariladigan dastur yaratishda maxsus ma’noga ega package nomi.

Go paketlarini umumiy ma’noda ikki turdagi vazifa uchun ishlatish mumkin:

* boshqa kod ishlatadigan funksiyalar va turlarni beruvchi paketlar;
* to‘g‘ridan-to‘g‘ri ishga tushiriladigan dastur yaratadigan `main` paketi.

Masalan, `fmt` boshqa dasturlar ishlatishi uchun tayyor funksiyalar beradi. `main` paketi esa bajariladigan dastur yaratish uchun ishlatiladi.

Lekin faqat:

```go
package main
```

yozishning o‘zi yetarli emas.

Ishga tushadigan dasturda `main()` funksiyasi ham bo‘lishi kerak:

```go
func main() {
}
```

Bu funksiya parametr qabul qilmaydi va qiymat qaytarmaydi.

Demak, bajariladigan Go dasturining asosiy ko‘rinishi quyidagicha:

```go
package main

func main() {
}
```

Agar `main` paketida kerakli `main()` funksiyasi bo‘lmasa, bajariladigan dastur uchun kirish nuqtasi mavjud bo‘lmaydi.

### `import "fmt"`

Keyingi qator:

```go
import "fmt"
```

boshqa paketdagi tayyor koddan foydalanish imkonini beradi.

`import` — boshqa paketni joriy Go faylida ishlatish uchun ulash vositasi.

Bu yerda:

```go
"fmt"
```

Go standart kutubxonasidagi `fmt` paketining import yo‘li.

Go bilan birga ko‘plab tayyor paketlar keladi. Ularning yig‘indisi **standard library**, ya’ni standart kutubxona deyiladi.

`fmt` paketi quyidagi kabi vazifalar uchun ishlatiladi:

* terminalga qiymat chiqarish;
* matnni formatlash;
* bir nechta qiymatni birga chiqarish;
* ayrim holatlarda terminaldan ma’lumot o‘qish.

Bu darsda faqat:

```go
fmt.Println()
```

funksiyasidan foydalanamiz.

Go’da import qilingan paket ishlatilishi kerak.

Masalan:

```go
package main

import "fmt"

func main() {
}
```

kodida `fmt` import qilingan, lekin undan foydalanilmagan.

Bunday holatda kompilyator xato beradi.

Bu Go’dagi muhim qoidalardan biri. U kodda keraksiz importlar yig‘ilib qolishining oldini oladi.

### `func main()`

Quyidagi qator:

```go
func main() {
```

`main` nomli funksiyani e’lon qiladi.

`func` — Go’da funksiya e’lon qilish uchun ishlatiladigan kalit so‘z.

Funksiyalarni keyingi darslarda batafsil o‘rganamiz. Hozircha funksiyani ma’lum vazifani bajaradigan kod bloki deb tasavvur qilish mumkin.

Bu yerda funksiya nomi:

```text
main
```

`main` paketidagi `main()` funksiyasi bajariladigan dasturning **kirish nuqtasi**, ya’ni entry point hisoblanadi.

Soddalashtirib aytganda, dastur ishlay boshlaganda asosiy kod aynan shu funksiyadan bajarila boshlaydi.

Go runtime dasturni ishga tushirish jarayonini tayyorlaydi va keyin `main.main` funksiyasini bajaradi.

Quyidagi jingalak qavslar:

```go
{
}
```

funksiya tanasining chegarasini bildiradi.

Masalan:

```go
func main() {
	fmt.Println("Salom, dunyo!")
}
```

kodida:

```go
fmt.Println("Salom, dunyo!")
```

`main()` funksiyasining tanasida joylashgan.

Bu misolda funksiyada faqat bitta amal bor.

Go kodidagi amallar odatda yuqoridan pastga qarab bajariladi.

Demak, bu dasturda oqimni sodda ko‘rinishda quyidagicha tasavvur qilish mumkin:

```text
main() boshlanadi
       ↓
fmt.Println(...) bajariladi
       ↓
main() tugaydi
       ↓
dastur tugaydi
```

Bu yerda yana bir nozik qoida bor.

`main()` funksiyasi tugasa, butun dastur ham tugaydi. Agar boshqa goroutinelar ishlayotgan bo‘lsa, `main()` ularni avtomatik ravishda kutmaydi.

Goroutinelarni keyingi darslarda alohida o‘rganamiz. Hozircha `main()` bajariladigan Go dasturining asosiy hayot siklini belgilashini eslab qolish yetarli.

### `fmt.Println("Salom, dunyo!")`

Endi asosiy amalni ko‘ramiz:

```go
fmt.Println("Salom, dunyo!")
```

Bu qatorda `fmt` paketidagi `Println()` funksiyasini chaqiryapmiz.

Nuqta:

```text
fmt.Println
   ^
```

chap tomondagi package ichidagi nomga murojaat qilayotganimizni bildiradi.

Bu yerda:

* `fmt` — package;
* `Println` — shu package ichidagi funksiya.

Funksiyaga quyidagi qiymat berilgan:

```go
"Salom, dunyo!"
```

Bu Go’dagi **string**, ya’ni satr qiymati.

String — matn ko‘rinishidagi ma’lumot.

Qo‘shtirnoqlar:

```text
"Salom, dunyo!"
```

satr qayerdan boshlanib, qayerda tugashini bildiradi.

Qo‘shtirnoqlarning o‘zi natijaga chiqarilmaydi.

Shu sabab kod:

```go
fmt.Println("Salom, dunyo!")
```

quyidagini chiqaradi:

```text
Salom, dunyo!
```

emas:

```text
"Salom, dunyo!"
```

`"Salom, dunyo!"` qiymati `Println()` funksiyasiga **argument** sifatida uzatilgan.

Argument — funksiyani chaqirish paytida unga beriladigan qiymat.

Bu jarayonni sodda ko‘rinishda quyidagicha tasavvur qilish mumkin:

```text
"Salom, dunyo!"
       ↓
fmt.Println(...)
       ↓
terminalga chiqariladi
       ↓
yangi qator qo‘shiladi
```

`Println()` nomidagi `ln` qismini “line” bilan bog‘lab eslab qolish mumkin. Funksiya qiymatlarni chiqargach, oxiriga yangi qator qo‘shadi.

Agar yangi qator avtomatik qo‘shilmasligi kerak bo‘lsa, `fmt.Print()` funksiyasidan foydalanish mumkin.

Masalan:

```go
fmt.Print("Salom, ")
fmt.Print("dunyo!")
```

Bu ikki chaqiruv bitta qatorda yozishi mumkin:

```text
Salom, dunyo!
```

Hozircha esa darslarda `fmt.Println()` ko‘proq qulay bo‘ladi.

### Nuqtali vergul

Ko‘plab dasturlash tillarida buyruq oxiriga nuqtali vergul yoziladi:

```text
;
```

Go sintaksisida ham nuqtali vergul tushunchasi mavjud.

Lekin Go dasturchisi odatda har bir qator oxiriga `;` yozmaydi.

Masalan, quyidagicha yozamiz:

```go
fmt.Println("Salom")
fmt.Println("Dunyo")
```

emas:

```go
fmt.Println("Salom");
fmt.Println("Dunyo");
```

Sababi Go lexer’i sintaksis qoidalariga qarab ko‘plab joylarga nuqtali vergulni avtomatik ravishda kiritadi.

Shu sabab kundalik Go kodida `;` deyarli yozilmaydi.

Lekin bu “kodni istalgan joydan yangi qatorga bo‘lish mumkin” degani emas.

Masalan, jingalak qavslarning joylashuvi ayrim holatlarda muhim.

Go’da odatiy yozilish:

```go
func main() {
	fmt.Println("Salom")
}
```

Ochuvchi `{` qavsni istalgancha boshqa qatorga ko‘chirish kompilyatsiya xatosiga olib kelishi mumkin.

Buning sabablaridan biri aynan nuqtali vergulni avtomatik qo‘yish qoidalaridir.

Shu sabab Go kodini standart uslubda yozish va `gofmt` bilan formatlash muhim.

## `go run`

Dasturni quyidagi buyruq bilan ishga tushirdik:

```bash
go run main.go
```

Bu buyruq bir nechta bosqichni bajaradi.

Jarayonni bosqichma-bosqich ko‘ramiz.

### 1. Fayl o‘qiladi

Avval Go vositalari:

```text
main.go
```

faylini o‘qiydi.

### 2. Kod tekshiriladi

Kompilyator kodning to‘g‘riligini tekshiradi.

Masalan:

* sintaksis to‘g‘rimi;
* ishlatilgan nomlar mavjudmi;
* importlar to‘g‘rimi;
* turlar bir-biriga mosmi;
* e’lonlar to‘g‘ri yozilganmi.

Agar shu bosqichda xato topilsa, kompilyatsiya davom etmaydi.

### 3. Kod kompilyatsiya qilinadi

Tekshiruvdan o‘tgan kod kompyuter bajarishi mumkin bo‘lgan ko‘rinishga kompilyatsiya qilinadi.

### 4. Vaqtinchalik dastur ishga tushiriladi

`go run` hosil bo‘lgan vaqtinchalik bajariladigan dasturni avtomatik ishga tushiradi.

Umumiy jarayon:

```text
main.go
   ↓
tekshirish
   ↓
kompilyatsiya
   ↓
vaqtinchalik bajariladigan dastur
   ↓
ishga tushirish
   ↓
Salom, dunyo!
```

Agar kompilyatsiya muvaffaqiyatsiz bo‘lsa, `main()` funksiyasi umuman ishga tushmaydi.

Bu yerda muhim farq bor.

Masalan, terminalda quyidagi yozuv chiqsa:

```text
Salom, dunyo!
```

uni bizning dasturimiz:

```go
fmt.Println("Salom, dunyo!")
```

orqali chiqaryapti.

Agar sintaksis xatosi haqida xabar chiqsa, uni esa dasturimiz emas, Go kompilyatori yoki Go vositalari chiqaryapti.

Demak:

```text
kompilyatsiya xabari → Go vositalaridan keladi

dastur natijasi     → biz yozgan koddan keladi
```

Bu farq keyinchalik xatolarni tahlil qilishda juda muhim bo‘ladi.

## Ishga tushadigan fayl yaratish

`go run` kodni tez sinab ko‘rish uchun qulay.

Lekin ba’zan dasturni alohida bajariladigan fayl sifatida yaratish kerak bo‘ladi.

Buning uchun `go build`dan foydalanamiz:

```bash
go build -o salom main.go
```

Buyruqni qismlarga ajratamiz.

`go build`:

```bash
go build
```

Go kodini kompilyatsiya qiladi.

`-o` parametri:

```bash
-o salom
```

hosil bo‘ladigan bajariladigan fayl nomini belgilaydi.

`main.go`:

```bash
main.go
```

kompilyatsiya qilinadigan manba fayl.

Demak:

```bash
go build -o salom main.go
```

buyrug‘i joriy papkada `salom` nomli bajariladigan dastur yaratadi.

Windows’da fayl odatda:

```text
salom.exe
```

ko‘rinishida bo‘ladi.

macOS va Linux’da esa:

```text
salom
```

ko‘rinishida bo‘lishi mumkin.

macOS va Linux’da dasturni quyidagicha ishga tushiring:

```bash
./salom
```

Bu yerda:

```text
./
```

joriy papkadagi faylni ishga tushirish kerakligini bildiradi.

PowerShell’da:

```powershell
.\salom.exe
```

buyrug‘idan foydalaniladi.

Ikkala holatda ham dastur bir xil natija beradi:

```text
Salom, dunyo!
```

`go run` va `go build` orasidagi asosiy farqni quyidagicha eslab qolish mumkin.

`go run`:

```text
kod
 ↓
kompilyatsiya
 ↓
darhol ishga tushirish
```

Bu darslar va tezkor tajribalar uchun qulay.

`go build`:

```text
kod
 ↓
kompilyatsiya
 ↓
bajariladigan faylni saqlash
```

Bu esa dasturni keyinroq ishga tushirish uchun qulay.

Tayyor bajariladigan Go dasturini ishga tushirish uchun odatda kompyuterda Go kompilyatori o‘rnatilgan bo‘lishi shart emas.

Sababi kompilyatsiya allaqachon bajarilgan bo‘ladi.

Bu yerda kichik bir aniqlik bor: boshqa operatsion tizim yoki protsessor arxitekturasi uchun yaratilgan bajariladigan fayl joriy tizimda ishlamasligi mumkin. Masalan, Linux uchun yaratilgan executable odatda Windows’da to‘g‘ridan-to‘g‘ri ishlamaydi.

## Izohlar

**Izoh** yoki **comment** — kodni o‘qiyotgan insonga qo‘shimcha tushuntirish berish uchun yoziladigan matn.

Masalan, izoh orqali:

* kod nima qilayotganini;
* nima uchun aynan shunday yozilganini;
* murakkab qarorning sababini;
* keyinroq nimani o‘zgartirish kerakligini

tushuntirish mumkin.

Kompilyator izohni dastur amali sifatida bajarmaydi.

### Bir qatorli izoh

Bir qatorli izoh:

```text
//
```

bilan boshlanadi.

Masalan:

```go
// Ekranga "Salom, dunyo!" chiqadi.
fmt.Println("Salom, dunyo!")
```

Birinchi qator izoh:

```go
// Ekranga "Salom, dunyo!" chiqadi.
```

U bajarilmaydi.

Keyingi qator esa oddiy Go kodi:

```go
fmt.Println("Salom, dunyo!")
```

va bajariladi.

`//` belgisidan qator oxirigacha bo‘lgan qism izoh hisoblanadi.

Izoh koddan keyin ham yozilishi mumkin:

```go
fmt.Println("Salom") // terminalga matn chiqaradi
```

Lekin izohlar haddan tashqari ko‘payib ketmasligi kerak. Kodning o‘zi aniq bo‘lsa, har bir oddiy qatorga izoh yozish shart emas.

### Ko‘p qatorli izoh

Ko‘p qatorli izoh:

```text
/*
```

bilan boshlanib:

```text
*/
```

bilan tugaydi.

Masalan:

```go
/*
Bu izoh
bir nechta qatorga yozilishi mumkin.
*/
```

`/*` va `*/` orasidagi matn kompilyator tomonidan dastur amali sifatida bajarilmaydi.

Go kodida kundalik izohlar uchun odatda `//` ko‘proq ishlatiladi.

Ayniqsa package, function, type va boshqa e’lonlar uchun dokumentatsiya izohlarida `//` keng qo‘llanadi.

## Ko‘p uchraydigan xatolar

Birinchi dastur juda kichik bo‘lsa ham, unda yangi boshlovchilar tez-tez uchratadigan bir nechta xato bor.

### Katta-kichik harfni almashtirish

Quyidagi chaqiruv noto‘g‘ri:

```go
// fmt.println("Salom, dunyo!") // xato: fmt paketida println yo‘q
```

Go katta va kichik harflarni farqlaydi.

Demak:

```text
Println
```

va:

```text
println
```

bir xil nom emas.

Bizga kerak bo‘lgan to‘g‘ri funksiya:

```go
fmt.Println
```

Real loyihalarda ham package, function, variable yoki type nomidagi bitta harf farqi butunlay boshqa nomga murojaat qilishni anglatadi.

Agar bunday nom mavjud bo‘lmasa, kompilyator xato beradi.

### Qo‘shtirnoq yoki qavsni yopmaslik

Quyidagi kod noto‘g‘ri:

```go
fmt.Println("Salom, dunyo!) // xato: yopuvchi qo‘shtirnoq yo‘q
```

String:

```text
"
```

bilan boshlangan bo‘lsa, tegishli joyda yana:

```text
"
```

bilan yopilishi kerak.

To‘g‘ri variant:

```go
fmt.Println("Salom, dunyo!")
```

Xuddi shu qoida oddiy va jingalak qavslarga ham tegishli.

Masalan:

```go
fmt.Println("Salom"
```

kodida yopuvchi:

```text
)
```

yetishmaydi.

Quyidagi kodda esa:

```go
func main() {
	fmt.Println("Salom")
```

yopuvchi:

```text
}
```

yetishmaydi.

Kompilyator bunday sintaktik muammolarni aniqlaydi va xato xabari chiqaradi.

Ba’zan xato xabari aynan xato boshlangan qatorda emas, undan keyingi qatorda ko‘rinishi mumkin. Sababi kompilyator noto‘g‘ri sintaksisni keyinroq sezishi mumkin.

### Noto‘g‘ri papkada buyruq bajarish

Agar terminal `main.go` joylashgan papkada bo‘lmasa:

```bash
go run main.go
```

buyrug‘i faylni topa olmasligi mumkin.

macOS va Linux’da joriy papkani:

```bash
pwd
```

bilan tekshirish mumkin.

Papkadagi fayllarni:

```bash
ls
```

ko‘rsatadi.

PowerShell’da joriy papkani:

```powershell
Get-Location
```

bilan tekshirish mumkin.

Fayllarni esa:

```powershell
Get-ChildItem
```

ko‘rsatadi.

Masalan, papkada quyidagi fayl ko‘rinishi kerak:

```text
main.go
```

Agar fayl boshqa papkada bo‘lsa, avval terminalni shu papkaga o‘tkazing.

### `package main` yoki `main()`ni unutish

Bajariladigan Go dasturida package:

```go
package main
```

bo‘lishi kerak.

Shuningdek, shu package ichida:

```go
func main() {
}
```

funksiyasi mavjud bo‘lishi kerak.

Masalan, quyidagi kodda `main()` yo‘q:

```go
package main

import "fmt"

func salom() {
	fmt.Println("Salom")
}
```

`salom()` oddiy funksiya. U avtomatik ravishda dastur boshlanish nuqtasiga aylanmaydi.

Bajariladigan dastur uchun `main.main` kerak.

Aksincha, `main()` bor, lekin package boshqa nomda bo‘lsa ham bajariladigan `main` dasturi hosil bo‘lmaydi.

Demak, ikkala shart birgalikda kerak:

```text
package main
+
func main()
```

## Dastur kodini formatlash

Go kodini standart uslubga keltirish uchun `gofmt` ishlatiladi.

Terminalda quyidagi buyruqni bajaring:

```bash
gofmt -w main.go
```

`gofmt` kodning tashqi ko‘rinishini Go standartlariga moslashtiradi.

Masalan, u:

* chekinishlarni;
* bo‘sh joylarni;
* qatorlarning joylashuvini;
* ayrim sintaktik formatlarni

bir xil uslubga keltiradi.

`-w` parametri:

```text
-w
```

formatlangan natijani `main.go` faylining o‘ziga yozishni bildiradi.

Agar kod allaqachon to‘g‘ri formatlangan bo‘lsa, ko‘rinadigan o‘zgarish bo‘lmasligi mumkin.

Muhim jihat: `gofmt` dastur mantig‘ini tekshirmaydi.

Masalan, quyidagi kod sintaktik va format jihatdan to‘g‘ri:

```go
fmt.Println("Xayr, dunyo!")
```

Lekin vazifa `"Salom, dunyo!"` chiqarish bo‘lsa, bu mantiqiy jihatdan noto‘g‘ri natija bo‘lishi mumkin.

`gofmt` buni tuzatmaydi.

Formatlangan faylni yana ishga tushiring:

```bash
go run main.go
```

Natija yana bir xil bo‘ladi:

```text
Salom, dunyo!
```

Bu tabiiy holat. Formatlash kodning ko‘rinishini o‘zgartiradi, uning maqsadini yoki ishlash mantig‘ini emas.

## Muhim tushunchalar

Bu birinchi dastur kichik bo‘lsa ham, unda keyingi darslarda qayta-qayta uchraydigan bir nechta asosiy tushunchalar bor.

* `package main` bajariladigan dastur yaratish uchun ishlatiladi.
* `main()` bajariladigan Go dasturining asosiy kirish nuqtasi hisoblanadi.
* `import` boshqa package ichidagi koddan foydalanish imkonini beradi.
* `fmt.Println()` terminalga qiymat chiqaradi va oxiriga yangi qator qo‘shadi.
* Go katta va kichik harflarni farqlaydi.
* Import qilingan package ishlatilishi kerak.
* `go run` kodni kompilyatsiya qilib, vaqtinchalik dasturni darhol ishga tushiradi.
* `go build` bajariladigan fayl yaratib, uni saqlab qoldiradi.
* `gofmt` kodni standart Go formatiga keltiradi, lekin mantiqiy xatolarni tuzatmaydi.
* Kompilyatsiya xabari bilan dastur chiqargan natijani bir-biridan ajratish kerak.

Keyingi darsda qiymatlarni nom bilan saqlash va ulardan qayta foydalanish uchun o‘zgaruvchilarni o‘rganamiz.
