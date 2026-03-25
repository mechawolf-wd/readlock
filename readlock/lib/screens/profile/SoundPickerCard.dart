// Sound picker card for selecting ambient sounds
// Expandable card with sound selection options

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:readlock/constants/RLDimensions.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLConstants.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLTheme.dart';
import 'package:readlock/utility_widgets/ExpandableCard.dart';

class SoundPickerCard extends StatefulWidget {
  const SoundPickerCard({super.key});

  @override
  State<SoundPickerCard> createState() => SoundPickerCardState();
}

class SoundPickerCardState extends State<SoundPickerCard> {
  String selectedSound = TYPEWRITER_SOUND;

  @override
  Widget build(BuildContext context) {
    final Widget soundContent = SoundPickerContent();

    return ExpandableCard(
      title: 'Sound Settings',
      icon: Icons.volume_up,
      backgroundColor: RLTheme.backgroundLight,
      titleColor: RLTheme.textPrimary,
      iconColor: RLTheme.textSecondary,
      expandedContent: soundContent,
    );
  }

  Widget SoundPickerContent() {
    final List<Map<String, dynamic>> soundOptions = [
      {'name': TYPEWRITER_SOUND, 'icon': Icons.keyboard},
      {'name': SWITCHES_SOUND, 'icon': Icons.toggle_on},
      {'name': OIIA_SOUND, 'icon': Icons.music_note},
    ];

    final List<Widget> soundBlocks = SoundBlockItems(soundOptions);

    return Div.row(soundBlocks, mainAxisAlignment: MainAxisAlignment.spaceEvenly);
  }

  List<Widget> SoundBlockItems(List<Map<String, dynamic>> soundOptions) {
    return soundOptions.map((sound) {
      final bool isSelected = selectedSound == sound['name'];

      return Expanded(
        child: SoundBlock(
          name: sound['name'] as String,
          icon: sound['icon'] as IconData,
          isSelected: isSelected,
          onTap: () => selectSound(sound['name'] as String),
        ),
      );
    }).toList();
  }

  Widget SoundBlock({
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

    final Color iconColor = isSelected ? RLTheme.primaryBlue : RLTheme.textSecondary;

    final Color textColor = isSelected ? RLTheme.primaryBlue : RLTheme.textPrimary;

    final BoxDecoration blockDecoration = BoxDecoration(
      color: backgroundColor,
      borderRadius: RLDimensions.borderRadiusL,
      border: Border.all(color: borderColor),
    );

    final Widget SoundIcon = Icon(icon, color: iconColor, size: RLDimensions.iconL);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: blockDecoration,
        padding: RLDimensions.paddingAllM,
        margin: const EdgeInsets.symmetric(horizontal: RLDimensions.spacing4),
        child: Div.column([
          SoundIcon,

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
    HapticFeedback.lightImpact();

    setState(() {
      selectedSound = soundName;
    });
  }
}
