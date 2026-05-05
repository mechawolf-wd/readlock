// Profile settings screen.
// Loads preferences from /users/{id} on mount, persists every toggle/segment
// change back to Firestore so state survives across devices and sessions.

import 'package:flutter/material.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/MainNavigation.dart';
import 'package:readlock/bottom_sheets/user/LoginBottomSheet.dart';
import 'package:readlock/bottom_sheets/user/LoginSupportBottomSheet.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/design_system/RLConfirmationDialog.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/models/UserModel.dart';
import 'package:readlock/screens/profile/MenuWidgets.dart';
import 'package:readlock/services/auth/AuthService.dart';
import 'package:readlock/services/auth/UserPreferencesHydrator.dart';
import 'package:readlock/services/auth/UserService.dart';
import 'package:readlock/services/feedback/HapticsService.dart';
import 'package:readlock/services/feedback/SoundService.dart';
import 'package:readlock/constants/RLReadingJustified.dart';
import 'package:readlock/utility_widgets/text_animation/BionicText.dart';
import 'package:readlock/utility_widgets/text_animation/RSVPText.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: RLDS.surface,
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
  bool bionicEnabled = false;
  bool rsvpEnabled = false;
  bool justifiedReadingEnabled = true;
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
      bionicEnabled = user.bionic;
      rsvpEnabled = user.rsvp;
      justifiedReadingEnabled = user.justifiedReading;
    });

    bionicEnabledNotifier.value = user.bionic;
    rsvpEnabledNotifier.value = user.rsvp;
    justifiedReadingEnabledNotifier.value = user.justifiedReading;

    // Re-apply the persisted enums and tunables (font, column, RSVP wpm,
    // night-shift, bird) in case the sheet is opened before MainNavigation's
    // initial hydration has finished, or a subsequent device write landed.
    hydrateUserPreferenceNotifiersFromUser(user);
  }

  // * Individual preference handlers — optimistic setState + fire-and-forget
  // persistence to Firestore. Intentionally not awaited so the UI stays
  // snappy; UserService logs any write failures for diagnostics.

  void handleTypingSoundToggled(bool value) {
    setState(() => typingSoundEnabled = value);
    SoundService.typingSoundEnabledNotifier.value = value;
    UserService.updateTypingSound(value);
  }

  void handleGeneralSoundsToggled(bool value) {
    setState(() => generalSoundsEnabled = value);
    SoundService.soundsEnabledNotifier.value = value;
    UserService.updateSounds(value);
  }

  void handleHapticsToggled(bool value) {
    setState(() => hapticsEnabled = value);
    HapticsService.userHapticsEnabledNotifier.value = value;
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
    bionicEnabledNotifier.value = value;
    UserService.updateBionic(value);
  }

  void handleRsvpToggled(bool value) {
    setState(() => rsvpEnabled = value);
    rsvpEnabledNotifier.value = value;
    UserService.updateRsvp(value);
  }

  void handleJustifiedReadingToggled(bool value) {
    setState(() => justifiedReadingEnabled = value);
    justifiedReadingEnabledNotifier.value = value;
    UserService.updateJustifiedReading(value);
  }

  // A signed-in user already has password reset / resend verification in
  // their account flow, so the settings entry skips the picker and goes
  // straight to the email-support sheet.
  void handleSupportTap() {
    EmailSupportSheet.show(context);
  }

  // * Logout flow.
  //
  // The settings sheet (and its confirmation dialog) must stay visible for the
  // whole trip: tap → confirm → sign out → close. Only after AuthService.signOut
  // resolves do we pop the sheet, and the login sheet is then explicitly
  // presented on the root navigator so the reader has an obvious sign-back-in
  // entry point. The app otherwise runs unauthenticated, so no auto-present
  // sheet appears outside this flow.

  void handleLogoutTap() {
    if (isLoggingOut) {
      return;
    }

    SoundService.playLogout();

    RLConfirmationDialog.show(
      context,
      title: RLUIStrings.LOGOUT_CONFIRMATION_TITLE,
      message: RLUIStrings.LOGOUT_CONFIRMATION_MESSAGE,
      cta: RLConfirmationAction(
        label: RLUIStrings.LOGOUT_CONFIRMATION_CONFIRM,
        variant: RLConfirmationVariant.destructive,
        onTap: handleLogoutConfirmed,
      ),
      cancel: const RLConfirmationAction(
        label: RLUIStrings.CANCEL_LABEL,
        variant: RLConfirmationVariant.neutral,
      ),
    );
  }

  Future<void> handleLogoutConfirmed() async {
    if (isLoggingOut) {
      return;
    }

    setState(() {
      isLoggingOut = true;
    });

    // Capture the root navigator before any async gap so we can collapse
    // the modal stack and present the login sheet on a still-mounted
    // ancestor context once the sign-out resolves.
    final NavigatorState rootNavigator = Navigator.of(context, rootNavigator: true);
    final BuildContext rootContext = rootNavigator.context;

    await AuthService.signOut();

    // Collapse every open bottom sheet (settings, and anything stacked
    // above it) so the login sheet lands on a clean main route. Holding
    // the pop until sign-out resolves keeps the in-progress state visible
    // through the trip.
    if (rootNavigator.mounted) {
      rootNavigator.popUntil((route) => route.isFirst);
    }

    // Switch the bottom-nav to the Search tab so the courses screen sits
    // behind the login sheet — gives the signed-out reader something
    // browseable to peek at instead of whatever screen happened to host the
    // settings sheet.
    activeTabIndexNotifier.value = TAB_INDEX_SEARCH;

    if (rootContext.mounted) {
      LoginBottomSheet.show(rootContext);
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
      justifiedReadingEnabled: justifiedReadingEnabled,
      onTypingSoundToggled: handleTypingSoundToggled,
      onGeneralSoundsToggled: handleGeneralSoundsToggled,
      onHapticsToggled: handleHapticsToggled,
      onRevealAllTrueFalseToggled: handleRevealToggled,
      onBlurToggled: handleBlurToggled,
      onColoredTextToggled: handleColoredTextToggled,
      onBionicToggled: handleBionicToggled,
      onRsvpToggled: handleRsvpToggled,
      onJustifiedReadingToggled: handleJustifiedReadingToggled,
      onSupportTap: handleSupportTap,
      onLogoutTap: handleLogoutTap,
    );

    // During logout: freeze interactions so the user can't tap anything while
    // the auth round-trip is in flight. A small banner tells them what's
    // happening. The sheet itself stays open until handleLogoutConfirmed pops.
    if (isLoggingOut) {
      return Div.column([
        IgnorePointer(child: Opacity(opacity: 0.5, child: menu)),
      ], crossAxisAlignment: CrossAxisAlignment.stretch);
    }

    return menu;
  }
}
