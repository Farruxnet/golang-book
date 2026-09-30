import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_info.dart';
import 'data/book_repository.dart';
import 'data/models.dart';
import 'l10n/strings.dart';
import 'screens/onboarding_screen.dart';
import 'screens/shell.dart';
import 'screens/splash_screen.dart';
import 'state/app_state.dart';
import 'theme.dart';

typedef BookLoader = Future<Book> Function(String language);

Future<Book> _loadFromAssets(String language) =>
    BookRepository.load(rootBundle, language: language);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _installErrorHandlers();
  unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));

  // Preferences are read before the first frame (it takes milliseconds and
  // decides theme and language); the lessons load behind the splash screen.
  final AppState state;
  try {
    state = AppState(
      await SharedPreferences.getInstance().timeout(const Duration(seconds: 5)),
    );
  } catch (error, stack) {
    _report(error, stack);
    runApp(const _LoadFailedApp());
    return;
  }
  runApp(GoBookApp(state: state));
}

void _report(Object error, StackTrace? stack) => FlutterError.reportError(
  FlutterErrorDetails(exception: error, stack: stack, library: 'go book'),
);

/// Errors are logged instead of tearing the app down; a broken widget shows
/// an empty space in release builds rather than a red screen.
void _installErrorHandlers() {
  FlutterError.onError = FlutterError.presentError;
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Uncaught error: $error\n$stack');
    return true;
  };
  if (kReleaseMode) {
    ErrorWidget.builder = (_) => const SizedBox.shrink();
  }
}

class GoBookApp extends StatefulWidget {
  const GoBookApp({
    super.key,
    required this.state,
    this.book,
    this.loadBook = _loadFromAssets,
  });

  final AppState state;

  /// A book that is already loaded (tests); otherwise it loads at startup
  /// behind the splash screen.
  final Book? book;

  /// Loads the lessons in a language; called again when the language changes.
  final BookLoader loadBook;

  @override
  State<GoBookApp> createState() => _GoBookAppState();
}

class _GoBookAppState extends State<GoBookApp> {
  /// Placeholder until the first load finishes; nothing reads it meanwhile.
  static final _empty = Book(const [], complete: false);

  late Book _book = widget.book ?? _empty;
  late bool _loading = widget.book == null;
  bool _failed = false;

  AppState get _state => widget.state;

  @override
  void initState() {
    super.initState();
    _state.languageListenable.addListener(_onLanguageChanged);
    if (_loading) _load(initial: true);
  }

  @override
  void dispose() {
    _state.languageListenable.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() => _load();

  /// Loads the book in the current language. On the first load the splash
  /// plays to its end; later loads swap the book in place and keep the old
  /// one if anything goes wrong.
  Future<void> _load({bool initial = false}) async {
    final language = _state.language;
    try {
      final load = widget.loadBook(language);
      final book = initial
          ? (await (
              load.timeout(const Duration(seconds: 20)),
              Future<void>.delayed(SplashScreen.duration),
            ).wait).$1
          : await load;
      // A newer language was picked while this one loaded.
      if (!mounted || language != _state.language) return;
      if (initial && book.complete) _state.prune(book);
      setState(() {
        _book = book;
        _loading = false;
        _failed = false;
      });
    } catch (error, stack) {
      _report(error, stack);
      if (!mounted || !_loading) return;
      setState(() => _failed = true);
    }
  }

  void _retry() {
    setState(() => _failed = false);
    _load(initial: true);
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      book: _book,
      state: _state,
      // Only theme mode and accent rebuild MaterialApp, not every progress
      // update.
      child: ListenableBuilder(
        listenable: Listenable.merge([
          _state.themeModeListenable,
          _state.accentListenable,
        ]),
        builder: (context, _) => MaterialApp(
          title: AppInfo.name,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.build(_state.accent, Brightness.light),
          darkTheme: AppTheme.build(_state.accent, Brightness.dark),
          themeMode: _state.themeMode,
          themeAnimationDuration: const Duration(milliseconds: 300),
          themeAnimationCurve: Curves.easeOutCubic,
          home: _Root(loading: _loading, failed: _failed, onRetry: _retry),
        ),
      ),
    );
  }
}

/// Splash → welcome flow or the app, cross-faded. Reads the state through
/// the scope, so finishing the welcome flow swaps the screen without
/// rebuilding MaterialApp.
class _Root extends StatelessWidget {
  const _Root({
    required this.loading,
    required this.failed,
    required this.onRetry,
  });

  final bool loading;
  final bool failed;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final Widget child;
    if (failed) {
      child = _LoadFailedView(key: const ValueKey('failed'), onRetry: onRetry);
    } else if (loading) {
      child = const SplashScreen(key: ValueKey('splash'));
    } else if (!context.appState.onboarded) {
      child = const OnboardingScreen(key: ValueKey('onboarding'));
    } else {
      child = const Shell(key: ValueKey('shell'));
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 450),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween(begin: 0.97, end: 1.0).animate(animation),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

class _LoadFailedApp extends StatelessWidget {
  const _LoadFailedApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const _LoadFailedView(),
    );
  }
}

/// Startup failed: explain it and offer to try again (or close the app when
/// there is nothing to retry).
class _LoadFailedView extends StatelessWidget {
  const _LoadFailedView({super.key, this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    // The saved language may be what failed to load, so use the device's.
    final s = S.device();
    return Scaffold(
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
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(s.loadFailedBody, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              if (onRetry != null)
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(s.tryAgain),
                )
              else
                FilledButton(
                  onPressed: SystemNavigator.pop,
                  child: Text(s.close),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
