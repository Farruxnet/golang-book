import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';

import '../theme.dart';
import 'run_sheet.dart';

/// Syntax-highlighted code block with a language label and copy button.
/// Always dark, like an editor, in both app themes.
class CodeBlock extends StatelessWidget {
  const CodeBlock({
    super.key,
    required this.code,
    required this.language,
    this.fontScale = 1,
  });

  final String code;
  final String language;
  final double fontScale;

  /// Complete programs can be executed on the Go Playground.
  bool get runnable =>
      language == 'go' &&
      code.contains('package main') &&
      code.contains('func main()');

  static const _background = Color(0xFF161B22);
  static const _header = Color(0xFF1F2630);

  static final _theme = {
    ...atomOneDarkTheme,
    'root': atomOneDarkTheme['root']!.copyWith(
      backgroundColor: Colors.transparent,
      color: const Color(0xFFD7DAE0),
    ),
  };

  @override
  Widget build(BuildContext context) {
    final label = language == 'plaintext' ? 'text' : language;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: _header,
            padding: const EdgeInsets.only(left: 14, right: 4),
            child: Row(
              children: [
                for (final c in const [
                  Color(0xFFFF5F57),
                  Color(0xFFFEBC2E),
                  Color(0xFF28C840),
                ])
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(right: 6),
                    decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                  ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF8B949E),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppTheme.mono,
                  ),
                ),
                const Spacer(),
                if (runnable)
                  TextButton.icon(
                    onPressed: () => showRunSheet(context, code),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF3FB950),
                      visualDensity: VisualDensity.compact,
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    icon: const Icon(Icons.play_arrow_rounded, size: 18),
                    label: const Text('Run'),
                  ),
                _CopyButton(code: code),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: HighlightView(
              code,
              language: language,
              theme: _theme,
              padding: EdgeInsets.zero,
              textStyle: TextStyle(
                fontFamily: AppTheme.mono,
                fontSize: 13.5 * fontScale,
                height: 1.55,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CopyButton extends StatefulWidget {
  const _CopyButton({required this.code});

  final String code;

  @override
  State<_CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<_CopyButton> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.code));
    if (!mounted) return;
    setState(() => _copied = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: _copy,
      style: TextButton.styleFrom(
        foregroundColor: _copied
            ? const Color(0xFF3FB950)
            : const Color(0xFF8B949E),
        visualDensity: VisualDensity.compact,
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      icon: Icon(_copied ? Icons.check_rounded : Icons.copy_rounded, size: 16),
      label: Text(_copied ? 'Copied' : 'Copy'),
    );
  }
}
