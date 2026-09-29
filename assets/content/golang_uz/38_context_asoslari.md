# `context` asoslari

Go’dagi `context.Context` uzoq davom etadigan ishlarni boshqarishga yordam beradi. U asosan uch xil ma’lumotni chaqiruv zanjiri bo‘ylab uzatadi:

* ishni bekor qilish signali;
* `deadline` yoki `timeout`;
* so‘rovga tegishli kichik metadata qiymatlari.

Masalan, HTTP server bir so‘rovni qabul qildi va shu so‘rov ichida database’ga murojaat qildi. Agar client ulanishni uzib yuborsa, server endi database natijasini kutishi shart emas. Shu holatda `context` orqali database amali ham bekor qilinishi mumkin.

Xuddi shunday, bir goroutine boshqa goroutine’ni ishga tushirsa, chaqiruvchi natijani endi kutmayotganini `context` orqali unga bildirish mumkin.

Muhim jihati shuki, `context` goroutine’ni majburan to‘xtatmaydi. Ishlayotgan kod `ctx.Done()` signalini o‘zi kuzatishi va signal kelganda ishini tugatishi kerak.

## Boshlang‘ich context

Yangi context zanjiri odatda `context.Background()` yoki `context.TODO()` dan boshlanadi.

`context.Background()` bo‘sh, bekor qilinmaydigan ildiz context hisoblanadi. U ko‘pincha:

* `main` funksiyasida;
* testlarda;
* serverning eng yuqori qatlamida;
* boshqa ota context mavjud bo‘lmagan joyda

ishlatiladi.

Masalan:

```go
ctx := context.Background()
```

Bu contextning o‘zida `deadline`, bekor qilish signali yoki qo‘shimcha qiymat yo‘q. Keyinchalik undan `WithCancel`, `WithTimeout`, `WithDeadline` yoki `WithValue` yordamida yangi contextlar hosil qilish mumkin.

`context.TODO()` ham amalda bo‘sh context hisoblanadi. Lekin uning ma’nosi boshqacha. U odatda qaysi contextni uzatish kerakligi hali aniqlanmagan vaqtinchalik joyda ishlatiladi.

Masalan, eski kodni asta-sekin `context` bilan ishlaydigan holatga o‘tkazayotgan bo‘lsangiz, vaqtincha `context.TODO()` ishlatishingiz mumkin.

Funksiya `context` qabul qilsa, Go kodida uni birinchi parametr sifatida berish odatiy:

```go
func LoadUser(ctx context.Context, id int64) error
```

Bu qatorda `ctx` birinchi parametr. Keyin funksiyaning o‘ziga tegishli argumentlar keladi.

Bunday tartib Go ekotizimida keng qo‘llanadi. Shu sabab funksiyani ko‘rgan dasturchi uning bekor qilish yoki `deadline` bilan ishlashi mumkinligini darhol tushunadi.

`Context`ni odatda struct ichida saqlash tavsiya qilinmaydi.

Masalan, bunday yondashuvdan qochish kerak:

```go
type Service struct {
	ctx context.Context
}
```

Sababi `context` odatda ma’lum bir operatsiya yoki request’ning umriga bog‘liq bo‘ladi. Struct esa undan ancha uzoq yashashi mumkin. Contextni struct ichida saqlash qaysi request yoki operatsiyaga tegishli ekanini noaniq qilib qo‘yadi.

Yaxshiroq usul — contextni kerakli methodga parametr sifatida uzatish:

```go
func (s *Service) LoadUser(ctx context.Context, id int64) error
```

Shuningdek, `context.Context` o‘rniga `nil` bermang.

Masalan:

```go
LoadUser(nil, 10)
```

o‘rniga, agar boshqa mos context bo‘lmasa:

```go
LoadUser(context.Background(), 10)
```

ishlatish kerak.

Bu funksiyaning ichida `ctx.Done()`, `ctx.Err()` yoki boshqa context methodlari xavfsiz chaqirilishini ta’minlaydi.

## Bekor qilish

Ba’zi ishlar tashqaridan aniq signal kelganda to‘xtatilishi kerak. Buning uchun `context.WithCancel()` ishlatiladi.

U ota contextdan yangi bola context yaratadi:

```go
ctx, cancel := context.WithCancel(context.Background())
defer cancel()
```

Bu yerda ikkita qiymat qaytmoqda:

* `ctx` — yangi context;
* `cancel` — shu contextni bekor qiladigan funksiya.

`cancel()` chaqirilganda `ctx.Done()` orqali olinadigan channel yopiladi.

Masalan, ishchi funksiya quyidagicha signalni kuzatishi mumkin:

```go
select {
case <-ctx.Done():
	return ctx.Err()
default:
}
```

`ctx.Done()` oddiy qiymat yuboradigan channel sifatida ishlatilmaydi. Context bekor qilinganda bu channel yopiladi. Channel yopilishi barcha kuzatuvchilarga bir vaqtning o‘zida signal beradi.

`ctx.Err()` esa context nima sababdan tugaganini ko‘rsatadi.

Agar `cancel()` qo‘lda chaqirilgan bo‘lsa:

```go
ctx.Err()
```

quyidagi xatoni qaytaradi:

```go
context.Canceled
```

Bu yerda muhim bir farq bor. `Done()` faqat "context tugadi" degan signalni beradi. Nega tugaganini bilish uchun `Err()` ishlatiladi.

`cancel()`ni `defer` orqali chaqirish keng tarqalgan:

```go
ctx, cancel := context.WithCancel(parent)
defer cancel()
```

Buning sababi context bilan bog‘liq resurslar kerak bo‘lmay qolganda albatta tozalanishidir.

Agar ish undan oldin boshqa sabab bilan tugasa ham, `defer cancel()` funksiyadan chiqishda `cancel()` chaqirilishini kafolatlaydi.

## Timeout va deadline

`context` vaqt chegarasi bilan ishlashning ikkita asosiy usulini beradi:

* `WithTimeout`;
* `WithDeadline`.

`timeout` hozirgi vaqtdan boshlab qancha vaqt ishlash mumkinligini bildiradi.

Masalan:

```go
ctx, cancel := context.WithTimeout(parent, 2*time.Second)
defer cancel()
```

Bu context taxminan ikki soniyadan keyin avtomatik tugaydi.

Jarayonni oddiy ko‘rinishda quyidagicha tasavvur qilish mumkin:

```text
context yaratildi
        |
        v
2 soniya davomida ishlash mumkin
        |
        v
timeout tugadi
        |
        v
ctx.Done() yopildi
        |
        v
ctx.Err() == context.DeadlineExceeded
```

`deadline` esa davomiylik emas, aniq vaqt nuqtasini bildiradi.

Masalan:

```go
ctx, cancel := context.WithDeadline(parent, time.Now().Add(2*time.Second))
defer cancel()
```

Bu misolda deadline hozirgi vaqtdan ikki soniya keyinga qo‘yilgan. Natijada bu kod amalda oldingi `WithTimeout` misoliga juda o‘xshash ishlaydi.

Farqi — API qanday ma’noni ifodalayotganida.

Agar sizga:

> "Bu ish ko‘pi bilan ikki soniya ishlasin"

degan qoida kerak bo‘lsa, `WithTimeout` tabiiyroq.

Agar sizga:

> "Bu ish soat 15:30 dan kech tugamasin"

kabi aniq vaqt chegarasi kerak bo‘lsa, `WithDeadline` mos keladi.

Vaqt tugaganda `Done()` kanali yopiladi.

Shundan keyin:

```go
ctx.Err()
```

quyidagini qaytaradi:

```go
context.DeadlineExceeded
```

Bu qiymat `context.Canceled`dan farq qiladi.

`context.Canceled` odatda context tashqaridan bekor qilinganini bildiradi.

`context.DeadlineExceeded` esa belgilangan vaqt chegarasi tugaganini bildiradi.

Ish deadline’dan oldin tugasa ham `cancel()`ni chaqirish kerak:

```go
ctx, cancel := context.WithTimeout(parent, 2*time.Second)
defer cancel()
```

Buning sababi faqat bekor qilish emas. `WithTimeout` va `WithDeadline` ichki timer va boshqa resurslarni boshqarishi mumkin. `cancel()` chaqirilsa, ular deadline kelishini kutmasdan oldinroq bo‘shatilishi mumkin.

## Bekor qilinadigan ishchi funksiya

Quyidagi dastur timeout va `ctx.Done()` birga qanday ishlashini ko‘rsatadi:

```go
package main

import (
	"context"
	"fmt"
	"time"
)

func work(ctx context.Context) error {
	ticker := time.NewTicker(100 * time.Millisecond)
	defer ticker.Stop()

	for step := 1; step <= 10; step++ {
		select {
		case <-ctx.Done():
			return ctx.Err()
		case <-ticker.C:
			fmt.Println("Qadam:", step)
		}
	}
	return nil
}

func main() {
	ctx, cancel := context.WithTimeout(context.Background(), 250*time.Millisecond)
	defer cancel()

	if err := work(ctx); err != nil {
		fmt.Println("Ish tugadi:", err)
	}
}
```

Bu misolda `work()` 10 ta qadam bajarishga harakat qiladi.

Har bir qadam orasida `100ms` kutish uchun `ticker` yaratilgan:

```go
ticker := time.NewTicker(100 * time.Millisecond)
defer ticker.Stop()
```

`time.NewTicker()` har `100ms` da `ticker.C` kanaliga signal beradi.

`ticker.Stop()` esa funksiya tugaganda ticker’ni to‘xtatadi. Uni `defer` bilan chaqirish ticker resurslari ortiqcha ishlashda davom etmasligi uchun kerak.

Keyin sikl boshlanadi:

```go
for step := 1; step <= 10; step++ {
```

Nazariy jihatdan funksiya 10 ta qadamni bajarishi kerak.

Lekin har bir aylanishda `select` ikkita hodisadan birini kutadi:

```go
select {
case <-ctx.Done():
	return ctx.Err()
case <-ticker.C:
	fmt.Println("Qadam:", step)
}
```

Birinchi `case`:

```go
case <-ctx.Done():
	return ctx.Err()
```

context tugashini kutadi.

Agar timeout tugasa yoki context qo‘lda bekor qilinsa, `ctx.Done()` yopiladi. Shunda funksiya darhol `ctx.Err()` bilan qaytadi.

Ikkinchi `case`:

```go
case <-ticker.C:
	fmt.Println("Qadam:", step)
```

keyingi `100ms` oralig‘i kelganini kutadi. Signal kelganda navbatdagi qadam chiqariladi.

`main()` ichida context uchun `250ms` timeout berilgan:

```go
ctx, cancel := context.WithTimeout(context.Background(), 250*time.Millisecond)
defer cancel()
```

Ishning taxminiy vaqt oqimini ko‘rsak:

```text
0ms
context yaratildi

100ms
Qadam: 1

200ms
Qadam: 2

250ms
context timeout bo‘ldi
ctx.Done() yopildi
work() ctx.Err() bilan tugadi
```

Shuning uchun funksiya odatda 10 ta qadamning barchasini bajarmaydi.

`work()` xato qaytarsa, `main()` uni chiqaradi:

```go
if err := work(ctx); err != nil {
	fmt.Println("Ish tugadi:", err)
}
```

Timeout sababli taxminan quyidagiga o‘xshash natija chiqadi:

```text
Qadam: 1
Qadam: 2
Ish tugadi: context deadline exceeded
```

Aniq scheduling sabab vaqt chegarasiga juda yaqin holatlarda qaysi `select` branch tanlanishi kafolatlanmaydi. Lekin bu misolning asosiy maqsadi o‘zgarmaydi: ishchi funksiya timer bilan birga bekor qilish signalini ham kuzatmoqda.

Bu pattern ayniqsa:

* HTTP so‘rovlarida;
* database query’larda;
* tashqi API chaqiruvlarida;
* background worker’larda;
* uzoq davom etadigan sikllarda

foydali.

Muhim qoida shuki, contextni yaratishning o‘zi ishni avtomatik to‘xtatmaydi. `work()` kabi kod `ctx.Done()`ni tekshirishi kerak.

## `WithValue()` qachon ishlatiladi?

`context.WithValue()` context zanjiri bo‘ylab kichik, request’ga tegishli qiymatlarni uzatish uchun ishlatiladi.

Masalan:

* request ID;
* trace ID;
* autentifikatsiyaga tegishli ma’lumot;
* request bilan birga yurishi kerak bo‘lgan metadata.

U quyidagicha ishlatiladi:

```go
ctx := context.WithValue(parent, key, value)
```

Keyin pastki qatlamdagi kod qiymatni olishi mumkin:

```go
value := ctx.Value(key)
```

Lekin `WithValue()` oddiy funksiya parametrining universal o‘rnini bosmaydi.

Masalan, funksiya uchun `userID` majburiy bo‘lsa, bunday yozish odatda yaxshiroq:

```go
func LoadUser(ctx context.Context, userID int64) error
```

`userID`ni context ichiga yashirib:

```go
func LoadUser(ctx context.Context) error
```

va keyin ichkarida `ctx.Value()` orqali olish API’ni kamroq tushunarli qiladi.

Xuddi shunday, konfiguratsiya yoki majburiy dependency’larni ham context ichiga joylashtirish tavsiya qilinmaydi.

Masalan, database connection:

```go
*sql.DB
```

yoki logger service uchun doimiy dependency bo‘lsa, uni struct yoki aniq parametr orqali berish odatda to‘g‘riroq.

`WithValue()` ko‘proq request oqimi bilan birga harakatlanadigan qo‘shimcha metadata uchun mo‘ljallangan.

Context kalitlari bilan ishlaganda yana bir muhim masala bor: kalitlar to‘qnashishi mumkin.

Masalan, ikki package bir xil string kalit ishlatsa:

```go
"requestID"
```

ular tasodifan bir-birining qiymatini ko‘rishi mumkin.

Shu sabab package ichida alohida, eksport qilinmagan tur yaratish yaxshi amaliyot:

```go
type contextKey string

const requestIDKey contextKey = "requestID"
```

Keyin qiymat yoziladi:

```go
ctx := context.WithValue(parent, requestIDKey, "abc-123")
```

Va olinadi:

```go
requestID, ok := ctx.Value(requestIDKey).(string)
if !ok {
	// qiymat yo‘q yoki kutilgan turda emas
}
```

Bu yerda type assertion ishlatilmoqda:

```go
.(string)
```

`ctx.Value()` `any` qaytaradi. Shu sabab olingan qiymat haqiqatan `string` ekanini tekshirish kerak.

`ok`ni tekshirmasdan ko‘r-ko‘rona type assertion qilish xavfli bo‘lishi mumkin.

Masalan:

```go
requestID := ctx.Value(requestIDKey).(string)
```

agar qiymat mavjud bo‘lmasa yoki boshqa turda bo‘lsa, runtime’da panic yuz beradi.

Xavfsizroq variant:

```go
requestID, ok := ctx.Value(requestIDKey).(string)
if !ok {
	// qiymat topilmadi yoki noto‘g‘ri turda
}
```

Shu sabab `WithValue()` bilan ishlaganda ikki qoida muhim:

* context ichiga faqat request’ga tegishli metadata joylashtiring;
* qiymatni olayotganda uning mavjudligi va turini tekshiring.
