// True/False question that tests whether the reader can identify fact from misconception
// Quick binary choice with animated feedback and an explanation reveal

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/models/CourseModel.dart';
import 'package:readlock/course_screens/CourseContentViewer.dart';
import 'package:readlock/design_system/RLCard.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/services/feedback/HapticsService.dart';
import 'package:readlock/services/feedback/SoundService.dart';
import 'package:readlock/utility_widgets/text_animation/ProgressiveText.dart';
import 'package:readlock/utility_widgets/visual_effects/BlurOverlay.dart';
import 'package:readlock/design_system/RLFeedbackSnackbar.dart';
import 'package:readlock/constants/RLReadingJustified.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/course_screens/widgets/CCContinueButton.dart';

import 'package:pixelarticons/pixel.dart';

enum TrueFalseButtonState { normal, selected, correctAndAnswered, incorrectAndMuted }

// Covered-button blur comes directly from BlurOverlay's defaults, which
// consume RLDS.lyricsBlur*. No per-file constants, one token, one place.

class ButtonColors {
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final Color iconColor;

  const ButtonColors({
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.iconColor,
  });
}

class CCTrueFalseQuestion extends StatefulWidget {
  final TrueFalseSwipe content;
  final void Function(int selectedIndex, bool isCorrect) onAnswerSelected;

  const CCTrueFalseQuestion({super.key, required this.content, required this.onAnswerSelected});

  @override
  State<CCTrueFalseQuestion> createState() => CCTrueFalseQuestionState();
}

class CCTrueFalseQuestionState extends State<CCTrueFalseQuestion> {
  int? selectedAnswerIndex;
  bool hasAnswered = false;
  bool isContinueVisible = false;
  bool isStatementRevealed = false;
  // Blur stays on both buttons until the reader taps one of them. The first
  // tap only removes the blur (for BOTH buttons together, never one at a
  // time). A second tap on either button commits the answer.
  bool areButtonsUnblurred = false;

  @override
  Widget build(BuildContext context) {
    // Live-rebuild on Justify Text toggle so flipping the setting reflows
    // the statement and explanation without leaving the swipe.
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
            padding: const EdgeInsets.all(RLDS.spacing24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Question text blurs once answered so the reader's
                // focus shifts to the explanation, matching how
                // ProgressiveText blurs completed sentences.
                BlurOverlay(
                  enabled: hasAnswered,
                  child: QuestionText(paragraphAlignment),
                ),

                const Spacing.height(RLDS.spacing16),

                // True/False button row
                ButtonRow(),

                const Spacing.height(RLDS.spacing16),

                // Explanation section
                ExplanationSection(paragraphAlignment),

                // Empty space below content also lifts the button blur on first
                // tap. Lets the reader unblur by tapping anywhere below the
                // statement, not just on a button.
                Expanded(child: BottomUnblurTapArea()),

                // Continue affordance. Delayed 1400ms after the correct answer
                // commits so the reader has a moment to absorb the result.
                CCContinueButton(visible: isContinueVisible),
              ],
            ),
          ),
        );
      },
    );
  }

  // Transparent fill below the explanation that, while the buttons are
  // still blurred, behaves as a synonym for tapping a button: first tap
  // clears the blur on both buttons. After the buttons are unblurred (or
  // the question is answered) it stays inert so it doesn't intercept
  // anything else.
  Widget BottomUnblurTapArea() {
    final bool shouldHandleTap =
        isStatementRevealed && !areButtonsUnblurred && !hasAnswered;

    if (!shouldHandleTap) {
      return const SizedBox.expand();
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: handleButtonsUnblur,
      child: const SizedBox.expand(),
    );
  }

  // Progressive reveal so the statement reads as part of the same typewriter
  // rhythm as other swipes. Single segment reserves full layout via a
  // transparent tail, so the buttons below never shift as chars type in.
  // Cadence matches text swipes (ProgressiveText's default delay).
  Widget QuestionText(TextAlign paragraphAlignment) {
    return ProgressiveText(
      textSegments: [widget.content.question],
      textStyle: RLTypography.readingLargeStyle,
      textAlign: paragraphAlignment,
      blurCompletedSentences: false,
      enableTapToReveal: false,
      onAllSegmentsRevealed: handleStatementRevealed,
    );
  }

  void handleStatementRevealed() {
    final bool canUpdateState = mounted;

    if (!canUpdateState) {
      return;
    }

    setState(() {
      isStatementRevealed = true;
    });
  }

  // Both buttons share a single BlurOverlay so the blur removal is always
  // synchronised, the reader never sees one button clear up before the
  // other. The blur lifts on the first tap on either button (see
  // getAnswerTapHandler), not when the statement finishes revealing.
  Widget ButtonRow() {
    final bool shouldBlurButtons = !areButtonsUnblurred;

    final Widget buttonRow = Div.row([
      // True button
      Expanded(
        child: AnswerButton(
          answerIndex: 0,
          label: RLUIStrings.TRUE_LABEL,
          baseColor: RLDS.info,
          icon: Pixel.check,
        ),
      ),

      const Spacing.width(RLDS.spacing16),

      // False button
      Expanded(
        child: AnswerButton(
          answerIndex: 1,
          label: RLUIStrings.FALSE_LABEL,
          baseColor: RLDS.error,
          icon: Pixel.close,
        ),
      ),
    ]);

    return BlurOverlay(
      enabled: shouldBlurButtons,
      child: buttonRow,
    );
  }

  Widget AnswerButton({
    required int answerIndex,
    required String label,
    required Color baseColor,
    required IconData icon,
  }) {
    final bool isSelected = selectedAnswerIndex == answerIndex;
    // correctAnswerIndex is 0-based, it's the index into content.options as
    // stored in the course JSON (`correct-answer-indices`). 0 = True, 1 = False.
    final bool isCorrect = widget.content.correctAnswerIndex == answerIndex;
    final bool shouldShowCorrect = hasAnswered && isCorrect;
    final bool shouldMute = hasAnswered && !isCorrect && !isSelected;

    final ButtonColors colors = getButtonColorsForState(
      shouldShowCorrect: shouldShowCorrect,
      isSelected: isSelected,
      shouldMute: shouldMute,
      baseColor: baseColor,
    );

    final Widget ButtonIcon = Icon(icon, color: colors.iconColor, size: RLDS.iconLarge);

    final VoidCallback? tapCallback = getAnswerTapHandler(answerIndex);

    return RLCard.subtle(
      padding: answerButtonPadding,
      onTap: tapCallback,
      child: Div.row([
        ButtonIcon,

        const Spacing.width(RLDS.spacing12),

        Flexible(child: RLTypography.bodyLarge(label, color: colors.textColor)),
      ], mainAxisAlignment: MainAxisAlignment.center),
    );
  }

  static const EdgeInsets answerButtonPadding = EdgeInsets.symmetric(
    vertical: RLDS.spacing16,
    horizontal: RLDS.spacing12,
  );

  VoidCallback? getAnswerTapHandler(int answerIndex) {
    if (hasAnswered) {
      return null;
    }

    // While the statement is still typing, taps are ignored, reader must
    // read the claim before interacting.
    if (!isStatementRevealed) {
      return null;
    }

    // First tap on a blurred button clears the blur on BOTH buttons at once
    // so the reader can read "True" and "False" together and then commit.
    if (!areButtonsUnblurred) {
      return handleButtonsUnblur;
    }

    return () => handleAnswerSelection(answerIndex);
  }

  void handleButtonsUnblur() {
    if (!mounted) {
      return;
    }

    SoundService.playRandomTextClick();

    setState(() {
      areButtonsUnblurred = true;
    });
  }

  Widget ExplanationSection(TextAlign paragraphAlignment) {
    final bool shouldShowExplanation = hasAnswered;

    return RenderIf.condition(
      shouldShowExplanation,
      ExplanationContent(paragraphAlignment),
    );
  }

  static const EdgeInsets explanationCardPadding = EdgeInsets.all(RLDS.spacing16);

  Widget ExplanationContent(TextAlign paragraphAlignment) {
    return Div.column([
      // Explanation text
      ProgressiveText(
        textSegments: [widget.content.explanation],
        textStyle: RLTypography.readingLargeStyle,
        textAlign: paragraphAlignment,
        blurCompletedSentences: false,
        enableTapToReveal: false,
      ),
    ]);
  }

  ButtonColors getButtonColorsForState({
    required bool shouldShowCorrect,
    required bool isSelected,
    required bool shouldMute,
    required Color baseColor,
  }) {
    if (shouldShowCorrect) {
      return ButtonColors(
        backgroundColor: RLDS.glass10(RLDS.success),
        borderColor: RLDS.success,
        textColor: RLDS.success,
        iconColor: RLDS.success,
      );
    }

    if (isSelected && !hasAnswered) {
      return ButtonColors(
        backgroundColor: RLDS.glass10(baseColor),
        borderColor: baseColor,
        textColor: baseColor,
        iconColor: baseColor,
      );
    }

    if (shouldMute) {
      return ButtonColors(
        backgroundColor: RLDS.backgroundLight,
        borderColor: RLDS.glass10(RLDS.textPrimary),
        textColor: RLDS.glass40(RLDS.textPrimary),
        iconColor: RLDS.glass40(RLDS.textPrimary),
      );
    }

    return ButtonColors(
      backgroundColor: RLDS.backgroundLight,
      borderColor: RLDS.glass15(RLDS.textPrimary),
      textColor: RLDS.textPrimary,
      iconColor: RLDS.glass70(RLDS.textPrimary),
    );
  }

  void handleAnswerSelection(int answerIndex) {
    if (hasAnswered) {
      return;
    }

    // correctAnswerIndex is 0-based, matches the options list directly.
    final bool isCorrect = widget.content.correctAnswerIndex == answerIndex;

    if (!isCorrect) {
      SoundService.playWrong();
      showIncorrectAnswerFeedback(answerIndex);
      return;
    }

    SoundService.playCorrectTrue();
    markQuestionAsAnswered(answerIndex);
    showCorrectAnswerFeedback(answerIndex);
    widget.onAnswerSelected(answerIndex, isCorrect);
  }

  void showIncorrectAnswerFeedback(int answerIndex) {
    final QuestionOption selectedOption = widget.content.options[answerIndex];
    final String consequenceMessage = getConsequenceMessage(selectedOption);

    FeedbackSnackBar.showWrongAnswer(context, hint: consequenceMessage);
  }

  String getConsequenceMessage(QuestionOption selectedOption) {
    if (selectedOption.consequenceMessage != null) {
      return selectedOption.consequenceMessage!;
    }

    if (widget.content.hint != null) {
      return widget.content.hint!;
    }

    return RLUIStrings.DEFAULT_WRONG_ANSWER_HINT;
  }

  void showCorrectAnswerFeedback(int answerIndex) {
    final QuestionOption selectedOption = widget.content.options[answerIndex];
    final String feedbackMessage = getFeedbackMessage(selectedOption);

    FeedbackSnackBar.showCorrectAnswer(context, explanation: feedbackMessage);
  }

  String getFeedbackMessage(QuestionOption selectedOption) {
    if (selectedOption.consequenceMessage != null) {
      return selectedOption.consequenceMessage!;
    }

    return widget.content.explanation;
  }

  void markQuestionAsAnswered(int selectedIndex) {
    setState(() {
      selectedAnswerIndex = selectedIndex;
      hasAnswered = true;
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
}
