import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/models/CourseModel.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLTheme.dart';
import 'package:readlock/utility_widgets/FeedbackSnackbar.dart';
import 'package:readlock/services/SoundService.dart';
import 'package:readlock/services/HapticsService.dart';

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
      padding: 24,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }

  Widget QuestionTextSection() {
    final String questionText = widget.content.question;
    return RLTypography.text(questionText);
  }

  Widget OptionsListSection() {
    final List<Widget> optionWidgets = buildOptionWidgets();
    return Div.column(optionWidgets);
  }

  List<Widget> buildOptionWidgets() {
    final List<Widget> optionWidgets = [];

    for (
      int optionIndex = 0;
      optionIndex < widget.content.options.length;
      optionIndex++
    ) {
      final QuestionOption option = widget.content.options[optionIndex];

      optionWidgets.add(
        OptionButtonWidget(optionIndex: optionIndex, option: option),
      );

      // Add spacing after each option except the last one
      final bool isLastOption =
          optionIndex == widget.content.options.length - 1;
      final bool shouldAddSpacing = !isLastOption;

      optionWidgets.add(
        RenderIf.condition(
          shouldAddSpacing,

          const Spacing.height(SINGLE_CHOICE_OPTION_SPACING),

          const SizedBox.shrink(),
        ),
      );
    }

    return optionWidgets;
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

    final BoxDecoration buttonDecoration = getOptionButtonDecoration(
      isSelected: isSelected,
      shouldShowCorrect: shouldShowCorrect,
      shouldShowIncorrect: shouldShowIncorrect,
      shouldMute: shouldMute,
    );

    // Extract tap callback logic from UI
    final VoidCallback? buttonTapCallback = hasAnsweredQuestion
        ? null
        : () => handleOptionSelection(optionIndex);

    final TextStyle optionTextStyle = getOptionButtonTextStyle(
      isSelected: isSelected,
      shouldShowCorrect: shouldShowCorrect,
      shouldShowIncorrect: shouldShowIncorrect,
      shouldMute: shouldMute,
    );

    final Widget optionText = Text(option.text, style: optionTextStyle);

    return Div.row(
      [
        Expanded(child: optionText),

        // Visual feedback indicators
        RenderIf.condition(
          shouldShowCorrect,

          const Icon(
            Icons.check_circle,
            color: RLTheme.primaryGreen,
            size: 20,
          ),

          const SizedBox.shrink(),
        ),

        RenderIf.condition(
          shouldShowIncorrect,

          Icon(
            Icons.cancel,
            color: RLTheme.textPrimary.withValues(alpha: 0.6),
            size: 20,
          ),

          const SizedBox.shrink(),
        ),
      ],
      padding: RLTheme.contentPaddingMediumInsets,
      decoration: buttonDecoration,
      onTap: buttonTapCallback,
    );
  }

  void handleOptionSelection(int optionIndex) {
    final bool alreadyAnswered = hasAnsweredQuestion;

    if (alreadyAnswered) {
      return;
    }

    // Provide light haptic feedback for option selection
    HapticsService.lightImpact();

    final bool isCorrectAnswer = widget.content.correctAnswerIndices
        .contains(optionIndex);

    if (!isCorrectAnswer) {
      showIncorrectAnswerFeedback(optionIndex);
      return;
    }

    markQuestionAsAnswered(optionIndex);
    showCorrectAnswerFeedback(optionIndex);
    SoundService.playCorrectAnswer();

    // Provide medium impact feedback for correct answer
    HapticsService.mediumImpact();

    widget.onAnswerSelected(optionIndex, isCorrectAnswer);
  }

  void showIncorrectAnswerFeedback(int optionIndex) {
    final QuestionOption selectedOption =
        widget.content.options[optionIndex];
    final String consequenceMessage =
        selectedOption.consequenceMessage ??
        widget.content.hint ??
        'Try again and think about the design principle.';

    FeedbackSnackBar.showWrongAnswer(context, hint: consequenceMessage);
  }

  void showCorrectAnswerFeedback(int optionIndex) {
    final QuestionOption selectedOption =
        widget.content.options[optionIndex];
    final String feedbackMessage =
        selectedOption.consequenceMessage ?? widget.content.explanation;

    FeedbackSnackBar.showCorrectAnswer(
      context,
      explanation: feedbackMessage,
    );
  }

  void markQuestionAsAnswered(int selectedIndex) {
    setState(() {
      selectedAnswerIndex = selectedIndex;
      hasAnsweredQuestion = true;
    });
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
