# Race detector

## Data raceni aniqlash

Data race concurrent dasturlashdagi muhim xatolardan biridir.

Oddiy qilib aytganda, data race quyidagi holatda yuz beradi:

1. kamida ikki goroutine bir xil xotira manziliga murojaat qiladi;
2. bu murojaatlar kerakli sinxronizatsiyasiz sodir bo‘ladi;
3. murojaatlardan kamida bittasi yozish amalidir.

Masalan, ikki goroutine bir xil o‘zgaruvchini bir vaqtda o‘zgartirsa, data race yuz berishi mumkin.

Go testlarini race detector bilan ishga tushirish uchun:

```bash
go test -race ./...
```

ishlatiladi.

Bu yerda:

* `-race` — race detectorni yoqadi;
* `./...` — joriy modul ostidagi package’larni rekursiv tekshiradi.

Oddiy dasturni ham race detector bilan ishga tushirish mumkin:

```bash
go run -race main.go
```

Race detector dastur kodiga qo‘shimcha instrumentatsiya qo‘shadi. U xotiraga murojaatlarni kuzatishi kerak.

Shu sabab `-race` bilan ishlayotgan dastur:

* odatdagidan sekinroq ishlashi;
* ko‘proq xotira sarflashi

mumkin.

Demak, race detector bilan olingan performance natijasini production performance o‘lchovi sifatida ishlatish kerak emas.

> **Diqqat**
>
> Race detector faqat dastur bajarilishi davomida haqiqatan ham ishga tushgan kod yo‘llarini kuzatadi. Masalan, data
> race kam uchraydigan bir branch ichida bo‘lsa va testlar o‘sha branch’ni bajarmasa, detector uni ko‘rmaydi.
>
> Shu sabab `-race` ogohlantirish chiqarmagani barcha mumkin bo‘lgan bajarilishlarda data race yo‘q degani emas.
> Muhim concurrent kod yo‘llarini testlar orqali amalda bajarishga harakat qiling.

Race detector data race topsa, hisobotda odatda bir-biriga zid bo‘lgan xotira murojaatlari ko‘rsatiladi.

Shuningdek, shu murojaatlarni bajargan goroutinelarning stack trace’lari ham beriladi.

Bu ma’lumot muammo qayerdan kelayotganini aniqlashga yordam beradi.

Race warning’ni shunchaki yashirish to‘g‘ri yechim emas.

Asosiy savol quyidagicha bo‘lishi kerak:

> Bu umumiy holatga qaysi goroutine egalik qiladi va boshqa goroutinelar unga qanday xavfsiz murojaat qilishi kerak?

Muammoga qarab turli sinxronizatsiya vositalari ishlatilishi mumkin:

* `sync.Mutex`;
* `sync.RWMutex`;
* channel;
* atomik operatsiyalar;
* state’ni faqat bitta goroutine boshqaradigan arxitektura.

Qaysi vosita kerakligi kodning maqsadiga bog‘liq.

## Misollar

### 1. Umumiy o‘zgaruvchidagi data raceni ko‘rish

Bu misol ataylab noto‘g‘ri concurrent kod yozadi.

Ikki goroutine bir xil `value` o‘zgaruvchisiga yozadi.

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	value := 0

	go func() {
		value = 1
	}()

	go func() {
		value = 2
	}()

	time.Sleep(100 * time.Millisecond)
	fmt.Println(value)
}
```

Avval:

```go
value := 0
```

yoziladi.

`int` turining zero value qiymati `0`, lekin bu yerda qiymat aniq ravishda ham `0` qilib berilgan.

Keyin birinchi goroutine:

```go
go func() {
	value = 1
}()
```

`value`ga `1` yozadi.

Ikkinchi goroutine esa:

```go
go func() {
	value = 2
}()
```

xuddi shu o‘zgaruvchiga `2` yozadi.

Ikkala goroutine ham bir xil xotira manziliga yozmoqda.

Ular orasida:

* mutex;
* channel;
* atomic operatsiya;
* boshqa synchronization

yo‘q.

Shuning uchun bu data race.

Dasturni:

```bash
go run -race main.go
```

bilan ishga tushirganda race detector qarama-qarshi xotira yozuvlarini aniqlashi mumkin.

Keyingi qator:

```go
time.Sleep(100 * time.Millisecond)
```

muhim nozik joyga ega.

`Sleep()` goroutinelarga bajarilish uchun vaqt beradi. Lekin u ularni sinxronlashtirmaydi.

Ya’ni:

```go
time.Sleep(...)
```

data raceni tuzatmaydi.

U faqat ushbu kichik misolda `main()` juda tez tugab ketmasligi uchun ishlatilgan.

Production kodda goroutinelar tugashini kutish uchun odatda aniq synchronization mexanizmi kerak bo‘ladi.

Masalan, vaziyatga qarab `sync.WaitGroup`, channel yoki boshqa yechim ishlatilishi mumkin.

### 2. Turli slice elementlariga yozish

Bu misolda ham ikki goroutine bitta slice bilan ishlaydi.

Lekin ular slicening turli elementlariga yozadi.

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	values := make([]int, 2)

	go func() {
		values[0] = 10
	}()

	go func() {
		values[1] = 20
	}()

	time.Sleep(100 * time.Millisecond)
	fmt.Println("Yozishlar yakunlandi")
}
```

Avval:

```go
values := make([]int, 2)
```

orqali uzunligi `2` bo‘lgan slice yaratiladi.

Uning indekslari:

```text
0
1
```

Birinchi goroutine:

```go
values[0] = 10
```

deb `0`-elementga yozadi.

Ikkinchi goroutine esa:

```go
values[1] = 20
```

deb `1`-elementga yozadi.

Bu ikki slice elementi alohida xotira joylarini bildiradi.

Shuning uchun aynan shu ikki yozuv bir-biriga qarama-qarshi murojaat hisoblanmaydi.

Bundan tashqari, `main()` goroutinelar ishlayotgan paytda:

```go
values[0]
```

yoki:

```go
values[1]
```

qiymatlarini o‘qimaydi.

U faqat:

```go
fmt.Println("Yozishlar yakunlandi")
```

deb boshqa matn chiqaradi.

Shu sabab:

```bash
go run -race main.go
```

bu ikki elementga yozish uchun data race ko‘rsatmasligi kerak.

Lekin bu yerda ham:

```go
time.Sleep(100 * time.Millisecond)
```

goroutinelar tugaganini ishonchli tasdiqlaydigan synchronization mexanizmi emas.

Bu kichik misolda faqat goroutinelarga bajarilish imkonini berish uchun ishlatilgan.

Real kodda goroutinelar qachon tugaganini aniq bilish kerak bo‘lsa, `Sleep()` o‘rniga to‘g‘ri synchronization vositasidan foydalanish kerak.
