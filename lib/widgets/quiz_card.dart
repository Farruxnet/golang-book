import 'package:flutter/material.dart';

import '../data/models.dart';
import '../state/app_state.dart';
import '../theme.dart';
import 'markdown_view.dart';

const kCorrect = Color(0xFF22A06B);
const kWrong = Color(0xFFE5484D);

/// Interactive multiple-choice question. The answer is saved in [AppState],
/// so the card looks the same wherever the quiz appears.
class QuizCard extends StatelessWidget {
  const QuizCard({
    super.key,
    required this.quiz,
    this.label = 'Quick check',
    this.showRetry = true,
    this.onAnswered,
  });

  final Quiz quiz;
  final String label;
  final bool showRetry;
  final ValueChanged<bool>? onAnswered;

  @override
  Widget build(BuildContext context) {
    final state = context.appState;
    final theme = Theme.of(context);
    final accent = quiz.lesson.section.color;
    final selected = state.answerOf(quiz);
    final answered = selected != null;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.35), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.quiz_rounded, size: 18, color: accent),
              const SizedBox(width: 6),
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  color: accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              Text(
                '+${AppState.xpPerQuiz} XP',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          MarkdownView(
            data: quiz.question,
            accent: accent,
            fontScale: state.fontScale * 0.95,
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < quiz.options.length; i++)
            QuizOption(
              index: i,
              text: quiz.options[i],
              accent: accent,
              status: !answered
                  ? OptionStatus.idle
                  : i == quiz.answer
                  ? OptionStatus.correct
                  : i == selected
                  ? OptionStatus.wrong
                  : OptionStatus.dimmed,
              onTap: answered
                  ? null
                  : () {
                      final correct = state.answer(quiz, i);
                      onAnswered?.call(correct);
                    },
            ),
          if (answered) ...[
            const SizedBox(height: 6),
            QuizFeedback(quiz: quiz, correct: selected == quiz.answer),
            if (showRetry && selected != quiz.answer)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => state.clearAnswers([quiz]),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Try again'),
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
    required this.accent,
    required this.status,
    this.onTap,
  });

  final int index;
  final String text;
  final Color accent;
  final OptionStatus status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (Color border, Color fill, Widget badge) = switch (status) {
      OptionStatus.correct => (
        kCorrect,
        kCorrect.withValues(alpha: 0.12),
        const Icon(Icons.check_rounded, size: 18, color: Colors.white),
      ),
      OptionStatus.wrong => (
        kWrong,
        kWrong.withValues(alpha: 0.12),
        const Icon(Icons.close_rounded, size: 18, color: Colors.white),
      ),
      OptionStatus.selected => (
        accent,
        accent.withValues(alpha: 0.1),
        Text(
          String.fromCharCode(65 + index),
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
      _ => (
        scheme.outlineVariant,
        Colors.transparent,
        Text(
          String.fromCharCode(65 + index),
          style: TextStyle(fontWeight: FontWeight.w800, color: accent),
        ),
      ),
    };
    final badgeColor = switch (status) {
      OptionStatus.correct => kCorrect,
      OptionStatus.wrong => kWrong,
      OptionStatus.selected => accent,
      _ => accent.withValues(alpha: 0.12),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: status == OptionStatus.dimmed ? 0.5 : 1,
        child: Material(
          color: fill,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: border, width: 1.5),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: badgeColor,
                      shape: BoxShape.circle,
                    ),
                    child: badge,
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: InlineCodeText(text, accent: accent)),
                ],
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
    final color = correct ? kCorrect : kWrong;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            correct ? 'Correct! 🎉' : 'Not quite',
            style: TextStyle(color: color, fontWeight: FontWeight.w800),
          ),
          if (quiz.explanation.isNotEmpty) ...[
            const SizedBox(height: 4),
            InlineCodeText(quiz.explanation, accent: color),
          ],
        ],
      ),
    );
  }
}

/// Plain text where `backtick` spans are shown as code.
class InlineCodeText extends StatelessWidget {
  const InlineCodeText(this.text, {super.key, required this.accent});

  final String text;
  final Color accent;

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
                      backgroundColor: accent.withValues(alpha: 0.12),
                    ),
                  )
                : TextSpan(text: parts[i]),
        ],
      ),
    );
  }
}
