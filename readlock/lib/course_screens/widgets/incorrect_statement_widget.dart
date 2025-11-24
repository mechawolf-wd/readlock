// Widget for identifying incorrect statements from a list of options
// Users select which statement is incorrect with visual feedback

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/app_constants.dart';
import 'package:readlock/course_screens/models/course_model.dart';
import 'package:readlock/utility_widgets/utility_widgets.dart';
import 'package:readlock/constants/typography.dart';
import 'package:readlock/constants/app_theme.dart';
import 'package:readlock/utility_widgets/text_animation/progressive_text.dart';

const double STATEMENT_ITEM_SPACING = 12.0;
const double STATEMENT_SECTION_SPACING = 24.0;
const int SHAKE_DURATION_MS = 500;

class IncorrectStatementWidget extends StatefulWidget {
  final QuestionContent content;
  final void Function(int selectedIndex, bool isCorrect)
  onAnswerSelected;

  const IncorrectStatementWidget({
    super.key,
    required this.content,
    required this.onAnswerSelected,
  });

  @override
  State<IncorrectStatementWidget> createState() =>
      IncorrectStatementWidgetState();
}

class IncorrectStatementWidgetState
    extends State<IncorrectStatementWidget>
    with SingleTickerProviderStateMixin {
  int? selectedStatementIndex;
  bool hasAnswered = false;
  AnimationController? shakeController;
  Animation<double>? shakeAnimation;

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
            QuestionText(),

            const Spacing.height(STATEMENT_SECTION_SPACING),

            StatementsList(),

            const Spacing.height(STATEMENT_SECTION_SPACING),

            ExplanationSection(),
          ],
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
    );
  }

  Widget QuestionText() {
    return Text(
      widget.content.question.isNotEmpty
          ? widget.content.question
          : 'Which statement is incorrect?',
      style: Typography.bodyLargeStyle.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget StatementsList() {
    return Div.column([
      ...widget.content.options.asMap().entries.map((entry) {
        final int statementIndex = entry.key;

        return Div.column([
          StatementItem(statementIndex: statementIndex),

          if (statementIndex < widget.content.options.length - 1)
            const Spacing.height(STATEMENT_ITEM_SPACING),
        ]);
      }),
    ]);
  }

  Widget StatementItem({required int statementIndex}) {
    final bool isSelected = selectedStatementIndex == statementIndex;
    final bool isIncorrectStatement = widget
        .content
        .correctAnswerIndices
        .contains(statementIndex);

    Color backgroundColor;
    Color borderColor;
    IconData? feedbackIcon;

    if (hasAnswered) {
      if (isIncorrectStatement) {
        backgroundColor = AppTheme.primaryGreen.withValues(alpha: 0.1);
        borderColor = AppTheme.primaryGreen;
        feedbackIcon = Icons.error_outline;
      } else {
        backgroundColor = AppTheme.backgroundLight;
        borderColor = AppTheme.textPrimary.withValues(alpha: 0.1);
        feedbackIcon = Icons.check_circle_outline;
      }
    } else if (isSelected) {
      backgroundColor = Colors.orange.shade50;
      borderColor = Colors.orange.shade400;
    } else {
      backgroundColor = AppTheme.backgroundLight;
      borderColor = AppTheme.textPrimary.withValues(alpha: 0.2);
    }

    final Widget statementContainer = Div.row([
      RenderIf.condition(
        hasAnswered && feedbackIcon != null,
        Div.row([
          Icon(
            feedbackIcon!,
            color: isIncorrectStatement
                ? AppTheme.primaryGreen
                : AppTheme.textPrimary.withValues(alpha: 0.4),
            size: 20,
          ),
          const Spacing.width(12),
        ]),
      ),

      Expanded(
        child: Text(
          widget.content.options[statementIndex].text,
          style: Typography.bodyLargeStyle.copyWith(
            fontSize: 15,
            fontWeight: isSelected
                ? FontWeight.w500
                : FontWeight.normal,
            height: 1.4,
          ),
        ),
      ),
    ], 
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 2),
        color: backgroundColor,
      ),
      radius: BorderRadius.circular(12),
      onTap: hasAnswered
          ? null
          : () => selectStatement(statementIndex),
    );

    if (isSelected && !isIncorrectStatement && shakeAnimation != null) {
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

    return statementContainer;
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
      child: Div.column([
        ProgressiveText(
          textSegments: [widget.content.explanation],
          textStyle: Typography.bodyLargeStyle.copyWith(
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ]),
    );
  }

  void selectStatement(int statementIndex) {
    if (hasAnswered) {
      return;
    }

    final bool isCorrect = widget.content.correctAnswerIndices.contains(
      statementIndex,
    );

    setState(() {
      selectedStatementIndex = statementIndex;
      hasAnswered = true;
    });

    if (!isCorrect) {
      triggerShakeAnimation();
    }

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
