// Widget for displaying interactive quiz questions with options and feedback
// Handles user answer selection and shows explanations after answering

import 'package:flutter/material.dart';
import 'package:relevant/course_screens/models/course_model.dart';

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
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QuestionTitle(),

          const SizedBox(height: 24),

          ScenarioContextSection(),

          const SizedBox(height: 20),

          QuestionText(),

          const SizedBox(height: 32),

          OptionsList(),

          const SizedBox(height: 20),

          ExplanationSection(),

          const SizedBox(height: 20),

          FollowUpPromptsSection(),
        ],
      ),
    );
  }

  Widget QuestionTitle() {
    return Text(
      widget.content.title,
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget QuestionText() {
    return Text(
      widget.content.question,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget OptionsList() {
    return Column(
      children: [
        for (int optionIndex = 0; optionIndex < widget.content.options.length; optionIndex++)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: OptionButton(optionIndex, widget.content.options[optionIndex]),
          ),
      ],
    );
  }

  Widget OptionButton(int optionIndex, QuestionOption option) {
    final bool isSelected = selectedAnswerIndex == optionIndex;
    final bool isCorrect = widget.content.correctAnswerIndices.contains(optionIndex);
    final bool shouldShowFeedback = hasAnswered && isSelected;

    const Color textColor = Colors.white;
    
    final Color buttonColor = shouldShowFeedback
        ? (isCorrect ? Colors.green[600]! : Colors.red[600]!)
        : isSelected
            ? Colors.blue[600]!
            : Colors.grey[700]!;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: hasAnswered ? null : () => selectAnswer(optionIndex),
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: textColor,
          padding: const EdgeInsets.all(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (shouldShowFeedback)
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: textColor,
              ),

            if (shouldShowFeedback) const SizedBox(width: 12),

            Expanded(
              child: Text(
                option.text,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget ExplanationSection() {
    final bool shouldShowExplanation = hasAnswered;
    
    if (!shouldShowExplanation) {
      return const SizedBox(height: 0);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        widget.content.explanation,
        style: const TextStyle(
          fontSize: 16,
          height: 1.5,
        ),
      ),
    );
  }

  Widget ScenarioContextSection() {
    final bool hasScenarioContext = widget.content.scenarioContext != null;
    
    if (!hasScenarioContext) {
      return const SizedBox(height: 0);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.purple[900]?.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple[600]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.theater_comedy,
                color: Colors.purple[400],
              ),

              const SizedBox(width: 8),

              Text(
                'Scenario',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[400],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            widget.content.scenarioContext ?? '',
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }


  Widget FollowUpPromptsSection() {
    final bool hasFollowUpPrompts = widget.content.followUpPrompts != null;
    final bool shouldShowPrompts = hasAnswered && hasFollowUpPrompts;
    
    if (!shouldShowPrompts) {
      return const SizedBox(height: 0);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          for (final String prompt in widget.content.followUpPrompts ?? [])
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: Text(
                prompt,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.4,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void selectAnswer(int optionIndex) {
    final bool canSelectAnswer = !hasAnswered;
    
    if (!canSelectAnswer) {
      return;
    }

    final bool isCorrect = widget.content.correctAnswerIndices.contains(optionIndex);

    setState(() {
      selectedAnswerIndex = optionIndex;
      hasAnswered = true;
    });

    widget.onAnswerSelected(optionIndex, isCorrect);
  }

}
