# `select` operatori

`select` bir nechta channel amali orasidan ayni paytda bajarishga tayyor bo‘lgan bittasini tanlaydi.

Oddiy channel amali faqat bitta yuborish yoki qabul qilish operatsiyasini kutadi. `select` esa bir vaqtning o‘zida bir nechta channelni kuzatishga imkon beradi.

Masalan, backend xizmat quyidagi ikki hodisani bir vaqtda kutishi mumkin:

* tashqi API’dan natija kelishi;
* foydalanuvchi so‘rovni bekor qilishi.

Qaysi hodisa birinchi tayyor bo‘lsa, `select` o‘sha holatga tegishli kodni bajaradi.

Shu sababli `select` odatda:

* bir nechta goroutinedan kelayotgan natijalarni kutishda;
* timeout, ya’ni vaqt chegarasini qo‘yishda;
* `context` orqali bekor qilish signalini kuzatishda;
* bir nechta channel orasidan tayyor bo‘lganini tanlashda

ishlatiladi.

## Asosiy sintaksis

`select` tashqi ko‘rinishidan `switch`ga o‘xshaydi. Lekin uning `case`lari oddiy shartlarni emas, channel operatsiyalarini kutadi:

```go
select {
case msg := <-messages:
	fmt.Println("Qabul qilindi:", msg)
case results <- value:
	fmt.Println("Natija yuborildi")
default:
	fmt.Println("Hozircha tayyor kanal yo‘q")
}
```

Bu yerda uchta imkoniyat bor.

Birinchi `case`:

```go
case msg := <-messages:
```

`messages` channelidan qiymat qabul qilishga urinadi.

Ikkinchi `case`:

```go
case results <- value:
```

`value` qiymatini `results` channeliga yuborishga urinadi.

`default` esa hech bir channel operatsiyasi hozir bajarishga tayyor bo‘lmasa ishlaydi.

`select` bajarilganda quyidagi qoidalar amal qiladi:

* faqat bitta `case` tayyor bo‘lsa, aynan o‘sha `case` bajariladi;
* bir nechta `case` bir vaqtda tayyor bo‘lsa, Go ular orasidan bittasini pseudo-random tarzda tanlaydi;
* hech bir `case` tayyor bo‘lmasa va `default` mavjud bo‘lmasa, joriy goroutine bloklanadi;
* hech bir `case` tayyor bo‘lmasa va `default` mavjud bo‘lsa, `default` darhol bajariladi.

Bu yerda muhim bir qoida bor: `case`larning kod ichidagi tartibi ularga ustuvorlik bermaydi.

Masalan:

```go
select {
case value := <-first:
	fmt.Println(value)
case value := <-second:
	fmt.Println(value)
}
```

agar `first` ham, `second` ham qabul qilish uchun tayyor bo‘lsa, yuqorida yozilgani uchun `first` avtomatik tanlanmaydi.

`select` yuqoridan pastga yurib, birinchi tayyor `case`ni tanlamaydi. Bir nechta operatsiya tayyor bo‘lsa, ulardan bittasi tanlanadi.

## Birinchi ishlaydigan misol

Quyidagi misolda ikkita goroutine turli vaqtda natija yuboradi:

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	fast := make(chan string)
	slow := make(chan string)

	go func() {
		time.Sleep(100 * time.Millisecond)
		fast <- "tez natija"
	}()

	go func() {
		time.Sleep(200 * time.Millisecond)
		slow <- "sekin natija"
	}()

	select {
	case value := <-fast:
		fmt.Println(value)
	case value := <-slow:
		fmt.Println(value)
	}
}
```

Odatdagi natija:

```text
tez natija
```

Jarayonni bosqichma-bosqich ko‘ramiz.

Avval ikkita buffersiz channel yaratiladi:

```go
fast := make(chan string)
slow := make(chan string)
```

Keyin birinchi goroutine ishga tushadi:

```go
go func() {
	time.Sleep(100 * time.Millisecond)
	fast <- "tez natija"
}()
```

U taxminan 100 millisekund kutadi va `fast` channeliga qiymat yubormoqchi bo‘ladi.

Ikkinchi goroutine esa:

```go
go func() {
	time.Sleep(200 * time.Millisecond)
	slow <- "sekin natija"
}()
```

taxminan 200 millisekunddan keyin `slow` channeliga qiymat yuboradi.

`main` goroutine esa quyidagi `select`ga keladi:

```go
select {
case value := <-fast:
	fmt.Println(value)
case value := <-slow:
	fmt.Println(value)
}
```

Bu paytda hech bir qiymat hali kelmagan bo‘lsa, `select` bloklanadi. U ikkala channeldan birortasi qabul qilish uchun tayyor bo‘lishini kutadi.

Taxminan 100 millisekunddan keyin `fast` channeliga yuborish operatsiyasi paydo bo‘ladi. Shu sabab:

```go
case value := <-fast:
```

bajarishga tayyor bo‘ladi va `select` shu `case`ni tanlaydi.

Ikkala channel ham buffersiz. Buffersiz channelda yuboruvchi va qabul qiluvchi bir-biriga mos kelishi kerak. Yuboruvchi qiymatni shunchaki channel ichiga tashlab, davom eta olmaydi. U qabul qiluvchi tayyor bo‘lishini kutadi.

Bu misolda uyqu vaqtlari ataylab turlicha berilgan. Shu sabab odatda `fast` birinchi tanlanadi.

Lekin quyidagini eslab qolish kerak: agar ikkala channel operatsiyasi bir vaqtda tayyor bo‘lsa, qaysi `case` tanlanishini koddagi tartibga qarab oldindan aytib bo‘lmaydi.

Yana bir muhim nuqta bor. Bu yerda `select` faqat bir marta bajarilgan.

`fast`dan qiymat olingach, `select` tugaydi va `main` funksiyasi yakunlanadi. Go `main` tugaganda boshqa goroutinelarning ham albatta yakunlanishini kutmaydi.

Shu sababli dastur `slow` channelidan ikkinchi natijani qabul qilmaydi.

## Bir nechta natijani qabul qilish

Agar ikkala natija ham kerak bo‘lsa, `select`ni bir marta bajarish yetarli emas.

Uni kerakli miqdorda takrorlash mumkin:

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	first := make(chan string)
	second := make(chan string)

	go func() {
		time.Sleep(100 * time.Millisecond)
		first <- "birinchi kanal"
	}()

	go func() {
		time.Sleep(200 * time.Millisecond)
		second <- "ikkinchi kanal"
	}()

	for i := 0; i < 2; i++ {
		select {
		case value := <-first:
			fmt.Println(value)
		case value := <-second:
			fmt.Println(value)
		}
	}
}
```

Natija:

```text
birinchi kanal
ikkinchi kanal
```

Bu yerda asosiy farq:

```go
for i := 0; i < 2; i++ {
```

siklida.

`select` ikki marta bajariladi.

Birinchi aylanishda `first` taxminan 100 millisekunddan keyin tayyor bo‘ladi:

```text
birinchi kanal
```

qiymati olinadi.

Shundan keyin sikl ikkinchi marta ishlaydi. `select` yana kanallardan birortasi tayyor bo‘lishini kutadi.

Bu safar qolgan `second` channelidan:

```text
ikkinchi kanal
```

qiymati olinadi.

Demak, `select`ning o‘zi barcha tayyor natijalarni birdaniga yig‘ib bermaydi. Har bir bajarilishida ko‘pi bilan bitta `case` tanlanadi.

Agar nechta natija kelishi oldindan ma’lum bo‘lsa, bu misoldagidek sanash mumkin.

Lekin natijalar soni oldindan noma’lum bo‘lsa, odatda channelning yopilganini kuzatish kerak. Bunday vaziyatda `value, ok := <-ch` shakli yordam beradi. Buni keyinroq yopilgan channel bo‘limida ko‘ramiz.

## Bloklanish nima?

Channel bilan ishlaganda `bloklanish` tushunchasini aniq tushunish muhim.

Goroutine bir operatsiyani bajarish uchun kerakli sharoit paydo bo‘lishini kutib qolsa, u bloklangan hisoblanadi.

Buffersiz channelda yuborish va qabul qilish bir-biriga mos kelishi kerak.

Yuborish:

```go
ch <- value
```

bajarilishi uchun qabul qiluvchi mavjud bo‘lishi kerak.

Qabul qilish:

```go
value := <-ch
```

bajarilishi uchun esa yuboruvchi mavjud bo‘lishi kerak.

Aks holda operatsiyani bajarayotgan goroutine kutadi.

Quyidagi kodda `main` goroutine buffersiz channelga qiymat yubormoqchi:

```go
package main

func main() {
	ch := make(chan int)
	ch <- 10 // Qabul qiluvchi yo‘q, shu sababli runtime deadlockni aniqlaydi.
}
```

Bu ataylab noto‘g‘ri yozilgan misol.

Jarayon quyidagicha:

1. `ch` nomli buffersiz channel yaratiladi.
2. `main` goroutine `10` qiymatini yuborishga keladi.
3. Lekin hech qanday boshqa goroutine `ch`dan qiymat qabul qilmayapti.
4. Shu sabab `main` shu qatorning o‘zida bloklanadi.
5. Ishlay oladigan boshqa goroutine ham yo‘q.
6. Go runtime dastur davom eta olmasligini aniqlaydi.

Natijada dastur odatda quyidagi xato bilan tugaydi:

```text
fatal error: all goroutines are asleep - deadlock!
```

Muammoni bir nechta usul bilan hal qilish mumkin.

Masalan, qabul qiluvchi goroutine ishga tushirish mumkin:

```go
go func() {
	<-ch
}()
```

Yoki vazifa shunga mos bo‘lsa, channelga buffer berish mumkin.

Lekin buffer qo‘shish har bir deadlock uchun universal yechim emas. To‘g‘ri yechim ma’lumot qayerdan kelishi, kim qabul qilishi va goroutinelar qanday sinxronlashtirilishiga bog‘liq.

## Bloklanmaydigan kanal amali

Ba’zan channel tayyor bo‘lmasa, kutish kerak emas. Dastur boshqa ishini davom ettirishi kerak bo‘ladi.

Bunday holatda `select` ichidagi `default` ishlatilishi mumkin:

```go
package main

import "fmt"

func main() {
	ch := make(chan int, 1)

	select {
	case value := <-ch:
		fmt.Println("Qabul qilindi:", value)
	default:
		fmt.Println("Kanalda qiymat yo‘q")
	}
}
```

Natija:

```text
Kanalda qiymat yo‘q
```

Bu yerda channel bufferli:

```go
ch := make(chan int, 1)
```

lekin uning ichiga hech qanday qiymat yozilmagan.

Shuning uchun:

```go
case value := <-ch:
```

hozir bajarishga tayyor emas.

Agar `default` bo‘lmaganida, `select` qiymat kelishini kutib bloklanardi.

Lekin bu yerda:

```go
default:
	fmt.Println("Kanalda qiymat yo‘q")
```

mavjud. Shu sabab `select` kutmaydi va `default` darhol bajariladi.

Bunday yondashuv `non-blocking` channel operatsiyasi deb ataladi. Ya’ni dastur channel tayyor bo‘lmasa ham shu joyda kutib qolmaydi.

Bu usul masalan telemetriya, statistik ma’lumot yoki tashlab yuborilishi mumkin bo‘lgan signal uchun foydali bo‘lishi mumkin.

Lekin muhim ma’lumotlar uchun ehtiyot bo‘lish kerak.

Masalan:

```go
select {
case jobs <- job:
	// yuborildi
default:
	// yuborilmadi
}
```

ko‘rinishidagi kod producerga kutmasdan davom etish imkonini beradi. Agar `jobs` channeli tayyor bo‘lmasa, `job` tashlab yuboriladi.

Agar bu biznes uchun muhim vazifa bo‘lsa, bunday xatti-harakat ma’lumot yo‘qolishiga olib kelishi mumkin.

`default` yana backpressurega ham ta’sir qiladi.

Backpressure — consumer producer tezligiga yetisha olmaganda, producerning tabiiy ravishda sekinlashishi yoki kutib qolishi.

Agar `default` orqali yuborishni doim bloklanmaydigan qilsak, bu tabiiy kutish mexanizmini chetlab o‘tishimiz mumkin.

**Diqqat**

`for` sikli ichida faqat `select` va `default` bo‘lsa, hech qanday bloklovchi operatsiya bo‘lmasligi mumkin. Natijada sikl juda tez qayta-qayta aylanadi. Bu holat **busy loop** deb ataladi va CPU vaqtini bekorga sarflashi mumkin.

Masalan:

```go
for {
    select {
    default:
    }
}
```

Bu sikl hech narsani kutmaydi. U imkon qadar tez aylanaveradi.

## Vaqt chegarasi

Tashqi xizmatdan javobni yoki uzoq davom etadigan hisoblashni cheksiz kutish ko‘pincha yaxshi yechim emas.

Masalan, tashqi API javob bermay qolsa, butun request handler uzoq vaqt kutib turishi mumkin.

`select`ga timer channelini qo‘shib, operatsiyaga vaqt chegarasi berish mumkin:

```go
package main

import (
	"fmt"
	"time"
)

func main() {
	result := make(chan string, 1)

	go func() {
		time.Sleep(200 * time.Millisecond)
		result <- "tayyor"
	}()

	timer := time.NewTimer(100 * time.Millisecond)
	defer timer.Stop()

	select {
	case value := <-result:
		fmt.Println(value)
	case <-timer.C:
		fmt.Println("vaqt tugadi")
	}
}
```

Natija:

```text
vaqt tugadi
```

Bu kodni bosqichma-bosqich ko‘ramiz.

Avval natija uchun channel yaratiladi:

```go
result := make(chan string, 1)
```

Uning sig‘imi `1`. Demak, bir dona qiymat buffer ichiga joylanishi mumkin.

Keyin goroutine ishga tushadi:

```go
go func() {
	time.Sleep(200 * time.Millisecond)
	result <- "tayyor"
}()
```

Bu goroutine 200 millisekunddan keyin natijani yuboradi.

Ammo timeout 100 millisekundga o‘rnatilgan:

```go
timer := time.NewTimer(100 * time.Millisecond)
```

`timer.C` — vaqt tugaganda qiymat yuboradigan channel.

`select` esa ikkita hodisani kutmoqda:

```go
select {
case value := <-result:
	fmt.Println(value)
case <-timer.C:
	fmt.Println("vaqt tugadi")
}
```

Taxminan 100 millisekunddan keyin timer birinchi bo‘lib tayyor bo‘ladi.

Shu sabab:

```go
case <-timer.C:
```

tanlanadi va:

```text
vaqt tugadi
```

chiqariladi.

Bu misolda `result` channelining bufferli ekaniga alohida e’tibor berish kerak.

Agar u buffersiz bo‘lganida:

```go
result := make(chan string)
```

`main` timeout sababli `select`dan chiqib ketganidan keyin worker goroutine:

```go
result <- "tayyor"
```

qatoriga kelishi mumkin edi.

Lekin endi `result`dan qiymat qabul qiladigan goroutine qolmagan bo‘ladi. Buffersiz channel sabab yuboruvchi shu yerda bloklanib qolishi mumkin.

Sig‘imi `1` bo‘lgan buffer workerga qiymatni joylashtirib, ishini tugatish imkonini beradi.

Bu timeoutning juda muhim xususiyatini ko‘rsatadi:

> timeout kutishni to‘xtatadi, lekin ishlayotgan goroutineni avtomatik ravishda bekor qilmaydi.

Agar hisoblashning o‘zini ham to‘xtatish kerak bo‘lsa, odatda `context` yoki alohida bekor qilish signali ishlatiladi.

Bitta oddiy kutish uchun `time.After` ham ishlatish mumkin:

```go
select {
case value := <-result:
	fmt.Println(value)
case <-time.After(100 * time.Millisecond):
	fmt.Println("vaqt tugadi")
}
```

Bu qisqa va o‘qilishi qulay.

Lekin uzoq davom etadigan siklda har aylanishda yangi `time.After` yaratish yangi timer obyektlarini yaratadi.

Timerning lifecycle’ini aniqroq boshqarish kerak bo‘lsa, `time.NewTimer` ishlatish va kerakli vaziyatda uni `Reset` qilish ma’qulroq bo‘lishi mumkin.

Davriy signal kerak bo‘lsa esa `time.NewTicker` ishlatiladi.

## `context` orqali bekor qilish

Real backend kodida faqat timeoutni kutishning o‘zi yetarli bo‘lmaydi.

Ko‘pincha ishlayotgan operatsiyani ham bekor qilish kerak.

Bunday signal Go’da odatda `context.Context` orqali uzatiladi.

`Context` ichidagi:

```go
ctx.Done()
```

bekor qilish yoki deadline tugaganda yopiladigan channel qaytaradi.

Channel yopilgach, undan qabul qilish darhol tayyor bo‘ladi. Shu sabab `ctx.Done()`ni `select` ichida kutish juda qulay.

`Context` yaratish, timeout, deadline va `cancel()` qoidalari `context` asoslari darsida batafsil tushuntiriladi.

Quyidagi misolda worker davriy ravishda qadam bajaradi, lekin `context` bekor qilinsa ishni to‘xtatadi:

```go
package main

import (
	"context"
	"fmt"
	"time"
)

func work(ctx context.Context) error {
	ticker := time.NewTicker(20 * time.Millisecond)
	defer ticker.Stop()

	for step := 1; step <= 10; step++ {
		select {
		case <-ctx.Done():
			return ctx.Err()
		case <-ticker.C:
			fmt.Println("qadam:", step)
		}
	}

	return nil
}

func main() {
	ctx, cancel := context.WithTimeout(context.Background(), 50*time.Millisecond)
	defer cancel()

	if err := work(ctx); err != nil {
		fmt.Println("ish to‘xtadi:", err)
	}
}
```

Bu kodda:

```go
ticker := time.NewTicker(20 * time.Millisecond)
```

har taxminan 20 millisekundda signal beradi.

Worker sikli:

```go
for step := 1; step <= 10; step++ {
```

eng ko‘pi bilan 10 ta qadam bajarishga harakat qiladi.

Har aylanishda `select` ikkita hodisani kutadi:

```go
case <-ctx.Done():
```

yoki:

```go
case <-ticker.C:
```

Agar ticker birinchi tayyor bo‘lsa:

```go
fmt.Println("qadam:", step)
```

bajariladi.

`main`da esa context uchun 50 millisekundlik timeout berilgan:

```go
ctx, cancel := context.WithTimeout(
	context.Background(),
	50*time.Millisecond,
)
```

Taxminan 50 millisekunddan keyin deadline tugaydi va `ctx.Done()` yopiladi.

Shundan keyin:

```go
case <-ctx.Done():
	return ctx.Err()
```

bajarilishi mumkin.

`ctx.Err()` bu holatda:

```text
context deadline exceeded
```

xatosini qaytaradi.

Shu sabab yakuniy satr:

```text
ish to‘xtadi: context deadline exceeded
```

ko‘rinishida bo‘ladi.

Undan oldin nechta:

```text
qadam: ...
```

satri chiqishi scheduler va timerlarning amalda qachon ishga tushishiga bog‘liq bo‘lishi mumkin. Shu sabab aniq qadamlar soniga tayanmaslik kerak.

Bu pattern real dasturlarda juda ko‘p uchraydi.

Masalan:

* HTTP request client tomonidan bekor qilinganda;
* database query deadline’dan oshib ketganda;
* bir nechta goroutine bitta umumiy signal orqali to‘xtatilishi kerak bo‘lganda;
* server shutdown paytida workerlarni boshqarishda.

Bu yerda asosiy qoida shuki, worker `context`ni shunchaki qabul qilib qo‘ymasligi kerak. U kerakli joylarda `ctx.Done()`ni kuzatishi yoki contextni context-aware API’larga uzatishi kerak.

## Yopilgan va `nil` kanal

`select` bilan ishlaganda yopilgan channel va `nil` channel orasidagi farq juda muhim.

Ular deyarli qarama-qarshi xatti-harakat qiladi:

* yopilgan channeldan qabul qilish bloklanmaydi;
* `nil` channeldan qabul qilish esa bloklanadi.

Avval yopilgan channelni ko‘ramiz.

Channel yopilgach, uning bufferida qolgan qiymatlar avval o‘qiladi. Buffer tugagach, undan yana qabul qilinsa channel element turining zero value qiymati qaytadi.

Channel haqiqatan yopilganini tekshirish uchun ikki qiymatli qabul qilish ishlatiladi:

```go
value, ok := <-ch
if !ok {
	// Kanal yopilgan.
}
```

Bu yerda:

* `value` — olingan qiymat;
* `ok` — qabul qilish muvaffaqiyatli qiymat berganini bildiradi.

Agar:

```go
ok == false
```

bo‘lsa, channel yopilgan va uning bufferida boshqa qiymat qolmagan.

Bu tekshiruv ayniqsa `int`, `bool`, pointer yoki boshqa zero value’ga ega turlarda muhim.

Masalan, `int` channel uchun yopilgandan keyingi qiymat:

```go
0
```

bo‘ladi.

Lekin `0` haqiqiy biznes ma’lumot ham bo‘lishi mumkin. `ok`ni tekshirmasak, yopilgan channeldan kelgan zero value’ni haqiqiy ma’lumot deb qabul qilishimiz mumkin.

Endi `select`dagi muammoni ko‘ramiz.

Yopilgan channeldan qabul qilish bloklanmagani uchun uning `case`i doim tayyor turadi.

Agar bir nechta channelni siklda o‘qiyotgan bo‘lsak, yopilgan channel qayta-qayta `select`ga tushishi mumkin.

Buni to‘xtatish uchun channel o‘zgaruvchisiga `nil` berish mumkin.

`nil` channelga yuborish ham, undan qabul qilish ham oddiy holatda abadiy bloklanadi. `select` ichida esa bunday channelga tegishli `case` tanlanmaydi.

Quyidagi misol shu usulni ko‘rsatadi:

```go
package main

import "fmt"

func main() {
	left := make(chan int, 1)
	right := make(chan int, 1)

	left <- 10
	right <- 20

	close(left)
	close(right)

	for left != nil || right != nil {
		select {
		case value, ok := <-left:
			if !ok {
				left = nil
				continue
			}
			fmt.Println("left:", value)

		case value, ok := <-right:
			if !ok {
				right = nil
				continue
			}
			fmt.Println("right:", value)
		}
	}
}
```

Natija satrlarining tartibi o‘zgarishi mumkin:

```text
left: 10
right: 20
```

Avval ikkala bufferli channelga bittadan qiymat yoziladi:

```go
left <- 10
right <- 20
```

Keyin ikkalasi yopiladi:

```go
close(left)
close(right)
```

Channel yopilishi uning ichidagi mavjud buffered qiymatlarni yo‘q qilib yubormaydi.

Shuning uchun `left`dan hali ham `10`, `right`dan esa `20` olish mumkin.

Sikl shunday davom etadi:

```go
for left != nil || right != nil {
```

Hech bo‘lmaganda bitta channel faol ekan, sikl ishlaydi.

Channelning qiymati tugab, yopilgan holati aniqlansa:

```go
if !ok {
	left = nil
	continue
}
```

o‘zgaruvchiga `nil` beriladi.

Shundan keyin:

```go
case value, ok := <-left:
```

amaliy jihatdan o‘chiriladi, chunki `left` endi `nil`.

Xuddi shu jarayon `right` uchun ham bajariladi.

Ikkalasi ham:

```go
left == nil
right == nil
```

bo‘lgach, sikl sharti yolg‘on bo‘ladi va sikl tugaydi.

Agar yopilgan channelni `nil`ga o‘tkazmasak, uning receive `case`i doim tayyor bo‘lib qoladi. Natijada `select` uni yana va yana tanlashi va zero value qaytarishi mumkin.

Bu `select` bilan bir nechta channelni dinamik boshqarishda juda foydali pattern.

## Bo‘sh `select`

Go’da quyidagi kod ham to‘g‘ri sintaksis hisoblanadi:

```go
select {}
```

Bu `select`da:

* `case` yo‘q;
* `default` yo‘q.

Demak, bajarishga tayyor bo‘lishi mumkin bo‘lgan hech qanday operatsiya ham yo‘q.

Natijada joriy goroutine abadiy bloklanadi.

Masalan:

```go
func main() {
	select {}
}
```

`main` goroutine shu yerda tugamasdan turadi.

Ba’zan dasturda fon goroutinelarni ishga tushirib, `main`ni sun’iy ravishda ochiq qoldirish uchun bunday kodni uchratish mumkin.

Lekin amaliy dasturda bu ko‘pincha eng yaxshi boshqaruv usuli emas.

Sababi `select {}` fon goroutinelarning holatini bilmaydi.

Masalan:

* worker xato bilan tugagan bo‘lishi mumkin;
* barcha goroutinelar allaqachon ishlashni to‘xtatgan bo‘lishi mumkin;
* server shutdown qilinishi kerak bo‘lishi mumkin.

Lekin `main` baribir abadiy kutib turadi.

Shu sabab goroutinelarning lifecycle’ini:

* `sync.WaitGroup`;
* channel;
* `context`

yordamida boshqarish odatda aniqroq.

Bu vositalar nafaqat kutish, balki ishning qachon va nima sababdan tugayotganini boshqarishga ham yordam beradi.

## Keng tarqalgan xatolar

`select` sintaksisi sodda ko‘rinsa ham, uning xatti-harakatini noto‘g‘ri tushunish oson.

Quyidagi xatolar ayniqsa ko‘p uchraydi.

### `select` barcha tayyor `case`larni bajaradi deb o‘ylash

Bu noto‘g‘ri.

`select` bir marta bajarilganda ko‘pi bilan bitta `case` tanlaydi.

Masalan, uchta channel bir vaqtda tayyor bo‘lsa ham:

```go
select {
case <-a:
case <-b:
case <-c:
}
```

faqat bittasi bajariladi.

Agar barcha natijalarni olish kerak bo‘lsa, `select` odatda sikl ichida ishlatiladi.

### Yuqoridagi `case` ustun deb hisoblash

Bu ham noto‘g‘ri.

Quyidagi kodda:

```go
select {
case <-first:
case <-second:
}
```

`first` yuqorida yozilgani uchun ustunlikka ega emas.

Agar ikkala operatsiya ham tayyor bo‘lsa, Go tayyor operatsiyalar orasidan bittasini tanlaydi.

Kod tartibi priority sifatida ishlamaydi.

Agar aniq priority kerak bo‘lsa, uni alohida boshqaruv logikasi bilan ifodalash kerak.

### Yopilgan channeldagi `ok` qiymatini tekshirmaslik

Quyidagi qabul qilish:

```go
value := <-ch
```

channel yopilganini o‘zi ko‘rsatmaydi.

Channel yopilib, buffer ham bo‘sh bo‘lsa, `value`ga element turining zero value’i keladi.

Shu sabab yopilish muhim bo‘lgan joyda:

```go
value, ok := <-ch
```

shaklidan foydalanish kerak.

Aks holda zero value haqiqiy ma’lumot deb qabul qilinishi mumkin.

### `default`ni har joyda ishlatish

`default` bloklanishni yo‘q qiladi.

Bu ba’zi vaziyatlarda juda foydali. Lekin uni avtomatik ravishda har bir `select`ga qo‘shish yaxshi fikr emas.

Masalan:

```go
select {
case jobs <- job:
default:
}
```

producerga consumer’ni kutmaslik imkonini beradi.

Bu esa tabiiy backpressure yo‘qolishiga yoki ma’lumotning tashlab yuborilishiga olib kelishi mumkin.

Shuning uchun `default` qo‘shayotganda quyidagi savolni berish kerak:

> Agar channel hozir tayyor bo‘lmasa, bu operatsiyani tashlab yuborish yoki kutmasdan davom etish haqiqatan ham to‘g‘rimi?

### Timeoutdan keyin yuboruvchi goroutineni unutish

Timeout faqat `select` kutishini to‘xtatishi mumkin.

Masalan:

```go
select {
case result := <-results:
	fmt.Println(result)
case <-timer.C:
	fmt.Println("timeout")
}
```

timeout tanlangach, natijani ishlab chiqarayotgan goroutine avtomatik to‘xtamaydi.

U keyinroq:

```go
results <- value
```

qatoriga kelishi mumkin.

Agar channel buffersiz bo‘lsa va boshqa qabul qiluvchi qolmagan bo‘lsa, worker bloklanib qolishi mumkin.

Shu sabab timeoutli kodda worker lifecycle’ini ham o‘ylash kerak.

Ko‘pincha buning uchun:

* bufferli result channel;
* `context.Context`;
* alohida cancellation channel

ishlatiladi.

### Kanalni qabul qiluvchi tomonda yopish

Channelni kim yopishi ham muhim.

Odatda kanalga boshqa qiymat yuborilmasligini aniq biladigan tomon channelni yopadi. Ko‘pincha bu producer, ya’ni yuboruvchi tomon bo‘ladi.

Masalan:

```go
for _, job := range jobs {
	results <- process(job)
}

close(results)
```

Bu yerda producer barcha natijalarni yuborganini biladi. Shu sabab `results`ni qachon yopish mumkinligini ham biladi.

Consumer esa odatda boshqa producer hali yuboradimi yoki yo‘qmi degan ma’lumotga ega bo‘lmasligi mumkin.

Yopilgan channelga yana qiymat yuborilsa, panic yuz beradi.

Shuning uchun channelni yopish ownership’ini aniq belgilash muhim.

## Interviewda muhim nuqtalar

`select` haqida suhbat yoki interviewda quyidagi qoidalarni aniq ayta olish foydali.

* `select` har bajarilganda ko‘pi bilan bitta tayyor `case`ni tanlaydi.

* `default`siz `select`da hech bir operatsiya tayyor bo‘lmasa, joriy goroutine bloklanadi.

* `default` mavjud bo‘lsa va boshqa `case`lar tayyor bo‘lmasa, `default` darhol bajariladi. Shu sabab bunday `select` bloklanmaydi.

* Bir nechta `case` bir vaqtda tayyor bo‘lsa, kodda yuqoriroq yozilgani avtomatik ustun bo‘lmaydi.

* Yopilgan channeldan qabul qilish bloklanmaydi. Buffer tugagach, zero value va `ok == false` olinadi.

* `nil` channel esa yuborish va qabul qilish uchun tayyor bo‘lmaydi. Shu sabab `select` ichida channelni `nil` qilish uning `case`ini vaqtincha o‘chirib qo‘yish usuli sifatida ishlatilishi mumkin.

* `select {}`da hech qanday `case` yoki `default` yo‘q. Shu sabab u joriy goroutineni abadiy bloklaydi.

* Timeout faqat natijani kutishni to‘xtatadi. U ishni bajarayotgan goroutineni avtomatik bekor qilmaydi.

* Agar timeoutdan keyin workerning o‘zini ham to‘xtatish kerak bo‘lsa, `context` yoki alohida cancellation mexanizmi kerak.
