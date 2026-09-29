import 'package:flutter/material.dart';

import '../data/models.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';
import '../widgets/haptics.dart';
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

  /// The rendered Markdown, reused across rebuilds (answering a quiz or
  /// toggling a bookmark must not re-parse and re-highlight the lesson).
  Widget? _content;
  double? _contentScale;
  double? _contentLineHeight;

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
          duration: const Duration(seconds: 3),
          content: Text(context.s.resumed),
          action: SnackBarAction(
            label: context.s.fromStart,
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

  Widget _markdown(double scale, double lineHeight) {
    if (_content == null ||
        _contentScale != scale ||
        _contentLineHeight != lineHeight) {
      _contentScale = scale;
      _contentLineHeight = lineHeight;
      _content = MarkdownView(
        data: lesson.markdown,
        fontScale: scale,
        lineHeight: lineHeight,
        quizzes: lesson.quizzes,
      );
    }
    return _content!;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.appState;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final bookmarked = state.isBookmarked(lesson);
    final scale = state.fontScale;

    return LearningTimer(
      child: Scaffold(
        appBar: AppBar(
          title: ValueListenableBuilder(
            valueListenable: _showTitle,
            builder: (_, show, child) => AnimatedOpacity(
              opacity: show ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: child,
            ),
            child: Text(lesson.title),
          ),
          actions: [
            IconButton(
              tooltip: context.s.textSize,
              icon: const Icon(Icons.text_fields_rounded),
              onPressed: () => showSettingsSheet(context),
            ),
            IconButton(
              tooltip: bookmarked ? context.s.removeBookmark : context.s.bookmark,
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, a) =>
                    ScaleTransition(scale: a, child: child),
                child: Icon(
                  bookmarked
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  key: ValueKey(bookmarked),
                  color: bookmarked ? scheme.primary : null,
                ),
              ),
              onPressed: () {
                Haptics.selection();
                state.toggleBookmark(lesson);
              },
            ),
            const SizedBox(width: 4),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(2),
            child: ValueListenableBuilder(
              valueListenable: _progress,
              builder: (_, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 2,
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
              12,
              20,
              32 + MediaQuery.paddingOf(context).bottom,
            ),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.s.lessonMetaRead(
                      lesson.section.title,
                      lesson.number,
                      lesson.minutes,
                    ),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    lesson.title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontSize: 27 * scale,
                      height: 1.25,
                    ),
                  ),
                  if (lesson.summary.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      lesson.summary,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                        fontSize: 16.5 * scale,
                        height: 1.5,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 8),
                ],
              ),
              _markdown(scale, state.lineHeight),
              const SizedBox(height: 32),
              _LessonFooter(lesson: lesson),
            ],
          ),
        ),
      ),
    );
  }
}

/// One clear action at the end: complete the lesson, then go to the next.
class _LessonFooter extends StatelessWidget {
  const _LessonFooter({required this.lesson});

  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    final state = context.appState;
    final theme = Theme.of(context);
    final done = state.isCompleted(lesson);
    final next = context.book.nextOf(lesson);

    final Widget child;
    if (!done) {
      child = SizedBox(
        key: const ValueKey('todo'),
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () {
            Haptics.light();
            state.setCompleted(lesson, true);
          },
          icon: const Icon(Icons.check_rounded),
          label: Text(context.s.markComplete),
        ),
      );
    } else {
      child = Column(
        key: const ValueKey('done'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle_rounded,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  context.s.completed,
                  style: theme.textTheme.titleSmall,
                ),
              ),
              TextButton(
                onPressed: () => state.setCompleted(lesson, false),
                child: Text(context.s.undo),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (next != null)
            FilledButton(
              onPressed: () => openLesson(context, next, replace: true),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      context.s.nextLesson(next.title),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 20),
                ],
              ),
            )
          else
            OutlinedButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: Text(context.s.backToLessons),
            ),
        ],
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SizeTransition(
          sizeFactor: animation,
          alignment: Alignment.topCenter,
          child: child,
        ),
      ),
      child: child,
    );
  }
}
