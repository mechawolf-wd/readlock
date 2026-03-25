// Learning statistics card showing reading progress
// Displays days/lessons completed stats

import 'package:flutter/material.dart';
import 'package:readlock/constants/RLDimensions.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLTheme.dart';

class LearningStatsCard extends StatelessWidget {
  const LearningStatsCard({super.key});

  static const Widget ShareIcon = Icon(
    Icons.share,
    color: RLTheme.white,
    size: RLDimensions.iconM,
  );

  void handleShareTap() {
    // Share functionality
  }

  @override
  Widget build(BuildContext context) {
    final BoxDecoration cardDecoration = BoxDecoration(
      color: RLTheme.primaryBlue,
      borderRadius: RLDimensions.borderRadiusXL,
    );

    return Container(
      decoration: cardDecoration,
      padding: RLDimensions.paddingAllXL,
      child: Div.column([
        // Header row
        Div.row([
          RLTypography.headingMedium('Learning Statistics', color: RLTheme.white),

          const Spacer(),

          GestureDetector(onTap: handleShareTap, child: ShareIcon),
        ]),

        const Spacing.height(20),

        // Stats row
        StatsRow(),
      ]),
    );
  }

  Widget StatsRow() {
    return Div.row([
      // Days equivalent stat
      const Expanded(
        child: StatItem(value: '320', unit: 'days', label: 'at 10 minutes/day'),
      ),

      // Divider
      Container(
        width: RLDimensions.dividerNormal,
        height: RLDimensions.buttonHeightL,
        color: Colors.white.withValues(alpha: RLDimensions.alphaMedium),
      ),

      // Lessons completed stat
      const Expanded(
        child: StatItem(value: '42', unit: 'lessons', label: 'completed'),
      ),
    ]);
  }
}

class StatItem extends StatelessWidget {
  final String value;
  final String unit;
  final String label;

  const StatItem({super.key, required this.value, required this.unit, required this.label});

  @override
  Widget build(BuildContext context) {
    return Div.column([
      Div.row([
        RLTypography.headingLarge(value, color: Colors.white),

        const Spacing.width(4),

        RLTypography.bodyMedium(
          unit,
          color: Colors.white.withValues(alpha: RLDimensions.opacitySoft),
        ),
      ], mainAxisAlignment: MainAxisAlignment.center),

      const Spacing.height(4),

      RLTypography.bodyMedium(
        label,
        color: Colors.white.withValues(alpha: RLDimensions.opacitySubtle),
        textAlign: TextAlign.center,
      ),
    ], crossAxisAlignment: CrossAxisAlignment.center);
  }
}
