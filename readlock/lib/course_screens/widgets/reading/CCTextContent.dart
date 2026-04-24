// Text content widget for course display with progressive text animation
// Shows a continue button at the bottom when all text segments are fully revealed

import 'package:flutter/material.dart' hide Typography;
import 'package:flutter/services.dart';
import 'package:readlock/models/CourseModel.dart';
import 'package:readlock/utility_widgets/text_animation/ProgressiveText.dart';
import 'package:readlock/design_system/RLLunarBlur.dart';
import 'package:readlock/design_system/RLReveal.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/course_screens/CourseContentViewer.dart';

// LunarBlur button geometry — matches RLButton's default padding so the
// continue pill reads the same size as the primary buttons elsewhere.
const EdgeInsets CONTINUE_BUTTON_PADDING = EdgeInsets.symmetric(
  vertical: RLDS.spacing16,
  horizontal: RLDS.spacing24,
);

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

  // Main text display with progressive reveal animation
  Widget ProgressiveTextSection() {
    return ProgressiveText(
      textSegments: widget.content.textSegments,
      textStyle: RLTypography.readingMediumStyle,
      textAlignment: CrossAxisAlignment.start,
      onAllSegmentsRevealed: handleAllSegmentsRevealed,
    );
  }

  // Container for continue button with visibility control. Routes through
  // RLReveal so the opacity timing matches every other reveal in the app
  // (true/false buttons, password field, etc.).
  Widget ContinueButtonContainer() {
    final bool shouldShowContinueButton = isAllTextRevealed;

    return RLReveal(
      visible: shouldShowContinueButton,
      child: ContinueButton(),
    );
  }

  // Button widget for continuing to next content — LunarBlur pill so the CTA
  // reads as frosted glass over the swipe content instead of a solid fill.
  Widget ContinueButton() {
    final Color accentColor = resolveCourseAccentColor();

    return GestureDetector(
      onTap: handleContinueButtonTap,
      child: SizedBox(
        width: double.infinity,
        child: RLLunarBlur(
          borderRadius: RLDS.borderRadiusSmall,
          padding: CONTINUE_BUTTON_PADDING,
          child: Center(
            child: RLTypography.bodyLarge(
              RLUIStrings.TEXT_CONTENT_CONTINUE_LABEL,
              color: accentColor,
            ),
          ),
        ),
      ),
    );
  }

  Color resolveCourseAccentColor() {
    final CourseDetailScreenState? courseDetailScreen = context
        .findAncestorStateOfType<CourseDetailScreenState>();

    final bool hasAncestor = courseDetailScreen != null;

    if (!hasAncestor) {
      return RLDS.green;
    }

    return courseDetailScreen.getCourseAccentColor();
  }

  // Handle when all text segments are revealed
  // Adds delay before showing continue button for reading time
  void handleAllSegmentsRevealed() async {
    final bool canUpdateState = mounted;

    if (!canUpdateState) {
      return;
    }

    // Wait for user to read the last segment
    await Future.delayed(const Duration(milliseconds: 700));

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

    HapticFeedback.lightImpact();
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
