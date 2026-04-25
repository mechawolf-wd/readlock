// Story Pass subscription bottom sheet — feather-based monthly subscription
// with three plan tiers (Enough / Reader / Knowledge). Plans are presented
// in a horizontal slider so the reader swipes through them one at a time;
// the currently-centred plan is what Subscribe will charge for.
//
// No icons in the plan cards on purpose — the numbers (feathers, books,
// price) carry the meaning, an icon would just be decoration.

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/bottom_sheets/RLBottomSheet.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/design_system/RLButton.dart';
import 'package:readlock/design_system/RLLunarBlur.dart';
import 'package:readlock/design_system/RLUtility.dart';

// Horizontal inset for every content row inside the sheet. Matches the
// no-grabber sheet constant so the Story Pass breathes the same as
// Account / Support at the left/right edges.
const EdgeInsets STORY_PASS_CONTENT_PADDING = EdgeInsets.symmetric(
  horizontal: RLDS.spacing24,
);

// * Plan slider tuning — horizontal PageView. Each card takes most of the
// viewport but leaves a small peek of the next card on either side so the
// horizontal-swipe affordance is obvious. Card height is fixed so peeks
// are predictable across screen sizes.
const double PLAN_SLIDER_HEIGHT = 280.0;
const double PLAN_CARD_VIEWPORT_FRACTION = 0.78;

// Plan data model — three tiers shown in the slider.
class StoryPassPlan {
  final String name;
  final String price;
  final String feathers;
  final String books;

  const StoryPassPlan({
    required this.name,
    required this.price,
    required this.feathers,
    required this.books,
  });
}

const List<StoryPassPlan> STORY_PASS_PLANS = [
  StoryPassPlan(
    name: RLUIStrings.PLAN_ENOUGH_NAME,
    price: RLUIStrings.PLAN_ENOUGH_PRICE,
    feathers: RLUIStrings.PLAN_ENOUGH_FEATHERS,
    books: RLUIStrings.PLAN_ENOUGH_BOOKS,
  ),

  StoryPassPlan(
    name: RLUIStrings.PLAN_READER_NAME,
    price: RLUIStrings.PLAN_READER_PRICE,
    feathers: RLUIStrings.PLAN_READER_FEATHERS,
    books: RLUIStrings.PLAN_READER_BOOKS,
  ),

  StoryPassPlan(
    name: RLUIStrings.PLAN_KNOWLEDGE_NAME,
    price: RLUIStrings.PLAN_KNOWLEDGE_PRICE,
    feathers: RLUIStrings.PLAN_KNOWLEDGE_FEATHERS,
    books: RLUIStrings.PLAN_KNOWLEDGE_BOOKS,
  ),
];

const int DEFAULT_PLAN_INDEX = 1; // Reader — the middle tier reads as default.

class StoryPassBottomSheet {
  static void show(BuildContext context) {
    RLBottomSheet.show(
      context,
      backgroundColor: RLDS.backgroundDark,
      child: const StoryPassSheet(),
    );
  }
}

class StoryPassSheet extends StatefulWidget {
  const StoryPassSheet({super.key});

  @override
  State<StoryPassSheet> createState() => StoryPassSheetState();
}

class StoryPassSheetState extends State<StoryPassSheet> {
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
    setState(() {
      selectedPlanIndex = index;
    });
  }

  void handleSubscribe() {
    // Subscription logic will go here. Selected tier is `selectedPlanIndex`.
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: STORY_PASS_CONTENT_PADDING,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TitleSection(),

              const Spacing.height(RLDS.spacing24),
            ],
          ),
        ),

        // Horizontal slider of plan cards. Sits flush to screen edges so the
        // peeking neighbours read past the page padding.
        PlanSlider(),

        Padding(
          padding: STORY_PASS_CONTENT_PADDING,
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

  Widget PlanSlider() {
    return SizedBox(
      height: PLAN_SLIDER_HEIGHT,
      child: PageView.builder(
        controller: planController,
        itemCount: STORY_PASS_PLANS.length,
        onPageChanged: handlePlanChanged,
        itemBuilder: buildPlanCardForIndex,
      ),
    );
  }

  Widget buildPlanCardForIndex(BuildContext context, int planIndex) {
    final StoryPassPlan plan = STORY_PASS_PLANS[planIndex];
    final bool isSelected = planIndex == selectedPlanIndex;

    return PlanCard(plan: plan, isSelected: isSelected);
  }

  Widget BookPricingNote() {
    return RLTypography.bodyMedium(
      RLUIStrings.STORY_PASS_BOOK_PRICING_NOTE,
      color: RLDS.textSecondary,
      textAlign: TextAlign.center,
    );
  }
}

// Single plan card — frosted LunarBlur pane that fills its PageView slot.
// The selected (centred) card paints at full opacity; off-centre cards
// fade to the secondary alpha so the eye lands on the active tier without
// hiding the others. No icons by design.
class PlanCard extends StatelessWidget {
  final StoryPassPlan plan;
  final bool isSelected;

  const PlanCard({super.key, required this.plan, required this.isSelected});

  static const EdgeInsets cardPadding = EdgeInsets.all(RLDS.spacing24);
  // Horizontal gap between adjacent plan cards in the swipe; vertical inset
  // gives a small breathing room within the slider's fixed height.
  static const EdgeInsets cardOuterPadding = EdgeInsets.symmetric(
    horizontal: RLDS.spacing8,
    vertical: RLDS.spacing4,
  );

  @override
  Widget build(BuildContext context) {
    final double cardOpacity = isSelected ? 1.0 : 0.45;
    final Color borderColor = isSelected
        ? RLDS.success.withValues(alpha: 0.4)
        : RLDS.transparent;

    return Padding(
      padding: cardOuterPadding,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: cardOpacity,
        child: RLLunarBlur(
          borderRadius: RLDS.borderRadiusMedium,
          borderColor: borderColor,
          padding: cardPadding,
          child: PlanCardBody(plan: plan),
        ),
      ),
    );
  }
}

class PlanCardBody extends StatelessWidget {
  final StoryPassPlan plan;

  const PlanCardBody({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Plan name — the marketing handle (Enough / Reader / Knowledge).
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
      ],
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
        RLTypography.headingLarge(price, color: RLDS.success),

        RLTypography.bodyLarge(
          RLUIStrings.PRICE_PERIOD,
          color: RLDS.textSecondary,
        ),
      ],
    );
  }
}
