// Full-screen loading widget displayed while course content is being prepared.
// Starfield background with a centered "Preparing..." label whose dots build
// one by one, matching the rhythm of the "Latest read..." heading on Home.

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/design_system/RLLoadingIndicator.dart';
import 'package:readlock/design_system/RLLunarBlur.dart';
import 'package:readlock/design_system/RLStarfieldBackground.dart';


class CourseLoadingScreen extends StatefulWidget {
  const CourseLoadingScreen({super.key});

  @override
  State<CourseLoadingScreen> createState() => CourseLoadingScreenState();
}

class CourseLoadingScreenState extends State<CourseLoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController dotsController;

  @override
  void initState() {
    super.initState();

    dotsController = AnimationController(
      vsync: this,
      duration: LOADING_DOT_CYCLE_DURATION,
    );

    dotsController.repeat();
  }

  @override
  void dispose() {
    dotsController.dispose();
    super.dispose();
  }

  int getActiveDotsCount() {
    final int phase = (dotsController.value * LOADING_DOT_COUNT).floor();
    final int clampedPhase = phase.clamp(0, LOADING_DOT_COUNT - 1);

    return clampedPhase + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: STARFIELD_BACKGROUND_COLOR,
      body: Stack(
        children: [
          const Positioned.fill(child: RLStarfieldBackground()),

          const Positioned.fill(
            child: RLLunarBlur(
              borderRadius: BorderRadius.zero,
              child: SizedBox.expand(),
            ),
          ),

          Center(
            child: AnimatedBuilder(
              animation: dotsController,
              builder: PreparingLabel,
            ),
          ),
        ],
      ),
    );
  }

  Widget PreparingLabel(BuildContext context, Widget? unusedChild) {
    final int activeDots = getActiveDotsCount();

    final List<Widget> rowChildren = [
      RLTypography.headingMedium(
        RLUIStrings.PREPARING_LABEL,
        color: RLDS.textSecondary,
      ),
    ];

    for (int dotIndex = 0; dotIndex < LOADING_DOT_COUNT; dotIndex++) {
      final bool isActive = dotIndex < activeDots;
      final double dotOpacity = isActive ? 1.0 : 0.0;

      rowChildren.add(
        Opacity(
          opacity: dotOpacity,
          child: RLTypography.headingMedium('.', color: RLDS.textSecondary),
        ),
      );
    }

    return Row(mainAxisSize: MainAxisSize.min, children: rowChildren);
  }
}
