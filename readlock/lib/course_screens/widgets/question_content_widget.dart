// Widget for displaying interactive quiz questions with options and feedback
// Handles user answer selection and shows explanations after answering

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/app_constants.dart';
import 'package:readlock/course_screens/models/course_model.dart';
import 'package:readlock/utility_widgets/utility_widgets.dart';
import 'package:readlock/constants/typography.dart';
import 'package:readlock/constants/app_theme.dart';
import 'package:readlock/utility_widgets/explanation_dialog.dart';

enum OptionButtonState { normal, selected, correctAndAnswered }

class QuestionContentWidget extends StatefulWidget {
  static const double QUESTION_SECTION_SPACING = 24.0;
  static const double OPTION_BUTTON_SPACING = 16.0;
  static const double BUTTON_PADDING = 16.0;
  static const double EAhaLANATION_PADDING = 16.0;

  final QuestionContent content;
  final void Function(int selectedIndex, bool isCorrect)
  onAnswerSelected;

  const QuestionContentWidget({
    super.key,
    required this.content,
    required this.onAnswerSelected,
  });

  @override
  State<QuestionContentWidget> createState() =>
      QuestionContentWidgetState();
}

class QuestionContentWidgetState extends State<QuestionContentWidget> {
  int? selectedAnswerIndex;
  List<int> selectedAnswerIndices = [];
  bool hasAnswered = false;
  bool showHint = false;

  @override
  Widget build(BuildContext context) {
    return Div.column(
      [
        QuestionText(),

        const Spacing.height(
          QuestionContentWidget.QUESTION_SECTION_SPACING,
        ),

        OptionsList(),

        const Spacing.height(
          QuestionContentWidget.QUESTION_SECTION_SPACING,
        ),

      ],
      color: AppTheme.backgroundDark,
      padding: Constants.COURSE_SECTION_PADDING,
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }

  Widget QuestionText() {
    return Typography.bodyLarge(widget.content.question);
  }

  Widget OptionsList() {
    return Div.column(BuildOptionWidgets());
  }

  List<Widget> BuildOptionWidgets() {
    return widget.content.options.asMap().entries.map((entry) {
      final int optionIndex = entry.key;
      final QuestionOption option = entry.value;

      return Div.column([
        OptionButton(optionIndex, option),

        const Spacing.height(
          QuestionContentWidget.OPTION_BUTTON_SPACING,
        ),
      ]);
    }).toList();
  }

  Widget OptionButton(int optionIndex, QuestionOption option) {
    final OptionButtonState buttonState = getOptionButtonState(
      optionIndex,
    );
    final BoxDecoration optionDecoration = BuildOptionDecoration(
      buttonState,
    );
    final TextStyle optionTextStyle = BuildOptionTextStyle(buttonState);
    final BorderRadius inkWellRadius = Style.inkWellRadius;

    return Div.row([
      Expanded(
        child: InkWell(
          onTap: hasAnswered ? null : () => selectAnswer(optionIndex),
          borderRadius: inkWellRadius,
          child: Div.row(
            [
              BuildCorrectAnswerIcon(buttonState),

              Expanded(
                child: Text(option.text, style: optionTextStyle),
              ),
            ],
            padding: AppTheme.contentPaddingMediumInsets,
            decoration: optionDecoration,
          ),
        ),
      ),
    ]);
  }

  OptionButtonState getOptionButtonState(int optionIndex) {
    final bool isSelected = selectedAnswerIndex == optionIndex;
    final bool isCorrectAnswer = widget.content.correctAnswerIndices
        .contains(optionIndex);
    final bool isCorrectAndAnswered =
        hasAnswered && isCorrectAnswer && isSelected;

    if (isCorrectAndAnswered) {
      return OptionButtonState.correctAndAnswered;
    } else if (isSelected && !hasAnswered) {
      return OptionButtonState.selected;
    } else {
      return OptionButtonState.normal;
    }
  }

  BoxDecoration BuildOptionDecoration(OptionButtonState state) {
    final Color themeColor = getThemeColorForState(state);

    return Style.optionDecoration.copyWith(
      border: Border.all(color: themeColor, width: 2),
    );
  }

  TextStyle BuildOptionTextStyle(OptionButtonState state) {
    final bool isSelected =
        state == OptionButtonState.selected ||
        state == OptionButtonState.correctAndAnswered;

    return Style.optionTextStyle.copyWith(
      fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
    );
  }

  Widget BuildCorrectAnswerIcon(OptionButtonState state) {
    if (state != OptionButtonState.correctAndAnswered) {
      return const SizedBox.shrink();
    }

    final Color themeColor = getThemeColorForState(state);
    final BoxDecoration iconDecoration = Style.correctIconDecoration
        .copyWith(color: themeColor.withValues(alpha: 0.1));

    return Div.row([
      Div.row(
        [Icon(Icons.check_circle, color: themeColor, size: 18)],
        padding: AppTheme.contentPaddingTinyInsets,
        decoration: iconDecoration,
      ),

      const Spacing.width(12),
    ]);
  }

  Color getThemeColorForState(OptionButtonState state) {
    switch (state) {
      case OptionButtonState.correctAndAnswered:
        return AppTheme.primaryGreen;
      case OptionButtonState.selected:
        return AppTheme.primaryBlue;
      case OptionButtonState.normal:
        return AppTheme.textPrimary.withValues(alpha: 0.2);
    }
  }

  void showIncorrectAnswerSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(buildIncorrectAnswerSnackbar());
  }

  SnackBar buildIncorrectAnswerSnackbar() {
    return SnackBar(
      content: Div.row([
        const Icon(Icons.lightbulb_outline, color: Colors.white, size: 16),

        const Spacing.width(8),

        Typography.text('Incorrect', color: Colors.white),

        const Spacer(),

        TextButton(
          onPressed: showHintDialog,
          child: Typography.text('Hint it?', color: Colors.white),
        ),
      ]),
      backgroundColor: Colors.grey.shade600,
      duration: const Duration(seconds: 4),
      behavior: SnackBarBehavior.floating,
      shape: Style.snackbarShape,
      margin: Style.snackbarMargin,
    );
  }

  // Logic methods

  void selectAnswer(int optionIndex) {
    final bool isCorrectAnswer = widget.content.correctAnswerIndices
        .contains(optionIndex);

    if (!isCorrectAnswer && !hasAnswered) {
      showIncorrectAnswerSnackbar();
      return;
    }

    if (isCorrectAnswer && !hasAnswered) {
      handleCorrectAnswer(optionIndex, isCorrectAnswer);
    }
  }

  void handleCorrectAnswer(int optionIndex, bool isCorrectAnswer) {
    setState(() {
      selectedAnswerIndex = optionIndex;
      hasAnswered = true;
    });

    showCorrectAnswerFeedback();
    widget.onAnswerSelected(optionIndex, isCorrectAnswer);
  }

  void showHintDialog() {
    final String dialogContent = widget.content.hint ?? 'No hint available';
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
        return ExplanationDialog(
          title: title,
          content: content,
        );
      },
    );
  }

  void showCorrectAnswerFeedback() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(buildCorrectAnswerSnackbar());
      }
    });
  }

  // UI building methods

  SnackBar buildCorrectAnswerSnackbar() {
    return SnackBar(
      content: Div.row([
        const Icon(Icons.star, color: Colors.white, size: 16),

        const Spacing.width(8),

        Typography.text('+5 Aha', color: Colors.white),

        const Spacer(),

        TextButton(
          onPressed: showExplanationDialog,
          child: Typography.text('Why?', color: Colors.white),
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
  static final BorderRadius inkWellRadius = BorderRadius.circular(12);

  static final BoxDecoration optionDecoration = BoxDecoration(
    color: AppTheme.backgroundLight,
    borderRadius: BorderRadius.circular(12),
  );

  static final TextStyle optionTextStyle = Typography.bodyLargeStyle
      .copyWith(fontSize: 14, color: AppTheme.textPrimary);

  static final BoxDecoration correctIconDecoration = BoxDecoration(
    borderRadius: BorderRadius.circular(4),
  );

  static final TextStyle explanationTextStyle = Typography
      .bodyLargeStyle
      .copyWith(fontSize: 14, height: 1.5);

  static final RoundedRectangleBorder snackbarShape =
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(8));

  static const EdgeInsets snackbarMargin = EdgeInsets.all(16);

  static final BoxDecoration hintButtonDecoration = BoxDecoration(
    color: AppTheme.primaryBlue.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(8),
    border: Border.all(
      color: AppTheme.primaryBlue.withValues(alpha: 0.3),
    ),
  );

  static final TextStyle dialogTextStyle = Typography.bodyLargeStyle.copyWith(
    fontSize: 16,
    height: 1.6,
  );
}
