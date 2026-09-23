import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'practice_screen.dart';
import 'progress_screen.dart';

enum ShellTab { learn, practice, progress }

/// Bottom navigation between the three main areas of the app.
class Shell extends StatefulWidget {
  const Shell({super.key});

  static void goTo(BuildContext context, ShellTab tab) =>
      context.findAncestorStateOfType<_ShellState>()?._select(tab.index);

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _index = 0;

  void _select(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Back on another tab returns to Learn before leaving the app.
      canPop: _index == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _select(0);
      },
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: const [HomeScreen(), PracticeScreen(), ProgressScreen()],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _select,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book_rounded),
              label: 'Learn',
            ),
            NavigationDestination(
              icon: Icon(Icons.extension_outlined),
              selectedIcon: Icon(Icons.extension_rounded),
              label: 'Practice',
            ),
            NavigationDestination(
              icon: Icon(Icons.insights_outlined),
              selectedIcon: Icon(Icons.insights_rounded),
              label: 'Progress',
            ),
          ],
        ),
      ),
    );
  }
}
