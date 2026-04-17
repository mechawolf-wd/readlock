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

  const RLTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.onChanged,
    this.onEditingComplete,
  });

  const RLTextField.email({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText = 'Email',
    this.onChanged,
    this.onEditingComplete,
  }) : obscureText = false,
       keyboardType = TextInputType.emailAddress;

  const RLTextField.password({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText = 'Password',
    this.onChanged,
    this.onEditingComplete,
  }) : obscureText = true,
       keyboardType = TextInputType.visiblePassword;

  @override
  Widget build(BuildContext context) {
    final BoxDecoration fieldDecoration = BoxDecoration(
      color: RLDS.backgroundLight,
      borderRadius: RLDS.borderRadiusSmall,
    );

    final TextStyle hintStyle = RLTypography.bodyLargeStyle.copyWith(
      color: RLDS.textMuted,
    );

    final InputDecoration inputDecoration = InputDecoration(
      hintText: hintText,
      hintStyle: hintStyle,
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
}
