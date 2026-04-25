// Reusable text field component with consistent styling
// Supports email, password, and general text input types.
// Password variant: holding the eye icon temporarily reveals the input.

import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/design_system/RLLunarBlur.dart';

class RLTextField extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final IconData? leadingIcon;

  const RLTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.onEditingComplete,
    this.leadingIcon,
  });

  const RLTextField.email({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText = RLUIStrings.EMAIL_PLACEHOLDER,
    this.onChanged,
    this.onEditingComplete,
    this.leadingIcon,
  }) : obscureText = false,
       keyboardType = TextInputType.emailAddress;

  const RLTextField.password({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText = RLUIStrings.PASSWORD_PLACEHOLDER,
    this.onChanged,
    this.onEditingComplete,
    this.leadingIcon,
  }) : obscureText = true,
       keyboardType = TextInputType.visiblePassword;

  @override
  State<RLTextField> createState() => RLTextFieldState();
}

class RLTextFieldState extends State<RLTextField> {
  // True while the user is actively pressing the eye icon.
  bool isRevealing = false;

  void handleRevealStart() {
    setState(() {
      isRevealing = true;
    });
  }

  void handleRevealEnd() {
    if (!isRevealing) {
      return;
    }

    setState(() {
      isRevealing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle hintStyle = RLTypography.bodyLargeStyle.copyWith(color: RLDS.textMuted);

    final Widget? prefixIconWidget = buildLeadingIcon();
    final Widget? suffixIconWidget = buildRevealIcon();
    final bool shouldObscure = widget.obscureText && !isRevealing;

    // Shrink Flutter's default 48x48 prefix/suffix icon box so the icon sits
    // flush with the field's own padding instead of floating inside its own
    // huge hit area (which was pushing the hint text off-centre).
    const BoxConstraints tightIconConstraints = BoxConstraints();

    final InputDecoration inputDecoration = InputDecoration(
      hintText: widget.hintText,
      hintStyle: hintStyle,
      prefixIcon: prefixIconWidget,
      prefixIconConstraints: tightIconConstraints,
      suffixIcon: suffixIconWidget,
      suffixIconConstraints: tightIconConstraints,
      border: InputBorder.none,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: RLDS.spacing20),
    );

    // Frosted surface — same configuration as the login bottom sheet's
    // container (LunarBlur over `backgroundLight` with a transparent
    // border). Default sigma + alpha mean the field reads as the same
    // family of surface as every other LunarBlur pane in the app.
    return RLLunarBlur(
      borderRadius: RLDS.borderRadiusSmall,
      surfaceColor: RLDS.backgroundLight,
      borderColor: RLDS.transparent,
      padding: const EdgeInsets.symmetric(horizontal: RLDS.spacing16),
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        obscureText: shouldObscure,
        keyboardType: widget.keyboardType,
        style: RLTypography.bodyLargeStyle,
        cursorColor: RLDS.primary,
        decoration: inputDecoration,
        onChanged: widget.onChanged,
        onEditingComplete: widget.onEditingComplete,
      ),
    );
  }

  // Wraps the optional IconData prop into an Icon widget sized + coloured to
  // match the field's muted hint treatment. The trailing padding gives the
  // hint/value text breathing room so it isn't glued to the icon.
  Widget? buildLeadingIcon() {
    final IconData? icon = widget.leadingIcon;
    final bool hasNoIcon = icon == null;

    if (hasNoIcon) {
      return null;
    }

    return Padding(
      padding: const EdgeInsets.only(right: RLDS.spacing12),
      child: Icon(icon, color: RLDS.textMuted, size: RLDS.iconMedium),
    );
  }

  // Press-and-hold eye icon. Only rendered on password-style fields. While the
  // user holds it, the input's obscureText flips off so the characters show.
  Widget? buildRevealIcon() {
    final bool hasNoReveal = !widget.obscureText;

    if (hasNoReveal) {
      return null;
    }

    final Color iconColor = isRevealing ? RLDS.textPrimary : RLDS.textMuted;

    return GestureDetector(
      onTapDown: (_) => handleRevealStart(),
      onTapUp: (_) => handleRevealEnd(),
      onTapCancel: handleRevealEnd,
      onLongPressStart: (_) => handleRevealStart(),
      onLongPressEnd: (_) => handleRevealEnd(),
      onLongPressCancel: handleRevealEnd,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: RLDS.spacing8),
        child: Icon(Pixel.eye, color: iconColor, size: RLDS.iconLarge),
      ),
    );
  }
}
