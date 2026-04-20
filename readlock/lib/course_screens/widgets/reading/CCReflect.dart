// Widget that displays reflective prompts for deeper thinking
// Encourages users to pause and think about design concepts

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/models/CourseModel.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/utility_widgets/text_animation/ProgressiveText.dart';

import 'package:pixelarticons/pixel.dart';
class CCReflect extends StatefulWidget {
  final ReflectSwipe content;

  const CCReflect({super.key, required this.content});

  @override
  State<CCReflect> createState() => CCReflectState();
}

class CCReflectState extends State<CCReflect> {
  Set<int> selectedPoints = {};
  Set<int> swipingPoints = {};

  // Style definitions
  late final BoxDecoration promptDecoration;
  late final TextStyle promptTextStyle;
  late final List<Color> cardColors;

  @override
  void initState() {
    super.initState();
    initializeStyles();
  }

  void initializeStyles() {
    promptDecoration = BoxDecoration(
      color: RLDS.backgroundLight,
      borderRadius: BorderRadius.circular(16),
    );

    promptTextStyle = RLTypography.readingLargeStyle;

    cardColors = [RLDS.info, RLDS.primary, RLDS.warning];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: RLDS.backgroundDark,
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Div.column(
          [
            // Reflection prompt section
            ReflectionPromptSection(),

            const Spacing.height(24),

            // Thinking cards with swipe interaction
            ThinkingCardsSection(),

            const Spacing.height(24),
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
    );
  }

  Widget ReflectionPromptSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: promptDecoration,
      child: ProgressiveText(textSegments: [widget.content.prompt], textStyle: promptTextStyle),
    );
  }

  Widget ThinkingCardsSection() {
    final List<String> limitedPoints = getLimitedThinkingPoints();

    final List<Widget> thinkingCards = ThinkingCardsList(limitedPoints);

    return Div.column([
      // Instructions header
      InstructionsHeader(),

      const Spacing.height(16),

      // Thinking cards list
      Div.column(thinkingCards),
    ], crossAxisAlignment: CrossAxisAlignment.stretch);
  }

  List<String> getLimitedThinkingPoints() {
    return widget.content.thinkingPoints.take(3).toList();
  }

  Widget InstructionsHeader() {
    return RLTypography.bodyMedium(
      RLUIStrings.REFLECTION_ASPECTS_LABEL,
      color: RLDS.textPrimary.withValues(alpha: 0.7),
    );
  }

  List<Widget> ThinkingCardsList(List<String> points) {
    return points.asMap().entries.map((entry) {
      final int pointIndex = entry.key;
      final String point = entry.value;

      return ThinkingCard(
        point: point,
        pointIndex: pointIndex,
        isSelected: selectedPoints.contains(pointIndex),
        isSwiping: swipingPoints.contains(pointIndex),
        onSwipeComplete: () => confirmPoint(pointIndex),
      );
    }).toList();
  }

  Widget ThinkingCard({
    required String point,
    required int pointIndex,
    required bool isSelected,
    required bool isSwiping,
    required VoidCallback onSwipeComplete,
  }) {
    final Color cardColor = getCardColor(pointIndex);
    final BoxDecoration cardDecoration = getCardDecoration(
      cardColor: cardColor,
      isSelected: isSelected,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: SwipeGestureDetector(
        onSwipeComplete: onSwipeComplete,
        pointIndex: pointIndex,
        cardDecoration: cardDecoration,
        cardColor: cardColor,
        point: point,
        isSelected: isSelected,
        isSwiping: isSwiping,
      ),
    );
  }

  Color getCardColor(int pointIndex) {
    return cardColors[pointIndex % cardColors.length];
  }

  BoxDecoration getCardDecoration({required Color cardColor, required bool isSelected}) {
    Color cardBackgroundColor = RLDS.backgroundLight;

    if (isSelected) {
      cardBackgroundColor = cardColor.withValues(alpha: 0.1);
    }

    Color cardBorderColor = RLDS.textPrimary.withValues(alpha: 0.1);

    if (isSelected) {
      cardBorderColor = cardColor;
    }

    double cardBorderWidth = 1;

    if (isSelected) {
      cardBorderWidth = 2;
    }

    return BoxDecoration(
      color: cardBackgroundColor,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: cardBorderColor, width: cardBorderWidth),
    );
  }

  Widget SwipeGestureDetector({
    required VoidCallback onSwipeComplete,
    required int pointIndex,
    required BoxDecoration cardDecoration,
    required Color cardColor,
    required String point,
    required bool isSelected,
    required bool isSwiping,
  }) {
    return GestureDetector(
      onHorizontalDragEnd: (details) => handleSwipeEnd(details, onSwipeComplete),
      onHorizontalDragUpdate: (details) => handleSwipeUpdate(details, pointIndex),
      onHorizontalDragStart: (details) => handleSwipeStart(pointIndex),
      child: AnimatedCardContainer(
        cardDecoration: cardDecoration,
        cardColor: cardColor,
        point: point,
        isSelected: isSelected,
        isSwiping: isSwiping,
      ),
    );
  }

  void handleSwipeEnd(DragEndDetails details, VoidCallback onSwipeComplete) {
    final bool isValidSwipe = details.primaryVelocity != null && details.primaryVelocity! > 300;

    if (isValidSwipe) {
      onSwipeComplete();
    }
  }

  void handleSwipeUpdate(DragUpdateDetails details, int pointIndex) {
    final bool isSwipingRight = details.delta.dx > 2;

    if (isSwipingRight) {
      setState(() {
        swipingPoints.add(pointIndex);
      });
    }
  }

  void handleSwipeStart(int pointIndex) {
    setState(() {
      swipingPoints.remove(pointIndex);
    });
  }

  Widget AnimatedCardContainer({
    required BoxDecoration cardDecoration,
    required Color cardColor,
    required String point,
    required bool isSelected,
    required bool isSwiping,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(16),
      decoration: cardDecoration,
      child: Div.row([
        // Swipe indicator section
        SwipeIndicatorSection(
          cardColor: cardColor,
          isSelected: isSelected,
          isSwiping: isSwiping,
        ),

        const Spacing.width(12),

        // Content section
        CardContentSection(point: point, cardColor: cardColor, isSelected: isSelected),
      ]),
    );
  }

  Widget SwipeIndicatorSection({
    required Color cardColor,
    required bool isSelected,
    required bool isSwiping,
  }) {
    final Color indicatorColor = getIndicatorColor(
      cardColor: cardColor,
      isSelected: isSelected,
      isSwiping: isSwiping,
    );

    IconData indicatorIcon = Pixel.chevronright;

    if (isSelected) {
      indicatorIcon = Pixel.check;
    }

    Color iconColor = cardColor;

    if (isSelected) {
      iconColor = RLDS.white;
    }

    final Widget IndicatorIcon = Icon(indicatorIcon, color: iconColor, size: 16);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 32,
      height: 32,
      decoration: BoxDecoration(color: indicatorColor, borderRadius: BorderRadius.circular(16)),
      child: IndicatorIcon,
    );
  }

  Color getIndicatorColor({
    required Color cardColor,
    required bool isSelected,
    required bool isSwiping,
  }) {
    if (isSelected) {
      return cardColor;
    }

    if (isSwiping) {
      return cardColor.withValues(alpha: 0.3);
    }

    return RLDS.textPrimary.withValues(alpha: 0.1);
  }

  Widget CardContentSection({
    required String point,
    required Color cardColor,
    required bool isSelected,
  }) {
    Color textColor = RLDS.textPrimary.withValues(alpha: 0.8);

    if (isSelected) {
      textColor = cardColor;
    }

    final bool shouldShowSwipeInstruction = !isSelected;

    return Expanded(
      child: Div.column([
        // Main point text
        RLTypography.readingMedium(point, color: textColor),

        // Swipe instruction
        RenderIf.condition(
          shouldShowSwipeInstruction,
          Div.column([
            const Spacing.height(4),

            RLTypography.bodyMedium(
              RLUIStrings.REFLECTION_SWIPE_HINT,
              color: RLDS.textPrimary.withValues(alpha: 0.5),
            ),
          ]),
        ),
      ], crossAxisAlignment: CrossAxisAlignment.start),
    );
  }

  void confirmPoint(int pointIndex) {
    setState(() {
      swipingPoints.remove(pointIndex);

      final bool isPointNotYetSelected = !selectedPoints.contains(pointIndex);

      if (isPointNotYetSelected) {
        selectedPoints.add(pointIndex);
      }
    });
  }
}
