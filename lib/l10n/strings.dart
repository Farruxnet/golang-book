import 'dart:ui';

/// Interface texts of the app in Uzbek, English and Russian.
///
/// Lesson content is not translated here; it comes from the book itself.
/// Each text is a getter (or a method when it has parameters) with its three
/// translations side by side, so a missing translation is easy to spot.
class S {
  const S(this.code);

  /// The language of the device if the app has it, otherwise English. Only
  /// for the startup failure screen, where no saved choice can be read.
  factory S.device() {
    final device = PlatformDispatcher.instance.locale.languageCode;
    return S(codes.contains(device) ? device : 'en');
  }

  /// Language codes the app is translated into. English is the default.
  static const codes = ['uz', 'en', 'ru'];
  static const defaultCode = 'en';

  /// The language named in English, shown under its own name.
  static const englishNames = {
    'uz': 'Uzbek',
    'en': 'English',
    'ru': 'Russian',
  };

  /// Language names are written in their own language everywhere.
  static const nativeNames = {
    'uz': "O'zbekcha",
    'en': 'English',
    'ru': 'Русский',
  };

  final String code;

  String _t(String en, String uz, String ru) => switch (code) {
    'uz' => uz,
    'ru' => ru,
    _ => en,
  };

  // ---- Navigation -----------------------------------------------------------

  String get navLearn => _t('Learn', "O'qish", 'Учёба');
  String get navPractice => _t('Practice', 'Mashq', 'Практика');
  String get navProgress => _t('Progress', 'Natija', 'Прогресс');
  String get navConfig => _t('Config', 'Sozlamalar', 'Настройки');

  // ---- Common ---------------------------------------------------------------

  String get cancel => _t('Cancel', 'Bekor qilish', 'Отмена');
  String get reset => _t('Reset', 'Tozalash', 'Сбросить');
  String get close => _t('Close', 'Yopish', 'Закрыть');
  String get done => _t('Done', 'Tayyor', 'Готово');
  String get undo => _t('Undo', 'Bekor qilish', 'Отменить');
  String get copy => _t('Copy', 'Nusxa olish', 'Копировать');
  String get copied => _t('Copied', 'Nusxa olindi', 'Скопировано');
  String get bookmarks => _t('Bookmarks', 'Xatcho‘plar', 'Закладки');
  String minutes(int m) => _t('$m min', '$m daqiqa', '$m мин');
  String minutesRead(int m) =>
      _t('$m min read', "$m daqiqa o'qish", '$m мин чтения');

  // ---- Learn ----------------------------------------------------------------

  String get learnGo => _t('Learn Go', "Go'ni o'rganing", 'Изучаем Go');
  String lessonsDone(int done, int total) => _t(
    '$done of $total lessons done',
    '$total ta darsdan $done tasi tugadi',
    'Пройдено уроков: $done из $total',
  );
  String get search => _t('Search', 'Qidirish', 'Поиск');
  String get finishedAll => _t(
    'You finished every lesson. Great work!',
    "Barcha darslarni tugatdingiz. Ofarin!",
    'Вы прошли все уроки. Отличная работа!',
  );
  String get continueReading =>
      _t('Continue reading', "O'qishni davom ettirish", 'Продолжить чтение');
  String get startHere => _t('Start here', 'Shu yerdan boshlang', 'Начните здесь');
  String lessonMeta(String section, int number, int minutes) => _t(
    '$section · Lesson $number · $minutes min',
    '$section · $number-dars · $minutes daqiqa',
    '$section · Урок $number · $minutes мин',
  );

  // ---- Lesson ---------------------------------------------------------------

  String get resumed => _t(
    'Resumed where you left off',
    "Qolgan joyingizdan davom ettirildi",
    'Продолжено с места, где вы остановились',
  );
  String get fromStart => _t('From start', 'Boshidan', 'С начала');
  String get textSize => _t('Text size', 'Matn o‘lchami', 'Размер текста');
  String get bookmark => _t('Bookmark', 'Xatcho‘p qo‘yish', 'В закладки');
  String get removeBookmark =>
      _t('Remove bookmark', 'Xatcho‘pni olib tashlash', 'Убрать закладку');
  String lessonMetaRead(String section, int number, int minutes) => _t(
    '$section · Lesson $number · $minutes min read',
    "$section · $number-dars · $minutes daqiqa o'qish",
    '$section · Урок $number · $minutes мин чтения',
  );
  String get markComplete =>
      _t('Mark as complete', 'Tugatilgan deb belgilash', 'Отметить как пройденный');
  String get completed => _t('Completed', 'Tugatildi', 'Пройдено');
  String nextLesson(String title) =>
      _t('Next: $title', 'Keyingisi: $title', 'Далее: $title');
  String get backToLessons =>
      _t('Back to lessons', 'Darslarga qaytish', 'Назад к урокам');

  // ---- Practice -------------------------------------------------------------

  String get practiceSubtitle => _t(
    'Short quizzes to check what you learned',
    "O'rganganlaringizni tekshiring: qisqa testlar",
    'Короткие тесты для проверки знаний',
  );
  String get quickQuiz => _t('Quick quiz', 'Tezkor test', 'Быстрый тест');
  String randomQuestions(int n) => _t(
    '$n random questions',
    '$n ta tasodifiy savol',
    'Случайных вопросов: $n',
  );
  String get questionOfDay =>
      _t('Question of the day', 'Kun savoli', 'Вопрос дня');
  String get solvedTomorrow => _t(
    'Solved. See you tomorrow!',
    'Yechildi. Ertagacha!',
    'Решено. До завтра!',
  );
  String get oneQuestionDaily => _t(
    'One question, new every day',
    'Bitta savol, har kuni yangi',
    'Один вопрос, новый каждый день',
  );
  String get byTopic => _t('By topic', 'Mavzu bo‘yicha', 'По темам');
  String correctOf(int correct, int total) => _t(
    '$correct of $total correct',
    '$total tadan $correct tasi to‘g‘ri',
    'Верно: $correct из $total',
  );

  // ---- Progress -------------------------------------------------------------

  String dayStreak(int n) => _t(
    n == 1 ? 'day streak' : 'days streak',
    'kunlik seriya',
    'дн. подряд',
  );
  String get lessons => _t('lessons', 'dars', 'уроков');
  String get quizAccuracy => _t('quiz accuracy', 'test aniqligi', 'точность тестов');
  String get sections => _t('Sections', 'Bo‘limlar', 'Разделы');
  String get settings => _t('Settings', 'Sozlamalar', 'Настройки');
  String get configSubtitle => _t(
    'Language, theme, text size and more',
    'Til, mavzu, matn o‘lchami va boshqalar',
    'Язык, тема, размер текста и другое',
  );
  String get dailyGoal => _t('Daily goal', 'Kunlik maqsad', 'Дневная цель');
  String get goalReached => _t(
    'Goal reached today. Nice!',
    'Bugungi maqsadga erishildi. Barakalla!',
    'Цель на сегодня достигнута. Отлично!',
  );
  String minutesToday(int m, int goal) => _t(
    '$m of $goal min today',
    'Bugun $goal daqiqadan $m tasi',
    'Сегодня $m из $goal мин',
  );

  // ---- Quizzes --------------------------------------------------------------

  String get check => _t('Check', 'Tekshirish', 'Проверить');
  String get seeResults =>
      _t('See results', 'Natijalarni ko‘rish', 'Посмотреть результаты');
  String get next => _t('Continue', 'Davom etish', 'Дальше');
  String get perfect =>
      _t('Perfect score!', 'Mukammal natija!', 'Отличный результат!');
  String get great => _t('Great job!', 'Ofarin!', 'Молодец!');
  String get goodEffort =>
      _t('Good effort', 'Yaxshi urinish', 'Хорошая попытка');
  String get keepPracticing =>
      _t('Keep practicing', 'Mashq qilishda davom eting', 'Продолжайте практиковаться');
  String get tryAgain => _t('Try again', 'Qayta urinish', 'Ещё раз');
  String get quickCheck =>
      _t('Quick check', 'Tezkor tekshiruv', 'Быстрая проверка');
  String get correct => _t('Correct!', "To'g'ri!", 'Верно!');
  String get notQuite => _t('Not quite', "Deyarli to'g'ri emas", 'Не совсем');

  // ---- Search and bookmarks -------------------------------------------------

  String get searchLessons =>
      _t('Search lessons', 'Darslarni qidirish', 'Поиск по урокам');
  String get searchTheBook =>
      _t('Search the book', 'Kitobdan qidirish', 'Поиск по книге');
  String get findAnyTopic => _t(
    'Find any topic across all sections.',
    'Barcha bo‘limlardan istalgan mavzuni toping.',
    'Найдите любую тему во всех разделах.',
  );
  String get noResults => _t('No results', 'Hech narsa topilmadi', 'Ничего не найдено');
  String get tryDifferent => _t(
    'Try a different keyword.',
    'Boshqa so‘z bilan urinib ko‘ring.',
    'Попробуйте другое слово.',
  );
  String get noBookmarks =>
      _t('No bookmarks yet', "Hali xatcho'plar yo'q", 'Закладок пока нет');
  String get noBookmarksHint => _t(
    'Tap the bookmark icon in a lesson to save it here.',
    "Darsni shu yerda saqlash uchun undagi xatcho'p belgisini bosing.",
    'Нажмите на значок закладки в уроке, чтобы сохранить его здесь.',
  );

  // ---- Config ---------------------------------------------------------------

  String get configTitle => _t('Config', 'Sozlamalar', 'Настройки');
  String get configHeading => _t(
    'Make the book look and feel the way you like',
    "Kitobni o'zingizga moslang",
    'Настройте книгу под себя',
  );
  String get language => _t('Language', 'Til', 'Язык');
  String get languageHint => _t(
    'Language of the app. Lessons stay as they are.',
    "Ilova tili. Darslar o'zgarmaydi.",
    'Язык приложения. Уроки не меняются.',
  );
  String get appearance => _t('Appearance', 'Ko‘rinish', 'Внешний вид');
  String get theme => _t('Theme', 'Mavzu', 'Тема');
  String get themeSystem => _t('System', 'Tizim', 'Система');
  String get themeLight => _t('Light', 'Yorug‘', 'Светлая');
  String get themeDark => _t('Dark', 'Qorong‘i', 'Тёмная');
  String get accentColor => _t('Accent color', 'Asosiy rang', 'Цвет акцента');
  String accentName(int index) => switch (index) {
    0 => _t('Go blue', 'Go ko‘ki', 'Синий Go'),
    1 => _t('Violet', 'Binafsha', 'Фиолетовый'),
    2 => _t('Green', 'Yashil', 'Зелёный'),
    3 => _t('Orange', 'To‘q sariq', 'Оранжевый'),
    _ => _t('Rose', 'Pushti', 'Розовый'),
  };
  String get reading => _t('Reading', 'O‘qish', 'Чтение');
  String get lineSpacing =>
      _t('Line spacing', 'Qatorlar oralig‘i', 'Межстрочный интервал');
  String get spacingCompact => _t('Compact', 'Zich', 'Плотный');
  String get spacingNormal => _t('Normal', 'O‘rtacha', 'Обычный');
  String get spacingRelaxed => _t('Relaxed', 'Keng', 'Свободный');
  String get sampleText => _t(
    'Go is **simple** and fast. Print a line with `fmt.Println("Salom")` '
        'and run it with `go run main.go`.',
    'Go **sodda** va tez. Qatorni `fmt.Println("Salom")` bilan chiqaring '
        'va `go run main.go` bilan ishga tushiring.',
    'Go **простой** и быстрый. Выведите строку через `fmt.Println("Salom")` '
        'и запустите её командой `go run main.go`.',
  );
  String get learning => _t('Learning', 'O‘rganish', 'Обучение');
  String get dailyGoalMinutes =>
      _t('Daily goal (minutes)', 'Kunlik maqsad (daqiqa)', 'Дневная цель (минуты)');
  String get haptics =>
      _t('Haptic feedback', 'Tebranish', 'Виброотклик');
  String get hapticsHint => _t(
    'Vibrate on taps and quiz answers',
    'Bosishda va test javoblarida tebranish',
    'Вибрация при нажатиях и ответах на тесты',
  );
  String get data => _t('Data', 'Ma’lumotlar', 'Данные');
  String get restoreDefaults => _t(
    'Restore default settings',
    'Standart sozlamalarni tiklash',
    'Вернуть настройки по умолчанию',
  );
  String get progressKept =>
      _t('Progress is kept', 'Natijalar saqlanadi', 'Прогресс сохранится');
  String get restoreDefaultsQ => _t(
    'Restore default settings?',
    'Standart sozlamalar tiklansinmi?',
    'Вернуть настройки по умолчанию?',
  );
  String get restoreDefaultsBody => _t(
    'Language, theme, accent color, text size, line spacing, daily goal and '
        'haptics go back to defaults.',
    'Til, mavzu, asosiy rang, matn o‘lchami, qatorlar oralig‘i, kunlik '
        'maqsad va tebranish standart holatga qaytadi.',
    'Язык, тема, цвет акцента, размер текста, межстрочный интервал, '
        'дневная цель и вибрация вернутся к значениям по умолчанию.',
  );
  String get restore => _t('Restore', 'Tiklash', 'Вернуть');
  String get resetProgress =>
      _t('Reset progress', 'Natijalarni tozalash', 'Сбросить прогресс');
  String get resetProgressHint => _t(
    'Lessons, quiz answers, streaks',
    'Darslar, test javoblari, seriyalar',
    'Уроки, ответы на тесты, серии',
  );
  String get resetProgressQ => _t(
    'Reset progress?',
    'Natijalar tozalansinmi?',
    'Сбросить прогресс?',
  );
  String get resetProgressBody => _t(
    'Completed lessons, quiz answers and streaks will be cleared. '
        'Bookmarks and settings are kept.',
    'Tugatilgan darslar, test javoblari va seriyalar o‘chiriladi. '
        'Xatcho‘plar va sozlamalar saqlanadi.',
    'Пройденные уроки, ответы на тесты и серии будут удалены. '
        'Закладки и настройки сохранятся.',
  );

  // ---- Welcome and intro ------------------------------------------------------

  String get chooseLanguage =>
      _t('Choose your language', 'Tilni tanlang', 'Выберите язык');
  String get chooseLanguageHint => _t(
    'You can change it later in Config.',
    "Uni keyinroq Sozlamalarda o'zgartirish mumkin.",
    'Позже его можно изменить в настройках.',
  );
  String get continueLabel => _t('Continue', 'Davom etish', 'Продолжить');
  String get skip => _t('Skip', "O'tkazib yuborish", 'Пропустить');
  String get nextStep => _t('Next', 'Keyingisi', 'Далее');
  String get getStarted => _t('Get started', 'Boshlash', 'Начать');
  String get introLearnTitle => _t(
    'Learn Go step by step',
    "Go'ni bosqichma-bosqich o'rganing",
    'Изучайте Go шаг за шагом',
  );
  String get introLearnBody => _t(
    'Short lessons with clear examples. The app remembers where you '
        'stopped, so you can pick up right there.',
    "Aniq misollar bilan qisqa darslar. Ilova qayerda to'xtaganingizni "
        "eslab qoladi, shu joydan davom etasiz.",
    'Короткие уроки с понятными примерами. Приложение запоминает, где вы '
        'остановились, и вы продолжаете с того же места.',
  );
  String get introPracticeTitle => _t(
    'Check yourself with quizzes',
    "Testlar bilan o'zingizni sinang",
    'Проверяйте себя тестами',
  );
  String get introPracticeBody => _t(
    'Quick quizzes, a new question every day, XP and streaks keep you '
        'moving.',
    "Tezkor testlar, har kuni yangi savol, XP va ketma-ket kunlar sizni "
        "harakatda ushlab turadi.",
    'Быстрые тесты, новый вопрос каждый день, очки опыта и серии '
        'помогают не сбиваться с ритма.',
  );
  String get introConfigTitle => _t(
    'Make it yours',
    "O'zingizga moslang",
    'Настройте под себя',
  );
  String get introConfigBody => _t(
    'Pick a theme and accent color, change the text size and set a daily '
        'goal in Config.',
    "Sozlamalarda mavzu va rangni tanlang, matn o'lchamini o'zgartiring va "
        "kunlik maqsad belgilang.",
    'В настройках выберите тему и цвет, измените размер текста и '
        'поставьте дневную цель.',
  );

  // ---- Startup failure ------------------------------------------------------

  String get loadFailedTitle => _t(
    'Could not open the book',
    'Kitobni ochib bo‘lmadi',
    'Не удалось открыть книгу',
  );
  String get loadFailedBody => _t(
    'Please restart the app. If this keeps happening, reinstall it.',
    'Ilovani qayta ishga tushiring. Muammo takrorlansa, ilovani qayta '
        "o'rnating.",
    'Перезапустите приложение. Если ошибка повторяется, '
        'переустановите его.',
  );
}
