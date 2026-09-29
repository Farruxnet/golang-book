import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/markdown_view.dart';

/// The Config tab: how the book looks and behaves.
class ConfigScreen extends StatelessWidget {
  const ConfigScreen({super.key});

  static const _sample =
      'Go is **simple** and fast. Print a line with `fmt.Println("Salom")` '
      'and run it with `go run main.go`.';

  static const _lineHeightLabels = ['Compact', 'Normal', 'Relaxed'];

  @override
  Widget build(BuildContext context) {
    final state = context.appState;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final range = AppState.fontScaleRange;

    return EntranceScope(
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            const FadeSlideIn(
              child: PageTitle(
                'Config',
                subtitle: 'Make the book look and feel the way you like',
              ),
            ),
            FadeSlideIn(
              index: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SectionHeader('Appearance'),
                  AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Theme', style: theme.textTheme.labelLarge),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: SegmentedButton<ThemeMode>(
                            segments: const [
                              ButtonSegment(
                                value: ThemeMode.system,
                                icon: Icon(Icons.brightness_auto_rounded),
                                label: Text('System'),
                              ),
                              ButtonSegment(
                                value: ThemeMode.light,
                                icon: Icon(Icons.light_mode_rounded),
                                label: Text('Light'),
                              ),
                              ButtonSegment(
                                value: ThemeMode.dark,
                                icon: Icon(Icons.dark_mode_rounded),
                                label: Text('Dark'),
                              ),
                            ],
                            selected: {state.themeMode},
                            onSelectionChanged: (s) =>
                                state.themeMode = s.first,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text('Accent color', style: theme.textTheme.labelLarge),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            for (var i = 0; i < AppTheme.accents.length; i++)
                              _AccentDot(
                                accent: AppTheme.accents[i],
                                selected: state.accent == i,
                                onTap: () => state.accent = i,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            FadeSlideIn(
              index: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SectionHeader('Reading'),
                  AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text('Text size', style: theme.textTheme.labelLarge),
                            const Spacer(),
                            Text(
                              '${(state.fontScale * 100).round()}%',
                              style: theme.textTheme.labelLarge,
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Text('A', style: TextStyle(fontSize: 14)),
                            Expanded(
                              child: Slider(
                                value: state.fontScale.clamp(
                                  range.min,
                                  range.max,
                                ),
                                min: range.min,
                                max: range.max,
                                divisions: 11,
                                onChanged: (v) => state.fontScale = v,
                              ),
                            ),
                            const Text('A', style: TextStyle(fontSize: 24)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('Line spacing', style: theme.textTheme.labelLarge),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: SegmentedButton<double>(
                            showSelectedIcon: false,
                            segments: [
                              for (var i = 0;
                                  i < AppState.lineHeightOptions.length;
                                  i++)
                                ButtonSegment(
                                  value: AppState.lineHeightOptions[i],
                                  label: Text(_lineHeightLabels[i]),
                                ),
                            ],
                            selected: {state.lineHeight},
                            onSelectionChanged: (s) =>
                                state.lineHeight = s.first,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: MarkdownView(
                            data: _sample,
                            fontScale: state.fontScale,
                            lineHeight: state.lineHeight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            FadeSlideIn(
              index: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SectionHeader('Learning'),
                  AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily goal (minutes)',
                          style: theme.textTheme.labelLarge,
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: SegmentedButton<int>(
                            showSelectedIcon: false,
                            segments: [
                              for (final m in AppState.dailyGoalOptions)
                                ButtonSegment(value: m, label: Text('$m')),
                            ],
                            selected: {state.dailyGoal},
                            onSelectionChanged: (s) =>
                                state.dailyGoal = s.first,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  AppCard(
                    child: SwitchListTile(
                      secondary: const Icon(Icons.vibration_rounded),
                      title: const Text('Haptic feedback'),
                      subtitle: const Text('Vibrate on taps and quiz answers'),
                      value: state.haptics,
                      onChanged: (v) => state.haptics = v,
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
                  const SectionHeader('Data'),
                  AppCard(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.settings_backup_restore),
                          title: const Text('Restore default settings'),
                          subtitle: const Text('Progress is kept'),
                          onTap: () => _confirm(
                            context,
                            title: 'Restore default settings?',
                            message:
                                'Theme, accent color, text size, line spacing, '
                                'daily goal and haptics go back to defaults.',
                            action: 'Restore',
                            onConfirm: state.resetPreferences,
                          ),
                        ),
                        const Divider(indent: 56),
                        ListTile(
                          leading: Icon(
                            Icons.restart_alt_rounded,
                            color: scheme.error,
                          ),
                          title: Text(
                            'Reset progress',
                            style: TextStyle(color: scheme.error),
                          ),
                          subtitle: const Text('Lessons, quiz answers, streaks'),
                          onTap: () => _confirm(
                            context,
                            title: 'Reset progress?',
                            message:
                                'Completed lessons, quiz answers and streaks '
                                'will be cleared. Bookmarks and settings are '
                                'kept.',
                            action: 'Reset',
                            onConfirm: state.resetProgress,
                          ),
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

  static Future<void> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String action,
    required VoidCallback onConfirm,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(action),
          ),
        ],
      ),
    );
    if (ok == true) onConfirm();
  }
}

class _AccentDot extends StatelessWidget {
  const _AccentDot({
    required this.accent,
    required this.selected,
    required this.onTap,
  });

  final AccentColor accent;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // The same shade the theme uses for its primary color.
    final color = Theme.of(context).brightness == Brightness.dark
        ? accent.dark
        : accent.light;
    return Semantics(
      button: true,
      selected: selected,
      label: accent.name,
      child: InkResponse(
        onTap: onTap,
        radius: 28,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(
              color: selected ? scheme.onSurface : Colors.transparent,
              width: 2.5,
            ),
          ),
          child: selected
              ? Icon(
                  Icons.check_rounded,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? accent.onDark
                      : Colors.white,
                )
              : null,
        ),
      ),
    );
  }
}
