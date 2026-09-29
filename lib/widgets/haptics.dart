import 'package:flutter/services.dart';

/// Vibration feedback that respects the "Haptic feedback" setting in Config.
class Haptics {
  static bool enabled = true;

  static void selection() {
    if (enabled) HapticFeedback.selectionClick();
  }

  static void light() {
    if (enabled) HapticFeedback.lightImpact();
  }

  static void medium() {
    if (enabled) HapticFeedback.mediumImpact();
  }
}
