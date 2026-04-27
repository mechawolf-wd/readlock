// Feathers subscription bottom sheet — feather-based monthly subscription
// with two plan tiers (Beginner / Reader). Plans are presented in a
// horizontal slider so the reader swipes through them one at a time;
// tapping a card is the purchase action — there is no separate CTA
// button, the card itself is the affordance.
//
// No icons in the plan cards on purpose — the numbers (feathers, books,
// price) carry the meaning, the user's profile bird sits below the copy
// as a small companion accent.

import 'package:flutter/material.dart' hide Typography;
import 'package:flutter/services.dart';
import 'package:readlock/bottom_sheets/RLBottomSheet.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/design_system/RLLunarBlur.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/screens/profile/BirdPicker.dart';

// Horizontal inset for every content row inside the sheet. Matches the
// no-grabber sheet constant so the Feathers sheet breathes the same as
// Account / Support at the left/right edges.
const EdgeInsets FEATHERS_CONTENT_PADDING = EdgeInsets.symmetric(horizontal: RLDS.spacing24);

// * Plan slider tuning — horizontal PageView. Each card takes most of the
// viewport but leaves a small peek of the next card on either side so the
// horizontal-swipe affordance is obvious. Card height is sized to fit the
// content (heading, price, feathers, books, bird) with no trailing slack.
const double PLAN_SLIDER_HEIGHT = 320.0;
const double PLAN_CARD_VIEWPORT_FRACTION = 0.78;
const double PLAN_CARD_BIRD_PREVIEW_SIZE = 88.0;

// Plan data model — two tiers shown in the slider. Each plan ships with a
// fixed companion bird (the small sprite at the base of the card) so the
// tier reads as visually distinct at a glance, independent of whatever the
// user has set in the bird picker.
class FeatherPlan {
  final String name;
  final String price;
  final String feathers;
  final String books;
  final BirdOption bird;

  const FeatherPlan({
    required this.name,
    required this.price,
    required this.feathers,
    required this.books,
    required this.bird,
  });
}

// Resolves a BirdOption out of the shared BIRD_OPTIONS catalogue by name so
// the plan list reuses the canonical sprite metadata (frame size, count,
// asset path) instead of re-declaring it.
BirdOption lookupBirdByName(String birdName) {
  return BIRD_OPTIONS.firstWhere((BirdOption bird) => bird.name == birdName);
}

final List<FeatherPlan> FEATHER_PLANS = [
  FeatherPlan(
    name: RLUIStrings.PLAN_BEGINNER_NAME,
    price: RLUIStrings.PLAN_BEGINNER_PRICE,
    feathers: RLUIStrings.PLAN_BEGINNER_FEATHERS,
    books: RLUIStrings.PLAN_BEGINNER_BOOKS,
    bird: lookupBirdByName(RLUIStrings.BIRD_SPARROW),
  ),

  FeatherPlan(
    name: RLUIStrings.PLAN_READER_NAME,
    price: RLUIStrings.PLAN_READER_PRICE,
    feathers: RLUIStrings.PLAN_READER_FEATHERS,
    books: RLUIStrings.PLAN_READER_BOOKS,
    bird: lookupBirdByName(RLUIStrings.BIRD_TOUCAN),
  ),
];

const int DEFAULT_PLAN_INDEX = 0; // Beginner — the default tier on open.

class FeathersBottomSheet {
  static void show(BuildContext context) {
    RLBottomSheet.show(
      context,
      backgroundColor: RLDS.backgroundDark,
      child: const FeathersSheet(),
    );
  }
}

class FeathersSheet extends StatefulWidget {
  const FeathersSheet({super.key});

  @override
  State<FeathersSheet> createState() => FeathersSheetState();
}

class FeathersSheetState extends State<FeathersSheet> {
  late PageController planController;
  int selectedPlanIndex = DEFAULT_PLAN_INDEX;

  @override
  void initState() {
    super.initState();

    planController = PageController(
      initialPage: selectedPlanIndex,
      viewportFraction: PLAN_CARD_VIEWPORT_FRACTION,
    );
  }

  @override
  void dispose() {
    planController.dispose();
    super.dispose();
  }

  void handlePlanChanged(int index) {
    // Tick haptic per page change — same selectionClick the bird carousel
    // uses, so swiping between Beginner and Reader feels detented.
    HapticFeedback.selectionClick();

    setState(() {
      selectedPlanIndex = index;
    });
  }

  // Mock payment trigger — fired when the user taps a plan card. Real
  // purchase flow will replace this body; the surface contract (tap a
  // card = start checkout for that tier) stays the same.
  void handlePlanPurchase(int planIndex) {
    final FeatherPlan purchasedPlan = FEATHER_PLANS[planIndex];

    debugPrint('Mock purchase: ${purchasedPlan.name} (${purchasedPlan.price})');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: FEATHERS_CONTENT_PADDING,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [TitleSection(), const Spacing.height(RLDS.spacing24)],
          ),
        ),

        // Horizontal slider of plan cards. Sits flush to screen edges so the
        // peeking neighbours read past the page padding. Tapping a card is
        // the purchase action — no separate CTA button.
        PlanSlider(),

        Padding(
          padding: FEATHERS_CONTENT_PADDING,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacing.height(RLDS.spacing16),

              BookPricingNote(),

              const Spacing.height(RLDS.spacing24),
            ],
          ),
        ),
      ],
    );
  }

  Widget TitleSection() {
    return Column(
      children: [
        RLTypography.headingLarge(RLUIStrings.FEATHERS_TITLE, textAlign: TextAlign.center),

        const Spacing.height(RLDS.spacing8),

        RLTypography.bodyLarge(
          RLUIStrings.FEATHERS_SUBTITLE,
          color: RLDS.textSecondary,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget PlanSlider() {
    return SizedBox(
      height: PLAN_SLIDER_HEIGHT,
      child: PageView.builder(
        controller: planController,
        itemCount: FEATHER_PLANS.length,
        onPageChanged: handlePlanChanged,
        itemBuilder: PlanCardForIndex,
      ),
    );
  }

  Widget PlanCardForIndex(BuildContext context, int planIndex) {
    final FeatherPlan plan = FEATHER_PLANS[planIndex];
    final bool isSelected = planIndex == selectedPlanIndex;

    void onCardTap() => handlePlanPurchase(planIndex);

    return PlanCard(plan: plan, isSelected: isSelected, onTap: onCardTap);
  }

  Widget BookPricingNote() {
    return RLTypography.bodyMedium(
      RLUIStrings.FEATHERS_BOOK_PRICING_NOTE,
      color: RLDS.textSecondary,
      textAlign: TextAlign.center,
    );
  }
}

// Single plan card — frosted LunarBlur pane that fills its PageView slot.
// The selected (centred) card paints at full opacity; off-centre cards
// fade to the secondary alpha so the eye lands on the active tier without
// hiding the others. Surface colour and tint come from RLLunarBlur's
// defaults so every floating pane in the app stays in lock-step.
class PlanCard extends StatelessWidget {
  final FeatherPlan plan;
  final bool isSelected;
  final VoidCallback onTap;

  const PlanCard({
    super.key,
    required this.plan,
    required this.isSelected,
    required this.onTap,
  });

  // Symmetric horizontal inset, tighter bottom — the bird sprite already
  // brings its own visual weight at the base of the card so a full
  // spacing24 below would read as dead space.
  static const EdgeInsets cardPadding = EdgeInsets.fromLTRB(
    RLDS.spacing24,
    RLDS.spacing24,
    RLDS.spacing24,
    RLDS.spacing12,
  );
  // Horizontal gap between adjacent plan cards in the swipe; vertical inset
  // gives a small breathing room within the slider's fixed height.
  static const EdgeInsets cardOuterPadding = EdgeInsets.symmetric(
    horizontal: RLDS.spacing8,
    vertical: RLDS.spacing4,
  );

  @override
  Widget build(BuildContext context) {
    final double cardOpacity = isSelected ? 1.0 : 0.45;

    return Padding(
      padding: cardOuterPadding,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: cardOpacity,
          child: RLLunarBlur(
            borderRadius: RLDS.borderRadiusMedium,
            padding: cardPadding,
            child: PlanCardBody(plan: plan),
          ),
        ),
      ),
    );
  }
}

class PlanCardBody extends StatelessWidget {
  final FeatherPlan plan;

  const PlanCardBody({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Plan name — the marketing handle (Reader / Insider).
        RLTypography.headingMedium(plan.name, textAlign: TextAlign.center),

        const Spacing.height(RLDS.spacing16),

        // Price + period in a single row, centred.
        PriceRow(price: plan.price),

        const Spacing.height(RLDS.spacing20),

        // Feather allotment — the primary spend currency for the plan.
        RLTypography.bodyLarge(plan.feathers, textAlign: TextAlign.center),

        const Spacing.height(RLDS.spacing4),

        // Estimated books per month — an approximate, easier-to-grasp
        // reframing of the token count.
        RLTypography.bodyMedium(
          plan.books,
          color: RLDS.textSecondary,
          textAlign: TextAlign.center,
        ),

        const Spacing.height(RLDS.spacing12),

        // Plan companion bird — fixed per tier (Blue Macaw / Toucan), so
        // the card reads as visually distinct independent of the user's
        // own bird-picker choice.
        PlanBird(bird: plan.bird),
      ],
    );
  }
}

class PlanBird extends StatelessWidget {
  final BirdOption bird;

  const PlanBird({super.key, required this.bird});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: BirdAnimationSprite(bird: bird, previewSize: PLAN_CARD_BIRD_PREVIEW_SIZE),
    );
  }
}

class PriceRow extends StatelessWidget {
  final String price;

  const PriceRow({super.key, required this.price});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        RLTypography.headingLarge(price, color: RLDS.primary),

        RLTypography.bodyLarge(RLUIStrings.PRICE_PERIOD, color: RLDS.textSecondary),
      ],
    );
  }
}
