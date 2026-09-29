# Go’da kataloglar bilan ishlash

Katalog — fayl va boshqa kataloglarni guruhlab saqlaydigan fayl tizimi obyektidir. Go dasturlarida kataloglar konfiguratsiya fayllari, loglar, cache, foydalanuvchi yuklagan fayllar va vaqtinchalik ma’lumotlarni tartibli saqlash uchun ko‘p ishlatiladi.

Lekin katalog bilan ishlash faqat yangi papka yaratishdan iborat emas. Real dastur bir nechta muhim holatni hisobga olishi kerak:

* Linux, macOS va Windows’dagi fayl yo‘llari bir xil ko‘rinishda emas;
* katalog va fayllarning ruxsatlari operatsion tizimga qarab farq qiladi;
* symbolic link oddiy katalog yoki fayldan boshqacha ishlaydi;
* tashqaridan kelgan yo‘l xavfli bo‘lishi mumkin;
* rekursiv o‘chirish noto‘g‘ri yo‘l bilan chaqirilsa, ko‘p ma’lumotni yo‘qotish mumkin.

Go standart kutubxonasida kataloglar bilan ishlash uchun asosan `os` va `path/filepath` paketlari ishlatiladi.

`os` paketi katalog yaratish, o‘qish, o‘chirish va nomini o‘zgartirish kabi fayl tizimi amallarini bajaradi. `path/filepath` esa lokal operatsion tizimga mos fayl yo‘llarini yaratish va tahlil qilishga yordam beradi.

## Fayl yo‘li qanday tuziladi?

Fayl yo‘li, ya’ni **path**, fayl yoki katalogning fayl tizimidagi manzilini bildiradi.

Yo‘l ikki xil bo‘lishi mumkin:

* **mutlaq yo‘l — absolute path**;
* **nisbiy yo‘l — relative path**.

Mutlaq yo‘l fayl tizimining aniq joyini bildiradi.

Unix oilasidagi tizimlarda u odatda `/` ildizidan boshlanadi:

```text
/home/user/project/data.json
```

Windows’da esa masalan disk harfi bilan boshlanishi mumkin:

```text
C:\Users\user\project\data.json
```

Nisbiy yo‘l esa joriy ish katalogiga nisbatan hisoblanadi:

```text
data/reports/daily.json
```

Bu yerda muhim bir farq bor. **Joriy ish katalogi executable fayl joylashgan katalog degani emas.**

Masalan, executable `/usr/local/bin/app` ichida joylashgan bo‘lishi mumkin. Lekin uni `/home/user/project` katalogidan ishga tushirsangiz, nisbiy yo‘llar odatda `/home/user/project`ga nisbatan hisoblanadi.

Joriy ish katalogini `os.Getwd()` orqali olish mumkin.

Yo‘l qismlarini `"/"` yoki `"\\"` separatorlari bilan qo‘lda birlashtirish tavsiya etilmaydi. Buning o‘rniga `filepath.Join` ishlatiladi. U joriy operatsion tizimga mos separatorni tanlaydi va ortiqcha separatorlarni ham tozalaydi.

```go
package main

import (
	"fmt"
	"os"
	"path/filepath"
)

func main() {
	path := filepath.Join("data", "reports", "daily.json")
	absPath, err := filepath.Abs(path)
	if err != nil {
		fmt.Println("mutlaq yo‘lni olish:", err)
		return
	}

	fmt.Println("fayl nomi:", filepath.Base(path))
	fmt.Println("katalog:", filepath.Dir(path))
	fmt.Println("kengaytma:", filepath.Ext(path))
	fmt.Println("mutlaq yo‘l:", absPath)
	fmt.Println("mutlaqmi:", filepath.IsAbs(absPath))
	fmt.Println("separator:", string(os.PathSeparator))
}
```

Endi koddagi funksiyalarni alohida ko‘rib chiqamiz.

```go
path := filepath.Join("data", "reports", "daily.json")
```

`filepath.Join` berilgan yo‘l qismlarini operatsion tizimga mos ko‘rinishda birlashtiradi.

Unix tizimida natija taxminan:

```text
data/reports/daily.json
```

Windows’da esa:

```text
data\reports\daily.json
```

ko‘rinishida bo‘lishi mumkin.

Keyingi qator:

```go
absPath, err := filepath.Abs(path)
```

nisbiy yo‘lni mutlaq yo‘lga aylantiradi.

Masalan, dastur `/home/farrux/project` ichida ishga tushirilgan bo‘lsa:

```text
data/reports/daily.json
```

quyidagiga o‘xshash mutlaq yo‘lga aylanishi mumkin:

```text
/home/farrux/project/data/reports/daily.json
```

`filepath.Base(path)` yo‘lning oxirgi qismini qaytaradi:

```text
daily.json
```

`filepath.Dir(path)` esa uning ota katalogini qaytaradi:

```text
data/reports
```

`filepath.Ext(path)` oxirgi fayl kengaytmasini qaytaradi:

```text
.json
```

`filepath.IsAbs(absPath)` yo‘l mutlaq yoki nisbiy ekanini tekshiradi.

`os.PathSeparator` esa joriy operatsion tizim ishlatadigan katalog separatorini beradi.

Mutlaq yo‘l va separatorning aniq qiymati dasturni qaysi operatsion tizimda va qaysi katalogdan ishga tushirganingizga bog‘liq. Shu sabab bu misolning to‘liq chiqishi barcha platformalarda bir xil bo‘lmaydi.

> **Ma'lumot**
>
> `path/filepath` lokal fayl tizimi yo‘llari uchun ishlatiladi.
>
> URL ichidagi yo‘llar esa boshqa qoidaga ega. URL yo‘llarida separator doim `/` bo‘ladi. Ular uchun `path` yoki `net/url` paketidan foydalanish kerak.
>
> Masalan, Windows fayl yo‘lini URL deb qabul qilish yoki URL yo‘lini `filepath.Join` bilan yig‘ish noto‘g‘ri natijaga olib kelishi mumkin.

## Bitta katalog yaratish

Bitta katalog yaratish uchun `os.Mkdir` ishlatiladi.

Muhim qoida: `os.Mkdir` faqat ko‘rsatilgan katalogning o‘zini yaratadi. Uning ota katalogi oldindan mavjud bo‘lishi kerak.

Masalan:

```go
package main

import (
	"errors"
	"fmt"
	"os"
)

func main() {
	err := os.Mkdir("katalog", 0o755)
	switch {
	case err == nil:
		fmt.Println("katalog yaratildi")
	case errors.Is(err, os.ErrExist):
		fmt.Println("katalog avvaldan mavjud")
	default:
		fmt.Println("katalog yaratilmadi:", err)
	}
}
```

Bu kod joriy ish katalogi ichida `katalog` nomli yangi katalog yaratishga urinadi.

```go
os.Mkdir("katalog", 0o755)
```

Bu yerda:

* `"katalog"` — yaratiladigan katalog yo‘li;
* `0o755` — ruxsat biti.

`0o755` sakkizlik sanoq sistemasida yozilgan permission qiymatidir.

Unix oilasidagi tizimlarda u odatda quyidagicha talqin qilinadi:

```text
egasi:      rwx
guruh:      r-x
boshqalar:  r-x
```

Katalog uchun `x`, ya’ni bajarish biti faylni ishga tushirish degani emas.

Katalogdagi `x` biti uning ichidagi nomlarga murojaat qilishga imkon beradi. Masalan, katalog ichidagi faylga kirish yoki ichki katalogga o‘tish uchun `x` ruxsati kerak bo‘ladi.

`r` biti esa katalog ichidagi nomlar ro‘yxatini o‘qishga yordam beradi.

Shu sabab katalog permissionlarini fayl permissionlari bilan aynan bir xil ma’noda tushunish noto‘g‘ri.

Yana bir muhim jihat: `0o755` har doim aynan `755` permission bilan katalog yaratilishini kafolatlamaydi. Unix tizimlarida jarayonning `umask` qiymati yakuniy permissionga ta’sir qilishi mumkin.

Windows’dagi permission modeli esa Unix’dan farq qiladi. Shu sabab Unix permission bitlari u yerda aynan bir xil ma’noda ishlamasligi mumkin.

Koddagi:

```go
errors.Is(err, os.ErrExist)
```

tekshiruvi yo‘l allaqachon mavjudligini aniqlaydi.

Lekin bu tekshiruvdan:

> “demak, bu yo‘lda katalog bor”

degan xulosa chiqarib bo‘lmaydi.

Masalan, `katalog` nomli oddiy fayl mavjud bo‘lsa ham `os.Mkdir` xato qaytaradi va u `os.ErrExist` bilan mos kelishi mumkin.

Agar mavjud obyekt aynan katalog ekanini bilish muhim bo‘lsa, `os.Stat` va `IsDir()` orqali alohida tekshirish kerak.

## Ichma-ich kataloglar yaratish

Bir nechta ichma-ich katalogni yaratish uchun `os.MkdirAll` qulayroq.

Masalan, quyidagi yo‘lni yaratmoqchimiz:

```text
cache/images/thumbnails
```

Agar `cache` va `images` hali mavjud bo‘lmasa, oddiy `os.Mkdir` bilan barcha bosqichlarni alohida yaratishga to‘g‘ri keladi.

`os.MkdirAll` esa yetishmayotgan ota kataloglarni ham o‘zi yaratadi.

```go
package main

import (
	"fmt"
	"os"
	"path/filepath"
)

func main() {
	dir := filepath.Join(os.TempDir(), "go-katalog-darsi", "cache", "images")
	if err := os.MkdirAll(dir, 0o755); err != nil {
		fmt.Println("kataloglarni yaratish:", err)
		return
	}
	defer os.RemoveAll(filepath.Join(os.TempDir(), "go-katalog-darsi"))

	fmt.Println("oxirgi katalog:", filepath.Base(dir))
}
```

Natija:

```text
oxirgi katalog: images
```

Avval:

```go
os.TempDir()
```

operatsion tizimning standart vaqtinchalik katalogini beradi.

Keyin:

```go
filepath.Join(
	os.TempDir(),
	"go-katalog-darsi",
	"cache",
	"images",
)
```

yo‘l qismlarini birlashtiradi.

Natijada taxminan quyidagiga o‘xshash yo‘l hosil bo‘lishi mumkin:

```text
/tmp/go-katalog-darsi/cache/images
```

Windows’da esa boshqa vaqtinchalik katalog ishlatilishi mumkin.

Keyingi qator:

```go
os.MkdirAll(dir, 0o755)
```

yo‘ldagi mavjud bo‘lmagan barcha kataloglarni yaratadi.

Masalan:

```text
go-katalog-darsi
go-katalog-darsi/cache
go-katalog-darsi/cache/images
```

kataloglari yo‘q bo‘lsa, uchalasi ham yaratiladi.

`MkdirAll`ning yana bir qulay xususiyati bor: kataloglar allaqachon mavjud bo‘lsa, u faqat shu sababli xato qaytarmaydi.

Shu sabab quyidagicha kodni bir necha marta chaqirish odatda muammo tug‘dirmaydi:

```go
os.MkdirAll(dir, 0o755)
```

Bir xil amalni qayta bajarish natijani buzmasa, bunday xususiyat **idempotent** deb ataladi.

Misoldagi:

```go
defer os.RemoveAll(filepath.Join(os.TempDir(), "go-katalog-darsi"))
```

qatori dastur tugayotganida namuna uchun yaratilgan katalog daraxtini o‘chiradi.

Bu test yoki o‘quv misolida qulay.

Lekin real dasturdagi doimiy ma’lumotlar uchun bunday kodni ko‘r-ko‘rona ishlatish mumkin emas. `os.RemoveAll` butun katalog daraxtini o‘chirishi mumkin.

## Katalog tarkibini o‘qish

Katalog ichidagi fayl va ichki kataloglar ro‘yxatini olish uchun `os.ReadDir` ishlatiladi.

`os.ReadDir` faqat ko‘rsatilgan katalogning **bevosita ichidagi** yozuvlarni qaytaradi. U ichki kataloglarning ichiga avtomatik kirmaydi.

Masalan:

```text
root/
├── config.json
└── images/
    └── logo.png
```

`os.ReadDir(root)` chaqirilsa:

```text
config.json
images
```

qaytadi.

Lekin `images/logo.png` avtomatik qaytmaydi.

```go
package main

import (
	"fmt"
	"os"
	"path/filepath"
)

func main() {
	root, err := os.MkdirTemp("", "read-dir-*")
	if err != nil {
		fmt.Println("vaqtinchalik katalog yaratish:", err)
		return
	}
	defer os.RemoveAll(root)

	if err := os.Mkdir(filepath.Join(root, "images"), 0o755); err != nil {
		fmt.Println("ichki katalog yaratish:", err)
		return
	}
	if err := os.WriteFile(filepath.Join(root, "config.json"), []byte("{}\n"), 0o644); err != nil {
		fmt.Println("fayl yaratish:", err)
		return
	}

	entries, err := os.ReadDir(root)
	if err != nil {
		fmt.Println("katalogni o‘qish:", err)
		return
	}

	for _, entry := range entries {
		kind := "FILE"
		if entry.IsDir() {
			kind = "DIR"
		}
		fmt.Printf("[%s] %s\n", kind, entry.Name())
	}
}
```

Natija:

```text
[FILE] config.json
[DIR] images
```

Birinchi qism:

```go
root, err := os.MkdirTemp("", "read-dir-*")
```

vaqtinchalik katalog yaratadi.

Keyin uning ichida:

```go
images
```

katalogi va:

```text
config.json
```

fayli yaratiladi.

Shundan so‘ng:

```go
entries, err := os.ReadDir(root)
```

katalog ichidagi yozuvlarni o‘qiydi.

`os.ReadDir` natijani nom bo‘yicha tartiblangan holda qaytaradi.

Har bir element `os.DirEntry` qiymati bo‘ladi.

`DirEntry` orqali, masalan:

```go
entry.Name()
```

yozuv nomini olish mumkin.

```go
entry.IsDir()
```

esa u katalog yoki katalog emasligini aniqlaydi.

`os.DirEntry` ataylab nisbatan yengil ma’lumot beradi. Agar fayl hajmi, modification time yoki boshqa to‘liq metadata kerak bo‘lsa:

```go
info, err := entry.Info()
```

chaqirish mumkin.

Lekin `Info()` qo‘shimcha fayl tizimi amalini bajarishi mumkin va u xato ham qaytarishi mumkin. Shu sabab faqat kerak bo‘lganda chaqirish foydali.

Yana bir muhim jihat bor.

`os.ReadDir` katalogdagi barcha yozuvlarni slice ko‘rinishida xotiraga oladi.

Oddiy kataloglarda bu muammo emas. Ammo katalogda millionlab yozuv bo‘lsa, barchasini birdan xotiraga olish qimmatga tushishi mumkin.

Bunday holatda katalogni:

```go
file, err := os.Open(path)
```

orqali ochib, keyin:

```go
file.ReadDir(n)
```

bilan qismlarga bo‘lib o‘qish mumkin.

Masalan, har safar 1000 ta yozuv o‘qish xotira sarfini cheklashga yordam beradi.

Katalog `os.Open` bilan ochilganda `*os.File` qaytadi. Uni ishlatib bo‘lgach yopish kerak:

```go
defer file.Close()
```

## Katalog daraxti bo‘ylab yurish

Ba’zan faqat bitta katalog darajasini emas, uning ichidagi barcha katalog va fayllarni ko‘rish kerak bo‘ladi.

Buning uchun `filepath.WalkDir` ishlatiladi.

Masalan, quyidagi daraxt bor deb olaylik:

```text
root/
└── docs/
    └── readme.txt
```

`WalkDir`:

1. `root`;
2. `root/docs`;
3. `root/docs/readme.txt`

yo‘llari bo‘ylab yurishi mumkin.

```go
package main

import (
	"fmt"
	"io/fs"
	"os"
	"path/filepath"
)

func main() {
	root, err := os.MkdirTemp("", "walk-dir-*")
	if err != nil {
		fmt.Println("vaqtinchalik katalog yaratish:", err)
		return
	}
	defer os.RemoveAll(root)

	docs := filepath.Join(root, "docs")
	if err := os.Mkdir(docs, 0o755); err != nil {
		fmt.Println("katalog yaratish:", err)
		return
	}
	if err := os.WriteFile(filepath.Join(docs, "readme.txt"), []byte("Salom\n"), 0o644); err != nil {
		fmt.Println("fayl yaratish:", err)
		return
	}

	err = filepath.WalkDir(root, func(path string, entry fs.DirEntry, walkErr error) error {
		if walkErr != nil {
			return walkErr
		}

		rel, err := filepath.Rel(root, path)
		if err != nil {
			return err
		}
		kind := "FILE"
		if entry.IsDir() {
			kind = "DIR"
		}
		fmt.Printf("[%s] %s\n", kind, rel)
		return nil
	})
	if err != nil {
		fmt.Println("katalog bo‘ylab yurish:", err)
	}
}
```

Unix tizimida natija taxminan quyidagicha ko‘rinadi:

```text
[DIR] .
[DIR] docs
[FILE] docs/readme.txt
```

Windows’da oxirgi yo‘l:

```text
docs\readme.txt
```

ko‘rinishida chiqishi mumkin.

`WalkDir`ga callback funksiya beriladi:

```go
func(path string, entry fs.DirEntry, walkErr error) error
```

Bu callback har bir topilgan yozuv uchun chaqiriladi.

`path` — joriy yozuvning yo‘li.

`entry` — joriy fayl yoki katalog haqidagi `fs.DirEntry`.

`walkErr` esa aynan shu yo‘lni ko‘rishda yuz bergan xatoni bildiradi.

Bu yerda `walkErr`ni birinchi bo‘lib tekshirish muhim:

```go
if walkErr != nil {
	return walkErr
}
```

Sababi xato bo‘lgan holatda `entry`dan foydalanish xavfsiz bo‘lmasligi mumkin. `entry` metodlarini tekshiruvsiz chaqirish ayrim vaziyatlarda panic keltirib chiqarishi mumkin.

Keyin:

```go
rel, err := filepath.Rel(root, path)
```

mutlaq yoki uzun vaqtinchalik yo‘l o‘rniga `root`ga nisbatan qisqaroq yo‘l hosil qiladi.

Masalan:

```text
/tmp/walk-dir-123456/docs/readme.txt
```

o‘rniga:

```text
docs/readme.txt
```

chiqariladi.

`filepath.WalkDir` eski `filepath.Walk`ga qaraganda odatda samaraliroq bo‘lishi mumkin. Sababi callback’ka `os.FileInfo` emas, `os.DirEntry` beriladi. Shu tufayli ayrim fayllar uchun qo‘shimcha `os.Lstat` chaqiruvi kerak bo‘lmasligi mumkin.

### Katalogni tashlab ketish

Ba’zan daraxt bo‘ylab yurayotganda ayrim katalog ichiga umuman kirishni xohlamaysiz.

Masalan:

```text
.git
node_modules
cache
```

kabi kataloglarni tashlab ketish kerak bo‘lishi mumkin.

Katalog callback’ida:

```go
return filepath.SkipDir
```

qaytarilsa, `WalkDir` shu katalogning ichiga kirmaydi.

Bitta oddiy faylni tashlab ketish uchun esa odatda hech qanday maxsus signal kerak emas. Callback’dan `nil` qaytarib, keyingi yozuvga o‘tiladi.

`fs.SkipAll` bundan boshqa ma’noga ega: u butun yurishni to‘xtatish uchun ishlatiladi. Shu sabab bitta faylni tashlab ketish uchun `fs.SkipAll` ishlatish noto‘g‘ri.

Yana bir nozik holat: `WalkDir` odatda symbolic link ko‘rsatgan katalog ichiga avtomatik ergashmaydi.

Masalan:

```text
root/link -> /other/data
```

bo‘lsa, `link` yozuv sifatida ko‘rinishi mumkin. Lekin `/other/data` ichidagi butun daraxt avtomatik yurib chiqilmaydi.

Bu xatti-harakat symbolic link sabab kutilmagan sikl yoki boshqa katalog daraxtiga chiqib ketish xavfini kamaytiradi.

## Nisbiy va mutlaq yo‘llar

`path/filepath` paketida yo‘llarni hisoblash uchun bir nechta muhim funksiyalar bor.

`filepath.Abs` nisbiy yo‘lni joriy ish katalogiga nisbatan mutlaq ko‘rinishga keltiradi.

Masalan:

```text
data/config.json
```

joriy ish katalogi:

```text
/home/user/app
```

bo‘lsa, natija taxminan:

```text
/home/user/app/data/config.json
```

bo‘lishi mumkin.

`filepath.Rel(base, target)` esa `base`dan `target`ga qanday nisbiy yo‘l bilan borishni hisoblaydi.

Masalan:

```text
base:   /home/user/app
target: /home/user/app/data/config.json
```

uchun natija:

```text
data/config.json
```

bo‘lishi mumkin.

Muhim jihat: `filepath.Abs` va `filepath.Rel` asosan yo‘lni **mantiqiy hisoblaydi**. Ular fayl yoki katalog real fayl tizimida mavjudligini o‘z-o‘zidan tekshirmaydi.

### `filepath.Clean`

`filepath.Clean` yo‘l sintaksisini normallashtiradi.

Masalan:

```text
data/./reports/../config.json
```

quyidagiga soddalashishi mumkin:

```text
data/config.json
```

U:

* `.` qismlarini yo‘qotadi;
* `..` qismlarini imkon qadar hisoblaydi;
* ortiqcha separatorlarni tozalaydi.

Lekin bu yerda juda muhim xavfsizlik qoidasi bor:

> `filepath.Clean` xavfsizlik tekshiruvi emas.

Masalan:

```go
filepath.Clean("uploads/../../config")
```

yo‘lni normallashtiradi, lekin uning `uploads` katalogidan tashqariga chiqishini taqiqlamaydi.

Demak, `Clean`:

> “yo‘l sintaksisini tartibga keltir”

degan vazifani bajaradi.

U:

> “foydalanuvchi faqat shu katalog ichida qolsin”

degan xavfsizlik siyosatini bajarmaydi.

### Bazaviy katalog ichidagi yo‘lni tekshirish

HTTP orqali kelgan fayl nomi, URL parametri yoki CLI argumenti ishonchsiz bo‘lishi mumkin.

Masalan, foydalanuvchi:

```text
../../config.json
```

degan yo‘l yuborishi mumkin.

Agar dastur buni ko‘r-ko‘rona:

```go
filepath.Join("uploads", name)
```

bilan birlashtirib, keyin faylni ochsa, foydalanuvchi ruxsat etilgan `uploads` katalogidan tashqaridagi fayllarga chiqib ketishga urinishi mumkin.

Bu **path traversal** deb ataladigan zaiflikka olib keladi.

Quyidagi misolda yo‘l bazaviy katalog ichida qolayotganini tekshiramiz:

```go
package main

import (
	"fmt"
	"path/filepath"
	"strings"
)

func safeJoin(base, name string) (string, error) {
	if filepath.IsAbs(name) {
		return "", fmt.Errorf("mutlaq yo‘lga ruxsat yo‘q")
	}

	baseAbs, err := filepath.Abs(base)
	if err != nil {
		return "", fmt.Errorf("bazaviy yo‘l: %w", err)
	}
	target := filepath.Join(baseAbs, name)
	rel, err := filepath.Rel(baseAbs, target)
	if err != nil {
		return "", fmt.Errorf("nisbiy yo‘l: %w", err)
	}
	if rel == ".." || strings.HasPrefix(rel, ".."+string(filepath.Separator)) {
		return "", fmt.Errorf("yo‘l bazaviy katalogdan tashqariga chiqdi")
	}
	return target, nil
}

func main() {
	for _, name := range []string{"images/logo.png", "../../config.json"} {
		path, err := safeJoin("uploads", name)
		if err != nil {
			fmt.Printf("%s: rad etildi\n", name)
			continue
		}
		fmt.Printf("%s: ruxsat berildi (%s)\n", name, filepath.Base(path))
	}
}
```

Natija:

```text
images/logo.png: ruxsat berildi (logo.png)
../../config.json: rad etildi
```

Endi tekshiruvni bosqichma-bosqich ko‘ramiz.

Avval:

```go
if filepath.IsAbs(name) {
	return "", fmt.Errorf("mutlaq yo‘lga ruxsat yo‘q")
}
```

foydalanuvchi to‘g‘ridan-to‘g‘ri mutlaq yo‘l yubormaganini tekshiradi.

Masalan:

```text
/etc/passwd
```

kabi yo‘l darhol rad etilishi mumkin.

Keyin:

```go
baseAbs, err := filepath.Abs(base)
```

bazaviy katalogning mutlaq yo‘lini oladi.

Masalan:

```text
uploads
```

quyidagiga aylanishi mumkin:

```text
/home/app/uploads
```

So‘ng:

```go
target := filepath.Join(baseAbs, name)
```

foydalanuvchi yuborgan nom bazaviy yo‘l bilan birlashtiriladi.

Keyin:

```go
rel, err := filepath.Rel(baseAbs, target)
```

`baseAbs`dan `target`ga nisbiy yo‘l hisoblanadi.

Oddiy holatda:

```text
images/logo.png
```

hosil bo‘ladi.

Lekin tashqariga chiqadigan yo‘lda:

```text
../../config.json
```

yoki shunga o‘xshash `..` bilan boshlanuvchi qiymat hosil bo‘lishi mumkin.

Shu sabab:

```go
if rel == ".." || strings.HasPrefix(rel, ".."+string(filepath.Separator))
```

tekshiruvi yo‘l ota katalogga chiqayotganini aniqlaydi.

Bu yerda oddiy:

```go
strings.HasPrefix(target, base)
```

tekshiruvidan foydalanish yetarli emas.

Masalan:

```text
base   = /data/app
target = /data/app-old/file.txt
```

bo‘lsa, `target` satr sifatida `/data/app` bilan boshlanadi.

Lekin `/data/app-old` `/data/app` katalogining ichida emas.

Demak, fayl tizimi yo‘llarida oddiy satr prefiksi katalog chegarasini to‘g‘ri ifodalamaydi.

> **Diqqat**
>
> Yuqoridagi `safeJoin` leksik, ya’ni yo‘l matniga asoslangan tekshiruvni bajaradi. U symbolic link orqali bazaviy katalog tashqarisiga chiqishni to‘liq to‘xtatmaydi.
>
> Masalan, foydalanuvchi `uploads` ichida tashqi katalogga qaraydigan symbolic link yarata olsa, matn bo‘yicha yo‘l hali ham `uploads` ichida ko‘rinishi mumkin.
>
> Bunday xavf mavjud bo‘lsa, `os.Lstat` bilan symbolic linklarni tekshirish, `filepath.EvalSymlinks` orqali haqiqiy yo‘lni aniqlash yoki operatsion tizimning katalog descriptoriga nisbiy xavfsizroq API’laridan foydalanish kerak bo‘lishi mumkin.
>
> Yana bir muammo — tekshiruv bilan faylni haqiqatan ochish orasidagi vaqt. Tashqi jarayon shu orada fayl tizimini o‘zgartirsa, race holati yuz berishi mumkin. Bu **TOCTOU**, ya’ni “time-of-check to time-of-use” turidagi muammolarga olib kelishi mumkin.

## Katalog nomini o‘zgartirish va ko‘chirish

Fayl yoki katalog nomini o‘zgartirish uchun:

```go
os.Rename(oldPath, newPath)
```

ishlatiladi.

Masalan:

```go
err := os.Rename("reports", "archive")
```

`reports` katalogini `archive` nomiga o‘zgartirishga urinadi.

`os.Rename` faqat nom o‘zgartirish uchun emas, ayrim hollarda obyektni boshqa katalogga ko‘chirish uchun ham ishlatiladi.

Masalan:

```go
os.Rename(
	"uploads/file.txt",
	"archive/file.txt",
)
```

bir xil fayl tizimi ichida faylni boshqa katalogga ko‘chirishi mumkin.

Bir fayl tizimi ichidagi `Rename` odatda tez ishlaydi. Sababi ko‘pincha butun fayl yoki katalog tarkibini qayta nusxalash shart emas. Fayl tizimidagi metadata o‘zgartiriladi.

Lekin turli disklar yoki turli mount nuqtalari orasida vaziyat boshqacha.

Masalan:

```text
/mnt/disk1/data
```

dan:

```text
/mnt/disk2/data
```

ga ko‘chirishda `os.Rename` xato qaytarishi mumkin.

Bunday holatda odatda quyidagi jarayon kerak bo‘ladi:

1. manba tarkibini yangi joyga nusxalash;
2. kerakli permission va boshqa metadata’ni saqlash;
3. nusxalash to‘liq muvaffaqiyatli bo‘lganini tekshirish;
4. faqat shundan keyin eski nusxani o‘chirish.

Bu oddiy `Rename`dan ancha murakkabroq.

Yana bir muhim jihat: `newPath` allaqachon mavjud bo‘lsa nima bo‘lishi operatsion tizim va obyekt turiga bog‘liq bo‘lishi mumkin.

Linux va Windows’da ayniqsa ochiq turgan fayllarni almashtirish qoidalari bir xil emas.

Shu sabab cross-platform dastur yozilsa, `Rename` bilan bog‘liq muhim ssenariylarni faqat bitta operatsion tizimda emas, barcha qo‘llab-quvvatlanadigan platformalarda tekshirish kerak.

## Katalogni o‘chirish

Bo‘sh katalogni o‘chirish uchun `os.Remove` ishlatilishi mumkin.

Masalan:

```go
err := os.Remove("empty-dir")
```

Agar katalog ichida fayl yoki boshqa katalog mavjud bo‘lsa, `os.Remove` odatda xato qaytaradi.

Butun katalog daraxtini rekursiv o‘chirish uchun esa `os.RemoveAll` ishlatiladi:

```go
if err := os.RemoveAll(cacheDir); err != nil {
	return fmt.Errorf("cache katalogini o‘chirish: %w", err)
}
```

Bu parcha mustaqil to‘liq dastur emas.

U `error` qaytaradigan funksiya ichida yozilishi kerak. Shuningdek, `fmt.Errorf` ishlatilgani uchun `fmt` paketi import qilinishi kerak.

`os.RemoveAll(cacheDir)` quyidagi kabi daraxtni:

```text
cache/
├── images/
│   ├── a.jpg
│   └── b.jpg
└── metadata.json
```

to‘liq o‘chirishi mumkin.

Ya’ni faqat `cache` katalogi emas, uning ichidagi barcha fayl va kataloglar ham o‘chiriladi.

**Diqqat**

`os.RemoveAll` juda kuchli amal.

U noto‘g‘ri yo‘l bilan chaqirilsa, katta hajmdagi ma’lumotni qaytarib bo‘lmaydigan tarzda o‘chirishi mumkin.

Ayniqsa quyidagi qiymatlar xavfli bo‘lishi mumkin:

```text
.

yoki noto‘g‘ri hisoblangan keng katalog yo‘li.

`RemoveAll`dan oldin yo‘l aynan dastur boshqaradigan katalog ekanini aniq tekshirish kerak.

Foydalanuvchi HTTP, CLI yoki boshqa tashqi manbadan yuborgan yo‘lni hech qanday tekshiruvsiz to‘g‘ridan-to‘g‘ri `os.RemoveAll`ga bermang.
```

`os.RemoveAll` mavjud bo‘lmagan yo‘lga chaqirilsa, odatda `nil` qaytaradi.

Bu uni cleanup jarayonlarida qulay qiladi. Masalan, katalog oldin o‘chirilgan bo‘lsa ham faqat shu sababli yana xato hosil bo‘lmaydi.

Symbolic link bilan ham muhim xatti-harakat bor.

Agar yo‘l symbolic linkning o‘ziga ko‘rsatsa, `RemoveAll` odatda linkni o‘chiradi. U symbolic link ko‘rsatgan tashqi katalog daraxtiga avtomatik kirib, uni rekursiv o‘chirib yubormaydi.

Lekin bu barcha xavflarni yo‘q qilmaydi.

Agar tashqi jarayonlar fayl tizimini sizning tekshiruvingiz bilan o‘chirish amali orasida o‘zgartira olsa, oddiy yo‘l tekshiruvi yetarli bo‘lmasligi mumkin.

Xavfsizlikka sezgir dasturlarda bunday race holatlarini alohida hisobga olish kerak.

## Vaqtinchalik kataloglar

Ba’zi kataloglar faqat qisqa vaqt kerak bo‘ladi.

Masalan:

* test davomida;
* faylni konvertatsiya qilish paytida;
* arxivni vaqtincha ochishda;
* katta faylni qismlarga ajratishda;
* vaqtinchalik intermediate natijalarni saqlashda.

Bunday vaziyatlarda `os.MkdirTemp` ishlatish mumkin.

```go
dir, err := os.MkdirTemp("", "report-*")
if err != nil {
	return err
}
defer os.RemoveAll(dir)
```

Birinchi argument:

```go
""
```

bo‘sh satr bo‘lsa, operatsion tizimning standart vaqtinchalik katalogi ishlatiladi.

Ikkinchi argument:

```text
report-*
```

katalog nomi uchun pattern hisoblanadi.

`*` qismi tasodifiy qiymat bilan almashtiriladi.

Natijada taxminan:

```text
/tmp/report-184729153
```

kabi katalog yaratilishi mumkin.

Muhim jihat: `MkdirTemp` shunchaki noyob nom taklif qilib qaytmaydi. U katalogni **o‘zi yaratib**, keyin yo‘lni qaytaradi.

Bu xavfsizlik nuqtai nazaridan muhim.

Noto‘g‘ri yondashuv quyidagicha bo‘lishi mumkin edi:

1. tasodifiy nom topish;
2. shu nom bo‘sh ekanini tekshirish;
3. keyin katalog yaratish.

2-qadam bilan 3-qadam orasida boshqa jarayon o‘sha nomni egallab olishi mumkin edi.

`MkdirTemp` bunday “tekshir, keyin yarat” poyga holatini oldini olishga yordam beradi.

Misoldagi:

```go
defer os.RemoveAll(dir)
```

funksiya tugaganda vaqtinchalik katalogni tozalaydi.

Qisqa ishlaydigan funksiya yoki testlarda bu juda qulay.

Lekin uzoq ishlovchi serverda `defer`ning qachon ishlashini unutmaslik kerak.

Agar `defer` `main` kabi juda uzoq yashaydigan funksiyada yozilsa, vaqtinchalik katalog server soatlab yoki kunlab ishlayotgan paytda o‘chirilmasligi mumkin.

Shu sabab real serverda:

* vaqtinchalik katalog qancha vaqt yashashi;
* qachon tozalanishi;
* dastur crash bo‘lsa nima bo‘lishi;
* eski kataloglarni kim va qachon o‘chirishi

oldindan belgilanishi kerak.

## Keng tarqalgan xatolar

### Yo‘lni satr orqali birlashtirish

Quyidagicha yo‘l yaratish tavsiya etilmaydi:

```go
path := base + "/" + name
```

Birinchi qarashda bu oddiy va ishlaydigan yechimdek ko‘rinadi.

Lekin bir nechta muammo bor:

* Windows boshqa separator ishlatishi mumkin;
* `base` oxirida separator bo‘lsa, ikkita separator paydo bo‘lishi mumkin;
* `name` kutilmagan ko‘rinishda kelishi mumkin;
* yo‘lni normallashtirish masalalari hisobga olinmaydi.

Lokal fayl tizimi yo‘llarida:

```go
filepath.Join(base, name)
```

ishlatish yaxshiroq.

Lekin `filepath.Join`ning o‘zi tashqaridan kelgan yo‘lni xavfsiz qilib qo‘ymaydi. Path traversal xavfi bo‘lsa, bazaviy katalog chegarasi alohida tekshirilishi kerak.

### `Mkdir` va `MkdirAll`ni bir xil deb hisoblash

Bu ikki funksiya o‘xshash ko‘rinsa ham, vazifasi bir xil emas.

`Mkdir`:

```go
os.Mkdir(path, perm)
```

faqat oxirgi katalogni yaratadi.

Masalan:

```text
data/cache/images
```

uchun `data/cache` mavjud bo‘lmasa, oddiy `Mkdir` muvaffaqiyatsiz bo‘ladi.

`MkdirAll` esa:

```go
os.MkdirAll(path, perm)
```

yetishmayotgan ota kataloglarni ham yaratadi.

Yana bir farq: kerakli katalog daraxti allaqachon mavjud bo‘lsa, `MkdirAll` faqat shu sababli xato qaytarmaydi.

### `os.ReadDir` ichki daraxtni ham o‘qiydi deb o‘ylash

`os.ReadDir` faqat bitta katalog darajasini qaytaradi.

Masalan:

```text
root/
├── a.txt
└── sub/
    └── b.txt
```

uchun:

```go
os.ReadDir(root)
```

natijasida:

```text
a.txt
sub
```

olinadi.

`sub/b.txt` avtomatik qaytmaydi.

Butun katalog daraxtini rekursiv ko‘rish kerak bo‘lsa:

```go
filepath.WalkDir(...)
```

ishlatiladi.

### `filepath.Clean`ni xavfsizlik vositasi deb bilish

`filepath.Clean` yo‘lni sintaktik jihatdan normallashtiradi.

Masalan:

```text
a/./b/../c
```

ni:

```text
a/c
```

ko‘rinishiga keltirishi mumkin.

Lekin u:

> “bu yo‘l foydalanuvchiga ruxsat berilgan katalog ichidami?”

degan savolga javob bermaydi.

Shu sabab:

* yo‘lni normallashtirish;
* ruxsat etilgan katalog chegarasini tekshirish;
* symbolic linklarni hisobga olish

alohida vazifalardir.

### Katalog ruxsatidagi bajarish bitini noto‘g‘ri tushunish

Unix tizimida katalog uchun `x` biti oddiy executable fayldagi `x` bitidan boshqacha ma’noga ega.

Katalogda `x` biti uning ichidagi yozuvlarga murojaat qilish imkonini beradi.

Masalan, katalog ichida `file.txt` borligini bilsangiz, unga kirish uchun katalogda `x` permission kerak bo‘lishi mumkin.

`r` biti esa katalog ichidagi nomlarni ro‘yxatlashga bog‘liq.

Shu sabab katalogda:

```text
r
```

bor, lekin:

```text
x
```

yo‘q bo‘lsa, katalog ichidagi nomlarni ko‘rish mumkin bo‘lsa ham ulardan foydalanish cheklanishi mumkin.

Permissionlar bilan ishlaganda `r`, `w` va `x` bitlarining katalogdagi ma’nosini fayldagi ma’nosi bilan aralashtirmaslik kerak.

## Interviewda nimalarga e’tibor beriladi?

Go’da kataloglar va fayl yo‘llari haqida savol berilganda faqat funksiya nomlarini bilish yetarli bo‘lmasligi mumkin. Ularning vazifasi va chegarasini ham tushuntira olish muhim.

* `path` paketi URL kabi `/` separatorli umumiy slash-pathlar uchun ishlatiladi. `path/filepath` esa lokal operatsion tizimning fayl yo‘llari uchun mo‘ljallangan.

* `os.Mkdir` bitta katalog yaratadi va ota katalog mavjud bo‘lishini talab qiladi. `os.MkdirAll` esa yo‘ldagi yetishmayotgan kataloglarni ham yaratadi.

* `MkdirAll` katalog daraxti allaqachon mavjud bo‘lsa, faqat shu sababli xato qaytarmaydi. Shu sabab uni idempotent tarzda ishlatish qulay.

* `os.ReadDir` faqat bitta katalog darajasini o‘qiydi. Ichki kataloglar ichiga avtomatik kirmaydi.

* Rekursiv yurish uchun `filepath.WalkDir` ishlatiladi.

* `WalkDir` symbolic link ko‘rsatgan katalogga odatda avtomatik ergashmaydi. Symbolic linkning o‘zi yozuv sifatida ko‘rinadi.

* `filepath.Clean` yo‘l sintaksisini normallashtiradi. Lekin u xavfsizlik chegarasini tekshirmaydi.

* Path traversalni oldini olish uchun foydalanuvchi bergan yo‘l bazaviy katalogdan tashqariga chiqmasligi alohida tekshiriladi.

* Oddiy `strings.HasPrefix(target, base)` tekshiruvi katalog chegarasini aniqlash uchun yetarli emas.

* Symbolic linklar mavjud bo‘lsa, faqat matnga asoslangan yo‘l tekshiruvi barcha xavflarni yopmaydi.

* `os.Remove` bo‘sh katalogni o‘chirishi mumkin. `os.RemoveAll` esa butun katalog daraxtini rekursiv o‘chiradi.

* `os.RemoveAll` kuchli va xavfli amal. Uning argumenti ishonch chegarasida tekshirilishi kerak.

* `os.MkdirTemp` vaqtinchalik noyob katalogni xavfsizroq usulda yaratadi. Katalog nomini oldindan tekshirib, keyin yaratishdagi race holatini kamaytiradi.

* `os.Rename` bir fayl tizimi ichida odatda tez ishlaydi. Lekin turli disk yoki mount nuqtalari orasida xato qaytarishi mumkin.

Keyingi darsda Go dasturiga fayllarni compile time’da qo‘shish uchun `embed` paketidan foydalanishni o‘rganamiz.
