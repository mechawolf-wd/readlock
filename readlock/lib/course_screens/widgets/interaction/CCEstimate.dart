// Widget for estimating percentages from studies or statistics
// Users slide to guess the percentage before revealing the actual answer

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/models/CourseModel.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/utility_widgets/text_animation/ProgressiveText.dart';
import 'package:readlock/constants/RLUIStrings.dart';

import 'package:pixelarticons/pixel.dart';
class CCEstimate extends StatefulWidget {
  final EstimateSwipe content;
  final void Function(int selectedIndex, bool isCorrect) onAnswerSelected;

  const CCEstimate({
    super.key,
    required this.content,
    required this.onAnswerSelected,
  });

  @override
  State<CCEstimate> createState() => CCEstimateState();
}

class CCEstimateState extends State<CCEstimate>
    with SingleTickerProviderStateMixin {
  double currentEstimate = 50;
  bool hasSubmittedEstimate = false;
  late AnimationController revealController;
  late Animation<double> revealAnimation;

  // Icon and styling definitions
  static final Icon CheckIcon = const Icon(Pixel.check, color: RLDS.success, size: 20);
  static const Icon InfoIcon = Icon(Pixel.infobox, size: 20);
  static final Icon StarIcon = const Icon(Pixel.moonstars, color: RLDS.white, size: 16);

  int getCorrectPercentage() {
    return widget.content.correctPercentage;
  }

  @override
  void initState() {
    super.initState();

    revealController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    revealAnimation = CurvedAnimation(parent: revealController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    revealController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Div.column(
        MainContent(),
        color: RLDS.backgroundDark,
        padding: RLDS.contentPaddingInsets,
        crossAxisAlignment: CrossAxisAlignment.stretch,
      ),
    );
  }

  // Widget methods

  List<Widget> MainContent() {
    return [
      QuestionText(),

      const Spacing.height(20),

      CurrentEstimateDisplay(),

      const Spacing.height(16),

      EstimationSlider(),

      const Spacing.height(20),

      SubmitButton(),

      RenderIf.condition(hasSubmittedEstimate, ResultsContent()),
    ];
  }

  Widget ResultsContent() {
    return Div.column([
      const Spacing.height(16),

      ResultSection(),

      const Spacing.height(16),

      ExplanationSection(),
    ]);
  }

  Widget QuestionText() {
    return RLTypography.readingLarge(widget.content.question, textAlign: TextAlign.center);
  }

  Widget CurrentEstimateDisplay() {
    return Div.row([
      RLTypography.bodyMedium(
        RLUIStrings.ESTIMATE_YOUR_LABEL,
        color: RLDS.textPrimary.withValues(alpha: 0.7),
      ),

      const Spacing.width(12),

      RLTypography.headingLarge('${currentEstimate.round()}', color: RLDS.info),

      RLTypography.headingMedium('%', color: RLDS.info.withValues(alpha: 0.7)),
    ], mainAxisAlignment: MainAxisAlignment.center);
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
        SliderLabelsRow(),
      ],
      padding: const [16, 0],
    );
  }

  Widget SliderLabelsRow() {
    final Color labelColor = RLDS.textPrimary.withValues(alpha: 0.5);

    return Div.row(
      [
        RLTypography.bodySmall(RLUIStrings.ESTIMATE_MIN_LABEL, color: labelColor),

        const Spacer(),

        RLTypography.bodySmall(RLUIStrings.ESTIMATE_MAX_LABEL, color: labelColor),
      ],
      padding: const [12, 0],
    );
  }

  Function(double)? getSliderChangeHandler() {
    final bool canChange = !hasSubmittedEstimate;

    if (!canChange) {
      return null;
    }

    return handleSliderChange;
  }

  void handleSliderChange(double value) {
    setState(() {
      currentEstimate = value;
    });
  }

  Widget SubmitButton() {
    final bool shouldShow = !hasSubmittedEstimate;

    final Widget TouchAppIcon = const Icon(Pixel.mouse, color: RLDS.white, size: 18);

    return RenderIf.condition(
      shouldShow,
      Div.row(
        [
          TouchAppIcon,

          const Spacing.width(8),

          RLTypography.bodyMedium(RLUIStrings.ESTIMATE_SUBMIT_LABEL, color: RLDS.white),
        ],
        height: 44,
        decoration: Style.submitButtonDecoration,
        mainAxisAlignment: MainAxisAlignment.center,
        onTap: submitEstimate,
      ),
    );
  }

  Widget ResultSection() {
    final int difference = (currentEstimate.round() - getCorrectPercentage()).abs();
    final bool isClose = difference <= widget.content.closeThreshold;

    return FadeTransition(
      opacity: revealAnimation,
      child: Div.column([
        // Result feedback card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: getResultCardDecoration(isClose),
          child: Div.column([
            // Result header
            getResultHeader(isClose, difference),

            const Spacing.height(12),

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
        RLTypography.headingMedium(RLUIStrings.ESTIMATE_EXCELLENT_LABEL, color: RLDS.success),
      ]);
    }

    final Widget LightbulbIcon = const Icon(
      Pixel.infobox,
      color: RLDS.warning,
      size: 20,
    );

    final bool isLargeDifference = difference > 30;
    String headerText = 'Getting closer!';

    if (isLargeDifference) {
      headerText = RLUIStrings.ESTIMATE_KEEP_LEARNING_LABEL;
    }

    return Div.column([
      Div.row([
        LightbulbIcon,
        const Spacing.width(12),
        RLTypography.headingMedium(headerText, color: RLDS.warning),
      ]),

      const Spacing.height(8),

      RLTypography.bodyMedium(
        getHintMessage(difference),
        color: RLDS.textPrimary.withValues(alpha: 0.7),
      ),
    ]);
  }

  Widget getComparisonDisplay(int difference) {
    final Widget ArrowForwardIcon = Icon(
      Pixel.arrowright,
      color: RLDS.textPrimary.withValues(alpha: 0.3),
      size: 20,
    );

    final TextStyle comparisonLabelStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: RLDS.textPrimary.withValues(alpha: 0.5),
      letterSpacing: 0.5,
    );

    return Div.row([
      // Your estimate
      Expanded(
        child: Div.column([
          Text(RLUIStrings.ESTIMATE_COMPARISON_YOUR_LABEL, style: comparisonLabelStyle, textAlign: TextAlign.center),
          const Spacing.height(4),
          RLTypography.headingMedium(
            '${currentEstimate.round()}%',
            color: RLDS.textPrimary,
            textAlign: TextAlign.center,
          ),
        ]),
      ),

      // Arrow indicator
      Div.column([ArrowForwardIcon]),

      // Actual answer
      Expanded(
        child: Div.column([
          Text(RLUIStrings.ESTIMATE_COMPARISON_ACTUAL_LABEL, style: comparisonLabelStyle, textAlign: TextAlign.center),
          const Spacing.height(4),
          RLTypography.headingMedium(
            '${getCorrectPercentage()}%',
            color: RLDS.success,
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
        textStyle: RLTypography.readingMediumStyle,
      ),
    );
  }

  BoxDecoration getResultCardDecoration(bool isClose) {
    Color backgroundColor = RLDS.warning.withValues(alpha: 0.08);

    if (isClose) {
      backgroundColor = RLDS.success.withValues(alpha: 0.08);
    }

    Color borderColor = RLDS.warning.withValues(alpha: 0.3);

    if (isClose) {
      borderColor = RLDS.success.withValues(alpha: 0.3);
    }

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

    final int difference = (currentEstimate.round() - getCorrectPercentage()).abs();
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

              RLTypography.bodyLarge('+8 experience', color: RLDS.white),
            ],
          ),
          backgroundColor: RLDS.success,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }
}

class Style {
  static const EdgeInsets sliderPadding = EdgeInsets.symmetric(horizontal: 16);

  static SliderThemeData getSliderTheme() {
    return SliderThemeData(
      activeTrackColor: RLDS.info,
      inactiveTrackColor: RLDS.textPrimary.withValues(alpha: 0.1),
      thumbColor: RLDS.info,
      overlayColor: RLDS.info.withValues(alpha: 0.1),
      thumbShape: const RoundSliderThumbShape(),
      trackHeight: 4,
      tickMarkShape: const RoundSliderTickMarkShape(),
    );
  }

  static const double submitButtonHeight = 44.0;

  static final BoxDecoration submitButtonDecoration = BoxDecoration(
    color: RLDS.info,
    borderRadius: BorderRadius.circular(16),
  );
}
