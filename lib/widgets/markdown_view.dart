import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:url_launcher/url_launcher.dart';

import '../data/models.dart';
import '../theme.dart';
import 'code_block.dart';
import 'quiz_card.dart';

/// Renders lesson Markdown with book typography and highlighted code.
class MarkdownView extends StatelessWidget {
  const MarkdownView({
    super.key,
    required this.data,
    this.fontScale = 1,
    this.quizzes = const [],
  });

  final String data;
  final double fontScale;

  /// Quizzes of the lesson, matched to ```` ```quiz ```` blocks by content.
  final List<Quiz> quizzes;

  static Future<void> _openLink(String? href) async {
    final uri = href == null ? null : Uri.tryParse(href);
    if (uri == null || !uri.hasScheme) return;
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Could not open $uri: $e');
    }
  }

  static Widget _image(Uri uri, String? title, String? alt) {
    Widget fallback(BuildContext _, Object _, StackTrace? _) =>
        const SizedBox.shrink();
    final image = uri.hasScheme
        ? Image.network(uri.toString(), errorBuilder: fallback)
        : Image.asset('assets/content/${uri.path}', errorBuilder: fallback);
    return ClipRRect(borderRadius: BorderRadius.circular(12), child: image);
  }

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: data,
      styleSheet: _styleSheet(Theme.of(context)),
      builders: {'pre': _CodeBlockBuilder(fontScale, quizzes)},
      onTapLink: (text, href, title) => _openLink(href),
      imageBuilder: _image,
    );
  }

  MarkdownStyleSheet _styleSheet(ThemeData theme) {
    final scheme = theme.colorScheme;
    final accent = scheme.primary;
    final s = fontScale;
    final body = TextStyle(
      fontSize: 16.5 * s,
      height: 1.7,
      color: scheme.onSurface.withValues(alpha: 0.9),
    );
    TextStyle heading(double size) => TextStyle(
      fontSize: size * s,
      height: 1.3,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
      color: scheme.onSurface,
    );

    return MarkdownStyleSheet.fromTheme(theme).copyWith(
      p: body,
      pPadding: const EdgeInsets.only(bottom: 4),
      h1: heading(24),
      h1Padding: const EdgeInsets.only(top: 20, bottom: 4),
      h2: heading(21),
      h2Padding: const EdgeInsets.only(top: 22, bottom: 2),
      h3: heading(18),
      h3Padding: const EdgeInsets.only(top: 16),
      h4: heading(16.5),
      strong: const TextStyle(fontWeight: FontWeight.w700),
      em: const TextStyle(fontStyle: FontStyle.italic),
      a: TextStyle(
        color: accent,
        decoration: TextDecoration.underline,
        decorationColor: accent.withValues(alpha: 0.4),
      ),
      code: TextStyle(
        fontFamily: AppTheme.mono,
        fontSize: 14.5 * s,
        color: scheme.onSurface,
        backgroundColor: scheme.surfaceContainer,
      ),
      listBullet: body.copyWith(color: scheme.onSurfaceVariant),
      listIndent: 22,
      blockSpacing: 14,
      blockquote: body,
      blockquotePadding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
      blockquoteDecoration: BoxDecoration(
        color: accent.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: accent, width: 3)),
      ),
      tableHead: body.copyWith(fontWeight: FontWeight.w600),
      tableBody: body.copyWith(fontSize: 15 * s),
      tableBorder: TableBorder.all(
        color: scheme.outlineVariant,
        borderRadius: BorderRadius.circular(10),
      ),
      tableHeadAlign: TextAlign.left,
      tableCellsPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      tableCellsDecoration: BoxDecoration(color: scheme.surfaceContainerLow),
      horizontalRuleDecoration: BoxDecoration(
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
    );
  }
}

class _CodeBlockBuilder extends MarkdownElementBuilder {
  _CodeBlockBuilder(this.fontScale, this.quizzes);

  final double fontScale;
  final List<Quiz> quizzes;

  @override
  bool isBlockElement() => true;

  @override
  Widget? visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    var language = 'plaintext';
    final child = element.children?.firstOrNull;
    if (child is md.Element) {
      final cls = child.attributes['class'];
      if (cls != null && cls.startsWith('language-')) {
        language = cls.substring('language-'.length);
      }
    }
    final code = element.textContent.trimRight();
    if (language == 'quiz') {
      final quiz = quizzes.where((q) => q.source == code.trim()).firstOrNull;
      return quiz == null ? const SizedBox.shrink() : QuizCard(quiz: quiz);
    }
    return CodeBlock(code: code, language: language, fontScale: fontScale);
  }
}
