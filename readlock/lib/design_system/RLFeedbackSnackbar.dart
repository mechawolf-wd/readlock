// Feedback snackbar system for course interactions
// Shows experience gains, hints, and other feedback at the bottom of the screen

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/bottom_sheets/course/FeedbackBottomSheet.dart';
import 'package:readlock/design_system/RLLunarBlur.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/services/feedback/HapticsService.dart';
import 'package:readlock/services/feedback/SoundService.dart';

import 'package:pixelarticons/pixel.dart';

// Snackbar controller singleton
class SnackbarController {
  OverlayEntry? overlayEntry;
  AnimatedSnackbarState? snackbarState;

  void show({required BuildContext context, required Widget content, Duration? duration}) {
    // Dismiss any existing snackbar instantly
    dismiss();

    final snackbar = AnimatedSnackbar(
      content: content,
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

    snackbarController.show(context: context, content: content);
  }

  static void showWrongAnswer(BuildContext context, {String? hint}) {
    final bool hasHint = hint != null && hint.isNotEmpty;

    Duration duration = const Duration(milliseconds: 3000);

    if (hasHint) {
      duration = const Duration(seconds: 5);
    }

    final Widget content = WrongAnswerContent(hasHint: hasHint, hint: hint);

    snackbarController.show(context: context, content: content, duration: duration);
  }

  static void showCustomFeedback(BuildContext context, String message, bool isCorrect) {
    Color accentColor = RLDS.info;

    if (isCorrect) {
      accentColor = RLDS.success;
    }

    final Widget content = RLTypography.bodyLarge(message, color: accentColor);

    snackbarController.show(context: context, content: content);
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
  final Duration? duration;
  final VoidCallback onDismiss;
  final void Function(AnimatedSnackbarState) onStateCreated;

  const AnimatedSnackbar({
    super.key,
    required this.content,
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
      duration: const Duration(milliseconds: 250),
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
    // Padding extends through the bottom safe-area inset so the solid colour
    // fill paints under the home-indicator — no bare strip between the
    // snackbar and the screen edge.
    final double bottomSafeArea = MediaQuery.of(context).padding.bottom;

    final EdgeInsets contentPadding = EdgeInsets.fromLTRB(
      RLDS.spacing20,
      RLDS.spacing16,
      RLDS.spacing20,
      RLDS.spacing16 + bottomSafeArea + RLDS.spacing8,
    );

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: slideAnimation,
        // Match the LoginSupport / Account bottom sheets — LunarBlur over the
        // shared `backgroundLight` surface so the snackbar reads as the same
        // family of frosted pane rising from the bottom edge. The semantic
        // colour (success / info) moves onto the label + icon instead of the
        // background. Transparent Material wraps the content so Text widgets
        // inherit a sane DefaultTextStyle (no debug yellow underlines).
        child: RLLunarBlur(
          borderRadius: RLDS.borderRadiusTopLarge,
          surfaceColor: RLDS.backgroundLight,
          child: Material(
            type: MaterialType.transparency,
            child: Padding(padding: contentPadding, child: widget.content),
          ),
        ),
      ),
    );
  }
}

// Correct answer content
class CorrectAnswerContent extends StatelessWidget {
  final bool hasExplanation;
  final String? explanation;

  const CorrectAnswerContent({super.key, required this.hasExplanation, this.explanation});

  static final Icon StarIcon = const Icon(Pixel.moonstars, color: RLDS.success, size: RLDS.iconMedium);

  @override
  Widget build(BuildContext context) {
    return Div.row([
      StarIcon,

      const Spacing.width(RLDS.spacing12),

      Expanded(
        child: RLTypography.bodyLarge(RLUIStrings.CORRECT_ANSWER_MESSAGE, color: RLDS.success),
      ),

      RenderIf.condition(hasExplanation, WhyButton(explanation: explanation)),
    ], crossAxisAlignment: CrossAxisAlignment.center);
  }
}

// Why button
class WhyButton extends StatelessWidget {
  final String? explanation;

  const WhyButton({super.key, this.explanation});

  void handleTap(BuildContext context) {
    HapticsService.lightImpact();
    SoundService.playRandomTextClick();
    FeedbackSnackBar.dismissAnimated();

    if (explanation != null) {
      FeedbackBottomSheets.showExplanation(context: context, explanation: explanation!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle buttonStyle = RLTypography.bodyMediumStyle.copyWith(
      color: RLDS.success,
      fontWeight: FontWeight.w600,
    );

    return GestureDetector(
      onTap: () => handleTap(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: RLDS.spacing8, vertical: RLDS.spacing4),
        child: Text(RLUIStrings.WHY_BUTTON_LABEL, style: buttonStyle),
      ),
    );
  }
}

// Wrong answer content
class WrongAnswerContent extends StatelessWidget {
  final bool hasHint;
  final String? hint;

  const WrongAnswerContent({super.key, required this.hasHint, this.hint});

  static final Icon LightbulbIcon = const Icon(Pixel.infobox, color: RLDS.info, size: RLDS.iconMedium);

  @override
  Widget build(BuildContext context) {
    return Div.row([
      LightbulbIcon,

      const Spacing.width(RLDS.spacing12),

      Expanded(child: RLTypography.bodyLarge(RLUIStrings.WRONG_ANSWER_TITLE, color: RLDS.info)),

      RenderIf.condition(hasHint, HintButton(hint: hint)),
    ], crossAxisAlignment: CrossAxisAlignment.center);
  }
}

// Hint button
class HintButton extends StatelessWidget {
  final String? hint;

  const HintButton({super.key, this.hint});

  void handleTap(BuildContext context) {
    HapticsService.lightImpact();
    SoundService.playRandomTextClick();
    FeedbackSnackBar.dismissAnimated();

    if (hint != null) {
      FeedbackBottomSheets.showHint(context: context, hint: hint!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle buttonStyle = RLTypography.bodyMediumStyle.copyWith(
      color: RLDS.info,
      fontWeight: FontWeight.w600,
    );

    return GestureDetector(
      onTap: () => handleTap(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: RLDS.spacing8, vertical: RLDS.spacing4),
        child: Text(RLUIStrings.HINT_BUTTON_LABEL, style: buttonStyle),
      ),
    );
  }
}
