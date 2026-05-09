// Single-choice question where the reader picks exactly one answer.
// Question reveals character-by-character (ProgressiveText).
// Each answer sits blurred until tapped — first tap unblurs, second tap commits.

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/models/CourseModel.dart';
import 'package:readlock/course_screens/CourseAccentScope.dart';
import 'package:readlock/design_system/RLLunarBlur.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLReadingJustified.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/course_screens/CourseContentViewer.dart';
import 'package:readlock/course_screens/widgets/CCContinueButton.dart';
import 'package:readlock/design_system/RLFeedbackSnackbar.dart';
import 'package:readlock/services/feedback/HapticsService.dart';
import 'package:readlock/services/feedback/SoundService.dart';
import 'package:readlock/utility_widgets/text_animation/ProgressiveText.dart';
import 'package:readlock/utility_widgets/visual_effects/BlurOverlay.dart';

import 'package:pixelarticons/pixel.dart';

// Covered-answer blur comes directly from BlurOverlay's defaults, which
// consume RLDS.lyricsBlur*. No per-file constants — one token, one place.

class CCQuestion extends StatefulWidget {
  final QuestionSwipe content;
  final void Function(int selectedIndex, bool isCorrect) onAnswerSelected;

  const CCQuestion({super.key, required this.content, required this.onAnswerSelected});

  @override
  State<CCQuestion> createState() => CCQuestionState();
}

class CCQuestionState extends State<CCQuestion> {
  int? selectedAnswerIndex;
  bool hasAnsweredQuestion = false;
  bool isContinueVisible = false;
  Set<int> revealedAnswers = {};

  @override
  Widget build(BuildContext context) {
    // Live-rebuild on Justify Text toggle so the question and answer text
    // reflow without leaving the swipe.
    return ValueListenableBuilder<bool>(
      valueListenable: justifiedReadingEnabledNotifier,
      builder: (context, isJustified, _) {
        final TextAlign paragraphAlignment = isJustified
            ? TextAlign.justify
            : TextAlign.left;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: isContinueVisible ? handleNextSlideTap : null,
          child: Padding(
            padding: RLDS.contentPaddingInsets,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Scrollable question and options content, centred when
                // the content fits and scrollable when it overflows.
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      child: CenteredQuestionContent(paragraphAlignment, constraints),
                    ),
                  ),
                ),

                // Continue affordance pinned at the bottom. Delayed 1400ms
                // after the correct answer commits so the reader has a moment
                // to absorb the result before advancing.
                CCContinueButton(visible: isContinueVisible),
              ],
            ),
          ),
        );
      },
    );
  }

  // Single-segment reveal — ProgressiveText lays the full text out via a
  // transparent tail from the first frame, so the answers below never shift
  // as characters type in. Cadence matches text swipes (ProgressiveText's
  // default typewriterCharacterDelay) so the question reads at the same
  // speed as the rest of the course content.
  Widget QuestionTextSection(TextAlign paragraphAlignment) {
    return ProgressiveText(
      textSegments: [widget.content.question],
      textStyle: RLTypography.readingMediumStyle,
      textAlign: paragraphAlignment,
      blurCompletedSentences: false,
      enableTapToReveal: false,
    );
  }

  Widget CenteredQuestionContent(TextAlign paragraphAlignment, BoxConstraints constraints) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: constraints.maxHeight),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QuestionTextSection(paragraphAlignment),

          const Spacing.height(RLDS.spacing32),

          OptionsListSection(paragraphAlignment),
        ],
      ),
    );
  }

  Widget OptionsListSection(TextAlign paragraphAlignment) {
    final List<Widget> optionWidgets = OptionWidgetsList(paragraphAlignment);

    return Div.column(optionWidgets);
  }

  List<Widget> OptionWidgetsList(TextAlign paragraphAlignment) {
    final List<Widget> optionWidgets = [];

    for (int optionIndex = 0; optionIndex < widget.content.options.length; optionIndex++) {
      final QuestionOption option = widget.content.options[optionIndex];

      optionWidgets.add(
        OptionButton(
          optionIndex: optionIndex,
          option: option,
          paragraphAlignment: paragraphAlignment,
        ),
      );

      final bool isLastOption = optionIndex == widget.content.options.length - 1;

      if (!isLastOption) {
        optionWidgets.add(const Spacing.height(RLDS.spacing16));
      }
    }

    return optionWidgets;
  }

  Widget OptionButton({
    required int optionIndex,
    required QuestionOption option,
    required TextAlign paragraphAlignment,
  }) {
    final bool isRevealed = revealedAnswers.contains(optionIndex);
    final bool isSelected = selectedAnswerIndex == optionIndex;
    // correctAnswerIndex is 0-based — matches the options list directly,
    // same as CCTrueFalseQuestion. lockie's exporter already converts the
    // 1-based source value to 0-based when writing the JSON.
    final bool isCorrectAnswer = widget.content.correctAnswerIndex == optionIndex;
    final bool shouldShowCorrect = hasAnsweredQuestion && isCorrectAnswer && isSelected;
    final bool shouldShowIncorrect = hasAnsweredQuestion && !isCorrectAnswer && isSelected;

    final bool isMutedOption = hasAnsweredQuestion && !isCorrectAnswer && !isSelected;

    final Color optionTextColor = getOptionTextColor(isMuted: isMutedOption);

    final VoidCallback? tapHandler = buildOptionTapHandler(
      optionIndex: optionIndex,
      isRevealed: isRevealed,
    );

    final Widget optionText = OptionText(
      optionIndex: optionIndex,
      option: option,
      textColor: optionTextColor,
      isRevealed: isRevealed,
      paragraphAlignment: paragraphAlignment,
      // Flips the ValueKey on the picked correct answer so the
      // ProgressiveText remounts and the typewriter replays alongside
      // the green border reveal.
      shouldReplayTypewriter: shouldShowCorrect,
    );

    final Widget optionRowContent = Row(
      children: [
        Expanded(child: optionText),

        RenderIf.condition(shouldShowIncorrect, IncorrectIcon(), const SizedBox.shrink()),
      ],
    );

    // LunarBlur surface — matches the continue button in CCTextContent so
    // every interactive pane on a swipe reads as the same frosted glass.
    // The correct-answer state wraps the pane in a 2px green border; the
    // text colour itself stays unchanged (white) so the border carries
    // all the success signal.
    final Widget frostedSurface = RLLunarBlur(
      borderRadius: RLDS.borderRadiusMedium,
      padding: RLDS.contentPaddingMediumInsets,
      child: optionRowContent,
    );

    final childWrappedWithCorrectAnswerBorder = Container(
      decoration: BoxDecoration(
        borderRadius: RLDS.borderRadiusMedium,
        border: Border.all(color: RLDS.success, width: 2.0),
      ),
      child: frostedSurface,
    );

    final Widget surfaceWithCorrectBorder = shouldShowCorrect
        ? childWrappedWithCorrectAnswerBorder
        : frostedSurface;

    final Widget optionRow = GestureDetector(
      onTap: tapHandler,
      child: surfaceWithCorrectBorder,
    );

    // Non-selected options re-blur after a correct answer so the reader's
    // eye lands on the winner only. Options the reader never revealed stay
    // blurred as before.
    final bool shouldBlurAfterAnswer = hasAnsweredQuestion && !isSelected;
    final bool shouldBlur = !isRevealed || shouldBlurAfterAnswer;

    final Widget blurredOption = BlurOverlay(enabled: shouldBlur, child: optionRow);

    // Stack a tap-to-reveal eye centred on top of every still-blurred,
    // pre-answer option. Same affordance as CCReflect's thinking points so
    // the "tap me to see" gesture reads consistently across the course.
    final bool showRevealEye = !isRevealed && !hasAnsweredQuestion;

    if (!showRevealEye) {
      return blurredOption;
    }

    return Stack(
      children: [
        blurredOption,

        Positioned.fill(child: IgnorePointer(child: Center(child: RevealEyeIcon()))),
      ],
    );
  }

  // Open-eye affordance, tinted with the active course's accent (falls back
  // to the muted secondary tone when no CourseAccentScope is in place) so
  // every CCReflect / CCQuestion blurred surface reads as the same family.
  Widget RevealEyeIcon() {
    final Color iconColor = CourseAccentScope.of(
      context,
      fallback: RLDS.textSecondary,
    );

    return Icon(
      Pixel.eye,
      color: iconColor,
      size: RLDS.iconXXLarge,
    );
  }

  // Two-state render:
  //
  //   1. not revealed → transparent label wrapped in a Div.column with the
  //      same width:infinity that ProgressiveText wraps its own content
  //      in — reserves the final card height from the first frame.
  //   2. revealed → ProgressiveText mounted with a ValueKey. The key is
  //      stable across rebuilds while the option is in its idle revealed
  //      state, so the typewriter plays exactly once. When the option is
  //      the correct picked answer, `shouldReplayTypewriter` flips the
  //      key, forcing a remount so the typewriter replays in lock-step
  //      with the green border reveal. Layout stays stable because
  //      ProgressiveText reserves its final height via a transparent
  //      tail from the first frame.
  Widget OptionText({
    required int optionIndex,
    required QuestionOption option,
    required Color textColor,
    required bool isRevealed,
    required TextAlign paragraphAlignment,
    required bool shouldReplayTypewriter,
  }) {
    if (!isRevealed) {
      return Div.column(
        [RLTypography.readingLarge(option.text, color: RLDS.transparent)],
        crossAxisAlignment: CrossAxisAlignment.start,
        width: double.infinity,
      );
    }

    final String replayPhase = shouldReplayTypewriter ? 'correct' : 'idle';

    return ProgressiveText(
      key: ValueKey('option_text_${optionIndex}_$replayPhase'),
      textSegments: [option.text],
      textStyle: RLTypography.readingLargeStyle.copyWith(color: textColor),
      textAlign: paragraphAlignment,
      blurCompletedSentences: false,
      enableTapToReveal: false,
    );
  }

  VoidCallback? buildOptionTapHandler({required int optionIndex, required bool isRevealed}) {
    if (hasAnsweredQuestion) {
      return null;
    }

    if (!isRevealed) {
      return () => handleAnswerReveal(optionIndex);
    }

    return () => handleOptionSelection(optionIndex);
  }

  Widget IncorrectIcon() {
    return Icon(Pixel.close, color: RLDS.glass70(RLDS.textPrimary), size: RLDS.iconMedium);
  }

  void handleAnswerReveal(int optionIndex) {
    HapticsService.lightImpact();
    SoundService.playRandomTextClick();

    setState(() {
      revealedAnswers.add(optionIndex);
    });
  }

  void handleOptionSelection(int optionIndex) {
    if (hasAnsweredQuestion) {
      return;
    }

    HapticsService.lightImpact();

    // correctAnswerIndex is 0-based — matches the options list directly.
    final bool isCorrectAnswer = widget.content.correctAnswerIndex == optionIndex;

    if (!isCorrectAnswer) {
      SoundService.playWrong();
      showIncorrectAnswerFeedback(optionIndex);
      return;
    }

    markQuestionAsAnswered(optionIndex);
    showCorrectAnswerFeedback(optionIndex);
    SoundService.playCorrect();
    HapticsService.mediumImpact();

    widget.onAnswerSelected(optionIndex, isCorrectAnswer);
  }

  void showIncorrectAnswerFeedback(int optionIndex) {
    final QuestionOption selectedOption = widget.content.options[optionIndex];
    final String consequenceMessage = getIncorrectConsequenceMessage(selectedOption);

    FeedbackSnackBar.showWrongAnswer(context, hint: consequenceMessage);
  }

  String getIncorrectConsequenceMessage(QuestionOption selectedOption) {
    if (selectedOption.consequenceMessage != null) {
      return selectedOption.consequenceMessage!;
    }

    if (widget.content.hint != null) {
      return widget.content.hint!;
    }

    return RLUIStrings.QUESTION_DEFAULT_WRONG_ANSWER_HINT;
  }

  void showCorrectAnswerFeedback(int optionIndex) {
    final QuestionOption selectedOption = widget.content.options[optionIndex];
    final String feedbackMessage = getCorrectFeedbackMessage(selectedOption);

    FeedbackSnackBar.showCorrectAnswer(context, explanation: feedbackMessage);
  }

  String getCorrectFeedbackMessage(QuestionOption selectedOption) {
    if (selectedOption.consequenceMessage != null) {
      return selectedOption.consequenceMessage!;
    }

    return widget.content.explanation;
  }

  void markQuestionAsAnswered(int selectedIndex) {
    setState(() {
      selectedAnswerIndex = selectedIndex;
      hasAnsweredQuestion = true;
    });

    showContinueButtonDelayed();
  }

  void showContinueButtonDelayed() async {
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
      isContinueVisible = true;
    });
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

  Color getOptionTextColor({required bool isMuted}) {
    if (isMuted) {
      return RLDS.glass40(RLDS.textPrimary);
    }

    return RLDS.textPrimary;
  }
}
