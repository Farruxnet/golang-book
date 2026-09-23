import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:highlight/highlight.dart' show Node, highlight;

import '../theme.dart';
import 'run_sheet.dart';

/// Syntax-highlighted code block with a language label and copy button.
/// Always dark, like an editor, in both app themes.
class CodeBlock extends StatefulWidget {
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

  @override
  State<CodeBlock> createState() => _CodeBlockState();
}

class _CodeBlockState extends State<CodeBlock> {
  static const _background = Color(0xFF16191F);
  static const _muted = Color(0xFF8B949E);
  static const _text = Color(0xFFD7DAE0);

  /// Highlighted once, not on every rebuild.
  late List<TextSpan> _spans;

  @override
  void initState() {
    super.initState();
    _spans = _highlight(widget.code, widget.language);
  }

  @override
  void didUpdateWidget(CodeBlock old) {
    super.didUpdateWidget(old);
    if (old.code != widget.code || old.language != widget.language) {
      _spans = _highlight(widget.code, widget.language);
    }
  }

  static List<TextSpan> _highlight(String code, String language) {
    try {
      final nodes = highlight.parse(code, language: language).nodes ?? [];
      return [for (final n in nodes) _toSpan(n)];
    } catch (_) {
      // Unusual input can trip the highlighter: show plain code instead.
      return [TextSpan(text: code)];
    }
  }

  static TextSpan _toSpan(Node node) {
    final style = node.className == null
        ? null
        : atomOneDarkTheme[node.className];
    return node.value != null
        ? TextSpan(text: node.value, style: style)
        : TextSpan(
            style: style,
            children: [for (final c in node.children ?? <Node>[]) _toSpan(c)],
          );
  }

  @override
  Widget build(BuildContext context) {
    final label = widget.language == 'plaintext' ? 'text' : widget.language;
    // Own layer: scrolling the lesson doesn't repaint the code, and
    // scrolling the code sideways doesn't repaint the lesson.
    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: _background,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 4, 0),
              child: Row(
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: _muted,
                      fontSize: 12,
                      fontFamily: AppTheme.mono,
                    ),
                  ),
                  const Spacer(),
                  if (widget.runnable)
                    TextButton.icon(
                      onPressed: () => showRunSheet(context, widget.code),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF3FB950),
                        visualDensity: VisualDensity.compact,
                        textStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      icon: const Icon(Icons.play_arrow_rounded, size: 18),
                      label: const Text('Run'),
                    ),
                  _CopyButton(code: widget.code),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 16),
              child: Text.rich(
                TextSpan(children: _spans),
                style: TextStyle(
                  fontFamily: AppTheme.mono,
                  fontSize: 13.5 * widget.fontScale,
                  height: 1.55,
                  color: _text,
                ),
              ),
            ),
          ],
        ),
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
    HapticFeedback.selectionClick();
    setState(() => _copied = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: _copied ? 'Copied' : 'Copy',
      onPressed: _copy,
      visualDensity: VisualDensity.compact,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: Icon(
          _copied ? Icons.check_rounded : Icons.copy_rounded,
          key: ValueKey(_copied),
          size: 18,
          color: _copied ? const Color(0xFF3FB950) : _CodeBlockState._muted,
        ),
      ),
    );
  }
}
