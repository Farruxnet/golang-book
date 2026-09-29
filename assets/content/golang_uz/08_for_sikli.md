# for sikl operatori

Bir xil takrorlanish jarayonlari sikl deb ataladi. Dasturlashda takrorlanishlar juda ko'p qo'llaniladi va bu jarayonlarda
`for` sikl operatori qo'llaniladi. Masalan, `1` dan `100` gacha sonlarni chiqarish, yig'indini hisoblash uchun sikl kerak
bo'ladi.

Goda sikl uchun faqat `for` operatori bor. U boshqa tillardagi `for`, `while` va cheksiz sikl vazifalarini bajaradi.

## Uch qismli `for`

Eng ko'p uchraydigan shakl:

```go
for boshlash; shart; yangilash {
	// takrorlanadigan kod
}
```

- `boshlash` sikl boshlanishidan oldin bir marta bajariladi;
- `shart` har bir iteratsiyadan oldin tekshiriladi;
- `yangilash` har bir iteratsiya oxirida bajariladi.

> **Ma'lumot**
>
> **Iteratsiya** - sikl tanasining bir marta bajarilishi.

```go
package main

import "fmt"

func main() {
	for i := 0; i < 5; i++ {
		fmt.Println(i)
	}
}
```

**Natija:**

```text
0
1
2
3
4
```

Avval `i := 0` bir marta bajariladi. `i < 5` `true` ekan, `i` ekranga chiqadi. So'ng `i++` qiymatni bittaga oshiradi va
shart yana tekshiriladi. `i` `5`ga yetganda shart `false` bo'ladi va sikl tugaydi.

`i`ga faqat `for` bloki ichida murojaat qilish mumkin. Sikldan keyin `fmt.Println(i)` yozish kompilyatsiya xatosiga
sabab bo'ladi.

> **Ma'lumot**
>
> `i++` Go'da faqat alohida buyruq sifatida ishlatiladi. `x := i++` yoki `if i++ > 2` deb yozib bo'lmaydi.

## Shartli `for`

Boshlash va yangilash qismlarini tashqariga olib chiqilsa, `for` boshqa tillardagi `while` kabi ishlaydi:

```go
package main

import "fmt"

func main() {
	i := 1
	for i <= 3 {
		fmt.Println(i)
		i++
	}
}
```

Natija:

```text
1
2
3
```

Bu shaklda `i` sikldan oldin yaratilgani uchun undan sikldan keyin ham foydalanish mumkin. `i`ning qiymatini oshirishni 
unutishdan extiyot bo'lish kerak, agar `i` o'zgarmasa, `i <= 3` doim `true` bo'lib qoladi va sikl tugamaydi.

## Cheksiz sikl

Shart yozilmasa, sikl cheksiz davom etadi:

```go
for {
	// jarayon cheksiz davom etadi
}
```

Cheksiz sikl server, worker va hodisalarni qayta ishlovchi dasturlarda kerak bo'ladi. Uni terminalni yopish bilan emas,
dastur mantig'idagi `break`, `return` yoki bekor qilish sharti bilan boshqarish mumkin.

> **Ma'lumot**
>
> `break` operatori siklni to'xtatish vazifasini bajaradi.

```go
package main

import "fmt"

func main() {
	son := 1

	for {
		if son > 3 {
			break // son 3 dan katta bo'lganda ishga tushadi va sikl shu yerda to'xtaydi.
		}

		fmt.Println(son)
		son++
	}
}
```

Natija:

```text
1
2
3
```

`son > 3` bo'lganda `break` `for`ni darhol tugatadi. `break`dan keyingi sikl tanasi bajarilmaydi.

## continue bilan iteratsiyani o'tkazib yuborish.

`continue` ayni paydagi siklning iteratsiyani qolgan qismini tashlab, keyingi iteratsiyaga o'tkazish uchun kerak bo'ladi.
Quyidagi dastur faqat juft sonlarni chiqaradi:

```go
package main

import "fmt"

func main() {
	for i := 1; i <= 10; i++ {
		if i%2 != 0 {
			continue
		}

		fmt.Println(i)
	}
}
```

Natija:

```text
2
4
6
8
10
```

`i%2` sonni `2`ga bo'lgandagi qoldiqni beradi. Toq sonda qoldiq nol emas va `continue` sabab `Println()` bajarilmaydi.
Uch qismli `for`da `continue`dan keyin yangilash qismi, ya'ni `i++` bajariladi.

Agar faqat juft sonlar kerak bo'lsa, sikl qadamini ikkiga oshirib ham natijani olish mumkin:

```go
for i := 2; i <= 10; i += 2 {
	fmt.Println(i)
}
```

## Misol: kiritilgan sonlar yig'indisini hisoblash

Foydalanuvchidan nechta son kiritilishini olib, ularning yig'indisini hisoblaymiz:

```go
package main

import "fmt"

func main() {
	var count int

	fmt.Print("Sonlar miqdorini kiriting: ")
	_, err := fmt.Scan(&count)
	if err != nil {
		fmt.Println("Xato: butun son kiriting.")
		return
	}
	if count < 1 || count > 1000 {
		fmt.Println("Xato: miqdor 1 dan 1000 gacha bo'lishi kerak.")
		return
	}

	sum := 0
	for i := 1; i <= count; i++ {
		var number int

		fmt.Printf("%d-sonni kiriting: ", i)
		_, err = fmt.Scan(&number)
		if err != nil {
			fmt.Println("Xato: barcha qiymatlar butun son bo'lishi kerak.")
			return
		}

		sum += number
	}

	fmt.Println("Yig'indi:", sum)
}
```

`3`, so'ng `10`, `20` va `-5` kiritilsa:

```text
Sonlar miqdorini kiriting: 3
1-sonni kiriting: 10
2-sonni kiriting: 20
3-sonni kiriting: -5
Yig'indi: 25
```

`count` tashqi qiymat bo'lgani uchun uning turi ham, ruxsat etilgan oralig'i ham tekshirildi. Sikl aynan `count` marta
ishlaydi. Har bir qiymat `sum += number` orqali yig'indiga qo'shiladi. `count` uchun yuqori chegara qo'yish uzoq sikl 
ishga tushishining oldini oladi.

> **Diqqat**
>
> Juda ko'p yoki juda katta `int` qiymatlarni qo'shish overflowga olib kelishi mumkin. Go signed integer overflowini
> runtime xatosi sifatida to'xtatmaydi. Moliyaviy yoki aniq bo'lmagan ma'lumotlar bilan ishlaganda chegaralarni tekshirish kerak.

## `range` bilan qiymatlar bo'ylab yurish

`range` string, array, slice, map va channel elementlari bo'ylab yurish(iteratsiya) uchun ishlatiladi. Quyidagi string misolida har
bir Unicode belgi va uning boshlanish bayt indeksi olinadi:

```go
package main

import "fmt"

func main() {
	word := "Go‘zal"

	for index, char := range word {
		fmt.Printf("indeks=%d belgi=%c\n", index, char)
	}
}
```

Natija:

```text
indeks=0 belgi=G
indeks=1 belgi=o
indeks=2 belgi=‘
indeks=5 belgi=z
indeks=6 belgi=a
indeks=7 belgi=l
```

Indekslar `0, 1, 2, 5...` bo'lishining sababi `‘` belgisi UTF-8da uch bayt egallaydi. `char` turi `rune` bo'ladi.
`byte` va `rune` farqi keyingi darsda chuqurroq ko'riladi.

Qiymatlardan biri kerak bo'lmasa, bo'sh identifikator `_` ishlatiladi:

```go
for _, char := range word {
	fmt.Printf("%c ", char)
}
```

Faqat indeks kerak bo'lsa, ikkinchi qiymatni yozish shart emas:

```go
for index := range word {
	fmt.Println(index)
}
```

## Ichma-ich sikl va `label break`

Sikl ichida boshqa sikl yozish mumkin. Oddiy `break` faqat joriy siklni tugatadi. Tashqi siklni ham tugatish
kerak bo'lsa, belgi (label) ishlatiladi:

```go
package main

import "fmt"

func main() {
outer:
	for row := 1; row <= 3; row++ {
		for column := 1; column <= 3; column++ {
			if row == 2 && column == 2 {
				break outer
			}
			fmt.Println(row, column)
		}
	}
}
```

Natija:

```text
1 1
1 2
1 3
2 1
```

`break outer` `outer:` belgisi qo'yilgan tashqi siklni tugatadi. Belgilar chuqur ichma-ich boshqaruvda foydali bo'ladi, ammo
ko'p ishlatilsa kodni tushunish qiyinlashadi.

## Keng tarqalgan xatolar

### Chegarani bittaga xato belgilash

`i < 10` `10`ni o'z ichiga olmaydi, `i <= 10` esa oladi. Bu off-by-one xatosi deyiladi. Birinchi, oxirgi va bo'sh oraliq
holatlarini tekshirish muhim.

### Keraksiz cheksiz sikl

Faqat shartli `for`da shartga ta'sir qiluvchi qiymat yangilanmasa sikl tugamaydi. Cheksiz sikl ataylab yozilganda ham
uni to'xtatish uchun kerakli mantiqlar bo'lishi kerak.

### `break` va `continue`ni adashtirish

`break` siklni butunlay tugatadi. `continue` faqat joriy iteratsiyaning qolgan qismini o'tkazadi. Qaysi biri kerakligini
dastur mantig'i belgilaydi.

Keyingi qismlarda `for` sikl operatori `array`, `slice` va `map` ma'lumot turlari bilan ishlashda yana qo'llanadi.

## Misollar

### 1. `1` dan `10` gacha sonlarni chiqarish

```go
package main

import "fmt"

func main() {
	for i := 1; i <= 10; i++ {
		fmt.Print(i, " ")
	}
	fmt.Println()
}
```

Boshlang‘ich qiymat `1`, shart esa `i <= 10`. Shu sababli ikkala chegara ham natijaga kiradi.

### 2. `10` dan `1` gacha sonlarni chiqarish

```go
package main

import "fmt"

func main() {
	for i := 10; i >= 1; i-- {
		fmt.Print(i, " ")
	}
	fmt.Println()
}
```

Bu safar hisoblagich `i--` bilan bittadan kamayadi. Shart `i` `1`dan kichik bo‘lganda siklni tugatadi.

### 3. `1` dan `10` gacha sonlar yig‘indisi

```go
package main

import "fmt"

func main() {
	yigindi := 0
	for i := 1; i <= 10; i++ {
		yigindi += i
	}
	fmt.Println(yigindi)
}
```

Natija `55`. Yig‘indining boshlang‘ich qiymati `0`, chunki songa nol qo‘shish uning qiymatini o‘zgartirmaydi.

### 4. `1` dan `10` gacha sonlar ko‘paytmasi

```go
package main

import "fmt"

func main() {
	kopaytma := 1
	for i := 1; i <= 10; i++ {
		kopaytma *= i
	}
	fmt.Println(kopaytma)
}
```

Natija `3628800`. Ko‘paytma `1`dan boshlanadi, chunki songa `1`ni ko‘paytirish qiymatni o‘zgartirmaydi. `0`dan boshlansa, natija doim nol bo‘lib qolardi.

### 5. Juft sonlarni chiqarish

```go
package main

import "fmt"

func main() {
	for i := 2; i <= 20; i += 2 {
		fmt.Print(i, " ")
	}
	fmt.Println()
}
```

Hisoblagich birdan emas, ikkidan oshiriladi. Shuning uchun sikl faqat juft qiymatlarga kiradi.

### 6. Son raqamlari yig‘indisi

```go
package main

import "fmt"

func main() {
	son := 5832
	yigindi := 0
	for son > 0 {
		yigindi += son % 10
		son /= 10
	}
	fmt.Println(yigindi)
}
```

`son % 10` oxirgi raqamni oladi, `son /= 10` esa shu raqamni olib tashlaydi. Natija `18`.

### 7. Sonni teskari yozish

```go
package main

import "fmt"

func main() {
	son := 1234
	teskari := 0
	for son > 0 {
		teskari = teskari*10 + son%10
		son /= 10
	}
	fmt.Println(teskari)
}
```

Har bir yangi raqam oldingi natijaning oxiriga qo‘shiladi. Natija `4321`.

### 8. Faktorialni hisoblash

```go
package main

import "fmt"

func main() {
	n := 6
	natija := 1
	for i := 2; i <= n; i++ {
		natija *= i
	}
	fmt.Println(natija)
}
```

`6!` natijasi `720`. Sikl `2`dan boshlanadi, chunki `1`ga ko‘paytirish natijani o‘zgartirmaydi.

### 9. Tub sonni tekshirish

```go
package main

import "fmt"

func main() {
	son := 29
	tub := son >= 2
	for i := 2; i*i <= son && tub; i++ {
		if son%i == 0 {
			tub = false
		}
	}
	fmt.Println(tub)
}
```

Bo‘luvchilarni sonning kvadrat ildizigacha tekshirish yetarli. Bo‘luvchi topilganda `tub` `false` bo‘ladi va sikl to‘xtaydi.

### 10. Fibonachchi ketma-ketligi

```go
package main

import "fmt"

func main() {
	a, b := 0, 1
	for i := 0; i < 10; i++ {
		fmt.Print(a, " ")
		a, b = b, a+b
	}
	fmt.Println()
}
```

Har bir yangi qiymat oldingi ikkita qiymat yig‘indisidan hosil bo‘ladi. Bir vaqtda qiymat berish eski `a` va `b` qiymatlarini yo‘qotmasdan yangilaydi.

### 11. Ko‘paytirish jadvali

```go
package main

import "fmt"

func main() {
	for i := 1; i <= 3; i++ {
		for j := 1; j <= 5; j++ {
			fmt.Printf("%d × %d = %d\n", i, j, i*j)
		}
	}
}
```

Tashqi sikl birinchi sonni, ichki sikl ikkinchi sonni boshqaradi. Har bir `i` uchun `j` yana `1`dan boshlanadi.

### 12. `continue` bilan keraksiz qiymatlarni o‘tkazish

```go
package main

import "fmt"

func main() {
	for i := 1; i <= 20; i++ {
		if i%3 != 0 {
			continue
		}
		fmt.Print(i, " ")
	}
	fmt.Println()
}
```

`continue` `3`ga bo‘linmaydigan qiymatlarda qolgan buyruqlarni bajarmaydi. Natijada faqat `3`ning karralari chiqadi.
