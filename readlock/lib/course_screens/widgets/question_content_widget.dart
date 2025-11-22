// Widget for displaying interactive quiz questions with options and feedback
// Handles user answer selection and shows explanations after answering

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/app_constants.dart';
import 'package:readlock/course_screens/models/course_model.dart';
import 'package:readlock/utility_widgets/utility_widgets.dart';
import 'package:readlock/constants/typography.dart';
import 'package:readlock/constants/app_theme.dart';
import 'package:readlock/utility_widgets/text_animation/progressive_text.dart';

class QuestionContentWidget extends StatefulWidget {
  static const double QUESTION_SECTION_SPACING = 24.0;
  static const double OPTION_BUTTON_SPACING = 16.0;
  static const double BUTTON_PADDING = 16.0;
  static const double EAhaLANATION_PADDING = 16.0;

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
      padding: const EdgeInsets.all(Constants.COURSE_SECTION_PADDING),
      child: Center(
        child: Div.column(
          [
            questionText(),

            const Spacing.height(
              QuestionContentWidget.QUESTION_SECTION_SPACING,
            ),

            optionsList(),

            const Spacing.height(
              QuestionContentWidget.QUESTION_SECTION_SPACING,
            ),

            explanationSection(),
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
    );
  }

  Widget questionText() {
    return Text(
      widget.content.question,
      style: Typography.bodyLargeStyle.copyWith(
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget optionsList() {
    return Div.column([
      ...widget.content.options.asMap().entries.map((entry) {
        final int optionIndex = entry.key;
        final QuestionOption option = entry.value;

        return Div.column([
          optionButton(optionIndex, option),

          const Spacing.height(
            QuestionContentWidget.OPTION_BUTTON_SPACING,
          ),
        ]);
      }),
    ]);
  }

  Widget optionButton(int optionIndex, QuestionOption option) {
    final bool isSelected = selectedAnswerIndex == optionIndex;
    final bool isCorrectAnswer = widget.content.correctAnswerIndices
        .contains(optionIndex);
    final bool isCorrectAndAnswered =
        hasAnswered && isCorrectAnswer && isSelected;

    Color themeColor;
    Color backgroundColor;
    Color textColor;

    if (isCorrectAndAnswered) {
      themeColor = AppTheme.primaryGreen;
      backgroundColor = AppTheme.backgroundLight;
      textColor = AppTheme.textPrimary;
    } else if (isSelected && !hasAnswered) {
      themeColor = AppTheme.primaryBlue;
      backgroundColor = AppTheme.backgroundLight;
      textColor = AppTheme.textPrimary;
    } else {
      themeColor = AppTheme.textPrimary.withValues(alpha: 0.2);
      backgroundColor = AppTheme.backgroundLight;
      textColor = AppTheme.textPrimary;
    }

    final Widget optionContainer = Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: themeColor, width: 2),
      ),
      child: InkWell(
        onTap: hasAnswered ? null : () => selectAnswer(optionIndex),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: AppTheme.contentPaddingMediumInsets,
          child: Row(
            children: [
              RenderIf.condition(
                isCorrectAndAnswered,
                Row(
                  children: [
                    Container(
                      padding: AppTheme.contentPaddingTinyInsets,
                      decoration: BoxDecoration(
                        color: themeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: themeColor,
                        size: 18,
                      ),
                    ),
                    const Spacing.width(12),
                  ],
                ),
              ),

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

    return optionContainer;
  }

  Widget explanationSection() {
    return RenderIf.condition(
      hasAnswered,
      ProgressiveText(
        textSegments: [widget.content.explanation],
        textStyle: Typography.bodyLargeStyle.copyWith(
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }

  void selectAnswer(int optionIndex) {
    final bool isCorrectAnswer = widget.content.correctAnswerIndices
        .contains(optionIndex);

    if (!isCorrectAnswer && !hasAnswered) {
      // Wrong answer - show helpful guidance
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    color: Colors.white,
                    size: 16,
                  ),
                  const Spacing.width(8),
                  Text(
                    'Think again',
                    style: Typography.bodyLargeStyle.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Spacing.height(4),
              Text(
                'Consider the key concepts from this section. The correct answer relates to the main principle discussed.',
                style: Typography.bodyMediumStyle.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange.shade600,
          duration: const Duration(milliseconds: 3000),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    if (isCorrectAnswer && !hasAnswered) {
      // Correct answer - mark as answered and show green
      setState(() {
        selectedAnswerIndex = optionIndex;
        hasAnswered = true;
      });

      // Show Aha snackbar after a short delay
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.white, size: 16),
                  const Spacing.width(8),
                  Text(
                    '+5 Aha',
                    style: Typography.bodyLargeStyle.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green.shade600,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      });

      widget.onAnswerSelected(optionIndex, isCorrectAnswer);
    }
  }
}
