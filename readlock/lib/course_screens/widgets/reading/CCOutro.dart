// Course outro widget that displays concluding content for lessons
// Shows completion icon, title, progressive text animation, and Fin button when complete

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/course_screens/models/courseModel.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/utility_widgets/text_animation/TextAnimation.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLTheme.dart';
import 'package:readlock/constants/RLDesignSystem.dart';

// Styling constants
const double COMPLETION_ICON_SIZE = 24.0;
const double HEADER_SPACING = 12.0;
const double CONTENT_SPACING = 20.0;
const Duration TYPEWRITER_CHARACTER_DELAY = Duration(milliseconds: 15);

class CCOutro extends StatefulWidget {
  // Course outro content data
  final OutroContent content;

  // Navigation callback for lesson completion
  final VoidCallback? onLessonComplete;

  const CCOutro({
    super.key,
    required this.content,
    this.onLessonComplete,
  });

  @override
  State<CCOutro> createState() => CCOutroState();
}

class CCOutroState extends State<CCOutro> {
  // Track whether all text segments have been revealed
  bool isAllTextRevealed = false;

  @override
  Widget build(BuildContext context) {
    // Text style for title with custom font weight
    final TextStyle titleTextStyle = RLTypography.bodyLargeStyle
        .copyWith(fontWeight: FontWeight.w600);

    return Div.column(
      [
        // Header section with icon and title
        HeaderSection(titleTextStyle),

        const Spacing.height(CONTENT_SPACING),

        // Progressive text content
        ProgressiveTextSection(),

        const Spacer(),

        const Spacing.height(CONTENT_SPACING),

        // Fin button when text is complete
        if (isAllTextRevealed) ...[FinishButton()],
      ],
      color: RLTheme.backgroundDark,
      padding: RLTheme.contentPaddingInsets,
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  // Header section with completion icon and title
  Widget HeaderSection(TextStyle titleTextStyle) {
    return Div.row([
      // Completion icon
      CompletionIcon(),

      const Spacing.width(HEADER_SPACING),

      // Title text
      Expanded(
        child: Text(
          widget.content.title,
          style: titleTextStyle,
          textAlign: TextAlign.left,
        ),
      ),
    ]);
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
    final bool hasOutroTextSegments =
        widget.content.outroTextSegments.isNotEmpty;

    if (!hasOutroTextSegments) {
      return const SizedBox.shrink();
    }

    return ProgressiveText(
      textSegments: widget.content.outroTextSegments,
      textStyle: RLTypography.bodyLargeStyle,
      typewriterCharacterDelay: TYPEWRITER_CHARACTER_DELAY,
      textAlignment: CrossAxisAlignment.start,
      onAllSegmentsRevealed: HandleAllTextRevealed,
    );
  }

  // Handle completion of all text segments
  void HandleAllTextRevealed() {
    setState(() {
      isAllTextRevealed = true;
    });
  }

  // Finish button using RLDesignSystem
  Widget FinishButton() {
    return RLDesignSystem.BlockButton(
      children: [RLTypography.bodyLarge('Fin', color: Colors.white)],
      onTap: HandleFinishButtonTapped,
      backgroundColor: RLTheme.primaryGreen,
      margin: EdgeInsets.all(0),
    );
  }

  // Handle Fin button tap to navigate to reward screen
  void HandleFinishButtonTapped() {
    final VoidCallback? lessonCompleteCallback =
        widget.onLessonComplete;

    if (lessonCompleteCallback != null) {
      lessonCompleteCallback();
    }
  }
}
