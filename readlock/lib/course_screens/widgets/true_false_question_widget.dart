// Widget for displaying true/false questions with animated blue/red choice buttons
// Provides intuitive visual feedback and smooth transitions between states

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/app_constants.dart';
import 'package:readlock/course_screens/models/course_model.dart';
import 'package:readlock/utility_widgets/utility_widgets.dart';
import 'package:readlock/constants/typography.dart';
import 'package:readlock/constants/app_theme.dart';
import 'package:readlock/utility_widgets/text_animation/progressive_text.dart';

const double TRUE_FALSE_BUTTON_HEIGHT = 60.0;
const double TRUE_FALSE_BUTTON_SPACING = 16.0;
const double TRUE_FALSE_SECTION_SPACING = 24.0;
const double TRUE_FALSE_ICON_SIZE = 24.0;
const int ANIMATION_DURATION_MS = 300;
const int SHAKE_ANIMATION_DURATION_MS = 500;

class TrueFalseQuestionWidget extends StatefulWidget {
  final QuestionContent content;
  final void Function(int selectedIndex, bool isCorrect)
  onAnswerSelected;

  const TrueFalseQuestionWidget({
    super.key,
    required this.content,
    required this.onAnswerSelected,
  });

  @override
  State<TrueFalseQuestionWidget> createState() =>
      TrueFalseQuestionWidgetState();
}

class TrueFalseQuestionWidgetState
    extends State<TrueFalseQuestionWidget>
    with TickerProviderStateMixin {
  int? selectedAnswerIndex;
  bool hasAnswered = false;
  AnimationController? shakeController;
  Animation<double>? shakeAnimation;

  @override
  void dispose() {
    shakeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.backgroundDark,
      padding: const EdgeInsets.all(Constants.COURSE_SECTION_PADDING),
      child: Center(
        child: Div.column(
          [
            QuestionText(),

            const Spacing.height(TRUE_FALSE_SECTION_SPACING),

            TrueFalseButtons(),

            const Spacing.height(TRUE_FALSE_SECTION_SPACING),

            ExplanationSection(),
          ],
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
    );
  }

  Widget QuestionText() {
    final TextStyle questionTextStyle = Typography.bodyLargeStyle
        .copyWith(fontWeight: FontWeight.w500, fontSize: 18);

    return Text(
      widget.content.question,
      style: questionTextStyle,
      textAlign: TextAlign.center,
    );
  }

  Widget TrueFalseButtons() {
    return Div.column([
      TrueButton(),

      const Spacing.height(TRUE_FALSE_BUTTON_SPACING),

      FalseButton(),
    ]);
  }

  Widget TrueButton() {
    const int trueIndex = 0;
    final bool isSelected = selectedAnswerIndex == trueIndex;
    final bool isCorrect = widget.content.correctAnswerIndices.contains(
      trueIndex,
    );
    final bool shouldShowFeedback = hasAnswered && isCorrect;

    return ChoiceButton(
      label: 'True',
      icon: Icons.check_circle_outline,
      baseColor: AppTheme.primaryBlue,
      isSelected: isSelected,
      shouldShowFeedback: shouldShowFeedback,
      isCorrect: isCorrect,
      onTap: hasAnswered ? null : () => selectAnswer(trueIndex),
      buttonIndex: trueIndex,
    );
  }

  Widget FalseButton() {
    const int falseIndex = 1;
    final bool isSelected = selectedAnswerIndex == falseIndex;
    final bool isCorrect = widget.content.correctAnswerIndices.contains(
      falseIndex,
    );
    final bool shouldShowFeedback = hasAnswered && isCorrect;

    return ChoiceButton(
      label: 'False',
      icon: Icons.cancel_outlined,
      baseColor: Colors.red.shade600,
      isSelected: isSelected,
      shouldShowFeedback: shouldShowFeedback,
      isCorrect: isCorrect,
      onTap: hasAnswered ? null : () => selectAnswer(falseIndex),
      buttonIndex: falseIndex,
    );
  }

  Widget ChoiceButton({
    required String label,
    required IconData icon,
    required Color baseColor,
    required bool isSelected,
    required bool shouldShowFeedback,
    required bool isCorrect,
    required VoidCallback? onTap,
    required int buttonIndex,
  }) {
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    Color iconColor;
    if (shouldShowFeedback && isCorrect) {
      backgroundColor = AppTheme.primaryGreen.withValues(alpha: 0.1);
      borderColor = AppTheme.primaryGreen;
      textColor = AppTheme.primaryGreen;
      iconColor = AppTheme.primaryGreen;
    } else if (isSelected && !hasAnswered) {
      backgroundColor = baseColor.withValues(alpha: 0.1);
      borderColor = baseColor;
      textColor = baseColor;
      iconColor = baseColor;
    } else if (hasAnswered && !isCorrect && !isSelected) {
      backgroundColor = AppTheme.backgroundLight;
      borderColor = AppTheme.textPrimary.withValues(alpha: 0.1);
      textColor = AppTheme.textPrimary.withValues(alpha: 0.4);
      iconColor = AppTheme.textPrimary.withValues(alpha: 0.4);
    } else {
      backgroundColor = AppTheme.backgroundLight;
      borderColor = AppTheme.textPrimary.withValues(alpha: 0.2);
      textColor = AppTheme.textPrimary;
      iconColor = AppTheme.textPrimary.withValues(alpha: 0.6);
    }

    final BoxDecoration buttonDecoration = BoxDecoration(
      border: Border.all(color: borderColor, width: 2),
      borderRadius: BorderRadius.circular(12),
    );

    final TextStyle buttonTextStyle = Typography.bodyLargeStyle
        .copyWith(
          color: textColor,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          fontSize: 16,
        );

    final Widget buttonContent = Material(
      borderRadius: BorderRadius.circular(12),
      color: backgroundColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: TRUE_FALSE_BUTTON_HEIGHT,
          decoration: buttonDecoration,
          child: Div.row([
            Icon(icon, color: iconColor, size: TRUE_FALSE_ICON_SIZE),

            const Spacing.width(12),

            Text(label, style: buttonTextStyle),
          ], mainAxisAlignment: MainAxisAlignment.center),
        ),
      ),
    );

    if (buttonIndex == selectedAnswerIndex && shakeAnimation != null) {
      return AnimatedBuilder(
        animation: shakeAnimation!,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(shakeAnimation!.value * 10, 0),
            child: child,
          );
        },
        child: buttonContent,
      );
    }

    return buttonContent;
  }

  Widget ExplanationSection() {
    final TextStyle explanationHeaderStyle = Typography.bodyLargeStyle
        .copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: AppTheme.textPrimary.withValues(alpha: 0.8),
        );

    final TextStyle explanationTextStyle = Typography.bodyLargeStyle
        .copyWith(fontSize: 14, height: 1.5);

    return RenderIf.condition(
      hasAnswered,
      Div.column(
        [
          Div.row([
            Icon(
              Icons.lightbulb_outline,
              color: AppTheme.textPrimary.withValues(alpha: 0.6),
              size: 20,
            ),

            const Spacing.width(8),

            Text('Explanation', style: explanationHeaderStyle),
          ]),

          const Spacing.height(12),

          ProgressiveText(
            textSegments: [widget.content.explanation],
            textStyle: explanationTextStyle,
          ),
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
        padding: 16,
        color: AppTheme.backgroundLight,
        radius: 12,
      ),
    );
  }

  void selectAnswer(int answerIndex) {
    if (hasAnswered) {
      return;
    }

    final bool isCorrect = widget.content.correctAnswerIndices.contains(
      answerIndex,
    );

    setState(() {
      selectedAnswerIndex = answerIndex;
      hasAnswered = true;
    });

    if (!isCorrect) {
      triggerShakeAnimation();
    }

    widget.onAnswerSelected(answerIndex, isCorrect);

    // Show Aha snackbar for correct answer
    if (isCorrect && mounted) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          final TextStyle ahaTextStyle = Typography.bodyLargeStyle
              .copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              );

          final RoundedRectangleBorder snackbarShape =
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.white, size: 16),
                  const Spacing.width(8),
                  Text('+10 Aha', style: ahaTextStyle),
                ],
              ),
              backgroundColor: Colors.green.shade600,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: snackbarShape,
              margin: const EdgeInsets.all(16),
            ),
          );
        }
      });
    }
  }

  void triggerShakeAnimation() {
    shakeController = AnimationController(
      duration: const Duration(
        milliseconds: SHAKE_ANIMATION_DURATION_MS,
      ),
      vsync: this,
    );

    shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: shakeController!,
        curve: Curves.elasticIn,
      ),
    );

    setState(() {});

    shakeController!.forward().then((_) {
      shakeController!.dispose();
      setState(() {
        shakeController = null;
        shakeAnimation = null;
      });
    });
  }
}
