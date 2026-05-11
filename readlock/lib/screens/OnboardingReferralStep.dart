// Referral code entry step, the final step of onboarding.
// The reader can enter a code they received from a friend or skip
// past it by tapping the forward chevron without entering anything.
// Submission calls the redeemReferralCode Cloud Function and shows
// the result via RLToast.

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/design_system/RLTextField.dart';
import 'package:readlock/design_system/RLToast.dart';
import 'package:readlock/services/purchases/PurchaseConstants.dart';
import 'package:readlock/services/purchases/PurchaseNotifiers.dart';
import 'package:readlock/services/referral/ReferralService.dart';

class OnboardingReferralStep extends StatefulWidget {
  const OnboardingReferralStep({super.key});

  @override
  State<OnboardingReferralStep> createState() => OnboardingReferralStepState();
}

class OnboardingReferralStepState extends State<OnboardingReferralStep> {
  final TextEditingController codeController = TextEditingController();
  bool isSubmitting = false;
  bool hasRedeemed = false;

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  Future<void> handleSubmitTap() async {
    final String rawCode = codeController.text.trim().toUpperCase();
    final bool codeIsEmpty = rawCode.isEmpty;

    if (codeIsEmpty) {
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
      // Optimistic balance bump so the reader sees the feathers immediately.
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
      padding: const EdgeInsets.symmetric(horizontal: RLDS.spacing24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Input field
          RLTextField(
            controller: codeController,
            hintText: RLUIStrings.REFERRAL_ONBOARDING_PLACEHOLDER,
          ),

          // Apply button
          SubmitButton(),
        ],
      ),
    );
  }

  Widget SubmitButton() {
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

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: buttonTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: RLDS.spacing16),
        child: Center(
          child: RLTypography.bodyLarge(buttonLabel, color: labelColor),
        ),
      ),
    );
  }
}
