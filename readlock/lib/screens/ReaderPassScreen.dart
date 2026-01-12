// Reader Pass subscription screen
// Displays subscription benefits and pricing

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLTheme.dart';

const String READER_PASS_TITLE = 'Reader Pass';
const String READER_PASS_SUBTITLE = 'Unlock unlimited learning';
const String DISCOUNT_TEXT = '25% OFF';
const String ORIGINAL_PRICE = '\$39.99';
const String DISCOUNTED_PRICE = '\$29.99';
const String PRICE_PERIOD = '/month';
const String SUBSCRIBE_BUTTON_TEXT = 'Get Reader Pass';

class ReaderPassScreen extends StatefulWidget {
  const ReaderPassScreen({super.key});

  @override
  State<ReaderPassScreen> createState() => ReaderPassScreenState();
}

class ReaderPassScreenState extends State<ReaderPassScreen> {
  void handleBackButton() {
    Navigator.of(context).pop();
  }

  void handleSubscribe() {
    // Subscription logic will go here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RLTheme.backgroundDark,
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
    final Widget BackArrowIcon = const Icon(
      Icons.arrow_back,
      color: RLTheme.textPrimary,
      size: 24,
    );

    final BorderRadius backButtonRadius = BorderRadius.circular(36);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Div.row([
        Div.row(
          [BackArrowIcon],
          padding: 8,
          radius: backButtonRadius,
          onTap: handleBackButton,
        ),
      ]),
    );
  }

  Widget TitleSection() {
    return Div.column([
      RLTypography.headingLarge(
        READER_PASS_TITLE,
        textAlign: TextAlign.center,
      ),

      const Spacing.height(8),

      RLTypography.bodyLarge(
        READER_PASS_SUBTITLE,
        color: RLTheme.textSecondary,
        textAlign: TextAlign.center,
      ),
    ], crossAxisAlignment: CrossAxisAlignment.center);
  }

  Widget DiscountBadge() {
    final BoxDecoration badgeDecoration = BoxDecoration(
      color: RLTheme.primaryGreen,
      borderRadius: BorderRadius.circular(8),
    );

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: badgeDecoration,
        child: RLTypography.headingMedium(
          DISCOUNT_TEXT,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget PricingSection() {
    final BoxDecoration pricingCardDecoration = BoxDecoration(
      color: RLTheme.backgroundLight.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: RLTheme.primaryGreen.withValues(alpha: 0.3),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: pricingCardDecoration,
      child: Div.column([
        // Original price (strikethrough)
        RLTypography.bodyLarge(
          ORIGINAL_PRICE,
          color: RLTheme.textSecondary,
          textAlign: TextAlign.center,
        ),

        const Spacing.height(8),

        // Discounted price
        Div.row([
          RLTypography.headingLarge(
            DISCOUNTED_PRICE,
            color: RLTheme.primaryGreen,
          ),

          RLTypography.bodyLarge(
            PRICE_PERIOD,
            color: RLTheme.textSecondary,
          ),
        ], mainAxisAlignment: MainAxisAlignment.center),
      ], crossAxisAlignment: CrossAxisAlignment.center),
    );
  }

  Widget BenefitsSection() {
    final List<Map<String, dynamic>> benefits = [
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
      RLTypography.headingMedium('What you get'),

      const Spacing.height(16),

      Div.column(
        BenefitCards(benefits),
        crossAxisAlignment: CrossAxisAlignment.start,
      ),
    ], crossAxisAlignment: CrossAxisAlignment.start);
  }

  List<Widget> BenefitCards(List<Map<String, dynamic>> benefits) {
    return benefits.map((benefit) {
      final IconData benefitIcon = benefit['icon'] ?? Icons.check;
      final String benefitTitle = benefit['title'] ?? '';
      final String benefitDescription = benefit['description'] ?? '';

      final BoxDecoration cardDecoration = BoxDecoration(
        color: RLTheme.backgroundLight.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: RLTheme.primaryGreen.withValues(alpha: 0.2),
        ),
      );

      final BoxDecoration iconDecoration = BoxDecoration(
        color: RLTheme.primaryGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      );

      final Widget BenefitIcon = Icon(
        benefitIcon,
        color: RLTheme.primaryGreen,
        size: 24,
      );

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: cardDecoration,
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

              RLTypography.bodyMedium(
                benefitDescription,
                color: RLTheme.textSecondary,
              ),
            ], crossAxisAlignment: CrossAxisAlignment.start),
          ),
        ]),
      );
    }).toList();
  }

  Widget SubscribeButton() {
    final BoxDecoration buttonDecoration = BoxDecoration(
      color: RLTheme.primaryGreen,
      borderRadius: BorderRadius.circular(12),
    );

    return GestureDetector(
      onTap: handleSubscribe,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: buttonDecoration,
        child: RLTypography.headingMedium(
          SUBSCRIBE_BUTTON_TEXT,
          color: Colors.white,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
