// Reader Pass subscription screen
// Displays subscription benefits and pricing

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/constants/DartAliases.dart';
import 'package:readlock/design_system/RLCard.dart';

import 'package:pixelarticons/pixel.dart';
class ReaderPassScreen extends StatefulWidget {
  const ReaderPassScreen({super.key});

  @override
  State<ReaderPassScreen> createState() => ReaderPassScreenState();
}

class ReaderPassScreenState extends State<ReaderPassScreen> {
  static final Widget BackArrowIcon = const Icon(Pixel.arrowleft, color: RLDS.textPrimary, size: 24);

  void handleBackButton() {
    Navigator.of(context).pop();
  }

  void handleSubscribe() {
    // Subscription logic will go here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RLDS.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Div.column([
            // Header with back button
            HeaderSection(),

            // Main content with padding
            Padding(
              padding: const EdgeInsets.all(24),
              child: Div.column([
                // Title and subtitle
                TitleSection(),

                const Spacing.height(32),

                // Discount badge
                DiscountBadge(),

                const Spacing.height(24),

                // Pricing section
                PricingSection(),

                const Spacing.height(32),

                // Benefits list
                BenefitsSection(),

                const Spacing.height(32),

                // Subscribe button
                SubscribeButton(),

                const Spacing.height(24),
              ], crossAxisAlignment: CrossAxisAlignment.stretch),
            ),
          ], crossAxisAlignment: CrossAxisAlignment.stretch),
        ),
      ),
    );
  }

  Widget HeaderSection() {
    final BorderRadius backButtonRadius = BorderRadius.circular(36);

    return Div.row(
      [
        Div.row([BackArrowIcon], padding: 8, radius: backButtonRadius, onTap: handleBackButton),
      ],
      padding: 20,
    );
  }

  Widget TitleSection() {
    return Div.column([
      RLTypography.headingLarge(RLUIStrings.READER_PASS_TITLE, textAlign: TextAlign.center),

      const Spacing.height(8),

      RLTypography.bodyLarge(
        RLUIStrings.READER_PASS_SUBTITLE,
        color: RLDS.textSecondary,
        textAlign: TextAlign.center,
      ),
    ], crossAxisAlignment: CrossAxisAlignment.center);
  }

  Widget DiscountBadge() {
    final BoxDecoration badgeDecoration = BoxDecoration(
      color: RLDS.success,
      borderRadius: BorderRadius.circular(8),
    );

    return Center(
      child: Div.column(
        [RLTypography.headingMedium(RLUIStrings.DISCOUNT_TEXT, color: RLDS.white)],
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: badgeDecoration,
      ),
    );
  }

  Widget PricingSection() {
    final BoxDecoration pricingCardDecoration = BoxDecoration(
      color: RLDS.backgroundLight.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: RLDS.success.withValues(alpha: 0.3)),
    );

    return Div.column(
      [
        // Original price (strikethrough)
        RLTypography.bodyLarge(
          RLUIStrings.ORIGINAL_PRICE,
          color: RLDS.textSecondary,
          textAlign: TextAlign.center,
        ),

        const Spacing.height(8),

        // Discounted price
        Div.row([
          RLTypography.headingLarge(RLUIStrings.DISCOUNTED_PRICE, color: RLDS.success),

          RLTypography.bodyLarge(RLUIStrings.PRICE_PERIOD, color: RLDS.textSecondary),
        ], mainAxisAlignment: MainAxisAlignment.center),
      ],
      crossAxisAlignment: CrossAxisAlignment.center,
      padding: 24,
      decoration: pricingCardDecoration,
    );
  }

  Widget BenefitsSection() {
    final JSONList benefits = [
      {
        'icon': Pixel.bookopen,
        'title': 'Unlimited Books',
        'description': 'Access to our entire library',
      },
      {
        'icon': Pixel.zap,
        'title': 'Offline Reading',
        'description': 'Download and read anywhere',
      },
      {
        'icon': Pixel.human,
        'title': 'Interactive Lessons',
        'description': 'Quizzes and reflections',
      },
      {
        'icon': Pixel.moonstars,
        'title': 'Premium Features',
        'description': 'All features unlocked',
      },
    ];

    return Div.column([
      RLTypography.headingMedium(RLUIStrings.READER_PASS_FEATURES_TITLE),

      const Spacing.height(16),

      Div.column(BenefitCards(benefits), crossAxisAlignment: CrossAxisAlignment.start),
    ], crossAxisAlignment: CrossAxisAlignment.start);
  }

  Widget BenefitCard(JSONMap benefit) {
    final IconData benefitIconData = benefit['icon'] as IconData? ?? Pixel.check;
    final String benefitTitle = benefit['title'] as String? ?? '';
    final String benefitDescription = benefit['description'] as String? ?? '';

    final Widget BenefitIcon = Icon(benefitIconData, color: RLDS.success, size: 24);

    final BoxDecoration iconDecoration = BoxDecoration(
      color: RLDS.success.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
    );

    return RLCard.subtle(
      borderColor: RLDS.success.withValues(alpha: 0.2),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      child: Div.row([
        Div.column(
          [BenefitIcon],
          padding: 8,
          decoration: iconDecoration,
        ),

        const Spacing.width(16),

        Expanded(
          child: Div.column([
            RLTypography.bodyLarge(benefitTitle),

            const Spacing.height(4),

            RLTypography.bodyMedium(benefitDescription, color: RLDS.textSecondary),
          ], crossAxisAlignment: CrossAxisAlignment.start),
        ),
      ]),
    );
  }

  List<Widget> BenefitCards(JSONList benefits) {
    final List<Widget> cards = [];

    for (final JSONMap benefit in benefits) {
      cards.add(BenefitCard(benefit));
    }

    return cards;
  }

  Widget SubscribeButton() {
    final BoxDecoration buttonDecoration = BoxDecoration(
      color: RLDS.success,
      borderRadius: BorderRadius.circular(12),
    );

    return Div.column(
      [
        RLTypography.headingMedium(
          RLUIStrings.SUBSCRIBE_BUTTON_TEXT,
          color: RLDS.white,
          textAlign: TextAlign.center,
        ),
      ],
      width: 'full',
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: buttonDecoration,
      onTap: handleSubscribe,
    );
  }
}
