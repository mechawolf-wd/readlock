// Reflective prompt swipe — renders thinking points as coloured cards that
// start blurred. Tapping the empty area below reveals them one-by-one, the
// same way ProgressiveText reveals sentences from a tap-to-continue zone.

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/models/CourseModel.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/services/feedback/HapticsService.dart';
import 'package:readlock/utility_widgets/visual_effects/BlurOverlay.dart';

// * Each thinking point rotates through one of these accent colours.
const List<Color> REFLECT_POINT_COLORS = [
  RLDS.info,
  RLDS.success,
  RLDS.warning,
];

const int REFLECT_POINTS_LIMIT = 3;

// Match the blur ProgressiveText applies to completed sentences so the reveal
// rhythm reads as part of the same family.
const double REFLECT_BLUR_SIGMA = 4.0;
const double REFLECT_BLUR_OPACITY = 0.2;

class CCReflect extends StatefulWidget {
  final ReflectSwipe content;

  const CCReflect({super.key, required this.content});

  @override
  State<CCReflect> createState() => CCReflectState();
}

class CCReflectState extends State<CCReflect> {
  int revealedCount = 0;

  List<String> getLimitedPoints() {
    return widget.content.thinkingPoints.take(REFLECT_POINTS_LIMIT).toList();
  }

  bool hasMoreToReveal() {
    return revealedCount < getLimitedPoints().length;
  }

  void handleRevealTap() {
    final bool canReveal = hasMoreToReveal();

    if (!canReveal) {
      return;
    }

    HapticsService.lightImpact();

    setState(() {
      revealedCount++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: RLDS.backgroundDark,
      padding: RLDS.contentPaddingInsets,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: ColumnChildren(),
      ),
    );
  }

  List<Widget> ColumnChildren() {
    final List<Widget> children = PointCards();

    children.add(Expanded(child: RevealArea()));

    return children;
  }

  List<Widget> PointCards() {
    final List<String> limitedPoints = getLimitedPoints();

    return limitedPoints.asMap().entries.map<Widget>((entry) {
      final int pointIndex = entry.key;
      final String point = entry.value;
      final Color pointColor = REFLECT_POINT_COLORS[pointIndex % REFLECT_POINT_COLORS.length];
      final bool isRevealed = pointIndex < revealedCount;

      return Padding(
        padding: const EdgeInsets.only(bottom: RLDS.spacing12),
        child: BlurOverlay(
          blurSigma: REFLECT_BLUR_SIGMA,
          opacity: REFLECT_BLUR_OPACITY,
          enabled: !isRevealed,
          child: PointCard(point: point, color: pointColor),
        ),
      );
    }).toList();
  }

  Widget PointCard({required String point, required Color color}) {
    final BoxDecoration cardDecoration = BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: RLDS.borderRadiusSmall,
      border: Border.all(color: color, width: 1),
    );

    return Container(
      padding: const EdgeInsets.all(RLDS.spacing16),
      decoration: cardDecoration,
      child: RLTypography.readingMedium(point, color: color),
    );
  }

  // Tap-to-reveal zone below the cards — mirrors ProgressiveText's
  // RevealButtonArea pattern: transparent surface filling the remaining
  // space, each tap pushes the next card out of blur.
  Widget RevealArea() {
    final bool hasMore = hasMoreToReveal();

    if (!hasMore) {
      return const SizedBox.shrink();
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: handleRevealTap,
        child: Container(width: double.infinity, color: RLDS.transparent),
      ),
    );
  }
}
