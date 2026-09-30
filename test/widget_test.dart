import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golang_book/data/book_repository.dart';
import 'package:golang_book/data/models.dart';
import 'package:golang_book/l10n/strings.dart';
import 'package:golang_book/main.dart';
import 'package:golang_book/screens/lesson_screen.dart';
import 'package:golang_book/state/app_state.dart';
import 'package:golang_book/theme.dart';
import 'package:golang_book/widgets/quiz_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late Book book;
  late AppState state;

  setUp(() async {
    // Most tests are about the app itself, not the first-launch flow.
    SharedPreferences.setMockInitialValues({'onboarded': true});
    state = AppState(await SharedPreferences.getInstance());
  });

  /// The real book has no quizzes yet, so quiz screens are tested on a small
  /// book of their own.
  Book quizBook() {
    const body =
        'Interfaces are implicit.\n\n'
        '```quiz\n'
        'How does a type implement an interface in Go?\n'
        '- With the `implements` keyword\n'
        '+ By having all of its methods\n'
        '> Interfaces are satisfied implicitly.\n'
        '```\n';
    return Book([
      Section(
        id: 'test',
        title: 'Test',
        subtitle: '',
        icon: Icons.book,
        color: Colors.blue,
        lessons: [
          Lesson(
            id: 'interfaces',
            title: 'Interfaces',
            summary: '',
            markdown: body,
            quizzes: Quiz.parseAll(body),
          ),
        ],
      ),
    ]);
  }

  Future<void> pumpApp(WidgetTester tester, {Book? withBook}) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    book =
        withBook ??
        (await tester.runAsync(() => BookRepository.load(rootBundle)))!;
    await tester.pumpWidget(GoBookApp(book: book, state: state));
    await tester.pumpAndSettle();
  }

  test('corrupted saved data falls back to defaults', () async {
    SharedPreferences.setMockInitialValues({
      'theme_mode': 42,
      'quiz_answers': '{"a": "oops", "b": 1}',
      'activity': 'not json',
      'font_scale': 9.0,
    });
    final s = AppState(await SharedPreferences.getInstance());
    expect(s.themeMode, ThemeMode.system);
    expect(s.fontScale, 1.4);
    expect(s.activeDays, 0);
    expect(s.bestStreak, 0);
  });

  test('quiz blocks are parsed', () {
    final q = Quiz.tryParse('Pick one\n- a\n+ `b`\n> because')!;
    expect(q.question, 'Pick one');
    expect(q.options, ['a', '`b`']);
    expect(q.answer, 1);
    expect(q.explanation, 'because');
    expect(Quiz.tryParse('No answer\n- a\n- b'), isNull);
  });

  testWidgets('read a lesson and complete it', (tester) async {
    await pumpApp(tester);

    expect(book.sections.map((s) => s.title), ['Go asoslari']);
    expect(find.text('Start here'), findsOneWidget);

    // The Start here card opens the first lesson of the book.
    await tester.tap(find.text('Start here'));
    await tester.pumpAndSettle();
    expect(find.byType(LessonScreen), findsOneWidget);

    final list = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.text('Mark as complete'),
      400,
      scrollable: list,
    );
    await tester.tap(find.text('Mark as complete'));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('Completed'), findsOneWidget);
    expect(find.textContaining('Next: '), findsOneWidget);
    expect(state.xp, AppState.xpPerLesson);
    expect(state.currentStreak, 1);

    // Back home, the continue card points at the next lesson.
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Continue reading'), -300);
    expect(find.text('Continue reading'), findsOneWidget);
  });

  testWidgets('answer a quiz inside a lesson', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    book = quizBook();
    final lesson = book.allLessons.single;
    await tester.pumpWidget(
      AppScope(
        book: book,
        state: state,
        child: MaterialApp(
          theme: AppTheme.light,
          home: LessonScreen(lesson: lesson),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final option = find.byWidgetPredicate(
      (w) => w is QuizOption && w.text == 'By having all of its methods',
    );
    await tester.scrollUntilVisible(
      option,
      400,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(option);
    await tester.pumpAndSettle();
    await tester.tap(option);
    await tester.pumpAndSettle();
    expect(find.text('Correct!'), findsOneWidget);
    expect(state.xp, AppState.xpPerQuiz);
  });

  testWidgets('practice and progress tabs render', (tester) async {
    await pumpApp(tester, withBook: quizBook());

    await tester.tap(find.text('Practice').last);
    await tester.pumpAndSettle();
    expect(find.text('By topic'), findsOneWidget);

    await tester.tap(find.text('Quick quiz'));
    await tester.pumpAndSettle();
    expect(find.text('Check'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Progress').last);
    await tester.pumpAndSettle();
    expect(find.text('Daily goal'), findsOneWidget);
    await tester.tap(find.text('15 min'));
    await tester.pump();
    expect(state.dailyGoal, 15);
  });

  testWidgets('config tab changes theme, accent and haptics', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Config').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect(state.themeMode, ThemeMode.dark);

    state.accent = 4;
    await tester.pumpAndSettle();
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.theme!.colorScheme.primary, AppTheme.accents[4].light);

    await tester.scrollUntilVisible(
      find.text('Haptic feedback'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Haptic feedback'));
    await tester.pump();
    expect(state.haptics, isFalse);

    state.resetPreferences();
    expect(state.language, 'en');
    expect(state.themeMode, ThemeMode.system);
    expect(state.accent, 0);
    expect(state.haptics, isTrue);
  });

  test('language is saved and unknown values fall back to system', () async {
    state.language = 'uz';
    final reloaded = AppState(await SharedPreferences.getInstance());
    expect(reloaded.language, 'uz');
    expect(reloaded.languageCode, 'uz');

    SharedPreferences.setMockInitialValues({'language': 'xx'});
    final bad = AppState(await SharedPreferences.getInstance());
    expect(bad.language, 'en');
    expect(S.defaultCode, 'en');
  });

  test('every language has its own texts', () {
    final all = [for (final c in S.codes) S(c)];
    for (final pick in <String Function(S)>[
      (s) => s.navLearn,
      (s) => s.markComplete,
      (s) => s.resetProgressBody,
      (s) => s.loadFailedBody,
      (s) => s.sampleText,
    ]) {
      final texts = all.map(pick).toList();
      expect(texts.every((t) => t.isNotEmpty), isTrue);
      expect(texts.toSet().length, S.codes.length);
    }
    expect(S('uz').minutes(5), '5 daqiqa');
    expect(S('en').minutes(5), '5 min');
    expect(S('ru').minutes(5), '5 мин');
  });

  testWidgets('language can be switched in Config', (tester) async {
    await pumpApp(tester);
    expect(find.text('Learn'), findsWidgets);

    await tester.tap(find.text('Config').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Русский'));
    await tester.pumpAndSettle();
    expect(state.languageCode, 'ru');
    expect(find.text('Учёба'), findsWidgets);
    expect(find.text('Learn'), findsNothing);

    await tester.tap(find.text("O'zbekcha"));
    await tester.pumpAndSettle();
    expect(state.languageCode, 'uz');
    expect(find.text("O'qish"), findsWidgets);
  });

  testWidgets('first launch: pick a language, read the intro, start', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    state = AppState(await SharedPreferences.getInstance());
    await pumpApp(tester);

    expect(state.onboarded, isFalse);
    expect(state.language, 'en');
    expect(find.text('Choose your language'), findsOneWidget);

    await tester.tap(find.text('Русский'));
    await tester.pumpAndSettle();
    expect(state.language, 'ru');
    expect(find.text('Выберите язык'), findsOneWidget);

    await tester.tap(find.text('Продолжить'));
    await tester.pumpAndSettle();
    expect(find.text('Изучайте Go шаг за шагом'), findsOneWidget);

    await tester.tap(find.text('Далее'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Далее'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Начать'));
    await tester.pumpAndSettle();

    expect(state.onboarded, isTrue);
    expect(find.text('Учёба'), findsWidgets);
  });

  testWidgets('the intro can be skipped', (tester) async {
    SharedPreferences.setMockInitialValues({});
    state = AppState(await SharedPreferences.getInstance());
    await pumpApp(tester);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(state.onboarded, isTrue);
    expect(state.language, 'en');
    expect(find.text('Start here'), findsOneWidget);
  });

  testWidgets('practice tab explains that there are no quizzes yet', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(book.allQuizzes, isEmpty);

    await tester.tap(find.text('Practice').last);
    await tester.pumpAndSettle();
    expect(find.text('No quizzes yet'), findsOneWidget);
    expect(find.text('Quick quiz'), findsNothing);
  });

  test('saved data about removed lessons is dropped', () async {
    SharedPreferences.setMockInitialValues({
      'onboarded': true,
      'completed': ['basic/01_introduction', 'test/interfaces'],
      'bookmarks': ['basic/02_variables'],
      'last_lesson': 'basic/01_introduction',
      'daily_goal': 7,
    });
    final s = AppState(await SharedPreferences.getInstance())
      ..prune(quizBook());
    expect(s.completedCount, 1);
    expect(s.bookmarks, isEmpty);
    expect(s.lastLessonKey, isNull);
    expect(s.dailyGoal, 10);
  });

  testWidgets('privacy policy opens from Config', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Config').last);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Privacy policy'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Privacy policy'));
    await tester.pumpAndSettle();
    expect(find.text('No tracking'), findsOneWidget);
  });
}
