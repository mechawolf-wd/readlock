// Drives device-panel brightness from the nightShiftLevelNotifier so the
// screen is actually dimmed below the OS slider when the reader picks a
// stronger Night Shift step. Uses screen_brightness's per-application
// override, which the OS restores automatically when the app is
// backgrounded so we don't need to babysit lifecycle events.

import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:readlock/constants/RLNightShift.dart';
import 'package:screen_brightness/screen_brightness.dart';

class NightShiftBrightnessService {
  static bool isInitialized = false;

  static void initialize() {
    if (isInitialized) {
      return;
    }

    isInitialized = true;

    nightShiftLevelNotifier.addListener(handleLevelChanged);

    // Apply the current value at startup so a persisted level takes
    // effect on first frame instead of waiting for a user interaction.
    handleLevelChanged();
  }

  static Future<void> handleLevelChanged() async {
    final int level = nightShiftLevelNotifier.value;
    final double target = getNightShiftBrightness(level);
    final bool isRestore = target == NIGHT_SHIFT_BRIGHTNESS_RESTORE;

    try {
      if (isRestore) {
        await ScreenBrightness().resetApplicationScreenBrightness();
        return;
      }

      await ScreenBrightness().setApplicationScreenBrightness(target);
    } on Exception catch (error) {
      if (kDebugMode) {
        developer.log('NightShiftBrightnessService failed: $error');
      }
    }
  }
}
