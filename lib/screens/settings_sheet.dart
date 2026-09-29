import 'package:flutter/material.dart';

import '../state/app_state.dart';

Future<void> showSettingsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
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
    final s = context.s;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.appearance, style: theme.textTheme.titleLarge),
          const SizedBox(height: 20),
          Text(s.theme, style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: const Icon(Icons.brightness_auto_rounded),
                  label: Text(s.themeSystem),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: const Icon(Icons.light_mode_rounded),
                  label: Text(s.themeLight),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: const Icon(Icons.dark_mode_rounded),
                  label: Text(s.themeDark),
                ),
              ],
              selected: {state.themeMode},
              onSelectionChanged: (v) => state.themeMode = v.first,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text(s.textSize, style: theme.textTheme.labelLarge),
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
          const Divider(),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
              icon: const Icon(Icons.restart_alt_rounded),
              label: Text(s.resetProgress),
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(s.resetProgressQ),
                    content: Text(s.resetProgressBody),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text(s.cancel),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text(s.reset),
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
