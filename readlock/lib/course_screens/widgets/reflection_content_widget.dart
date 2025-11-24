// Widget that displays reflective prompts for deeper thinking
// Encourages users to pause and think about design concepts

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/app_constants.dart';
import 'package:readlock/course_screens/models/course_model.dart';
import 'package:readlock/utility_widgets/utility_widgets.dart';
import 'package:readlock/constants/typography.dart';
import 'package:readlock/constants/app_theme.dart';
import 'package:readlock/utility_widgets/text_animation/progressive_text.dart';

class ReflectionContentWidget extends StatefulWidget {
  final ReflectionContent content;

  const ReflectionContentWidget({super.key, required this.content});

  @override
  State<ReflectionContentWidget> createState() =>
      ReflectionContentWidgetState();
}

class ReflectionContentWidgetState
    extends State<ReflectionContentWidget> {
  Set<int> selectedPoints = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.backgroundDark,
      padding: const EdgeInsets.all(Constants.COURSE_SECTION_PADDING),
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
      color: AppTheme.backgroundLight,
      borderRadius: BorderRadius.circular(16),
    );

    final TextStyle promptTextStyle = Typography.bodyLargeStyle
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
      Typography.bodyMedium(
        'Consider these aspects:',
        color: AppTheme.textPrimary.withValues(alpha: 0.7),
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
    final colors = [AppTheme.primaryBlue, Colors.purple, Colors.orange];

    final color = colors[index % colors.length];

    final BoxDecoration cardDecoration = BoxDecoration(
      color: isSelected
          ? color.withValues(alpha: 0.1)
          : AppTheme.backgroundLight,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isSelected
            ? color
            : AppTheme.textPrimary.withValues(alpha: 0.1),
        width: isSelected ? 2 : 1,
      ),
    );

    final BoxDecoration checkboxDecoration = BoxDecoration(
      color: isSelected ? color : Colors.transparent,
      borderRadius: BorderRadius.circular(6),
      border: Border.all(
        color: isSelected
            ? color
            : AppTheme.textPrimary.withValues(alpha: 0.3),
        width: 2,
      ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Div.row([
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 24,
          height: 24,
          decoration: checkboxDecoration,
          child: isSelected
              ? const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                )
              : null,
        ),
        const Spacing.width(12),
        Expanded(
          child: Typography.bodyMedium(
            point,
            color: isSelected
                ? color
                : AppTheme.textPrimary.withValues(alpha: 0.8),
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
