// Notable-quote slide. Mirrors CCPause's structure (bird companion above
// a centred typewriter line) so the reader's eye lands the same way on
// both interaction beats. Quote body is italic and wrapped in opening /
// closing quotation marks; the author sits underneath in muted text as a
// quiet attribution.

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/course_screens/CourseContentViewer.dart';
import 'package:readlock/course_screens/widgets/CCContinueButton.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/models/CourseModel.dart';
import 'package:readlock/screens/profile/BirdPicker.dart';
import 'package:readlock/services/feedback/HapticsService.dart';
import 'package:readlock/utility_widgets/text_animation/ProgressiveText.dart';

class CCQuote extends StatefulWidget {
  final QuoteSwipe content;

  const CCQuote({super.key, required this.content});

  @override
  State<CCQuote> createState() => CCQuoteState();
}

class CCQuoteState extends State<CCQuote> {
  static const double birdPreviewSize = BIRD_PREVIEW_SIZE_SMALL;

  // Flips once the typewriter lands on the last character so the continue
  // button only appears when the quote is fully readable.
  bool isQuoteRevealed = false;

  void handleQuoteRevealed() async {
    final bool canUpdateState = mounted;

    if (!canUpdateState) {
      return;
    }

    await Future.delayed(const Duration(milliseconds: 1400));

    final bool stillMounted = mounted;

    if (!stillMounted) {
      return;
    }

    setState(() {
      isQuoteRevealed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle quoteTextStyle = RLTypography.readingLargeStyle.copyWith(
      color: RLDS.textPrimary,
      fontStyle: FontStyle.italic,
    );

    return Padding(
      padding: RLDS.contentPaddingInsets,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Tapping anywhere in the expanded area advances to the next
          // slide, but only once the continue button is visible.
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: isQuoteRevealed ? handleNextSlideTap : null,
              child: QuoteContent(quoteTextStyle: quoteTextStyle),
            ),
          ),

          // Continue affordance. Reveals once the quote has fully typed
          // out, so the pause moment lands before the verb does.
          CCContinueButton(visible: isQuoteRevealed),
        ],
      ),
    );
  }

  void handleNextSlideTap() {
    final PageController? pageController = findPageController(context);

    final bool hasValidPageController = pageController != null && pageController.hasClients;

    if (!hasValidPageController) {
      return;
    }

    HapticsService.lightImpact();
    navigateToNextPage(pageController);
  }

  PageController? findPageController(BuildContext context) {
    final CourseDetailScreenState? courseDetailScreen =
        context.findAncestorStateOfType<CourseDetailScreenState>();

    return courseDetailScreen?.pageController;
  }

  void navigateToNextPage(PageController pageController) {
    final double? currentPageDouble = pageController.page;
    final bool hasCurrentPage = currentPageDouble != null;

    if (!hasCurrentPage) {
      return;
    }

    final int currentPage = currentPageDouble.round();
    final int nextPage = currentPage + 1;

    pageController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
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
    final String wrappedQuote = '"${widget.content.quote}"';

    return ProgressiveText(
      textSegments: [wrappedQuote],
      textStyle: textStyle,
      textAlignment: CrossAxisAlignment.center,
      textAlign: TextAlign.center,
      blurCompletedSentences: false,
      enableTapToReveal: false,
      onAllSegmentsRevealed: handleQuoteRevealed,
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
      widget.content.author,
      style: authorTextStyle,
      textAlign: TextAlign.center,
    );
  }
}
