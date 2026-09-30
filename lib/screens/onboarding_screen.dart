import 'dart:async';

import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../state/app_state.dart';
import '../theme.dart';
import '../widgets/brand_mark.dart';
import '../widgets/haptics.dart';

/// First launch: pick the language, then three short intro pages.
///
/// Language comes first so everything after it is already translated. The
/// flow is a single [PageView]: one primary button always moves forward,
/// Back and Skip sit in the top bar, and swiping works too.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _pageCount = 4; // language + three intro pages
  static const _slide = Duration(milliseconds: 380);

  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isLast => _page == _pageCount - 1;

  void _go(int page) => _controller.animateToPage(
    page,
    duration: _slide,
    curve: Curves.easeOutCubic,
  );

  void _next() {
    Haptics.selection();
    _isLast ? _finish() : _go(_page + 1);
  }

  void _finish() => context.appState.completeOnboarding();

  @override
  Widget build(BuildContext context) {
    final s = context.s;
    final label = _page == 0
        ? s.continueLabel
        : _isLast
        ? s.getStarted
        : s.nextStep;
    final intro = [
      (s.introLearnTitle, s.introLearnBody, const _LessonArt()),
      (s.introProgressTitle, s.introProgressBody, const _HabitArt()),
      (s.introConfigTitle, s.introConfigBody, const _StyleArt()),
    ];

    return Scaffold(
      body: SafeArea(
        child: Center(
          // Phones use the full width; tablets get a readable column.
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              children: [
                _TopBar(
                  showBack: _page > 0,
                  showSkip: _page > 0 && !_isLast,
                  onBack: () => _go(_page - 1),
                  onSkip: _finish,
                  skipLabel: s.skip,
                ),
                Expanded(
                  child: PageView(
                    controller: _controller,
                    onPageChanged: (i) => setState(() => _page = i),
                    children: [
                      const _LanguagePage(),
                      for (final (i, (title, body, art)) in intro.indexed)
                        _IntroPage(
                          controller: _controller,
                          index: i + 1,
                          title: title,
                          body: body,
                          art: art,
                        ),
                    ],
                  ),
                ),
                _Dots(count: _pageCount, current: _page),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _next,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: Text(label, key: ValueKey(label)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.showBack,
    required this.showSkip,
    required this.onBack,
    required this.onSkip,
    required this.skipLabel,
  });

  final bool showBack;
  final bool showSkip;
  final VoidCallback onBack;
  final VoidCallback onSkip;
  final String skipLabel;

  static Widget _fade(bool visible, Widget child) => AnimatedOpacity(
    opacity: visible ? 1 : 0,
    duration: const Duration(milliseconds: 180),
    child: IgnorePointer(ignoring: !visible, child: child),
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            _fade(
              showBack,
              IconButton(
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: onBack,
              ),
            ),
            const Spacer(),
            _fade(
              showSkip,
              TextButton(onPressed: onSkip, child: Text(skipLabel)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == current ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: i <= current ? scheme.primary : scheme.outlineVariant,
            ),
          ),
      ],
    );
  }
}

// ---- Language -----------------------------------------------------------------

class _LanguagePage extends StatelessWidget {
  const _LanguagePage();

  @override
  Widget build(BuildContext context) {
    final state = context.appState;
    final s = context.s;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      children: [
        Row(
          children: [
            const BrandMark(size: 56),
            const SizedBox(width: 14),
            Expanded(child: _Greeting(style: theme.textTheme.headlineMedium)),
          ],
        ),
        const SizedBox(height: 28),
        Text(s.chooseLanguage, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text(
          s.chooseLanguageHint,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),
        for (final code in S.codes) ...[
          _LanguageTile(
            code: code,
            selected: state.language == code,
            onTap: () {
              Haptics.selection();
              state.language = code;
            },
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

/// "Salom", "Hello", "Привет" in turn, so the screen greets the reader before
/// they have picked a language.
class _Greeting extends StatefulWidget {
  const _Greeting({this.style});

  final TextStyle? style;

  @override
  State<_Greeting> createState() => _GreetingState();
}

class _GreetingState extends State<_Greeting> {
  static const _words = ['Salom', 'Hello', 'Привет'];
  late final Timer _timer;
  int _i = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(
      const Duration(milliseconds: 2200),
      (_) => setState(() => _i = (_i + 1) % _words.length),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      layoutBuilder: (current, previous) => Stack(
        alignment: Alignment.centerLeft,
        children: [...previous, ?current],
      ),
      transitionBuilder: (child, a) => FadeTransition(
        opacity: a,
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).animate(a),
          child: child,
        ),
      ),
      child: Text(
        '${_words[_i]}!',
        key: ValueKey(_i),
        style: widget.style?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// A large tap target with a code badge instead of a flag, the language in its
/// own name and in English, and a radio-style mark for the current choice.
class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.code,
    required this.selected,
    required this.onTap,
  });

  final String code;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    const duration = Duration(milliseconds: 200);

    return Semantics(
      button: true,
      selected: selected,
      child: AnimatedContainer(
        duration: duration,
        decoration: BoxDecoration(
          color: selected
              ? scheme.primary.withValues(alpha: 0.08)
              : scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? scheme.primary : scheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: duration,
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? scheme.primary
                          : scheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      code.toUpperCase(),
                      style: TextStyle(
                        fontFamily: AppTheme.mono,
                        fontWeight: FontWeight.w700,
                        color: selected ? scheme.onPrimary : scheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.nativeNames[code]!,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          S.englishNames[code]!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedContainer(
                    duration: duration,
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected ? scheme.primary : Colors.transparent,
                      border: Border.all(
                        color: selected
                            ? scheme.primary
                            : scheme.outlineVariant,
                        width: 2,
                      ),
                    ),
                    child: selected
                        ? Icon(
                            Icons.check_rounded,
                            size: 16,
                            color: scheme.onPrimary,
                          )
                        : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---- Intro ------------------------------------------------------------------------

class _IntroPage extends StatelessWidget {
  const _IntroPage({
    required this.controller,
    required this.index,
    required this.title,
    required this.body,
    required this.art,
  });

  final PageController controller;
  final int index;
  final String title;
  final String body;
  final Widget art;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, box) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: box.maxHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Parallax: the art drifts slower than the page while swiping.
              AnimatedBuilder(
                animation: controller,
                builder: (_, child) {
                  final page = controller.hasClients &&
                          controller.position.haveDimensions
                      ? controller.page ?? index.toDouble()
                      : index.toDouble();
                  final delta = (index - page).clamp(-1.0, 1.0);
                  return Opacity(
                    opacity: 1 - delta.abs() * 0.6,
                    child: Transform.translate(
                      offset: Offset(delta * 80, 0),
                      child: child,
                    ),
                  );
                },
                child: SizedBox(height: 240, child: Center(child: art)),
              ),
              const SizedBox(height: 36),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(
                body,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card used by the intro illustrations.
class _ArtCard extends StatelessWidget {
  const _ArtCard({required this.child, this.color, this.width});

  final Widget child;
  final Color? color;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: width,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: child,
    );
  }
}

/// Illustration: a code snippet with a lesson badge.
class _LessonArt extends StatelessWidget {
  const _LessonArt();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const code = TextStyle(fontFamily: AppTheme.mono, fontSize: 14, height: 1.7);
    const keyword = Color(0xFFC678DD);
    const fn = Color(0xFF61AFEF);
    const str = Color(0xFF98C379);
    const plain = Color(0xFFD7DAE0);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        _ArtCard(
          width: 260,
          color: const Color(0xFF16191F),
          child: Text.rich(
            const TextSpan(
              style: code,
              children: [
                TextSpan(text: 'package ', style: TextStyle(color: keyword)),
                TextSpan(text: 'main\n\n', style: TextStyle(color: plain)),
                TextSpan(text: 'func ', style: TextStyle(color: keyword)),
                TextSpan(text: 'main', style: TextStyle(color: fn)),
                TextSpan(text: '() {\n  fmt.', style: TextStyle(color: plain)),
                TextSpan(text: 'Println', style: TextStyle(color: fn)),
                TextSpan(text: '(', style: TextStyle(color: plain)),
                TextSpan(text: '"Salom"', style: TextStyle(color: str)),
                TextSpan(text: ')\n}', style: TextStyle(color: plain)),
              ],
            ),
          ),
        ),
        Positioned(
          right: -14,
          bottom: -16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.menu_book_rounded, size: 18, color: scheme.onPrimary),
                const SizedBox(width: 6),
                Text(
                  '48',
                  style: TextStyle(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Illustration: streak, daily goal ring and the week's activity.
class _HabitArt extends StatelessWidget {
  const _HabitArt();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    const active = [true, true, true, false, true, true, true];

    return _ArtCard(
      width: 270,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_fire_department_rounded,
                color: AppTheme.streak,
                size: 36,
              ),
              const SizedBox(width: 6),
              Text(
                '7',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.streak,
                ),
              ),
              const Spacer(),
              SizedBox.square(
                dimension: 56,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: 0.7,
                      strokeWidth: 6,
                      strokeCap: StrokeCap.round,
                      color: AppTheme.correct,
                      backgroundColor: AppTheme.correct.withValues(alpha: 0.15),
                    ),
                    Text('70%', style: theme.textTheme.labelMedium),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final on in active)
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: on ? scheme.primary : scheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: on
                      ? Icon(Icons.check_rounded, size: 16, color: scheme.onPrimary)
                      : null,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Illustration: accent colors, light/dark and text size.
class _StyleArt extends StatelessWidget {
  const _StyleArt();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;

    return _ArtCard(
      width: 270,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final a in AppTheme.accents)
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dark ? a.dark : a.light,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Icon(
                        Icons.light_mode_rounded,
                        color: dark ? scheme.onSurfaceVariant : scheme.primary,
                      ),
                      Icon(
                        Icons.dark_mode_rounded,
                        color: dark ? scheme.primary : scheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text.rich(
                  TextSpan(
                    style: TextStyle(color: scheme.onSurface),
                    children: const [
                      TextSpan(text: 'A', style: TextStyle(fontSize: 14)),
                      TextSpan(text: ' A', style: TextStyle(fontSize: 22)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
