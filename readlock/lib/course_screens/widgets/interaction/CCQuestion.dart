// Widget for displaying interactive quiz questions with options and feedback
// Handles user answer selection and shows explanations after answering

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/RLConstants.dart';
import 'package:readlock/course_screens/models/courseModel.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLTheme.dart';
import 'package:readlock/utility_widgets/ExplanationDialog.dart';

enum OptionButtonState {
  normal,
  selected,
  correctAndAnswered,
  incorrectAndAnswered,
}

class CCQuestion extends StatefulWidget {
  static const double QUESTION_SECTION_SPACING = 24.0;
  static const double OPTION_BUTTON_SPACING = 16.0;

  final QuestionContent content;
  final void Function(int selectedIndex, bool isCorrect)
  onAnswerSelected;

  const CCQuestion({
    super.key,
    required this.content,
    required this.onAnswerSelected,
  });

  @override
  State<CCQuestion> createState() => CCQuestionState();
}

class CCQuestionState extends State<CCQuestion> {
  int? selectedAnswerIndex;
  bool hasAnsweredQuestion = false;

  // Icon definitions
  static const Icon LightbulbIcon = Icon(
    Icons.lightbulb_outline,
    color: Colors.white,
    size: 16,
  );

  static const Icon StarIcon = Icon(
    Icons.star,
    color: Colors.white,
    size: 16,
  );

  @override
  Widget build(BuildContext context) {
    return Div.column(
      [
        QuestionText(),

        const Spacing.height(CCQuestion.QUESTION_SECTION_SPACING),

        OptionsList(),

        const Spacing.height(CCQuestion.QUESTION_SECTION_SPACING),
      ],
      color: RLTheme.backgroundDark,
      padding: 24,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }

  Widget QuestionText() {
    return RLTypography.bodyLarge(widget.content.question);
  }

  Widget OptionsList() {
    return Div.column(OptionWidgets());
  }

  List<Widget> OptionWidgets() {
    return widget.content.options.asMap().entries.map((entry) {
      final int optionIndex = entry.key;
      final QuestionOption option = entry.value;

      return Div.column([
        OptionButton(optionIndex, option),

        const Spacing.height(CCQuestion.OPTION_BUTTON_SPACING),
      ]);
    }).toList();
  }

  Widget OptionButton(int optionIndex, QuestionOption option) {
    final OptionButtonState buttonState = getOptionButtonState(
      optionIndex,
    );
    final BoxDecoration optionDecoration = OptionDecoration(
      buttonState,
    );
    final Color textColor =
        OptionTextStyle(buttonState).color ?? RLTheme.textPrimary;

    return Div.row([
      Expanded(
        child: Div.row(
          [
            CorrectAnswerIcon(buttonState),

            Expanded(
              child: RLTypography.bodyLarge(
                option.text,
                color: textColor,
              ),
            ),
          ],
          padding: RLTheme.contentPaddingMediumInsets,
          decoration: optionDecoration,
          onTap: hasAnsweredQuestion
              ? null
              : () => selectAnswer(optionIndex),
        ),
      ),
    ]);
  }

  OptionButtonState getOptionButtonState(int optionIndex) {
    final bool isSelected = selectedAnswerIndex == optionIndex;
    final bool isCorrectAnswer = widget.content.correctAnswerIndices
        .contains(optionIndex);
    final bool isCorrectAndAnswered =
        hasAnsweredQuestion && isCorrectAnswer && isSelected;
    final bool isIncorrectAndAnswered =
        hasAnsweredQuestion && !isCorrectAnswer;

    if (isCorrectAndAnswered) {
      return OptionButtonState.correctAndAnswered;
    }

    if (isIncorrectAndAnswered) {
      return OptionButtonState.incorrectAndAnswered;
    }

    if (isSelected && !hasAnsweredQuestion) {
      return OptionButtonState.selected;
    }

    return OptionButtonState.normal;
  }

  BoxDecoration OptionDecoration(OptionButtonState state) {
    final Color themeColor = getThemeColorForState(state);
    final bool isCorrect =
        state == OptionButtonState.correctAndAnswered;

    return Style.optionDecoration.copyWith(
      border: Border.all(color: themeColor, width: 2),
      color: isCorrect
          ? RLTheme.primaryGreen.withValues(alpha: 0.1)
          : Style.optionDecoration.color,
    );
  }

  TextStyle OptionTextStyle(OptionButtonState state) {
    final bool isSelected =
        state == OptionButtonState.selected ||
        state == OptionButtonState.correctAndAnswered;
    final bool isCorrect =
        state == OptionButtonState.correctAndAnswered;
    final bool isIncorrect =
        state == OptionButtonState.incorrectAndAnswered;

    Color? textColor;
    if (isCorrect) {
      textColor = RLTheme.primaryGreen;
    } else if (isIncorrect) {
      textColor = RLTheme.textPrimary.withValues(alpha: 0.3);
    } else {
      textColor = Style.optionTextStyle.color;
    }

    return Style.optionTextStyle.copyWith(
      fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
      color: textColor,
    );
  }

  Widget CorrectAnswerIcon(OptionButtonState state) {
    // No icon shown - green color is enough
    return const SizedBox.shrink();
  }

  Color getThemeColorForState(OptionButtonState state) {
    switch (state) {
      case OptionButtonState.correctAndAnswered:
        {
          return RLTheme.primaryGreen;
        }
      case OptionButtonState.selected:
        {
          return RLTheme.primaryBlue;
        }
      case OptionButtonState.incorrectAndAnswered:
        {
          return RLTheme.textPrimary.withValues(alpha: 0.1);
        }
      case OptionButtonState.normal:
        {
          return RLTheme.textPrimary.withValues(alpha: 0.2);
        }
    }
  }

  void showIncorrectAnswerSnackbar() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(IncorrectAnswerSnackbar());
  }

  SnackBar IncorrectAnswerSnackbar() {
    return SnackBar(
      content: Div.row([
        LightbulbIcon,

        const Spacing.width(8),

        RLTypography.bodyMedium('Incorrect', color: Colors.white),

        const Spacer(),

        TextButton(
          onPressed: showHintDialog,
          child: RLTypography.bodyMedium(
            'Hint it?',
            color: Colors.white,
          ),
        ),
      ]),
      backgroundColor: Colors.grey.shade600,
      behavior: SnackBarBehavior.floating,
      shape: Style.snackbarShape,
      margin: Style.snackbarMargin,
    );
  }

  // Logic methods

  void selectAnswer(int optionIndex) {
    final bool isCorrectAnswer = widget.content.correctAnswerIndices
        .contains(optionIndex);

    if (!isCorrectAnswer && !hasAnsweredQuestion) {
      showIncorrectAnswerSnackbar();
      return;
    }

    if (isCorrectAnswer && !hasAnsweredQuestion) {
      handleCorrectAnswer(optionIndex, isCorrectAnswer);
    }
  }

  void handleCorrectAnswer(int optionIndex, bool isCorrectAnswer) {
    setState(() {
      selectedAnswerIndex = optionIndex;
      hasAnsweredQuestion = true;
    });

    showCorrectAnswerFeedback();
    widget.onAnswerSelected(optionIndex, isCorrectAnswer);
  }

  void showHintDialog() {
    final String dialogContent =
        widget.content.hint ?? 'No hint available';
    showFullScreenDialog('Hint', dialogContent);
  }

  void showExplanationDialog() {
    showFullScreenDialog('Explanation', widget.content.explanation);
  }

  void showFullScreenDialog(String title, String content) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ExplanationDialog(title: title, content: content);
      },
    );
  }

  void showCorrectAnswerFeedback() {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(CorrectAnswerSnackbar());
    }
  }

  // UI building methods

  SnackBar CorrectAnswerSnackbar() {
    return SnackBar(
      content: Div.row([
        StarIcon,

        const Spacing.width(8),

        RLTypography.bodyMedium('+5 experience', color: Colors.white),

        const Spacer(),

        TextButton(
          onPressed: showExplanationDialog,
          child: RLTypography.bodyMedium('Why?', color: Colors.white),
        ),
      ]),
      backgroundColor: Colors.green.shade600,
      duration: const Duration(seconds: 5),
      behavior: SnackBarBehavior.floating,
      shape: Style.snackbarShape,
      margin: Style.snackbarMargin,
    );
  }
}

class Style {
  static final BoxDecoration optionDecoration = BoxDecoration(
    color: RLTheme.backgroundLight,
    borderRadius: BorderRadius.circular(12),
  );

  static final TextStyle optionTextStyle = RLTypography.bodyLargeStyle
      .copyWith(fontSize: 14, color: RLTheme.textPrimary);

  static final BoxDecoration correctIconDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(4),
  );

  static final RoundedRectangleBorder snackbarShape =
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(8));

  static const EdgeInsets snackbarMargin = EdgeInsets.all(16);
}
