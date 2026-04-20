// Streak information bottom sheet
// Displays daily streak progress with week tracker

import 'package:flutter/material.dart';
import 'package:readlock/bottom_sheets/RLBottomSheet.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLUIStrings.dart';

import 'package:pixelarticons/pixel.dart';
class StreakBottomSheet extends StatelessWidget {
  const StreakBottomSheet({super.key});

  static void show(BuildContext context) {
    RLBottomSheet.show(context, child: const StreakBottomSheet());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Fire icon
          LargeFireIcon,

          const Spacing.height(16),

          // Title
          RLTypography.headingLarge(RLUIStrings.STREAK_TITLE),

          const Spacing.height(8),

          // Message
          RLTypography.bodyMedium(
            RLUIStrings.STREAK_MESSAGE,
            color: RLDS.textSecondary,
            textAlign: TextAlign.center,
          ),

          const Spacing.height(24),

          // Week progress
          WeekStreakProgress(),
        ],
      ),
    );
  }

  static final Widget LargeFireIcon = const Icon(
    Pixel.zap,
    color: RLDS.warning,
    size: 48,
  );

  Widget WeekStreakProgress() {
    final List<String> weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final List<bool> completedDays = [true, true, true, false, false, false, false];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: DayIndicators(weekDays, completedDays),
    );
  }

  List<Widget> DayIndicators(List<String> days, List<bool> completed) {
    final List<Widget> indicators = [];

    for (int dayIndex = 0; dayIndex < days.length; dayIndex++) {
      final bool isCompleted = completed[dayIndex];
      final Color dayColor = getDayColor(isCompleted);
      final Color textColor = getDayTextColor(isCompleted);

      final BoxDecoration dayDecoration = BoxDecoration(
        color: dayColor,
        shape: BoxShape.circle,
      );

      indicators.add(
        Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: dayDecoration,
              child: Center(child: RLTypography.bodyMedium(days[dayIndex], color: textColor)),
            ),
          ],
        ),
      );
    }

    return indicators;
  }

  Color getDayColor(bool isCompleted) {
    if (isCompleted) {
      return RLDS.warning;
    }
    return RLDS.textSecondary.withValues(alpha: 0.2);
  }

  Color getDayTextColor(bool isCompleted) {
    if (isCompleted) {
      return RLDS.white;
    }
    return RLDS.textSecondary;
  }
}
