// Motivational breathing slide between lesson sections.
// Shows the reader's chosen bird in its idle animation and progressively
// types out the motivational message.

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/course_screens/widgets/CCContinueButton.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/screens/profile/BirdPicker.dart';
import 'package:readlock/utility_widgets/text_animation/ProgressiveText.dart';

class CCPause extends StatefulWidget {
  final String text;
  final String? iconName;

  const CCPause({super.key, required this.text, this.iconName});

  @override
  State<CCPause> createState() => CCPauseState();
}

class CCPauseState extends State<CCPause> {
  static const double birdPreviewSize = BIRD_PREVIEW_SIZE_SMALL;

  // Slower than the default 10ms/char — the pause message is short, and a
  // default-speed reveal finishes before the swipe animation does, so the
  // reader never sees it type in. 40ms/char keeps the reveal in progress
  // while the user lands on the page.
  static const Duration pauseTypewriterCharacterDelay = Duration(milliseconds: 40);

  // Flips once the typewriter lands on the last character so the continue
  // button only appears when the message is fully readable.
  bool isMotivationRevealed = false;

  void handleMotivationRevealed() {
    if (!mounted) {
      return;
    }

    setState(() {
      isMotivationRevealed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Reads as part of the same reading voice as CCTextContent — shared
    // reading weight, full textPrimary colour. Bold is reserved for bionic
    // fixation prefixes and colour-markup spans (see RLTypography note),
    // so no weight override here.
    final TextStyle motivationalTextStyle = RLTypography.readingLargeStyle.copyWith(
      color: RLDS.textPrimary,
    );

    return Padding(
      padding: RLDS.contentPaddingInsets,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: MotivationalContent(motivationalTextStyle: motivationalTextStyle),
          ),

          // Continue affordance. Reveals once the motivational message has
          // fully typed out, so the pause moment lands before the verb does.
          CCContinueButton(visible: isMotivationRevealed),
        ],
      ),
    );
  }

  Widget MotivationalContent({required TextStyle motivationalTextStyle}) {
    return Div.column(
      [
        BirdCompanion(),

        const Spacing.height(RLDS.spacing16),

        MotivationalText(textStyle: motivationalTextStyle),
      ],
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }

  // Subscribes to selectedBirdNotifier so the sprite updates whenever the
  // user switches birds in Settings. Always renders the idle tag.
  Widget BirdCompanion() {
    return ValueListenableBuilder<BirdOption>(
      valueListenable: selectedBirdNotifier,
      builder: BirdBuilder,
    );
  }

  Widget BirdBuilder(BuildContext context, BirdOption bird, Widget? _) {
    return BirdAnimationSprite(bird: bird, previewSize: birdPreviewSize);
  }

  Widget MotivationalText({required TextStyle textStyle}) {
    return ProgressiveText(
      textSegments: [widget.text],
      textStyle: textStyle,
      textAlignment: CrossAxisAlignment.center,
      textAlign: TextAlign.center,
      blurCompletedSentences: false,
      enableTapToReveal: false,
      typewriterCharacterDelay: pauseTypewriterCharacterDelay,
      onAllSegmentsRevealed: handleMotivationRevealed,
    );
  }
}
