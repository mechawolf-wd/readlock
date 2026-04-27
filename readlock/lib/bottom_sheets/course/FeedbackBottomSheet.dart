// Centralized bottom sheet modals for course feedback
// Provides consistent UI for explanations and hints across the app

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/bottom_sheets/RLBottomSheet.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/utility_widgets/text_animation/BionicText.dart';

class FeedbackBottomSheets {
  // Show explanation bottom sheet for correct answers
  static void showExplanation({required BuildContext context, required String explanation}) {
    showFeedbackSheet(context: context, content: explanation);
  }

  // Show hint bottom sheet for wrong answers
  static void showHint({required BuildContext context, required String hint}) {
    showFeedbackSheet(context: context, content: hint);
  }

  // Generic bottom sheet implementation — LunarBlur over `backgroundLight` to
  // match the LoginSupport / Account sheets, so the Why?/Hint/Consequence
  // sheets read as the same frosted pane family as the snackbar that opens
  // them.
  static void showFeedbackSheet({
    required BuildContext context,
    required String content,
  }) {
    RLBottomSheet.show(
      context,
      backgroundColor: RLDS.backgroundLight,
      showGrabber: false,
      child: FeedbackSheet(content: content),
    );
  }
}

class FeedbackSheet extends StatelessWidget {
  final String content;

  const FeedbackSheet({super.key, required this.content});

  // Style definitions
  static const EdgeInsets bodyPadding = EdgeInsets.fromLTRB(
    RLDS.spacing24,
    RLDS.spacing24,
    RLDS.spacing24,
    RLDS.spacing24,
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).pop(),
      child: Padding(
        padding: bodyPadding,
        child: BionicAwareReadingText(content: content),
      ),
    );
  }
}

// Reading body that mirrors RLTypography.readingLarge but flips into
// bionic-bold spans when the global bionic toggle is on. Listens to the
// notifier so the sheet repaints live if the user flips the setting while
// the sheet is open — matches the ProgressiveText contract used in CC content.
class BionicAwareReadingText extends StatelessWidget {
  final String content;

  const BionicAwareReadingText({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: bionicEnabledNotifier,
      builder: (context, bionicEnabled, _) {
        final TextStyle baseStyle = RLTypography.readingLargeStyle;

        if (!bionicEnabled) {
          return Text(content, style: baseStyle, textAlign: TextAlign.left);
        }

        final List<InlineSpan> spans = bionicSpans(content, baseStyle);

        return Text.rich(
          TextSpan(children: spans),
          textAlign: TextAlign.left,
        );
      },
    );
  }
}
