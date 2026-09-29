# Goda `struct`

`struct` bir-biriga bog'liq, har-xil turdagi qiymatlarni bitta tur ichida birlashtiradi. Masalan, mahsulot nomi 
`string`, narxi `int64`, ombordagi holati esa `bool` bo'lishi mumkin. Bu ma'lumotlarni alohida o'zgaruvchilarda emas, 
bitta `Product` qiymatida saqlash kodni tushunarli qiladi.

## Turni e'lon qilish va qiymat berish

```go
package main

import "fmt"

type User struct {
	Name  string
	Age   int
	Email string
}

func main() {
	user := User{
		Name:  "Ali",
		Age:   25,
		Email: "ali@example.com",
	}

	fmt.Println(user.Name, user.Age, user.Email)
}
```

Natija:

```text
Ali 25 ali@example.com
```

`type User struct` orqali `User` nomli yangi struct turi e'lon qilinadi. `Name`, `Age` va `Email` esa shu structning 
maydonlari hisoblanadi.

Goda tur yoki maydondan boshqa paketda foydalanish kerak bo'lsa, uning nomi bosh harf bilan boshlanishi kerak. Masalan, 
`User` va `Name` boshqa paketlardan ishlatilishi mumkin, `user` yoki `name` esa faqat o'zi e'lon qilingan paket ichida 
ishlatiladi.

Struct qiymatini maydon nomlarini ko'rsatib yaratish tavsiya qilinadi:

```go
User{
    Name:  "Ali",
    Age:   25,
    Email: "ali@example.com",
}
```

Bu usulda maydonlarning yozilish tartibi muhim emas.

Go quyidagi qisqa ko'rinishni ham qo'llab-quvvatlaydi:

```go
User{"Ali", 25, "ali@example.com"}
```

Lekin bunda qiymatlar `struct` ichidagi maydonlar tartibiga bog'liq bo'ladi. Structga yangi maydon qo'shilsa yoki
maydonlar tartibi o'zgarsa, bunday kod xatoga olib kelishi mumkin.

Shu sababli amaliyotda maydon nomlarini ko'rsatib yozish tushunarliroq va xato ehtimolini kamaytiradi.

## Nol qiymat

`struct`ning nol qiymatida har bir maydon o'z turining nol qiymatini oladi:

```go
package main

import "fmt"

type Product struct {
	Name  string
	Price int64
	Stock int
}

func main() {
	var product Product
	fmt.Printf("%q %d %d\n", product.Name, product.Price, product.Stock)
}
```

Natija:

```text
"" 0 0
```

## Ichma-ich `struct`

```go
package main

import "fmt"

type Address struct {
	City   string
	Street string
}

type Customer struct {
	Name    string
	Address Address
}

func main() {
	customer := Customer{
		Name: "Lola",
		Address: Address{
			City:   "Toshkent",
			Street: "Amir Temur",
		},
	}

	fmt.Println(customer.Name, customer.Address.City)
}
```

Natija:

```text
Lola Toshkent
```

Goda meros olish yo'q. Murakkab turlar odatda kichik turlarni birlashtirish orqali tuziladi.

## Embedding

Struct ichida tur maydon nomisiz yozilsa, u joylashtirilgan maydon (embedded field) bo'ladi:

```go
package main

import "fmt"

type Audit struct {
	CreatedBy string
}

type Order struct {
	ID int
	Audit
}

func main() {
	order := Order{ID: 19, Audit: Audit{CreatedBy: "admin"}}
	fmt.Println(order.ID, order.CreatedBy)
}
```

Natija:

```text
19 admin
```

`order.CreatedBy` yozuvi `order.Audit.CreatedBy`ning qisqa ko'rinishi. Embedding meros olish emas: `Order` va `Audit`
alohida turlar bo'lib qoladi. Maydon nomlari to'qnashsa, kerakli maydonga to'liq yo'l orqali murojaat qilinadi.

## Qiymat semantikasi, pointer va taqqoslash

`struct` boshqa o'zgaruvchiga berilganda uning maydonlari nusxalanadi. Ammo `slice`, `map` yoki `pointer` turidagi 
maydon nusxasi ham avvalgi asosiy ma'lumotga murojaat qilishi mumkin. Demak, bu chuqur nusxa emas. Asl `struct` 
maydonlarini o'zgartirish kerak bo'lsa `pointer` ishlatiladi.

Barcha maydonlari taqqoslanadigan `struct` qiymatlarini `==` bilan taqqoslash mumkin. `slice`, `map` yoki `funksiya` 
turidagi maydoni bor structni esa to'g'ridan-to'g'ri taqqoslab bo'lmaydi.

## Misollar

### 1. Nomlangan maydonlar bilan qiymat yaratish

```go
package main

import "fmt"

type Mahsulot struct {
	Nomi string
	Narx int
}

func main() {
	kitob := Mahsulot{Nomi: "Go kitobi", Narx: 85_000}
	fmt.Println(kitob)
}
```

Maydon nomlari ko'rsatilgan literal maydonlar tartibiga bog'liq emas. Ko'rsatilmagan maydonlar o'z turining nol 
qiymatini oladi.

### 2. Struct maydonini yangilash

```go
package main

import "fmt"

type Hisob struct {
	Egasi  string
	Balans int
}

func main() {
	hisob := Hisob{Egasi: "Ali", Balans: 100_000}
	hisob.Balans += 25_000
	fmt.Println(hisob)
}
```

Struct maydoniga nuqta orqali murojaat qilinadi. `Balans` maydoni yangilanganda `Egasi` maydoni o'zgarmaydi.

### 3. Structning nol qiymati

```go
package main

import "fmt"

type Natija struct {
	Ball  int
	Otgan bool
	Izoh  string
}

func main() {
	var natija Natija
	fmt.Printf("%+v\n", natija)
}
```

Har bir maydon o'z turining nol qiymatini oladi. `%+v` maydon nomlarini ham chiqaradi.

### 4. Structlarni solishtirish

```go
package main

import "fmt"

type Nuqta struct {
	X int
	Y int
}

func main() {
	a := Nuqta{X: 2, Y: 3}
	b := Nuqta{X: 2, Y: 3}
	fmt.Println(a == b)
}
```

Barcha maydonlari taqqoslanadigan struct qiymatlari `==` yordamida maydonma-maydon solishtiriladi.

### 5. Struct nusxasini mustaqil o'zgartirish

```go
package main

import "fmt"

type Olcham struct {
	Eni  int
	Boyi int
}

func main() {
	asl := Olcham{Eni: 10, Boyi: 5}
	nusxa := asl
	nusxa.Eni = 20
	fmt.Println(asl, nusxa)
}
```

Struct boshqa o'zgaruvchiga tayinlanganda uning qiymati nusxalanadi. Nusxadagi oddiy maydonni o'zgartirish asl structga 
ta'sir qilmaydi.

### 6. Pointer orqali structni o'zgartirish

```go
package main

import "fmt"

type Foydalanuvchi struct {
	Ism  string
	Faol bool
}

func faollashtir(f *Foydalanuvchi) {
	f.Faol = true
}

func main() {
	foydalanuvchi := Foydalanuvchi{Ism: "Vali"}
	faollashtir(&foydalanuvchi)
	fmt.Println(foydalanuvchi)
}
```

Struct ko'rsatkichi funksiyaga asl struct maydonlarini o'zgartirish imkonini beradi. Go `(*f).Faol` yozuvini qisqa 
`f.Faol` ko'rinishida yozishga ruxsat beradi.

### 7. Ichma-ich struct

```go
package main

import "fmt"

type Manzil struct {
	Shahar string
	Uy     int
}

type Shaxs struct {
	Ism    string
	Manzil Manzil
}

func main() {
	shaxs := Shaxs{Ism: "Ali", Manzil: Manzil{Shahar: "Toshkent", Uy: 12}}
	fmt.Println(shaxs.Manzil.Shahar)
}
```

Ichki struct maydoniga nuqtalarni ketma-ket yozish orqali murojaat qilinadi.

### 8. Embedding orqali maydonni ko'tarish

```go
package main

import "fmt"

type Manzil struct {
	Shahar string
}

type Tashkilot struct {
	Nomi string
	Manzil
}

func main() {
	t := Tashkilot{Nomi: "Go markazi", Manzil: Manzil{Shahar: "Samarqand"}}
	fmt.Println(t.Shahar)
}
```

Ichki tur maydon nomisiz yozilsa, bu embedding deyiladi. Shu sabab `t.Manzil.Shahar` o'rniga qisqa `t.Shahar` yozuvidan 
foydalanish mumkin.

### 9. Structlardan slice tuzish

```go
package main

import "fmt"

type Talaba struct {
	Ism  string
	Ball int
}

func main() {
	talabalar := []Talaba{{Ism: "Ali", Ball: 86}, {Ism: "Vali", Ball: 92}}
	for _, talaba := range talabalar {
		fmt.Println(talaba.Ism, talaba.Ball)
	}
}
```

Slice elementi struct bo'lishi mumkin. Bu misolda `range` har bir aylanishda navbatdagi struct qiymatining nusxasini 
beradi.

### 10. Structni map kaliti sifatida ishlatish

```go
package main

import "fmt"

type Koordinata struct {
	X int
	Y int
}

func main() {
	ranglar := map[Koordinata]string{{X: 1, Y: 2}: "ko'k"}
	fmt.Println(ranglar[Koordinata{X: 1, Y: 2}])
}
```

Maydonlari taqqoslanadigan struct map kaliti bo'la oladi. Ikki koordinata shu tariqa bitta kalitga birlashtiriladi.
