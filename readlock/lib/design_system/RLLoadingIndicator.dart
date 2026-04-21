// Centralised loading indicator.
//
// Two variants:
//   RLLoadingIndicator.text() — "Loading" with 0 → 3 animated dots, looping.
//   RLLoadingIndicator.bird() — same dots under the user's chosen bird sprite.

import 'package:flutter/material.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/screens/profile/BirdPicker.dart';

// * Animation + layout tuning
const Duration LOADING_DOT_CYCLE_DURATION = Duration(milliseconds: 1600);
const int LOADING_DOT_COUNT = 3;
const int LOADING_DOT_PHASE_COUNT = 4;
const double LOADING_DOT_INACTIVE_OPACITY = 0.2;
const double LOADING_BIRD_SIZE = 160.0;

class RLLoadingIndicator extends StatefulWidget {
  final bool showBird;

  const RLLoadingIndicator.text({super.key}) : showBird = false;

  const RLLoadingIndicator.bird({super.key}) : showBird = true;

  @override
  State<RLLoadingIndicator> createState() => RLLoadingIndicatorState();
}

class RLLoadingIndicatorState extends State<RLLoadingIndicator>
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

  // Current phase of the cycle, mapped to how many dots are lit (0..3).
  int getActiveDotsCount() {
    final int phase = (dotsController.value * LOADING_DOT_PHASE_COUNT).floor();

    return phase.clamp(0, LOADING_DOT_COUNT);
  }

  @override
  Widget build(BuildContext context) {
    final Widget dotsText = AnimatedBuilder(
      animation: dotsController,
      builder: (context, _) => LoadingDotsRow(activeDots: getActiveDotsCount()),
    );

    final bool shouldShowBird = widget.showBird;

    return Center(
      child: RenderIf.condition(
        shouldShowBird,
        BirdWithDots(dotsText: dotsText),
        dotsText,
      ),
    );
  }

  Widget BirdWithDots({required Widget dotsText}) {
    return ValueListenableBuilder<BirdOption>(
      valueListenable: selectedBirdNotifier,
      builder: (context, bird, _) {
        final Widget birdSprite = BirdAnimationSprite(
          bird: bird,
          previewSize: LOADING_BIRD_SIZE,
        );

        return Div.column(
          [
            birdSprite,

            const Spacing.height(RLDS.spacing16),

            dotsText,
          ],
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
        );
      },
    );
  }
}

class LoadingDotsRow extends StatelessWidget {
  final int activeDots;

  const LoadingDotsRow({super.key, required this.activeDots});

  List<Widget> RowChildren() {
    final List<Widget> children = [
      RLTypography.headingMedium(
        RLUIStrings.LOADING_LABEL,
        color: RLDS.textSecondary,
      ),
    ];

    for (int dotIndex = 0; dotIndex < LOADING_DOT_COUNT; dotIndex++) {
      final bool isActive = dotIndex < activeDots;
      final double dotOpacity =
          isActive ? 1.0 : LOADING_DOT_INACTIVE_OPACITY;

      final Widget dot = Opacity(
        opacity: dotOpacity,
        child: RLTypography.headingMedium('.', color: RLDS.textSecondary),
      );

      children.add(dot);
    }

    return children;
  }

  @override
  Widget build(BuildContext context) {
    return Div.row(
      RowChildren(),
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
    );
  }
}
