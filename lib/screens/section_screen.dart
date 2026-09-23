import 'package:flutter/material.dart';

import '../data/models.dart';
import '../state/app_state.dart';
import '../widgets/common.dart';

class SectionScreen extends StatelessWidget {
  const SectionScreen({super.key, required this.section});

  static const _expandedHeight = 290.0;

  final Section section;

  @override
  Widget build(BuildContext context) {
    final state = context.appState;
    final done = state.completedIn(section.lessons);
    final c = section.color;
    final dark = Color.lerp(c, Colors.black, 0.45)!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: _expandedHeight,
            backgroundColor: dark,
            foregroundColor: Colors.white,
            flexibleSpace: LayoutBuilder(
              builder: (context, box) {
                final top = MediaQuery.paddingOf(context).top;
                final min = kToolbarHeight + top;
                final t =
                    ((box.maxHeight - min) / (_expandedHeight + top - min))
                        .clamp(0.0, 1.0);
                return DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color.lerp(dark, c, t)!, dark],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -30,
                        bottom: -20,
                        child: Icon(
                          section.icon,
                          size: 200,
                          color: Colors.white.withValues(alpha: 0.08 * t),
                        ),
                      ),
                      // Small title while collapsed.
                      Positioned(
                        left: 64,
                        right: 16,
                        top: top,
                        height: kToolbarHeight,
                        child: Opacity(
                          opacity: (1 - t * 3).clamp(0.0, 1.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              section.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Expanded header, clipped below the toolbar as it collapses.
                      Positioned(
                        left: 20,
                        right: 20,
                        top: min,
                        bottom: 22,
                        child: ClipRect(
                          child: OverflowBox(
                            alignment: Alignment.bottomLeft,
                            maxHeight: double.infinity,
                            child: Opacity(
                              opacity: ((t - 0.5) / 0.5).clamp(0.0, 1.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    section.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    section.subtitle,
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.85,
                                      ),
                                      fontSize: 15,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      _pill(
                                        Icons.menu_book_rounded,
                                        '${section.lessons.length} lessons',
                                      ),
                                      _pill(
                                        Icons.schedule_rounded,
                                        '${section.totalMinutes} min',
                                      ),
                                      _pill(
                                        Icons.check_circle_rounded,
                                        '$done done',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  LinearProgressIndicator(
                                    value: state.progressOf(section.lessons),
                                    color: Colors.white,
                                    backgroundColor: Colors.white.withValues(
                                      alpha: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 40),
            sliver: SliverList.builder(
              itemCount: section.lessons.length,
              itemBuilder: (context, i) =>
                  LessonTile(lesson: section.lessons[i]),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _pill(IconData icon, String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.white),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}
