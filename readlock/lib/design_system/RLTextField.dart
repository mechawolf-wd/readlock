// Reusable text field component with consistent styling
// Supports email, password, and general text input types

import 'package:flutter/material.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';

class RLTextField extends StatelessWidget {
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
    this.hintText = 'Email',
    this.onChanged,
    this.onEditingComplete,
    this.leadingIcon,
  }) : obscureText = false,
       keyboardType = TextInputType.emailAddress;

  const RLTextField.password({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText = 'Password',
    this.onChanged,
    this.onEditingComplete,
    this.leadingIcon,
  }) : obscureText = true,
       keyboardType = TextInputType.visiblePassword;

  @override
  Widget build(BuildContext context) {
    final BoxDecoration fieldDecoration = BoxDecoration(
      color: RLDS.backgroundLight,
      borderRadius: RLDS.borderRadiusSmall,
      border: Border.all(color: RLDS.textMuted.withValues(alpha: 0.3)),
    );

    final TextStyle hintStyle = RLTypography.bodyLargeStyle.copyWith(
      color: RLDS.textMuted,
    );

    final Widget? prefixIconWidget = buildLeadingIcon();

    final InputDecoration inputDecoration = InputDecoration(
      hintText: hintText,
      hintStyle: hintStyle,
      prefixIcon: prefixIconWidget,
      border: InputBorder.none,
    );

    return Container(
      decoration: fieldDecoration,
      padding: const EdgeInsets.symmetric(horizontal: RLDS.spacing16),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: RLTypography.bodyLargeStyle,
        cursorColor: RLDS.primary,
        decoration: inputDecoration,
        onChanged: onChanged,
        onEditingComplete: onEditingComplete,
      ),
    );
  }

  // Wraps the optional IconData prop into an Icon widget sized + coloured to
  // match the field's muted hint treatment.
  Widget? buildLeadingIcon() {
    final IconData? icon = leadingIcon;
    final bool hasNoIcon = icon == null;

    if (hasNoIcon) {
      return null;
    }

    return Icon(
      icon,
      color: RLDS.textMuted,
      size: RLDS.iconMedium,
    );
  }
}
