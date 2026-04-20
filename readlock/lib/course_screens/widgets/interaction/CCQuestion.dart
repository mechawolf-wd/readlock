// Single-choice question where the reader picks exactly one answer
// Used as a quick comprehension check — shows consequence messages for each choice

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/models/CourseModel.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/design_system/RLFeedbackSnackbar.dart';
import 'package:readlock/services/feedback/HapticsService.dart';
import 'package:readlock/services/feedback/SoundService.dart';

import 'package:pixelarticons/pixel.dart';
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
    final BorderRadius optionRadius = RLDS.borderRadiusMedium;

    normalOptionDecoration = BoxDecoration(
      color: RLDS.backgroundLight,
      borderRadius: optionRadius,
    );

    selectedOptionDecoration = BoxDecoration(
      color: RLDS.backgroundLight,
      borderRadius: optionRadius,
    );

    correctOptionDecoration = BoxDecoration(
      color: RLDS.success.withValues(alpha: 0.1),
      borderRadius: optionRadius,
    );

    incorrectOptionDecoration = BoxDecoration(
      color: RLDS.backgroundLight,
      borderRadius: optionRadius,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Div.column(
      [
        // Question text section
        QuestionTextSection(),

        const Spacing.height(32),

        // Single choice options
        OptionsListSection(),

        const Spacing.height(32),
      ],
      color: RLDS.backgroundDark,
      padding: 24,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }

  Widget QuestionTextSection() {
    return RLTypography.readingMedium(widget.content.question);
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

      // Spacing between options
      final bool isLastOption = optionIndex == widget.content.options.length - 1;

      if (!isLastOption) {
        optionWidgets.add(const Spacing.height(16));
      }
    }

    return optionWidgets;
  }

  Widget OptionButton({required int optionIndex, required QuestionOption option}) {
    final bool isSelected = selectedAnswerIndex == optionIndex;
    final bool isCorrectAnswer = widget.content.correctAnswerIndex == optionIndex;
    final bool shouldShowCorrect = hasAnsweredQuestion && isCorrectAnswer && isSelected;
    final bool shouldShowIncorrect = hasAnsweredQuestion && !isCorrectAnswer && isSelected;
    final bool shouldMute = hasAnsweredQuestion && !isCorrectAnswer && !isSelected;

    final BoxDecoration buttonDecoration = getOptionButtonDecoration(
      isSelected: isSelected,
      shouldShowCorrect: shouldShowCorrect,
      shouldShowIncorrect: shouldShowIncorrect,
      shouldMute: shouldMute,
    );

    VoidCallback? buttonTapCallback;

    if (!hasAnsweredQuestion) {
      buttonTapCallback = () => handleOptionSelection(optionIndex);
    }

    final TextStyle optionTextStyle = getOptionButtonTextStyle(
      isSelected: isSelected,
      shouldShowCorrect: shouldShowCorrect,
      shouldShowIncorrect: shouldShowIncorrect,
      shouldMute: shouldMute,
    );

    final Widget CorrectCheckIcon = const Icon(
      Pixel.check,
      color: RLDS.success,
      size: RLDS.iconMedium,
    );

    final Widget IncorrectCancelIcon = Icon(
      Pixel.close,
      color: RLDS.textPrimary.withValues(alpha: 0.6),
      size: RLDS.iconMedium,
    );

    return Div.row(
      [
        Expanded(child: RLTypography.readingMedium(option.text, color: optionTextStyle.color)),

        // Visual feedback indicators
        RenderIf.condition(shouldShowCorrect, CorrectCheckIcon, const SizedBox.shrink()),

        RenderIf.condition(shouldShowIncorrect, IncorrectCancelIcon, const SizedBox.shrink()),
      ],
      padding: RLDS.contentPaddingMediumInsets,
      decoration: buttonDecoration,
      onTap: buttonTapCallback,
    );
  }

  void handleOptionSelection(int optionIndex) {
    if (hasAnsweredQuestion) {
      return;
    }

    HapticsService.lightImpact();

    final bool isCorrectAnswer = widget.content.correctAnswerIndex == optionIndex;

    if (!isCorrectAnswer) {
      showIncorrectAnswerFeedback(optionIndex);
      return;
    }

    markQuestionAsAnswered(optionIndex);
    showCorrectAnswerFeedback(optionIndex);
    SoundService.playCorrectAnswer();
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

    return 'Try again and think about the design principle.';
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
    if (shouldShowCorrect) {
      return RLTypography.readingMediumStyle.copyWith(color: RLDS.success);
    }

    if (shouldMute) {
      return RLTypography.readingMediumStyle.copyWith(
        color: RLDS.textPrimary.withValues(alpha: 0.4),
      );
    }

    return RLTypography.readingMediumStyle;
  }
}
