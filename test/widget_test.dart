import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golang_book/data/book_repository.dart';
import 'package:golang_book/data/models.dart';
import 'package:golang_book/main.dart';
import 'package:golang_book/screens/lesson_screen.dart';
import 'package:golang_book/state/app_state.dart';
import 'package:golang_book/widgets/quiz_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late Book book;
  late AppState state;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    state = AppState(await SharedPreferences.getInstance());
  });

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    book = (await tester.runAsync(() => BookRepository.load(rootBundle)))!;
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

  testWidgets('read a lesson, answer its quiz, complete it', (tester) async {
    await pumpApp(tester);

    expect(book.sections.map((s) => s.title), [
      'Basic',
      'Advanced',
      'Practice',
    ]);
    expect(book.allQuizzes, isNotEmpty);
    expect(find.text('Start here'), findsOneWidget);

    await tester.ensureVisible(find.text('Introduction to Go').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Introduction to Go').last);
    await tester.pumpAndSettle();
    expect(find.text('Your first program'), findsOneWidget);
    expect(find.text('Run'), findsOneWidget);

    final list = find.byType(Scrollable).first;
    // Scope to the lesson: offstage tabs also contain quiz cards.
    final option = find.descendant(
      of: find.byType(LessonScreen),
      matching: find.byWidgetPredicate(
        (w) => w is QuizOption && w.text == '`go run main.go`',
      ),
    );
    await tester.scrollUntilVisible(option.first, 400, scrollable: list);
    await tester.ensureVisible(option.first);
    await tester.pumpAndSettle();
    await tester.tap(option.first);
    await tester.pumpAndSettle();
    expect(find.text('Correct!'), findsOneWidget);
    expect(state.xp, AppState.xpPerQuiz);

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
    expect(state.xp, AppState.xpPerQuiz + AppState.xpPerLesson);
    expect(state.currentStreak, 1);

    // Back home, the continue card points at the next lesson.
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Continue reading'), -300);
    expect(find.text('Continue reading'), findsOneWidget);
  });

  testWidgets('practice and progress tabs render', (tester) async {
    await pumpApp(tester);

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
}
