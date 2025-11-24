// Widget for displaying fill-in-the-gap questions with draggable answer options
// Users drag answers to fill blanks in sentences with visual feedback

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/app_constants.dart';
import 'package:readlock/course_screens/models/course_model.dart';
import 'package:readlock/utility_widgets/utility_widgets.dart';
import 'package:readlock/constants/typography.dart';
import 'package:readlock/constants/app_theme.dart';
import 'package:readlock/utility_widgets/text_animation/progressive_text.dart';
import 'package:readlock/utility_widgets/feedback_snackbar.dart';

const double FILL_GAP_OPTION_HEIGHT = 48.0;
const double FILL_GAP_OPTION_SPACING = 12.0;
const double FILL_GAP_SECTION_SPACING = 24.0;
const double FILL_GAP_BLANK_WIDTH = 120.0;
const double FILL_GAP_BLANK_HEIGHT = 40.0;
const int FILL_GAP_ANIMATION_DURATION_MS = 300;
const int FILL_GAP_SHAKE_DURATION_MS = 500;

class FillGapQuestionWidget extends StatefulWidget {
  final QuestionContent content;
  final void Function(int selectedIndex, bool isCorrect)
  onAnswerSelected;

  const FillGapQuestionWidget({
    super.key,
    required this.content,
    required this.onAnswerSelected,
  });

  @override
  State<FillGapQuestionWidget> createState() =>
      FillGapQuestionWidgetState();
}

class FillGapQuestionWidgetState extends State<FillGapQuestionWidget>
    with TickerProviderStateMixin {
  Map<int, int?> selectedOptionsForGaps = {};
  bool hasAnswered = false;
  AnimationController? shakeController;
  Animation<double>? shakeAnimation;
  Set<int> usedOptionIndices = {};

  @override
  void initState() {
    super.initState();
    initializeGaps();
  }

  void initializeGaps() {
    final int numberOfGaps = countGapsInQuestion();
    selectedOptionsForGaps = Map.fromEntries(
      List.generate(numberOfGaps, (index) => MapEntry(index, null)),
    );
  }

  int countGapsInQuestion() {
    return '___'.allMatches(widget.content.question).length;
  }

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
            QuestionWithGaps(),

            const Spacing.height(FILL_GAP_SECTION_SPACING),

            AvailableOptions(),

            const Spacing.height(FILL_GAP_SECTION_SPACING),

            SubmitButton(),

            const Spacing.height(FILL_GAP_SECTION_SPACING),

            ExplanationSection(),
          ],
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
    );
  }

  Widget QuestionWithGaps() {
    final List<String> questionParts = widget.content.question.split(
      '___',
    );

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 12,
      children: [
        ...questionParts.asMap().entries.expand((entry) {
          final int index = entry.key;
          final String part = entry.value;

          return [
            if (part.isNotEmpty)
              Text(
                part,
                style: Typography.bodyLargeStyle.copyWith(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            if (index < questionParts.length - 1)
              GapWidget(gapIndex: index),
          ];
        }),
      ],
    );
  }

  Widget GapWidget({required int gapIndex}) {
    final int? selectedOptionIndex = selectedOptionsForGaps[gapIndex];
    final bool hasSelection = selectedOptionIndex != null;
    final bool isCorrect =
        hasAnswered &&
        hasSelection &&
        widget.content.correctAnswerIndices.contains(
          selectedOptionIndex,
        );
    final bool isIncorrect = hasAnswered && hasSelection && !isCorrect;

    Color backgroundColor;
    Color borderColor;
    String displayText;

    if (hasAnswered) {
      if (isCorrect) {
        backgroundColor = AppTheme.primaryGreen.withValues(alpha: 0.1);
        borderColor = AppTheme.primaryGreen;
      } else if (isIncorrect) {
        backgroundColor = AppTheme.backgroundLight;
        borderColor = AppTheme.textPrimary.withValues(alpha: 0.3);
      } else {
        backgroundColor = AppTheme.backgroundLight;
        borderColor = AppTheme.textPrimary.withValues(alpha: 0.2);
      }
    } else if (hasSelection) {
      backgroundColor = AppTheme.primaryBlue.withValues(alpha: 0.1);
      borderColor = AppTheme.primaryBlue;
    } else {
      backgroundColor = AppTheme.backgroundLight;
      borderColor = AppTheme.textPrimary.withValues(alpha: 0.2);
    }

    if (hasSelection) {
      displayText = widget.content.options[selectedOptionIndex].text;
    } else {
      displayText = '______';
    }

    final Widget gapContainer = Div.column(
      [
        Center(
          child: Text(
            displayText,
            style: Typography.bodyLargeStyle.copyWith(
              fontSize: 14,
              fontWeight: hasSelection
                  ? FontWeight.w500
                  : FontWeight.normal,
              color: hasSelection
                  ? AppTheme.textPrimary
                  : AppTheme.textPrimary.withValues(alpha: 0.3),
            ),
          ),
        ),
      ],
      width: FILL_GAP_BLANK_WIDTH,
      height: FILL_GAP_BLANK_HEIGHT,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 2),
      ),
      onTap: hasAnswered ? null : () => clearGapSelection(gapIndex),
    );

    if (isIncorrect && shakeAnimation != null) {
      return AnimatedBuilder(
        animation: shakeAnimation!,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(shakeAnimation!.value * 10, 0),
            child: child,
          );
        },
        child: gapContainer,
      );
    }

    return gapContainer;
  }

  Widget AvailableOptions() {
    return Div.column([
      Text(
        'Tap options to fill the gaps:',
        style: Typography.bodyLargeStyle.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppTheme.textPrimary.withValues(alpha: 0.7),
        ),
      ),

      const Spacing.height(12),

      Wrap(
        spacing: FILL_GAP_OPTION_SPACING,
        runSpacing: FILL_GAP_OPTION_SPACING,
        children: List.generate(
          widget.content.options.length,
          (optionIndex) => OptionChip(optionIndex: optionIndex),
        ),
      ),
    ]);
  }

  Widget OptionChip({required int optionIndex}) {
    final bool isUsed = usedOptionIndices.contains(optionIndex);
    final bool isDisabled = isUsed && !hasAnswered;
    final bool isCorrectOption =
        hasAnswered &&
        widget.content.correctAnswerIndices.contains(optionIndex);

    Color chipColor;
    Color borderColor;
    Color textColor;

    if (hasAnswered && isCorrectOption) {
      chipColor = AppTheme.primaryGreen.withValues(alpha: 0.1);
      borderColor = AppTheme.primaryGreen;
      textColor = AppTheme.primaryGreen;
    } else if (isUsed) {
      chipColor = AppTheme.textPrimary.withValues(alpha: 0.05);
      borderColor = AppTheme.textPrimary.withValues(alpha: 0.1);
      textColor = AppTheme.textPrimary.withValues(alpha: 0.3);
    } else {
      chipColor = AppTheme.backgroundLight;
      borderColor = AppTheme.primaryBlue.withValues(alpha: 0.3);
      textColor = AppTheme.textPrimary;
    }

    return Div.row(
      [
        Text(
          widget.content.options[optionIndex].text,
          style: Typography.bodyLargeStyle.copyWith(
            fontSize: 14,
            color: textColor,
            fontWeight: isCorrectOption
                ? FontWeight.w600
                : FontWeight.normal,
            decoration: isUsed && !isCorrectOption
                ? TextDecoration.lineThrough
                : null,
          ),
        ),
      ],
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      onTap: isDisabled ? null : () => selectOption(optionIndex),
    );
  }

  Widget SubmitButton() {
    final bool allGapsFilled = selectedOptionsForGaps.values.every(
      (selectedOption) => selectedOption != null,
    );
    final bool canSubmit = allGapsFilled && !hasAnswered;

    return Div.row(
      [
        Center(
          child: Text(
            hasAnswered ? 'Submitted' : 'Submit Answer',
            style: Typography.bodyLargeStyle.copyWith(
              color: canSubmit
                  ? Colors.white
                  : AppTheme.textPrimary.withValues(alpha: 0.4),
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ],
      height: 48,
      color: canSubmit
          ? AppTheme.primaryBlue
          : AppTheme.backgroundLight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: canSubmit
              ? AppTheme.primaryBlue
              : AppTheme.textPrimary.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      onTap: canSubmit ? checkAnswer : null,
    );
  }

  Widget ExplanationSection() {
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

            Text(
              'Explanation',
              style: Typography.bodyLargeStyle.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppTheme.textPrimary.withValues(alpha: 0.8),
              ),
            ),
          ]),

          const Spacing.height(12),

          ProgressiveText(
            textSegments: [widget.content.explanation],
            textStyle: Typography.bodyLargeStyle.copyWith(
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
        padding: 16,
        color: AppTheme.backgroundLight,
        radius: 12,
      ),
    );
  }

  void selectOption(int optionIndex) {
    if (hasAnswered || usedOptionIndices.contains(optionIndex)) {
      return;
    }

    final int? firstEmptyGap = findFirstEmptyGap();
    if (firstEmptyGap != null) {
      setState(() {
        selectedOptionsForGaps[firstEmptyGap] = optionIndex;
        usedOptionIndices.add(optionIndex);
      });
    }
  }

  int? findFirstEmptyGap() {
    return selectedOptionsForGaps.entries
        .where((entry) => entry.value == null)
        .map((entry) => entry.key)
        .firstOrNull;
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
    final bool allCorrect = selectedOptionsForGaps.entries.every((
      entry,
    ) {
      final int gapIndex = entry.key;
      final int? selectedOption = entry.value;
      if (selectedOption == null) {
        return false;
      }
      return widget.content.correctAnswerIndices[gapIndex] ==
          selectedOption;
    });

    setState(() {
      hasAnswered = true;
    });

    if (allCorrect) {
      FeedbackSnackBar.showCorrectAnswer(context);
    } else {
      showCorrectAnswers();
      triggerShakeAnimation();
      FeedbackSnackBar.showWrongAnswer(
        context,
        explanation: widget.content.explanation,
      );
    }

    widget.onAnswerSelected(0, allCorrect);
  }

  void triggerShakeAnimation() {
    shakeController = AnimationController(
      duration: const Duration(
        milliseconds: FILL_GAP_SHAKE_DURATION_MS,
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

  void showCorrectAnswers() {
    setState(() {
      for (
        int gapIndex = 0;
        gapIndex < widget.content.correctAnswerIndices.length;
        gapIndex++
      ) {
        selectedOptionsForGaps[gapIndex] =
            widget.content.correctAnswerIndices[gapIndex];
        usedOptionIndices.add(
          widget.content.correctAnswerIndices[gapIndex],
        );
      }
    });
  }
}
