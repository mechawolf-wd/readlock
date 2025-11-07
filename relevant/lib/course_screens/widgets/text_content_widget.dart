import 'package:flutter/material.dart';
import 'package:relevant/course_screens/models/course_model.dart';
import 'package:relevant/course_screens/widgets/progressive_text_widget.dart';
import 'package:relevant/utility_widgets/utility_widgets.dart';

class TextContentWidget extends StatelessWidget {
  final TextContent content;

  const TextContentWidget({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Div.column(
        [ProgressiveTextWidget(text: content.text)],
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    );
  }
}
