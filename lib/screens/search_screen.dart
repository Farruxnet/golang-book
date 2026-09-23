import 'package:flutter/material.dart';

import '../data/models.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Title matches first, then content matches with a short snippet.
  List<(Lesson, String?)> _search(Book book) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return [];
    final byTitle = <(Lesson, String?)>[];
    final byBody = <(Lesson, String?)>[];
    for (final l in book.allLessons) {
      if (l.title.toLowerCase().contains(q)) {
        byTitle.add((l, null));
        continue;
      }
      final i = l.plainTextLower.indexOf(q);
      if (i >= 0) {
        final text = l.plainText;
        final start = (i - 40).clamp(0, text.length);
        final end = (i + q.length + 60).clamp(0, text.length);
        final snippet = text
            .substring(start, end)
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim();
        byBody.add((l, '${start > 0 ? '…' : ''}$snippet…'));
      }
    }
    return [...byTitle, ...byBody];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final results = _search(context.book);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onChanged: (v) => setState(() => _query = v),
          decoration: InputDecoration(
            hintText: 'Search lessons',
            border: InputBorder.none,
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () {
                      _controller.clear();
                      setState(() => _query = '');
                    },
                  ),
          ),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: _query.trim().isEmpty
          ? const EmptyState(
              icon: Icons.search_rounded,
              title: 'Search the book',
              message: 'Find any topic across all sections.',
            )
          : results.isEmpty
          ? const EmptyState(
              icon: Icons.search_off_rounded,
              title: 'No results',
              message: 'Try a different keyword.',
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                LessonGroup(
                  lessons: [for (final r in results) r.$1],
                  subtitles: [for (final r in results) r.$2],
                  showSection: true,
                ),
              ],
            ),
    );
  }
}
