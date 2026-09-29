# Go’da regular expression bilan ishlash

Regular expression, qisqacha **regex**, matndagi ma’lum bir shaklni ifodalovchi shablondir. U aniq bir matnni emas, matn qanday tuzilishga ega bo‘lishi kerakligini tasvirlaydi.

Regex yordamida:

* matndan kerakli qiymatlarni qidirish;
* qiymat ma’lum formatga mos kelishini tekshirish;
* matnning ayrim qismlarini ajratib olish;
* mos kelgan qismlarni boshqa matn bilan almashtirish

mumkin.

Masalan, log satridan sanani topish, foydalanuvchi nomining formatini tekshirish yoki ketma-ket kelgan ortiqcha bo‘sh joylarni bitta bo‘sh joyga almashtirish mumkin.

Lekin regex barcha matn bilan ishlash vazifalari uchun eng yaxshi vosita emas. Oddiy substring qidirish uchun `strings.Contains()`, prefiksni tekshirish uchun `strings.HasPrefix()`, URL bilan ishlash uchun `net/url`, sana va vaqt uchun esa `time.Parse()` ko‘pincha soddaroq va ishonchliroq bo‘ladi.

Shuning uchun regexdan matndagi **shaklni** ifodalash kerak bo‘lganda foydalanish ma’qul.

## Birinchi shablon

Quyidagi matndan `YYYY-MM-DD` ko‘rinishidagi sanaga o‘xshash qismni topamiz:

```text
Bugungi sana: 2025-08-31
```

Buning uchun quyidagi regex ishlatilishi mumkin:

```text
\d{4}-\d{2}-\d{2}
```

Bu patternni qismlarga ajratib ko‘ramiz:

* `\d` — ASCII raqamga mos keladi, ya’ni `0`dan `9`gacha;
* `{4}` — undan oldingi element aynan to‘rt marta takrorlanishi kerakligini bildiradi;
* `-` — oddiy tire belgisi;
* `\d{2}` — aynan ikkita raqam.

Shunday qilib:

```text
\d{4}
```

to‘rtta raqamni topadi.

Keyingi:

```text
-
```

tire belgisiga mos keladi.

So‘ng:

```text
\d{2}
```

ikkita raqamni topadi.

To‘liq pattern:

```text
\d{4}-\d{2}-\d{2}
```

quyidagi ko‘rinishga mos keladi:

```text
2025-08-31
```

Bu yerda muhim cheklov bor. Regex faqat qiymatning **ko‘rinishini** tekshiradi. U qiymat haqiqiy sana ekanini isbotlamaydi.

Masalan:

```text
9999-99-99
```

ham shu regexga mos keladi.

Lekin bu haqiqiy sana emas.

Shuning uchun sana bilan ishlaganda odatda ikki bosqich kerak bo‘ladi:

1. regex orqali kerakli ko‘rinishdagi qism topiladi;
2. topilgan qiymat `time.Parse()` orqali haqiqiy sana sifatida tekshiriladi.

Masalan:

```go
time.Parse("2006-01-02", value)
```

Bu yondashuv regexning vazifasi bilan semantic validation vazifasini bir-biridan ajratadi.

## Asosiy belgilar

Regex sintaksisida ayrim belgilar maxsus ma’noga ega.

| Belgi    | Ma’nosi                           | Misol      | Mos qiymat            |
| -------- | --------------------------------- | ---------- | --------------------- |
| `.`      | Yangi qatordan boshqa bitta belgi | `c.t`      | `cat`, `cut`          |
| `\d`     | ASCII raqam                       | `\d{2}`    | `12`                  |
| `\w`     | ASCII harf, raqam yoki `_`        | `\w+`      | `go_123`              |
| `\s`     | Bo‘sh joy belgisi                 | `a\s+b`    | `a b`, `a\tb`         |
| `+`      | Bir yoki ko‘p marta               | `a+`       | `a`, `aaa`            |
| `*`      | Nol yoki ko‘p marta               | `ba*`      | `b`, `baa`            |
| `?`      | Nol yoki bir marta                | `colou?r`  | `color`, `colour`     |
| `{n}`    | Aynan `n` marta                   | `\d{4}`    | `2025`                |
| `{n,m}`  | `n`dan `m`gacha                   | `\d{2,4}`  | `12`, `2025`          |
| `^`      | Matn boshi                        | `^salom`   | boshidagi `salom`     |
| `$`      | Matn oxiri                        | `dunyo$`   | oxiridagi `dunyo`     |
| `[abc]`  | To‘plamdagi bitta belgi           | `[abc]`    | `a`, `b` yoki `c`     |
| `[^0-9]` | To‘plamga kirmaydigan belgi       | `[^0-9]`   | raqamdan boshqa belgi |
| `a\|b`   | Chap yoki o‘ng variant            | `cat\|dog` | `cat` yoki `dog`      |
| `()`     | Guruhlash va natijani tutish      | `(ab)+`    | `ab`, `abab`          |

Bu belgilarni ishlatishda Go regexining ayrim xususiyatlarini bilish muhim.

Masalan, `\d`, `\w` va `\b` kabi Perl uslubidagi sinflar ASCII qoidalariga asoslanadi.

`\w` taxminan quyidagilarni qamrab oladi:

```text
A-Z
a-z
0-9
_
```

Shuning uchun `\w` o‘zbek tilidagi `o‘`, `g‘`, `sh` kabi yozuvlarda uchraydigan barcha Unicode harflarini avtomatik qamrab olmaydi.

Unicode bilan ishlash uchun `\p{...}` ko‘rinishidagi sinflar ishlatiladi.

Masalan:

```text
\p{L}
```

Unicode bo‘yicha harf hisoblangan belgilarga mos keladi.

```text
\p{N}
```

esa Unicode raqamlariga mos keladi.

Maxsus belgining o‘zini qidirish kerak bo‘lsa, uni odatda `\` bilan escape qilish kerak.

Masalan:

```text
.
```

regexda istalgan bitta belgini anglatadi.

Oddiy nuqtaning o‘zini topish uchun esa:

```text
\.
```

yoziladi.

Xuddi shuningdek, `+` regexda takrorlash operatori. Oddiy `+` belgisiga mos kelish uchun:

```text
\+
```

yoziladi.

## Go’da regex kompilyatsiya qilish

Go standart kutubxonasida regex bilan ishlash uchun `regexp` paketi mavjud.

Regex odatda ikki bosqichda ishlatiladi:

1. matnli pattern kompilyatsiya qilinadi;
2. hosil bo‘lgan `*regexp.Regexp` obyektidan qidirish yoki tekshirish uchun foydalaniladi.

Misol:

```go
package main

import (
	"fmt"
	"regexp"
)

func main() {
	re := regexp.MustCompile(`\d{4}-\d{2}-\d{2}`)
	date := re.FindString("Buyurtma sanasi: 2025-08-31")

	fmt.Println(date)
}
```

Natija:

```text
2025-08-31
```

Bu kodni bosqichma-bosqich ko‘ramiz.

Avval:

```go
re := regexp.MustCompile(`\d{4}-\d{2}-\d{2}`)
```

patternni kompilyatsiya qiladi.

Natijada `re` o‘zgaruvchisida `*regexp.Regexp` qiymati bo‘ladi.

Keyingi qator:

```go
date := re.FindString("Buyurtma sanasi: 2025-08-31")
```

berilgan matndan pattern bilan mos keladigan birinchi qismni qidiradi.

Natijada:

```text
2025-08-31
```

topiladi.

Pattern backtick bilan yozilgan:

```go
`\d{4}-\d{2}-\d{2}`
```

Bu Go’dagi raw string literal.

Raw string ichida `\` belgisi Go string sintaksisi tomonidan alohida escape qilinmaydi. Shu sabab regex yozishda backtick ko‘pincha qulay.

Agar oddiy qo‘shtirnoqli Go string ishlatilsa:

```go
"\\d{4}-\\d{2}-\\d{2}"
```

deb yozish kerak bo‘ladi.

Sababi bu holatda birinchi `\` Go string uchun escape, ikkinchisi esa regexga yetib boradigan haqiqiy `\` belgisidir.

`regexp.MustCompile()` pattern noto‘g‘ri bo‘lsa panic qiladi.

Bu oldindan ma’lum va kod ichiga yozilgan o‘zgarmas patternlar uchun qulay.

Masalan:

```go
var phonePattern = regexp.MustCompile(`^\+998[0-9]{9}$`)
```

Bu pattern dasturchi tomonidan yozilgan va dastur ishga tushishidan oldin deyarli o‘zgarmaydi. Agar unda sintaktik xato bo‘lsa, uni ishlab chiqish yoki test vaqtida darhol ko‘rish foydali.

## Qidirish va to‘liq validatsiya farqi

Regex bilan ishlashda eng ko‘p uchraydigan xatolardan biri qidirish va to‘liq validatsiyani bir xil deb o‘ylashdir.

`MatchString()` satrning istalgan qismida moslik topilsa `true` qaytarishi mumkin.

Agar butun qiymat ma’lum formatga mos bo‘lishi kerak bo‘lsa, satr boshini va oxirini ham belgilash kerak.

Buning uchun:

```text
^
```

satr boshini,

```text
$
```

esa satr oxirini bildiradi.

Telefon raqamini tekshiradigan misol:

```go
package main

import (
	"fmt"
	"regexp"
)

var phonePattern = regexp.MustCompile(`^\+998[0-9]{9}$`)

func main() {
	fmt.Println(phonePattern.MatchString("+998901234567"))
	fmt.Println(phonePattern.MatchString("Telefon: +998901234567"))
	fmt.Println(phonePattern.MatchString("+99890123456"))
}
```

Natija:

```text
true
false
false
```

Pattern:

```text
^\+998[0-9]{9}$
```

ni qismlarga ajratamiz.

`^`:

```text
^
```

moslik aynan satr boshidan boshlanishi kerakligini bildiradi.

Keyingi:

```text
\+998
```

oddiy `+998` belgilar ketma-ketligini talab qiladi.

Bu yerda `+` regex operatori bo‘lgani uchun:

```text
\+
```

deb escape qilingan.

Keyingi qism:

```text
[0-9]{9}
```

mamlakat kodidan keyin aynan to‘qqizta ASCII raqam bo‘lishini talab qiladi.

Oxiridagi:

```text
$
```

esa moslik satr oxirida tugashi kerakligini bildiradi.

Shuning uchun:

```text
+998901234567
```

mos keladi.

Lekin:

```text
Telefon: +998901234567
```

mos kelmaydi. Chunki `+998...` satr boshidan boshlanmagan.

Agar `^` va `$` yozilmaganida, regex satr ichidagi mos kelgan kichik qismni topib, ikkinchi holatda ham `true` qaytarishi mumkin edi.

Bu yerda yana bir muhim farq bor.

Regex quyidagini tekshiradi:

> Telefon raqami kerakli sintaktik formatga o‘xshaydimi?

Lekin u quyidagilarni aniqlamaydi:

* bu raqam haqiqatan ajratilganmi;
* raqam faolmi;
* operator diapazoniga mos keladimi;
* foydalanuvchi shu raqam egasimi.

Bular regex emas, alohida biznes qoidalari orqali tekshiriladi.

## Barcha mosliklarni topish

Ba’zan matndan faqat birinchi moslik emas, barcha mos qismlar kerak bo‘ladi.

Buning uchun `FindAllString()` ishlatiladi.

Misol:

```go
package main

import (
	"fmt"
	"regexp"
)

func main() {
	re := regexp.MustCompile(`[0-9]+`)
	prices := re.FindAllString("Olma 12000, nok 18000, jami 30000", -1)

	fmt.Println(prices)
}
```

Natija:

```text
[12000 18000 30000]
```

Bu yerda pattern:

```text
[0-9]+
```

bir yoki undan ko‘p raqamdan iborat ketma-ketlikka mos keladi.

`FindAllString()`ning ikkinchi argumenti maksimal natijalar sonini belgilaydi.

Bu yerda:

```go
-1
```

berilgan.

`-1` barcha mosliklarni qaytarishni bildiradi.

Shuning uchun uchta son topiladi:

```text
12000
18000
30000
```

Agar:

```go
re.FindAllString(text, 2)
```

yozilsa, faqat dastlabki ikkita moslik qaytariladi.

Masalan:

```text
[12000 18000]
```

Agar umuman moslik bo‘lmasa, metod `nil` slice qaytaradi.

Bu misolda topilgan qiymatlar hali `int` emas. Ular `string` sifatida qaytadi.

Masalan:

```go
"12000"
```

Bu qiymat bilan arifmetik amal bajarish kerak bo‘lsa, uni son turiga o‘tkazish kerak.

Odatda:

```go
strconv.Atoi()
```

ishlatiladi.

Masalan:

```go
value, err := strconv.Atoi("12000")
```

Bu yerda conversion xatosini ham tekshirish kerak.

Regex matndan kerakli qismlarni topadi. Topilgan ma’lumotni keyingi bosqichda kerakli Go turiga aylantirish alohida vazifa.

## Guruhlar orqali qismlarni ajratish

Regexda qavslar:

```text
(...)
```

nafaqat elementlarni guruhlaydi, balki **capturing group**, ya’ni natijada alohida olinadigan guruh yaratadi.

Masalan, quyidagi qiymat bor:

```text
order-42
```

Biz undan:

* `order`;
* `42`

qismlarini alohida olishni xohlaymiz.

Buning uchun:

```go
package main

import (
	"fmt"
	"regexp"
)

func main() {
	re := regexp.MustCompile(`^([a-z]+)-([0-9]+)$`)
	parts := re.FindStringSubmatch("order-42")
	if parts == nil {
		fmt.Println("Format mos emas")
		return
	}

	fmt.Println("To‘liq:", parts[0])
	fmt.Println("Turi:", parts[1])
	fmt.Println("ID:", parts[2])
}
```

Natija:

```text
To‘liq: order-42
Turi: order
ID: 42
```

Pattern:

```text
^([a-z]+)-([0-9]+)$
```

ikki capturing groupga ega.

Birinchi guruh:

```text
([a-z]+)
```

bir yoki undan ko‘p kichik ASCII harfga mos keladi.

Ikkinchi guruh:

```text
([0-9]+)
```

bir yoki undan ko‘p raqamga mos keladi.

Ularning orasida oddiy tire bor:

```text
-
```

`FindStringSubmatch()` natijani slice ko‘rinishida qaytaradi.

Bu slicedagi:

```go
parts[0]
```

har doim to‘liq moslikni bildiradi.

Bu misolda:

```text
order-42
```

Keyingi element:

```go
parts[1]
```

birinchi capturing group qiymati:

```text
order
```

`parts[2]` esa ikkinchi capturing group qiymati:

```text
42
```

Bu yerda:

```go
if parts == nil {
	fmt.Println("Format mos emas")
	return
}
```

tekshiruvi juda muhim.

Agar pattern mos kelmasa, `FindStringSubmatch()` `nil` qaytarishi mumkin.

Shundan keyin:

```go
parts[0]
```

kabi indeksga murojaat qilinsa, dastur panic qiladi.

Shuning uchun submatch metodlari bilan ishlaganda natija borligini avval tekshirish kerak.

Ba’zan guruhlash kerak, lekin natijani alohida olish kerak emas.

Bunday holatda non-capturing group ishlatiladi:

```text
(?:...)
```

Masalan:

```text
(?:ab)+
```

`ab` qismini guruhlaydi, lekin uni alohida capturing result sifatida saqlamaydi.

Go regexida nomlangan guruhlar ham mavjud.

Sintaksis:

```text
(?P<name>...)
```

Masalan:

```text
(?P<type>[a-z]+)
```

Keyinchalik guruh nomlarini:

```go
SubexpNames()
```

orqali olish mumkin.

Bu ayniqsa bir nechta guruh bo‘lgan katta patternlarda `parts[1]`, `parts[2]` kabi indekslarni o‘qishni osonlashtiradi.

## Matnni almashtirish

Regex faqat qidirish uchun emas. Mos kelgan qismlarni boshqa matn bilan almashtirish ham mumkin.

Buning uchun `ReplaceAllString()` ishlatiladi.

Masalan, ketma-ket bo‘sh joylarni bitta bo‘sh joyga keltiramiz:

```go
package main

import (
	"fmt"
	"regexp"
	"strings"
)

func main() {
	re := regexp.MustCompile(`\s+`)
	cleaned := re.ReplaceAllString("  Go\tregex\n bilan   ishlaydi  ", " ")

	fmt.Println(strings.TrimSpace(cleaned))
}
```

Natija:

```text
Go regex bilan ishlaydi
```

Pattern:

```text
\s+
```

bir yoki undan ko‘p whitespace belgisiga mos keladi.

Bu faqat oddiy space emas. Masalan:

* bo‘sh joy;
* `\t` tab;
* `\n` yangi qator

kabi belgilar ham mos kelishi mumkin.

Boshlang‘ich matn:

```text
  Go\tregex\n bilan   ishlaydi  
```

ichidagi har bir ketma-ket whitespace guruhi:

```text
" "
```

bilan almashtiriladi.

Lekin satr boshida va oxirida ham bo‘sh joy qolishi mumkin.

Shuning uchun:

```go
strings.TrimSpace(cleaned)
```

ishlatilgan.

U satrning boshidagi va oxiridagi whitespace belgilarini olib tashlaydi.

Bu misolda regex ishlatish mumkin, lekin faqat matndagi bo‘sh joylarni normallashtirish vazifasi bo‘lsa, boshqa sodda yechim ham bor:

```go
strings.Fields()
```

`strings.Fields()` matnni whitespace bo‘yicha qismlarga ajratadi. Keyin ularni bitta bo‘sh joy bilan birlashtirish mumkin.

Masalan:

```go
strings.Join(strings.Fields(text), " ")
```

Murakkabroq qoidalar bilan almashtirish kerak bo‘lsa, regex foydaliroq bo‘ladi.

`ReplaceAllString()` replacement matnida capturing grouplardan ham foydalanish mumkin.

Masalan:

```text
$1
```

birinchi capturing group qiymatini bildiradi.

Nomlangan guruh uchun:

```text
${name}
```

ishlatish mumkin.

Bu yerda nozik jihat bor. Replacement satridagi `$` maxsus ma’noga ega.

Shuning uchun oddiy dollar belgisini qo‘shish kerak bo‘lsa, `ReplaceAllString()`ning replacement sintaksisini hisobga olish kerak.

Murakkab holatlarda:

```go
ReplaceAllStringFunc()
```

ishlatish qulayroq bo‘lishi mumkin.

Bu metod har bir topilgan moslik uchun Go funksiyasini chaqirishga imkon beradi.

## Tashqaridan kelgan pattern

`MustCompile()` oldindan ma’lum patternlar uchun qulay.

Lekin pattern konfiguratsiyadan, HTTP requestdan yoki foydalanuvchidan kelsa, vaziyat boshqa.

Noto‘g‘ri pattern:

```go
regexp.MustCompile(pattern)
```

ga berilsa, panic yuz beradi.

Server dasturida foydalanuvchi xatosi sabab butun processning panic qilishi odatda istalmaydi.

Bunday holatda `regexp.Compile()` ishlatiladi.

Misol:

```go
package main

import (
	"fmt"
	"regexp"
)

func main() {
	pattern := `[a-z+`

	re, err := regexp.Compile(pattern)
	if err != nil {
		fmt.Println("Noto‘g‘ri pattern:", err)
		return
	}

	fmt.Println(re.MatchString("go"))
}
```

Bu yerda pattern:

```text
[a-z+
```

noto‘g‘ri.

Sababi `[` bilan boshlangan character class yopilmagan.

`regexp.Compile()` panic qilmaydi.

U ikkita qiymat qaytaradi:

```go
re, err := regexp.Compile(pattern)
```

Agar pattern to‘g‘ri bo‘lsa:

* `re` ishlatishga tayyor regex bo‘ladi;
* `err == nil`.

Agar pattern xato bo‘lsa:

* `err` xato haqida ma’lumot beradi.

Natijadagi xato matni Go versiyasiga qarab biroz farq qilishi mumkin:

```text
Noto‘g‘ri pattern: error parsing regexp: missing closing ]: `[a-z+`
```

Bu yondashuv foydalanuvchi tomonidan berilgan patternlar uchun xavfsizroq.

Masalan, web API’da foydalanuvchi noto‘g‘ri regex yuborsa, server:

```text
400 Bad Request
```

kabi javob qaytarishi mumkin.

Lekin ichki parser xatosini to‘liq mijozga chiqarish har doim ham yaxshi emas.

Amalda foydalanuvchiga tushunarliroq validatsiya xabari berish ma’qul.

Masalan:

```text
Regex pattern noto‘g‘ri.
```

Ichki texnik xatoni esa logga yozish mumkin.

## Email va URL validatsiyasi

Emailni regex bilan tekshirish mumkin, lekin bu vazifada ehtiyot bo‘lish kerak.

Quyidagi pattern odatiy email ko‘rinishlarini soddalashtirilgan tarzda tekshiradi:

```text
(?i)^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,}$
```

Bu patternni qismlarga ajratamiz.

```text
(?i)
```

case-insensitive rejimni yoqadi.

Demak, katta va kichik harflar o‘rtasidagi farq hisobga olinmaydi.

Keyingi:

```text
^[a-z0-9._%+-]+
```

`@` belgisigacha bo‘lgan qismda ruxsat etilgan belgilarni tekshiradi.

So‘ng:

```text
@
```

oddiy `@` belgisi kelishi kerak.

Domen qismi:

```text
[a-z0-9.-]+
```

orqali tekshiriladi.

Oxirida:

```text
\.[a-z]{2,}$
```

nuqta va kamida ikki harfdan iborat suffix talab qiladi.

Masalan:

```text
user@example.com
```

mos kelishi mumkin.

Lekin bu pattern email standartining barcha holatlarini ifodalamaydi.

Email sintaksisi amalda ancha murakkab.

Bundan tashqari, regex quyidagilarni aniqlay olmaydi:

* domen haqiqatan mavjudmi;
* mailbox mavjudmi;
* foydalanuvchi bu email egasimi;
* emailga xat yetib boradimi.

Shuning uchun account ro‘yxatdan o‘tkazish kabi jarayonda eng ishonchli yakuniy tekshiruv odatda tasdiqlash xatini yuborishdir.

URL uchun ham xuddi shunday tamoyil ishlaydi.

URL’ni juda katta regex bilan to‘liq validatsiya qilish o‘rniga:

```go
net/url.ParseRequestURI()
```

yoki vazifaga mos boshqa parserdan foydalanish ma’qul.

Parser URL’ni qismlarga ajratib beradi.

Masalan:

* scheme;
* host;
* path;
* query;
* escaping

kabi qismlar tuzilmali ko‘rinishda olinadi.

Regex URL uchun faqat loyiha talab qilgan tor formatni qo‘shimcha tekshirishda foydali bo‘lishi mumkin.

Masalan:

> Faqat `https://` bilan boshlanadigan URL qabul qilinsin.

kabi loyiha qoidasi regex yoki parserdan keyingi qo‘shimcha validation bilan tekshirilishi mumkin.

## Go regex dvigatelining xususiyatlari

Go `regexp` paketi RE2 sintaksisiga asoslangan.

Bu faqat sintaksis farqi emas. Uning ishlash modeli ham muhim.

Go regex matching vaqtini kirish hajmiga nisbatan chiziqli saqlashga mo‘ljallangan.

Oddiy qilib aytganda, ayrim backtracking regex dvigatellarida noto‘g‘ri tuzilgan pattern juda katta hisoblash xarajatiga olib kelishi mumkin.

Bu hodisa ko‘pincha **catastrophic backtracking** deb ataladi.

RE2 dizayni bunday holatni cheklashga qaratilgan.

Bu web server kabi foydalanuvchidan matn keladigan tizimlar uchun muhim. Chunki juda og‘ir regex CPU resursini uzoq vaqt band qilib qo‘yishi mumkin.

Lekin bu xavfsizroq ishlash modeli evaziga ayrim regex imkoniyatlari qo‘llanmaydi.

Go `regexp` paketida quyidagilar mavjud emas:

* backreference: `\1`, `\k<name>`;
* lookahead: `(?=...)`, `(?!...)`;
* lookbehind: `(?<=...)`;
* shartli patternlar;
* rekursiv patternlar.

Masalan, quyidagi vazifani olaylik:

> Yonma-yon yozilgan ikkita aynan bir xil so‘zni topish.

Ba’zi regex dvigatellarida birinchi so‘z capturing group orqali olinib, keyin backreference bilan yana o‘sha qiymat talab qilinishi mumkin.

Go regexida backreference yo‘q.

Shuning uchun kerakli qismlarni avval regex orqali ajratib olish, keyin Go kodida ularni solishtirish kerak.

Bu yerda muhim amaliy qoida bor.

Agar pattern o‘zgarmasa, uni har safar qayta kompilyatsiya qilish shart emas.

Masalan, bunday yozish:

```go
func ValidatePhone(value string) bool {
	re := regexp.MustCompile(`^\+998[0-9]{9}$`)
	return re.MatchString(value)
}
```

har chaqirilganda regexni qayta kompilyatsiya qiladi.

Doimiy patternni paket darajasida bir marta tayyorlash yaxshiroq:

```go
var phonePattern = regexp.MustCompile(`^\+998[0-9]{9}$`)

func ValidatePhone(value string) bool {
	return phonePattern.MatchString(value)
}
```

Buning sababi `*regexp.Regexp` kompilyatsiyadan keyin qayta ishlatilishi mumkin.

U bir nechta goroutine tomonidan concurrent tarzda ham xavfsiz ishlatiladi.

Bu server kodida ayniqsa foydali. Chunki har requestda regexni qayta yaratish CPU va allocation sarfini oshiradi.

## Unicode va bayt indekslari

Go stringlari UTF-8 kodlangan baytlardan tashkil topadi.

Regex esa matnni Unicode code pointlar, ya’ni rune’lar sifatida ko‘rib ishlaydi.

Masalan:

```text
.
```

odatda bitta rune’ga mos keladi.

Bu ASCII matnda katta farq qilmaydi. Chunki ASCII belgilarining har biri UTF-8 da bitta bayt.

Lekin Unicode belgisi bir nechta baytdan iborat bo‘lishi mumkin.

Shu sabab indeks qaytaradigan regex metodlarida nozik jihat mavjud.

Masalan:

```go
FindStringIndex()
```

rune indeksini emas, **bayt offsetlarini** qaytaradi.

Bu Go string indexing qoidalariga mos.

Agar matnda `o‘`, `g‘`, kirill harfi yoki boshqa ko‘p baytli Unicode belgilar bo‘lsa, bayt offseti bilan rune tartib raqami bir xil bo‘lmasligi mumkin.

O‘zbek va boshqa Unicode harflari bilan ishlash uchun `\p{L}` kabi Unicode sinflari foydali.

Misol:

```go
package main

import (
	"fmt"
	"regexp"
)

func main() {
	re := regexp.MustCompile(`^\p{L}+(?:[’']\p{L}+)*$`)

	fmt.Println(re.MatchString("g‘alaba"))
	fmt.Println(re.MatchString("o'zbek"))
	fmt.Println(re.MatchString("go123"))
}
```

Natija:

```text
true
true
false
```

Pattern:

```text
^\p{L}+(?:[’']\p{L}+)*$
```

ni qismlarga ajratamiz.

Birinchi qism:

```text
^\p{L}+
```

satr boshidan boshlab bir yoki undan ko‘p Unicode harf talab qiladi.

`\p{L}` faqat ASCII emas, Unicode bo‘yicha harf hisoblangan belgilarni qamrab oladi.

Keyingi qism:

```text
(?:[’']\p{L}+)*
```

ixtiyoriy ravishda apostrof va undan keyin yana harflar kelishiga ruxsat beradi.

```text
[’']
```

ikkita apostrof variantini qabul qiladi:

* tipografik apostrof: `’`;
* oddiy apostrof: `'`.

Shuning uchun:

```text
g‘alaba
```

mos keladi.

```text
o'zbek
```

ham mos keladi.

Lekin:

```text
go123
```

mos kelmaydi.

Sababi raqamlar `\p{L}` guruhiga kirmaydi.

Bu patternni real ism validatsiyasi sifatida qabul qilish kerak emas.

Haqiqiy ismlarda:

* tire;
* bo‘sh joy;
* bir nechta so‘z;
* turli apostrof belgilar;
* turli yozuv tizimlari

uchrashi mumkin.

Shuning uchun ism validatsiyasi loyiha talabiga qarab alohida biznes qoidalari bilan belgilanadi.

## Keng tarqalgan xatolar

Regex bilan ishlashda bir nechta xato tez-tez uchraydi.

* Validatsiya patternida `^` va `$`ni unutish. Bunda satrning faqat kichik qismi mos kelsa ham `MatchString()` `true` qaytarishi mumkin. Agar butun qiymat tekshirilayotgan bo‘lsa, chegaralarni aniq yozish kerak.

* Raw string va oddiy Go string escapingini aralashtirish. Regexda `\` ko‘p ishlatiladi. Shu sabab backtick bilan yozilgan raw string patternni o‘qishni ko‘pincha osonlashtiradi.

* `MustCompile()`ni foydalanuvchidan kelgan pattern bilan ishlatish. Noto‘g‘ri pattern panic keltirib chiqarishi mumkin. Tashqi pattern uchun `regexp.Compile()` va `error` handling ishlatiladi.

* Har requestda bir xil regexni qayta kompilyatsiya qilish. Doimiy patternni bir marta kompilyatsiya qilib, tayyor `*regexp.Regexp`ni qayta ishlatish yaxshiroq.

* `FindStringSubmatch()` natijasini `nil`ga tekshirmasdan indekslash. Moslik bo‘lmasa slice `nil` bo‘lishi mumkin va indeksga murojaat panic qiladi.

* `\w` barcha Unicode harflarini qamrab oladi deb o‘ylash. Go regexida `\w` ASCII asosida ishlaydi. Unicode harflar uchun `\p{L}` kabi sinflardan foydalanish kerak.

* Regexga moslikni ma’lumotning haqiqiyligi bilan tenglashtirish. `2025-99-99` sana formatiga o‘xshashi mumkin, lekin haqiqiy sana emas. Email, URL, telefon va boshqa qiymatlarda ham semantic validation alohida kerak bo‘ladi.

* Oddiy vazifani murakkab regex bilan hal qilish. Ba’zan `strings`, `strconv`, `time`, `net/url` yoki boshqa maxsus parser kodni ancha aniq va ishonchli qiladi.

## Interviewda nimalarga e’tibor beriladi?

Regex mavzusida Go bo‘yicha interviewda faqat sintaksis emas, `regexp` paketining xususiyatlari ham so‘ralishi mumkin.

Muhim jihatlardan biri `MatchString()`ning qisman moslikni qabul qilishi.

Masalan:

```go
re := regexp.MustCompile(`[0-9]+`)
fmt.Println(re.MatchString("ID: 42"))
```

bu yerda satrning faqat `42` qismi mos kelgani uchun natija `true` bo‘lishi mumkin.

Shuning uchun butun qiymat validatsiya qilinayotgan bo‘lsa:

```text
^
```

va:

```text
$
```

chegaralarining ahamiyatini tushunish kerak.

`Compile()` va `MustCompile()` farqi ham muhim.

`MustCompile()`:

* pattern noto‘g‘ri bo‘lsa panic qiladi;
* oldindan ma’lum constant patternlar uchun qulay.

`Compile()`:

* xatoni `error` sifatida qaytaradi;
* tashqi yoki dinamik patternlar uchun mosroq.

Go regexining RE2 asosida ishlashi ham muhim texnik jihat.

Bu yondashuv matching vaqtini kirish hajmiga nisbatan chiziqli saqlashga mo‘ljallangan va catastrophic backtracking muammosini cheklaydi.

Shu dizayn sabab Go regexida ayrim imkoniyatlar mavjud emas:

* backreference;
* lookahead;
* lookbehind.

Standart metodlarning vazifalarini ham ajrata bilish kerak:

```go
FindString()
```

birinchi moslikni topadi.

```go
FindAllString()
```

bir nechta yoki barcha mosliklarni qaytaradi.

```go
FindStringSubmatch()
```

to‘liq moslik bilan birga capturing grouplarni qaytaradi.

```go
ReplaceAllString()
```

mos kelgan qismlarni almashtiradi.

Unicode bilan ishlaganda `\w` va `\p{L}` o‘rtasidagi farqni bilish foydali.

Shuningdek, indeks qaytaruvchi metodlarning natijasi rune index emas, bayt offseti ekanini unutmaslik kerak.

Yana bir amaliy qoida:

```go
*regexp.Regexp
```

kompilyatsiyadan keyin qayta ishlatilishi mumkin va bir nechta goroutine tomonidan concurrent tarzda xavfsiz ishlatiladi.

Shuning uchun bir xil patternni request ichida qayta-qayta kompilyatsiya qilish odatda kerak emas.
