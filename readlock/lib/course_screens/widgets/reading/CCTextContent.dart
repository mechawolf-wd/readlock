// Reading swipe for prose content. Progressively types out all text segments
// and pins a continue affordance at the bottom once every segment is revealed.

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/services/feedback/HapticsService.dart';
import 'package:readlock/models/CourseModel.dart';
import 'package:readlock/utility_widgets/text_animation/ProgressiveText.dart';
import 'package:readlock/utility_widgets/text_animation/RSVPText.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLReadingJustified.dart';
import 'package:readlock/course_screens/widgets/CCContinueButton.dart';
import 'package:readlock/course_screens/CourseContentViewer.dart';

class CCTextContent extends StatefulWidget {
  final TextSwipe content;

  const CCTextContent({super.key, required this.content});

  @override
  State<CCTextContent> createState() => CCTextContentState();
}

class CCTextContentState extends State<CCTextContent> {
  // True once the last segment finishes its typewriter animation.
  bool isLastSegmentRevealed = false;

  // True after the 1400ms pause that lets the reader absorb the last line
  // before the button fades in. Controls button visibility only.
  bool isAllTextRevealed = false;

  final GlobalKey<ProgressiveTextState> progressiveTextKey = GlobalKey<ProgressiveTextState>();

  @override
  void initState() {
    super.initState();
    // First-view haptic: the swipe lands and the typewriter starts laying
    // down the first segment in the same frame, so a single light impact
    // here reads as part of the reveal landing.
    HapticsService.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: RLDS.contentPaddingInsets,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: ProgressiveTextSection()),

          ContinueButtonContainer(),
        ],
      ),
    );
  }

  // Main text display — picks between typewriter reveal (default) and the
  // RSVP word-flash reader based on the global rsvpEnabledNotifier. The
  // ValueListenableBuilder means flipping the switch in Settings swaps
  // the reading surface live without leaving the swipe.
  Widget ProgressiveTextSection() {
    return ValueListenableBuilder<bool>(
      valueListenable: rsvpEnabledNotifier,
      builder: (context, isRsvpEnabled, _) {
        if (isRsvpEnabled) {
          return RSVPReadingSurface();
        }

        return ProgressiveReadingSurface();
      },
    );
  }

  Widget ProgressiveReadingSurface() {
    // Live-rebuilds when the user flips the Justified text toggle in
    // Settings, so the open swipe re-justifies (or un-justifies) without
    // leaving the reading surface.
    return ValueListenableBuilder<bool>(
      valueListenable: justifiedReadingEnabledNotifier,
      builder: (context, isJustified, _) {
        final TextAlign paragraphAlignment = isJustified ? TextAlign.justify : TextAlign.left;

        return ProgressiveText(
          key: progressiveTextKey,
          textSegments: widget.content.textSegments,
          textStyle: RLTypography.readingMediumStyle,
          textAlignment: CrossAxisAlignment.start,
          textAlign: paragraphAlignment,
          onAllSegmentsRevealed: handleAllSegmentsRevealed,
        );
      },
    );
  }

  Widget RSVPReadingSurface() {
    return RSVPText(
      textSegments: widget.content.textSegments,
      textStyle: RLTypography.readingMediumStyle,
      onAllSegmentsRevealed: handleAllSegmentsRevealed,
    );
  }

  // Continue CTA. Invisible until all segments finish, but the tap area is
  // always active: tapping before reveal triggers the next segment via the
  // ProgressiveText key; after reveal, advances to the next page.
  Widget ContinueButtonContainer() {
    final bool shouldShowContinueButton = isAllTextRevealed;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: handleContinueTap,
      child: CCContinueButton(visible: shouldShowContinueButton),
    );
  }

  void handleContinueTap() {
    if (isAllTextRevealed) {
      advanceToNextPage();
      return;
    }

    progressiveTextKey.currentState?.handleTap();
  }

  void advanceToNextPage() {
    final CourseDetailScreenState? courseDetailScreen =
        context.findAncestorStateOfType<CourseDetailScreenState>();

    final bool hasNoAncestor = courseDetailScreen == null;

    if (hasNoAncestor) {
      return;
    }

    final PageController pageController = courseDetailScreen.pageController;
    final bool hasNoClients = !pageController.hasClients;

    if (hasNoClients) {
      return;
    }

    final double? currentPageDouble = pageController.page;
    final bool hasNoCurrentPage = currentPageDouble == null;

    if (hasNoCurrentPage) {
      return;
    }

    final int nextPage = currentPageDouble.round() + 1;

    pageController.animateToPage(
      nextPage,
      duration: CC_CONTINUE_PAGE_TRANSITION_DURATION,
      curve: CC_CONTINUE_PAGE_TRANSITION_CURVE,
    );
  }

  void handleAllSegmentsRevealed() async {
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
      isAllTextRevealed = true;
    });
  }

}
