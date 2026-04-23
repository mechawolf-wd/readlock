// Reusable statistics card showing key metrics
// Solid color background with configurable stat items

import 'package:flutter/material.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/constants/RLDesignSystem.dart';

class RLStatsCard extends StatelessWidget {
  final String title;
  final Color color;
  final List<RLStatItem> items;

  const RLStatsCard({
    super.key,
    required this.title,
    required this.items,
    this.color = RLDS.info,
  });

  @override
  Widget build(BuildContext context) {
    final BoxDecoration cardDecoration = BoxDecoration(
      color: color,
      borderRadius: RLDS.borderRadiusMedium,
    );

    return Container(
      decoration: cardDecoration,
      padding: const EdgeInsets.all(RLDS.spacing20),
      child: Div.column([
        // Header
        Div.row([
          RLTypography.headingMedium(title, color: RLDS.white),
        ]),

        const Spacing.height(RLDS.spacing20),

        // Stats row
        StatsRow(),
      ]),
    );
  }

  Widget StatsRow() {
    final List<Widget> children = [];

    for (int itemIndex = 0; itemIndex < items.length; itemIndex++) {
      final RLStatItem item = items[itemIndex];

      children.add(Expanded(child: StatItemWidget(item: item)));

      final bool isNotLastItem = itemIndex < items.length - 1;

      if (isNotLastItem) {
        children.add(
          Container(
            width: 1.0,
            height: 48.0,
            color: RLDS.white.withValues(alpha: 0.2),
          ),
        );
      }
    }

    return Div.row(children);
  }
}

class RLStatItem {
  final String value;
  final String unit;
  final String label;

  const RLStatItem({
    required this.value,
    required this.unit,
    required this.label,
  });
}

class StatItemWidget extends StatelessWidget {
  final RLStatItem item;

  const StatItemWidget({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Div.column([
      Div.row([
        RLTypography.headingLarge(item.value, color: RLDS.white),

        const Spacing.width(RLDS.spacing4),

        RLTypography.bodyMedium(
          item.unit,
          color: RLDS.white.withValues(alpha: 0.8),
        ),
      ], mainAxisAlignment: MainAxisAlignment.center),

      const Spacing.height(RLDS.spacing4),

      RLTypography.bodyMedium(
        item.label,
        color: RLDS.white.withValues(alpha: 0.6),
        textAlign: TextAlign.center,
      ),
    ], crossAxisAlignment: CrossAxisAlignment.center);
  }
}
