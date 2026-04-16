// Gamified reward screen displaying XP gains, streak multiplier, and loot rewards
// Shows lesson completion achievements with sequential reveal animations and counting effects

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLUIStrings.dart';

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
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    streakplierController = AnimationController(
      duration: const Duration(milliseconds: 800),
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

  // Start the sequential reveal with simple opacity changes
  void startRevealSequence() {
    const Duration initialDelay = Duration(milliseconds: 500);
    const Duration itemRevealDelay = Duration(milliseconds: 600);

    // Lesson time reveal (first with emphasis)
    Future.delayed(initialDelay, () {
      if (mounted) {
        setState(() => lessonTimeOpacity = 1.0);
      }
    });

    // Streakplier reveal (second)
    Future.delayed(initialDelay + itemRevealDelay, () {
      if (mounted) {
        setState(() => streakplierOpacity = 1.0);
        streakplierController.forward();
      }
    });

    // Experience points reveal (third)
    Future.delayed(initialDelay + itemRevealDelay * 2, () {
      if (mounted) {
        setState(() => experiencePointsOpacity = 1.0);
        experiencePointsController.forward();
      }
    });

    // Continue button reveal
    Future.delayed(initialDelay + itemRevealDelay * 3, () {
      if (mounted) {
        setState(() => continueButtonOpacity = 1.0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RLDS.backgroundDark,
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
        RLUIStrings.REWARD_CONGRATULATIONS,
        color: RLDS.success,
        textAlign: TextAlign.center,
      ),

      const Spacing.height(8),

      // Lesson complete subtitle
      RLTypography.bodyLarge(
        RLUIStrings.REWARD_LESSON_COMPLETE,
        color: RLDS.textSecondary,
        textAlign: TextAlign.center,
      ),
    ], crossAxisAlignment: CrossAxisAlignment.center);
  }

  // Large celebration check mark icon
  Widget CelebrationIcon() {
    final BoxDecoration iconDecoration = BoxDecoration(
      color: RLDS.success.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(32),
    );

    final Widget CheckIcon = const Icon(Icons.check_circle, color: RLDS.success, size: 48);

    return Container(width: 64, height: 64, decoration: iconDecoration, child: CheckIcon);
  }

  // Statistics display for all reward components with sequential animations
  Widget RewardStatistics() {
    final String formattedLessonTime = formatLessonDuration();

    return Div.column([
      // Featured lesson time card
      FeaturedReadingTimeCard(formattedLessonTime),

      const Spacing.height(24),

      // Secondary stats row
      SecondaryStatsRow(),
    ], crossAxisAlignment: CrossAxisAlignment.stretch);
  }

  // Featured reading time card with enhanced visual prominence
  Widget FeaturedReadingTimeCard(String formattedLessonTime) {
    final BoxDecoration featuredCardDecoration = BoxDecoration(
      color: RLDS.warning.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: RLDS.warning.withValues(alpha: 0.3), width: 2),
    );

    final BoxDecoration timerIconDecoration = BoxDecoration(
      color: RLDS.warning.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(40),
    );

    final Widget TimerIcon = const Icon(Icons.timer_rounded, color: RLDS.warning, size: 40);

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
            RLUIStrings.REWARD_LESSON_TIME_LABEL,
            color: RLDS.textPrimary,
            textAlign: TextAlign.center,
          ),

          const Spacing.height(8),

          // Featured large time display
          Text(
            formattedLessonTime,
            style: RLTypography.headingLargeStyle.copyWith(
              color: RLDS.warning,
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
      padding: const EdgeInsets.all(24),
      decoration: getRewardCardDecoration(),
      child: Div.row([
        // Streakplier on the left
        Expanded(
          child: AnimatedOpacity(
            opacity: streakplierOpacity,
            duration: const Duration(milliseconds: 300),
            child: CompactRewardStatisticItem(
              icon: Icons.trending_up,
              label: RLUIStrings.REWARD_STREAKPLIER_LABEL,
              animatedValue: AnimatedBuilder(
                animation: streakplierCountAnimation,
                builder: (context, child) {
                  return RLTypography.bodyLarge(
                    '${streakplierCountAnimation.value.toStringAsFixed(2)}x',
                    color: RLDS.success,
                    textAlign: TextAlign.center,
                  );
                },
              ),
              color: RLDS.success,
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
              label: RLUIStrings.REWARD_COLLECTED_LABEL,
              animatedValue: AnimatedBuilder(
                animation: experiencePointsCountAnimation,
                builder: (context, child) {
                  return RLTypography.bodyLarge(
                    '+${experiencePointsCountAnimation.value} XP',
                    color: RLDS.info,
                    textAlign: TextAlign.center,
                  );
                },
              ),
              color: RLDS.info,
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
      RLTypography.bodyMedium(label, color: RLDS.textSecondary, textAlign: TextAlign.center),
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
      child: GestureDetector(
        onTap: widget.onContinue,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: BoxDecoration(
            color: RLDS.success,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [RLTypography.bodyLarge(RLUIStrings.REWARD_CONTINUE_LABEL, color: RLDS.white)],
          ),
        ),
      ),
    );
  }

  // Reward card styling decoration
  BoxDecoration getRewardCardDecoration() {
    return BoxDecoration(
      color: RLDS.backgroundLight,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: RLDS.textPrimary.withValues(alpha: 0.1)),
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
