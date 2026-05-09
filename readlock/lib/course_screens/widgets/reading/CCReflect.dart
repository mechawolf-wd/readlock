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
import 'package:pixelarticons/pixel.dart';
import 'package:readlock/models/CourseModel.dart';
import 'package:readlock/course_screens/CourseAccentScope.dart';
import 'package:readlock/course_screens/CourseContentViewer.dart';
import 'package:readlock/course_screens/widgets/CCContinueButton.dart';
import 'package:readlock/design_system/RLLunarBlur.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLReadingJustified.dart';
import 'package:readlock/services/feedback/HapticsService.dart';
import 'package:readlock/services/feedback/SoundService.dart';
import 'package:readlock/utility_widgets/text_animation/ProgressiveText.dart';
import 'package:readlock/utility_widgets/visual_effects/BlurOverlay.dart';

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

  bool isContinueVisible = false;

  // Per-card "tap me" affordance — open eye centred on every blurred
  // reflect point. Disappears once the card reveals so the typewriter
  // takes the centre uncluttered. Tinted with the active course's accent
  // colour so the hint reads as part of the course's voice; falls back to
  // the muted secondary tone when no CourseAccentScope is in place.
  Widget RevealEyeIcon() {
    final Color iconColor = CourseAccentScope.of(
      context,
      fallback: RLDS.textSecondary,
    );

    return Icon(
      Pixel.eye,
      color: iconColor,
      size: RLDS.iconXXLarge,
    );
  }

  List<String> getLimitedPoints() {
    return widget.content.thinkingPoints.take(REFLECT_POINTS_LIMIT).toList();
  }

  void handlePointTap(int pointIndex) {
    final bool alreadyRevealed = revealedPoints.contains(pointIndex);

    if (alreadyRevealed) {
      return;
    }

    HapticsService.lightImpact();
    SoundService.playRandomTextClick();

    setState(() {
      revealedPoints.add(pointIndex);
    });

    final bool isLastPoint = revealedPoints.length >= getLimitedPoints().length;

    if (isLastPoint) {
      showContinueButtonDelayed();
    }
  }

  void handleNextSlideTap() {
    final PageController? pageController = findPageController(context);

    final bool hasValidPageController = pageController != null && pageController.hasClients;

    if (!hasValidPageController) {
      return;
    }

    HapticsService.lightImpact();
    navigateToNextPage(pageController);
  }

  PageController? findPageController(BuildContext context) {
    final CourseDetailScreenState? courseDetailScreen =
        context.findAncestorStateOfType<CourseDetailScreenState>();

    return courseDetailScreen?.pageController;
  }

  void navigateToNextPage(PageController pageController) {
    final double? currentPageDouble = pageController.page;
    final bool hasCurrentPage = currentPageDouble != null;

    if (!hasCurrentPage) {
      return;
    }

    final int currentPage = currentPageDouble.round();
    final int nextPage = currentPage + 1;

    pageController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void showContinueButtonDelayed() async {
    final bool canUpdateState = mounted;

    if (!canUpdateState) {
      return;
    }

    await Future.delayed(const Duration(milliseconds: 1400));

    final bool stillMounted = mounted;

    if (!stillMounted) {
      return;
    }

    setState(() {
      isContinueVisible = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Live-rebuild on Justify Text toggle so each thinking point reflows
    // when the setting flips, without leaving the reflect surface.
    return ValueListenableBuilder<bool>(
      valueListenable: justifiedReadingEnabledNotifier,
      builder: (context, isJustified, _) {
        final TextAlign paragraphAlignment = isJustified
            ? TextAlign.justify
            : TextAlign.center;

        return Padding(
          padding: RLDS.contentPaddingInsets,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Points centered in the expanded area. Tapping empty space
              // above or below the cards advances the slide once all points
              // are revealed (card taps win the arena for their own area).
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: isContinueVisible ? handleNextSlideTap : null,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: PointsColumnChildren(paragraphAlignment),
                  ),
                ),
              ),

              // Continue affordance. Delayed 1400ms after the last point
              // is revealed so the reader has a moment of reflection.
              CCContinueButton(visible: isContinueVisible),
            ],
          ),
        );
      },
    );
  }

  List<Widget> PointsColumnChildren(TextAlign paragraphAlignment) {
    final List<String> points = getLimitedPoints();
    final List<Widget> widgets = [];

    for (int pointIndex = 0; pointIndex < points.length; pointIndex++) {
      widgets.add(
        PointEntry(
          pointIndex: pointIndex,
          point: points[pointIndex],
          paragraphAlignment: paragraphAlignment,
        ),
      );

      final bool isLastPoint = pointIndex == points.length - 1;

      if (!isLastPoint) {
        widgets.add(const Spacing.height(RLDS.spacing24));
      }
    }

    return widgets;
  }

  Widget PointEntry({
    required int pointIndex,
    required String point,
    required TextAlign paragraphAlignment,
  }) {
    final bool isRevealed = revealedPoints.contains(pointIndex);

    void onEntryTap() => handlePointTap(pointIndex);

    final Widget pointText = PointText(
      pointIndex: pointIndex,
      point: point,
      isRevealed: isRevealed,
      paragraphAlignment: paragraphAlignment,
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

    // Stack the open-eye affordance ON TOP of the BlurOverlay so the
    // icon stays crisp while the card behind it is blurred. The icon
    // is centred over the card's reserved height (PointText keeps the
    // final text height even while transparent), so its position
    // doesn't shift when the typewriter takes over after reveal.
    final List<Widget> stackChildren = [BlurOverlay(enabled: !isRevealed, child: pointSurface)];

    if (!isRevealed) {
      stackChildren.add(Positioned.fill(child: Center(child: RevealEyeIcon())));
    }

    return GestureDetector(
      onTap: onEntryTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(children: stackChildren),
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
    required bool isRevealed,
    required TextAlign paragraphAlignment,
  }) {
    if (!isRevealed) {
      return RLTypography.readingLarge(
        point,
        color: RLDS.transparent,
        textAlign: paragraphAlignment,
      );
    }

    return ProgressiveText(
      key: ValueKey('reflect_point_$pointIndex'),
      textSegments: [point],
      textStyle: RLTypography.readingLargeStyle.copyWith(color: RLDS.textPrimary),
      textAlign: paragraphAlignment,
      blurCompletedSentences: false,
      enableTapToReveal: false,
    );
  }
}
