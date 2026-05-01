// Login support flow — four coordinated bottom sheets:
//
//   1. LoginSupportPicker              — entry point, lists three options
//   2. ResetPasswordSupportSheet       — email input + red "Send reset link"
//   3. ResendVerificationSupportSheet  — single red "Resend verification" button
//   4. EmailSupportSheet               — address display + red "Copy email"
//
// Each action sheet is self-contained (its own state, its own inputs, its
// own status line). The picker closes itself before pushing the selected
// action so the stack stays flat.

import 'package:flutter/material.dart' hide Typography;
import 'package:flutter/services.dart';
import 'package:pixelarticons/pixel.dart';
import 'package:readlock/bottom_sheets/RLBottomSheet.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/design_system/RLButton.dart';
import 'package:readlock/design_system/RLTextField.dart';
import 'package:readlock/design_system/RLToast.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/services/auth/AuthService.dart';
import 'package:readlock/services/feedback/SoundService.dart';

// * Shared layout constants across all four sheets. The outer sheet padding
// routes through RLBottomSheet's shared no-grabber constant, so every
// sheet without a grabber (Support, Account, etc.) breathes the same.

class LoginSupportLayout {
  static const EdgeInsets SUPPORT_SHEET_PADDING = RL_BOTTOM_SHEET_NO_GRABBER_CONTENT_PADDING;

  static const EdgeInsets SUPPORT_BUTTON_PADDING = EdgeInsets.symmetric(
    vertical: RLDS.spacing16,
    horizontal: RLDS.spacing16,
  );
}

// * Picker ------------------------------------------------------------------

class LoginSupportPicker {
  static void show(BuildContext context, {String? prefillEmail}) {
    RLBottomSheet.show(
      context,
      backgroundColor: RLDS.surface,
      showGrabber: false,
      child: LoginSupportPickerContent(prefillEmail: prefillEmail),
    );
  }
}

class LoginSupportPickerContent extends StatefulWidget {
  final String? prefillEmail;

  const LoginSupportPickerContent({super.key, this.prefillEmail});

  @override
  State<LoginSupportPickerContent> createState() => LoginSupportPickerContentState();
}

class LoginSupportPickerContentState extends State<LoginSupportPickerContent> {
  static final Widget HeaderIcon = const Icon(
    Pixel.message,
    color: RLDS.info,
    size: RLDS.iconMedium,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: LoginSupportLayout.SUPPORT_SHEET_PADDING,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HeaderRow(),

          const Spacing.height(RLDS.spacing16),

          PickerRow(
            icon: Pixel.reload,
            label: RLUIStrings.SUPPORT_RESET_PASSWORD_LABEL,
            onTap: handleResetPasswordTap,
          ),

          PickerRow(
            icon: Pixel.mail,
            label: RLUIStrings.SUPPORT_RESEND_VERIFICATION_LABEL,
            onTap: handleResendVerificationTap,
          ),

          PickerRow(
            icon: Pixel.message,
            label: RLUIStrings.SUPPORT_EMAIL_LABEL,
            onTap: handleEmailSupportTap,
          ),
        ],
      ),
    );
  }

  Widget HeaderRow() {
    return Div.row([
      HeaderIcon,

      const Spacing.width(RLDS.spacing12),

      RLTypography.headingMedium(RLUIStrings.SUPPORT_OPTIONS_TITLE),
    ], mainAxisAlignment: MainAxisAlignment.start);
  }

  Widget PickerRow({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final Widget TrailingIcon = Icon(
      icon,
      color: RLDS.glass50(RLDS.textSecondary),
      size: RLDS.iconMedium,
    );

    void onPickerRowTap() {
      SoundService.playRandomTextClick();
      onTap();
    }

    return Div.row(
      [Expanded(child: RLTypography.bodyLarge(label)), TrailingIcon],
      padding: const EdgeInsets.symmetric(vertical: RLDS.spacing12),
      onTap: onPickerRowTap,
    );
  }

  // Close the picker first so the action sheet ends up on top of the login
  // sheet, not on top of the picker. We pre-capture the root navigator so the
  // action-sheet `show` call gets a still-valid context after the pop.

  void handleResetPasswordTap() {
    final NavigatorState rootNavigator = Navigator.of(context, rootNavigator: true);

    Navigator.of(context).pop();

    ResetPasswordSupportSheet.show(rootNavigator.context, prefillEmail: widget.prefillEmail);
  }

  void handleResendVerificationTap() {
    final NavigatorState rootNavigator = Navigator.of(context, rootNavigator: true);

    Navigator.of(context).pop();

    ResendVerificationSupportSheet.show(
      rootNavigator.context,
      prefillEmail: widget.prefillEmail,
    );
  }

  void handleEmailSupportTap() {
    final NavigatorState rootNavigator = Navigator.of(context, rootNavigator: true);

    Navigator.of(context).pop();

    EmailSupportSheet.show(rootNavigator.context);
  }
}

// * Reset password ----------------------------------------------------------

class ResetPasswordSupportSheet {
  static void show(BuildContext context, {String? prefillEmail}) {
    RLBottomSheet.show(
      context,
      backgroundColor: RLDS.backgroundLight,
      showGrabber: false,
      child: ResetPasswordSupportContent(prefillEmail: prefillEmail),
    );
  }
}

class ResetPasswordSupportContent extends StatefulWidget {
  final String? prefillEmail;

  const ResetPasswordSupportContent({super.key, this.prefillEmail});

  @override
  State<ResetPasswordSupportContent> createState() => ResetPasswordSupportContentState();
}

class ResetPasswordSupportContentState extends State<ResetPasswordSupportContent> {
  final TextEditingController emailController = TextEditingController();
  final FocusNode emailFocusNode = FocusNode();

  bool isBusy = false;

  @override
  void initState() {
    super.initState();

    final String? prefill = widget.prefillEmail;
    final bool hasPrefill = prefill != null && prefill.isNotEmpty;

    if (hasPrefill) {
      emailController.text = prefill;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    emailFocusNode.dispose();
    super.dispose();
  }

  VoidCallback? getSubmitHandler() {
    if (isBusy) {
      return null;
    }

    return handleSendResetLink;
  }

  Future<void> handleSendResetLink() async {
    final String email = emailController.text.trim();
    final bool hasNoEmail = email.isEmpty;

    if (hasNoEmail) {
      RLToast.error(context, RLUIStrings.RESET_PASSWORD_EMAIL_REQUIRED);
      return;
    }

    setState(() {
      isBusy = true;
    });

    final String? error = await AuthService.sendPasswordResetEmail(email: email);

    if (!mounted) {
      return;
    }

    setState(() {
      isBusy = false;
    });

    final bool hasError = error != null;

    if (hasError) {
      RLToast.error(context, error);
      return;
    }

    RLToast.success(context, RLUIStrings.RESET_PASSWORD_SENT_MESSAGE);
  }

  String getButtonLabel() {
    if (isBusy) {
      return RLUIStrings.SUPPORT_SEND_RESET_LINK_LOADING_LABEL;
    }

    return RLUIStrings.SUPPORT_SEND_RESET_LINK_LABEL;
  }

  @override
  Widget build(BuildContext context) {
    final VoidCallback? submitHandler = getSubmitHandler();
    final String buttonLabel = getButtonLabel();

    return Padding(
      padding: LoginSupportLayout.SUPPORT_SHEET_PADDING,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SheetHeader(
            title: RLUIStrings.SUPPORT_RESET_PASSWORD_LABEL,
            description: RLUIStrings.SUPPORT_RESET_PASSWORD_DESCRIPTION,
          ),

          const Spacing.height(RLDS.spacing16),

          RLTextField.email(controller: emailController, focusNode: emailFocusNode),

          const Spacing.height(RLDS.spacing24),

          RLButton.primary(
            label: buttonLabel,
            color: RLDS.primary,
            padding: LoginSupportLayout.SUPPORT_BUTTON_PADDING,
            onTap: submitHandler,
          ),
        ],
      ),
    );
  }
}

// * Resend verification -----------------------------------------------------

class ResendVerificationSupportSheet {
  static void show(BuildContext context, {String? prefillEmail}) {
    RLBottomSheet.show(
      context,
      backgroundColor: RLDS.backgroundLight,
      showGrabber: false,
      child: ResendVerificationSupportContent(prefillEmail: prefillEmail),
    );
  }
}

class ResendVerificationSupportContent extends StatefulWidget {
  final String? prefillEmail;

  const ResendVerificationSupportContent({super.key, this.prefillEmail});

  @override
  State<ResendVerificationSupportContent> createState() =>
      ResendVerificationSupportContentState();
}

class ResendVerificationSupportContentState extends State<ResendVerificationSupportContent> {
  final TextEditingController emailController = TextEditingController();
  final FocusNode emailFocusNode = FocusNode();

  bool isBusy = false;

  @override
  void initState() {
    super.initState();

    final String? prefill = resolveInitialEmail();
    final bool hasPrefill = prefill != null && prefill.isNotEmpty;

    if (hasPrefill) {
      emailController.text = prefill;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    emailFocusNode.dispose();
    super.dispose();
  }

  // Prefer the signed-in user's email when available — that's where the
  // verification mail actually goes. Fall back to whatever was typed on the
  // login form so the field is never blank for users arriving mid-flow.
  String? resolveInitialEmail() {
    final String? currentEmail = AuthService.currentUserEmail;
    final bool hasCurrentEmail = currentEmail != null && currentEmail.isNotEmpty;

    if (hasCurrentEmail) {
      return currentEmail;
    }

    return widget.prefillEmail;
  }

  VoidCallback? getSubmitHandler() {
    if (isBusy) {
      return null;
    }

    return handleResendVerification;
  }

  Future<void> handleResendVerification() async {
    final String email = emailController.text.trim();
    final bool hasNoEmail = email.isEmpty;

    if (hasNoEmail) {
      RLToast.warning(context, RLUIStrings.RESET_PASSWORD_EMAIL_REQUIRED);
      return;
    }

    // The Firebase client SDK can only resend verification to the currently
    // signed-in user — there is no "resend by email" endpoint. If we hit
    // this sheet while signed out, calling sendEmailVerification just fails
    // silently, so we surface the requirement explicitly instead.
    final bool isSignedOut = !AuthService.isSignedIn;

    if (isSignedOut) {
      RLToast.warning(context, RLUIStrings.RESEND_VERIFICATION_REQUIRES_SIGN_IN);
      return;
    }

    setState(() {
      isBusy = true;
    });

    final bool isAlreadyVerified = await AuthService.isEmailVerified();

    if (!mounted) {
      return;
    }

    if (isAlreadyVerified) {
      setState(() {
        isBusy = false;
      });

      RLToast.info(context, RLUIStrings.RESEND_VERIFICATION_ALREADY_VERIFIED);
      return;
    }

    final bool wasSent = await AuthService.sendEmailVerification();

    if (!mounted) {
      return;
    }

    setState(() {
      isBusy = false;
    });

    if (wasSent) {
      RLToast.success(context, RLUIStrings.VERIFICATION_EMAIL_SENT);
      return;
    }

    RLToast.error(context, RLUIStrings.RESEND_VERIFICATION_FAILED);
  }

  String getButtonLabel() {
    if (isBusy) {
      return RLUIStrings.SUPPORT_RESEND_VERIFICATION_LOADING_LABEL;
    }

    return RLUIStrings.SUPPORT_RESEND_VERIFICATION_BUTTON_LABEL;
  }

  @override
  Widget build(BuildContext context) {
    final VoidCallback? submitHandler = getSubmitHandler();
    final String buttonLabel = getButtonLabel();

    return Padding(
      padding: LoginSupportLayout.SUPPORT_SHEET_PADDING,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SheetHeader(
            title: RLUIStrings.SUPPORT_RESEND_VERIFICATION_LABEL,
            description: RLUIStrings.SUPPORT_RESEND_VERIFICATION_DESCRIPTION,
          ),

          const Spacing.height(RLDS.spacing16),

          RLTextField.email(controller: emailController, focusNode: emailFocusNode),

          const Spacing.height(RLDS.spacing24),

          RLButton.primary(
            label: buttonLabel,
            color: RLDS.primary,
            padding: LoginSupportLayout.SUPPORT_BUTTON_PADDING,
            onTap: submitHandler,
          ),
        ],
      ),
    );
  }
}

// * Email support -----------------------------------------------------------

class EmailSupportSheet {
  static void show(BuildContext context) {
    RLBottomSheet.show(
      context,
      backgroundColor: RLDS.backgroundLight,
      showGrabber: false,
      child: const EmailSupportContent(),
    );
  }
}

class EmailSupportContent extends StatefulWidget {
  const EmailSupportContent({super.key});

  @override
  State<EmailSupportContent> createState() => EmailSupportContentState();
}

class EmailSupportContentState extends State<EmailSupportContent> {
  bool isBusy = false;

  static final Widget HeaderIcon = const Icon(
    Pixel.message,
    color: RLDS.primary,
    size: RLDS.iconMedium,
  );

  VoidCallback? getSubmitHandler() {
    if (isBusy) {
      return null;
    }

    return handleCopyEmail;
  }

  Future<void> handleCopyEmail() async {
    setState(() {
      isBusy = true;
    });

    await Clipboard.setData(const ClipboardData(text: RLUIStrings.SUPPORT_EMAIL_ADDRESS));

    if (!mounted) {
      return;
    }

    setState(() {
      isBusy = false;
    });

    RLToast.success(context, RLUIStrings.SUPPORT_EMAIL_COPIED_MESSAGE);
  }

  @override
  Widget build(BuildContext context) {
    final VoidCallback? submitHandler = getSubmitHandler();

    return Padding(
      padding: LoginSupportLayout.SUPPORT_SHEET_PADDING,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SheetHeader(
            icon: HeaderIcon,
            title: RLUIStrings.SUPPORT_EMAIL_LABEL,
            description: RLUIStrings.SUPPORT_EMAIL_DESCRIPTION,
          ),

          const Spacing.height(RLDS.spacing16),

          RLTypography.bodyLarge(
            RLUIStrings.SUPPORT_EMAIL_ADDRESS,
            color: RLDS.textPrimary,
            textAlign: TextAlign.center,
          ),

          const Spacing.height(RLDS.spacing24),

          RLButton.primary(
            label: RLUIStrings.SUPPORT_COPY_EMAIL_BUTTON_LABEL,
            color: RLDS.primary,
            padding: LoginSupportLayout.SUPPORT_BUTTON_PADDING,
            onTap: submitHandler,
          ),
        ],
      ),
    );
  }
}

// * Shared atoms ------------------------------------------------------------

class SheetHeader extends StatelessWidget {
  final Widget? icon;
  final String title;
  final String description;

  const SheetHeader({super.key, this.icon, required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TitleRow(),

        const Spacing.height(RLDS.spacing16),

        RLTypography.bodyMedium(description, color: RLDS.textSecondary),
      ],
    );
  }

  // Render the heading alone when no icon is supplied, otherwise prepend the
  // icon with its spacer so the title column stays visually aligned.
  Widget TitleRow() {
    final Widget? iconWidget = icon;
    final bool hasIcon = iconWidget != null;

    if (!hasIcon) {
      return RLTypography.headingMedium(title);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        iconWidget,

        const Spacing.width(RLDS.spacing12),

        RLTypography.headingMedium(title),
      ],
    );
  }
}
