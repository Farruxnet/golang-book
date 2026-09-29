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
      appBar: AppBar(title: Text(context.s.bookmarks)),
      body: lessons.isEmpty
          ? EmptyState(
              icon: Icons.bookmark_border_rounded,
              title: context.s.noBookmarks,
              message: context.s.noBookmarksHint,
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [LessonGroup(lessons: lessons, showSection: true)],
            ),
    );
  }
}
