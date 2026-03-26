// Open-ended reflection question that encourages the reader to think critically
// Presents a prompt with answer options — focuses on deeper understanding, not right/wrong

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/models/CourseModel.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/utility_widgets/FeedbackSnackbar.dart';

class ThoughtTextStyleConfig {
  final Color color;
  final FontWeight fontWeight;

  const ThoughtTextStyleConfig({required this.color, required this.fontWeight});
}

class CCReflectionQuestion extends StatefulWidget {
  final ReflectionQuestionContent content;
  final void Function(int selectedIndex, bool isCorrect) onAnswerSelected;

  const CCReflectionQuestion({
    super.key,
    required this.content,
    required this.onAnswerSelected,
  });

  @override
  State<CCReflectionQuestion> createState() => CCReflectionQuestionState();
}

class CCReflectionQuestionState extends State<CCReflectionQuestion> {
  int? selectedAnswerIndex;
  bool hasReflected = false;
  bool hasSelectedInitialThought = false;

  // Style definitions
  late final BoxDecoration thoughtDecoration;
  late final BoxDecoration selectedThoughtDecoration;
  late final BoxDecoration reflectedDecoration;
  late final TextStyle headerTextStyle;
  late final TextStyle promptTextStyle;
  late final TextStyle insightHeaderTextStyle;
  late final TextStyle insightContentTextStyle;

  // Icon definitions
  late final Widget ReflectionIcon;
  late final Widget CheckIcon;
  late final Widget InsightIcon;

  @override
  void initState() {
    super.initState();
    initializeStyles();
    initializeIcons();
  }

  void initializeStyles() {
    thoughtDecoration = BoxDecoration(
      color: RLDS.backgroundLight,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: RLDS.textPrimary.withValues(alpha: 0.1)),
    );

    selectedThoughtDecoration = BoxDecoration(
      color: RLDS.primaryBlue.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: RLDS.primaryBlue.withValues(alpha: 0.5), width: 2),
    );

    reflectedDecoration = BoxDecoration(
      color: RLDS.primaryGreen.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: RLDS.primaryGreen.withValues(alpha: 0.4), width: 1.5),
    );

    headerTextStyle = RLTypography.headingMediumStyle.copyWith(
      fontSize: 18,
      color: RLDS.textPrimary.withValues(alpha: 0.9),
    );

    promptTextStyle = RLTypography.bodyLargeStyle.copyWith(fontSize: 16, height: 1.6);

    insightHeaderTextStyle = RLTypography.bodyLargeStyle.copyWith(
      fontWeight: FontWeight.w600,
      fontSize: 14,
      color: RLDS.primaryGreen,
    );

    insightContentTextStyle = RLTypography.bodyMediumStyle.copyWith(
      fontSize: 14,
      height: 1.6,
      color: RLDS.textPrimary.withValues(alpha: 0.9),
    );
  }

  void initializeIcons() {
    ReflectionIcon = Icon(
      Icons.self_improvement,
      color: RLDS.primaryBlue.withValues(alpha: 0.7),
      size: 32,
    );

    CheckIcon = Icon(Icons.check_circle_outline, color: RLDS.primaryGreen, size: 20);

    InsightIcon = Icon(
      Icons.auto_awesome,
      color: RLDS.primaryGreen.withValues(alpha: 0.8),
      size: 20,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Div.column(
      [
        // Reflection header with icon and title
        ReflectionHeaderSection(),

        const Spacing.height(28),

        // Reflection question prompt
        ReflectionPromptSection(),

        const Spacing.height(28),

        // Thought options for selection
        ThoughtOptionsSection(),

        const Spacing.height(28),

        // Reflection insight after selection
        ReflectionInsightSection(),
      ],
      color: RLDS.backgroundDark,
      padding: 24,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }

  Widget ReflectionHeaderSection() {
    return Div.column([
      Center(child: ReflectionIcon),

      const Spacing.height(12),

      Center(child: Text(RLUIStrings.REFLECT_TITLE, style: headerTextStyle)),
    ]);
  }

  Widget ReflectionPromptSection() {
    return Text(widget.content.question, style: promptTextStyle, textAlign: TextAlign.center);
  }

  Widget ThoughtOptionsSection() {
    return Div.column(getThoughtOptionsList());
  }

  List<Widget> getThoughtOptionsList() {
    return widget.content.options.asMap().entries.map((entry) {
      final int optionIndex = entry.key;
      final QuestionOption option = entry.value;

      return Div.column([
        ThoughtOption(optionIndex: optionIndex, option: option),

        const Spacing.height(16),
      ]);
    }).toList();
  }

  Widget ThoughtOption({required int optionIndex, required QuestionOption option}) {
    final bool isSelected = selectedAnswerIndex == optionIndex;
    final bool isCorrectAnswer = widget.content.correctAnswerIndices.contains(optionIndex);

    final BoxDecoration decoration = getThoughtOptionDecoration(
      isSelected: isSelected,
      hasReflected: hasReflected,
      isCorrect: isCorrectAnswer,
    );

    final TextStyle textStyle = getThoughtTextStyle(
      isSelected: isSelected,
      hasReflected: hasReflected,
      isCorrect: isCorrectAnswer,
    );

    final bool shouldShowCheckIcon = hasReflected && isCorrectAnswer;

    VoidCallback? tapCallback;

    if (!hasReflected) {
      tapCallback = () => handleThoughtSelection(optionIndex);
    }

    return Div.row(
      [
        // Show check icon for correct answer after reflection
        RenderIf.condition(shouldShowCheckIcon, Div.row([CheckIcon, const Spacing.width(12)])),

        Expanded(child: Text(option.text, style: textStyle)),
      ],
      padding: 20,
      decoration: decoration,
      onTap: tapCallback,
    );
  }

  Widget ReflectionInsightSection() {
    return RenderIf.condition(hasReflected, ReflectionInsightContent());
  }

  Widget ReflectionInsightContent() {
    final Widget InsightIcon = Icon(
      Icons.auto_awesome,
      color: RLDS.primaryGreen.withValues(alpha: 0.8),
      size: 20,
    );

    return Div.column(
      [
        Div.row([
          InsightIcon,

          const Spacing.width(8),

          Text(
            'Insight',
            style: RLTypography.bodyLargeStyle.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: RLDS.primaryGreen,
            ),
          ),
        ]),

        const Spacing.height(12),

        Text(
          widget.content.explanation,
          style: RLTypography.bodyMediumStyle.copyWith(
            fontSize: 14,
            height: 1.6,
            color: RLDS.textPrimary.withValues(alpha: 0.9),
          ),
        ),
      ],
      padding: 20,
      color: RLDS.primaryGreen.withValues(alpha: 0.05),
      radius: 12,
    );
  }

  BoxDecoration getThoughtOptionDecoration({
    required bool isSelected,
    required bool hasReflected,
    required bool isCorrect,
  }) {
    if (hasReflected && isCorrect) {
      return reflectedDecoration;
    }

    if (isSelected && !hasReflected) {
      return selectedThoughtDecoration;
    }

    if (hasReflected) {
      return thoughtDecoration.copyWith(color: RLDS.backgroundLight.withValues(alpha: 0.5));
    }

    return thoughtDecoration;
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
      return normalDecoration.copyWith(color: RLDS.backgroundLight.withValues(alpha: 0.5));
    }

    return normalDecoration;
  }

  TextStyle getThoughtTextStyle({
    required bool isSelected,
    required bool hasReflected,
    required bool isCorrect,
  }) {
    Color textColor = RLDS.textPrimary;
    FontWeight fontWeight = FontWeight.normal;

    if (hasReflected && isCorrect) {
      textColor = RLDS.primaryGreen;
      fontWeight = FontWeight.w500;
    } else if (hasReflected && !isCorrect) {
      textColor = RLDS.textPrimary.withValues(alpha: 0.5);
    } else if (isSelected && !hasReflected) {
      fontWeight = FontWeight.w500;
      textColor = RLDS.primaryBlue;
    }

    return RLTypography.bodyMediumStyle.copyWith(
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
