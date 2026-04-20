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
  final bool soundsEnabled;
  final bool hapticsEnabled;
  final bool revealAllTrueFalse;
  final bool blurEnabled;
  final bool coloredTextEnabled;
  final bool notificationsEnabled;
  final String textSpeed;
  final ValueChanged<bool> onSoundsToggled;
  final ValueChanged<bool> onHapticsToggled;
  final ValueChanged<bool> onRevealAllTrueFalseToggled;
  final ValueChanged<bool> onBlurToggled;
  final ValueChanged<bool> onColoredTextToggled;
  final ValueChanged<bool> onNotificationsToggled;
  final ValueChanged<String> onTextSpeedChanged;
  final VoidCallback onSupportTap;

  const MenuSection({
    super.key,
    required this.soundsEnabled,
    required this.hapticsEnabled,
    required this.revealAllTrueFalse,
    required this.blurEnabled,
    required this.coloredTextEnabled,
    required this.notificationsEnabled,
    required this.textSpeed,
    required this.onSoundsToggled,
    required this.onHapticsToggled,
    required this.onRevealAllTrueFalseToggled,
    required this.onBlurToggled,
    required this.onColoredTextToggled,
    required this.onNotificationsToggled,
    required this.onTextSpeedChanged,
    required this.onSupportTap,
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
          value: soundsEnabled,
          onChanged: onSoundsToggled,
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

        SegmentedMenuItem(
          icon: Pixel.chartbar,
          title: RLUIStrings.MENU_TEXT_SPEED,
          options: const [RLUIStrings.SPEED_CAREFUL, RLUIStrings.SPEED_CLASSIC, RLUIStrings.SPEED_SPEED],
          selectedOption: textSpeed,
          onChanged: onTextSpeedChanged,
        ),

        TextSpeedDemo(selectedSpeed: textSpeed),

        const MenuDivider(),

        // Notifications & Support
        SwitchMenuItem(
          icon: Pixel.notification,
          title: RLUIStrings.MENU_NOTIFICATIONS,
          value: notificationsEnabled,
          onChanged: onNotificationsToggled,
        ),

        MenuItem(icon: Pixel.message, title: RLUIStrings.MENU_SUPPORT, onTap: onSupportTap),

        const MenuDivider(),

        // Legal
        MenuItem(icon: Pixel.shield, title: RLUIStrings.MENU_PRIVACY_POLICY, onTap: () {}),

        MenuItem(icon: Pixel.article, title: RLUIStrings.MENU_TERMS_AND_CONDITIONS, onTap: () {}),

        MenuItem(icon: Pixel.scale, title: RLUIStrings.MENU_EULA, onTap: () {}),

        const MenuDivider(),

        // Log out
        MenuItem(icon: Pixel.logout, title: RLUIStrings.MENU_LOG_OUT, onTap: () {}),

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

class SegmentedMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> options;
  final String selectedOption;
  final ValueChanged<String> onChanged;

  const SegmentedMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.options,
    required this.selectedOption,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final Color iconColor = RLDS.textPrimary.withValues(alpha: 0.7);
    final Color titleColor = RLDS.textPrimary;

    final Widget MenuItemIcon = Icon(icon, color: iconColor, size: RLDS.iconMedium);

    return Padding(
      padding: const EdgeInsets.only(top: RLDS.spacing32, bottom: RLDS.spacing16),
      child: Column(
        children: [
          Row(
            children: [
              MenuItemIcon,

              const Spacing.width(RLDS.spacing16),

              Expanded(child: RLTypography.bodyMedium(title, color: titleColor)),
            ],
          ),

          const Spacing.height(RLDS.spacing16),

          // Segmented options
          SegmentedOptions(
            options: options,
            selectedOption: selectedOption,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget SegmentedOptions({
    required List<String> options,
    required String selectedOption,
    required ValueChanged<String> onChanged,
  }) {
    final BoxDecoration containerDecoration = BoxDecoration(
      color: RLDS.textPrimary.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(RLDS.spacing8),
    );

    return Container(
      decoration: containerDecoration,
      padding: const EdgeInsets.all(RLDS.spacing8),
      child: Row(children: OptionButtons(options, selectedOption, onChanged)),
    );
  }

  List<Widget> OptionButtons(
    List<String> options,
    String selectedOption,
    ValueChanged<String> onChanged,
  ) {
    return options.map((option) {
      final bool isSelected = option == selectedOption;

      Color optionColor = Colors.transparent;
      Color textColor = RLDS.textPrimary.withValues(alpha: 0.6);

      if (isSelected) {
        optionColor = RLDS.primary;
        textColor = RLDS.white;
      }

      final BoxDecoration optionDecoration = BoxDecoration(
        color: optionColor,
        borderRadius: BorderRadius.circular(RLDS.spacing4 + 2),
      );

      return Expanded(
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onChanged(option);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: RLDS.spacing8),
            decoration: optionDecoration,
            child: Center(child: RLTypography.bodyMedium(option, color: textColor)),
          ),
        ),
      );
    }).toList();
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
