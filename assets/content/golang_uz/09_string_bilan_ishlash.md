# Goda `string` bilan ishlash

`string` matn va ixtiyoriy baytlar ketma-ketligini saqlaydigan tur. Foydalanuvchi nomi, URL, fayl manzili, JSON
kabi qiymatlar dasturlarda ko'pincha `string` ko'rinishida ishlatiladi.

String bilan to'g'ri ishlash uchun uchta tushunchani farqlash muhim:

* **baytlar** - matnning xotirada saqlanishi;
* **Unicode kodi** - har bir belgiga berilgan qiymat;
* **foydalanuvchi ko'radigan belgilar** - ekranda bitta belgi sifatida ko'rinadigan harf, raqam yoki belgi.

Bu uchalasining soni har doim ham bir xil bo'lmaydi. Masalan, ingliz tilidagi oddiy harf ko'pincha bitta bayt egallaydi.
O'zbek tilidagi ayrim harflar yoki emoji esa bir nechta baytdan iborat bo'lishi mumkin.

## String literal va o'zgarmaslik

Go tilida matnni ikki xil usulda yozish mumkin.

Qo'shtirnoq ichida yozilgan string **interpreted string literal** deyiladi. Unda `\n`, `\t` va `\"` kabi maxsus
ketma-ketliklar alohida ma'noga ega:

```go
matn := "Salom\nDunyo"
```

Bu yerda `\n` yangi qatorga o'tishni bildiradi.

Backtick ichida yozilgan string esa **raw string literal** deyiladi. Undagi matn deyarli qanday yozilgan bo'lsa, shunday
saqlanadi. Maxsus ketma-ketliklar talqin qilinmaydi va matnni bir nechta qatorda yozish mumkin:

```go
matn := `Salom\nDunyo`
```

Bu holatda `\n` yangi qator emas, oddiy ikkita belgi sifatida saqlanadi.

```go
package main

import "fmt"

func main() {
	line := "Birinchi qator\nIkkinchi qator"
	path := `C:\temp\main.go`

	fmt.Println(line)
	fmt.Println(path)
}
```

**Natija:**

```text
Birinchi qator
Ikkinchi qator
C:\temp\main.go
```

Bitta tirnoq ichidagi `'A'` string emas, `rune` literaldir. `rune` bitta Unicodeni ifodalaydi va `int32`
turining boshqa nomi hisoblanadi.

Goda string o'zgarmas (immutable) bo'ladi. Yaratilgan string ichidagi baytni almashtirib bo'lmaydi:

```go
text := "Go"
// text[0] = 'N' // kompilyatsiya xatosi: string elementiga qiymat berib bo'lmaydi
```

`text = "No"` esa mumkin. Bu eski stringni o'zgartirmaydi, `text` o'zgaruvchisiga boshqa string qiymatini beradi.

## String, `byte` va `rune`

String ixtiyoriy baytlarni saqlashi mumkin. Go matn uchun ko'pincha UTF-8dan foydalanadi, lekin `string` qiymatining
o'zi uning ichidagi baytlar to'g'ri UTF-8 ekanini kafolatlamaydi.

- `byte` bitta baytni ifodalaydi va `uint8` turining boshqa nomi;
- `rune` Unicode kodni ifodalaydi va `int32` turining boshqa nomi;
- ASCII belgilar UTF-8da bir bayt, boshqa belgilar esa bir necha bayt egallaydi.

```go
package main

import (
	"fmt"
	"unicode/utf8"
)

func main() {
	text := "Go tili - zo'r"

	fmt.Println("Baytlar:", len(text))
	fmt.Println("Rune soni:", utf8.RuneCountInString(text))
	for index, char := range text {
		fmt.Printf("%2d: %c\n", index, char)
	}
}
```

Natija:

```text
Baytlar: 18
Rune soni: 14
 0: G
 1: o
 2: (bo'sh joy)
 3: t
```

`len(text)` belgilarni emas, baytlarni sanaydi. `utf8.RuneCountInString()` Unicodelarni sanaydi. `range` har
safar bitta UTF-8 kodlangan runeni beradi, indeks esa shu runening boshlanish bayt o'rni.

> **Ma'lumot**
>
> Rune soni foydalanuvchi ko'radigan belgilar soniga har doim teng emas. Ayrim belgilar bir nechta Unicodedan tuziladi.
> Go standart kutubxonasi bir nechta belgilardan tashkel topgan ma'lumotlarni sanaydigan umumiy funksiyaga ega emas.

## Indeks orqali baytlarni olish

`text[i]` `i`-indeksdagi baytni `byte` sifatida qaytaradi:

```go
package main

import "fmt"

func main() {
	text := "Go"
	first := text[0]

	fmt.Println(first)
	fmt.Printf("%c\n", first)
}
```

**Natija:**

```text
71
G
```

`71` - `G`ning UTF-8 va ASCII dagi bayt qiymati. `%c` shu qiymatni belgi sifatida chiqaradi. Indeks manfiy bo'lsa yoki
`len(text)`ga teng yoki undan katta bo'lsa dastur runtime paytida xatolik qaytaradi(panic).

Ko'p baytli belgining faqat bir baytini olish to'liq belgini bermaydi. Unicode matnni belgilar bo'yicha qayta ishlash
uchun `range` yoki `[]rune` ishlatiladi:

```go
package main

import "fmt"

func main() {
	text := "O'zbek"
	runes := []rune(text)

	fmt.Printf("Birinchi rune: %c\n", runes[0])
	fmt.Printf("Uchinchi rune: %c\n", runes[2])
}
```

Natija:

```text
Birinchi rune: O
Uchinchi rune: z
```

`[]rune(text)` yangi rune slice va unga mos xotira yaratadi. Matnni faqat bir marta ketma-ket o'qish kerak bo'lsa,
`range` odatda kamroq xotira ishlatadi.

## Stringlarni birlashtirish va taqqoslash

Kichik miqdordagi stringlarni `+` bilan birlashtirish mumkin. `==` va `!=` baytlar ketma-ketligining tengligini
tekshiradi. `<`, `>`, `<=` va `>=` esa leksikografik, ya'ni bayt qiymatlari tartibida solishtiradi.

```go
package main

import "fmt"

func main() {
	firstName := "Ali"
	lastName := "Valiyev"
	fullName := firstName + " " + lastName

	fmt.Println(fullName)
	fmt.Println(fullName == "Ali Valiyev")
	fmt.Println("Go" < "Rust")
}
```

Natija:

```text
Ali Valiyev
true
true
```

## `strings.Builder` yordamida string yaratish

Bir nechta kichik stringni `+` operatori bilan qo'shish oddiy holatlarda qulay:

```go
matn := "Salom, " + "dunyo!"
```

Lekin katta sikl ichida stringlarni qayta-qayta `+` bilan qo'shish samarasiz bo'lishi mumkin. Sababi Go stringlari
o'zgarmas bo'lgani uchun har bir qo'shish jarayonida yangi string yaratilishi va qo'shimcha xotira ajratilishi mumkin.

Ko'p miqdordagi matn qismlarini yig'ish uchun `strings.Builder` ishlatiladi:

```go
package main

import (
	"fmt"
	"strings"
)

func main() {
	var builder strings.Builder

	for i := 1; i <= 3; i++ {
		if i > 1 {
			builder.WriteString(", ")
		}

		fmt.Fprint(&builder, i)
	}

	fmt.Println(builder.String())
}
```

Natija:

```text
1, 2, 3
```

Bu kodda:

* `var builder strings.Builder` - matn qismlarini yig'ish uchun builder yaratadi;
* `builder.WriteString(", ")` - builder ichiga vergul va bo'sh joy yozadi;
* `fmt.Fprint(&builder, i)` - sonni matn ko'rinishida builder ichiga yozadi;
* `builder.String()` - yig'ilgan natijani oddiy `string` qiymatiga aylantiradi.

`if i > 1` sharti vergulni birinchi sondan oldin emas, faqat keyingi sonlar orasiga qo'yish uchun ishlatilgan.

`strings.Builder` qismlarni ichki bufferda yig'adi. Tayyor natija `String()` bilan olinadi.

## string qismini olish

`text[start:end]` `start` indeksidan boshlab `end` indeksigacha, ammo `end`ning o'zini olmasdan baytlar oralig'ini
qaytaradi:

```go
package main

import "fmt"

func main() {
	text := "Salom, dunyo!"

	fmt.Println(text[:5])
	fmt.Println(text[7:12])
	fmt.Println(text[7:])
}
```

**Natija:**

```text
Salom
dunyo
dunyo!
```

Chegaralar bayt indekslari hisoblanadi. `0 <= start <= end <= len(text)` bo'lmasa dastur xato qaytaradi. UTF-8 belgining
o'rtasidan kesish noto'g'ri natija hosil qilishi mumkin.

Unicode bo'yicha kesish kerak bo'lsa, avval `[]rune`ga o'tkaziladi:

```go
runes := []rune("Go'zal")
part := string(runes[:3]) // "Go'"
```

## String qismini nusxalash

Katta stringdan kichik bir qism ajratib olinganda, hosil bo'lgan string ayrim holatlarda asl string saqlanayotgan
xotiradan foydalanishda davom etishi mumkin.

Masalan:

```go
kattaMatn := "juda katta hajmdagi matn..."
qism := kattaMatn[:4]
```

Bu yerda `qism` faqat kichik matnni ifodalasa ham, katta matnning xotirada uzoqroq saqlanib qolishiga sabab bo'lishi
mumkin.

Kichik qismning asl stringdan butunlay mustaqil nusxasi kerak bo'lsa, `strings.Clone` ishlatiladi:

```go
qism := strings.Clone(kattaMatn[:4])
```

`strings.Clone` berilgan stringning yangi nusxasini yaratadi. Shundan keyin `qism` asl katta stringning xotirasiga
bog'liq bo'lmaydi.

Biroq `strings.Clone` har doim ishlatilishi shart emas. Chunki u yangi xotira ajratadi va string ma'lumotlarini
nusxalaydi. Uni asosan quyidagi holatlarda qo'llash maqsadga muvofiq:

* kichik qism juda katta stringdan olingan bo'lsa;
* bu qism uzoq vaqt saqlansa;
* stringning nusxasi bo'lishi talab qilinsa.

Oddiy va qisqa muddatli operatsiyalarda esa string qismini bevosita ishlatish mumkin.

## `strings` paketi

Standart kutubxonadagi `strings` paketi qidirish, ajratish, birlashtirish, almashtirish va registrni o'zgartirish
funksiyalarini beradi.

### Qidirish va tekshirish

```go
package main

import (
	"fmt"
	"strings"
)

func main() {
	text := "Go dasturlash tili"

	fmt.Println(strings.Contains(text, "Go"))
	fmt.Println(strings.Count(text, "a"))
	fmt.Println(strings.HasPrefix(text, "Go"))
	fmt.Println(strings.HasSuffix(text, "tili"))
	fmt.Println(strings.Index(text, "dastur"))
	fmt.Println(strings.Index(text, "Python"))
}
```

Natija:

```text
true
3
true
true
3
-1
```

`Contains()` qism mavjudligini, `Count()` takrorlanmas sonini tekshiradi. `Index()` birinchi
topilgan bayt indeksini, topilmasa `-1`ni qaytaradi. Natijani indeks sifatida ishlatishdan oldin `-1` emasligini
tekshirish kerak.

`strings.ContainsAny(text, "abc")` ikkinchi argumentdagi runelardan kamida bittasi borligini tekshiradi. Butun qism
stringni qidirish uchun esa `Contains()` ishlatish kerak.

### Stringni ajratish va qayta birlashtirish

Go tilida stringni qismlarga ajratish uchun `strings.Split()` va `strings.Fields()`, qismlarni qayta birlashtirish uchun
esa `strings.Join()` ishlatiladi.

```go
package main

import (
	"fmt"
	"strings"
)

func main() {
	line := " go, backend ,api "
	parts := strings.Split(line, ",")

	for i := range parts {
		parts[i] = strings.TrimSpace(parts[i])
	}

	fmt.Println(parts)
	fmt.Println(strings.Join(parts, " | "))
	fmt.Println(strings.Fields("  Go\tbackend\nAPI  "))
}
```

Natija:

```text
[go backend api]
go | backend | api
[Go backend API]
```

`strings.Split(line, ",")` stringni vergul uchragan joylardan ajratadi:

```go
parts := strings.Split(line, ",")
```

Natijada quyidagi slice hosil bo'ladi:

```go
[" go" " backend " "api "]
```

Elementlarning boshida yoki oxirida bo'sh joylar qolishi mumkin. Shu sababli sikl ichida `strings.TrimSpace()` yordamida
ortiqcha bo'sh joylar olib tashlanadi:

```go
for i := range parts {
	parts[i] = strings.TrimSpace(parts[i])
}
```

`strings.Join()` slice ichidagi stringlarni berilgan ajratgich yordamida bitta stringga birlashtiradi:

```go
strings.Join(parts, " | ")
```

Natija:

```text
go | backend | api
```

`strings.Fields()` esa stringni bo'sh joylar bo'yicha ajratadi:

```go
strings.Fields("  Go\tbackend\nAPI  ")
```

Bu funksiya oddiy bo'sh joy bilan birga tab (`\t`), yangi qator (`\n`) va boshqa Unicode bo'sh joy belgilarini ham
ajratgich sifatida qabul qiladi. Ketma-ket kelgan bo'sh joylar bitta ajratgichdek hisoblanadi va natijaga bo'sh
elementlar qo'shilmaydi.

Asosiy farq:

* `Split()` faqat berilgan ajratgich bo'yicha ajratadi;
* `Split()` ayrim holatlarda bo'sh elementlarni ham saqlaydi;
* `Fields()` barcha ketma-ket bo'sh joylarni ajratgich deb oladi;
* `Fields()` bo'sh elementlarni natijaga qo'shmaydi;
* `Join()` slice elementlarini bitta stringga birlashtiradi.

`Split()` bo'sh elementlarni qanday hosil qilishini alohida misol bilan ko'rsatish foydali bo'ladi:

```go
fmt.Println(strings.Split("go,,api", ","))
// [go  api]
```

### String ichidagi matnni almashtirish va takrorlash

Go tilida string ichidagi ma'lum matnni boshqasiga almashtirish uchun `strings.Replace()` va `strings.ReplaceAll()`
funksiyalari ishlatiladi. Bir xil matnni bir necha marta takrorlash uchun esa `strings.Repeat()` qo'llaniladi.

```go
package main

import (
	"fmt"
	"strings"
)

func main() {
	text := "Go tez, Go sodda"

	fmt.Println(strings.Replace(text, "Go", "Golang", 1))
	fmt.Println(strings.ReplaceAll(text, "Go", "Golang"))
	fmt.Printf("%q\n", strings.Repeat("Go! ", 3))
}
```

Natija:

```text
Golang tez, Go sodda
Golang tez, Golang sodda
"Go! Go! Go! "
```

`strings.Replace()` string ichidagi eski matnni yangi matnga almashtiradi:

```go
strings.Replace(text, "Go", "Golang", 1)
```

Bu yerda:

* `text` — o'zgartiriladigan string;
* `"Go"` — qidiriladigan eski matn;
* `"Golang"` — uning o'rniga yoziladigan yangi matn;
* `1` — nechta uchrashuv almashtirilishini bildiradi.

Shuning uchun faqat birinchi `"Go"` almashtiriladi:

```text
Golang tez, Go sodda
```

Barcha uchrashuvlarni almashtirish uchun `-1` berish mumkin:

```go
strings.Replace(text, "Go", "Golang", -1)
```

Lekin bu maqsad uchun `strings.ReplaceAll()` aniqroq va o'qishga qulayroq:

```go
strings.ReplaceAll(text, "Go", "Golang")
```

Natijada string ichidagi barcha `"Go"` qiymatlari almashtiriladi:

```text
Golang tez, Golang sodda
```

`strings.Repeat()` berilgan stringni ko'rsatilgan miqdorda takrorlaydi:

```go
strings.Repeat("Go! ", 3)
```

Natija:

```text
Go! Go! Go! 
```

Misolda `%q` formatlash belgisi ishlatilgani sababli natija qo'shtirnoq ichida chiqariladi. Bu usul string oxiridagi
bo'sh joyni ham ko'rishga yordam beradi.

`Repeat()` funksiyasiga manfiy takrorlash soni berilsa yoki yaratiladigan string hajmi haddan tashqari katta bo'lsa,
dastur `panic` holatiga tushishi mumkin. Shu sababli takrorlash soni foydalanuvchidan yoki tashqi manbadan kelayotgan
bo'lsa, uni oldindan tekshirish kerak:

```go
if count >= 0 && count <= 100 {
	result := strings.Repeat("Go! ", count)
	fmt.Println(result)
}
```

### String boshidagi va oxiridagi belgilarni olib tashlash

Go tilida stringning boshi yoki oxiridagi keraksiz bo'sh joylar, prefikslar, suffikslar va boshqa belgilarni olib
tashlash uchun `strings` paketidagi `Trim` funksiyalaridan foydalaniladi.

```go
package main

import (
	"fmt"
	"strings"
)

func main() {
	value := "\t Go dasturlash tili \n"
	url := "https://go-lang.uz/"

	fmt.Printf("%q\n", strings.TrimSpace(value))
	fmt.Println(strings.TrimPrefix(url, "https://"))
	fmt.Println(strings.TrimSuffix(url, "/"))
	fmt.Println(strings.Trim("...Go...", "."))
}
```

Natija:

```text
"Go dasturlash tili"
go-lang.uz/
https://go-lang.uz
Go
```

`strings.TrimSpace()` stringning boshi va oxiridagi bo'sh joy belgilarini olib tashlaydi:

```go
strings.TrimSpace(value)
```

Bu funksiya oddiy bo'sh joy bilan birga tab (`\t`), yangi qator (`\n`) va boshqa Unicode bo'sh joy belgilarini ham
tozalaydi. String ichidagi bo'sh joylarga esa tegmaydi.

`strings.TrimPrefix()` string boshidagi aniq prefiksni olib tashlaydi:

```go
strings.TrimPrefix(url, "https://")
```

Natija:

```text
go-lang.uz/
```

`strings.TrimSuffix()` string oxiridagi aniq suffiksni olib tashlaydi:

```go
strings.TrimSuffix(url, "/")
```

Natija:

```text
https://go-lang.uz
```

Agar berilgan prefiks yoki suffiks stringda mavjud bo'lmasa, `TrimPrefix()` va `TrimSuffix()` asl stringni
o'zgartirmasdan qaytaradi.

`strings.Trim()` esa ikkinchi argumentni yaxlit matn sifatida emas, olib tashlanishi kerak bo'lgan belgilar to'plami
sifatida qabul qiladi:

```go
strings.Trim("...Go...", ".")
```

Bu yerda stringning boshi va oxiridagi barcha nuqtalar olib tashlanadi:

```text
Go
```

Masalan:

```go
fmt.Println(strings.Trim("!?Go?!", "!?"))
```

Natija:

```text
Go
```

Chunki `Trim()` stringning ikki chetidagi `!` va `?` belgilarini uchraganicha olib tashlaydi. String o'rtasidagi
belgilar esa saqlanib qoladi.

### Katta-kichik harflarga o'tkazish va registrni hisobga olmasdan taqqoslash

Go tilida stringdagi harflarni kichik yoki katta ko'rinishga o'tkazish uchun `strings.ToLower()` va `strings.ToUpper()`
funksiyalari ishlatiladi. Katta-kichik harflar farqini hisobga olmasdan ikkita stringni taqqoslash uchun esa
`strings.EqualFold()` qo'llaniladi.

```go
package main

import (
	"fmt"
	"strings"
)

func main() {
	value := "Go Dasturlash"

	fmt.Println(strings.ToLower(value))
	fmt.Println(strings.ToUpper(value))
	fmt.Println(strings.EqualFold("GO", "go"))
}
```

Natija:

```text
go dasturlash
GO DASTURLASH
true
```

`strings.ToLower()` stringdagi harflarni kichik harfga o'tkazadi:

```go
strings.ToLower("Go Dasturlash")
```

Natija:

```text
go dasturlash
```

`strings.ToUpper()` esa harflarni katta harfga o'tkazadi:

```go
strings.ToUpper("Go Dasturlash")
```

Natija:

```text
GO DASTURLASH
```

Bu funksiyalar yangi string qaytaradi. Asl string o'zgarmaydi, chunki Go'da stringlar o'zgarmas qiymat hisoblanadi.

`strings.EqualFold()` ikkita stringni katta-kichik harflar farqini hisobga olmasdan taqqoslaydi:

```go
strings.EqualFold("GO", "go")
```

Natija:

```text
true
```

Faqat registrni hisobga olmasdan tenglikni tekshirish kerak bo'lsa, ikkala stringni `ToLower()` yordamida o'zgartirib
taqqoslashdan ko'ra `EqualFold()` ishlatish ma'qul:

```go
// Ishlaydi, lekin maqsad unchalik aniq ko'rinmaydi
strings.ToLower(a) == strings.ToLower(b)

// Maqsadni aniqroq ifodalaydi
strings.EqualFold(a, b)
```

`EqualFold()` Unicode harflarini taqqoslash qoidalaridan foydalanadi. Shu sababli u oddiy ingliz harflaridan tashqari
boshqa yozuv tizimlari bilan ishlashda ham mosroq.

`strings.ToTitle()` nomiga qarab har bir so'zning faqat birinchi harfini katta qiladi deb o'ylash mumkin, ammo u bunday
ishlamaydi. Bu funksiya stringdagi har bir harfni Unicode qoidalariga ko'ra `title case` ko'rinishiga o'tkazadi:

```go
fmt.Println(strings.ToTitle("go dasturlash"))
```

Natija odatda:

```text
GO DASTURLASH
```

Shuning uchun `ToTitle()` tabiiy tildagi sarlavhalarni formatlash uchun mo'ljallanmagan. Masalan, ism yoki sarlavhadagi
har bir so'zning faqat birinchi harfini katta qilish qoidalari tilga qarab farq qiladi va alohida mantiq bilan
bajarilishi kerak.

### `strings.Map()` yordamida belgilarni o'zgartirish

`strings.Map()` string ichidagi har bir Unicode belgini, ya'ni `rune`ni, berilgan funksiya orqali qayta ishlaydi va
yangi string hosil qiladi.

Funksiya:

* rune qaytarsa, shu belgi natijaga qo'shiladi;
* boshqa rune qaytarsa, belgi almashtiriladi;
* `-1` qaytarsa, belgi natijadan olib tashlanadi.

Quyidagi misolda faqat harflar saqlanadi, raqam, nuqta va bo'sh joy esa olib tashlanadi:

```go
package main

import (
	"fmt"
	"strings"
	"unicode"
)

func main() {
	value := "Go 1.22"

	onlyLetters := strings.Map(func(char rune) rune {
		if unicode.IsLetter(char) {
			return char
		}

		return -1
	}, value)

	fmt.Println(onlyLetters)
}
```

Natija:

```text
Go
```

`strings.Map()` stringdagi runelarni bittadan `char` o'zgaruvchisiga uzatadi:

```go
func(char rune) rune
```

`unicode.IsLetter(char)` rune harf ekanini tekshiradi. Agar u harf bo'lsa, o'zgarishsiz qaytariladi:

```go
return char
```

Agar rune harf bo'lmasa, `-1` qaytariladi va u yangi stringga qo'shilmaydi:

```go
return -1
```

`strings.Map()` belgilarni faqat olib tashlash uchun emas, almashtirish uchun ham ishlatilishi mumkin. Masalan, barcha
bo'sh joylarni chiziqcha bilan almashtirish:

```go
result := strings.Map(func(char rune) rune {
	if unicode.IsSpace(char) {
		return '-'
	}

	return char
}, "Go dasturlash tili")

fmt.Println(result)
```

Natija:

```text
Go-dasturlash-tili
```

Bu usul matnni tozalash, normalizatsiya qilish yoki faqat ruxsat etilgan belgilarni qoldirishda foydali.

Biroq validatsiya va matnni tozalash bir xil vazifa emas. Noto'g'ri belgilar kiritilganda ularni jimgina olib tashlash
foydalanuvchi xatosini yashirishi mumkin. Agar kiritilgan qiymat qat'iy qoidalarga mos bo'lishi kerak bo'lsa, noto'g'ri
belgilarni o'chirish o'rniga foydalanuvchiga tushunarli xato xabari qaytarish ma'qul.

## Stringning UTF-8 formatida ekanini tekshirish

Godagi `string` aslida baytlar ketma-ketligidir. Shu sababli string ichida har doim ham to'g'ri UTF-8 matn bo'lishi
shart emas. Ayniqsa, ma'lumot fayl, tarmoq, ma'lumotlar bazasi yoki boshqa tashqi manbadan olinganda noto'g'ri baytlar
uchrashi mumkin.

Quyidagi misolda `0xff` bayti UTF-8 qoidalariga mos kelmaydi:

```go
package main

import (
	"fmt"
	"unicode/utf8"
)

func main() {
	value := string([]byte{0xff, 'G', 'o'})

	fmt.Println(utf8.ValidString(value))
	fmt.Printf("%q\n", value)
}
```

Natija:

```text
false
"\xffGo"
```

`utf8.ValidString()` string ichidagi baytlar to'g'ri UTF-8 ketma-ketligini hosil qilganini tekshiradi:

```go
utf8.ValidString(value)
```

Agar string to'g'ri UTF-8 bo'lsa, funksiya `true`, aks holda `false` qaytaradi.

Misolda `value` quyidagi baytlardan yaratilgan:

```go
[]byte{0xff, 'G', 'o'}
```

`'G'` va `'o'` baytlari to'g'ri UTF-8 belgilaridir, lekin `0xff` UTF-8 matnida yaroqli bayt hisoblanmaydi. Shu sababli
natija `false` bo'ladi.

`%q` formati stringni qo'shtirnoq va escape ketma-ketliklari bilan chiqaradi:

```go
fmt.Printf("%q\n", value)
```

Shuning uchun noto'g'ri bayt natijada `\xff` ko'rinishida ko'rsatiladi:

```text
"\xffGo"
```

Noto'g'ri UTF-8 string ustida `range` sikli ishlatilsa, Go yaroqsiz ketma-ketlik o'rniga `utf8.RuneError` qiymatini
qaytaradi. U ekranda odatda `�` belgisi ko'rinishida chiqadi:

```go
for _, char := range value {
	fmt.Printf("%c\n", char)
}
```

Taxminiy natija:

```text
�
G
o
```

Agar foydalanilayotgan protokol yoki fayl formati faqat UTF-8 matnni qabul qilsa, qiymatni qayta ishlashdan oldin
tekshirish kerak:

```go
if !utf8.ValidString(value) {
	fmt.Println("Xato: matn UTF-8 formatiga mos emas")
	return
}
```

Bu tekshiruv noto'g'ri kodlangan ma'lumotni keyingi bosqichlarga o'tkazmaslikka yordam beradi.

## Keng tarqalgan xatolar

### `len()` natijasini belgilar soni deb o'ylash

Go'da `len()` string ichidagi belgilarni emas, baytlar sonini qaytaradi.

ASCII belgilarida bitta belgi odatda bitta bayt egallaydi. Shu sababli oddiy inglizcha matnda `len()` natijasi belgilar
soniga tengdek ko'rinadi:

```go
text := "Go"

fmt.Println(len(text)) // 2
```

Unicode belgilarida esa bitta belgi bir nechta baytdan iborat bo'lishi mumkin:

```go
text := "Go😊"

fmt.Println(len(text))                    // 6 bayt
fmt.Println(utf8.RuneCountInString(text)) // 3 rune
```

Kod nuqtalari, ya'ni runelar sonini aniqlash uchun `utf8.RuneCountInString()` ishlatiladi.

Biroq foydalanuvchi ekranda ko'radigan belgilar soni rune soniga ham har doim teng bo'lmaydi. Masalan, ayrim emoji yoki
diakritik belgilar bir nechta runedan tuzilishi mumkin. Bunday holatda grapheme clusterlarni hisoblaydigan maxsus yechim
kerak bo'ladi.

### Stringni noto'g'ri bayt chegarasidan kesish

Stringni quyidagicha kesishda indekslar belgilarni emas, baytlarni bildiradi:

```go
part := text[a:b]
```

Agar Unicode belgi bir nechta baytdan iborat bo'lsa, uni o'rtasidan kesish noto'g'ri UTF-8 string hosil qilishi mumkin.

Masalan:

```go
text := "Go😊"
part := text[:3]

fmt.Printf("%q\n", part)
```

Bu kesish emojining faqat birinchi baytini olishi mumkin va natija yaroqsiz UTF-8 bo'ladi.

Runelar bo'yicha kesish kerak bo'lsa, stringni `[]rune` ga aylantirish mumkin:

```go
text := "Go😊"
runes := []rune(text)

part := string(runes[:3])

fmt.Println(part) // Go😊
```

Bu usul tushunarli, lekin yangi slice va string yaratgani sababli qo'shimcha xotira talab qiladi.

### `strings.Trim()` qism stringni olib tashlaydi deb o'ylash

`strings.Trim()` ikkinchi argumentni yaxlit qism string sifatida emas, olib tashlanadigan runelar to'plami sifatida
qabul qiladi.

Masalan:

```go
result := strings.Trim("abba", "ab")

fmt.Printf("%q\n", result)
```

Natija:

```text
""
```

Sababi funksiya stringning boshi va oxiridan barcha `a` hamda `b` runelarini olib tashlaydi.

Agar string boshidagi aniq `"ab"` qismini olib tashlash kerak bo'lsa, `TrimPrefix()` ishlatiladi:

```go
fmt.Println(strings.TrimPrefix("abba", "ab"))
// ba
```

String oxiridagi aniq qism uchun esa `TrimSuffix()` ishlatiladi:

```go
fmt.Println(strings.TrimSuffix("abba", "ba"))
// ab
```

### Harflar registrini o'zgartirish barcha matn muammolarini hal qiladi deb o'ylash

Matnni `ToLower()` yoki `ToUpper()` bilan o'zgartirish har doim ham tabiiy til qoidalariga to'liq mos kelmaydi. Unicode
registr qoidalari va turli tillardagi matn formatlash talablari murakkab bo'lishi mumkin.

Faqat katta-kichik harflarni hisobga olmasdan texnik tenglikni tekshirish kerak bo'lsa, `strings.EqualFold()` ishlatish
ma'qul:

```go
fmt.Println(strings.EqualFold("GO", "go"))
// true
```

Ammo foydalanuvchi ismlarini formatlash, lokal til qoidalari bo'yicha saralash yoki sarlavha yaratish uchun oddiy
`ToLower()` va `ToUpper()` yetarli bo'lmasligi mumkin. Bunday vazifalarda aniq mahsulot talabi va tilga mos maxsus
kutubxona kerak bo'ladi.

## Misollar

### 1. `strings.Builder` bilan matn yig'ish

```go
package main

import (
	"fmt"
	"strings"
)

func main() {
	var builder strings.Builder
	for i := 1; i <= 3; i++ {
		builder.WriteString(fmt.Sprintf("Qator %d\n", i))
	}
	fmt.Print(builder.String())
}
```

Ko'p bo'lakni ketma-ket birlashtirishda `Builder` har safar yangi string yaratishni kamaytiradi. Tayyor natija
`String()` bilan olinadi.

### 2. So'zlar orasidagi ortiqcha bo'shliqlarni tozalash

```go
package main

import (
	"fmt"
	"strings"
)

func main() {
	matn := "  Go\t tilini   o'rganamiz\n"
	toza := strings.Join(strings.Fields(matn), " ")
	fmt.Println(toza)
}
```

`Fields()` ketma-ket bo'sh joy, tab va yangi qatorlarni ajratuvchi deb oladi. `Join()` so'zlarni bitta bo'sh joy bilan
qayta birlashtiradi.

### 3. Bir nechta ajratuvchi bo'yicha bo'lish

```go
package main

import (
	"fmt"
	"strings"
)

func main() {
	qismlar := strings.FieldsFunc("olma,anor;uzum nok", func(r rune) bool {
		return r == ',' || r == ';' || r == ' '
	})
	fmt.Println(qismlar)
}
```

`FieldsFunc()` qaysi runelar ajratuvchi ekanini funksiya orqali belgilashga imkon beradi.

### 4. Prefiksni faqat mavjud bo'lsa olib tashlash

```go
package main

import (
	"fmt"
	"strings"
)

func main() {
	manzil := "https://go.dev"
	manzil = strings.TrimPrefix(manzil, "https://")
	fmt.Println(manzil)
}
```

`TrimPrefix()` faqat to'liq prefiks mos kelsa uni olib tashlaydi. `Trim()` esa berilgan belgilar to'plamini ikki chetdan
olib tashlaydi.

### 5. Stringni ajratgich bo'yicha ajratish

```go
package main

import (
	"fmt"
	"strings"
)

func main() {
	oldin, keyin, topildi := strings.Cut("lang=uz", "=")
	fmt.Println(oldin, keyin, topildi)
}
```

`Cut()` stringni birinchi ajratuvchigacha bo'lgan va undan keyingi qismlarga ajratadi. Uchinchi qiymat ajratuvchi
topilgan yoki topilmaganini bildiradi.

### 6. Qism string necha marta uchrashini sanash

```go
package main

import (
	"fmt"
	"strings"
)

func main() {
	matn := "go test, go build, go run"
	fmt.Println(strings.Count(matn, "go"))
}
```

Natija `3` bo'ladi. `Count()` bir-birini qoplamaydigan uchrashuvlarni sanaydi.

### 7. Faqat birinchi uchrashuvni almashtirish

```go
package main

import (
	"fmt"
	"strings"
)

func main() {
	matn := "xato: xato: fayl topilmadi"
	fmt.Println(strings.Replace(matn, "xato", "ogohlantirish", 1))
}
```

Oxirgi argument nechta uchrashuvni almashtirish kerakligini belgilaydi. `1` berilgani uchun faqat birinchi uchrashuv
almashtiriladi. `-1` berilsa, barcha uchrashuvlar almashtiriladi.

### 8. Unicode bo'yicha matnni teskari yozish

```go
package main

import "fmt"

func main() {
	runelar := []rune("Go'zal")
	for chap, ong := 0, len(runelar)-1; chap < ong; chap, ong = chap+1, ong-1 {
		runelar[chap], runelar[ong] = runelar[ong], runelar[chap]
	}
	fmt.Println(string(runelar))
}
```

Stringni baytlar bo'yicha teskari qilish ko'p baytli UTF-8 belgilarni buzishi mumkin. `[]rune` belgilar chegarasini
saqlaydi.

### 9. Har bir so'zning bosh harfini tekshirish

```go
package main

import (
	"fmt"
	"strings"
	"unicode"
)

func main() {
	for _, soz := range strings.Fields("Go Dasturlash Tili") {
		for _, birinchi := range soz {
			fmt.Println(soz, unicode.IsUpper(birinchi))
			break
		}
	}
}
```

Ichki `range` so'zning birinchi Unicode runesini xavfsiz oladi. `break` qolgan runelarni tekshirmaydi,
`unicode.IsUpper()` esa olingan runening katta harf ekanini aniqlaydi.

### 10. Stringning mustaqil nusxasini olish

```go
package main

import (
	"fmt"
	"strings"
)

func main() {
	katta := strings.Repeat("a", 1000) + "yakun"
	kichik := strings.Clone(katta[len(katta)-5:])
	fmt.Println(kichik)
}
```

Qism string ba'zan katta manba egallagan xotirani band qilib turishi mumkin. `strings.Clone()` qism stringning mustaqil
nusxasini yaratadi.
