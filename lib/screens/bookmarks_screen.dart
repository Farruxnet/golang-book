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
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [LessonGroup(lessons: lessons, showSection: true)],
            ),
    );
  }
}
