// Bottom sheet that lets the reader dial in the eye-strain (Night Shift)
// overlay. CupertinoSlider with five divisions (off + four warmth steps),
// matching Apple's Night Shift "Less Warm / More Warm" picker. Updates the
// global nightShiftLevelNotifier on every drag so RLNightShiftOverlay
// reflects the change live; the Firestore write is debounced so dragging
// across the slider issues a single persistence call instead of one per
// division crossed.

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:readlock/services/feedback/HapticsService.dart';
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

const EdgeInsets NIGHT_SHIFT_SHEET_PADDING = EdgeInsets.fromLTRB(
  RLDS.spacing24,
  RLDS.spacing0,
  RLDS.spacing24,
  RLDS.spacing24,
);

// Warm amber the slider tint mirrors at max warmth — same hue family as
// the moon icon in the sheet header so the slider track reads as part of
// the same accent.
const Color NIGHT_SHIFT_WARM_COLOR = Color(0xFFCF6A1A);

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
    color: RLDS.warning,
    size: RLDS.iconMedium,
  );

  late int currentLevel;
  // Last value persisted to Firestore. Used by the debounced writer so a
  // settle-back to the original level (drag right then back to start)
  // doesn't fire a redundant write.
  late int lastPersistedLevel;
  Timer? persistDebounce;

  @override
  void initState() {
    super.initState();

    currentLevel = nightShiftLevelNotifier.value;
    lastPersistedLevel = currentLevel;
  }

  @override
  void dispose() {
    // Flush any pending write before tearing down so the level the user
    // landed on still makes it to Firestore even if they close the sheet
    // immediately after dragging.
    final Timer? pendingDebounce = persistDebounce;
    final bool hasPendingWrite = pendingDebounce != null && pendingDebounce.isActive;

    if (hasPendingWrite) {
      pendingDebounce.cancel();
      persistLevel(currentLevel);
    }

    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: NIGHT_SHIFT_SHEET_PADDING,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HeaderRow(),

          const Spacing.height(RLDS.spacing12),

          DescriptionLine(),

          const Spacing.height(RLDS.spacing24),

          WarmthSlider(),

          const Spacing.height(RLDS.spacing12),

          SliderEndLabels(),
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
    return Div.row(
      [
        RLTypography.bodyMedium(
          RLUIStrings.NIGHT_SHIFT_LESS_WARM_LABEL,
          color: RLDS.textMuted,
        ),

        RLTypography.bodyMedium(
          RLUIStrings.NIGHT_SHIFT_MORE_WARM_LABEL,
          color: RLDS.textMuted,
        ),
      ],
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
    );
  }
}
