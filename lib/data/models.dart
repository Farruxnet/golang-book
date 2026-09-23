import 'package:flutter/material.dart';

/// A top-level part of the book: Basic, Advanced, Practice.
class Section {
  Section({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.lessons,
  }) {
    for (var i = 0; i < lessons.length; i++) {
      lessons[i]
        ..section = this
        ..index = i;
    }
  }

  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<Lesson> lessons;

  int get totalMinutes => lessons.fold(0, (sum, l) => sum + l.minutes);
}

/// A single lesson backed by a Markdown file in `assets/content/`.
class Lesson {
  Lesson({
    required this.id,
    required this.title,
    required this.summary,
    required this.markdown,
    required this.quizzes,
  }) {
    for (var i = 0; i < quizzes.length; i++) {
      quizzes[i]
        ..lesson = this
        ..index = i;
    }
  }

  final String id;
  final String title;
  final String summary;

  /// Markdown body with the leading `# Title` stripped (the screen renders it).
  final String markdown;

  /// Quizzes written inside the lesson as ```` ```quiz ```` blocks.
  final List<Quiz> quizzes;

  late final Section section;
  late final int index;

  /// Globally unique key, used for progress and bookmarks.
  String get key => '${section.id}/$id';

  int get number => index + 1;

  /// Estimated reading time at ~180 words per minute (code reads slower).
  /// Computed once: it is shown in every list row.
  late final int minutes = () {
    final prose = markdown.replaceAll(Quiz.blockPattern, '');
    final words = RegExp(r'\S+').allMatches(prose).length;
    return (words / 180).ceil().clamp(1, 999);
  }();

  /// Markdown without syntax characters, lowercased lazily for search.
  late final String plainText = markdown.replaceAll(RegExp(r'[#*`>\[\]_]'), '');
  late final String plainTextLower = plainText.toLowerCase();
}

class Book {
  Book(this.sections);

  final List<Section> sections;

  late final List<Lesson> allLessons = [for (final s in sections) ...s.lessons];

  late final Map<String, Lesson> _byKey = {
    for (final l in allLessons) l.key: l,
  };

  late final List<Quiz> allQuizzes = [for (final l in allLessons) ...l.quizzes];

  /// Same question for everyone on a given day.
  Quiz? get dailyQuiz {
    if (allQuizzes.isEmpty) return null;
    final now = DateTime.now();
    final day = DateTime.utc(
      now.year,
      now.month,
      now.day,
    ).difference(DateTime.utc(2024)).inDays;
    return allQuizzes[(day * 7919) % allQuizzes.length];
  }

  Lesson? lessonByKey(String? key) => key == null ? null : _byKey[key];

  Lesson? nextOf(Lesson lesson) {
    final i = allLessons.indexOf(lesson);
    return i >= 0 && i < allLessons.length - 1 ? allLessons[i + 1] : null;
  }
}

/// A multiple-choice question written in Markdown:
///
/// ````
/// ```quiz
/// What does `len("Go")` return?
/// - 1
/// + 2
/// - 3
/// > Strings are byte sequences; "Go" has 2 bytes.
/// ```
/// ````
///
/// Lines before the first option form the question (Markdown; use `~~~go`
/// fences for code). `+` marks the correct option, `>` lines explain it.
class Quiz {
  Quiz({
    required this.source,
    required this.question,
    required this.options,
    required this.answer,
    required this.explanation,
  });

  static final blockPattern = RegExp(
    r'^```quiz\s*\n([\s\S]*?)^```\s*$',
    multiLine: true,
  );

  static List<Quiz> parseAll(String markdown) => [
    for (final m in blockPattern.allMatches(markdown))
      ?Quiz.tryParse(m.group(1)!),
  ];

  static Quiz? tryParse(String source) {
    final question = <String>[];
    final options = <String>[];
    final explanation = <String>[];
    var answer = -1;
    var inFence = false;
    for (final line in source.trimRight().split('\n')) {
      if (line.trimLeft().startsWith('~~~')) inFence = !inFence;
      final t = line.trimLeft();
      if (!inFence && (t.startsWith('- ') || t.startsWith('+ '))) {
        if (t.startsWith('+')) answer = options.length;
        options.add(t.substring(2).trim());
      } else if (!inFence && options.isNotEmpty && t.startsWith('>')) {
        explanation.add(t.substring(1).trim());
      } else if (options.isEmpty) {
        question.add(line);
      }
    }
    if (options.length < 2 || answer < 0) return null;
    return Quiz(
      source: source.trim(),
      question: question.join('\n').trim(),
      options: options,
      answer: answer,
      explanation: explanation.join(' '),
    );
  }

  /// Raw block content, used to match a rendered block back to this quiz.
  final String source;
  final String question;
  final List<String> options;
  final int answer;
  final String explanation;

  late final Lesson lesson;
  late final int index;

  String get id => '${lesson.key}#$index';
}
