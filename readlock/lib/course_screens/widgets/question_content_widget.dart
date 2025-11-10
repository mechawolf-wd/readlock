// Widget for displaying interactive quiz questions with options and feedback
// Handles user answer selection and shows explanations after answering

import 'package:flutter/material.dart' hide Typography;
import 'package:relevant/constants/app_constants.dart';
import 'package:relevant/course_screens/models/course_model.dart';
import 'package:relevant/utility_widgets/utility_widgets.dart';
import 'package:relevant/constants/typography.dart';

class QuestionContentWidget extends StatefulWidget {
  static const double QUESTION_SECTION_SPACING = 24.0;
  static const double OPTION_BUTTON_SPACING = 16.0;
  static const double BUTTON_PADDING = 16.0;
  static const double EXPLANATION_PADDING = 16.0;

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
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Constants.COURSE_SECTION_PADDING),
        child: Div.column([
          QuestionText(),

          const Spacing.height(
            QuestionContentWidget.QUESTION_SECTION_SPACING,
          ),

          OptionsList(),

          const Spacing.height(
            QuestionContentWidget.QUESTION_SECTION_SPACING,
          ),

          ExplanationSection(),
        ], crossAxisAlignment: CrossAxisAlignment.start),
      ),
    );
  }

  Widget QuestionText() {
    return Typography.headingMedium(widget.content.question);
  }

  Widget OptionsList() {
    return Div.column([
      for (
        int optionIndex = 0;
        optionIndex < widget.content.options.length;
        optionIndex++
      )
        Div.column([
          OptionButton(
            optionIndex,
            widget.content.options[optionIndex],
          ),

          const Spacing.height(QuestionContentWidget.OPTION_BUTTON_SPACING),
        ]),
    ]);
  }

  Widget OptionButton(int optionIndex, QuestionOption option) {
    final bool isSelected = selectedAnswerIndex == optionIndex;
    final bool isCorrect = widget.content.correctAnswerIndices.contains(
      optionIndex,
    );
    final bool shouldShowFeedback = hasAnswered && isSelected;

    const Color textColor = Colors.white;
    final Color buttonColor = getButtonColor(
      shouldShowFeedback,
      isCorrect,
      isSelected,
    );

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: hasAnswered ? null : () => selectAnswer(optionIndex),
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: textColor,
          padding: const EdgeInsets.all(
            QuestionContentWidget.BUTTON_PADDING,
          ),
        ),
        child: Div.row([
          if (shouldShowFeedback)
            Icon(getFeedbackIcon(isCorrect), color: textColor),

          if (shouldShowFeedback)
            const Spacing.width(
              QuestionContentWidget.OPTION_BUTTON_SPACING - 4,
            ),

          Expanded(
            child: Text(
              option.text,
              style: TextStyle(
                fontWeight: getTextWeight(isSelected),
                color: textColor,
              ),
            ),
          ),
        ], mainAxisAlignment: MainAxisAlignment.start),
      ),
    );
  }

  Widget ExplanationSection() {
    final bool shouldShowExplanation = hasAnswered;

    if (!shouldShowExplanation) {
      return const Spacing.height(0);
    }

    return Div.column([
      Typography.bodyMedium(widget.content.explanation),
    ], padding: QuestionContentWidget.EXPLANATION_PADDING);
  }

  Color getButtonColor(
    bool shouldShowFeedback,
    bool isCorrect,
    bool isSelected,
  ) {
    if (shouldShowFeedback) {
      if (isCorrect) {
        return Colors.green[600]!;
      } else {
        return Colors.red[600]!;
      }
    }

    if (isSelected) {
      return Colors.blue[600]!;
    } else {
      return Colors.grey[700]!;
    }
  }

  IconData getFeedbackIcon(bool isCorrect) {
    if (isCorrect) {
      return Icons.check_circle;
    } else {
      return Icons.question_mark;
    }
  }

  FontWeight getTextWeight(bool isSelected) {
    if (isSelected) {
      return FontWeight.w600;
    } else {
      return FontWeight.normal;
    }
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
