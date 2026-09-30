import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'bookmarks_screen.dart';
import 'shell.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.appState;
    final book = context.book;
    final theme = Theme.of(context);
    final answered = book.allQuizzes.where(state.isAnswered).length;
    final accuracy = answered == 0
        ? '–'
        : '${(state.correctIn(book.allQuizzes) / answered * 100).round()}%';
    final streak = state.currentStreak;

    return EntranceScope(
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            FadeSlideIn(child: PageTitle(context.s.navProgress)),
            const SizedBox(height: 8),
            FadeSlideIn(
              index: 1,
              child: AppCard(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      _Stat(
                        value: '$streak',
                        label: context.s.dayStreak(streak),
                        color: streak > 0 ? AppTheme.streak : null,
                      ),
                      const VerticalDivider(width: 1),
                      _Stat(
                        value:
                            '${state.completedIn(book.allLessons)}/${book.allLessons.length}',
                        label: context.s.lessons,
                      ),
                      const VerticalDivider(width: 1),
                      _Stat(value: accuracy, label: context.s.quizAccuracy),
                    ],
                  ),
                ),
              ),
            ),
            const FadeSlideIn(index: 2, child: _DailyGoal()),
            FadeSlideIn(
              index: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionHeader(context.s.sections),
                  AppCard(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
                    child: Column(
                      children: [
                        for (final s in book.sections)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        s.title,
                                        style: theme.textTheme.bodyLarge,
                                      ),
                                    ),
                                    Text(
                                      '${state.completedIn(s.lessons)} / ${s.lessons.length}',
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(
                                            color: theme
                                                .colorScheme
                                                .onSurfaceVariant,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                ProgressLine(
                                  value: state.progressOf(s.lessons),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            FadeSlideIn(
              index: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionHeader(context.s.settings),
                  AppCard(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.bookmark_border_rounded),
                          title: Text(context.s.bookmarks),
                          trailing: Text('${state.bookmarks.length}'),
                          onTap: () => pushScreen<void>(
                            context,
                            const BookmarksScreen(),
                          ),
                        ),
                        const Divider(indent: 56),
                        ListTile(
                          leading: const Icon(Icons.tune_rounded),
                          title: Text(context.s.navConfig),
                          subtitle: Text(context.s.configSubtitle),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => Shell.goTo(context, ShellTab.config),
                        ),
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

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, this.color});

  final String value;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(color: color),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyGoal extends StatelessWidget {
  const _DailyGoal();

  @override
  Widget build(BuildContext context) {
    final state = context.appState;
    final theme = Theme.of(context);
    final reached = state.todayGoalProgress >= 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(context.s.dailyGoal),
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reached
                    ? context.s.goalReached
                    : context.s.minutesToday(
                        state.todayMinutes,
                        state.dailyGoal,
                      ),
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 10),
              ProgressLine(
                value: state.todayGoalProgress,
                color: AppTheme.correct,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final m in AppState.dailyGoalOptions)
                    ChoiceChip(
                      label: Text(context.s.minutes(m)),
                      selected: state.dailyGoal == m,
                      onSelected: (_) => state.dailyGoal = m,
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
