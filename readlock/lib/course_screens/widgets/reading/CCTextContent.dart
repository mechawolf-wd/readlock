// Text content widget for course display with progressive text animation
// Shows a continue button at the bottom when all text segments are fully revealed

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/course_screens/models/courseModel.dart';
import 'package:readlock/utility_widgets/text_animation/ProgressiveText.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLTheme.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/course_screens/CourseContentViewer.dart';

// String constants
const String CONTINUE_BUTTON_TEXT = 'Continue';

// Styling constants
const double CONTINUE_BUTTON_HEIGHT = 48.0;
const double CONTINUE_BUTTON_BOTTOM_PADDING = 32.0;
const double BUTTON_BORDER_RADIUS = 12.0;
const Duration PAGE_TRANSITION_DURATION = Duration(milliseconds: 300);
const Duration CONTINUE_BUTTON_DELAY = Duration(seconds: 1);

class CCTextContent extends StatefulWidget {
  // Text content data to display
  final TextContent content;

  const CCTextContent({super.key, required this.content});

  @override
  State<CCTextContent> createState() => CCTextContentState();
}

class CCTextContentState extends State<CCTextContent> {
  // Track whether all text segments have been revealed
  bool isAllTextRevealed = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: RLTheme.backgroundDark,
      padding: RLTheme.contentPaddingInsets,
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

  // Main text display with progressive reveal animation
  Widget ProgressiveTextSection() {
    return SingleChildScrollView(
      child: ProgressiveText(
        textSegments: widget.content.textSegments,
        textStyle: RLTypography.bodyMediumStyle,
        textAlignment: CrossAxisAlignment.start,
        onAllSegmentsRevealed: handleAllSegmentsRevealed,
      ),
    );
  }

  // Container for continue button with visibility control
  Widget ContinueButtonContainer() {
    final bool shouldShowContinueButton = isAllTextRevealed;

    if (!shouldShowContinueButton) {
      return const SizedBox.shrink();
    }

    return ContinueButtonSection();
  }

  // Continue button section with spacing
  Widget ContinueButtonSection() {
    return ContinueButton();
  }

  // Button widget for continuing to next content
  Widget ContinueButton() {
    // Button text style
    final Widget buttonText = RLTypography.bodyMedium(
      CONTINUE_BUTTON_TEXT,
      color: Colors.white,
    );

    return RLDesignSystem.BlockButton(
      children: [buttonText],
      onTap: handleContinueButtonTap,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      margin: EdgeInsets.zero,
    );
  }

  // Handle when all text segments are revealed
  // Adds delay before showing continue button for reading time
  void handleAllSegmentsRevealed() async {
    final bool canUpdateState = mounted;

    if (!canUpdateState) {
      return;
    }

    // Wait for user to read the last segment
    await Future.delayed(CONTINUE_BUTTON_DELAY);

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

    final bool hasValidPageController =
        pageController != null && pageController.hasClients;

    if (!hasValidPageController) {
      return;
    }

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
      duration: PAGE_TRANSITION_DURATION,
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
