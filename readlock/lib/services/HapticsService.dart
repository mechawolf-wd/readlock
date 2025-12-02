import 'package:flutter/services.dart';
import 'dart:developer' as developer;

class HapticsService {
  static bool isHapticsEnabled = true;

  static Future<void> lightImpact() async {
    final bool canProvideHaptics = isHapticsEnabled;

    if (!canProvideHaptics) {
      return;
    }

    try {
      await HapticFeedback.lightImpact();
    } on Exception catch (error) {
      developer.log('Failed to provide light haptic feedback: $error');
      isHapticsEnabled = false;
    }
  }

  static Future<void> mediumImpact() async {
    final bool canProvideHaptics = isHapticsEnabled;

    if (!canProvideHaptics) {
      return;
    }

    try {
      await HapticFeedback.mediumImpact();
    } on Exception catch (error) {
      developer.log('Failed to provide medium haptic feedback: $error');
      isHapticsEnabled = false;
    }
  }

  static Future<void> heavyImpact() async {
    final bool canProvideHaptics = isHapticsEnabled;

    if (!canProvideHaptics) {
      return;
    }

    try {
      await HapticFeedback.heavyImpact();
    } on Exception catch (error) {
      developer.log('Failed to provide heavy haptic feedback: $error');
      isHapticsEnabled = false;
    }
  }

  static Future<void> selectionClick() async {
    final bool canProvideHaptics = isHapticsEnabled;

    if (!canProvideHaptics) {
      return;
    }

    try {
      await HapticFeedback.selectionClick();
    } on Exception catch (error) {
      developer.log(
        'Failed to provide selection haptic feedback: $error',
      );
      isHapticsEnabled = false;
    }
  }

  static Future<void> vibrate() async {
    final bool canProvideHaptics = isHapticsEnabled;

    if (!canProvideHaptics) {
      return;
    }

    try {
      await HapticFeedback.vibrate();
    } on Exception catch (error) {
      developer.log('Failed to provide vibration feedback: $error');
      isHapticsEnabled = false;
    }
  }
}
