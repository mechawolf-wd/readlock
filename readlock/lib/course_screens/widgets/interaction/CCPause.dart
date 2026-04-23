// Motivational breathing slide between lesson sections.
// Shows the reader's chosen bird in its idle animation and progressively
// types out the motivational message.

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/screens/profile/BirdPicker.dart';
import 'package:readlock/utility_widgets/text_animation/ProgressiveText.dart';

class CCPause extends StatelessWidget {
  final String text;
  final String? iconName;

  const CCPause({super.key, required this.text, this.iconName});

  static const double birdPreviewSize = BIRD_PREVIEW_SIZE_SMALL;
  static const double birdZoom = 1.0;

  @override
  Widget build(BuildContext context) {
    // Colour matches CCTextContent's reading text (full textPrimary) so the
    // motivational line reads as part of the same reading voice, not a muted
    // caption.
    final TextStyle motivationalTextStyle = RLTypography.readingLargeStyle.copyWith(
      fontWeight: FontWeight.w600,
      color: RLDS.textPrimary,
    );

    return Div.column(
      [
        MotivationalContent(motivationalTextStyle: motivationalTextStyle),
      ],
      padding: RLDS.contentPaddingInsets,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
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
    return BirdAnimationSprite(
      bird: bird,
      previewSize: birdPreviewSize,
      zoom: birdZoom,
    );
  }

  // Slower than the default 10ms/char — the pause message is short, and a
  // default-speed reveal finishes before the swipe animation does, so the
  // reader never sees it type in. 40ms/char keeps the reveal in progress
  // while the user lands on the page.
  static const Duration pauseTypewriterCharacterDelay = Duration(milliseconds: 40);

  Widget MotivationalText({required TextStyle textStyle}) {
    return ProgressiveText(
      textSegments: [text],
      textStyle: textStyle,
      textAlignment: CrossAxisAlignment.center,
      textAlign: TextAlign.center,
      blurCompletedSentences: false,
      enableTapToReveal: false,
      typewriterCharacterDelay: pauseTypewriterCharacterDelay,
    );
  }
}
