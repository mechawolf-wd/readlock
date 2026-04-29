// Notable-quote slide. Mirrors CCPause's structure (bird companion above
// a centred typewriter line) so the reader's eye lands the same way on
// both interaction beats. Quote body is italic and wrapped in opening /
// closing quotation marks; the author sits underneath in muted text as a
// quiet attribution.

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/models/CourseModel.dart';
import 'package:readlock/screens/profile/BirdPicker.dart';
import 'package:readlock/utility_widgets/text_animation/ProgressiveText.dart';

class CCQuote extends StatelessWidget {
  final QuoteSwipe content;

  const CCQuote({super.key, required this.content});

  static const double birdPreviewSize = BIRD_PREVIEW_SIZE_SMALL;

  // Slower than the default 10ms/char — the quote is short, and a default-
  // speed reveal finishes before the swipe animation does, so the reader
  // never sees it type in. 40ms/char keeps the reveal in progress while
  // the user lands on the page. Same pace as CCPause for consistency.
  static const Duration quoteTypewriterCharacterDelay = Duration(milliseconds: 40);

  @override
  Widget build(BuildContext context) {
    // Italic reading style — same weight and colour as CCPause but tilted
    // so the line reads as a citation rather than narration.
    final TextStyle quoteTextStyle = RLTypography.readingLargeStyle.copyWith(
      color: RLDS.textPrimary,
      fontStyle: FontStyle.italic,
    );

    return Div.column(
      [
        QuoteContent(quoteTextStyle: quoteTextStyle),
      ],
      padding: RLDS.contentPaddingInsets,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }

  Widget QuoteContent({required TextStyle quoteTextStyle}) {
    return Div.column(
      [
        BirdCompanion(),

        const Spacing.height(RLDS.spacing16),

        QuoteBody(textStyle: quoteTextStyle),

        const Spacing.height(RLDS.spacing12),

        AuthorAttribution(),
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

  Widget BirdBuilder(BuildContext context, BirdOption bird, Widget? unusedChild) {
    return BirdAnimationSprite(bird: bird, previewSize: birdPreviewSize);
  }

  Widget QuoteBody({required TextStyle textStyle}) {
    final String wrappedQuote = '"${content.quote}"';

    return ProgressiveText(
      textSegments: [wrappedQuote],
      textStyle: textStyle,
      textAlignment: CrossAxisAlignment.center,
      textAlign: TextAlign.center,
      blurCompletedSentences: false,
      enableTapToReveal: false,
      typewriterCharacterDelay: quoteTypewriterCharacterDelay,
    );
  }

  Widget AuthorAttribution() {
    // Reuses the reader-picked reading family (Lora / Lexend / Mono) so the
    // attribution sits in the same voice as the quote above instead of
    // jumping to the JetBrains Mono UI font. Muted colour drops the line
    // back so the quote stays the visual focus.
    final TextStyle authorTextStyle = RLTypography.readingMediumStyle.copyWith(
      color: RLDS.textMuted,
    );

    return Text(
      content.author,
      style: authorTextStyle,
      textAlign: TextAlign.center,
    );
  }
}
