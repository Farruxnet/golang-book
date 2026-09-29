# Goda if, else if va else shart operatorlari

Dastur har doim bir xil buyruqlarni bajarmaydi. Ba'zan qiymat o'zgarish holatiga qarab turli mantiqlardan birini
tanlashi kerak. Masalan, foydalanuvchi voyaga yetgan bo'lsa tizimga kirishga ruxsat berish, aks holda rad etish mumkin.

Kodning shartga qarab turli yo'nalishda bajarilishi tarmoqlanish (branching) deyiladi. Bunday tarmoqlanish `if`,
`else if` va `else` yordamida amalga oshiriladi.

## `if` sharti

`if` berilgan mantiqiy ifodani tekshiradi. Ifoda `true` bo'lsa, `{` va `}` orasidagi kod bajariladi. `false` bo'lsa,
keyingi qismga o'tkazib yuboriladi.

```go
if mantiqiyIfoda {
	// Shart true bo'lsa, bu yerdagi kod bajariladi.
}
```

Masalan:

```go
package main

import "fmt"

func main() {
	harorat := 32
	harorat_issiq := harorat > 30 // 30 dan baland bo'lsa issiq deb belgilash
	if harorat_issiq {
		fmt.Println("Bugun havo issiq.")
	}
}
```

**Natija:**

```text
Bugun havo issiq.
```

`harorat > 30` taqqoslashning natijasi `true`, shuning uchun xabar ekranga chiqadi. `harorat` qiymati `25` bo'lsa, `if`
bloki bajarilmaydi.

> **Ma'lumot**
>
> Goda `if` sharti blokida jingalak qavslar bo'lishi majburiy, blokda faqat bitta buyruq bo'lsa ham qavslar yoziladi.

## Shart `bool` bo'lishi kerak

`if` ichidagi ifoda `bool`, ya'ni `true` yoki `false` qiymat qaytarishi kerak:

```go
yosh := 20
if yosh >= 18 {
	fmt.Println("Voyaga yetgan")
}
```

**Natija:**

```text
Voyaga yetgan
```

Go bazi tillardagi kabi `0`ni `false`, boshqa sonlarni `true` deb qabul qilmaydi:

```go
son := 1
// if son { } // kompilyatsiya xatosi: son bool emas
```

## Foydalanuvchi yoshini tekshirish

Konsoldan yosh qiymatini olib, foydalanuvchi 18 yoshdan katta bo'lsa xabar chiqaramiz:

```go
package main

import "fmt"

func main() {
	var yosh int

	fmt.Print("Yoshingizni kiriting: ")
	_, err := fmt.Scan(&yosh)
	if err != nil {
		fmt.Println("Xato: yoshni butun son bilan kiriting.")
		return
	}

	if yosh > 18 {
		fmt.Println("Xush kelibsiz!")
	}
}
```

`19` kiritilsa:

```text
Yoshingizni kiriting: 19
Xush kelibsiz!
```

`18` kiritilsa, xabar chiqmaydi. Sababi `18 > 18` ifodasi `false`. Agar 18 yosh ham ruxsat etilgan bo'lsa, katta yoki
teng operatori ishlatish kerak:

```go
if yosh >= 18 {
	fmt.Println("Xush kelibsiz!")
}
```

Qiymatlar chegarasini aniq tanlash muhim:

- `yosh > 18` - faqat 19 va undan katta qiymatlar;
- `yosh >= 18` - 18 hamda undan katta qiymatlar;
- `yosh < 18` - 18 dan kichik qiymatlar;
- `yosh <= 18` - 18 hamda undan kichik qiymatlar.

**Ma'lumot**

`_, err := fmt.Scan(&yosh)` qanday ishlaydi?
***
`fmt.Scan(&yosh)` foydalanuvchi kiritgan qiymatni o‘qiydi va **ikkita natija** qaytaradi:
1. nechta qiymat muvaffaqiyatli o‘qilganini;
2. o‘qish vaqtida yuz bergan xatoni.
```go
_, err := fmt.Scan(&yosh)
```
Bu yerda:
- `_` — birinchi natija bizga kerak emasligini bildiradi. Go tilida `_` **bo‘sh identifikator** deb ataladi. U qiymatni qabul qiladi, lekin saqlamaydi;
- `err` — xato haqidagi qiymatni saqlaydi. Agar foydalanuvchi yosh o‘rniga matn kiritsa, `err` xato qiymatiga ega bo‘ladi;
- `:=` — `err` o‘zgaruvchisini yaratadi va unga qiymat beradi;
- `&yosh` — kiritilgan qiymatni `yosh` o‘zgaruvchisiga yozish uchun uning xotiradagi manzilini `fmt.Scan` funksiyasiga uzatadi.
Masalan, foydalanuvchi `25` kiritsa, `fmt.Scan` taxminan quyidagi natijalarni qaytaradi:
```go
1, nil
```
Bu `1` ta qiymat muvaffaqiyatli o‘qilganini va xato bo‘lmaganini bildiradi. Bizga birinchi natija kerak bo‘lmagani uchun uni `_` bilan e’tiborsiz qoldiramiz.
Agar foydalanuvchi `yigirma` deb kiritsa, qiymat `int` turiga mos kelmaydi va `err` ichida xato paydo bo‘ladi:
```go
if err != nil {
    fmt.Println("Xato: yoshni butun son bilan kiriting.")
    return
}
```
Go tilida `nil` — xato yo‘q degani. `err != nil` bo‘lsa, demak, qiymatni o‘qishda xato yuz bergan.

## else aks holda

Faqat `if` ishlatilsa, shart `false` bo'lganida hech qanday kod bajarilmaydi. Xabarni `if` blokidan keyin oddiy
yozish ham muammoni hal qilmaydi:

```go
if yosh >= 18 {
	fmt.Println("Xush kelibsiz!")
}

fmt.Println("Mumkin emas!")
```

Bu kodda `Mumkin emas!` har doim chiqadi. Yosh `20` bo'lsa, ikkala xabar ham ko'rinadi, chunki ikkinchi `Println()` hech
qanday shart ichida emas.

Ikki yo'nalishdan aynan bittasini bajarish uchun `else` ishlatiladi:

```go
if mantiqiyIfoda {
	// Shart true bo'lsa bajariladi.
} else {
	// Shart false bo'lsa bajariladi.
}
```

Yosh misolini `else` bilan to'ldiramiz:

```go
package main

import "fmt"

func main() {
	var yosh int

	fmt.Print("Yoshingizni kiriting: ")
	_, err := fmt.Scan(&yosh)
	if err != nil {
		fmt.Println("Xato: yoshni butun son bilan kiriting.")
		return
	}

	if yosh >= 18 {
		fmt.Println("Xush kelibsiz!")
	} else {
		fmt.Println("Mumkin emas!")
	}
}
```

`15` kiritilsa:

```text
Yoshingizni kiriting: 15
Mumkin emas!
```

`18` kiritilsa:

```text
Yoshingizni kiriting: 18
Xush kelibsiz!
```

`if` va `else` bloklaridan faqat bittasi bajariladi. Shart `true` bo'lsa `if`, aks holda `else` ishlaydi.

## else if bir nechta shart

Ba'zan ikkita emas, bir nechta holatdan birini tanlash kerak. `else if` qo'shimcha shartlarni ketma-ket tekshiradi:

```go
if birinchiShart {
	// Birinchi shart true bo'lsa bajariladi.
} else if ikkinchiShart {
	// Birinchi false, ikkinchi true bo'lsa bajariladi.
} else if uchinchiShart {
	// Oldingi shartlar false, uchinchi true bo'lsa bajariladi.
} else {
	// Hech bir shart true bo'lmasa bajariladi.
}
```

Go shartlarni yuqoridan pastga tekshiradi. Birinchi `true` shartning bloki bajarilgach, qolgan `else if` va `else`
qismlari tekshirilmaydi.

```go
package main

import "fmt"

func main() {
	var yosh int

	fmt.Print("Yoshingizni kiriting: ")
	_, err := fmt.Scan(&yosh)
	if err != nil {
		fmt.Println("Xato: yoshni butun son bilan kiriting.")
		return
	}

	if yosh >= 30 {
		fmt.Println("Siz 30 yosh yoki undan kattasiz.")
	} else if yosh >= 18 {
		fmt.Println("Xush kelibsiz!")
	} else {
		fmt.Println("Mumkin emas!")
	}
}
```

Bu yerda oraliqlar quyidagicha taqsimlanadi:

|                Yosh | Bajariladigan blok   |
|--------------------:|----------------------|
| `30` va undan katta | `if yosh >= 30`      |
| `18` dan `29` gacha | `else if yosh >= 18` |
|     `18` dan kichik | `else`               |

Ikkinchi shartda `yosh < 30` deb yozish shart emas. Dastur shu qatorga kelgan bo'lsa, birinchi `yosh >= 30` sharti
allaqachon `false` bo'lgan bo'ladi.

## Shartlar tartibi muhim

Kengroq shart oldin yozilsa keyingi aniqroq shart bajarilmasligi mumkin:

```go
if yosh >= 18 {
	fmt.Println("18 yoki undan katta")
} else if yosh >= 30 {
	fmt.Println("30 yoki undan katta")
}
```

Bu kodda `yosh >= 30` bloki hech qachon bajarilmaydi. Masalan, `35` birinchi `yosh >= 18` shartiga mos keladi va
tekshiruv shu yerda tugaydi.

To'g'ri tartib aniqroq yoki yuqori chegarali shartni oldin yozish!

```go
if yosh >= 30 {
	fmt.Println("30 yoki undan katta")
} else if yosh >= 18 {
	fmt.Println("18 dan 29 gacha")
}
```

## Bir nechta shartlarni birlashtirish

`&&`, `||` va `!` operatorlari yordamida bir nechta tekshiruvni bitta shartga birlashtirish mumkin.

### `&&`: barcha shartlar bajarilishi kerak

```go
package main

import "fmt"

func main() {
	yosh := 24
	chiptasiBor := true

	if yosh >= 18 && chiptasiBor {
		fmt.Println("Tadbirga kirishingiz mumkin.")
	} else {
		fmt.Println("Kirish uchun yosh va chipta bo'lishi kerak.")
	}
}
```

`&&` ishlatilganda ikkala shart ham `true` bo'lishi kerak.

### `||`: shartlardan bittasi yetarli

```go
damOlishKuni := true
tatil := false

if damOlishKuni || tatil {
	fmt.Println("Bugun dam olish mumkin.")
}
```

`||` ishlatilganda kamida bitta shart `true` bo'lsa, blok bajariladi.

### `!`: qiymatni inkor qilish

```go
bloklangan := false

if !bloklangan {
	fmt.Println("Foydalanuvchi faol.")
}
```

`!bloklangan` qiymati `bloklangan == false` bilan bir xil ma'noni beradi, ammo ko'pincha qisqaroq ko'rinish bo'lgani uchun
inkor ko'rinishidan foydalaniladi.

## Qiymat oralig'ini tekshirish

Son ma'lum oraliqda ekanini tekshirish ko'p uchraydi. Masalan, imtihon bali `0` dan `100` gacha
bo'lishi kerak:

```go
package main

import "fmt"

func main() {
	var ball int

	fmt.Print("Natijani kiriting: ")
	_, err := fmt.Scan(&ball)
	if err != nil {
		fmt.Println("Xato: butun son kiriting.")
		return
	}

	if ball < 0 || ball > 100 {
		fmt.Println("Xato: natija 0 dan 100 gacha bo'lishi kerak.")
	} else if ball >= 86 {
		fmt.Println("A'lo")
	} else if ball >= 71 {
		fmt.Println("Yaxshi")
	} else if ball >= 56 {
		fmt.Println("Qoniqarli")
	} else {
		fmt.Println("Qoniqarsiz")
	}
}
```

Avval noto'g'ri oraliq tekshirildi. Keyin baholar yuqoridan pastga qarab joylashtirildi. Masalan, `90` birinchi baholash
shartiga mos keladi; `75` birinchisidan o'tmay, ikkinchisiga mos keladi.

## Ichma-ich `if`

Bir `if` blokining ichida boshqa `if` yozish mumkin. Bu ichma-ich shart (nested `if`) deyiladi:

```go
package main

import "fmt"

func main() {
	tizimgaKirdi := true
	admin := false

	if tizimgaKirdi {
		fmt.Println("Shaxsiy sahifa ochildi.")

		if admin {
			fmt.Println("Boshqaruv paneli ochildi.")
		}
	} else {
		fmt.Println("Avval tizimga kiring.")
	}
}
```

Ichki `if admin` faqat tashqi `tizimgaKirdi` sharti `true` bo'lganda tekshiriladi.

Ichma-ich bloklar ko'payib ketsa, kodni o'qish qiyinlashadi. Oddiy mantiqiy operator yoki `return` bilan soddalashtirish 
mumkin.

## `if` ichida qisqa e'lon

Go `if` shartidan oldin qisqa buyruq yozishga ruxsat beradi. Buyruq va shart nuqtali vergul bilan ajratiladi:

```go
package main

import "fmt"

func main() {
	pul := 3

	if hisob := pul; hisob > 5 {
		fmt.Println("Mablag':", hisob)
	} else {
		fmt.Println("Yetarli emas", hisob)
	}
}
```

`hisob := pul;` avval bajariladi, keyin `hisob > 5` tekshiriladi.

Qisqa e'londa yaratilgan o'zgaruvchi faqat `if`, unga bog'langan `else if` va `else` bloklarida ishlaydi:

```go
if son := 10; son > 0 {
	fmt.Println(son)
}

// fmt.Println(son) // bu yerda songa murojaat qilib bo'lmaydi
```

Bu usul vaqtinchalik natija faqat shart ichida kerak bo'lganda qulay. Masalan, funksiya qaytargan `err`ni tekshirishda
ko'p ishlatiladi.

## Murojaat qilish chegarasi

`if` ichida e'lon qilingan o'zgaruvchiga shu blokdan tashqarida murojaat qilib bo'lmaydi:

```go
yosh := 20

if yosh >= 18 {
	xabar := "Xush kelibsiz"
	fmt.Println(xabar)
}

// fmt.Println(xabar) // kompilyatsiya xatosi
```

`xabar` faqat `if`ning `{}` bloki ichida mavjud. Agar qiymat blokdan keyin ham kerak bo'lsa, o'zgaruvchini `if`dan oldin
e'lon qilish kerak:

```go
xabar := "Mumkin emas"

if yosh >= 18 {
	xabar = "Xush kelibsiz"
}

fmt.Println(xabar)
```

## `return` bilan kodni soddalashtirish

Xato holatlarni boshida tekshirib, funksiyani darhol tugatish ichma-ich shartlarni kamaytiradi:

```go
package main

import "fmt"

func main() {
	var yosh int

	fmt.Print("Yoshingizni kiriting: ")
	_, err := fmt.Scan(&yosh)
	if err != nil {
		fmt.Println("Xato: butun son kiriting.")
		return
	}

	if yosh < 0 || yosh > 150 {
		fmt.Println("Xato: yosh 0 dan 150 gacha bo'lishi kerak.")
		return
	}

	if yosh < 18 {
		fmt.Println("Mumkin emas!")
		return
	}

	fmt.Println("Xush kelibsiz!")
}
```

Har bir noto'g'ri holat tekshirilgach, `return` `main()` funksiyasi ishini tugatadi. Ortiqcha `else` va
va ichma-ich shartlar tekshirilmaydi.

## `if` va `else if` lardan foydalanish farqi

Bir nechta `if` ishlatilsa bir nechta blok bajariladi:

```go
son := 12

if son > 0 {
	fmt.Println("Musbat")
}

if son%2 == 0 {
	fmt.Println("Juft")
}
```

Natijada `Musbat` ham, `Juft` ham chiqadi. Chunki ikkala shart alohida tekshiriladi.

`if`–`else if`–`else` zanjirida esa faqat birinchi mos blok bajariladi:

```go
if son < 0 {
	fmt.Println("Manfiy")
} else if son == 0 {
	fmt.Println("Nol")
} else {
	fmt.Println("Musbat")
}
```

Bir nechta har-xil holatlar sharti bir vaqtda tekshirilsa faqat `if`lardan, bir-birini istisno qiladigan holatlardan 
bittasi tanlanadigan holatlarda `else if` mos keladi.

> **Diqqat**
>
> `fmt.Scan(&)` natijasini tekshirmaslik matn yoki noto'g'ri format kiritilganda dastur xato qiymat bilan davom
> etishiga sabab bo'lishi mumkin. Tashqaridan kelgan qiymatning turi va ruxsat etilgan shartlarga mosligini doim tekshiring.

Keyingi qismda bir qiymatni bir nechta aniq variant bilan solishtirish uchun `switch` operatoridan 
foydalanishni o'rganamiz.

## Misollar

### 1. Sonning ishorasini aniqlash

```go
package main

import "fmt"

func main() {
	son := -7
	if son > 0 {
		fmt.Println("Musbat")
	} else if son < 0 {
		fmt.Println("Manfiy")
	} else {
		fmt.Println("Nol")
	}
}
```

Uch holat bir-birini istisno qiladi, shuning uchun ulardan faqat bittasi bajariladi.

### 2. Kabisa yilini tekshirish

```go
package main

import "fmt"

func main() {
	yil := 2024
	kabisa := yil%400 == 0 || yil%4 == 0 && yil%100 != 0
	if kabisa {
		fmt.Println("Kabisa yili")
	} else {
		fmt.Println("Oddiy yil")
	}
}
```

`400`ga bo‘linadigan yoki `4`ga bo‘linib, `100`ga bo‘linmaydigan yil kabisa bo‘ladi.

### 3. Uch sondan kattasini topish

```go
package main

import "fmt"

func main() {
	a, b, c := 12, 27, 19
	katta := a
	if b > katta {
		katta = b
	}
	if c > katta {
		katta = c
	}
	fmt.Println(katta)
}
```

Har bir mustaqil `if` joriy eng katta qiymatni yangilashi mumkin.

### 4. Uchburchak mavjudligini tekshirish

```go
package main

import "fmt"

func main() {
	a, b, c := 3, 4, 5
	if a > 0 && b > 0 && c > 0 && a+b > c && a+c > b && b+c > a {
		fmt.Println("Uchburchak mavjud")
	} else {
		fmt.Println("Uchburchak mavjud emas")
	}
}
```

Tomonlar musbat va istalgan ikki tomon yig‘indisi uchinchi tomondan katta bo‘lishi kerak.

### 5. Ichma-ich tekshiruv

```go
package main

import "fmt"

func main() {
	login, parol := "admin", "go123"
	if login == "admin" {
		if parol == "go123" {
			fmt.Println("Kirish muvaffaqiyatli")
		} else {
			fmt.Println("Parol noto‘g‘ri")
		}
	} else {
		fmt.Println("Foydalanuvchi topilmadi")
	}
}
```

Ichki `if` faqat login to‘g‘ri bo‘lganda parolni tekshiradi.

### 6. `if` ichida o‘zgaruvchi e’lon qilish

```go
package main

import "fmt"

func main() {
	if son := 42; son%2 == 0 {
		fmt.Println(son, "juft son")
	} else {
		fmt.Println(son, "toq son")
	}
}
```

`son` boshlang‘ich qismda e’lon qilinadi. U faqat shu `if` hamda uning `else` blokida ko‘rinadi.

### 7. Bo‘sh qiymatga standart nom berish

```go
package main

import "fmt"

func main() {
	ism := ""
	if ism == "" {
		ism = "Mehmon"
	}
	fmt.Println("Salom,", ism)
}
```

Bitta shartli o‘zgarish uchun `else` yozish shart emas.

### 8. Chegirma darajasini tanlash

```go
package main

import "fmt"

func main() {
	xarid := 750_000
	chegirma := 0
	if xarid >= 1_000_000 {
		chegirma = 15
	} else if xarid >= 500_000 {
		chegirma = 10
	} else if xarid >= 100_000 {
		chegirma = 5
	}
	fmt.Println(chegirma, "%")
}
```

Tekshiruv katta chegaradan boshlanadi. Aks holda kichik chegara avval mos kelib qoladi.

### 9. Nolga bo‘lishdan oldin tekshirish

```go
package main

import "fmt"

func main() {
	son, boluvchi := 20, 0
	if boluvchi != 0 {
		fmt.Println("Natija:", son/boluvchi)
	} else {
		fmt.Println("Nolga bo‘lish mumkin emas")
	}
}
```

Bo‘lish amali faqat bo‘luvchi nol bo‘lmaganda bajariladi. Bu tekshiruv dasturning bajarilish vaqtida xato bilan to‘xtashini oldini oladi.

### 10. Qiymatni oraliqqa keltirish

```go
package main

import "fmt"

func main() {
	ovoz := 120
	if ovoz < 0 {
		ovoz = 0
	} else if ovoz > 100 {
		ovoz = 100
	}
	fmt.Println(ovoz)
}
```

Natija `100`. Bu usul tashqi qiymatning ruxsat etilgan chegaradan chiqib ketishiga yo‘l qo‘ymaydi.
