// Redeem code bottom sheet. The reader enters a referral code they
// received from a friend, and if valid, gets feathers credited.
// Self-referral is caught locally (against the user's own codes fetched
// on mount) before hitting the backend.

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/bottom_sheets/RLBottomSheet.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/design_system/RLTextField.dart';
import 'package:readlock/design_system/RLToast.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/models/ReferralModel.dart';
import 'package:readlock/services/purchases/PurchaseConstants.dart';
import 'package:readlock/services/purchases/PurchaseNotifiers.dart';
import 'package:readlock/services/referral/ReferralService.dart';

class RedeemCodeBottomSheet {
  static void show(BuildContext context) {
    RLBottomSheet.show(
      context,
      backgroundColor: RLDS.surface,
      showGrabber: false,
      child: const RedeemCodeSheet(),
    );
  }
}

class RedeemCodeSheet extends StatefulWidget {
  const RedeemCodeSheet({super.key});

  @override
  State<RedeemCodeSheet> createState() => RedeemCodeSheetState();
}

class RedeemCodeSheetState extends State<RedeemCodeSheet> {
  final TextEditingController codeController = TextEditingController();
  List<ReferralModel> ownCodes = [];
  bool isSubmitting = false;
  bool hasRedeemed = false;

  @override
  void initState() {
    super.initState();
    fetchOwnCodes();
  }

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  Future<void> fetchOwnCodes() async {
    final List<ReferralModel> fetchedCodes = await ReferralService.fetchMyCodes();

    if (!mounted) {
      return;
    }

    setState(() {
      ownCodes = fetchedCodes;
    });
  }

  Future<void> handleSubmitTap() async {
    final String rawCode = codeController.text.trim().toUpperCase();
    final bool codeIsEmpty = rawCode.isEmpty;

    if (codeIsEmpty) {
      return;
    }

    // Check locally first: if the code matches one of the user's own
    // codes, skip the network call entirely.
    final bool isOwnCode = ownCodes.any(
      (ReferralModel code) => code.code == rawCode,
    );

    if (isOwnCode) {
      RLToast.error(context, RLUIStrings.REFERRAL_CODE_OWN);
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    final ReferralRedeemResult result = await ReferralService.redeemCode(rawCode);

    if (!mounted) {
      return;
    }

    setState(() {
      isSubmitting = false;
    });

    if (result == ReferralRedeemResult.success) {
      userBalanceNotifier.value =
          userBalanceNotifier.value + PurchaseConstants.REFERRAL_REDEEMER_REWARD;

      setState(() {
        hasRedeemed = true;
      });

      RLToast.success(context, RLUIStrings.REFERRAL_ONBOARDING_SUCCESS);
      return;
    }

    if (result == ReferralRedeemResult.notFound) {
      RLToast.error(context, RLUIStrings.REFERRAL_CODE_INVALID);
      return;
    }

    if (result == ReferralRedeemResult.selfReferral) {
      RLToast.error(context, RLUIStrings.REFERRAL_CODE_OWN);
      return;
    }

    RLToast.error(context, RLUIStrings.ERROR_UNKNOWN);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: RL_BOTTOM_SHEET_NO_GRABBER_CONTENT_PADDING.copyWith(bottom: 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          RLTypography.headingLarge(
            RLUIStrings.REFERRAL_ONBOARDING_TITLE,
            textAlign: TextAlign.center,
          ),

          const Spacing.height(RLDS.sheetSubheadingToContentSpacing),

          // Input or success label
          RedeemBody(),
        ],
      ),
    );
  }

  Widget RedeemBody() {
    if (hasRedeemed) {
      return RLTypography.bodyMedium(
        RLUIStrings.REFERRAL_ONBOARDING_SUCCESS,
        color: RLDS.success,
        textAlign: TextAlign.center,
      );
    }

    final String buttonLabel = isSubmitting
        ? RLUIStrings.REFERRAL_ONBOARDING_SUBMITTING_LABEL
        : RLUIStrings.REFERRAL_ONBOARDING_SUBMIT_LABEL;

    final VoidCallback? buttonTap = isSubmitting ? null : handleSubmitTap;
    final Color labelColor = isSubmitting ? RLDS.textMuted : RLDS.markupGreen;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RLTextField(
          controller: codeController,
          hintText: RLUIStrings.REFERRAL_ONBOARDING_PLACEHOLDER,
        ),

        const Spacing.height(RLDS.spacing24),

        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: buttonTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: RLDS.spacing16),
            child: Center(
              child: RLTypography.bodyLarge(buttonLabel, color: labelColor),
            ),
          ),
        ),
      ],
    );
  }
}
