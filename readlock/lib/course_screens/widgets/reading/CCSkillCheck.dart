// Skill check introduction widget for course assessment section
// Displays configurable title, subtitle, and icon before skill check questions

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/course_screens/CourseContentViewer.dart';

class CCSkillCheck extends StatefulWidget {
  final String title;
  final String subtitle;
  final String iconName;

  const CCSkillCheck({
    super.key,
    this.title = 'Skill Check',
    this.subtitle = 'Test Your Understanding',
    this.iconName = 'check',
  });

  @override
  State<CCSkillCheck> createState() => CCSkillCheckState();
}

class CCSkillCheckState extends State<CCSkillCheck> with SingleTickerProviderStateMixin {
  late AnimationController iconAnimationController;

  @override
  void initState() {
    super.initState();

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

          const Spacing.height(48),

          // Ready button
          ReadyButton(context),
        ],
      ),
    );
  }

  Widget SkillCheckIcon() {
    final IconData iconData = getIconDataFromName(widget.iconName);
    final Widget CheckIcon = Icon(iconData, color: RLDS.primaryGreen, size: 48);

    return AnimatedBuilder(
      animation: iconAnimationController,
      builder: (context, child) {
        return Transform.rotate(
          angle: iconAnimationController.value * 2.0 * 3.14159,
          child: CheckIcon,
        );
      },
    );
  }

  Widget TitleSection() {
    return Column(
      children: [
        RLTypography.headingLarge(widget.title, textAlign: TextAlign.center),

        const Spacing.height(8),

        RLTypography.bodyLarge(
          widget.subtitle,
          color: RLDS.textSecondary,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

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

  void navigateToNextContent(BuildContext context) {
    final courseDetailScreen = context.findAncestorStateOfType<CourseDetailScreenState>();
    final PageController? pageController = courseDetailScreen?.pageController;
    final bool hasValidPageController = pageController != null && pageController.hasClients;

    if (!hasValidPageController) {
      return;
    }

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

  IconData getIconDataFromName(String name) {
    switch (name.toLowerCase()) {
      case 'check': {
        return Icons.check_circle_outline;
      }
      case 'quiz': {
        return Icons.quiz_outlined;
      }
      case 'star': {
        return Icons.star_outline;
      }
      case 'lightning': {
        return Icons.flash_on;
      }
      case 'target': {
        return Icons.track_changes;
      }
      case 'brain': {
        return Icons.psychology;
      }
      case 'trophy': {
        return Icons.emoji_events;
      }
      default: {
        return Icons.check_circle_outline;
      }
    }
  }
}
