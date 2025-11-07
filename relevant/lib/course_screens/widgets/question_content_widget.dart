// Widget for displaying interactive quiz questions with options and feedback
// Handles user answer selection and shows explanations after answering

import 'package:flutter/material.dart';
import 'package:relevant/course_screens/models/course_model.dart';
import 'package:relevant/utility_widgets/utility_widgets.dart';

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
      child: Div.column(
        [
          QuestionTitle(),

          const Spacing.height(24),

          ScenarioContextSection(),

          const Spacing.height(20),

          QuestionText(),

          const Spacing.height(32),

          OptionsList(),

          const Spacing.height(20),

          ExplanationSection(),
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );
  }

  Widget QuestionTitle() {
    return Text(
      widget.content.title,
      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
    );
  }

  Widget QuestionText() {
    return Text(
      widget.content.question,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
    );
  }

  Widget OptionsList() {
    return Div.column(
      [
        for (
          int optionIndex = 0;
          optionIndex < widget.content.options.length;
          optionIndex++
        )
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: OptionButton(
              optionIndex,
              widget.content.options[optionIndex],
            ),
          ),
      ],
    );
  }

  Widget OptionButton(int optionIndex, QuestionOption option) {
    final bool isSelected = selectedAnswerIndex == optionIndex;
    final bool isCorrect = widget.content.correctAnswerIndices.contains(
      optionIndex,
    );
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
        child: Div.row(
          [
            if (shouldShowFeedback)
              Icon(
                isCorrect ? Icons.check_circle : Icons.cancel,
                color: textColor,
              ),

            if (shouldShowFeedback) const Spacing.width(12),

            Expanded(
              child: Text(
                option.text,
                style: TextStyle(
                  fontWeight: isSelected
                      ? FontWeight.w600
                      : FontWeight.normal,
                  color: textColor,
                ),
              ),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.start,
        ),
      ),
    );
  }

  Widget ExplanationSection() {
    final bool shouldShowExplanation = hasAnswered;

    if (!shouldShowExplanation) {
      return const Spacing.height(0);
    }

    return Div.column(
      [
        Text(
          widget.content.explanation,
          style: const TextStyle(fontSize: 16, height: 1.0),
        ),
      ],
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget ScenarioContextSection() {
    final bool hasScenarioContext =
        widget.content.scenarioContext != null;

    if (!hasScenarioContext) {
      return const Spacing.height(0);
    }

    return Div.column(
      [
        Div.row(
          [
            Icon(Icons.theater_comedy, color: Colors.purple[400]),

            const Spacing.width(8),

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

        const Spacing.height(12),

        Text(
          widget.content.scenarioContext ?? '',
          style: const TextStyle(fontSize: 16, height: 1.0),
        ),
      ],
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.purple[900]?.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple[600]!),
      ),
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  void selectAnswer(int optionIndex) {
    final bool canSelectAnswer = !hasAnswered;

    if (!canSelectAnswer) {
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
}
