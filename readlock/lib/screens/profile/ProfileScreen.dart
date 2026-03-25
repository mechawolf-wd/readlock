// Gamified profile screen
// Showcases mockups of engaging learning patterns adapted for book reading

import 'package:flutter/material.dart';
import 'package:readlock/constants/RLDimensions.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLTheme.dart';
import 'package:readlock/screens/profile/SoundPickerCard.dart';
import 'package:readlock/screens/profile/MenuWidgets.dart';

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

  void handleSoundsToggled(bool value) {
    setState(() => soundsEnabled = value);
  }

  void handleHapticsToggled(bool value) {
    setState(() => hapticsEnabled = value);
  }

  void handleRevealAllTrueFalseToggled(bool value) {
    setState(() => revealAllTrueFalse = value);
  }

  void handleBlurToggled(bool value) {
    setState(() => blurEnabled = value);
  }

  void handleColoredTextToggled(bool value) {
    setState(() => coloredTextEnabled = value);
  }

  void handleTextSpeedChanged(String value) {
    setState(() => textSpeed = value);
  }

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
          onSoundsToggled: handleSoundsToggled,
          onHapticsToggled: handleHapticsToggled,
          onRevealAllTrueFalseToggled: handleRevealAllTrueFalseToggled,
          onBlurToggled: handleBlurToggled,
          onColoredTextToggled: handleColoredTextToggled,
          onTextSpeedChanged: handleTextSpeedChanged,
        ),
      ],
    );
  }
}
