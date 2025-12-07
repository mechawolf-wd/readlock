import 'package:flutter/material.dart';
import 'package:readlock/constants/RLTheme.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/services/SoundService.dart';
import 'package:readlock/services/HapticsService.dart';

class RLDesignSystem {
  static Widget BlockButton({
    required List<Widget> children,
    required VoidCallback onTap,
    Color? backgroundColor,
    Color? shadowColor,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) {
    return BlockButtonWidget(
      onTap: onTap,
      backgroundColor: backgroundColor,
      shadowColor: shadowColor,
      padding: padding,
      margin: margin,
      children: children,
    );
  }
}

class BlockButtonWidget extends StatefulWidget {
  final List<Widget> children;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? shadowColor;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const BlockButtonWidget({
    super.key,
    required this.children,
    required this.onTap,
    this.backgroundColor,
    this.shadowColor,
    this.padding,
    this.margin,
  });

  @override
  State<BlockButtonWidget> createState() => BlockButtonState();
}

class BlockButtonState extends State<BlockButtonWidget> {
  bool isPressed = false;
  static const double SHADOW_OFFSET = 4.0;

  void handleTapDown(TapDownDetails details) {
    setState(() {
      isPressed = true;
    });
  }

  void handleTapUp(TapUpDetails details) {
    setState(() {
      isPressed = false;
    });

    // Call the original tap handler
    HapticsService.mediumImpact();
    SoundService.playContinueClick();
    widget.onTap();
  }

  void handleTapCancel() {
    setState(() {
      isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Extract style constants above widget (rule #16)
    final Color defaultBackgroundColor = RLTheme.primaryGreen;
    final Color buttonBackgroundColor =
        widget.backgroundColor ?? defaultBackgroundColor;
    final Color defaultShadowColor = buttonBackgroundColor.withValues(
      alpha: 0.7,
    );
    final Color buttonShadowColor =
        widget.shadowColor ?? defaultShadowColor;
    final EdgeInsets defaultPadding = const EdgeInsets.symmetric(
      vertical: 12,
      horizontal: 16,
    );
    final EdgeInsets buttonPadding = widget.padding ?? defaultPadding;
    final EdgeInsets defaultMargin = const EdgeInsets.all(20);
    final EdgeInsets buttonMargin = widget.margin ?? defaultMargin;

    // Extract conditions above widget logic (rule #27)
    final bool shouldShowShadow = !isPressed;
    final bool shouldMoveButton = isPressed;

    // Extract shadow offset calculation (rule #30)
    final Offset shadowOffset = shouldShowShadow
        ? const Offset(0, SHADOW_OFFSET)
        : const Offset(0, 0);

    // Extract transform offset calculation (rule #30)
    final Offset transformOffset = shouldMoveButton
        ? const Offset(0, SHADOW_OFFSET)
        : const Offset(0, 0);

    // Extract decoration (rule #16)
    final BoxDecoration buttonDecoration = BoxDecoration(
      color: buttonBackgroundColor,
      borderRadius: BorderRadius.circular(36),
      boxShadow: [
        BoxShadow(color: buttonShadowColor, offset: shadowOffset),
      ],
    );

    return Transform.translate(
      offset: transformOffset,
      child: GestureDetector(
        onTapDown: handleTapDown,
        onTapUp: handleTapUp,
        onTapCancel: handleTapCancel,
        child: Div.row(
          widget.children,
          padding: buttonPadding,
          margin: buttonMargin,
          decoration: buttonDecoration,
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
    );
  }
}
