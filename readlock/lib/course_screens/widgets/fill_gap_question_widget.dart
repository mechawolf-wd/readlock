// Widget for displaying fill-in-the-gap questions with draggable answer options
// Users drag answers to fill blanks in sentences with visual feedback

import 'package:flutter/material.dart' hide Typography;
import 'package:relevant/constants/app_constants.dart';
import 'package:relevant/course_screens/models/course_model.dart';
import 'package:relevant/utility_widgets/utility_widgets.dart';
import 'package:relevant/constants/typography.dart';
import 'package:relevant/constants/app_theme.dart';
import 'package:relevant/utility_widgets/text_animation/progressive_text.dart';

const double FILL_GAP_OPTION_HEIGHT = 48.0;
const double FILL_GAP_OPTION_SPACING = 12.0;
const double FILL_GAP_SECTION_SPACING = 24.0;
const double FILL_GAP_BLANK_WIDTH = 120.0;
const double FILL_GAP_BLANK_HEIGHT = 40.0;
const int FILL_GAP_ANIMATION_DURATION_MS = 300;
const int FILL_GAP_SHAKE_DURATION_MS = 500;

class FillGapQuestionWidget extends StatefulWidget {
  final QuestionContent content;
  final void Function(int selectedIndex, bool isCorrect) onAnswerSelected;

  const FillGapQuestionWidget({
    super.key,
    required this.content,
    required this.onAnswerSelected,
  });

  @override
  State<FillGapQuestionWidget> createState() => FillGapQuestionWidgetState();
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
    for (int gapIndex = 0; gapIndex < numberOfGaps; gapIndex++) {
      selectedOptionsForGaps[gapIndex] = null;
    }
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
    final List<String> questionParts = widget.content.question.split('___');
    final List<Widget> questionWidgets = [];

    for (int partIndex = 0; partIndex < questionParts.length; partIndex++) {
      if (questionParts[partIndex].isNotEmpty) {
        questionWidgets.add(
          Text(
            questionParts[partIndex],
            style: Typography.bodyLargeStyle.copyWith(
              fontSize: 16,
              height: 1.5,
            ),
          ),
        );
      }

      if (partIndex < questionParts.length - 1) {
        questionWidgets.add(
          GapWidget(gapIndex: partIndex),
        );
      }
    }

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 12,
      children: questionWidgets,
    );
  }

  Widget GapWidget({required int gapIndex}) {
    final int? selectedOptionIndex = selectedOptionsForGaps[gapIndex];
    final bool hasSelection = selectedOptionIndex != null;
    final bool isCorrect = hasAnswered &&
        hasSelection &&
        widget.content.correctAnswerIndices.contains(selectedOptionIndex);
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

    final Widget gapContainer = GestureDetector(
      onTap: hasAnswered ? null : () => clearGapSelection(gapIndex),
      child: Container(
        constraints: const BoxConstraints(
          minWidth: FILL_GAP_BLANK_WIDTH,
          minHeight: FILL_GAP_BLANK_HEIGHT,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Center(
          child: Text(
            displayText,
            style: Typography.bodyLargeStyle.copyWith(
              fontSize: 14,
              fontWeight: hasSelection ? FontWeight.w500 : FontWeight.normal,
              color: hasSelection
                  ? AppTheme.textPrimary
                  : AppTheme.textPrimary.withValues(alpha: 0.3),
            ),
          ),
        ),
      ),
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
    return Div.column(
      [
        Text(
          'Drag options to fill the gaps:',
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
          children: [
            for (int optionIndex = 0;
                optionIndex < widget.content.options.length;
                optionIndex++)
              OptionChip(optionIndex: optionIndex),
          ],
        ),
      ],
    );
  }

  Widget OptionChip({required int optionIndex}) {
    final bool isUsed = usedOptionIndices.contains(optionIndex);
    final bool isDisabled = hasAnswered || isUsed;

    return GestureDetector(
      onTap: isDisabled ? null : () => selectOption(optionIndex),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: FILL_GAP_ANIMATION_DURATION_MS),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isUsed
              ? AppTheme.textPrimary.withValues(alpha: 0.05)
              : AppTheme.backgroundLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isUsed
                ? AppTheme.textPrimary.withValues(alpha: 0.1)
                : AppTheme.primaryBlue.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Text(
          widget.content.options[optionIndex].text,
          style: Typography.bodyLargeStyle.copyWith(
            fontSize: 14,
            color: isUsed
                ? AppTheme.textPrimary.withValues(alpha: 0.3)
                : AppTheme.textPrimary,
            decoration: isUsed ? TextDecoration.lineThrough : null,
          ),
        ),
      ),
    );
  }

  Widget SubmitButton() {
    final bool allGapsFilled = selectedOptionsForGaps.values
        .every((selectedOption) => selectedOption != null);
    final bool canSubmit = allGapsFilled && !hasAnswered;

    return Material(
      elevation: canSubmit ? 2 : 0,
      borderRadius: BorderRadius.circular(12),
      color: canSubmit ? AppTheme.primaryBlue : AppTheme.backgroundLight,
      child: InkWell(
        onTap: canSubmit ? checkAnswer : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: canSubmit
                  ? AppTheme.primaryBlue
                  : AppTheme.textPrimary.withValues(alpha: 0.2),
              width: 2,
            ),
          ),
          child: Center(
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
        ),
      ),
    );
  }

  Widget ExplanationSection() {
    if (!hasAnswered) {
      return const Spacing.height(0);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.textPrimary.withValues(alpha: 0.1),
        ),
      ),
      child: Div.column(
        [
          Div.row(
            [
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
            ],
          ),

          const Spacing.height(12),

          ProgressiveText(
            textSegments: [widget.content.explanation],
            textStyle: Typography.bodyLargeStyle.copyWith(
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
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
    for (final MapEntry<int, int?> entry in selectedOptionsForGaps.entries) {
      if (entry.value == null) {
        return entry.key;
      }
    }
    return null;
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

    if (!allCorrect) {
      triggerShakeAnimation();
    }

    widget.onAnswerSelected(0, allCorrect);
  }

  void triggerShakeAnimation() {
    shakeController = AnimationController(
      duration: const Duration(milliseconds: FILL_GAP_SHAKE_DURATION_MS),
      vsync: this,
    );

    shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
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