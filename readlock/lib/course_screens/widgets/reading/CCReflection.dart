// Widget that displays reflective prompts for deeper thinking
// Encourages users to pause and think about design concepts

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/RLConstants.dart';
import 'package:readlock/course_screens/models/courseModel.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLTheme.dart';
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

    cardColors = [RLTheme.primaryBlue, Colors.purple, Colors.orange];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: RLTheme.backgroundDark,
      padding: const EdgeInsets.all(RLConstants.COURSE_SECTION_PADDING),
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

    return Div.column([
      // Instructions header
      buildInstructionsHeader(),

      const Spacing.height(16),

      // Thinking cards list
      ...buildThinkingCardsList(limitedPoints),
    ], crossAxisAlignment: CrossAxisAlignment.stretch);
  }

  List<String> getLimitedThinkingPoints() {
    return widget.content.thinkingPoints.take(3).toList();
  }

  Widget buildInstructionsHeader() {
    return RLTypography.bodyMedium(
      'Consider these aspects:',
      color: RLTheme.textPrimary.withValues(alpha: 0.7),
    );
  }

  List<Widget> buildThinkingCardsList(List<String> points) {
    return points.asMap().entries.map((entry) {
      final int index = entry.key;
      final String point = entry.value;
      
      return ThinkingCardWidget(
        point: point,
        index: index,
        isSelected: selectedPoints.contains(index),
        isSwiping: swipingPoints.contains(index),
        onSwipeComplete: () => confirmPoint(index),
      );
    }).toList();
  }

  Widget ThinkingCardWidget({
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
      child: buildSwipeGestureDetector(
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
    return BoxDecoration(
      color: isSelected
          ? cardColor.withValues(alpha: 0.1)
          : RLTheme.backgroundLight,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isSelected
            ? cardColor
            : RLTheme.textPrimary.withValues(alpha: 0.1),
        width: isSelected ? 2 : 1,
      ),
    );
  }

  Widget buildSwipeGestureDetector({
    required VoidCallback onSwipeComplete,
    required int index,
    required BoxDecoration cardDecoration,
    required Color cardColor,
    required String point,
    required bool isSelected,
    required bool isSwiping,
  }) {
    return GestureDetector(
      onHorizontalDragEnd: (details) => handleSwipeEnd(details, onSwipeComplete),
      onHorizontalDragUpdate: (details) => handleSwipeUpdate(details, index),
      onHorizontalDragStart: (details) => handleSwipeStart(index),
      child: buildAnimatedCardContainer(
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

  void handleSwipeUpdate(DragUpdateDetails details, int index) {
    if (details.delta.dx > 2) {
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

  Widget buildAnimatedCardContainer({
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
        buildSwipeIndicatorSection(
          cardColor: cardColor,
          isSelected: isSelected,
          isSwiping: isSwiping,
        ),
        
        const Spacing.width(12),
        
        // Content section
        buildCardContentSection(
          point: point,
          cardColor: cardColor,
          isSelected: isSelected,
        ),
      ]),
    );
  }

  Widget buildSwipeIndicatorSection({
    required Color cardColor,
    required bool isSelected,
    required bool isSwiping,
  }) {
    final Color indicatorColor = getIndicatorColor(
      cardColor: cardColor,
      isSelected: isSelected,
      isSwiping: isSwiping,
    );

    final IconData indicatorIcon = isSelected ? Icons.check : Icons.arrow_forward_ios;
    final Color iconColor = isSelected ? Colors.white : cardColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: indicatorColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(
        indicatorIcon,
        color: iconColor,
        size: 16,
      ),
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

  Widget buildCardContentSection({
    required String point,
    required Color cardColor,
    required bool isSelected,
  }) {
    final Color textColor = isSelected 
        ? cardColor 
        : RLTheme.textPrimary.withValues(alpha: 0.8);

    return Expanded(
      child: Div.column([
        // Main point text
        RLTypography.bodyMedium(
          point,
          color: textColor,
        ),
        
        // Swipe instruction
        if (!isSelected) ...[
          const Spacing.height(4),
          
          RLTypography.bodyMedium(
            'Swipe right to confirm',
            color: RLTheme.textPrimary.withValues(alpha: 0.5),
          ),
        ],
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
