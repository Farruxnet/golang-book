# Go Book

A Flutter app for learning Go. Lessons are Markdown files; the app adds quizzes,
runnable code, progress tracking, streaks and XP on top.

## App structure

| Tab | What's there |
|-----|--------------|
| **Learn** | Continue reading, daily goal & level, daily challenge, sections with their lessons |
| **Practice** | Mixed quiz, daily challenge, quiz by topic, projects |
| **Progress** | Level/XP, streak, stats, 12-week activity heatmap, daily goal, settings |

## Adding content

1. Put a `.md` file in `assets/content/basic`, `advanced` or `practice`.
2. Add it to the section's `lessons` list in `assets/content/manifest.json`:

```json
{ "file": "basic/07_pointers.md", "summary": "Short one-line description." }
```

- The lesson title comes from the file's first `# Heading`, or from an optional `"title"` field.
- Reading time is calculated automatically.
- Name the language on code blocks (```` ```go ````) to get syntax highlighting.
  Blocks containing `package main` and `func main()` get a **Run** button (Go Playground).
- Images go in `assets/content/images/` and are referenced as `![alt](images/pic.png)`.
- If you add a new folder, register it under `flutter/assets` in `pubspec.yaml`.

Sections (title, subtitle, color, icon: `school`, `rocket`, `code`, `book`, `bolt`, `build`) are also defined in the manifest.

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
