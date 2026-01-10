// Skill check introduction widget for course assessment section
// Displays information about the upcoming skill check questions

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLTheme.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/course_screens/CourseContentViewer.dart';

// String constants
const String SKILL_CHECK_TITLE = 'Skill Check';
const String SKILL_CHECK_SUBTITLE = 'Test Your Understanding';
const String SKILL_CHECK_DESCRIPTION =
    'You\'ve completed the lesson! Now let\'s check your understanding with a few questions.';
const String READY_BUTTON_TEXT = 'I\'m Ready';

// Styling constants
const double ICON_SIZE = 48.0;
const double TITLE_SPACING = 16.0;
const double CONTENT_SPACING = 24.0;
const double BUTTON_HEIGHT = 48.0;
const double BUTTON_BORDER_RADIUS = 12.0;

class CCSkillCheck extends StatefulWidget {
  const CCSkillCheck({super.key});

  @override
  State<CCSkillCheck> createState() => CCSkillCheckState();
}

class CCSkillCheckState extends State<CCSkillCheck>
    with SingleTickerProviderStateMixin {
  // Animation controller for spinning icon
  late AnimationController iconAnimationController;

  @override
  void initState() {
    super.initState();

    // Initialize spinning animation for skill check icon
    iconAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    iconAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: RLTheme.backgroundDark,
      padding: RLTheme.contentPaddingInsets,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Spinning icon
          SkillCheckIcon(),

          const Spacing.height(TITLE_SPACING),

          // Title section
          TitleSection(),

          const Spacing.height(CONTENT_SPACING),

          // Description
          DescriptionSection(),

          const Spacing.height(CONTENT_SPACING * 2),

          // Ready button
          ReadyButton(context),
        ],
      ),
    );
  }

  // Animated skill check icon display
  Widget SkillCheckIcon() {
    return AnimatedBuilder(
      animation: iconAnimationController,
      builder: (context, child) {
        return Transform.rotate(
          angle: iconAnimationController.value * 2.0 * 3.14159,
          child: const Icon(
            Icons.quiz_outlined,
            color: RLTheme.primaryGreen,
            size: ICON_SIZE,
          ),
        );
      },
    );
  }

  // Title and subtitle section
  Widget TitleSection() {
    return Column(
      children: [
        RLTypography.headingLarge(
          SKILL_CHECK_TITLE,
          textAlign: TextAlign.center,
        ),

        const Spacing.height(8.0),

        RLTypography.bodyLarge(
          SKILL_CHECK_SUBTITLE,
          color: RLTheme.textSecondary,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Description text section
  Widget DescriptionSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: RLTypography.bodyMedium(
        SKILL_CHECK_DESCRIPTION,
        textAlign: TextAlign.center,
        color: RLTheme.textPrimary,
      ),
    );
  }

  // Ready button to continue to questions
  Widget ReadyButton(BuildContext context) {
    // Button decoration
    final BoxDecoration buttonDecoration = BoxDecoration(
      color: RLTheme.primaryGreen,
      borderRadius: BorderRadius.circular(BUTTON_BORDER_RADIUS),
    );

    // Button text
    final Widget buttonText = RLTypography.bodyMedium(
      READY_BUTTON_TEXT,
      color: Colors.white,
    );

    return Div.column(
      [buttonText],
      width: double.infinity,
      height: BUTTON_HEIGHT,
      decoration: buttonDecoration,
      mainAxisAlignment: MainAxisAlignment.center,
      onTap: () => navigateToNextContent(context),
    );
  }

  // Navigate to next content (skill check questions)
  void navigateToNextContent(BuildContext context) {
    // Import CourseContentViewer to access state
    final courseDetailScreen = context
        .findAncestorStateOfType<CourseDetailScreenState>();

    final PageController? pageController =
        courseDetailScreen?.pageController;

    final bool hasValidPageController =
        pageController != null && pageController.hasClients;

    if (!hasValidPageController) {
      return;
    }

    // Navigate to next page
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
}
