// Multiple-choice question where the reader selects one or more correct answers
// Tests comprehension after a reading section — wrong answers show hints, correct ones show explanations

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/models/CourseModel.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/utility_widgets/FeedbackSnackbar.dart';

class CCMultipleChoice extends StatefulWidget {
  final MultipleChoiceQuestionContent content;
  final void Function(int selectedIndex, bool isCorrect) onAnswerSelected;

  const CCMultipleChoice({super.key, required this.content, required this.onAnswerSelected});

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
      color: RLDS.backgroundLight,
      borderRadius: RLDS.borderRadiusSmall,
      border: Border.all(color: RLDS.textPrimary.withValues(alpha: 0.2), width: 2),
    );

    selectedOptionDecoration = BoxDecoration(
      color: RLDS.backgroundLight,
      borderRadius: RLDS.borderRadiusSmall,
      border: Border.all(color: RLDS.primaryBlue, width: 2),
    );

    correctOptionDecoration = BoxDecoration(
      color: RLDS.primaryGreen.withValues(alpha: 0.1),
      borderRadius: RLDS.borderRadiusSmall,
      border: Border.all(color: RLDS.primaryGreen, width: 2),
    );

    incorrectOptionDecoration = BoxDecoration(
      color: RLDS.backgroundLight,
      borderRadius: RLDS.borderRadiusSmall,
      border: Border.all(color: RLDS.textPrimary.withValues(alpha: 0.1), width: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Div.column(
      [
        // Question text section
        QuestionTextSection(),

        const Spacing.height(24),

        // Multiple choice options
        OptionsListSection(),

        const Spacing.height(24),
      ],
      color: RLDS.backgroundDark,
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
    final List<Widget> optionWidgets = [];

    for (int optionIndex = 0; optionIndex < widget.content.options.length; optionIndex++) {
      final QuestionOption option = widget.content.options[optionIndex];

      optionWidgets.add(OptionButton(optionIndex: optionIndex, option: option));

      final bool isLastOption = optionIndex == widget.content.options.length - 1;

      if (!isLastOption) {
        optionWidgets.add(const Spacing.height(16));
      }
    }

    return optionWidgets;
  }

  Widget OptionButton({required int optionIndex, required QuestionOption option}) {
    final bool isSelected = selectedAnswerIndex == optionIndex;
    final bool isCorrectAnswer = widget.content.correctAnswerIndices.contains(optionIndex);
    final bool shouldShowCorrect = hasAnsweredQuestion && isCorrectAnswer;
    final bool shouldShowIncorrect = hasAnsweredQuestion && !isCorrectAnswer && isSelected;
    final bool shouldMute = hasAnsweredQuestion && !isCorrectAnswer && !isSelected;

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

    VoidCallback? optionTapHandler;

    if (!hasAnsweredQuestion) {
      optionTapHandler = () => handleOptionSelection(optionIndex);
    }

    return Div.row(
      [Expanded(child: RLTypography.bodyMedium(option.text, color: textStyle.color))],
      padding: RLDS.contentPaddingMediumInsets,
      decoration: decoration,
      onTap: optionTapHandler,
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

    final bool isSelectedBeforeAnswer = isSelected && !hasAnsweredQuestion;

    if (isSelectedBeforeAnswer) {
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
    Color textColor = RLDS.textPrimary;
    FontWeight fontWeight = FontWeight.normal;

    if (shouldShowCorrect) {
      textColor = RLDS.primaryGreen;
      fontWeight = FontWeight.w500;
    } else if (shouldShowIncorrect) {
      textColor = RLDS.textPrimary.withValues(alpha: 0.5);
    } else if (shouldMute) {
      textColor = RLDS.textPrimary.withValues(alpha: 0.3);
    } else if (isSelected && !hasAnsweredQuestion) {
      fontWeight = FontWeight.w500;
    }

    return RLTypography.bodyMediumStyle.copyWith(color: textColor, fontWeight: fontWeight);
  }

  void handleOptionSelection(int optionIndex) {
    final bool isCorrectAnswer = widget.content.correctAnswerIndices.contains(optionIndex);

    final bool isWrongAnswerAttempt = !isCorrectAnswer && !hasAnsweredQuestion;

    if (isWrongAnswerAttempt) {
      showIncorrectAnswerFeedback();
      return;
    }

    final bool isCorrectAnswerAttempt = isCorrectAnswer && !hasAnsweredQuestion;

    if (isCorrectAnswerAttempt) {
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
      FeedbackSnackBar.showCorrectAnswer(context, explanation: widget.content.explanation);
    }
  }

  void showIncorrectAnswerFeedback() {
    FeedbackSnackBar.showWrongAnswer(context, hint: widget.content.hint);
  }
}
