// Learning statistics card showing reading progress
// Uses RLStatsCard component with days/lessons stats

import 'package:flutter/material.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/design_system/RLStatsCard.dart';

class LearningStatsCard extends StatelessWidget {
  const LearningStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const RLStatsCard(
      title: RLUIStrings.LEARNING_STATS_TITLE,
      items: [
        RLStatItem(
          value: '320',
          unit: RLUIStrings.LEARNING_STATS_DAYS_UNIT,
          label: RLUIStrings.LEARNING_STATS_DAYS_LABEL,
        ),

        RLStatItem(
          value: '42',
          unit: RLUIStrings.LEARNING_STATS_LESSONS_UNIT,
          label: RLUIStrings.LEARNING_STATS_LESSONS_LABEL,
        ),
      ],
    );
  }
}
