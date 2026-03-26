// Learning statistics card showing reading progress
// Displays days/lessons completed stats

import 'package:flutter/material.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLDesignSystem.dart';

class LearningStatsCard extends StatelessWidget {
  const LearningStatsCard({super.key});

  static final Widget ShareIcon = Icon(
    Icons.share,
    color: RLDS.white,
    size: 20.0,
  );

  void handleShareTap() {
    // Share functionality
  }

  @override
  Widget build(BuildContext context) {
    final BoxDecoration cardDecoration = BoxDecoration(
      color: RLDS.primaryBlue,
      borderRadius: BorderRadius.circular(16.0),
    );

    return Container(
      decoration: cardDecoration,
      padding: EdgeInsets.all(20.0),
      child: Div.column([
        // Header row
        Div.row([
          RLTypography.headingMedium(RLUIStrings.LEARNING_STATS_TITLE, color: RLDS.white),

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
        child: StatItem(value: '320', unit: RLUIStrings.LEARNING_STATS_DAYS_UNIT, label: RLUIStrings.LEARNING_STATS_DAYS_LABEL),
      ),

      // Divider
      Container(
        width: 1.0,
        height: 48.0,
        color: RLDS.white.withValues(alpha: 0.2),
      ),

      // Lessons completed stat
      const Expanded(
        child: StatItem(value: '42', unit: RLUIStrings.LEARNING_STATS_LESSONS_UNIT, label: RLUIStrings.LEARNING_STATS_LESSONS_LABEL),
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
        RLTypography.headingLarge(value, color: RLDS.white),

        const Spacing.width(4),

        RLTypography.bodyMedium(
          unit,
          color: RLDS.white.withValues(alpha: 0.8),
        ),
      ], mainAxisAlignment: MainAxisAlignment.center),

      const Spacing.height(4),

      RLTypography.bodyMedium(
        label,
        color: RLDS.white.withValues(alpha: 0.6),
        textAlign: TextAlign.center,
      ),
    ], crossAxisAlignment: CrossAxisAlignment.center);
  }
}
