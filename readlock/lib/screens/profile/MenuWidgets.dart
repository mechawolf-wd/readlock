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
import 'package:readlock/bottom_sheets/user/FontPickerBottomSheet.dart';
import 'package:readlock/screens/profile/SettingsDemos.dart';

import 'package:pixelarticons/pixel.dart';

// Shared row geometry for every settings row. A fixed content height keeps
// MenuItem (text-only) and SwitchMenuItem (with CupertinoSwitch) the same
// total size, so gaps between rows match across Account / Sounds / Legal.
// Vertical padding and the top/bottom margins of MenuDivider combine to give
// every section the same first-element and last-element spacing.
const double MENU_ROW_CONTENT_HEIGHT = 32.0;
const EdgeInsets MENU_ROW_PADDING = EdgeInsets.symmetric(vertical: RLDS.spacing12);

class MenuSection extends StatelessWidget {
  final bool typingSoundEnabled;
  final bool generalSoundsEnabled;
  final bool hapticsEnabled;
  final bool revealAllTrueFalse;
  final bool blurEnabled;
  final bool coloredTextEnabled;
  final bool bionicEnabled;
  final bool rsvpEnabled;
  final ValueChanged<bool> onTypingSoundToggled;
  final ValueChanged<bool> onGeneralSoundsToggled;
  final ValueChanged<bool> onHapticsToggled;
  final ValueChanged<bool> onRevealAllTrueFalseToggled;
  final ValueChanged<bool> onBlurToggled;
  final ValueChanged<bool> onColoredTextToggled;
  final ValueChanged<bool> onBionicToggled;
  final ValueChanged<bool> onRsvpToggled;
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
    required this.bionicEnabled,
    required this.rsvpEnabled,
    required this.onTypingSoundToggled,
    required this.onGeneralSoundsToggled,
    required this.onHapticsToggled,
    required this.onRevealAllTrueFalseToggled,
    required this.onBlurToggled,
    required this.onColoredTextToggled,
    required this.onBionicToggled,
    required this.onRsvpToggled,
    required this.onSupportTap,
    required this.onLogoutTap,
  });

  // Inverts the switch value before forwarding to the stored-preference
  // callback. "Progressive" (user-facing) = !revealAllTrueFalse (internal).
  void handleProgressiveToggled(bool progressiveEnabled) {
    onRevealAllTrueFalseToggled(!progressiveEnabled);
  }

  @override
  Widget build(BuildContext context) {
    // Tap handlers extracted out of the widget tree so the Column's
    // children list stays lambda-free (rule #13).
    final VoidCallback onAccountTap = () => AccountBottomSheet.show(context);
    final VoidCallback onBirdPickerTap = () => BirdPickerBottomSheet.show(context);
    final VoidCallback onFontPickerTap = () => FontPickerBottomSheet.show(context);
    final VoidCallback onReaderPassTap = () {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Account & Subscription
        MenuItem(
          icon: Pixel.user,
          title: RLUIStrings.MENU_ACCOUNT,
          onTap: onAccountTap,
        ),

        MenuItem(
          icon: Pixel.card,
          title: RLUIStrings.MENU_READER_PASS,
          onTap: onReaderPassTap,
        ),

        MenuItem(
          icon: Pixel.human,
          title: RLUIStrings.MENU_PROFILE_BIRD,
          onTap: onBirdPickerTap,
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

        // Reading Settings.
        //
        // "Progressive" is the user-facing inverse of the internal
        // `revealAllTrueFalse` flag: when the switch is ON the text types
        // in progressively (revealAllTrueFalse = false); when OFF it lands
        // all at once (revealAllTrueFalse = true). The flip happens here
        // at the menu layer (see handleProgressiveToggled) so the stored
        // preference stays compatible.
        SwitchMenuItem(
          icon: Pixel.visible,
          title: RLUIStrings.MENU_REVEAL,
          value: !revealAllTrueFalse,
          onChanged: handleProgressiveToggled,
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

        SwitchMenuItem(
          icon: Pixel.speedfast,
          title: RLUIStrings.MENU_BIONIC,
          value: bionicEnabled,
          onChanged: onBionicToggled,
        ),

        BionicDemo(isEnabled: bionicEnabled),

        // RSVP — switch gates the demo stream, the card itself hosts the
        // WPM slider (the tempo is the configurator). Sits after Bionic
        // since it's the most specialised reading mode in the section.
        SwitchMenuItem(
          icon: Pixel.zap,
          title: RLUIStrings.MENU_RSVP,
          value: rsvpEnabled,
          onChanged: onRsvpToggled,
        ),

        RSVPDemo(isEnabled: rsvpEnabled),

        // Font picker + live demo — sits at the end of Reading Settings so
        // it follows the toggles that govern what text looks like.
        MenuItem(
          icon: Pixel.book,
          title: RLUIStrings.MENU_READING_FONT,
          onTap: onFontPickerTap,
        ),

        const ReadingFontDemo(),

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
        padding: MENU_ROW_PADDING,
        child: SizedBox(
          height: MENU_ROW_CONTENT_HEIGHT,
          child: Row(
            children: [
              MenuItemIcon,

              const Spacing.width(RLDS.spacing16),

              Expanded(child: RLTypography.bodyLarge(title, color: titleColor)),
            ],
          ),
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

  // Tap anywhere on the row (icon, title, whitespace) toggles the switch.
  void handleRowTap() {
    handleSwitchChange(!value);
  }

  @override
  Widget build(BuildContext context) {
    final Color iconColor = RLDS.textPrimary.withValues(alpha: 0.7);
    final Color titleColor = RLDS.textPrimary;

    final Widget MenuItemIcon = Icon(icon, color: iconColor, size: RLDS.iconMedium);

    return GestureDetector(
      onTap: handleRowTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: MENU_ROW_PADDING,
        child: SizedBox(
          height: MENU_ROW_CONTENT_HEIGHT,
          child: Row(
            children: [
              MenuItemIcon,

              const Spacing.width(RLDS.spacing16),

              Expanded(child: RLTypography.bodyLarge(title, color: titleColor)),

              RLSwitch(value: value, onChanged: handleSwitchChange),
            ],
          ),
        ),
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
