// Widget that displays reflective prompts for deeper thinking
// Encourages users to pause and think about design concepts

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/models/CourseModel.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLTheme.dart';
import 'package:readlock/constants/RLConstants.dart';
import 'package:readlock/utility_widgets/text_animation/ProgressiveText.dart';

class CCReflection extends StatefulWidget {
  final ReflectionContent content;

  const CCReflection({super.key, required this.content});

  @override
  State<CCReflection> createState() => CCReflectionState();
}

class CCReflectionState extends State<CCReflection> {
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
      color: RLTheme.backgroundLight,
      borderRadius: BorderRadius.circular(16),
    );

    promptTextStyle = RLTypography.bodyLargeStyle.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      height: 1.6,
    );

    cardColors = [RLTheme.primaryBlue, RLTheme.accentPurple, RLTheme.warningColor];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: RLTheme.backgroundDark,
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
      child: ProgressiveText(
        textSegments: [widget.content.prompt],
        textStyle: promptTextStyle,
      ),
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
      REFLECTION_ASPECTS_LABEL,
      color: RLTheme.textPrimary.withValues(alpha: 0.7),
    );
  }

  List<Widget> ThinkingCardsList(List<String> points) {
    return points.asMap().entries.map((entry) {
      final int index = entry.key;
      final String point = entry.value;

      return ThinkingCard(
        point: point,
        index: index,
        isSelected: selectedPoints.contains(index),
        isSwiping: swipingPoints.contains(index),
        onSwipeComplete: () => confirmPoint(index),
      );
    }).toList();
  }

  Widget ThinkingCard({
    required String point,
    required int index,
    required bool isSelected,
    required bool isSwiping,
    required VoidCallback onSwipeComplete,
  }) {
    final Color cardColor = getCardColor(index);
    final BoxDecoration cardDecoration = getCardDecoration(
      cardColor: cardColor,
      isSelected: isSelected,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: SwipeGestureDetector(
        onSwipeComplete: onSwipeComplete,
        index: index,
        cardDecoration: cardDecoration,
        cardColor: cardColor,
        point: point,
        isSelected: isSelected,
        isSwiping: isSwiping,
      ),
    );
  }

  Color getCardColor(int index) {
    return cardColors[index % cardColors.length];
  }

  BoxDecoration getCardDecoration({
    required Color cardColor,
    required bool isSelected,
  }) {
    final Color cardBackgroundColor = isSelected
        ? cardColor.withValues(alpha: 0.1)
        : RLTheme.backgroundLight;

    final Color cardBorderColor = isSelected
        ? cardColor
        : RLTheme.textPrimary.withValues(alpha: 0.1);

    final double cardBorderWidth = isSelected ? 2 : 1;

    return BoxDecoration(
      color: cardBackgroundColor,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: cardBorderColor,
        width: cardBorderWidth,
      ),
    );
  }

  Widget SwipeGestureDetector({
    required VoidCallback onSwipeComplete,
    required int index,
    required BoxDecoration cardDecoration,
    required Color cardColor,
    required String point,
    required bool isSelected,
    required bool isSwiping,
  }) {
    return GestureDetector(
      onHorizontalDragEnd: (details) =>
          handleSwipeEnd(details, onSwipeComplete),
      onHorizontalDragUpdate: (details) =>
          handleSwipeUpdate(details, index),
      onHorizontalDragStart: (details) => handleSwipeStart(index),
      child: AnimatedCardContainer(
        cardDecoration: cardDecoration,
        cardColor: cardColor,
        point: point,
        isSelected: isSelected,
        isSwiping: isSwiping,
      ),
    );
  }

  void handleSwipeEnd(
    DragEndDetails details,
    VoidCallback onSwipeComplete,
  ) {
    final bool isValidSwipe =
        details.primaryVelocity != null &&
        details.primaryVelocity! > 300;

    if (isValidSwipe) {
      onSwipeComplete();
    }
  }

  void handleSwipeUpdate(DragUpdateDetails details, int index) {
    final bool isSwipingRight = details.delta.dx > 2;

    if (isSwipingRight) {
      setState(() {
        swipingPoints.add(index);
      });
    }
  }

  void handleSwipeStart(int index) {
    setState(() {
      swipingPoints.remove(index);
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
        CardContentSection(
          point: point,
          cardColor: cardColor,
          isSelected: isSelected,
        ),
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

    IconData indicatorIcon = Icons.arrow_forward_ios;

    if (isSelected) {
      indicatorIcon = Icons.check;
    }

    Color iconColor = cardColor;

    if (isSelected) {
      iconColor = RLTheme.white;
    }

    final Widget IndicatorIcon = Icon(
      indicatorIcon,
      color: iconColor,
      size: 16,
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: indicatorColor,
        borderRadius: BorderRadius.circular(16),
      ),
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

    return RLTheme.textPrimary.withValues(alpha: 0.1);
  }

  Widget CardContentSection({
    required String point,
    required Color cardColor,
    required bool isSelected,
  }) {
    Color textColor = RLTheme.textPrimary.withValues(alpha: 0.8);

    if (isSelected) {
      textColor = cardColor;
    }

    final bool shouldShowSwipeInstruction = !isSelected;

    return Expanded(
      child: Div.column([
        // Main point text
        RLTypography.bodyMedium(point, color: textColor),

        // Swipe instruction
        RenderIf.condition(
          shouldShowSwipeInstruction,
          Div.column([
            const Spacing.height(4),

            RLTypography.bodyMedium(
              REFLECTION_SWIPE_HINT,
              color: RLTheme.textPrimary.withValues(alpha: 0.5),
            ),
          ]),
        ),
      ], crossAxisAlignment: CrossAxisAlignment.start),
    );
  }

  void confirmPoint(int index) {
    setState(() {
      swipingPoints.remove(index);
      if (!selectedPoints.contains(index)) {
        selectedPoints.add(index);
      }
    });
  }
}
