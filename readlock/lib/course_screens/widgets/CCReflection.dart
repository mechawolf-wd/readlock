// Widget that displays reflective prompts for deeper thinking
// Encourages users to pause and think about design concepts

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/constants.dart';
import 'package:readlock/course_screens/models/courseModel.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/typography.dart';
import 'package:readlock/constants/appTheme.dart';
import 'package:readlock/utility_widgets/text_animation/ProgressiveText.dart';

class CCReflection extends StatefulWidget {
  final ReflectionContent content;

  const CCReflection({super.key, required this.content});

  @override
  State<CCReflection> createState() => CCReflectionState();
}

class CCReflectionState extends State<CCReflection> {
  Set<int> selectedPoints = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: RLTheme.backgroundDark,
      padding: const EdgeInsets.all(RLConstants.COURSE_SECTION_PADDING),
      child: Center(
        child: Div.column(
          [
            ReflectionPrompt(),

            const Spacing.height(24),

            ThinkingCards(),

            const Spacing.height(24),
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
    );
  }

  Widget ReflectionPrompt() {
    final BoxDecoration promptDecoration = BoxDecoration(
      color: RLTheme.backgroundLight,
      borderRadius: BorderRadius.circular(16),
    );

    final TextStyle promptTextStyle = RLTypography.bodyLargeStyle
        .copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1.6,
        );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: promptDecoration,
      child: ProgressiveText(
        textSegments: [widget.content.prompt],
        textStyle: promptTextStyle,
      ),
    );
  }

  Widget ThinkingCards() {
    // Limit to first 3 thinking points for better UX
    final limitedPoints = widget.content.thinkingPoints
        .take(3)
        .toList();

    return Div.column([
      RLTypography.bodyMedium(
        'Consider these aspects:',
        color: RLTheme.textPrimary.withValues(alpha: 0.7),
      ),

      const Spacing.height(16),

      ...limitedPoints.asMap().entries.map((entry) {
        final int index = entry.key;
        final String point = entry.value;
        return ThinkingCard(
          point: point,
          index: index,
          isSelected: selectedPoints.contains(index),
          onTap: () => togglePoint(index),
        );
      }),
    ], crossAxisAlignment: CrossAxisAlignment.stretch);
  }

  Widget ThinkingCard({
    required String point,
    required int index,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colors = [RLTheme.primaryBlue, Colors.purple, Colors.orange];

    final color = colors[index % colors.length];

    final BoxDecoration cardDecoration = BoxDecoration(
      color: isSelected
          ? color.withValues(alpha: 0.1)
          : RLTheme.backgroundLight,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isSelected
            ? color
            : RLTheme.textPrimary.withValues(alpha: 0.1),
        width: isSelected ? 2 : 1,
      ),
    );

    final BoxDecoration checkboxDecoration = BoxDecoration(
      color: isSelected ? color : Colors.transparent,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(
        color: isSelected
            ? color
            : RLTheme.textPrimary.withValues(alpha: 0.3),
        width: 2,
      ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Div.row(
        [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 24,
            height: 24,
            decoration: checkboxDecoration,
            child: isSelected
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : null,
          ),
          const Spacing.width(12),
          Expanded(
            child: RLTypography.bodyMedium(
              point,
              color: isSelected
                  ? color
                  : RLTheme.textPrimary.withValues(alpha: 0.8),
            ),
          ),
        ],
        padding: const EdgeInsets.all(16),
        decoration: cardDecoration,
        radius: BorderRadius.circular(12),
        onTap: onTap,
      ),
    );
  }

  void togglePoint(int index) {
    setState(() {
      if (selectedPoints.contains(index)) {
        selectedPoints.remove(index);
      } else {
        selectedPoints.add(index);
      }
    });
  }
}
