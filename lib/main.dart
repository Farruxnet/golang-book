import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/book_repository.dart';
import 'data/models.dart';
import 'screens/shell.dart';
import 'state/app_state.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  final (prefs, book) = await (
    SharedPreferences.getInstance(),
    BookRepository.load(rootBundle),
  ).wait;

  runApp(GoBookApp(book: book, state: AppState(prefs)));
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
      child: ListenableBuilder(
        listenable: state,
        builder: (context, _) => MaterialApp(
          title: 'Go Programming',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: state.themeMode,
          home: const Shell(),
        ),
      ),
    );
  }
}
