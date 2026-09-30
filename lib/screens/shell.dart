import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../widgets/haptics.dart';
import 'config_screen.dart';
import 'home_screen.dart';
import 'practice_screen.dart';
import 'progress_screen.dart';

enum ShellTab { learn, practice, progress, config }

/// Bottom navigation between the main areas of the app.
class Shell extends StatefulWidget {
  const Shell({super.key});

  static void goTo(BuildContext context, ShellTab tab) =>
      context.findAncestorStateOfType<_ShellState>()?._select(tab.index);

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> with SingleTickerProviderStateMixin {
  int _index = 0;

  /// Fades the newly selected tab in. Tabs stay alive in the IndexedStack
  /// (scroll positions are kept); hidden ones have their tickers paused.
  late final _fade = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
    value: 1,
  );
  late final _opacity = CurvedAnimation(
    parent: _fade,
    curve: Curves.easeOutCubic,
  );
  late final _offset = Tween(
    begin: const Offset(0, 0.012),
    end: Offset.zero,
  ).animate(_opacity);

  void _select(int i) {
    if (i == _index) return;
    Haptics.selection();
    setState(() => _index = i);
    _fade.forward(from: 0);
  }

  @override
  void dispose() {
    _opacity.dispose();
    _fade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Back on another tab returns to Learn before leaving the app.
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _select(0);
      },
      child: Scaffold(
        body: FadeTransition(
          opacity: _opacity,
          child: SlideTransition(
            position: _offset,
            child: IndexedStack(
              index: _index,
              children: const [
                HomeScreen(),
                PracticeScreen(),
                ProgressScreen(),
                ConfigScreen(),
              ],
            ),
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _select,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.menu_book_outlined),
              selectedIcon: const Icon(Icons.menu_book_rounded),
              label: context.s.navLearn,
            ),
            NavigationDestination(
              icon: const Icon(Icons.quiz_outlined),
              selectedIcon: const Icon(Icons.quiz_rounded),
              label: context.s.navPractice,
            ),
            NavigationDestination(
              icon: const Icon(Icons.insights_outlined),
              selectedIcon: const Icon(Icons.insights_rounded),
              label: context.s.navProgress,
            ),
            NavigationDestination(
              icon: const Icon(Icons.tune_outlined),
              selectedIcon: const Icon(Icons.tune_rounded),
              label: context.s.navConfig,
            ),
          ],
        ),
      ),
    );
  }
}
