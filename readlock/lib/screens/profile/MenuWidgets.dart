// Profile menu widgets for settings and navigation
// Includes menu items, switches, segmented controls, and dividers

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/utility_widgets/RLButton.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/bottom_sheets/user/AccountBottomSheet.dart';
import 'package:readlock/screens/profile/SettingsDemos.dart';

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
    return Div.column([
      // Account & Subscription
      MenuItem(
        icon: Icons.person,
        title: RLUIStrings.MENU_ACCOUNT,
        onTap: () => AccountBottomSheet.show(context),
      ),

      MenuItem(icon: Icons.card_membership, title: RLUIStrings.MENU_READER_PASS, onTap: () {}),

      const MenuDivider(),

      // App Settings
      SwitchMenuItem(
        icon: Icons.volume_up,
        title: RLUIStrings.MENU_SOUNDS,
        value: soundsEnabled,
        onChanged: onSoundsToggled,
      ),

      SwitchMenuItem(
        icon: Icons.vibration,
        title: RLUIStrings.MENU_HAPTICS,
        value: hapticsEnabled,
        onChanged: onHapticsToggled,
      ),

      const MenuDivider(),

      // Reading Settings
      SwitchMenuItem(
        icon: Icons.visibility,
        title: RLUIStrings.MENU_REVEAL,
        value: revealAllTrueFalse,
        onChanged: onRevealAllTrueFalseToggled,
      ),

      RevealDemo(isEnabled: revealAllTrueFalse),

      SwitchMenuItem(
        icon: Icons.blur_on,
        title: RLUIStrings.MENU_BLUR,
        value: blurEnabled,
        onChanged: onBlurToggled,
      ),

      BlurDemo(isEnabled: blurEnabled),

      SwitchMenuItem(
        icon: Icons.format_color_text,
        title: RLUIStrings.MENU_COLORED_TEXT,
        value: coloredTextEnabled,
        onChanged: onColoredTextToggled,
      ),

      ColoredTextDemo(isEnabled: coloredTextEnabled),

      SegmentedMenuItem(
        icon: Icons.speed,
        title: RLUIStrings.MENU_TEXT_SPEED,
        options: const [RLUIStrings.SPEED_CAREFUL, RLUIStrings.SPEED_CLASSIC, RLUIStrings.SPEED_SPEED],
        selectedOption: textSpeed,
        onChanged: onTextSpeedChanged,
      ),

      TextSpeedDemo(selectedSpeed: textSpeed),

      const MenuDivider(),

      // Support & Information
      SwitchMenuItem(
        icon: Icons.notifications,
        title: RLUIStrings.MENU_NOTIFICATIONS,
        value: notificationsEnabled,
        onChanged: onNotificationsToggled,
      ),

      const Spacing.height(12),

      SupportButton(onTap: onSupportTap),

      const MenuDivider(),

      // Account Actions & Legal
      MenuItem(icon: Icons.gavel, title: RLUIStrings.MENU_LEGAL, onTap: () {}),

      MenuItem(icon: Icons.logout, title: RLUIStrings.MENU_LOG_OUT, onTap: () {}),

      const Spacing.height(24),

      Center(
        child: RLTypography.bodyMedium(
          RLUIStrings.MENU_VERSION,
          color: RLDS.textPrimary.withValues(alpha: 0.5),
        ),
      ),
    ]);
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

    final Widget MenuItemIcon = Icon(icon, color: iconColor, size: 20.0);

    return Div.row(
      [
        MenuItemIcon,

        const Spacing.width(16.0),

        Expanded(child: RLTypography.bodyMedium(title, color: titleColor)),
      ],
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      onTap: onTap,
    );
  }
}

class SupportButton extends StatelessWidget {
  final VoidCallback onTap;

  const SupportButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return RLButton.primary(
      label: RLUIStrings.MENU_SUPPORT,
      color: RLDS.info,
      onTap: onTap,
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

    final Widget MenuItemIcon = Icon(icon, color: iconColor, size: 20.0);

    return Div.row([
      MenuItemIcon,

      const Spacing.width(16.0),

      Expanded(child: RLTypography.bodyMedium(title, color: titleColor)),

      Switch(
        value: value,
        onChanged: handleSwitchChange,
        activeThumbColor: RLDS.info,
        activeTrackColor: RLDS.info.withValues(alpha: 0.3),
        inactiveThumbColor: RLDS.textPrimary.withValues(alpha: 0.5),
        inactiveTrackColor: RLDS.textPrimary.withValues(alpha: 0.1),
      ),
    ], padding: const EdgeInsets.symmetric(vertical: 16.0));
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

    final Widget MenuItemIcon = Icon(icon, color: iconColor, size: 20.0);

    return Div.column(
      [
        Div.row([
          MenuItemIcon,

          const Spacing.width(16.0),

          Expanded(child: RLTypography.bodyMedium(title, color: titleColor)),
        ]),

        const Spacing.height(16.0),

        // Segmented options
        SegmentedOptions(
          options: options,
          selectedOption: selectedOption,
          onChanged: onChanged,
        ),
      ],
      padding: const EdgeInsets.only(
        top: 32.0,
        bottom: 16.0,
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
      borderRadius: BorderRadius.circular(8.0),
    );

    return Container(
      decoration: containerDecoration,
      padding: const EdgeInsets.all(8.0),
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
        optionColor = RLDS.info;
        textColor = RLDS.white;
      }

      final BoxDecoration optionDecoration = BoxDecoration(
        color: optionColor,
        borderRadius: BorderRadius.circular(6.0),
      );

      return Expanded(
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onChanged(option);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
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
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: RLDS.textPrimary.withValues(alpha: 0.1),
    );
  }
}
