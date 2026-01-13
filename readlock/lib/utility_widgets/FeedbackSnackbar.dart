// Feedback snackbar system for course interactions
// Shows experience gains, hints, and other feedback at the bottom of the screen

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLTheme.dart';
import 'package:readlock/utility_widgets/FeedbackBottomSheet.dart';
import 'package:readlock/utility_widgets/Utility.dart';

// Text constants
const String CORRECT_ANSWER_MESSAGE = '+5 experience';
const String WRONG_ANSWER_TITLE = 'Common thought';

// Timing constants
const Duration SNACKBAR_ANIMATION_DURATION = Duration(milliseconds: 250);
const Duration DEFAULT_SNACKBAR_DURATION = Duration(milliseconds: 3000);
const Duration HINT_SNACKBAR_DURATION = Duration(seconds: 5);

// Sizing constants
const double SNACKBAR_VERTICAL_PADDING = 16.0;
const double SNACKBAR_HORIZONTAL_PADDING = 20.0;
const double SNACKBAR_BOTTOM_SAFE_AREA_EXTRA = 8.0;

// Snackbar controller singleton
class _SnackbarController {
  OverlayEntry? _entry;
  _AnimatedSnackbarState? _state;

  void show({
    required BuildContext context,
    required Widget content,
    required Color backgroundColor,
    Duration? duration,
  }) {
    // Dismiss any existing snackbar instantly
    dismiss();

    final snackbar = _AnimatedSnackbar(
      content: content,
      backgroundColor: backgroundColor,
      duration: duration,
      onDismiss: dismiss,
      onStateCreated: (state) => _state = state,
    );

    _entry = OverlayEntry(
      builder: (context) => snackbar,
    );

    Overlay.of(context).insert(_entry!);
  }

  void dismiss() {
    _state = null;
    _entry?.remove();
    _entry = null;
  }

  void animatedDismiss() {
    final state = _state;

    if (state == null) {
      dismiss();
      return;
    }

    state.animateOut().then((_) {
      _entry?.remove();
      _entry = null;
      _state = null;
    });
  }
}

final _snackbarController = _SnackbarController();

// Public API
class FeedbackSnackBar {
  static void showCorrectAnswer(
    BuildContext context, {
    String? explanation,
  }) {
    final bool hasExplanation =
        explanation != null && explanation.isNotEmpty;

    final Widget content = _CorrectAnswerContent(
      hasExplanation: hasExplanation,
      explanation: explanation,
    );

    _snackbarController.show(
      context: context,
      content: content,
      backgroundColor: RLTheme.primaryGreen,
    );
  }

  static void showWrongAnswer(BuildContext context, {String? hint}) {
    final bool hasHint = hint != null && hint.isNotEmpty;

    final Duration duration = hasHint
        ? HINT_SNACKBAR_DURATION
        : DEFAULT_SNACKBAR_DURATION;

    final Widget content = _WrongAnswerContent(
      hasHint: hasHint,
      hint: hint,
    );

    _snackbarController.show(
      context: context,
      content: content,
      backgroundColor: RLTheme.primaryBlue,
      duration: duration,
    );
  }

  static void showCustomFeedback(
    BuildContext context,
    String message,
    bool isCorrect,
  ) {
    final Color backgroundColor = isCorrect
        ? RLTheme.primaryGreen
        : RLTheme.primaryBlue;

    final Widget content = RLTypography.bodyLarge(
      message,
      color: RLTheme.white,
    );

    _snackbarController.show(
      context: context,
      content: content,
      backgroundColor: backgroundColor,
    );
  }

  static void clearSnackbars() {
    _snackbarController.dismiss();
  }

  static void dismissAnimated() {
    _snackbarController.animatedDismiss();
  }
}

// Animated snackbar widget
class _AnimatedSnackbar extends StatefulWidget {
  final Widget content;
  final Color backgroundColor;
  final Duration? duration;
  final VoidCallback onDismiss;
  final void Function(_AnimatedSnackbarState) onStateCreated;

  const _AnimatedSnackbar({
    required this.content,
    required this.backgroundColor,
    required this.duration,
    required this.onDismiss,
    required this.onStateCreated,
  });

  @override
  State<_AnimatedSnackbar> createState() => _AnimatedSnackbarState();
}

class _AnimatedSnackbarState extends State<_AnimatedSnackbar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    widget.onStateCreated(this);

    _controller = AnimationController(
      vsync: this,
      duration: SNACKBAR_ANIMATION_DURATION,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));

    _controller.forward();

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
    _controller.dispose();
    super.dispose();
  }

  Future<void> animateOut() {
    return _controller.reverse();
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
        position: _slideAnimation,
        child: Material(
          color: widget.backgroundColor,
          child: Padding(
            padding: contentPadding,
            child: widget.content,
          ),
        ),
      ),
    );
  }
}

// Correct answer content
class _CorrectAnswerContent extends StatelessWidget {
  final bool hasExplanation;
  final String? explanation;

  const _CorrectAnswerContent({
    required this.hasExplanation,
    this.explanation,
  });

  static const Icon StarIcon = Icon(
    Icons.star,
    color: RLTheme.white,
    size: 20,
  );

  @override
  Widget build(BuildContext context) {
    return Div.row([
      StarIcon,

      const Spacing.width(12),

      Expanded(
        child: RLTypography.bodyLarge(
          CORRECT_ANSWER_MESSAGE,
          color: RLTheme.white,
        ),
      ),

      RenderIf.condition(
        hasExplanation,
        _WhyButton(explanation: explanation),
      ),
    ], crossAxisAlignment: CrossAxisAlignment.center);
  }
}

// Why button
class _WhyButton extends StatelessWidget {
  final String? explanation;

  const _WhyButton({this.explanation});

  @override
  Widget build(BuildContext context) {
    void handleTap() {
      FeedbackSnackBar.dismissAnimated();

      if (explanation != null) {
        FeedbackBottomSheets.showExplanation(
          context: context,
          explanation: explanation!,
        );
      }
    }

    final TextStyle buttonStyle = RLTypography.bodyMediumStyle.copyWith(
      color: RLTheme.white,
      fontWeight: FontWeight.w600,
    );

    return GestureDetector(
      onTap: handleTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text('Why?', style: buttonStyle),
      ),
    );
  }
}

// Wrong answer content
class _WrongAnswerContent extends StatelessWidget {
  final bool hasHint;
  final String? hint;

  const _WrongAnswerContent({
    required this.hasHint,
    this.hint,
  });

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

      Expanded(
        child: RLTypography.bodyLarge(
          WRONG_ANSWER_TITLE,
          color: RLTheme.white,
        ),
      ),

      RenderIf.condition(
        hasHint,
        _HintButton(hint: hint),
      ),
    ], crossAxisAlignment: CrossAxisAlignment.center);
  }
}

// Hint button
class _HintButton extends StatelessWidget {
  final String? hint;

  const _HintButton({this.hint});

  @override
  Widget build(BuildContext context) {
    void handleTap() {
      FeedbackSnackBar.dismissAnimated();

      if (hint != null) {
        FeedbackBottomSheets.showHint(
          context: context,
          hint: hint!,
        );
      }
    }

    final TextStyle buttonStyle = RLTypography.bodyMediumStyle.copyWith(
      color: RLTheme.white,
      fontWeight: FontWeight.w600,
    );

    return GestureDetector(
      onTap: handleTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Text('Hint', style: buttonStyle),
      ),
    );
  }
}
