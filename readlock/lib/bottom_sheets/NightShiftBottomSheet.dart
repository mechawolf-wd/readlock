// Bottom sheet that lets the reader dial in the eye-strain (Night Shift)
// overlay. CupertinoSlider with five divisions (off + four warmth steps),
// matching Apple's Night Shift "Less Warm / More Warm" picker. Updates the
// global nightShiftLevelNotifier on every drag so RLNightShiftOverlay
// reflects the change live.

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:readlock/bottom_sheets/RLBottomSheet.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLNightShift.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/services/auth/UserService.dart';

import 'package:pixelarticons/pixel.dart';

const EdgeInsets NIGHT_SHIFT_SHEET_PADDING = EdgeInsets.fromLTRB(
  RLDS.spacing24,
  RLDS.spacing0,
  RLDS.spacing24,
  RLDS.spacing24,
);

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

  @override
  void initState() {
    super.initState();

    currentLevel = nightShiftLevelNotifier.value;
  }

  void handleLevelChanged(double value) {
    final int nextLevel = value.round();
    final bool isUnchanged = nextLevel == currentLevel;

    if (isUnchanged) {
      return;
    }

    HapticFeedback.selectionClick();

    nightShiftLevelNotifier.value = nextLevel;

    setState(() {
      currentLevel = nextLevel;
    });

    UserService.updateNightShiftLevel(nextLevel);
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
