import 'package:readlock/constants/RLTheme.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:flutter/material.dart' hide Typography;

class StatisticsTopBar extends StatelessWidget {
  const StatisticsTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Div.row([AhaCounter(), const Spacer(), StreakCounter()]);
  }

  Widget StreakCounter() {
    return Div.row(
      [Style.FireIcon, const Spacing.width(8), RLTypography.text('7')],
      decoration: Style.decoration,
      color: Style.backgroundColor,
      padding: Style.padding,
      radius: 16,
    );
  }

  Widget AhaCounter() {
    return Div.row(
      [Style.KeyIcon, const Spacing.width(8), RLTypography.text('23')],
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
    color: Colors.orange,
    size: 20,
  );
}
