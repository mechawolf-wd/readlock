// Single-choice question where the reader picks exactly one answer.
// Question reveals character-by-character (ProgressiveText).
// Each answer sits blurred until tapped — first tap unblurs, second tap commits.

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/models/CourseModel.dart';
import 'package:readlock/design_system/RLLunarBlur.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLUIStrings.dart';
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
  Set<int> revealedAnswers = {};

  @override
  Widget build(BuildContext context) {
    return Div.column(
      [
        QuestionTextSection(),

        const Spacing.height(RLDS.spacing32),

        OptionsListSection(),

        const Spacing.height(RLDS.spacing32),
      ],
      padding: RLDS.contentPaddingInsets,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }

  // Single-segment reveal — ProgressiveText lays the full text out via a
  // transparent tail from the first frame, so the answers below never shift
  // as characters type in. Cadence matches text swipes (ProgressiveText's
  // default typewriterCharacterDelay) so the question reads at the same
  // speed as the rest of the course content.
  Widget QuestionTextSection() {
    return ProgressiveText(
      textSegments: [widget.content.question],
      textStyle: RLTypography.readingMediumStyle,
      blurCompletedSentences: false,
      enableTapToReveal: false,
    );
  }

  Widget OptionsListSection() {
    final List<Widget> optionWidgets = OptionWidgetsList();

    return Div.column(optionWidgets);
  }

  List<Widget> OptionWidgetsList() {
    final List<Widget> optionWidgets = [];

    for (int optionIndex = 0; optionIndex < widget.content.options.length; optionIndex++) {
      final QuestionOption option = widget.content.options[optionIndex];

      optionWidgets.add(OptionButton(optionIndex: optionIndex, option: option));

      final bool isLastOption = optionIndex == widget.content.options.length - 1;

      if (!isLastOption) {
        optionWidgets.add(const Spacing.height(RLDS.spacing16));
      }
    }

    return optionWidgets;
  }

  Widget OptionButton({required int optionIndex, required QuestionOption option}) {
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

    return BlurOverlay(enabled: shouldBlur, child: optionRow);
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
  }

  Color getOptionTextColor({required bool isMuted}) {
    if (isMuted) {
      return RLDS.glass40(RLDS.textPrimary);
    }

    return RLDS.textPrimary;
  }
}
