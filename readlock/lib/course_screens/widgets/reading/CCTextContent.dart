// Text content widget for course display with progressive text animation
// Shows a continue button at the bottom when all text segments are fully revealed

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/services/feedback/HapticsService.dart';
import 'package:readlock/models/CourseModel.dart';
import 'package:readlock/utility_widgets/text_animation/ProgressiveText.dart';
import 'package:readlock/utility_widgets/text_animation/RSVPText.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLReadingJustified.dart';
import 'package:readlock/course_screens/CourseContentViewer.dart';
import 'package:readlock/course_screens/widgets/CCContinueButton.dart';

class CCTextContent extends StatefulWidget {
  // Text content data to display
  final TextSwipe content;

  const CCTextContent({super.key, required this.content});

  @override
  State<CCTextContent> createState() => CCTextContentState();
}

class CCTextContentState extends State<CCTextContent> {
  // Track whether all text segments have been revealed
  bool isAllTextRevealed = false;

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
          // Progressive text content (expands to fill available space)
          Expanded(child: ProgressiveTextSection()),

          // Continue button at bottom (shows when text fully revealed)
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
          textSegments: widget.content.textSegments,
          textStyle: RLTypography.readingMediumStyle,
          textAlignment: CrossAxisAlignment.start,
          textAlign: paragraphAlignment,
          onAllSegmentsRevealed: handleAllSegmentsRevealed,
          // Once every segment has landed, the empty area below the last
          // line becomes a synonym for the continue button: tapping it
          // advances to the next slide instead of toggling blur.
          onTapAfterAllRevealed: handleContinueButtonTap,
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

  // Continue CTA. The shared CCContinueButton owns the geometry, accent
  // resolution, and page-controller hop, so this swipe just hands it the
  // "is everyone done reading?" flag.
  Widget ContinueButtonContainer() {
    final bool shouldShowContinueButton = isAllTextRevealed;

    return CCContinueButton(visible: shouldShowContinueButton);
  }

  // Handle when all text segments are revealed
  // Adds delay before showing continue button for reading time
  void handleAllSegmentsRevealed() async {
    final bool canUpdateState = mounted;

    if (!canUpdateState) {
      return;
    }

    // Wait for user to read the last segment
    await Future.delayed(const Duration(milliseconds: 1400));

    // Check mounted again after delay
    final bool stillMounted = mounted;

    if (!stillMounted) {
      return;
    }

    setState(() {
      isAllTextRevealed = true;
    });
  }

  // Handle continue button tap - scroll to next content
  void handleContinueButtonTap() {
    // Find the PageController from CourseContentViewer
    final PageController? pageController = findPageController(context);

    final bool hasValidPageController = pageController != null && pageController.hasClients;

    if (!hasValidPageController) {
      return;
    }

    HapticsService.lightImpact();
    navigateToNextPage(pageController);
  }

  // Navigate to the next content page
  void navigateToNextPage(PageController pageController) {
    // Get current page index
    final double? currentPageDouble = pageController.page;
    final bool hasCurrentPage = currentPageDouble != null;

    if (!hasCurrentPage) {
      return;
    }

    final int currentPage = currentPageDouble.round();
    final int nextPage = currentPage + 1;

    // Animate to next page
    pageController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // Find the PageController from parent CourseContentViewer
  PageController? findPageController(BuildContext context) {
    // Look up the widget tree to find CourseDetailScreen
    final CourseDetailScreenState? courseDetailScreen = context
        .findAncestorStateOfType<CourseDetailScreenState>();

    return courseDetailScreen?.pageController;
  }
}
