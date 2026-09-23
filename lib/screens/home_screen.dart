import 'package:flutter/material.dart';

import '../data/models.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/quiz_card.dart';
import 'quiz_session_screen.dart';
import 'bookmarks_screen.dart';
import 'search_screen.dart';
import 'shell.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final book = context.book;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: _Header()),
            const SliverToBoxAdapter(child: _ProgressHero()),
            const SliverToBoxAdapter(child: _TodayRow()),
            if (book.dailyQuiz case final quiz?)
              SliverToBoxAdapter(child: _DailyBanner(quiz: quiz)),
            SliverToBoxAdapter(
              child: SectionHeader(
                'Sections',
                trailing: '${book.allLessons.length} lessons',
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              sliver: SliverList.separated(
                itemCount: book.sections.length,
                separatorBuilder: (_, _) => const SizedBox(height: 16),
                itemBuilder: (context, i) =>
                    _SectionCard(section: book.sections[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 20),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.goBlue, Color(0xFF0A7EA4)],
              ),
            ),
            child: const Text(
              'Go',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Learn Go', style: theme.textTheme.headlineSmall),
                Text(
                  'From basics to real projects',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SearchScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Bookmarks',
            icon: const Icon(Icons.bookmarks_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const BookmarksScreen()),
            ),
          ),
          const SizedBox(width: 4),
          const _StreakChip(),
        ],
      ),
    );
  }
}

class _ProgressHero extends StatelessWidget {
  const _ProgressHero();

  @override
  Widget build(BuildContext context) {
    final book = context.book;
    final state = context.appState;
    final done = state.completedIn(book.allLessons);
    final total = book.allLessons.length;
    final progress = total == 0 ? 0.0 : done / total;

    final last = book.lessonByKey(state.lastLessonKey);
    final next =
        last ??
        book.allLessons.where((l) => !state.isCompleted(l)).firstOrNull ??
        book.allLessons.firstOrNull;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF00ADD8), Color(0xFF0A6E9E), Color(0xFF223C7A)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.goBlue.withValues(alpha: 0.3),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(right: -40, top: -50, child: _circle(170, 0.10)),
            Positioned(right: 50, bottom: -70, child: _circle(140, 0.07)),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'YOUR PROGRESS',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.75),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '$done of $total lessons',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 64,
                        height: 64,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CircularProgressIndicator(
                              value: progress,
                              strokeWidth: 6,
                              strokeCap: StrokeCap.round,
                              color: Colors.white,
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.2,
                              ),
                            ),
                            Center(
                              child: Text(
                                '${(progress * 100).round()}%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (next != null) ...[
                    const SizedBox(height: 20),
                    Material(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => openLesson(context, next),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: next.section.color.withValues(
                                    alpha: 0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.play_arrow_rounded,
                                  color: next.section.color,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      last == null
                                          ? 'Start learning'
                                          : 'Continue reading',
                                      style: const TextStyle(
                                        color: Color(0xFF5B6675),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      next.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Color(0xFF0D1117),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                color: Color(0xFF0D1117),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _circle(double size, double alpha) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withValues(alpha: alpha),
    ),
  );
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.section});

  static const _previewCount = 3;

  final Section section;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.appState;
    final muted = theme.colorScheme.onSurfaceVariant;
    final done = state.completedIn(section.lessons);
    final progress = state.progressOf(section.lessons);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => openSection(context, section),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SectionBadge(section: section),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(section.title, style: theme.textTheme.titleLarge),
                        const SizedBox(height: 2),
                        Text(
                          section.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _Stat(
                    icon: Icons.menu_book_rounded,
                    text: '${section.lessons.length} lessons',
                  ),
                  const SizedBox(width: 16),
                  _Stat(
                    icon: Icons.schedule_rounded,
                    text: '${section.totalMinutes} min',
                  ),
                  const Spacer(),
                  Text(
                    '$done/${section.lessons.length}',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: section.color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(value: progress, color: section.color),
              const SizedBox(height: 12),
              for (final lesson in section.lessons.take(_previewCount))
                _LessonPreviewRow(lesson: lesson),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => openSection(context, section),
                  style: TextButton.styleFrom(foregroundColor: section.color),
                  iconAlignment: IconAlignment.end,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: Text(
                    section.lessons.length > _previewCount
                        ? 'All ${section.lessons.length} lessons'
                        : 'Open section',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: muted),
        const SizedBox(width: 5),
        Text(text, style: theme.textTheme.labelLarge?.copyWith(color: muted)),
      ],
    );
  }
}

class _LessonPreviewRow extends StatelessWidget {
  const _LessonPreviewRow({required this.lesson});

  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final done = context.appState.isCompleted(lesson);
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => openLesson(context, lesson),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 2),
        child: Row(
          children: [
            LessonNumber(lesson: lesson, done: done, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                lesson.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: done
                      ? theme.colorScheme.onSurfaceVariant
                      : theme.colorScheme.onSurface,
                ),
              ),
            ),
            Text(
              '${lesson.minutes} min',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StreakChip extends StatelessWidget {
  const _StreakChip();

  @override
  Widget build(BuildContext context) {
    final streak = context.appState.currentStreak;
    const orange = Color(0xFFFF8A00);
    return Tooltip(
      message: '$streak day streak',
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Shell.goTo(context, ShellTab.progress),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: orange.withValues(alpha: streak > 0 ? 0.15 : 0.07),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.local_fire_department_rounded,
                size: 20,
                color: streak > 0 ? orange : orange.withValues(alpha: 0.45),
              ),
              const SizedBox(width: 2),
              Text(
                '$streak',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: orange,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Daily goal and level at a glance.
class _TodayRow extends StatelessWidget {
  const _TodayRow();

  @override
  Widget build(BuildContext context) {
    final state = context.appState;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: StatTile(
              onTap: () => Shell.goTo(context, ShellTab.progress),
              leading: RingProgress(
                value: state.todayGoalProgress,
                color: kCorrect,
                child: Icon(
                  state.todayGoalProgress >= 1
                      ? Icons.check_rounded
                      : Icons.flag_rounded,
                  size: 18,
                  color: kCorrect,
                ),
              ),
              title: '${state.todayMinutes}/${state.dailyGoal} min',
              subtitle: 'Daily goal',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatTile(
              onTap: () => Shell.goTo(context, ShellTab.progress),
              leading: RingProgress(
                value: state.levelProgress,
                color: const Color(0xFF8B5CF6),
                child: Text(
                  '${state.level}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF8B5CF6),
                  ),
                ),
              ),
              title: '${state.xp} XP',
              subtitle: 'Level ${state.level}',
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact entry to today's question; the full card lives in Practice.
class _DailyBanner extends StatelessWidget {
  const _DailyBanner({required this.quiz});

  final Quiz quiz;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = context.appState;
    final solved = state.isCorrect(quiz);
    const orange = Color(0xFFFF8A00);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            if (!solved) state.clearAnswers([quiz]);
            openQuizSession(context, title: 'Daily challenge', quizzes: [quiz]);
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: (solved ? kCorrect : orange).withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    solved ? Icons.check_rounded : Icons.emoji_events_rounded,
                    color: solved ? kCorrect : orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily challenge',
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        solved
                            ? 'Solved! Come back tomorrow'
                            : 'One question · +${AppState.xpPerQuiz} XP',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
