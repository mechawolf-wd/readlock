// Bottom sheet for account settings and management. Rendered as a LunarBlur
// surface without a grabber — content padding is the shared
// RL_BOTTOM_SHEET_NO_GRABBER_CONTENT_PADDING from RLBottomSheet, so the
// layout rhythm matches Support / Font picker / any other no-grabber sheet.

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/bottom_sheets/RLBottomSheet.dart';
import 'package:readlock/bottom_sheets/user/LoginBottomSheet.dart';
import 'package:readlock/design_system/RLConfirmationDialog.dart';
import 'package:readlock/design_system/RLToast.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/services/auth/AuthService.dart';
import 'package:readlock/services/feedback/SoundService.dart';

import 'package:pixelarticons/pixel.dart';

class AccountBottomSheet {
  static void show(BuildContext context) {
    RLBottomSheet.show(
      context,
      backgroundColor: RLDS.surface,
      showGrabber: false,
      child: const AccountSheet(),
    );
  }
}

class AccountSheet extends StatelessWidget {
  const AccountSheet({super.key});

  static final Widget HeaderIcon = const Icon(
    Pixel.user,
    color: RLDS.info,
    size: RLDS.iconMedium,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: RL_BOTTOM_SHEET_NO_GRABBER_CONTENT_PADDING,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HeaderRow(),

          const Spacing.height(RLDS.spacing16),

          AccountActionRow(
            label: RLUIStrings.ACCOUNT_DELETE_LABEL,
            onTap: () => handleDeleteAccountTap(context),
          ),
        ],
      ),
    );
  }

  Widget HeaderRow() {
    return Div.row([
      HeaderIcon,

      const Spacing.width(RLDS.spacing12),

      RLTypography.headingMedium(RLUIStrings.ACCOUNT_TITLE),
    ], mainAxisAlignment: MainAxisAlignment.start);
  }

  // * Delete account flow.
  //
  // Two checkpoints stand between the tap and the irreversible cloud-function
  // call so an accidental tap (or a borrowed device) cannot take the account
  // out:
  //   1. Reauthentication via the login sheet, configured with a delete
  //      header and the sign-up + dev-skip rows hidden.
  //   2. A destructive confirmation dialog that asks one last time before
  //      we hand off to AuthService.deleteAccount.
  //
  // Everything routes through the root navigator so the follow-up dialog
  // pushes onto a still-mounted ancestor once the login sheet pops itself.

  void handleDeleteAccountTap(BuildContext context) {
    SoundService.playLogout();

    final LoginSheetConfig reauthConfig = LoginSheetConfig(
      title: RLUIStrings.ACCOUNT_DELETE_LABEL,
      subtitle: RLUIStrings.ACCOUNT_DELETE_REAUTH_SUBTITLE,
      allowSignUp: false,
      allowSupport: false,
      showDevSkip: false,
      isReauthMode: true,
      onAuthenticated: presentFinalDeleteConfirmation,
    );

    LoginBottomSheet.show(context, config: reauthConfig);
  }

  void presentFinalDeleteConfirmation(BuildContext context) {
    RLConfirmationDialog.show(
      context,
      title: RLUIStrings.ACCOUNT_DELETE_LABEL,
      message: RLUIStrings.ACCOUNT_DELETE_MESSAGE,
      cta: RLConfirmationAction(
        label: RLUIStrings.ACCOUNT_DELETE_CONFIRM,
        variant: RLConfirmationVariant.destructive,
        onTap: () => runAccountDeletion(context),
      ),
      cancel: const RLConfirmationAction(
        label: RLUIStrings.CANCEL_LABEL,
        variant: RLConfirmationVariant.neutral,
      ),
    );
  }

  Future<void> runAccountDeletion(BuildContext context) async {
    // Capture the root navigator before the async gap so we can present
    // the login sheet on a still-mounted ancestor context after the modal
    // stack collapses.
    final NavigatorState rootNavigator = Navigator.of(context, rootNavigator: true);
    final BuildContext rootContext = rootNavigator.context;

    try {
      await AuthService.deleteAccount();

      // AuthService.deleteAccount signs the user out as its final step.
      // The app no longer auto-presents the login sheet on sign-out, so we
      // pop the modal stack and explicitly mount the login sheet on the
      // root navigator — otherwise the reader would be stranded on Home
      // with no obvious way to sign back in.
      if (!context.mounted) {
        return;
      }

      Navigator.of(context).popUntil((route) => route.isFirst);

      LoginBottomSheet.show(rootContext);
    } on Exception catch (error) {
      // The error here is the localized RLUIStrings.ERROR_ACCOUNT_DELETION_FAILED
      // copy that AuthService rethrows; surface it via toast so the user
      // knows the action did not go through.
      if (!context.mounted) {
        return;
      }

      final String errorMessage = error.toString().replaceFirst('Exception: ', '');

      RLToast.error(context, errorMessage);
    }
  }
}

// Same row shape as LoginSupportPicker's PickerRow — bodyLarge label +
// chevron, vertical spacing12 padding.
class AccountActionRow extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const AccountActionRow({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final Widget ChevronIcon = Icon(
      Pixel.chevronright,
      color: RLDS.glass50(RLDS.textSecondary),
      size: RLDS.iconMedium,
    );

    return Div.row(
      [Expanded(child: RLTypography.bodyLarge(label)), ChevronIcon],
      padding: const EdgeInsets.symmetric(vertical: RLDS.spacing12),
      onTap: onTap,
    );
  }
}
