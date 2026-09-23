import 'package:flutter/material.dart';

import '../data/models.dart';
import '../screens/lesson_screen.dart';
import '../state/app_state.dart';

void openLesson(BuildContext context, Lesson lesson, {bool replace = false}) {
  final route = MaterialPageRoute<void>(
    builder: (_) => LessonScreen(lesson: lesson),
  );
  replace
      ? Navigator.of(context).pushReplacement(route)
      : Navigator.of(context).push(route);
}

/// Marks when a screen appeared, so [FadeSlideIn] only animates the first
/// view of it — not items scrolled into view later.
class EntranceScope extends StatefulWidget {
  const EntranceScope({super.key, required this.child});

  final Widget child;

  static const window = Duration(milliseconds: 700);

  /// Whether the screen above [context] appeared less than [window] ago.
  static bool isEntering(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<_EntranceMarker>();
    return scope == null || DateTime.now().difference(scope.start) < window;
  }

  @override
  State<EntranceScope> createState() => _EntranceScopeState();
}

class _EntranceScopeState extends State<EntranceScope> {
  final _start = DateTime.now();

  @override
  Widget build(BuildContext context) =>
      _EntranceMarker(start: _start, child: widget.child);
}

class _EntranceMarker extends InheritedWidget {
  const _EntranceMarker({required this.start, required super.child});

  final DateTime start;

  @override
  bool updateShouldNotify(_EntranceMarker old) => false;
}

/// Fades and lifts [child] in once, staggered by [index]. Runs a single
/// short tween and then costs nothing (full opacity adds no layer).
class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({super.key, required this.child, this.index = 0});

  final Widget child;
  final int index;

  static const _base = 360;
  static const _step = 50;
  static const _maxIndex = 6;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context) ||
        !EntranceScope.isEntering(context)) {
      return child;
    }
    final delay = index.clamp(0, _maxIndex) * _step;
    final total = _base + delay;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: total),
      curve: Interval(delay / total, 1, curve: Curves.easeOutCubic),
      child: child,
      builder: (_, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, (1 - t) * 14),
          child: child,
        ),
      ),
    );
  }
}

/// Flat bordered card. When tappable it shrinks slightly while pressed,
/// which makes taps feel responsive without any heavy effect.
class AppCard extends StatefulWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.color,
    this.padding = EdgeInsets.zero,
    this.bordered = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color? color;
  final EdgeInsetsGeometry padding;
  final bool bordered;

  static const radius = 16.0;

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppCard.radius),
      side: widget.bordered
          ? BorderSide(color: scheme.outlineVariant)
          : BorderSide.none,
    );
    return AnimatedScale(
      scale: _pressed ? 0.98 : 1,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      child: Material(
        color: widget.color ?? scheme.surfaceContainerLow,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          // Fires only for a real press, not when a scroll starts.
          onHighlightChanged: widget.onTap == null
              ? null
              : (v) => setState(() => _pressed = v),
          child: Padding(padding: widget.padding, child: widget.child),
        ),
      ),
    );
  }
}

/// Small circle with the lesson number, or a check once it is done.
class LessonNumber extends StatelessWidget {
  const LessonNumber({super.key, required this.lesson, required this.done});

  final Lesson lesson;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? scheme.primary : scheme.surfaceContainer,
      ),
      child: done
          ? Icon(Icons.check_rounded, size: 18, color: scheme.onPrimary)
          : Text(
              '${lesson.number}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: scheme.onSurfaceVariant,
              ),
            ),
    );
  }
}

/// One lesson in a list: number, title and a short muted line.
class LessonTile extends StatelessWidget {
  const LessonTile({
    super.key,
    required this.lesson,
    this.subtitle,
    this.showSection = false,
  });

  final Lesson lesson;
  final String? subtitle;
  final bool showSection;

  @override
  Widget build(BuildContext context) {
    final state = context.appState;
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final done = state.isCompleted(lesson);
    final meta = [
      if (showSection) lesson.section.title,
      '${lesson.minutes} min',
    ].join(' · ');

    return InkWell(
      onTap: () => openLesson(context, lesson),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            LessonNumber(lesson: lesson, done: done),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle ?? meta,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(color: muted),
                  ),
                ],
              ),
            ),
            if (state.isBookmarked(lesson))
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.bookmark_rounded,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Lesson rows grouped in one card, separated by hairlines.
class LessonGroup extends StatelessWidget {
  const LessonGroup({
    super.key,
    required this.lessons,
    this.subtitles,
    this.showSection = false,
  });

  final List<Lesson> lessons;
  final List<String?>? subtitles;
  final bool showSection;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        children: [
          for (var i = 0; i < lessons.length; i++) ...[
            if (i > 0) const Divider(indent: 62),
            LessonTile(
              lesson: lessons[i],
              subtitle: subtitles?[i],
              showSection: showSection,
            ),
          ],
        ],
      ),
    );
  }
}

/// Progress bar that eases to its new value instead of jumping.
class ProgressLine extends StatelessWidget {
  const ProgressLine({super.key, required this.value, this.color});

  final double value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (_, v, _) => LinearProgressIndicator(value: v, color: color),
    );
  }
}

/// Small title above a group of content.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 24, 4, 10),
      child: Row(
        children: [
          Expanded(child: Text(title, style: theme.textTheme.titleMedium)),
          if (trailing != null)
            Text(
              trailing!,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}

/// Page title with an optional line below, used at the top of each tab.
class PageTitle extends StatelessWidget {
  const PageTitle(
    this.title, {
    super.key,
    this.subtitle,
    this.actions = const [],
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 0, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.headlineSmall),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          ...actions,
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: FadeSlideIn(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 44, color: muted.withValues(alpha: 0.6)),
              const SizedBox(height: 16),
              Text(title, style: theme.textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
