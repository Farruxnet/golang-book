import 'package:flutter/material.dart';

import '../app_info.dart';
import '../widgets/brand_mark.dart';

/// Shown while the lessons load. It takes over from the native launch screen
/// (same background, the mark in the middle), so the app opens with one
/// continuous motion: the mark settles, then the name rises in below it.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  /// How long the entrance takes; the app waits for it before switching.
  static const duration = Duration(milliseconds: 900);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: SplashScreen.duration,
  )..forward();

  late final _mark = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.6, curve: Curves.easeOutBack),
  );
  late final _text = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.35, 1, curve: Curves.easeOutCubic),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) _controller.value = 1;
  }

  @override
  void dispose() {
    _mark.dispose();
    _text.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: Tween(begin: 0.82, end: 1.0).animate(_mark),
              child: FadeTransition(
                opacity: _controller.drive(
                  CurveTween(curve: const Interval(0, 0.3)),
                ),
                child: const BrandMark(size: 72),
              ),
            ),
            const SizedBox(height: 20),
            FadeTransition(
              opacity: _text,
              child: SlideTransition(
                position: Tween(
                  begin: const Offset(0, 0.4),
                  end: Offset.zero,
                ).animate(_text),
                child: Text(
                  AppInfo.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
