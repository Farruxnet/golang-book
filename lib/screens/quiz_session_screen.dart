import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/models.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/learning_timer.dart';
import '../widgets/markdown_view.dart';
import '../widgets/quiz_card.dart';

void openQuizSession(
  BuildContext context, {
  required String title,
  required List<Quiz> quizzes,
}) {
  if (quizzes.isEmpty) return;
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

  Quiz get _quiz => widget.quizzes[_index];
  bool get _finished => _index >= widget.quizzes.length;

  void _check() {
    final correct = context.appState.answer(_quiz, _selected!);
    correct ? HapticFeedback.lightImpact() : HapticFeedback.mediumImpact();
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
            onPressed: () => Navigator.maybePop(context),
          ),
          title: _finished
              ? Text(widget.title)
              : Row(
                  children: [
                    Expanded(
                      child: ProgressLine(
                        value: (_index + (_checked ? 1 : 0)) / total,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text('${_index + 1} / $total'),
                  ],
                ),
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0.06, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: _finished ? _results(context) : _question(context),
        ),
      ),
    );
  }

  Widget _question(BuildContext context) {
    final theme = Theme.of(context);
    final quiz = _quiz;
    final correct = _selected == quiz.answer;

    return Column(
      key: ValueKey(_index),
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            children: [
              Text(
                quiz.lesson.title,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              MarkdownView(
                data: quiz.question,
                fontScale: context.appState.fontScale * 1.05,
              ),
              const SizedBox(height: 16),
              for (var i = 0; i < quiz.options.length; i++)
                QuizOption(
                  index: i,
                  text: quiz.options[i],
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
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _selected == null
                    ? null
                    : _checked
                    ? _next
                    : _check,
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
        ),
      ],
    );
  }

  Widget _results(BuildContext context) {
    final theme = Theme.of(context);
    final total = widget.quizzes.length;
    final ratio = _correct / total;
    final headline = switch (ratio) {
      1 => 'Perfect score!',
      >= 0.7 => 'Great job!',
      >= 0.4 => 'Good effort',
      _ => 'Keep practicing',
    };
    final color = ratio >= 0.7 ? AppTheme.correct : AppTheme.streak;

    return SafeArea(
      key: const ValueKey('results'),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: ratio),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (_, v, _) => SizedBox.square(
                dimension: 132,
                child: CircularProgressIndicator(
                  value: v,
                  strokeWidth: 10,
                  strokeCap: StrokeCap.round,
                  color: color,
                  backgroundColor: color.withValues(alpha: 0.14),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '$_correct of $total correct',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              headline,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.maybePop(context),
                child: const Text('Done'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _restart,
                child: const Text('Try again'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
