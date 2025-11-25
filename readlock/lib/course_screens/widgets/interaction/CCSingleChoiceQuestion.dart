import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/RLConstants.dart';
import 'package:readlock/course_screens/models/courseModel.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLTheme.dart';
import 'package:readlock/utility_widgets/FeedbackSnackbar.dart';
import 'package:readlock/utility_widgets/text_animation/ProgressiveText.dart';

enum SingleChoiceButtonState {
  normal,
  selected,
  correctAndAnswered,
  incorrectAndAnswered,
}

const double SINGLE_CHOICE_OPTION_SPACING = 16.0;
const double SINGLE_CHOICE_SECTION_SPACING = 32.0;

class CCSingleChoice extends StatefulWidget {
  final QuestionContent content;
  final void Function(int selectedIndex, bool isCorrect)
  onAnswerSelected;

  const CCSingleChoice({
    super.key,
    required this.content,
    required this.onAnswerSelected,
  });

  @override
  State<CCSingleChoice> createState() => CCSingleChoiceState();
}

class CCSingleChoiceState extends State<CCSingleChoice> {
  int? selectedAnswerIndex;
  bool hasAnsweredQuestion = false;

  // Style definitions
  late final BoxDecoration normalOptionDecoration;
  late final BoxDecoration selectedOptionDecoration;
  late final BoxDecoration correctOptionDecoration;
  late final BoxDecoration incorrectOptionDecoration;

  @override
  void initState() {
    super.initState();
    initializeStyles();
  }

  void initializeStyles() {
    final optionRadius = BorderRadius.circular(16);

    normalOptionDecoration = BoxDecoration(
      color: RLTheme.backgroundLight,
      borderRadius: optionRadius,
    );

    selectedOptionDecoration = BoxDecoration(
      color: RLTheme.backgroundLight,
      borderRadius: optionRadius,
    );

    correctOptionDecoration = BoxDecoration(
      color: RLTheme.primaryGreen.withValues(alpha: 0.1),
      borderRadius: optionRadius,
    );

    incorrectOptionDecoration = BoxDecoration(
      color: RLTheme.backgroundLight,
      borderRadius: optionRadius,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Div.column(
      [
        // Question text section
        QuestionTextSection(),

        const Spacing.height(SINGLE_CHOICE_SECTION_SPACING),

        // Single choice options
        OptionsListSection(),

        const Spacing.height(SINGLE_CHOICE_SECTION_SPACING),
      ],
      color: RLTheme.backgroundDark,
      padding: RLConstants.COURSE_SECTION_PADDING,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }

  Widget QuestionTextSection() {
    return RLTypography.text(widget.content.question);
  }

  Widget OptionsListSection() {
    return Div.column(getOptionWidgetsList());
  }

  List<Widget> getOptionWidgetsList() {
    return widget.content.options.asMap().entries.map((entry) {
      final int optionIndex = entry.key;
      final QuestionOption option = entry.value;

      return Div.column([
        OptionButtonWidget(optionIndex: optionIndex, option: option),

        const Spacing.height(SINGLE_CHOICE_OPTION_SPACING),
      ]);
    }).toList();
  }

  Widget OptionButtonWidget({
    required int optionIndex,
    required QuestionOption option,
  }) {
    final bool isSelected = selectedAnswerIndex == optionIndex;
    final bool isCorrectAnswer = widget.content.correctAnswerIndices
        .contains(optionIndex);
    final bool shouldShowCorrect =
        hasAnsweredQuestion && isCorrectAnswer && isSelected;
    final bool shouldShowIncorrect =
        hasAnsweredQuestion && !isCorrectAnswer && isSelected;
    final bool shouldMute =
        hasAnsweredQuestion && !isCorrectAnswer && !isSelected;

    final BoxDecoration decoration = getOptionButtonDecoration(
      isSelected: isSelected,
      shouldShowCorrect: shouldShowCorrect,
      shouldShowIncorrect: shouldShowIncorrect,
      shouldMute: shouldMute,
    );
    return Div.row(
      [
        Expanded(
          child: ProgressiveText(textSegments: [option.text]),
        ),
      ],
      padding: RLTheme.contentPaddingMediumInsets,
      decoration: decoration,
      onTap: hasAnsweredQuestion
          ? null
          : () => handleOptionSelection(optionIndex),
    );
  }

  void handleOptionSelection(int optionIndex) {
    if (hasAnsweredQuestion) {
      return;
    }

    final bool isCorrect = widget.content.correctAnswerIndices.contains(
      optionIndex,
    );

    if (!isCorrect) {
      FeedbackSnackBar.showWrongAnswer(
        context,
        hint: widget.content.hint,
      );
      return;
    }

    setState(() {
      selectedAnswerIndex = optionIndex;
      hasAnsweredQuestion = true;
    });

    FeedbackSnackBar.showCorrectAnswer(
      context,
      explanation: widget.content.explanation,
    );
    widget.onAnswerSelected(optionIndex, isCorrect);
  }

  BoxDecoration getOptionButtonDecoration({
    required bool isSelected,
    required bool shouldShowCorrect,
    required bool shouldShowIncorrect,
    required bool shouldMute,
  }) {
    if (shouldShowCorrect) {
      return correctOptionDecoration;
    }

    if (shouldShowIncorrect || shouldMute) {
      return incorrectOptionDecoration;
    }

    if (isSelected && !hasAnsweredQuestion) {
      return selectedOptionDecoration;
    }

    return normalOptionDecoration;
  }

  TextStyle getOptionButtonTextStyle({
    required bool isSelected,
    required bool shouldShowCorrect,
    required bool shouldShowIncorrect,
    required bool shouldMute,
  }) {
    if (shouldShowCorrect) {
      return RLTypography.bodyMediumStyle.copyWith(
        color: RLTheme.primaryGreen,
      );
    }

    if (shouldMute) {
      return RLTypography.bodyMediumStyle.copyWith(
        color: RLTheme.textPrimary.withValues(alpha: 0.4),
      );
    }

    return RLTypography.bodyMediumStyle;
  }
}
