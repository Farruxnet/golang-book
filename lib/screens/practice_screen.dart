import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/models.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/quiz_card.dart';
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
    final theme = Theme.of(context);
    final topics = book.allLessons.where((l) => l.quizzes.isNotEmpty).toList();
    final projects = book.sections
        .where((s) => s.id == 'practice')
        .expand((s) => s.lessons)
        .toList();
    final answered = book.allQuizzes.where(state.isAnswered).length;
    final correct = state.correctIn(book.allQuizzes);

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Practice', style: theme.textTheme.headlineSmall),
                  Text(
                    'Test yourself and build real things',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (book.allQuizzes.isNotEmpty)
            SliverToBoxAdapter(
              child: _MixedQuizCard(
                total: book.allQuizzes.length,
                answered: answered,
                correct: correct,
                onStart: () => openQuizSession(
                  context,
                  title: 'Mixed quiz',
                  quizzes: _mixed(book, state),
                ),
              ),
            ),
          if (book.dailyQuiz case final quiz?)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: QuizCard(
                  quiz: quiz,
                  label: 'Daily challenge',
                  showRetry: false,
                ),
              ),
            ),
          if (topics.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: SectionHeader(
                'Quiz by topic',
                trailing: '${topics.length} topics',
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList.separated(
                itemCount: topics.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, i) => _TopicTile(lesson: topics[i]),
              ),
            ),
          ],
          if (projects.isNotEmpty) ...[
            const SliverToBoxAdapter(child: SectionHeader('Projects')),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              sliver: SliverList.builder(
                itemCount: projects.length,
                itemBuilder: (context, i) => LessonTile(lesson: projects[i]),
              ),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _MixedQuizCard extends StatelessWidget {
  const _MixedQuizCard({
    required this.total,
    required this.answered,
    required this.correct,
    required this.onStart,
  });

  final int total;
  final int answered;
  final int correct;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    final accuracy = answered == 0 ? 0 : (correct / answered * 100).round();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF8B5CF6), Color(0xFF5B3CC4)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.shuffle_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'MIXED QUIZ',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              '10 random questions',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$answered of $total answered · $accuracy% accuracy',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onStart,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF5B3CC4),
                minimumSize: const Size(0, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.w800),
              ),
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Start'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopicTile extends StatelessWidget {
  const _TopicTile({required this.lesson});

  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.appState;
    final total = lesson.quizzes.length;
    final correct = state.correctIn(lesson.quizzes);
    final color = lesson.section.color;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => openQuizSession(
          context,
          title: lesson.title,
          quizzes: lesson.quizzes,
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              RingProgress(
                value: correct / total,
                color: color,
                child: Icon(
                  correct == total ? Icons.star_rounded : Icons.quiz_rounded,
                  size: 20,
                  color: color,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.section.title.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(lesson.title, style: theme.textTheme.titleMedium),
                    Text(
                      '$correct of $total correct',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.play_circle_fill_rounded, size: 32, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
