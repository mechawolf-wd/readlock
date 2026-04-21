// Profile menu widgets for settings and navigation
// Includes menu items, switches, segmented controls, and dividers

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/design_system/RLSwitch.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/bottom_sheets/user/AccountBottomSheet.dart';
import 'package:readlock/bottom_sheets/user/BirdPickerBottomSheet.dart';
import 'package:readlock/screens/profile/SettingsDemos.dart';

import 'package:pixelarticons/pixel.dart';
class MenuSection extends StatelessWidget {
  final bool typingSoundEnabled;
  final bool generalSoundsEnabled;
  final bool hapticsEnabled;
  final bool revealAllTrueFalse;
  final bool blurEnabled;
  final bool coloredTextEnabled;
  final ValueChanged<bool> onTypingSoundToggled;
  final ValueChanged<bool> onGeneralSoundsToggled;
  final ValueChanged<bool> onHapticsToggled;
  final ValueChanged<bool> onRevealAllTrueFalseToggled;
  final ValueChanged<bool> onBlurToggled;
  final ValueChanged<bool> onColoredTextToggled;
  final VoidCallback onSupportTap;
  final VoidCallback onLogoutTap;

  const MenuSection({
    super.key,
    required this.typingSoundEnabled,
    required this.generalSoundsEnabled,
    required this.hapticsEnabled,
    required this.revealAllTrueFalse,
    required this.blurEnabled,
    required this.coloredTextEnabled,
    required this.onTypingSoundToggled,
    required this.onGeneralSoundsToggled,
    required this.onHapticsToggled,
    required this.onRevealAllTrueFalseToggled,
    required this.onBlurToggled,
    required this.onColoredTextToggled,
    required this.onSupportTap,
    required this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Account & Subscription
        MenuItem(
          icon: Pixel.user,
          title: RLUIStrings.MENU_ACCOUNT,
          onTap: () => AccountBottomSheet.show(context),
        ),

        MenuItem(icon: Pixel.card, title: RLUIStrings.MENU_READER_PASS, onTap: () {}),

        MenuItem(
          icon: Pixel.human,
          title: RLUIStrings.MENU_PROFILE_BIRD,
          onTap: () => BirdPickerBottomSheet.show(context),
        ),

        const MenuDivider(),

        // Sound & Haptics
        SwitchMenuItem(
          icon: Pixel.keyboard,
          title: RLUIStrings.MENU_TYPING_SOUND,
          value: typingSoundEnabled,
          onChanged: onTypingSoundToggled,
        ),

        SwitchMenuItem(
          icon: Pixel.volume2,
          title: RLUIStrings.MENU_SOUNDS,
          value: generalSoundsEnabled,
          onChanged: onGeneralSoundsToggled,
        ),

        SwitchMenuItem(
          icon: Pixel.alert,
          title: RLUIStrings.MENU_HAPTICS,
          value: hapticsEnabled,
          onChanged: onHapticsToggled,
        ),

        const MenuDivider(),

        // Reading Settings
        SwitchMenuItem(
          icon: Pixel.visible,
          title: RLUIStrings.MENU_REVEAL,
          value: revealAllTrueFalse,
          onChanged: onRevealAllTrueFalseToggled,
        ),

        RevealDemo(isEnabled: revealAllTrueFalse),

        SwitchMenuItem(
          icon: Pixel.eye,
          title: RLUIStrings.MENU_BLUR,
          value: blurEnabled,
          onChanged: onBlurToggled,
        ),

        BlurDemo(isEnabled: blurEnabled),

        SwitchMenuItem(
          icon: Pixel.edit,
          title: RLUIStrings.MENU_COLORED_TEXT,
          value: coloredTextEnabled,
          onChanged: onColoredTextToggled,
        ),

        ColoredTextDemo(isEnabled: coloredTextEnabled),

        const MenuDivider(),

        // Legal (Support listed last, after EULA)
        MenuItem(icon: Pixel.shield, title: RLUIStrings.MENU_PRIVACY_POLICY, onTap: () {}),

        MenuItem(icon: Pixel.article, title: RLUIStrings.MENU_TERMS_AND_CONDITIONS, onTap: () {}),

        MenuItem(icon: Pixel.scale, title: RLUIStrings.MENU_EULA, onTap: () {}),

        MenuItem(icon: Pixel.message, title: RLUIStrings.MENU_SUPPORT, onTap: onSupportTap),

        const MenuDivider(),

        // Log out
        MenuItem(icon: Pixel.logout, title: RLUIStrings.MENU_LOG_OUT, onTap: onLogoutTap),

        const Spacing.height(RLDS.spacing24),

        Center(
          child: RLTypography.bodyMedium(
            RLUIStrings.MENU_VERSION,
            color: RLDS.textPrimary.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}

class MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;

  const MenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasTextColor = textColor != null;

    Color iconColor = RLDS.textPrimary.withValues(alpha: 0.7);
    Color titleColor = RLDS.textPrimary;

    if (hasTextColor) {
      iconColor = textColor!;
      titleColor = textColor!;
    }

    final Widget MenuItemIcon = Icon(icon, color: iconColor, size: RLDS.iconMedium);

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: RLDS.spacing16),
        child: Row(
          children: [
            MenuItemIcon,

            const Spacing.width(RLDS.spacing16),

            Expanded(child: RLTypography.bodyMedium(title, color: titleColor)),
          ],
        ),
      ),
    );
  }
}

class SwitchMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SwitchMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  void handleSwitchChange(bool newValue) {
    HapticFeedback.lightImpact();
    onChanged(newValue);
  }

  @override
  Widget build(BuildContext context) {
    final Color iconColor = RLDS.textPrimary.withValues(alpha: 0.7);
    final Color titleColor = RLDS.textPrimary;

    final Widget MenuItemIcon = Icon(icon, color: iconColor, size: RLDS.iconMedium);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: RLDS.spacing16),
      child: Row(
        children: [
          MenuItemIcon,

          const Spacing.width(RLDS.spacing16),

          Expanded(child: RLTypography.bodyMedium(title, color: titleColor)),

          RLSwitch(value: value, onChanged: handleSwitchChange),
        ],
      ),
    );
  }
}

class MenuDivider extends StatelessWidget {
  const MenuDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1.0,
      margin: const EdgeInsets.symmetric(vertical: RLDS.spacing8),
      color: RLDS.textPrimary.withValues(alpha: 0.1),
    );
  }
}
