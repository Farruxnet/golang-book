import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../widgets/common.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.appState;
    final lessons = context.book.allLessons.where(state.isBookmarked).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarks')),
      body: lessons.isEmpty
          ? const EmptyState(
              icon: Icons.bookmark_border_rounded,
              title: 'No bookmarks yet',
              message: 'Tap the bookmark icon in a lesson to save it here.',
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 32),
              itemCount: lessons.length,
              itemBuilder: (context, i) =>
                  LessonTile(lesson: lessons[i], showSection: true),
            ),
    );
  }
}
