import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/playground.dart';
import '../theme.dart';

Future<void> showRunSheet(BuildContext context, String code) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: const Color(0xFF0D1117),
    builder: (_) => _RunSheet(code: code),
  );
}

class _RunSheet extends StatefulWidget {
  const _RunSheet({required this.code});

  final String code;

  @override
  State<_RunSheet> createState() => _RunSheetState();
}

class _RunSheetState extends State<_RunSheet> {
  late Future<RunResult> _result = Playground.run(widget.code);
  bool _sharing = false;

  static const _text = Color(0xFFD7DAE0);
  static const _muted = Color(0xFF8B949E);
  static const _error = Color(0xFFFF7B72);
  static const _ok = Color(0xFF3FB950);

  Future<void> _openInPlayground() async {
    setState(() => _sharing = true);
    try {
      final url = await Playground.share(widget.code);
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Could not reach go.dev')));
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const mono = TextStyle(
      fontFamily: AppTheme.mono,
      fontSize: 13.5,
      height: 1.5,
      color: _text,
    );

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.7,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: _muted.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.terminal_rounded, color: _muted, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Output',
                  style: TextStyle(
                    color: _text,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Close',
                  color: _muted,
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF161B22),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
                child: FutureBuilder(
                  future: _result,
                  builder: (context, snap) {
                    if (snap.connectionState != ConnectionState.done) {
                      return const Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _ok,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Running on go.dev…', style: mono),
                        ],
                      );
                    }
                    if (snap.hasError) {
                      return Text(
                        'Could not reach the Go Playground.\n'
                        'Check your internet connection and try again.',
                        style: mono.copyWith(color: _error),
                      );
                    }
                    final r = snap.data!;
                    return SingleChildScrollView(
                      child: SelectableText.rich(
                        TextSpan(
                          style: mono,
                          children: [
                            if (r.compileError.isNotEmpty)
                              TextSpan(
                                text: r.compileError,
                                style: const TextStyle(color: _error),
                              ),
                            for (final e in r.output)
                              TextSpan(
                                text: e.text,
                                style: e.isError
                                    ? const TextStyle(color: _error)
                                    : null,
                              ),
                            if (r.vetError.isNotEmpty)
                              TextSpan(
                                text: '\n${r.vetError}',
                                style: const TextStyle(color: _error),
                              ),
                            TextSpan(
                              text: r.failed
                                  ? '\n\nBuild failed.'
                                  : '\nProgram exited.',
                              style: TextStyle(
                                color: r.failed ? _error : _muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _sharing ? null : _openInPlayground,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _text,
                      side: BorderSide(color: _muted.withValues(alpha: 0.4)),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    label: const Text('Edit in Playground'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () =>
                        setState(() => _result = Playground.run(widget.code)),
                    style: FilledButton.styleFrom(
                      backgroundColor: _ok,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                    ),
                    icon: const Icon(Icons.replay_rounded, size: 18),
                    label: const Text('Run again'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
