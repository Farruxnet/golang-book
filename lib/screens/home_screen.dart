import 'package:flutter/material.dart';

import '../data/models.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import 'bookmarks_screen.dart';
import 'search_screen.dart';

/// The book's table of contents with a single "continue" entry on top.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final book = context.book;
    final state = context.appState;

    return EntranceScope(
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              sliver: SliverToBoxAdapter(
                child: FadeSlideIn(
                  child: PageTitle(
                    'Learn Go',
                    subtitle:
                        '${state.completedIn(book.allLessons)} of '
                        '${book.allLessons.length} lessons done',
                    actions: [
                      IconButton(
                        tooltip: 'Search',
                        icon: const Icon(Icons.search_rounded),
                        onPressed: () => _push(context, const SearchScreen()),
                      ),
                      IconButton(
                        tooltip: 'Bookmarks',
                        icon: const Icon(Icons.bookmark_border_rounded),
                        onPressed: () =>
                            _push(context, const BookmarksScreen()),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SliverPadding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
              sliver: SliverToBoxAdapter(
                child: FadeSlideIn(index: 1, child: _ContinueCard()),
              ),
            ),
            for (final (i, section) in book.sections.indexed)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: FadeSlideIn(
                    index: i + 2,
                    child: _SectionBlock(section: section),
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ),
      ),
    );
  }

  static void _push(BuildContext context, Widget screen) =>
      Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (_) => screen));
}

/// Resume the lesson in progress, or start the next unfinished one.
class _ContinueCard extends StatelessWidget {
  const _ContinueCard();

  static Lesson? _nextLesson(Book book, AppState state) {
    final last = book.lessonByKey(state.lastLessonKey);
    if (last != null && !state.isCompleted(last)) return last;
    final from = last == null ? 0 : book.allLessons.indexOf(last) + 1;
    return book.allLessons
            .skip(from)
            .where((l) => !state.isCompleted(l))
            .firstOrNull ??
        book.allLessons.where((l) => !state.isCompleted(l)).firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    final book = context.book;
    final state = context.appState;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final next = _nextLesson(book, state);
    final started = state.lastLessonKey != null;

    if (next == null) {
      return AppCard(
        color: scheme.primary.withValues(alpha: 0.08),
        bordered: false,
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Icon(Icons.celebration_outlined, color: scheme.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'You finished every lesson. Great work!',
                style: theme.textTheme.titleMedium,
              ),
            ),
          ],
        ),
      );
    }

    return AppCard(
      color: scheme.primary.withValues(alpha: 0.08),
      bordered: false,
      padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
      onTap: () => openLesson(context, next),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  started ? 'Continue reading' : 'Start here',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  next.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  '${next.section.title} · Lesson ${next.number} · '
                  '${next.minutes} min',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: scheme.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.arrow_forward_rounded, color: scheme.onPrimary),
          ),
        ],
      ),
    );
  }
}

class _SectionBlock extends StatelessWidget {
  const _SectionBlock({required this.section});

  final Section section;

  @override
  Widget build(BuildContext context) {
    final state = context.appState;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          section.title,
          trailing:
              '${state.completedIn(section.lessons)}/${section.lessons.length}',
        ),
        LessonGroup(lessons: section.lessons),
      ],
    );
  }
}
