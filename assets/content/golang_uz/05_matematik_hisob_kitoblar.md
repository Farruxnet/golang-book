# Goda matematik funksiyalar

Qo‘shish, ayirish, ko‘paytirish va bo‘lish kabi oddiy matematik amallarni Go operatorlari bilan bajarish mumkin.

Masalan:

```go
a + b
a - b
a * b
a / b
```

Lekin kvadrat ildiz topish, sonni darajaga oshirish, sinus yoki kosinus hisoblash, sonlarni yaxlitlash kabi murakkabroq hisob-kitoblar uchun tayyor funksiyalar kerak bo‘ladi.

Go standart kutubxonasida bunday funksiyalar `math` paketida joylashgan.

Bu qismda:

* `math` paketini dasturga qo‘shishni;
* matematik o‘zgarmas qiymatlardan foydalanishni;
* ildiz va daraja hisoblashni;
* sonlarni yaxlitlashni;
* trigonometrik funksiyalarni;
* logarifm va eksponentani;
* `NaN` va cheksiz qiymatlarni

ko‘rib chiqamiz.

## `math` paketini import qilish

`math` paketidagi funksiyalar va o‘zgarmas qiymatlardan foydalanish uchun avval paketni `import` qilish kerak.

Masalan:

```go
package main

import "math"
import "fmt"

func main() {
    fmt.Println(math.Pi)
}
```

Natija:

```text
3.141592653589793
```

Bu yerda `math.Pi` π sonining Go standart kutubxonasida tayyor berilgan qiymatidir.

Muhim jihat shundaki, `Pi` funksiya emas. U o‘zgarmas qiymat.

Shuning uchun:

```go
math.Pi
```

deb yoziladi.

Qavs kerak emas.

Bunga qarama-qarshi ravishda `math.Sqrt()` yoki `fmt.Println()` funksiyalardir:

```go
math.Sqrt(81)
fmt.Println("Salom")
```

Funksiyaga argument uzatish uchun qavs ishlatiladi.

Birinchi misoldagi `fmt.Println()` `math.Pi` qiymatini odatiy ko‘rinishda chiqaradi:

```text
3.141592653589793
```

Agar natijada verguldan keyin faqat ikki xona ko‘rsatish kerak bo‘lsa, `fmt.Printf()` va `%.2f` formatidan foydalanish mumkin:

```go
package main

import (
    "fmt"
    "math"
)

func main() {
    fmt.Printf("Pi: %.2f\n", math.Pi)
}
```

Natija:

```text
Pi: 3.14
```

Bu yerda:

```text
%.2f
```

`float` turidagi sonni verguldan keyin ikki xona bilan chiqarishni bildiradi.

Masalan:

* `%.2f` — ikki xona;
* `%.3f` — uch xona;
* `%.4f` — to‘rt xona.

Muhim farq bor: formatlash faqat ekranda ko‘rinadigan natijani o‘zgartiradi.

`math.Pi`ning o‘z qiymati o‘zgarmaydi.

Masalan, `math.Pi` ichida hali ham taxminan:

```text
3.141592653589793
```

qiymati saqlanadi. Biz faqat uni `3.14` ko‘rinishida chiqaryapmiz.

**Maslahat**

Agar bir nechta paket kerak bo‘lsa, ularni alohida `import` bilan yozish mumkin. Lekin Go kodida odatda bitta `import` blokidan foydalaniladi:

````
```go
import (
    "fmt"
    "math"
)
```
````

## Ko‘p ishlatiladigan matematik funksiyalar

`math` paketidagi funksiyalarning katta qismi `float64` qiymatlar bilan ishlaydi.

Ko‘p hollarda funksiya:

1. `float64` argument qabul qiladi;
2. hisob-kitob bajaradi;
3. `float64` qiymat qaytaradi.

Quyidagi jadvalda eng ko‘p ishlatiladigan funksiyalar keltirilgan:

| Funksiya yoki o‘zgarmas | Vazifasi                                                          |
| ----------------------- | ----------------------------------------------------------------- |
| `math.Abs(x)`           | `x`ning modulini, ya’ni manfiy bo‘lmagan qiymatini qaytaradi      |
| `math.Sqrt(x)`          | `x`ning kvadrat ildizini hisoblaydi                               |
| `math.Cbrt(x)`          | `x`ning kub ildizini hisoblaydi                                   |
| `math.Pow(x, y)`        | `x`ni `y`-darajaga oshiradi                                       |
| `math.Pow10(n)`         | 10 ning `n`-darajasini hisoblaydi                                 |
| `math.Min(x, y)`        | ikki sondan kichigini qaytaradi                                   |
| `math.Max(x, y)`        | ikki sondan kattasini qaytaradi                                   |
| `math.Mod(x, y)`        | kasrli sonlar uchun bo‘lish qoldig‘ini hisoblaydi                 |
| `math.Floor(x)`         | eng yaqin kichik butun qiymat tomon yaxlitlaydi                   |
| `math.Ceil(x)`          | eng yaqin katta butun qiymat tomon yaxlitlaydi                    |
| `math.Round(x)`         | eng yaqin butun qiymatga yaxlitlaydi                              |
| `math.Sin(x)`           | radian bilan berilgan `x`ning sinusini hisoblaydi                 |
| `math.Cos(x)`           | radian bilan berilgan `x`ning kosinusini hisoblaydi               |
| `math.Tan(x)`           | radian bilan berilgan `x`ning tangensini hisoblaydi               |
| `math.Asin(x)`          | `x`ning arksinusini radianlarda qaytaradi                         |
| `math.Acos(x)`          | `x`ning arkkosinusini radianlarda qaytaradi                       |
| `math.Atan(x)`          | `x`ning arktangensini radianlarda qaytaradi                       |
| `math.Exp(x)`           | `e` sonini `x`-darajaga oshiradi                                  |
| `math.Log(x)`           | `x`ning natural logarifmini hisoblaydi                            |
| `math.Log10(x)`         | `x`ning 10 asosli logarifmini hisoblaydi                          |
| `math.Hypot(x, y)`      | katetlari `x` va `y` bo‘lgan uchburchak gipotenuzasini hisoblaydi |
| `math.Pi`               | π matematik o‘zgarmas qiymati                                     |
| `math.E`                | e matematik o‘zgarmas qiymati                                     |

Keyingi bo‘limlarda bu funksiyalarning muhimlarini alohida misollar bilan ko‘rib chiqamiz.

## Modul, ildiz va daraja

Modul sonning ishorasini hisobga olmasdan uning kattaligini bildiradi.

Masalan:

```text
|-12.5| = 12.5
```

Go’da modulni `math.Abs()` bilan hisoblash mumkin.

Kvadrat ildiz uchun `math.Sqrt()`, kub ildiz uchun `math.Cbrt()` ishlatiladi.

Darajaga oshirish uchun esa `math.Pow()` mavjud.

```go
package main

import (
    "fmt"
    "math"
)

func main() {
    son := -12.5

    fmt.Println("Modul:", math.Abs(son))
    fmt.Println("81 ning kvadrat ildizi:", math.Sqrt(81))
    fmt.Println("27 ning kub ildizi:", math.Cbrt(27))
    fmt.Println("2 ning 5-darajasi:", math.Pow(2, 5))
    fmt.Println("10 ning 3-darajasi:", math.Pow10(3))
}
```

Natija:

```text
Modul: 12.5
81 ning kvadrat ildizi: 9
27 ning kub ildizi: 3
2 ning 5-darajasi: 32
10 ning 3-darajasi: 1000
```

Endi har bir hisobni alohida ko‘ramiz.

```go
math.Abs(-12.5)
```

natijasi:

```text
12.5
```

bo‘ladi. Chunki modul manfiy ishorani olib tashlaydi.

```go
math.Sqrt(81)
```

`81`ning kvadrat ildizini hisoblaydi:

```text
9 × 9 = 81
```

Shuning uchun natija `9`.

```go
math.Cbrt(27)
```

esa kub ildizni topadi:

```text
3 × 3 × 3 = 27
```

Natija `3`.

`math.Pow()` ikki argument qabul qiladi:

```go
math.Pow(2, 5)
```

Bu yerda:

* `2` — asos;
* `5` — daraja.

Hisob:

```text
2 × 2 × 2 × 2 × 2 = 32
```

bo‘ladi.

`math.Pow()`ning ikkala argumenti ham hisoblash vaqtida `float64` sifatida ishlatiladi va natija ham `float64` bo‘ladi.

`math.Pow10(3)` esa maxsus holat uchun mo‘ljallangan:

```text
10³ = 1000
```

Ya’ni faqat 10 ning darajasini hisoblash kerak bo‘lsa, `math.Pow10()` qulayroq.

## Aylana yuzini hisoblash

Aylananing yuzi quyidagi formula bilan topiladi:

```text
S = πr²
```

Bu yerda:

* `S` — aylana yuzi;
* `π` — pi soni;
* `r` — radius.

Radiusni foydalanuvchidan olib, `math.Pi` va `math.Pow()` yordamida aylana yuzini hisoblaymiz:

```go
package main

import (
    "fmt"
    "math"
)

func main() {
    var radius float64

    fmt.Print("Aylana radiusini kiriting: ")
    fmt.Scan(&radius)

    yuza := math.Pi * math.Pow(radius, 2)

    fmt.Printf("Aylana yuzi: %.2f\n", yuza)
}
```

Bu dastur bosqichma-bosqich quyidagicha ishlaydi.

Avval `radius` nomli `float64` o‘zgaruvchi yaratiladi:

```go
var radius float64
```

Keyin foydalanuvchi kiritgan qiymat o‘qiladi:

```go
fmt.Scan(&radius)
```

Masalan, foydalanuvchi `5` kiritsa:

```text
radius = 5
```

bo‘ladi.

Keyin:

```go
math.Pow(radius, 2)
```

quyidagini hisoblaydi:

```text
5² = 25
```

So‘ng:

```text
math.Pi * 25
```

hisoblanadi.

Taxminan:

```text
3.141592653589793 × 25 = 78.539816...
```

Natija `%.2f` bilan chiqarilgani uchun ekranda:

```text
78.54
```

ko‘rinadi.

To‘liq natija:

```text
Aylana radiusini kiriting: 5
Aylana yuzi: 78.54
```

Radiusning kvadratini `math.Pow()` ishlatmasdan ham hisoblash mumkin:

```go
radius * radius
```

Masalan:

```go
yuza := math.Pi * radius * radius
```

Aynan kvadrat hisoblashda bu usul sodda va tushunarli.

`math.Pow()` esa daraja oldindan aniq bo‘lmaganda yoki ixtiyoriy daraja bilan ishlaganda ayniqsa foydali.

## Gipotenuzani hisoblash

Pifagor teoremasiga ko‘ra, to‘g‘ri burchakli uchburchakning gipotenuzasi quyidagi formula bilan hisoblanadi:

```text
c = √(a² + b²)
```

Bu yerda `a` va `b` — katetlar.

Masalan, `a = 3` va `b = 4` bo‘lsa:

```text
a² = 9
b² = 16

9 + 16 = 25

√25 = 5
```

Go’da bu hisobni ikki xil usul bilan bajarish mumkin:

```go
package main

import (
    "fmt"
    "math"
)

func main() {
    a := 3.0
    b := 4.0

    oddiyUsul := math.Sqrt(a*a + b*b)
    hypotBilan := math.Hypot(a, b)

    fmt.Println("Sqrt bilan:", oddiyUsul)
    fmt.Println("Hypot bilan:", hypotBilan)
}
```

Natija:

```text
Sqrt bilan: 5
Hypot bilan: 5
```

Birinchi usul formulani bevosita yozadi:

```go
math.Sqrt(a*a + b*b)
```

Bu yerda:

```text
a * a = 3 * 3 = 9
b * b = 4 * 4 = 16
9 + 16 = 25
sqrt(25) = 5
```

Ikkinchi usul:

```go
math.Hypot(a, b)
```

aynan shu vazifa uchun tayyorlangan.

Oddiy qiymatlarda ikkala usul ham bir xil natija beradi.

Lekin `math.Hypot()` juda katta yoki juda kichik sonlar bilan ishlaganda hisoblashni sonli jihatdan barqarorroq bajaradi. Oddiy `a*a + b*b` hisobida ayrim ekstremal qiymatlarda `float64` chegaralari bilan bog‘liq muammolar yuzaga kelishi mumkin.

Shuning uchun gipotenuza yoki ikki koordinata orasidagi masofa kabi hisoblarda `math.Hypot()` qulay.

## Sonlarni yaxlitlash

Kasrli sonlarni butun qiymatlarga yaqinlashtirish uchun `math` paketida bir nechta funksiya mavjud.

Eng ko‘p ishlatiladiganlari:

* `math.Floor()`;
* `math.Ceil()`;
* `math.Round()`.

Ular o‘xshash ko‘rinsa ham, bir xil ishlamaydi.

```go
package main

import (
    "fmt"
    "math"
)

func main() {
    son := 3.7

    fmt.Println("Floor:", math.Floor(son))
    fmt.Println("Ceil:", math.Ceil(son))
    fmt.Println("Round:", math.Round(son))
}
```

Natija:

```text
Floor: 3
Ceil: 4
Round: 4
```

Har bir funksiyani alohida ko‘ramiz.

```go
math.Floor(3.7)
```

sondan kichik yoki unga teng bo‘lgan eng yaqin butun qiymatni qaytaradi.

Shuning uchun:

```text
3.7 → 3
```

`math.Ceil()` esa yuqori tomonga ishlaydi:

```go
math.Ceil(3.7)
```

natija:

```text
3.7 → 4
```

`math.Round()` eng yaqin butun qiymatni tanlaydi:

```go
math.Round(3.7)
```

`3.7` soni `4`ga `3`dan yaqinroq. Shu sababli natija:

```text
4
```

bo‘ladi.

Bu funksiyalar `float64` qiymat qaytaradi.

Masalan:

```go
yaxlit := math.Floor(3.7)
fmt.Printf("Qiymat: %v, tur: %T\n", yaxlit, yaxlit)
```

Natija taxminan:

```text
Qiymat: 3, tur: float64
```

ko‘rinishida bo‘ladi.

Ekranda `3` deb ko‘rinsada, o‘zgaruvchining turi `int` emas.

U hali ham:

```go
float64
```

turida.

Manfiy sonlarda `Floor` va `Ceil` natijalariga alohida e’tibor berish kerak.

Masalan:

```go
math.Floor(-3.2)
```

natijasi:

```text
-4
```

bo‘ladi.

Birinchi qarashda `-3` bo‘lishi kerakdek ko‘rinishi mumkin. Lekin `Floor` doim son o‘qida kichik tomonga harakat qiladi.

Son o‘qida:

```text
-4 < -3.2 < -3
```

Shuning uchun kichik butun son `-4`.

Aksincha:

```go
math.Ceil(-3.2)
```

natijasi:

```text
-3
```

bo‘ladi.

## Ma’lum kasr xonasigacha yaxlitlash

Ba’zan sonni butun songacha emas, masalan ikki kasr xonasigacha matematik yaxlitlash kerak bo‘ladi.

Misol:

```text
12.3456
```

qiymatini:

```text
12.35
```

ko‘rinishiga keltirmoqchimiz.

Buning uchun qiymatni avval `100`ga ko‘paytirish, keyin yaxlitlash va so‘ng yana `100`ga bo‘lish mumkin.

```go
package main

import (
    "fmt"
    "math"
)

func main() {
    son := 12.3456
    yaxlit := math.Round(son*100) / 100

    fmt.Println(yaxlit)
}
```

Natija:

```text
12.35
```

Hisobni bosqichma-bosqich ko‘ramiz.

Boshlang‘ich qiymat:

```text
12.3456
```

Avval `100`ga ko‘paytiriladi:

```text
12.3456 × 100 = 1234.56
```

Keyin:

```go
math.Round(1234.56)
```

natija:

```text
1235
```

bo‘ladi.

So‘ng yana `100`ga bo‘linadi:

```text
1235 / 100 = 12.35
```

Natijada qiymatning o‘zi ikki kasr xonasigacha matematik yaxlitlanadi.

Bu usulni:

```go
fmt.Printf("%.2f", son)
```

bilan aralashtirmaslik kerak.

`fmt.Printf("%.2f", son)` faqat ekranga chiqariladigan ko‘rinishni ikki xonaga formatlaydi.

`math.Round()` yordamidagi usul esa keyingi hisoblarda ishlatiladigan qiymatni ham yaxlitlashga harakat qiladi.

**Diqqat**

`float64` barcha o‘nli kasrlarni xotirada mutlaqo aniq saqlay olmaydi.

```
Masalan, `0.1`, `0.2` kabi ayrim sonlarning ikkilik ko‘rinishi cheksiz davom etadi. Shu sababli kompyuter ularni eng yaqin `float64` qiymat bilan saqlaydi.

Moliyaviy hisob-kitoblarda oddiy `float64` va `math.Round()` har doim yetarli bo‘lmasligi mumkin.

Pul qiymatlari bilan ishlaganda ko‘pincha pulni eng kichik birlikda butun son sifatida saqlash qulayroq.

Masalan, `125.50` so‘m o‘rniga eng kichik birlik asosida butun son saqlanishi mumkin.

Murakkab moliyaviy tizimlarda maxsus **decimal** turlar yoki kutubxonalar ham qo‘llanadi.
```

## Eng kichik va eng katta qiymat

Ikki `float64` qiymatdan kichigini topish uchun `math.Min()`, kattasini topish uchun `math.Max()` ishlatiladi.

```go
package main

import (
    "fmt"
    "math"
)

func main() {
    birinchi := 17.5
    ikkinchi := 12.8

    fmt.Println("Kichigi:", math.Min(birinchi, ikkinchi))
    fmt.Println("Kattasi:", math.Max(birinchi, ikkinchi))
}
```

Natija:

```text
Kichigi: 12.8
Kattasi: 17.5
```

Bu yerda:

```go
math.Min(17.5, 12.8)
```

ikkala sonni taqqoslab:

```text
12.8
```

qiymatini qaytaradi.

```go
math.Max(17.5, 12.8)
```

esa:

```text
17.5
```

qiymatini qaytaradi.

Bu funksiyalar, masalan, qiymatni ma’lum chegaradan oshirmaslik yoki ikkita o‘lchamdan kattasini tanlash kabi vazifalarda foydali.

**Ma'lumot**

`math.Min()` va `math.Max()` `float64` qiymatlar bilan ishlaydi.

````
Oddiy `int` qiymatlar bilan ishlaganda zamonaviy Go versiyalarida tilning ichki `min()` va `max()` funksiyalaridan foydalanish mumkin.

Masalan:

```go
kichik := min(10, 20)
katta := max(10, 20)
```

Bu holda `int` qiymatlarni `float64`ga aylantirish shart emas.
````

## Daraja va radian

Trigonometriyada burchakni o‘lchashning bir nechta usuli mavjud.

Kundalik matematikada ko‘pincha daraja ishlatiladi:

```text
30°
45°
90°
180°
```

Lekin Go’dagi:

```go
math.Sin()
math.Cos()
math.Tan()
```

funksiyalari burchakni darajada emas, **radian**da qabul qiladi.

Shuning uchun darajani avval radianga aylantirish kerak.

Formula:

```text
radian = daraja × π / 180
```

Masalan, `30°` uchun:

```text
30 × π / 180
```

Hisob qisqartirilsa:

```text
π / 6
```

bo‘ladi.

Go’da:

```go
package main

import (
    "fmt"
    "math"
)

func main() {
    daraja := 30.0
    radian := daraja * math.Pi / 180

    fmt.Printf("sin(30°) = %.2f\n", math.Sin(radian))
    fmt.Printf("cos(30°) = %.2f\n", math.Cos(radian))
}
```

Natija:

```text
sin(30°) = 0.50
cos(30°) = 0.87
```

Koddagi muhim qator:

```go
radian := daraja * math.Pi / 180
```

Bu `30°` qiymatini radian ko‘rinishiga o‘tkazadi.

Keyin:

```go
math.Sin(radian)
```

va:

```go
math.Cos(radian)
```

to‘g‘ri qiymatlarni hisoblaydi.

**Diqqat**

Quyidagi kod:

````
```go
math.Sin(30)
```

`30°`ning sinusini hisoblamaydi.

Bu yerda `30` qiymati **30 radian** deb qabul qilinadi.

Shu sabab trigonometrik hisoblarda daraja va radianni aralashtirib yuborish keng tarqalgan xatolardan biridir.
````

## Teskari trigonometrik funksiyalar

Oddiy trigonometrik funksiyalar burchakdan trigonometrik qiymatni topadi.

Masalan:

```text
sin(30°) = 0.5
```

Teskari trigonometrik funksiyalar esa buning teskarisini bajaradi.

Agar:

```text
sin(x) = 0.5
```

bo‘lsa, `x` burchagini topish uchun `math.Asin()` ishlatiladi.

`math.Asin()` va `math.Acos()` uchun argument odatda:

```text
-1 ≤ x ≤ 1
```

oralig‘ida bo‘lishi kerak.

Natija radianlarda qaytadi.

Agar natijani darajada olish kerak bo‘lsa, quyidagi formula ishlatiladi:

```text
daraja = radian × 180 / π
```

Misol:

```go
package main

import (
    "fmt"
    "math"
)

func main() {
    qiymat := 0.5
    radian := math.Asin(qiymat)
    daraja := radian * 180 / math.Pi

    fmt.Printf("asin(%.1f) = %.0f°\n", qiymat, daraja)
}
```

Natija:

```text
asin(0.5) = 30°
```

Kod bosqichma-bosqich quyidagicha ishlaydi.

Avval:

```go
math.Asin(0.5)
```

hisoblanadi.

Natija taxminan:

```text
0.523598...
```

radian bo‘ladi.

Keyin:

```go
radian * 180 / math.Pi
```

yordamida darajaga o‘tkaziladi.

Natija:

```text
30
```

bo‘ladi.

**Diqqat**

`math.Asin()` va `math.Acos()` uchun haqiqiy sonlar doirasidagi argument `-1` dan `1` gacha bo‘lishi kerak.

````
Masalan:

```go
math.Asin(2.5)
```

yoki:

```go
math.Acos(2.5)
```

haqiqiy son sifatida aniqlangan natijaga ega emas.

Bunday holatda Go `NaN` qiymatini qaytaradi.
````

**Ma'lumot**

`NaN` — **Not a Number**, ya’ni “son emas” degan maxsus `float64` qiymat.

```
Bu qiymat noto‘g‘ri yoki haqiqiy sonlarda aniqlanmagan matematik amal natijasini ifodalash uchun ishlatiladi.
```

## Logarifm va eksponenta

`math.Exp(x)` va `math.Log(x)` bir-biriga teskari matematik amallardir.

`math.Exp(x)`:

```text
eˣ
```

qiymatini hisoblaydi.

Bu yerda `e` — taxminan:

```text
2.718281828...
```

ga teng matematik o‘zgarmas.

`math.Log(x)` esa natural logarifmni hisoblaydi.

Misol:

```go
package main

import (
    "fmt"
    "math"
)

func main() {
    x := 2.0
    eDaraja := math.Exp(x)

    fmt.Printf("e^%.0f = %.4f\n", x, eDaraja)
    fmt.Printf("log(%.4f) = %.4f\n", eDaraja, math.Log(eDaraja))
    fmt.Println("10 asosli logarifm:", math.Log10(1000))
}
```

Natija:

```text
e^2 = 7.3891
log(7.3891) = 2.0000
10 asosli logarifm: 3
```

Avval:

```go
math.Exp(2)
```

hisoblanadi:

```text
e² ≈ 7.389056...
```

Natija `eDaraja` o‘zgaruvchisiga yoziladi.

Keyin:

```go
math.Log(eDaraja)
```

hisoblanadi.

`Log` va `Exp` teskari amallar bo‘lgani uchun natija yana taxminan:

```text
2
```

bo‘ladi.

`math.Log10()` esa 10 asosli logarifmni hisoblaydi:

```go
math.Log10(1000)
```

chunki:

```text
10³ = 1000
```

natija:

```text
3
```

bo‘ladi.

`math.Log(x)` uchun argumentning musbat bo‘lishi muhim.

Masalan:

```go
math.Log(0)
```

manfiy cheksizlikni qaytaradi.

Manfiy sonning haqiqiy sonlar doirasidagi natural logarifmi mavjud emas.

Shuning uchun:

```go
math.Log(-5)
```

kabi hisob `NaN` qaytaradi.

## `NaN` va cheksizlik

Ayrim matematik amallar haqiqiy sonlar to‘plamida natijaga ega emas.

Masalan:

```text
√-1
```

haqiqiy son emas.

Go’da:

```go
math.Sqrt(-1)
```

bajarilganda dastur darhol to‘xtab qolmaydi.

Buning o‘rniga `math` paketi maxsus `NaN` qiymatini qaytaradi.

```go
package main

import (
    "fmt"
    "math"
)

func main() {
    natija := math.Sqrt(-1)

    fmt.Println(natija)
    fmt.Println("NaN qiymatmi?", math.IsNaN(natija))
}
```

Natija:

```text
NaN
NaN qiymatmi? true
```

Bu yerda:

```go
math.IsNaN(natija)
```

qiymat `NaN` ekanini tekshiradi.

Natija `NaN` bo‘lgani uchun funksiya:

```text
true
```

qaytaradi.

`NaN`ni oddiy tenglik bilan tekshirish to‘g‘ri yondashuv emas. Buning uchun aynan `math.IsNaN()` ishlatiladi.

Cheksiz qiymatlarni tekshirish uchun esa:

```go
math.IsInf()
```

mavjud.

Masalan, matematik hisob natijasi musbat yoki manfiy cheksizlik bo‘lishi mumkin.

Amaliy dasturlarda funksiyaga beriladigan argument ruxsat etilgan oraliqda ekanini hisoblashdan oldin tekshirish ko‘pincha yaxshiroq.

Masalan, kvadrat ildiz faqat manfiy bo‘lmagan qiymatlar uchun kerak bo‘lsa:

```go
if x < 0 {
    fmt.Println("Manfiy sondan haqiqiy kvadrat ildiz olib bo‘lmaydi")
    return
}

natija := math.Sqrt(x)
```

Bu yondashuv noto‘g‘ri natijani keyingi hisob-kitoblarga uzatib yuborishning oldini oladi.

## Funksiyalarni bir dasturda ko‘rish

Quyidagi misolda yuqorida ko‘rib chiqilgan asosiy `math` funksiyalarining ko‘pchiligi bitta dasturda jamlangan:

```go
package main

import (
    "fmt"
    "math"
)

func main() {
    x := 2.5
    y := 3.0
    trigQiymat := 0.5

    fmt.Printf("math.Abs(-%v) = %v\n", x, math.Abs(-x))
    fmt.Printf("math.Sin(%v) = %.4f\n", x, math.Sin(x))
    fmt.Printf("math.Cos(%v) = %.4f\n", x, math.Cos(x))
    fmt.Printf("math.Tan(%v) = %.4f\n", x, math.Tan(x))
    fmt.Printf("math.Asin(%v) = %.4f\n", trigQiymat, math.Asin(trigQiymat))
    fmt.Printf("math.Acos(%v) = %.4f\n", trigQiymat, math.Acos(trigQiymat))
    fmt.Printf("math.Atan(%v) = %.4f\n", x, math.Atan(x))
    fmt.Printf("math.Exp(%v) = %.4f\n", x, math.Exp(x))
    fmt.Printf("math.Log(%v) = %.4f\n", x, math.Log(x))
    fmt.Printf("math.Pow(%v, %v) = %.4f\n", x, y, math.Pow(x, y))
    fmt.Printf("math.Pow10(3) = %.4f\n", math.Pow10(3))
    fmt.Printf("math.Sqrt(%v) = %.4f\n", x, math.Sqrt(x))
    fmt.Printf("math.Floor(%v) = %.4f\n", x, math.Floor(x))
    fmt.Printf("math.Ceil(%v) = %.4f\n", x, math.Ceil(x))
    fmt.Printf("math.Round(%v) = %.4f\n", x, math.Round(x))
    fmt.Printf("math.Pi = %.4f\n", math.Pi)
    fmt.Printf("math.E = %.4f\n", math.E)
    fmt.Printf("math.Min(%v, %v) = %.4f\n", x, y, math.Min(x, y))
    fmt.Printf("math.Max(%v, %v) = %.4f\n", x, y, math.Max(x, y))
    fmt.Printf("math.Mod(%v, %v) = %.4f\n", x, y, math.Mod(x, y))
}
```

Natija:

```text
math.Abs(-2.5) = 2.5
math.Sin(2.5) = 0.5985
math.Cos(2.5) = -0.8011
math.Tan(2.5) = -0.7470
math.Asin(0.5) = 0.5236
math.Acos(0.5) = 1.0472
math.Atan(2.5) = 1.1903
math.Exp(2.5) = 12.1825
math.Log(2.5) = 0.9163
math.Pow(2.5, 3) = 15.6250
math.Pow10(3) = 1000.0000
math.Sqrt(2.5) = 1.5811
math.Floor(2.5) = 2.0000
math.Ceil(2.5) = 3.0000
math.Round(2.5) = 3.0000
math.Pi = 3.1416
math.E = 2.7183
math.Min(2.5, 3) = 2.5000
math.Max(2.5, 3) = 3.0000
math.Mod(2.5, 3) = 2.5000
```

Bu yerda `x`:

```go
x := 2.5
```

ko‘pchilik oddiy matematik funksiyalar uchun ishlatiladi.

`y`:

```go
y := 3.0
```

`math.Pow()`, `math.Min()`, `math.Max()` va `math.Mod()` kabi ikkita argument talab qiladigan funksiyalarda ishlatiladi.

Teskari trigonometrik funksiyalarda esa alohida:

```go
trigQiymat := 0.5
```

tanlangan.

Sababi `math.Asin()` va `math.Acos()` uchun qiymat `-1` va `1` oralig‘ida bo‘lishi kerak.

Masalan:

```go
math.Asin(0.5)
```

to‘g‘ri argument.

Natija radianlarda:

```text
0.5236
```

atrofida chiqadi.

`math.Mod(x, y)` esa bo‘lish qoldig‘ini hisoblaydi.

Bu misolda:

```go
math.Mod(2.5, 3)
```

hisoblanmoqda.

`2.5` soni `3`dan kichik bo‘lgani sababli `3` unga bir marta ham to‘liq sig‘maydi. Shu sabab qoldiq:

```text
2.5
```

bo‘ladi.

Natijalardagi ko‘pchilik sonlar:

```text
%.4f
```

bilan formatlangan.

Shu sabab ular verguldan keyin to‘rt xona bilan ko‘rsatilgan.

Keyingi qism Goda if, else if va else shartlari haqida.

## Misollar

Quyidagi misollarda oddiy arifmetik operatorlar va `math` paketidagi funksiyalar amaliy vazifalarda qanday ishlatilishini ko‘ramiz.

### 1. To‘g‘ri to‘rtburchak yuzi va perimetri

Bu misolda to‘g‘ri to‘rtburchakning yuzi va perimetri hisoblanadi.

Yuza formulasi:

```text
S = eni × bo‘yi
```

Perimetr formulasi:

```text
P = 2 × (eni + bo‘yi)
```

Kod:

```go
package main

import "fmt"

func main() {
    eni, boyi := 8.0, 5.0

    fmt.Println("Yuza:", eni*boyi)
    fmt.Println("Perimetr:", 2*(eni+boyi))
}
```

Hisobni bosqichma-bosqich ko‘ramiz.

Yuza:

```text
8 × 5 = 40
```

Perimetr:

```text
8 + 5 = 13
2 × 13 = 26
```

Natija:

```text
Yuza: 40
Perimetr: 26
```

Bu misolda maxsus `math` funksiyasi kerak emas. Oddiy ko‘paytirish va qo‘shish operatorlari yetarli.

### 2. Aylana uzunligi va yuzi

Bu misolda radius orqali aylananing uzunligi va yuzi hisoblanadi.

Aylana uzunligi:

```text
L = 2πr
```

Aylana yuzi:

```text
S = πr²
```

Kod:

```go
package main

import (
    "fmt"
    "math"
)

func main() {
    radius := 3.0

    fmt.Printf("Uzunlik: %.2f\n", 2*math.Pi*radius)
    fmt.Printf("Yuza: %.2f\n", math.Pi*radius*radius)
}
```

Bu yerda `radius`:

```text
3
```

ga teng.

Aylana uzunligi taxminan:

```text
2 × 3.14159 × 3 ≈ 18.85
```

Aylana yuzi esa:

```text
3.14159 × 3 × 3 ≈ 28.27
```

bo‘ladi.

`math.Pi` π sonining Go standart kutubxonasidagi tayyor qiymatini beradi. Uni qo‘lda `3.14` deb yozishdan ko‘ra `math.Pi`dan foydalanish aniqroq.

### 3. Uchta sonning o‘rtacha qiymati

Arifmetik o‘rtacha qiymat barcha sonlarni qo‘shib, ularning soniga bo‘lish orqali topiladi.

```go
package main

import "fmt"

func main() {
    a, b, c := 7.0, 8.0, 10.0

    ortacha := (a + b + c) / 3

    fmt.Printf("%.2f\n", ortacha)
}
```

Hisob:

```text
7 + 8 + 10 = 25
25 / 3 = 8.3333...
```

`fmt.Printf("%.2f", ...)` natijani ikki kasr xonasigacha ko‘rsatadi:

```text
8.33
```

`a`, `b` va `c` qiymatlari `float64` bo‘lgani sababli bo‘lish kasr qismini yo‘qotmaydi.

Agar hisob butun sonlar bilan bajarilganda, butun sonli bo‘lish qoidalariga e’tibor berish kerak bo‘lardi.

### 4. Foizni hisoblash

Bu misolda mahsulot narxiga chegirma qo‘llanadi.

```go
package main

import "fmt"

func main() {
    narx := 240_000.0
    chegirmaFoizi := 15.0

    chegirma := narx * chegirmaFoizi / 100

    fmt.Println("Yangi narx:", narx-chegirma)
}
```

Avval `240 000`ning `15%`i hisoblanadi:

```text
240000 × 15 / 100 = 36000
```

Demak, chegirma:

```text
36000
```

Keyin boshlang‘ich narxdan chegirma ayriladi:

```text
240000 - 36000 = 204000
```

Natija:

```text
Yangi narx: 204000
```

Bu formulani foiz, soliq, komissiya va boshqa nisbiy hisob-kitoblarda ishlatish mumkin.

### 5. Haroratni aylantirish

Selsiy bo‘yicha haroratni Farengeytga o‘tkazish formulasi:

```text
°F = °C × 9 / 5 + 32
```

Kod:

```go
package main

import "fmt"

func main() {
    celsius := 25.0
    fahrenheit := celsius*9/5 + 32

    fmt.Printf("%.1f °F\n", fahrenheit)
}
```

Hisob:

```text
25 × 9 = 225
225 / 5 = 45
45 + 32 = 77
```

Natija:

```text
77.0 °F
```

Bu yerda `celsius` qiymati `25.0` deb yozilgan.

Shuning uchun u `float64`.

Natijada ifodadagi hisoblar ham suzuvchi nuqtali sonlar bilan bajariladi va kasr qismi kerak bo‘lsa saqlanadi.

### 6. Ikki nuqta orasidagi masofa

Koordinata tekisligida ikki nuqta orasidagi masofa quyidagi formula bilan hisoblanadi:

```text
d = √((x₂ - x₁)² + (y₂ - y₁)²)
```

`math.Hypot()` aynan:

```text
√(a² + b²)
```

hisobini bajaradi.

Shuning uchun koordinatalar farqini unga uzatish mumkin:

```go
package main

import (
    "fmt"
    "math"
)

func main() {
    x1, y1 := 1.0, 2.0
    x2, y2 := 4.0, 6.0

    masofa := math.Hypot(x2-x1, y2-y1)

    fmt.Println(masofa)
}
```

Avval koordinatalar orasidagi farq topiladi:

```text
x2 - x1 = 4 - 1 = 3
y2 - y1 = 6 - 2 = 4
```

Keyin:

```text
√(3² + 4²)
```

hisoblanadi:

```text
3² = 9
4² = 16
9 + 16 = 25
√25 = 5
```

Natija:

```text
5
```

Bu Pifagor teoremasining koordinatalarga qo‘llangan ko‘rinishidir.

### 7. Yuqoriga qarab bo‘lish

Ba’zan elementlarni ma’lum sig‘imdagi guruhlarga ajratish kerak bo‘ladi.

Masalan:

* `23` ta mahsulot bor;
* har bir qutiga `5` ta mahsulot sig‘adi.

Oddiy butun sonli bo‘lish:

```text
23 / 5 = 4
```

natija beradi.

Lekin `4` ta qutiga faqat:

```text
4 × 5 = 20
```

mahsulot sig‘adi.

Yana `3` ta mahsulot qoladi.

Demak, aslida `5` ta quti kerak.

Quyidagi formula butun sonli bo‘lishni yuqoriga yaxlitlashning keng tarqalgan usuli:

```go
package main

import "fmt"

func main() {
    mahsulot, qutiSigimi := 23, 5

    qutilar := (mahsulot + qutiSigimi - 1) / qutiSigimi

    fmt.Println(qutilar)
}
```

Hisob:

```text
23 + 5 - 1 = 27
27 / 5 = 5
```

Butun sonli bo‘lishda kasr qismi tashlab yuboriladi.

Shuning uchun natija:

```text
5
```

bo‘ladi.

Bu formula musbat butun sonlar uchun foydali:

```text
(n + d - 1) / d
```

Bu yerda:

* `n` — elementlar soni;
* `d` — bitta guruh sig‘imi.

### 8. Sonni ma’lum oraliqda saqlash

Ba’zan qiymat ma’lum pastki va yuqori chegaradan chiqmasligi kerak.

Masalan, foiz:

```text
0
```

dan kichik va:

```text
100
```

dan katta bo‘lmasligi kerak.

Lekin dasturga:

```text
135
```

qiymati kelgan deb tasavvur qilamiz.

Uni `0..100` oralig‘ida saqlash uchun `math.Min()` va `math.Max()`ni birga ishlatish mumkin:

```go
package main

import (
    "fmt"
    "math"
)

func main() {
    foiz := 135.0

    foiz = math.Max(0, math.Min(foiz, 100))

    fmt.Println(foiz)
}
```

Hisob ichkaridan tashqariga bajariladi.

Avval:

```go
math.Min(135, 100)
```

hisoblanadi.

Natija:

```text
100
```

Chunki `100` kichikroq.

Keyin:

```go
math.Max(0, 100)
```

hisoblanadi.

Natija yana:

```text
100
```

bo‘ladi.

Shunday qilib:

```text
135 → 100
```

ga cheklanadi.

Agar qiymat `-20` bo‘lganida:

```text
math.Min(-20, 100) = -20
math.Max(0, -20) = 0
```

bo‘lardi.

Demak:

```text
-20 → 0
```

Bu usul qiymatni ma’lum interval ichida ushlab turish uchun ishlatiladi.

### 9. Suzuvchi nuqtali sonlarni taqqoslash

`float64` qiymatlarni bevosita `==` bilan taqqoslash har doim ham kutilgan natijani bermasligi mumkin.

Sababi ko‘pgina o‘nli kasrlar ikkilik sanoq tizimida aniq ifodalanmaydi.

Shu sabab son xotirada juda kichik xato bilan saqlanishi mumkin.

Ikki qiymat orasidagi farq juda kichik bo‘lsa, ularni amaliy jihatdan teng deb hisoblash mumkin.

```go
package main

import (
    "fmt"
    "math"
)

func main() {
    a := 0.1 + 0.2
    b := 0.3

    teng := math.Abs(a-b) < 1e-9

    fmt.Println(teng)
}
```

Bu yerda:

```go
a - b
```

ikki qiymat orasidagi farqni hisoblaydi.

Farq manfiy chiqishi ham mumkin. Shuning uchun:

```go
math.Abs(a - b)
```

orqali uning moduli olinadi.

Keyin:

```go
< 1e-9
```

bilan juda kichik ruxsat etilgan chegaradan kichikligi tekshiriladi.

`1e-9` ilmiy yozuvda:

```text
0.000000001
```

degani.

Agar farq bundan kichik bo‘lsa:

```go
teng = true
```

bo‘ladi.

Bu usul **epsilon bilan taqqoslash** deb ataladigan yondashuvga misol.

Amaliy dasturda epsilon qiymatini tanlash hisobning masshtabi va talab qilinadigan aniqlikka bog‘liq.

### 10. Murakkab foiz

Murakkab foizda har bir yangi davrdagi foiz faqat boshlang‘ich summaga emas, oldingi davrlarda yig‘ilgan foizga ham qo‘shiladi.

Soddalashtirilgan formula:

```text
A = P × (1 + r)ⁿ
```

Bu yerda:

* `P` — boshlang‘ich summa;
* `r` — bir davrdagi foiz;
* `n` — davrlar soni;
* `A` — yakuniy summa.

Go’da darajani `math.Pow()` bilan hisoblash mumkin:

```go
package main

import (
    "fmt"
    "math"
)

func main() {
    boshlangich := 1_000_000.0
    yillikFoiz := 12.0
    yil := 3.0

    natija := boshlangich * math.Pow(1+yillikFoiz/100, yil)

    fmt.Printf("%.2f\n", natija)
}
```

Avval foiz kasr ko‘rinishiga o‘tkaziladi:

```text
12 / 100 = 0.12
```

Keyin:

```text
1 + 0.12 = 1.12
```

bo‘ladi.

Uch yil uchun:

```text
1.12³
```

hisoblanadi.

Bosqichma-bosqich:

```text
1.12 × 1.12 = 1.2544
1.2544 × 1.12 = 1.404928
```

Keyin boshlang‘ich summa ko‘paytiriladi:

```text
1 000 000 × 1.404928 = 1 404 928
```

Natija:

```text
1404928.00
```

bo‘ladi.

Bu yerda `math.Pow()` har bir yil uchun bir xil ko‘paytirishni qo‘lda takrorlamasdan, daraja orqali hisoblash imkonini beradi.
