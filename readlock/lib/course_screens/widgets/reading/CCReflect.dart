// Reflective prompt swipe — renders thinking points as plain coloured text,
// centred on the screen, revealed one-by-one with the exact same blur +
// progressive-text reveal rhythm as CCQuestion answer options.
//
// Each point sits blurred until tapped; the first tap kicks off the
// typewriter reveal (same cadence / same blur token / same once-completed
// pinning as the question options). No card chrome — just coloured text,
// so the reflect page reads as a moment of quiet thinking instead of
// a dashboard.

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/models/CourseModel.dart';
import 'package:readlock/design_system/RLLunarBlur.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/services/feedback/HapticsService.dart';
import 'package:readlock/utility_widgets/text_animation/ProgressiveText.dart';
import 'package:readlock/utility_widgets/visual_effects/BlurOverlay.dart';

// * Each thinking point rotates through one of these accent colours.
const List<Color> REFLECT_POINT_COLORS = [RLDS.markupRed, RLDS.markupGreen, RLDS.onSurface];

const int REFLECT_POINTS_LIMIT = 3;

class CCReflect extends StatefulWidget {
  final ReflectSwipe content;

  const CCReflect({super.key, required this.content});

  @override
  State<CCReflect> createState() => CCReflectState();
}

class CCReflectState extends State<CCReflect> {
  // Point indices the reader has already tapped to reveal.
  Set<int> revealedPoints = {};

  List<String> getLimitedPoints() {
    return widget.content.thinkingPoints.take(REFLECT_POINTS_LIMIT).toList();
  }

  void handlePointTap(int pointIndex) {
    final bool alreadyRevealed = revealedPoints.contains(pointIndex);

    if (alreadyRevealed) {
      return;
    }

    HapticsService.lightImpact();

    setState(() {
      revealedPoints.add(pointIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: RLDS.contentPaddingInsets,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: PointsColumnChildren(),
      ),
    );
  }

  List<Widget> PointsColumnChildren() {
    final List<String> points = getLimitedPoints();
    final List<Widget> widgets = [];

    for (int pointIndex = 0; pointIndex < points.length; pointIndex++) {
      widgets.add(PointEntry(pointIndex: pointIndex, point: points[pointIndex]));

      final bool isLastPoint = pointIndex == points.length - 1;

      if (!isLastPoint) {
        widgets.add(const Spacing.height(RLDS.spacing24));
      }
    }

    return widgets;
  }

  Widget PointEntry({required int pointIndex, required String point}) {
    final Color pointColor = REFLECT_POINT_COLORS[pointIndex % REFLECT_POINT_COLORS.length];
    final bool isRevealed = revealedPoints.contains(pointIndex);

    void onEntryTap() => handlePointTap(pointIndex);

    final Widget pointText = PointText(
      pointIndex: pointIndex,
      point: point,
      color: pointColor,
      isRevealed: isRevealed,
    );

    // Same frosted LunarBlur surface the continue button in CCTextContent
    // uses — each thinking point reads as a card on the same pane. The
    // BlurOverlay still gates the tap-to-reveal typewriter until the reader
    // taps, matching the question's covered-answer rhythm.
    final Widget pointSurface = RLLunarBlur(
      borderRadius: RLDS.borderRadiusMedium,
      padding: RLDS.contentPaddingMediumInsets,
      child: pointText,
    );

    return GestureDetector(
      onTap: onEntryTap,
      behavior: HitTestBehavior.opaque,
      child: BlurOverlay(enabled: !isRevealed, child: pointSurface),
    );
  }

  // Two-state render:
  //
  //   1. not revealed → transparent label (reserves layout so the tap
  //      target height doesn't shift when the reveal kicks off).
  //   2. revealed → ProgressiveText mounted with a stable ValueKey. State
  //      persists across later parent rebuilds, so the reveal plays
  //      exactly once and never swaps to a different widget — the snap
  //      at completion is what that swap was causing.
  Widget PointText({
    required int pointIndex,
    required String point,
    required Color color,
    required bool isRevealed,
  }) {
    if (!isRevealed) {
      return RLTypography.readingLarge(
        point,
        color: RLDS.transparent,
        textAlign: TextAlign.center,
      );
    }

    return ProgressiveText(
      key: ValueKey('reflect_point_$pointIndex'),
      textSegments: [point],
      textStyle: RLTypography.readingLargeStyle.copyWith(color: color),
      textAlign: TextAlign.center,
      blurCompletedSentences: false,
      enableTapToReveal: false,
    );
  }
}
