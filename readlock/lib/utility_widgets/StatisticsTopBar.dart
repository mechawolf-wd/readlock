import 'package:readlock/constants/RLTheme.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:flutter/material.dart' hide Typography;

class StatisticsTopBar extends StatelessWidget {
  const StatisticsTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Div.row([
      XPCounter(),
      const Spacer(),
      StreakCounter(context),
    ]);
  }

  Widget StreakCounter(BuildContext context) {
    return Div.row(
      [
        Style.FireIcon,
        const Spacing.width(8),
        RLTypography.bodyLarge(
          '3',
          color: Colors.grey.withValues(alpha: 0.8),
        ),
      ],
      decoration: Style.decoration,
      color: Style.backgroundColor,
      padding: Style.padding,
      radius: 16,
      onTap: () => showStreakBottomSheet(context),
    );
  }

  void showStreakBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => const StreakBottomSheet(),
    );
  }

  Widget XPCounter() {
    return Div.row(
      [
        Style.KeyIcon,
        const Spacing.width(8),
        RLTypography.bodyLarge(
          '17',
          color: Colors.grey.withValues(alpha: 0.8),
        ),
      ],
      decoration: Style.decoration,
      color: Style.backgroundColor,
      padding: Style.padding,
      radius: 16,
    );
  }
}

class Style {
  static BoxDecoration decoration = BoxDecoration(
    border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withAlpha(70),
        offset: const Offset(0, 2),
      ),
    ],
  );

  static Color backgroundColor = Colors.white;

  static List<int> padding = [8, 16];

  static Icon KeyIcon = const Icon(
    Icons.key,
    color: RLTheme.primaryGreen,
    size: 20,
  );

  static Icon FireIcon = const Icon(
    Icons.local_fire_department,
    color: RLTheme.warningColor,
    size: 20,
  );
}

class StreakBottomSheet extends StatelessWidget {
  const StreakBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    const BoxDecoration sheetDecoration = BoxDecoration(
      color: RLTheme.backgroundDark,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
    );

    final BoxDecoration handleDecoration = BoxDecoration(
      color: RLTheme.textSecondary.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(2),
    );

    return Container(
      decoration: sheetDecoration,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: handleDecoration,
            ),
          ),

          const Spacing.height(24),

          // Fire icon
          LargeFireIcon(),

          const Spacing.height(16),

          // Title
          RLTypography.headingLarge('3 Day Combo!'),

          const Spacing.height(8),

          // Message
          RLTypography.bodyMedium(
            'Keep learning daily to build your combo.',
            color: RLTheme.textSecondary,
            textAlign: TextAlign.center,
          ),

          const Spacing.height(24),

          // Week progress
          WeekStreakProgress(),
        ],
      ),
    );
  }

  Widget LargeFireIcon() {
    return const Icon(
      Icons.local_fire_department,
      color: RLTheme.warningColor,
      size: 48,
    );
  }

  Widget WeekStreakProgress() {
    final List<String> weekDays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final List<bool> completedDays = [
      true,
      true,
      true,
      false,
      false,
      false,
      false,
    ];

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
              child: Center(
                child: RLTypography.bodyMedium(
                  days[dayIndex],
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return indicators;
  }

  Color getDayColor(bool isCompleted) {
    if (isCompleted) {
      return RLTheme.warningColor;
    }
    return RLTheme.textSecondary.withValues(alpha: 0.2);
  }

  Color getDayTextColor(bool isCompleted) {
    if (isCompleted) {
      return RLTheme.white;
    }
    return RLTheme.textSecondary;
  }
}
