// Profile settings screen.
// Loads preferences from /users/{id} on mount, persists every toggle/segment
// change back to Firestore so state survives across devices and sessions.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/design_system/RLConfirmationDialog.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/models/UserModel.dart';
import 'package:readlock/screens/profile/MenuWidgets.dart';
import 'package:readlock/services/auth/AuthService.dart';
import 'package:readlock/services/auth/UserService.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: RLDS.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(RLDS.spacing20),
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
  bool typingSoundEnabled = true;
  bool generalSoundsEnabled = true;
  bool hapticsEnabled = true;
  bool revealEnabled = false;
  bool blurEnabled = true;
  bool coloredTextEnabled = true;
  // Bionic reading lives in-memory only for now — no UserModel round-trip
  // until we integrate the transform into ProgressiveText / CCTextContent.
  bool bionicEnabled = false;
  // RSVP (rapid reading) — also in-memory only until it's wired into the
  // reading surfaces. The demo is self-contained in SettingsDemos.
  bool rsvpEnabled = false;
  bool isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    fetchUserPreferences();
  }

  // * Load preferences from /users/{id}.

  Future<void> fetchUserPreferences() async {
    final UserModel? user = await UserService.getCurrentUserProfile();
    final bool hasNoUser = user == null;
    final bool isUnmounted = !mounted;

    if (isUnmounted) {
      return;
    }

    if (hasNoUser) {
      return;
    }

    setState(() {
      typingSoundEnabled = user.typingSound;
      generalSoundsEnabled = user.sounds;
      hapticsEnabled = user.haptics;
      revealEnabled = user.reveal;
      blurEnabled = user.blur;
      coloredTextEnabled = user.coloredText;
    });
  }

  // * Individual preference handlers — optimistic setState + fire-and-forget
  // persistence to Firestore. Intentionally not awaited so the UI stays
  // snappy; UserService logs any write failures for diagnostics.

  void handleTypingSoundToggled(bool value) {
    setState(() => typingSoundEnabled = value);
    UserService.updateTypingSound(value);
  }

  void handleGeneralSoundsToggled(bool value) {
    setState(() => generalSoundsEnabled = value);
    UserService.updateSounds(value);
  }

  void handleHapticsToggled(bool value) {
    setState(() => hapticsEnabled = value);
    UserService.updateHaptics(value);
  }

  void handleRevealToggled(bool value) {
    setState(() => revealEnabled = value);
    UserService.updateReveal(value);
  }

  void handleBlurToggled(bool value) {
    setState(() => blurEnabled = value);
    UserService.updateBlur(value);
  }

  void handleColoredTextToggled(bool value) {
    setState(() => coloredTextEnabled = value);
    UserService.updateColoredText(value);
  }

  void handleBionicToggled(bool value) {
    setState(() => bionicEnabled = value);
  }

  void handleRsvpToggled(bool value) {
    setState(() => rsvpEnabled = value);
  }

  void handleSupportTap() {}

  // * Logout flow.
  //
  // The settings sheet (and its confirmation dialog) must stay visible for the
  // whole trip: tap → confirm → sign out → close. Only after AuthService.signOut
  // resolves do we pop the sheet. MainNavigation listens to auth state changes
  // and re-presents the login sheet on its own, so we don't push it manually.

  void handleLogoutTap() {
    if (isLoggingOut) {
      return;
    }

    RLConfirmationDialog.show(
      context,
      title: RLUIStrings.LOGOUT_CONFIRMATION_TITLE,
      message: RLUIStrings.LOGOUT_CONFIRMATION_MESSAGE,
      cta: RLConfirmationAction(
        label: RLUIStrings.LOGOUT_CONFIRMATION_CONFIRM,
        variant: RLConfirmationVariant.destructive,
        onTap: handleLogoutConfirmed,
      ),
      cancel: rlDismissCancelAction(),
    );
  }

  Future<void> handleLogoutConfirmed() async {
    if (isLoggingOut) {
      return;
    }

    setState(() {
      isLoggingOut = true;
    });

    await AuthService.signOut();

    // The settings sheet is this widget's ancestor route — only pop it once
    // the sign-out is complete so the user sees the in-progress state.
    if (mounted) {
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget menu = MenuSection(
      typingSoundEnabled: typingSoundEnabled,
      generalSoundsEnabled: generalSoundsEnabled,
      hapticsEnabled: hapticsEnabled,
      revealAllTrueFalse: revealEnabled,
      blurEnabled: blurEnabled,
      coloredTextEnabled: coloredTextEnabled,
      bionicEnabled: bionicEnabled,
      rsvpEnabled: rsvpEnabled,
      onTypingSoundToggled: handleTypingSoundToggled,
      onGeneralSoundsToggled: handleGeneralSoundsToggled,
      onHapticsToggled: handleHapticsToggled,
      onRevealAllTrueFalseToggled: handleRevealToggled,
      onBlurToggled: handleBlurToggled,
      onColoredTextToggled: handleColoredTextToggled,
      onBionicToggled: handleBionicToggled,
      onRsvpToggled: handleRsvpToggled,
      onSupportTap: handleSupportTap,
      onLogoutTap: handleLogoutTap,
    );

    // During logout: freeze interactions so the user can't tap anything while
    // the auth round-trip is in flight. A small banner tells them what's
    // happening. The sheet itself stays open until handleLogoutConfirmed pops.
    if (isLoggingOut) {
      return Div.column([
        LogoutProgressBanner(),

        const Spacing.height(RLDS.spacing12),

        IgnorePointer(child: Opacity(opacity: 0.4, child: menu)),
      ], crossAxisAlignment: CrossAxisAlignment.stretch);
    }

    return menu;
  }

  Widget LogoutProgressBanner() {
    final BoxDecoration bannerDecoration = BoxDecoration(
      color: RLDS.backgroundLight,
      borderRadius: RLDS.borderRadiusSmall,
    );

    final Widget spinner = const CupertinoActivityIndicator(radius: 8);

    return Div.row(
      [
        spinner,

        const Spacing.width(RLDS.spacing12),

        RLTypography.bodyMedium(
          RLUIStrings.LOGOUT_IN_PROGRESS_LABEL,
          color: RLDS.textSecondary,
        ),
      ],
      padding: const EdgeInsets.symmetric(horizontal: RLDS.spacing16, vertical: RLDS.spacing12),
      decoration: bannerDecoration,
      mainAxisAlignment: MainAxisAlignment.start,
    );
  }
}
