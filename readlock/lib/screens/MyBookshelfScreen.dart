// My Bookshelf screen — header with bird + settings, placeholder body until
// real bookshelf state (saved / in-progress courses) exists.

import 'package:flutter/material.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/bottom_sheets/user/SettingsBottomSheet.dart';
import 'package:readlock/screens/profile/BirdPicker.dart';

import 'package:pixelarticons/pixel.dart';
class MyBookshelfScreen extends StatefulWidget {
  const MyBookshelfScreen({super.key});

  @override
  State<MyBookshelfScreen> createState() => MyBookshelfScreenState();
}

class MyBookshelfScreenState extends State<MyBookshelfScreen> {
  static final Widget SettingsIcon = const Icon(
    Pixel.sliders,
    color: RLDS.textSecondary,
    size: 24,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RLDS.backgroundDark,
      body: SafeArea(
        bottom: false,
        child: BookshelfBody(),
      ),
    );
  }

  Widget BookshelfBody() {
    return Padding(
      padding: const EdgeInsets.all(RLDS.spacing24),
      child: Div.column([
        BookshelfHeaderWithSettings(),

        const Spacing.height(40),

        EmptyBookshelfMessage(),
      ], crossAxisAlignment: CrossAxisAlignment.stretch),
    );
  }

  Widget BookshelfHeaderWithSettings() {
    return Div.row([
      RLTypography.headingLarge(RLUIStrings.BOOKSHELF_TITLE),

      const Spacing.width(RLDS.spacing12),

      BookshelfTitleBird(),

      const Spacer(),

      GestureDetector(
        onTap: () => SettingsBottomSheet.show(context),
        child: SettingsIcon,
      ),
    ], crossAxisAlignment: CrossAxisAlignment.center);
  }

  Widget BookshelfTitleBird() {
    return ValueListenableBuilder<BirdOption>(
      valueListenable: selectedBirdNotifier,
      builder: TitleBirdBuilder,
    );
  }

  Widget TitleBirdBuilder(BuildContext context, BirdOption bird, Widget? _) {
    return BirdAnimationSprite(
      bird: bird,
      previewSize: BIRD_PREVIEW_SIZE_SMALL,
      zoom: 2.0,
    );
  }

  Widget EmptyBookshelfMessage() {
    return Center(
      child: Text(
        RLUIStrings.BOOKSHELF_EMPTY_MESSAGE,
        style: RLTypography.bodyMediumStyle.copyWith(color: RLDS.textSecondary),
      ),
    );
  }
}
