import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/book_repository.dart';
import 'data/models.dart';
import 'l10n/strings.dart';
import 'screens/shell.dart';
import 'state/app_state.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _installErrorHandlers();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // The native splash stays up while this loads, so there is no blank frame.
  try {
    final (prefs, book) = await (
      SharedPreferences.getInstance(),
      BookRepository.load(rootBundle),
    ).wait;
    runApp(GoBookApp(book: book, state: AppState(prefs)));
  } catch (error, stack) {
    FlutterError.reportError(
      FlutterErrorDetails(exception: error, stack: stack),
    );
    runApp(const _LoadFailedApp());
  }
}

/// Errors are logged instead of tearing the app down; a broken widget shows
/// an empty space in release builds rather than a red screen.
void _installErrorHandlers() {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Uncaught error: $error\n$stack');
    return true;
  };
  if (kReleaseMode) {
    ErrorWidget.builder = (_) => const SizedBox.shrink();
  }
}

class GoBookApp extends StatelessWidget {
  const GoBookApp({super.key, required this.book, required this.state});

  final Book book;
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return AppScope(
      book: book,
      state: state,
      // Only theme mode and accent rebuild MaterialApp, not every progress
      // update.
      child: ListenableBuilder(
        listenable: Listenable.merge([
          state.themeModeListenable,
          state.accentListenable,
        ]),
        builder: (context, _) => MaterialApp(
          title: 'Go Book',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.build(state.accent, Brightness.light),
          darkTheme: AppTheme.build(state.accent, Brightness.dark),
          themeMode: state.themeMode,
          themeAnimationDuration: const Duration(milliseconds: 250),
          home: const Shell(),
        ),
      ),
    );
  }
}

class _LoadFailedApp extends StatelessWidget {
  const _LoadFailedApp();

  @override
  Widget build(BuildContext context) {
    // The app state did not load, so the device language is all we have.
    final s = S.device();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.menu_book_outlined, size: 48),
                const SizedBox(height: 16),
                Text(
                  s.loadFailedTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(s.loadFailedBody, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => SystemNavigator.pop(),
                  child: Text(s.close),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
