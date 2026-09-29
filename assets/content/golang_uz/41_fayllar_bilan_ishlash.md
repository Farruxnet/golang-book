# Go’da fayllar bilan ishlash

Fayl — ma’lumotni dastur tugaganidan keyin ham saqlash usullaridan biri. Dastur xotirasidagi oddiy o‘zgaruvchilar dastur tugashi bilan yo‘qoladi. Faylga yozilgan ma’lumot esa diskda qoladi va keyingi ishga tushishda yana o‘qilishi mumkin.

Konfiguratsiya, log, JSON hujjat, rasm, hisobot va boshqa ko‘plab ma’lumotlar fayl ko‘rinishida saqlanishi mumkin.

Go’da fayllar bilan ishlaganda xato yuz berishi odatiy holat. Masalan:

* fayl mavjud bo‘lmasligi mumkin;
* dasturda faylni o‘qish yoki yozish uchun ruxsat bo‘lmasligi mumkin;
* diskda bo‘sh joy qolmagan bo‘lishi mumkin;
* fayl boshqa jarayon tomonidan ishlatilayotgan bo‘lishi mumkin;
* berilgan yo‘l noto‘g‘ri bo‘lishi mumkin.

Shu sabab fayl bilan ishlaydigan deyarli har bir amal `error` qaytaradi. Bu xatolarni tekshirmasdan davom etish noto‘g‘ri natijaga yoki hatto `panic`ga olib kelishi mumkin.

## Asosiy paketlar

Fayllar bilan ishlashda Go standart kutubxonasidagi bir nechta paket ko‘p uchraydi:

* `os` — fayl yaratish, ochish, o‘qish, yozish, o‘chirish va metadata olish uchun;
* `io` — ma’lumot oqimini o‘qish va yozish uchun umumiy interface va yordamchi funksiyalarni beradi;
* `bufio` — buferli o‘qish va yozish uchun, jumladan faylni qatorma-qator o‘qishda qulay;
* `path/filepath` — operatsion tizimga mos fayl yo‘llarini qurish va tahlil qilish uchun;
* `encoding/json` — JSON ma’lumotini Go qiymatiga va Go qiymatini JSON ko‘rinishiga o‘girish uchun.

Eski Go kodlarida `io/ioutil` paketini ham uchratishingiz mumkin. Uning ko‘p funksiyalari keyinchalik `os` va `io` paketlariga ko‘chirilgan.

Masalan, yangi kodda odatda:

* `os.ReadFile`;
* `os.WriteFile`;
* `os.CreateTemp`;
* `io.ReadAll`

kabi funksiyalar ishlatiladi.

Bu eski kod ishlamaydi degani emas. `io/ioutil` bilan yozilgan mavjud kodni ko‘rishingiz mumkin. Lekin yangi kod yozayotganda zamonaviy `os` va `io` funksiyalaridan foydalanish ma’qul.

## Faylga yozish va undan o‘qish

Kichik faylni bir amal bilan yozish uchun `os.WriteFile` juda qulay.

Uning asosiy xatti-harakati quyidagicha:

1. fayl mavjud bo‘lmasa, yangi fayl yaratadi;
2. fayl mavjud bo‘lsa, uning eski tarkibini qisqartiradi;
3. berilgan ma’lumotni fayl boshidan yozadi.

Quyidagi misolda avval matn faylga yoziladi, keyin shu fayl qayta o‘qiladi:

```go
package main

import (
	"fmt"
	"log"
	"os"
)

func main() {
	path := "xabar.txt"
	content := []byte("Go fayllarni baytlar ketma-ketligi sifatida o‘qiydi.\n")

	if err := os.WriteFile(path, content, 0o644); err != nil {
		log.Fatal("faylga yozilmadi: ", err)
	}

	data, err := os.ReadFile(path)
	if err != nil {
		log.Fatal("fayl o‘qilmadi: ", err)
	}

	fmt.Print(string(data))
}
```

Natija:

```text
Go fayllarni baytlar ketma-ketligi sifatida o‘qiydi.
```

Bu kodni bosqichma-bosqich ko‘ramiz.

Avval fayl yo‘li belgilanadi:

```go
path := "xabar.txt"
```

Bu relative path. Demak, fayl odatda dastur ishlayotgan joriy katalogga nisbatan topiladi yoki yaratiladi.

Keyin matn `[]byte`ga aylantiriladi:

```go
content := []byte("Go fayllarni baytlar ketma-ketligi sifatida o‘qiydi.\n")
```

`os.WriteFile` ma’lumotni `[]byte` ko‘rinishida qabul qiladi.

Fayl tizimi uchun "matn", "JSON" yoki "rasm" degan tushuncha asosiy darajada mavjud emas. Fayl ichida baytlar ketma-ketligi saqlanadi. Fayl formati shu baytlarni qanday talqin qilish kerakligini belgilaydi.

Masalan:

```go
[]byte("Go")
```

string qiymatini UTF-8 kodlangan baytlar ketma-ketligiga aylantiradi.

Keyin fayl yoziladi:

```go
if err := os.WriteFile(path, content, 0o644); err != nil {
	log.Fatal("faylga yozilmadi: ", err)
}
```

Bu yerda uchta argument bor:

```text
path
content
0o644
```

`path` — fayl nomi.

`content` — yoziladigan baytlar.

`0o644` — yangi fayl yaratilganda ishlatiladigan fayl rejimi.

Keyin fayl qayta o‘qiladi:

```go
data, err := os.ReadFile(path)
```

`os.ReadFile` ham `[]byte` qaytaradi. Shu sabab chiqarishda:

```go
fmt.Print(string(data))
```

deb `[]byte` qiymati `string`ga aylantiriladi.

### `0o644` nimani anglatadi?

`0o644` — sakkizlik, ya’ni octal sanoq sistemasida yozilgan fayl rejimi.

Unix oilasidagi tizimlarda u taxminan quyidagi ruxsatlarni bildiradi:

```text
egasi:      read + write
guruh:      read
boshqalar:  read
```

Simvolik ko‘rinishda:

```text
rw-r--r--
```

Bu qiymatni uchta qism sifatida ko‘rish mumkin:

```text
6 4 4
```

`6`:

```text
4 + 2 = read + write
```

`4`:

```text
read
```

Yana bir `4` ham:

```text
read
```

Lekin bu yerda muhim bir nozik joy bor. Yangi faylning real yakuniy ruxsati jarayonning `umask` sozlamasiga ham bog‘liq.

Demak, `0o644` berilgan bo‘lsa ham, operatsion tizim undan ayrim ruxsatlarni olib tashlashi mumkin.

Windows esa Unix permission bitlarini aynan Unix tizimlaridagidek talqin qilmaydi.

> **Diqqat**
>
> `os.WriteFile` mavjud fayl tarkibini almashtiradi. Eski ma’lumot kerak bo‘lsa, uni avval saqlab oling yoki faylni `os.O_APPEND` rejimida oching.

### Qachon `os.ReadFile` ishlatish kerak?

`os.ReadFile` faylning butun tarkibini bir marta xotiraga yuklaydi.

Masalan, 20 KiB konfiguratsiya fayli uchun bu juda qulay:

```go
data, err := os.ReadFile("config.json")
```

Kod sodda va tushunarli bo‘ladi.

Lekin fayl bir necha gigabayt bo‘lsa, vaziyat o‘zgaradi. Masalan, 4 GiB log faylini `os.ReadFile` bilan o‘qishga urinsangiz, dastur juda katta hajmdagi xotirani band qilishi mumkin.

Shu sabab katta fayllarda ma’lumotni oqim, ya’ni stream tarzida qayta ishlash ma’qul. Bunda faylning hammasi birdan xotiraga olinmaydi. U kichik qismlar bilan o‘qiladi.

Bunday vazifalarda `bufio.Scanner`, `bufio.Reader`, `file.Read` yoki `io.Copy` kabi vositalar ishlatiladi.

## Faylga qo‘shimcha yozish

Ba’zan mavjud fayl tarkibini yo‘qotmasdan, yangi ma’lumotni uning oxiriga qo‘shish kerak bo‘ladi.

Log fayli bunga yaxshi misol:

```text
server ishga tushdi
so‘rov qabul qilindi
yangi foydalanuvchi kirdi
```

Har yangi log yozuvi eski ma’lumotni almashtirmasdan fayl oxiriga qo‘shilishi kerak.

Buning uchun `os.OpenFile` ishlatilishi mumkin:

```go
package main

import (
	"fmt"
	"os"
)

func appendLine(path, line string) error {
	file, err := os.OpenFile(path, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0o644)
	if err != nil {
		return fmt.Errorf("faylni ochish: %w", err)
	}

	if _, err := file.WriteString(line + "\n"); err != nil {
		_ = file.Close()
		return fmt.Errorf("faylga yozish: %w", err)
	}

	if err := file.Close(); err != nil {
		return fmt.Errorf("faylni yopish: %w", err)
	}
	return nil
}

func main() {
	path := "ilova.log"
	if err := os.Remove(path); err != nil && !os.IsNotExist(err) {
		fmt.Println("eski faylni o‘chirish:", err)
		return
	}

	if err := appendLine(path, "server ishga tushdi"); err != nil {
		fmt.Println("xato:", err)
		return
	}
	if err := appendLine(path, "so‘rov qabul qilindi"); err != nil {
		fmt.Println("xato:", err)
		return
	}

	data, err := os.ReadFile(path)
	if err != nil {
		fmt.Println("xato:", err)
		return
	}
	fmt.Print(string(data))
}
```

Natija:

```text
server ishga tushdi
so‘rov qabul qilindi
```

Asosiy qator:

```go
file, err := os.OpenFile(
	path,
	os.O_APPEND|os.O_CREATE|os.O_WRONLY,
	0o644,
)
```

Original kodda bu bir qatorda yozilgan. Ma’nosi esa bir xil: bir nechta flag bitta qiymatga birlashtirilmoqda.

Bu yerda `|` — bitli OR operatori.

Flaglar quyidagi vazifani bajaradi:

* `os.O_APPEND` — yozuvlarni fayl oxiriga qo‘shadi;
* `os.O_CREATE` — fayl mavjud bo‘lmasa, uni yaratadi;
* `os.O_WRONLY` — faylni faqat yozish uchun ochadi.

Ularni birlashtirish:

```go
os.O_APPEND | os.O_CREATE | os.O_WRONLY
```

`os.OpenFile`ga bir vaqtning o‘zida uchta xatti-harakat kerakligini bildiradi.

### Nega `Close` xatosi tekshirildi?

Yozuvchi kodda faylni yopish ham alohida tekshirilmoqda:

```go
if err := file.Close(); err != nil {
	return fmt.Errorf("faylni yopish: %w", err)
}
```

Birinchi qarashda bu ortiqcha ko‘rinishi mumkin. Axir `WriteString` muvaffaqiyatli tugadi.

Lekin yozish jarayonida ma’lumot darhol fizik diskka tushishi shart emas. Operatsion tizim ma’lumotni vaqtincha buferda saqlashi mumkin.

Ayrim xatolar:

* `Write`;
* `Sync`;
* `Close`

vaqtida aniqlanishi mumkin.

Shuning uchun muhim yozuvlarda `Close` xatosini ham tekshirish foydali.

Faqat o‘qish uchun ochilgan fayllarda esa ko‘pincha:

```go
defer file.Close()
```

yetarli bo‘ladi. Chunki o‘qish natijasining muvaffaqiyatli saqlanishi `Close`ga bog‘liq emas.

### Bir nechta goroutine bir faylga yozsa nima bo‘ladi?

Bir nechta goroutine yoki bir nechta process bir vaqtning o‘zida bir faylga yozishi mumkin.

Bunday vaziyatda yozuvlar:

* kutilmagan tartibda kelishi;
* bir-birining orasiga kirib ketishi;
* dastur kutgan mantiqiy yozuv chegarasini buzishi

mumkin.

`O_APPEND` ishlatilgani har qanday murakkab yozuvni avtomatik tarzda to‘liq atomar qiladi deb hisoblamang.

Masalan, bitta log yozuvi bir nechta `Write` chaqiruvidan tuzilgan bo‘lsa, boshqa yozuvchi ular orasiga o‘z ma’lumotini yozib yuborishi mumkin.

Shu sabab umumiy faylga parallel yozishda odatda quyidagilardan biri ishlatiladi:

* bitta yozuvchi goroutine;
* `sync.Mutex`;
* maxsus logging kutubxonasi;
* tashqi log tizimi.

## Faylni qatorma-qator o‘qish

Katta matn faylini o‘qishda uning hammasini birdan xotiraga yuklash shart emas.

Masalan, log faylini bir qatordan qayta ishlash mumkin.

Buning uchun `bufio.Scanner` qulay:

```go
package main

import (
	"bufio"
	"fmt"
	"os"
)

func main() {
	file, err := os.Open("ilova.log")
	if err != nil {
		fmt.Println("faylni ochish:", err)
		return
	}
	defer file.Close()

	scanner := bufio.NewScanner(file)
	scanner.Buffer(make([]byte, 64*1024), 1024*1024)

	lineNumber := 1
	for scanner.Scan() {
		fmt.Printf("%d: %s\n", lineNumber, scanner.Text())
		lineNumber++
	}

	if err := scanner.Err(); err != nil {
		fmt.Println("faylni o‘qish:", err)
	}
}
```

Avval fayl ochiladi:

```go
file, err := os.Open("ilova.log")
```

`os.Open` faylni faqat o‘qish rejimida ochadi.

Muvaffaqiyatli ochilgandan keyin:

```go
defer file.Close()
```

yoziladi.

Bu funksiya tugaganda fayl yopilishini ta’minlaydi.

Keyin `Scanner` yaratiladi:

```go
scanner := bufio.NewScanner(file)
```

`bufio.NewScanner` `io.Reader` qabul qiladi. `*os.File` esa `io.Reader` interface’ini bajaradi. Shu sabab faylni to‘g‘ridan-to‘g‘ri `Scanner`ga berish mumkin.

Sikl:

```go
for scanner.Scan() {
	fmt.Printf("%d: %s\n", lineNumber, scanner.Text())
	lineNumber++
}
```

har iteratsiyada keyingi tokenni o‘qiydi.

Default holatda `Scanner` satrlar bo‘yicha ishlaydi. Shuning uchun bu yerda token — bitta qator.

`scanner.Scan()`:

* keyingi qator mavjud bo‘lsa `true`;
* fayl tugasa `false`;
* o‘qish xatosi yuz bersa ham `false`

qaytaradi.

Joriy qator:

```go
scanner.Text()
```

orqali olinadi.

`Text()` qator oxiridagi `\n` belgisini qaytarmaydi.

### Nega sikldan keyin `scanner.Err()` tekshiriladi?

Muammo shundaki, `Scan()` ikki xil vaziyatda `false` qaytarishi mumkin:

1. fayl normal tugadi;
2. o‘qish vaqtida xato yuz berdi.

Shuning uchun sikldan chiqqandan keyin:

```go
if err := scanner.Err(); err != nil {
	fmt.Println("faylni o‘qish:", err)
}
```

tekshiriladi.

Agar `scanner.Err()` `nil` bo‘lsa, odatda o‘qish normal tugagan.

Agar xato bo‘lsa, faylni o‘qish jarayonida muammo yuz bergan.

### `Scanner.Buffer` nima uchun kerak?

`Scanner` bitta token hajmiga limit qo‘yadi.

Juda uzun satr uchrasa, default limit yetmasligi mumkin.

Misolda:

```go
scanner.Buffer(make([]byte, 64*1024), 1024*1024)
```

deb maksimal token hajmi 1 MiB qilib belgilanmoqda.

Bu yerda:

```text
64 * 1024
```

boshlang‘ich bufer uchun ishlatiladi.

```text
1024 * 1024
```

esa tokenning maksimal hajmini 1 MiB qilib belgilaydi.

Agar fayldagi bitta qator bundan ham uzun bo‘lsa, `Scanner` xato qaytarishi mumkin.

Juda uzun yozuvlar, katta bloklar yoki qatorlarga bo‘linmagan binar ma’lumot bilan ishlaganda quyidagilar ma’qulroq bo‘lishi mumkin:

* `bufio.Reader`;
* `file.Read`;
* `io.Copy`.

## `os.File` va fayl kursori

`os.Open` yoki `os.OpenFile` muvaffaqiyatli tugaganda `*os.File` qaytaradi.

`*os.File` oddiy Go struct qiymati sifatida ko‘rinsa ham, uning ortida operatsion tizimdagi ochilgan fayl resursi mavjud.

Ochiq faylda joriy pozitsiya bo‘ladi. Bu ko‘pincha fayl kursori yoki offset deb ataladi.

Masalan, faylda:

```text
abcdef
```

ma’lumoti bor deb tasavvur qilamiz.

Agar dastur dastlabki uch baytni o‘qisa:

```text
abc
```

fayl kursori keyingi pozitsiyaga o‘tadi:

```text
abc|def
```

Keyingi `Read` odatda `d` joylashgan pozitsiyadan boshlanadi.

`Read` va `Write` odatda joriy pozitsiyadan ishlaydi va operatsiyadan keyin kursorni oldinga siljitadi.

`Seek` esa kursordan boshqa joyga o‘tish imkonini beradi.

Masalan, konseptual jihatdan:

```text
boshi   -> offset 0
o‘rtasi -> ma’lum offset
oxiri   -> fayl hajmi
```

Bu random access, ya’ni faylning istalgan qismiga o‘tib ishlashda foydali.

### Nega faylni yopish kerak?

Ochiq fayl faqat Go xotirasidan joy egallamaydi.

Operatsion tizim har ochilgan fayl uchun cheklangan resurs, odatda file descriptor yoki handle saqlaydi.

Agar dastur fayllarni ochib, ularni yopmasa, vaqt o‘tishi bilan bu limit tugashi mumkin.

Unix tizimlarida bunday vaziyatda quyidagiga o‘xshash xato uchrashi mumkin:

```text
too many open files
```

Ayniqsa uzoq ishlaydigan backend dasturida bu jiddiy muammo.

**Diqqat**

Sikl ichida minglab fayl ochib, har safar `defer file.Close()` yozish ham muammo tug‘dirishi mumkin. `defer` chaqiruvlari funksiya tugaganda bajariladi. Demak, katta sikl tugamaguncha barcha fayllar ochiq qolishi mumkin.

Masalan, bunday yondashuv ehtiyotkorlikni talab qiladi:

```go
for _, path := range paths {
    file, err := os.Open(path)
    if err != nil {
        continue
    }
    defer file.Close()

    // ...
}

Agar `paths` ichida minglab fayl bo‘lsa, ularning hammasi tashqi funksiya tugaguncha ochiq qolishi mumkin.

Buning o‘rniga bitta fayl bilan ishlashni alohida funksiyaga ajratish mumkin:

```

```go
func processFile(path string) error {
    file, err := os.Open(path)
    if err != nil {
        return err
    }
    defer file.Close()

    // ...
    return nil
}

Bu holda har bir `processFile` chaqiruvi tugagach, tegishli fayl yopiladi.

Yoki faylni iteratsiya oxirida aniq `Close` qilish mumkin.

## Fayl mavjudligini va turini tekshirish

Fayl yoki katalog haqida metadata olish uchun `os.Stat` ishlatiladi.

U muvaffaqiyatli bo‘lsa `os.FileInfo` qaytaradi.

Misol:

```

```go
package main

import (
	"errors"
	"fmt"
	"os"
)

func main() {
	info, err := os.Stat("xabar.txt")
	switch {
	case err == nil:
		fmt.Println("nom:", info.Name())
		fmt.Println("hajm:", info.Size(), "bayt")
		fmt.Println("katalog:", info.IsDir())
		fmt.Println("rejim:", info.Mode())
	case errors.Is(err, os.ErrNotExist):
		fmt.Println("fayl mavjud emas")
	default:
		fmt.Println("fayl haqida ma’lumot olinmadi:", err)
	}
}
```

Bu yerda uchta holat ajratilgan.

Birinchi holat:

```go
case err == nil:
```

`os.Stat` muvaffaqiyatli ishlagan. Demak, metadata mavjud.

Ikkinchi holat:

```go
case errors.Is(err, os.ErrNotExist):
```

ko‘rsatilgan yo‘l mavjud emas.

Uchinchi holat:

```go
default:
```

boshqa turdagi xato yuz berdi.

Masalan:

* permission yetishmasligi;
* yo‘lning bir qismiga kirib bo‘lmasligi;
* fayl tizimi bilan bog‘liq I/O xatosi.

Shu sabab faqat "`IsNotExist` emas ekan, demak fayl mavjud" deb xulosa qilish noto‘g‘ri.

### `os.FileInfo` metodlari

`os.FileInfo`ning ko‘p ishlatiladigan metodlari quyidagilar:

* `Name()` — fayl yoki katalogning bazaviy nomini qaytaradi;
* `Size()` — oddiy fayl hajmini baytlarda qaytaradi;
* `Mode()` — fayl turi va permission bitlarini qaytaradi;
* `ModTime()` — oxirgi o‘zgartirish vaqtini qaytaradi;
* `IsDir()` — obyekt katalog bo‘lsa `true` qaytaradi;
* `Sys()` — operatsion tizimga bog‘liq qo‘shimcha metadata beradi.

Masalan:

```go
info.Size()
```

oddiy fayl uchun uning hajmini baytlarda qaytaradi.

Lekin `Size()` qiymatini katalog uchun oddiy "katalog ichidagi jami fayllar hajmi" deb tushunish kerak emas. Katalog metadata’sining semantikasi fayl tizimiga bog‘liq.

### `errors.Is` nima uchun ishlatiladi?

Quyidagi kod:

```go
errors.Is(err, os.ErrNotExist)
```

xato `os.ErrNotExist`ning o‘zi ekanini emas, balki u boshqa xatolar ichiga o‘ralgan bo‘lsa ham mos kelishini tekshira oladi.

Masalan, xato:

```go
fmt.Errorf("config ochilmadi: %w", err)
```

orqali o‘ralgan bo‘lishi mumkin.

Shuning uchun yangi Go kodida `errors.Is` xatolarni sabab bo‘yicha tekshirish uchun juda qulay.

### Avval `Stat`, keyin `Open` qilish xavfsizmi?

Quyidagi fikr birinchi qarashda mantiqli ko‘rinadi:

```text
1. fayl mavjudligini tekshir;
2. mavjud bo‘lsa och.
```

Lekin bu ikki amal orasida boshqa process faylni o‘chirishi, almashtirishi yoki permission’ini o‘zgartirishi mumkin.

Masalan:

```text
Stat -> fayl mavjud
        boshqa process faylni o‘chiradi
Open -> xato
```

Shuning uchun `Stat` bilan oldindan tekshirish `Open` qaytargan xatoni tekshirish o‘rnini bosmaydi.

Ko‘pincha eng to‘g‘ri yondashuv:

1. kerakli amalni bajaring;
2. aynan shu amal qaytargan `error`ni boshqaring.

## Faylni o‘chirish

Bitta fayl yoki bo‘sh katalogni o‘chirish uchun `os.Remove` ishlatiladi:

```go
if err := os.Remove("xabar.txt"); err != nil && !errors.Is(err, os.ErrNotExist) {
	return fmt.Errorf("faylni o‘chirish: %w", err)
}
```

Bu parcha to‘liq dastur emas.

Undan foydalanishda:

```go
"errors"
"fmt"
```

paketlari import qilinishi kerak.

Shuningdek, kod `error` qaytara oladigan funksiya ichida yozilgan bo‘lishi kerak.

Kodning mantig‘i quyidagicha.

Avval:

```go
os.Remove("xabar.txt")
```

faylni o‘chirishga urinadi.

Agar xato bo‘lmasa:

```text
err == nil
```

hech narsa qilinmaydi.

Agar fayl mavjud bo‘lmasa:

```go
errors.Is(err, os.ErrNotExist)
```

`true` bo‘ladi.

Misolda bu holat ham muvaffaqiyat sifatida qabul qilinmoqda. Chunki maqsad — operatsiya oxirida fayl mavjud bo‘lmasligi.

Lekin boshqa xatolar:

* permission yetishmasligi;
* fayl tizimi xatosi;
* noto‘g‘ri yo‘l

yuqoriga qaytariladi.

### O‘chirishdagi xavfsizlik

`os.Remove` faylni o‘chiradi. U "trash" yoki "recycle bin"ga ko‘chirishni kafolatlamaydi.

Shuning uchun:

```go
os.Remove(path)
```

chaqirig‘idan oldin `path` aynan kerakli faylga tegishli ekaniga ishonch hosil qilish muhim.

Bu ayniqsa `path` foydalanuvchidan, HTTP request’dan yoki boshqa tashqi manbadan kelganda muhim.

Masalan, foydalanuvchi:

```text
../../maxfiy.txt
```

kabi yo‘l yuborishi mumkin.

Bunday xavf `Yo‘l xavfsizligi` bo‘limida yana ko‘rib chiqiladi.

## JSON fayl bilan ishlash

`encoding/json` paketi JSON ma’lumotini Go qiymatlariga o‘girish va Go qiymatlarini JSON ko‘rinishiga keltirish uchun ishlatiladi.

Quyidagi dastur:

1. JSON hujjatini faylga yozadi;
2. faylni ochadi;
3. JSON’ni stream orqali o‘qiydi;
4. natijani `Person` structiga joylaydi.

```go
package main

import (
	"encoding/json"
	"fmt"
	"os"
)

type Person struct {
	Name   string   `json:"name"`
	Age    int      `json:"age"`
	Skills []string `json:"skills"`
}

func main() {
	const document = `{
  "name": "Ali",
  "age": 25,
  "skills": ["Go", "PostgreSQL"]
}`

	if err := os.WriteFile("person.json", []byte(document), 0o644); err != nil {
		fmt.Println("JSON faylini yozish:", err)
		return
	}

	file, err := os.Open("person.json")
	if err != nil {
		fmt.Println("JSON faylini ochish:", err)
		return
	}
	defer file.Close()

	var person Person
	decoder := json.NewDecoder(file)
	decoder.DisallowUnknownFields()
	if err := decoder.Decode(&person); err != nil {
		fmt.Println("JSON faylini o‘qish:", err)
		return
	}

	fmt.Println("Ism:", person.Name)
	fmt.Println("Yosh:", person.Age)
	fmt.Println("Ko‘nikmalar:", person.Skills)
}
```

Natija:

```text
Ism: Ali
Yosh: 25
Ko‘nikmalar: [Go PostgreSQL]
```

`os.WriteFile()` JSON matnini `person.json` fayliga yozadi. `os.Open()` qaytargan `*os.File` qiymati `io.Reader`
interface’ini bajargani uchun uni `json.NewDecoder()`ga bevosita berish mumkin. `Decode(&person)` esa o‘qilgan
qiymatlarni mavjud `person` o‘zgaruvchisiga yozadi.

JSON va Go turlari mosligi, struct taglar, `Marshal`, `Unmarshal` hamda qat’iy dekodlash Go’da JSON bilan ishlash darsida batafsil tushuntiriladi.

## Muhim faylni atomar almashtirish

Ba’zi fayllarni oddiy `os.WriteFile` bilan to‘g‘ridan-to‘g‘ri qayta yozish xavfli bo‘lishi mumkin.

Masalan, `config.txt` faylida:

```text
port=8080
```

bor.

Dastur uni yangilash vaqtida:

1. eski faylni qisqartiradi;
2. yangi ma’lumotni yozishni boshlaydi;
3. yozish tugamasidan process to‘xtaydi.

Natijada faylning faqat bir qismi qolishi mumkin.

Muhim konfiguratsiya fayli uchun bu yomon holat.

Amaliy yondashuv quyidagicha:

1. yangi tarkibni vaqtinchalik faylga yozish;
2. yozilgan ma’lumotni sinxronlash;
3. faylni yopish;
4. tayyor vaqtinchalik faylni asosiy nomga `Rename` qilish.

Misol:

```go
package main

import (
	"fmt"
	"os"
	"path/filepath"
)

func writeAtomic(path string, data []byte, perm os.FileMode) error {
	dir := filepath.Dir(path)
	temp, err := os.CreateTemp(dir, ".update-*")
	if err != nil {
		return fmt.Errorf("vaqtinchalik fayl yaratish: %w", err)
	}
	tempName := temp.Name()
	defer os.Remove(tempName)

	if err := temp.Chmod(perm); err != nil {
		_ = temp.Close()
		return fmt.Errorf("ruxsatni o‘rnatish: %w", err)
	}
	if _, err := temp.Write(data); err != nil {
		_ = temp.Close()
		return fmt.Errorf("vaqtinchalik faylga yozish: %w", err)
	}
	if err := temp.Sync(); err != nil {
		_ = temp.Close()
		return fmt.Errorf("faylni diskka uzatish: %w", err)
	}
	if err := temp.Close(); err != nil {
		return fmt.Errorf("vaqtinchalik faylni yopish: %w", err)
	}
	if err := os.Rename(tempName, path); err != nil {
		return fmt.Errorf("asosiy faylni almashtirish: %w", err)
	}
	return nil
}

func main() {
	if err := writeAtomic("config.txt", []byte("port=8080\n"), 0o600); err != nil {
		fmt.Println("xato:", err)
		return
	}

	data, err := os.ReadFile("config.txt")
	if err != nil {
		fmt.Println("xato:", err)
		return
	}
	fmt.Print(string(data))
}
```

Natija:

```text
port=8080
```

Endi `writeAtomic` funksiyasini bosqichma-bosqich ko‘ramiz.

### 1. Asosiy fayl katalogini aniqlash

```go
dir := filepath.Dir(path)
```

Masalan:

```text
path = /app/config/config.txt
```

bo‘lsa:

```text
dir = /app/config
```

bo‘ladi.

### 2. Shu katalogda vaqtinchalik fayl yaratish

```go
temp, err := os.CreateTemp(dir, ".update-*")
```

Bu vaqtinchalik faylni aynan asosiy fayl turgan katalog ichida yaratadi.

Masalan:

```text
/app/config/.update-123456
```

kabi nom hosil bo‘lishi mumkin.

Nega aynan shu katalog?

Chunki keyin `Rename` ishlatiladi. Bir fayl tizimi ichidagi `Rename` ko‘pincha kerakli atomarlik xususiyatlarini yaxshiroq beradi.

Agar vaqtinchalik fayl boshqa fayl tizimida yaratilsa, rename oddiy nom almashtirish bo‘lib qolmasligi yoki umuman ishlamasligi mumkin.

### 3. Vaqtinchalik fayl nomini saqlash

```go
tempName := temp.Name()
```

Bu nom keyinchalik `Rename` uchun kerak.

### 4. Xato bo‘lsa vaqtinchalik faylni tozalash

```go
defer os.Remove(tempName)
```

Agar keyingi bosqichlardan biri xato bilan tugasa, vaqtinchalik fayl diskda qolib ketmasligi uchun uni o‘chirishga urinish rejalashtiriladi.

Agar `Rename` muvaffaqiyatli bo‘lsa, eski `tempName` endi mavjud bo‘lmaydi. Bunday holatda `os.Remove(tempName)` xato qaytarishi mumkin, lekin bu yerda uning natijasi ataylab ishlatilmayapti.

### 5. Permission o‘rnatish

```go
if err := temp.Chmod(perm); err != nil {
	_ = temp.Close()
	return fmt.Errorf("ruxsatni o‘rnatish: %w", err)
}
```

Vaqtinchalik faylga kerakli permission beriladi.

Misolda:

```go
0o600
```

berilgan.

Unix tizimlarida bu odatda:

```text
rw-------
```

ya’ni faqat fayl egasi o‘qishi va yozishi mumkinligini bildiradi.

### 6. Ma’lumotni vaqtinchalik faylga yozish

```go
if _, err := temp.Write(data); err != nil {
	_ = temp.Close()
	return fmt.Errorf("vaqtinchalik faylga yozish: %w", err)
}
```

Asosiy fayl hali o‘zgartirilmaydi.

Yangi ma’lumot avval vaqtinchalik faylga yoziladi.

Shu sabab yozish jarayonida xato yuz bersa, eski asosiy konfiguratsiya hali saqlanib turadi.

### 7. `Sync`

```go
if err := temp.Sync(); err != nil {
	_ = temp.Close()
	return fmt.Errorf("faylni diskka uzatish: %w", err)
}
```

`Sync` operatsion tizimdan faylga tegishli yozuvlarni storage qurilmasiga uzatishni so‘raydi.

Bu "Write qaytdi, demak ma’lumot albatta fizik diskka tushdi" degan taxminni kamaytirish uchun kerak.

Lekin `Sync`ning aniq chidamlilik kafolatlari operatsion tizim, fayl tizimi va storage qurilmasiga bog‘liq.

### 8. Vaqtinchalik faylni yopish

```go
if err := temp.Close(); err != nil {
	return fmt.Errorf("vaqtinchalik faylni yopish: %w", err)
}
```

Bu yerda `Close` xatosi ham tekshiriladi.

Muhim fayl yozishda bu foydali.

### 9. Tayyor faylni asosiy nomga almashtirish

```go
if err := os.Rename(tempName, path); err != nil {
	return fmt.Errorf("asosiy faylni almashtirish: %w", err)
}
```

Shu bosqichgacha eski asosiy fayl saqlanib turgan.

Endi to‘liq yozilgan vaqtinchalik fayl `path` nomiga o‘tkaziladi.

Konseptual oqim:

```text
config.txt
    |
    | eski fayl hali ishlayapti
    |
.update-123
    |
    | yangi ma’lumot to‘liq yoziladi
    | Sync
    | Close
    v
Rename
    |
    v
config.txt
```

### `Rename` har doim bir xil ishlaydimi?

Yo‘q.

`Rename`ning mavjud faylni almashtirish semantikasi operatsion tizimga bog‘liq bo‘lishi mumkin.

Ayniqsa:

* Windows;
* bir nechta process bir faylni ochib turgan holat;
* turli fayl tizimlari;
* network filesystem

bilan ishlaganda xatti-harakatni alohida sinovdan o‘tkazish kerak.

Bundan tashqari, bu usul "elektr to‘satdan o‘chsa ham mutlaq kafolat bor" degani emas.

Kuchli durability kafolati kerak bo‘lsa, ayrim platformalarda katalog metadata’sini ham sinxronlash kabi qo‘shimcha choralar talab qilinishi mumkin.

Demak, bu yondashuv amaliy va muhim, lekin uning aniq kafolatlari fayl tizimi va operatsion tizimga bog‘liq.

## Yo‘l xavfsizligi

Fayl yo‘li tashqi manbadan kelsa, uni oddiy string sifatida ishonchli deb qabul qilish xavfli.

Masalan, dastur foydalanuvchidan fayl nomini oladi:

```text
report.txt
```

va uni quyidagi katalog ichidan ochadi:

```text
/app/files/
```

Oddiy holatda:

```text
/app/files/report.txt
```

hosil bo‘ladi.

Lekin foydalanuvchi quyidagini yuborishi mumkin:

```text
../../maxfiy.txt
```

Natijada qurilgan yo‘l ruxsat etilgan katalogdan tashqariga chiqishi mumkin.

Bu **path traversal**, ya’ni katalog bo‘ylab tashqariga chiqish zaifligi deyiladi.

### `filepath.Clean` yetarlimi?

Masalan:

```go
clean := filepath.Clean(userPath)
```

yo‘lni normallashtiradi.

Masalan:

```text
a/../b
```

taxminan:

```text
b
```

ko‘rinishiga keltirilishi mumkin.

Lekin `filepath.Clean` yo‘l xavfsiz ekanini tekshirmaydi.

Masalan:

```text
../../maxfiy.txt
```

tozalangandan keyin ham bazaviy katalogdan tashqariga chiqadigan yo‘l bo‘lib qolishi mumkin.

Shuning uchun alohida ishonch chegarasi tekshirilishi kerak.

Bunda `filepath.Rel` yoki ishonchli bazaviy katalog bilan boshqa aniq tekshiruv ishlatilishi mumkin.

Konseptual talab:

```text
foydalanuvchi yo‘li
      |
      v
bazaviy katalog bilan birlashtirish
      |
      v
normalizatsiya
      |
      v
yakuniy yo‘l bazaviy katalog ichidami?
      |
   +--+--+
   |     |
  ha    yo‘q
   |     |
 ruxsat  rad etish
```

### Symbolic link ham muhim

Faqat string ko‘rinishidagi yo‘lni tekshirish ham ayrim holatlarda yetarli emas.

Masalan, ruxsat etilgan katalog ichidagi:

```text
/app/files/link
```

symbolic link bo‘lib, tashqaridagi:

```text
/etc/
```

katalogiga olib borishi mumkin.

Shunda tashqi tomondan yo‘l:

```text
link/passwd
```

ruxsat etilgan katalog ichida ko‘rinadi, lekin real fayl boshqa joyda bo‘lishi mumkin.

Shu sabab foydalanuvchi nazorat qiladigan fayl nomlari bilan ishlashda path traversal va symbolic link masalalari xavfsizlik dizaynining bir qismi hisoblanadi.

Bu ayniqsa:

* HTTP handler;
* fayl yuklash yoki yuklab olish endpoint’i;
* arxiv ochuvchi dastur;
* CLI utilita;
* fayl serveri

uchun muhim.

Katalog yo‘llari va ularni xavfsiz tekshirish keyingi darsda batafsil ko‘rib chiqiladi.

## Keng tarqalgan xatolar

### Xatodan keyin bajarishni davom ettirish

Masalan:

```go
file, err := os.Open("data.txt")
if err != nil {
	fmt.Println(err)
}

defer file.Close()
```

Bu kod xavfli.

`os.Open` xato qaytarsa, `file` odatda foydalanish mumkin bo‘lgan `*os.File` bo‘lmaydi.

Shunga qaramay kod davom etmoqda:

```go
defer file.Close()
```

Bu keyinchalik `panic`ga olib kelishi mumkin.

To‘g‘ri yondashuv:

```go
file, err := os.Open("data.txt")
if err != nil {
	fmt.Println(err)
	return
}
defer file.Close()
```

Yoki funksiya `error` qaytarsa:

```go
file, err := os.Open("data.txt")
if err != nil {
	return fmt.Errorf("faylni ochish: %w", err)
}
defer file.Close()
```

Asosiy qoida oddiy:

> Agar keyingi kod muvaffaqiyatli natijaga bog‘liq bo‘lsa, xatodan keyin bajarishni davom ettirmang.

### Har qanday faylni to‘liq xotiraga yuklash

`os.ReadFile` juda qulay:

```go
data, err := os.ReadFile(path)
```

Lekin u faylni butunlay xotiraga oladi.

Fayl hajmi nazorat qilinmasa, xotira sarfi ham nazoratdan chiqishi mumkin.

Masalan:

```text
fayl hajmi: 5 GiB
```

bo‘lsa, uni bitta `[]byte`ga olish katta xotira talab qiladi.

Shu sabab katta yoki tashqaridan kelgan fayllar uchun quyidagilardan foydalanish mumkin:

* `bufio.Scanner`;
* `bufio.Reader`;
* `file.Read`;
* `io.Copy`;
* explicit size limit.

Qaysi usul tanlanishi fayl formatiga bog‘liq.

Masalan, qatorma-qator log uchun `Scanner` qulay. Katta binar oqimni bir joydan boshqa joyga nusxalashda `io.Copy` ma’qulroq bo‘lishi mumkin.

### Yozish natijasidagi baytlar sonini e’tiborsiz qoldirish

`Write` ikki qiymat qaytaradi:

```go
n, err := file.Write(data)
```

Bu yerda:

* `n` — nechta bayt yozilganini;
* `err` — xatoni

bildiradi.

Ideal holatda:

```text
n == len(data)
err == nil
```

bo‘ladi.

Lekin:

```text
n < len(data)
```

bo‘lsa, barcha ma’lumot yozilmagan.

Agar `n < len(data)` va `err == nil` bo‘lsa ham, bu qisqa yozuv — short write hisoblanadi.

Shu sabab yozish natijasini beparvo tashlab yubormaslik kerak.

Masalan:

```go
n, err := file.Write(data)
if err != nil {
	return err
}
if n != len(data) {
	return io.ErrShortWrite
}
```

kabi tekshiruv talab qilinishi mumkin.

`io.WriteString` va `io.Copy` kabi yordamchi funksiyalar ham natija va xato qaytaradi. Muhim I/O kodida ularni tekshirish kerak.

### Fayl mavjudligini alohida tekshirishga ortiqcha tayanish

Quyidagi ketma-ketlik ko‘p uchraydi:

```text
1. fayl mavjudmi?
2. mavjud bo‘lsa ishlat.
```

Lekin birinchi va ikkinchi amal orasida boshqa process vaziyatni o‘zgartirishi mumkin.

Masalan:

```text
Stat -> mavjud
        |
        | boshqa process faylni o‘chiradi
        v
Open -> xato
```

Yoki:

```text
Stat -> mavjud
        |
        | permission o‘zgaradi
        v
Open -> permission denied
```

Bu **TOCTOU** — time-of-check to time-of-use poyga holati deyiladi.

Shuning uchun oldindan tekshirish asosiy operatsiya xatosini tekshirish o‘rnini bosmaydi.

Masalan, sizga faylni ochish kerak bo‘lsa:

```go
file, err := os.Open(path)
```

qiling va aynan `Open` qaytargan xatoni boshqaring.

## Interviewda nimalarga e’tibor beriladi?

Fayllar mavzusidagi interview savollarida ko‘pincha faqat `os.Open` sintaksisini bilish emas, I/O semantikasini tushunish tekshiriladi.

Muhim nuqtalar:

* `os.ReadFile` butun faylni xotiraga oladi. Oqimli o‘qish esa xotira sarfini cheklash imkonini beradi.
* `defer file.Close()` o‘qishda qulay. Muhim yozuvlarda esa `Close` xatosini alohida tekshirish kerak bo‘lishi mumkin.
* `O_CREATE`, `O_APPEND`, `O_TRUNC`, `O_RDONLY` va `O_WRONLY` flaglari fayl qanday rejimda ochilishini belgilaydi.
* `O_APPEND` mavjud ma’lumotni saqlab, yozuvni fayl oxiriga yo‘naltiradi.
* `O_TRUNC` mavjud fayl tarkibini qisqartiradi. Noto‘g‘ri ishlatilsa eski ma’lumot yo‘qolishi mumkin.
* `os.Stat`dagi "fayl mavjud emas" holatini permission yoki boshqa I/O xatolaridan ajratish kerak.
* `errors.Is(err, os.ErrNotExist)` o‘ralgan xatolar bilan ham ishlay oladi.
* "Avval tekshir, keyin ishlat" yondashuvi TOCTOU poyga holatini yo‘q qilmaydi.
* `bufio.Scanner` qatorma-qator o‘qishda qulay, lekin token hajmi limitiga ega.
* `*os.File` operatsion tizimdagi resurs bilan bog‘liq. Fayllarni vaqtida yopmaslik file descriptor limitiga olib kelishi mumkin.
* Muhim faylni yangilashda vaqtinchalik fayl, `Sync`, `Close` va `Rename` orqali atomar almashtirish yondashuvi ishlatilishi mumkin.
* Atomarlik va durability bir xil tushuncha emas. `Rename` atomar bo‘lishi mumkin, lekin elektr uzilishiga qarshi saqlanish kafolati fayl tizimi va operatsion tizimga bog‘liq.
* Tashqaridan kelgan fayl yo‘llarida path traversal va symbolic link xavflarini hisobga olish kerak.

Keyingi darsda katalog yaratish, uning tarkibini o‘qish, katalog daraxti bo‘ylab yurish va fayl yo‘llarini xavfsiz tuzishni o‘rganamiz.
