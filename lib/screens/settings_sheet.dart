import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../widgets/common.dart';

/// Reading settings opened from a lesson: theme and text size.
Future<void> showSettingsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    sheetAnimationStyle: const AnimationStyle(
      duration: Duration(milliseconds: 320),
      reverseDuration: Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ),
    builder: (_) => const _SettingsSheet(),
  );
}

class _SettingsSheet extends StatelessWidget {
  const _SettingsSheet();

  @override
  Widget build(BuildContext context) {
    final state = context.appState;
    final theme = Theme.of(context);
    final s = context.s;

    // The app draws edge-to-edge, so the sheet must keep clear of the system
    // navigation bar itself (useSafeArea only covers the top and sides). It
    // scrolls when large text or a small screen makes it taller than the
    // space above the bar.
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.appearance, style: theme.textTheme.titleLarge),
            const SizedBox(height: 20),
            Text(s.theme, style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            const ThemeModeSelector(),
            const SizedBox(height: 24),
            const FontScaleSlider(),
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
                onPressed: () => confirmAction(
                  context,
                  title: s.resetProgressQ,
                  message: s.resetProgressBody,
                  action: s.reset,
                  onConfirm: state.resetProgress,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
