// Centralised haptic feedback. Every surface in the app should route
// through this service instead of calling HapticFeedback.* directly so
// the user-facing Haptics toggle in Settings silences haptics globally
// from one place. Methods early-return when the user has disabled
// haptics or when the underlying platform call has previously failed
// (latched off to avoid log spam on simulators / unsupported devices).
//
// Method names mirror HapticFeedback's API (lightImpact, mediumImpact,
// heavyImpact, selectionClick) so migrating a call site is a literal
// `HapticFeedback.x()` → `HapticsService.x()` swap.

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;

class HapticsService {
  // User-facing master switch. Wired to the Settings, Haptics toggle and
  // hydrated from UserModel.haptics on auth.
  static final ValueNotifier<bool> userHapticsEnabledNotifier = ValueNotifier<bool>(true);

  // Latched off when the platform throws (eg. unsupported device).
  static bool isHapticsAvailable = true;

  static Future<void> lightImpact() {
    return runHapticCall('light', HapticFeedback.lightImpact);
  }

  static Future<void> mediumImpact() {
    return runHapticCall('medium', HapticFeedback.mediumImpact);
  }

  static Future<void> heavyImpact() {
    return runHapticCall('heavy', HapticFeedback.heavyImpact);
  }

  static Future<void> selectionClick() {
    return runHapticCall('selection', HapticFeedback.selectionClick);
  }

  static Future<void> runHapticCall(String label, Future<void> Function() platformCall) async {
    final bool userMutedHaptics = !userHapticsEnabledNotifier.value;

    if (userMutedHaptics) {
      return;
    }

    final bool canProvideHaptics = isHapticsAvailable;

    if (!canProvideHaptics) {
      return;
    }

    try {
      await platformCall();
    } on Exception catch (error) {
      developer.log('Failed to provide $label haptic feedback: $error');
      isHapticsAvailable = false;
    }
  }
}
