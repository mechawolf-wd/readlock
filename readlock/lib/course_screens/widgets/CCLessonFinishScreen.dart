// Final page of every lesson in the course content viewer. The drop is
// decided once on lesson entry by CourseDetailScreen and frozen for the
// rest of the session, so this widget is a pure renderer: when a feather
// has dropped it sits as the hero of the screen with the elapsed lesson
// time tucked underneath as a subtitle; when nothing dropped the time
// stands on its own.
//
// The Finish button is purely a navigation affordance. The cumulative
// timeSpentReading counter is bumped by CourseDetailScreen.dispose when
// the reader actually leaves the course, not when this finish screen
// appears, so a reader who lingers on the finish page or scrolls back
// up still gets credit for the full session.

import 'package:flutter/material.dart' hide Typography;
import 'package:pixelarticons/pixel.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/design_system/RLButton.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/screens/profile/BirdPicker.dart';

// One-shot count-up that animates the elapsed time from 0:00 to its
// final value the moment the screen appears, so the duration reads as
// "earned" rather than just printed. Short and ease-out so the seconds
// fly past quickly and settle on the final value.
const Duration LESSON_FINISH_TIME_COUNTUP_DURATION = Duration(milliseconds: 1200);

// Breathing pulse shared with the roadmap nodes (0.97 to 1.03 over
// 2200ms, ease-in-out, reversing). Mirrors CourseRoadmapScreen so the
// reward heartbeat reads as the same family across the journey.
const Duration LESSON_FINISH_BREATHING_DURATION = Duration(milliseconds: 2200);
const double LESSON_FINISH_BREATHING_MIN_SCALE = 0.97;
const double LESSON_FINISH_BREATHING_MAX_SCALE = 1.03;

class CCLessonFinishScreen extends StatefulWidget {
  final Duration timeSpent;
  final bool didEarnFeather;
  final VoidCallback onFinishTap;

  const CCLessonFinishScreen({
    super.key,
    required this.timeSpent,
    required this.didEarnFeather,
    required this.onFinishTap,
  });

  @override
  State<CCLessonFinishScreen> createState() => CCLessonFinishScreenState();
}

class CCLessonFinishScreenState extends State<CCLessonFinishScreen>
    with TickerProviderStateMixin {
  late AnimationController breathingController;
  late Animation<double> breathingAnimation;

  late AnimationController timeCountUpController;
  late Animation<int> timeCountUpAnimation;

  @override
  void initState() {
    super.initState();

    breathingController = AnimationController(
      vsync: this,
      duration: LESSON_FINISH_BREATHING_DURATION,
    )..repeat(reverse: true);

    breathingAnimation = Tween<double>(
      begin: LESSON_FINISH_BREATHING_MIN_SCALE,
      end: LESSON_FINISH_BREATHING_MAX_SCALE,
    ).animate(CurvedAnimation(parent: breathingController, curve: Curves.easeInOut));

    final int totalSeconds = widget.timeSpent.inSeconds;

    timeCountUpController = AnimationController(
      vsync: this,
      duration: LESSON_FINISH_TIME_COUNTUP_DURATION,
    );

    timeCountUpAnimation = IntTween(begin: 0, end: totalSeconds).animate(
      CurvedAnimation(parent: timeCountUpController, curve: Curves.easeOut),
    );

    timeCountUpController.forward();
  }

  @override
  void dispose() {
    breathingController.dispose();
    timeCountUpController.dispose();
    super.dispose();
  }

  // M:SS for short lessons, H:MM:SS once a lesson run crosses the hour.
  // Stays compact so the time stays readable as a subtitle under the
  // feather without dominating the hero.
  String formatElapsedTime(Duration duration) {
    final int totalSeconds = duration.inSeconds;
    final int hours = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    final int seconds = totalSeconds % 60;
    final String twoDigitSeconds = seconds.toString().padLeft(2, '0');
    final bool spansAtLeastAnHour = hours > 0;

    if (spansAtLeastAnHour) {
      final String twoDigitMinutes = minutes.toString().padLeft(2, '0');

      return '$hours:$twoDigitMinutes:$twoDigitSeconds';
    }

    return '$minutes:$twoDigitSeconds';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: RLDS.contentPaddingInsets,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hero, feather (if dropped) and the elapsed time, vertically
          // centred in the available slot above the commit button.
          Expanded(child: HeroContent()),

          // Commit button. Tapping it is what writes the elapsed delta
          // back to the user model via the host's onFinishTap.
          FinishButton(),
        ],
      ),
    );
  }

  // Branches the hero layout: feather + time when dropped (feather is the
  // main thing, time is a small subtitle below); time-only when not. Same
  // typographic weight on the time in both branches so the no-drop case
  // doesn't read as an error or empty state, just a quiet finish.
  Widget HeroContent() {
    if (widget.didEarnFeather) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PulsingBird(),

          const Spacing.height(RLDS.spacing16),

          AnimatedTimeSpentRow(),
        ],
      );
    }

    return Center(child: AnimatedTimeSpentRow());
  }

  // Re-renders the time row each tick of the count-up animation so the
  // seconds fly from 0:00 up to the lesson's final elapsed value.
  Widget AnimatedTimeSpentRow() {
    return AnimatedBuilder(
      animation: timeCountUpAnimation,
      builder: (BuildContext context, Widget? _) {
        final Duration tickDuration = Duration(seconds: timeCountUpAnimation.value);
        final String formattedTime = formatElapsedTime(tickDuration);

        return TimeSpentRow(formattedTime: formattedTime);
      },
    );
  }

  // User's profile bird wrapped in the shared roadmap heartbeat so the
  // reward breathes in lock-step with the lesson tiles the reader just
  // left. Rebuilds when the reader picks a different bird mid-session
  // so the finish screen always shows the latest selection.
  Widget PulsingBird() {
    return ValueListenableBuilder<BirdOption>(
      valueListenable: selectedBirdNotifier,
      builder: (BuildContext context, BirdOption bird, Widget? _) {
        return ScaleTransition(
          scale: breathingAnimation,
          // BirdAnimationSprite defaults to BIRD_PREVIEW_SIZE_LARGE
          // (128), the shared "hero bird" size used by the picker too.
          child: BirdAnimationSprite(bird: bird),
        );
      },
    );
  }

  // Clock glyph + elapsed time. The icon makes the duration legible at a
  // glance instead of a bare number floating under the feather.
  static const Widget TimeSpentClockIcon = Icon(
    Pixel.clock,
    color: RLDS.textSecondary,
    size: RLDS.iconMedium,
  );

  Widget TimeSpentRow({required String formattedTime}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TimeSpentClockIcon,

        const Spacing.width(RLDS.spacing8),

        RLTypography.bodyLarge(
          formattedTime,
          color: RLDS.textSecondary,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget FinishButton() {
    return RLButton.tertiary(
      label: RLUIStrings.LESSON_FINISH_BUTTON_LABEL,
      onTap: widget.onFinishTap,
    );
  }
}
