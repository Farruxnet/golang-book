# Go’da tasodifiy qiymatlar yaratish

Tasodifiy qiymatlar dasturlashda juda ko‘p joyda kerak bo‘ladi. Masalan, o‘yinlarda tasodifiy harakat tanlash, simulyatsiya qilish, test ma’lumoti yaratish yoki slice elementlarini aralashtirish uchun tasodifiy sonlardan foydalanish mumkin.

Xavfsizlikka oid vazifalarda ham tasodifiy qiymatlar kerak bo‘ladi. Masalan:

* session ID yaratish;
* parolni tiklash tokeni yaratish;
* API kaliti yaratish;
* bir martalik tasdiqlash kodi yaratish.

Lekin bu vazifalarning barchasi uchun bitta tasodifiy generatorni ishlatib bo‘lmaydi.

Go’da tasodifiy qiymatlar bilan ishlash uchun ikkita asosiy paket mavjud:

* `math/rand` — tez ishlaydigan psevdotasodifiy qiymatlar uchun;
* `crypto/rand` — oldindan taxmin qilish qiyin bo‘lgan kriptografik xavfsiz qiymatlar uchun.

Bu paketlarning ikkalasida ham `rand` nomi ishlatiladi. Lekin ularning maqsadi va xavfsizlik xususiyatlari bir xil emas.

Masalan, o‘yin ichidagi tasodifiy son uchun `math/rand` mos keladi. Session ID yoki parolni tiklash tokeni uchun esa `math/rand` ishlatish xavfli. Bunday qiymatlar uchun `crypto/rand` kerak.

## Psevdotasodifiy son nima?

`math/rand` haqiqiy fizik tasodifiylik yaratmaydi. U **psevdotasodifiy sonlar generatori**, ya’ni PRNG yordamida qiymatlar hosil qiladi.

PRNG ma’lum bir boshlang‘ich holatdan sonlar ketma-ketligini hisoblaydi. Bu boshlang‘ich qiymat odatda **seed** deb ataladi.

Hosil bo‘lgan sonlar tashqi tomondan tasodifiy ko‘rinadi. Lekin ular algoritm orqali hisoblangan.

Muhim xususiyat shuki, bir xil generatorga bir xil seed berilsa, bir xil chaqiruvlar ketma-ketligida bir xil natijalar olinadi.

Masalan, bir generator:

```text
42 -> 5, 87, 68, ...
```

ketma-ketligini bersa, xuddi shu generator yana `42` seed bilan yaratilganda shu ketma-ketlikni qayta hosil qilishi mumkin.

Bu xususiyat testlarda juda foydali.

Tasavvur qiling, simulyatsiya faqat ma’lum tasodifiy ketma-ketlikda xato bermoqda. Xato yuz bergan seed saqlab qolinsa, keyinchalik aynan shu ketma-ketlikni qayta yaratish mumkin.

Lekin xavfsizlikka oid qiymatlarda buning aksi kerak.

Masalan, hujumchi session tokenining keyingi qiymatini taxmin qila olmasligi kerak. Agar generator holati yoki seed aniqlansa va keyingi qiymatlar hisoblab chiqilishi mumkin bo‘lsa, bunday generator xavfsizlik uchun yaroqsiz bo‘ladi.

## `math/rand` bilan ishlash

`math/rand` paketi oddiy psevdotasodifiy qiymatlar yaratish uchun qulay.

Zamonaviy Go versiyalarida paket darajasidagi `math/rand` funksiyalarining boshlang‘ich holati avtomatik tayyorlanadi. Shu sababli oddiy dasturda global generator uchun har safar:

```go
rand.Seed(time.Now().UnixNano())
```

kabi kod yozish kerak emas.

Oddiy tasodifiy son yaratish:

```go
package main

import (
	"fmt"
	"math/rand"
)

func main() {
	n := rand.Intn(100)
	fmt.Println("Tasodifiy son:", n)
}
```

Mumkin bo‘lgan natija:

```text
Tasodifiy son: 57
```

Bu yerda asosiy qator:

```go
n := rand.Intn(100)
```

`rand.Intn(n)` quyidagi oraliqdan `int` qiymat qaytaradi:

```text
[0, n)
```

Bu **yarim ochiq oraliq** deyiladi.

`[` chap chegara kirishini, `)` esa o‘ng chegara kirmasligini bildiradi.

Shuning uchun:

```go
rand.Intn(100)
```

quyidagi qiymatlardan birini qaytarishi mumkin:

```text
0, 1, 2, ..., 98, 99
```

Lekin `100` qaytmaydi.

Demak:

```text
eng kichik qiymat = 0
eng katta qiymat   = 99
```

Generator tasodifiy ishlagani sababli dastur qayta ishga tushirilganda boshqa son chiqishi mumkin.

**Diqqat**

`rand.Intn(n)` uchun `n` musbat bo‘lishi shart.

Agar:

```go
rand.Intn(0)
```

yoki:

```go
rand.Intn(-5)
```

kabi qiymat uzatilsa, dastur `panic` qiladi.

Agar yuqori chegara foydalanuvchi, konfiguratsiya yoki tashqi API orqali kelayotgan bo‘lsa, `Intn()` chaqirilishidan oldin uni tekshirish kerak.

### Ixtiyoriy oraliqdan son olish

`rand.Intn()` natijani doim `0`dan boshlab beradi.

Lekin amaliyotda ko‘pincha boshqa oraliq kerak bo‘ladi.

Masalan:

```text
10 dan 15 gacha
```

tasodifiy son kerak bo‘lsin.

Bu yerda ikkala chegara ham natijaga kirishi kerak:

```text
10, 11, 12, 13, 14, 15
```

Bunday oraliqda nechta qiymat borligini hisoblaymiz:

```text
max - min + 1
```

Bizning misolda:

```text
15 - 10 + 1 = 6
```

Demak, avval `[0, 6)` oralig‘idan qiymat olish mumkin:

```text
0, 1, 2, 3, 4, 5
```

Keyin unga `min`, ya’ni `10` qo‘shiladi:

```text
0 + 10 = 10
1 + 10 = 11
2 + 10 = 12
3 + 10 = 13
4 + 10 = 14
5 + 10 = 15
```

Shu sababli formula quyidagicha bo‘ladi:

```go
min + rand.Intn(max-min+1)
```

To‘liq misol:

```go
package main

import (
	"errors"
	"fmt"
	"math/rand"
)

func randomBetween(min, max int) (int, error) {
	if min > max {
		return 0, errors.New("min maxdan katta bo‘lmasligi kerak")
	}

	return min + rand.Intn(max-min+1), nil
}

func main() {
	n, err := randomBetween(10, 15)
	if err != nil {
		fmt.Println("Xato:", err)
		return
	}

	fmt.Println(n)
}
```

Mumkin bo‘lgan natija:

```text
13
```

`randomBetween(10, 15)` quyidagi qiymatlardan birini qaytarishi mumkin:

```text
10
11
12
13
14
15
```

Bu yerda:

```go
if min > max {
	return 0, errors.New("min maxdan katta bo‘lmasligi kerak")
}
```

tekshiruvi muhim.

Agar `min > max` bo‘lsa, quyidagi ifoda noto‘g‘ri diapazon hosil qilishi mumkin:

```go
max - min + 1
```

Natijada `rand.Intn()`ga `0` yoki manfiy son berilishi va dastur `panic` qilishi mumkin.

Shuning uchun funksiya noto‘g‘ri chegarani oldindan aniqlab, `error` qaytarmoqda.

Yana bir nozik holat mavjud.

Quyidagi hisob:

```go
max - min + 1
```

`int` turida bajariladi.

Agar `min` va `max` juda katta ekstremal `int` qiymatlariga yaqin bo‘lsa, ayirish yoki `+1` amali overflow qilishi mumkin.

Masalan, ishonchsiz tashqi ma’lumotdan juda katta chegaralar kelayotgan bo‘lsa, faqat `min <= max` tekshiruvi yetarli bo‘lmasligi mumkin.

Oddiy kichik diapazonlarda bu odatda muammo emas. Lekin tashqi input yoki katta sonlar bilan ishlaganda diapazonni hisoblashdan oldin uning ruxsat etilgan chegaralarini tekshirish kerak.

## Takrorlanuvchi natija uchun lokal generator

Ba’zi holatlarda tasodifiy natijaning har safar o‘zgarishi kerak emas.

Test buning yaxshi misoli.

Testda bir xil tasodifiy ketma-ketlikni qayta-qayta ishlata olish foydali. Chunki test xato bersa, aynan o‘sha holatni yana takrorlash mumkin.

Buning uchun global generatorni o‘zgartirish o‘rniga alohida lokal generator yaratish yaxshi yondashuv hisoblanadi.

```go
package main

import (
	"fmt"
	"math/rand"
)

func main() {
	first := rand.New(rand.NewSource(42))
	second := rand.New(rand.NewSource(42))

	for i := 0; i < 3; i++ {
		fmt.Println(first.Intn(100) == second.Intn(100))
	}
}
```

Natija:

```text
true
true
true
```

Endi bu kodni bosqichma-bosqich ko‘ramiz.

Birinchi generator:

```go
first := rand.New(rand.NewSource(42))
```

Ikkinchi generator:

```go
second := rand.New(rand.NewSource(42))
```

Ikkala `rand.NewSource()` ham bir xil seed olmoqda:

```text
42
```

Demak, ikkala generatorning boshlang‘ich holati bir xil.

Keyin siklda:

```go
first.Intn(100)
second.Intn(100)
```

metodlari bir xil tartibda chaqirilmoqda.

Shu sabab birinchi chaqiruvdagi qiymatlar bir xil bo‘ladi. Ikkinchi chaqiruvdagi qiymatlar ham bir xil bo‘ladi. Uchinchi chaqiruv ham xuddi shunday.

Natijada uch marta:

```text
true
```

chiqadi.

Bu yerda muhim narsa faqat seed emas. **Generator metodlari qanday tartibda chaqirilayotgani ham muhim.**

Masalan, `first` uchun qo‘shimcha bitta tasodifiy qiymat olinsa:

```go
first.Intn(100)
```

uning ichki holati bir qadam oldinga siljiydi.

`second` esa oldingi holatda qoladi.

Shundan keyin ikkala generatorning keyingi natijalari endi bir-biriga mos kelmasligi mumkin.

Paket darajasidagi:

```go
rand.Seed(...)
```

yondashuvi eskirgan hisoblanadi.

Deterministik, ya’ni takrorlanuvchi oqim kerak bo‘lsa:

```go
rand.New(rand.NewSource(seed))
```

ishlatish aniqroq.

Buning yana bir afzalligi bor: lokal generator boshqa kod ishlatayotgan global `math/rand` holatiga ta’sir qilmaydi.

> **Diqqat**
>
> `rand.NewSource()` qaytargan `Source` va undan yaratilgan `*rand.Rand` bir nechta goroutine tomonidan bir vaqtning o‘zida ishlatilishi uchun xavfsiz emas.
>
> Masalan, bitta lokal `*rand.Rand`ni bir nechta goroutine parallel chaqirsa, generatorning ichki holatiga bir vaqtning o‘zida murojaat qilinadi.
>
> Bunday vaziyatda:
>
> - har bir goroutine uchun alohida generator yaratish;
> - yoki umumiy generatorga murojaatni `sync.Mutex` bilan himoyalash
>
> mumkin.
>
> Paket darajasidagi `math/rand` funksiyalari esa concurrent foydalanishga mos.

## Elementlarni aralashtirish

Tasodifiylik faqat son tanlash uchun emas.

Ba’zan slice ichidagi elementlarning tartibini tasodifiy o‘zgartirish kerak bo‘ladi.

Buning uchun `math/rand` paketida `Shuffle()` funksiyasi mavjud.

```go
package main

import (
	"fmt"
	"math/rand"
)

func main() {
	names := []string{"Ali", "Vali", "Aziza", "Madina"}

	rand.Shuffle(len(names), func(i, j int) {
		names[i], names[j] = names[j], names[i]
	})

	fmt.Println(names)
}
```

Mumkin bo‘lgan natija:

```text
[Aziza Ali Madina Vali]
```

Asosiy chaqiruv:

```go
rand.Shuffle(len(names), func(i, j int) {
	names[i], names[j] = names[j], names[i]
})
```

`rand.Shuffle()`ga birinchi argument sifatida elementlar soni beriladi:

```go
len(names)
```

Ikkinchi argument esa `i` va `j` indekslaridagi elementlarni almashtiradigan callback funksiya.

Bizning holatda:

```go
names[i], names[j] = names[j], names[i]
```

ikki elementning joyini almashtiradi.

Muhim jihat shuki, yangi slice yaratilmaydi.

`names` slice’ining o‘zidagi elementlar almashtiriladi. Ya’ni operatsiya slice ustida joyida bajariladi.

Masalan, dastlab:

```text
[Ali Vali Aziza Madina]
```

bo‘lgan tartib:

```text
[Aziza Ali Madina Vali]
```

yoki boshqa tartibga aylanishi mumkin.

Natija har ishga tushirilganda boshqacha bo‘lishi mumkin.

`Shuffle()` quyidagi vazifalarda qulay:

* test ma’lumotlarini aralashtirish;
* o‘yinchilar navbatini tasodifiy belgilash;
* savollar tartibini almashtirish;
* xavfsizlikka aloqasi bo‘lmagan tasodifiy tartib yaratish.

Lekin xavfsizlik uchun muhim bo‘lgan tasodifiy tartib kerak bo‘lsa, `math/rand`ning psevdotasodifiy generatoriga tayanish to‘g‘ri emas.

## `crypto/rand` bilan xavfsiz son olish

Xavfsizlikka oid qiymatlarda asosiy talab faqat “tasodifiy ko‘rinish” emas.

Natijani hujumchi oldindan taxmin qila olmasligi ham kerak.

Bunday vazifalar uchun Go’da `crypto/rand` paketi mavjud.

`crypto/rand` operatsion tizim taqdim etadigan kriptografik tasodifiylik manbasidan foydalanadi.

Bu paket bilan ishlaganda foydalanuvchi:

```go
Seed(...)
```

bermaydi.

Oddiy misol:

```go
package main

import (
	"crypto/rand"
	"fmt"
	"math/big"
)

func main() {
	max := big.NewInt(101)

	n, err := rand.Int(rand.Reader, max)
	if err != nil {
		fmt.Println("Xato:", err)
		return
	}

	fmt.Println("Tasodifiy son:", n)
}
```

Mumkin bo‘lgan natija:

```text
Tasodifiy son: 16
```

Bu yerda:

```go
max := big.NewInt(101)
```

yuqori chegarani yaratmoqda.

Keyin:

```go
n, err := rand.Int(rand.Reader, max)
```

kriptografik xavfsiz tasodifiy son oladi.

`crypto/rand.Int()` quyidagi oraliqdan qiymat qaytaradi:

```text
[0, max)
```

Ya’ni bu yerda ham yuqori chegara natijaga kirmaydi.

Biz:

```go
big.NewInt(101)
```

berganimiz uchun mumkin bo‘lgan qiymatlar:

```text
0..100
```

bo‘ladi.

`crypto/rand.Int()` natijani `*big.Int` ko‘rinishida qaytaradi.

Bu `int` emas. Sababi funksiya oddiy mashina `int` chegarasi bilan cheklanmagan katta sonlar bilan ham ishlashi mumkin.

Yana bir muhim xususiyat — `[0, max)` oralig‘idagi qiymatlar bir xil ehtimol bilan tanlanadi.

> **Diqqat**
>
> `crypto/rand.Int()` uchun `max` musbat bo‘lishi kerak.
>
> Agar yuqori chegara `0` yoki manfiy bo‘lsa, funksiya `panic` qiladi.
>
> Shuning uchun `max` foydalanuvchi yoki boshqa tashqi manbadan kelayotgan bo‘lsa, uni `rand.Int()`ga berishdan oldin tekshirish kerak.

### Bir xil nomdagi paketlarni alias bilan ajratish

Ba’zan bitta faylda ham `crypto/rand`, ham `math/rand` kerak bo‘lishi mumkin.

Muammo shundaki, ikkala paketning standart import nomi ham:

```text
rand
```

bo‘ladi.

Go bitta scope ichida ikkita importni aynan bir xil nom bilan ishlatishga ruxsat bermaydi.

Bunday holatda import alias ishlatiladi:

```go
import (
	cryptorand "crypto/rand"
	mathrand "math/rand"
)
```

Endi kodda paketlar aniq farqlanadi:

```go
cryptorand.Int(...)
```

va:

```go
mathrand.Intn(...)
```

Masalan:

```go
cryptorand.Int(cryptorand.Reader, max)
```

kriptografik generatorni bildiradi.

```go
mathrand.Intn(100)
```

esa `math/rand` psevdotasodifiy generatoridan foydalanadi.

Bu import parchasi alohida ishlaydigan dastur emas. U faqat nomi bir xil ikkita paketni qanday ajratishni ko‘rsatadi.

## Xavfsiz token yaratish

Token yaratishning keng tarqalgan usullaridan biri tasodifiy baytlar yaratib, keyin ularni matn ko‘rinishiga kodlashdir.

Masalan, 16 bayt tasodifiy ma’lumot olaylik:

```go
package main

import (
	"crypto/rand"
	"encoding/hex"
	"fmt"
)

func main() {
	data := make([]byte, 16)

	if _, err := rand.Read(data); err != nil {
		fmt.Println("Xato:", err)
		return
	}

	token := hex.EncodeToString(data)
	fmt.Println("Token uzunligi:", len(token))
}
```

Natija:

```text
Token uzunligi: 32
```

Birinchi muhim qator:

```go
data := make([]byte, 16)
```

Bu 16 baytli slice yaratadi.

Hozircha bu baytlar tasodifiy emas. Slice shunchaki ajratildi.

Keyin:

```go
rand.Read(data)
```

`crypto/rand` yordamida slice ichini kriptografik tasodifiy baytlar bilan to‘ldiradi.

16 bayt nechta bit bo‘lishini hisoblaymiz:

```text
1 bayt = 8 bit
16 × 8 = 128 bit
```

Demak, bu yerda 128 bit tasodifiy ma’lumot olinmoqda.

Keyin:

```go
token := hex.EncodeToString(data)
```

baytlarni hexadecimal matnga aylantiradi.

Hexadecimal formatda har bir bayt ikkita belgi bilan yoziladi.

Masalan:

```text
0x0A -> "0a"
0xFF -> "ff"
```

Shuning uchun:

```text
16 bayt × 2 belgi = 32 belgi
```

Natijadagi token uzunligi doim:

```text
32
```

bo‘ladi.

Tokenning o‘zi esa har chaqiruvda o‘zgaradi.

Masalan, real token taxminan quyidagicha ko‘rinishi mumkin:

```text
6ac97ce51a7197f45e85c023034c3812
```

Lekin dastur bu misolda tokenning o‘zini emas, faqat uning uzunligini chop etmoqda.

Yangi Go versiyalarida `crypto/rand.Read()` berilgan slice’ni to‘liq tasodifiy baytlar bilan to‘ldiradi.

Shunga qaramay:

```go
if _, err := rand.Read(data); err != nil {
	...
}
```

ko‘rinishida xatoni tekshirish yaxshi amaliyot.

Bu kod eski Go versiyalari bilan ham mos keladi va tasodifiy ma’lumot olish muvaffaqiyatsiz bo‘lishi mumkinligini kodning o‘zida aniq ko‘rsatadi.

Xavfsizlikka oid kodda xatoni e’tiborsiz qoldirish ayniqsa yomon fikr. Agar kerakli kriptografik tasodifiylik olinmasa, token yaratishni davom ettirish o‘rniga operatsiyani to‘xtatish kerak.

## Modulo bias nima?

Kriptografik tasodifiy sonni kichik diapazonga keltirishda keng tarqalgan xatolardan biri `%` operatoridan noto‘g‘ri foydalanishdir.

Masalan, tasodifiy bitta bayt olindi deb tasavvur qilamiz.

Bayt quyidagi qiymatlardan birini olishi mumkin:

```text
0..255
```

Demak, jami:

```text
256
```

ta qiymat bor.

Endi `0..9` oralig‘idan tasodifiy raqam olish uchun:

```go
digit := randomByte % 10
```

deb yozish mumkinligi birinchi qarashda to‘g‘ri ko‘rinadi.

Lekin `256` soni `10`ga qoldiqsiz bo‘linmaydi:

```text
256 / 10 = 25, qoldiq 6
```

Shu sabab ayrim natijalar boshqalariga qaraganda ko‘proq chiqadi.

Bosqichma-bosqich ko‘ramiz.

Quyidagi qiymatlar `% 10` qilinganda `0` beradi:

```text
0
10
20
...
250
```

Shunga o‘xshash tarzda `1`, `2`, `3`, `4`, `5` qoldiqlari uchun ham bittadan qo‘shimcha qiymat mavjud.

Lekin `6`, `7`, `8`, `9` qoldiqlarida bunday qo‘shimcha qiymat yo‘q.

Natijada `0..5` qiymatlari `6..9`ga nisbatan biroz ko‘proq ehtimol bilan paydo bo‘ladi.

Bu **modulo bias**, ya’ni modulo og‘ishi deyiladi.

Kriptografik kod uchun quyidagi yondashuv noto‘g‘ri:

```go
// Kriptografik kod uchun noto‘g‘ri yondashuv:
digit := randomByte % 10
```

Oddiy o‘yin yoki xavfsizlikka aloqasi bo‘lmagan kodda juda kichik og‘ish muhim bo‘lmasligi mumkin.

Lekin:

* bir martalik tasdiqlash kodi;
* xavfsiz indeks;
* token qismini tanlash;
* kriptografik tasodifiy qiymat

kabi holatlarda taqsimotning bir xil bo‘lishi muhim.

`crypto/rand.Int()` bu muammoni to‘g‘ri hal qiladi.

U kerakli diapazonga teng taqsimlanmaydigan ortiqcha qiymatlarni qabul qilmaydi va qayta tasodifiy qiymat oladi.

Natijada `[0, n)` oralig‘idagi qiymatlar bir xil ehtimol bilan tanlanadi.

Shu sabab xavfsiz tasodifiy indeks yoki tasdiqlash kodi yaratishda `% n` o‘rniga `crypto/rand.Int()` ishlatish kerak.

## Qaysi paketni tanlash kerak?

`math/rand` va `crypto/rand` bir-birining to‘liq o‘rnini bosmaydi.

Qaysi paket tanlanishi vazifaga bog‘liq.

| Vazifa                                       | Paket                        | Sabab                                                 |
| -------------------------------------------- | ---------------------------- | ----------------------------------------------------- |
| Testni takrorlash                            | `math/rand` lokal generatori | Bir xil seed bir xil oqim beradi                      |
| Simulyatsiya yoki o‘yin                      | `math/rand`                  | Tez va qulay                                          |
| Slice’ni xavfsizlikka aloqasiz aralashtirish | `math/rand`                  | `Shuffle()` mavjud                                    |
| Session ID yoki reset token                  | `crypto/rand`                | Natijani taxmin qilish qiyin                          |
| Kriptografik kalit                           | `crypto/rand`                | Xavfsiz tasodifiy baytlar beradi                      |
| Bir martalik tasdiqlash kodi                 | `crypto/rand`                | Bir xil taqsimot va taxmin qilishga chidamlilik kerak |

Bu yerda asosiy qoida sodda:

Agar natijaning keyingi qiymatini boshqa odam taxmin qilishi xavf tug‘dirmasa, odatda `math/rand` yetarli.

Agar qiymat autentifikatsiya, token, kalit yoki boshqa xavfsizlik mexanizmida ishlatilsa, `crypto/rand` tanlanishi kerak.

## Keng tarqalgan xatolar

### Xavfsizlik tokeni uchun `math/rand` ishlatish

Masalan:

```go
tokenNumber := rand.Intn(1_000_000)
```

oddiy test yoki o‘yin uchun muammo bo‘lmasligi mumkin.

Lekin bu qiymat parolni tiklash kodi yoki session tokenining bir qismi bo‘lsa, `math/rand` mos emas.

`math/rand` psevdotasodifiy generator hisoblanadi. Agar uning seed’i yoki ichki holati aniqlansa, keyingi qiymatlarni taxmin qilish imkoniyati paydo bo‘lishi mumkin.

Xavfsizlikka oid tasodifiylik uchun `crypto/rand` ishlatiladi.

### Har chaqiruv oldidan yangi vaqt seed’i yaratish

Yana bir eski yondashuv — har safar tasodifiy son kerak bo‘lganda yangi generatorni vaqt bilan seed qilish.

Masalan, konseptual jihatdan:

```go
rand.New(rand.NewSource(time.Now().UnixNano()))
```

ni har chaqiruvda yaratish.

Bu yaxshi yondashuv emas.

Bir-biriga juda yaqin vaqtda yaratilgan generatorlar juda yaqin yoki ayrim muhitlarda bir xil boshlang‘ich qiymatlar olish xavfiga ega bo‘lishi mumkin.

Bundan tashqari, doimiy ravishda yangi generator yaratishning o‘zi ham keraksiz.

Odatda bitta generator yaratiladi va kerakli joylarda qayta ishlatiladi.

Zamonaviy Go’da oddiy paket darajasidagi `math/rand` funksiyalarini ishlatayotganda global generator uchun qo‘lda vaqt seed’i berishning o‘zi ham kerak emas.

### `Intn()` yuqori chegarani ham qo‘shadi deb o‘ylash

Quyidagi chaqiruv:

```go
rand.Intn(10)
```

`0`dan `10`gacha emas.

U:

```text
[0, 10)
```

oralig‘idan qiymat beradi.

Ya’ni mumkin bo‘lgan natijalar:

```text
0
1
2
3
4
5
6
7
8
9
```

`10` chiqmaydi.

Agar `1..10` oralig‘i kerak bo‘lsa, masalan:

```go
1 + rand.Intn(10)
```

kabi siljitish kerak.

### `n <= 0` holatini tekshirmaslik

Quyidagi chaqiruvlar xavfli:

```go
rand.Intn(n)
```

va:

```go
rand.Int(rand.Reader, max)
```

Agar chegara tashqaridan kelayotgan bo‘lsa va u noto‘g‘ri qiymat olsa, funksiya `panic` qilishi mumkin.

Shuning uchun chegarani oldindan tekshirish kerak.

Masalan:

```go
if n <= 0 {
	return errors.New("n musbat bo‘lishi kerak")
}
```

kabi tekshiruv foydali.

### Tasodifiy natijaga aniq test yozish

Tasodifiy funksiya uchun quyidagi kabi test noto‘g‘ri yondashuv bo‘lishi mumkin:

```go
if got != 57 {
	t.Fatal("kutilmagan qiymat")
}
```

Agar generator deterministik qilib berilmagan bo‘lsa, `57` chiqishi uchun hech qanday kafolat yo‘q.

Tasodifiy natijani test qilishda odatda uning **invariantlari**, ya’ni doim bajarilishi kerak bo‘lgan shartlari tekshiriladi.

Masalan:

```go
if n < 0 || n >= max {
	t.Fatalf("qiymat diapazondan tashqarida: %d", n)
}
```

Bu yerda aniq natija emas, diapazon tekshirilmoqda.

Agar testda aynan bir xil ketma-ketlik kerak bo‘lsa, lokal generatorga aniq seed berish mumkin:

```go
r := rand.New(rand.NewSource(42))
```

Shunda test takrorlanuvchi bo‘ladi.

## Interviewda nimalarga e’tibor beriladi?

Tasodifiy qiymatlar mavzusida odatda faqat `rand.Intn()` sintaksisini bilish yetarli emas.

Quyidagi farqlarni tushunish muhim.

### Psevdotasodifiy va kriptografik generator farqi

`math/rand` psevdotasodifiy generator.

U tez, qulay va testlarda deterministik oqim yaratish imkonini beradi.

Lekin xavfsizlik tokenlari uchun mo‘ljallanmagan.

`crypto/rand` esa xavfsizlikka oid tasodifiy qiymatlar uchun ishlatiladi. Token, kalit va tasdiqlash kodi kabi qiymatlar uchun shu paket tanlanadi.

### `[0, n)` oralig‘i

`rand.Intn(n)`:

```text
[0, n)
```

oralig‘idan qiymat beradi.

Ya’ni:

```go
rand.Intn(10)
```

uchun eng katta natija:

```text
9
```

bo‘ladi.

`n <= 0` bo‘lsa, funksiya `panic` qiladi.

### Takrorlanuvchi test uchun lokal generator

Testda aniq tasodifiy oqim kerak bo‘lsa, global holatni o‘zgartirish o‘rniga:

```go
rand.New(rand.NewSource(seed))
```

bilan lokal `*rand.Rand` yaratish yaxshi yondashuv.

Bu generator boshqa kodga ta’sir qilmaydi va testni takrorlashni osonlashtiradi.

### Lokal `rand.Source` va concurrency

`rand.NewSource()`dan olingan source va undan yaratilgan `*rand.Rand`ni bir nechta goroutine bir vaqtning o‘zida ishlatishi xavfsiz emas.

Agar bitta generator umumiy ishlatilsa, unga kirishni sinxronlashtirish kerak.

Yoki har bir goroutine o‘z generatoriga ega bo‘lishi mumkin.

### Modulo bias

Kriptografik tasodifiy qiymatni:

```go
value % n
```

orqali diapazonga tushirish har doim teng taqsimot bermaydi.

Agar manba qiymatlari soni `n`ga qoldiqsiz bo‘linmasa, ayrim natijalar boshqalardan ko‘proq uchraydi.

Bu modulo bias deyiladi.

Xavfsizlikka oid vazifalarda kerakli diapazon uchun `crypto/rand.Int()` kabi teng taqsimotni saqlaydigan usuldan foydalanish kerak.
