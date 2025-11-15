// Widget for estimating percentages from studies or statistics
// Users slide to guess the percentage before revealing the actual answer

import 'package:flutter/material.dart' hide Typography;
import 'package:relevant/constants/app_constants.dart';
import 'package:relevant/course_screens/models/course_model.dart';
import 'package:relevant/utility_widgets/utility_widgets.dart';
import 'package:relevant/constants/typography.dart';
import 'package:relevant/constants/app_theme.dart';
import 'package:relevant/utility_widgets/text_animation/progressive_text.dart';

const double ESTIMATE_SECTION_SPACING = 24.0;
const double SLIDER_HEIGHT = 60.0;
const int ANIMATION_DURATION_MS = 300;

class EstimatePercentageWidget extends StatefulWidget {
  final QuestionContent content;
  final void Function(int selectedIndex, bool isCorrect) onAnswerSelected;

  const EstimatePercentageWidget({
    super.key,
    required this.content,
    required this.onAnswerSelected,
  });

  @override
  State<EstimatePercentageWidget> createState() =>
      EstimatePercentageWidgetState();
}

class EstimatePercentageWidgetState extends State<EstimatePercentageWidget>
    with SingleTickerProviderStateMixin {
  double currentEstimate = 50;
  bool hasSubmitted = false;
  late AnimationController revealController;
  late Animation<double> revealAnimation;
  
  // The correct answer should be stored in correctAnswerIndices[0]
  int get correctPercentage => widget.content.correctAnswerIndices.isNotEmpty 
      ? widget.content.correctAnswerIndices[0] 
      : 50;

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

            if (hasSubmitted) ...[
              const Spacing.height(ESTIMATE_SECTION_SPACING),

              ResultSection(),

              const Spacing.height(ESTIMATE_SECTION_SPACING),

              ExplanationSection(),
            ],
          ],
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
    );
  }

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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasSubmitted 
              ? AppTheme.primaryGreen.withValues(alpha: 0.3)
              : AppTheme.primaryBlue.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Your Estimate',
            style: Typography.bodyMediumStyle.copyWith(
              fontSize: 12,
              color: AppTheme.textPrimary.withValues(alpha: 0.6),
              letterSpacing: 1,
            ),
          ),

          const Spacing.height(8),

          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: Typography.bodyLargeStyle.copyWith(
              fontSize: hasSubmitted ? 36 : 42,
              fontWeight: FontWeight.bold,
              color: hasSubmitted 
                  ? AppTheme.textPrimary.withValues(alpha: 0.7)
                  : AppTheme.primaryBlue,
            ),
            child: Text('${currentEstimate.round()}%'),
          ),
        ],
      ),
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
              inactiveTrackColor: AppTheme.textPrimary.withValues(alpha: 0.1),
              thumbColor: AppTheme.primaryBlue,
              overlayColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 12,
                pressedElevation: 4,
              ),
              trackHeight: 6,
              tickMarkShape: const RoundSliderTickMarkShape(tickMarkRadius: 0),
            ),
            child: Slider(
              value: currentEstimate,
              min: 0,
              max: 100,
              divisions: 100,
              onChanged: hasSubmitted ? null : (value) {
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
    if (hasSubmitted) {
      return const SizedBox.shrink();
    }

    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      color: AppTheme.primaryBlue,
      child: InkWell(
        onTap: submitEstimate,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              'Submit Estimate',
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
    final int difference = (currentEstimate.round() - correctPercentage).abs();
    final bool isClose = difference <= 10;
    
    return FadeTransition(
      opacity: revealAnimation,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isClose 
              ? AppTheme.primaryGreen.withValues(alpha: 0.1)
              : Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isClose 
                ? AppTheme.primaryGreen
                : Colors.orange.shade400,
            width: 2,
          ),
        ),
        child: Div.column(
          [
            Div.row(
              [
                Icon(
                  isClose ? Icons.check_circle : Icons.info_outline,
                  color: isClose 
                      ? AppTheme.primaryGreen
                      : Colors.orange.shade600,
                  size: 20,
                ),

                const Spacing.width(8),

                Text(
                  isClose ? 'Great estimate!' : 'Not quite!',
                  style: Typography.bodyLargeStyle.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isClose 
                        ? AppTheme.primaryGreen
                        : Colors.orange.shade700,
                  ),
                ),
              ],
            ),

            const Spacing.height(12),

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
          ],
        ),
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
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
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

  void submitEstimate() {
    setState(() {
      hasSubmitted = true;
    });

    revealController.forward();

    final int difference = (currentEstimate.round() - correctPercentage).abs();
    final bool isClose = difference <= 10;

    // Show XP snackbar after a short delay only if close
    if (isClose) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 16,
                  ),

                  const Spacing.width(8),

                  Text(
                    '+8 XP',
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

    widget.onAnswerSelected(currentEstimate.round(), isClose);
  }
}