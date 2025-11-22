// Widget for estimating percentages from studies or statistics
// Users slide to guess the percentage before revealing the actual answer

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/app_constants.dart';
import 'package:readlock/course_screens/models/course_model.dart';
import 'package:readlock/utility_widgets/utility_widgets.dart';
import 'package:readlock/constants/typography.dart';
import 'package:readlock/constants/app_theme.dart';
import 'package:readlock/utility_widgets/text_animation/progressive_text.dart';

// Constants
const double ESTIMATE_SECTION_SPACING = 24.0;
const double SLIDER_HEIGHT = 60.0;
const int ANIMATION_DURATION_MS = 300;
const int CLOSE_ESTIMATE_THRESHOLD = 10;
const String YOUR_ESTIMATE_LABEL = 'Your Estimate';
const String SUBMIT_BUTTON_TEXT = 'Submit Estimate';

class EstimatePercentageWidget extends StatefulWidget {
  final QuestionContent content;
  final void Function(int selectedIndex, bool isCorrect)
  onAnswerSelected;

  const EstimatePercentageWidget({
    super.key,
    required this.content,
    required this.onAnswerSelected,
  });

  @override
  State<EstimatePercentageWidget> createState() =>
      EstimatePercentageWidgetState();
}

class EstimatePercentageWidgetState
    extends State<EstimatePercentageWidget>
    with SingleTickerProviderStateMixin {
  double currentEstimate = 50;
  bool hasSubmitted = false;
  late AnimationController revealController;
  late Animation<double> revealAnimation;

  int get correctPercentage {
    if (widget.content.correctAnswerIndices.isNotEmpty) {
      return widget.content.correctAnswerIndices[0];
    }
    return 50;
  }

  @override
  void initState() {
    super.initState();

    revealController = AnimationController(
      duration: const Duration(milliseconds: ANIMATION_DURATION_MS),
      vsync: this,
    );

    revealAnimation = CurvedAnimation(
      parent: revealController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    revealController.dispose();
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

            const Spacing.height(ESTIMATE_SECTION_SPACING),

            EstimateDisplay(),

            const Spacing.height(ESTIMATE_SECTION_SPACING),

            SliderSection(),

            const Spacing.height(ESTIMATE_SECTION_SPACING),

            SubmitButton(),

            RenderIf.condition(
              hasSubmitted,
              Column(
                children: [
                  const Spacing.height(ESTIMATE_SECTION_SPACING),
                  ResultSection(),
                  const Spacing.height(ESTIMATE_SECTION_SPACING),
                  ExplanationSection(),
                ],
              ),
            ),
          ],
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
    );
  }

  // Widget methods

  Widget QuestionText() {
    return Text(
      widget.content.question,
      style: Typography.bodyLargeStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget EstimateDisplay() {
    final Color borderColor = getBorderColor();
    final TextStyle estimateTextStyle = getEstimateTextStyle();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Column(
        children: [
          Text(
            YOUR_ESTIMATE_LABEL,
            style: Typography.bodyMediumStyle.copyWith(
              fontSize: 12,
              color: AppTheme.textPrimary.withValues(alpha: 0.6),
              letterSpacing: 1,
            ),
          ),

          const Spacing.height(8),

          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: estimateTextStyle,
            child: Typography.text('${currentEstimate.round()}%'),
          ),
        ],
      ),
    );
  }

  // Helper methods

  Color getBorderColor() {
    if (hasSubmitted) {
      return AppTheme.primaryGreen.withValues(alpha: 0.3);
    }
    return AppTheme.primaryBlue.withValues(alpha: 0.3);
  }

  TextStyle getEstimateTextStyle() {
    final double fontSize = hasSubmitted ? 36 : 42;
    final Color textColor = hasSubmitted
        ? AppTheme.textPrimary.withValues(alpha: 0.7)
        : AppTheme.primaryBlue;

    return Typography.bodyLargeStyle.copyWith(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: textColor,
    );
  }

  Widget SliderSection() {
    return Container(
      height: SLIDER_HEIGHT,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppTheme.primaryBlue,
              inactiveTrackColor: AppTheme.textPrimary.withValues(
                alpha: 0.1,
              ),
              thumbColor: AppTheme.primaryBlue,
              overlayColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 12,
                pressedElevation: 4,
              ),
              trackHeight: 6,
              tickMarkShape: const RoundSliderTickMarkShape(),
            ),
            child: Slider(
              value: currentEstimate,
              max: 100,
              divisions: 100,
              onChanged: hasSubmitted
                  ? null
                  : (value) {
                      setState(() {
                        currentEstimate = value;
                      });
                    },
            ),
          ),

          Positioned(
            left: 0,
            bottom: 0,
            child: Text(
              '0%',
              style: Typography.bodyMediumStyle.copyWith(
                fontSize: 12,
                color: AppTheme.textPrimary.withValues(alpha: 0.5),
              ),
            ),
          ),

          Positioned(
            right: 0,
            bottom: 0,
            child: Text(
              '100%',
              style: Typography.bodyMediumStyle.copyWith(
                fontSize: 12,
                color: AppTheme.textPrimary.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget SubmitButton() {
    return RenderIf.condition(
      !hasSubmitted,
      InkWell(
        onTap: submitEstimate,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              SUBMIT_BUTTON_TEXT,
              style: Typography.bodyLargeStyle.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget ResultSection() {
    final int difference = (currentEstimate.round() - correctPercentage)
        .abs();
    final bool isClose = difference <= CLOSE_ESTIMATE_THRESHOLD;

    return FadeTransition(
      opacity: revealAnimation,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: buildResultDecoration(isClose),
        child: Div.column([
          Div.row([
            buildResultIcon(isClose),

            const Spacing.width(8),

            buildResultMessage(isClose),
          ]),

          const Spacing.height(12),

          RenderIf.condition(
            !isClose,
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: buildHintText(difference),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ResultColumn(
                label: 'Your Estimate',
                value: '${currentEstimate.round()}%',
                isHighlighted: false,
              ),

              Container(
                width: 1,
                height: 40,
                color: AppTheme.textPrimary.withValues(alpha: 0.1),
              ),

              ResultColumn(
                label: 'Actual',
                value: '$correctPercentage%',
                isHighlighted: true,
              ),

              Container(
                width: 1,
                height: 40,
                color: AppTheme.textPrimary.withValues(alpha: 0.1),
              ),

              ResultColumn(
                label: 'Difference',
                value: '$difference%',
                isHighlighted: false,
              ),
            ],
          ),
        ]),
      ),
    );
  }

  Widget ResultColumn({
    required String label,
    required String value,
    required bool isHighlighted,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: Typography.bodyMediumStyle.copyWith(
            fontSize: 11,
            color: AppTheme.textPrimary.withValues(alpha: 0.6),
          ),
        ),

        const Spacing.height(4),

        Text(
          value,
          style: Typography.bodyLargeStyle.copyWith(
            fontSize: 18,
            fontWeight: isHighlighted
                ? FontWeight.bold
                : FontWeight.w600,
            color: isHighlighted
                ? AppTheme.primaryGreen
                : AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget ExplanationSection() {
    return FadeTransition(
      opacity: revealAnimation,
      child: ProgressiveText(
        textSegments: [widget.content.explanation],
        textStyle: Typography.bodyLargeStyle.copyWith(
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }

  BoxDecoration buildResultDecoration(bool isClose) {
    final Color backgroundColor = isClose
        ? AppTheme.primaryGreen.withValues(alpha: 0.1)
        : Colors.orange.shade50;
    final Color borderColor = isClose
        ? AppTheme.primaryGreen
        : Colors.orange.shade400;

    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: borderColor, width: 2),
    );
  }

  Widget buildResultIcon(bool isClose) {
    final IconData iconData = isClose
        ? Icons.check_circle
        : Icons.info_outline;
    final Color iconColor = isClose
        ? AppTheme.primaryGreen
        : Colors.orange.shade600;

    return Icon(iconData, color: iconColor, size: 20);
  }

  Widget buildResultMessage(bool isClose) {
    final String message = isClose
        ? 'Great estimate!'
        : 'Keep practicing!';
    final Color textColor = isClose
        ? AppTheme.primaryGreen
        : Colors.orange.shade700;

    return Text(
      message,
      style: Typography.bodyLargeStyle.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: 14,
        color: textColor,
      ),
    );
  }

  Widget buildHintText(int difference) {
    final String hintMessage = getHintMessage(difference);

    return Text(
      hintMessage,
      style: Typography.bodyMediumStyle.copyWith(
        fontSize: 12,
        color: Colors.orange.shade600,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  String getHintMessage(int difference) {
    final bool isLargeDifference = difference > 30;

    if (isLargeDifference) {
      return 'Tip: Consider the context and real-world factors that might influence this statistic.';
    }

    return 'Close! Think about the specific details mentioned in the text.';
  }

  // Action methods

  void submitEstimate() {
    setState(() {
      hasSubmitted = true;
    });

    revealController.forward();

    final int difference = (currentEstimate.round() - correctPercentage)
        .abs();
    final bool isClose = difference <= CLOSE_ESTIMATE_THRESHOLD;

    if (isClose) {
      showAhaReward();
    }

    widget.onAnswerSelected(currentEstimate.round(), isClose);
  }

  void showAhaReward() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.white, size: 16),
                const Spacing.width(8),
                Text(
                  '+8 Aha',
                  style: Typography.bodyLargeStyle.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    });
  }
}
