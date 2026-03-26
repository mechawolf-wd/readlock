// Reader Pass subscription screen
// Displays subscription benefits and pricing

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/constants/DartAliases.dart';
import 'package:readlock/utility_widgets/RLCard.dart';

class ReaderPassScreen extends StatefulWidget {
  const ReaderPassScreen({super.key});

  @override
  State<ReaderPassScreen> createState() => ReaderPassScreenState();
}

class ReaderPassScreenState extends State<ReaderPassScreen> {
  static final Widget BackArrowIcon = Icon(Icons.arrow_back, color: RLDS.textPrimary, size: 24);

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

    return Container(
      padding: const EdgeInsets.all(20),
      child: Div.row([
        Div.row([BackArrowIcon], padding: 8, radius: backButtonRadius, onTap: handleBackButton),
      ]),
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
      color: RLDS.primaryGreen,
      borderRadius: BorderRadius.circular(8),
    );

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: badgeDecoration,
        child: RLTypography.headingMedium(RLUIStrings.DISCOUNT_TEXT, color: RLDS.white),
      ),
    );
  }

  Widget PricingSection() {
    final BoxDecoration pricingCardDecoration = BoxDecoration(
      color: RLDS.backgroundLight.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: RLDS.primaryGreen.withValues(alpha: 0.3)),
    );

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: pricingCardDecoration,
      child: Div.column([
        // Original price (strikethrough)
        RLTypography.bodyLarge(
          RLUIStrings.ORIGINAL_PRICE,
          color: RLDS.textSecondary,
          textAlign: TextAlign.center,
        ),

        const Spacing.height(8),

        // Discounted price
        Div.row([
          RLTypography.headingLarge(RLUIStrings.DISCOUNTED_PRICE, color: RLDS.primaryGreen),

          RLTypography.bodyLarge(RLUIStrings.PRICE_PERIOD, color: RLDS.textSecondary),
        ], mainAxisAlignment: MainAxisAlignment.center),
      ], crossAxisAlignment: CrossAxisAlignment.center),
    );
  }

  Widget BenefitsSection() {
    final JSONList benefits = [
      {
        'icon': Icons.menu_book,
        'title': 'Unlimited Books',
        'description': 'Access to our entire library',
      },
      {
        'icon': Icons.offline_bolt,
        'title': 'Offline Reading',
        'description': 'Download and read anywhere',
      },
      {
        'icon': Icons.psychology,
        'title': 'Interactive Lessons',
        'description': 'Skill checks and reflections',
      },
      {
        'icon': Icons.stars,
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

  List<Widget> BenefitCards(JSONList benefits) {
    return benefits.map((benefit) {
      final IconData benefitIcon = benefit['icon'] ?? Icons.check;
      final String benefitTitle = benefit['title'] ?? '';
      final String benefitDescription = benefit['description'] ?? '';

      final BoxDecoration iconDecoration = BoxDecoration(
        color: RLDS.primaryGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      );

      final Widget BenefitIcon = Icon(benefitIcon, color: RLDS.primaryGreen, size: 24);

      return RLCard.subtle(
        borderColor: RLDS.primaryGreen.withValues(alpha: 0.2),
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        child: Div.row([
          Container(
            padding: const EdgeInsets.all(8),
            decoration: iconDecoration,
            child: BenefitIcon,
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
    }).toList();
  }

  Widget SubscribeButton() {
    final BoxDecoration buttonDecoration = BoxDecoration(
      color: RLDS.primaryGreen,
      borderRadius: BorderRadius.circular(12),
    );

    return GestureDetector(
      onTap: handleSubscribe,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: buttonDecoration,
        child: RLTypography.headingMedium(
          RLUIStrings.SUBSCRIBE_BUTTON_TEXT,
          color: RLDS.white,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
