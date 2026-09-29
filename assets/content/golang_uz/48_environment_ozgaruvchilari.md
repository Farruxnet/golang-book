# Muhit o‘zgaruvchilari bilan ishlash

Muhit o‘zgaruvchisi (`environment variable`) — operatsion tizim dastur jarayoniga nom va qiymat ko‘rinishida uzatadigan konfiguratsiya.

Masalan, dastur qaysi portda ishlashi, `development` yoki `production` rejimida ishga tushishi, database yoki boshqa tashqi xizmat qayerda joylashgani muhit o‘zgaruvchilari orqali berilishi mumkin.

Buning asosiy foydasi — konfiguratsiyani koddan ajratish.

Masalan, portni kod ichida doimiy yozish mumkin:

```go
port := "8080"
```

Lekin bunda boshqa muhitga o‘tish uchun kodni o‘zgartirish kerak bo‘ladi. Muhit o‘zgaruvchisi ishlatilsa, kod o‘zgarmaydi. Faqat dasturni ishga tushirayotgan muhitdagi qiymat almashtiriladi.

Shu sabab muhit o‘zgaruvchilari server dasturlari, CLI dasturlar, containerlar va deployment konfiguratsiyalarida ko‘p ishlatiladi.

## `os` paketi

Go muhit o‘zgaruvchilari bilan standart `os` paketi orqali ishlaydi.

Muhit o‘zgaruvchisini o‘qish uchun asosan ikkita funksiya ishlatiladi:

- `os.Getenv`;
- `os.LookupEnv`.

`os.Getenv` faqat o‘zgaruvchining qiymatini qaytaradi.

`os.LookupEnv` esa ikkita ma’lumot beradi:

1. o‘zgaruvchining qiymati;
2. o‘zgaruvchi umuman mavjud yoki mavjud emasligi.

Masalan:

```go
package main

import (
	"fmt"
	"os"
)

func main() {
	port, ok := os.LookupEnv("APP_PORT")
	if !ok || port == "" {
		port = "8080"
	}

	fmt.Println("Server porti:", port)
}
```

Bu kodni bosqichma-bosqich ko‘ramiz.

```go
port, ok := os.LookupEnv("APP_PORT")
```

`LookupEnv` ikkita qiymat qaytaradi.

`port` ichiga `APP_PORT` qiymati tushadi.

`ok` esa o‘zgaruvchi mavjudligini bildiradi:

```text
ok = true
```

bo‘lsa, `APP_PORT` muhitda mavjud.

```text
ok = false
```

bo‘lsa, bunday muhit o‘zgaruvchisi umuman berilmagan.

Keyingi tekshiruv:

```go
if !ok || port == "" {
	port = "8080"
}
```

ikki holatni tekshiradi:

- `APP_PORT` umuman mavjud emas;
- `APP_PORT` mavjud, lekin qiymati bo‘sh satr.

Har ikki holatda dastur `8080` standart qiymatidan foydalanadi.

PowerShell orqali `APP_PORT` qiymatini berib, keyin dasturni ishga tushirish mumkin:

```powershell
$env:APP_PORT = "9000"
go run main.go
```

Natija:

```text
Server porti: 9000
```

Bu safar `LookupEnv` quyidagiga yaqin natija qaytaradi:

```text
port = "9000"
ok   = true
```

Shuning uchun `8080` standart qiymati ishlatilmaydi.

Agar o‘zgaruvchi berilmasa yoki uning qiymati bo‘sh bo‘lsa, dastur:

```text
Server porti: 8080
```

natijasini chiqaradi.

Bu yerda `LookupEnv` va `Getenv` orasidagi farq muhim.

Masalan, muhitda quyidagi qiymat mavjud bo‘lishi mumkin:

```text
APP_MODE=
```

Bu holatda `APP_MODE` mavjud, lekin uning qiymati bo‘sh satr.

`os.Getenv("APP_MODE")` faqat:

```text
""
```

qaytaradi.

Lekin o‘zgaruvchi umuman mavjud bo‘lmasa ham `Getenv` aynan shu bo‘sh satrni qaytaradi.

Shuning uchun “o‘zgaruvchi yo‘q” va “o‘zgaruvchi bor, lekin qiymati bo‘sh” holatlarini ajratish kerak bo‘lsa, `os.LookupEnv` ishlatiladi.

## Qiymatni tekshirish va turga o‘tkazish

Muhit o‘zgaruvchilarining qiymatlari dasturga matn, ya’ni `string` ko‘rinishida keladi.

Masalan:

```text
APP_PORT=8080
```

yozilgan bo‘lsa, Go bu qiymatni avtomatik ravishda `int`ga aylantirmaydi.

Dastur oladigan qiymat:

```go
"8080"
```

ko‘rinishidagi `string` bo‘ladi.

Agar dasturga son kerak bo‘lsa, qiymatni kerakli turga ochiq ravishda konvertatsiya qilish lozim.

Bundan tashqari, faqat konvertatsiya qilish yetarli emas. Qiymat mantiqan ruxsat etilgan oraliqda ekanini ham tekshirish kerak.

Masalan, TCP yoki HTTP server porti uchun `1` dan `65535` gacha bo‘lgan son kerak.

```go
package main

import (
	"fmt"
	"os"
	"strconv"
)

func main() {
	raw := os.Getenv("APP_PORT")
	if raw == "" {
		raw = "8080"
	}

	port, err := strconv.Atoi(raw)
	if err != nil || port < 1 || port > 65535 {
		fmt.Fprintln(os.Stderr, "APP_PORT 1 dan 65535 gacha butun son bo‘lishi kerak")
		os.Exit(1)
	}

	fmt.Printf("Server :%d manzilida ishga tushadi\n", port)
}
```

Bu kodda avval `APP_PORT` matn sifatida olinadi:

```go
raw := os.Getenv("APP_PORT")
```

Agar qiymat bo‘sh bo‘lsa:

```go
if raw == "" {
	raw = "8080"
}
```

standart qiymat ishlatiladi.

Hali bu qiymat `string`:

```text
"8080"
```

Keyin:

```go
port, err := strconv.Atoi(raw)
```

orqali matn `int` turiga o‘tkaziladi.

Masalan:

```text
"8080" -> 8080
```

Agar foydalanuvchi:

```text
APP_PORT=abc
```

bergan bo‘lsa, `strconv.Atoi` bu matnni butun songa aylantira olmaydi va `err` qaytaradi.

Shuning uchun:

```go
if err != nil || port < 1 || port > 65535 {
```

tekshiruvi bir nechta yaroqsiz holatlarni ushlaydi.

Masalan:

```text
APP_PORT=abc
```

son emas.

```text
APP_PORT=0
```

sintaktik jihatdan son, lekin biz belgilagan port oralig‘iga kirmaydi.

```text
APP_PORT=70000
```

ham butun son, lekin `65535` dan katta.

Shu sabab bu qiymatlar server konfiguratsiyasiga o‘tib ketmaydi.

Xato topilganda:

```go
fmt.Fprintln(os.Stderr, "APP_PORT 1 dan 65535 gacha butun son bo‘lishi kerak")
```

xabar standart xato oqimiga, ya’ni `stderr`ga yoziladi.

Keyin:

```go
os.Exit(1)
```

dastur muvaffaqiyatsiz holatda tugatilganini operatsion tizimga bildiradi.

Bu yerda muhim qoida bor: muhit o‘zgaruvchisi tashqaridan kelayotgan ma’lumot hisoblanadi.

Shuning uchun uning qiymati to‘g‘ri deb taxmin qilmaslik kerak. Uni ishlatishdan oldin:

- kerakli turga o‘tkazish;
- konvertatsiya xatosini tekshirish;
- ruxsat etilgan oraliqni tekshirish

yaxshi amaliyot hisoblanadi.

Mantiqiy qiymatlar uchun ham shu qoida ishlaydi.

Masalan:

```text
DEBUG=true
```

qiymatini `bool`ga aylantirish uchun `strconv.ParseBool` ishlatilishi mumkin.

Haqiqiy loyihalarda muhit o‘zgaruvchilarini kodning turli joylarida qayta-qayta o‘qish o‘rniga, konfiguratsiyani dastur ishga tushayotgan paytda bir marta o‘qish qulay.

Masalan, tekshirilgan qiymatlarni alohida `Config` structida saqlash mumkin:

```go
type Config struct {
	Port int
}
```

Shunda dasturning qolgan qismi xom `string` qiymatlar bilan emas, allaqachon tekshirilgan konfiguratsiya bilan ishlaydi.

Bu xato bilan ishlashni ham soddalashtiradi. Konfiguratsiyada muammo bo‘lsa, dastur boshida darhol aniqlanadi.

## Qiymat yozish va o‘chirish

Go dasturi muhit o‘zgaruvchisini faqat o‘qishi shart emas.

`os.Setenv` orqali qiymat o‘rnatish mumkin.

`os.Unsetenv` esa mavjud o‘zgaruvchini olib tashlaydi.

```go
package main

import (
	"fmt"
	"os"
)

func main() {
	if err := os.Setenv("APP_MODE", "development"); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	fmt.Println(os.Getenv("APP_MODE"))

	if err := os.Unsetenv("APP_MODE"); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}
```

Avval:

```go
os.Setenv("APP_MODE", "development")
```

joriy jarayon muhitida `APP_MODE` qiymatini yaratadi yoki mavjud qiymatni almashtiradi.

Shundan keyin:

```go
os.Getenv("APP_MODE")
```

quyidagi qiymatni qaytaradi:

```text
development
```

Keyin:

```go
os.Unsetenv("APP_MODE")
```

joriy jarayon muhitidan `APP_MODE`ni olib tashlaydi.

`Setenv` va `Unsetenv` xato qaytarishi mumkin. Shu sabab misolda `err` tekshirilmoqda.

Bu funksiyalar haqida muhim bir jihat bor.

Ular terminalning yoki operatsion tizimning doimiy konfiguratsiyasini o‘zgartirmaydi.

Masalan, dastur ichida:

```go
os.Setenv("APP_MODE", "development")
```

chaqirilgani PowerShell yoki boshqa terminal oynasidagi doimiy sozlamani o‘zgartirmaydi.

Qiymat asosan joriy jarayon muhitida mavjud bo‘ladi.

Agar shu Go dasturi keyinchalik boshqa child process, ya’ni ichki jarayon ishga tushirsa, o‘sha jarayon ham odatda joriy environment asosida qiymatni meros qilib olishi mumkin.

Demak, `os.Setenv` operatsion tizimdagi global va doimiy environment sozlamasini tahrirlash vositasi emas.

## `.env` fayli nima?

`.env` — muhit konfiguratsiyasini `KEY=value` ko‘rinishida yozish uchun keng qo‘llanadigan oddiy matn fayli.

Masalan:

```text
APP_PORT=8080
APP_MODE=development
```

Bu faylda:

```text
APP_PORT
```

va:

```text
APP_MODE
```

kalit nomlari hisoblanadi.

Ularning o‘ng tomonidagi qiymatlar esa konfiguratsiya qiymatlaridir.

Bu yerda muhim jihat shuki, `.env` Go tilining maxsus fayl formati emas.

U operatsion tizimning ham universal avtomatik environment formati emas.

Bu shunchaki keng tarqalgan kelishuv.

Go standart kutubxonasi `.env` faylini ko‘rib:

```text
APP_PORT=8080
```

qiymatini avtomatik ravishda `os.Getenv("APP_PORT")` orqali mavjud qilib qo‘ymaydi.

Qiymatlarni dastur environmentiga boshqa usul orqali yuklash kerak.

Masalan:

- shell vositalari orqali environmentga eksport qilish;
- maxsus tashqi paket yordamida `.env` faylini o‘qish.

Shuning uchun quyidagi fayl loyihada mavjud bo‘lishining o‘zi yetarli emas:

```text
APP_PORT=8080
APP_MODE=development
```

Agar u environmentga yuklanmagan bo‘lsa:

```go
os.Getenv("APP_PORT")
```

bu qiymatni ko‘rmaydi.

**Diqqat**

Parol, token va API kalitlari kabi maxfiy qiymatlarni repozitoriyga commit qilmang.

Agar lokal development uchun `.env` ishlatilsa, uni `.gitignore` fayliga kiritish odatiy amaliyot hisoblanadi.

Shu bilan birga loyiha qaysi environment nomlarini kutishini hujjatlashtirish foydali. Buning uchun maxfiy qiymatlarsiz `.env.example` fayli yaratish mumkin.

Masalan:

```text
APP_PORT=8080
APP_MODE=development
API_TOKEN=
```

Bu fayl kerakli o‘zgaruvchi nomlarini ko‘rsatadi, lekin haqiqiy maxfiy qiymatlarni saqlamaydi.

Ishlab chiqarish muhitida maxfiy ma’lumotlarni oddiy `.env` faylida saqlash o‘rniga maxfiy ma’lumotlar boshqaruvchisi (`secret manager`) ishlatish afzal.

## Keng tarqalgan xatolar

Muhit o‘zgaruvchilari bilan ishlash oddiy ko‘rinsa ham, bir nechta nozik holatlar mavjud.

- `os.Getenv` qaytargan bo‘sh satrni doim “o‘zgaruvchi mavjud emas” deb qabul qilish.

  `os.Getenv` o‘zgaruvchi umuman mavjud bo‘lmaganda ham, mavjud bo‘lib qiymati bo‘sh bo‘lganda ham `""` qaytarishi mumkin.

  Agar bu ikki holat orasidagi farq muhim bo‘lsa, `os.LookupEnv` ishlating:

  ```go
  value, ok := os.LookupEnv("APP_MODE")
  ```

  Bu yerda `ok` o‘zgaruvchining mavjudligini alohida bildiradi.

- Son va mantiqiy qiymatlarni tekshirmasdan ishlatish.

  Environmentdagi barcha qiymatlar matn sifatida keladi.

  Masalan:

  ```text
  APP_PORT=abc
  ```

  ham environment nuqtai nazaridan oddiy matn qiymati.

  Uni son sifatida ishlatmoqchi bo‘lsangiz, `strconv.Atoi` xatosini tekshirish kerak.

  Xuddi shunday, `bool` qiymat uchun `strconv.ParseBool` qaytargan xatoni ham e’tiborsiz qoldirmaslik kerak.

- Maxfiy qiymatni logga chiqarish.

  Masalan, konfiguratsiyada `API_TOKEN` noto‘g‘ri bo‘lsa, xato xabariga tokenning o‘zini yozish xavfli:

  ```text
  invalid API_TOKEN: abc123-secret-token
  ```

  Buning o‘rniga o‘zgaruvchi nomini ko‘rsatish odatda yetarli:

  ```text
  API_TOKEN konfiguratsiyasi noto‘g‘ri
  ```

  Loglar ko‘pincha alohida monitoring tizimlariga yuboriladi. Shu sabab maxfiy ma’lumotni logga chiqarish uning tarqalishiga olib kelishi mumkin.

- Dastur ishlayotgan paytda tashqi environment qiymati o‘zgarsa, dastur konfiguratsiyasi avtomatik yangilanadi deb o‘ylash.

  Jarayon odatda o‘z environmenti bilan ishga tushadi.

  Masalan, shell ichida keyinchalik:

  ```powershell
  $env:APP_PORT = "9001"
  ```

  deb yozish allaqachon ishlayotgan boshqa processning environmentini avtomatik o‘zgartirmaydi.

  Shu sabab ko‘p dasturlar konfiguratsiyani startup vaqtida bir marta o‘qiydi va keyin tekshirilgan qiymatlarni xotirada saqlaydi.

  Agar dasturga runtime vaqtida konfiguratsiyani yangilash kerak bo‘lsa, buning uchun alohida mexanizm kerak bo‘ladi. Masalan, konfiguratsiya faylini qayta o‘qish, signal qabul qilish yoki tashqi konfiguratsiya xizmatidan foydalanish mumkin.
