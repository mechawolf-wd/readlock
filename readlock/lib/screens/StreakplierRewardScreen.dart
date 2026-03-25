// Gamified reward screen displaying XP gains, streak multiplier, and loot rewards
// Shows lesson completion achievements with sequential reveal animations and counting effects

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLTheme.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLConstants.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/services/SoundService.dart';

// Reward data model
class LessonReward {
  final int experiencePointsGained;
  final double streakplierMultiplier;
  final Duration lessonDuration;

  const LessonReward({
    required this.experiencePointsGained,
    required this.streakplierMultiplier,
    required this.lessonDuration,
  });
}

class StreakplierRewardScreen extends StatefulWidget {
  // Lesson completion reward data
  final LessonReward reward;

  // Navigation callback when user continues
  final VoidCallback onContinue;

  const StreakplierRewardScreen({super.key, required this.reward, required this.onContinue});

  @override
  State<StreakplierRewardScreen> createState() => StreakplierRewardScreenState();
}

class StreakplierRewardScreenState extends State<StreakplierRewardScreen>
    with TickerProviderStateMixin {
  // Animation controllers for counting effects only
  late AnimationController experiencePointsController;
  late AnimationController streakplierController;

  // Animations for counting effects
  late Animation<int> experiencePointsCountAnimation;
  late Animation<double> streakplierCountAnimation;

  // Track which items are revealed with simple opacity
  double experiencePointsOpacity = 0.0;
  double streakplierOpacity = 0.0;
  double lessonTimeOpacity = 0.0;
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
  }

  // Initialize counting animations for numeric values
  void initializeCountingAnimations() {
    experiencePointsCountAnimation = IntTween(
      begin: 0,
      end: widget.reward.experiencePointsGained,
    ).animate(CurvedAnimation(parent: experiencePointsController, curve: Curves.easeOut));

    streakplierCountAnimation = Tween<double>(
      begin: 1.0,
      end: widget.reward.streakplierMultiplier,
    ).animate(CurvedAnimation(parent: streakplierController, curve: Curves.easeOut));
  }

  // Start the sequential reveal with simple opacity changes and audio
  void startRevealSequence() {
    // Lesson time reveal (now first with emphasis)
    Future.delayed(REWARD_INITIAL_DELAY, () {
      if (mounted) {
        setState(() => lessonTimeOpacity = 1.0);
      }
    });

    // Streakplier reveal (now second)
    Future.delayed(REWARD_INITIAL_DELAY + ITEM_REVEAL_DELAY, () {
      if (mounted) {
        setState(() => streakplierOpacity = 1.0);
        streakplierController.forward();
      }
    });

    // Experience points reveal (now third)
    Future.delayed(REWARD_INITIAL_DELAY + ITEM_REVEAL_DELAY * 2, () {
      if (mounted) {
        setState(() => experiencePointsOpacity = 1.0);
        experiencePointsController.forward();
      }
    });

    // Continue button reveal and stop audio
    Future.delayed(REWARD_INITIAL_DELAY + ITEM_REVEAL_DELAY * 3, () {
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

    const Widget CheckIcon = Icon(
      Icons.check_circle,
      color: RLTheme.primaryGreen,
      size: CELEBRATION_ICON_SIZE,
    );

    return Container(width: 64, height: 64, decoration: iconDecoration, child: CheckIcon);
  }

  // Statistics display for all reward components with sequential animations
  Widget RewardStatistics() {
    final String formattedLessonTime = formatLessonDuration();

    return Div.column([
      // Featured lesson time card - larger and more prominent
      FeaturedReadingTimeCard(formattedLessonTime),

      const Spacing.height(24),

      // Secondary stats row
      SecondaryStatsRow(),
    ], crossAxisAlignment: CrossAxisAlignment.stretch);
  }

  // Featured reading time card with enhanced visual prominence
  Widget FeaturedReadingTimeCard(String formattedLessonTime) {
    final BoxDecoration featuredCardDecoration = BoxDecoration(
      color: RLTheme.warningColor.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: RLTheme.warningColor.withValues(alpha: 0.3), width: 2),
      boxShadow: [
        BoxShadow(
          color: RLTheme.warningColor.withValues(alpha: 0.1),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );

    final BoxDecoration timerIconDecoration = BoxDecoration(
      color: RLTheme.warningColor.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(40),
    );

    const Widget TimerIcon = Icon(Icons.timer_rounded, color: RLTheme.warningColor, size: 40);

    return AnimatedOpacity(
      opacity: lessonTimeOpacity,
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: featuredCardDecoration,
        child: Div.column([
          // Large timer icon
          Container(width: 80, height: 80, decoration: timerIconDecoration, child: TimerIcon),

          const Spacing.height(16),

          // Reading time label
          RLTypography.bodyLarge(
            LESSON_TIME_LABEL,
            color: RLTheme.textPrimary,
            textAlign: TextAlign.center,
          ),

          const Spacing.height(8),

          // Featured large time display
          Text(
            formattedLessonTime,
            style: RLTypography.headingLargeStyle.copyWith(
              color: RLTheme.warningColor,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ], crossAxisAlignment: CrossAxisAlignment.center),
      ),
    );
  }

  // Secondary stats in a row layout
  Widget SecondaryStatsRow() {
    return Container(
      padding: const EdgeInsets.all(REWARD_CARD_PADDING),
      decoration: getRewardCardDecoration(),
      child: Div.row([
        // Streakplier on the left
        Expanded(
          child: AnimatedOpacity(
            opacity: streakplierOpacity,
            duration: const Duration(milliseconds: 300),
            child: CompactRewardStatisticItem(
              icon: Icons.trending_up,
              label: STREAKPLIER_LABEL,
              animatedValue: AnimatedBuilder(
                animation: streakplierCountAnimation,
                builder: (context, child) {
                  return RLTypography.bodyLarge(
                    '${streakplierCountAnimation.value.toStringAsFixed(2)}x',
                    color: RLTheme.primaryGreen,
                    textAlign: TextAlign.center,
                  );
                },
              ),
              color: RLTheme.primaryGreen,
            ),
          ),
        ),

        const Spacing.width(24),

        // Experience points on the right
        Expanded(
          child: AnimatedOpacity(
            opacity: experiencePointsOpacity,
            duration: const Duration(milliseconds: 300),
            child: CompactRewardStatisticItem(
              label: EXPERIENCE_POINTS_LABEL,
              animatedValue: AnimatedBuilder(
                animation: experiencePointsCountAnimation,
                builder: (context, child) {
                  return RLTypography.bodyLarge(
                    '+${experiencePointsCountAnimation.value} XP',
                    color: RLTheme.primaryBlue,
                    textAlign: TextAlign.center,
                  );
                },
              ),
              color: RLTheme.primaryBlue,
            ),
          ),
        ),
      ]),
    );
  }

  // Compact reward statistic item for secondary stats
  Widget CompactRewardStatisticItem({
    IconData? icon,
    required String label,
    required Widget animatedValue,
    required Color color,
  }) {
    final BoxDecoration iconContainerDecoration = BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
    );

    final bool hasIcon = icon != null;
    final List<Widget> statisticChildren = [];

    if (hasIcon) {
      final Widget StatisticIcon = Icon(icon, color: color, size: 18);

      statisticChildren.add(
        Container(
          width: 32,
          height: 32,
          decoration: iconContainerDecoration,
          child: StatisticIcon,
        ),
      );

      statisticChildren.add(const Spacing.height(8));
    }

    statisticChildren.add(
      RLTypography.bodyMedium(label, color: RLTheme.textSecondary, textAlign: TextAlign.center),
    );

    statisticChildren.add(const Spacing.height(4));

    statisticChildren.add(animatedValue);

    return Div.column(statisticChildren, crossAxisAlignment: CrossAxisAlignment.center);
  }

  // Continue button with simple opacity animation
  Widget ContinueButton() {
    return AnimatedOpacity(
      opacity: continueButtonOpacity,
      duration: const Duration(milliseconds: 300),
      child: RLDS.BlockButton(
        children: [RLTypography.bodyLarge(REWARD_CONTINUE_BUTTON_TEXT, color: Colors.white)],
        onTap: widget.onContinue,
        backgroundColor: RLTheme.primaryGreen,
        margin: EdgeInsets.zero,
      ),
    );
  }

  // Reward card styling decoration
  BoxDecoration getRewardCardDecoration() {
    return BoxDecoration(
      color: RLTheme.backgroundLight,
      borderRadius: BorderRadius.circular(REWARD_CARD_BORDER_RADIUS),
      border: Border.all(color: RLTheme.textPrimary.withValues(alpha: 0.1)),
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
  String formatLessonDuration() {
    final int totalMinutes = widget.reward.lessonDuration.inMinutes;
    final int remainingSeconds = widget.reward.lessonDuration.inSeconds % 60;

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
