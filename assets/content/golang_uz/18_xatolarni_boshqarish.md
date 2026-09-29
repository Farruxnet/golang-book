# Go’da xatolarni boshqarish

Dastur ishlayotganda hamma amal muvaffaqiyatli tugamaydi. Masalan, dastur ochmoqchi bo‘lgan fayl mavjud bo‘lmasligi mumkin. Foydalanuvchi noto‘g‘ri qiymat kiritishi mumkin. Tarmoq orqali yuborilgan so‘rov ham turli sabablarga ko‘ra bajarilmasligi mumkin.

Bular dasturda uchrashi tabiiy bo‘lgan holatlar. Go’da bunday kutiladigan muammolar odatda `error` qiymati orqali boshqariladi.

Har bir funksiya `error` qaytarishi shart emas. Agar funksiya bajarilishi muvaffaqiyatsiz tugashi mumkin bo‘lsa, u odatda asosiy natija bilan birga `error` ham qaytaradi.

Masalan, ikkita sonni qo‘shish kabi oddiy funksiya ko‘pincha xato qaytarishga muhtoj emas. Lekin fayl ochish, ma’lumotlar bazasiga ulanish yoki foydalanuvchi kiritgan qiymatni tekshirish kabi amallar muvaffaqiyatsiz tugashi mumkin. Bunday funksiyalarda `error` qaytarish tabiiy hisoblanadi.

## `error` nima?

Go’da `error` alohida built-in interface hisoblanadi. U faqat bitta metodni talab qiladi:

```go
type error interface {
	Error() string
}
```

Interface turning qanday ma’lumot saqlashini emas, u qaysi metodlarni bajarishi kerakligini belgilaydi. Hozircha
`error`ni `Error() string` metodiga ega qiymat deb tushunish yetarli. Keyingi interface darsida bu
tushuncha va turning interface talabiga qanday mos kelishi batafsil ko‘rib chiqiladi.

Bu yerda asosiy fikr juda sodda: `Error()` metodi xatoni odam o‘qishi mumkin bo‘lgan `string` ko‘rinishida ifodalaydi.

Agar biror turda quyidagi signature’ga ega metod mavjud bo‘lsa:

```go
Error() string
```

u `error` interface’ini bajarishi mumkin.

Funksiya muvaffaqiyatli bajarilganda `error` o‘rniga odatda `nil` qaytariladi. Xato yuz berganda esa muammoning sababini ifodalovchi haqiqiy `error` qiymati qaytariladi.

Quyidagi funksiya ikkita `float64` sonni bo‘ladi:

```go
package main

import (
	"errors"
	"fmt"
)

func bolish(a, b float64) (float64, error) {
	if b == 0 {
		return 0, errors.New("nolga bo‘lish mumkin emas")
	}

	return a / b, nil
}

func main() {
	natija, err := bolish(10, 4)
	if err != nil {
		fmt.Println("Xato:", err)
		return
	}

	fmt.Println("Natija:", natija)
}
```

Natija:

```text
Natija: 2.5
```

`bolish()` ikkita qiymat qaytaryapti:

```go
(float64, error)
```

Birinchi qiymat — hisob natijasi.

Ikkinchi qiymat — xato haqida ma’lumot.

`b` nol bo‘lmasa, bo‘lish muvaffaqiyatli bajariladi:

```go
return a / b, nil
```

Bu yerda haqiqiy hisob natijasi va `nil` qaytariladi. `nil` xato yo‘qligini bildiradi.

Agar `b == 0` bo‘lsa:

```go
return 0, errors.New("nolga bo‘lish mumkin emas")
```

funksiya hisobni davom ettirmaydi. `float64` turning nol qiymati bo‘lgan `0` va xato qaytariladi.

Bu yerda muhim qoida bor: xato qaytarilgan holatda birinchi natijaning o‘zi ko‘pincha ishonchli emas. Chaqiruvchi avval `err`ni tekshirishi kerak.

## Xatoni tekshirish

`error` qaytaradigan funksiya chaqirilganda odatda birinchi qilinadigan ish — `err` qiymatini tekshirish.

Masalan:

```go
natija, err := bolish(10, 0)
if err != nil {
	fmt.Println("Xato:", err)
	return
}

fmt.Println(natija)
```

Natija:

```text
Xato: nolga bo‘lish mumkin emas
```

Bu yerda `bolish(10, 0)` xato qaytardi.

Shuning uchun:

```go
if err != nil {
```

sharti `true` bo‘ladi va xato boshqariladi.

`return` orqali esa qolgan kod bajarilmaydi:

```go
fmt.Println(natija)
```

Bu yaxshi amaliyot. Sababi xato yuz bergandan keyin qaytgan asosiy natija ko‘pincha ishlatishga yaroqsiz bo‘ladi.

Masalan, faylni o‘qish funksiyasi xato qaytargan bo‘lsa, undan kelgan `data` bilan odatdagidek ishlash noto‘g‘ri bo‘lishi mumkin.

Shuning uchun xato aniqlanganda odatda quyidagi qarorlardan biri qabul qilinadi:

* xatoni yuqoridagi funksiyaga qaytarish;
* foydalanuvchiga tushunarli xabar ko‘rsatish;
* boshqa yo‘l bilan amalni qayta bajarish;
* ma’lum xato turi uchun alohida fallback ishlatish;
* tizim chegarasida xatoni logga yozish.

Bu “har bir funksiyada albatta `err` tekshiriladi” degani emas. Faqat funksiya `error` qaytarsa, chaqiruvchi bu qiymat bilan nima qilishini ongli ravishda hal qilishi kerak.

Ayrim hollarda xatoni ataylab e’tiborsiz qoldirish ham mumkin. Lekin bunday qarorning sababi koddan aniq ko‘rinishi yaxshi.

Masalan:

```go
_ = file.Close()
```

Bu yerda xato ongli ravishda tashlab yuborilganini `_` ko‘rsatadi. Lekin resursni yopishdagi xato muhim bo‘lsa, uni ham tekshirish kerak bo‘lishi mumkin.

## Xato yaratish

Sodda va o‘zgarmas matnli xato yaratish uchun `errors.New()` ishlatiladi.

Masalan:

```go
if yosh < 0 {
	return errors.New("yosh manfiy bo‘lmaydi")
}
```

`errors.New()` berilgan matndan yangi `error` qiymati yaratadi.

Bu usul xato matni oldindan ma’lum bo‘lsa qulay.

Lekin ba’zan xato xabariga runtime’da olingan qiymatni ham qo‘shish kerak bo‘ladi. Masalan, aynan qaysi yosh noto‘g‘ri ekanini ko‘rsatmoqchimiz.

Bunda `fmt.Errorf()` qulay:

```go
func yoshniTekshir(yosh int) error {
	if yosh < 0 {
		return fmt.Errorf("noto‘g‘ri yosh: %d", yosh)
	}
	return nil
}
```

Agar `yosh == -5` bo‘lsa, xato taxminan quyidagicha bo‘ladi:

```text
noto‘g‘ri yosh: -5
```

`%d` orqali `yosh` qiymati xato matniga qo‘shildi.

Xato matnini yozishda odatda bir necha kichik qoidaga amal qilinadi.

Xabar qisqa bo‘lishi kerak, lekin muammoning sababini tushuntirsin.

Odatda xato matni kichik harf bilan boshlanadi:

```text
fayl topilmadi
```

va oxiriga nuqta qo‘yilmaydi.

Buning sababi xato yuqori qatlamlarda boshqa matn bilan birlashtirilishi mumkin.

Masalan:

```text
sozlamani yuklash: fayl topilmadi
```

Agar ichki xato bosh harf va nuqta bilan yozilgan bo‘lsa, zanjirlangan xabarlar kamroq tabiiy ko‘rinishi mumkin.

## Xatoni yuqoriga uzatish

Funksiya xatoni o‘zi hal qila olmasa, uni chaqiruvchiga qaytaradi.

Eng sodda variant:

```go
if err != nil {
	return err
}
```

Bu ishlaydi. Lekin muammo shundaki, yuqori qatlam faqat asl xatoni ko‘radi. Xato aynan qaysi amal vaqtida yuz bergani tushunarsiz bo‘lib qolishi mumkin.

Shuning uchun xatoga kontekst qo‘shish foydali.

Quyidagi misolda xato bir necha qatlam orqali yuqoriga uzatiladi:

```go
package main

import (
	"fmt"
	"os"
)

func faylniOqish(nom string) ([]byte, error) {
	data, err := os.ReadFile(nom)
	if err != nil {
		return nil, fmt.Errorf("%q faylini o‘qish: %w", nom, err)
	}
	return data, nil
}

func sozlamaniYuklash() ([]byte, error) {
	data, err := faylniOqish("config.json")
	if err != nil {
		return nil, fmt.Errorf("sozlamani yuklash: %w", err)
	}
	return data, nil
}

func run() error {
	data, err := sozlamaniYuklash()
	if err != nil {
		return err
	}

	fmt.Println(string(data))
	return nil
}

func main() {
	if err := run(); err != nil {
		fmt.Println("Dastur ishga tushmadi:", err)
	}
}
```

Bu oqimni bosqichma-bosqich ko‘ramiz.

Avval:

```go
sozlamaniYuklash()
```

chaqiriladi.

U esa:

```go
faylniOqish("config.json")
```

funksiyasini chaqiradi.

`faylniOqish()` ichida:

```go
os.ReadFile(nom)
```

bajariladi.

Agar `config.json` mavjud bo‘lmasa, `os.ReadFile()` xato qaytaradi.

`faylniOqish()` bu xatoni shunchaki uzatmaydi. U qo‘shimcha kontekst qo‘shadi:

```go
fmt.Errorf("%q faylini o‘qish: %w", nom, err)
```

Natijada ichki xato endi qaysi amal vaqtida yuz bergani bilan birga qaytadi.

Keyin `sozlamaniYuklash()` ham o‘z kontekstini qo‘shadi:

```go
fmt.Errorf("sozlamani yuklash: %w", err)
```

Oxirida `main()` tizimning yuqori chegarasida xatoni foydalanuvchiga chiqaradi.

`config.json` mavjud bo‘lmasa, xabar taxminan quyidagicha bo‘ladi:

```text
Dastur ishga tushmadi: sozlamani yuklash: "config.json" faylini o‘qish: open config.json: no such file or directory
```

Bu xabarni ichkaridan tashqariga o‘qish mumkin:

```text
open config.json: no such file or directory
```

— operatsion tizim darajasidagi asl sabab.

```text
"config.json" faylini o‘qish
```

— qaysi amal bajarilayotgan edi.

```text
sozlamani yuklash
```

— bu amal kattaroq jarayonning qaysi qismi edi.

```text
Dastur ishga tushmadi
```

— xato foydalanuvchiga qaysi kontekstda ko‘rsatilmoqda.

Har bir qatlam faqat o‘ziga tegishli ma’lumotni qo‘shdi.

Yana bir muhim jihat: pastki funksiyalar xatoni ekranga chiqarib, keyin yana yuqoriga qaytarmayapti.

Masalan, `faylniOqish()` ichida bunday qilinmagan:

```go
fmt.Println(err)
return nil, err
```

Agar har bir qatlam xatoni logga yozib, keyin qaytarsa, bir xil xato loglarda bir necha marta takrorlanishi mumkin.

Ko‘pincha yaxshi yondashuv — pastki qatlamlarda xatoga kontekst qo‘shish, yuqori tizim chegarasida esa uni bir marta chiqarish yoki logga yozish.

### `%w` nima qiladi?

`fmt.Errorf()` ichidagi `%w` maxsus ma’noga ega:

```go
fmt.Errorf("sozlamani yuklash: %w", err)
```

U asl xatoni yangi xato ichiga o‘raydi, ya’ni wrap qiladi.

Natijada ikki narsa sodir bo‘ladi:

1. xato matniga qo‘shimcha kontekst qo‘shiladi;
2. asl xato zanjir ichida saqlanib qoladi.

Shuning uchun keyinroq `errors.Is()` yoki `errors.As()` orqali ichki sababni topish mumkin.

Agar `%w` o‘rniga `%v` ishlatilsa:

```go
fmt.Errorf("sozlamani yuklash: %v", err)
```

xato matni ko‘rinishda deyarli bir xil bo‘lishi mumkin.

Lekin asl `error` zanjir sifatida saqlanmaydi. Bu esa keyinchalik xatoni turiga yoki sababiga qarab tekshirish imkonini yo‘qotadi.

## `errors.Is()` bilan sababni tekshirish

Xatoni matni orqali tekshirish yaxshi usul emas.

Masalan, bunday kod mo‘rt hisoblanadi:

```go
if err.Error() == "file does not exist" {
	// ...
}
```

Xato matni platformaga, kutubxonaga yoki qo‘shilgan kontekstga qarab o‘zgarishi mumkin.

Ma’lum bir xato qiymati zanjir ichida bor yoki yo‘qligini tekshirish uchun `errors.Is()` ishlatiladi.

```go
package main

import (
	"errors"
	"fmt"
	"os"
)

func faylniOqish(nom string) ([]byte, error) {
	data, err := os.ReadFile(nom)
	if err != nil {
		return nil, fmt.Errorf("%q faylini o‘qish: %w", nom, err)
	}
	return data, nil
}

func main() {
	_, err := faylniOqish("config.json")
	if errors.Is(err, os.ErrNotExist) {
		fmt.Println("Sozlama fayli topilmadi")
		return
	}
	if err != nil {
		fmt.Println("Xato:", err)
	}
}
```

Bu yerda `os.ReadFile()`dan kelgan xato `fmt.Errorf()` va `%w` orqali o‘ralgan:

```go
fmt.Errorf("%q faylini o‘qish: %w", nom, err)
```

Shunga qaramay:

```go
errors.Is(err, os.ErrNotExist)
```

xatolar zanjirini ichkariga qarab tekshiradi.

Agar zanjir ichida `os.ErrNotExist`ga mos xato topilsa, `true` qaytaradi.

Demak, xatoga qancha kontekst qo‘shilganidan qat’i nazar, dastur asl sababga qarab qaror qabul qila oladi.

### Sentinel error

Dasturga tegishli doimiy va alohida xato holati uchun oldindan xato qiymati e’lon qilish mumkin:

```go
var ErrUserNotFound = errors.New("foydalanuvchi topilmadi")
```

Bunday qiymat ko‘pincha **sentinel error** deb ataladi.

Masalan, chaqiruvchi aynan foydalanuvchi topilmagan holatni boshqa xatolardan ajratishi kerak bo‘lsa:

```go
if errors.Is(err, ErrUserNotFound) {
	// maxsus qaror
}
```

Sentinel error har bir xato uchun kerak emas.

U odatda chaqiruvchi aynan shu holatni dasturiy ravishda aniqlab, unga alohida munosabat bildirishi kerak bo‘lganda foydali.

Agar xato faqat foydalanuvchiga matn ko‘rsatish uchun kerak bo‘lsa, alohida sentinel qiymat yaratish ortiqcha bo‘lishi mumkin.

## Custom error va `errors.As()`

Ba’zan xatoda faqat matn yetarli bo‘lmaydi.

Masalan, forma tekshirayotganda aynan qaysi maydon noto‘g‘ri ekanini va muammo sababini alohida saqlamoqchimiz.

Bunday vaziyatda custom error type, ya’ni maxsus xato turi yaratish mumkin.

```go
package main

import (
	"errors"
	"fmt"
)

type ValidationError struct {
	Field   string
	Message string
}

func (e *ValidationError) Error() string {
	return fmt.Sprintf("%s: %s", e.Field, e.Message)
}

func userYarat(name string, age int) error {
	if name == "" {
		return &ValidationError{
			Field:   "name",
			Message: "bo‘sh bo‘lmasligi kerak",
		}
	}
	if age < 0 {
		return &ValidationError{
			Field:   "age",
			Message: "manfiy bo‘lmasligi kerak",
		}
	}
	return nil
}

func register(name string, age int) error {
	if err := userYarat(name, age); err != nil {
		return fmt.Errorf("foydalanuvchini ro‘yxatdan o‘tkazish: %w", err)
	}
	return nil
}

func main() {
	err := register("", 20)
	if err == nil {
		return
	}

	var validationErr *ValidationError
	if errors.As(err, &validationErr) {
		fmt.Printf("%s maydonida xato: %s\n", validationErr.Field, validationErr.Message)
		return
	}

	fmt.Println("Kutilmagan xato:", err)
}
```

Natija:

```text
name maydonida xato: bo‘sh bo‘lmasligi kerak
```

Avval maxsus struct yaratildi:

```go
type ValidationError struct {
	Field   string
	Message string
}
```

Bu struct ikkita alohida ma’lumot saqlaydi:

* `Field` — xato qaysi maydonda yuz bergani;
* `Message` — muammoning izohi.

Keyin pointer receiver bilan `Error()` metodi yozildi:

```go
func (e *ValidationError) Error() string
```

Shu sabab `*ValidationError` `error` interface’ini bajaradi.

Masalan:

```go
return &ValidationError{
	Field:   "name",
	Message: "bo‘sh bo‘lmasligi kerak",
}
```

oddiy `error` sifatida qaytarilishi mumkin.

Keyingi qatlamda xato wrap qilinadi:

```go
return fmt.Errorf("foydalanuvchini ro‘yxatdan o‘tkazish: %w", err)
```

Demak, `main()`ga kelgan `err` to‘g‘ridan-to‘g‘ri `*ValidationError` bo‘lmasligi mumkin. Tashqarida `fmt.Errorf()` yaratgan xato turibdi.

Shuning uchun oddiy type assertion qilish o‘rniga `errors.As()` ishlatiladi:

```go
var validationErr *ValidationError
if errors.As(err, &validationErr) {
```

`errors.As()` xatolar zanjirini tekshiradi.

Agar ichkarida `*ValidationError` topilsa, uning qiymatini:

```go
validationErr
```

o‘zgaruvchisiga yozadi.

Shundan keyin custom error ichidagi strukturaviy ma’lumotlardan foydalanish mumkin:

```go
validationErr.Field
validationErr.Message
```

Bu faqat xato matnini parse qilishdan ancha ishonchli.

### `errors.Is()` va `errors.As()` farqi

Ularning vazifasi o‘xshash ko‘rinsa ham, maqsadi boshqa.

`errors.Is()`:

```go
errors.Is(err, ErrUserNotFound)
```

ma’lum xato qiymati yoki sabab zanjir ichida mavjudligini tekshiradi.

`errors.As()`:

```go
errors.As(err, &validationErr)
```

ma’lum xato turini zanjirdan topadi va shu turdagi qiymatni olish imkonini beradi.

Qisqacha:

* `errors.Is()` — “shu xato sabablar orasida bormi?”;
* `errors.As()` — “shu turdagi xato bormi va uning ma’lumotlarini bera olasanmi?”.

## `defer` va resurslarni yopish

Dastur fayl, socket, database connection yoki boshqa resursni ochsa, uni kerakli vaqtda yopish ham muhim.

Go’da `defer` funksiyaning keyinroq bajarilishi kerak bo‘lgan chaqiruvini rejalashtirish imkonini beradi.

Deferred chaqiruv joriy funksiya tugashidan oldin bajariladi.

Fayl bilan ishlashda bu ayniqsa qulay:

```go
package main

import (
	"fmt"
	"os"
)

func faylHajmi(nom string) (int64, error) {
	file, err := os.Open(nom)
	if err != nil {
		return 0, fmt.Errorf("faylni ochish: %w", err)
	}
	defer file.Close()

	info, err := file.Stat()
	if err != nil {
		return 0, fmt.Errorf("fayl ma’lumotini olish: %w", err)
	}

	return info.Size(), nil
}

func main() {
	size, err := faylHajmi("config.json")
	if err != nil {
		fmt.Println("Xato:", err)
		return
	}
	fmt.Println("Fayl hajmi:", size)
}
```

Bu yerda avval fayl ochiladi:

```go
file, err := os.Open(nom)
```

Agar faylni ochishning o‘zi muvaffaqiyatsiz bo‘lsa:

```go
if err != nil {
	return 0, fmt.Errorf("faylni ochish: %w", err)
}
```

funksiya darhol qaytadi.

Muhim joy: `defer file.Close()` faqat fayl muvaffaqiyatli ochilgandan keyin yozilgan:

```go
defer file.Close()
```

Bu to‘g‘ri, chunki `os.Open()` xato qaytargan bo‘lsa, ishlatish mumkin bo‘lgan ochiq `file` resursi yo‘q.

Keyin:

```go
info, err := file.Stat()
```

bajariladi.

Agar shu joyda xato yuz bersa ham:

```go
return 0, fmt.Errorf("fayl ma’lumotini olish: %w", err)
```

funksiya tugashidan oldin deferred `file.Close()` ishlaydi.

Muvaffaqiyatli holatda ham aynan shu narsa sodir bo‘ladi.

Shuning uchun `defer` barcha chiqish yo‘llarida resursni yopishni osonlashtiradi.

Aks holda har bir `return`dan oldin alohida:

```go
file.Close()
```

yozishga to‘g‘ri kelishi mumkin edi.

### Bir nechta `defer`

Bir funksiyada bir nechta `defer` bo‘lishi mumkin.

Ular **LIFO** tartibida bajariladi: oxirgi qo‘shilgan `defer` birinchi bajariladi.

Masalan:

```go
defer birinchi()
defer ikkinchi()
defer uchinchi()
```

funksiya tugaganda bajarilish tartibi:

```text
uchinchi
ikkinchi
birinchi
```

Bu resurslarni teskari tartibda yopish uchun qulay.

Masalan, avval A resursini, keyin B resursini ochgan bo‘lsak, odatda avval B, keyin A yopilishi tabiiy.

### `defer` va uzun sikllar

`defer` joriy blok tugaganda emas, **funksiya** tugaganda bajariladi.

Shuning uchun uzoq davom etadigan sikl ichida juda ko‘p `defer` yig‘ish ehtiyotkorlikni talab qiladi.

Masalan:

```go
for _, name := range names {
	file, err := os.Open(name)
	if err != nil {
		continue
	}
	defer file.Close()
}
```

Bu yerda har bir fayl iteratsiya tugaganda emas, butun funksiya tugaganda yopiladi.

Agar fayllar ko‘p bo‘lsa, bir vaqtning o‘zida juda ko‘p ochiq resurs qolib ketishi mumkin.

Bunday vaziyatda sikl tanasini alohida funksiyaga chiqarish yoki resursni kerakli joyda bevosita yopish ma’qul bo‘lishi mumkin.

## `panic` va `recover`

Go’da `panic` mavjud, lekin u oddiy xatolarni qaytarishning o‘rnini bosmaydi.

Kutiladigan muammolar odatda `error` orqali qaytarilishi kerak.

Masalan:

* fayl topilmadi;
* foydalanuvchi noto‘g‘ri qiymat kiritdi;
* tarmoq uzildi;
* ma’lumotlar bazasida kerakli yozuv topilmadi.

Bular odatiy xato oqimiga kiradi.

`panic` esa dastur odatdagidek davom eta olmaydigan holatlar yoki dasturchi qilgan jiddiy mantiqiy xatolar uchun ishlatilishi mumkin.

`panic` yuz berganda joriy funksiyaning oddiy bajarilishi to‘xtaydi va stack bo‘ylab yuqoriga tarqalish boshlanadi. Shu jarayonda deferred funksiyalar bajariladi.

`recover()` esa deferred funksiya ichida panic qiymatini ushlashi mumkin.

```go
package main

import "fmt"

func xavfsizIshgaTushir(fn func()) {
	defer func() {
		if value := recover(); value != nil {
			fmt.Println("Panic ushlandi:", value)
		}
	}()

	fn()
}

func main() {
	xavfsizIshgaTushir(func() {
		panic("kutilmagan ichki holat")
	})
}
```

Natija:

```text
Panic ushlandi: kutilmagan ichki holat
```

Oqimni bosqichma-bosqich ko‘ramiz.

Avval:

```go
xavfsizIshgaTushir(...)
```

chaqiriladi.

Funksiya ichida deferred anonim funksiya ro‘yxatdan o‘tkaziladi:

```go
defer func() {
	if value := recover(); value != nil {
		fmt.Println("Panic ushlandi:", value)
	}
}()
```

Keyin:

```go
fn()
```

bajariladi.

Uzatilgan funksiya ichida:

```go
panic("kutilmagan ichki holat")
```

chaqiriladi.

Oddiy bajarilish shu nuqtada to‘xtaydi.

`xavfsizIshgaTushir()` tugashidan oldin uning deferred funksiyasi ishlaydi.

`recover()` panic bilan yuborilgan qiymatni oladi:

```go
"kutilmagan ichki holat"
```

va panic tarqalishini shu goroutine ichida to‘xtatadi.

Bu yerda muhim noziklik bor.

`recover()` bajarilishni `panic(...)` yozilgan qatordan keyin davom ettirmaydi.

Masalan:

```go
func test() {
	panic("xato")
	fmt.Println("bu bajarilmaydi")
}
```

`recover()` yuqori qatlamda panicni ushlasa ham:

```go
fmt.Println("bu bajarilmaydi")
```

ishga tushmaydi.

Panic yuz bergan funksiya yakunlangan hisoblanadi. Boshqaruv panicni ushlagan deferred funksiya tugagandan keyin yuqoridagi normal oqimga qaytishi mumkin.

### `recover()` qayerda ishlatiladi?

`recover()`ni har bir funksiya ichiga qo‘yish kerak emas.

U ko‘pincha tizim chegarasida ishlatiladi.

Masalan, HTTP server bitta request handler ichidagi kutilmagan `panic` sabab butun server processini to‘xtatishni istamasligi mumkin.

Shunday chegarada `recover()` panicni ushlab, xatoni logga yozishi va shu requestni xato bilan tugatishi mumkin.

Lekin bu oddiy biznes xatolarini `panic` orqali uzatish kerak degani emas.

Masalan, bunday yondashuv tavsiya etilmaydi:

```go
if user == nil {
	panic("user topilmadi")
}
```

agar `user` topilmasligi odatiy va kutiladigan holat bo‘lsa.

Bunday vaziyatda oddiy `error` qaytarish to‘g‘riroq.

## Xatolar bilan ishlash tartibi

Amaliy kodda xatolar bilan ishlash uchun quyidagi tartib foydali.

1. Xato yuz berishi mumkin bo‘lgan funksiya `error` qaytarsin.

2. Chaqiruvchi xatoni shu qatlamda mazmunli hal qila olsa, shu yerning o‘zida qaror qabul qilsin.

Masalan, fayl topilmasa default konfiguratsiyani ishlatish mumkin bo‘lsa, bu aynan shu qatlamda hal qilinishi mumkin.

3. Agar qatlam xatoni hal qila olmasa, foydali kontekst qo‘shib yuqoriga qaytarsin.

Masalan:

```go
return fmt.Errorf("sozlamani yuklash: %w", err)
```

4. Yuqori qatlam ma’lum xato sababiga alohida munosabat bildirishi kerak bo‘lsa, `errors.Is()` ishlatsin.

Masalan:

```go
if errors.Is(err, os.ErrNotExist) {
	// ...
}
```

5. Xatodan strukturaviy ma’lumot olish kerak bo‘lsa, `errors.As()` ishlatsin.

6. Xatoni foydalanuvchiga ko‘rsatish yoki logga yozishni odatda tizim chegarasida bir marta bajaring.

7. `panic`ni kutiladigan xatolar uchun ishlatmang.

Bu yondashuv xato oqimini aniq saqlaydi. Pastki qatlamlar texnik sababni yo‘qotmaydi, yuqori qatlamlar esa foydalanuvchi yoki tizim uchun mos qaror qabul qila oladi.

Keyingi amaliy darslardan birida xatoni `stderr`ga yozish va mos exit code qaytarishni buyruq qatori dasturi misolida ko‘ramiz.

## Misollar

### 1. O‘zgarmas xato yaratish

Bu misol oldindan yaratilgan xato qiymatini qayta ishlatishni ko‘rsatadi.

Bo‘sh nom alohida xato holati hisoblanadi:

```go
package main

import (
	"errors"
	"fmt"
)

var ErrEmptyName = errors.New("nom bo‘sh bo‘lmasligi kerak")

func validateName(name string) error {
	if name == "" {
		return ErrEmptyName
	}
	return nil
}

func main() {
	err := validateName("")
	if err != nil {
		fmt.Println("Xato:", err)
	}
}
```

Bu yerda:

```go
var ErrEmptyName = errors.New("nom bo‘sh bo‘lmasligi kerak")
```

package darajasida bitta xato qiymati yaratadi.

`validateName()` nomni tekshiradi:

```go
if name == "" {
	return ErrEmptyName
}
```

Bo‘sh `string` qiymati:

```go
""
```

`string` turning zero value qiymati hisoblanadi.

Bu misolda u “nom kiritilmagan” holatini bildiradi.

Nom mavjud bo‘lsa:

```go
return nil
```

qaytariladi.

Nom bo‘sh bo‘lsa esa aynan `ErrEmptyName` qaytariladi.

Oldindan e’lon qilingan bunday xato qiymatining foydasi shundaki, chaqiruvchi kerak bo‘lsa uni keyinchalik:

```go
errors.Is(err, ErrEmptyName)
```

bilan ham tekshirishi mumkin.

### 2. Xato xabariga qiymat qo‘shish

Bu misolda `fmt.Errorf()` yordamida aynan qaysi yosh qiymati xato ekanini xabarga qo‘shamiz.

```go
package main

import "fmt"

func validateAge(age int) error {
	if age < 0 {
		return fmt.Errorf("yosh manfiy bo‘lmasligi kerak: %d", age)
	}
	return nil
}

func main() {
	if err := validateAge(-4); err != nil {
		fmt.Println("Xato:", err)
		return
	}

	fmt.Println("Yosh qabul qilindi")
}
```

`validateAge()` ichidagi shart:

```go
if age < 0 {
```

faqat manfiy qiymatlarni rad etadi.

Masalan:

```text
-1
-4
-100
```

xato hisoblanadi.

Lekin `0` avtomatik ravishda xato deb olinmayapti.

Shuning uchun:

```go
age < 0
```

ishlatilgan, `age <= 0` emas.

Bu biznes qoidasiga bog‘liq. Agar tizimda yosh albatta `1` yoki undan katta bo‘lishi kerak bo‘lsa, shart boshqacha bo‘lishi mumkin edi.

Xato hosil qilinayotgan joy:

```go
fmt.Errorf("yosh manfiy bo‘lmasligi kerak: %d", age)
```

Bu yerda `%d` kelgan `int` qiymatini xabarga qo‘shadi.

`age == -4` bo‘lsa:

```text
yosh manfiy bo‘lmasligi kerak: -4
```

hosil bo‘ladi.

Bu debugging va foydalanuvchiga muammoni tushuntirishda oddiy statik matndan ko‘ra foydaliroq bo‘lishi mumkin.

### 3. Natija bilan birga xato qaytarish

Bu misol funksiya bir vaqtning o‘zida asosiy natija va `error` qaytarishini ko‘rsatadi.

Omborda mavjud miqdordan ko‘p mahsulot so‘ralgan bo‘lsa, amal bajarilmaydi.

```go
package main

import (
	"errors"
	"fmt"
)

func remaining(stock, requested int) (int, error) {
	if requested < 1 {
		return 0, errors.New("so‘ralgan miqdor musbat bo‘lishi kerak")
	}
	if requested > stock {
		return 0, errors.New("omborda yetarli mahsulot yo‘q")
	}
	return stock - requested, nil
}

func main() {
	left, err := remaining(12, 5)
	if err != nil {
		fmt.Println("Xato:", err)
		return
	}

	fmt.Println("Qoldi:", left)
}
```

Avval so‘ralgan miqdor tekshiriladi:

```go
if requested < 1 {
```

`requested` kamida `1` bo‘lishi kerak.

Keyin omborda yetarli mahsulot bor yoki yo‘qligi tekshiriladi:

```go
if requested > stock {
```

Agar `requested` `stock`dan katta bo‘lsa, hisoblashning ma’nosi yo‘q.

Ikkala xato holatida ham:

```go
return 0, ...
```

qaytariladi.

`int` turning zero value qiymati `0`.

Lekin chaqiruvchi avval:

```go
if err != nil {
```

ni tekshiradi.

Shuning uchun xato holatidagi `0`ni haqiqiy natija sifatida ishlatmaydi.

Muvaffaqiyatli holatda:

```go
return stock - requested, nil
```

bajariladi.

Berilgan qiymatlar:

```text
stock = 12
requested = 5
```

Hisob:

```text
12 - 5 = 7
```

Shuning uchun funksiya:

```text
7, nil
```

qaytaradi.

Natija:

```text
Qoldi: 7
```

### 4. Sentinel xatoni o‘rab uzatish

Bu misol sentinel errorni yuqori qatlamga kontekst bilan uzatish va keyin `errors.Is()` orqali asl sababni aniqlashni ko‘rsatadi.

```go
package main

import (
	"errors"
	"fmt"
)

var ErrProductNotFound = errors.New("mahsulot topilmadi")

func findProduct(id int) error {
	if id != 10 {
		return ErrProductNotFound
	}
	return nil
}

func loadProduct(id int) error {
	if err := findProduct(id); err != nil {
		return fmt.Errorf("%d identifikatorli mahsulotni yuklash: %w", id, err)
	}
	return nil
}

func main() {
	err := loadProduct(25)
	if errors.Is(err, ErrProductNotFound) {
		fmt.Println("Boshqa mahsulot tanlang")
		return
	}
	fmt.Println("Mahsulot yuklandi")
}
```

Sentinel error:

```go
var ErrProductNotFound = errors.New("mahsulot topilmadi")
```

aniq bir biznes holatini ifodalaydi.

Misolni sodda qilish uchun faqat `id == 10` mavjud mahsulot deb olingan:

```go
if id != 10 {
	return ErrProductNotFound
}
```

`loadProduct(25)` chaqirilganda `findProduct(25)` xato qaytaradi.

Lekin `loadProduct()` bu xatoni to‘g‘ridan-to‘g‘ri uzatmaydi:

```go
return fmt.Errorf("%d identifikatorli mahsulotni yuklash: %w", id, err)
```

Natijada taxminan shunday xato hosil bo‘ladi:

```text
25 identifikatorli mahsulotni yuklash: mahsulot topilmadi
```

Bu yerda `%w` juda muhim.

U `ErrProductNotFound`ni ichki sabab sifatida saqlab qoladi.

Shuning uchun:

```go
errors.Is(err, ErrProductNotFound)
```

`true` qaytaradi.

Chaqiruvchi xato matnini solishtirmaydi. U xatoning haqiqiy sababiga qarab qaror qabul qiladi:

```go
fmt.Println("Boshqa mahsulot tanlang")
```

Bu sentinel error va wrapping birga qanday ishlashini ko‘rsatadigan tipik misol.

### 5. Maxsus xato turidan ma’lumot olish

Bu misolda xato faqat matn emas, alohida maydonlarda strukturaviy ma’lumot saqlaydi.

```go
package main

import (
	"errors"
	"fmt"
)

type FieldError struct {
	Field string
	Value int
}

func (e *FieldError) Error() string {
	return fmt.Sprintf("%s maydonida noto‘g‘ri qiymat: %d", e.Field, e.Value)
}

func validateCount(count int) error {
	if count < 1 {
		return &FieldError{Field: "count", Value: count}
	}
	return nil
}

func main() {
	err := validateCount(0)
	var fieldErr *FieldError
	if errors.As(err, &fieldErr) {
		fmt.Println("Maydon:", fieldErr.Field)
		fmt.Println("Qiymat:", fieldErr.Value)
	}
}
```

Custom error turi:

```go
type FieldError struct {
	Field string
	Value int
}
```

ikkita ma’lumotni alohida saqlaydi.

`Field` — qaysi maydon xato ekanini bildiradi.

`Value` — aynan qanday noto‘g‘ri qiymat kelganini saqlaydi.

Keyin `Error()` metodi yozilgan:

```go
func (e *FieldError) Error() string
```

Shu sabab `*FieldError` `error` interface’iga mos keladi.

`count` kamida `1` bo‘lishi kerak:

```go
if count < 1 {
```

Misolda `0` yuborilgan:

```go
err := validateCount(0)
```

Shuning uchun:

```go
&FieldError{
	Field: "count",
	Value: 0,
}
```

mazmunidagi xato qaytariladi.

Keyin:

```go
var fieldErr *FieldError
```

o‘zgaruvchisi e’lon qilinadi.

`errors.As()`:

```go
errors.As(err, &fieldErr)
```

xato `*FieldError` turiga mos kelishini tekshiradi.

Mos kelsa, topilgan qiymat `fieldErr`ga yoziladi.

Shundan keyin xato matnini parse qilish shart emas:

```go
fieldErr.Field
fieldErr.Value
```

orqali kerakli ma’lumot bevosita olinadi.

### 6. O‘ralgan xatolar zanjirini ko‘rish

Bu misol `%w` bilan o‘ralgan xatolar ichma-ich zanjir hosil qilishini va `errors.Unwrap()` yordamida uni ochish mumkinligini ko‘rsatadi.

```go
package main

import (
	"errors"
	"fmt"
)

func prepareReport() error {
	base := errors.New("ma’lumot mavjud emas")
	loadErr := fmt.Errorf("ma’lumotni yuklash: %w", base)
	return fmt.Errorf("hisobotni tayyorlash: %w", loadErr)
}

func main() {
	err := prepareReport()
	for err != nil {
		fmt.Println(err)
		err = errors.Unwrap(err)
	}
}
```

Avval eng ichki xato yaratiladi:

```go
base := errors.New("ma’lumot mavjud emas")
```

Keyin u wrap qilinadi:

```go
loadErr := fmt.Errorf("ma’lumotni yuklash: %w", base)
```

Endi zanjir taxminan shunday:

```text
ma’lumotni yuklash
    ↓
ma’lumot mavjud emas
```

So‘ng yana bir qatlam qo‘shiladi:

```go
return fmt.Errorf("hisobotni tayyorlash: %w", loadErr)
```

Natijada zanjir:

```text
hisobotni tayyorlash
    ↓
ma’lumotni yuklash
    ↓
ma’lumot mavjud emas
```

`main()` ichida sikl:

```go
for err != nil {
```

xato mavjud ekan, ishlashda davom etadi.

Avval joriy tashqi xato chiqariladi:

```go
fmt.Println(err)
```

Keyin:

```go
err = errors.Unwrap(err)
```

orqali bitta ichki qatlamga o‘tiladi.

Jarayon taxminan quyidagicha:

```text
1. hisobotni tayyorlash: ma’lumotni yuklash: ma’lumot mavjud emas

2. ma’lumotni yuklash: ma’lumot mavjud emas

3. ma’lumot mavjud emas

4. nil
```

Eng ichki oddiy xato wrap qilinmagan bo‘lgani uchun undan keyin:

```go
errors.Unwrap(err)
```

`nil` qaytaradi.

Shunda sikl tugaydi.

Amaliy kodda ko‘pincha zanjirni qo‘lda `Unwrap()` qilish shart emas. `errors.Is()` va `errors.As()` odatda kerakli tekshiruvni o‘zi bajaradi. Lekin bu misol wrapping qanday tuzilishini tushunish uchun foydali.

### 7. Bir nechta xatoni birlashtirish

Ba’zan bir nechta mustaqil tekshiruvni bajarib, barcha topilgan xatolarni birgalikda qaytarish kerak bo‘ladi.

Buning uchun `errors.Join()` ishlatilishi mumkin.

```go
package main

import (
	"errors"
	"fmt"
)

var ErrNameRequired = errors.New("nom kerak")
var ErrPriceInvalid = errors.New("narx musbat bo‘lishi kerak")

func validateProduct(name string, price int) error {
	var nameErr error
	var priceErr error

	if name == "" {
		nameErr = ErrNameRequired
	}
	if price < 1 {
		priceErr = ErrPriceInvalid
	}

	return errors.Join(nameErr, priceErr)
}

func main() {
	err := validateProduct("", 0)
	fmt.Println(err)
	fmt.Println(errors.Is(err, ErrNameRequired))
	fmt.Println(errors.Is(err, ErrPriceInvalid))
}
```

Funksiya ikkita mustaqil tekshiruv bajaradi:

```go
if name == "" {
```

va:

```go
if price < 1 {
```

Muhim jihat shundaki, birinchi xato topilganda funksiya darhol qaytmayapti.

Buning o‘rniga xatolar alohida o‘zgaruvchilarda saqlanadi:

```go
var nameErr error
var priceErr error
```

`error` interface turning zero value qiymati `nil`.

Demak, boshida:

```text
nameErr  = nil
priceErr = nil
```

Agar nom bo‘sh bo‘lsa:

```go
nameErr = ErrNameRequired
```

Agar narx noto‘g‘ri bo‘lsa:

```go
priceErr = ErrPriceInvalid
```

Oxirida:

```go
return errors.Join(nameErr, priceErr)
```

chaqiriladi.

`errors.Join()` `nil` bo‘lgan elementlarni tashlab yuboradi va qolgan xatolarni bitta `error` qiymatiga birlashtiradi.

Misolda ikkala tekshiruv ham xato:

```go
validateProduct("", 0)
```

Shuning uchun birlashtirilgan xatoda ikkala sabab mavjud.

Natijada:

```go
errors.Is(err, ErrNameRequired)
```

ham `true`, va:

```go
errors.Is(err, ErrPriceInvalid)
```

ham `true` bo‘ladi.

Bu `errors.Join()`ning muhim xususiyati: birlashtirilgan xato ichidagi sabablar `errors.Is()` va `errors.As()` uchun tekshirilishi mumkin.

### 8. Erta qaytishda `defer`ni bajarish

Bu misol funksiya xato sabab erta tugasa ham `defer` ishlashini ko‘rsatadi.

```go
package main

import (
	"errors"
	"fmt"
)

func process(value int) error {
	fmt.Println("Jarayon boshlandi")
	defer fmt.Println("Tozalash bajarildi")

	if value < 0 {
		return errors.New("qiymat manfiy bo‘lmasligi kerak")
	}

	fmt.Println("Qiymat:", value)
	return nil
}

func main() {
	if err := process(-1); err != nil {
		fmt.Println("Xato:", err)
	}
}
```

Avval:

```go
fmt.Println("Jarayon boshlandi")
```

bajariladi.

Keyin:

```go
defer fmt.Println("Tozalash bajarildi")
```

deferred chaqiruv sifatida ro‘yxatdan o‘tadi.

Bu chaqiruv aynan shu vaqtda bajarilmaydi.

Keyin `value` tekshiriladi:

```go
if value < 0 {
```

Misolda:

```text
value = -1
```

Shuning uchun funksiya:

```go
return errors.New("qiymat manfiy bo‘lmasligi kerak")
```

orqali erta tugaydi.

Lekin `return` bajarilishidan oldin deferred chaqiruv ishlaydi:

```text
Tozalash bajarildi
```

Shundan keyingina boshqaruv `main()`ga qaytadi.

Natija taxminan:

```text
Jarayon boshlandi
Tozalash bajarildi
Xato: qiymat manfiy bo‘lmasligi kerak
```

Demak, `defer` faqat muvaffaqiyatli `return nil` holatida emas, xato sabab erta `return` bo‘lganda ham ishlaydi.

Aynan shu sabab resurslarni tozalash uchun `defer` juda qulay.

### 9. Bir nechta `defer`ning tartibi

Bu misol deferred chaqiruvlar qaysi tartibda bajarilishini ko‘rsatadi.

```go
package main

import "fmt"

func steps() {
	defer fmt.Println("1-qadam yopildi")
	defer fmt.Println("2-qadam yopildi")
	defer fmt.Println("3-qadam yopildi")

	fmt.Println("Asosiy ish bajarildi")
}

func main() {
	steps()
}
```

Funksiya ishlayotganda `defer`lar quyidagi tartibda ro‘yxatdan o‘tadi:

```text
1-qadam yopildi
2-qadam yopildi
3-qadam yopildi
```

Lekin ular shu tartibda bajarilmaydi.

`defer`lar stack kabi LIFO tartibida ishlaydi:

```text
Last In, First Out
```

Ya’ni oxirgi qo‘shilgan chaqiruv birinchi bajariladi.

Avval oddiy kod bajariladi:

```text
Asosiy ish bajarildi
```

Keyin deferred chaqiruvlar:

```text
3-qadam yopildi
2-qadam yopildi
1-qadam yopildi
```

tartibida ishlaydi.

To‘liq natija:

```text
Asosiy ish bajarildi
3-qadam yopildi
2-qadam yopildi
1-qadam yopildi
```

Bu tartib resurslar bilan ishlashda foydali.

Masalan, resurslar quyidagi tartibda ochilgan bo‘lsa:

```text
A
B
C
```

ularni ko‘pincha teskari tartibda yopish kerak:

```text
C
B
A
```

`defer`ning LIFO xususiyati aynan shunga mos keladi.

### 10. `panic`ni xatoga aylantirish

Bu misolda tizim chegarasidagi funksiya kutilmagan `panic` qiymatini oddiy `error`ga aylantiradi.

```go
package main

import "fmt"

func safeRun(action func()) (err error) {
	defer func() {
		if value := recover(); value != nil {
			err = fmt.Errorf("amal to‘xtadi: %v", value)
		}
	}()

	action()
	return nil
}

func main() {
	err := safeRun(func() {
		panic("ichki holat buzildi")
	})
	if err != nil {
		fmt.Println("Xato:", err)
	}
}
```

Bu misolda funksiya signature’iga e’tibor bering:

```go
func safeRun(action func()) (err error)
```

`err` — nomlangan qaytish qiymati.

Bu shuni anglatadiki, deferred funksiya `err` o‘zgaruvchisiga yozishi mumkin.

Avval `defer` ro‘yxatdan o‘tadi:

```go
defer func() {
	if value := recover(); value != nil {
		err = fmt.Errorf("amal to‘xtadi: %v", value)
	}
}()
```

Keyin:

```go
action()
```

chaqiriladi.

Uzatilgan funksiya:

```go
panic("ichki holat buzildi")
```

bajaradi.

Shu zahoti `action()`ning odatiy bajarilishi to‘xtaydi.

Stack ochila boshlaydi va `safeRun()`ning deferred funksiyasi ishlaydi.

`recover()` panic qiymatini oladi:

```go
value == "ichki holat buzildi"
```

Keyin bu qiymat oddiy `error`ga aylantiriladi:

```go
err = fmt.Errorf("amal to‘xtadi: %v", value)
```

Natijada `safeRun()`dan taxminan quyidagi xato qaytadi:

```text
amal to‘xtadi: ichki holat buzildi
```

`main()` esa uni odatiy `error` sifatida boshqaradi:

```go
if err != nil {
	fmt.Println("Xato:", err)
}
```

Natija:

```text
Xato: amal to‘xtadi: ichki holat buzildi
```

Bu yondashuvni oddiy tekshiruvlar uchun ishlatish kerak emas.

Masalan, foydalanuvchi noto‘g‘ri qiymat yuborsa:

```go
panic("noto‘g‘ri qiymat")
```

qilish o‘rniga funksiya to‘g‘ridan-to‘g‘ri `error` qaytarishi kerak.

`panic`ni `error`ga aylantirish ko‘proq server, worker yoki boshqa tizim chegaralarida kutilmagan ichki nosozlik butun jarayonni yiqitib yubormasligi uchun ishlatiladi.
