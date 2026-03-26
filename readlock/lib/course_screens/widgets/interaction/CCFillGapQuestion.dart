// Widget for displaying fill-in-the-gap questions with tappable answer options
// Users tap options to fill blanks in sentences with visual feedback

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/models/CourseModel.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/utility_widgets/text_animation/ProgressiveText.dart';
import 'package:readlock/utility_widgets/FeedbackSnackbar.dart';
import 'package:readlock/constants/RLUIStrings.dart';

class CCFillGapQuestion extends StatefulWidget {
  final FillGapQuestionContent content;
  final void Function(int selectedIndex, bool isCorrect) onAnswerSelected;

  const CCFillGapQuestion({super.key, required this.content, required this.onAnswerSelected});

  @override
  State<CCFillGapQuestion> createState() => CCFillGapQuestionState();
}

class CCFillGapQuestionState extends State<CCFillGapQuestion> with TickerProviderStateMixin {
  // State
  Map<int, int?> selectedOptionsForGaps = {};
  bool hasAnswered = false;
  Set<int> usedOptionIndices = {};

  // Shake animation
  AnimationController? shakeController;
  Animation<double>? shakeAnimation;

  @override
  void initState() {
    super.initState();
    initializeGaps();
  }

  void initializeGaps() {
    final int numberOfGaps = '___'.allMatches(widget.content.question).length;

    selectedOptionsForGaps = Map.fromEntries(
      List.generate(numberOfGaps, (index) => MapEntry(index, null)),
    );
  }

  @override
  void dispose() {
    shakeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Div.column(
      [
        // Question with inline gaps
        QuestionWithGaps(),

        const Spacing.height(24),

        // Tappable options
        AvailableOptions(),

        const Spacing.height(24),

        // Submit
        SubmitButton(),

        const Spacing.height(24),

        // Explanation (shown after answering)
        ExplanationSection(),
      ],
      color: RLDS.backgroundDark,
      padding: 20,
      crossAxisAlignment: CrossAxisAlignment.stretch,
    );
  }

  // * Question display

  Widget QuestionWithGaps() {
    final List<String> questionParts = widget.content.question.split('___');
    final List<Widget> questionWidgets = [];

    for (int partIndex = 0; partIndex < questionParts.length; partIndex++) {
      final String part = questionParts[partIndex];
      final bool isLastPart = partIndex == questionParts.length - 1;

      final bool hasPartText = part.isNotEmpty;

      if (hasPartText) {
        questionWidgets.add(RLTypography.bodyLarge(part));
      }

      if (!isLastPart) {
        questionWidgets.add(GapSlot(gapIndex: partIndex));
      }
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 16,
      children: questionWidgets,
    );
  }

  Widget GapSlot({required int gapIndex}) {
    final int? selectedOptionIndex = selectedOptionsForGaps[gapIndex];
    final bool hasSelection = selectedOptionIndex != null;
    final bool isCorrect = getIsGapCorrect(gapIndex, selectedOptionIndex);
    final bool isIncorrect = hasAnswered && hasSelection && !isCorrect;

    // Styling
    final Color backgroundColor = getGapBackgroundColor(hasSelection, isCorrect, isIncorrect);
    final Color borderColor = getGapBorderColor(hasSelection, isCorrect, isIncorrect);

    final String displayText = hasSelection
        ? widget.content.options[selectedOptionIndex].text
        : '______';

    final Color textColor = hasSelection
        ? RLDS.textPrimary
        : RLDS.textPrimary.withValues(alpha: 0.4);

    final FontWeight textWeight = hasSelection ? FontWeight.w600 : FontWeight.normal;

    final BoxDecoration gapDecoration = BoxDecoration(
      color: backgroundColor,
      borderRadius: RLDS.borderRadiusSmall,
      border: Border.all(color: borderColor, width: 1.5),
    );

    VoidCallback? gapTapHandler;

    if (!hasAnswered) {
      gapTapHandler = () => clearGapSelection(gapIndex);
    }

    // Gap chip — sizes to content via IntrinsicWidth
    final Widget gapWidget = Div.row(
      [RLTypography.bodyMedium(displayText, color: textColor)],
      padding: const [16, 8],
      decoration: gapDecoration,
      mainAxisAlignment: MainAxisAlignment.center,
      onTap: gapTapHandler,
    );

    // Shake if incorrect
    final bool shouldShake = isIncorrect && shakeAnimation != null;

    if (shouldShake) {
      return AnimatedBuilder(
        animation: shakeAnimation!,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(shakeAnimation!.value * 10, 0),
            child: child,
          );
        },
        child: gapWidget,
      );
    }

    return gapWidget;
  }

  Color getGapBackgroundColor(bool hasSelection, bool isCorrect, bool isIncorrect) {
    if (hasAnswered && isCorrect) {
      return RLDS.primaryGreen.withValues(alpha: 0.15);
    }

    if (isIncorrect) {
      return RLDS.errorColor.withValues(alpha: 0.08);
    }

    if (hasSelection) {
      return RLDS.primaryBlue.withValues(alpha: 0.12);
    }

    return RLDS.backgroundLight;
  }

  Color getGapBorderColor(bool hasSelection, bool isCorrect, bool isIncorrect) {
    if (hasAnswered && isCorrect) {
      return RLDS.primaryGreen;
    }

    if (isIncorrect) {
      return RLDS.errorColor.withValues(alpha: 0.5);
    }

    if (hasSelection) {
      return RLDS.primaryBlue;
    }

    return RLDS.textPrimary.withValues(alpha: 0.25);
  }

  bool getIsGapCorrect(int gapIndex, int? selectedOptionIndex) {
    if (!hasAnswered || selectedOptionIndex == null) {
      return false;
    }

    return widget.content.correctAnswerIndices.contains(selectedOptionIndex);
  }

  // * Options

  Widget AvailableOptions() {
    final List<Widget> optionChips = [];

    for (int optionIndex = 0; optionIndex < widget.content.options.length; optionIndex++) {
      optionChips.add(OptionChip(optionIndex: optionIndex));
    }

    return Div.column([
      RLTypography.bodyMedium(
        RLUIStrings.FILL_GAP_INSTRUCTION,
        color: RLDS.textPrimary.withValues(alpha: 0.8),
      ),

      const Spacing.height(16),

      Wrap(spacing: 12, runSpacing: 12, children: optionChips),
    ]);
  }

  Widget OptionChip({required int optionIndex}) {
    final bool isUsed = usedOptionIndices.contains(optionIndex);
    final bool isDisabled = isUsed && !hasAnswered;
    final bool isCorrectOption =
        hasAnswered && widget.content.correctAnswerIndices.contains(optionIndex);

    // Colors
    Color backgroundColor;
    Color borderColor;
    Color textColor;

    if (isCorrectOption) {
      backgroundColor = RLDS.primaryGreen.withValues(alpha: 0.12);
      borderColor = RLDS.primaryGreen;
      textColor = RLDS.primaryGreen;
    } else if (isUsed) {
      backgroundColor = RLDS.textPrimary.withValues(alpha: 0.03);
      borderColor = RLDS.textPrimary.withValues(alpha: 0.15);
      textColor = RLDS.textPrimary.withValues(alpha: 0.35);
    } else {
      backgroundColor = RLDS.backgroundLight;
      borderColor = RLDS.primaryBlue.withValues(alpha: 0.4);
      textColor = RLDS.textPrimary;
    }

    final BoxDecoration decoration = BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: borderColor, width: 1.5),
    );

    VoidCallback? chipTapHandler;

    if (!isDisabled) {
      chipTapHandler = () => selectOption(optionIndex);
    }

    return Div.row(
      [RLTypography.bodyMedium(widget.content.options[optionIndex].text, color: textColor)],
      padding: const [16, 8],
      decoration: decoration,
      onTap: chipTapHandler,
    );
  }

  // * Submit

  Widget SubmitButton() {
    final bool allGapsFilled = selectedOptionsForGaps.values.every((v) => v != null);
    final bool canSubmit = allGapsFilled && !hasAnswered;

    final String buttonText = hasAnswered ? RLUIStrings.FILL_GAP_SUBMITTED_LABEL : RLUIStrings.FILL_GAP_SUBMIT_LABEL;

    final Color buttonColor = canSubmit ? RLDS.primaryBlue : RLDS.backgroundLight;
    final Color buttonTextColor = canSubmit
        ? RLDS.white
        : RLDS.textPrimary.withValues(alpha: 0.4);
    final Color buttonBorderColor = canSubmit
        ? RLDS.primaryBlue
        : RLDS.textPrimary.withValues(alpha: 0.2);

    final BoxDecoration buttonDecoration = BoxDecoration(
      color: buttonColor,
      borderRadius: RLDS.borderRadiusSmall,
      border: Border.all(color: buttonBorderColor, width: 1.5),
    );

    VoidCallback? submitTapHandler;

    if (canSubmit) {
      submitTapHandler = checkAnswer;
    }

    return Div.row(
      [RLTypography.bodyMedium(buttonText, color: buttonTextColor)],
      height: 48,
      decoration: buttonDecoration,
      mainAxisAlignment: MainAxisAlignment.center,
      onTap: submitTapHandler,
    );
  }

  // * Explanation

  Widget ExplanationSection() {
    final bool shouldShowExplanation = hasAnswered;

    final Widget ExplanationIcon = Icon(
      Icons.lightbulb_outline,
      color: RLDS.warningColor,
      size: RLDS.iconMedium,
    );

    return RenderIf.condition(
      shouldShowExplanation,

      Div.column(
        [
          // Header
          Div.row([
            ExplanationIcon,

            const Spacing.width(8),

            RLTypography.bodyMedium(RLUIStrings.FILL_GAP_EXPLANATION_LABEL),
          ]),

          const Spacing.height(12),

          // Body
          ProgressiveText(
            textSegments: [widget.content.explanation],
            textStyle: RLTypography.bodyMediumStyle.copyWith(height: 1.6),
          ),
        ],
        padding: 20,
        color: RLDS.backgroundLight,
        radius: 12,
      ),

      const SizedBox.shrink(),
    );
  }

  // * Actions

  void selectOption(int optionIndex) {
    final bool shouldSkipSelection = hasAnswered || usedOptionIndices.contains(optionIndex);

    if (shouldSkipSelection) {
      return;
    }

    final int? firstEmptyGap = selectedOptionsForGaps.entries
        .where((entry) => entry.value == null)
        .map((entry) => entry.key)
        .firstOrNull;

    if (firstEmptyGap != null) {
      setState(() {
        selectedOptionsForGaps[firstEmptyGap] = optionIndex;
        usedOptionIndices.add(optionIndex);
      });
    }
  }

  void clearGapSelection(int gapIndex) {
    if (hasAnswered) {
      return;
    }

    final int? currentOption = selectedOptionsForGaps[gapIndex];

    if (currentOption != null) {
      setState(() {
        selectedOptionsForGaps[gapIndex] = null;
        usedOptionIndices.remove(currentOption);
      });
    }
  }

  void checkAnswer() {
    final bool allCorrect = selectedOptionsForGaps.entries.every((entry) {
      final int gapIndex = entry.key;
      final int? selectedOption = entry.value;

      if (selectedOption == null) {
        return false;
      }

      return widget.content.correctAnswerIndices[gapIndex] == selectedOption;
    });

    setState(() {
      hasAnswered = true;
    });

    if (allCorrect) {
      FeedbackSnackBar.showCorrectAnswer(context);
    } else {
      showCorrectAnswers();
      triggerShakeAnimation();
      FeedbackSnackBar.showWrongAnswer(context, hint: widget.content.hint);
    }

    widget.onAnswerSelected(0, allCorrect);
  }

  void triggerShakeAnimation() {
    shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: shakeController!, curve: Curves.elasticIn));

    setState(() {});

    shakeController!.forward().then((_) {
      shakeController!.dispose();

      setState(() {
        shakeController = null;
        shakeAnimation = null;
      });
    });
  }

  void showCorrectAnswers() {
    setState(() {
      for (
        int gapIndex = 0;
        gapIndex < widget.content.correctAnswerIndices.length;
        gapIndex++
      ) {
        selectedOptionsForGaps[gapIndex] = widget.content.correctAnswerIndices[gapIndex];
        usedOptionIndices.add(widget.content.correctAnswerIndices[gapIndex]);
      }
    });
  }
}
