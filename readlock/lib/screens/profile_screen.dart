// Profile screen with Lottie animation showcase
// Demonstrates integration of Lottie animations for enhanced user experience

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:relevant/constants/typography.dart' as app_typography;
import 'package:relevant/utility_widgets/utility_widgets.dart';

const IconData PROFILE_IMAGE_PLACEHOLDER_ICON = Icons.person;
const String USER_NAME_TEXT = 'John Doe';
const String USER_EMAIL_TEXT = 'john.doe@example.com';
const String USER_BIO_TEXT = 'Design enthusiast | UX/UI Explorer';
const String PROFILE_STATS_COURSES_LABEL = 'Courses';
const String PROFILE_STATS_COMPLETED_LABEL = 'Completed';
const String PROFILE_STATS_HOURS_LABEL = 'Hours';
const String PROFILE_STATS_COURSES_VALUE = '12';
const String PROFILE_STATS_COMPLETED_VALUE = '8';
const String PROFILE_STATS_HOURS_VALUE = '156';
const String ACHIEVEMENTS_SECTION_TITLE = 'Recent Achievements';
const String SETTINGS_BUTTON_TEXT = 'Settings';
const String LOGOUT_BUTTON_TEXT = 'Logout';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: ProfileAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Div.column([
            ProfileHeaderSection(),
            Spacing.height(24),
            ProfileStatsSection(),
            Spacing.height(24),
            LottieAnimationShowcase(),
            Spacing.height(24),
            AchievementsSection(),
            Spacing.height(24),
            ProfileActionsSection(),
            Spacing.height(32),
          ], padding: 16),
        ),
      ),
    );
  }

  PreferredSizeWidget ProfileAppBar() {
    return AppBar(
      backgroundColor: Colors.grey[850],
      elevation: 0,
      title: app_typography.Typography.headingMedium(
        'Profile',
        textAlign: TextAlign.center,
      ),
      centerTitle: true,
    );
  }
}

class ProfileHeaderSection extends StatelessWidget {
  const ProfileHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Div.column([
      ProfileAvatar(),
      Spacing.height(16),
      app_typography.Typography.headingLarge(
        USER_NAME_TEXT,
        textAlign: TextAlign.center,
      ),
      Spacing.height(8),
      app_typography.Typography.bodyMedium(
        USER_EMAIL_TEXT,
        textAlign: TextAlign.center,
      ),
      Spacing.height(8),
      app_typography.Typography.bodyLarge(
        USER_BIO_TEXT,
        textAlign: TextAlign.center,
      ),
    ], crossAxisAlignment: 'center');
  }

  Widget ProfileAvatar() {
    return Div.emptyColumn(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue.withValues(alpha: 0.2),
        border: Border.all(color: Colors.blue, width: 3),
      ),
      mainAxisAlignment: 'center',
      crossAxisAlignment: 'center',
    );
  }
}

class ProfileStatsSection extends StatelessWidget {
  const ProfileStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Div.row([
      StatItem(
        label: PROFILE_STATS_COURSES_LABEL,
        value: PROFILE_STATS_COURSES_VALUE,
      ),
      StatItem(
        label: PROFILE_STATS_COMPLETED_LABEL,
        value: PROFILE_STATS_COMPLETED_VALUE,
      ),
      StatItem(
        label: PROFILE_STATS_HOURS_LABEL,
        value: PROFILE_STATS_HOURS_VALUE,
      ),
    ], mainAxisAlignment: 'spaceEvenly');
  }

  Widget StatItem({required String label, required String value}) {
    return Div.column([
      app_typography.Typography.headingLarge(
        value,
        textAlign: TextAlign.center,
      ),

      const Spacing.height(4),

      app_typography.Typography.bodyMedium(
        label,
        textAlign: TextAlign.center,
      ),
    ], crossAxisAlignment: 'center');
  }
}

class LottieAnimationShowcase extends StatelessWidget {
  const LottieAnimationShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return Div.column(
      [
        app_typography.Typography.headingMedium(
          'Learning Journey',
          textAlign: TextAlign.center,
        ),

        Spacing.height(16),

        LottieAnimationWidget(),
      ],
      padding: 16,
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[700]!, width: 1),
      ),
    );
  }

  Widget LottieAnimationWidget() {
    return SizedBox(
      height: 200,
      child: Lottie.asset(
        'assets/logo_animation.lottie',
        fit: BoxFit.contain,
        animate: true,
        repeat: true,
      ),
    );
  }
}

class AchievementsSection extends StatelessWidget {
  const AchievementsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Div.column([
      app_typography.Typography.headingMedium(
        ACHIEVEMENTS_SECTION_TITLE,
        textAlign: TextAlign.left,
      ),
      Spacing.height(16),
      AchievementItem(
        title: 'Design Fundamentals',
        description: 'Completed all modules',
        icon: Icons.school,
      ),
      Spacing.height(12),
      AchievementItem(
        title: 'Quick Learner',
        description: 'Finished course in 7 days',
        icon: Icons.timer,
      ),
      Spacing.height(12),
      AchievementItem(
        title: 'Perfect Score',
        description: 'Answered all questions correctly',
        icon: Icons.star,
      ),
    ], crossAxisAlignment: 'stretch');
  }

  Widget AchievementItem({
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Div.row(
      [
        Icon(icon, color: Colors.amber, size: 32),
        Spacing.width(16),
        Expanded(
          child: Div.column([
            app_typography.Typography.bodyLarge(title),
            app_typography.Typography.bodyMedium(description),
          ], crossAxisAlignment: 'start'),
        ),
      ],
      padding: 12,
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

class ProfileActionsSection extends StatelessWidget {
  const ProfileActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Div.column([
      ActionButton(
        text: SETTINGS_BUTTON_TEXT,
        icon: Icons.settings,
        onPressed: () {},
      ),
      Spacing.height(12),
      ActionButton(
        text: LOGOUT_BUTTON_TEXT,
        icon: Icons.logout,
        onPressed: () {},
        isPrimary: false,
      ),
    ], crossAxisAlignment: 'stretch');
  }

  Widget ActionButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    bool isPrimary = true,
  }) {
    final Color backgroundColor = isPrimary
        ? Colors.blue
        : Colors.red.withValues(alpha: 0.2);
    final Color textColor = isPrimary ? Colors.white : Colors.red;

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: textColor),
      label: app_typography.Typography.bodyLarge(
        text,
        textAlign: TextAlign.center,
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 24,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
