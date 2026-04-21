// Reflective prompt swipe — renders the prompt at the top and a short list
// of thinking points below, each in its own accent colour. Read-only:
// no swipe-to-confirm, no selection state.

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/models/CourseModel.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/utility_widgets/text_animation/ProgressiveText.dart';

// * Each thinking point rotates through one of these accent colours.
const List<Color> REFLECT_POINT_COLORS = [
  RLDS.info,
  RLDS.success,
  RLDS.warning,
];

const int REFLECT_POINTS_LIMIT = 3;

class CCReflect extends StatelessWidget {
  final ReflectSwipe content;

  const CCReflect({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: RLDS.backgroundDark,
      padding: RLDS.contentPaddingInsets,
      child: SingleChildScrollView(
        child: Div.column(
          ReflectBody(),
          crossAxisAlignment: CrossAxisAlignment.stretch,
        ),
      ),
    );
  }

  List<Widget> ReflectBody() {
    return [
      PromptSection(),

      const Spacing.height(RLDS.spacing24),

      AspectsHeader(),

      const Spacing.height(RLDS.spacing12),

      ...PointCards(),
    ];
  }

  Widget PromptSection() {
    final BoxDecoration promptDecoration = BoxDecoration(
      color: RLDS.backgroundLight,
      borderRadius: RLDS.borderRadiusSmall,
    );

    return Container(
      padding: const EdgeInsets.all(RLDS.spacing20),
      decoration: promptDecoration,
      child: ProgressiveText(
        textSegments: [content.prompt],
        textStyle: RLTypography.readingLargeStyle,
        blurCompletedSentences: false,
        enableTapToReveal: false,
      ),
    );
  }

  Widget AspectsHeader() {
    return RLTypography.bodyMedium(
      RLUIStrings.REFLECTION_ASPECTS_LABEL,
      color: RLDS.textPrimary.withValues(alpha: 0.7),
    );
  }

  List<Widget> PointCards() {
    final List<String> limitedPoints = content.thinkingPoints.take(REFLECT_POINTS_LIMIT).toList();

    return limitedPoints.asMap().entries.map((entry) {
      final int pointIndex = entry.key;
      final String point = entry.value;
      final Color pointColor = REFLECT_POINT_COLORS[pointIndex % REFLECT_POINT_COLORS.length];

      return Padding(
        padding: const EdgeInsets.only(bottom: RLDS.spacing12),
        child: PointCard(point: point, color: pointColor),
      );
    }).toList();
  }

  Widget PointCard({required String point, required Color color}) {
    final BoxDecoration cardDecoration = BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: RLDS.borderRadiusSmall,
      border: Border.all(color: color, width: 1),
    );

    return Container(
      padding: const EdgeInsets.all(RLDS.spacing16),
      decoration: cardDecoration,
      child: RLTypography.readingMedium(point, color: color),
    );
  }
}
