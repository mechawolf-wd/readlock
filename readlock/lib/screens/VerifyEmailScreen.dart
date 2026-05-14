// Verify-email gate. Pushed after onboarding (replacing the old "Read"
// step) and after any returning sign-in whose user.emailVerified is still
// false. Two actions: refresh-and-check ("I have verified"), and resend
// the verification link. Closes itself the moment Firebase reports the
// email as verified, dropping the reader on whatever route sits below.

import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/design_system/RLLunarBlur.dart';
import 'package:readlock/design_system/RLStarfieldBackground.dart';
import 'package:readlock/design_system/RLToast.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/services/feedback/HapticsService.dart';
import 'package:readlock/MainNavigation.dart';
import 'package:readlock/bottom_sheets/user/LoginBottomSheet.dart';
import 'package:readlock/services/auth/AuthService.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  // Pushes the verify-email screen as a full-screen route. Returns the
  // route future so callers can await it before continuing the flow.
  static Future<void> show(BuildContext context) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (BuildContext routeContext) => const VerifyEmailScreen(),
      ),
    );
  }

  @override
  State<VerifyEmailScreen> createState() => VerifyEmailScreenState();
}

class VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool isCheckingVerification = false;
  bool isResending = false;
  bool isLoggingOut = false;

  // Refreshes the user from Firebase and pops the screen if the email is
  // now confirmed. Otherwise nudges the reader to check their inbox.
  Future<void> handleVerifyTap() async {
    if (isCheckingVerification) {
      return;
    }

    setState(() {
      isCheckingVerification = true;
    });

    final bool isVerified = await AuthService.isEmailVerified();

    if (!mounted) {
      return;
    }

    setState(() {
      isCheckingVerification = false;
    });

    if (isVerified) {
      Navigator.of(context).maybePop();
      return;
    }

    RLToast.warning(context, RLUIStrings.VERIFY_EMAIL_NOT_YET_MESSAGE);
  }

  // Re-sends the verification link. Surfaces success or failure as a
  // toast, the action is intentionally lightweight and stays on-screen.
  Future<void> handleResendTap() async {
    if (isResending) {
      return;
    }

    HapticsService.lightImpact();

    setState(() {
      isResending = true;
    });

    final bool wasSent = await AuthService.sendEmailVerification();

    if (!mounted) {
      return;
    }

    setState(() {
      isResending = false;
    });

    if (wasSent) {
      RLToast.success(context, RLUIStrings.VERIFICATION_EMAIL_SENT);
      return;
    }

    RLToast.error(context, RLUIStrings.RESEND_VERIFICATION_FAILED);
  }

  // Signs the user out, collapses the verify gate down to the main
  // navigator, and re-presents the login sheet so the reader sees the
  // sign-in entry point immediately. Mirrors ProfileScreen's logout flow
  // so both logout paths land on the same chrome.
  Future<void> handleLogoutTap() async {
    if (isLoggingOut) {
      return;
    }

    setState(() {
      isLoggingOut = true;
    });

    // Capture the root navigator before any async gap so we can collapse
    // the verify route and present the login sheet on a still-mounted
    // ancestor context once the sign-out resolves.
    final NavigatorState rootNavigator = Navigator.of(context, rootNavigator: true);
    final BuildContext rootContext = rootNavigator.context;

    await AuthService.signOut();

    if (rootNavigator.mounted) {
      rootNavigator.popUntil((route) => route.isFirst);
    }

    // Switch the bottom-nav to the Search tab so the courses screen sits
    // behind the login sheet, matching the post-logout home that
    // ProfileScreen lands on.
    activeTabIndexNotifier.value = TAB_INDEX_SEARCH;

    if (rootContext.mounted) {
      LoginBottomSheet.show(rootContext);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: STARFIELD_BACKGROUND_COLOR,
      body: Stack(
        children: [
          const Positioned.fill(child: RLStarfieldBackground()),

          SafeArea(child: VerifyScaffold()),
        ],
      ),
    );
  }

  // Stacks the centered verify content with the top-left logout chrome so
  // the user always has an escape hatch off the gate without disturbing
  // the centered hero copy + CTA cluster underneath.
  Widget VerifyScaffold() {
    return Stack(
      children: [
        Center(child: VerifyContent()),

        Align(alignment: Alignment.topLeft, child: LogoutButton()),
      ],
    );
  }

  // Header copy spacing mirrors LoginSheet.HeaderSection: headingLarge
  // title, RLDS.spacing4 to a textSecondary bodyMedium subtitle, both
  // centered. The CTA cluster below echoes LoginSheet.ActionRow's
  // top:RLDS.spacing20 / bottom:RLDS.spacing8 rhythm so the resend link
  // sits the same visual distance below the primary button as login's
  // secondary links sit below their CTA.
  Widget VerifyContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: RLDS.spacing24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RLTypography.headingLarge(
            RLUIStrings.VERIFY_EMAIL_TITLE,
            textAlign: TextAlign.center,
          ),

          const Spacing.height(RLDS.spacing4),

          RLTypography.bodyMedium(
            RLUIStrings.VERIFY_EMAIL_DESCRIPTION,
            color: RLDS.textSecondary,
            textAlign: TextAlign.center,
          ),

          const Spacing.height(RLDS.spacing20),

          VerifyButton(),

          const Spacing.height(RLDS.spacing8),

          ResendLink(),
        ],
      ),
    );
  }

  // Top-left logout chrome. Icon + bodyMedium label, textSecondary so the
  // escape hatch reads as a quiet utility rather than a peer to the
  // primary "I have verified" CTA. Disabled while the sign-out is in
  // flight so a double-tap doesn't queue two pops.
  Widget LogoutButton() {
    final Color labelColor = RLDS.textSecondary;
    final Widget LogoutIcon = Icon(Pixel.logout, color: labelColor, size: RLDS.iconMedium);
    final VoidCallback? logoutTap = isLoggingOut ? null : handleLogoutTap;

    return Div.row(
      [
        LogoutIcon,

        const Spacing.width(RLDS.spacing8),

        RLTypography.bodyMedium(RLUIStrings.MENU_LOG_OUT, color: labelColor),
      ],
      padding: const EdgeInsets.symmetric(
        horizontal: RLDS.spacing16,
        vertical: RLDS.spacing12,
      ),
      onTap: logoutTap,
    );
  }

  Widget VerifyButton() {
    final String buttonLabel = isCheckingVerification
        ? RLUIStrings.VERIFY_EMAIL_CHECKING_LABEL
        : RLUIStrings.VERIFY_EMAIL_CONFIRM_LABEL;

    final VoidCallback? buttonTap = isCheckingVerification ? null : handleVerifyTap;

    return RLLunarBlur(
      borderRadius: RLDS.borderRadiusSmall,
      borderColor: RLDS.transparent,
      child: Div.row(
        [RLTypography.bodyLarge(buttonLabel, color: RLDS.primary)],
        width: double.infinity,
        // Transparent fill so the gesture detector receives taps across
        // the whole button, not only on the centered label glyphs.
        color: RLDS.transparent,
        padding: const EdgeInsets.symmetric(
          vertical: RLDS.spacing16,
          horizontal: RLDS.spacing24,
        ),
        mainAxisAlignment: MainAxisAlignment.center,
        onTap: buttonTap,
      ),
    );
  }

  Widget ResendLink() {
    final String linkLabel = isResending
        ? RLUIStrings.VERIFY_EMAIL_RESENDING_LABEL
        : RLUIStrings.VERIFY_EMAIL_RESEND_LABEL;

    final VoidCallback? linkTap = isResending ? null : handleResendTap;

    return GestureDetector(
      onTap: linkTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: RLDS.spacing12),
        child: RLTypography.bodyMedium(
          linkLabel,
          color: RLDS.textSecondary,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
