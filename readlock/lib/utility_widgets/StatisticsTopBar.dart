import 'package:readlock/constants/appTheme.dart';
import 'package:readlock/constants/typography.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:flutter/material.dart' hide Typography;

class StatisticsTopBar extends StatelessWidget {
  const StatisticsTopBar({super.key});

  // * ----- build -----
  @override
  Widget build(BuildContext context) {
    return Div.row([StreakCounter(), const Spacer(), AhaCounter()]);
  }
  // * -----------------

  Widget StreakCounter() {
    return Div.row([
      const Icon(
        Icons.local_fire_department,
        color: Colors.orange,
        size: 20,
      ),

      const Spacing.width(8),

      RLTypography.text('7'),
    ]);
  }

  Widget AhaCounter() {
    return Div.row([
      Style.LightBulbIcon,

      const Spacing.width(8),

      RLTypography.text('23'),
    ]);
  }
}

class Style {
  static BoxDecoration decoration = BoxDecoration(
    color: Colors.grey.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
  );

  static Icon LightBulbIcon = const Icon(
    Icons.lightbulb,
    color: RLTheme.primaryGreen,
    size: 20,
  );
}
