# Go’da operatorlar

Operator — qiymatlar ustida ma’lum bir amal bajaradigan belgi yoki belgilar birikmasi.

Masalan:

* `+` ikki sonni qo‘shadi;
* `==` ikkita qiymat teng yoki teng emasligini tekshiradi;
* `&&` bir nechta mantiqiy shartni birlashtiradi.

Operator ishlaydigan qiymatlar **operand** deyiladi.

Masalan:

```go
a + b
```

Bu ifodada:

* `+` — operator;
* `a` — birinchi operand;
* `b` — ikkinchi operand.

Go’da operatorlar arifmetik hisob-kitoblar, qiymatlarni taqqoslash, shartlarni tekshirish, bitlar bilan ishlash va o‘zgaruvchilar qiymatini yangilash kabi ko‘plab vazifalarda ishlatiladi.

## Arifmetik operatorlar

Arifmetik operatorlar sonlar ustida matematik amallar bajaradi.

| Operator | Amal             | Misol    | Natija |
| -------- | ---------------- | -------- | -----: |
| `+`      | qo‘shish         | `10 + 3` |   `13` |
| `-`      | ayirish          | `10 - 3` |    `7` |
| `*`      | ko‘paytirish     | `10 * 3` |   `30` |
| `/`      | bo‘lish          | `10 / 3` |    `3` |
| `%`      | qoldiqli bo‘lish | `10 % 3` |    `1` |

Quyidagi dastur barcha asosiy arifmetik operatorlarni ko‘rsatadi:

```go
package main

import "fmt"

func main() {
    a := 10
    b := 3

    fmt.Println("Qo'shish:", a+b)
    fmt.Println("Ayirish:", a-b)
    fmt.Println("Ko'paytirish:", a*b)
    fmt.Println("Bo'lish:", a/b)
    fmt.Println("Qoldiq:", a%b)
}
```

Natija:

```text
Qo'shish: 13
Ayirish: 7
Ko'paytirish: 30
Bo'lish: 3
Qoldiq: 1
```

Bu yerda `a` va `b` ikkalasi ham `int` turidagi butun sonlar.

Shuning uchun:

```go
a / b
```

ifodasi ham butun sonli bo‘lish sifatida bajariladi.

`10 / 3` matematik jihatdan `3.333...` bo‘lsa ham, Go bu yerda faqat butun qismini qoldiradi. Natija `3` bo‘ladi.

### Butun va kasrli sonlarni bo‘lish

Go’da bo‘lish natijasining turi operandlarning turiga bog‘liq.

Agar ikkala operand ham butun son bo‘lsa, natija ham butun son bo‘ladi. Kasr qismi tashlab yuboriladi:

```go
natija := 10 / 3 // 3
```

Bu hisob quyidagicha ishlaydi:

```text
10 / 3 = 3.333...
```

Lekin ikkala operand ham `int` bo‘lgani uchun kasr qismi saqlanmaydi:

```text
natija = 3
```

Agar kasrli natija kerak bo‘lsa, operandlarni `float32` yoki `float64` kabi kasrli turga o‘tkazish kerak.

Masalan:

```go
package main

import "fmt"

func main() {
    jami := 10
    odamlar := 3
    harBiriga := float64(jami) / float64(odamlar)

    fmt.Printf("Har biriga: %.2f\n", harBiriga)
}
```

Natija:

```text
Har biriga: 3.33
```

Bu yerda:

```go
float64(jami)
```

`jami` qiymatini `int` turidan `float64` turiga o‘tkazadi.

Xuddi shunday:

```go
float64(odamlar)
```

ham `odamlar` qiymatini `float64` turiga o‘tkazadi.

Shundan keyin hisob:

```text
10.0 / 3.0
```

ko‘rinishida bajariladi va kasr qismi saqlanadi.

`fmt.Printf` ichidagi:

```go
%.2f
```

natijani kasrdan keyin ikkita raqam bilan chiqaradi.

**Diqqat**

Nolga bo‘lish mumkin emas.

````
Butun sonni `0`ga bo‘lish runtime paytida xatoga olib keladi.

Masalan, quyidagi kod xavfli:

```go
boluvchi := 0
natija := 10 / boluvchi
```

`boluvchi` qiymati runtime paytida `0` bo‘lgani uchun dastur bajarilish vaqtida panic yuz beradi.
````

### Qoldiqli bo‘lish

`%` operatori bo‘lishdan keyin qolgan qoldiqni qaytaradi.

Masalan:

```go
17 % 5
```

Hisobni bosqichma-bosqich ko‘ramiz:

```text
17 / 5 = 3
3 * 5 = 15
17 - 15 = 2
```

Demak:

```text
17 % 5 = 2
```

Qoldiq operatori ko‘p joyda foydali.

Masalan:

* son juft yoki toqligini tekshirish;
* vaqtni soat, daqiqa va sekundga ajratish;
* davriy hisob-kitoblar;
* indekslarni aylantirib ishlatish.

Muhim jihat: `%` Go’da butun sonlar bilan ishlaydi.

## Birga oshirish va kamaytirish

`++` operatori qiymatni bittaga oshiradi.

`--` operatori esa qiymatni bittaga kamaytiradi.

Masalan:

```go
package main

import "fmt"

func main() {
    hisob := 5
    hisob++
    fmt.Println(hisob)

    hisob--
    fmt.Println(hisob)
}
```

Natija:

```text
6
5
```

Dastur boshida:

```text
hisob = 5
```

Keyin:

```go
hisob++
```

bajariladi:

```text
hisob = 6
```

So‘ng:

```go
hisob--
```

bajariladi:

```text
hisob = 5
```

Bu operatorlar boshqa ayrim dasturlash tillaridagi kabi ifoda emas.

Go’da `hisob++` va `hisob--` alohida statement, ya’ni alohida buyruq hisoblanadi.

Shuning uchun ularni boshqa ifodaning ichiga joylab bo‘lmaydi:

```go
// natija := hisob++ // kompilyatsiya xatosi
```

Masalan, C yoki JavaScript’da uchrashi mumkin bo‘lgan:

```text
x = y++
```

usuli Go’da mavjud emas.

Bu qoida kodni tushunarliroq qiladi. Qiymatning qachon oshirilgani yoki kamaytirilgani alohida qatorda aniq ko‘rinib turadi.

## Tayinlash operatorlari

`=` operatori o‘ng tomondagi qiymatni chap tomondagi mavjud o‘zgaruvchiga tayinlaydi.

Masalan:

```go
son := 10
son = 20
```

Birinchi qatorda:

```go
son := 10
```

yangi `son` o‘zgaruvchisi yaratiladi va unga `10` qiymati beriladi.

Ikkinchi qatorda:

```go
son = 20
```

yangi o‘zgaruvchi yaratilmaydi. Mavjud `son` o‘zgaruvchisining qiymati `20`ga o‘zgartiriladi.

Go’da arifmetik amal va tayinlashni bitta qisqa operator bilan yozish mumkin:

| Qisqa yozuv | To‘liq yozuv    |
| ----------- | --------------- |
| `son += 5`  | `son = son + 5` |
| `son -= 5`  | `son = son - 5` |
| `son *= 5`  | `son = son * 5` |
| `son /= 5`  | `son = son / 5` |
| `son %= 5`  | `son = son % 5` |

Masalan:

```go
package main

import "fmt"

func main() {
    balans := 100
    balans += 50
    balans -= 20

    fmt.Println("Balans:", balans)
}
```

Natija:

```text
Balans: 130
```

Hisobni bosqichma-bosqich ko‘ramiz.

Boshlang‘ich qiymat:

```text
balans = 100
```

Keyin:

```go
balans += 50
```

aslida quyidagini anglatadi:

```go
balans = balans + 50
```

Natija:

```text
balans = 150
```

Keyin:

```go
balans -= 20
```

quyidagiga teng:

```go
balans = balans - 20
```

Natija:

```text
balans = 130
```

Bu yerda `:=` va `=` o‘rtasidagi farqni eslab qolish muhim.

`:=` odatda yangi lokal o‘zgaruvchi e’lon qilish va unga boshlang‘ich qiymat berish uchun ishlatiladi.

`=` esa mavjud o‘zgaruvchiga yangi qiymat tayinlaydi.

## Taqqoslash operatorlari

Taqqoslash operatorlari ikkita qiymatni solishtiradi.

Taqqoslash natijasi har doim `bool` turida bo‘ladi:

```text
true
```

yoki:

```text
false
```

Asosiy taqqoslash operatorlari:

| Operator | Ma’nosi          | Misol      | Natija  |
| -------- | ---------------- | ---------- | ------- |
| `==`     | teng             | `10 == 10` | `true`  |
| `!=`     | teng emas        | `10 != 3`  | `true`  |
| `>`      | katta            | `10 > 3`   | `true`  |
| `<`      | kichik           | `10 < 3`   | `false` |
| `>=`     | katta yoki teng  | `10 >= 10` | `true`  |
| `<=`     | kichik yoki teng | `3 <= 10`  | `true`  |

Masalan:

```go
package main

import "fmt"

func main() {
    yosh := 20
    minimalYosh := 18

    fmt.Println("Teng:", yosh == minimalYosh)
    fmt.Println("Teng emas:", yosh != minimalYosh)
    fmt.Println("Ruxsat etilgan:", yosh >= minimalYosh)
}
```

Natija:

```text
Teng: false
Teng emas: true
Ruxsat etilgan: true
```

Birinchi taqqoslash:

```go
yosh == minimalYosh
```

quyidagicha:

```text
20 == 18
```

Bu noto‘g‘ri, shuning uchun natija:

```text
false
```

Ikkinchi taqqoslash:

```go
20 != 18
```

Bu to‘g‘ri:

```text
true
```

Uchinchi shart:

```go
20 >= 18
```

ham to‘g‘ri. Demak, minimal yosh talabi bajarilgan.

**Ma'lumot**

`=` va `==` bir xil operator emas.

````
`=` qiymat tayinlaydi:

```go
yosh = 20
```

`==` esa tenglikni tekshiradi:

```go
yosh == 20
```
````

## Mantiqiy operatorlar

Mantiqiy operatorlar `bool` qiymatlar bilan ishlaydi.

Ular bir nechta shartni birlashtirish yoki shartning teskarisini olish uchun ishlatiladi.

| Operator | Nomi | Qachon `true` bo‘ladi?                   |
| -------- | ---- | ---------------------------------------- |
| `&&`     | VA   | ikkala shart ham `true` bo‘lsa           |
| `\|\|`   | YOKI | shartlardan kamida bittasi `true` bo‘lsa |
| `!`      | EMAS | operand `false` bo‘lsa                   |

**Ma'lumot**

`bool` qiymatlar uchun tartib taqqoslashlari, masalan `<` yoki `>`, ishlatilmaydi.

```
`bool` qiymatlarini tenglik bo‘yicha taqqoslash uchun `==` va `!=` operatorlaridan foydalanish mumkin.
```

Masalan:

```go
package main

import "fmt"

func main() {
    yosh := 22
    chiptasiBor := true
    taqiqlangan := false

    kirishiMumkin := yosh >= 18 && chiptasiBor && !taqiqlangan
    fmt.Println("Kirish mumkin:", kirishiMumkin)
}
```

Natija:

```text
Kirish mumkin: true
```

Bu ifodani alohida qismlarga ajratamiz:

```go
yosh >= 18
```

Natija:

```text
22 >= 18
true
```

Keyingi qiymat:

```go
chiptasiBor
```

uning qiymati allaqachon:

```text
true
```

Keyin:

```go
!taqiqlangan
```

`taqiqlangan` qiymati:

```text
false
```

`!` operatori uni teskarisiga o‘giradi:

```text
!false = true
```

Shuning uchun umumiy ifoda:

```text
true && true && true
```

bo‘ladi.

Natija:

```text
true
```

Demak, foydalanuvchining yoshi yetarli, chiptasi bor va unga kirish taqiqlanmagan.

**Mantiqiy jadval:**

| `a`     | `b`     | `a && b` | `a \|\| b` |
| ------- | ------- | -------- | ---------- |
| `false` | `false` | `false`  | `false`    |
| `false` | `true`  | `false`  | `true`     |
| `true`  | `false` | `false`  | `true`     |
| `true`  | `true`  | `true`   | `true`     |

`&&` operatorida ikkala tomon ham `true` bo‘lishi kerak.

Masalan:

```text
true && false = false
```

`||` operatorida esa kamida bitta tomon `true` bo‘lishi yetarli:

```text
true || false = true
```

`!` operatori qiymatni teskarisiga o‘zgartiradi:

```text
!true  = false
!false = true
```

### Qisqa tutashuv

`&&` va `||` operatorlari barcha operandlarni har doim ham hisoblamaydi.

Natija oldindan ma’lum bo‘lib qolsa, Go ifodaning qolgan qismini tekshirmaydi.

Bu **qisqa tutashuv**, ya’ni short-circuit evaluation deyiladi.

Masalan:

```go
boluvchi := 0
xavfsiz := boluvchi != 0 && 10/boluvchi > 1
```

Bu ifodani bosqichma-bosqich ko‘ramiz.

Birinchi shart:

```go
boluvchi != 0
```

`boluvchi` qiymati `0`, shuning uchun:

```text
0 != 0
false
```

`&&` operatorida umumiy natija `true` bo‘lishi uchun ikkala tomon ham `true` bo‘lishi kerak.

Birinchi tomon allaqachon `false`.

Demak, umumiy natija ham albatta `false` bo‘ladi.

Shu sabab Go ikkinchi qismni hisoblamaydi:

```go
10 / boluvchi > 1
```

Agar bu qism bajarilganida:

```go
10 / 0
```

nolga bo‘lish yuz berardi.

Lekin short-circuit tufayli bu hisob umuman bajarilmaydi.

`||` operatorida ham shunga o‘xshash qoida ishlaydi.

Masalan:

```go
tayyor := true || murakkabTekshiruv()
```

Birinchi operand `true` bo‘lgani uchun umumiy natija allaqachon `true`.

Shuning uchun `murakkabTekshiruv()` chaqirilmaydi.

## Bit operatorlari

Bit operatorlari butun sonlarning ikkilik, ya’ni binary ko‘rinishi ustida ishlaydi.

Masalan, o‘nlik sanoq sistemasidagi:

```text
6
```

ikkilik ko‘rinishda:

```text
110
```

bo‘ladi.

Bit operatorlari quyidagi vazifalarda uchrashi mumkin:

* bir nechta ruxsatni bitta qiymatda saqlash;
* bit flag va bitmask bilan ishlash;
* protokol yoki fayl formatlarini qayta ishlash;
* past darajali hisob-kitoblar;
* ma’lum bitlarni yoqish yoki o‘chirish.

Asosiy bit operatorlari:

| Operator | Amal                                                      |
| -------- | --------------------------------------------------------- |
| `&`      | bit bo‘yicha VA                                           |
| `\|`     | bit bo‘yicha YOKI                                         |
| `^`      | bit bo‘yicha XOR yoki unary holatda bitlarni inkor qilish |
| `&^`     | bitni tozalash — AND NOT                                  |
| `<<`     | chapga surish                                             |
| `>>`     | o‘ngga surish                                             |

Misol:

```go
package main

import "fmt"

func main() {
    a := 6 // ikkilik ko'rinishi: 110
    b := 3 // ikkilik ko'rinishi: 011

    fmt.Println(a & b)  // 010, ya'ni 2
    fmt.Println(a | b)  // 111, ya'ni 7
    fmt.Println(a ^ b)  // 101, ya'ni 5
    fmt.Println(a << 1) // 1100, ya'ni 12
}
```

Natija:

```text
2
7
5
12
```

Endi bu natijalar qanday hosil bo‘lishini ko‘ramiz.

`a`:

```text
6 = 110
```

`b`:

```text
3 = 011
```

Qulay bo‘lishi uchun ularni bir xil uzunlikda yozamiz:

```text
a = 110
b = 011
```

### `&` — bit bo‘yicha VA

```text
110
011
---
010
```

Har bir bit juftligi tekshiriladi.

Faqat ikkala bit ham `1` bo‘lsa, natijada `1` qoladi.

```text
1 & 0 = 0
1 & 1 = 1
0 & 1 = 0
```

Natija:

```text
010 = 2
```

### `|` — bit bo‘yicha YOKI

```text
110
011
---
111
```

Kamida bittasi `1` bo‘lsa, natija biti `1` bo‘ladi.

Natija:

```text
111 = 7
```

### `^` — XOR

Ikki operandli `^` operatorida bitlar har xil bo‘lsa `1`, bir xil bo‘lsa `0` hosil bo‘ladi:

```text
110
011
---
101
```

Natija:

```text
101 = 5
```

`^` unary operator sifatida bitta butun songa qo‘llansa, uning barcha bitlarini teskarisiga o‘giradi. Bunda natija turning bit kengligiga bog‘liq bo‘ladi.

### `<<` — chapga surish

Quyidagi ifoda:

```go
a << 1
```

`a` qiymatining bitlarini bir pozitsiya chapga suradi.

Boshlang‘ich qiymat:

```text
110
```

Bir bit chapga:

```text
1100
```

Bu o‘nlik sanoq sistemasida:

```text
12
```

ga teng.

Hozircha bu operatorlarning asosiy vazifasini tushunib olish yetarli. Keyingi misollarda bit flaglar bilan amaliy ishlatilishini ko‘ramiz.

## Operatorlar ustuvorligi

Bitta ifodada bir nechta operator qatnashsa, Go ularni ma’lum ustuvorlik tartibida bajaradi.

Masalan:

```go
birinchi := 2 + 3*4
```

Bu ifoda:

```text
2 + 3 * 4
```

ko‘rinishida.

`*` operatorining ustuvorligi `+`dan yuqori.

Shuning uchun avval:

```text
3 * 4 = 12
```

hisoblanadi.

Keyin:

```text
2 + 12 = 14
```

Natija:

```text
14
```

Agar qavs ishlatsak:

```go
ikkinchi := (2 + 3) * 4
```

avval qavs ichidagi ifoda bajariladi:

```text
2 + 3 = 5
```

Keyin:

```text
5 * 4 = 20
```

Natija:

```text
20
```

Soddalashtirilgan ustuvorlik tartibi yuqoridan pastga quyidagicha:

1. `*`, `/`, `%`, `<<`, `>>`, `&`, `&^`;
2. `+`, `-`, `|`, `^`;
3. `==`, `!=`, `<`, `<=`, `>`, `>=`;
4. `&&`;
5. `||`.

Bir guruh ichidagi operatorlar bir xil ustuvorlikka ega.

Ifoda murakkablashib ketsa, faqat operatorlar ustuvorligiga ishonib yozish shart emas.

Qavs ishlatish ko‘pincha kodning maqsadini aniqroq ko‘rsatadi.

Masalan:

```go
narx - narx*chegirma/100
```

texnik jihatdan to‘g‘ri bo‘lishi mumkin.

Lekin:

```go
narx - (narx*chegirma)/100
```

ko‘rinishi o‘quvchiga hisob qanday guruhlanganini aniqroq ko‘rsatadi.

Keyingi qismda operatorlardan foydalanib sodda matematik hisob-kitoblarni bajaramiz.

## Misollar

### 1. Juft yoki toq sonni aniqlash

Bu misol `%` operatoridan foydalanib sonning juft yoki toqligini tekshirishni ko‘rsatadi.

```go
package main

import "fmt"

func main() {
    son := 17
    fmt.Println(son%2 == 0)
}
```

`son % 2` sonni `2`ga bo‘lgandagi qoldiqni hisoblaydi.

`17` uchun:

```text
17 % 2 = 1
```

Keyin:

```go
son%2 == 0
```

aslida:

```text
1 == 0
```

bo‘ladi.

Natija:

```text
false
```

Agar son juft bo‘lsa, uni `2`ga bo‘lganda qoldiq `0` bo‘ladi.

Masalan:

```text
18 % 2 = 0
```

Shuning uchun `% 2 == 0` juft sonni tekshirishning keng tarqalgan usuli hisoblanadi.

### 2. Qiymatni oraliqda tekshirish

Bu misol bitta qiymat ikkita chegara orasida ekanini tekshiradi.

```go
package main

import "fmt"

func main() {
    yosh := 24
    mehnatYoshi := yosh >= 18 && yosh <= 60
    fmt.Println(mehnatYoshi)
}
```

Ifodani ikkita qismga ajratamiz:

```go
yosh >= 18
```

va:

```go
yosh <= 60
```

`yosh` qiymati `24`.

Demak:

```text
24 >= 18 = true
24 <= 60 = true
```

Keyin `&&` ishlaydi:

```text
true && true = true
```

Natija:

```text
true
```

Bu yerda `&&` ishlatilganining sababi shuki, yosh ikkala talabga ham bir vaqtda mos kelishi kerak.

### 3. Qiymatni ketma-ket yangilash

Bu misolda tayinlash operatorlarining qisqa ko‘rinishlari va `--` operatori birgalikda ishlatiladi.

```go
package main

import "fmt"

func main() {
    son := 10
    son += 5
    son *= 2
    son--
    fmt.Println(son)
}
```

Boshlang‘ich qiymat:

```text
son = 10
```

Birinchi amal:

```go
son += 5
```

quyidagiga teng:

```text
10 + 5 = 15
```

Endi:

```text
son = 15
```

Keyin:

```go
son *= 2
```

quyidagiga teng:

```text
15 * 2 = 30
```

Endi:

```text
son = 30
```

Oxirida:

```go
son--
```

qiymatni bittaga kamaytiradi:

```text
30 - 1 = 29
```

Natija:

```text
29
```

Bu misol qiymatni bir necha amal orqali ketma-ket o‘zgartirishni ko‘rsatadi.

### 4. Qisqa tutashuv

Bu misol `&&` operatorining short-circuit xususiyati nolga bo‘lishning oldini qanday olishini ko‘rsatadi.

```go
package main

import "fmt"

func main() {
    boluvchi := 0
    xavfsiz := boluvchi != 0 && 10/boluvchi > 1
    fmt.Println(xavfsiz)
}
```

Avval:

```go
boluvchi != 0
```

tekshiriladi.

Qiymat:

```text
boluvchi = 0
```

Shuning uchun:

```text
0 != 0 = false
```

`&&`ning chap tomoni `false` bo‘lsa, umumiy ifoda ham `false` bo‘lishi aniq.

Go o‘ng tomonni hisoblamaydi:

```go
10 / boluvchi > 1
```

Shu sabab:

```text
10 / 0
```

amali bajarilmaydi va nolga bo‘lish xatosi yuz bermaydi.

Natija:

```text
false
```

Bu usul ko‘pincha xavfli amalni bajarishdan oldin kerakli shartni tekshirish uchun ishlatiladi.

### 5. Qoldiq bilan vaqtni ajratish

Bu misol `/` va `%` operatorlari yordamida umumiy sekundlarni soat, daqiqa va sekundlarga ajratadi.

```go
package main

import "fmt"

func main() {
    jamiSekund := 3672
    soat := jamiSekund / 3600
    daqiqa := jamiSekund % 3600 / 60
    sekund := jamiSekund % 60
    fmt.Println(soat, daqiqa, sekund)
}
```

Boshlang‘ich qiymat:

```text
jamiSekund = 3672
```

Avval soatni topamiz:

```go
soat := jamiSekund / 3600
```

Hisob:

```text
3672 / 3600 = 1
```

Demak:

```text
soat = 1
```

Endi to‘liq soatdan keyin qancha sekund qolganini topamiz:

```text
3672 % 3600 = 72
```

Bu `72` sekund ichidan daqiqani topamiz:

```text
72 / 60 = 1
```

Demak:

```text
daqiqa = 1
```

Oxirida to‘liq daqiqalardan keyingi qoldiq sekundlarni topamiz:

```text
3672 % 60 = 12
```

Demak:

```text
sekund = 12
```

Natija:

```text
1 1 12
```

Ya’ni:

```text
1 soat, 1 daqiqa, 12 sekund
```

Bu yerda `/` to‘liq birliklar sonini oladi, `%` esa keyingi bosqich uchun qolgan qismini ajratadi.

### 6. Bit yordamida bayroqni yoqish

Bu misol bit flag yordamida yangi ruxsatni mavjud qiymatga qo‘shishni ko‘rsatadi.

```go
package main

import "fmt"

func main() {
    const yozish = 1 << 1
    ruxsat := 1
    ruxsat |= yozish
    fmt.Printf("%03b\n", ruxsat)
}
```

Avval:

```go
const yozish = 1 << 1
```

hisoblanadi.

`1`ning binary ko‘rinishi:

```text
001
```

Uni bir bit chapga suramiz:

```text
001 << 1 = 010
```

Demak:

```text
yozish = 2
```

Keyin:

```go
ruxsat := 1
```

Binary ko‘rinishda:

```text
ruxsat = 001
```

Quyidagi operator:

```go
ruxsat |= yozish
```

aslida:

```go
ruxsat = ruxsat | yozish
```

degani.

Hisob:

```text
001
010
---
011
```

Natija:

```text
011
```

`|` kerakli bitni yoqadi va boshqa yoqilgan bitlarni saqlab qoladi.

Shu sabab bit flaglar to‘plamiga yangi ruxsat qo‘shishda bu operator juda qulay.

### 7. Bit yordamida bayroqni tekshirish

Bu misol ma’lum bir bit yoqilgan yoki yoqilmaganini tekshiradi.

```go
package main

import "fmt"

func main() {
    const yozish = 1 << 1
    ruxsat := 0b011
    fmt.Println(ruxsat&yozish != 0)
}
```

`yozish` qiymati:

```text
010
```

`ruxsat` esa:

```text
011
```

Endi `&` operatorini qo‘llaymiz:

```text
011
010
---
010
```

Natija `0` emas:

```text
010 != 000
```

Shuning uchun:

```text
true
```

chiqadi.

Bu tekshiruvning ma’nosi: `ruxsat` qiymatida `yozish` biti yoqilganmi?

`&` faqat ikkala qiymatda ham `1` bo‘lgan bitlarni qoldiradi.

Agar kerakli bit mavjud bo‘lmasa, natija `0` bo‘ladi.

### 8. Bitni o‘chirish

Bu misolda `&^` operatori yordamida ma’lum bir flag o‘chiriladi.

```go
package main

import "fmt"

func main() {
    const yozish = 1 << 1
    ruxsat := 0b111
    ruxsat &^= yozish
    fmt.Printf("%03b\n", ruxsat)
}
```

Boshlang‘ich qiymat:

```text
ruxsat = 111
```

`yozish` flagi:

```text
010
```

Quyidagi yozuv:

```go
ruxsat &^= yozish
```

aslida:

```go
ruxsat = ruxsat &^ yozish
```

degani.

`&^` operatori o‘ng operandda `1` bo‘lgan bitlarni chap operanddan tozalaydi.

Shuning uchun:

```text
111
010
---
101
```

Natija:

```text
101
```

Ya’ni o‘rtadagi bit o‘chirildi, qolgan bitlar esa o‘zgarishsiz qoldi.

### 9. Eksklyuziv OR bilan qiymatlarni almashtirish

Bu misol `^` operatori yordamida ikki butun son qiymatini vaqtinchalik o‘zgaruvchisiz almashtirish mumkinligini ko‘rsatadi.

```go
package main

import "fmt"

func main() {
    a, b := 5, 9
    a ^= b
    b ^= a
    a ^= b
    fmt.Println(a, b)
}
```

Boshlanishida:

```text
a = 5
b = 9
```

Birinchi amal:

```go
a ^= b
```

aslida:

```go
a = a ^ b
```

Keyingi amallar XOR xususiyatidan foydalanib eski qiymatlarni qayta tiklaydi va ularning joyini almashtiradi.

Oxirida:

```text
a = 9
b = 5
```

Natija:

```text
9 5
```

Bu misol `^` operatorining qiziqarli xususiyatini ko‘rsatadi.

Lekin amaliy Go kodida bu usul odatda tavsiya etilmaydi, chunki Go’da ancha tushunarli yozuv mavjud:

```go
a, b = b, a
```

Bu variant qisqaroq, o‘qilishi osonroq va kodning maqsadini darhol ko‘rsatadi.

### 10. Ustuvorlikni qavs bilan aniqlashtirish

Bu misol operatorlar ustuvorligi va qavs yordamida hisoblash maqsadini aniq ko‘rsatishni namoyish qiladi.

```go
package main

import "fmt"

func main() {
    chegirma := 100_000 - (100_000*15)/100
    fmt.Println(chegirma)
}
```

Bu yerda boshlang‘ich narx:

```text
100000
```

Chegirma:

```text
15%
```

Avval chegirma miqdori hisoblanadi:

```text
100000 * 15 = 1500000
```

Keyin:

```text
1500000 / 100 = 15000
```

Demak, chegirma miqdori:

```text
15000
```

Asosiy qiymatdan chegirmani ayiramiz:

```text
100000 - 15000 = 85000
```

Natija:

```text
85000
```

Qavs:

```go
(100_000 * 15)
```

hisobning qaysi qismini birgalikda ko‘rish kerakligini aniqroq ko‘rsatadi.

`100_000` ichidagi `_` esa faqat sonni o‘qishni osonlashtiradi.

Quyidagi ikki yozuvning qiymati bir xil:

```go
100000
```

va:

```go
100_000
```

Underscore `_` sonning qiymatiga ta’sir qilmaydi. U katta sonlarni ko‘z bilan guruhlab o‘qishni qulaylashtiradi.
