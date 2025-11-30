import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/RLConstants.dart';
import 'package:readlock/course_screens/models/courseModel.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLTheme.dart';
import 'package:readlock/utility_widgets/FeedbackSnackbar.dart';

const double REFLECTION_SECTION_SPACING = 28.0;
const double REFLECTION_OPTION_SPACING = 16.0;
const double REFLECTION_THOUGHT_SPACING = 12.0;

class ThoughtTextStyleConfig {
  final Color color;
  final FontWeight fontWeight;

  const ThoughtTextStyleConfig({
    required this.color,
    required this.fontWeight,
  });
}

class CCReflectionQuestion extends StatefulWidget {
  final QuestionContent content;
  final void Function(int selectedIndex, bool isCorrect)
  onAnswerSelected;

  const CCReflectionQuestion({
    super.key,
    required this.content,
    required this.onAnswerSelected,
  });

  @override
  State<CCReflectionQuestion> createState() =>
      CCReflectionQuestionState();
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
      color: RLTheme.backgroundLight,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: RLTheme.textPrimary.withValues(alpha: 0.1),
        width: 1,
      ),
    );

    selectedThoughtDecoration = BoxDecoration(
      color: RLTheme.primaryBlue.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: RLTheme.primaryBlue.withValues(alpha: 0.5),
        width: 2,
      ),
    );

    reflectedDecoration = BoxDecoration(
      color: RLTheme.primaryGreen.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: RLTheme.primaryGreen.withValues(alpha: 0.4),
        width: 1.5,
      ),
    );

    headerTextStyle = RLTypography.headingMediumStyle.copyWith(
      fontSize: 18,
      color: RLTheme.textPrimary.withValues(alpha: 0.9),
    );

    promptTextStyle = RLTypography.bodyLargeStyle.copyWith(
      fontSize: 16,
      height: 1.6,
    );

    insightHeaderTextStyle = RLTypography.bodyLargeStyle.copyWith(
      fontWeight: FontWeight.w600,
      fontSize: 14,
      color: RLTheme.primaryGreen,
    );

    insightContentTextStyle = RLTypography.bodyMediumStyle.copyWith(
      fontSize: 14,
      height: 1.6,
      color: RLTheme.textPrimary.withValues(alpha: 0.9),
    );
  }

  void initializeIcons() {
    ReflectionIcon = Icon(
      Icons.self_improvement,
      color: RLTheme.primaryBlue.withValues(alpha: 0.7),
      size: 32,
    );

    CheckIcon = Icon(
      Icons.check_circle_outline,
      color: RLTheme.primaryGreen,
      size: 20,
    );

    InsightIcon = Icon(
      Icons.auto_awesome,
      color: RLTheme.primaryGreen.withValues(alpha: 0.8),
      size: 20,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Div.column(
      [
        // Reflection header with icon and title
        ReflectionHeaderSection(),

        const Spacing.height(REFLECTION_SECTION_SPACING),

        // Reflection question prompt
        ReflectionPromptSection(),

        const Spacing.height(REFLECTION_SECTION_SPACING),

        // Thought options for selection
        ThoughtOptionsSection(),

        const Spacing.height(REFLECTION_SECTION_SPACING),

        // Reflection insight after selection
        ReflectionInsightSection(),
      ],
      color: RLTheme.backgroundDark,
      padding: 24,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }

  Widget ReflectionHeaderSection() {
    return Div.column([
      Center(child: ReflectionIcon),

      const Spacing.height(12),

      Center(
        child: Text('Take a Moment to Reflect', style: headerTextStyle),
      ),
    ]);
  }

  Widget ReflectionPromptSection() {
    return Text(
      widget.content.question,
      style: promptTextStyle,
      textAlign: TextAlign.center,
    );
  }

  Widget ThoughtOptionsSection() {
    return Div.column(getThoughtOptionsList());
  }

  List<Widget> getThoughtOptionsList() {
    return widget.content.options.asMap().entries.map((entry) {
      final int optionIndex = entry.key;
      final QuestionOption option = entry.value;

      return Div.column([
        ThoughtOptionWidget(optionIndex: optionIndex, option: option),

        const Spacing.height(REFLECTION_OPTION_SPACING),
      ]);
    }).toList();
  }

  Widget ThoughtOptionWidget({
    required int optionIndex,
    required QuestionOption option,
  }) {
    final bool isSelected = selectedAnswerIndex == optionIndex;
    final bool isCorrectAnswer = widget.content.correctAnswerIndices
        .contains(optionIndex);

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

    return Div.row(
      [
        // Show check icon for correct answer after reflection
        if (hasReflected && isCorrectAnswer) ...[
          CheckIcon,
          const Spacing.width(12),
        ],

        Expanded(child: Text(option.text, style: textStyle)),
      ],
      padding: 20,
      decoration: decoration,
      onTap: hasReflected
          ? null
          : () => handleThoughtSelection(optionIndex),
    );
  }

  Widget ReflectionInsightSection() {
    if (!hasReflected) {
      return const SizedBox.shrink();
    }

    final Widget InsightIcon = Icon(
      Icons.auto_awesome,
      color: RLTheme.primaryGreen.withValues(alpha: 0.8),
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
              color: RLTheme.primaryGreen,
            ),
          ),
        ]),

        const Spacing.height(12),

        Text(
          widget.content.explanation,
          style: RLTypography.bodyMediumStyle.copyWith(
            fontSize: 14,
            height: 1.6,
            color: RLTheme.textPrimary.withValues(alpha: 0.9),
          ),
        ),
      ],
      padding: 20,
      color: RLTheme.primaryGreen.withValues(alpha: 0.05),
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
      return thoughtDecoration.copyWith(
        color: RLTheme.backgroundLight.withValues(alpha: 0.5),
      );
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
      return normalDecoration.copyWith(
        color: RLTheme.backgroundLight.withValues(alpha: 0.5),
      );
    }

    return normalDecoration;
  }

  TextStyle getThoughtTextStyle({
    required bool isSelected,
    required bool hasReflected,
    required bool isCorrect,
  }) {
    Color textColor = RLTheme.textPrimary;
    FontWeight fontWeight = FontWeight.normal;

    if (hasReflected && isCorrect) {
      textColor = RLTheme.primaryGreen;
      fontWeight = FontWeight.w500;
    } else if (hasReflected && !isCorrect) {
      textColor = RLTheme.textPrimary.withValues(alpha: 0.5);
    } else if (isSelected && !hasReflected) {
      fontWeight = FontWeight.w500;
      textColor = RLTheme.primaryBlue;
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
    final bool isCorrectAnswer = widget.content.correctAnswerIndices
        .contains(optionIndex);

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
