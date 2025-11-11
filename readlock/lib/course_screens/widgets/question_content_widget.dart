// Widget for displaying interactive quiz questions with options and feedback
// Handles user answer selection and shows explanations after answering

import 'package:flutter/material.dart' hide Typography;
import 'package:relevant/constants/app_constants.dart';
import 'package:relevant/course_screens/models/course_model.dart';
import 'package:relevant/utility_widgets/utility_widgets.dart';
import 'package:relevant/constants/typography.dart';
import 'package:relevant/constants/app_theme.dart';
import 'package:relevant/utility_widgets/text_animation/progressive_text.dart';

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
    return Container(
      color: AppTheme.backgroundDark,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(
            Constants.COURSE_SECTION_PADDING,
          ),
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
      ),
    );
  }

  Widget QuestionText() {
    return Text(
      widget.content.question,
      style: Typography.bodyLargeStyle.copyWith(
        fontWeight: FontWeight.w500,
      ),
    );
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

          const Spacing.height(
            QuestionContentWidget.OPTION_BUTTON_SPACING,
          ),
        ]),
    ]);
  }

  Widget OptionButton(int optionIndex, QuestionOption option) {
    final bool isSelected = selectedAnswerIndex == optionIndex;
    final bool isCorrect = widget.content.correctAnswerIndices.contains(
      optionIndex,
    );
    final bool shouldShowFeedback = hasAnswered && (isSelected || isCorrect);

    Color themeColor;
    Color backgroundColor;
    Color textColor;

    if (shouldShowFeedback) {
      if (isCorrect) {
        themeColor = AppTheme.primaryGreen;
        backgroundColor = AppTheme.backgroundLight;
        textColor = AppTheme.textPrimary;
      } else if (isSelected && !isCorrect) {
        // Gentle orange for wrong answers instead of harsh red
        themeColor = const Color(0xFFFF9800); // Orange
        backgroundColor = AppTheme.backgroundLight;
        textColor = AppTheme.textPrimary;
      } else {
        // Unselected options
        themeColor = AppTheme.textPrimary.withValues(alpha: 0.2);
        backgroundColor = AppTheme.backgroundLight;
        textColor = AppTheme.textPrimary;
      }
    } else if (isSelected) {
      themeColor = AppTheme.primaryBlue;
      backgroundColor = AppTheme.backgroundLight;
      textColor = AppTheme.textPrimary;
    } else {
      themeColor = AppTheme.textPrimary.withValues(alpha: 0.2);
      backgroundColor = AppTheme.backgroundLight;
      textColor = AppTheme.textPrimary;
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeColor, width: 2),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: themeColor.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: InkWell(
        onTap: hasAnswered ? null : () => selectAnswer(optionIndex),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              if (shouldShowFeedback) ...[
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: themeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    getFeedbackIcon(isCorrect),
                    color: themeColor,
                    size: 18,
                  ),
                ),
                const Spacing.width(12),
              ],

              Expanded(
                child: Text(
                  option.text,
                  style: Typography.bodyLargeStyle.copyWith(
                    fontSize: 14,
                    fontWeight: isSelected
                        ? FontWeight.w500
                        : FontWeight.normal,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget ExplanationSection() {
    final bool shouldShowExplanation = hasAnswered;

    if (!shouldShowExplanation) {
      return const Spacing.height(0);
    }

    return Div.column([
      ProgressiveText(
        textSegments: [widget.content.explanation],
        textStyle: Typography.bodyLargeStyle.copyWith(
          fontSize: 14,
        ),
        characterDelay: const Duration(milliseconds: 10),
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    ]);
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
