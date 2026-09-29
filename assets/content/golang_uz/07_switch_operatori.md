# switch bir nechta holatdan birini tanlash

`switch` bir qiymat yoki shartga qarab bir nechta yo'ldan birini tanlaydi. Masalan, hafta kuni raqamidan kun nomini
topish, HTTP status kodini izohlash yoki foydalanuvchi roliga mos amalni bajarish mumkin.

Oldingi darsdagi `if` va `else if` ham tanlash uchun ishlatiladi. Biroq bitta qiymatni ko'p variant bilan solishtirganda
`switch` odatda ixchamroq va o'qilishi osonroq bo'ladi.

## Asosiy sintaksis

```go
switch ifoda {
case qiymat1:
	// ifoda qiymat1 ga teng bo'lsa bajariladi
case qiymat2:
	// ifoda qiymat2 ga teng bo'lsa bajariladi
default:
	// hech bir case mos kelmasa bajariladi
}
```

`switch` avval ifodani hisoblaydi. So'ng `case` qiymatlarini yuqoridan pastga solishtiradi. Birinchi mos kelgan `case` bloki
bajariladi va `switch` tugaydi. Hech biri mos kelmasa, ixtiyoriy `default` bloki bajariladi.

> **Ma'lumot**
>
> Goda har bir `case` oxiriga `break` yozish shart emas. Mos blok bajarilgach keyingi `case`ga avtomatik o'tilmaydi. Bu
> xususiyat Goni C, Java va JavaScript kabi tillardan ajratib turadi.

## Hafta kunini aniqlash

```go
package main

import "fmt"

func main() {
	var kun int

	fmt.Print("Hafta kuni raqamini kiriting (1-7): ")
	_, err := fmt.Scan(&kun)
	if err != nil {
		fmt.Println("Xato: butun son kiriting.")
		return
	}

	switch kun {
	case 1:
		fmt.Println("Dushanba")
	case 2:
		fmt.Println("Seshanba")
	case 3:
		fmt.Println("Chorshanba")
	case 4:
		fmt.Println("Payshanba")
	case 5:
		fmt.Println("Juma")
	case 6:
		fmt.Println("Shanba")
	case 7:
		fmt.Println("Yakshanba")
	default:
		fmt.Println("Xato: kun raqami 1 dan 7 gacha bo'lishi kerak.")
	}
}
```

`5` kiritilsa:

```text
Hafta kuni raqamini kiriting (1-7): 5
Juma
```

`kun` qiymati har bir `case` bilan solishtiriladi. `5` faqat `case 5`ga mos keladi. `0` yoki `8`
qiymatlar hech bir kunga mos emas, shuning uchun `default` xato xabarini chiqaradi. Matn kiritilsa, `fmt.Scan()`
qaytargan xato `err` o'zgaruvchisiga beriladi, `if` shart operatori tekshiradi va shu yerda ishni to'xtatadi.

## Bitta `case`da bir nechta qiymat

Bir nechta qiymatlar uchun bitta vazifani bajarish kerak bo'lsa, qiymatlarni vergul bilan bitta `case`ga yozish mumkin:

```go
package main

import "fmt"

func main() {
	kun := "shanba"

	switch kun {
	case "shanba", "yakshanba":
		fmt.Println("Dam olish kuni")
	case "dushanba", "seshanba", "chorshanba", "payshanba", "juma":
		fmt.Println("Ish kuni")
	default:
		fmt.Println("Noma'lum kun")
	}
}
```

Natija:

```text
Dam olish kuni
```

Vergul bu yerda **yoki** ma'nosini beradi. `kun` qiymati `"shanba"` yoki `"yakshanba"` bo'lsa, birinchi blok bajariladi.
Qiymatlar `kun` bilan taqqoslanadigan turda bo'lishi kerak. Masalan, switch ichida `string` turi bo'lsa, `case 1` ya'ni
boshqa turni yozib bo'lmaydi.

## Ifodasiz `switch`

`switch`dan keyingi ifodani yozmaslik mumkin. Bunda `switch true` kabi bo'ladi va har bir `case` mantiqiy shart bo'ladi:

```go
package main

import "fmt"

func main() {
	harorat := 28

	switch {
	case harorat < -50 || harorat > 60:
		fmt.Println("Harorat ruxsat etilgan oraliqdan tashqarida")
	case harorat < 0:
		fmt.Println("Sovuq")
	case harorat < 20:
		fmt.Println("Salqin")
	case harorat < 30:
		fmt.Println("Iliq")
	default:
		fmt.Println("Issiq")
	}
}
```

Natija:

```text
Iliq
```

Shartlar yuqoridan pastga tekshiriladi. `28 < 30` birinchi mos shart bo'lgani uchun `Iliq` chiqadi. Tartib muhim!
`harorat < 30`ni `harorat < 20`dan oldin yozsak, masalan `15` ham shartga mos kelib, `Salqin` bloki bajarilmay qoladi.

Ifodasiz `switch` murakkab `if`–`else if` zanjiriga o'qilishi qulay muqobil bo'la oladi. Oraliqlar, validatsiya va
bir-birini istisno qiladigan shartlarda ko'p qo'laniladi.

## `switch` ichida qisqa e'lon

`switch` ifodasidan oldin qisqa buyruq yozish mumkin. Buyruq va ifoda nuqtali vergul bilan ajratiladi:

```go
package main

import "fmt"

func main() {
	name := "  Go  "

	switch length := len(name); length {
	case 0:
		fmt.Println("Matn bo'sh")
	case 1, 2, 3:
		fmt.Println("Qisqa matn")
	default:
		fmt.Println("Matn uzunligi:", length)
	}
}
```

Natija:

```text
Matn uzunligi: 6
```

`length := len(name)` faqat bir marta bajariladi. `length` o'zgaruvchisi `case` va `default` bloklarida mavjud, ammo
`switch`dan tashqarida ko'rinmaydi. `len()` baytlar sonini qaytaradi.

## `break` va `fallthrough`

Oddiy `switch`da `break` kerak emas. Lekin blokni ertaroq tugatish zarur bo'lsa, undan foydalanish mumkin:

```go
switch holat {
case "tayyor":
	if bekorQilingan {
		break
	}
	fmt.Println("Ish boshlandi")
}
```

`break` eng yaqin `switch` yoki `for`ni tugatadi. Bu misolda `bekorQilingan` `true` bo'lsa, chop etish bajarilmaydi.

`fallthrough` mos kelgan blokdan keyingi `case`ni shartini tekshirmasdan bajaradi:

```go
package main

import "fmt"

func main() {
	daraja := 3

	switch daraja {
	case 3:
		fmt.Println("Asosiy imkoniyatlar")
		fallthrough
	case 2:
		fmt.Println("Qo'shimcha imkoniyatlar")
		fallthrough
	case 1:
		fmt.Println("Boshlang'ich imkoniyatlar")
	default:
		fmt.Println("Noma'lum daraja")
	}
}
```

Natija:

```text
Asosiy imkoniyatlar
Qo'shimcha imkoniyatlar
Boshlang'ich imkoniyatlar
```

> **Diqqat**
>
> `fallthrough` keyingi `case` shartini tekshirmaydi. Shu sababli ehtiyotkorlik bilan va kam ishlatiladi.

> **Maslahat**
>
> `fallthrough` blokdagi oxirgi buyruq bo'lishi kerak. Oxirgi `case`da ishlatilmaydi.

## Qaysi qiymatlarni solishtirish mumkin?

Oddiy `switch`da ifoda va `case` qiymatlari o'zaro taqqoslanadigan bo'lishi kerak. Sonlar, `string`, `bool`, pointer,
channel, shuningdek faqat taqqoslanadigan maydonlardan tuzilgan array va struct qiymatlari ishlashi mumkin. Slice, map
va function qiymatlarini oddiy tenglik bilan solishtirib bo'lmagani uchun ular `case` qiymati bo'la olmaydi.

`case` qiymatlari compile vaqtida ma'lum konstanta bo'lishi shart emas. Ifodalar ham ishlatilishi mumkin. Biroq bir xil
konstantali `case`ni takrorlash kompilyatsiya xatosiga olib keladi:

```go
// Noto'g'ri: ikkala case ham bir xil qiymat.
switch son {
case 1:
	fmt.Println("bir")
case 1:
	fmt.Println("yana bir")
}
```

> **Ma'lumot**
>
> `default` ixtiyoriy. U bo'lmasa va hech bir `case` mos kelmasa, `switch` hech narsa bajarmaydi. Tashqi qiymatni
> tekshirishda noma'lum holatni yashirmaslik uchun `default` ko'pincha foydali.

Keyingi qismda takrorlash operatori `for` siklini o'rganamiz.

## Misollar

### 1. Bir nechta qiymatni bitta `case`da tekshirish

```go
package main

import "fmt"

func main() {
	kun := "shanba"
	switch kun {
	case "shanba", "yakshanba":
		fmt.Println("Dam olish kuni")
	default:
		fmt.Println("Ish kuni")
	}
}
```

Vergul bilan yozilgan qiymatlardan bittasi mos kelsa, shu `case` bajariladi.

### 2. Ifodasiz `switch` bilan oraliq tekshirish

```go
package main

import "fmt"

func main() {
	ball := 86
	switch {
	case ball >= 90:
		fmt.Println("A")
	case ball >= 80:
		fmt.Println("B")
	case ball >= 70:
		fmt.Println("C")
	default:
		fmt.Println("F")
	}
}
```

`switch`dan keyin ifoda yozilmasa, har bir `case` mantiqiy shart sifatida tekshiriladi.

### 3. `switch` ichida boshlang‘ich qiymat

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	switch soat := time.Now().Hour(); {
	case soat < 12:
		fmt.Println("Xayrli tong")
	case soat < 18:
		fmt.Println("Xayrli kun")
	default:
		fmt.Println("Xayrli kech")
	}
}
```

`soat` faqat `switch` ichida ko‘rinadi. Nuqtali verguldan keyingi qism bo‘sh bo‘lgani uchun shartli `case`lar ishlaydi.

### 4. Oy nomidan faslni aniqlash

```go
package main

import "fmt"

func main() {
	oy := "aprel"
	switch oy {
	case "dekabr", "yanvar", "fevral":
		fmt.Println("Qish")
	case "mart", "aprel", "may":
		fmt.Println("Bahor")
	case "iyun", "iyul", "avgust":
		fmt.Println("Yoz")
	case "sentabr", "oktabr", "noyabr":
		fmt.Println("Kuz")
	default:
		fmt.Println("Noma’lum oy")
	}
}
```

Bir `case` ichida bir faslga tegishli bir nechta oy yoziladi. `default` noto‘g‘ri oy nomini alohida ko‘rsatadi.

### 5. Kalkulyator amalini tanlash

```go
package main

import "fmt"

func main() {
	a, b := 12, 4
	amal := "/"
	switch amal {
	case "+":
		fmt.Println(a + b)
	case "-":
		fmt.Println(a - b)
	case "*":
		fmt.Println(a * b)
	case "/":
		fmt.Println(a / b)
	default:
		fmt.Println("Noma’lum amal")
	}
}
```

`switch` amal belgisiga qarab kerakli operatorni tanlaydi. Bo‘lish misolida `b` nol emasligi oldindan ma’lum.

### 6. Hisoblangan `case` qiymatlari

```go
package main

import "fmt"

func main() {
	a, b := 2, 3
	natija := 6
	switch natija {
	case a + b:
		fmt.Println("Yig‘indi")
	case a * b:
		fmt.Println("Ko‘paytma")
	default:
		fmt.Println("Mos emas")
	}
}
```

`case` qiymati o‘zgaruvchilardan hisoblanishi ham mumkin. Bu yerda `6` ikkinchi `case`ga mos keladi.

### 7. `break` bilan `case`ni erta tugatish

```go
package main

import "fmt"

func main() {
	buyruq, ruxsat := "delete", false
	switch buyruq {
	case "delete":
		if !ruxsat {
			fmt.Println("Ruxsat yo‘q")
			break
		}
		fmt.Println("O‘chirildi")
	default:
		fmt.Println("Noma’lum buyruq")
	}
}
```

Go har bir `case`dan avtomatik chiqadi. Ichki shartda blokni oldinroq tugatish kerak bo‘lsa, `break` foydali.

### 8. Belgini turkumlash

```go
package main

import "fmt"

func main() {
	belgi := 'e'
	switch belgi {
	case 'a', 'e', 'i', 'o', 'u':
		fmt.Println("Unli")
	default:
		fmt.Println("Undosh yoki boshqa belgi")
	}
}
```

`switch` `rune` qiymatlari bilan ham ishlaydi.

### 9. HTTP holat kodini guruhlash

```go
package main

import "fmt"

func main() {
	kod := 404
	switch kod / 100 {
	case 2:
		fmt.Println("Muvaffaqiyatli")
	case 4:
		fmt.Println("Mijoz xatosi")
	case 5:
		fmt.Println("Server xatosi")
	default:
		fmt.Println("Boshqa javob")
	}
}
```

Butun sonli bo‘lish kodning yuzlik raqamini ajratib, bir guruhdagi holatlarni birgalikda tekshiradi.

### 10. `fallthrough` bilan umumiy amalni davom ettirish

```go
package main

import "fmt"

func main() {
	daraja := "admin"
	switch daraja {
	case "admin":
		fmt.Println("Sozlamalarni boshqarish")
		fallthrough
	case "editor":
		fmt.Println("Maqolani tahrirlash")
		fallthrough
	case "reader":
		fmt.Println("Maqolani o‘qish")
	}
}
```

`admin`dan keyingi bloklar shartsiz bajariladi. Huquqlar modeli uchun odatda aniq shartlar tushunarliroq; misol `fallthrough` xatti-harakatini ko‘rsatadi.
