// Question Content Widget
// 
// This file contains the QuestionContentWidget that displays interactive quiz
// questions with multiple choice options, answer validation, and feedback.
// Handles user interactions and maintains question state.

import 'package:flutter/material.dart';
import 'package:relevant/course_screens/models/course_model.dart';
import 'package:relevant/constants/app_theme.dart';

class QuestionContentWidget extends StatefulWidget {
  final QuestionContent content;
  final void Function(int selectedIndex, bool isCorrect)
  onAnswerSelected;

  const QuestionContentWidget({
    super.key,
    required this.content,
    required this.onAnswerSelected,
  });

  @override
  State<QuestionContentWidget> createState() =>
      QuestionContentWidgetState();
}

class QuestionContentWidgetState extends State<QuestionContentWidget> {
  int? selectedAnswerIndex;
  List<int> selectedAnswerIndices = [];
  bool hasAnswered = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingXXL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QuestionTitle(),

          const SizedBox(height: AppTheme.spacingXXL),

          ScenarioContextSection(),

          const SizedBox(height: AppTheme.spacingXL),

          QuestionText(),

          const SizedBox(height: AppTheme.spacingXXXL),

          OptionsList(),

          const SizedBox(height: AppTheme.spacingXL),

          ExplanationSection(),

          const SizedBox(height: AppTheme.spacingXL),

          FollowUpPromptsSection(),
        ],
      ),
    );
  }

  /// @Widget: Large heading displaying the quiz or question title
  Widget QuestionTitle() {
    return Text(widget.content.title, style: AppTheme.headingLarge);
  }

  /// @Widget: Main question text that users need to answer
  Widget QuestionText() {
    return Text(
      widget.content.question,
      style: AppTheme.headingSmall,
      textAlign: TextAlign.center,
    );
  }

  /// @Widget: Vertical list of selectable answer options
  Widget OptionsList() {
    final List<Widget> optionWidgets = [];

    for (
      int optionIndex = 0;
      optionIndex < widget.content.options.length;
      optionIndex++
    ) {
      final QuestionOption option = widget.content.options[optionIndex];

      optionWidgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
          child: Center(child: OptionButton(optionIndex, option)),
        ),
      );
    }

    return Column(children: optionWidgets);
  }

  /// @Widget: Interactive button for each answer choice with visual feedback
  Widget OptionButton(int optionIndex, QuestionOption option) {
    final bool isMultipleChoice =
        widget.content.hasMultipleCorrectAnswers;
    final bool isSelected = isMultipleChoice
        ? selectedAnswerIndices.contains(optionIndex)
        : selectedAnswerIndex == optionIndex;
    final bool isCorrect = widget.content.correctAnswerIndices.contains(
      optionIndex,
    );
    final bool shouldShowFeedback = hasAnswered && isSelected;
    final QuestionOptionColors colors =
        AppTheme.getQuestionOptionColors(
          isSelected: isSelected,
          shouldShowFeedback: shouldShowFeedback,
          isCorrect: isCorrect,
        );

    return ElevatedButton(
      onPressed: hasAnswered ? null : () => selectAnswer(optionIndex),
      style:
          AppTheme.getElevatedButtonStyle(
            backgroundColor: colors.backgroundColor,
            foregroundColor: colors.textColor,
          ).copyWith(
            elevation: WidgetStateProperty.all(
              isSelected ? AppTheme.elevationLow : 0,
            ),
          ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (shouldShowFeedback)
            AppIcons.GetColoredIcon(
              isCorrect ? AppIcons.checkCircle : AppIcons.cancel,
              isCorrect ? AppTheme.green800 : AppTheme.red800,
            ),

          if (shouldShowFeedback)
            const SizedBox(width: AppTheme.spacingM),

          Text(
            option.text,
            style: AppTheme.bodyMedium.copyWith(
              fontWeight: isSelected
                  ? FontWeight.w600
                  : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  /// @Widget: Detailed explanation shown after answering the question
  Widget ExplanationSection() {
    if (!hasAnswered) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingXL),
      child: Text(
        widget.content.explanation,
        style: AppTheme.bodyMedium.copyWith(height: 1.5),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// @Widget: Background context or scenario setup for the question
  Widget ScenarioContextSection() {
    if (widget.content.scenarioContext == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingXL),
      decoration: ContentBackgroundStyles.scenarioContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppIcons.GetColoredIcon(
                AppIcons.theater,
                AppTheme.purple600,
              ),

              const SizedBox(width: AppTheme.spacingS),

              Text(
                'Scenario',
                style: AppTheme.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingM),

          Text(
            widget.content.scenarioContext ?? '',
            style: AppTheme.bodyMedium.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }

  /// @Widget: Button to submit multiple choice answers when ready
  Widget SubmitButtonSection() {
    if (!widget.content.hasMultipleCorrectAnswers || hasAnswered) {
      return const SizedBox.shrink();
    }

    final bool hasSelections = selectedAnswerIndices.isNotEmpty;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: hasSelections ? submitMultipleChoiceAnswer : null,
        style: AppTheme.getElevatedButtonStyle(
          backgroundColor: hasSelections
              ? AppTheme.blue600
              : AppTheme.grey400,
          foregroundColor: AppTheme.white,
        ),
        child: Text(
          'Submit Answer${selectedAnswerIndices.length > 1 ? 's' : ''}',
          style: AppTheme.bodyLarge.copyWith(
            color: AppTheme.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// @Widget: Additional prompts or questions shown after main answer
  Widget FollowUpPromptsSection() {
    if (!hasAnswered || widget.content.followUpPrompts == null) {
      return const SizedBox.shrink();
    }

    final List<Widget> promptWidgets = [];

    for (final String prompt in widget.content.followUpPrompts ?? []) {
      promptWidgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
          child: Text(
            prompt,
            style: AppTheme.bodyMedium.copyWith(height: 1.4),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingXL),
      child: Column(children: promptWidgets),
    );
  }

  /// @Method: Handle answer selection
  void selectAnswer(int optionIndex) {
    if (hasAnswered) {
      return;
    }

    if (widget.content.hasMultipleCorrectAnswers) {
      setState(() {
        if (selectedAnswerIndices.contains(optionIndex)) {
          selectedAnswerIndices.remove(optionIndex);
        } else {
          selectedAnswerIndices.add(optionIndex);
        }
      });

      // Auto-submit for multiple choice questions
      if (selectedAnswerIndices.isNotEmpty) {
        submitMultipleChoiceAnswer();
      }
      return;
    }

    final bool isCorrect = widget.content.correctAnswerIndices.contains(
      optionIndex,
    );

    setState(() {
      selectedAnswerIndex = optionIndex;
      hasAnswered = true;
    });

    widget.onAnswerSelected(optionIndex, isCorrect);
  }

  /// @Method: Submit multiple choice answer
  void submitMultipleChoiceAnswer() {
    if (hasAnswered || selectedAnswerIndices.isEmpty) {
      return;
    }

    final Set<int> correctIndices = widget.content.correctAnswerIndices
        .toSet();
    final Set<int> selectedIndicesSet = selectedAnswerIndices.toSet();

    final bool isCorrect =
        correctIndices.difference(selectedIndicesSet).isEmpty &&
        selectedIndicesSet.difference(correctIndices).isEmpty;

    setState(() {
      hasAnswered = true;
    });

    widget.onAnswerSelected(selectedAnswerIndices.first, isCorrect);
  }
}
