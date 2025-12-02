// Gamified reward screen displaying XP gains, streak multiplier, and loot rewards
// Shows lesson completion achievements with sequential reveal animations and counting effects

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLTheme.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/utility_widgets/Utility.dart';

// Reward data model
class LessonReward {
  final int experiencePointsGained;
  final double streakplierMultiplier;
  final Duration lessonDuration;
  final int keysLooted;

  const LessonReward({
    required this.experiencePointsGained,
    required this.streakplierMultiplier,
    required this.lessonDuration,
    required this.keysLooted,
  });
}

// String constants
const String CONGRATULATIONS_MESSAGE = 'Congratulations!';
const String LESSON_COMPLETE_MESSAGE = 'Lesson Complete';
const String EXPERIENCE_POINTS_LABEL = 'Experience Points';
const String STREAKPLIER_LABEL = 'Streakplier';
const String LESSON_TIME_LABEL = 'Lesson Time';
const String KEYS_LOOTED_LABEL = 'Keys Looted';
const String CONTINUE_BUTTON_TEXT = 'Continue';

// Styling constants
const double REWARD_CARD_PADDING = 24.0;
const double REWARD_ITEM_SPACING = 20.0;
const double ICON_SIZE = 32.0;
const double CELEBRATION_ICON_SIZE = 48.0;
const double BORDER_RADIUS = 16.0;

// Animation constants
const Duration ITEM_REVEAL_DELAY = Duration(milliseconds: 600);
const Duration COUNTING_ANIMATION_DURATION = Duration(
  milliseconds: 800,
);
const Duration INITIAL_DELAY = Duration(milliseconds: 500);

class StreakplierRewardScreen extends StatefulWidget {
  // Lesson completion reward data
  final LessonReward reward;

  // Navigation callback when user continues
  final VoidCallback onContinue;

  const StreakplierRewardScreen({
    super.key,
    required this.reward,
    required this.onContinue,
  });

  @override
  State<StreakplierRewardScreen> createState() =>
      StreakplierRewardScreenState();
}

class StreakplierRewardScreenState
    extends State<StreakplierRewardScreen>
    with TickerProviderStateMixin {
  // Animation controllers for counting effects only
  late AnimationController experiencePointsController;
  late AnimationController streakplierController;
  late AnimationController keysController;

  // Animations for counting effects
  late Animation<int> experiencePointsCountAnimation;
  late Animation<double> streakplierCountAnimation;
  late Animation<int> keysCountAnimation;

  // Track which items are revealed with simple opacity
  double experiencePointsOpacity = 0.0;
  double streakplierOpacity = 0.0;
  double lessonTimeOpacity = 0.0;
  double keysOpacity = 0.0;
  double continueButtonOpacity = 0.0;

  @override
  void initState() {
    super.initState();
    initializeCountingControllers();
    initializeCountingAnimations();
    startRevealSequence();
  }

  @override
  void dispose() {
    experiencePointsController.dispose();
    streakplierController.dispose();
    keysController.dispose();
    super.dispose();
  }

  // Initialize counting animation controllers only
  void initializeCountingControllers() {
    experiencePointsController = AnimationController(
      duration: COUNTING_ANIMATION_DURATION,
      vsync: this,
    );
    streakplierController = AnimationController(
      duration: COUNTING_ANIMATION_DURATION,
      vsync: this,
    );
    keysController = AnimationController(
      duration: COUNTING_ANIMATION_DURATION,
      vsync: this,
    );
  }

  // Initialize counting animations for numeric values
  void initializeCountingAnimations() {
    experiencePointsCountAnimation =
        IntTween(
          begin: 0,
          end: widget.reward.experiencePointsGained,
        ).animate(
          CurvedAnimation(
            parent: experiencePointsController,
            curve: Curves.easeOut,
          ),
        );

    streakplierCountAnimation =
        Tween<double>(
          begin: 1.0,
          end: widget.reward.streakplierMultiplier,
        ).animate(
          CurvedAnimation(
            parent: streakplierController,
            curve: Curves.easeOut,
          ),
        );

    keysCountAnimation =
        IntTween(begin: 0, end: widget.reward.keysLooted).animate(
          CurvedAnimation(
            parent: keysController,
            curve: Curves.easeOut,
          ),
        );
  }

  // Start the sequential reveal with simple opacity changes
  void startRevealSequence() {
    // Experience points reveal
    Future.delayed(INITIAL_DELAY, () {
      if (mounted) {
        setState(() => experiencePointsOpacity = 1.0);
        experiencePointsController.forward();
      }
    });

    // Streakplier reveal
    Future.delayed(INITIAL_DELAY + ITEM_REVEAL_DELAY, () {
      if (mounted) {
        setState(() => streakplierOpacity = 1.0);
        streakplierController.forward();
      }
    });

    // Lesson time reveal
    Future.delayed(INITIAL_DELAY + ITEM_REVEAL_DELAY * 2, () {
      if (mounted) {
        setState(() => lessonTimeOpacity = 1.0);
      }
    });

    // Keys reveal
    Future.delayed(INITIAL_DELAY + ITEM_REVEAL_DELAY * 3, () {
      if (mounted) {
        setState(() => keysOpacity = 1.0);
        keysController.forward();
      }
    });

    // Continue button reveal
    Future.delayed(INITIAL_DELAY + ITEM_REVEAL_DELAY * 4, () {
      if (mounted) {
        setState(() => continueButtonOpacity = 1.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RLTheme.backgroundDark,
      body: SafeArea(
        child: Div.column(
          [
            // Celebration header
            CelebrationHeader(),

            const Spacing.height(32),

            // Reward statistics
            RewardStatistics(),

            const Spacing.height(40),

            // Continue button
            ContinueButton(),
          ],
          padding: const EdgeInsets.all(24),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
    );
  }

  // Celebration header with icon and congratulations message
  Widget CelebrationHeader() {
    return Div.column([
      // Celebration icon
      CelebrationIcon(),

      const Spacing.height(16),

      // Congratulations text
      RLTypography.headingLarge(
        CONGRATULATIONS_MESSAGE,
        color: RLTheme.primaryGreen,
        textAlign: TextAlign.center,
      ),

      const Spacing.height(8),

      // Lesson complete subtitle
      RLTypography.bodyLarge(
        LESSON_COMPLETE_MESSAGE,
        color: RLTheme.textSecondary,
        textAlign: TextAlign.center,
      ),
    ], crossAxisAlignment: CrossAxisAlignment.center);
  }

  // Large celebration check mark icon
  Widget CelebrationIcon() {
    final BoxDecoration iconDecoration = BoxDecoration(
      color: RLTheme.primaryGreen.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(32),
    );

    return Container(
      width: 64,
      height: 64,
      decoration: iconDecoration,
      child: const Icon(
        Icons.check_circle,
        color: RLTheme.primaryGreen,
        size: CELEBRATION_ICON_SIZE,
      ),
    );
  }

  // Statistics display for all reward components with sequential animations
  Widget RewardStatistics() {
    final String formattedLessonTime = FormatLessonDuration();

    return Container(
      padding: const EdgeInsets.all(REWARD_CARD_PADDING),
      decoration: RewardCardDecoration(),
      child: Div.column([
        // Experience points gained with animation
        AnimatedOpacity(
          opacity: experiencePointsOpacity,
          duration: const Duration(milliseconds: 300),
          child: RewardStatisticItem(
            icon: Icons.auto_awesome,
            label: EXPERIENCE_POINTS_LABEL,
            animatedValue: AnimatedBuilder(
              animation: experiencePointsCountAnimation,
              builder: (context, child) {
                return RLTypography.headingMedium(
                  '+${experiencePointsCountAnimation.value} XP',
                  color: RLTheme.primaryBlue,
                  textAlign: TextAlign.left,
                );
              },
            ),
            color: RLTheme.primaryBlue,
          ),
        ),

        const Spacing.height(REWARD_ITEM_SPACING),

        // Streak multiplier increase with animation
        AnimatedOpacity(
          opacity: streakplierOpacity,
          duration: const Duration(milliseconds: 300),
          child: RewardStatisticItem(
            icon: Icons.trending_up,
            label: STREAKPLIER_LABEL,
            animatedValue: AnimatedBuilder(
              animation: streakplierCountAnimation,
              builder: (context, child) {
                return RLTypography.headingMedium(
                  '${streakplierCountAnimation.value.toStringAsFixed(2)}x',
                  color: RLTheme.primaryGreen,
                  textAlign: TextAlign.left,
                );
              },
            ),
            color: RLTheme.primaryGreen,
          ),
        ),

        const Spacing.height(REWARD_ITEM_SPACING),

        // Lesson completion time (no counting animation needed)
        AnimatedOpacity(
          opacity: lessonTimeOpacity,
          duration: const Duration(milliseconds: 300),
          child: RewardStatisticItem(
            icon: Icons.timer,
            label: LESSON_TIME_LABEL,
            animatedValue: RLTypography.headingMedium(
              formattedLessonTime,
              color: Colors.orange,
              textAlign: TextAlign.left,
            ),
            color: Colors.orange,
          ),
        ),

        const Spacing.height(REWARD_ITEM_SPACING),

        // Keys collected with animation
        AnimatedOpacity(
          opacity: keysOpacity,
          duration: const Duration(milliseconds: 300),
          child: RewardStatisticItem(
            icon: Icons.vpn_key,
            label: KEYS_LOOTED_LABEL,
            animatedValue: AnimatedBuilder(
              animation: keysCountAnimation,
              builder: (context, child) {
                return RLTypography.headingMedium(
                  '${keysCountAnimation.value} keys',
                  color: Colors.amber,
                  textAlign: TextAlign.left,
                );
              },
            ),
            color: Colors.amber,
          ),
        ),
      ], crossAxisAlignment: CrossAxisAlignment.stretch),
    );
  }

  // Simple reward statistic display item with animated counting
  Widget RewardStatisticItem({
    required IconData icon,
    required String label,
    required Widget animatedValue,
    required Color color,
  }) {
    final BoxDecoration iconContainerDecoration = BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
    );

    return Div.row([
      // Icon container
      Container(
        width: 48,
        height: 48,
        decoration: iconContainerDecoration,
        child: Icon(icon, color: color, size: ICON_SIZE),
      ),

      const Spacing.width(16),

      // Label and animated value column
      Expanded(
        child: Div.column([
          RLTypography.bodyLarge(
            label,
            color: RLTheme.textPrimary,
            textAlign: TextAlign.left,
          ),

          const Spacing.height(4),

          animatedValue,
        ], crossAxisAlignment: CrossAxisAlignment.start),
      ),
    ], crossAxisAlignment: CrossAxisAlignment.center);
  }

  // Continue button with simple opacity animation
  Widget ContinueButton() {
    return AnimatedOpacity(
      opacity: continueButtonOpacity,
      duration: const Duration(milliseconds: 300),
      child: RLDesignSystem.BlockButton(
        children: [
          RLTypography.bodyLarge(
            CONTINUE_BUTTON_TEXT,
            color: Colors.white,
          ),
        ],
        onTap: widget.onContinue,
        backgroundColor: RLTheme.primaryGreen,
        margin: EdgeInsets.zero,
      ),
    );
  }

  // Reward card styling decoration
  BoxDecoration RewardCardDecoration() {
    return BoxDecoration(
      color: RLTheme.backgroundLight,
      borderRadius: BorderRadius.circular(BORDER_RADIUS),
      border: Border.all(
        color: RLTheme.textPrimary.withValues(alpha: 0.1),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // Format lesson duration into readable short format
  String FormatLessonDuration() {
    final int totalMinutes = widget.reward.lessonDuration.inMinutes;
    final int remainingSeconds =
        widget.reward.lessonDuration.inSeconds % 60;

    final bool hasMinutes = totalMinutes > 0;
    final bool hasSeconds = remainingSeconds > 0;

    if (hasMinutes && hasSeconds) {
      return '${totalMinutes}m ${remainingSeconds}s';
    } else if (hasMinutes) {
      return '${totalMinutes}m';
    } else {
      return '${remainingSeconds}s';
    }
  }
}
