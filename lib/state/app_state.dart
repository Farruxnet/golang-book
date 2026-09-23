import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models.dart';

/// Reader state persisted on device: progress, gamification and preferences.
class AppState extends ChangeNotifier {
  AppState(this._prefs)
    : _completed = _stringSet(_prefs, _kCompleted),
      _bookmarks = _stringSet(_prefs, _kBookmarks),
      _rewarded = _stringSet(_prefs, _kRewarded),
      _lastLessonKey = _safe(() => _prefs.getString(_kLastLesson), null),
      themeModeListenable = ValueNotifier(_readThemeMode(_prefs)),
      _fontScale =
          _safe(() => _prefs.getDouble(_kFontScale), null)?.clamp(0.85, 1.4) ??
          1.0,
      _xp = _safe(() => _prefs.getInt(_kXp), null) ?? 0,
      _dailyGoal = _safe(() => _prefs.getInt(_kDailyGoal), null) ?? 10,
      _answers = _readMap<int>(_prefs, _kAnswers),
      _activity = _readMap<int>(_prefs, _kActivity),
      _scroll = _readMap<num>(_prefs, _kScroll);

  static const _kCompleted = 'completed';
  static const _kBookmarks = 'bookmarks';
  static const _kRewarded = 'rewarded';
  static const _kLastLesson = 'last_lesson';
  static const _kTheme = 'theme_mode';
  static const _kFontScale = 'font_scale';
  static const _kXp = 'xp';
  static const _kDailyGoal = 'daily_goal';
  static const _kAnswers = 'quiz_answers';
  static const _kActivity = 'activity';
  static const _kScroll = 'scroll_offsets';

  static const xpPerLesson = 20;
  static const xpPerQuiz = 10;
  static const xpPerLevel = 200;
  static const dailyGoalOptions = [5, 10, 15, 20, 30];

  final SharedPreferences _prefs;
  final Set<String> _completed;
  final Set<String> _bookmarks;

  /// Lesson keys and quiz ids that already granted XP (no farming by toggling).
  final Set<String> _rewarded;
  String? _lastLessonKey;
  double _fontScale;
  int _xp;
  int _dailyGoal;

  /// Quiz id → last selected option.
  final Map<String, int> _answers;

  /// `yyyy-mm-dd` → seconds spent learning that day. A key with 0 seconds
  /// still counts as an active day (e.g. a quiz answered).
  final Map<String, int> _activity;

  /// Lesson key → last scroll offset, to resume reading where you left off.
  final Map<String, num> _scroll;

  /// Reads a JSON map, dropping entries of the wrong type. Converted eagerly:
  /// a lazy `cast` would throw later, far from here, on corrupted data.
  static Map<String, T> _readMap<T>(SharedPreferences p, String key) {
    final raw = p.getString(key);
    if (raw == null) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return {};
      return {
        for (final e in decoded.entries)
          if (e.key is String && e.value is T) e.key as String: e.value as T,
      };
    } catch (_) {
      return {};
    }
  }

  /// Stored values are ours, but a value of the wrong type (e.g. after an
  /// app update) must fall back to a default instead of crashing on launch.
  static T _safe<T>(T Function() read, T fallback) {
    try {
      return read();
    } catch (_) {
      return fallback;
    }
  }

  static Set<String> _stringSet(SharedPreferences p, String key) =>
      _safe(() => p.getStringList(key)?.toSet(), null) ?? {};

  static ThemeMode _readThemeMode(SharedPreferences p) {
    final i = _safe(() => p.getInt(_kTheme), null) ?? 0;
    return i >= 0 && i < ThemeMode.values.length
        ? ThemeMode.values[i]
        : ThemeMode.system;
  }

  void _writeMap(String key, Map<String, Object> map) =>
      _prefs.setString(key, jsonEncode(map));

  // ---- Reading progress -----------------------------------------------------

  String? get lastLessonKey => _lastLessonKey;
  Set<String> get bookmarks => Set.unmodifiable(_bookmarks);

  bool isCompleted(Lesson l) => _completed.contains(l.key);
  bool isBookmarked(Lesson l) => _bookmarks.contains(l.key);

  int get completedCount => _completed.length;

  int completedIn(Iterable<Lesson> lessons) =>
      lessons.where(isCompleted).length;

  double progressOf(Iterable<Lesson> lessons) {
    final list = lessons.toList();
    return list.isEmpty ? 0 : completedIn(list) / list.length;
  }

  void setCompleted(Lesson l, bool value) {
    value ? _completed.add(l.key) : _completed.remove(l.key);
    _prefs.setStringList(_kCompleted, _completed.toList());
    if (value) {
      _reward(l.key, xpPerLesson);
      _touchToday();
    }
    notifyListeners();
  }

  void toggleBookmark(Lesson l) {
    _bookmarks.contains(l.key)
        ? _bookmarks.remove(l.key)
        : _bookmarks.add(l.key);
    _prefs.setStringList(_kBookmarks, _bookmarks.toList());
    notifyListeners();
  }

  void markOpened(Lesson l) {
    if (_lastLessonKey == l.key) return;
    _lastLessonKey = l.key;
    _prefs.setString(_kLastLesson, l.key);
    notifyListeners();
  }

  double scrollOffsetOf(Lesson l) => (_scroll[l.key] ?? 0).toDouble();

  /// Saved silently: no listeners need to rebuild for this.
  void saveScrollOffset(Lesson l, double offset) {
    _scroll[l.key] = offset.roundToDouble();
    _writeMap(_kScroll, _scroll);
  }

  // ---- Quizzes ----------------------------------------------------------------

  int? answerOf(Quiz q) => _answers[q.id];
  bool isAnswered(Quiz q) => _answers.containsKey(q.id);
  bool isCorrect(Quiz q) => _answers[q.id] == q.answer;

  int correctIn(Iterable<Quiz> quizzes) => quizzes.where(isCorrect).length;

  /// Records an answer and returns whether it was correct.
  bool answer(Quiz q, int option) {
    _answers[q.id] = option;
    _writeMap(_kAnswers, _answers);
    final correct = option == q.answer;
    if (correct) _reward(q.id, xpPerQuiz);
    _touchToday();
    notifyListeners();
    return correct;
  }

  void clearAnswers(Iterable<Quiz> quizzes) {
    for (final q in quizzes) {
      _answers.remove(q.id);
    }
    _writeMap(_kAnswers, _answers);
    notifyListeners();
  }

  // ---- XP & levels ------------------------------------------------------------

  int get xp => _xp;
  int get level => _xp ~/ xpPerLevel + 1;
  double get levelProgress => (_xp % xpPerLevel) / xpPerLevel;
  int get xpToNextLevel => xpPerLevel - _xp % xpPerLevel;

  void _reward(String id, int amount) {
    if (!_rewarded.add(id)) return;
    _xp += amount;
    _prefs
      ..setInt(_kXp, _xp)
      ..setStringList(_kRewarded, _rewarded.toList());
  }

  // ---- Activity, streaks and daily goal ---------------------------------------

  static String dayKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static DateTime get _today {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  int get dailyGoal => _dailyGoal;

  set dailyGoal(int minutes) {
    _dailyGoal = minutes;
    _prefs.setInt(_kDailyGoal, minutes);
    notifyListeners();
  }

  int secondsOn(DateTime day) => _activity[dayKey(day)] ?? 0;
  bool isActiveOn(DateTime day) => _activity.containsKey(dayKey(day));

  int get todayMinutes => secondsOn(_today) ~/ 60;
  double get todayGoalProgress =>
      (secondsOn(_today) / (_dailyGoal * 60)).clamp(0.0, 1.0);

  int get totalMinutes => _activity.values.fold(0, (a, b) => a + b) ~/ 60;
  int get activeDays => _activity.length;

  void addLearningTime(Duration d) {
    if (d.inSeconds <= 0) return;
    final key = dayKey(_today);
    _activity[key] = (_activity[key] ?? 0) + d.inSeconds;
    _writeMap(_kActivity, _activity);
    notifyListeners();
  }

  void _touchToday() {
    final key = dayKey(_today);
    if (_activity.containsKey(key)) return;
    _activity[key] = 0;
    _writeMap(_kActivity, _activity);
  }

  /// Consecutive active days ending today (or yesterday, so a streak isn't
  /// shown as lost before the user has had a chance to study today).
  int get currentStreak {
    var day = _today;
    if (!isActiveOn(day)) day = day.subtract(const Duration(days: 1));
    var streak = 0;
    while (isActiveOn(day)) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int get bestStreak {
    final days = _activity.keys.map(DateTime.tryParse).nonNulls.toList()
      ..sort();
    var best = 0, run = 0;
    DateTime? prev;
    for (final d in days) {
      run = prev != null && d.difference(prev).inDays == 1 ? run + 1 : 1;
      best = math.max(best, run);
      prev = d;
    }
    return best;
  }

  // ---- Preferences --------------------------------------------------------------

  /// Separate from [notifyListeners] so only [MaterialApp] listens to it:
  /// progress changes must not rebuild the whole app.
  final ValueNotifier<ThemeMode> themeModeListenable;

  ThemeMode get themeMode => themeModeListenable.value;
  double get fontScale => _fontScale;

  set themeMode(ThemeMode mode) {
    themeModeListenable.value = mode;
    _prefs.setInt(_kTheme, mode.index);
    notifyListeners();
  }

  set fontScale(double value) {
    _fontScale = value;
    _prefs.setDouble(_kFontScale, value);
    notifyListeners();
  }

  void resetProgress() {
    _completed.clear();
    _rewarded.clear();
    _answers.clear();
    _activity.clear();
    _scroll.clear();
    _xp = 0;
    _lastLessonKey = null;
    for (final k in [
      _kCompleted,
      _kRewarded,
      _kAnswers,
      _kActivity,
      _kScroll,
      _kXp,
      _kLastLesson,
    ]) {
      _prefs.remove(k);
    }
    notifyListeners();
  }
}

/// Exposes [Book] and [AppState] to the widget tree.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({
    super.key,
    required this.book,
    required AppState state,
    required super.child,
  }) : super(notifier: state);

  final Book book;

  static AppScope _of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!;

  static AppState stateOf(BuildContext context) => _of(context).notifier!;
  static Book bookOf(BuildContext context) => _of(context).book;
}

extension AppScopeX on BuildContext {
  AppState get appState => AppScope.stateOf(this);
  Book get book => AppScope.bookOf(this);
}
