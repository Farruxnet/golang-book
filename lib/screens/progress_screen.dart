import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/quiz_card.dart';
import 'bookmarks_screen.dart';
import 'settings_sheet.dart';

const _purple = Color(0xFF8B5CF6);
const _orange = Color(0xFFFF8A00);

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

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text('Progress', style: theme.textTheme.headlineSmall),
          ),
          const SizedBox(height: 16),
          const _LevelCard(),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.1,
            children: [
              StatTile(
                leading: const _StatIcon(
                  Icons.local_fire_department_rounded,
                  _orange,
                ),
                title:
                    '${state.currentStreak} ${state.currentStreak == 1 ? 'day' : 'days'}',
                subtitle: 'Streak · best ${state.bestStreak}',
              ),
              StatTile(
                leading: const _StatIcon(
                  Icons.menu_book_rounded,
                  Color(0xFF00ADD8),
                ),
                title:
                    '${state.completedIn(book.allLessons)}/${book.allLessons.length}',
                subtitle: 'Lessons done',
              ),
              StatTile(
                leading: const _StatIcon(Icons.check_circle_rounded, kCorrect),
                title: accuracy,
                subtitle: 'Quiz accuracy',
              ),
              StatTile(
                leading: const _StatIcon(Icons.timer_rounded, _purple),
                title: '${state.totalMinutes} min',
                subtitle: 'Time learning',
              ),
            ],
          ),
          const SectionHeader('Activity', trailing: 'Last 12 weeks'),
          const _Heatmap(),
          const SectionHeader('Daily goal'),
          const _GoalPicker(),
          const SectionHeader('Sections'),
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Column(
                children: [
                  for (final s in book.sections)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          SectionBadge(section: s, size: 36),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        s.title,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ),
                                    Text(
                                      '${state.completedIn(s.lessons)}/${s.lessons.length}',
                                      style: theme.textTheme.labelMedium,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                LinearProgressIndicator(
                                  value: state.progressOf(s.lessons),
                                  color: s.color,
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
          ),
          const SectionHeader('Settings'),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.bookmarks_outlined),
                  title: const Text('Bookmarks'),
                  trailing: Text('${state.bookmarks.length}'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const BookmarksScreen(),
                    ),
                  ),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: const Text('Theme & text size'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => showSettingsSheet(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatIcon extends StatelessWidget {
  const _StatIcon(this.icon, this.color);

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard();

  @override
  Widget build(BuildContext context) {
    final state = context.appState;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_purple, Color(0xFF3B2A8C)],
        ),
      ),
      child: Row(
        children: [
          RingProgress(
            value: state.levelProgress,
            color: Colors.white,
            size: 72,
            stroke: 7,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'LVL',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '${state.level}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${state.xp} XP',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${state.xpToNextLevel} XP to level ${state.level + 1}',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                ),
                const SizedBox(height: 8),
                Text(
                  '+${AppState.xpPerLesson} per lesson · +${AppState.xpPerQuiz} per correct answer',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// GitHub-style grid: one column per week, Monday at the top.
class _Heatmap extends StatelessWidget {
  const _Heatmap();

  static const _weeks = 12;
  static const _gap = 4.0;

  @override
  Widget build(BuildContext context) {
    final state = context.appState;
    final theme = Theme.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = today.subtract(
      Duration(days: (today.weekday - 1) + 7 * (_weeks - 1)),
    );
    final goal = state.dailyGoal * 60;
    const color = kCorrect;

    Color cellColor(DateTime d) {
      if (d.isAfter(today)) return Colors.transparent;
      if (!state.isActiveOn(d)) return theme.colorScheme.outlineVariant;
      final ratio = (state.secondsOn(d) / goal).clamp(0.0, 1.0);
      return color.withValues(alpha: 0.3 + 0.7 * ratio);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            LayoutBuilder(
              builder: (context, box) {
                const labelWidth = 22.0;
                final cell =
                    (box.maxWidth - labelWidth - _gap * (_weeks - 1)) / _weeks;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: labelWidth,
                      child: Column(
                        children: [
                          for (final (i, l)
                              in 'M T W T F S S'.split(' ').indexed)
                            SizedBox(
                              height: cell + (i < 6 ? _gap : 0),
                              child: Text(
                                i.isEven ? l : '',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    for (var w = 0; w < _weeks; w++) ...[
                      Column(
                        children: [
                          for (var d = 0; d < 7; d++) ...[
                            Tooltip(
                              message: _label(
                                start.add(Duration(days: w * 7 + d)),
                                state,
                              ),
                              child: Container(
                                width: cell,
                                height: cell,
                                decoration: BoxDecoration(
                                  color: cellColor(
                                    start.add(Duration(days: w * 7 + d)),
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                  border:
                                      start.add(Duration(days: w * 7 + d)) ==
                                          today
                                      ? Border.all(
                                          color: theme.colorScheme.onSurface,
                                          width: 1.5,
                                        )
                                      : null,
                                ),
                              ),
                            ),
                            if (d < 6) const SizedBox(height: _gap),
                          ],
                        ],
                      ),
                      if (w < _weeks - 1) const SizedBox(width: _gap),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Less', style: theme.textTheme.labelSmall),
                const SizedBox(width: 6),
                for (final a in [0.0, 0.3, 0.65, 1.0])
                  Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.only(right: 3),
                    decoration: BoxDecoration(
                      color: a == 0
                          ? theme.colorScheme.outlineVariant
                          : color.withValues(alpha: a),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                const SizedBox(width: 3),
                Text('More', style: theme.textTheme.labelSmall),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _label(DateTime d, AppState state) {
    final m = state.secondsOn(d) ~/ 60;
    return '${d.day}.${d.month.toString().padLeft(2, '0')} · $m min';
  }
}

class _GoalPicker extends StatelessWidget {
  const _GoalPicker();

  @override
  Widget build(BuildContext context) {
    final state = context.appState;
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                RingProgress(
                  value: state.todayGoalProgress,
                  color: kCorrect,
                  child: const Icon(
                    Icons.flag_rounded,
                    size: 18,
                    color: kCorrect,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    state.todayGoalProgress >= 1
                        ? 'Goal reached today — nice! 🎯'
                        : '${state.todayMinutes} of ${state.dailyGoal} min today',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
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
    );
  }
}
