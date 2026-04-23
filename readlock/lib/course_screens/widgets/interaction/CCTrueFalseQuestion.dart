// True/False question that tests whether the reader can identify fact from misconception
// Quick binary choice with animated feedback and an explanation reveal

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/models/CourseModel.dart';
import 'package:readlock/design_system/RLCard.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/utility_widgets/text_animation/ProgressiveText.dart';
import 'package:readlock/utility_widgets/visual_effects/BlurOverlay.dart';
import 'package:readlock/design_system/RLFeedbackSnackbar.dart';
import 'package:readlock/constants/RLUIStrings.dart';

import 'package:pixelarticons/pixel.dart';

enum TrueFalseButtonState { normal, selected, correctAndAnswered, incorrectAndMuted }

// Covered-button blur comes directly from BlurOverlay's defaults, which
// consume RLDS.lyricsBlur*. No per-file constants — one token, one place.

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
  bool isStatementRevealed = false;
  // Blur stays on both buttons until the reader taps one of them. The first
  // tap only removes the blur (for BOTH buttons together — never one at a
  // time). A second tap on either button commits the answer.
  bool areButtonsUnblurred = false;

  @override
  Widget build(BuildContext context) {
    return Div.column(
      [
        // Question text
        QuestionText(),

        const Spacing.height(RLDS.spacing16),

        // True/False button row
        ButtonRow(),

        const Spacing.height(RLDS.spacing16),

        // Explanation section
        ExplanationSection(),
      ],
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.start,
      padding: RLDS.spacing24,
    );
  }

  // Progressive reveal so the statement reads as part of the same typewriter
  // rhythm as other swipes. Single segment reserves full layout via a
  // transparent tail, so the buttons below never shift as chars type in.
  // Cadence matches text swipes (ProgressiveText's default delay).
  Widget QuestionText() {
    return ProgressiveText(
      textSegments: [widget.content.question],
      textStyle: RLTypography.readingLargeStyle,
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
  // synchronised — the reader never sees one button clear up before the
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
    // correctAnswerIndex is 0-based — it's the index into content.options as
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

    // While the statement is still typing, taps are ignored — reader must
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

    setState(() {
      areButtonsUnblurred = true;
    });
  }

  Widget ExplanationSection() {
    final bool shouldShowExplanation = hasAnswered;

    return RenderIf.condition(shouldShowExplanation, ExplanationContent());
  }

  static const EdgeInsets explanationCardPadding = EdgeInsets.all(RLDS.spacing16);

  Widget ExplanationContent() {
    return Div.column([
      // Explanation text
      ProgressiveText(
        textSegments: [widget.content.explanation],
        textStyle: RLTypography.readingLargeStyle,
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
        backgroundColor: RLDS.success.withValues(alpha: 0.1),
        borderColor: RLDS.success,
        textColor: RLDS.success,
        iconColor: RLDS.success,
      );
    }

    if (isSelected && !hasAnswered) {
      return ButtonColors(
        backgroundColor: baseColor.withValues(alpha: 0.1),
        borderColor: baseColor,
        textColor: baseColor,
        iconColor: baseColor,
      );
    }

    if (shouldMute) {
      return ButtonColors(
        backgroundColor: RLDS.backgroundLight,
        borderColor: RLDS.textPrimary.withValues(alpha: 0.1),
        textColor: RLDS.textPrimary.withValues(alpha: 0.4),
        iconColor: RLDS.textPrimary.withValues(alpha: 0.4),
      );
    }

    return ButtonColors(
      backgroundColor: RLDS.backgroundLight,
      borderColor: RLDS.textPrimary.withValues(alpha: 0.2),
      textColor: RLDS.textPrimary,
      iconColor: RLDS.textPrimary.withValues(alpha: 0.6),
    );
  }

  void handleAnswerSelection(int answerIndex) {
    if (hasAnswered) {
      return;
    }

    // correctAnswerIndex is 0-based — matches the options list directly.
    final bool isCorrect = widget.content.correctAnswerIndex == answerIndex;

    if (!isCorrect) {
      showIncorrectAnswerFeedback(answerIndex);
      return;
    }

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
  }
}
