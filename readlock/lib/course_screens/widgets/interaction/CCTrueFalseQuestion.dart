import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/RLConstants.dart';
import 'package:readlock/course_screens/models/courseModel.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLTheme.dart';
import 'package:readlock/utility_widgets/text_animation/ProgressiveText.dart';
import 'package:readlock/utility_widgets/FeedbackSnackbar.dart';

enum TrueFalseButtonState {
  normal,
  selected,
  correctAndAnswered,
  incorrectAndMuted,
}

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

const double TRUE_FALSE_BUTTON_HEIGHT = 60.0;
const double TRUE_FALSE_BUTTON_SPACING = 16.0;
const double TRUE_FALSE_SECTION_SPACING = 24.0;
const double TRUE_FALSE_ICON_SIZE = 24.0;

class CCTrueFalseQuestion extends StatefulWidget {
  final QuestionContent content;
  final void Function(int selectedIndex, bool isCorrect)
  onAnswerSelected;

  const CCTrueFalseQuestion({
    super.key,
    required this.content,
    required this.onAnswerSelected,
  });

  @override
  State<CCTrueFalseQuestion> createState() =>
      CCTrueFalseQuestionState();
}

class CCTrueFalseQuestionState extends State<CCTrueFalseQuestion> {
  int? selectedAnswerIndex;
  bool hasAnswered = false;

  @override
  Widget build(BuildContext context) {
    final BoxDecoration correctButtonDecoration = BoxDecoration(
      border: Border.all(color: RLTheme.primaryGreen, width: 2),
      borderRadius: BorderRadius.circular(12),
    );

    final BoxDecoration selectedTrueDecoration = BoxDecoration(
      border: Border.all(color: RLTheme.primaryBlue, width: 2),
      borderRadius: BorderRadius.circular(12),
    );

    final BoxDecoration selectedFalseDecoration = BoxDecoration(
      border: Border.all(color: Colors.red.shade600, width: 2),
      borderRadius: BorderRadius.circular(12),
    );

    final BoxDecoration mutedDecoration = BoxDecoration(
      border: Border.all(
        color: RLTheme.textPrimary.withValues(alpha: 0.1),
        width: 2,
      ),
      borderRadius: BorderRadius.circular(12),
    );

    final BoxDecoration normalDecoration = BoxDecoration(
      border: Border.all(
        color: RLTheme.textPrimary.withValues(alpha: 0.2),
        width: 2,
      ),
      borderRadius: BorderRadius.circular(12),
    );

    final Widget CheckIcon = const Icon(
      Icons.check_circle_outline,
      size: TRUE_FALSE_ICON_SIZE,
    );

    final Widget CancelIcon = const Icon(
      Icons.cancel_outlined,
      size: TRUE_FALSE_ICON_SIZE,
    );

    return Div.column(
      [
        // Question text
        questionTextWidget(),

        const Spacing.height(TRUE_FALSE_SECTION_SPACING),

        // True button
        trueButtonWidget(
          CheckIcon,
          correctButtonDecoration,
          selectedTrueDecoration,
          mutedDecoration,
          normalDecoration,
        ),

        const Spacing.height(TRUE_FALSE_BUTTON_SPACING),

        // False button
        falseButtonWidget(
          CancelIcon,
          correctButtonDecoration,
          selectedFalseDecoration,
          mutedDecoration,
          normalDecoration,
        ),

        const Spacing.height(TRUE_FALSE_SECTION_SPACING),

        // Explanation section
        explanationSectionWidget(),
      ],
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      padding: RLConstants.COURSE_SECTION_PADDING,
      color: RLTheme.backgroundDark,
    );
  }

  Widget questionTextWidget() {
    final TextStyle questionStyle = RLTypography.bodyLargeStyle
        .copyWith(fontWeight: FontWeight.w500, fontSize: 18);

    return Text(
      widget.content.question,
      style: questionStyle,
      textAlign: TextAlign.center,
    );
  }

  Widget trueButtonWidget(
    Widget checkIcon,
    BoxDecoration correctDecoration,
    BoxDecoration selectedDecoration,
    BoxDecoration mutedDecoration,
    BoxDecoration normalDecoration,
  ) {
    const int trueIndex = 0;
    final bool isSelected = selectedAnswerIndex == trueIndex;
    final bool isCorrect = widget.content.correctAnswerIndices.contains(
      trueIndex,
    );
    final bool shouldShowCorrect = hasAnswered && isCorrect;
    final bool shouldMute = hasAnswered && !isCorrect && !isSelected;

    final ButtonColors colors = getButtonColorsForState(
      shouldShowCorrect: shouldShowCorrect,
      isSelected: isSelected,
      shouldMute: shouldMute,
      baseColor: RLTheme.primaryBlue,
    );

    final BoxDecoration decoration = getDecorationForState(
      shouldShowCorrect: shouldShowCorrect,
      isSelected: isSelected,
      shouldMute: shouldMute,
      correctDecoration: correctDecoration,
      selectedDecoration: selectedDecoration,
      mutedDecoration: mutedDecoration,
      normalDecoration: normalDecoration,
    );

    final TextStyle textStyle = RLTypography.bodyLargeStyle.copyWith(
      color: colors.textColor,
      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      fontSize: 16,
    );

    return Div.row(
      [
        Icon(
          Icons.check_circle_outline,
          color: colors.iconColor,
          size: TRUE_FALSE_ICON_SIZE,
        ),

        const Spacing.width(12),

        Text('True', style: textStyle),
      ],
      height: TRUE_FALSE_BUTTON_HEIGHT,
      decoration: decoration.copyWith(color: colors.backgroundColor),
      radius: BorderRadius.circular(12),
      mainAxisAlignment: MainAxisAlignment.center,
      onTap: hasAnswered
          ? null
          : () => handleAnswerSelection(trueIndex),
    );
  }

  Widget falseButtonWidget(
    Widget cancelIcon,
    BoxDecoration correctDecoration,
    BoxDecoration selectedDecoration,
    BoxDecoration mutedDecoration,
    BoxDecoration normalDecoration,
  ) {
    const int falseIndex = 1;
    final bool isSelected = selectedAnswerIndex == falseIndex;
    final bool isCorrect = widget.content.correctAnswerIndices.contains(
      falseIndex,
    );
    final bool shouldShowCorrect = hasAnswered && isCorrect;
    final bool shouldMute = hasAnswered && !isCorrect && !isSelected;

    final ButtonColors colors = getButtonColorsForState(
      shouldShowCorrect: shouldShowCorrect,
      isSelected: isSelected,
      shouldMute: shouldMute,
      baseColor: Colors.red.shade600,
    );

    final BoxDecoration decoration = getDecorationForState(
      shouldShowCorrect: shouldShowCorrect,
      isSelected: isSelected,
      shouldMute: shouldMute,
      correctDecoration: correctDecoration,
      selectedDecoration: selectedDecoration,
      mutedDecoration: mutedDecoration,
      normalDecoration: normalDecoration,
    );

    final TextStyle textStyle = RLTypography.bodyLargeStyle.copyWith(
      color: colors.textColor,
      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      fontSize: 16,
    );

    return Div.row(
      [
        Icon(
          Icons.cancel_outlined,
          color: colors.iconColor,
          size: TRUE_FALSE_ICON_SIZE,
        ),

        const Spacing.width(12),

        Text('False', style: textStyle),
      ],
      height: TRUE_FALSE_BUTTON_HEIGHT,
      decoration: decoration.copyWith(color: colors.backgroundColor),
      radius: BorderRadius.circular(12),
      mainAxisAlignment: MainAxisAlignment.center,
      onTap: hasAnswered
          ? null
          : () => handleAnswerSelection(falseIndex),
    );
  }

  Widget explanationSectionWidget() {
    final bool shouldShowExplanation = hasAnswered;

    if (!shouldShowExplanation) {
      return const SizedBox.shrink();
    }

    final TextStyle headerStyle = RLTypography.bodyLargeStyle.copyWith(
      fontWeight: FontWeight.w600,
      fontSize: 14,
      color: RLTheme.textPrimary.withValues(alpha: 0.8),
    );

    final TextStyle explanationStyle = RLTypography.bodyLargeStyle
        .copyWith(fontSize: 14, height: 1.5);

    final Widget LightbulbIcon = Icon(
      Icons.lightbulb_outline,
      color: RLTheme.textPrimary.withValues(alpha: 0.6),
      size: 20,
    );

    return Div.column(
      [
        // Header row
        Div.row([
          LightbulbIcon,

          const Spacing.width(8),

          Text('Explanation', style: headerStyle),
        ]),

        const Spacing.height(12),

        // Explanation text
        ProgressiveText(
          textSegments: [widget.content.explanation],
          textStyle: explanationStyle,
        ),
      ],
      crossAxisAlignment: CrossAxisAlignment.start,
      padding: 16,
      color: RLTheme.backgroundLight,
      radius: 12,
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
        backgroundColor: RLTheme.primaryGreen.withValues(alpha: 0.1),
        borderColor: RLTheme.primaryGreen,
        textColor: RLTheme.primaryGreen,
        iconColor: RLTheme.primaryGreen,
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
        backgroundColor: RLTheme.backgroundLight,
        borderColor: RLTheme.textPrimary.withValues(alpha: 0.1),
        textColor: RLTheme.textPrimary.withValues(alpha: 0.4),
        iconColor: RLTheme.textPrimary.withValues(alpha: 0.4),
      );
    }

    return ButtonColors(
      backgroundColor: RLTheme.backgroundLight,
      borderColor: RLTheme.textPrimary.withValues(alpha: 0.2),
      textColor: RLTheme.textPrimary,
      iconColor: RLTheme.textPrimary.withValues(alpha: 0.6),
    );
  }

  BoxDecoration getDecorationForState({
    required bool shouldShowCorrect,
    required bool isSelected,
    required bool shouldMute,
    required BoxDecoration correctDecoration,
    required BoxDecoration selectedDecoration,
    required BoxDecoration mutedDecoration,
    required BoxDecoration normalDecoration,
  }) {
    if (shouldShowCorrect) {
      return correctDecoration;
    }

    if (isSelected && !hasAnswered) {
      return selectedDecoration;
    }

    if (shouldMute) {
      return mutedDecoration;
    }

    return normalDecoration;
  }

  void handleAnswerSelection(int answerIndex) {
    if (hasAnswered) {
      return;
    }

    final bool isCorrect = widget.content.correctAnswerIndices.contains(
      answerIndex,
    );

    setState(() {
      selectedAnswerIndex = answerIndex;
      hasAnswered = true;
    });

    widget.onAnswerSelected(answerIndex, isCorrect);

    // Show feedback snackbar
    if (mounted) {
      if (isCorrect) {
        FeedbackSnackBar.showCorrectAnswer(
          context,
          explanation: widget.content.explanation,
        );
      } else {
        FeedbackSnackBar.showWrongAnswer(
          context,
          hint: widget.content.hint,
        );
      }
    }
  }
}
