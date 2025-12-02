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
    final Color? buttonBackgroundColor = backgroundColor;
    final Color finalBackgroundColor =
        buttonBackgroundColor ?? RLTheme.primaryGreen;

    final Color? buttonShadowColor = shadowColor;
    final Color finalShadowColor =
        buttonShadowColor ??
        finalBackgroundColor.withValues(alpha: 0.7);

    final EdgeInsets? buttonPadding = padding;
    final EdgeInsets finalPadding =
        buttonPadding ??
        const EdgeInsets.symmetric(vertical: 12, horizontal: 16);

    final EdgeInsets? buttonMargin = margin;
    final EdgeInsets finalMargin =
        buttonMargin ?? const EdgeInsets.all(20);

    final BoxDecoration buttonDecoration = BoxDecoration(
      color: finalBackgroundColor,
      borderRadius: BorderRadius.circular(36),
      boxShadow: [
        BoxShadow(color: finalShadowColor, offset: const Offset(0, 4)),
      ],
    );

    return Div.row(
      children,
      padding: finalPadding,
      margin: finalMargin,
      decoration: buttonDecoration,
      mainAxisAlignment: MainAxisAlignment.center,
      onTap: () {
        HapticsService.mediumImpact();
        SoundService.playContinueClick();
        onTap();
      },
    );
  }
}
