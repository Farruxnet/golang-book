import 'dart:convert';

import 'package:flutter/material.dart';

import 'models.dart';

/// Loads the book from `assets/content/manifest.json` and the Markdown files
/// it references.
///
/// To add a lesson: drop a `.md` file into the section folder and add an entry
/// to the manifest. `title` is optional — the first `# Heading` is used.
class BookRepository {
  static const _root = 'assets/content';

  static const _icons = <String, IconData>{
    'school': Icons.school_rounded,
    'rocket': Icons.rocket_launch_rounded,
    'code': Icons.terminal_rounded,
    'book': Icons.menu_book_rounded,
    'bolt': Icons.bolt_rounded,
    'build': Icons.build_rounded,
  };

  static Future<Book> load(AssetBundle bundle) async {
    final manifest = jsonDecode(
      await bundle.loadString('$_root/manifest.json'),
    ) as Map<String, dynamic>;

    // Every section and lesson file is read in parallel.
    final sections = await Future.wait([
      for (final s in manifest['sections'] as List)
        _loadSection(bundle, s as Map),
    ]);
    return Book(sections);
  }

  static Future<Section> _loadSection(AssetBundle bundle, Map s) async {
    final lessons = await Future.wait([
      for (final l in s['lessons'] as List) _loadLesson(bundle, l as Map),
    ]);
    return Section(
      id: s['id'] as String,
      title: s['title'] as String,
      subtitle: s['subtitle'] as String? ?? '',
      icon: _icons[s['icon']] ?? Icons.menu_book_rounded,
      color: _parseColor(s['color'] as String? ?? '#00ADD8'),
      lessons: [...lessons.nonNulls],
    );
  }

  /// A missing or unreadable file skips that lesson instead of the whole book.
  static Future<Lesson?> _loadLesson(AssetBundle bundle, Map json) async {
    final file = json['file'] as String;
    final String raw;
    try {
      raw = await bundle.loadString('$_root/$file');
    } catch (e) {
      debugPrint('Skipping lesson $file: $e');
      return null;
    }
    final (heading, body) = _splitTitle(raw);
    return Lesson(
      id: file.split('/').last.replaceAll('.md', ''),
      title: json['title'] as String? ?? heading ?? file,
      summary: json['summary'] as String? ?? '',
      markdown: body,
      quizzes: Quiz.parseAll(body),
    );
  }

  /// Returns the first `# H1` and the Markdown without it.
  static (String?, String) _splitTitle(String raw) {
    final match = RegExp(r'^\s*#\s+(.+)\s*$', multiLine: true).firstMatch(raw);
    if (match == null || raw.substring(0, match.start).trim().isNotEmpty) {
      return (null, raw);
    }
    return (match.group(1)!.trim(), raw.substring(match.end).trimLeft());
  }

  static Color _parseColor(String hex) =>
      Color(int.tryParse(hex.replaceFirst('#', 'FF'), radix: 16) ?? 0xFF00ADD8);
}
