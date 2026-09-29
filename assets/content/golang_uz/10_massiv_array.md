# Goda massiv(array)

Massiv (array) bir xil turdagi va o'zgarmas o'lchamga ega elementlarni saqlash uchun ma'lumot turi. Masalan, haftaning
har bir kunidagi harorat uchun doim yettita qiymat kerak bo'ladi bu qiymatlarni massivida saqlash mumkin.

Goda massiv uzunligi uning turini bir qismi hisoblanadi. Shu sabab `[3]int` va `[4]int` boshqa-boshqa tur deb
qaraladi, massivni yana bir xususiyatlaridan biri massiv yaratilganidan keyin unga yangi element uchun joy qo'shib yoki 
uning o'lchamini qisqartirib bo'lmaydi.

## Massivni e'lon qilish

Massiv turi `[uzunlik]elementTuri` ko'rinishida e'lon qilinadi:

```go
package main

import "fmt"

func main() {
	var ballar [4]int
	ballar[0] = 78
	ballar[1] = 91

	fmt.Println(ballar)
	fmt.Println("Uzunligi:", len(ballar))
}
```

**Natija:**

```text
[78 91 0 0]
Uzunligi: 4
```

> **Ma'lumot**
>
> Massiv o'lchami `len` bilan hisoblanadi.

`var ballar [4]int` qatori to'rtta `int` qiymati uchun joy ajratadi. Qiymat berilmagan elementlar dastlab `0` bo'ladi.
Chunki `0` - `int` turining nol qiymati. Nol qiymat o'zgaruvchi yaratilganda Go avtomatik beradigan boshlang'ich
qiymat.

Massivdagi har bir element indeks, ya'ni uning tartib raqami orqali tanlanadi. Massiv indekslari `0` dan boshlanadi.
Shuning uchun to'rtta elementli massivning indekslari `0`, `1`, `2` va `3` bo'ladi. Yuqoridagi misolda dastlabki ikkita
elementga qiymat berilgan, qolgan ikkita element esa `0` bo'lgan.

> **Diqqat**
>
> Yuqoridagi misolda `ballar[4]` deb massiv elementiga murojaat qilib bo'lmaydi, chunki bu massivda `4` indeks yo'q.
> Agar indeks chagaradan tashqari berilsa kompilyator xato beradi. Lekin indeks dastur ishlayotgan paytda hisoblanib,
> chegaradan chiqib ketsa dastur `panic` xatosi bilan to'xtaydi.

## Massiv uzunligni e'lon qilishda belgilamaslik

Shunday holatlar bo'ladi massiv uzunligi dastur tuzish davomida aniq bo'lmaydi, bunday holatlar uchun ham Go kompilaytor
imkoniyat qo'shilgan. Buning uchun massiv e'lon qilishda massiv o'lchamini `[..]` kabi yozish kifoya.

```go
package main

import "fmt"

func main() {
	ranglar := [3]string{"qizil", "yashil", "ko'k"}
	sonlar := [...]int{10, 20, 30, 40}

	fmt.Println(ranglar)
	fmt.Println(sonlar, len(sonlar))
}
```

**Natija:**

```text
[qizil yashil ko'k]
[10 20 30 40] 4
```

`[3]string` yozuvida massiv uzunligi aniq ko'rsatilgan. `[...]int` ichidagi `...` esa uzunlikni berilgan elementlar
sonidan aniqlashni kompilyatorga topshiradi. `sonlar` ichida to'rtta element borligi uchun uning turi `[4]int` bo'ladi.

## Massiv bo'ylab yurish(iteratsiya)

Massivning barcha elementlarini ketma-ket o'qish uchun `range` ishlatiladi. U siklning har bir iteratsiyasida element
indeksi va qiymatini beradi.

> **Ma'lumot**
>
> Iteratsiya — sikl tanasining bir marta bajarilishi.

```go
package main

import "fmt"

func main() {
	ballar := [4]int{78, 91, 85, 88}
	yigindi := 0

	for indeks, ball := range ballar {
		fmt.Printf("%d-indeks: %d\n", indeks, ball)
		yigindi += ball
	}

	fmt.Println("O'rtacha:", float64(yigindi)/float64(len(ballar)))
}
```

Natija:

```text
0-indeks: 78
1-indeks: 91
2-indeks: 85
3-indeks: 88
O'rtacha: 85.5
```

Sikl har bir `ball` qiymatini `yigindi` o'zgaruvchisiga qo'shadi. O'rtacha qiymatni hisoblash uchun esa yig'indi
elementlar
soniga bo'linadi. Bo'lishdan oldin ikkala qiymat ham `float64` turiga o'tkazilgan chunki Go ikkita `int` qiymatini
bo'lib va natijani kasr qismini tashlab yuborishi mumkin

## Massivdan nusxa olish

Massivni boshqa o'zgaruvchiga berganda Go uning barcha elementlaridan alohida nusxa oladi. Nusxadagi elementni
o'zgartirish dastlabki massivga ta'sir qilmaydi:

```go
package main

import "fmt"

func main() {
	asl := [3]int{1, 2, 3}
	nusxa := asl
	nusxa[0] = 99

	fmt.Println("Asl:", asl)
	fmt.Println("Nusxa:", nusxa)
}
```

**Natija:**

```text
Asl: [1 2 3]
Nusxa: [99 2 3]
```

Misolda `asl` va `nusxa` bir xil qiymatlardan tuzilgan ikkita mustaqil massiv. Shu sababdan `nusxa[0]` o'zgartirilganda
`asl[0]` avvalgi qiymatini saqlab qoldi.

> **Ma'lumot**
>
> Massiv funksiyaga argument sifatida uzatilganda ham to'liq nusxalanadi. Katta massivni funksiyaga qayta-qayta uzatish
> ortiqcha nusxalar yaratishi mumkin. Bunday holatda ko'pincha slice ishlatiladi.

## Massivlarni taqqoslash

Massivlarni `==` va `!=` operatorlari bilan taqqoslash mumkin, lekin bu massiv elementlarining turiga bog'liq. Agar
element turi taqqoslanadigan bo'lsa, massivlarning o'zi ham taqqoslanadi.

Masalan, `int` turi taqqoslanadi, shuning uchun `int` elementlaridan tashkil topgan massivlarni ham taqqoslash mumkin:

```go
a := [3]int{1, 2, 3}
b := [3]int{1, 2, 3}
c := [3]int{1, 2, 4}

fmt.Println(a == b) // true
fmt.Println(a == c) // false
```

Go massivlarni elementma-element taqqoslaydi. Barcha mos elementlar teng bo'lsa, natija `true` bo'ladi.

Agar massiv ichidagi element turi taqqoslanmaydigan bo'lsa, massivning o'zini ham `==` yoki `!=` operatorlari bilan
tekshirib bo'lmaydi. Masalan, `slice` taqqoslanmaydi:

```go
a := [2][]int{
	{1, 2},
	{3, 4},
}

b := [2][]int{
	{1, 2},
	{3, 4},
}

// fmt.Println(a == b)
// Xato: slice elementlariga ega massivlarni taqqoslab bo'lmaydi.
```

## Qachon massiv ishlatiladi?

Elementlar soni oldindan ma'lum va o'zgarmas bo'lsa, massivdan foydalanish qulay. Masalan, IPv4 manzili doim to'rtta
baytdan iborat. Uni `[4]byte` turi bilan ifodalash mumkin.

Elementlar soni dastur ishlashi davomida ko'payishi yoki kamayishi mumkin bo'lsa, odatda `slice` ishlatiladi. Demak,
`massiv` va `slice` orasidagi tanlov avvalo elementlar soni o'zgarishi yoki o'zgarmasligiga bog'liq.

## Qo'shimcha misollar

### 1. Uzunlikni kompilyatorga aniqlatish

```go
package main

import "fmt"

func main() {
	ranglar := [...]string{"qizil", "yashil", "ko'k"}
	fmt.Printf("%T, uzunligi: %d\n", ranglar, len(ranglar))
}
```

**Natija:**

```text
[3]string, uzunligi: 3
```

`...` yozuvi massiv uzunligini qo'lda kiritmaslik imkonini beradi. Kompilyator uchta rang borligini ko'radi va
`ranglar` turini `[3]string` deb belgilaydi.

### 2. Indeksli massiv literali

```go
package main

import "fmt"

func main() {
	sonlar := [6]int{1: 10, 4: 40}
	fmt.Println(sonlar)
}
```

**Natija:**

```text
[0 10 0 0 40 0]
```

Massiv literalida faqat kerakli indekslarga qiymat berish ham mumkin. Bu misolda `1`-indeksga `10`, `4`-indeksga
esa `40` yoziladi. Qolgan elementlar `int` turining nol qiymati — `0` bilan to'ldiriladi.

### 3. Massivlarni tenglik bilan solishtirish

```go
package main

import "fmt"

func main() {
	a := [3]int{1, 2, 3}
	b := [3]int{1, 2, 3}
	fmt.Println(a == b)
}
```

**Natija:**

```text
true
```

`a` va `b` bir xil `[3]int` turiga ega. Ularning mos indekslaridagi qiymatlar ham teng. Shu sabab dastur `true`
qiymatini ekranga chiqaradi.

### 4. Massiv nusxasini o'zgartirish

```go
package main

import "fmt"

func main() {
	asl := [3]int{2, 4, 6}
	nusxa := asl
	for i := range nusxa {
		nusxa[i] *= 2
	}
	fmt.Println("Asl:", asl)
	fmt.Println("Nusxa:", nusxa)
}
```

**Natija:**

```text
Asl: [2 4 6]
Nusxa: [4 8 12]
```

`nusxa := asl` barcha elementlardan nusxa oladi. Sikl faqat `nusxa` elementlarini ikki baravar oshiradi. Natijada
`asl` o'z holicha qoladi.

### 5. Massiv yig'indisini hisoblash

```go
package main

import "fmt"

func main() {
	sonlar := [5]int{4, 7, 2, 9, 3}
	yigindi := 0
	for _, son := range sonlar {
		yigindi += son
	}
	fmt.Println(yigindi)
}
```

**Natija:**

```text
25
```

`range` indeks va qiymat qaytaradi. Bu misolda indeks kerak emasligi uchun uning o'rniga bo'sh identifikator `_`
yozilgan. Har bir qiymat `yigindi`ga qo'shiladi va dastur `25` sonini ekranga chiqaradi.

### 6. Eng katta element indeksini topish

```go
package main

import "fmt"

func main() {
	sonlar := [5]int{4, 17, 8, 17, 3}
	engKatta := 0
	for i := 1; i < len(sonlar); i++ {
		if sonlar[i] > sonlar[engKatta] {
			engKatta = i
		}
	}
	fmt.Println(engKatta, sonlar[engKatta])
}
```

**Natija:**

```text
1 17
```

`engKatta` o'zgaruvchisi qiymatni emas, eng katta element indeksini saqlaydi. Dastlab `0`-indeksdagi element eng
katta deb olinadi. Sikl qolgan elementlarni `sonlar[engKatta]` qiymati bilan solishtiradi.

Taqqoslashda `>` ishlatilgan. Shu sabab eng katta qiymat bir necha marta uchrasa, uning birinchi indeksi saqlanadi.
Bu massivda `17` ikki marta uchraydi, lekin natijada uning birinchi indeksi — `1` chiqadi.

### 7. Ikki o'lchamli massiv

```go
package main

import "fmt"

func main() {
	matritsa := [2][3]int{{1, 2, 3}, {4, 5, 6}}
	for qator := range matritsa {
		for ustun := range matritsa[qator] {
			fmt.Print(matritsa[qator][ustun], " ")
		}
		fmt.Println()
	}
}
```

**Natija:**

```text
1 2 3
4 5 6
```

`[2][3]int` — ikki qatorli va uch ustunli massiv. Har bir qatorning o'zi uchta elementdan iborat `[3]int` massivi
hisoblanadi. Elementni olish uchun avval qator, keyin ustun indeksi yoziladi: `matritsa[qator][ustun]`.

### 8. Matritsaning bosh diagonali

```go
package main

import "fmt"

func main() {
	matritsa := [3][3]int{{1, 2, 3}, {4, 5, 6}, {7, 8, 9}}
	yigindi := 0
	for i := range matritsa {
		yigindi += matritsa[i][i]
	}
	fmt.Println(yigindi)
}
```

**Natija:**

```text
15
```

Bosh diagonaldagi elementlarning qator va ustun indekslari bir xil bo'ladi: `[0][0]`, `[1][1]` va `[2][2]`.
Sikl `1`, `5` va `9` qiymatlarini qo'shadi. Shu sabab natija `15` bo'ladi.

### 9. Raqamlar chastotasi

```go
package main

import "fmt"

func main() {
	son := 120221
	var sanoq [10]int
	for son > 0 {
		sanoq[son%10]++
		son /= 10
	}
	fmt.Println(sanoq)
}
```

**Natija:**

```text
[1 2 3 0 0 0 0 0 0 0]
```

Bu misolda massiv indeksi raqamning o'zini bildiradi. Indeksdagi qiymat esa shu raqam necha marta uchraganini
saqlaydi. Masalan, `sanoq[2]` qiymati `2` raqamining son ichida necha marta borligini ko'rsatadi. `120221` sonida
`1` ikki marta, `2` esa uch marta qatnashgan.

O'nlik sanoq tizimida `0` dan `9` gacha doim o'nta raqam bor. Elementlar soni o'zgarmagani uchun bu vazifada
`[10]int` massivi mos keladi.

> **Ma'lumot**
>
> Ushbu sodda misolda `son` musbat deb olingan. Agar `son` qiymati aynan `0` bo'lsa, sikl ishlamaydi va nol raqami
> sanalmaydi. Tashqi ma'lumot bilan ishlaydigan dasturda bu holatni alohida tekshirish kerak.

### 10. Massivni joyida teskari qilish

```go
package main

import "fmt"

func main() {
	massiv := [5]int{10, 20, 30, 40, 50}
	for chap, ong := 0, len(massiv)-1; chap < ong; chap, ong = chap+1, ong-1 {
		massiv[chap], massiv[ong] = massiv[ong], massiv[chap]
	}
	fmt.Println(massiv)
}
```

**Natija:**

```text
[50 40 30 20 10]
```

`chap` indeksi massiv boshidan, `ong` esa oxiridan yuradi. Har bir iteratsiyada shu indekslardagi qiymatlar o'zaro
almashtiriladi. Indekslar uchrashganda sikl tugaydi. O'zgartirish massivning o'zida bajarilgani uchun qo'shimcha massiv
kerak emas.

Keyingi darsda elementlar sonini o'zgartirish mumkin bo'lgan slice, uning uzunligi, sig'imi va `append()` funksiyasi
bilan ishlashni o'rganamiz.
