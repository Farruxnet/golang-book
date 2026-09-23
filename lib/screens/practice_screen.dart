import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/models.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'quiz_session_screen.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  static const _mixedCount = 10;

  /// Random questions, preferring lessons the reader has finished.
  static List<Quiz> _mixed(Book book, AppState state) {
    final done = book.allQuizzes.where((q) => state.isCompleted(q.lesson));
    final pool = (done.length >= 5 ? done : book.allQuizzes).toList()
      ..shuffle(math.Random());
    return pool.take(_mixedCount).toList();
  }

  @override
  Widget build(BuildContext context) {
    final book = context.book;
    final state = context.appState;
    final topics = book.allLessons.where((l) => l.quizzes.isNotEmpty).toList();
    final daily = book.dailyQuiz;

    return EntranceScope(
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            const FadeSlideIn(
              child: PageTitle(
                'Practice',
                subtitle: 'Short quizzes to check what you learned',
              ),
            ),
            const SizedBox(height: 8),
            if (book.allQuizzes.isNotEmpty)
              FadeSlideIn(
                index: 1,
                child: _ActionCard(
                  icon: Icons.shuffle_rounded,
                  title: 'Quick quiz',
                  subtitle: '$_mixedCount random questions',
                  onTap: () => openQuizSession(
                    context,
                    title: 'Quick quiz',
                    quizzes: _mixed(book, state),
                  ),
                ),
              ),
            if (daily != null) ...[
              const SizedBox(height: 10),
              FadeSlideIn(
                index: 2,
                child: _ActionCard(
                  icon: state.isCorrect(daily)
                      ? Icons.check_rounded
                      : Icons.today_rounded,
                  iconColor: state.isCorrect(daily) ? AppTheme.correct : null,
                  title: 'Question of the day',
                  subtitle: state.isCorrect(daily)
                      ? 'Solved. See you tomorrow!'
                      : 'One question, new every day',
                  onTap: () {
                    if (!state.isCorrect(daily)) state.clearAnswers([daily]);
                    openQuizSession(
                      context,
                      title: 'Question of the day',
                      quizzes: [daily],
                    );
                  },
                ),
              ),
            ],
            if (topics.isNotEmpty)
              FadeSlideIn(
                index: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SectionHeader('By topic'),
                    AppCard(
                      child: Column(
                        children: [
                          for (final (i, lesson) in topics.indexed) ...[
                            if (i > 0) const Divider(indent: 16),
                            _TopicRow(lesson: lesson),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final Color? iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = iconColor ?? scheme.primary;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
        ],
      ),
    );
  }
}

class _TopicRow extends StatelessWidget {
  const _TopicRow({required this.lesson});

  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final state = context.appState;
    final total = lesson.quizzes.length;
    final correct = state.correctIn(lesson.quizzes);

    return InkWell(
      onTap: () => openQuizSession(
        context,
        title: lesson.title,
        quizzes: lesson.quizzes,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$correct of $total correct',
                    style: theme.textTheme.bodySmall?.copyWith(color: muted),
                  ),
                ],
              ),
            ),
            if (correct == total)
              const Icon(Icons.check_circle_rounded, color: AppTheme.correct)
            else
              Icon(Icons.chevron_right_rounded, color: muted),
          ],
        ),
      ),
    );
  }
}
