// Drives the warmth level from the user's daily schedule, modelled on
// iOS Night Shift's "Custom Schedule". When the schedule is on and the
// wall clock crosses the From boundary, the level is auto-set to
// NIGHT_SHIFT_SCHEDULED_LEVEL; when it crosses the To boundary, the
// level returns to 0. If the user manually changes the warmth slider
// inside the window, that override is respected until the next entry
// boundary (matches Apple's "off until tomorrow" affordance).
//
// Re-evaluation triggers:
//   1. A 30s periodic timer while the app is foregrounded.
//   2. AppLifecycleState.resumed (foreground returns from background).
//   3. Any change to the schedule notifiers (toggle, From, To).
//
// The service does not persist state of its own. Schedule preferences
// live on UserModel; the override flag is in-memory and resets at the
// next entry transition, which is the simplest behaviour that matches
// the user's expectation of "manual off lasts the night".

import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:readlock/constants/RLNightShift.dart';

// How often the foregrounded app re-checks whether the wall clock has
// crossed a window boundary. 30s is well under the smallest meaningful
// scheduling unit (1 minute), so a boundary is never missed by more
// than half a minute.
const Duration NIGHT_SHIFT_SCHEDULE_TICK_INTERVAL = Duration(seconds: 30);

class NightShiftScheduleService with WidgetsBindingObserver {
  static final NightShiftScheduleService instance = NightShiftScheduleService();
  static bool isInitialized = false;

  // Snapshot of the last evaluation: true if the wall clock was inside
  // the daily window. Used to detect entry / exit transitions between
  // ticks. Starts false so a startup-in-window appears as an entry
  // transition and the auto-apply rule fires.
  bool wasInWindow = false;

  // True while the user has manually adjusted the warmth slider during
  // the current window. Suppresses auto-apply for the rest of the
  // window. Resets on the next entry boundary.
  bool userOverrodeThisWindow = false;

  // Gates handleLevelChanged so the service's own writes to
  // nightShiftLevelNotifier don't get misclassified as a manual user
  // override.
  bool isApplyingAutomatically = false;

  Timer? evaluateTimer;

  static void initialize() {
    if (isInitialized) {
      return;
    }

    isInitialized = true;
    instance.attach();
  }

  void attach() {
    WidgetsBinding.instance.addObserver(this);

    nightShiftScheduleEnabledNotifier.addListener(handleEnabledChanged);
    nightShiftScheduleFromMinutesNotifier.addListener(handleBoundsChanged);
    nightShiftScheduleToMinutesNotifier.addListener(handleBoundsChanged);
    nightShiftLevelNotifier.addListener(handleLevelChanged);

    startTicking();
    evaluate();
  }

  void startTicking() {
    evaluateTimer?.cancel();
    evaluateTimer = Timer.periodic(
      NIGHT_SHIFT_SCHEDULE_TICK_INTERVAL,
      (_) => evaluate(),
    );
  }

  void stopTicking() {
    evaluateTimer?.cancel();
    evaluateTimer = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final bool isResumed = state == AppLifecycleState.resumed;

    if (isResumed) {
      startTicking();
      evaluate();
      return;
    }

    final bool isBackgrounded =
        state == AppLifecycleState.paused || state == AppLifecycleState.inactive;

    if (isBackgrounded) {
      stopTicking();
    }
  }

  // Fired when the user toggles the master "Scheduled" switch. Turning
  // it on while inside the window applies the scheduled level
  // immediately (Apple does the same); turning it off clears any active
  // warmth so the overlay disappears with the toggle, matching the
  // user's expectation that "Scheduled off" means "no night session".
  void handleEnabledChanged() {
    final bool scheduleEnabled = nightShiftScheduleEnabledNotifier.value;

    if (!scheduleEnabled) {
      userOverrodeThisWindow = false;
      wasInWindow = false;
      applyLevel(NIGHT_SHIFT_OFF_LEVEL);
      return;
    }

    userOverrodeThisWindow = false;

    final int nowMinutes = currentMinutesSinceMidnight(DateTime.now());
    final int fromMinutes = nightShiftScheduleFromMinutesNotifier.value;
    final int toMinutes = nightShiftScheduleToMinutesNotifier.value;
    final bool inWindow = isWithinNightShiftWindow(nowMinutes, fromMinutes, toMinutes);

    wasInWindow = inWindow;

    final bool levelIsOff = nightShiftLevelNotifier.value == NIGHT_SHIFT_OFF_LEVEL;

    if (inWindow && levelIsOff) {
      applyLevel(NIGHT_SHIFT_SCHEDULED_LEVEL);
    }
  }

  void handleBoundsChanged() {
    evaluate();
  }

  void handleLevelChanged() {
    if (isApplyingAutomatically) {
      return;
    }

    final bool scheduleEnabled = nightShiftScheduleEnabledNotifier.value;

    if (!scheduleEnabled) {
      return;
    }

    if (!wasInWindow) {
      return;
    }

    userOverrodeThisWindow = true;
  }

  void evaluate() {
    final bool scheduleEnabled = nightShiftScheduleEnabledNotifier.value;
    final int fromMinutes = nightShiftScheduleFromMinutesNotifier.value;
    final int toMinutes = nightShiftScheduleToMinutesNotifier.value;
    final int nowMinutes = currentMinutesSinceMidnight(DateTime.now());

    final bool inWindow = isWithinNightShiftWindow(nowMinutes, fromMinutes, toMinutes);

    final bool justEnteredWindow = inWindow && !wasInWindow;
    final bool justExitedWindow = !inWindow && wasInWindow;

    if (justEnteredWindow) {
      userOverrodeThisWindow = false;
    }

    wasInWindow = inWindow;

    if (!scheduleEnabled) {
      return;
    }

    if (userOverrodeThisWindow) {
      return;
    }

    if (justEnteredWindow) {
      final bool levelIsOff = nightShiftLevelNotifier.value == NIGHT_SHIFT_OFF_LEVEL;

      if (levelIsOff) {
        applyLevel(NIGHT_SHIFT_SCHEDULED_LEVEL);
      }

      return;
    }

    if (justExitedWindow) {
      applyLevel(NIGHT_SHIFT_OFF_LEVEL);
    }
  }

  void applyLevel(int level) {
    final bool isUnchanged = nightShiftLevelNotifier.value == level;

    if (isUnchanged) {
      return;
    }

    isApplyingAutomatically = true;

    try {
      nightShiftLevelNotifier.value = level;
    } on Exception catch (error) {
      if (kDebugMode) {
        developer.log('NightShiftScheduleService applyLevel failed: $error');
      }
    } finally {
      isApplyingAutomatically = false;
    }
  }
}
