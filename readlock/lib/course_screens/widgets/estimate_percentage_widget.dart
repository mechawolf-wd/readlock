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
const String SUBMIT_BUTTON_TEXT = 'Estimate';

class EstimatePercentageWidget extends StatefulWidget {
  final EstimatePercentageContent content;
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
  bool hasSubmittedEstimate = false;
  late AnimationController revealController;
  late Animation<double> revealAnimation;

  // Icon and styling definitions
  static const Icon CheckIcon = Icon(
    Icons.check_circle,
    color: AppTheme.primaryGreen,
    size: 20,
  );
  static const Icon InfoIcon = Icon(Icons.info_outline, size: 20);
  static const Icon StarIcon = Icon(
    Icons.star,
    color: Colors.white,
    size: 16,
  );

  int get correctPercentage {
    return widget.content.correctPercentage;
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
    return Div.column(
      MainContent(),
      color: AppTheme.backgroundDark,
      padding: const EdgeInsets.all(Constants.COURSE_SECTION_PADDING),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }

  // Widget methods

  List<Widget> MainContent() {
    return [
      QuestionText(),

      const Spacing.height(ESTIMATE_SECTION_SPACING),

      SliderWithPercentage(),

      const Spacing.height(ESTIMATE_SECTION_SPACING),

      SubmitButton(),

      RenderIf.condition(hasSubmittedEstimate, ResultsContent()),
    ];
  }

  Widget ResultsContent() {
    return Div.column([
      const Spacing.height(ESTIMATE_SECTION_SPACING),
      ResultSection(),
      const Spacing.height(ESTIMATE_SECTION_SPACING),
      ExplanationSection(),
    ]);
  }

  Widget QuestionText() {
    return Typography.bodyLarge(
      widget.content.question,
      textAlign: TextAlign.center,
    );
  }

  Widget PercentageLabel() {
    final double sliderPosition = currentEstimate / 100;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double sliderWidth = screenWidth - (Style.sliderPadding.horizontal * 2);
    final double labelPosition = (sliderPosition * sliderWidth) - 20; // Center label on thumb

    return Positioned(
      left: labelPosition.clamp(0, sliderWidth - 40), // Keep within bounds
      top: -30, // Position above slider
      child: Div.column(
        [
          Typography.bodyLarge(
            '${currentEstimate.round()}%',
            color: AppTheme.primaryBlue,
            textAlign: TextAlign.center,
          ),
        ],
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.backgroundLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.primaryBlue.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }

  // Helper methods

  Widget SliderWithPercentage() {
    final SliderThemeData sliderTheme = Style.getSliderTheme();

    return Div.column(
      [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            SliderTheme(
              data: sliderTheme,
              child: Slider(
                value: currentEstimate,
                max: 100,
                divisions: 100,
                onChanged: SliderChangeHandler(),
              ),
            ),
            PercentageLabel(),
          ],
        ),
      ],
      height: SLIDER_HEIGHT + 30, // Extra height for percentage label
      padding: Style.sliderPadding,
    );
  }

  Function(double)? SliderChangeHandler() {
    final bool canChange = !hasSubmittedEstimate;

    if (!canChange) {
      return null;
    }

    return (value) {
      setState(() {
        currentEstimate = value;
      });
    };
  }

  Widget SubmitButton() {
    final bool shouldShow = !hasSubmittedEstimate;

    return RenderIf.condition(
      shouldShow,
      GestureDetector(
        onTap: submitEstimate,
        child: Div.column(
          [
            Typography.bodyLarge(
              SUBMIT_BUTTON_TEXT,
              color: Colors.white,
            ),
          ],
          height: Style.submitButtonHeight,
          decoration: Style.submitButtonDecoration,
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
    );
  }

  Widget ResultSection() {
    final int difference = (currentEstimate.round() - correctPercentage)
        .abs();
    final bool isClose = difference <= widget.content.closeThreshold;

    return FadeTransition(
      opacity: revealAnimation,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: ResultDecoration(isClose),
        child: Div.column([
          Div.row([
            ResultIcon(isClose),

            const Spacing.width(8),

            ResultMessage(isClose),
          ]),

          const Spacing.height(12),

          RenderIf.condition(
            !isClose,
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: HintText(difference),
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
    return Div.column([
      Typography.bodyMedium(
        label,
        color: AppTheme.textPrimary.withValues(alpha: 0.6),
      ),

      const Spacing.height(4),

      Typography.bodyLarge(
        value,
        color: isHighlighted
            ? AppTheme.primaryGreen
            : AppTheme.textPrimary,
      ),
    ]);
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

  BoxDecoration ResultDecoration(bool isClose) {
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

  Widget ResultIcon(bool isClose) {
    if (isClose) {
      return CheckIcon;
    }

    return Icon(
      Icons.info_outline,
      color: Colors.orange.shade600,
      size: 20,
    );
  }

  Widget ResultMessage(bool isClose) {
    final bool shouldShow = isClose;

    if (!shouldShow) {
      return const SizedBox.shrink();
    }

    return Typography.bodyLarge(
      'Great estimate!',
      color: AppTheme.primaryGreen,
    );
  }

  Widget HintText(int difference) {
    final String hintMessage = getHintMessage(difference);

    return Typography.bodyMedium(
      hintMessage,
      color: Colors.orange.shade600,
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
      hasSubmittedEstimate = true;
    });

    revealController.forward();

    final int difference = (currentEstimate.round() - correctPercentage)
        .abs();
    final bool isClose = difference <= widget.content.closeThreshold;

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
                StarIcon,
                const Spacing.width(8),
                Typography.bodyLarge('+8 Aha', color: Colors.white),
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

class Style {
  static const EdgeInsets sliderPadding = EdgeInsets.symmetric(
    horizontal: 16,
  );

  static SliderThemeData getSliderTheme() {
    return SliderThemeData(
      activeTrackColor: AppTheme.primaryBlue,
      inactiveTrackColor: AppTheme.textPrimary.withValues(alpha: 0.1),
      thumbColor: AppTheme.primaryBlue,
      overlayColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
      thumbShape: const RoundSliderThumbShape(
        enabledThumbRadius: 12,
        pressedElevation: 4,
      ),
      trackHeight: 6,
      tickMarkShape: const RoundSliderTickMarkShape(),
    );
  }

  static const double submitButtonHeight = 48.0;

  static final BoxDecoration submitButtonDecoration = BoxDecoration(
    color: AppTheme.primaryBlue,
    borderRadius: BorderRadius.circular(12),
  );
}
