# Go’da test yozish

Test — kodning kutilgan natijani berishini avtomatik tekshiradigan kod.

Masalan, `Add(2, 3)` funksiyasi `5` qaytarishi kerak bo‘lsa, buni har safar qo‘lda tekshirish shart emas. Test yozib qo‘ysak, Go bu tekshiruvni avtomatik bajaradi.

Go’da buning uchun alohida test framework o‘rnatish shart emas. Standart kutubxonadagi `testing` paketi va `go test` buyrug‘i asosiy testlarni yozish uchun yetarli.

Testlar faqat funksiyaning to‘g‘ri natija qaytarishini tekshirish uchun emas. Ular xato holatlari, chegara qiymatlari, fayl bilan ishlash, `error` qiymatlari va boshqa xatti-harakatlarni ham tekshirishi mumkin.

## Birinchi test

Avval juda oddiy funksiyadan boshlaymiz.

Quyidagi `hisob` paketi ikkita butun sonni qo‘shadi:

```go
package hisob

func Add(a, b int) int {
	return a + b
}
```

`Add()` ikkita `int` qiymat qabul qiladi va ularning yig‘indisini qaytaradi.

Masalan:

```text
Add(2, 3) → 5
```

Endi shu xatti-harakatni test bilan tekshiramiz.

Go test fayllarining nomi `_test.go` bilan tugashi kerak. Masalan:

```text
hisob.go
hisob_test.go
```

Test funksiyasi odatda `TestXxx(t *testing.T)` ko‘rinishida yoziladi:

```go
package hisob

import "testing"

func TestAdd(t *testing.T) {
	got := Add(2, 3)
	want := 5

	if got != want {
		t.Errorf("Add(2, 3) = %d; %d kutilgan", got, want)
	}
}
```

Bu testni bosqichma-bosqich ko‘ramiz.

Avval haqiqiy natija olinadi:

```go
got := Add(2, 3)
```

`got` — funksiya amalda qaytargan qiymat. Bu yerda uning qiymati `5` bo‘lishi kerak.

Keyin kutilgan natijani yozamiz:

```go
want := 5
```

`want` — test bo‘yicha to‘g‘ri deb hisoblangan qiymat.

So‘ng ikkala qiymat solishtiriladi:

```go
if got != want {
	t.Errorf("Add(2, 3) = %d; %d kutilgan", got, want)
}
```

Agar `got` va `want` teng bo‘lmasa, test muvaffaqiyatsiz hisoblanadi.

Masalan, `Add()` tasodifan quyidagicha yozilgan bo‘lsa:

```go
func Add(a, b int) int {
	return a - b
}
```

`Add(2, 3)` natijasi `-1` bo‘ladi. Test esa `5` kutmoqda. Shunda `t.Errorf()` xatoni qayd etadi.

Joriy paketdagi testlarni quyidagicha bajarish mumkin:

```bash
go test
```

Modul ichidagi barcha paketlarning testlarini bajarish uchun:

```bash
go test ./...
```

Bu ikki buyruq o‘rtasida muhim farq bor:

```text
go test
```

faqat joriy paketni test qiladi.

```text
go test ./...
```

esa joriy modul ichidagi paketlar va ularning quyi paketlarini ham tekshiradi.

### `t.Errorf()` va `t.Fatalf()` farqi

Testlarda xatoni qayd etishning bir nechta usuli bor. Eng ko‘p uchraydiganlaridan ikkitasi `t.Errorf()` va `t.Fatalf()`.

`t.Errorf()` testni muvaffaqiyatsiz deb belgilaydi, lekin joriy test funksiyasi bajarilishini davom ettiradi:

```go
if got != want {
	t.Errorf("natija noto‘g‘ri")
}
```

Bu keyingi tekshiruvlarni ham bajarish foydali bo‘lgan holatlarda ishlatiladi.

`t.Fatalf()` esa xatoni qayd etadi va joriy test funksiyasini shu joyda to‘xtatadi:

```go
if err != nil {
	t.Fatalf("kutilmagan xato: %v", err)
}
```

Bu odatda keyingi kodni bajarish ma’nosiz bo‘lib qolganida kerak.

Masalan, faylni ochishning o‘zi muvaffaqiyatsiz bo‘lsa, fayl ichidagi ma’lumotni tekshirishning iloji yo‘q. Shunday holatda `t.Fatalf()` mantiqan to‘g‘riroq.

Muhim jihat shuki, `t.Fatalf()` butun `go test` jarayonini to‘xtatmaydi. U aynan joriy testning bajarilishini to‘xtatadi. Boshqa testlar odatda bajarilishda davom etishi mumkin.

## Table-driven test va subtest

Ko‘pincha bitta funksiyani faqat bitta qiymat bilan tekshirish yetarli bo‘lmaydi.

Masalan, `Add()` funksiyasini quyidagi holatlarda tekshirmoqchi bo‘lishimiz mumkin:

* ikkita musbat son;
* ikkita manfiy son;
* son va nol.

Har bir holat uchun alohida `Test...` funksiyasi yozish mumkin. Lekin Go’da bunday testlarni jadval ko‘rinishida saqlash juda keng tarqalgan.

Bu usul **table-driven test** deb ataladi.

```go
func TestAdd(t *testing.T) {
	tests := []struct {
		name       string
		a, b, want int
	}{
		{name: "musbat", a: 2, b: 3, want: 5},
		{name: "manfiy", a: -2, b: -3, want: -5},
		{name: "nol", a: 4, b: 0, want: 4},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := Add(tt.a, tt.b)

			if got != tt.want {
				t.Errorf(
					"Add(%d, %d) = %d; %d kutilgan",
					tt.a,
					tt.b,
					got,
					tt.want,
				)
			}
		})
	}
}
```

Bu yerda `tests` — test holatlari saqlanadigan slice.

Har bir element quyidagi ma’lumotlarni saqlaydi:

```go
name       string
a, b, want int
```

`name` test holatining nomi.

`a` va `b` — `Add()` funksiyasiga beriladigan argumentlar.

`want` — kutilgan natija.

Masalan:

```go
{name: "manfiy", a: -2, b: -3, want: -5}
```

quyidagi tekshiruvni bildiradi:

```text
Add(-2, -3) → -5 bo‘lishi kerak
```

Keyin barcha holatlar `for` orqali birma-bir olinadi:

```go
for _, tt := range tests {
	...
}
```

Har bir holat uchun `t.Run()` chaqiriladi:

```go
t.Run(tt.name, func(t *testing.T) {
	...
})
```

`t.Run()` alohida **subtest** yaratadi.

Natijada testlar taxminan quyidagi nomlarda ko‘rinadi:

```text
TestAdd/musbat
TestAdd/manfiy
TestAdd/nol
```

Buning foydasi shundaki, aynan qaysi holat yiqilganini ko‘rish osonlashadi.

Masalan, faqat `musbat` subtestini ishga tushirish mumkin:

```bash
go test -run 'TestAdd/musbat'
```

Bitta subtest muvaffaqiyatsiz bo‘lsa, boshqa subtestlar ham odatda bajarilishda davom etadi.

Table-driven test ayniqsa bir xil qoidani ko‘p qiymatlar bilan tekshirish kerak bo‘lganda foydali. Yangi holat qo‘shish uchun yangi test funksiyasi yozish shart emas. Jadvalga yana bitta element qo‘shish kifoya.

## Testlarni mustaqil saqlash

Yaxshi test boshqa testning natijasiga yoki bajarilish tartibiga bog‘liq bo‘lmasligi kerak.

Masalan, bunday yondashuv xavfli:

```text
TestA global qiymatni o‘zgartiradi
↓
TestB shu o‘zgargan qiymatga ishonadi
```

Agar testlarning bajarilish tartibi o‘zgarsa yoki `TestB` alohida bajarilsa, u yiqilishi mumkin.

Shuning uchun har bir test imkon qadar o‘z holatini o‘zi tayyorlashi va test tugagach tashqi muhitda keraksiz o‘zgarish qoldirmasligi kerak.

Ayniqsa quyidagilarga ehtiyot bo‘lish kerak:

* global holatni o‘zgartirish;
* foydalanuvchining haqiqiy fayllarini ishlatish;
* umumiy database holatiga tayanish;
* tashqi network servislariga keraksiz murojaat qilish;
* boshqa test yaratgan fayl yoki ma’lumotga bog‘lanish.

Fayl bilan ishlaydigan testlarda vaqtinchalik katalog kerak bo‘lishi mumkin. Buning uchun Go `t.TempDir()` metodini beradi.

```go
func TestSave(t *testing.T) {
	dir := t.TempDir()
	path := filepath.Join(dir, "result.txt")

	if err := os.WriteFile(path, []byte("salom"), 0o600); err != nil {
		t.Fatalf("fayl yozilmadi: %v", err)
	}

	data, err := os.ReadFile(path)
	if err != nil {
		t.Fatalf("fayl o‘qilmadi: %v", err)
	}

	if string(data) != "salom" {
		t.Errorf("natija = %q; %q kutilgan", data, "salom")
	}
}
```

Bu snippet uchun quyidagi importlar kerak:

```go
import (
	"os"
	"path/filepath"
	"testing"
)
```

Jarayonni bosqichma-bosqich ko‘ramiz.

Avval test uchun vaqtinchalik katalog yaratiladi:

```go
dir := t.TempDir()
```

Bu katalog testga tegishli bo‘ladi. Test tugagach Go uni avtomatik tozalaydi.

Keyin shu katalog ichida fayl yo‘li yaratiladi:

```go
path := filepath.Join(dir, "result.txt")
```

`filepath.Join()` operatsion tizimga mos fayl yo‘lini hosil qiladi.

So‘ng `"salom"` matni faylga yoziladi:

```go
os.WriteFile(path, []byte("salom"), 0o600)
```

`0o600` Unix uslubidagi permission qiymati:

```text
egasi:     o‘qish + yozish
boshqalar: ruxsat yo‘q
```

Agar yozishda xato yuz bersa:

```go
t.Fatalf("fayl yozilmadi: %v", err)
```

deyiladi.

Bu yerda `Fatalf` ishlatilishining sababi muhim. Fayl yozilmagan bo‘lsa, keyingi bosqichda uni o‘qish va ichidagi ma’lumotni tekshirishning ma’nosi qolmaydi.

Keyin fayl qayta o‘qiladi:

```go
data, err := os.ReadFile(path)
```

Va yakunda fayl ichidagi qiymat tekshiriladi:

```go
if string(data) != "salom" {
	t.Errorf(...)
}
```

`t.TempDir()` yordamida test foydalanuvchining haqiqiy fayllariga bog‘lanmaydi. Bu testlarni xavfsizroq va takror bajarishga qulayroq qiladi.

## Coverage

**Coverage** testlar kodning qaysi qismlarini bajarganini ko‘rsatadi.

Oddiy coverage foizini olish uchun:

```bash
go test -cover ./...
```

Masalan, natijada shunga o‘xshash ma’lumot chiqishi mumkin:

```text
coverage: 82.4% of statements
```

Bu testlar bajarilganda statementlarning qanchasi ishga tushganini bildiradi.

Coverage natijasini faylga saqlash uchun:

```bash
go test -coverprofile=coverage.out ./...
```

Bu buyruq `coverage.out` nomli profil yaratadi.

Keyin uni HTML ko‘rinishida ochish mumkin:

```bash
go tool cover -html=coverage.out
```

HTML hisobot qaysi kod testlar orqali bajarilganini va qaysi qism bajarilmaganini ko‘rishni osonlashtiradi.

Lekin coverage foizini kod sifatining to‘liq o‘lchovi deb qabul qilish kerak emas.

Masalan, test funksiya ichidagi barcha satrlarni bajargani bilan noto‘g‘ri natijalarni tekshirmayotgan bo‘lishi mumkin. Bunday test yuqori coverage berishi mumkin, lekin amalda foydasi kam.

Shuning uchun testlarda faqat coverage foiziga emas, tekshirilayotgan xatti-harakatga ham qarash kerak.

Muhim holatlar orasida odatda quyidagilar bor:

* odatiy muvaffaqiyatli yo‘l;
* chegara qiymatlari;
* noto‘g‘ri input;
* `error` qaytadigan yo‘llar;
* nol yoki bo‘sh qiymatlar;
* biznes uchun muhim maxsus holatlar.

Yuqori coverage foydali signal bo‘lishi mumkin. Lekin u kod to‘g‘riligini o‘zi mustaqil ravishda isbotlamaydi.

## Misollar

### 1. Oddiy natijani tekshirish

Bu misol test yozishning eng asosiy shaklini ko‘rsatadi. Funksiya qaytargan haqiqiy qiymat kutilgan qiymat bilan solishtiriladi.

```go
package main

import "testing"

func multiply(a, b int) int {
	return a * b
}

func TestMultiply(t *testing.T) {
	got := multiply(4, 3)
	want := 12

	if got != want {
		t.Errorf("multiply(4, 3) = %d; %d kutilgan", got, want)
	}
}
```

Testning birinchi muhim qatori:

```go
got := multiply(4, 3)
```

Bu yerda funksiya amalda nima qaytargani olinadi.

Hisob:

```text
4 * 3 = 12
```

Keyingi qator:

```go
want := 12
```

test kutayotgan natijani saqlaydi.

So‘ng:

```go
if got != want {
	...
}
```

orqali amaldagi va kutilgan qiymat taqqoslanadi.

Agar `multiply(4, 3)` `12` qaytarsa, test muvaffaqiyatli tugaydi.

Agar boshqa qiymat qaytarsa:

```go
t.Errorf("multiply(4, 3) = %d; %d kutilgan", got, want)
```

testni failed holatiga o‘tkazadi.

Bu misoldagi asosiy qoida juda sodda:

```text
got = amaldagi natija
want = kutilgan natija
```

Ko‘p Go testlarining asosida aynan shu yondashuv turadi.

### 2. Xatoni natijadan oldin tekshirish

Funksiya qiymat bilan birga `error` ham qaytarsa, ko‘pincha `error`ni birinchi bo‘lib tekshirish kerak.

Quyidagi funksiya ikkita butun sonni bo‘ladi:

```go
package main

import (
	"errors"
	"testing"
)

func divide(a, b int) (int, error) {
	if b == 0 {
		return 0, errors.New("nolga bo‘lish mumkin emas")
	}

	return a / b, nil
}

func TestDivide(t *testing.T) {
	got, err := divide(12, 3)
	if err != nil {
		t.Fatalf("divide() kutilmagan xato qaytardi: %v", err)
	}

	want := 4
	if got != want {
		t.Errorf("divide(12, 3) = %d; %d kutilgan", got, want)
	}
}
```

`divide()` ikkita natija qaytaradi:

```go
(int, error)
```

Muvaffaqiyatli holatda:

```go
return a / b, nil
```

bo‘ladi.

Masalan:

```text
12 / 3 = 4
```

Shuning uchun:

```go
got, err := divide(12, 3)
```

dan keyin:

```text
got = 4
err = nil
```

bo‘lishi kutiladi.

Birinchi tekshiruv aynan `err` uchun yozilgan:

```go
if err != nil {
	t.Fatalf("divide() kutilmagan xato qaytardi: %v", err)
}
```

Bu yerda `t.Fatalf()` tanlangan. Sababi `divide()` xato qaytargan bo‘lsa, `got` qiymatini normal natija sifatida tekshirish endi mantiqan to‘g‘ri emas.

Faqat xato yo‘q ekaniga ishonch hosil qilgandan keyin:

```go
want := 4
```

va:

```go
if got != want {
	...
}
```

bajariladi.

Bu misolda `12` va `3` tasodifiy tanlanmagan. `12 / 3` butun son sifatida aniq `4` beradi. Shuning uchun bu test integer division bilan bog‘liq boshqa nozikliklarni aralashtirmaydi.

Asosiy qoida:

```text
Agar natijaning ma’nosi muvaffaqiyatli bajarilishga bog‘liq bo‘lsa,
avval errorni tekshiring.
```

### 3. Chegara qiymatlarini jadvalda tekshirish

Bu misol table-driven test yordamida funksiyaning bir nechta muhim holatini tekshiradi.

```go
package main

import "testing"

func normalize(value int) int {
	if value < 0 {
		return 0
	}

	return value
}

func TestNormalize(t *testing.T) {
	tests := []struct {
		name  string
		value int
		want  int
	}{
		{name: "manfiy", value: -1, want: 0},
		{name: "chegara", value: 0, want: 0},
		{name: "musbat", value: 5, want: 5},
	}

	for _, tt := range tests {
		got := normalize(tt.value)

		if got != tt.want {
			t.Errorf(
				"%s: normalize(%d) = %d; %d kutilgan",
				tt.name,
				tt.value,
				got,
				tt.want,
			)
		}
	}
}
```

`normalize()` qoidasi:

```text
value < 0 bo‘lsa → 0
aks holda          → value
```

Shuning uchun test uchta muhim holatni tekshiradi.

Birinchisi:

```go
{name: "manfiy", value: -1, want: 0}
```

`-1 < 0` rost. Funksiya `0` qaytarishi kerak.

Ikkinchisi:

```go
{name: "chegara", value: 0, want: 0}
```

Bu aynan shart chegarasi.

Funksiyada:

```go
if value < 0
```

yozilgan.

`0 < 0` yolg‘on. Demak, `0` o‘zgarishsiz qaytariladi.

Uchinchisi:

```go
{name: "musbat", value: 5, want: 5}
```

`5` musbat qiymat bo‘lgani uchun funksiya uni o‘zgartirmasdan qaytarishi kerak.

Chegara qiymatlarini test qilish muhim. Chunki `<`, `<=`, `>`, `>=` kabi operatorlardagi bitta belgining o‘zgarishi funksiyaning aynan chegaradagi xatti-harakatini o‘zgartirib yuborishi mumkin.

Bu misolning asosiy qoidasi — faqat odatiy qiymatlarni emas, shart o‘zgaradigan chegarani ham tekshirish.

### 4. Holatlarni subtestlarga ajratish

Bu misol table-driven testdagi har bir holatni alohida subtest sifatida bajarishni ko‘rsatadi.

```go
package main

import "testing"

func isEven(value int) bool {
	return value%2 == 0
}

func TestIsEven(t *testing.T) {
	tests := []struct {
		name  string
		value int
		want  bool
	}{
		{name: "juft", value: 8, want: true},
		{name: "toq", value: 7, want: false},
		{name: "nol", value: 0, want: true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := isEven(tt.value)

			if got != tt.want {
				t.Errorf(
					"isEven(%d) = %t; %t kutilgan",
					tt.value,
					got,
					tt.want,
				)
			}
		})
	}
}
```

`isEven()` juftlikni qoldiq orqali tekshiradi:

```go
value%2 == 0
```

Masalan:

```text
8 % 2 = 0
```

Shuning uchun `8` juft.

```text
7 % 2 = 1
```

Shuning uchun `7` toq.

Nol uchun:

```text
0 % 2 = 0
```

Demak, `0` ham juft son hisoblanadi.

`t.Run()` orqali har bir holat o‘z nomiga ega bo‘ladi:

```text
TestIsEven/juft
TestIsEven/toq
TestIsEven/nol
```

Bu test natijasini o‘qishni osonlashtiradi.

Masalan, faqat juft son holatini bajarish mumkin:

```bash
go test -run 'TestIsEven/juft'
```

Bu katta test to‘plamida ayniqsa qulay. Muammo faqat bitta holatda bo‘lsa, butun jadvalni qayta-qayta bajarish shart bo‘lmasligi mumkin.

Asosiy qoida — `t.Run()` test holatlariga alohida nom va alohida subtest kontekstini beradi.

### 5. Takroriy tekshiruvni helper funksiyaga ajratish

Bir xil test tekshiruvi ko‘p joyda takrorlansa, uni helper funksiyaga chiqarish mumkin.

```go
package main

import "testing"

func add(a, b int) int {
	return a + b
}

func assertEqual(t *testing.T, got, want int) {
	t.Helper()

	if got != want {
		t.Errorf("natija = %d; %d kutilgan", got, want)
	}
}

func TestAdd(t *testing.T) {
	assertEqual(t, add(2, 3), 5)
	assertEqual(t, add(-2, 2), 0)
}
```

Helper funksiya:

```go
func assertEqual(t *testing.T, got, want int)
```

bir xil tenglik tekshiruvini bitta joyga to‘playdi.

Muhim qator:

```go
t.Helper()
```

Bu `testing` paketiga `assertEqual()` oddiy test logikasi emas, yordamchi test funksiyasi ekanini bildiradi.

Buning foydasi xato hisobotida ko‘rinadi.

Agar helper ichidagi tekshiruv yiqilsa, Go xato joyini imkon qadar helperning ichidagi:

```go
t.Errorf(...)
```

qatoriga emas, helper chaqirilgan test qatoriga bog‘lab ko‘rsatadi.

Masalan:

```go
assertEqual(t, add(2, 3), 5)
```

Bu qaysi tekshiruv muammo berganini tezroq aniqlashga yordam beradi.

Ikkinchi holat:

```go
assertEqual(t, add(-2, 2), 0)
```

qarama-qarshi qiymatlarni tekshiradi:

```text
-2 + 2 = 0
```

Helper funksiyalar ayniqsa katta testlarda takroriy tekshiruv, setup yoki boshqa yordamchi operatsiyalarni ajratish uchun foydali.

Asosiy qoida — test helper yozsangiz, kerakli joyda `t.Helper()` orqali uni yordamchi funksiya sifatida belgilash foydali.

### 6. Test tozalash funksiyasini ro‘yxatdan o‘tkazish

Test davomida vaqtinchalik resource yaratish kerak bo‘lishi mumkin.

Masalan:

* fayl;
* vaqtinchalik server;
* test database holati;
* o‘zgartirilgan global konfiguratsiya.

Bunday resource test tugagach tozalanishi kerak.

`t.Cleanup()` test yoki subtest tugagandan keyin bajariladigan funksiyani ro‘yxatdan o‘tkazadi.

```go
package main

import "testing"

func TestCleanup(t *testing.T) {
	events := make([]string, 0, 2)

	t.Run("resource", func(t *testing.T) {
		t.Cleanup(func() {
			events = append(events, "tozalandi")
		})

		events = append(events, "ishlatildi")
	})

	if len(events) != 2 {
		t.Fatalf("hodisalar soni = %d; 2 kutilgan", len(events))
	}

	if events[0] != "ishlatildi" || events[1] != "tozalandi" {
		t.Errorf("hodisalar tartibi noto‘g‘ri: %v", events)
	}
}
```

Avval slice yaratiladi:

```go
events := make([]string, 0, 2)
```

Bu yerda:

```text
len = 0
cap = 2
```

`len` `0`, chunki hali slice ichida hech qanday element yo‘q.

`cap` `2`, chunki bu test ikkita hodisa yozilishini kutmoqda:

```text
ishlatildi
tozalandi
```

Keyin subtest boshlanadi:

```go
t.Run("resource", func(t *testing.T) {
	...
})
```

Subtest ichida cleanup funksiyasi ro‘yxatdan o‘tkaziladi:

```go
t.Cleanup(func() {
	events = append(events, "tozalandi")
})
```

Bu funksiya shu zahoti bajarilmaydi.

Keyingi qator bajariladi:

```go
events = append(events, "ishlatildi")
```

Shu vaqtda:

```text
events = ["ishlatildi"]
```

Subtest tugayotganida uning cleanup funksiyasi ishlaydi:

```text
events = ["ishlatildi", "tozalandi"]
```

`t.Run()` qaytgan paytda subtestning cleanup funksiyalari bajarib bo‘lingan bo‘ladi. Shuning uchun tashqi test quyidagi tartibni tekshira oladi:

```go
events[0] == "ishlatildi"
events[1] == "tozalandi"
```

Avval uzunlik tekshiriladi:

```go
if len(events) != 2 {
	t.Fatalf(...)
}
```

Bu yerda `Fatalf` ishlatilishi mantiqli. Agar slice ichida ikkita element bo‘lmasa, keyingi `events[0]` yoki `events[1]` kabi murojaatlar xavfli bo‘lishi mumkin.

Bu misolning asosiy qoidasi — resource yaratgan test uning cleanup ishini ham o‘zi boshqarishi kerak.

### 7. Vaqtinchalik katalogda fayl tekshirish

Bu misolda test foydalanuvchining haqiqiy kataloglariga tegmasdan fayl yozishni tekshiradi.

```go
package main

import (
	"os"
	"path/filepath"
	"testing"
)

func TestWriteMessage(t *testing.T) {
	dir := t.TempDir()
	path := filepath.Join(dir, "message.txt")

	if err := os.WriteFile(path, []byte("salom"), 0o600); err != nil {
		t.Fatalf("fayl yozilmadi: %v", err)
	}

	data, err := os.ReadFile(path)
	if err != nil {
		t.Fatalf("fayl o‘qilmadi: %v", err)
	}

	if string(data) != "salom" {
		t.Errorf("fayl = %q; %q kutilgan", data, "salom")
	}
}
```

Birinchi qadam:

```go
dir := t.TempDir()
```

Go test uchun vaqtinchalik katalog yaratadi.

Keyingi qadam:

```go
path := filepath.Join(dir, "message.txt")
```

shu katalog ichidagi `message.txt` fayliga yo‘l hosil qiladi.

So‘ng fayl yoziladi:

```go
os.WriteFile(path, []byte("salom"), 0o600)
```

`[]byte("salom")` matnni byte slice ko‘rinishiga aylantiradi.

Permission:

```text
0o600
```

egaga o‘qish va yozish huquqini beradi.

Agar fayl yozilmasa:

```go
t.Fatalf("fayl yozilmadi: %v", err)
```

testni davom ettirishning ma’nosi yo‘q.

Keyin fayl qayta o‘qiladi:

```go
data, err := os.ReadFile(path)
```

Agar bu ham muvaffaqiyatli bo‘lsa, o‘qilgan byte slice matnga aylantiriladi:

```go
string(data)
```

va kutilgan qiymat bilan solishtiriladi:

```go
if string(data) != "salom" {
	...
}
```

Bu test foydalanuvchining masalan:

```text
/home/user/message.txt
```

kabi haqiqiy fayliga tayanmaydi.

`t.TempDir()` testlarni bir-biridan va tashqi muhitdan yaxshiroq ajratishga yordam beradi. Test tugagach vaqtinchalik katalog ham avtomatik tozalanadi.

### 8. Sentinel xatoni `errors.Is()` bilan tekshirish

Go’da ayrim xatolar paket darajasida oldindan yaratiladi:

```go
var ErrNotFound = errors.New("topilmadi")
```

Bunday xatolar ko‘pincha **sentinel error** deb ataladi.

Quyidagi misolda funksiya `ErrNotFound`ni qo‘shimcha kontekst bilan o‘raydi:

```go
package main

import (
	"errors"
	"fmt"
	"testing"
)

var ErrNotFound = errors.New("topilmadi")

func find(id int) error {
	if id != 10 {
		return fmt.Errorf("%d identifikator: %w", id, ErrNotFound)
	}

	return nil
}

func TestFindNotFound(t *testing.T) {
	err := find(25)

	if !errors.Is(err, ErrNotFound) {
		t.Fatalf("xato = %v; ErrNotFound kutilgan", err)
	}
}
```

`find()` qoidasi sodda:

```text
id == 10 → topildi, nil
id != 10 → ErrNotFound
```

Lekin xato shunchaki:

```go
return ErrNotFound
```

ko‘rinishida qaytarilmagan.

U `%w` orqali o‘ralgan:

```go
fmt.Errorf("%d identifikator: %w", id, ErrNotFound)
```

Masalan, `id = 25` bo‘lsa, xato matni taxminan:

```text
25 identifikator: topilmadi
```

ko‘rinishida bo‘ladi.

Lekin xatoning ichki zanjirida `ErrNotFound` ham saqlanib qoladi.

Shuning uchun testda xato matnini solishtirish o‘rniga:

```go
errors.Is(err, ErrNotFound)
```

ishlatiladi.

Bu tekshiruv:

> `err`ning o‘zi yoki uning o‘ralgan xatolar zanjirida `ErrNotFound` bormi?

degan ma’noni beradi.

Oddiy:

```go
err == ErrNotFound
```

bu misolda ishlamaydi, chunki `err` tashqi `fmt.Errorf()` tomonidan yaratilgan boshqa error qiymati.

Xato matnini:

```go
err.Error() == "25 identifikator: topilmadi"
```

ko‘rinishida tekshirish ham odatda mo‘rt yondashuv. Xabarning matni o‘zgarsa, semantik sabab o‘zgarmagan bo‘lsa ham test yiqiladi.

Bu misolning asosiy qoidasi — o‘ralgan sentinel errorni tekshirish uchun `errors.Is()`dan foydalanish.

### 9. Dokumentatsiya misolini test bilan tekshirish

Go’da `Example` funksiyalar bir vaqtning o‘zida ham dokumentatsiya misoli, ham avtomatik tekshiriladigan test vazifasini bajarishi mumkin.

```go
package main

import "fmt"

func greeting(name string) string {
	return "Salom, " + name + "!"
}

func Example_greeting() {
	fmt.Println(greeting("Ali"))

	// Output: Salom, Ali!
}
```

`greeting()` oddiy satr qaytaradi:

```go
func greeting(name string) string {
	return "Salom, " + name + "!"
}
```

Masalan:

```text
greeting("Ali")
```

natijasi:

```text
Salom, Ali!
```

bo‘ladi.

`Example_greeting()` ichida natija stdout’ga chiqariladi:

```go
fmt.Println(greeting("Ali"))
```

Keyin maxsus izoh yozilgan:

```go
// Output: Salom, Ali!
```

`go test` example funksiyani bajarganda haqiqiy stdout natijasini shu `Output` qiymati bilan solishtiradi.

Bu jarayonni soddalashtirib quyidagicha ko‘rish mumkin:

```text
greeting("Ali")
        ↓
"Salom, Ali!"
        ↓
fmt.Println(...)
        ↓
stdout: Salom, Ali!
        ↓
 // Output: Salom, Ali!
        ↓
solishtirish
```

Agar haqiqiy natija va `Output` mos kelsa, example muvaffaqiyatli o‘tadi.

Masalan, funksiya keyinchalik:

```go
return "Assalomu alaykum, " + name + "!"
```

deb o‘zgartirilsa, lekin `// Output:` yangilanmasa, `go test` example’ni muvaffaqiyatsiz deb belgilaydi.

Shuning uchun `Example` faqat o‘quvchi uchun ko‘rsatiladigan kod emas. U dokumentatsiyadagi misolning amaldagi kod bilan mosligini ham avtomatik tekshirishi mumkin.

Bu misoldagi `Example_greeting` nomi `greeting` funksiyasiga bog‘langan example’ni bildiradi. `go test` uni oddiy testlar bilan birga bajarishi mumkin.

Asosiy qoida — `// Output:` mavjud bo‘lgan `Example` funksiyalar dokumentatsiya va avtomatik test vazifasini birgalikda bajaradi.
