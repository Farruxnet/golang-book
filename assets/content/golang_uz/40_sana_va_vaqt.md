# Go’da sana va vaqt bilan ishlash

Go’da sana, vaqt va vaqt oralig‘i bilan ishlash uchun standart kutubxonadagi `time` paketi ishlatiladi.

Backend dasturlarda vaqt bilan ishlash juda ko‘p joyda uchraydi. Masalan:

* database yozuvi qachon yaratilganini saqlash;
* tokenning amal qilish muddati tugaganini tekshirish;
* HTTP yoki database operatsiyasiga timeout qo‘yish;
* foydalanuvchiga vaqtni uning vaqt zonasida ko‘rsatish;
* ikki hodisa orasida qancha vaqt o‘tganini hisoblash;
* ma’lum vaqtdan keyin biror ishni bajarish.

Vaqt bilan ishlashda uchta asosiy tushunchani bir-biridan ajratish muhim:

* `time.Time` — vaqt chizig‘idagi aniq bir nuqta;
* `time.Duration` — qancha vaqt davom etganini bildiradigan vaqt oralig‘i;
* `time.Location` — vaqt nuqtasini qaysi vaqt zonasi qoidalari asosida ko‘rsatish kerakligini belgilaydi.

Masalan, bitta uchrashuv Toshkentda `14:00` bo‘lishi mumkin. Xuddi shu uchrashuv Londonda boshqa mahalliy soatda ko‘rinadi.

Bu ikki xil uchrashuv degani emas. Vaqt chizig‘idagi nuqta bitta. Faqat uni ko‘rsatishda ishlatilayotgan `Location` boshqacha.

## Joriy vaqtni olish

Joriy vaqtni olish uchun `time.Now()` ishlatiladi.

Bu funksiya operatsion tizimdan joriy vaqtni oladi va `time.Time` qiymatini qaytaradi:

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	now := time.Now()

	fmt.Println("Mahalliy vaqt:", now)
	fmt.Println("UTC vaqti:", now.UTC())
}
```

Natija dastur qachon va qaysi muhitda ishga tushirilganiga bog‘liq. Masalan:

```text
Mahalliy vaqt: 2026-03-15 14:30:20.123456789 +0500 +05 m=+0.000031201
UTC vaqti: 2026-03-15 09:30:20.123456789 +0000 UTC
```

Bu yerda `now` serverning mahalliy vaqt zonasidagi vaqtni saqlaydi.

`now.UTC()` esa aynan shu vaqt nuqtasini UTC ko‘rinishida qaytaradi.

Muhim jihat shuki, `time.Now()` har doim UTC qaytarmaydi. U tizimning mahalliy `Location`idan foydalanadi.

Masalan, server UTCga sozlangan bo‘lsa:

```go
time.Now()
```

natijasining o‘zi ham UTCda bo‘lishi mumkin.

Server Toshkent vaqt zonasida ishlayotgan bo‘lsa, natija `+05:00` atrofidagi offset bilan chiqishi mumkin.

Shuning uchun kodda server qaysi vaqt zonasida ishlayotganini taxmin qilish yaxshi yondashuv emas. UTC kerak bo‘lsa, buni ochiq yozish ma’qul:

```go
now := time.Now().UTC()
```

Yuqoridagi standart `time.Time` matn ko‘rinishida bir nechta qism bor:

| Qism                 | Ma’nosi                                                            |
| -------------------- | ------------------------------------------------------------------ |
| `2026-03-15`         | yil, oy va kun                                                     |
| `14:30:20.123456789` | soat, daqiqa, soniya va soniyaning kasr qismi                      |
| `+0500`              | UTCdan siljish, ya’ni offset                                       |
| `+05`                | vaqt zonasi nomi; tizimga qarab boshqa nom bo‘lishi mumkin         |
| `m=+...`             | `time.Time` ichida bo‘lishi mumkin bo‘lgan monotonic clock o‘qishi |

Oxirgi `m=+...` qismi birinchi qarashda g‘alati ko‘rinishi mumkin. U oddiy sana yoki vaqt zonasining bir qismi emas.

### Monotonic vaqt nima?

Vaqtni o‘lchashda ikki xil tushunchani ajratish foydali:

* wall clock;
* monotonic clock.

**Wall clock** — foydalanuvchi ko‘radigan oddiy sana va vaqt.

Masalan:

```text
2026-03-15 14:30:20
```

Bu vaqt operatsion tizim soati bilan bog‘liq.

Tizim vaqti esa o‘zgarishi mumkin. Masalan:

* administrator soatni qo‘lda o‘zgartirishi mumkin;
* NTP vaqtni tuzatishi mumkin;
* tizim soati oldinga yoki orqaga siljishi mumkin.

Agar ikki hodisa orasidagi davomiylikni faqat wall clock orqali hisoblasak, bunday o‘zgarishlar natijaga ta’sir qilishi mumkin.

**Monotonic clock** esa vaqt oralig‘ini o‘lchashga mo‘ljallangan.

Uning asosiy vazifasi:

> “Soat necha bo‘ldi?” degan savolga javob berish emas, “qancha vaqt o‘tdi?” degan savolga javob berish.

`time.Now()` qaytargan `time.Time` qiymati monotonic o‘qishni ham saqlashi mumkin.

Masalan:

```go
start := time.Now()

// Biror ish bajariladi.

elapsed := time.Since(start)
```

Agar `start` monotonic ma’lumotga ega bo‘lsa, `time.Since` operatsion tizimning wall clock vaqti tuzatilishidan kamroq ta’sirlanadi.

`Sub`, `Before`, `After` kabi amallar ham ikkala operandda monotonic ma’lumot mavjud bo‘lsa, undan foydalanishi mumkin.

Bu yerda bir nozik jihat bor.

`m=+...` qiymatini:

> “Dastur ishga tushganidan beri o‘tgan vaqt”

deb tushunish to‘g‘ri emas.

Bu runtime ishlatadigan ichki monotonic ko‘rsatkichdir. U doimiy identifikator emas va uni databasega saqlash yoki boshqa servisga yuborish uchun ishlatish kerak emas.

Formatlash va serializatsiya jarayonida monotonic qism odatda olib tashlanadi.

Masalan:

```go
now.Format(time.RFC3339)
```

natijasida `m=+...` yozilmaydi.

Xuddi shuningdek, `time.Time` JSONga aylantirilganda ham monotonic o‘qish boshqa tizimga uzatilmaydi.

## Sana va vaqt qismlarini olish

`time.Time` qiymatidan yil, oy, kun, soat va boshqa qismlarni alohida olish mumkin.

Buning uchun `time.Time` metodlari mavjud:

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	moment := time.Date(2024, time.February, 29, 16, 45, 30, 0, time.UTC)

	fmt.Println("Yil:", moment.Year())
	fmt.Println("Oy:", moment.Month())
	fmt.Println("Kun:", moment.Day())
	fmt.Println("Hafta kuni:", moment.Weekday())
	fmt.Println("Soat:", moment.Hour())
	fmt.Println("Daqiqa:", moment.Minute())
	fmt.Println("Soniya:", moment.Second())
}
```

Natija:

```text
Yil: 2024
Oy: February
Kun: 29
Hafta kuni: Thursday
Soat: 16
Daqiqa: 45
Soniya: 30
```

Bu misolda `time.Now()` ishlatilmagan.

Vaqt oldindan aniq berilgan:

```go
time.Date(2024, time.February, 29, 16, 45, 30, 0, time.UTC)
```

Shu sabab natija har safar bir xil chiqadi.

Metodlarning vazifasi:

```go
moment.Year()
```

yilni qaytaradi.

```go
moment.Month()
```

oyni `time.Month` turida qaytaradi.

```go
moment.Day()
```

oy ichidagi kun raqamini beradi.

```go
moment.Weekday()
```

hafta kunini qaytaradi.

```go
moment.Hour()
moment.Minute()
moment.Second()
```

esa vaqtning mos qismlarini beradi.

`Month()` oddiy `int` emas, `time.Month` turini qaytaradi.

`fmt.Println` bilan chiqarilganda u:

```text
February
```

kabi inglizcha nom ko‘rinishida chiqishi mumkin.

Xuddi shuningdek, `Weekday()`:

```text
Thursday
```

kabi inglizcha qiymat beradi.

Agar foydalanuvchiga:

```text
Fevral
Payshanba
```

kabi o‘zbekcha nomlar ko‘rsatish kerak bo‘lsa, buni ilova darajasida alohida mahalliylashtirish kerak.

`time` paketi oy va hafta kunlarini avtomatik o‘zbek tiliga tarjima qilib bermaydi.

## Vaqtni formatlash

`time.Time` qiymatini foydalanuvchiga yoki boshqa tizimga satr ko‘rinishida yuborish kerak bo‘lishi mumkin.

Buning uchun `Format` metodi ishlatiladi.

Go’dagi vaqt formatlash tizimi boshqa ko‘p dasturlash tillaridan farq qiladi.

Masalan, boshqa tillarda quyidagi ko‘rinish uchrashi mumkin:

```text
YYYY-MM-DD
```

Go’da esa bunday format belgilari ishlatilmaydi.

Buning o‘rniga maxsus **reference time**, ya’ni namuna vaqt ishlatiladi:

```text
Mon Jan 2 15:04:05 MST 2006
```

Go layoutini yozayotganda kerakli format shu namuna vaqtning qismlari bilan ifodalanadi.

Esda saqlash uchun quyidagi ketma-ketlik ham ishlatiladi:

```text
01/02 03:04:05PM '06 -0700
```

Bu raqamlar tasodifiy tanlanmagan.

Ular mos ravishda:

```text
01 → oy
02 → kun
03 → 12 soatlik soat
04 → daqiqa
05 → soniya
06 → yilning oxirgi ikki raqami
-0700 → vaqt zonasi offseti
```

kabi ishlatiladi.

Misol:

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	moment := time.Date(2024, time.August, 9, 16, 7, 5, 123_000_000, time.UTC)

	fmt.Println("Sana:", moment.Format("02-01-2006"))
	fmt.Println("Vaqt:", moment.Format("15:04:05"))
	fmt.Println("API:", moment.Format(time.RFC3339Nano))
}
```

Natija:

```text
Sana: 09-08-2024
Vaqt: 16:07:05
API: 2024-08-09T16:07:05.123Z
```

Birinchi format:

```go
moment.Format("02-01-2006")
```

quyidagi tartibni bildiradi:

```text
kun-oy-yil
```

Shuning uchun:

```text
09-08-2024
```

hosil bo‘ladi.

Ikkinchi format:

```go
moment.Format("15:04:05")
```

24 soatlik:

```text
soat:daqiqa:soniya
```

ko‘rinishini beradi.

Natija:

```text
16:07:05
```

API va servislar orasida vaqt yuborishda odatda standart formatlardan foydalanish ma’qul.

Masalan:

```go
time.RFC3339
```

yoki nanosekund aniqligini saqlash kerak bo‘lsa:

```go
time.RFC3339Nano
```

Bu yondashuv har bir loyihada o‘zboshimchalik bilan yangi sana formati yaratishdan ko‘ra xavfsizroq.

### Asosiy layout qismlari

Go layoutida ko‘p ishlatiladigan qismlar:

| Layout qismi   | Natija ma’nosi                            |
| -------------- | ----------------------------------------- |
| `2006`         | to‘rt xonali yil                          |
| `06`           | ikki xonali yil                           |
| `01`           | ikki xonali oy                            |
| `1`            | bosh nol qo‘yilmagan oy                   |
| `Jan`          | qisqa oy nomi                             |
| `January`      | to‘liq oy nomi                            |
| `02`           | ikki xonali kun                           |
| `2`            | bosh nol qo‘yilmagan kun                  |
| `Mon`          | qisqa hafta kuni                          |
| `Monday`       | to‘liq hafta kuni                         |
| `15`           | 24 soatlik soat                           |
| `03`           | 12 soatlik soat                           |
| `PM` yoki `pm` | 12 soatlik davr belgisi                   |
| `04`           | daqiqa                                    |
| `05`           | soniya                                    |
| `.000`         | millisekund, doim uch xona                |
| `.000000`      | mikrosekund, doim olti xona               |
| `.000000000`   | nanosekund, doim to‘qqiz xona             |
| `MST`          | zona nomi                                 |
| `-0700`        | `+0500` ko‘rinishidagi offset             |
| `-07:00`       | `+05:00` ko‘rinishidagi offset            |
| `Z07:00`       | UTC uchun `Z`, boshqa zonada sonli offset |

Bu jadvalni yodlash shart emas. Lekin `2006-01-02` va `15:04:05` kabi asosiy qismlarni tanib olish juda foydali.

Ayniqsa, boshqa tillardan Go’ga kelganda quyidagi xato juda ko‘p uchraydi:

```go
// Noto‘g‘ri: "YYYY" Go layout belgisi emas.
fmt.Println(moment.Format("YYYY-MM-DD"))
```

Bu kod kompilyatsiyadan o‘tadi.

Muammo shundaki, Go `YYYY`, `MM` yoki `DD`ni maxsus format belgisi sifatida tanimaydi.

Ularni oddiy matn deb qabul qiladi.

Shuning uchun bunday xato compile time’da aniqlanmasligi mumkin.

Masalan, yil uchun:

```text
2006
```

oy uchun:

```text
01
```

kun uchun:

```text
02
```

ishlatish kerak:

```go
moment.Format("2006-01-02")
```

Bu yerda Go layoutining reference time modelini tushunish muhim. Aks holda kod ishlayotgandek ko‘rinsa ham, noto‘g‘ri satr hosil qilishi mumkin.

## Satrni vaqtga aylantirish

Ba’zan vaqt `time.Time` ko‘rinishida emas, satr sifatida keladi.

Masalan, HTTP request:

```text
2024-08-09
```

qiymatini yuborishi mumkin.

Bunday satrni `time.Time`ga aylantirish uchun `time.Parse` ishlatiladi:

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	input := "2024-08-09"
	moment, err := time.Parse("2006-01-02", input)
	if err != nil {
		fmt.Println("Sana noto‘g‘ri:", err)
		return
	}

	fmt.Println(moment.Format(time.RFC3339))
}
```

Natija:

```text
2024-08-09T00:00:00Z
```

`time.Parse` ikkita muhim ma’lumot oladi:

```go
time.Parse(layout, value)
```

Birinchisi — satr qanday formatda ekanini bildiradigan layout.

Ikkinchisi — parse qilinadigan qiymat.

Bu misolda:

```go
"2006-01-02"
```

quyidagi satrga mos keladi:

```text
2024-08-09
```

Satrdagi vaqt qismi ko‘rsatilmagan.

Shu sabab:

```text
00:00:00
```

ishlatiladi.

Layout ichida vaqt zonasi ham yo‘q.

`time.Parse` bunday holatda qiymatni UTC bilan yaratadi.

Shu sabab natija:

```text
2024-08-09T00:00:00Z
```

bo‘ladi.

Satr layoutga mos kelishi kerak.

Masalan:

```text
2024-02-30
```

calendar bo‘yicha mavjud bo‘lmagan sana.

Fevralning 30-kuni yo‘q.

Shuning uchun `time.Parse` xato qaytaradi.

Bu ayniqsa tashqi ma’lumot bilan ishlaganda muhim.

Quyidagi kabi yozish xavfli:

```go
moment, _ := time.Parse("2006-01-02", input)
```

Bu yerda xato butunlay e’tiborsiz qoldirilmoqda.

Agar input noto‘g‘ri bo‘lsa, keyingi biznes logika noto‘g‘ri vaqt bilan ishlashi mumkin.

Shuning uchun tashqaridan kelgan vaqtni parse qilganda `err`ni tekshirish kerak.

### Ma’lum zonadagi mahalliy vaqtni parse qilish

Quyidagi qiymatni tasavvur qilamiz:

```text
2024-08-09 14:30
```

Bu satrda sana va vaqt bor.

Lekin vaqt zonasi yo‘q.

Shuning uchun muhim savol paydo bo‘ladi:

> `14:30` qaysi hududdagi mahalliy vaqt?

Agar bu Toshkent vaqti bo‘lsa, ilova buni bilishi kerak.

Bunday vaziyatda `time.ParseInLocation` ishlatiladi:

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	location, err := time.LoadLocation("Asia/Tashkent")
	if err != nil {
		fmt.Println("Vaqt zonasi yuklanmadi:", err)
		return
	}

	input := "2024-08-09 14:30"
	moment, err := time.ParseInLocation("2006-01-02 15:04", input, location)
	if err != nil {
		fmt.Println("Vaqt noto‘g‘ri:", err)
		return
	}

	fmt.Println("Toshkent:", moment.Format(time.RFC3339))
	fmt.Println("UTC:", moment.UTC().Format(time.RFC3339))
}
```

Natija:

```text
Toshkent: 2024-08-09T14:30:00+05:00
UTC: 2024-08-09T09:30:00Z
```

Jarayonni bosqichma-bosqich ko‘ramiz.

Avval Toshkent locationi yuklanadi:

```go
location, err := time.LoadLocation("Asia/Tashkent")
```

`Asia/Tashkent` — IANA time zone bazasidagi nom.

Keyin:

```go
time.ParseInLocation("2006-01-02 15:04", input, location)
```

chaqiriladi.

`input` ichida timezone yozilmagan.

Shuning uchun Go bu vaqtni:

```text
Asia/Tashkent
```

qoidalari asosida izohlaydi.

Natija:

```text
2024-08-09T14:30:00+05:00
```

bo‘ladi.

Keyin:

```go
moment.UTC()
```

chaqirilmoqda.

Natija:

```text
2024-08-09T09:30:00Z
```

Bu yerda vaqt nuqtasi o‘zgarmadi.

Faqat bir xil vaqt boshqa vaqt zonasida ko‘rsatildi.

Ya’ni:

```text
14:30 +05:00
```

va:

```text
09:30 UTC
```

bir xil vaqt nuqtasidir.

`time.LoadLocation` IANA vaqt zonasi ma’lumotlariga muhtoj.

Bu ma’lumot operatsion tizimdagi zoneinfo bazasidan olinishi mumkin.

Oddiy Linux distributivlarida u ko‘pincha mavjud bo‘ladi.

Lekin juda minimal container image ishlatilsa, zoneinfo bazasi umuman bo‘lmasligi mumkin.

Bunday holatda:

```go
time.LoadLocation("Asia/Tashkent")
```

xato qaytarishi mumkin.

Muammoni bir necha usul bilan hal qilish mumkin.

Masalan, container image’ga zoneinfo ma’lumotlarini o‘rnatish mumkin.

Yoki Go dasturiga timezone bazasini qo‘shish mumkin:

```go
import _ "time/tzdata"
```

Bu usul executable ichiga timezone ma’lumotlarini qo‘shadi.

Afzalligi — dastur tashqi zoneinfo fayllariga kamroq bog‘liq bo‘ladi.

Kamchiligi — executable hajmi kattalashadi.

Shuning uchun qaysi variantni tanlash deployment talabiga bog‘liq.

> **Diqqat**
>
> `time.FixedZone("UZT", 5*60*60)` doimiy `+05:00` offsetli zona yaratadi.
>
> Lekin `FixedZone` tarixiy timezone qoidalarini yoki daylight saving time kabi o‘zgarishlarni bilmaydi.
>
> Agar hududning vaqt qoidalari tarix davomida o‘zgargan yoki kelajakda o‘zgarishi mumkin bo‘lsa, `time.LoadLocation` va `Asia/Tashkent` kabi IANA nomidan foydalanish ma’qul.

## `time.Date` bilan vaqt yaratish

Ma’lum yil, oy, kun va soatdan `time.Time` yaratish uchun `time.Date` ishlatiladi.

Misol:

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	moment := time.Date(
		2024,
		time.August,
		9,
		14,
		30,
		0,
		0,
		time.UTC,
	)

	fmt.Println(moment.Format(time.RFC3339))
}
```

Natija:

```text
2024-08-09T14:30:00Z
```

`time.Date` argumentlarini soddalashtirib quyidagicha tasavvur qilish mumkin:

```text
yil
oy
kun
soat
daqiqa
soniya
nanosekund
location
```

Bu misolda:

```go
2024
```

— yil.

```go
time.August
```

— avgust.

```go
9
```

— oyning 9-kuni.

```go
14, 30, 0
```

— `14:30:00`.

Nanosekund:

```go
0
```

Location esa:

```go
time.UTC
```

sifatida berilgan.

Oy uchun quyidagicha ham yozish mumkin:

```go
time.Date(2024, 8, 9, ...)
```

Bu kompilyatsiyadan o‘tadi.

Sababi `time.Month` butun son asosidagi named type.

Lekin:

```go
time.August
```

yozuvi ancha tushunarli.

Kodga qaragan odam `8` nimani anglatishini eslab o‘tirmaydi.

### `time.Date` qiymatlarni normalizatsiya qiladi

Bu yerda muhim bir nozik jihat bor.

`time.Date` diapazondan tashqaridagi qiymatlarni doim ham xato deb rad etmaydi.

Ularni normalizatsiya qilishi mumkin.

Masalan, yanvarning 32-kuni berilsa, natija keyingi oyga o‘tadi.

Ya’ni:

```text
2024-yil 32-yanvar
```

degan noto‘g‘ri calendar qiymati to‘g‘ridan-to‘g‘ri xato bermasdan fevraldagi sanaga aylanishi mumkin.

Shuning uchun `time.Date`ni:

> “Foydalanuvchi kiritgan sana haqiqatan mavjudmi?”

degan savolni tekshirish uchun validator sifatida ishlatish yaxshi emas.

Agar foydalanuvchi yoki tashqi API matn yuborsa, masalan:

```text
2024-02-30
```

uni qat’iy layout bilan:

```go
time.Parse("2006-01-02", input)
```

orqali tekshirish ma’qul.

`Parse` noto‘g‘ri calendar sanasi uchun xato qaytaradi.

## `Duration`: vaqt oralig‘i

`time.Time` vaqt chizig‘idagi nuqtani bildiradi.

`time.Duration` esa qancha vaqt davom etganini bildiradi.

Masalan:

```text
90 daqiqa
2 soniya
500 millisekund
```

bular vaqt nuqtasi emas, davomiylikdir.

Go’da `time.Duration` `int64` asosidagi named type hisoblanadi.

Ichki qiymat nanosekundlarda ifodalanadi.

Lekin kodda nanosekund sonini qo‘lda yozish shart emas.

Standart konstantalar mavjud:

```go
time.Nanosecond
time.Microsecond
time.Millisecond
time.Second
time.Minute
time.Hour
```

Masalan:

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	start := time.Date(2024, time.January, 1, 12, 0, 0, 0, time.UTC)
	duration := 90 * time.Minute
	end := start.Add(duration)

	fmt.Println("Boshlanish:", start.Format(time.RFC3339))
	fmt.Println("Tugash:", end.Format(time.RFC3339))
	fmt.Println("Davomiylik:", end.Sub(start))
}
```

Natija:

```text
Boshlanish: 2024-01-01T12:00:00Z
Tugash: 2024-01-01T13:30:00Z
Davomiylik: 1h30m0s
```

Bu misolda:

```go
duration := 90 * time.Minute
```

90 daqiqalik `Duration` yaratadi.

Keyin:

```go
end := start.Add(duration)
```

boshlanish vaqtiga 90 daqiqa qo‘shadi.

Natijada:

```text
12:00 + 90 daqiqa = 13:30
```

hosil bo‘ladi.

Keyin:

```go
end.Sub(start)
```

ikki vaqt orasidagi davomiylikni qaytaradi.

Natija:

```text
1h30m0s
```

### Nega `time.Day` yo‘q?

Go standart kutubxonasida:

```go
time.Hour
```

bor.

Lekin:

```go
time.Day
```

yo‘q.

Buning sababi calendar kuni har doim aniq `24*time.Hour` degani emas.

Yozgi vaqt, ya’ni DST qo‘llanadigan hududlarda ayrim calendar kunlari real vaqt bo‘yicha:

```text
23 soat
```

yoki:

```text
25 soat
```

davom etishi mumkin.

Shuning uchun:

> “Aniq 24 soat”

va:

> “Keyingi calendar kuni”

ikki xil tushuncha.

Bu farqni keyingi `Add` va `AddDate` bo‘limida ko‘ramiz.

### `ParseDuration`

Konfiguratsiyada vaqt oralig‘i matn sifatida kelishi mumkin.

Masalan:

```text
1.5s
```

yoki:

```text
1h30m
```

Bunday qiymatlarni `time.ParseDuration` bilan o‘qish mumkin:

```go
timeout, err := time.ParseDuration("1.5s")
if err != nil {
	return err
}
```

Bu yerda:

```text
1.5s
```

quyidagi davomiylikka teng:

```text
1500ms
```

`ParseDuration` noto‘g‘ri format yoki noma’lum birlik uchun xato qaytaradi.

Masalan, tashqi konfiguratsiya bilan ishlaganda xatoni tekshirish muhim.

`time.Duration` ichki tomondan `int64`ga asoslangan.

Shu sabab uning diapazoni cheksiz emas.

Juda katta qiymatlarni hisoblashda `int64` overflow ehtimolini ham hisobga olish kerak.

Oddiy timeout va servis konfiguratsiyalarida bu kam uchraydi, lekin juda katta durationlar bilan matematik amal qilinayotgan kodda bu nozik jihat muhim bo‘lishi mumkin.

## `Add` va `AddDate` farqi

Go’da vaqtga biror narsa qo‘shishning kamida ikki muhim usuli bor:

* `Add`;
* `AddDate`.

Ularning ma’nosi bir xil emas.

### `Add`

`Add` aniq `Duration` qo‘shadi:

```go
later := moment.Add(2 * time.Hour)
earlier := moment.Add(-30 * time.Minute)
```

Birinchi qatorda:

```go
2 * time.Hour
```

aniq ikki soat qo‘shiladi.

Ikkinchi qatorda manfiy duration ishlatilgani uchun:

```go
-30 * time.Minute
```

30 daqiqa ayriladi.

Demak, `Add` vaqt chizig‘ida aniq davomiylik bilan ishlaydi.

### `AddDate`

`AddDate` esa calendar birliklari bilan ishlaydi:

```go
nextMonth := moment.AddDate(0, 1, 0)
twoMonthsAgo := moment.AddDate(0, -2, 0)
nextWeek := moment.AddDate(0, 0, 7)
```

`AddDate` argumentlari:

```go
AddDate(years, months, days)
```

ko‘rinishida.

Shuning uchun:

```go
moment.AddDate(0, 1, 0)
```

bir calendar oy qo‘shadi.

```go
moment.AddDate(0, -2, 0)
```

ikki calendar oy orqaga o‘tadi.

```go
moment.AddDate(0, 0, 7)
```

yetti calendar kun qo‘shadi.

### `24*time.Hour` va bitta calendar kuni

Quyidagi ikki kod har doim bir xil ma’noni anglatmaydi:

```go
moment.Add(24 * time.Hour)
```

va:

```go
moment.AddDate(0, 0, 1)
```

Birinchi variant:

> Aynan 24 real soat qo‘sh.

deydi.

Ikkinchi variant:

> Keyingi calendar kuniga o‘t.

deydi.

DST ishlatiladigan zonada keyingi calendar kuni mahalliy vaqt bo‘yicha 23 yoki 25 real soatdan keyin kelishi mumkin.

Shuning uchun talabga qarab metod tanlanadi.

Agar talab:

> “Aynan 24 soatdan keyin”

bo‘lsa:

```go
Add(24 * time.Hour)
```

mos keladi.

Agar talab:

> “Ertaga shu mahalliy soatda”

bo‘lsa:

```go
AddDate(0, 0, 1)
```

ko‘proq mos keladi.

### Oy qo‘shishdagi nozik holat

Calendar oylarining uzunligi bir xil emas.

Masalan:

* ayrim oylar 31 kun;
* ayrimlari 30 kun;
* fevral 28 yoki 29 kun.

Shuning uchun oyning 31-kunidan bir oy oldinga o‘tishda yangi oyda 31-kun mavjud bo‘lmasligi mumkin.

`AddDate` bunday holatlarni `time.Date` normalizatsiya qoidalari bo‘yicha hisoblaydi.

Shu sabab biznes talabi:

> “Keyingi oyning aynan oxirgi kuni”

bo‘lsa, shunchaki:

```go
AddDate(0, 1, 0)
```

har doim kerakli biznes natijani bermasligi mumkin.

Bunday vazifada “oyning oxirgi kuni” uchun alohida calendar qoidasini yozish kerak.

## Vaqt zonalari bilan ishlash

`time.Time` faqat yil, oy va soatni saqlaydigan oddiy struct deb qarash yetarli emas.

U vaqt nuqtasini ma’lum `Location` bilan ko‘rsatishi mumkin.

`Location` shu vaqtni foydalanuvchi qaysi mahalliy soatda ko‘rishini belgilaydi.

Bir vaqt nuqtasini boshqa vaqt zonasida ko‘rsatish uchun `In` metodi ishlatiladi:

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	tashkent, err := time.LoadLocation("Asia/Tashkent")
	if err != nil {
		fmt.Println("Zona yuklanmadi:", err)
		return
	}

	moment := time.Date(2024, time.January, 15, 9, 0, 0, 0, time.UTC)

	fmt.Println("UTC:", moment.Format(time.RFC3339))
	fmt.Println("Toshkent:", moment.In(tashkent).Format(time.RFC3339))
}
```

Natija:

```text
UTC: 2024-01-15T09:00:00Z
Toshkent: 2024-01-15T14:00:00+05:00
```

Boshlang‘ich qiymat:

```text
2024-01-15T09:00:00Z
```

UTCda.

Keyin:

```go
moment.In(tashkent)
```

chaqiriladi.

Toshkent UTCdan `+05:00` oldinda bo‘lgani uchun ko‘rinish:

```text
2024-01-15T14:00:00+05:00
```

bo‘ladi.

Bu yerda:

```text
09:00 UTC
```

va:

```text
14:00 +05:00
```

ikki xil vaqt nuqtasi emas.

Ular bir xil nuqtani ikki xil vaqt zonasida ko‘rsatadi.

Shuning uchun `In`:

> vaqtning o‘zini boshqa vaqtga aylantirish

emas.

U:

> bir xil vaqt nuqtasini boshqa `Location` qoidalari bilan ko‘rsatish

uchun ishlatiladi.

Backend tizimlarda keng tarqalgan yondashuv quyidagicha:

1. vaqt nuqtalarini UTCda saqlash;
2. servislar orasida UTC yoki aniq offsetli standart format yuborish;
3. foydalanuvchiga chiqarishda uning `Location`iga o‘tkazish.

Bu yondashuv timezone bilan bog‘liq ko‘plab xatolarni kamaytiradi.

Lekin barcha ma’lumotni majburan “vaqt nuqtasi” deb qarash ham to‘g‘ri emas.

Masalan, tug‘ilgan sana ko‘pincha calendar sanasi bo‘ladi. U aniq UTC moment bo‘lishi shart emas.

Bu farqni API va database modelini loyihalashda hisobga olish kerak.

### Offset va `Location` bir xil emas

Quyidagi qiymat:

```text
+05:00
```

faqat UTCdan joriy siljishni bildiradi.

U hududning to‘liq tarixiy qoidalarini bildirmaydi.

Masalan:

```text
Asia/Tashkent
```

IANA timezone nomi bo‘lib, zoneinfo bazasidagi qoidalarga tayanadi.

Bunday location kerak bo‘lsa:

```go
time.LoadLocation("Asia/Tashkent")
```

ishlatiladi.

Shuning uchun:

```text
+05:00
```

va:

```text
Asia/Tashkent
```

bir xil tushuncha emas.

## Vaqtlarni taqqoslash

Ikki `time.Time` qiymatini vaqt nuqtasi sifatida taqqoslash uchun maxsus metodlar mavjud:

* `Before`;
* `After`;
* `Equal`.

Misol:

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	utc := time.Date(2024, time.January, 1, 9, 0, 0, 0, time.UTC)
	fixed := time.FixedZone("UTC+5", 5*60*60)
	local := time.Date(2024, time.January, 1, 14, 0, 0, 0, fixed)

	fmt.Println("Bir vaqt nuqtasimi:", utc.Equal(local))
	fmt.Println("UTC oldinmi:", utc.Before(local))
}
```

Natija:

```text
Bir vaqt nuqtasimi: true
UTC oldinmi: false
```

Bu yerda birinchi vaqt:

```text
2024-01-01 09:00 UTC
```

Ikkinchi vaqt:

```text
2024-01-01 14:00 UTC+5
```

`UTC+5` UTCdan besh soat oldinda.

Shuning uchun:

```text
14:00 - 5 soat = 09:00 UTC
```

Demak, ikki qiymat bir xil vaqt nuqtasini ifodalaydi.

Shu sabab:

```go
utc.Equal(local)
```

`true` qaytaradi.

`utc.Before(local)` esa `false`.

Chunki `utc` ikkinchi qiymatdan oldin emas. Ular teng.

### Nega `==` ishlatmaslik kerak?

`time.Time` Go’da comparable type hisoblanadi.

Demak, sintaktik jihatdan:

```go
a == b
```

yozish mumkin.

Lekin bu taqqoslash faqat vaqt chizig‘idagi nuqtani emas, `time.Time` ichki ko‘rinishining boshqa qismlarini ham hisobga olishi mumkin.

Masalan:

* `Location`;
* monotonic ma’lumot.

Shuning uchun:

> “Bu ikki qiymat aynan bir xil vaqt nuqtasimi?”

degan savol uchun:

```go
a.Equal(b)
```

ishlatish ma’qul.

Agar:

```go
time.Time
```

`map` uchun kalit sifatida ishlatilsa, bu nozik jihat ayniqsa muhim.

Masalan:

```go
map[time.Time]string
```

ishlatish mumkin.

Lekin bir xil vaqt nuqtasi turli internal representation bilan kelishi mumkin.

Shuning uchun map kaliti sifatida ishlatishdan oldin vaqtlarni qanday normalize qilish qoidasi borligini aniq belgilash kerak.

## Unix timestamp

Unix timestamp vaqt nuqtasini bitta son bilan ifodalash usuli.

Boshlang‘ich nuqta Unix epoch hisoblanadi:

```text
1970-01-01T00:00:00Z
```

Unix timestamp shu vaqtdan qancha soniya yoki kichikroq vaqt birligi o‘tganini bildiradi.

Misol:

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	moment := time.Date(2024, time.January, 1, 0, 0, 0, 0, time.UTC)
	seconds := moment.Unix()
	restored := time.Unix(seconds, 0).UTC()

	fmt.Println("Timestamp:", seconds)
	fmt.Println("Qayta tiklandi:", restored.Format(time.RFC3339))
}
```

Natija:

```text
Timestamp: 1704067200
Qayta tiklandi: 2024-01-01T00:00:00Z
```

Avval:

```go
moment.Unix()
```

vaqt nuqtasini Unix soniyalariga aylantiradi.

Natija:

```text
1704067200
```

Keyin:

```go
time.Unix(seconds, 0)
```

shu timestampdan yangi `time.Time` yaratadi.

`.UTC()` esa natijani UTC ko‘rinishida beradi.

### Timestamp birligini aniq ko‘rsatish kerak

Unix timestamp bilan ishlashdagi eng keng tarqalgan xatolardan biri birlikni chalkashtirishdir.

Masalan:

```text
1704067200
```

soniya bo‘lishi mumkin.

Boshqa API esa timestampni millisekundlarda yuborishi mumkin:

```text
1704067200000
```

Agar millisekunddagi qiymatni soniya deb qabul qilsak yoki aksincha, butunlay noto‘g‘ri sana hosil bo‘ladi.

Go’da birlikni ochiq ifodalovchi metodlar bor:

```go
moment.Unix()
moment.UnixMilli()
moment.UnixMicro()
moment.UnixNano()
```

Ularning nomi qiymat qaysi birlikda ekanini ko‘rsatadi.

API shartnomasida ham birlikni aniq yozish kerak.

Masalan:

```text
created_at_unix_seconds
```

yoki hujjatda:

```text
Unix timestamp in milliseconds
```

deb ko‘rsatish foydali.

### Unix timestamp timezone saqlamaydi

Unix timestamp:

```text
1704067200
```

ichida:

```text
Asia/Tashkent
```

yoki:

```text
Europe/London
```

degan ma’lumot yo‘q.

U faqat vaqt nuqtasini bildiradi.

Uni foydalanuvchiga ko‘rsatishda qaysi `Location` ishlatilishi keyin tanlanadi.

## JSON va API formatlari

Go’ning standart `encoding/json` paketi `time.Time` qiymatini odatda RFC 3339 formatidagi matn sifatida serializatsiya qiladi.

Masalan:

```json
{
  "created_at": "2024-08-09T09:30:00Z"
}
```

Bunday ko‘rinishning afzalligi shundaki, vaqt zonasi ma’nosi aniq.

Bu yerda:

```text
Z
```

UTCni bildiradi.

Boshqa zonadagi qiymat esa masalan:

```text
2024-08-09T14:30:00+05:00
```

ko‘rinishida bo‘lishi mumkin.

Servislar orasida vaqt yuborishda timezone yoki offset ma’nosi aniq bo‘lgan format ishlatish muhim.

### Calendar sana va vaqt nuqtasi bir xil emas

Ba’zan API faqat sanani saqlashi kerak.

Masalan:

```text
2024-08-09
```

Buning uchun Go layouti:

```text
2006-01-02
```

bo‘ladi.

Bu yerda qiymatga avtomatik ravishda vaqt nuqtasi ma’nosini berish har doim ham to‘g‘ri emas.

Masalan, tug‘ilgan kun:

```text
2000-05-10
```

ko‘pincha shunchaki calendar sanasidir.

Agar uni:

```text
2000-05-10T00:00:00Z
```

ga aylantirsak va keyin boshqa timezonega o‘tkazsak, ayrim zonalarda sana:

```text
2000-05-09
```

yoki boshqa calendar kunga siljishi mumkin.

Bu biznes ma’nosini buzadi.

Shuning uchun ma’lumot modelida quyidagi tushunchalarni aralashtirmang:

* aniq vaqt nuqtasi;
* faqat calendar sanasi;
* mahalliy calendar vaqt.

Database ustunini tanlashda ham shu semantika muhim.

Masalan, database’da:

* vaqt nuqtasi;
* faqat sana;
* foydalanuvchi mahalliy vaqtiga bog‘liq uchrashuv

bir xil turdagi ma’lumot emas.

Database driver va database ustun turi timezone bilan qanday ishlashini ham alohida tekshirish kerak.

## `Sleep`, timer va ticker

`time` paketi faqat sanalarni formatlash uchun emas.

U goroutine ishini vaqt bo‘yicha boshqarish uchun ham vositalar beradi.

### `time.Sleep`

`time.Sleep` joriy goroutineni kamida berilgan davomiylikka to‘xtatadi:

```go
time.Sleep(500 * time.Millisecond)
```

Bu yerda goroutine taxminan yarim soniyaga to‘xtaydi.

Muhim nuqta:

```go
time.Sleep(500 * time.Millisecond)
```

“aniq 500 millisekunddan keyin CPU yana shu goroutinega beriladi” degani emas.

Scheduler va operatsion tizim sabab goroutine biroz kechroq davom etishi mumkin.

Ya’ni `Sleep` minimal kutish davomiyligini bildiradi.

Agar nol yoki manfiy duration berilsa:

```go
time.Sleep(0)
```

yoki:

```go
time.Sleep(-1 * time.Second)
```

`Sleep` darhol qaytadi.

### Timer

Bir marta, ma’lum vaqt o‘tgandan keyin signal kerak bo‘lsa, `time.NewTimer` ishlatiladi:

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	timer := time.NewTimer(20 * time.Millisecond)
	defer timer.Stop()

	<-timer.C
	fmt.Println("Timer tugadi")
}
```

Natija:

```text
Timer tugadi
```

Bu yerda:

```go
timer := time.NewTimer(20 * time.Millisecond)
```

20 millisekundlik timer yaratadi.

Timer ichida:

```go
timer.C
```

channel mavjud.

Keyin:

```go
<-timer.C
```

shu channeldan signal kelishini kutadi.

Timer muddati tugagach, goroutine davom etadi va:

```text
Timer tugadi
```

chiqariladi.

### `Stop`

Quyidagi qatorda:

```go
defer timer.Stop()
```

timer kerak bo‘lmay qolganda to‘xtatiladi.

Timer allaqachon ishlagan bo‘lsa, `Stop`ning amaliy ta’siri bo‘lmasligi mumkin.

Lekin hali faol timer yoki ticker kerak bo‘lmay qolsa, uni to‘xtatish resurslarni keraksiz ishlatmaslik uchun muhim.

### Ticker

Davriy signal kerak bo‘lsa, `time.NewTicker` ishlatiladi.

Masalan, har soniyada biror ish bajarish kabi holatda ticker qulay.

Lekin ticker haqida muhim bir nozik jihat bor.

Agar consumer sekin ishlasa, ticker:

> har bir o‘tib ketgan tickni cheksiz navbatga yig‘ib boradi

degan taxmin noto‘g‘ri.

Shuning uchun kod:

> “Har bir interval uchun albatta bitta event qayta ishlanadi”

degan talabga ko‘r-ko‘rona tayanmasligi kerak.

Agar har bir vaqt oralig‘i alohida hisobga olinishi biznes uchun muhim bo‘lsa, boshqa dizayn talab qilinishi mumkin.

### `Sleep` bilan sinxronizatsiya qilmang

Quyidagi kabi yondashuv yaxshi emas:

```go
go doWork()

time.Sleep(time.Second)

// doWork tugagan deb taxmin qilish
```

Bu yerda dastur:

> “Bir soniya yetarli bo‘lsa kerak”

deb taxmin qilmoqda.

Lekin `doWork` tezroq ham, sekinroq ham tugashi mumkin.

Goroutine tugashini kutish uchun:

* `sync.WaitGroup`;
* channel;
* boshqa aniq sinxronizatsiya vositasi

ishlatish kerak.

Timeout va cancellation kerak bo‘lgan backend operatsiyalarida esa ko‘pincha:

```go
context.WithTimeout
```

mos keladi.

## O‘tgan vaqtni o‘lchash

Operatsiya qancha vaqt davom etganini o‘lchash uchun `time.Now()` va `time.Since()` ishlatilishi mumkin:

```go
start := time.Now()

// O‘lchanadigan ish.

elapsed := time.Since(start)
fmt.Println(elapsed)
```

Jarayon juda sodda:

1. ish boshlanishidan oldin vaqt olinadi;
2. operatsiya bajariladi;
3. `time.Since(start)` orqali qancha vaqt o‘tgani hisoblanadi.

Masalan:

```go
start := time.Now()

doWork()

fmt.Println("Davomiylik:", time.Since(start))
```

Agar `start` qiymatida monotonic clock ma’lumoti mavjud bo‘lsa, `time.Since` undan foydalanishi mumkin.

Bu wall clock o‘zgarishlarining davomiylik o‘lchoviga ta’sirini kamaytiradi.

Lekin performance tahlilida bitta bunday o‘lchov yetarli emas.

Masalan, bir marta:

```text
12ms
```

chiqqani funksiyaning doim 12 millisekund ishlashini anglatmaydi.

Natijaga:

* scheduler;
* garbage collector;
* CPU yuklamasi;
* cache;
* operatsion tizim;
* boshqa processlar

ta’sir qilishi mumkin.

Takroriy va barqarorroq performance o‘lchovi uchun Go benchmarklaridan foydalanish ma’qul.

## Vaqtga bog‘liq kodni testlash

Vaqtga bog‘liq biznes logikani testlashda `time.Now()`ni funksiya ichida bevosita chaqirish muammo tug‘dirishi mumkin.

Masalan:

```go
func expired(deadline time.Time) bool {
	return !time.Now().Before(deadline)
}
```

Bu funksiya natijasi test qachon ishga tushganiga bog‘liq.

Test yanada barqaror bo‘lishi uchun joriy vaqtni tashqaridan uzatish mumkin:

```go
package main

import (
	"fmt"
	"time"
)

func expired(now, deadline time.Time) bool {
	return !now.Before(deadline)
}

func main() {
	now := time.Date(2024, time.January, 1, 12, 0, 0, 0, time.UTC)
	deadline := now.Add(30 * time.Minute)

	fmt.Println(expired(now, deadline))
	fmt.Println(expired(deadline, deadline))
}
```

Natija:

```text
false
true
```

Birinchi chaqiruv:

```go
expired(now, deadline)
```

uchun `now` deadline’dan 30 daqiqa oldin.

Shuning uchun:

```go
now.Before(deadline)
```

`true`.

Funksiya esa:

```go
!now.Before(deadline)
```

qaytaradi.

Natija:

```text
false
```

ya’ni muddat hali tugamagan.

Ikkinchi chaqiruv:

```go
expired(deadline, deadline)
```

da `now` va `deadline` teng.

`Before` faqat birinchi vaqt ikkinchisidan oldin bo‘lsa `true` qaytaradi.

Teng bo‘lsa:

```go
deadline.Before(deadline)
```

`false`.

Shuning uchun:

```go
!false
```

`true`.

Natija:

```text
true
```

bo‘ladi.

Demak, bu koddagi biznes qoida:

> `now` deadlinega teng bo‘lsa ham, muddat tugagan hisoblanadi.

Bu juda muhim chegara holati.

Real loyihalarda quyidagi farqni ongli ravishda tanlash kerak:

```text
now > deadline
```

yoki:

```text
now >= deadline
```

Bu shunchaki texnik tafsilot emas. Biznes qaroridir.

Shuning uchun bunday chegara holatlarini test bilan mustahkamlash kerak.

### Clock funksiyasini uzatish

Kattaroq servisda vaqt manbasini funksiya sifatida berish mumkin:

```go
type Clock func() time.Time
```

Production kodida:

```go
time.Now
```

uzatiladi.

Testda esa doim oldindan belgilangan vaqtni qaytaruvchi funksiya berish mumkin.

Masalan:

```go
fixedNow := func() time.Time {
	return time.Date(2024, time.January, 1, 12, 0, 0, 0, time.UTC)
}
```

Buning foydasi shundaki, test real vaqtga bog‘liq bo‘lmaydi.

Natija har safar bir xil bo‘ladi.

Timer bilan ishlaydigan testlarda ham haqiqiy `time.Sleep` ishlatish ko‘pincha yaxshi yondashuv emas.

Masalan:

```go
time.Sleep(2 * time.Second)
```

testni sekinlashtiradi.

Bundan tashqari, timingga bog‘liq testlar yuklama yuqori bo‘lgan CI muhitida beqaror bo‘lishi mumkin.

Imkon qadar:

* signal;
* channel;
* dependency sifatida berilgan clock;
* boshqariladigan timer abstraksiyasi

kabi yondashuvlardan foydalanish ma’qul.

## Keng tarqalgan xatolar

Vaqt bilan ishlashda quyidagi xatolar tez-tez uchraydi.

* `time.Now()` doim UTC qaytaradi deb o‘ylash.

  `time.Now()` tizimning mahalliy `Location`idan foydalanadi.

  UTC aniq kerak bo‘lsa:

  ```go
  time.Now().UTC()
  ```

  yozing.

* Layoutda `YYYY-MM-DD` ishlatish.

  Go boshqa ko‘p tillardagi `YYYY`, `MM`, `DD` format belgilaridan foydalanmaydi.

  To‘g‘ri Go layouti:

  ```text
  2006-01-02
  ```

* `time.Parse` xatosini tekshirmaslik.

  Tashqi input noto‘g‘ri formatda bo‘lishi yoki mavjud bo‘lmagan sanani ifodalashi mumkin.

  Shuning uchun:

  ```go
  moment, err := time.Parse(...)
  ```

  dan keyin `err`ni tekshiring.

* Zonasiz satrni noto‘g‘ri zonada parse qilish.

  Agar zonasiz vaqt UTC deb talqin qilinishi kerak bo‘lsa:

  ```go
  time.Parse
  ```

  ishlatilishi mumkin.

  Agar u ma’lum mahalliy timezonega tegishli bo‘lsa:

  ```go
  time.ParseInLocation
  ```

  kerak bo‘lishi mumkin.

* Offset va `Location`ni bir xil deb hisoblash.

  ```text
  +05:00
  ```

  faqat UTCdan siljishni bildiradi.

  ```text
  Asia/Tashkent
  ```

  esa zoneinfo bazasidagi hudud qoidalariga tayanadi.

* Calendar kuni doim 24 soat deb hisoblash.

  “Aniq 24 soat” uchun:

  ```go
  Add(24 * time.Hour)
  ```

  “Keyingi calendar kuni” uchun esa:

  ```go
  AddDate(0, 0, 1)
  ```

  kerak bo‘lishi mumkin.

* Vaqt nuqtalarini formatlangan satr orqali taqqoslash.

  Masalan:

  ```go
  a.Format(...) == b.Format(...)
  ```

  vaqt tengligini tekshirish uchun yaxshi yondashuv emas.

  `Before`, `After` va `Equal` metodlaridan foydalaning.

* `time.Time`ni vaqt tengligi uchun `==` bilan solishtirish.

  `==` internal representationning boshqa qismlarini ham hisobga olishi mumkin.

  Vaqt nuqtasining tengligi uchun:

  ```go
  a.Equal(b)
  ```

  ishlating.

* Unix timestamp birligini ko‘rsatmaslik.

  Timestamp:

  ```text
  seconds
  ```

  yoki:

  ```text
  milliseconds
  ```

  ekanini API shartnomasida aniq yozing.

* `time.Sleep` bilan goroutine sinxronlashtirish.

  `Sleep`:

  > “Bu vaqt ichida goroutine albatta tugaydi”

  degan kafolat bermaydi.

  `WaitGroup`, channel yoki boshqa sinxronizatsiya vositasidan foydalaning.

* Testlarda `Sleep`ga ortiqcha tayanish.

  Bunday testlar sekin va timingga bog‘liq bo‘lib qoladi.

* `time.Time` ichidagi monotonic qiymat serializatsiyada saqlanadi deb o‘ylash.

  Monotonic clock ma’lumoti process ichidagi davomiylik hisoblari uchun ishlatiladi.

  U JSON, oddiy formatlash yoki servislararo uzatishda saqlanmaydi.

## Interviewda nimalarga e’tibor beriladi?

Go’da sana va vaqt bo‘yicha savollarda ko‘pincha faqat `time.Now()`ni bilish yetarli bo‘lmaydi.

Quyidagi farqlarni tushunish muhim:

* Go layouti maxsus reference time asosida ishlaydi:

  ```text
  Mon Jan 2 15:04:05 MST 2006
  ```

  Masalan, standart sana layouti:

  ```text
  2006-01-02
  ```

* `time.Time` va `time.Duration` boshqa-boshqa tushunchalarni ifodalaydi.

  `time.Time`:

  > vaqt chizig‘idagi aniq nuqta.

  `time.Duration`:

  > ikki vaqt orasidagi davomiylik.

* `time.Parse` va `time.ParseInLocation` farqini bilish kerak.

  Zonasiz qiymatni `time.Parse` parse qilsa, vaqt UTC bilan hosil bo‘ladi.

  `time.ParseInLocation` esa zonasiz qiymatni berilgan `Location` asosida talqin qiladi.

* `Add` va `AddDate` farqli ma’noga ega.

  `Add` aniq duration bilan ishlaydi.

  `AddDate` calendar yil, oy va kunlari bilan ishlaydi.

* Bir xil vaqt nuqtasi turli timezone ko‘rinishida turlicha soat bilan chiqishi mumkin.

  Masalan:

  ```text
  09:00 UTC
  ```

  va:

  ```text
  14:00 +05:00
  ```

  bir xil vaqt nuqtasi bo‘lishi mumkin.

* Vaqt nuqtasining tengligini tekshirish uchun:

  ```go
  Equal
  ```

  ishlatish kerak.

* `time.Now()` monotonic clock ma’lumotini ham saqlashi mumkin.

  Bu ma’lumot `Sub` va `Since` kabi davomiylik hisoblarida foydali.

  Lekin u formatlash va serializatsiya orqali boshqa tizimga uzatilmaydi.

* Backend servislarida vaqt nuqtalarini UTCda saqlash va servislar orasida UTC yoki aniq offsetli format yuborish ko‘pincha qulay.

  Foydalanuvchiga ko‘rsatishda esa uning `Location`iga o‘tkazish mumkin.

  Lekin faqat calendar sana bo‘lgan qiymatlarni, masalan tug‘ilgan kunni, majburan UTC vaqt nuqtasiga aylantirmaslik kerak.
