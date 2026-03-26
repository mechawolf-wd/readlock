// Skill check introduction widget for course assessment section
// Displays information about the upcoming skill check questions

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/course_screens/CourseContentViewer.dart';

class CCSkillCheck extends StatefulWidget {
  const CCSkillCheck({super.key});

  @override
  State<CCSkillCheck> createState() => CCSkillCheckState();
}

class CCSkillCheckState extends State<CCSkillCheck> with SingleTickerProviderStateMixin {
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
      color: RLDS.backgroundDark,
      padding: RLDS.contentPaddingInsets,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Spinning icon
          SkillCheckIcon(),

          const Spacing.height(16),

          // Title section
          TitleSection(),

          const Spacing.height(24),

          // Description
          DescriptionSection(),

          const Spacing.height(24 * 2),

          // Ready button
          ReadyButton(context),
        ],
      ),
    );
  }

  // Animated skill check icon display
  Widget SkillCheckIcon() {
    final Widget QuizIcon = Icon(Icons.quiz_outlined, color: RLDS.primaryGreen, size: 48);

    return AnimatedBuilder(
      animation: iconAnimationController,
      builder: (context, child) {
        return Transform.rotate(
          angle: iconAnimationController.value * 2.0 * 3.14159,
          child: QuizIcon,
        );
      },
    );
  }

  // Title and subtitle section
  Widget TitleSection() {
    return Column(
      children: [
        RLTypography.headingLarge(RLUIStrings.SKILL_CHECK_TITLE, textAlign: TextAlign.center),

        const Spacing.height(8),

        RLTypography.bodyLarge(
          RLUIStrings.SKILL_CHECK_SUBTITLE,
          color: RLDS.textSecondary,
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
        RLUIStrings.SKILL_CHECK_DESCRIPTION,
        textAlign: TextAlign.center,
        color: RLDS.textPrimary,
      ),
    );
  }

  // Ready button to continue to questions
  Widget ReadyButton(BuildContext context) {
    final BoxDecoration buttonDecoration = BoxDecoration(
      color: RLDS.primaryGreen,
      borderRadius: BorderRadius.circular(12),
    );

    final Widget buttonText = RLTypography.bodyMedium(
      RLUIStrings.SKILL_CHECK_READY_BUTTON_TEXT,
      color: RLDS.white,
    );

    return Div.column(
      [buttonText],
      width: double.infinity,
      height: 48,
      decoration: buttonDecoration,
      mainAxisAlignment: MainAxisAlignment.center,
      onTap: () => navigateToNextContent(context),
    );
  }

  // Navigate to next content (skill check questions)
  void navigateToNextContent(BuildContext context) {
    // Import CourseContentViewer to access state
    final courseDetailScreen = context.findAncestorStateOfType<CourseDetailScreenState>();

    final PageController? pageController = courseDetailScreen?.pageController;

    final bool hasValidPageController = pageController != null && pageController.hasClients;

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
