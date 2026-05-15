// Bottom sheet that lets the reader dial in the eye-strain (Night Shift)
// overlay. CupertinoSlider with five divisions (off + four warmth steps),
// matching Apple's Night Shift "Less Warm / More Warm" picker. Updates the
// global nightShiftLevelNotifier on every drag so RLNightShiftOverlay
// reflects the change live; the Firestore write is debounced so dragging
// across the slider issues a single persistence call instead of one per
// division crossed.
//
// Below the slider the sheet exposes Apple's Night Shift Custom Schedule:
// a Scheduled toggle plus From / To time rows that, when tapped, reveal an
// inline Cupertino time wheel. NightShiftScheduleService picks up the
// notifier changes and auto-applies the warmth at the window edges.

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:readlock/services/feedback/HapticsService.dart';
import 'package:readlock/services/feedback/SoundService.dart';
import 'package:readlock/bottom_sheets/RLBottomSheet.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLNightShift.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/services/auth/UserService.dart';

import 'package:pixelarticons/pixel.dart';

// * How long the slider waits after the last value change before
// persisting to Firestore. Long enough to coalesce a full sweep across
// all four divisions into one write, short enough that releasing the
// thumb feels effectively instant.
const Duration NIGHT_SHIFT_PERSIST_DEBOUNCE = Duration(milliseconds: 400);

// Wheel pickers fire onChanged on every detent so the schedule write is
// debounced the same way the warmth slider's is, with a slightly longer
// settle so the user can land on a minute without a write per click.
const Duration NIGHT_SHIFT_SCHEDULE_PERSIST_DEBOUNCE = Duration(milliseconds: 600);

const EdgeInsets NIGHT_SHIFT_SHEET_PADDING = EdgeInsets.fromLTRB(
  RLDS.spacing24,
  RLDS.spacing0,
  RLDS.spacing24,
  RLDS.spacing24,
);

// Warm amber the slider tint mirrors at max warmth, same hue family as
// the moon icon in the sheet header so the slider track reads as part of
// the same accent.
const Color NIGHT_SHIFT_WARM_COLOR = Color(0xFFCF6A1A);

// Inline time picker height. Matches the visual weight of the iOS Night
// Shift sheet's wheel without dominating the bottom sheet.
const double NIGHT_SHIFT_PICKER_HEIGHT = 180.0;

// Hairline divider drawn above the schedule section and between the From
// and To rows.
const double NIGHT_SHIFT_DIVIDER_HEIGHT = 1.0;
const Color NIGHT_SHIFT_DIVIDER_COLOR = Color(0x1FFFFFFF);

// Schedule row sentinel values used by expandedField, kept as constants
// so the comparison sites read clearly.
const String NIGHT_SHIFT_SCHEDULE_FIELD_FROM = 'from';
const String NIGHT_SHIFT_SCHEDULE_FIELD_TO = 'to';

// Animation curve / duration used when expanding the inline picker and
// when the schedule body reveals on toggle. Short and snappy so the
// sheet feels responsive on tap.
const Duration NIGHT_SHIFT_REVEAL_DURATION = Duration(milliseconds: 220);
const Curve NIGHT_SHIFT_REVEAL_CURVE = Curves.easeInOut;

class NightShiftBottomSheet {
  static void show(BuildContext context) {
    RLBottomSheet.show(context, child: const NightShiftSheet());
  }
}

class NightShiftSheet extends StatefulWidget {
  const NightShiftSheet({super.key});

  @override
  State<NightShiftSheet> createState() => NightShiftSheetState();
}

class NightShiftSheetState extends State<NightShiftSheet> {
  static final Widget HeaderIcon = const Icon(
    Pixel.moon,
    color: NIGHT_SHIFT_WARM_COLOR,
    size: RLDS.iconLarge,
  );

  static const Widget RowDivider = SizedBox(
    height: NIGHT_SHIFT_DIVIDER_HEIGHT,
    child: ColoredBox(color: NIGHT_SHIFT_DIVIDER_COLOR),
  );

  late int currentLevel;
  // Last value persisted to Firestore. Used by the debounced writer so a
  // settle-back to the original level (drag right then back to start)
  // doesn't fire a redundant write.
  late int lastPersistedLevel;
  Timer? persistDebounce;

  // * Schedule state. Mirrors the three schedule notifiers locally so
  // the toggle and time rows can rebuild without a ValueListenableBuilder
  // for each. Persisted writes are debounced through schedulePersistDebounce
  // so wheel rotation doesn't hammer Firestore.
  late bool scheduleEnabled;
  late int scheduleFromMinutes;
  late int scheduleToMinutes;
  int? lastPersistedFromMinutes;
  int? lastPersistedToMinutes;
  Timer? schedulePersistDebounce;

  // Which time row currently has its inline picker expanded. Null when
  // both rows are collapsed; otherwise NIGHT_SHIFT_SCHEDULE_FIELD_FROM
  // or NIGHT_SHIFT_SCHEDULE_FIELD_TO.
  String? expandedField;

  @override
  void initState() {
    super.initState();

    currentLevel = nightShiftLevelNotifier.value;
    lastPersistedLevel = currentLevel;

    scheduleEnabled = nightShiftScheduleEnabledNotifier.value;
    scheduleFromMinutes = nightShiftScheduleFromMinutesNotifier.value;
    scheduleToMinutes = nightShiftScheduleToMinutesNotifier.value;
    lastPersistedFromMinutes = scheduleFromMinutes;
    lastPersistedToMinutes = scheduleToMinutes;
  }

  @override
  void dispose() {
    // Flush any pending writes before tearing down so the level / times
    // the user landed on still make it to Firestore even if they close
    // the sheet immediately after the last change.
    flushPendingLevelWrite();
    flushPendingScheduleWrite();

    super.dispose();
  }

  void flushPendingLevelWrite() {
    final Timer? pendingDebounce = persistDebounce;
    final bool hasPendingWrite = pendingDebounce != null && pendingDebounce.isActive;

    if (!hasPendingWrite) {
      return;
    }

    pendingDebounce.cancel();
    persistLevel(currentLevel);
  }

  void flushPendingScheduleWrite() {
    final Timer? pendingDebounce = schedulePersistDebounce;
    final bool hasPendingWrite = pendingDebounce != null && pendingDebounce.isActive;

    if (!hasPendingWrite) {
      return;
    }

    pendingDebounce.cancel();
    persistSchedule();
  }

  // * Warmth slider handlers (existing flow).

  void handleLevelChanged(double value) {
    final int nextLevel = value.round();
    final bool isUnchanged = nextLevel == currentLevel;

    if (isUnchanged) {
      return;
    }

    HapticsService.selectionClick();

    nightShiftLevelNotifier.value = nextLevel;

    setState(() {
      currentLevel = nextLevel;
    });

    schedulePersist(nextLevel);
  }

  // Coalesces drag updates into a single Firestore write. Each new step
  // resets the timer, so the network call only fires once the slider has
  // been still for NIGHT_SHIFT_PERSIST_DEBOUNCE.
  void schedulePersist(int level) {
    persistDebounce?.cancel();

    persistDebounce = Timer(NIGHT_SHIFT_PERSIST_DEBOUNCE, () {
      persistLevel(level);
    });
  }

  void persistLevel(int level) {
    final bool isAlreadyPersisted = level == lastPersistedLevel;

    if (isAlreadyPersisted) {
      return;
    }

    lastPersistedLevel = level;

    UserService.updateNightShiftLevel(level);
  }

  // * Schedule handlers.

  void handleScheduleToggle(bool nextValue) {
    HapticsService.selectionClick();
    SoundService.playSwitch();

    setState(() {
      scheduleEnabled = nextValue;

      // Collapse any expanded picker when the schedule turns off so the
      // sheet shrinks back to its compact height.
      if (!nextValue) {
        expandedField = null;
      }
    });

    nightShiftScheduleEnabledNotifier.value = nextValue;

    UserService.updateNightShiftScheduleEnabled(nextValue);
  }

  void handleFromTapped() {
    HapticsService.selectionClick();

    setState(() {
      final bool fromIsExpanded = expandedField == NIGHT_SHIFT_SCHEDULE_FIELD_FROM;
      expandedField = fromIsExpanded ? null : NIGHT_SHIFT_SCHEDULE_FIELD_FROM;
    });
  }

  void handleToTapped() {
    HapticsService.selectionClick();

    setState(() {
      final bool toIsExpanded = expandedField == NIGHT_SHIFT_SCHEDULE_FIELD_TO;
      expandedField = toIsExpanded ? null : NIGHT_SHIFT_SCHEDULE_FIELD_TO;
    });
  }

  void handleFromTimeChanged(DateTime nextTime) {
    final int nextMinutes = nextTime.hour * 60 + nextTime.minute;
    final bool isUnchanged = nextMinutes == scheduleFromMinutes;

    if (isUnchanged) {
      return;
    }

    HapticsService.selectionClick();

    setState(() {
      scheduleFromMinutes = nextMinutes;
    });

    nightShiftScheduleFromMinutesNotifier.value = nextMinutes;

    queueSchedulePersist();
  }

  void handleToTimeChanged(DateTime nextTime) {
    final int nextMinutes = nextTime.hour * 60 + nextTime.minute;
    final bool isUnchanged = nextMinutes == scheduleToMinutes;

    if (isUnchanged) {
      return;
    }

    HapticsService.selectionClick();

    setState(() {
      scheduleToMinutes = nextMinutes;
    });

    nightShiftScheduleToMinutesNotifier.value = nextMinutes;

    queueSchedulePersist();
  }

  // Single debounce that flushes whichever of the two times changed.
  // Each wheel rotation resets the timer so a settle on the final value
  // results in one write per changed field.
  void queueSchedulePersist() {
    schedulePersistDebounce?.cancel();

    schedulePersistDebounce = Timer(NIGHT_SHIFT_SCHEDULE_PERSIST_DEBOUNCE, persistSchedule);
  }

  void persistSchedule() {
    final bool fromChanged = scheduleFromMinutes != lastPersistedFromMinutes;
    final bool toChanged = scheduleToMinutes != lastPersistedToMinutes;

    if (fromChanged) {
      lastPersistedFromMinutes = scheduleFromMinutes;
      UserService.updateNightShiftScheduleFromMinutes(scheduleFromMinutes);
    }

    if (toChanged) {
      lastPersistedToMinutes = scheduleToMinutes;
      UserService.updateNightShiftScheduleToMinutes(scheduleToMinutes);
    }
  }

  // * Helpers.

  String formatMinutesAsClockTime(int minutes) {
    final int hours = (minutes ~/ 60) % 24;
    final int remainingMinutes = minutes % 60;
    final String hoursLabel = hours.toString().padLeft(2, '0');
    final String minutesLabel = remainingMinutes.toString().padLeft(2, '0');

    return '$hoursLabel:$minutesLabel';
  }

  DateTime initialPickerDateTime(int minutes) {
    final int hours = (minutes ~/ 60) % 24;
    final int remainingMinutes = minutes % 60;

    return DateTime(2000, 1, 1, hours, remainingMinutes);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: NIGHT_SHIFT_SHEET_PADDING,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          HeaderRow(),

          const Spacing.height(RLDS.spacing12),

          // Description
          DescriptionLine(),

          const Spacing.height(RLDS.spacing24),

          // Warmth slider
          WarmthSlider(),

          const Spacing.height(RLDS.spacing12),

          SliderEndLabels(),

          const Spacing.height(RLDS.spacing24),

          // Schedule section
          ScheduleSection(),
        ],
      ),
    );
  }

  Widget HeaderRow() {
    return Div.row([
      HeaderIcon,

      const Spacing.width(RLDS.spacing12),

      RLTypography.headingMedium(RLUIStrings.NIGHT_SHIFT_TITLE),
    ], mainAxisAlignment: MainAxisAlignment.start);
  }

  Widget DescriptionLine() {
    return RLTypography.bodyMedium(
      RLUIStrings.NIGHT_SHIFT_DESCRIPTION,
      color: RLDS.textSecondary,
    );
  }

  Widget WarmthSlider() {
    final double sliderMax = NIGHT_SHIFT_MAX_LEVEL.toDouble();
    final double sliderValue = currentLevel.toDouble();

    return CupertinoSlider(
      value: sliderValue,
      max: sliderMax,
      divisions: NIGHT_SHIFT_MAX_LEVEL,
      activeColor: NIGHT_SHIFT_WARM_COLOR,
      onChanged: handleLevelChanged,
    );
  }

  Widget SliderEndLabels() {
    return Div.row([
      RLTypography.bodyMedium(RLUIStrings.NIGHT_SHIFT_LESS_WARM_LABEL, color: RLDS.textMuted),

      RLTypography.bodyMedium(RLUIStrings.NIGHT_SHIFT_MORE_WARM_LABEL, color: RLDS.textMuted),
    ], mainAxisAlignment: MainAxisAlignment.spaceBetween);
  }

  // * Schedule section: Scheduled toggle, then (when enabled) From/To
  // rows with inline time pickers that expand on tap.

  Widget ScheduleSection() {
    final Widget scheduleBody = ScheduleBody();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RowDivider,

        ScheduleToggleRow(),

        // AnimatedSize gives the reveal a smooth height transition so the
        // bottom sheet grows / shrinks instead of snapping when the
        // toggle flips or a picker expands.
        AnimatedSize(
          duration: NIGHT_SHIFT_REVEAL_DURATION,
          curve: NIGHT_SHIFT_REVEAL_CURVE,
          alignment: Alignment.topCenter,
          child: scheduleBody,
        ),
      ],
    );
  }

  Widget ScheduleBody() {
    final bool scheduleIsEnabled = scheduleEnabled;

    if (!scheduleIsEnabled) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [FromRow(), FromPicker(), RowDivider, ToRow(), ToPicker()],
    );
  }

  Widget ScheduleToggleRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: RLDS.spacing12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RLTypography.bodyMedium(RLUIStrings.NIGHT_SHIFT_SCHEDULE_LABEL),

          CupertinoSwitch(
            value: scheduleEnabled,
            activeTrackColor: NIGHT_SHIFT_WARM_COLOR,
            onChanged: handleScheduleToggle,
          ),
        ],
      ),
    );
  }

  Widget FromRow() {
    final bool fromIsExpanded = expandedField == NIGHT_SHIFT_SCHEDULE_FIELD_FROM;
    final Color timeColor = fromIsExpanded ? NIGHT_SHIFT_WARM_COLOR : RLDS.textPrimary;
    final String timeLabel = formatMinutesAsClockTime(scheduleFromMinutes);

    return Div.row(
      [
        RLTypography.bodyMedium(RLUIStrings.NIGHT_SHIFT_SCHEDULE_FROM_LABEL),

        RLTypography.bodyMedium(timeLabel, color: timeColor),
      ],
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      // Transparent fill so the gesture detector receives taps across
      // the whole row, not just where the two text widgets paint.
      color: RLDS.transparent,
      padding: const EdgeInsets.symmetric(vertical: RLDS.spacing12),
      onTap: handleFromTapped,
    );
  }

  Widget ToRow() {
    final bool toIsExpanded = expandedField == NIGHT_SHIFT_SCHEDULE_FIELD_TO;
    final Color timeColor = toIsExpanded ? NIGHT_SHIFT_WARM_COLOR : RLDS.textPrimary;
    final String timeLabel = formatMinutesAsClockTime(scheduleToMinutes);

    return Div.row(
      [
        RLTypography.bodyMedium(RLUIStrings.NIGHT_SHIFT_SCHEDULE_TO_LABEL),

        RLTypography.bodyMedium(timeLabel, color: timeColor),
      ],
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      color: RLDS.transparent,
      padding: const EdgeInsets.symmetric(vertical: RLDS.spacing12),
      onTap: handleToTapped,
    );
  }

  Widget FromPicker() {
    final bool fromIsExpanded = expandedField == NIGHT_SHIFT_SCHEDULE_FIELD_FROM;

    if (!fromIsExpanded) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: NIGHT_SHIFT_PICKER_HEIGHT,
      child: CupertinoDatePicker(
        mode: CupertinoDatePickerMode.time,
        use24hFormat: true,
        initialDateTime: initialPickerDateTime(scheduleFromMinutes),
        onDateTimeChanged: handleFromTimeChanged,
      ),
    );
  }

  Widget ToPicker() {
    final bool toIsExpanded = expandedField == NIGHT_SHIFT_SCHEDULE_FIELD_TO;

    if (!toIsExpanded) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: NIGHT_SHIFT_PICKER_HEIGHT,
      child: CupertinoDatePicker(
        mode: CupertinoDatePickerMode.time,
        use24hFormat: true,
        initialDateTime: initialPickerDateTime(scheduleToMinutes),
        onDateTimeChanged: handleToTimeChanged,
      ),
    );
  }
}
