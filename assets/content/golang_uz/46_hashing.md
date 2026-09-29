# Go’da heshlash va Base64 bilan ishlash

Heshlash (hashing) — ixtiyoriy uzunlikdagi ma’lumotdan belgilangan uzunlikdagi xesh qiymat, ya’ni **digest** hosil qilish jarayoni.

Oddiy qilib aytganda, xesh funksiyasi ma’lumotni qabul qiladi va undan qisqa, belgilangan uzunlikdagi qiymat hisoblaydi.

Masalan, xesh quyidagi vazifalarda ishlatiladi:

* yuklab olingan fayl buzilmaganini tekshirish;
* cache uchun kalit yaratish;
* ma’lumot o‘zgargan-o‘zgarmaganini aniqlash;
* xabar yaxlitligini tekshirish;
* HMAC orqali xabarni autentifikatsiya qilish.

Bu yerda bir nechta o‘xshash ko‘rinadigan, lekin maqsadi mutlaqo boshqa tushunchalar bor. Ularni aralashtirmaslik muhim:

* **xesh** — odatda bir tomonlama o‘zgartirish;
* **Base64** — qayta ochiladigan matnli kodlash;
* **shifrlash (`encryption`)** — kalit yordamida qayta ochiladigan himoya;
* **HMAC** — maxfiy kalit yordamida xabarning yaxlitligi va haqiqiyligini tekshirish usuli.

Masalan, Base64 bilan kodlangan ma’lumotni maxfiy deb hisoblash mumkin emas. Uni istalgan kishi dekodlay oladi. Xuddi shuningdek, oddiy SHA-256 digest xabar kim tomonidan yuborilganini isbotlamaydi.

## Xesh funksiyasining asosiy xususiyatlari

Yaxshi kriptografik xesh funksiyasi bir nechta muhim xususiyatga ega.

Birinchidan, bir xil kirish doim bir xil digest beradi.

Masalan:

```text
"salom" -> bir xil digest
"salom" -> yana o‘sha digest
```

Bu xususiyat fayl yoki matn keyinchalik o‘zgargan-o‘zgarmaganini tekshirish imkonini beradi.

Ikkinchidan, kirishdagi juda kichik o‘zgarish digestni keskin o‘zgartiradi. Masalan, faqat bitta harfni katta harfga almashtirish ham mutlaqo boshqa natija berishi mumkin.

Uchinchidan, digestdan dastlabki ma’lumotni tiklash amalda qiyin bo‘lishi kerak. Xesh shifrlash emas, shuning uchun uni "decrypt" qilish uchun kalit mavjud emas.

To‘rtinchidan, turli ikkita kirish uchun bir xil digest topish qiyin bo‘lishi kerak. Bunday holat **kolliziya (`collision`)** deb ataladi.

Masalan:

```text
A ma’lumot -> abc123...
B ma’lumot -> abc123...
```

Agar `A` va `B` turli bo‘lsa-yu, digest bir xil chiqsa, kolliziya yuz bergan bo‘ladi.

Kriptografik xesh algoritmida bunday kolliziyani ataylab yaratish juda qiyin bo‘lishi talab qilinadi.

Digest uzunligi kirish hajmiga bog‘liq emas.

Masalan, SHA-256:

* bo‘sh matn uchun ham;
* `"salom"` kabi qisqa matn uchun ham;
* bir necha gigabaytlik fayl uchun ham

doim 256 bitlik digest beradi.

256 bit:

```text
256 / 8 = 32 bayt
```

degani.

Shuning uchun SHA-256 natijasi har doim 32 bayt bo‘ladi.

> **Diqqat**
>
> Xesh qiymati ma’lumotni yashirmaydi.
>
> Agar kirish qiymatlarini taxmin qilish oson bo‘lsa, hujumchi ehtimoliy qiymatlarni o‘zi xeshlab, digestlar bilan solishtirishi mumkin.
>
> Masalan, parol `"123456"` bo‘lsa, hujumchi keng tarqalgan parollar ro‘yxatini SHA-256 orqali hisoblab chiqishi mumkin. Shu sababli oddiy SHA-256 parollarni saqlash uchun mos emas.

## SHA-256 bilan birinchi misol

Go standart kutubxonasidagi `crypto/sha256` paketi SHA-256 digestini hisoblash imkonini beradi.

Quyidagi misolda `"salom dunyo"` matnining SHA-256 qiymatini hisoblaymiz:

```go
package main

import (
	"crypto/sha256"
	"encoding/hex"
	"fmt"
)

func main() {
	data := []byte("salom dunyo")
	sum := sha256.Sum256(data)

	fmt.Println("Baytlar soni:", len(sum))
	fmt.Println("SHA-256:", hex.EncodeToString(sum[:]))
}
```

Natija:

```text
Baytlar soni: 32
SHA-256: 3d241073bae411a45a85ce25b3415ae1f1b32915a80c7fd9e1b07546526f665c
```

Endi muhim qatorlarni alohida ko‘ramiz.

```go
data := []byte("salom dunyo")
```

SHA-256 matn bilan emas, baytlar bilan ishlaydi. Shu sababli `string` avval `[]byte` ko‘rinishiga o‘tkazildi.

Keyin:

```go
sum := sha256.Sum256(data)
```

`sha256.Sum256()` `[]byte` qabul qiladi va `[32]byte` qiymat qaytaradi.

Bu `slice` emas, balki uzunligi compile time’da ma’lum bo‘lgan massiv:

```go
[32]byte
```

32 bayt aynan SHA-256 digestining 256 bit uzunligidan kelib chiqadi:

```text
256 bit / 8 = 32 bayt
```

Keyingi qatorda:

```go
len(sum)
```

natija `32` bo‘ladi.

Digestning o‘zi binary baytlardan iborat. Uni terminalda o‘qish qulay bo‘lishi uchun ko‘pincha hexadecimal ko‘rinishga o‘tkaziladi:

```go
hex.EncodeToString(sum[:])
```

Bu yerda:

```go
sum[:]
```

`[32]byte` massivdan `[]byte` slice yaratadi.

`hex.EncodeToString()` esa har bir baytni ikkita hexadecimal belgi bilan yozadi.

Masalan, bitta bayt:

```text
255
```

hexadecimal ko‘rinishda:

```text
ff
```

bo‘ladi.

SHA-256 32 bayt bo‘lgani uchun hexadecimal satr uzunligi:

```text
32 × 2 = 64 belgi
```

bo‘ladi.

Shuning uchun SHA-256 digestini hex formatda ko‘rsangiz, odatda 64 ta belgini ko‘rasiz.

Bir xil matnni qayta xeshlasangiz, natija o‘zgarmaydi. Ammo kirishdagi eng kichik farq ham digestni o‘zgartiradi.

Masalan:

```text
salom
Salom
salom 
```

bu uchala matn ko‘zga juda o‘xshash bo‘lsa ham, ularning baytlari bir xil emas. Natijada digestlar ham boshqacha chiqadi.

Unicode bilan ishlaganda ham shu qoida muhim. Ko‘rinishi bir xil bo‘lgan matnlar ba’zan turli Unicode kod nuqtalari orqali ifodalanishi mumkin. Xesh ko‘rinayotgan belgiga emas, aynan baytlar ketma-ketligiga hisoblanadi.

SHA-256 digestini chiqarish uchun `encoding/hex` paketini ishlatish shart emas. `fmt` ham baytlarni hexadecimal formatda ko‘rsata oladi:

```go
sum := sha256.Sum256([]byte("go-lang.uz"))
fmt.Printf("%x\n", sum)
```

Bu yerda:

```text
%x
```

baytlarni kichik harfli hexadecimal formatda chiqaradi.

Bunday usul faqat digestni ko‘rsatish kerak bo‘lganda juda qulay.

Agar hex satrni keyinchalik alohida o‘zgaruvchi sifatida ishlatish kerak bo‘lsa, `hex.EncodeToString()` ko‘proq mos keladi.

## Katta ma’lumotni oqim sifatida heshlash

Kichik matn yoki kichik faylni bir marta `sha256.Sum256()` bilan xeshlash qulay.

Lekin katta fayl bilan ishlaganda uni to‘liq RAMga yuklash yaxshi yondashuv emas.

Masalan, 10 GB faylni quyidagicha o‘qish:

```go
data, err := os.ReadFile("big-file.iso")
```

butun faylni xotiraga olishga urinadi.

Xesh hisoblash uchun esa bunga ehtiyoj yo‘q. Xesh algoritmi ma’lumotni bo‘lakma-bo‘lak qabul qila oladi.

Go’da buning uchun `sha256.New()` ishlatiladi. U `hash.Hash` interfeysini bajaradigan obyekt qaytaradi.

```go
package main

import (
	"crypto/sha256"
	"fmt"
	"io"
	"log"
	"strings"
)

func main() {
	source := strings.NewReader("katta fayldan kelayotgan ma’lumot")
	hasher := sha256.New()

	if _, err := io.Copy(hasher, source); err != nil {
		log.Fatal(err)
	}

	fmt.Printf("%x\n", hasher.Sum(nil))
}
```

Natija 64 belgili SHA-256 digest bo‘ladi:

```text
e66486a5eee0875c1004804c143af03364fb6ca1c550fdffc1bf3f4953f00a1d
```

Bu misolda:

```go
source := strings.NewReader("katta fayldan kelayotgan ma’lumot")
```

`io.Reader` vazifasini bajaradigan manba yaratadi.

Real dasturda bu ko‘pincha fayl bo‘ladi:

```go
file, err := os.Open("big-file.iso")
```

Keyin:

```go
hasher := sha256.New()
```

SHA-256 hisoblaydigan yangi hasher yaratadi.

`sha256.New()` natijasi `hash.Hash` interfeysini bajaradi. `hash.Hash` esa `io.Writer` sifatida ham ishlay oladi.

Shu sababli quyidagi kod mumkin:

```go
io.Copy(hasher, source)
```

`io.Copy()` `source`dan ma’lumotni bo‘laklab o‘qiydi va `hasher`ga yozadi.

Jarayon taxminan quyidagicha ketadi:

```text
source
  ↓
birinchi bo‘lak
  ↓
hasher.Write(...)

source
  ↓
ikkinchi bo‘lak
  ↓
hasher.Write(...)

source
  ↓
keyingi bo‘laklar
  ↓
hasher.Write(...)
```

Hasher har bir bo‘lak kelganida ichki holatini yangilaydi.

Bu yerda muhim jihat bor:

```go
hasher.Write(data)
```

digestni darhol qaytarmaydi.

U faqat hisoblashning ichki holatini yangilaydi.

Oxirida:

```go
hasher.Sum(nil)
```

shu paytgacha yozilgan barcha ma’lumotning digestini qaytaradi.

`Sum(nil)` hasher holatini reset qilmaydi.

Masalan:

```go
hasher.Write([]byte("salom"))
sum1 := hasher.Sum(nil)

hasher.Write([]byte(" dunyo"))
sum2 := hasher.Sum(nil)
```

`sum2` faqat `" dunyo"` uchun emas. U:

```text
"salom dunyo"
```

uchun hisoblangan digest bo‘ladi.

Agar yangi, mustaqil xesh hisoblashni boshlash kerak bo‘lsa, ikki variant bor:

```go
hasher.Reset()
```

yoki yangi hasher yaratish:

```go
hasher = sha256.New()
```

Oqimli usulning asosiy foydasi shundaki, xotira sarfi fayl hajmiga to‘g‘ridan-to‘g‘ri bog‘lanmaydi.

Masalan, 10 GB faylni xeshlash uchun 10 GB RAM kerak emas. Fayl kichik bo‘laklarda o‘qilib, digest bosqichma-bosqich hisoblanadi.

## MD5 va SHA-1 nega xavfsiz emas?

MD5 va SHA-1 eski xesh algoritmlaridir.

MD5:

```text
128 bit = 16 bayt
```

digest beradi.

SHA-1 esa:

```text
160 bit = 20 bayt
```

digest beradi.

Muammo faqat digestning SHA-256’dan qisqaroq ekanida emas. Eng muhim muammo — bu algoritmlar uchun amaliy kolliziya hujumlari mavjud.

Ya’ni hujumchi maxsus tayyorlangan ikki xil fayl uchun bir xil digest hosil qilishi mumkin.

Xavfsizlik tizimi:

```text
digest bir xil -> fayl bir xil
```

degan taxminga tayansa, bunday kolliziya katta muammo tug‘diradi.

Shu sababli MD5 va SHA-1 yangi xavfsizlik yechimlari uchun tavsiya etilmaydi.

MD5 ba’zan legacy tizim bilan moslik yoki xavfsizlikka aloqasi bo‘lmagan eski checksum formatlari uchun uchrashi mumkin.

Go’da MD5 hisoblash texnik jihatdan juda oson:

```go
package main

import (
	"crypto/md5"
	"fmt"
)

func main() {
	sum := md5.Sum([]byte("salom dunyo"))
	fmt.Printf("%x\n", sum)
}
```

Natija:

```text
8f4b0e175285a09d3bff44f0fdec2e0f
```

MD5 natijasi 16 bayt:

```text
128 bit / 8 = 16 bayt
```

Hexadecimal ko‘rinishda har bir bayt ikkita belgiga aylangani uchun:

```text
16 × 2 = 32 belgi
```

chiqadi.

Kod to‘g‘ri ishlaydi. Muammo API’da emas, algoritmning xavfsizlik xususiyatlarida.

MD5’ni quyidagi vazifalar uchun ishlatmang:

* parol saqlash;
* raqamli imzo xavfsizligini tekshirish;
* sertifikat bilan bog‘liq xavfsizlik qarorlari;
* hujumchi o‘zgartira oladigan faylning haqiqiyligini tekshirish.

Agar legacy protokol aynan MD5 talab qilsa, uni ishlatishga to‘g‘ri kelishi mumkin. Lekin bunday holat yangi xavfsizlik dizayni uchun MD5 yaxshi tanlov degani emas.

## Oddiy xesh autentifikatsiya bermaydi

SHA-256 ma’lumot o‘zgarganini aniqlashga yordam beradi.

Masalan, server fayl uchun digest bergan bo‘lsin:

```text
file.zip
SHA-256: abc123...
```

Faylni yuklab olgandan keyin SHA-256 hisoblab, natijani kutilgan digest bilan solishtirish mumkin.

Bu tasodifiy buzilishlarni yaxshi aniqlaydi.

Ammo bu yerda muhim cheklov bor.

Agar hujumchi:

* xabarni o‘zgartira olsa;
* digestni ham o‘zgartira olsa,

u yangi xabar uchun yangi SHA-256 digestni o‘zi hisoblaydi.

Masalan:

```text
asl xabar:
amount=150000

asl digest:
SHA256(amount=150000)
```

Hujumchi ikkalasini ham almashtirishi mumkin:

```text
yangi xabar:
amount=1

yangi digest:
SHA256(amount=1)
```

Qabul qiluvchi oddiy SHA-256 orqali tekshirsa, digest to‘g‘ri chiqadi.

Demak, oddiy xesh xabarning **kim tomonidan yuborilganini** isbotlamaydi.

Buning uchun HMAC ishlatiladi.

HMAC xesh funksiyasi bilan birga faqat ishonchli tomonlar biladigan maxfiy kalitdan foydalanadi.

```go
package main

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/hex"
	"fmt"
)

func sign(message, key []byte) []byte {
	mac := hmac.New(sha256.New, key)
	mac.Write(message)
	return mac.Sum(nil)
}

func main() {
	message := []byte("order_id=42&amount=150000")
	key := []byte("serverdagi-maxfiy-kalit")

	signature := sign(message, key)
	fmt.Println("Imzo:", hex.EncodeToString(signature))
	fmt.Println("Mos:", hmac.Equal(signature, sign(message, key)))
	fmt.Println("O‘zgargan xabar:", hmac.Equal(signature, sign([]byte("order_id=42&amount=1"), key)))
}
```

Natija:

```text
Imzo: 12cc899b0604da2c317e5a83dabe7ea5d0daff236a6c33b3714cd33993ac5ea0
Mos: true
O‘zgargan xabar: false
```

Avval `sign()` funksiyasini ko‘ramiz:

```go
func sign(message, key []byte) []byte {
	mac := hmac.New(sha256.New, key)
	mac.Write(message)
	return mac.Sum(nil)
}
```

Bu yerda:

```go
hmac.New(sha256.New, key)
```

SHA-256 asosida ishlaydigan HMAC yaratadi.

Birinchi argument:

```go
sha256.New
```

xesh funksiyasini yaratadigan funksiya.

Ikkinchi argument:

```go
key
```

maxfiy kalit.

Keyin:

```go
mac.Write(message)
```

imzolanadigan xabarni HMAC hisobiga qo‘shadi.

Oxirida:

```go
mac.Sum(nil)
```

HMAC natijasini qaytaradi.

HMAC’da natija faqat xabarga emas, kalitga ham bog‘liq.

Shuning uchun:

```text
bir xil message + bir xil key -> bir xil HMAC
```

ammo:

```text
boshqa message + bir xil key -> boshqa HMAC
```

va:

```text
bir xil message + boshqa key -> boshqa HMAC
```

bo‘ladi.

Asosiy g‘oya shuki, hujumchi maxfiy kalitni bilmasa, o‘zgartirilgan xabar uchun to‘g‘ri HMAC qiymatini hisoblay olmaydi.

Tekshirishda:

```go
hmac.Equal(signature, calculatedSignature)
```

ishlatiladi.

Misolda:

```go
hmac.Equal(signature, sign(message, key))
```

`true` qaytaradi, chunki xabar ham, kalit ham o‘sha-o‘sha.

Lekin:

```go
hmac.Equal(
	signature,
	sign([]byte("order_id=42&amount=1"), key),
)
```

`false` qaytaradi, chunki xabar o‘zgargan.

Nega oddiy `==` yoki oddiy satr solishtirish ishlatilmaydi?

Xavfsizlikka tegishli qiymatlarni solishtirishda bajarilish vaqti orqali ma’lumot sizib chiqishi mumkin. `hmac.Equal()` shunday tekshiruv uchun maxsus yozilgan.

Shu sababli HMAC imzosini tekshirishda:

```go
hmac.Equal(a, b)
```

ishlatish kerak.

Oddiy:

```go
a == b
```

yoki hex satrlar uchun `==` ishlatish xavfsizlik nuqtai nazaridan yaxshi amaliyot emas.

Misolda maxfiy kalit kod ichiga yozilgan:

```go
key := []byte("serverdagi-maxfiy-kalit")
```

Bu faqat tushuntirish uchun.

Real production loyihada secretni source code ichida saqlamang.

Kalit odatda:

* environment variable;
* secret manager;
* container secret;
* Kubernetes Secret;
* boshqa himoyalangan konfiguratsiya

orqali olinadi.

## Base64 xesh emas

Base64 ko‘pincha xavfsizlik mavzulari yonida uchragani uchun uni xesh yoki shifrlash bilan adashtirish oson.

Aslida Base64 — **kodlash (`encoding`)** usuli.

U binary ma’lumotni faqat matnli belgilar yordamida ifodalaydi.

Masalan, binary ma’lumotni:

* JSON;
* XML;
* email;
* URL;
* boshqa matnli protokol

ichida tashish kerak bo‘lsa, Base64 foydali bo‘lishi mumkin.

Lekin Base64 hech qanday maxfiylik bermaydi.

Kodlangan ma’lumotni istalgan kishi qayta dekodlay oladi.

Quyidagi misolda matnni avval Base64 orqali kodlaymiz, keyin yana tiklaymiz:

```go
package main

import (
	"encoding/base64"
	"fmt"
)

func main() {
	data := []byte("salom dunyo")
	encoded := base64.StdEncoding.EncodeToString(data)

	decoded, err := base64.StdEncoding.DecodeString(encoded)
	if err != nil {
		fmt.Println("Decode xatosi:", err)
		return
	}

	fmt.Println("Kodlangan:", encoded)
	fmt.Println("Tiklangan:", string(decoded))
}
```

Natija:

```text
Kodlangan: c2Fsb20gZHVueW8=
Tiklangan: salom dunyo
```

Kodlash qatori:

```go
encoded := base64.StdEncoding.EncodeToString(data)
```

`data` ichidagi baytlarni Base64 matniga aylantiradi.

Natija:

```text
c2Fsb20gZHVueW8=
```

Bu qiymat shifrlanmagan. Uni dekodlash uchun maxfiy kalit kerak emas.

Keyingi qator:

```go
decoded, err := base64.StdEncoding.DecodeString(encoded)
```

Base64 satrni yana asl baytlarga qaytaradi.

Agar satr noto‘g‘ri Base64 formatida bo‘lsa, `DecodeString()` xato qaytaradi.

Masalan, noto‘g‘ri belgi yoki noto‘g‘ri padding bo‘lsa:

```go
decoded, err := base64.StdEncoding.DecodeString("###")
```

`err` `nil` bo‘lmaydi.

Base64 ma’lumot hajmini ham biroz oshiradi.

Asosiy qoida:

```text
3 bayt -> 4 ta Base64 belgi
```

Masalan:

```text
24 bit kirish
↓
4 × 6 bit
↓
4 ta Base64 belgi
```

Shuning uchun natija odatda asl ma’lumotdan taxminan uchdan birga katta bo‘ladi.

Aniqrog‘i, uzunlik odatda 4 baytlik bloklarga yaxlitlanadi.

Base64 oxirida ko‘rinadigan:

```text
=
```

belgisi **padding**, ya’ni to‘ldiruvchi belgi hisoblanadi.

U oxirgi blokda 3 bayt to‘liq bo‘lmaganini ko‘rsatishga yordam beradi.

## Standard va URL-safe Base64

Base64’ning bir nechta variantlari mavjud.

Go’da eng ko‘p ishlatiladiganlari:

```go
base64.StdEncoding
base64.URLEncoding
base64.RawURLEncoding
```

Ularning farqi ayniqsa URL ichida muhim.

Standard Base64 alifbosida:

```text
+
/
```

belgilari mavjud.

URL ichida esa bu belgilar alohida ma’noga ega bo‘lishi yoki qo‘shimcha escaping talab qilishi mumkin.

Shuning uchun URL-safe variant:

```text
+ -> -
/ -> _
```

almashtirishdan foydalanadi.

Quyidagi misol farqni ko‘rsatadi:

```go
package main

import (
	"encoding/base64"
	"fmt"
)

func main() {
	data := []byte{251, 255, 239}

	fmt.Println(base64.StdEncoding.EncodeToString(data))
	fmt.Println(base64.RawURLEncoding.EncodeToString(data))
}
```

Natija:

```text
+//v
-__v
```

Birinchi natija:

```text
+//v
```

`StdEncoding` orqali hosil bo‘lgan.

Ikkinchi natija:

```text
-__v
```

`RawURLEncoding` orqali hosil bo‘lgan.

Bu yerda:

```text
+ -> -
/ -> _
```

almashtirilgan.

`RawURLEncoding` nomidagi `Raw` esa padding ishlatilmasligini bildiradi.

Masalan, oddiy URL-safe variant:

```go
base64.URLEncoding
```

padding bilan ishlashi mumkin.

Raw variant:

```go
base64.RawURLEncoding
```

esa oxiridagi `=` padding belgilarini yozmaydi.

URL tokenlari, JWT qismlari yoki fayl nomiga mos qiymatlarda raw URL-safe format ko‘p uchraydi.

Encode va decode vaqtida bir xil variantni ishlatish muhim.

Masalan, qiymat:

```go
base64.RawURLEncoding.EncodeToString(data)
```

bilan yaratilgan bo‘lsa, uni odatda:

```go
base64.RawURLEncoding.DecodeString(value)
```

bilan ochish kerak.

Boshqa encoding ishlatilsa, alifbo yoki padding qoidasi mos kelmasligi mumkin va `DecodeString()` xato qaytaradi.

## Parollarni qanday saqlash kerak?

SHA-256 va SHA-512 kuchli kriptografik xesh algoritmlaridir.

Lekin bu ularni parol saqlash uchun avtomatik ravishda yaxshi qiladi degani emas.

Muammo shundaki, SHA-256 juda tez ishlaydi.

Fayl yaxlitligini tekshirishda bu afzallik:

```text
ko‘p ma’lumot -> tez digest
```

Ammo parol uchun aynan shu tezlik xavf tug‘diradi.

Agar database’dan parol xeshlari sizib chiqsa, hujumchi millionlab yoki milliardlab ehtimoliy parollarni tez tekshirishga urinishi mumkin.

Masalan:

```text
123456
password
qwerty
admin
...
```

Har bir taxmin uchun SHA-256 hisoblash juda arzon.

Shu sababli parol uchun maxsus **password hashing** algoritmlari ishlatiladi.

Keng tarqalgan variantlar:

* Argon2id;
* scrypt;
* bcrypt;
* tashkilot yoki standart talabi bo‘lsa, PBKDF2.

Bu algoritmlar ataylab sekinroq va resurs talab qiladigan qilib yaratilgan.

Maqsad loginni sekinlashtirish emas. Maqsad hujumchining juda ko‘p taxminni tekshirish xarajatini oshirish.

Password hashing odatda **salt** bilan ham ishlaydi.

Salt — har bir parol uchun yaratiladigan alohida tasodifiy qiymat.

Masalan, ikkita foydalanuvchining paroli bir xil bo‘lsin:

```text
foydalanuvchi A: secret123
foydalanuvchi B: secret123
```

Agar salt ishlatilmasa:

```text
hash(secret123) == hash(secret123)
```

bo‘ladi.

Database sizib chiqsa, bir xil digestlar foydalanuvchilarda bir xil parol bo‘lishi mumkinligini ko‘rsatadi.

Salt bilan esa:

```text
hash(secret123 + saltA)
hash(secret123 + saltB)
```

turli natija beradi.

Muhim nuqta: salt maxfiy bo‘lishi shart emas.

U odatda password hash bilan birga database’da saqlanadi.

Saltning vazifasi:

* bir xil parollarni bir xil digestga aylantirmaslik;
* oldindan hisoblangan katta hash jadvallarining foydasini kamaytirish.

Argon2id, scrypt, bcrypt kabi algoritmlar bundan tashqari **cost**, ya’ni hisoblash xarajatini boshqaradigan parametrga ham ega.

Masalan, server kuchliroq bo‘lsa, algoritmni qimmatroq qilib sozlash mumkin.

Go ekotizimida ushbu algoritmlarning amaliy implementatsiyalari `golang.org/x/crypto` modulida mavjud.

Algoritm va parametrlarni tanlashda:

* xavfsizlik talabi;
* server CPU imkoniyati;
* xotira;
* login trafik hajmi;
* amaldagi xavfsizlik tavsiyalari

hisobga olinadi.

Quyidagi kabi qo‘lbola sxema yaratmang:

```text
SHA-256(password + salt)
```

Salt qo‘shilgan bo‘lsa ham, SHA-256 baribir juda tez algoritm bo‘lib qoladi.

Password hashing uchun aynan shu vazifa uchun yaratilgan algoritmni ishlatish kerak.

## Fayl checksumini tekshirish

SHA-256 faylning buzilmaganini tekshirish uchun juda foydali.

Masalan, dastur distributivini yuklab olayotgan bo‘lsangiz, rasmiy sayt quyidagicha digest berishi mumkin:

```text
SHA256:
6b7e...
```

Siz yuklab olingan fayl uchun SHA-256 hisoblab, kutilgan qiymat bilan solishtirasiz.

Agar digestlar bir xil bo‘lsa, fayl baytlari kutilgan faylga mos kelish ehtimoli juda yuqori.

Lekin bu yerda digestning **qayerdan olingani** muhim.

Agar fayl ham, digest ham bir xil ishonchsiz serverdan olinayotgan bo‘lsa, hujumchi ikkalasini ham almashtirishi mumkin.

Masalan:

```text
asl fayl      -> zararli fayl
asl SHA-256   -> zararli faylning yangi SHA-256 qiymati
```

Siz tekshirganingizda digest mos chiqadi, chunki hujumchi uni ham yangilagan.

Shu sababli checksum xavfsizlik uchun foydali bo‘lishi uchun kutilgan digest ishonchli manbadan olinishi kerak.

Masalan:

* ishonchli HTTPS sahifasi;
* imzolangan release manifest;
* alohida tekshirilgan manba.

Digest matnini solishtirishdan oldin uning formatini tekshirish ham foydali.

SHA-256 digest:

```text
32 bayt
```

va hexadecimal formatda:

```text
64 belgi
```

bo‘lishi kerak.

Masalan, tashqi manbadan kelgan qiymat:

```text
ABCDEF...
```

yoki:

```text
abcdef...
```

ko‘rinishida bo‘lishi mumkin.

Hexadecimal raqamlarda katta-kichik harf qiymatni o‘zgartirmaydi.

Shuning uchun satrlarni oddiy string sifatida solishtirishdan ko‘ra, kutilgan digestni avval baytlarga dekodlash mumkin:

```go
expected, err := hex.DecodeString(expectedHex)
```

Keyin 32 bayt ekanini tekshirish mumkin:

```go
if len(expected) != sha256.Size {
	// noto‘g‘ri SHA-256 uzunligi
}
```

`sha256.Size` qiymati:

```text
32
```

ga teng.

Shundan keyin hisoblangan digest bilan baytlar ko‘rinishida solishtirish mumkin.

Bu usul format masalalarini aniqroq boshqarishga yordam beradi.

## Keng tarqalgan xatolar

### Base64’ni shifrlash deb hisoblash

Base64 ma’lumotni yashirmaydi.

Masalan:

```text
c2Fsb20gZHVueW8=
```

ko‘zga tushunarsiz ko‘rinishi mumkin. Lekin uni dekodlash uchun hech qanday secret yoki kalit kerak emas.

Bu qiymat oddiy Base64 decoder yordamida:

```text
salom dunyo
```

ga qaytariladi.

Shuning uchun Base64’ni maxfiy ma’lumotni himoyalash uchun ishlatmang.

### Parolga oddiy SHA-256 qo‘llash

SHA-256 kuchli xesh funksiyasi, ammo parol uchun juda tez.

Hujumchi juda ko‘p parol taxminini qisqa vaqtda tekshirishi mumkin.

Parol uchun:

* Argon2id;
* scrypt;
* bcrypt;
* kerakli holatda PBKDF2

kabi password hashing algoritmini tanlang.

### MD5 yoki SHA-1’ni xavfsizlik qarori uchun ishlatish

MD5 va SHA-1 uchun amaliy kolliziya hujumlari ma’lum.

Shu sababli hujumchi boshqarishi mumkin bo‘lgan ma’lumotning xavfsizligini tekshirish uchun bu algoritmlarga tayanmang.

Legacy moslik boshqa masala. Lekin yangi xavfsizlik dizaynida zamonaviy algoritm ishlatilishi kerak.

### Xabar autentifikatsiyasi uchun qo‘lbola sxema yaratish

Ba’zan quyidagicha kod uchraydi:

```text
SHA-256(key || message)
```

yoki:

```text
SHA-256(message || key)
```

Bu HMAC o‘rnini bosadigan standart sxema emas.

Kriptografik konstruksiyalarni qo‘lda yaratish nozik xatolarga olib kelishi mumkin.

Xabar autentifikatsiyasi uchun standart HMAC ishlating:

```go
hmac.New(sha256.New, key)
```

### Katta faylni to‘liq RAMga olish

Quyidagi kod kichik fayllar uchun qulay:

```go
data, err := os.ReadFile(path)
```

Lekin juda katta faylda bu butun faylni RAMga yuklaydi.

Xesh hisoblashda bunga ehtiyoj yo‘q.

Buning o‘rniga:

```go
file, err := os.Open(path)
```

va:

```go
io.Copy(hasher, file)
```

kabi oqimli yondashuv ishlating.

### Xavfsizlik imzosini oddiy `==` bilan solishtirish

HMAC kabi xavfsizlik qiymatlarini tekshirishda:

```go
hmac.Equal(a, b)
```

ishlatish kerak.

Bu funksiya aynan MAC qiymatlarini xavfsiz solishtirish uchun mo‘ljallangan.

### Ko‘rinishi bir xil matnning baytlari ham bir xil deb o‘ylash

Xesh belgilar tasviriga emas, baytlarga hisoblanadi.

Masalan, Unicode’da foydalanuvchiga bir xil ko‘rinadigan matn turli kod nuqtalari ketma-ketligi bilan ifodalanishi mumkin.

Shu sababli protokolda matn qanday kodlanishi va kerak bo‘lsa Unicode normalizatsiyasi qanday bajarilishi aniq belgilanishi kerak.

Aks holda ikki tizim ko‘rinishda bir xil matn uchun turli digest hisoblab qo‘yishi mumkin.

## Interviewda nimalarga e’tibor beriladi?

Interviewda faqat `sha256.Sum256()` sintaksisini bilish yetarli bo‘lmasligi mumkin. Odatda tushunchalar orasidagi farqni to‘g‘ri ajrata olish muhim.

### Xesh, kodlash, shifrlash va HMAC farqi

Quyidagilarni aniq ajratish kerak:

```text
Hash:
ma’lumot -> digest
odatda orqaga qaytarilmaydi

Base64:
ma’lumot -> matnli kodlash
oson dekodlanadi

Encryption:
ma’lumot + kalit -> ciphertext
kalit bilan qayta ochiladi

HMAC:
xabar + maxfiy kalit -> autentifikatsiya kodi
```

Base64’ni encryption deb aytish texnik xato bo‘ladi.

### Kolliziya va preimage tushunchalari

**Kolliziya** — turli ikkita kirish uchun bir xil digest topilishi:

```text
hash(A) == hash(B)
A != B
```

**Preimage** muammosi esa berilgan digestga mos kirishni topish bilan bog‘liq:

```text
digest berilgan
↓
unga mos input topish
```

Kriptografik xesh funksiyasida bunday hisoblashlar amalda juda qiyin bo‘lishi kerak.

### Digest uzunligi kirishga bog‘liq emas

SHA-256 uchun:

```text
1 bayt input -> 32 bayt digest
1 MB input   -> 32 bayt digest
10 GB input  -> 32 bayt digest
```

Digest hajmi kirish hajmiga qarab o‘smaydi.

### SHA-256 nega parol uchun mos emas?

Sabab SHA-256 zaif algoritm ekanida emas.

Sabab uning **juda tez** ishlashida.

Fayl xeshlashda tezlik foydali. Parol taxminlarini tekshirishda esa hujumchiga ham foyda beradi.

Shu sababli password hashing algoritmlari ataylab qimmatroq ishlaydi.

### `sha256.Sum256()` va `sha256.New()` farqi

`sha256.Sum256()` bir martalik hisoblash uchun qulay:

```go
sum := sha256.Sum256(data)
```

U:

```go
[32]byte
```

qaytaradi.

`sha256.New()` esa oqimli hisoblash uchun ishlatiladi:

```go
h := sha256.New()
```

U `hash.Hash` interfeysini bajaradigan obyekt qaytaradi.

Keyin unga ma’lumot bo‘laklab yoziladi:

```go
h.Write(part1)
h.Write(part2)
h.Write(part3)
```

Oxirida:

```go
sum := h.Sum(nil)
```

orqali digest olinadi.

### Base64 hajmi

Base64’da:

```text
3 bayt -> 4 ta belgi
```

qoidasi ishlaydi.

Shuning uchun natija odatda originaldan taxminan 33% kattaroq bo‘ladi.

Padding sabab aniq uzunlik 4 belgilik bloklarga to‘ldiriladi.

### Base64 variantlari

Asosiy variantlar:

```go
base64.StdEncoding
base64.URLEncoding
base64.RawURLEncoding
```

`StdEncoding`:

```text
+
/
```

belgilaridan foydalanadi.

`URLEncoding`:

```text
-
_
```

belgilaridan foydalanadi.

`RawURLEncoding` ham URL-safe, lekin padding yozmaydi.

### HMAC’da `hmac.Equal()` ishlatilish sababi

HMAC imzosini tekshirganda:

```go
hmac.Equal(expected, actual)
```

ishlatish kerak.

Bu MAC qiymatlarini xavfsiz solishtirish uchun maxsus funksiya.

Oddiy satr yoki baytlarni `==` orqali solishtirish o‘rniga HMAC uchun shu API’dan foydalanish to‘g‘ri amaliyot hisoblanadi.
