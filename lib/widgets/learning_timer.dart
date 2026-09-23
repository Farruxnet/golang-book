import 'dart:async';

import 'package:flutter/material.dart';

import '../state/app_state.dart';

/// Counts time spent on [child] toward the daily goal.
///
/// Pauses when the app is in the background or when the user hasn't touched
/// the screen for [idleAfter], so a phone left on the table doesn't count.
class LearningTimer extends StatefulWidget {
  const LearningTimer({super.key, required this.child});

  final Widget child;

  static const idleAfter = Duration(minutes: 3);

  @override
  State<LearningTimer> createState() => _LearningTimerState();
}

class _LearningTimerState extends State<LearningTimer> {
  final _watch = Stopwatch()..start();
  late final AppLifecycleListener _lifecycle;
  late AppState _state;
  Timer? _idle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onPause: _flush,
      onHide: _flush,
      onShow: _activity,
    );
    _armIdle();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _state = context.appState;
  }

  void _armIdle() {
    _idle?.cancel();
    _idle = Timer(LearningTimer.idleAfter, _flush);
  }

  void _activity() {
    if (!_watch.isRunning) _watch.start();
    _armIdle();
  }

  void _flush() {
    _watch.stop();
    // Idle time before the timeout fired doesn't count.
    final idle = _idle?.isActive == false
        ? LearningTimer.idleAfter
        : Duration.zero;
    final spent = _watch.elapsed - idle;
    _watch.reset();
    if (spent > Duration.zero) _state.addLearningTime(spent);
  }

  @override
  void dispose() {
    _flush();
    _idle?.cancel();
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _activity(),
      onPointerSignal: (_) => _activity(),
      child: widget.child,
    );
  }
}
