# Go Book

A Flutter app for learning Go. Lessons are Markdown files; the app adds quizzes,
progress tracking, streaks and XP on top.

## Related repositories

| Repository | Purpose |
|------------|---------|
| [Farruxnet/go-lang.uz](https://github.com/Farruxnet/go-lang.uz) | Source of the [go-lang.uz](https://go-lang.uz) website: Uzbek Go lessons (MkDocs Material, content in `docs/`). |

## App structure

| Tab | What's there |
|-----|--------------|
| **Learn** | Continue reading, search, bookmarks, the lesson list |
| **Practice** | Quick quiz, question of the day, quiz by topic (shows an empty state until lessons have quizzes) |
| **Progress** | Level/XP, streak, stats, 12-week activity heatmap, daily goal, bookmarks |
| **Config** | Language (Uzbek/English/Russian), theme (system/light/dark), accent color, text size, line spacing, daily goal, haptics, reset, about (privacy policy, licenses) |

## Languages

The app's own texts (menus, buttons, messages) come in Uzbek, English and Russian and are
chosen on first launch (the welcome screen is followed by a short intro) and later in
**Config → Language**. English is the default.
All of them live in `lib/l10n/strings.dart`; add a language by adding its code to `S.codes` and a
translation to every entry. Lesson content is not translated.

## Release checklist

- **App id:** `uz.golang.book` (`android/app/build.gradle.kts`). Change it before the first upload if you want another one; it can't change after.
- **Version:** `version:` in `pubspec.yaml` and `AppInfo.version` in `lib/app_info.dart` must match. Raise the build number (`+N`) on every upload.
- **Signing:** create an upload key and `android/key.properties` (git-ignored):
  ```properties
  storeFile=/absolute/path/upload-keystore.jks
  storePassword=...
  keyAlias=upload
  keyPassword=...
  ```
  Without it release builds are signed with the debug key and the Play Store rejects them.
- **Build:** `flutter build appbundle --release`
- **Privacy policy:** the store needs a public URL. Publish `PRIVACY.md` (same text as Config → About → Privacy policy) and update `AppInfo.privacyUpdated` when it changes.
- **Data safety form:** no data collected or shared; no internet permission.

## Adding content

1. Put a `.md` file in `assets/content/golang_uz` (or a new folder).
2. Add it to the section's `lessons` list in `assets/content/manifest.json`:

```json
{ "file": "golang_uz/49_pointers.md", "summary": "Short one-line description." }
```

- The lesson title comes from the file's first `# Heading`, or from an optional `"title"` field.
- Reading time is calculated automatically.
- Name the language on code blocks (```` ```go ````) to get syntax highlighting.
- Images go in `assets/content/images/` and are referenced as `![alt](images/pic.png)`.
- If you add a new folder, register it under `flutter/assets` in `pubspec.yaml`.

Sections (title, subtitle, color, icon: `school`, `rocket`, `code`, `book`, `bolt`, `build`) are also defined in the manifest.

### Lessons from go-lang.uz

The **Go asoslari** section (`assets/content/golang_uz`) holds the basic lessons of
[go-lang.uz](https://github.com/Farruxnet/go-lang.uz), converted from MkDocs Markdown. Don't edit these
files by hand; re-run the importer after the site changes:

```sh
pip install pyyaml
python3 tool/import_golang_uz.py /path/to/go-lang.uz
```

## Writing quizzes

Put a `quiz` block anywhere in a lesson. It shows up inline in the lesson and
automatically in the Practice tab.

````markdown
```quiz
What is printed?

~~~go
fmt.Println(len("Go"))
~~~
- 1
+ 2
- 3
> Strings are byte sequences; "Go" is 2 bytes.
```
````

- Lines before the first option are the question (Markdown; use `~~~go` for code).
- `-` is a wrong option, `+` is the correct one (exactly one).
- `>` lines are the explanation shown after answering.
