import 'package:flutter/material.dart' hide Typography;
import 'package:relevant/course_screens/models/course_model.dart';
import 'package:relevant/utility_widgets/text_animation/progressive_text.dart';
import 'package:relevant/constants/typography.dart';

class TextContentWidget extends StatelessWidget {
  final TextContent content;

  const TextContentWidget({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ProgressiveText(
        textSegments: content.textSegments,
        textStyle: Typography.bodyMediumStyle,
        characterDelay: const Duration(milliseconds: 15),
      ),
    );
  }
}
