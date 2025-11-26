// Course outro widget that displays concluding content for lessons
// Shows completion icon, title, and progressive text animation

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/course_screens/models/courseModel.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/utility_widgets/text_animation/TextAnimation.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLTheme.dart';

// Styling constants
const double COMPLETION_ICON_SIZE = 24.0;
const double HEADER_SPACING = 12.0;
const double CONTENT_SPACING = 20.0;
const Duration TYPEWRITER_CHARACTER_DELAY = Duration(milliseconds: 15);

class CCOutro extends StatelessWidget {
  // Course outro content data
  final OutroContent content;

  const CCOutro({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    // Text style for title with custom font weight
    final TextStyle titleTextStyle = RLTypography.bodyLargeStyle.copyWith(
      fontWeight: FontWeight.w600,
    );

    return Div.column(
      [
        // Header section with icon and title
        HeaderSection(titleTextStyle),

        const Spacing.height(CONTENT_SPACING),

        // Progressive text content
        ProgressiveTextSection(),
      ],
      color: RLTheme.backgroundDark,
      padding: RLTheme.contentPaddingInsets,
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  // Header section with completion icon and title
  Widget HeaderSection(TextStyle titleTextStyle) {
    return Div.row(
      [
        // Completion icon
        CompletionIcon(),

        const Spacing.width(HEADER_SPACING),

        // Title text
        Expanded(
          child: Text(
            content.title,
            style: titleTextStyle,
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }

  // Completion check circle icon
  Widget CompletionIcon() {
    return const Icon(
      Icons.check_circle,
      color: RLTheme.primaryGreen,
      size: COMPLETION_ICON_SIZE,
    );
  }

  // Progressive text animation section
  Widget ProgressiveTextSection() {
    final bool hasOutroTextSegments = content.outroTextSegments.isNotEmpty;

    if (!hasOutroTextSegments) {
      return const SizedBox.shrink();
    }

    return ProgressiveText(
      textSegments: content.outroTextSegments,
      textStyle: RLTypography.bodyLargeStyle,
      typewriterCharacterDelay: TYPEWRITER_CHARACTER_DELAY,
      textAlignment: CrossAxisAlignment.start,
    );
  }
}
