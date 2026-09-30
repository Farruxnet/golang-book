import 'dart:convert';

import 'package:flutter/material.dart';

import 'models.dart';

/// Loads the book from `assets/content/manifest.json` and the Markdown files
/// it references.
///
/// The manifest and its files are the original (Uzbek) book. A translation
/// lives in `assets/content/i18n/<language>/`: a `manifest.json` with the
/// section titles and lesson summaries, and the lesson files under the same
/// paths as the originals. Anything not translated falls back to the original,
/// so lesson keys (and saved progress) are the same in every language.
///
/// To add a lesson: drop a `.md` file into the section folder and add an entry
/// to the manifest. `title` is optional — the first `# Heading` is used.
class BookRepository {
  static const _root = 'assets/content';

  /// The language the original lessons are written in.
  static const sourceLanguage = 'uz';

  static const _icons = <String, IconData>{
    'school': Icons.school_rounded,
    'rocket': Icons.rocket_launch_rounded,
    'code': Icons.terminal_rounded,
    'book': Icons.menu_book_rounded,
    'bolt': Icons.bolt_rounded,
    'build': Icons.build_rounded,
  };

  static Future<Book> load(
    AssetBundle bundle, {
    String language = sourceLanguage,
  }) async {
    final (manifest, overlay) = await (
      _readJson(bundle, '$_root/manifest.json'),
      _readOverlay(bundle, language),
    ).wait;
    final translated = language == sourceLanguage ? null : language;

    // Every section and lesson file is read in parallel.
    final loaded = await Future.wait([
      for (final s in manifest['sections'] as List)
        _loadSection(bundle, s as Map, overlay, translated),
    ]);
    return Book(
      [for (final (section, _) in loaded) section],
      language: language,
      complete: loaded.every((r) => r.$2),
    );
  }

  static Future<Map<String, dynamic>> _readJson(
    AssetBundle bundle,
    String path,
  ) async => jsonDecode(await bundle.loadString(path)) as Map<String, dynamic>;

  /// Section titles and summaries of a translation, keyed by section id.
  /// A missing or broken overlay just means untranslated texts.
  static Future<Map> _readOverlay(AssetBundle bundle, String language) async {
    if (language == sourceLanguage) return const {};
    try {
      final json = await _readJson(bundle, '$_root/i18n/$language/manifest.json');
      return json['sections'] as Map? ?? const {};
    } catch (e) {
      debugPrint('No book translation for $language: $e');
      return const {};
    }
  }

  /// Returns the section and whether every one of its lessons loaded.
  static Future<(Section, bool)> _loadSection(
    AssetBundle bundle,
    Map s,
    Map overlay,
    String? language,
  ) async {
    final tr = overlay[s['id']] as Map? ?? const {};
    final summaries = tr['summaries'] as Map? ?? const {};
    final entries = [for (final l in s['lessons'] as List) l as Map];
    final lessons = await Future.wait([
      for (final l in entries)
        _loadLesson(bundle, l, summaries[l['file']] as String?, language),
    ]);
    final section = Section(
      id: s['id'] as String,
      title: tr['title'] as String? ?? s['title'] as String,
      subtitle: tr['subtitle'] as String? ?? s['subtitle'] as String? ?? '',
      icon: _icons[s['icon']] ?? Icons.menu_book_rounded,
      color: _parseColor(s['color'] as String? ?? '#00ADD8'),
      lessons: [...lessons.nonNulls],
    );
    return (section, section.lessons.length == entries.length);
  }

  /// Prefers the translated file; a missing translation shows the original
  /// and a missing original skips that lesson instead of the whole book.
  static Future<Lesson?> _loadLesson(
    AssetBundle bundle,
    Map json,
    String? translatedSummary,
    String? language,
  ) async {
    final file = json['file'] as String;
    final translated = language == null
        ? null
        : await _tryLoad(bundle, '$_root/i18n/$language/$file');
    final raw = translated ?? await _tryLoad(bundle, '$_root/$file');
    if (raw == null) return null;
    final (heading, body) = _splitTitle(raw);
    return Lesson(
      id: file.split('/').last.replaceAll('.md', ''),
      // A manifest title names the original, so a translation's heading wins.
      title: (translated != null ? heading : null) ??
          json['title'] as String? ??
          heading ??
          file,
      summary: (translated != null ? translatedSummary : null) ??
          json['summary'] as String? ??
          '',
      markdown: body,
      quizzes: Quiz.parseAll(body),
    );
  }

  static Future<String?> _tryLoad(AssetBundle bundle, String path) async {
    try {
      return await bundle.loadString(path);
    } catch (e) {
      debugPrint('Could not read $path: $e');
      return null;
    }
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
