// Referral code management sheet. Shows the user's existing codes
// (up to 3) with their used/available status, a share button per
// available code, and a generate-new-code action when the lifetime
// limit has not yet been reached.

import 'package:flutter/material.dart' hide Typography;
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pixelarticons/pixel.dart';
import 'package:readlock/bottom_sheets/RLBottomSheet.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/design_system/RLFeatherIcon.dart';
import 'package:readlock/design_system/RLLoadingIndicator.dart';
import 'package:readlock/design_system/RLToast.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/models/ReferralModel.dart';
import 'package:readlock/services/feedback/HapticsService.dart';
import 'package:readlock/services/feedback/SoundService.dart';
import 'package:readlock/services/purchases/PurchaseConstants.dart';
import 'package:readlock/services/referral/ReferralService.dart';

const EdgeInsets REFERRAL_CONTENT_PADDING = EdgeInsets.symmetric(horizontal: RLDS.spacing24);

class ReferralBottomSheet {
  static void show(BuildContext context) {
    RLBottomSheet.show(context, backgroundColor: RLDS.surface, child: const ReferralSheet());
  }
}

class ReferralSheet extends StatefulWidget {
  const ReferralSheet({super.key});

  @override
  State<ReferralSheet> createState() => ReferralSheetState();
}

class ReferralSheetState extends State<ReferralSheet> {
  List<ReferralModel> codes = [];
  bool isLoadingCodes = true;
  bool isGeneratingCode = false;

  @override
  void initState() {
    super.initState();
    fetchCodes();
  }

  Future<void> fetchCodes() async {
    final List<ReferralModel> fetchedCodes = await ReferralService.fetchMyCodes();

    if (!mounted) {
      return;
    }

    setState(() {
      codes = fetchedCodes;
      isLoadingCodes = false;
    });
  }

  Future<void> handleGenerateCodeTap() async {
    HapticsService.lightImpact();
    SoundService.playRandomTextClick();

    setState(() {
      isGeneratingCode = true;
    });

    final String? newCode = await ReferralService.generateCode();

    if (!mounted) {
      return;
    }

    setState(() {
      isGeneratingCode = false;
    });

    if (newCode == null) {
      RLToast.error(context, RLUIStrings.ERROR_UNKNOWN);
      return;
    }

    fetchCodes();
  }

  void handleShareTap(String code) {
    HapticsService.lightImpact();

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    Rect shareOrigin = Rect.zero;

    final bool hasRenderBox = renderBox != null;

    if (hasRenderBox) {
      shareOrigin = renderBox.localToGlobal(Offset.zero) & renderBox.size;
    }

    Share.share(code, sharePositionOrigin: shareOrigin);
  }

  void handleCopyTap(String code) {
    HapticsService.lightImpact();
    Clipboard.setData(ClipboardData(text: code));
    RLToast.success(context, RLUIStrings.REFERRAL_CODE_COPIED);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: REFERRAL_CONTENT_PADDING,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          TitleSection(),

          const Spacing.height(RLDS.spacing24),

          // Code list or loading state
          SheetBody(),

          const Spacing.height(RLDS.spacing24),
        ],
      ),
    );
  }

  Widget TitleSection() {
    final TextStyle subtitleStyle = RLTypography.bodyLargeStyle.copyWith(
      color: RLDS.textSecondary,
    );

    const Widget PlumeInline = RLFeatherIcon(size: RLDS.iconSmall);

    return Column(
      children: [
        RLTypography.headingLarge(RLUIStrings.REFERRAL_TITLE, textAlign: TextAlign.center),

        const Spacing.height(RLDS.spacing8),

        // Subtitle with inline plume icons replacing the word "feathers".
        Text.rich(
          TextSpan(
            style: subtitleStyle,
            children: [
              const TextSpan(text: RLUIStrings.REFERRAL_SUBTITLE_THEY_GET),

              const WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: PlumeInline,
              ),

              const TextSpan(text: RLUIStrings.REFERRAL_SUBTITLE_YOU_GET),

              const WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: PlumeInline,
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget SheetBody() {
    if (isLoadingCodes) {
      return const Center(child: RLLoadingIndicator.text());
    }

    final bool hasReachedLimit = codes.length >= PurchaseConstants.MAX_REFERRAL_CODES;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Existing codes
        CodeList(),

        const Spacing.height(RLDS.spacing16),

        // Generate button or limit label
        RenderIf.condition(!hasReachedLimit, GenerateButton(), LimitReachedLabel()),
      ],
    );
  }

  Widget CodeList() {
    final bool hasNoCodes = codes.isEmpty;

    if (hasNoCodes) {
      return const SizedBox.shrink();
    }

    final List<Widget> codeRows = [];

    for (int codeIndex = 0; codeIndex < codes.length; codeIndex++) {
      final ReferralModel code = codes[codeIndex];

      codeRows.add(CodeRow(model: code));

      final bool isNotLastRow = codeIndex < codes.length - 1;

      if (isNotLastRow) {
        codeRows.add(const Spacing.height(RLDS.spacing12));
      }
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: codeRows);
  }

  // Icon widgets extracted above the build tree per rule @17.
  static const Widget ShareIcon = Icon(
    Pixel.externallink,
    color: RLDS.textPrimary,
    size: RLDS.iconMedium,
  );

  static const Widget CopyIcon = Icon(
    Pixel.clipboard,
    color: RLDS.textSecondary,
    size: RLDS.iconMedium,
  );

  Widget CodeRow({required ReferralModel model}) {
    final bool isUsed = model.isRedeemed;
    final Color codeColor = isUsed ? RLDS.textMuted : RLDS.textPrimary;

    final String statusLabel = isUsed
        ? RLUIStrings.REFERRAL_CODE_USED_LABEL
        : RLUIStrings.REFERRAL_CODE_AVAILABLE_LABEL;

    final Color statusColor = isUsed ? RLDS.textMuted : RLDS.textSecondary;

    return Row(
      children: [
        // Code text + status
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RLTypography.bodyLarge(model.code, color: codeColor),

              RLTypography.bodySmall(statusLabel, color: statusColor),
            ],
          ),
        ),

        // Action icons (only for available codes)
        RenderIf.condition(
          !isUsed,
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => handleShareTap(model.code),
                behavior: HitTestBehavior.opaque,
                child: Padding(padding: const EdgeInsets.all(RLDS.spacing8), child: ShareIcon),
              ),

              GestureDetector(
                onTap: () => handleCopyTap(model.code),
                behavior: HitTestBehavior.opaque,
                child: Padding(padding: const EdgeInsets.all(RLDS.spacing8), child: CopyIcon),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget GenerateButton() {
    final String buttonLabel = isGeneratingCode
        ? RLUIStrings.REFERRAL_GENERATING_LABEL
        : RLUIStrings.REFERRAL_GENERATE_LABEL;

    final VoidCallback? buttonTap = isGeneratingCode ? null : handleGenerateCodeTap;
    final Color labelColor = isGeneratingCode ? RLDS.textMuted : RLDS.markupGreen;

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

  Widget LimitReachedLabel() {
    return RLTypography.bodyMedium(
      RLUIStrings.REFERRAL_CODE_LIMIT_REACHED,
      color: RLDS.textMuted,
      textAlign: TextAlign.center,
    );
  }

}
