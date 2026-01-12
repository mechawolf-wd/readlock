import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/models/CourseModel.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLTheme.dart';
import 'package:readlock/utility_widgets/FeedbackSnackbar.dart';

enum OptionButtonState {
  normal,
  selected,
  correctAndAnswered,
  incorrectAndAnswered,
}

const double OPTION_BUTTON_SPACING = 16.0;
const double QUESTION_SECTION_SPACING = 24.0;

class CCMultipleChoice extends StatefulWidget {
  final QuestionContent content;
  final void Function(int selectedIndex, bool isCorrect)
  onAnswerSelected;

  const CCMultipleChoice({
    super.key,
    required this.content,
    required this.onAnswerSelected,
  });

  @override
  State<CCMultipleChoice> createState() => CCMultipleChoiceState();
}

class CCMultipleChoiceState extends State<CCMultipleChoice> {
  int? selectedAnswerIndex;
  bool hasAnsweredQuestion = false;

  // Style definitions
  late final BoxDecoration normalOptionDecoration;
  late final BoxDecoration selectedOptionDecoration;
  late final BoxDecoration correctOptionDecoration;
  late final BoxDecoration incorrectOptionDecoration;

  @override
  void initState() {
    super.initState();
    initializeStyles();
  }

  void initializeStyles() {
    normalOptionDecoration = BoxDecoration(
      color: RLTheme.backgroundLight,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: RLTheme.textPrimary.withValues(alpha: 0.2),
        width: 2,
      ),
    );

    selectedOptionDecoration = BoxDecoration(
      color: RLTheme.backgroundLight,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: RLTheme.primaryBlue, width: 2),
    );

    correctOptionDecoration = BoxDecoration(
      color: RLTheme.primaryGreen.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: RLTheme.primaryGreen, width: 2),
    );

    incorrectOptionDecoration = BoxDecoration(
      color: RLTheme.backgroundLight,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: RLTheme.textPrimary.withValues(alpha: 0.1),
        width: 2,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Div.column(
      [
        // Question text section
        QuestionTextSection(),

        const Spacing.height(QUESTION_SECTION_SPACING),

        // Multiple choice options
        OptionsListSection(),

        const Spacing.height(QUESTION_SECTION_SPACING),
      ],
      color: RLTheme.backgroundDark,
      padding: 24,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }

  Widget QuestionTextSection() {
    return RLTypography.bodyLarge(widget.content.question);
  }

  Widget OptionsListSection() {
    return Div.column(getOptionWidgetsList());
  }

  List<Widget> getOptionWidgetsList() {
    return widget.content.options.asMap().entries.map((entry) {
      final int optionIndex = entry.key;
      final QuestionOption option = entry.value;

      return Div.column([
        OptionButtonWidget(optionIndex: optionIndex, option: option),

        const Spacing.height(OPTION_BUTTON_SPACING),
      ]);
    }).toList();
  }

  Widget OptionButtonWidget({
    required int optionIndex,
    required QuestionOption option,
  }) {
    final bool isSelected = selectedAnswerIndex == optionIndex;
    final bool isCorrectAnswer = widget.content.correctAnswerIndices
        .contains(optionIndex);
    final bool shouldShowCorrect =
        hasAnsweredQuestion && isCorrectAnswer;
    final bool shouldShowIncorrect =
        hasAnsweredQuestion && !isCorrectAnswer && isSelected;
    final bool shouldMute =
        hasAnsweredQuestion && !isCorrectAnswer && !isSelected;

    final BoxDecoration decoration = getOptionButtonDecoration(
      isSelected: isSelected,
      shouldShowCorrect: shouldShowCorrect,
      shouldShowIncorrect: shouldShowIncorrect,
      shouldMute: shouldMute,
    );

    final TextStyle textStyle = getOptionButtonTextStyle(
      isSelected: isSelected,
      shouldShowCorrect: shouldShowCorrect,
      shouldShowIncorrect: shouldShowIncorrect,
      shouldMute: shouldMute,
    );

    return Div.row(
      [Expanded(child: Text(option.text, style: textStyle))],
      padding: RLTheme.contentPaddingMediumInsets,
      decoration: decoration,
      onTap: hasAnsweredQuestion
          ? null
          : () => handleOptionSelection(optionIndex),
    );
  }

  BoxDecoration getOptionButtonDecoration({
    required bool isSelected,
    required bool shouldShowCorrect,
    required bool shouldShowIncorrect,
    required bool shouldMute,
  }) {
    if (shouldShowCorrect) {
      return correctOptionDecoration;
    }

    if (shouldShowIncorrect || shouldMute) {
      return incorrectOptionDecoration;
    }

    if (isSelected && !hasAnsweredQuestion) {
      return selectedOptionDecoration;
    }

    return normalOptionDecoration;
  }

  TextStyle getOptionButtonTextStyle({
    required bool isSelected,
    required bool shouldShowCorrect,
    required bool shouldShowIncorrect,
    required bool shouldMute,
  }) {
    Color textColor = RLTheme.textPrimary;
    FontWeight fontWeight = FontWeight.normal;

    if (shouldShowCorrect) {
      textColor = RLTheme.primaryGreen;
      fontWeight = FontWeight.w500;
    } else if (shouldShowIncorrect) {
      textColor = RLTheme.textPrimary.withValues(alpha: 0.5);
    } else if (shouldMute) {
      textColor = RLTheme.textPrimary.withValues(alpha: 0.3);
    } else if (isSelected && !hasAnsweredQuestion) {
      fontWeight = FontWeight.w500;
    }

    return RLTypography.bodyLargeStyle.copyWith(
      fontSize: 14,
      color: textColor,
      fontWeight: fontWeight,
    );
  }

  void handleOptionSelection(int optionIndex) {
    final bool isCorrectAnswer = widget.content.correctAnswerIndices
        .contains(optionIndex);

    if (!isCorrectAnswer && !hasAnsweredQuestion) {
      showIncorrectAnswerFeedback();
      return;
    }

    if (isCorrectAnswer && !hasAnsweredQuestion) {
      updateSelectedAnswer(optionIndex);

      notifyAnswerSelected(optionIndex, isCorrectAnswer);

      showCorrectAnswerFeedback();
    }
  }

  void updateSelectedAnswer(int optionIndex) {
    setState(() {
      selectedAnswerIndex = optionIndex;
      hasAnsweredQuestion = true;
    });
  }

  void notifyAnswerSelected(int optionIndex, bool isCorrect) {
    widget.onAnswerSelected(optionIndex, isCorrect);
  }

  void showCorrectAnswerFeedback() {
    if (mounted) {
      FeedbackSnackBar.showCorrectAnswer(
        context,
        explanation: widget.content.explanation,
      );
    }
  }

  void showIncorrectAnswerFeedback() {
    FeedbackSnackBar.showWrongAnswer(
      context,
      hint: widget.content.hint,
    );
  }
}
