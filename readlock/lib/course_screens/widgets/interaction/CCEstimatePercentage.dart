// Widget for estimating percentages from studies or statistics
// Users slide to guess the percentage before revealing the actual answer

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/RLConstants.dart';
import 'package:readlock/course_screens/models/courseModel.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLTheme.dart';
import 'package:readlock/utility_widgets/text_animation/ProgressiveText.dart';

// Constants
const double ESTIMATE_SECTION_SPACING = 24.0;
const double SLIDER_HEIGHT = 60.0;
const int ANIMATION_DURATION_MS = 300;
const int CLOSE_ESTIMATE_THRESHOLD = 10;
const String YOUR_ESTIMATE_LABEL = 'Your Estimate';
const String SUBMIT_BUTTON_TEXT = 'Estimate';

class CCEstimatePercentage extends StatefulWidget {
  final EstimatePercentageContent content;
  final void Function(int selectedIndex, bool isCorrect)
  onAnswerSelected;

  const CCEstimatePercentage({
    super.key,
    required this.content,
    required this.onAnswerSelected,
  });

  @override
  State<CCEstimatePercentage> createState() =>
      CCEstimatePercentageState();
}

class CCEstimatePercentageState extends State<CCEstimatePercentage>
    with SingleTickerProviderStateMixin {
  double currentEstimate = 50;
  bool hasSubmittedEstimate = false;
  late AnimationController revealController;
  late Animation<double> revealAnimation;

  // Icon and styling definitions
  static const Icon CheckIcon = Icon(
    Icons.check_circle,
    color: RLTheme.primaryGreen,
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
      color: RLTheme.backgroundDark,
      padding: 24,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }

  // Widget methods

  List<Widget> MainContent() {
    return [
      QuestionText(),

      const Spacing.height(32),

      CurrentEstimateDisplay(),

      const Spacing.height(24),

      EstimationSlider(),

      const Spacing.height(32),

      SubmitButton(),

      RenderIf.condition(hasSubmittedEstimate, ResultsContent()),
    ];
  }

  Widget ResultsContent() {
    return Div.column([
      const Spacing.height(24),
      ResultSection(),
      const Spacing.height(24),
      ExplanationSection(),
    ]);
  }

  Widget QuestionText() {
    return RLTypography.bodyLarge(
      widget.content.question,
      textAlign: TextAlign.center,
    );
  }

  Widget CurrentEstimateDisplay() {
    return Div.column([
      RLTypography.bodyMedium(
        'Your estimate',
        color: RLTheme.textPrimary.withValues(alpha: 0.7),
      ),

      const Spacing.height(8),

      Div.row([
        RLTypography.headingLarge(
          '${currentEstimate.round()}',
          color: RLTheme.primaryBlue,
        ),

        RLTypography.headingMedium(
          '%',
          color: RLTheme.primaryBlue.withValues(alpha: 0.7),
        ),
      ], mainAxisAlignment: MainAxisAlignment.center),
    ], crossAxisAlignment: CrossAxisAlignment.center);
  }

  // Helper methods

  Widget EstimationSlider() {
    final SliderThemeData sliderTheme = Style.getSliderTheme();

    return Div.column(
      [
        // Slider with labels
        SliderTheme(
          data: sliderTheme,
          child: Slider(
            value: currentEstimate,
            max: 100,
            divisions: 100,
            onChanged: getSliderChangeHandler(),
          ),
        ),

        // Min/Max labels
        Div.row(
          [
            Text(
              '0%',
              style: TextStyle(
                fontSize: 12,
                color: RLTheme.textPrimary.withValues(alpha: 0.5),
              ),
            ),

            const Spacer(),

            Text(
              '100%',
              style: TextStyle(
                fontSize: 12,
                color: RLTheme.textPrimary.withValues(alpha: 0.5),
              ),
            ),
          ],
          padding: const [12, 0],
        ),
      ],
      padding: const [24, 0],
    );
  }

  Function(double)? getSliderChangeHandler() {
    final bool canChange = !hasSubmittedEstimate;

    if (!canChange) {
      return null;
    }

    void handleSliderChange(double value) {
      setState(() {
        currentEstimate = value;
      });
    }

    return handleSliderChange;
  }

  Widget SubmitButton() {
    final bool shouldShow = !hasSubmittedEstimate;

    return RenderIf.condition(
      shouldShow,
      Div.row(
        [
          const Icon(Icons.touch_app, color: Colors.white, size: 20),

          const Spacing.width(8),

          RLTypography.bodyLarge(
            'Submit Estimate',
            color: Colors.white,
          ),
        ],
        height: 52,
        decoration: Style.submitButtonDecoration,
        mainAxisAlignment: MainAxisAlignment.center,
        onTap: submitEstimate,
      ),
    );
  }

  Widget ResultSection() {
    final int difference = (currentEstimate.round() - correctPercentage)
        .abs();
    final bool isClose = difference <= widget.content.closeThreshold;

    return FadeTransition(
      opacity: revealAnimation,
      child: Div.column([
        // Result feedback card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: getResultCardDecoration(isClose),
          child: Div.column([
            // Result header
            getResultHeader(isClose, difference),

            const Spacing.height(20),

            // Comparison display
            getComparisonDisplay(difference),
          ]),
        ),
      ]),
    );
  }

  Widget getResultHeader(bool isClose, int difference) {
    if (isClose) {
      return Div.row([
        CheckIcon,
        const Spacing.width(12),
        RLTypography.headingMedium(
          'Excellent estimate!',
          color: RLTheme.primaryGreen,
        ),
      ]);
    }

    return Div.column([
      Div.row([
        Icon(
          Icons.lightbulb_outline,
          color: Colors.orange.shade600,
          size: 20,
        ),
        const Spacing.width(12),
        RLTypography.headingMedium(
          difference > 30 ? 'Keep learning!' : 'Getting closer!',
          color: Colors.orange.shade600,
        ),
      ]),

      const Spacing.height(8),

      RLTypography.bodyMedium(
        getHintMessage(difference),
        color: RLTheme.textPrimary.withValues(alpha: 0.7),
      ),
    ]);
  }

  Widget getComparisonDisplay(int difference) {
    return Div.row([
      // Your estimate
      Expanded(
        child: Div.column([
          Text(
            'YOUR ESTIMATE',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: RLTheme.textPrimary.withValues(alpha: 0.5),
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacing.height(4),
          RLTypography.headingMedium(
            '${currentEstimate.round()}%',
            color: RLTheme.textPrimary,
            textAlign: TextAlign.center,
          ),
        ]),
      ),

      // Arrow indicator
      Div.column([
        Icon(
          Icons.arrow_forward,
          color: RLTheme.textPrimary.withValues(alpha: 0.3),
          size: 20,
        ),
      ]),

      // Actual answer
      Expanded(
        child: Div.column([
          Text(
            'ACTUAL',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: RLTheme.textPrimary.withValues(alpha: 0.5),
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const Spacing.height(4),
          RLTypography.headingMedium(
            '$correctPercentage%',
            color: RLTheme.primaryGreen,
            textAlign: TextAlign.center,
          ),
        ]),
      ),
    ]);
  }

  Widget ExplanationSection() {
    return FadeTransition(
      opacity: revealAnimation,
      child: ProgressiveText(
        textSegments: [widget.content.explanation],
        textStyle: RLTypography.bodyLargeStyle.copyWith(
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }

  BoxDecoration getResultCardDecoration(bool isClose) {
    final Color backgroundColor = isClose
        ? RLTheme.primaryGreen.withValues(alpha: 0.08)
        : RLTheme.warningColor.withValues(alpha: 0.08);
    final Color borderColor = isClose
        ? RLTheme.primaryGreen.withValues(alpha: 0.3)
        : Colors.orange.shade400.withValues(alpha: 0.3);

    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: borderColor, width: 1.5),
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
      showExperienceReward();
    }

    widget.onAnswerSelected(currentEstimate.round(), isClose);
  }

  void showExperienceReward() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              StarIcon,

              const Spacing.width(8),

              RLTypography.bodyLarge(
                '+8 experience',
                color: Colors.white,
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
  }
}

class Style {
  static const EdgeInsets sliderPadding = EdgeInsets.symmetric(
    horizontal: 16,
  );

  static SliderThemeData getSliderTheme() {
    return SliderThemeData(
      activeTrackColor: RLTheme.primaryBlue,
      inactiveTrackColor: RLTheme.textPrimary.withValues(alpha: 0.1),
      thumbColor: RLTheme.primaryBlue,
      overlayColor: RLTheme.primaryBlue.withValues(alpha: 0.1),
      thumbShape: const RoundSliderThumbShape(
        enabledThumbRadius: 12,
        pressedElevation: 4,
      ),
      trackHeight: 6,
      tickMarkShape: const RoundSliderTickMarkShape(),
    );
  }

  static const double submitButtonHeight = 52.0;

  static final BoxDecoration submitButtonDecoration = BoxDecoration(
    color: RLTheme.primaryBlue,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: RLTheme.primaryBlue.withValues(alpha: 0.3),
        offset: const Offset(0, 4),
        blurRadius: 12,
      ),
    ],
  );
}
