import 'package:flutter/material.dart';

import '../data/models.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/learning_timer.dart';
import '../widgets/markdown_view.dart';
import 'settings_sheet.dart';

class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key, required this.lesson});

  final Lesson lesson;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final _scroll = ScrollController();
  final _progress = ValueNotifier<double>(0);
  final _showTitle = ValueNotifier<bool>(false);
  late AppState _state;

  Lesson get lesson => widget.lesson;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _restore());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _state = context.appState;
  }

  /// Jumps back to where the reader stopped last time.
  void _restore() {
    if (!mounted) return;
    _state.markOpened(lesson);
    final offset = _state.scrollOffsetOf(lesson);
    if (offset < 200 || _state.isCompleted(lesson) || !_scroll.hasClients) {
      return;
    }
    if (offset > _scroll.position.maxScrollExtent * 0.9) return;
    _scroll.jumpTo(offset);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('Resumed where you left off'),
          action: SnackBarAction(
            label: 'START OVER',
            onPressed: () => _scroll.animateTo(
              0,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
            ),
          ),
        ),
      );
  }

  void _onScroll() {
    final pos = _scroll.position;
    _progress.value = pos.maxScrollExtent <= 0
        ? 1
        : (pos.pixels / pos.maxScrollExtent).clamp(0, 1);
    _showTitle.value = pos.pixels > 90;
  }

  @override
  void dispose() {
    if (_scroll.hasClients) _state.saveScrollOffset(lesson, _scroll.offset);
    _scroll.dispose();
    _progress.dispose();
    _showTitle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.appState;
    final book = context.book;
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final color = lesson.section.color;
    final bookmarked = state.isBookmarked(lesson);

    return LearningTimer(
      child: Scaffold(
        appBar: AppBar(
          title: ValueListenableBuilder(
            valueListenable: _showTitle,
            builder: (_, show, _) => AnimatedOpacity(
              opacity: show ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: Text(lesson.title),
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'Text size',
              icon: const Icon(Icons.format_size_rounded),
              onPressed: () => showSettingsSheet(context),
            ),
            IconButton(
              tooltip: bookmarked ? 'Remove bookmark' : 'Bookmark',
              icon: Icon(
                bookmarked
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_add_outlined,
                color: bookmarked ? color : null,
              ),
              onPressed: () => state.toggleBookmark(lesson),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(3),
            child: ValueListenableBuilder(
              valueListenable: _progress,
              builder: (_, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 3,
                color: color,
                backgroundColor: Colors.transparent,
                borderRadius: BorderRadius.zero,
              ),
            ),
          ),
        ),
        body: SelectionArea(
          child: ListView(
            controller: _scroll,
            padding: EdgeInsets.fromLTRB(
              20,
              8,
              20,
              32 + MediaQuery.paddingOf(context).bottom,
            ),
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${lesson.section.title.toUpperCase()} · LESSON ${lesson.number}',
                      style: TextStyle(
                        color: color,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                  _Meta(Icons.schedule_rounded, '${lesson.minutes} min read'),
                  if (lesson.quizzes.isNotEmpty)
                    _Meta(
                      Icons.quiz_outlined,
                      '${lesson.quizzes.length} questions',
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                lesson.title,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontSize: 30 * state.fontScale,
                  height: 1.2,
                ),
              ),
              if (lesson.summary.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  lesson.summary,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w400,
                    color: muted,
                    height: 1.45,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Divider(height: 32, color: theme.colorScheme.outlineVariant),
              MarkdownView(
                data: lesson.markdown,
                accent: color,
                fontScale: state.fontScale,
                quizzes: lesson.quizzes,
              ),
              const SizedBox(height: 32),
              _CompleteButton(lesson: lesson),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _NavCard(
                      lesson: book.previousOf(lesson),
                      isNext: false,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _NavCard(lesson: book.nextOf(lesson), isNext: true),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta(this.icon, this.text);

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: muted),
        const SizedBox(width: 4),
        Text(text, style: theme.textTheme.labelMedium?.copyWith(color: muted)),
      ],
    );
  }
}

class _CompleteButton extends StatelessWidget {
  const _CompleteButton({required this.lesson});

  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    final state = context.appState;
    final done = state.isCompleted(lesson);
    final color = lesson.section.color;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: done
          ? OutlinedButton.icon(
              key: const ValueKey('done'),
              onPressed: () => state.setCompleted(lesson, false),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                foregroundColor: color,
                side: BorderSide(color: color.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              icon: const Icon(Icons.check_circle_rounded),
              label: const Text(
                'Completed',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            )
          : FilledButton.icon(
              key: const ValueKey('todo'),
              onPressed: () {
                state.setCompleted(lesson, true);
                final next = context.book.nextOf(lesson);
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Lesson completed · +${AppState.xpPerLesson} XP 🎉',
                      ),
                      action: next == null
                          ? null
                          : SnackBarAction(
                              label: 'NEXT',
                              onPressed: () =>
                                  openLesson(context, next, replace: true),
                            ),
                    ),
                  );
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                backgroundColor: color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              icon: const Icon(Icons.task_alt_rounded),
              label: const Text(
                'Mark as complete',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
    );
  }
}

class _NavCard extends StatelessWidget {
  const _NavCard({required this.lesson, required this.isNext});

  final Lesson? lesson;
  final bool isNext;

  @override
  Widget build(BuildContext context) {
    final lesson = this.lesson;
    if (lesson == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final align = isNext ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => openLesson(context, lesson, replace: true),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: align,
            children: [
              Row(
                mainAxisAlignment: isNext
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                children: [
                  if (!isNext)
                    Icon(
                      Icons.arrow_back_rounded,
                      size: 16,
                      color: lesson.section.color,
                    ),
                  const SizedBox(width: 4),
                  Text(
                    isNext ? 'Next' : 'Previous',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: lesson.section.color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  if (isNext)
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: lesson.section.color,
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                lesson.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: isNext ? TextAlign.end : TextAlign.start,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
