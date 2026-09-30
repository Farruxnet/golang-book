import 'package:flutter/material.dart';

import '../app_info.dart';
import '../state/app_state.dart';

/// The privacy policy, in the app's language. PRIVACY.md holds the same text
/// for the store listing.
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.privacyPolicy)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            s.privacyUpdated(AppInfo.privacyUpdated),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          for (final (title, body) in s.privacySections) ...[
            const SizedBox(height: 20),
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(body, style: theme.textTheme.bodyLarge?.copyWith(height: 1.5)),
          ],
        ],
      ),
    );
  }
}
