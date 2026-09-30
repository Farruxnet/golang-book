import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_info.dart';
import '../l10n/strings.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/markdown_view.dart';
import 'privacy_screen.dart';

/// The Config tab: how the book looks and behaves.
class ConfigScreen extends StatelessWidget {
  const ConfigScreen({super.key});

  static String _lineHeightLabel(S s, int i) =>
      [s.spacingCompact, s.spacingNormal, s.spacingRelaxed][i];

  @override
  Widget build(BuildContext context) {
    final state = context.appState;
    final s = context.s;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final range = AppState.fontScaleRange;

    return EntranceScope(
      child: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            FadeSlideIn(
              child: PageTitle(s.configTitle, subtitle: s.configHeading),
            ),
            FadeSlideIn(
              index: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionHeader(s.language),
                  AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final code in S.codes)
                              ChoiceChip(
                                label: Text(S.nativeNames[code]!),
                                selected: state.language == code,
                                onSelected: (_) => state.language = code,
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          s.languageHint,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
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
                  SectionHeader(s.appearance),
                  AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                            onSelectionChanged: (v) =>
                                state.themeMode = v.first,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(s.accentColor, style: theme.textTheme.labelLarge),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            for (var i = 0; i < AppTheme.accents.length; i++)
                              _AccentDot(
                                accent: AppTheme.accents[i],
                                name: s.accentName(i),
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
              index: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionHeader(s.reading),
                  AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                        Text(s.lineSpacing, style: theme.textTheme.labelLarge),
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
                                  label: Text(_lineHeightLabel(s, i)),
                                ),
                            ],
                            selected: {state.lineHeight},
                            onSelectionChanged: (v) =>
                                state.lineHeight = v.first,
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
                            data: s.sampleText,
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
              index: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionHeader(s.learning),
                  AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.dailyGoalMinutes,
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
                            onSelectionChanged: (v) =>
                                state.dailyGoal = v.first,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  AppCard(
                    child: SwitchListTile(
                      secondary: const Icon(Icons.vibration_rounded),
                      title: Text(s.haptics),
                      subtitle: Text(s.hapticsHint),
                      value: state.haptics,
                      onChanged: (v) => state.haptics = v,
                    ),
                  ),
                ],
              ),
            ),
            FadeSlideIn(
              index: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionHeader(s.data),
                  AppCard(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.settings_backup_restore),
                          title: Text(s.restoreDefaults),
                          subtitle: Text(s.progressKept),
                          onTap: () => _confirm(
                            context,
                            title: s.restoreDefaultsQ,
                            message: s.restoreDefaultsBody,
                            action: s.restore,
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
                            s.resetProgress,
                            style: TextStyle(color: scheme.error),
                          ),
                          subtitle: Text(s.resetProgressHint),
                          onTap: () => _confirm(
                            context,
                            title: s.resetProgressQ,
                            message: s.resetProgressBody,
                            action: s.reset,
                            onConfirm: state.resetProgress,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            FadeSlideIn(
              index: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionHeader(s.about),
                  AppCard(
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.privacy_tip_outlined),
                          title: Text(s.privacyPolicy),
                          subtitle: Text(s.privacyShort),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const PrivacyScreen(),
                            ),
                          ),
                        ),
                        const Divider(indent: 56),
                        ListTile(
                          leading: const Icon(Icons.public_rounded),
                          title: Text(s.website),
                          subtitle: const Text('go-lang.uz'),
                          trailing: const Icon(Icons.open_in_new_rounded),
                          onTap: () => launchUrl(
                            Uri.parse(AppInfo.website),
                            mode: LaunchMode.externalApplication,
                          ),
                        ),
                        const Divider(indent: 56),
                        ListTile(
                          leading: const Icon(Icons.description_outlined),
                          title: Text(s.licenses),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => showLicensePage(
                            context: context,
                            applicationName: AppInfo.name,
                            applicationVersion: AppInfo.version,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${AppInfo.name} · ${s.version(AppInfo.version)}',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
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
            child: Text(context.s.cancel),
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
    required this.name,
    required this.selected,
    required this.onTap,
  });

  final AccentColor accent;
  final String name;
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
      label: name,
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
