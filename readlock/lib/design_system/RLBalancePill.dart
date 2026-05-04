// Live feather-balance pill — plume sprite + count, subscribes to
// userBalanceNotifier so a top-up from any surface reflects here without
// a refetch. Tap opens FeathersBottomSheet so the indicator doubles as
// the affordance for topping up. Shared by every header that surfaces
// the wallet (bookshelf, search) so the wallet feel is consistent and a
// future restyle only edits this file.
//
// Always rendered — even at a zero balance — so the top-up affordance is
// always visible. Callers control surrounding spacing themselves.

import 'package:flutter/material.dart';
import 'package:readlock/services/feedback/HapticsService.dart';
import 'package:readlock/bottom_sheets/user/FeathersBottomSheet.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/design_system/RLFeatherIcon.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/services/purchases/PurchaseNotifiers.dart';

class RLBalancePill extends StatelessWidget {
  const RLBalancePill({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: userBalanceNotifier,
      builder: BalanceRow,
    );
  }

  Widget BalanceRow(BuildContext context, int balance, Widget? unusedChild) {
    void onBalanceTap() {
      HapticsService.lightImpact();
      FeathersBottomSheet.show(context);
    }

    return GestureDetector(
      onTap: onBalanceTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const RLFeatherIcon(size: RLDS.iconLarge),

          const Spacing.width(RLDS.spacing4),

          RLTypography.bodyLarge('$balance', color: RLDS.primary),
        ],
      ),
    );
  }
}
