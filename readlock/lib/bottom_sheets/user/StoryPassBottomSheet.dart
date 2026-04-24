// Story Pass subscription bottom sheet — pricing, benefits, and the
// Subscribe CTA. Uses the standard grabber sheet (content is tall enough
// to warrant the drag affordance) and the shared footer-button margin so
// the CTA's bottom gap matches every other primary-CTA sheet.

import 'package:flutter/material.dart' hide Typography;
import 'package:pixelarticons/pixel.dart';
import 'package:readlock/bottom_sheets/RLBottomSheet.dart';
import 'package:readlock/constants/DartAliases.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/design_system/RLButton.dart';
import 'package:readlock/design_system/RLCard.dart';
import 'package:readlock/design_system/RLUtility.dart';

// Horizontal inset for every content row inside the sheet. Matches the
// no-grabber sheet constant so the Story Pass breathes the same as
// Account / Support at the left/right edges.
const EdgeInsets STORY_PASS_CONTENT_PADDING = EdgeInsets.symmetric(
  horizontal: RLDS.spacing24,
);

class StoryPassBottomSheet {
  static void show(BuildContext context) {
    RLBottomSheet.show(
      context,
      backgroundColor: RLDS.backgroundDark,
      child: const StoryPassSheet(),
    );
  }
}

class StoryPassSheet extends StatelessWidget {
  const StoryPassSheet({super.key});

  void handleSubscribe() {
    // Subscription logic will go here.
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Scrollable body — caps at ~65% of screen height so the sheet never
        // exceeds the comfortable drag range on small devices.
        Flexible(
          child: SingleChildScrollView(
            padding: STORY_PASS_CONTENT_PADDING,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                TitleSection(),

                const Spacing.height(RLDS.spacing24),

                // Discount badge
                DiscountBadge(),

                const Spacing.height(RLDS.spacing20),

                // Pricing
                PricingSection(),

                const Spacing.height(RLDS.spacing24),

                // Benefits
                const BenefitsSection(),

                const Spacing.height(RLDS.spacing24),
              ],
            ),
          ),
        ),

        // Footer CTA — shared margin so the bottom gap lines up with every
        // other primary-CTA sheet.
        RLButton.primary(
          label: RLUIStrings.SUBSCRIBE_BUTTON_TEXT,
          color: RLDS.success,
          margin: RL_BOTTOM_SHEET_FOOTER_BUTTON_MARGIN,
          onTap: handleSubscribe,
        ),
      ],
    );
  }

  Widget TitleSection() {
    return Column(
      children: [
        RLTypography.headingLarge(
          RLUIStrings.STORY_PASS_TITLE,
          textAlign: TextAlign.center,
        ),

        const Spacing.height(RLDS.spacing8),

        RLTypography.bodyLarge(
          RLUIStrings.STORY_PASS_SUBTITLE,
          color: RLDS.textSecondary,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget DiscountBadge() {
    final BoxDecoration badgeDecoration = BoxDecoration(
      color: RLDS.success,
      borderRadius: RLDS.borderRadiusXSmall,
    );

    return Center(
      child: Div.column(
        [RLTypography.headingMedium(RLUIStrings.DISCOUNT_TEXT, color: RLDS.white)],
        padding: const EdgeInsets.symmetric(
          horizontal: RLDS.spacing16,
          vertical: RLDS.spacing8,
        ),
        decoration: badgeDecoration,
      ),
    );
  }

  Widget PricingSection() {
    final BoxDecoration pricingCardDecoration = BoxDecoration(
      color: RLDS.backgroundLight.withValues(alpha: 0.08),
      borderRadius: RLDS.borderRadiusMedium,
      border: Border.all(color: RLDS.success.withValues(alpha: 0.3)),
    );

    return Div.column(
      [
        RLTypography.bodyLarge(
          RLUIStrings.ORIGINAL_PRICE,
          color: RLDS.textSecondary,
          textAlign: TextAlign.center,
        ),

        const Spacing.height(RLDS.spacing8),

        Div.row(
          [
            RLTypography.headingLarge(RLUIStrings.DISCOUNTED_PRICE, color: RLDS.success),

            RLTypography.bodyLarge(RLUIStrings.PRICE_PERIOD, color: RLDS.textSecondary),
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ],
      crossAxisAlignment: CrossAxisAlignment.center,
      padding: RLDS.spacing24,
      decoration: pricingCardDecoration,
    );
  }
}

class BenefitsSection extends StatelessWidget {
  const BenefitsSection({super.key});

  static const JSONList BENEFITS = [
    {
      'icon': Pixel.bookopen,
      'title': RLUIStrings.STORY_PASS_BENEFIT_BOOKS_TITLE,
      'description': RLUIStrings.STORY_PASS_BENEFIT_BOOKS_DESCRIPTION,
    },
    {
      'icon': Pixel.zap,
      'title': RLUIStrings.STORY_PASS_BENEFIT_OFFLINE_TITLE,
      'description': RLUIStrings.STORY_PASS_BENEFIT_OFFLINE_DESCRIPTION,
    },
    {
      'icon': Pixel.human,
      'title': RLUIStrings.STORY_PASS_BENEFIT_LESSONS_TITLE,
      'description': RLUIStrings.STORY_PASS_BENEFIT_LESSONS_DESCRIPTION,
    },
    {
      'icon': Pixel.moonstars,
      'title': RLUIStrings.STORY_PASS_BENEFIT_PREMIUM_TITLE,
      'description': RLUIStrings.STORY_PASS_BENEFIT_PREMIUM_DESCRIPTION,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RLTypography.headingMedium(RLUIStrings.STORY_PASS_FEATURES_TITLE),

        const Spacing.height(RLDS.spacing16),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: BenefitCards(),
        ),
      ],
    );
  }

  List<Widget> BenefitCards() {
    final List<Widget> cards = [];

    for (final JSONMap benefit in BENEFITS) {
      cards.add(BenefitCard(benefit: benefit));
    }

    return cards;
  }
}

class BenefitCard extends StatelessWidget {
  final JSONMap benefit;

  const BenefitCard({super.key, required this.benefit});

  @override
  Widget build(BuildContext context) {
    final IconData benefitIconData = benefit['icon'] as IconData? ?? Pixel.check;
    final String benefitTitle = benefit['title'] as String? ?? '';
    final String benefitDescription = benefit['description'] as String? ?? '';

    final Widget BenefitIcon = Icon(benefitIconData, color: RLDS.success, size: 24);

    final BoxDecoration iconDecoration = BoxDecoration(
      color: RLDS.success.withValues(alpha: 0.1),
      borderRadius: RLDS.borderRadiusXSmall,
    );

    return RLCard.subtle(
      borderColor: RLDS.success.withValues(alpha: 0.2),
      padding: const EdgeInsets.all(RLDS.spacing16),
      margin: const EdgeInsets.only(bottom: RLDS.spacing12),
      child: Div.row([
        Div.column(
          [BenefitIcon],
          padding: RLDS.spacing8,
          decoration: iconDecoration,
        ),

        const Spacing.width(RLDS.spacing16),

        Expanded(
          child: Div.column(
            [
              RLTypography.bodyLarge(benefitTitle),

              const Spacing.height(RLDS.spacing4),

              RLTypography.bodyMedium(benefitDescription, color: RLDS.textSecondary),
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        ),
      ]),
    );
  }
}
