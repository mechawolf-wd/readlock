// True/False question that tests whether the reader can identify fact from misconception
// Quick binary choice with animated feedback and an explanation reveal

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/models/CourseModel.dart';
import 'package:readlock/design_system/RLCard.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/utility_widgets/text_animation/ProgressiveText.dart';
import 'package:readlock/design_system/RLFeedbackSnackbar.dart';
import 'package:readlock/constants/RLUIStrings.dart';

import 'package:pixelarticons/pixel.dart';
enum TrueFalseButtonState { normal, selected, correctAndAnswered, incorrectAndMuted }

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

  @override
  Widget build(BuildContext context) {
    return Div.column(
      [
        // Question text
        QuestionText(),

        const Spacing.height(24),

        // True/False button row
        ButtonRow(),

        const Spacing.height(24),

        // Explanation section
        ExplanationSection(),
      ],
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.start,
      padding: 24,
      color: RLDS.backgroundDark,
    );
  }

  Widget QuestionText() {
    return RLTypography.readingLarge(widget.content.question, textAlign: TextAlign.center);
  }

  Widget ButtonRow() {
    return Div.row([
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
  }

  Widget AnswerButton({
    required int answerIndex,
    required String label,
    required Color baseColor,
    required IconData icon,
  }) {
    final bool isSelected = selectedAnswerIndex == answerIndex;
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
      borderColor: colors.borderColor,
      padding: answerButtonPadding,
      onTap: tapCallback,
      child: Div.row(
        [
          ButtonIcon,

          const Spacing.width(12),

          Flexible(child: RLTypography.bodyLarge(label, color: colors.textColor)),
        ],
        mainAxisAlignment: MainAxisAlignment.center,
      ),
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

    return () => handleAnswerSelection(answerIndex);
  }

  Widget ExplanationSection() {
    final bool shouldShowExplanation = hasAnswered;

    return RenderIf.condition(shouldShowExplanation, ExplanationContent());
  }

  static const EdgeInsets explanationCardPadding = EdgeInsets.all(RLDS.spacing16);

  Widget ExplanationContent() {
    final Widget LightbulbIcon = Icon(
      Pixel.infobox,
      color: RLDS.textPrimary.withValues(alpha: 0.6),
      size: RLDS.iconMedium,
    );

    return RLCard.subtle(
      padding: explanationCardPadding,
      child: Div.column(
        [
          // Header row
          Div.row([
            LightbulbIcon,

            const Spacing.width(8),

            RLTypography.bodyMedium(
              RLUIStrings.EXPLANATION_LABEL,
              color: RLDS.textPrimary.withValues(alpha: 0.8),
            ),
          ]),

          const Spacing.height(12),

          // Explanation text
          ProgressiveText(
            textSegments: [widget.content.explanation],
            textStyle: RLTypography.readingMediumStyle,
            blurCompletedSentences: false,
            enableTapToReveal: false,
          ),
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );
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
