// Profile menu widgets for settings and navigation
// Includes menu items, switches, segmented controls, and dividers

import 'package:flutter/material.dart';
import 'package:readlock/services/feedback/HapticsService.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/design_system/RLFeatherIcon.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/design_system/RLSwitch.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/bottom_sheets/NightShiftBottomSheet.dart';
import 'package:readlock/bottom_sheets/course/FeedbackBottomSheet.dart';
import 'package:readlock/bottom_sheets/user/AccountBottomSheet.dart';
import 'package:readlock/bottom_sheets/user/BirdPickerBottomSheet.dart';
import 'package:readlock/bottom_sheets/user/FontPickerBottomSheet.dart';
import 'package:readlock/bottom_sheets/user/FeathersBottomSheet.dart';
import 'package:readlock/screens/profile/BirdPicker.dart';
import 'package:readlock/screens/profile/SettingsDemos.dart';
import 'package:readlock/services/feedback/SoundService.dart';
import 'package:readlock/services/LinkService.dart';
import 'package:readlock/constants/RLLinks.dart';

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
  final bool justifiedReadingEnabled;
  final ValueChanged<bool> onTypingSoundToggled;
  final ValueChanged<bool> onGeneralSoundsToggled;
  final ValueChanged<bool> onHapticsToggled;
  final ValueChanged<bool> onRevealAllTrueFalseToggled;
  final ValueChanged<bool> onBlurToggled;
  final ValueChanged<bool> onColoredTextToggled;
  final ValueChanged<bool> onBionicToggled;
  final ValueChanged<bool> onJustifiedReadingToggled;
  final VoidCallback onInviteFriendsTap;
  final VoidCallback onRedeemCodeTap;
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
    required this.justifiedReadingEnabled,
    required this.onTypingSoundToggled,
    required this.onGeneralSoundsToggled,
    required this.onHapticsToggled,
    required this.onRevealAllTrueFalseToggled,
    required this.onBlurToggled,
    required this.onColoredTextToggled,
    required this.onBionicToggled,
    required this.onJustifiedReadingToggled,
    required this.onInviteFriendsTap,
    required this.onRedeemCodeTap,
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
    void onAccountTap() => AccountBottomSheet.show(context);
    void onBirdPickerTap() => BirdPickerBottomSheet.show(context);
    void onFontPickerTap() => FontPickerBottomSheet.show(context);
    void onFeathersTap() => FeathersBottomSheet.show(context);
    void onNightShiftTap() => NightShiftBottomSheet.show(context);
    void onPrivacyPolicyTap() => LinkService.openUrl(RLLinks.PRIVACY_POLICY_URL);
    void onTermsTap() => LinkService.openUrl(RLLinks.TERMS_OF_SERVICE_URL);
    void onEulaTap() => LinkService.openUrl(RLLinks.EULA_URL);
    // Column width row has its control (chips) inside the demo card below,
    // so the row itself is a label — tap is a no-op.
    void onColumnWidthRowTap() {}

    // Tapping a demo card flips the matching switch — same effect as
    // clicking the switch itself, so the preview doubles as the control
    // and gets the same switch click sound. The user-supplied toggle
    // handlers are also called from RLSwitch directly, so we play the
    // sound here (the demo path) rather than inside the handler to avoid
    // double-firing when the switch itself is tapped.
    void onProgressiveDemoTap() {
      SoundService.playSwitch();
      handleProgressiveToggled(revealAllTrueFalse);
    }

    void onBlurDemoTap() {
      SoundService.playSwitch();
      onBlurToggled(!blurEnabled);
    }

    void onColoredTextDemoTap() {
      SoundService.playSwitch();
      onColoredTextToggled(!coloredTextEnabled);
    }

    void onBionicDemoTap() {
      SoundService.playSwitch();
      onBionicToggled(!bionicEnabled);
    }

    // Same wrapping for JustifiedReadingDemo's onToggle — its tap also
    // commits a boolean swap, just via a different prop name. Wrapping
    // here keeps the un-wrapped onJustifiedReadingToggled intact for the
    // SwitchMenuItem above (which routes through RLSwitch's own click).
    void onJustifiedReadingDemoToggle(bool nextValue) {
      SoundService.playSwitch();
      onJustifiedReadingToggled(nextValue);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Account & Subscription
        MenuItem(icon: Pixel.user, title: RLUIStrings.MENU_ACCOUNT, onTap: onAccountTap),

        MenuItem(
          leading: const RLFeatherIcon(size: RLDS.iconMedium),
          title: RLUIStrings.MENU_FEATHERS,
          onTap: onFeathersTap,
        ),

        MenuItem(
          // The reader's currently-selected bird sprite stands in for the
          // generic glyph here so the row reads as "your bird" at a glance.
          // Rebuilds via ValueListenableBuilder when the picker writes a
          // new selection so the icon stays in sync.
          leading: const ProfileBirdMenuIcon(),
          title: RLUIStrings.MENU_PROFILE_BIRD,
          onTap: onBirdPickerTap,
        ),

        MenuItem(
          icon: Pixel.mail,
          title: RLUIStrings.MENU_INVITE_FRIENDS,
          iconColor: RLDS.success,
          onTap: onInviteFriendsTap,
        ),

        MenuItem(
          icon: Pixel.gift,
          title: RLUIStrings.MENU_REDEEM_CODE,
          iconColor: RLDS.success,
          onTap: onRedeemCodeTap,
        ),

        const MenuDivider(label: RLUIStrings.MENU_SECTION_SOUND),

        // Sound & Haptics
        SwitchMenuItem(
          icon: Pixel.volume2,
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

        const MenuDivider(label: RLUIStrings.MENU_SECTION_READING),

        // Reading Settings.
        //
        // Night Shift sits at the top: it shifts the global tint of every
        // reading surface, so it reads naturally as a frame around the
        // per-feature toggles below it.
        MenuItem(
          icon: Pixel.moon,
          title: RLUIStrings.NIGHT_SHIFT_TITLE,
          onTap: onNightShiftTap,
          // Match the warm amber moon used inside NightShiftBottomSheet so
          // the row's icon and the sheet's icon read as the same accent.
          iconColor: NIGHT_SHIFT_WARM_COLOR,
        ),

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

        RevealDemo(isEnabled: revealAllTrueFalse, onTap: onProgressiveDemoTap),

        const DemoExplainLabel(explanation: RLUIStrings.DEMO_EXPLAIN_REVEAL),

        SwitchMenuItem(
          icon: Pixel.eye,
          title: RLUIStrings.MENU_BLUR,
          value: blurEnabled,
          onChanged: onBlurToggled,
        ),

        BlurDemo(isEnabled: blurEnabled, onTap: onBlurDemoTap),

        const DemoExplainLabel(explanation: RLUIStrings.DEMO_EXPLAIN_BLUR),

        SwitchMenuItem(
          icon: Pixel.edit,
          title: RLUIStrings.MENU_COLORED_TEXT,
          value: coloredTextEnabled,
          onChanged: onColoredTextToggled,
        ),

        ColoredTextDemo(isEnabled: coloredTextEnabled, onTap: onColoredTextDemoTap),

        const DemoExplainLabel(explanation: RLUIStrings.DEMO_EXPLAIN_COLORED_TEXT),

        // Font picker + live demo — sits at the end of Reading Settings so
        // it follows the toggles that govern what text looks like.
        MenuItem(
          icon: Pixel.book,
          title: RLUIStrings.MENU_READING_FONT,
          onTap: onFontPickerTap,
        ),

        const ReadingFontDemo(),

        const DemoExplainLabel(explanation: RLUIStrings.DEMO_EXPLAIN_FONT),

        // Column width — label row above (chevron-less, no-op tap) matches
        // the other reading-setting rows; the chips inside the demo card
        // below are the actual control.
        MenuItem(
          icon: Pixel.textcolums,
          title: RLUIStrings.MENU_READING_COLUMN,
          onTap: onColumnWidthRowTap,
        ),

        const ReadingColumnDemo(),

        const DemoExplainLabel(explanation: RLUIStrings.DEMO_EXPLAIN_COLUMN),

        // Justified text — paragraph-shape preference for long-form reading.
        // Off by default (regular/left-aligned); flipping it on retypes every
        // ProgressiveText surface that opts in (CCTextContent) as justified.
        SwitchMenuItem(
          icon: Pixel.alignjustify,
          title: RLUIStrings.MENU_JUSTIFIED_READING,
          value: justifiedReadingEnabled,
          onChanged: onJustifiedReadingToggled,
        ),

        JustifiedReadingDemo(onToggle: onJustifiedReadingDemoToggle),

        const DemoExplainLabel(explanation: RLUIStrings.DEMO_EXPLAIN_JUSTIFIED),

        // Bionic + RSVP sit at the bottom of Reading Settings. They are
        // the most specialised reading modes in the section, so they live
        // below the everyday typography settings rather than in the middle.
        SwitchMenuItem(
          icon: Pixel.speedfast,
          title: RLUIStrings.MENU_BIONIC,
          value: bionicEnabled,
          onChanged: onBionicToggled,
        ),

        BionicDemo(isEnabled: bionicEnabled, onTap: onBionicDemoTap),

        const DemoExplainLabel(explanation: RLUIStrings.DEMO_EXPLAIN_BIONIC),

        // RSVP mode hidden from settings until ready for release.
        // SwitchMenuItem(
        //   icon: Pixel.zap,
        //   title: RLUIStrings.MENU_RSVP,
        //   value: rsvpEnabled,
        //   onChanged: onRsvpToggled,
        // ),
        // RSVPDemo(isEnabled: rsvpEnabled),
        const MenuDivider(label: RLUIStrings.MENU_SECTION_LEGAL),

        // Legal (Support listed last, after EULA)
        MenuItem(
          icon: Pixel.shield,
          title: RLUIStrings.MENU_PRIVACY_POLICY,
          onTap: onPrivacyPolicyTap,
        ),

        MenuItem(
          icon: Pixel.article,
          title: RLUIStrings.MENU_TERMS_AND_CONDITIONS,
          onTap: onTermsTap,
        ),

        MenuItem(icon: Pixel.scale, title: RLUIStrings.MENU_EULA, onTap: onEulaTap),

        MenuItem(icon: Pixel.message, title: RLUIStrings.MENU_SUPPORT, onTap: onSupportTap),

        const MenuDivider(label: RLUIStrings.MENU_SECTION_SESSION),

        // Log out
        MenuItem(icon: Pixel.logout, title: RLUIStrings.MENU_LOG_OUT, onTap: onLogoutTap),

        const Spacing.height(RLDS.spacing24),

        Center(
          child: RLTypography.bodyMedium(
            RLUIStrings.MENU_VERSION,
            color: RLDS.glass50(RLDS.textPrimary),
          ),
        ),
      ],
    );
  }
}

class MenuItem extends StatelessWidget {
  final IconData? icon;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;
  // Optional override for the leading icon's tint only. Wins over textColor
  // so the title can stay neutral while the icon picks up an accent (eg.
  // Night Shift's amber matches the moon icon in NightShiftBottomSheet).
  final Color? iconColor;
  // Optional custom leading widget that replaces the IconData glyph. Used
  // by the Feathers row so it can render the Plume sprite instead of a
  // pixelarticons icon. When supplied, `icon` may be omitted.
  final Widget? leading;

  const MenuItem({
    super.key,
    this.icon,
    required this.title,
    required this.onTap,
    this.textColor,
    this.iconColor,
    this.leading,
  }) : assert(icon != null || leading != null, 'MenuItem needs an icon or a leading widget');

  @override
  Widget build(BuildContext context) {
    final bool hasTextColor = textColor != null;
    final bool hasIconColorOverride = iconColor != null;

    Color resolvedIconColor = RLDS.glass70(RLDS.textPrimary);
    Color titleColor = RLDS.textPrimary;

    if (hasTextColor) {
      resolvedIconColor = textColor!;
      titleColor = textColor!;
    }

    if (hasIconColorOverride) {
      resolvedIconColor = iconColor!;
    }

    final Widget MenuItemIcon =
        leading ?? Icon(icon, color: resolvedIconColor, size: RLDS.iconMedium);

    void handleMenuItemTap() {
      HapticsService.lightImpact();
      SoundService.playRandomTextClick();
      onTap();
    }

    return GestureDetector(
      onTap: handleMenuItemTap,
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
    HapticsService.lightImpact();
    onChanged(newValue);
  }

  // Tap anywhere on the row (icon, title, whitespace) toggles the switch.
  // Fires the switch click here because the row tap bypasses RLSwitch
  // (which only sounds when CupertinoSwitch itself is the tap target),
  // so without this the row would commit the toggle silently.
  void handleRowTap() {
    SoundService.playSwitch();
    handleSwitchChange(!value);
  }

  @override
  Widget build(BuildContext context) {
    final Color iconColor = RLDS.glass70(RLDS.textPrimary);
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
  // Optional section label rendered to the left of the divider line.
  // When null the divider falls back to a plain hairline (the original
  // behaviour) so callers that don't want a section break stay clean.
  final String? label;

  const MenuDivider({super.key, this.label});

  @override
  Widget build(BuildContext context) {
    final Color lineColor = RLDS.glass10(RLDS.textPrimary);
    final String? labelText = label;
    final bool hasLabel = labelText != null;

    if (!hasLabel) {
      return Container(
        height: 1.0,
        margin: const EdgeInsets.symmetric(vertical: RLDS.spacing8),
        color: lineColor,
      );
    }

    final Widget LineFill = Expanded(child: Container(height: 1.0, color: lineColor));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: RLDS.spacing12),
      child: Row(
        children: [
          RLTypography.bodySmall(labelText, color: RLDS.textSecondary),

          const Spacing.width(RLDS.spacing12),

          LineFill,
        ],
      ),
    );
  }
}

// Live "Profile Bird" leading icon: the user's currently-selected bird
// rendered at the standard menu-glyph size so the row icon and the
// picker target read as the same object. Listens to selectedBirdNotifier
// so flipping a bird in the picker sheet updates this row immediately.
class ProfileBirdMenuIcon extends StatelessWidget {
  const ProfileBirdMenuIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<BirdOption>(
      valueListenable: selectedBirdNotifier,
      builder: ProfileBirdMenuIconBuilder,
    );
  }

  Widget ProfileBirdMenuIconBuilder(
    BuildContext context,
    BirdOption bird,
    Widget? unusedChild,
  ) {
    return SizedBox(
      width: RLDS.iconMedium,
      height: RLDS.iconMedium,
      child: BirdAnimationSprite(bird: bird, previewSize: RLDS.iconMedium),
    );
  }
}

// Right-aligned "What's this?" label placed under each settings demo box.
// Tapping opens a feedback-style bottom sheet with a short explanation
// of what the feature does.
class DemoExplainLabel extends StatelessWidget {
  final String explanation;

  const DemoExplainLabel({super.key, required this.explanation});

  @override
  Widget build(BuildContext context) {
    void handleTap() {
      HapticsService.lightImpact();
      SoundService.playRandomTextClick();
      FeedbackBottomSheets.showFeedbackSheet(context: context, content: explanation);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: RLDS.spacing8),
      child: Align(
        alignment: Alignment.centerRight,
        child: GestureDetector(
          onTap: handleTap,
          behavior: HitTestBehavior.opaque,
          child: RLTypography.bodySmall(
            RLUIStrings.DEMO_EXPLAIN_LABEL,
            color: RLDS.textSecondary,
          ),
        ),
      ),
    );
  }
}
