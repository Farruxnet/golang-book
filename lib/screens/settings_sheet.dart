import 'package:flutter/material.dart';

import '../state/app_state.dart';

Future<void> showSettingsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    builder: (_) => const _SettingsSheet(),
  );
}

class _SettingsSheet extends StatelessWidget {
  const _SettingsSheet();

  static const _min = 0.85;
  static const _max = 1.4;

  @override
  Widget build(BuildContext context) {
    final state = context.appState;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Reading settings', style: theme.textTheme.titleLarge),
          const SizedBox(height: 20),
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
              onSelectionChanged: (s) => state.themeMode = s.first,
            ),
          ),
          const SizedBox(height: 24),
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
                  value: state.fontScale.clamp(_min, _max),
                  min: _min,
                  max: _max,
                  divisions: 11,
                  onChanged: (v) => state.fontScale = v,
                ),
              ),
              const Text('A', style: TextStyle(fontSize: 24)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
              icon: const Icon(Icons.restart_alt_rounded),
              label: const Text('Reset reading progress'),
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Reset progress?'),
                    content: const Text(
                      'All lessons will be marked as not completed.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                );
                if (ok == true) state.resetProgress();
              },
            ),
          ),
        ],
      ),
    );
  }
}
