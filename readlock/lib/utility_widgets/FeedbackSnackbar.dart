// Feedback snackbar system for course interactions
// Shows experience gains, hints, and other feedback at the bottom of the screen

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/RLConstants.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLTheme.dart';
import 'package:readlock/bottom_sheets/course/FeedbackBottomSheet.dart';
import 'package:readlock/utility_widgets/Utility.dart';

// Snackbar controller singleton
class SnackbarController {
  OverlayEntry? overlayEntry;
  AnimatedSnackbarState? snackbarState;

  void show({
    required BuildContext context,
    required Widget content,
    required Color backgroundColor,
    Duration? duration,
  }) {
    // Dismiss any existing snackbar instantly
    dismiss();

    final snackbar = AnimatedSnackbar(
      content: content,
      backgroundColor: backgroundColor,
      duration: duration,
      onDismiss: dismiss,
      onStateCreated: (state) {
        snackbarState = state;
      },
    );

    overlayEntry = OverlayEntry(builder: (context) => snackbar);

    Overlay.of(context).insert(overlayEntry!);
  }

  void dismiss() {
    snackbarState = null;
    overlayEntry?.remove();
    overlayEntry = null;
  }

  void animatedDismiss() {
    final AnimatedSnackbarState? currentState = snackbarState;

    final bool hasNoState = currentState == null;

    if (hasNoState) {
      dismiss();
      return;
    }

    currentState.animateOut().then((result) {
      overlayEntry?.remove();
      overlayEntry = null;
      snackbarState = null;
    });
  }
}

final snackbarController = SnackbarController();

// Public API
class FeedbackSnackBar {
  static void showCorrectAnswer(BuildContext context, {String? explanation}) {
    final bool hasExplanation = explanation != null && explanation.isNotEmpty;

    final Widget content = CorrectAnswerContent(
      hasExplanation: hasExplanation,
      explanation: explanation,
    );

    snackbarController.show(
      context: context,
      content: content,
      backgroundColor: RLTheme.primaryGreen,
    );
  }

  static void showWrongAnswer(BuildContext context, {String? hint}) {
    final bool hasHint = hint != null && hint.isNotEmpty;

    final Duration duration = hasHint ? HINT_SNACKBAR_DURATION : DEFAULT_SNACKBAR_DURATION;

    final Widget content = WrongAnswerContent(hasHint: hasHint, hint: hint);

    snackbarController.show(
      context: context,
      content: content,
      backgroundColor: RLTheme.primaryBlue,
      duration: duration,
    );
  }

  static void showCustomFeedback(BuildContext context, String message, bool isCorrect) {
    final Color backgroundColor = isCorrect ? RLTheme.primaryGreen : RLTheme.primaryBlue;

    final Widget content = RLTypography.bodyLarge(message, color: RLTheme.white);

    snackbarController.show(
      context: context,
      content: content,
      backgroundColor: backgroundColor,
    );
  }

  static void clearSnackbars() {
    snackbarController.dismiss();
  }

  static void dismissAnimated() {
    snackbarController.animatedDismiss();
  }
}

// Animated snackbar widget
class AnimatedSnackbar extends StatefulWidget {
  final Widget content;
  final Color backgroundColor;
  final Duration? duration;
  final VoidCallback onDismiss;
  final void Function(AnimatedSnackbarState) onStateCreated;

  const AnimatedSnackbar({
    required this.content,
    required this.backgroundColor,
    required this.duration,
    required this.onDismiss,
    required this.onStateCreated,
  });

  @override
  State<AnimatedSnackbar> createState() => AnimatedSnackbarState();
}

class AnimatedSnackbarState extends State<AnimatedSnackbar>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<Offset> slideAnimation;

  @override
  void initState() {
    super.initState();

    widget.onStateCreated(this);

    animationController = AnimationController(
      vsync: this,
      duration: SNACKBAR_ANIMATION_DURATION,
    );

    slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    animationController.forward();

    // Auto-dismiss if duration is set
    final bool shouldAutoDismiss = widget.duration != null;

    if (shouldAutoDismiss) {
      Future.delayed(widget.duration!, () {
        if (mounted) {
          animateOut().then((_) => widget.onDismiss());
        }
      });
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  Future<void> animateOut() {
    return animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final double bottomSafeArea = MediaQuery.of(context).padding.bottom;

    final EdgeInsets contentPadding = EdgeInsets.fromLTRB(
      SNACKBAR_HORIZONTAL_PADDING,
      SNACKBAR_VERTICAL_PADDING,
      SNACKBAR_HORIZONTAL_PADDING,
      SNACKBAR_VERTICAL_PADDING + bottomSafeArea + SNACKBAR_BOTTOM_SAFE_AREA_EXTRA,
    );

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: slideAnimation,
        child: Material(
          color: widget.backgroundColor,
          child: Padding(padding: contentPadding, child: widget.content),
        ),
      ),
    );
  }
}

// Correct answer content
class CorrectAnswerContent extends StatelessWidget {
  final bool hasExplanation;
  final String? explanation;

  const CorrectAnswerContent({required this.hasExplanation, this.explanation});

  static const Icon StarIcon = Icon(Icons.star, color: RLTheme.white, size: 20);

  @override
  Widget build(BuildContext context) {
    return Div.row([
      StarIcon,

      const Spacing.width(12),

      Expanded(child: RLTypography.bodyLarge(CORRECT_ANSWER_MESSAGE, color: RLTheme.white)),

      RenderIf.condition(hasExplanation, WhyButton(explanation: explanation)),
    ], crossAxisAlignment: CrossAxisAlignment.center);
  }
}

// Why button
class WhyButton extends StatelessWidget {
  final String? explanation;

  const WhyButton({this.explanation});

  void handleTap(BuildContext context) {
    FeedbackSnackBar.dismissAnimated();

    if (explanation != null) {
      FeedbackBottomSheets.showExplanation(context: context, explanation: explanation!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle buttonStyle = RLTypography.bodyMediumStyle.copyWith(
      color: RLTheme.white,
      fontWeight: FontWeight.w600,
    );

    return GestureDetector(
      onTap: () => handleTap(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text('Why?', style: buttonStyle),
      ),
    );
  }
}

// Wrong answer content
class WrongAnswerContent extends StatelessWidget {
  final bool hasHint;
  final String? hint;

  const WrongAnswerContent({required this.hasHint, this.hint});

  static const Icon LightbulbIcon = Icon(
    Icons.lightbulb_outline,
    color: RLTheme.white,
    size: 20,
  );

  @override
  Widget build(BuildContext context) {
    return Div.row([
      LightbulbIcon,

      const Spacing.width(12),

      Expanded(child: RLTypography.bodyLarge(WRONG_ANSWER_TITLE, color: RLTheme.white)),

      RenderIf.condition(hasHint, HintButton(hint: hint)),
    ], crossAxisAlignment: CrossAxisAlignment.center);
  }
}

// Hint button
class HintButton extends StatelessWidget {
  final String? hint;

  const HintButton({this.hint});

  void handleTap(BuildContext context) {
    FeedbackSnackBar.dismissAnimated();

    if (hint != null) {
      FeedbackBottomSheets.showHint(context: context, hint: hint!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle buttonStyle = RLTypography.bodyMediumStyle.copyWith(
      color: RLTheme.white,
      fontWeight: FontWeight.w600,
    );

    return GestureDetector(
      onTap: () => handleTap(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text('Hint', style: buttonStyle),
      ),
    );
  }
}
