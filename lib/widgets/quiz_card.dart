import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/models.dart';
import '../state/app_state.dart';
import '../theme.dart';
import 'common.dart';
import 'markdown_view.dart';

/// Multiple-choice question inside a lesson. The answer is saved in
/// [AppState], so the card looks the same wherever the quiz appears.
class QuizCard extends StatelessWidget {
  const QuizCard({super.key, required this.quiz});

  final Quiz quiz;

  @override
  Widget build(BuildContext context) {
    final state = context.appState;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final selected = state.answerOf(quiz);
    final answered = selected != null;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppCard.radius),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.help_outline_rounded, size: 18, color: scheme.primary),
              const SizedBox(width: 6),
              Text(
                'Quick check',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: scheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          MarkdownView(data: quiz.question, fontScale: state.fontScale * 0.95),
          const SizedBox(height: 10),
          for (var i = 0; i < quiz.options.length; i++)
            QuizOption(
              index: i,
              text: quiz.options[i],
              status: !answered
                  ? OptionStatus.idle
                  : i == quiz.answer
                  ? OptionStatus.correct
                  : i == selected
                  ? OptionStatus.wrong
                  : OptionStatus.dimmed,
              onTap: answered ? null : () => state.answer(quiz, i),
            ),
          if (answered) ...[
            const SizedBox(height: 4),
            QuizFeedback(quiz: quiz, correct: selected == quiz.answer),
            if (selected != quiz.answer)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => state.clearAnswers([quiz]),
                  child: const Text('Try again'),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

enum OptionStatus { idle, selected, correct, wrong, dimmed }

class QuizOption extends StatelessWidget {
  const QuizOption({
    super.key,
    required this.index,
    required this.text,
    required this.status,
    this.onTap,
  });

  final int index;
  final String text;
  final OptionStatus status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final letter = String.fromCharCode(65 + index);
    final (
      Color border,
      Color fill,
      Color badge,
      Color onBadge,
    ) = switch (status) {
      OptionStatus.correct => (
        AppTheme.correct,
        AppTheme.correct.withValues(alpha: 0.1),
        AppTheme.correct,
        Colors.white,
      ),
      OptionStatus.wrong => (
        AppTheme.wrong,
        AppTheme.wrong.withValues(alpha: 0.1),
        AppTheme.wrong,
        Colors.white,
      ),
      OptionStatus.selected => (
        scheme.primary,
        scheme.primary.withValues(alpha: 0.08),
        scheme.primary,
        scheme.onPrimary,
      ),
      _ => (
        scheme.outlineVariant,
        Colors.transparent,
        scheme.surfaceContainer,
        scheme.onSurfaceVariant,
      ),
    };
    final radius = BorderRadius.circular(12);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: status == OptionStatus.dimmed ? 0.5 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: fill,
            borderRadius: radius,
            border: Border.all(color: border, width: 1.2),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: radius,
              onTap: onTap == null
                  ? null
                  : () {
                      HapticFeedback.selectionClick();
                      onTap!();
                    },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 11,
                ),
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: badge,
                        shape: BoxShape.circle,
                      ),
                      child: switch (status) {
                        OptionStatus.correct => Icon(
                          Icons.check_rounded,
                          size: 17,
                          color: onBadge,
                        ),
                        OptionStatus.wrong => Icon(
                          Icons.close_rounded,
                          size: 17,
                          color: onBadge,
                        ),
                        _ => Text(
                          letter,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: onBadge,
                          ),
                        ),
                      },
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: InlineCodeText(text)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class QuizFeedback extends StatelessWidget {
  const QuizFeedback({super.key, required this.quiz, required this.correct});

  final Quiz quiz;
  final bool correct;

  @override
  Widget build(BuildContext context) {
    final color = correct ? AppTheme.correct : AppTheme.wrong;
    return FadeSlideIn(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              correct ? 'Correct!' : 'Not quite',
              style: TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
            if (quiz.explanation.isNotEmpty) ...[
              const SizedBox(height: 4),
              InlineCodeText(quiz.explanation),
            ],
          ],
        ),
      ),
    );
  }
}

/// Plain text where `backtick` spans are shown as code.
class InlineCodeText extends StatelessWidget {
  const InlineCodeText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final parts = text.split('`');
    return Text.rich(
      TextSpan(
        style: TextStyle(fontSize: 15.5, height: 1.45, color: scheme.onSurface),
        children: [
          for (var i = 0; i < parts.length; i++)
            i.isOdd
                ? TextSpan(
                    text: parts[i],
                    style: TextStyle(
                      fontFamily: AppTheme.mono,
                      fontSize: 14.5,
                      backgroundColor: scheme.surfaceContainer,
                    ),
                  )
                : TextSpan(text: parts[i]),
        ],
      ),
    );
  }
}
