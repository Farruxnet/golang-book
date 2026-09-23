import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'bookmarks_screen.dart';
import 'settings_sheet.dart';

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
            const FadeSlideIn(child: PageTitle('Progress')),
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
                        label: streak == 1 ? 'day streak' : 'days streak',
                        color: streak > 0 ? AppTheme.streak : null,
                      ),
                      const VerticalDivider(width: 1),
                      _Stat(
                        value:
                            '${state.completedIn(book.allLessons)}/${book.allLessons.length}',
                        label: 'lessons',
                      ),
                      const VerticalDivider(width: 1),
                      _Stat(value: accuracy, label: 'quiz accuracy'),
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
                  const SectionHeader('Sections'),
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
                  const SectionHeader('Settings'),
                  AppCard(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.bookmark_border_rounded),
                          title: const Text('Bookmarks'),
                          trailing: Text('${state.bookmarks.length}'),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const BookmarksScreen(),
                            ),
                          ),
                        ),
                        const Divider(indent: 56),
                        ListTile(
                          leading: const Icon(Icons.tune_rounded),
                          title: const Text('Theme & text size'),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => showSettingsSheet(context),
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
        const SectionHeader('Daily goal'),
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                reached
                    ? 'Goal reached today. Nice!'
                    : '${state.todayMinutes} of ${state.dailyGoal} min today',
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
                      label: Text('$m min'),
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
