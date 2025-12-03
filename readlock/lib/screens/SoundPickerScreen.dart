import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLTheme.dart';

const String TYPEWRITER_SOUND = 'Typewriter';
const String SWITCHES_SOUND = 'Switches';
const String OIIA_SOUND = 'OIIA';

class SoundPickerScreen extends StatefulWidget {
  const SoundPickerScreen({super.key});

  @override
  State<SoundPickerScreen> createState() => _SoundPickerScreenState();
}

class _SoundPickerScreenState extends State<SoundPickerScreen> {
  String selectedSound = TYPEWRITER_SOUND;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RLTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: RLTheme.backgroundDark,
        title: RLTypography.headingLarge(
          'Sound Settings',
          color: RLTheme.textPrimary,
        ),
        iconTheme: const IconThemeData(color: RLTheme.textPrimary),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Div.column([
            RLTypography.bodyLarge(
              'Choose your preferred sound',
              color: RLTheme.textPrimary,
            ),

            const Spacing.height(32),

            soundOptionBlock(),
          ]),
        ),
      ),
    );
  }

  Widget soundOptionBlock() {
    final List<Map<String, dynamic>> soundOptions = [
      {
        'name': TYPEWRITER_SOUND,
        'icon': Icons.keyboard,
        'description': 'Classic typing sounds',
        'color': RLTheme.primaryBlue,
      },
      {
        'name': SWITCHES_SOUND,
        'icon': Icons.toggle_on,
        'description': 'Mechanical switch sounds',
        'color': RLTheme.primaryGreen,
      },
      {
        'name': OIIA_SOUND,
        'icon': Icons.music_note,
        'description': 'OIIA sound effects',
        'color': Colors.orange,
      },
    ];

    return Div.row([
      ...soundOptions.map((sound) {
        final bool isSelected = selectedSound == sound['name'];

        return Expanded(
          child: soundBlock(
            name: sound['name'] as String,
            icon: sound['icon'] as IconData,
            description: sound['description'] as String,
            color: sound['color'] as Color,
            isSelected: isSelected,
            onTap: () => selectSound(sound['name'] as String),
          ),
        );
      }),
    ], mainAxisAlignment: MainAxisAlignment.spaceBetween);
  }

  Widget soundBlock({
    required String name,
    required IconData icon,
    required String description,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final Color backgroundColor = isSelected
        ? color.withValues(alpha: 0.2)
        : RLTheme.backgroundLight;

    final Color borderColor = isSelected
        ? color
        : RLTheme.textPrimary.withValues(alpha: 0.1);

    final BoxDecoration blockDecoration = BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: blockDecoration,
        padding: const EdgeInsets.all(16),
        child: Div.column([
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(icon, color: color, size: 24),
          ),

          const Spacing.height(12),

          RLTypography.headingMedium(
            name,
            color: isSelected ? color : RLTheme.textPrimary,
            textAlign: TextAlign.center,
          ),

          const Spacing.height(4),

          RLTypography.bodyMedium(
            description,
            color: RLTheme.textPrimary.withValues(alpha: 0.7),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),

          if (isSelected) ...[
            const Spacing.height(8),

            Icon(Icons.check_circle, color: color, size: 20),
          ],
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
