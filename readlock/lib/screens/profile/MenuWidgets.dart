// Profile menu widgets for settings and navigation
// Includes menu items, switches, segmented controls, and dividers

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:readlock/constants/RLDimensions.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLTheme.dart';
import 'package:readlock/bottom_sheets/user/AccountBottomSheet.dart';
import 'package:readlock/screens/profile/SettingsDemos.dart';

class MenuSection extends StatelessWidget {
  final bool soundsEnabled;
  final bool hapticsEnabled;
  final bool revealAllTrueFalse;
  final bool blurEnabled;
  final bool coloredTextEnabled;
  final String textSpeed;
  final ValueChanged<bool> onSoundsToggled;
  final ValueChanged<bool> onHapticsToggled;
  final ValueChanged<bool> onRevealAllTrueFalseToggled;
  final ValueChanged<bool> onBlurToggled;
  final ValueChanged<bool> onColoredTextToggled;
  final ValueChanged<String> onTextSpeedChanged;

  const MenuSection({
    super.key,
    required this.soundsEnabled,
    required this.hapticsEnabled,
    required this.revealAllTrueFalse,
    required this.blurEnabled,
    required this.coloredTextEnabled,
    required this.textSpeed,
    required this.onSoundsToggled,
    required this.onHapticsToggled,
    required this.onRevealAllTrueFalseToggled,
    required this.onBlurToggled,
    required this.onColoredTextToggled,
    required this.onTextSpeedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Div.column([
      // Account & Subscription
      MenuItem(
        icon: Icons.person,
        title: 'Account',
        onTap: () => AccountBottomSheet.show(context),
      ),

      MenuItem(icon: Icons.card_membership, title: 'Reader Pass', onTap: () {}),

      const MenuDivider(),

      // App Settings
      SwitchMenuItem(
        icon: Icons.volume_up,
        title: 'Sounds',
        value: soundsEnabled,
        onChanged: onSoundsToggled,
      ),

      SwitchMenuItem(
        icon: Icons.vibration,
        title: 'Haptics',
        value: hapticsEnabled,
        onChanged: onHapticsToggled,
      ),

      const MenuDivider(),

      // Reading Settings
      SwitchMenuItem(
        icon: Icons.visibility,
        title: 'Reveal',
        value: revealAllTrueFalse,
        onChanged: onRevealAllTrueFalseToggled,
      ),

      RevealDemo(isEnabled: revealAllTrueFalse),

      SwitchMenuItem(
        icon: Icons.blur_on,
        title: 'Blur',
        value: blurEnabled,
        onChanged: onBlurToggled,
      ),

      BlurDemo(isEnabled: blurEnabled),

      SwitchMenuItem(
        icon: Icons.format_color_text,
        title: 'Colored text',
        value: coloredTextEnabled,
        onChanged: onColoredTextToggled,
      ),

      ColoredTextDemo(isEnabled: coloredTextEnabled),

      SegmentedMenuItem(
        icon: Icons.speed,
        title: 'Text speed',
        options: const ['Careful', 'Classic', 'Speed'],
        selectedOption: textSpeed,
        onChanged: onTextSpeedChanged,
      ),

      TextSpeedDemo(selectedSpeed: textSpeed),

      const MenuDivider(),

      // Support & Information
      MenuItem(icon: Icons.notifications, title: 'Notifications', onTap: () {}),

      MenuItem(icon: Icons.info, title: 'About', onTap: () {}),

      MenuItem(icon: Icons.help, title: 'Help', onTap: () {}),

      MenuItem(icon: Icons.bug_report, title: 'Report a problem', onTap: () {}),

      MenuItem(icon: Icons.new_releases, title: 'Product Updates', onTap: () {}),

      const MenuDivider(),

      // Account Actions & Legal
      MenuItem(icon: Icons.gavel, title: 'Legal', onTap: () {}),

      MenuItem(icon: Icons.logout, title: 'Log out', onTap: () {}),

      const Spacing.height(24),

      Center(
        child: RLTypography.bodyMedium(
          'Version 1.0.0',
          color: RLTheme.textPrimary.withValues(alpha: RLDimensions.opacityMuted),
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
    final Color iconColor =
        textColor ?? RLTheme.textPrimary.withValues(alpha: RLDimensions.opacityLight);
    final Color titleColor = textColor ?? RLTheme.textPrimary;

    final Widget MenuItemIcon = Icon(icon, color: iconColor, size: RLDimensions.iconM);

    final Widget ChevronRightIcon = Icon(
      Icons.chevron_right,
      color: RLTheme.textPrimary.withValues(alpha: RLDimensions.alphaDark),
      size: RLDimensions.iconM,
    );

    return Div.row(
      [
        MenuItemIcon,

        const Spacing.width(RLDimensions.spacing16),

        Expanded(child: RLTypography.bodyMedium(title, color: titleColor)),

        ChevronRightIcon,
      ],
      padding: RLDimensions.paddingVerticalL,
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

  @override
  Widget build(BuildContext context) {
    final Color iconColor = RLTheme.textPrimary.withValues(alpha: RLDimensions.opacityLight);
    final Color titleColor = RLTheme.textPrimary;

    final Widget MenuItemIcon = Icon(icon, color: iconColor, size: RLDimensions.iconM);

    return Div.row([
      MenuItemIcon,

      const Spacing.width(RLDimensions.spacing16),

      Expanded(child: RLTypography.bodyMedium(title, color: titleColor)),

      Switch(
        value: value,
        onChanged: (newValue) {
          HapticFeedback.lightImpact();
          onChanged(newValue);
        },
        activeThumbColor: RLTheme.primaryBlue,
        activeTrackColor: RLTheme.primaryBlue.withValues(alpha: RLDimensions.alphaDark),
        inactiveThumbColor: RLTheme.textPrimary.withValues(alpha: RLDimensions.opacityMuted),
        inactiveTrackColor: RLTheme.textPrimary.withValues(alpha: RLDimensions.alphaLight),
      ),
    ], padding: RLDimensions.paddingVerticalL);
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
    final Color iconColor = RLTheme.textPrimary.withValues(alpha: RLDimensions.opacityLight);
    final Color titleColor = RLTheme.textPrimary;

    final Widget MenuItemIcon = Icon(icon, color: iconColor, size: RLDimensions.iconM);

    return Div.column(
      [
        Div.row([
          MenuItemIcon,

          const Spacing.width(RLDimensions.spacing16),

          Expanded(child: RLTypography.bodyMedium(title, color: titleColor)),
        ]),

        const Spacing.height(RLDimensions.spacing16),

        // Segmented options
        SegmentedOptions(
          options: options,
          selectedOption: selectedOption,
          onChanged: onChanged,
        ),
      ],
      padding: const EdgeInsets.only(
        top: RLDimensions.spacing32,
        bottom: RLDimensions.spacing16,
      ),
    );
  }

  Widget SegmentedOptions({
    required List<String> options,
    required String selectedOption,
    required ValueChanged<String> onChanged,
  }) {
    final BoxDecoration containerDecoration = BoxDecoration(
      color: RLTheme.textPrimary.withValues(alpha: RLDimensions.alphaVeryLight),
      borderRadius: RLDimensions.borderRadiusM,
    );

    return Container(
      decoration: containerDecoration,
      padding: RLDimensions.paddingAllS,
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

      final Color optionColor = isSelected ? RLTheme.primaryBlue : Colors.transparent;

      final BoxDecoration optionDecoration = BoxDecoration(
        color: optionColor,
        borderRadius: RLDimensions.borderRadiusS,
      );

      final Color textColor = isSelected
          ? RLTheme.white
          : RLTheme.textPrimary.withValues(alpha: RLDimensions.opacitySubtle);

      return Expanded(
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            onChanged(option);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: RLDimensions.spacing8),
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
      height: RLDimensions.dividerNormal,
      margin: const EdgeInsets.symmetric(vertical: RLDimensions.spacing8),
      color: RLTheme.textPrimary.withValues(alpha: RLDimensions.alphaLight),
    );
  }
}
