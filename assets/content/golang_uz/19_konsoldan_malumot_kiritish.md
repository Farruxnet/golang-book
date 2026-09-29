# Konsoldan ma'lumot kiritish

Bundan oldingi qismlarda dastur ishlatadigan qiymatlarni kodning ichida yozdik. Asosan dasturlar foydalanuvchidan 
ism, son yoki boshqa ma'lumotlarni qo'lda kiritishini so'raydi.

Bu qismda shu ishni terminalda amalga oshirishni va uni o'zgaruvchiga biriktirishni o'rganamiz.

Terminaldan ma'lumot olish uchun `fmt` paketida `fmt.Scan()` funksiyasi bor. Shu funksiya bilan qiymatlarni o'qib olish
mumkin.

```go
package main

import "fmt"

func main() {
	var yosh int

	fmt.Print("Yoshingizni kiriting: ")
	if _, err := fmt.Scan(&yosh); err != nil {
		fmt.Println("Yoshni o'qib bo'lmadi:", err)
		return
	}

	fmt.Println("Siz kiritgan yosh:", yosh)
}
```

Dasturni ishga tushiring:

```bash
go run main.go
```

Terminalda so'rov chiqganidan so'ng `25` yozib `Enter` tugmasini bosing:

Natija quyidagicha bo'lishi kerak:

```text
Yoshingizni kiriting: 25
Siz kiritgan yosh: 25
```

> **Ma'lumot**
>
> `fmt.Print()` matnni chiqaradi, lekin yangi qator qo'shmaydi. Shu sababli foydalanuvchi qiymatni so'rovning yoniga
> yozadi. `fmt.Println()` esa natijadan keyin yangi qator qo'shardi.

Keling endi yuqoridagi dasturni tushunishga harakat qilamiz:

`var yosh int` o'zgaruvchini yaratadi va unga `0` nol qiymatini beradi. `fmt.Scan(&yosh)` terminaldan qiymat o'qib, uni
shu o'zgaruvchiga yozadi. `Scan()` nechta qiymat o'qilganini va yuz berishi mumkin bo'lgan xatoni qaytaradi. Bu misolda
qiymatlar soni kerak emasligi uchun `_` ishlatildi, xato esa `err` orqali tekshirildi. Xato bo'lsa, dastur sababni chiqarib,
`return` bilan ishini yakunlaydi.

Bu yerda ishlatilgan `if` shart bajarilganda uning blokidagi kodni ishga tushiradi. `err != nil` yozuvi xato mavjudligini
tekshiradi. Shart operatorlari va xatolar bilan ishlash oldingi darslarda batafsil tushuntirilgan.

`&yosh` — `yosh` o'zgaruvchisining xotiradagi manzili. `Scan()` qiymat sifatida o'zgaruvchining xotiradagi manzilini qabul
qiladi. 

> **Diqqat**
>
> `fmt.Scan(yosh)` emas, `fmt.Scan(&yosh)` yoziladi. `&` bo'lmasa, `Scan()` o'zgaruvchiga yangi qiymat yoza olmaydi va
> xato qaytaradi.

> **Ma'lumot**
>
> Xotira manzili haqida mana bu [> Kompyuter va Operatsion tizim](https://farruxnet.uz/blog/2026/06/01/kompyuter-va-operatsion-tizim/) maqolasida tanishishingiz mumkin.
> Hozircha `&`ni **qiymatni shu o'zgaruvchi turgan manzilga yoz** degan ko'rsatma sifatida tushunish yetarli. Xotira manzili va pointerlar
> keyingi alohida qismda batafsil tushuntiriladi.

## Bir nechta qiymat o'qish

`Scan()`ga bir nechta o'zgaruvchining manzilini berish mumkin. Qiymatlar terminalda bo'sh joy yoki yangi qator bilan
ajratiladi:

```go
package main

import "fmt"

func main() {
	var eni float64
	var balandlik float64

	fmt.Print("To'rtburchak eni va balandligini kiriting: ")
	if _, err := fmt.Scan(&eni, &balandlik); err != nil {
		fmt.Println("O'lchamlarni o'qib bo'lmadi:", err)
		return
	}
	yuza := eni * balandlik
	fmt.Printf("Yuza: %.2f\n", yuza)
}
```

**Natija:**

```text
To'rtburchak eni va balandligini kiriting: 5.5 3
Yuza: 16.50
```

**Qiymatlarni alohida qatorlarda ham kiritish mumkin:**

```text
To'rtburchak eni va balandligini kiriting: 5.5
3
Yuza: 16.50
```

`fmt.Scan()` matnlarni o'qishda bo'sh joygacha o'qiydi. Ya'ni bitta so'z:

```go
package main

import "fmt"

func main() {
	var ism string

	fmt.Print("Ism va familyangizni kiriting: ")
	if _, err := fmt.Scan(&ism); err != nil {
		fmt.Println("Ismni o'qib bo'lmadi:", err)
		return
	}

	fmt.Printf("Salom, %s!\n", ism)
}
```

Natija:

```text
Ism va familyangizni kiriting: Ali
Salom, Ali!
```

Foydalanuvchi `Ali Valiyev` deb kiritsa, `ism`ga faqat `Ali` yoziladi. To'liq qator uchun boshqa boshqa funksiyadan 
foydalanish kerak.

To'liq ism yoki uzun matnlarni `bufio.Reader` yordamida bir qator qilib o'qish mumkin:

```go
package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

func main() {
	reader := bufio.NewReader(os.Stdin)
	fmt.Print("Ism va familiyangizni kiriting: ")

	ism, err := reader.ReadString('\n')
	if err != nil {
		fmt.Println("Ismni o'qib bo'lmadi:", err)
		return
	}
	ism = strings.TrimSpace(ism)

	fmt.Printf("Salom, %s!\n", ism)
}
```

Natija:

```text
Ism va familyangizni kiriting: Ali Valiyev
Salom, Ali Valiyev!
```

Bu dasturda:

- `os.Stdin` terminaldan keladigan ma'lumot oqimini bildiradi;
- `bufio.NewReader()` shu oqimdan o'qish vositasini yaratadi;
- `ReadString('\n')` `Enter` bosilganda keladigan yangi qator belgisigacha o'qiydi;
- `strings.TrimSpace()` matn boshidagi va oxiridagi bo'sh joy hamda yangi qator belgisini olib tashlaydi.

> **Ma'lumot**
>
> `reader.ReadString('\n')` ikkita qiymat qaytaradi: foydalanuvchi kiritgan matn va o‘qish vaqtida yuz berishi mumkin
> bo‘lgan xato. Matn `ism`ga, xato esa `err`ga saqlanadi. `err != nil` bo‘lsa, dastur xato sababini chiqaradi va
> `return` orqali ishini yakunlaydi. Funksiyalar va xatolar bilan ishlash oldingi qismlarda batafsil o‘rganildi.

Keyingi darsda argumentlar, standart oqimlar va exit code bilan ishlaydigan buyruq qatori dasturlarini
ko'rib chiqamiz.

## Misollar

### 1. Ikki sonni bitta qatordan o‘qish

```go
package main

import "fmt"

func main() {
	var a, b int
	fmt.Print("Ikki son kiriting: ")
	if _, err := fmt.Scan(&a, &b); err != nil {
		fmt.Println("Sonlarni o'qib bo'lmadi:", err)
		return
	}
	fmt.Println("Yig‘indi:", a+b)
}
```

`fmt.Scan()` qiymatlarni bo‘sh joy yoki yangi qator bilan ajratib o‘qiydi. `&a` va `&b` kiritilgan qiymatlar qayerga yozilishini ko‘rsatadi.

### 2. Kasrli sonni o‘qish

```go
package main

import "fmt"

func main() {
	var narx float64
	fmt.Print("Narx: ")
	if _, err := fmt.Scan(&narx); err != nil {
		fmt.Println("Narxni o'qib bo'lmadi:", err)
		return
	}
	fmt.Printf("Narx: %.2f\n", narx)
}
```

`float64` uchun kasr ajratuvchi nuqta bilan yoziladi: `12.5`.

### 3. Ha yoki yo‘q qiymatini o‘qish

```go
package main

import "fmt"

func main() {
	var faol bool
	fmt.Print("Faolmi (true/false): ")
	if _, err := fmt.Scan(&faol); err != nil {
		fmt.Println("Qiymatni o'qib bo'lmadi:", err)
		return
	}
	fmt.Println(faol)
}
```

`bool` o‘zgaruvchiga `true` yoki `false` matni bevosita o‘qiladi.

### 4. `Fscan` bilan o‘qish manbasini ko‘rsatish

```go
package main

import (
	"fmt"
	"os"
)

func main() {
	var son int
	fmt.Fscan(os.Stdin, &son)
	fmt.Println(son * son)
}
```

`Fscan()` ma’lumot manbasini alohida qabul qiladi. Bu yerda manba terminalni bildiruvchi `os.Stdin`.

### 5. Butun qatorni o‘qish

```go
package main

import (
	"bufio"
	"fmt"
	"os"
	"strings"
)

func main() {
	reader := bufio.NewReader(os.Stdin)
	fmt.Print("Manzil: ")
	manzil, _ := reader.ReadString('\n')
	fmt.Println(strings.TrimSpace(manzil))
}
```

`ReadString()` bo‘sh joyli matnni ham qator oxirigacha saqlab oladi.

### 6. `Scanner` bilan qator o‘qish

```go
package main

import (
	"bufio"
	"fmt"
	"os"
)

func main() {
	scanner := bufio.NewScanner(os.Stdin)
	fmt.Print("Izoh: ")
	scanner.Scan()
	fmt.Println("Qabul qilindi:", scanner.Text())
}
```

`Scanner.Text()` qator oxiridagi `\n` belgisini qo‘shmaydi.

### 7. Birinchi Unicode belgini o‘qish

```go
package main

import (
	"bufio"
	"fmt"
	"os"
)

func main() {
	reader := bufio.NewReader(os.Stdin)
	fmt.Print("Bitta belgi: ")
	belgi, baytlar, _ := reader.ReadRune()
	fmt.Printf("Belgi: %c, UTF-8 hajmi: %d bayt\n", belgi, baytlar)
}
```

`ReadRune()` bitta Unicode belgini o‘qiydi. Ikkinchi natija shu belgi UTF-8 kodlashida necha bayt egallaganini bildiradi.

### 8. `Scanln` bilan bitta qatorni o‘qish

```go
package main

import "fmt"

func main() {
	var ism, familiya string
	fmt.Print("Ism va familiya: ")
	fmt.Scanln(&ism, &familiya)
	fmt.Println("Salom,", ism, familiya)
}
```

`Scanln()` qiymatlarni faqat joriy qator oxirigacha o‘qiydi. Bu misolda ism va familiya alohida o‘zgaruvchilarga yoziladi.

### 9. Vergul bilan ajratilgan sonlarni o‘qish

```go
package main

import "fmt"

func main() {
	var a, b int
	fmt.Print("a,b: ")
	fmt.Scanf("%d,%d", &a, &b)
	fmt.Println(a + b)
}
```

`Scanf()` kiritish formatini belgilashga imkon beradi. Bu misolda vergul majburiy ajratuvchi.

### 10. Kiritishlar sonini tekshirish

```go
package main

import "fmt"

func main() {
	var eni, boyi int
	n, err := fmt.Scan(&eni, &boyi)
	fmt.Println("O‘qilgan qiymatlar:", n)
	fmt.Println("Xato:", err)
	fmt.Println("Yuza:", eni*boyi)
}
```

`Scan()` nechta qiymat muvaffaqiyatli o‘qilgani va yuz bergan xatoni ham qaytaradi. Bu natijalarni yuqoridagi misollarda `if` yordamida tekshirdik.
