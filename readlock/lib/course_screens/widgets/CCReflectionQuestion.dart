import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/constants.dart';
import 'package:readlock/course_screens/models/courseModel.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/typography.dart';
import 'package:readlock/constants/appTheme.dart';
import 'package:readlock/utility_widgets/FeedbackSnackbar.dart';

const double REFLECTION_SECTION_SPACING = 28.0;
const double REFLECTION_OPTION_SPACING = 16.0;
const double REFLECTION_THOUGHT_SPACING = 12.0;

class ReflectionQuestionWidget extends StatefulWidget {
  final QuestionContent content;
  final void Function(int selectedIndex, bool isCorrect) onAnswerSelected;

  const ReflectionQuestionWidget({
    super.key,
    required this.content,
    required this.onAnswerSelected,
  });

  @override
  State<ReflectionQuestionWidget> createState() => 
      ReflectionQuestionWidgetState();
}

class ReflectionQuestionWidgetState extends State<ReflectionQuestionWidget> {
  int? selectedAnswerIndex;
  bool hasReflected = false;
  bool hasSelectedInitialThought = false;

  @override
  Widget build(BuildContext context) {
    final BoxDecoration thoughtDecoration = BoxDecoration(
      color: AppTheme.backgroundLight,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: AppTheme.textPrimary.withValues(alpha: 0.1),
        width: 1,
      ),
    );

    final BoxDecoration selectedThoughtDecoration = BoxDecoration(
      color: AppTheme.primaryBlue.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: AppTheme.primaryBlue.withValues(alpha: 0.5),
        width: 2,
      ),
    );

    final BoxDecoration reflectedDecoration = BoxDecoration(
      color: AppTheme.primaryGreen.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: AppTheme.primaryGreen.withValues(alpha: 0.4),
        width: 1.5,
      ),
    );

    final Widget ReflectionIcon = Icon(
      Icons.self_improvement,
      color: AppTheme.primaryBlue.withValues(alpha: 0.7),
      size: 32,
    );

    return Div.column(
      [
        // Reflection header
        reflectionHeaderWidget(ReflectionIcon),

        const Spacing.height(REFLECTION_SECTION_SPACING),

        // Reflection prompt
        reflectionPromptWidget(),

        const Spacing.height(REFLECTION_SECTION_SPACING),

        // Thought options
        thoughtOptionsWidget(
          thoughtDecoration,
          selectedThoughtDecoration,
          reflectedDecoration,
        ),

        const Spacing.height(REFLECTION_SECTION_SPACING),

        // Reflection insight after selection
        reflectionInsightWidget(),
      ],
      color: AppTheme.backgroundDark,
      padding: Constants.COURSE_SECTION_PADDING,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }

  Widget reflectionHeaderWidget(Widget reflectionIcon) {
    return Div.column(
      [
        Center(child: reflectionIcon),

        const Spacing.height(12),

        Center(
          child: Text(
            'Take a Moment to Reflect',
            style: Typography.headingMediumStyle.copyWith(
              fontSize: 18,
              color: AppTheme.textPrimary.withValues(alpha: 0.9),
            ),
          ),
        ),
      ],
    );
  }

  Widget reflectionPromptWidget() {
    return Text(
      widget.content.question,
      style: Typography.bodyLargeStyle.copyWith(
        fontSize: 16,
        height: 1.6,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget thoughtOptionsWidget(
    BoxDecoration normalDecoration,
    BoxDecoration selectedDecoration,
    BoxDecoration reflectedDecoration,
  ) {
    final List<Widget> optionWidgets = widget.content.options
        .asMap()
        .entries
        .map((entry) {
          final int optionIndex = entry.key;
          final QuestionOption option = entry.value;

          return Div.column([
            thoughtOptionWidget(
              optionIndex,
              option,
              normalDecoration,
              selectedDecoration,
              reflectedDecoration,
            ),

            const Spacing.height(REFLECTION_OPTION_SPACING),
          ]);
        })
        .toList();

    return Div.column(optionWidgets);
  }

  Widget thoughtOptionWidget(
    int optionIndex,
    QuestionOption option,
    BoxDecoration normalDecoration,
    BoxDecoration selectedDecoration,
    BoxDecoration reflectedDecoration,
  ) {
    final bool isSelected = selectedAnswerIndex == optionIndex;
    final bool isCorrectAnswer = widget.content.correctAnswerIndices.contains(optionIndex);

    final BoxDecoration decoration = getThoughtDecoration(
      isSelected: isSelected,
      hasReflected: hasReflected,
      isCorrect: isCorrectAnswer,
      normalDecoration: normalDecoration,
      selectedDecoration: selectedDecoration,
      reflectedDecoration: reflectedDecoration,
    );

    final TextStyle textStyle = getThoughtTextStyle(
      isSelected: isSelected,
      hasReflected: hasReflected,
      isCorrect: isCorrectAnswer,
    );

    final Widget CheckIcon = Icon(
      Icons.check_circle_outline,
      color: AppTheme.primaryGreen,
      size: 20,
    );

    return Div.row(
      [
        // Show check icon for correct answer after reflection
        if (hasReflected && isCorrectAnswer) ...[
          CheckIcon,
          const Spacing.width(12),
        ],

        Expanded(
          child: Text(
            option.text,
            style: textStyle,
          ),
        ),
      ],
      padding: 20,
      decoration: decoration,
      onTap: hasReflected ? null : () => handleThoughtSelection(optionIndex),
    );
  }

  Widget reflectionInsightWidget() {
    if (!hasReflected) {
      return const SizedBox.shrink();
    }

    final Widget InsightIcon = Icon(
      Icons.auto_awesome,
      color: AppTheme.primaryGreen.withValues(alpha: 0.8),
      size: 20,
    );

    return Div.column(
      [
        Div.row([
          InsightIcon,

          const Spacing.width(8),

          Text(
            'Insight',
            style: Typography.bodyLargeStyle.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppTheme.primaryGreen,
            ),
          ),
        ]),

        const Spacing.height(12),

        Text(
          widget.content.explanation,
          style: Typography.bodyMediumStyle.copyWith(
            fontSize: 14,
            height: 1.6,
            color: AppTheme.textPrimary.withValues(alpha: 0.9),
          ),
        ),
      ],
      padding: 20,
      color: AppTheme.primaryGreen.withValues(alpha: 0.05),
      radius: 12,
    );
  }

  BoxDecoration getThoughtDecoration({
    required bool isSelected,
    required bool hasReflected,
    required bool isCorrect,
    required BoxDecoration normalDecoration,
    required BoxDecoration selectedDecoration,
    required BoxDecoration reflectedDecoration,
  }) {
    if (hasReflected && isCorrect) {
      return reflectedDecoration;
    }

    if (isSelected && !hasReflected) {
      return selectedDecoration;
    }

    if (hasReflected) {
      return normalDecoration.copyWith(
        color: AppTheme.backgroundLight.withValues(alpha: 0.5),
      );
    }

    return normalDecoration;
  }

  TextStyle getThoughtTextStyle({
    required bool isSelected,
    required bool hasReflected,
    required bool isCorrect,
  }) {
    Color textColor = AppTheme.textPrimary;
    FontWeight fontWeight = FontWeight.normal;

    if (hasReflected && isCorrect) {
      textColor = AppTheme.primaryGreen;
      fontWeight = FontWeight.w500;
    } else if (hasReflected && !isCorrect) {
      textColor = AppTheme.textPrimary.withValues(alpha: 0.5);
    } else if (isSelected && !hasReflected) {
      fontWeight = FontWeight.w500;
      textColor = AppTheme.primaryBlue;
    }

    return Typography.bodyMediumStyle.copyWith(
      fontSize: 15,
      color: textColor,
      fontWeight: fontWeight,
      height: 1.5,
    );
  }

  void handleThoughtSelection(int optionIndex) {
    if (!hasSelectedInitialThought) {
      setState(() {
        selectedAnswerIndex = optionIndex;
        hasSelectedInitialThought = true;
      });

      // Complete reflection immediately
      completeReflection(optionIndex);
    }
  }

  void completeReflection(int optionIndex) {
    final bool isCorrectAnswer = widget.content.correctAnswerIndices.contains(optionIndex);

    setState(() {
      hasReflected = true;
    });

    widget.onAnswerSelected(optionIndex, isCorrectAnswer);

    if (mounted) {
      if (isCorrectAnswer) {
        FeedbackSnackBar.showCustomFeedback(
          context,
          'Your reflection aligns with the deeper insight!',
          true,
        );
      } else {
        FeedbackSnackBar.showCustomFeedback(
          context,
          'Consider the insight below for a different perspective',
          false,
        );
      }
    }
  }
}