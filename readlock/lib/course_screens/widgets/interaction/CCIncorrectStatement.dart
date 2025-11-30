// Widget for identifying incorrect statements from a list of options
// Users select which statement is incorrect with visual feedback

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/RLConstants.dart';
import 'package:readlock/course_screens/models/courseModel.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLTheme.dart';
import 'package:readlock/utility_widgets/text_animation/ProgressiveText.dart';

const double STATEMENT_ITEM_SPACING = 12.0;
const double STATEMENT_SECTION_SPACING = 24.0;
const int SHAKE_DURATION_MS = 500;

class StatementStyle {
  final Color backgroundColor;
  final Color borderColor;
  final IconData? feedbackIcon;

  const StatementStyle({
    required this.backgroundColor,
    required this.borderColor,
    this.feedbackIcon,
  });
}

class CCIncorrectStatement extends StatefulWidget {
  final QuestionContent content;
  final void Function(int selectedIndex, bool isCorrect)
  onAnswerSelected;

  const CCIncorrectStatement({
    super.key,
    required this.content,
    required this.onAnswerSelected,
  });

  @override
  State<CCIncorrectStatement> createState() =>
      CCIncorrectStatementState();
}

class CCIncorrectStatementState extends State<CCIncorrectStatement>
    with SingleTickerProviderStateMixin {
  int? selectedStatementIndex;
  bool hasAnswered = false;
  AnimationController? shakeController;
  Animation<double>? shakeAnimation;

  // Style definitions
  late final TextStyle questionTextStyle;
  late final TextStyle statementTextStyle;
  late final TextStyle explanationTextStyle;

  @override
  void initState() {
    super.initState();
    initializeStyles();
  }

  @override
  void dispose() {
    shakeController?.dispose();
    super.dispose();
  }

  void initializeStyles() {
    questionTextStyle = RLTypography.bodyLargeStyle.copyWith(
      fontWeight: FontWeight.w600,
      fontSize: 18,
    );

    statementTextStyle = RLTypography.bodyLargeStyle.copyWith(
      fontSize: 15,
      height: 1.4,
    );

    explanationTextStyle = RLTypography.bodyLargeStyle.copyWith(
      fontSize: 14,
      height: 1.5,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: RLTheme.backgroundDark,
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Div.column(
          [
            // Question prompt section
            QuestionTextSection(),

            const Spacing.height(STATEMENT_SECTION_SPACING),

            // Statements list to identify incorrect one
            StatementsListSection(),

            const Spacing.height(STATEMENT_SECTION_SPACING),

            // Explanation after answer
            ExplanationSection(),
          ],
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
    );
  }

  Widget QuestionTextSection() {
    final String questionText = getQuestionText();

    return Text(
      questionText,
      style: questionTextStyle,
      textAlign: TextAlign.center,
    );
  }

  String getQuestionText() {
    return widget.content.question.isNotEmpty
        ? widget.content.question
        : 'Which statement is incorrect?';
  }

  Widget StatementsListSection() {
    return Div.column(getStatementItemsList());
  }

  List<Widget> getStatementItemsList() {
    return widget.content.options.asMap().entries.map((entry) {
      final int statementIndex = entry.key;
      final bool isLastItem =
          statementIndex == widget.content.options.length - 1;

      return Div.column([
        StatementItemWidget(statementIndex: statementIndex),

        if (!isLastItem) const Spacing.height(STATEMENT_ITEM_SPACING),
      ]);
    }).toList();
  }

  Widget StatementItemWidget({required int statementIndex}) {
    final bool isSelected = selectedStatementIndex == statementIndex;
    final bool isIncorrectStatement = widget
        .content
        .correctAnswerIndices
        .contains(statementIndex);

    final StatementStyle statementStyle = getStatementStyle(
      isSelected: isSelected,
      isIncorrectStatement: isIncorrectStatement,
    );

    final Widget statementContainer = buildStatementContainer(
      statementIndex: statementIndex,
      isSelected: isSelected,
      statementStyle: statementStyle,
    );

    return applyShakeAnimationIfNeeded(
      statementContainer: statementContainer,
      isSelected: isSelected,
      isIncorrectStatement: isIncorrectStatement,
    );
  }

  StatementStyle getStatementStyle({
    required bool isSelected,
    required bool isIncorrectStatement,
  }) {
    if (hasAnswered) {
      return getAnsweredStatementStyle(isIncorrectStatement);
    }

    if (isSelected) {
      return getSelectedStatementStyle();
    }

    return getDefaultStatementStyle();
  }

  StatementStyle getAnsweredStatementStyle(bool isIncorrectStatement) {
    if (isIncorrectStatement) {
      return StatementStyle(
        backgroundColor: RLTheme.primaryGreen.withValues(alpha: 0.1),
        borderColor: RLTheme.primaryGreen,
        feedbackIcon: Icons.error_outline,
      );
    } else {
      return StatementStyle(
        backgroundColor: RLTheme.backgroundLight,
        borderColor: RLTheme.textPrimary.withValues(alpha: 0.1),
        feedbackIcon: Icons.check_circle_outline,
      );
    }
  }

  StatementStyle getSelectedStatementStyle() {
    return StatementStyle(
      backgroundColor: Colors.orange.shade50,
      borderColor: Colors.orange.shade400,
      feedbackIcon: null,
    );
  }

  StatementStyle getDefaultStatementStyle() {
    return StatementStyle(
      backgroundColor: RLTheme.backgroundLight,
      borderColor: RLTheme.textPrimary.withValues(alpha: 0.2),
      feedbackIcon: null,
    );
  }

  Widget buildStatementContainer({
    required int statementIndex,
    required bool isSelected,
    required StatementStyle statementStyle,
  }) {
    final BoxDecoration containerDecoration =
        getStatementContainerDecoration(
          statementStyle.backgroundColor,
          statementStyle.borderColor,
        );

    return Div.row(
      [
        // Feedback icon section
        buildFeedbackIconSection(statementIndex, statementStyle),

        // Statement text section
        buildStatementTextSection(statementIndex, isSelected),
      ],
      padding: 16,
      decoration: containerDecoration,
      radius: BorderRadius.circular(12),
      onTap: hasAnswered ? null : () => selectStatement(statementIndex),
    );
  }

  Widget buildFeedbackIconSection(
    int statementIndex,
    StatementStyle statementStyle,
  ) {
    final bool shouldShowIcon =
        hasAnswered && statementStyle.feedbackIcon != null;

    if (!shouldShowIcon) {
      return const Spacing.width(0);
    }

    final bool isIncorrectStatement = widget
        .content
        .correctAnswerIndices
        .contains(statementIndex);

    final Color iconColor = isIncorrectStatement
        ? RLTheme.primaryGreen
        : RLTheme.textPrimary.withValues(alpha: 0.4);

    return Div.row([
      Icon(statementStyle.feedbackIcon!, color: iconColor, size: 20),

      const Spacing.width(12),
    ]);
  }

  Widget buildStatementTextSection(
    int statementIndex,
    bool isSelected,
  ) {
    final String statementText =
        widget.content.options[statementIndex].text;
    final TextStyle textStyle = getStatementTextStyle(isSelected);

    return Expanded(child: Text(statementText, style: textStyle));
  }

  TextStyle getStatementTextStyle(bool isSelected) {
    return statementTextStyle.copyWith(
      fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
    );
  }

  BoxDecoration getStatementContainerDecoration(
    Color backgroundColor,
    Color borderColor,
  ) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: borderColor, width: 2),
      color: backgroundColor,
    );
  }

  Widget applyShakeAnimationIfNeeded({
    required Widget statementContainer,
    required bool isSelected,
    required bool isIncorrectStatement,
  }) {
    final bool shouldApplyShake =
        isSelected && !isIncorrectStatement && shakeAnimation != null;

    if (!shouldApplyShake) {
      return statementContainer;
    }

    return AnimatedBuilder(
      animation: shakeAnimation!,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(shakeAnimation!.value * 10, 0),
          child: child,
        );
      },
      child: statementContainer,
    );
  }

  Widget ExplanationSection() {
    if (!hasAnswered) {
      return const Spacing.height(0);
    }

    final BoxDecoration explanationDecoration =
        getExplanationDecoration();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: explanationDecoration,
      child: Div.column([
        ProgressiveText(
          textSegments: [widget.content.explanation],
          textStyle: explanationTextStyle,
        ),
      ]),
    );
  }

  BoxDecoration getExplanationDecoration() {
    return BoxDecoration(
      color: RLTheme.backgroundLight,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: RLTheme.textPrimary.withValues(alpha: 0.1),
      ),
    );
  }

  void selectStatement(int statementIndex) {
    if (hasAnswered) {
      return;
    }

    final bool isCorrect = checkIfAnswerIsCorrect(statementIndex);

    updateSelectedAnswer(statementIndex);

    handleAnswerFeedback(isCorrect);

    notifyAnswerSelected(statementIndex, isCorrect);
  }

  bool checkIfAnswerIsCorrect(int statementIndex) {
    return widget.content.correctAnswerIndices.contains(statementIndex);
  }

  void updateSelectedAnswer(int statementIndex) {
    setState(() {
      selectedStatementIndex = statementIndex;
      hasAnswered = true;
    });
  }

  void handleAnswerFeedback(bool isCorrect) {
    if (!isCorrect) {
      triggerShakeAnimation();
    }
  }

  void notifyAnswerSelected(int statementIndex, bool isCorrect) {
    widget.onAnswerSelected(statementIndex, isCorrect);
  }

  void triggerShakeAnimation() {
    shakeController = AnimationController(
      duration: const Duration(milliseconds: SHAKE_DURATION_MS),
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
}
