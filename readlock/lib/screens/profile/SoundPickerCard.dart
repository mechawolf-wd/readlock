// Sound picker card for selecting ambient sounds
// Expandable card with sound selection options

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/design_system/RLExpandableCard.dart';
import 'package:readlock/constants/DartAliases.dart';

class SoundPickerCard extends StatefulWidget {
  const SoundPickerCard({super.key});

  @override
  State<SoundPickerCard> createState() => SoundPickerCardState();
}

class SoundPickerCardState extends State<SoundPickerCard> {
  String selectedSound = RLUIStrings.TYPEWRITER_SOUND;

  @override
  Widget build(BuildContext context) {
    final Widget soundContent = SoundPickerContent();

    return ExpandableCard(
      title: RLUIStrings.SOUND_SETTINGS_TITLE,
      icon: Icons.volume_up,
      backgroundColor: RLDS.backgroundLight,
      titleColor: RLDS.textPrimary,
      iconColor: RLDS.textSecondary,
      expandedContent: soundContent,
    );
  }

  Widget SoundPickerContent() {
    final JSONList soundOptions = [
      {'name': RLUIStrings.TYPEWRITER_SOUND, 'icon': Icons.keyboard},
      {'name': RLUIStrings.SWITCHES_SOUND, 'icon': Icons.toggle_on},
    ];

    final List<Widget> soundBlocks = SoundBlockItems(soundOptions);

    return Div.row(soundBlocks, mainAxisAlignment: MainAxisAlignment.spaceEvenly);
  }

  List<Widget> SoundBlockItems(JSONList soundOptions) {
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
        ? RLDS.primary.withValues(alpha: 0.1)
        : Colors.transparent;

    final Color borderColor = isSelected
        ? RLDS.primary
        : RLDS.textPrimary.withValues(alpha: 0.2);

    final Color iconColor = isSelected ? RLDS.primary : RLDS.textSecondary;

    final Color textColor = isSelected ? RLDS.primary : RLDS.textPrimary;

    final BoxDecoration blockDecoration = BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12.0),
      border: Border.all(color: borderColor),
    );

    final Widget SoundIcon = Icon(icon, color: iconColor, size: 24.0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: blockDecoration,
        padding: const EdgeInsets.all(12.0),
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Div.column([
          SoundIcon,

          const Spacing.height(8),

          RLTypography.bodyMedium(name, color: textColor, textAlign: TextAlign.center),
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
