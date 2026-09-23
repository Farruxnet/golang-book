import 'package:flutter/material.dart';

import '../data/models.dart';
import '../screens/lesson_screen.dart';
import '../screens/section_screen.dart';
import '../state/app_state.dart';

void openLesson(BuildContext context, Lesson lesson, {bool replace = false}) {
  final route = MaterialPageRoute<void>(
    builder: (_) => LessonScreen(lesson: lesson),
  );
  replace
      ? Navigator.of(context).pushReplacement(route)
      : Navigator.of(context).push(route);
}

void openSection(BuildContext context, Section section) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => SectionScreen(section: section)),
  );
}

/// Rounded, gradient-filled tile with the section icon.
class SectionBadge extends StatelessWidget {
  const SectionBadge({super.key, required this.section, this.size = 52});

  final Section section;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = section.color;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c, Color.lerp(c, Colors.black, 0.25)!],
        ),
        boxShadow: [
          BoxShadow(
            color: c.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Icon(section.icon, color: Colors.white, size: size * 0.5),
    );
  }
}

/// Numbered circle that turns into a check mark when the lesson is done.
class LessonNumber extends StatelessWidget {
  const LessonNumber({
    super.key,
    required this.lesson,
    required this.done,
    this.size = 40,
  });

  final Lesson lesson;
  final bool done;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = lesson.section.color;
    final scheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? color : color.withValues(alpha: 0.12),
        border: Border.all(
          color: done ? color : color.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: done
          ? Icon(Icons.check_rounded, size: size * 0.55, color: Colors.white)
          : Text(
              '${lesson.number}',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: size * 0.38,
                color: Color.lerp(color, scheme.onSurface, 0.2),
              ),
            ),
    );
  }
}

/// A row describing one lesson, used in section, search and bookmark lists.
class LessonTile extends StatelessWidget {
  const LessonTile({
    super.key,
    required this.lesson,
    this.showSection = false,
    this.subtitle,
  });

  final Lesson lesson;
  final bool showSection;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final state = context.appState;
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final done = state.isCompleted(lesson);
    final text = subtitle ?? lesson.summary;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => openLesson(context, lesson),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LessonNumber(lesson: lesson, done: done),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showSection)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        lesson.section.title.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: lesson.section.color,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  Text(lesson.title, style: theme.textTheme.titleMedium),
                  if (text.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.schedule_rounded, size: 14, color: muted),
                      const SizedBox(width: 4),
                      Text(
                        '${lesson.minutes} min read',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: muted,
                        ),
                      ),
                      if (state.isBookmarked(lesson)) ...[
                        const SizedBox(width: 12),
                        Icon(
                          Icons.bookmark_rounded,
                          size: 14,
                          color: lesson.section.color,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Icon(Icons.chevron_right_rounded, color: muted),
            ),
          ],
        ),
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 20),
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small circular progress with a centered child.
class RingProgress extends StatelessWidget {
  const RingProgress({
    super.key,
    required this.value,
    required this.color,
    required this.child,
    this.size = 44,
    this.stroke = 4.5,
  });

  final double value;
  final Color color;
  final Widget child;
  final double size;
  final double stroke;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(end: value),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (_, v, _) => CircularProgressIndicator(
              value: v,
              strokeWidth: stroke,
              strokeCap: StrokeCap.round,
              color: color,
              backgroundColor: color.withValues(alpha: 0.15),
            ),
          ),
          Center(child: child),
        ],
      ),
    );
  }
}

/// Card with a leading visual, a bold value and a caption.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final Widget leading;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              leading,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(title, style: theme.textTheme.titleMedium),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Title row above a group of content.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
      child: Row(
        children: [
          Expanded(child: Text(title, style: theme.textTheme.titleLarge)),
          if (trailing != null)
            Text(
              trailing!,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}
