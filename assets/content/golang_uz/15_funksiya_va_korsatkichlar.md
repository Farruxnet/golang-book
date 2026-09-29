# Funksiya va ko'rsatkichlar

Go funksiyaga berilgan argument qiymatini nusxalab oladi. Ba'zan funksiya asl o'zgaruvchini o'zgartirishi yoki katta 
qiymatni nusxalashdan qochishi kerak. Bunday vaziyatda `pointer` parametrdan foydalanish to'g'ri bo'ladi.

## Qiymat va pointer parametr

```go
package main

import "fmt"

func qiymatBilanOzgartir(n int) {
	n = 100
}

func pointerBilanOzgartir(n *int) {
	*n = 100
}

func main() {
	son := 10
	qiymatBilanOzgartir(son)
	fmt.Println("Qiymatdan keyin:", son)

	pointerBilanOzgartir(&son)
	fmt.Println("Pointerdan keyin:", son)
}
```

Natija:

```text
Qiymatdan keyin: 10
Pointerdan keyin: 100
```

Birinchi funksiya `son` qiymatining nusxasini o'zgartiradi. Ikkinchi funksiyaga `&son`, ya'ni `son`ning manzili 
uzatiladi. `n` ko'rsatkichi ham qiymat bo'yicha uzatiladi, ammo uning nusxasi o'sha `son` o'zgaruvchisiga murojaat
qiladi. `*n = 100` shu o'zgaruvchining qiymatini yangilaydi.

Goda C++ tilidagidek reference parametr yo'q. Pointer ham funksiyaga qiymat bo'yicha uzatiladi.

## `nil`ni xavfsiz boshqarish

Pointer parametr `nil` bo'lishi mumkin. Funksiya talabiga qarab bunday holatda xato qaytarish yoki `nil`ni alohida 
ma'no sifatida qabul qilish mumkin:

```go
package main

import (
	"fmt"
	"strings"
)

func tozalash(matn *string) error {
	if matn == nil {
		return fmt.Errorf("matn ko'rsatkichi nil")
	}
	*matn = strings.TrimSpace(*matn)
	return nil
}

func main() {
	nom := "  Go dasturchi  "
	if err := tozalash(&nom); err != nil {
		fmt.Println("Xato:", err)
		return
	}
	fmt.Printf("%q\n", nom)
}
```

Natija:

```text
"Go dasturchi"
```

`nil` tekshirilmasdan `*matn` ishlatilsa, dastur ishlayotgan vaqtda `panic` yuz beradi. Ochiq APIda funksiya `nil` 
qiymatga qanday munosabatda bo'lishi hujjatlashtirilishi kerak.

## Pointer qachon kerak?

Quyidagi holatlarda pointer ishlatish to'g'ri bo'lishi mumkin:

- funksiya qiymatni o'zgartirishi kerak bo'lsa;
- katta ma'lumotni nusxalash xarajatini kamaytirish muhim bo'lsa va o'lchash natijalari buni tasdiqlasa;
- bir obyektning umumiy holati bir nechta joydan boshqarilsa.

Kichik son, `bool` yoki kichik structni faqat "pointer tezroq" degan taxmin bilan pointer orqali uzatmang. Pointer `nil`
holatini va umumiy o'zgaruvchan ma'lumotni yuzaga keltiradi. Bu kodni tushunish va parallel ishlatishni
murakkablashtirishi mumkin.

Slice yoki `map` elementlarini o'zgartirish uchun odatda `*[]T` yoki `*map[K]V` kerak emas. Ularning qiymati asosiy 
ma'lumotga murojaat qiladi. Ammo funksiyadagi `append` natijasida slice uzunligi yoki sig'imi o'zgarsa, yangilangan 
sliceni qaytarish odatiy va tushunarli usul.

## Pointer qaytarish

Goda lokal o'zgaruvchiga ko'rsatkich qaytarish xavfsiz hisoblanadi. Kompilyator qiymatning kerakli vaqtgacha 
saqlanishini ta'minlaydi:

```go
func yangiSon() *int {
	n := 16
	return &n
}
```

Qiymat stack yoki heapda joylashishini kompilyator escape analysis yordamida hal qiladi. Kodning ishlash mantig'ini 
qiymat xotiraning qaysi qismida joylashishi haqidagi taxminga bog'lamang.

## Misollar

### 1. Qiymatni pointer orqali oshirish

```go
package main

import "fmt"

func oshir(son *int) {
	*son++
}

func main() {
	son := 9
	oshir(&son)
	fmt.Println(son)
}
```

Funksiya o'zgaruvchining manzilini qabul qiladi. `*son++` yozuvi `(*son)++` bilan bir xil bo'lib, ko'rsatkich murojaat
qilayotgan qiymatni bittaga oshiradi.

### 2. Ikki qiymatni almashtirish

```go
package main

import "fmt"

func almashtir(a, b *string) {
	*a, *b = *b, *a
}

func main() {
	birinchi, ikkinchi := "chap", "o'ng"
	almashtir(&birinchi, &ikkinchi)
	fmt.Println(birinchi, ikkinchi)
}
```

Ikkala ko'rsatkich ham chaqiruvchidagi o'zgaruvchilarga murojaat qiladi. Qiymatlar alohida vaqtinchalik o'zgaruvchisiz 
almashtiriladi.

### 3. `nil` pointerdan xavfsiz chiqish

```go
package main

import "fmt"

func chiqar(son *int) {
	if son == nil {
		fmt.Println("Qiymat berilmagan")
		return
	}
	fmt.Println(*son)
}

func main() {
	chiqar(nil)
}
```

Ko'rsatkich orqali qiymatga murojaat qilishdan oldin `nil` tekshiriladi. Erta `return` tufayli `son` qiymati `nil` 
bo'lganda `*son` bajarilmaydi.

### 4. Standart qiymatni pointer orqali berish

```go
package main

import "fmt"

func qiymatYoki(p *int, standart int) int {
	if p == nil {
		return standart
	}
	return *p
}

func main() {
	son := 0
	fmt.Println(qiymatYoki(nil, 10))
	fmt.Println(qiymatYoki(&son, 10))
}
```

`nil` va `0` alohida holatlar sifatida ko'riladi. Birinchi chaqiruv standart qiymat — `10` ni, ikkinchisi esa mavjud
qiymat — `0` ni qaytaradi.

### 5. Pointer qaytaradigan funksiya

```go
package main

import "fmt"

func yangiHisoblagich(boshlanish int) *int {
	son := boshlanish
	return &son
}

func main() {
	p := yangiHisoblagich(5)
	*p += 3
	fmt.Println(*p)
}
```

Lokal o'zgaruvchiga ko'rsatkich qaytarish Go'da xavfsiz. Kompilyator qiymat qancha vaqt saqlanishi kerakligini aniqlaydi.

### 6. Slice'ning o'zini pointer orqali almashtirish

```go
package main

import "fmt"

func qosh(sonlar *[]int, son int) {
	*sonlar = append(*sonlar, son)
}

func main() {
	sonlar := []int{1, 2}
	qosh(&sonlar, 3)
	fmt.Println(sonlar)
}
```

Elementlarni o'zgartirish uchun slice ko'rsatkichi kerak emas. Bu misolda funksiya slice tavsifidagi uzunlikni ham 
yangilashi uchun ko'rsatkich ishlatilgan. Odatda yangilangan slice'ni qaytarish sodda va tushunarliroq bo'ladi.

### 7. Map pointeri kerak emas

```go
package main

import "fmt"

func yangila(ball map[string]int) {
	ball["Go"] = 100
}

func main() {
	ball := map[string]int{"Go": 80}
	yangila(ball)
	fmt.Println(ball)
}
```

`map` funksiyaga qiymat bo'yicha uzatilsa ham, funksiya uning elementlarini yangilay oladi. Shu vazifa uchun `*map` 
kerak emas.

### 8. Massivni pointer orqali o'zgartirish

```go
package main

import "fmt"

func tozalash(sonlar *[3]int) {
	for i := range sonlar {
		sonlar[i] = 0
	}
}

func main() {
	sonlar := [3]int{4, 5, 6}
	tozalash(&sonlar)
	fmt.Println(sonlar)
}
```

Massiv funksiyaga qiymat bo'yicha uzatilsa, to'liq nusxalanadi. Massiv ko'rsatkichi esa nusxa yaratmasdan asl massiv 
elementlarini o'zgartirish imkonini beradi.

### 9. Pointer parametrning o'zi nusxalanadi

```go
package main

import "fmt"

func boshqaManzil(p *int) {
	yangi := 99
	p = &yangi
}

func main() {
	son := 10
	p := &son
	boshqaManzil(p)
	fmt.Println(*p)
}
```

Natija `10` bo'ladi. Funksiya ichidagi `p` ko'rsatkichning nusxasidir. Uni boshqa o'zgaruvchiga yo'naltirish 
chaqiruvchidagi `p`ni o'zgartirmaydi.

### 10. Pointerga pointer orqali manzilni yangilash

```go
package main

import "fmt"

func almashtir(p **int, yangi *int) {
	*p = yangi
}

func main() {
	birinchi, ikkinchi := 10, 20
	p := &birinchi
	almashtir(&p, &ikkinchi)
	fmt.Println(*p)
}
```

`**int` turi `*int` turidagi ko'rsatkichga ko'rsatkichni bildiradi. Shu sabab funksiya chaqiruvchidagi `p`ni boshqa 
o'zgaruvchiga yo'naltira oladi.
