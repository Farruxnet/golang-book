# Tashqi kutubxonalar va dependency management

Go o‘rnatilganda `fmt`, `strings`, `net/http` kabi ko‘plab standart paketlar ham birga keladi. Oddiy va ko‘plab amaliy vazifalarni shu paketlarning o‘zi bilan hal qilish mumkin.

Lekin real loyihalarda standart kutubxonada tayyor yechimi bo‘lmagan vazifalar ham uchraydi. Masalan:

* UUID yaratish;
* ma’lum bir ma’lumotlar bazasi bilan ishlash;
* maxsus konfiguratsiya formatini o‘qish;
* muayyan protokol bilan ishlash;
* tashqi servis uchun tayyor client ishlatish.

Bunday holatda boshqa dasturchi yoki tashkilot yaratgan paketdan foydalanish mumkin. Bunday paket **tashqi paket** hisoblanadi.

Tashqi kod loyihaga qo‘shilgach, u sizning loyihangizning **dependency**, ya’ni bog‘liqligiga aylanadi.

Dependency management esa faqat paketni yuklash degani emas. U bir nechta vazifani o‘z ichiga oladi:

* qaysi modul kerakligini aniqlash;
* qaysi versiyadan foydalanishni tanlash;
* modulni yuklash;
* versiyani yangilash;
* kerak bo‘lmay qolgan dependencylarni olib tashlash;
* boshqa kompyuter yoki CI muhitida ham aynan mos dependencylar ishlatilishini ta’minlash.

Go’da bu jarayon asosan `go.mod`, `go.sum` va `go` buyrug‘ining modul bilan bog‘liq komandalariga tayangan holda boshqariladi.

## Paket, modul va kutubxona

`package`, `module` va `library` atamalari bir-biriga yaqin. Shu sabab yangi boshlovchilar ularni bir xil tushuncha deb o‘ylashi mumkin.

Lekin ular turli narsani anglatadi.

* **Paket (`package`)** — odatda bitta katalog ichidagi va bir xil `package` nomiga ega Go fayllari to‘plami.
* **Modul (`module`)** — `go.mod` fayli bilan belgilangan versiyalanadigan birlik. Bitta modul ichida bitta yoki ko‘plab paketlar bo‘lishi mumkin.
* **Kutubxona (`library`)** — boshqa dasturlarda qayta ishlatish uchun yozilgan kodga nisbatan ishlatiladigan umumiy atama. Go vositalarining o‘zi esa ko‘proq `package` va `module` tushunchalari bilan ishlaydi.

Masalan:

```text
github.com/google/uuid
```

Bu holatda `github.com/google/uuid` modul yo‘li ham, modul ildizidagi paketning import yo‘li ham bo‘lishi mumkin.

Lekin har doim modul va paket yo‘li aynan bir xil bo‘lavermaydi.

Masalan, quyidagi modulni tasavvur qilaylik:

```text
example.com/project
```

Uning ichida bir nechta paket bo‘lishi mumkin:

```text
example.com/project/client
example.com/project/server
example.com/project/config
```

Demak, **modul kattaroq birlik**, paket esa shu modul ichidagi kodning ma’lum bir qismi bo‘lishi mumkin.

Go paketlari bitta markaziy bazada saqlanmaydi. Paketlarning hujjatlarini [pkg.go.dev](https://pkg.go.dev/) orqali qidirish mumkin.

Modulning asl manba kodi esa odatda uning modul yo‘li orqali aniqlanadigan Git repozitoriyda joylashadi.

Masalan:

```text
github.com/google/uuid
```

yo‘li modulning GitHub’dagi manbasini ham ko‘rsatadi.

## Tashqi paket nima uchun kerak?

Tashqi paketning eng katta foydasi — oldin yozilgan va ko‘pincha amalda sinovdan o‘tgan koddan qayta foydalanish imkoniyati.

Masalan, dasturda UUID kerak bo‘lsa, UUID formatini noldan implementatsiya qilish shart emas. Tayyor paketdan foydalanish mumkin.

Xuddi shuningdek:

* PostgreSQL bilan ishlash uchun driver;
* API bilan ishlash uchun client;
* ma’lumot validatsiyasi uchun paket;
* konfiguratsiya parseri;
* maxsus protokol implementatsiyasi

kabi tashqi dependencylardan foydalanish mumkin.

Lekin tashqi dependency qo‘shish bilan birga yangi mas’uliyat ham paydo bo‘ladi.

Masalan:

* paket API’si yangi versiyada o‘zgarishi mumkin;
* dependency o‘z navbatida boshqa modullarga bog‘langan bo‘lishi mumkin;
* litsenziya sizning loyiha talablaringizga mos kelmasligi mumkin;
* dependency ichidagi bug sizning dasturingizga ham ta’sir qiladi;
* xavfsizlik muammosi paydo bo‘lsa, siz ham dependency versiyasini yangilashingiz kerak bo‘lishi mumkin.

Shuning uchun har bir kichik vazifa uchun darhol tashqi paket izlash to‘g‘ri yondashuv emas.

Avval Go standart kutubxonasi vazifani hal qila oladimi, tekshirish foydali.

Agar tashqi dependency haqiqatan kerak bo‘lsa, kamida quyidagilarni ko‘rib chiqish kerak:

* paketning hujjatlari;
* litsenziyasi;
* oxirgi yangilanishlari;
* API barqarorligi;
* relizlar tarixi;
* loyiha hali ham qo‘llab-quvvatlanayotgan yoki yo‘qligi.

## Loyihani tayyorlash

Go’da tashqi dependencylar odatda modul ichida boshqariladi.

Avval yangi katalog yaratamiz:

```bash
mkdir uuid-demo
cd uuid-demo
```

Keyin yangi Go modulini boshlaymiz:

```bash
go mod init example.com/uuid-demo
```

Bu buyruq joriy katalogda `go.mod` faylini yaratadi.

`example.com/uuid-demo` — biz tanlagan modul yo‘li.

Faqat lokal mashq qilayotgan bo‘lsangiz, bunday sun’iy nom yetarli.

Lekin modul haqiqiy ochiq repozitoriyga joylashtirilsa, odatda uning real manzili ishlatiladi. Masalan:

```text
github.com/foydalanuvchi/uuid-demo
```

`go mod init` bajarilgandan keyin taxminan quyidagi fayl hosil bo‘ladi:

```text
module example.com/uuid-demo

go 1.xx
```

Birinchi qator:

```text
module example.com/uuid-demo
```

joriy modulning yo‘lini belgilaydi.

`go` direktivasi esa loyiha uchun Go versiyasi bilan bog‘liq semantika va toolchain xatti-harakatiga ta’sir qiladigan qiymatni saqlaydi.

Masalan:

```text
go 1.25
```

kabi qiymat bo‘lishi mumkin.

Bu qiymat o‘rnatilgan Go toolchain va loyiha sozlamasiga qarab farq qilishi mumkin. Darsdagi qiymat bilan aynan bir xil qilish uchun uni majburan o‘zgartirish shart emas.

Modullar keyingi darslarda chuqurroq ko‘rib chiqilishi mumkin. Hozir esa dependency bilan ishlash uchun `go.mod` mavjud bo‘lishi muhim.

## Birinchi tashqi paket

UUID yaratish uchun `github.com/google/uuid` paketidan foydalanamiz.

`main.go` faylini yarating:

```go
package main

import (
	"fmt"

	"github.com/google/uuid"
)

func main() {
	id := uuid.New()
	fmt.Println("UUID:", id)
}
```

Bu yerda ikkita paket import qilinyapti:

```go
"fmt"
```

standart kutubxonadagi paket.

Quyidagi esa tashqi paket:

```go
"github.com/google/uuid"
```

`main()` ichida:

```go
id := uuid.New()
```

yangi UUID yaratadi.

Keyingi qator:

```go
fmt.Println("UUID:", id)
```

uni terminalga chiqaradi.

Endi dependencylarni loyiha holatiga moslashtiramiz:

```bash
go mod tidy
```

So‘ng dasturni ishga tushiramiz:

```bash
go run .
```

Natija taxminan quyidagicha bo‘ladi:

```text
UUID: 550e8400-e29b-41d4-a716-446655440000
```

Lekin aynan shu UUID chiqishini kutmang.

`uuid.New()` har bir chaqirilganda yangi qiymat yaratadi. Shu sabab keyingi ishga tushirishda boshqa UUID chiqadi.

Bu yerda `go mod tidy` muhim vazifani bajaradi.

U loyiha ichidagi importlarni tahlil qiladi. Kodda:

```go
"github.com/google/uuid"
```

import qilinganini ko‘radi va kerakli modulni dependency sifatida `go.mod`ga kiritadi.

Shuningdek, kerak bo‘lsa modulni yuklaydi va tegishli checksum ma’lumotlarini `go.sum` fayliga yozadi.

Dependency’ni aniq buyruq bilan ham qo‘shish mumkin:

```bash
go get github.com/google/uuid@latest
```

Bu buyruqda:

```text
github.com/google/uuid
```

modul yo‘li.

```text
@latest
```

esa mos keladigan eng yangi versiyani tanlashni so‘raydi.

`go get`ni shunchaki "paketni kompyuterga o‘rnatish" deb tushunish noto‘g‘ri.

Bu buyruq joriy Go modulining dependency grafigini o‘zgartiradi. Tanlangan versiya `go.mod` orqali loyihaga bog‘lanadi.

Kundalik ishda esa ko‘pincha quyidagi oqim qulay:

1. kodda kerakli paketni `import` qilish;
2. `go mod tidy` bajarish;
3. build yoki testlarni ishga tushirish.

**Ma'lumot**

CLI dasturini kompyuterga o‘rnatish dependency qo‘shishdan boshqa amal.

Masalan:

```bash
go install example.com/cmd/tool@version

`go install` ko‘rsatilgan command’ni o‘rnatadi.

U joriy loyihaning `go.mod` fayliga dependency qo‘shmaydi.

Demak, `go get` bilan modul dependencylarini boshqarish va `go install` bilan CLI tool o‘rnatish bir xil vazifa emas.
```

## Bevosita va bilvosita dependency

Dependencylar ikki asosiy turga bo‘linishi mumkin:

* bevosita dependency;
* bilvosita dependency.

Sizning kodingiz to‘g‘ridan-to‘g‘ri import qiladigan modul **bevosita dependency** hisoblanadi.

Masalan:

```go
import "github.com/google/uuid"
```

bo‘lsa, `github.com/google/uuid` loyihangiz uchun bevosita dependency.

Lekin `github.com/google/uuid`ning o‘zi boshqa modulni talab qilsa, o‘sha modul sizning kodingizda to‘g‘ridan-to‘g‘ri import qilinmasligi mumkin.

Shunday dependency **bilvosita dependency**, ya’ni indirect dependency hisoblanadi.

Modul grafigidagi barcha modullarni ko‘rish uchun:

```bash
go list -m all
```

buyrug‘idan foydalanish mumkin.

Bu yerda muhim bir qoida bor: bilvosita dependency ko‘rib qolsangiz, uni faqat o‘zingiz import qilmaganingiz uchun qo‘lda o‘chirib tashlamang.

U boshqa modulga kerak bo‘lishi mumkin.

Dependencylar holatini importlar va modul grafigiga moslashtirish uchun:

```bash
go mod tidy
```

ishlatiladi.

Bu buyruq qaysi dependency kerakligini Go modul qoidalari asosida aniqlaydi.

## Versiyani tanlash va yangilash

Dependency versiyasini boshqarish takrorlanuvchi build uchun muhim.

Masalan, aniq versiyani tanlash mumkin:

```bash
go get github.com/google/uuid@v1.6.0
```

Bu yerda:

```text
@v1.6.0
```

dependency’ning aniq versiyasini bildiradi.

Natijada loyiha `github.com/google/uuid` uchun aynan shu versiyani ishlatishga moslashtiriladi.

Bu darsdagi `v1.6.0` qiymati buyruq sintaksisini ko‘rsatish uchun ishlatilmoqda.

Amaliy loyihada esa versiyani shunchaki raqamiga qarab tanlamaslik kerak.

Quyidagilarni tekshirish foydali:

* release notes;
* changelog;
* API o‘zgarishlari;
* bug fixlar;
* xavfsizlik tuzatishlari;
* siz foydalanayotgan Go versiyasi bilan moslik.

Dependencylar bilan ishlashda tez-tez uchraydigan buyruqlar:

```bash
go list -m -u all
go get example.com/modul@v1.2.3
go get example.com/modul@latest
go mod tidy
```

Ularni alohida ko‘rib chiqamiz.

```bash
go list -m -u all
```

joriy modul grafigidagi dependencylar uchun yangiroq versiyalar mavjudligini tekshiradi.

Bu buyruqning maqsadi dependencylarni avtomatik yangilash emas. U mavjud yangilanishlarni ko‘rishga yordam beradi.

Quyidagi buyruq aniq versiyani tanlaydi:

```bash
go get example.com/modul@v1.2.3
```

Quyidagi esa eng yangi mos versiyani so‘raydi:

```bash
go get example.com/modul@latest
```

Lekin `@latest` ishlatilgani yangi versiya sizning kodingiz bilan albatta mos ishlashini anglatmaydi.

Dependency yangilangach quyidagilarni qayta bajarish kerak:

* testlar;
* build;
* static analysis;
* zarur bo‘lsa integration testlar.

Semantic Versioning qoidasida versiyalar odatda quyidagicha yoziladi:

```text
MAJOR.MINOR.PATCH
```

Masalan:

```text
v1.4.0
```

dan:

```text
v1.5.0
```

ga o‘tishda API mosligi saqlanishi kutiladi.

Lekin bu kutish dependency muallifi Semantic Versioning qoidalariga to‘g‘ri rioya qilayotganiga ham bog‘liq.

`v2` kabi major versiya esa mos kelmaydigan o‘zgarishlarni o‘z ichiga olishi mumkin.

Go modullarida `v2` va undan keyingi major versiyalar ko‘pincha modul va import yo‘lining bir qismiga aylanadi:

```go
import "example.com/lib/v2"
```

Bu juda muhim.

Masalan, `example.com/lib` va:

```text
example.com/lib/v2
```

Go nuqtai nazaridan turli modul yo‘llari hisoblanadi.

Shu sabab katta major versiyaga o‘tishda faqat `go.mod` emas, `import` qatorlarini ham o‘zgartirish kerak bo‘lishi mumkin.

## `go.mod` va `go.sum`

Go modulida dependencylarni boshqarishda ikkita fayl juda muhim:

```text
go.mod
go.sum
```

Ularning vazifasi bir xil emas.

### `go.mod`

`go.mod` joriy modul haqida asosiy ma’lumotlarni saqlaydi.

Masalan, unda:

* modul yo‘li;
* `go` direktivasi;
* kerakli dependencylar;
* ularning tanlangan versiyalari

bo‘lishi mumkin.

Soddalashtirilgan misol:

```text
module example.com/app

go 1.xx

require github.com/google/uuid v1.6.0
```

Bu yerda:

```text
require github.com/google/uuid v1.6.0
```

loyiha shu modulning tanlangan versiyasiga bog‘liqligini bildiradi.

### `go.sum`

`go.sum` esa modul fayllari uchun kriptografik nazorat summalarini saqlaydi.

Uning asosiy vazifalaridan biri dependency kontentini tekshirishga yordam berishdir.

Masalan, bir dependency avval ma’lum kontent bilan olingan bo‘lsa, keyinchalik aynan shu versiya nomi ostida kutilmagan boshqa kontent berilsa, checksum tekshiruvi buni aniqlashga yordam beradi.

Lekin `go.sum` haqida bir nechta muhim nozik jihat bor.

`go.sum`:

* dependency kodi xavfsiz ekanini isbotlamaydi;
* dependency’da bug yo‘qligini isbotlamaydi;
* barcha yozilgan modullar hozir to‘g‘ridan-to‘g‘ri import qilinayotganini anglatmaydi;
* security audit o‘rnini bosmaydi.

U asosan olingan modul kontentining yaxlitligini tekshirish mexanizmining bir qismidir.

`go.mod` va `go.sum` fayllarini odatda Git repozitoriyga commit qilish kerak.

Bu boshqa dasturchilar va CI muhitlariga bir xil dependency holatini qayta tiklashga yordam beradi.

Lekin modul keshi boshqa narsa.

Go yuklagan modullar odatda lokal module cache ichida saqlanadi. Bu keshni repozitoriyga commit qilish kerak emas.

## Keng tarqalgan xatolar

### Modul yaratmasdan `go get` ishlatish

Dependencylar loyiha modulining kontekstida boshqariladi.

Shu sabab yangi loyiha boshlaganda avval modul yaratish kerak:

```bash
go mod init example.com/project
```

Agar mavjud loyiha ichida ishlayotgan bo‘lsangiz, `go.mod` aynan joriy katalogda bo‘lishi shart emas. U yuqoridagi kataloglardan birida bo‘lishi mumkin.

Go qaysi `go.mod` faylidan foydalanayotganini ko‘rish uchun:

```bash
go env GOMOD
```

buyrug‘idan foydalanish mumkin.

Agar natija siz kutgan loyiha fayliga olib bormasa, ehtimol noto‘g‘ri katalogda ishlayotgan bo‘lishingiz mumkin.

### Import yo‘li o‘rniga repozitoriy sahifasini yozish

Go kodidagi `import` uchun to‘g‘ri **package import path** kerak.

Masalan:

```go
import "github.com/google/uuid"
```

Bu qiymatni brauzerda ochilgan tasodifiy GitHub katalog URL’i bilan adashtirmaslik kerak.

Repozitoriy ichidagi har bir katalog Go paketi bo‘lavermaydi.

Shuningdek, paketning import yo‘li har doim brauzerdagi sahifa URL’i bilan bir xil ko‘rinishda bo‘lishi shart emas.

Eng ishonchli manba — paketning rasmiy hujjati va uning ko‘rsatilgan import yo‘li.

### `go.sum`ni o‘chirib muammoni yashirish

Ba’zan dependency bilan bog‘liq checksum xatosi chiqqanda yangi boshlovchi:

```bash
rm go.sum
```

qilib muammoni yo‘qotishga urinishi mumkin.

Bu muammoning sababini tushunmasdan faylni o‘chirish yaxshi yondashuv emas.

Checksum xatosida quyidagilarni tekshirish kerak:

* dependency manbasi;
* modul versiyasi;
* proxy sozlamasi;
* korporativ proxy yoki private repository konfiguratsiyasi;
* oldin olingan va hozir olingan kontent o‘rtasida farq bor-yo‘qligi.

Checksum xatosi ba’zan aynan dependency kontenti kutilmaganda o‘zgarganini ko‘rsatishi mumkin.

Shuning uchun xatoni yo‘qotishdan oldin uning sababini aniqlash muhim.

### Dependency yangilanishini tekshirmaslik

Yangi versiya muvaffaqiyatli kompilyatsiya bo‘lsa, hammasi to‘g‘ri degani emas.

API signature o‘zgarmagan bo‘lsa ham, dependency xatti-harakati o‘zgargan bo‘lishi mumkin.

Masalan:

* default qiymatlar o‘zgargan;
* error qaytarish holati o‘zgargan;
* timeout xatti-harakati o‘zgargan;
* eski deprecated funksiyalar olib tashlangan;
* performance xususiyatlari o‘zgargan.

Shu sabab dependency yangilangach changelog yoki release notes’ni o‘qish kerak.

Keyin loyiha tekshiruvlarini ishga tushirish foydali:

```bash
go test ./...
go vet ./...
```

Agar loyiha boshqa build yoki integration testlardan foydalansa, ularni ham bajarish kerak.

## Misollar

Quyidagi misollarda `github.com/google/uuid` modulining `v1.6.0` versiyasi ishlatiladi.

Misollar bir-biridan mustaqil. Shu sabab har birini alohida bo‘sh katalogda bajarish qulay.

Bu usul bir misoldagi `go.mod`, `go.sum` yoki dependency holatining boshqa misolga ta’sir qilishining oldini oladi.

### 1. Dependency versiyasini aniq belgilash

Bu misolda tashqi modulning aniq versiyasini tanlaymiz va yangi UUID yaratamiz.

Kod:

```go
package main

import (
	"fmt"

	"github.com/google/uuid"
)

func main() {
	fmt.Println("UUID:", uuid.NewString())
}
```

Loyihani tayyorlash va ishga tushirish:

```bash
go mod init example.com/pinned-uuid
go get github.com/google/uuid@v1.6.0
go run .
```

Birinchi buyruq:

```bash
go mod init example.com/pinned-uuid
```

yangi modul yaratadi.

Keyingi buyruq:

```bash
go get github.com/google/uuid@v1.6.0
```

`github.com/google/uuid` modulining aynan `v1.6.0` versiyasini tanlaydi.

Koddagi:

```go
uuid.NewString()
```

har chaqirilganda yangi UUID yaratib, uni string ko‘rinishida qaytaradi.

Natija, masalan:

```text
UUID: 550e8400-e29b-41d4-a716-446655440000
```

ko‘rinishida bo‘lishi mumkin.

Lekin keyingi ishga tushirishda boshqa qiymat chiqadi.

Bu misoldagi asosiy qoida — dependency versiyasini aniq belgilash.

Aniq versiya tanlash turli muhitlarda aynan bir dependency versiyasi ishlatilishiga yordam beradi.

### 2. Importdan keyin `go mod tidy` ishlatish

Bu misol dependency ma’lumotlarini koddagi importlarga moslashtirish jarayonini ko‘rsatadi.

Kod:

```go
package main

import (
	"fmt"

	"github.com/google/uuid"
)

func main() {
	id := uuid.New()
	fmt.Println(id.String())
}
```

Buyruqlar:

```bash
go mod init example.com/tidy-uuid
go get github.com/google/uuid@v1.6.0
go mod tidy
go run .
```

Avval:

```bash
go get github.com/google/uuid@v1.6.0
```

bilan kerakli aniq versiya tanlanadi.

Keyin:

```bash
go mod tidy
```

importlar va modul dependencylari holatini bir-biriga moslashtiradi.

`go mod tidy` faqat dependency qo‘shish bilan cheklanmaydi. Keraksiz dependency yozuvlarini ham olib tashlashi mumkin.

Koddagi:

```go
id := uuid.New()
```

UUID qiymatini yaratadi.

Keyin:

```go
id.String()
```

UUID’ni string ko‘rinishiga aylantiradi.

Demak, bu misolda ikki alohida tushuncha ko‘rinmoqda:

1. dependency versiyasi `go get` bilan tanlanmoqda;
2. modul fayllari `go mod tidy` bilan koddagi haqiqiy importlarga moslashtirilmoqda.

### 3. Tanlangan modul versiyasini ko‘rish

Ba’zan `go.mod`ni qo‘lda ochishdan ko‘ra, Go aynan qaysi modul versiyasini tanlaganini buyruq orqali ko‘rish qulay.

Bu misolda UUID matndan parse qilinadi va dependency versiyasi ham tekshiriladi.

Kod:

```go
package main

import (
	"fmt"

	"github.com/google/uuid"
)

func main() {
	id, err := uuid.Parse("550e8400-e29b-41d4-a716-446655440000")
	if err != nil {
		fmt.Println("Xato:", err)
		return
	}

	fmt.Println(id)
}
```

Buyruqlar:

```bash
go mod init example.com/list-version
go get github.com/google/uuid@v1.6.0
go list -m github.com/google/uuid
go run .
```

Quyidagi buyruq:

```bash
go list -m github.com/google/uuid
```

modul grafigida `github.com/google/uuid` uchun tanlangan versiyani chiqaradi.

Bu misolda taxminan:

```text
github.com/google/uuid v1.6.0
```

ko‘rinishidagi natija kutiladi.

Koddagi:

```go
uuid.Parse(...)
```

string ko‘rinishidagi UUID’ni `uuid.UUID` qiymatiga aylantirishga urinadi.

Funksiya ikki qiymat qaytaradi:

```go
id, err := uuid.Parse(...)
```

`id` — muvaffaqiyatli parse qilingan UUID.

`err` — xato yuz bersa, xato ma’lumoti.

Shu sabab:

```go
if err != nil {
	fmt.Println("Xato:", err)
	return
}
```

orqali xato avval tekshiriladi.

Bu misol dependency versiyasini tekshirish bilan birga Go’dagi odatiy error handling usulini ham ko‘rsatadi.

### 4. Mavjud versiyalar ro‘yxatini olish

Yangi versiyaga o‘tishdan oldin modul uchun qanday versiyalar mavjudligini ko‘rish mumkin.

Bu misolda dastur UUID formatini tekshiradi, terminalda esa modul versiyalari ro‘yxati olinadi.

Kod:

```go
package main

import (
	"fmt"

	"github.com/google/uuid"
)

func main() {
	value := "550e8400-e29b-41d4-a716-446655440000"
	if err := uuid.Validate(value); err != nil {
		fmt.Println("Noto‘g‘ri UUID:", err)
		return
	}

	fmt.Println("UUID formati to‘g‘ri")
}
```

Buyruqlar:

```bash
go mod init example.com/uuid-versions
go get github.com/google/uuid@v1.6.0
go list -m -versions github.com/google/uuid
go run .
```

Quyidagi buyruq:

```bash
go list -m -versions github.com/google/uuid
```

modul uchun topilgan versiyalarni ko‘rsatadi.

Muhim jihat: bu buyruq dependency’ni yangilamaydi.

U faqat mavjud versiyalar haqida ma’lumot beradi.

Keyin qaysi versiyaga o‘tishni o‘zingiz tanlaysiz. Bunda release notes va API mosligini tekshirish kerak.

Koddagi:

```go
uuid.Validate(value)
```

berilgan string UUID formatiga mos yoki mos emasligini tekshiradi.

Agar qiymat to‘g‘ri bo‘lsa, `Validate()`:

```go
nil
```

qaytaradi.

Shunda `if` ichiga kirmaydi va:

```text
UUID formati to‘g‘ri
```

chiqariladi.

### 5. Dependency nima sababdan kerakligini tekshirish

Kattaroq loyihada ba’zan `go.mod` yoki modul grafigida dependency ko‘rib:

> Bu modul nima uchun kerak?

degan savol paydo bo‘ladi.

Buning uchun `go mod why` foydali.

Kod:

```go
package main

import (
	"fmt"

	"github.com/google/uuid"
)

func main() {
	id := uuid.MustParse("550e8400-e29b-41d4-a716-446655440000")
	users := map[uuid.UUID]string{
		id: "Ali",
	}

	fmt.Println(users[id])
}
```

Buyruqlar:

```bash
go mod init example.com/why-uuid
go get github.com/google/uuid@v1.6.0
go mod why -m github.com/google/uuid
go run .
```

Quyidagi buyruq:

```bash
go mod why -m github.com/google/uuid
```

asosiy moduldan shu dependency’ga olib keladigan paketlar yo‘lini ko‘rsatadi.

Ya’ni Go bu modul nima sababdan dependency grafigida borligini tushuntirishga yordam beradi.

Kodda:

```go
id := uuid.MustParse(...)
```

oldindan ma’lum UUID stringini `uuid.UUID` qiymatiga aylantiradi.

`MustParse()` oddiy `Parse()`dan farqli ravishda noto‘g‘ri qiymat kelsa `error` qaytarish o‘rniga panic qiladi.

Shu sabab u foydalanuvchi kiritgan noma’lum qiymatlar uchun yaxshi tanlov emas.

Bu misolda esa qiymat kod ichida oldindan yozilgan va to‘g‘ri ekanini bilamiz. Shu sabab `MustParse()` ishlatilgan.

Keyingi qism:

```go
users := map[uuid.UUID]string{
	id: "Ali",
}
```

`uuid.UUID`ni `map` kaliti sifatida ishlatadi.

Bu mumkin, chunki `uuid.UUID` solishtiriladigan tur.

So‘ng:

```go
fmt.Println(users[id])
```

orqali shu UUID kalitiga tegishli qiymat olinadi:

```text
Ali
```

### 6. Modul bog‘lanishlari grafigini ko‘rish

Dependencylar faqat bitta darajadan iborat bo‘lmasligi mumkin.

Bitta modul boshqa modulga, u esa yana boshqa modulga bog‘liq bo‘lishi mumkin.

Modullar o‘rtasidagi bu bog‘lanish **dependency graph** hosil qiladi.

Kod:

```go
package main

import (
	"fmt"

	"github.com/google/uuid"
)

func main() {
	id, err := uuid.NewV7()
	if err != nil {
		fmt.Println("UUID yaratilmadi:", err)
		return
	}

	fmt.Println(id)
}
```

Buyruqlar:

```bash
go mod init example.com/uuid-graph
go get github.com/google/uuid@v1.6.0
go mod graph
go run .
```

Quyidagi buyruq:

```bash
go mod graph
```

modullar o‘rtasidagi dependency aloqalarini chiqaradi.

Har bir satrda taxminan:

```text
talab-qiluvchi-modul talab-qilinuvchi-modul
```

munosabati ko‘rinadi.

Kichik loyiha va dependencylari kam modulda natija qisqa bo‘lishi mumkin.

Kattaroq loyihada esa grafik ancha katta bo‘ladi.

Koddagi:

```go
id, err := uuid.NewV7()
```

version 7 UUID yaratishga urinadi.

Bu funksiya UUID bilan birga `error` ham qaytaradi.

Shuning uchun:

```go
if err != nil {
	fmt.Println("UUID yaratilmadi:", err)
	return
}
```

orqali xato tekshiriladi.

Faqat operatsiya muvaffaqiyatli bo‘lgandan keyin:

```go
fmt.Println(id)
```

bajariladi.

### 7. Dependencylarni oldindan yuklash va tekshirish

Ba’zan build boshlanishidan oldin barcha kerakli modullarni yuklab qo‘yish foydali.

Masalan, CI pipeline yoki tarmoqdan foydalanishni oldindan nazorat qilish kerak bo‘lgan muhitda.

Kod:

```go
package main

import (
	"fmt"

	"github.com/google/uuid"
)

func main() {
	data := make([]byte, 16)
	id, err := uuid.FromBytes(data)
	if err != nil {
		fmt.Println("Xato:", err)
		return
	}

	fmt.Println(id)
}
```

Buyruqlar:

```bash
go mod init example.com/verify-uuid
go get github.com/google/uuid@v1.6.0
go mod download
go mod verify
go run .
```

Quyidagi buyruq:

```bash
go mod download
```

modul dependencylarini lokal module cache’ga yuklash uchun ishlatiladi.

Keyingi buyruq:

```bash
go mod verify
```

cache’dagi dependency kontenti oldin qayd etilgan nazorat summalari bilan mos kelishini tekshiradi.

Bu dependency kodi xavfsizligini audit qilmaydi.

Uning vazifasi boshqa: yuklangan modul fayllari kutilgan kontent bilan mosligini tekshirish.

Endi kodni ko‘ramiz.

```go
data := make([]byte, 16)
```

uzunligi `16` bo‘lgan `[]byte` yaratadi.

`make` bilan yaratilgan byte slice’ning barcha elementlari dastlab zero value oladi:

```text
0
```

Shuning uchun konseptual tarzda qiymat quyidagiga teng:

```text
[0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]
```

UUID `16` baytdan iborat bo‘lgani uchun:

```go
uuid.FromBytes(data)
```

shu slice’dan `uuid.UUID` yaratishi mumkin.

Funksiya `error` ham qaytargani sabab u albatta tekshiriladi.

### 8. Yangilanishni alohida tekshirish

Dependency’ning yangi versiyasi mavjudligini tekshirish va uni yangilash ikki xil amal.

Bu misolda faqat yangilanish mavjudligi tekshiriladi.

Kod:

```go
package main

import (
	"fmt"

	"github.com/google/uuid"
)

func main() {
	first := uuid.NewString()
	second := uuid.NewString()

	fmt.Println("Bir xilmi:", first == second)
}
```

Buyruqlar:

```bash
go mod init example.com/check-version
go get github.com/google/uuid@v1.6.0
go list -m -u github.com/google/uuid
go run .
```

Avval:

```bash
go get github.com/google/uuid@v1.6.0
```

bilan aniq versiya tanlanadi.

Keyin:

```bash
go list -m -u github.com/google/uuid
```

shu modul uchun yangiroq versiya mavjudligini tekshiradi.

Agar yangilanish mavjud bo‘lsa, buyruq tanlangan va yangi versiya haqida ma’lumot ko‘rsatishi mumkin.

Muhim jihat:

```bash
go list -m -u
```

`go.mod`ni yangilamaydi.

U faqat ma’lumot beradi.

Dependency’ni yangilashdan oldin:

* release notes;
* changelog;
* breaking change ehtimoli;
* test natijalari

tekshirilishi kerak.

Kodda:

```go
first := uuid.NewString()
second := uuid.NewString()
```

ikkita alohida yangi UUID yaratiladi.

Keyin:

```go
first == second
```

ularni solishtiradi.

Oddiy holatda ular turli bo‘ladi. Shu sabab natija:

```text
Bir xilmi: false
```

bo‘lishi kutiladi.

### 9. Ishlatilmaydigan dependencyni olib tashlash

Dependency bir paytlar kerak bo‘lib, keyinchalik koddan olib tashlanishi mumkin.

Bunday holatda `go.mod`ni doim qo‘lda tozalash shart emas.

`go mod tidy` dependency holatini koddagi haqiqiy importlarga moslashtira oladi.

Yakuniy kod:

```go
package main

import "fmt"

func main() {
	fmt.Println("Tashqi dependency kerak emas")
}
```

Buyruqlar:

```bash
go mod init example.com/remove-dependency
go get github.com/google/uuid@v1.6.0
go mod tidy
go run .
```

Bu yerda avval:

```bash
go get github.com/google/uuid@v1.6.0
```

bilan `github.com/google/uuid` dependency sifatida qo‘shiladi.

Lekin dastur kodiga qarasak, unda:

```go
import "github.com/google/uuid"
```

yo‘q.

Kod faqat:

```go
import "fmt"
```

standart paketidan foydalanmoqda.

Shundan keyin:

```bash
go mod tidy
```

ishga tushirilganda Go importlarni tahlil qiladi.

`github.com/google/uuid` endi kerak emasligini aniqlaydi va uning keraksiz `require` yozuvini `go.mod`dan olib tashlaydi.

Bu yerda asosiy qoida shuki, dependency ro‘yxatini imkon qadar kodning haqiqiy holati bilan sinxron saqlash kerak.

Shuning uchun dependency qatorlarini sababsiz qo‘lda tahrirlash o‘rniga:

```bash
go mod tidy
```

dan foydalanish odatda xavfsizroq va qulayroq.

### 10. Dependencylarni `vendor` katalogiga yig‘ish

Odatda Go dependencylarni module cache orqali boshqaradi.

Lekin ayrim loyihalarda build uchun kerakli dependency paketlarini loyihaning o‘z ichiga nusxalash talab qilinishi mumkin.

Buning uchun `vendor` katalogidan foydalanish mumkin.

Kod:

```go
package main

import (
	"fmt"

	"github.com/google/uuid"
)

func main() {
	id := uuid.MustParse("550e8400-e29b-41d4-a716-446655440000")
	fmt.Println("UUID versiyasi:", id.Version())
}
```

Buyruqlar:

```bash
go mod init example.com/vendor-uuid
go get github.com/google/uuid@v1.6.0
go mod vendor
go run -mod=vendor .
```

Avval dependency aniq versiya bilan qo‘shiladi:

```bash
go get github.com/google/uuid@v1.6.0
```

Keyin:

```bash
go mod vendor
```

buyrug‘i build uchun kerakli dependency paketlarini loyiha ichidagi:

```text
vendor/
```

katalogiga joylashtiradi.

Masalan, loyiha tuzilishi taxminan quyidagicha bo‘lishi mumkin:

```text
example-project/
├── go.mod
├── go.sum
├── main.go
└── vendor/
```

Keyingi buyruq:

```bash
go run -mod=vendor .
```

Go’ga dependencylarni `vendor` katalogidan ishlatishni aniq bildiradi.

Koddagi:

```go
id := uuid.MustParse("550e8400-e29b-41d4-a716-446655440000")
```

oldindan ma’lum UUID’ni parse qiladi.

Keyin:

```go
id.Version()
```

UUID’ning versiyasini qaytaradi.

Natija UUID qiymatiga qarab chiqariladi.

`vendor` katalogidan foydalanish har bir loyiha uchun majburiy emas.

Uni Git repozitoriyga commit qilish yoki qilmaslik ham loyiha siyosatiga bog‘liq.

Masalan, ba’zi jamoalar:

* barcha dependency kodini build bilan birga saqlash;
* tashqi tarmoqqa bog‘liqlikni kamaytirish;
* maxsus build siyosatini bajarish

uchun `vendor`dan foydalanadi.

Boshqa loyihalarda esa oddiy Go module cache va `go.mod`/`go.sum` yetarli bo‘ladi.

Muhim jihat shuki, `vendor` katalogi ishlatilsa ham:

```text
go.mod
go.sum
```

dependency tanlovini boshqaradigan asosiy modul fayllari bo‘lib qoladi.
