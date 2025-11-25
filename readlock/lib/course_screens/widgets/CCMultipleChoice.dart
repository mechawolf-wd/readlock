import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/constants.dart';
import 'package:readlock/course_screens/models/courseModel.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/typography.dart';
import 'package:readlock/constants/appTheme.dart';
import 'package:readlock/utility_widgets/FeedbackSnackbar.dart';

enum OptionButtonState {
  normal,
  selected,
  correctAndAnswered,
  incorrectAndAnswered
}

const double OPTION_BUTTON_SPACING = 16.0;
const double QUESTION_SECTION_SPACING = 24.0;

class MultipleChoiceWidget extends StatefulWidget {
  final QuestionContent content;
  final void Function(int selectedIndex, bool isCorrect) onAnswerSelected;

  const MultipleChoiceWidget({
    super.key,
    required this.content,
    required this.onAnswerSelected,
  });

  @override
  State<MultipleChoiceWidget> createState() => MultipleChoiceWidgetState();
}

class MultipleChoiceWidgetState extends State<MultipleChoiceWidget> {
  int? selectedAnswerIndex;
  bool hasAnsweredQuestion = false;

  @override
  Widget build(BuildContext context) {
    final BoxDecoration normalOptionDecoration = BoxDecoration(
      color: AppTheme.backgroundLight,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: AppTheme.textPrimary.withValues(alpha: 0.2),
        width: 2,
      ),
    );

    final BoxDecoration selectedOptionDecoration = BoxDecoration(
      color: AppTheme.backgroundLight,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: AppTheme.primaryBlue,
        width: 2,
      ),
    );

    final BoxDecoration correctOptionDecoration = BoxDecoration(
      color: AppTheme.primaryGreen.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: AppTheme.primaryGreen,
        width: 2,
      ),
    );

    final BoxDecoration incorrectOptionDecoration = BoxDecoration(
      color: AppTheme.backgroundLight,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: AppTheme.textPrimary.withValues(alpha: 0.1),
        width: 2,
      ),
    );

    return Div.column(
      [
        // Question text
        questionTextWidget(),

        const Spacing.height(QUESTION_SECTION_SPACING),

        // Options list
        optionListWidget(
          normalOptionDecoration,
          selectedOptionDecoration,
          correctOptionDecoration,
          incorrectOptionDecoration,
        ),

        const Spacing.height(QUESTION_SECTION_SPACING),
      ],
      color: AppTheme.backgroundDark,
      padding: Constants.COURSE_SECTION_PADDING,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }

  Widget questionTextWidget() {
    return Typography.bodyLarge(widget.content.question);
  }

  Widget optionListWidget(
    BoxDecoration normalDecoration,
    BoxDecoration selectedDecoration,
    BoxDecoration correctDecoration,
    BoxDecoration incorrectDecoration,
  ) {
    final List<Widget> optionWidgets = widget.content.options
        .asMap()
        .entries
        .map((entry) {
          final int optionIndex = entry.key;
          final QuestionOption option = entry.value;

          return Div.column([
            optionButtonWidget(
              optionIndex,
              option,
              normalDecoration,
              selectedDecoration,
              correctDecoration,
              incorrectDecoration,
            ),

            const Spacing.height(OPTION_BUTTON_SPACING),
          ]);
        })
        .toList();

    return Div.column(optionWidgets);
  }

  Widget optionButtonWidget(
    int optionIndex,
    QuestionOption option,
    BoxDecoration normalDecoration,
    BoxDecoration selectedDecoration,
    BoxDecoration correctDecoration,
    BoxDecoration incorrectDecoration,
  ) {
    final bool isSelected = selectedAnswerIndex == optionIndex;
    final bool isCorrectAnswer = widget.content.correctAnswerIndices.contains(optionIndex);
    final bool shouldShowCorrect = hasAnsweredQuestion && isCorrectAnswer;
    final bool shouldShowIncorrect = hasAnsweredQuestion && !isCorrectAnswer && isSelected;
    final bool shouldMute = hasAnsweredQuestion && !isCorrectAnswer && !isSelected;

    final BoxDecoration decoration = getOptionDecoration(
      isSelected: isSelected,
      shouldShowCorrect: shouldShowCorrect,
      shouldShowIncorrect: shouldShowIncorrect,
      shouldMute: shouldMute,
      normalDecoration: normalDecoration,
      selectedDecoration: selectedDecoration,
      correctDecoration: correctDecoration,
      incorrectDecoration: incorrectDecoration,
    );

    final TextStyle textStyle = getOptionTextStyle(
      isSelected: isSelected,
      shouldShowCorrect: shouldShowCorrect,
      shouldShowIncorrect: shouldShowIncorrect,
      shouldMute: shouldMute,
    );

    return Div.row(
      [
        Expanded(
          child: Text(
            option.text,
            style: textStyle,
          ),
        ),
      ],
      padding: AppTheme.contentPaddingMediumInsets,
      decoration: decoration,
      onTap: hasAnsweredQuestion ? null : () => handleOptionSelection(optionIndex),
    );
  }

  BoxDecoration getOptionDecoration({
    required bool isSelected,
    required bool shouldShowCorrect,
    required bool shouldShowIncorrect,
    required bool shouldMute,
    required BoxDecoration normalDecoration,
    required BoxDecoration selectedDecoration,
    required BoxDecoration correctDecoration,
    required BoxDecoration incorrectDecoration,
  }) {
    if (shouldShowCorrect) {
      return correctDecoration;
    }

    if (shouldShowIncorrect || shouldMute) {
      return incorrectDecoration;
    }

    if (isSelected && !hasAnsweredQuestion) {
      return selectedDecoration;
    }

    return normalDecoration;
  }

  TextStyle getOptionTextStyle({
    required bool isSelected,
    required bool shouldShowCorrect,
    required bool shouldShowIncorrect,
    required bool shouldMute,
  }) {
    Color textColor = AppTheme.textPrimary;
    FontWeight fontWeight = FontWeight.normal;

    if (shouldShowCorrect) {
      textColor = AppTheme.primaryGreen;
      fontWeight = FontWeight.w500;
    } else if (shouldShowIncorrect) {
      textColor = AppTheme.textPrimary.withValues(alpha: 0.5);
    } else if (shouldMute) {
      textColor = AppTheme.textPrimary.withValues(alpha: 0.3);
    } else if (isSelected && !hasAnsweredQuestion) {
      fontWeight = FontWeight.w500;
    }

    return Typography.bodyLargeStyle.copyWith(
      fontSize: 14,
      color: textColor,
      fontWeight: fontWeight,
    );
  }

  void handleOptionSelection(int optionIndex) {
    final bool isCorrectAnswer = widget.content.correctAnswerIndices.contains(optionIndex);

    if (!isCorrectAnswer && !hasAnsweredQuestion) {
      showIncorrectAnswerFeedback();
      return;
    }

    if (isCorrectAnswer && !hasAnsweredQuestion) {
      setState(() {
        selectedAnswerIndex = optionIndex;
        hasAnsweredQuestion = true;
      });

      widget.onAnswerSelected(optionIndex, isCorrectAnswer);

      if (mounted) {
        FeedbackSnackBar.showCorrectAnswer(
          context,
          explanation: widget.content.explanation,
        );
      }
    }
  }

  void showIncorrectAnswerFeedback() {
    FeedbackSnackBar.showWrongAnswer(
      context,
      hint: widget.content.hint,
    );
  }

}