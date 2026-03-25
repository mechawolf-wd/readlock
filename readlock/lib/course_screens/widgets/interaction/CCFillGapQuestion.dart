// Widget for displaying fill-in-the-gap questions with draggable answer options
// Users drag answers to fill blanks in sentences with visual feedback

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/models/CourseModel.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLTheme.dart';
import 'package:readlock/constants/RLConstants.dart';
import 'package:readlock/utility_widgets/text_animation/ProgressiveText.dart';
import 'package:readlock/utility_widgets/FeedbackSnackbar.dart';

// Helper classes for styling
class GapStyling {
  final Color backgroundColor;
  final Color borderColor;

  GapStyling({
    required this.backgroundColor,
    required this.borderColor,
  });
}

class ChipStyling {
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;

  ChipStyling({
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
  });
}

class CCFillGapQuestion extends StatefulWidget {
  final QuestionContent content;
  final void Function(int selectedIndex, bool isCorrect) onAnswerSelected;

  const CCFillGapQuestion({
    super.key,
    required this.content,
    required this.onAnswerSelected,
  });

  @override
  State<CCFillGapQuestion> createState() => CCFillGapQuestionState();
}

class CCFillGapQuestionState extends State<CCFillGapQuestion>
    with TickerProviderStateMixin {
  // State management
  Map<int, int?> selectedOptionsForGaps = {};
  bool hasAnswered = false;
  Set<int> usedOptionIndices = {};
  
  // Animation controllers
  AnimationController? shakeController;
  Animation<double>? shakeAnimation;

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
    return Div.column(
      [
        // Question Section
        QuestionWithGaps(),

        const Spacing.height(FILL_GAP_SECTION_SPACING),

        // Options Section
        AvailableOptions(),

        const Spacing.height(FILL_GAP_SECTION_SPACING),

        // Submit Button
        SubmitButton(),

        const Spacing.height(FILL_GAP_SECTION_SPACING),

        // Explanation
        ExplanationSection(),
      ],
      color: RLTheme.backgroundDark,
      padding: FILL_GAP_CONTENT_PADDING,
      crossAxisAlignment: CrossAxisAlignment.stretch,
    );
  }

  Widget QuestionWithGaps() {
    final List<String> questionParts = widget.content.question.split('___');
    final List<Widget> questionWidgets = [];

    for (int partIndex = 0; partIndex < questionParts.length; partIndex++) {
      final String part = questionParts[partIndex];
      final bool isLastPart = partIndex == questionParts.length - 1;

      final bool hasPartText = part.isNotEmpty;

      if (hasPartText) {
        questionWidgets.add(
          Text(
            part,
            style: RLTypography.bodyLargeStyle.copyWith(
              fontSize: FILL_GAP_QUESTION_TEXT_SIZE,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }

      if (!isLastPart) {
        questionWidgets.add(Gap(gapIndex: partIndex));
      }
    }

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 16,
      children: questionWidgets,
    );
  }

  Widget Gap({required int gapIndex}) {
    final int? selectedOptionIndex = selectedOptionsForGaps[gapIndex];
    final bool hasSelection = selectedOptionIndex != null;
    final bool isCorrect = getIsGapCorrect(gapIndex, selectedOptionIndex);
    final bool isIncorrect = hasAnswered && hasSelection && !isCorrect;

    // Get styling based on state
    final GapStyling styling = getGapStyling(
      hasAnswered: hasAnswered,
      hasSelection: hasSelection,
      isCorrect: isCorrect,
      isIncorrect: isIncorrect,
    );

    // Get display text
    String displayText = '______';

    if (hasSelection) {
      displayText = widget.content.options[selectedOptionIndex].text;
    }

    // Calculate dynamic width
    final double gapWidth = calculateGapWidth(displayText, hasSelection);

    // Build gap container
    final Widget gapContainer = GapContainer(
      displayText: displayText,
      gapWidth: gapWidth,
      styling: styling,
      hasSelection: hasSelection,
      gapIndex: gapIndex,
    );

    // Apply shake animation if incorrect
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
        child: gapContainer,
      );
    }

    return gapContainer;
  }

  bool getIsGapCorrect(int gapIndex, int? selectedOptionIndex) {
    final bool hasSelection = selectedOptionIndex != null;
    final bool isAnswered = hasAnswered;
    
    if (!isAnswered || !hasSelection) {
      return false;
    }
    
    return widget.content.correctAnswerIndices.contains(selectedOptionIndex);
  }

  GapStyling getGapStyling({
    required bool hasAnswered,
    required bool hasSelection,
    required bool isCorrect,
    required bool isIncorrect,
  }) {
    Color backgroundColor;
    Color borderColor;

    if (hasAnswered) {
      if (isCorrect) {
        backgroundColor = RLTheme.primaryGreen.withValues(alpha: 0.15);
        borderColor = RLTheme.primaryGreen;
      } else if (isIncorrect) {
        backgroundColor = RLTheme.errorColor.withValues(alpha: 0.08);
        borderColor = RLTheme.errorColor.withValues(alpha: 0.5);
      } else {
        backgroundColor = RLTheme.backgroundLight;
        borderColor = RLTheme.textPrimary.withValues(alpha: 0.2);
      }
    } else if (hasSelection) {
      backgroundColor = RLTheme.primaryBlue.withValues(alpha: 0.12);
      borderColor = RLTheme.primaryBlue;
    } else {
      backgroundColor = RLTheme.backgroundLight;
      borderColor = RLTheme.textPrimary.withValues(alpha: 0.25);
    }

    return GapStyling(
      backgroundColor: backgroundColor,
      borderColor: borderColor,
    );
  }

  double calculateGapWidth(String text, bool hasSelection) {
    if (!hasSelection) {
      return FILL_GAP_MIN_BLANK_WIDTH;
    }
    
    final double calculatedWidth = text.length * 9.0 + 40;
    return calculatedWidth.clamp(FILL_GAP_MIN_BLANK_WIDTH, FILL_GAP_MAX_BLANK_WIDTH);
  }

  Widget GapContainer({
    required String displayText,
    required double gapWidth,
    required GapStyling styling,
    required bool hasSelection,
    required int gapIndex,
  }) {
    // Text style for gap content
    final TextStyle gapTextStyle = RLTypography.bodyLargeStyle.copyWith(
      fontSize: FILL_GAP_OPTION_TEXT_SIZE,
      fontWeight: hasSelection ? FontWeight.w600 : FontWeight.normal,
      color: hasSelection
          ? RLTheme.textPrimary
          : RLTheme.textPrimary.withValues(alpha: 0.4),
    );

    // Gap decoration
    final BoxDecoration gapDecoration = BoxDecoration(
      color: styling.backgroundColor,
      borderRadius: BorderRadius.circular(FILL_GAP_GAP_RADIUS),
      border: Border.all(
        color: styling.borderColor,
        width: FILL_GAP_BORDER_WIDTH,
      ),
    );

    return Div.row(
      [
        Flexible(
          child: Text(
            displayText,
            style: gapTextStyle,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.center,
          ),
        ),
      ],
      width: gapWidth,
      height: FILL_GAP_BLANK_HEIGHT,
      padding: const [FILL_GAP_GAP_PADDING_H, FILL_GAP_GAP_PADDING_V],
      decoration: gapDecoration,
      mainAxisAlignment: MainAxisAlignment.center,
      onTap: hasAnswered ? null : () => clearGapSelection(gapIndex), // Simple null guard
    );
  }

  Widget AvailableOptions() {
    // Section label style
    final TextStyle labelStyle = RLTypography.bodyLargeStyle.copyWith(
      fontSize: FILL_GAP_LABEL_TEXT_SIZE,
      fontWeight: FontWeight.w600,
      color: RLTheme.textPrimary.withValues(alpha: 0.8),
    );

    // Build option chips
    final List<Widget> optionChips = [];
    for (int optionIndex = 0; optionIndex < widget.content.options.length; optionIndex++) {
      optionChips.add(OptionChip(optionIndex: optionIndex));
    }

    return Div.column([
      // Label
      Text(
        'Select words to fill the gaps:',
        style: labelStyle,
      ),

      const Spacing.height(16),

      // Options grid
      Wrap(
        spacing: FILL_GAP_OPTION_SPACING,
        runSpacing: FILL_GAP_OPTION_SPACING,
        children: optionChips,
      ),
    ]);
  }

  Widget OptionChip({required int optionIndex}) {
    final bool isUsed = usedOptionIndices.contains(optionIndex);
    final bool isDisabled = isUsed && !hasAnswered;
    final bool isCorrectOption = getIsCorrectOption(optionIndex);

    // Get chip styling
    final ChipStyling styling = getChipStyling(
      hasAnswered: hasAnswered,
      isCorrectOption: isCorrectOption,
      isUsed: isUsed,
    );

    // Build chip text style
    final TextStyle chipTextStyle = RLTypography.bodyLargeStyle.copyWith(
      fontSize: FILL_GAP_OPTION_TEXT_SIZE,
      color: styling.textColor,
      fontWeight: isCorrectOption ? FontWeight.w600 : FontWeight.w500,
      decoration: isUsed && !isCorrectOption
          ? TextDecoration.lineThrough
          : null,
    );

    // Build chip decoration
    final BoxDecoration chipDecoration = BoxDecoration(
      color: styling.backgroundColor,
      borderRadius: BorderRadius.circular(FILL_GAP_CHIP_RADIUS),
      border: Border.all(
        color: styling.borderColor,
        width: FILL_GAP_BORDER_WIDTH,
      ),
    );

    return Div.row(
      [
        Text(
          widget.content.options[optionIndex].text,
          style: chipTextStyle,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
      padding: const [FILL_GAP_OPTION_CHIP_PADDING_H, FILL_GAP_OPTION_CHIP_PADDING_V],
      decoration: chipDecoration,
      onTap: isDisabled ? null : () => selectOption(optionIndex), // Simple null guard
    );
  }

  bool getIsCorrectOption(int optionIndex) {
    final bool isAnswered = hasAnswered;
    
    if (!isAnswered) {
      return false;
    }
    
    return widget.content.correctAnswerIndices.contains(optionIndex);
  }

  ChipStyling getChipStyling({
    required bool hasAnswered,
    required bool isCorrectOption,
    required bool isUsed,
  }) {
    Color backgroundColor;
    Color borderColor;
    Color textColor;

    if (hasAnswered && isCorrectOption) {
      backgroundColor = RLTheme.primaryGreen.withValues(alpha: 0.12);
      borderColor = RLTheme.primaryGreen;
      textColor = RLTheme.primaryGreen;
    } else if (isUsed) {
      backgroundColor = RLTheme.textPrimary.withValues(alpha: 0.03);
      borderColor = RLTheme.textPrimary.withValues(alpha: 0.15);
      textColor = RLTheme.textPrimary.withValues(alpha: 0.35);
    } else {
      backgroundColor = RLTheme.backgroundLight;
      borderColor = RLTheme.primaryBlue.withValues(alpha: 0.4);
      textColor = RLTheme.textPrimary;
    }

    return ChipStyling(
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      textColor: textColor,
    );
  }

  Widget SubmitButton() {
    final bool allGapsFilled = checkAllGapsFilled();
    final bool canSubmit = allGapsFilled && !hasAnswered;

    // Button text
    String buttonText = 'Submit Answer';

    if (hasAnswered) {
      buttonText = 'Submitted';
    }

    // Button text color
    Color buttonTextColor = RLTheme.textPrimary.withValues(alpha: 0.4);

    if (canSubmit) {
      buttonTextColor = Colors.white;
    }

    // Button text style
    final TextStyle buttonTextStyle = RLTypography.bodyLargeStyle.copyWith(
      color: buttonTextColor,
      fontWeight: FontWeight.w600,
      fontSize: FILL_GAP_BUTTON_TEXT_SIZE,
    );

    // Button colors
    Color buttonColor = RLTheme.backgroundLight;

    if (canSubmit) {
      buttonColor = RLTheme.primaryBlue;
    }

    Color buttonBorderColor = RLTheme.textPrimary.withValues(alpha: 0.2);

    if (canSubmit) {
      buttonBorderColor = RLTheme.primaryBlue;
    }

    // Button decoration
    final BoxDecoration buttonDecoration = BoxDecoration(
      color: buttonColor,
      borderRadius: BorderRadius.circular(FILL_GAP_BUTTON_RADIUS),
      border: Border.all(
        color: buttonBorderColor,
        width: FILL_GAP_BORDER_WIDTH,
      ),
    );

    return Div.row(
      [
        Text(
          buttonText,
          style: buttonTextStyle,
        ),
      ],
      height: 48,
      decoration: buttonDecoration,
      mainAxisAlignment: MainAxisAlignment.center,
      onTap: canSubmit ? checkAnswer : null, // Simple null guard
    );
  }

  bool checkAllGapsFilled() {
    return selectedOptionsForGaps.values.every(
      (selectedOption) => selectedOption != null,
    );
  }

  Widget ExplanationSection() {
    final bool shouldShowExplanation = hasAnswered;

    return RenderIf.condition(
      shouldShowExplanation,
      
      Div.column(
        [
          // Header
          ExplanationHeader(),

          const Spacing.height(12),

          // Explanation text
          ProgressiveText(
            textSegments: [widget.content.explanation],
            textStyle: RLTypography.bodyLargeStyle.copyWith(
              fontSize: FILL_GAP_LABEL_TEXT_SIZE,
              height: 1.6,
            ),
          ),
        ],
        padding: 20,
        color: RLTheme.backgroundLight,
        radius: 12,
      ),
      
      const SizedBox.shrink(),
    );
  }

  Widget ExplanationHeader() {
    // Icon
    const Icon ExplanationIcon = Icon(
      Icons.lightbulb_outline,
      color: RLTheme.warningColor,
      size: 20,
    );

    // Title style
    final TextStyle titleStyle = RLTypography.bodyLargeStyle.copyWith(
      fontWeight: FontWeight.w600,
      fontSize: FILL_GAP_LABEL_TEXT_SIZE,
      color: RLTheme.textPrimary,
    );

    return Div.row([
      ExplanationIcon,

      const Spacing.width(FILL_GAP_ICON_SPACING),

      Text(
        'Explanation',
        style: titleStyle,
      ),
    ]);
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
      FeedbackSnackBar.showWrongAnswer(
        context,
        hint: widget.content.hint,
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
      for (int gapIndex = 0; gapIndex < widget.content.correctAnswerIndices.length; gapIndex++) {
        selectedOptionsForGaps[gapIndex] = widget.content.correctAnswerIndices[gapIndex];
        usedOptionIndices.add(widget.content.correctAnswerIndices[gapIndex]);
      }
    });
  }
}