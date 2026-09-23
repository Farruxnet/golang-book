import 'package:flutter/material.dart';

import '../data/models.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/learning_timer.dart';
import '../widgets/markdown_view.dart';
import '../widgets/quiz_card.dart';

void openQuizSession(
  BuildContext context, {
  required String title,
  required List<Quiz> quizzes,
}) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => QuizSessionScreen(title: title, quizzes: quizzes),
    ),
  );
}

/// One question per page: pick, check, read the explanation, continue.
class QuizSessionScreen extends StatefulWidget {
  const QuizSessionScreen({
    super.key,
    required this.title,
    required this.quizzes,
  });

  final String title;
  final List<Quiz> quizzes;

  @override
  State<QuizSessionScreen> createState() => _QuizSessionScreenState();
}

class _QuizSessionScreenState extends State<QuizSessionScreen> {
  int _index = 0;
  int? _selected;
  bool _checked = false;
  int _correct = 0;
  late int _startXp;
  bool _started = false;

  Quiz get _quiz => widget.quizzes[_index];
  bool get _finished => _index >= widget.quizzes.length;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_started) {
      _startXp = context.appState.xp;
      _started = true;
    }
  }

  void _check() {
    final correct = context.appState.answer(_quiz, _selected!);
    setState(() {
      _checked = true;
      if (correct) _correct++;
    });
  }

  void _next() => setState(() {
    _index++;
    _selected = null;
    _checked = false;
  });

  void _restart() => setState(() {
    _index = 0;
    _selected = null;
    _checked = false;
    _correct = 0;
  });

  @override
  Widget build(BuildContext context) {
    final total = widget.quizzes.length;
    return LearningTimer(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Close',
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.pop(context),
          ),
          title: _finished
              ? Text(widget.title)
              : Row(
                  children: [
                    Expanded(
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(
                          end: (_index + (_checked ? 1 : 0)) / total,
                        ),
                        duration: const Duration(milliseconds: 300),
                        builder: (_, v, _) => LinearProgressIndicator(
                          value: v,
                          minHeight: 10,
                          color: kCorrect,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text('${_index + 1}/$total'),
                  ],
                ),
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: _finished ? _results(context) : _question(context),
        ),
      ),
    );
  }

  Widget _question(BuildContext context) {
    final theme = Theme.of(context);
    final quiz = _quiz;
    final accent = quiz.lesson.section.color;
    final correct = _selected == quiz.answer;

    return Column(
      key: ValueKey(_index),
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            children: [
              Text(
                '${quiz.lesson.section.title} · ${quiz.lesson.title}'
                    .toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 10),
              MarkdownView(
                data: quiz.question,
                accent: accent,
                fontScale: context.appState.fontScale * 1.05,
              ),
              const SizedBox(height: 16),
              for (var i = 0; i < quiz.options.length; i++)
                QuizOption(
                  index: i,
                  text: quiz.options[i],
                  accent: accent,
                  status: !_checked
                      ? (i == _selected
                            ? OptionStatus.selected
                            : OptionStatus.idle)
                      : i == quiz.answer
                      ? OptionStatus.correct
                      : i == _selected
                      ? OptionStatus.wrong
                      : OptionStatus.dimmed,
                  onTap: _checked ? null : () => setState(() => _selected = i),
                ),
              if (_checked) ...[
                const SizedBox(height: 8),
                QuizFeedback(quiz: quiz, correct: correct),
              ],
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: FilledButton(
              onPressed: _selected == null
                  ? null
                  : _checked
                  ? _next
                  : _check,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                backgroundColor: _checked
                    ? (correct ? kCorrect : kWrong)
                    : accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: Text(
                !_checked
                    ? 'Check'
                    : _index == widget.quizzes.length - 1
                    ? 'See results'
                    : 'Continue',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _results(BuildContext context) {
    final theme = Theme.of(context);
    final total = widget.quizzes.length;
    final ratio = _correct / total;
    final earned = context.appState.xp - _startXp;
    final (emoji, headline) = switch (ratio) {
      1 => ('🏆', 'Perfect score!'),
      >= 0.7 => ('🎉', 'Great job!'),
      >= 0.4 => ('💪', 'Good effort'),
      _ => ('📚', 'Keep practicing'),
    };

    return SafeArea(
      key: const ValueKey('results'),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),
            Text(emoji, style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            Text(headline, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 24),
            RingProgress(
              value: ratio,
              color: ratio >= 0.7 ? kCorrect : const Color(0xFFFF8A00),
              size: 140,
              stroke: 12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$_correct/$total',
                    style: theme.textTheme.headlineMedium,
                  ),
                  Text(
                    'correct',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (earned > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '+$earned XP earned',
                  style: const TextStyle(
                    color: Color(0xFF8B5CF6),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            const Spacer(),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text('Done'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: _restart,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
