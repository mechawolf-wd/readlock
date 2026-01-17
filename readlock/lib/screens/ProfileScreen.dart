// Duolingo-inspired gamified profile screen
// Showcases mockups of engaging learning patterns adapted for book reading

import 'package:flutter/material.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDimensions.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLTheme.dart';
import 'package:readlock/widgets/ExpandableCard.dart';
import 'package:readlock/utility_widgets/AccountBottomSheet.dart';

const String TYPEWRITER_SOUND = 'Typewriter';
const String SWITCHES_SOUND = 'Switches';
const String OIIA_SOUND = 'OIIA';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: RLTheme.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: RLDimensions.paddingAllXL,
          child: ProfileContent(),
        ),
      ),
    );
  }
}

class ProfileContent extends StatefulWidget {
  const ProfileContent({super.key});

  @override
  State<ProfileContent> createState() => ProfileContentState();
}

class ProfileContentState extends State<ProfileContent> {
  bool soundsEnabled = true;
  bool hapticsEnabled = true;
  bool revealAllTrueFalse = false;
  bool blurEnabled = true;
  bool coloredTextEnabled = true;
  String textSpeed = 'Classic';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SoundPickerCard(),

        const Spacing.height(24),

        MenuSection(
          soundsEnabled: soundsEnabled,
          hapticsEnabled: hapticsEnabled,
          revealAllTrueFalse: revealAllTrueFalse,
          blurEnabled: blurEnabled,
          coloredTextEnabled: coloredTextEnabled,
          textSpeed: textSpeed,
          onSoundsToggled: (value) =>
              setState(() => soundsEnabled = value),
          onHapticsToggled: (value) =>
              setState(() => hapticsEnabled = value),
          onRevealAllTrueFalseToggled: (value) =>
              setState(() => revealAllTrueFalse = value),
          onBlurToggled: (value) => setState(() => blurEnabled = value),
          onColoredTextToggled: (value) =>
              setState(() => coloredTextEnabled = value),
          onTextSpeedChanged: (value) =>
              setState(() => textSpeed = value),
        ),
      ],
    );
  }
}

class LearningStatsCard extends StatelessWidget {
  const LearningStatsCard({super.key});

  static const Widget ShareIcon = Icon(
    Icons.share,
    color: RLTheme.white,
    size: RLDimensions.iconM,
  );

  @override
  Widget build(BuildContext context) {
    final BoxDecoration cardDecoration = BoxDecoration(
      color: RLTheme.primaryBlue,
      borderRadius: RLDimensions.borderRadiusXL,
    );

    void handleShareTap() {
      // Share functionality
    }

    return Container(
      decoration: cardDecoration,
      padding: RLDimensions.paddingAllXL,
      child: Div.column([
        // Header row
        Div.row([
          RLTypography.headingMedium(
            'Learning Statistics',
            color: RLTheme.white,
          ),

          const Spacer(),

          GestureDetector(onTap: handleShareTap, child: ShareIcon),
        ]),

        const Spacing.height(20),

        // Stats row
        StatsRow(),
      ]),
    );
  }

  Widget StatsRow() {
    return Div.row([
      // Days equivalent stat
      const Expanded(
        child: StatItem(
          value: '320',
          unit: 'days',
          label: 'at 10 minutes/day',
        ),
      ),

      // Divider
      Container(
        width: RLDimensions.dividerNormal,
        height: RLDimensions.buttonHeightL,
        color: Colors.white.withValues(alpha: RLDimensions.alphaMedium),
      ),

      // Lessons completed stat
      const Expanded(
        child: StatItem(
          value: '42',
          unit: 'lessons',
          label: 'completed',
        ),
      ),
    ]);
  }
}

class StatItem extends StatelessWidget {
  final String value;
  final String unit;
  final String label;

  const StatItem({
    super.key,
    required this.value,
    required this.unit,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Div.column([
      Div.row([
        RLTypography.headingLarge(value, color: Colors.white),

        const Spacing.width(4),

        RLTypography.bodyMedium(
          unit,
          color: Colors.white.withValues(alpha: RLDimensions.opacitySoft),
        ),
      ], mainAxisAlignment: MainAxisAlignment.center),

      const Spacing.height(4),

      RLTypography.bodyMedium(
        label,
        color: Colors.white.withValues(alpha: RLDimensions.opacitySubtle),
        textAlign: TextAlign.center,
      ),
    ], crossAxisAlignment: CrossAxisAlignment.center);
  }
}

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

      MenuItem(
        icon: Icons.card_membership,
        title: 'Reader Pass',
        onTap: () {},
      ),

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

      SwitchMenuItem(
        icon: Icons.blur_on,
        title: 'Blur',
        value: blurEnabled,
        onChanged: onBlurToggled,
      ),

      SwitchMenuItem(
        icon: Icons.format_color_text,
        title: 'Colored text',
        value: coloredTextEnabled,
        onChanged: onColoredTextToggled,
      ),

      SegmentedMenuItem(
        icon: Icons.speed,
        title: 'Text speed',
        options: const ['Careful', 'Classic', 'Speed'],
        selectedOption: textSpeed,
        onChanged: onTextSpeedChanged,
      ),

      const MenuDivider(),

      // Support & Information
      MenuItem(
        icon: Icons.notifications,
        title: 'Notifications',
        onTap: () {},
      ),

      MenuItem(icon: Icons.info, title: 'About', onTap: () {}),

      MenuItem(icon: Icons.help, title: 'Help', onTap: () {}),

      MenuItem(
        icon: Icons.bug_report,
        title: 'Report a problem',
        onTap: () {},
      ),

      MenuItem(
        icon: Icons.new_releases,
        title: 'Product Updates',
        onTap: () {},
      ),

      const MenuDivider(),

      // Account Actions & Legal
      MenuItem(icon: Icons.gavel, title: 'Legal', onTap: () {}),

      MenuItem(
        icon: Icons.logout,
        title: 'Log out',
        onTap: () {},
      ),

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

    return Div.row(
      [
        Icon(icon, color: iconColor, size: RLDimensions.iconM),

        const Spacing.width(RLDimensions.spacing16),

        Expanded(
          child: RLTypography.bodyMedium(title, color: titleColor),
        ),

        Icon(
          Icons.chevron_right,
          color: RLTheme.textPrimary.withValues(alpha: RLDimensions.alphaDark),
          size: RLDimensions.iconM,
        ),
      ],
      padding: RLDimensions.paddingVerticalL,
      onTap: onTap,
    );
  }
}

class SoundPickerCard extends StatefulWidget {
  const SoundPickerCard({super.key});

  @override
  State<SoundPickerCard> createState() => SoundPickerCardState();
}

class SoundPickerCardState extends State<SoundPickerCard> {
  String selectedSound = TYPEWRITER_SOUND;

  @override
  Widget build(BuildContext context) {
    final Widget soundContent = soundPickerContent();

    return ExpandableCard(
      title: 'Sound Settings',
      icon: Icons.volume_up,
      backgroundColor: RLTheme.backgroundLight,
      titleColor: RLTheme.textPrimary,
      iconColor: RLTheme.textSecondary,
      expandedContent: soundContent,
    );
  }

  Widget soundPickerContent() {
    final List<Map<String, dynamic>> soundOptions = [
      {'name': TYPEWRITER_SOUND, 'icon': Icons.keyboard},
      {'name': SWITCHES_SOUND, 'icon': Icons.toggle_on},
      {'name': OIIA_SOUND, 'icon': Icons.music_note},
    ];

    final List<Widget> soundBlocks = soundOptions.map((sound) {
      final bool isSelected = selectedSound == sound['name'];

      return Expanded(
        child: soundBlock(
          name: sound['name'] as String,
          icon: sound['icon'] as IconData,
          isSelected: isSelected,
          onTap: () => selectSound(sound['name'] as String),
        ),
      );
    }).toList();

    return Div.row(
      soundBlocks,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    );
  }

  Widget soundBlock({
    required String name,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final Color backgroundColor = isSelected
        ? RLTheme.primaryBlue.withValues(alpha: RLDimensions.alphaLight)
        : Colors.transparent;

    final Color borderColor = isSelected
        ? RLTheme.primaryBlue
        : RLTheme.textPrimary.withValues(alpha: RLDimensions.alphaMedium);

    final Color iconColor = isSelected
        ? RLTheme.primaryBlue
        : RLTheme.textSecondary;

    final Color textColor = isSelected
        ? RLTheme.primaryBlue
        : RLTheme.textPrimary;

    final BoxDecoration blockDecoration = BoxDecoration(
      color: backgroundColor,
      borderRadius: RLDimensions.borderRadiusL,
      border: Border.all(color: borderColor),
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: blockDecoration,
        padding: RLDimensions.paddingAllM,
        margin: const EdgeInsets.symmetric(horizontal: RLDimensions.spacing4),
        child: Div.column([
          Icon(icon, color: iconColor, size: RLDimensions.iconL),

          const Spacing.height(8),

          RLTypography.bodyMedium(
            name,
            color: textColor,
            textAlign: TextAlign.center,
            maxLines: 1,
          ),
        ], crossAxisAlignment: CrossAxisAlignment.center),
      ),
    );
  }

  void selectSound(String soundName) {
    setState(() {
      selectedSound = soundName;
    });
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

    return Div.row([
      Icon(icon, color: iconColor, size: RLDimensions.iconM),

      const Spacing.width(RLDimensions.spacing16),

      Expanded(
        child: RLTypography.bodyMedium(title, color: titleColor),
      ),

      Switch(
        value: value,
        onChanged: onChanged,
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

    return Div.column([
      Div.row([
        Icon(icon, color: iconColor, size: RLDimensions.iconM),

        const Spacing.width(RLDimensions.spacing16),

        Expanded(
          child: RLTypography.bodyMedium(title, color: titleColor),
        ),
      ]),

      const Spacing.height(RLDimensions.spacing16),

      // Segmented options
      SegmentedOptions(
        options: options,
        selectedOption: selectedOption,
        onChanged: onChanged,
      ),
    ], padding: const EdgeInsets.only(top: RLDimensions.spacing32, bottom: RLDimensions.spacing16));
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
      child: Row(
        children: OptionButtons(options, selectedOption, onChanged),
      ),
    );
  }

  List<Widget> OptionButtons(
    List<String> options,
    String selectedOption,
    ValueChanged<String> onChanged,
  ) {
    return options.map((option) {
      final bool isSelected = option == selectedOption;

      final BoxDecoration optionDecoration = BoxDecoration(
        color: isSelected ? RLTheme.primaryBlue : Colors.transparent,
        borderRadius: RLDimensions.borderRadiusS,
      );

      final Color textColor = isSelected
          ? RLTheme.white
          : RLTheme.textPrimary.withValues(alpha: RLDimensions.opacitySubtle);

      return Expanded(
        child: GestureDetector(
          onTap: () => onChanged(option),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: RLDimensions.spacing8),
            decoration: optionDecoration,
            child: Center(
              child: RLTypography.bodyMedium(option, color: textColor),
            ),
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
