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

// * Matches CCQuestion's answer-blur defaults so true/false buttons read as
// the same kind of "covered" as the multi-choice options.
const double TRUE_FALSE_BUTTON_BLUR_SIGMA = 4.0;
const double TRUE_FALSE_BUTTON_BLUR_OPACITY = 0.2;

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
      padding: 24,
      color: RLDS.backgroundDark,
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

  // Buttons stay blurred until the statement finishes revealing — the reader
  // commits to an answer only after they've read the claim, mirroring how
  // CCQuestion's multi-choice options are covered until tapped.
  Widget ButtonRow() {
    final bool shouldBlurButtons = !isStatementRevealed;

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

      const Spacing.width(16),

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
      blurSigma: TRUE_FALSE_BUTTON_BLUR_SIGMA,
      opacity: TRUE_FALSE_BUTTON_BLUR_OPACITY,
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
    // correctAnswerIndex is 1-based on the data (1 = first answer / true).
    final bool isCorrect = widget.content.correctAnswerIndex == answerIndex + 1;
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

        const Spacing.width(12),

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

    // Buttons are blurred + non-tappable until the statement finishes
    // revealing — forces the reader through the typewriter before they can
    // commit.
    if (!isStatementRevealed) {
      return null;
    }

    return () => handleAnswerSelection(answerIndex);
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

    // correctAnswerIndex is 1-based on the data (1 = first answer / true).
    final bool isCorrect = widget.content.correctAnswerIndex == answerIndex + 1;

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
