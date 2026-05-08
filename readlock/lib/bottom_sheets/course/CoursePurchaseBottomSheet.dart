// Course purchase prompt — opens from the cart icon on a Search/Bookshelf
// list card. Frosted circular book disc, title + author + description, and
// a feather-priced purchase button that mirrors CourseRoadmapScreen's
// PurchaseButton so the two surfaces read as the same family.

import 'package:flutter/material.dart';
import 'package:readlock/bottom_sheets/RLBottomSheet.dart';
import 'package:readlock/bottom_sheets/user/FeathersBottomSheet.dart';
import 'package:readlock/constants/RLCoursePalette.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/constants/DartAliases.dart';
import 'package:readlock/design_system/RLCourseBookImage.dart';
import 'package:readlock/design_system/RLFeatherIcon.dart';
import 'package:readlock/design_system/RLLunarBlur.dart';
import 'package:readlock/design_system/RLToast.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/services/feedback/HapticsService.dart';
import 'package:readlock/services/feedback/SoundService.dart';
import 'package:readlock/services/purchases/PurchaseConstants.dart';
import 'package:readlock/services/purchases/PurchaseService.dart';

// * Layout — circular book disc sized to feel like the focal point of the
// sheet without dominating it. 144 = 1.5x of the 96px book asset, leaving
// breathing room around the cover inside the frosted circle.
const double PURCHASE_SHEET_BOOK_DISC_SIZE = 144.0;
const double PURCHASE_SHEET_BOOK_SIZE = 96.0;

class CoursePurchaseBottomSheet {
  static Future<void> show(BuildContext context, {required JSONMap course}) {
    // Use RLBottomSheet.show with all defaults so the purchase sheet
    // wears the same frosted LunarBlur surface + backdrop blur + grabber
    // as the Settings sheet. Keeps every modal in the app reading as
    // one family of floating frosted panes.
    return RLBottomSheet.show(context, child: CoursePurchaseSheet(course: course));
  }
}

class CoursePurchaseSheet extends StatefulWidget {
  final JSONMap course;

  const CoursePurchaseSheet({super.key, required this.course});

  @override
  State<CoursePurchaseSheet> createState() => CoursePurchaseSheetState();
}

class CoursePurchaseSheetState extends State<CoursePurchaseSheet> {
  bool isPurchasing = false;

  String getCourseId() {
    return widget.course['course-id'] as String? ?? '';
  }

  String getCourseTitle() {
    return widget.course['title'] as String? ?? RLUIStrings.ROADMAP_DEFAULT_TITLE;
  }

  String getCourseAuthor() {
    return widget.course['author'] as String? ?? RLUIStrings.ROADMAP_DEFAULT_AUTHOR;
  }

  String getCourseDescription() {
    final String raw = widget.course['description'] as String? ?? '';

    return raw.trim();
  }

  String? getCourseColor() {
    return widget.course['color'] as String?;
  }

  String getNormalizedCourseColor() {
    final String? raw = getCourseColor();
    final bool hasNoColor = raw == null || raw.isEmpty;

    if (hasNoColor) {
      return '';
    }

    return raw.replaceAll('#', '').trim().toUpperCase();
  }

  Color getCourseAccentColor() {
    final String normalized = getNormalizedCourseColor();
    final bool isKnown = KNOWN_COURSE_COLORS.contains(normalized);

    final String effectiveHex = isKnown ? normalized : COURSE_FALLBACK_COLOR_HEX;
    final Color? parsed = RLDS.parseHexColor(effectiveHex);

    return parsed ?? RLDS.success;
  }

  @override
  Widget build(BuildContext context) {
    final String title = getCourseTitle();
    final String author = getCourseAuthor();
    final String description = getCourseDescription();
    final bool hasDescription = description.isNotEmpty;

    return Padding(
      padding: RL_BOTTOM_SHEET_NO_GRABBER_CONTENT_PADDING,
      child: Div.column([
        // Circular frosted disc hosting the book cover.
        Center(child: BookDisc()),

        const Spacing.height(RLDS.spacing24),

        // Title
        RLTypography.headingMedium(title, textAlign: TextAlign.center),

        const Spacing.height(RLDS.sheetHeadingToSubheadingSpacing),

        // Author
        RLTypography.bodyMedium(author, color: RLDS.textSecondary, textAlign: TextAlign.center),

        // Description (optional — hidden when the course doesn't supply one)
        RenderIf.condition(
          hasDescription,
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacing.height(RLDS.sheetSubheadingToContentSpacing),

              RLTypography.bodyMedium(
                description,
                color: RLDS.textMuted,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        const Spacing.height(RLDS.spacing32),

        PurchaseButton(),
      ], crossAxisAlignment: CrossAxisAlignment.stretch),
    );
  }

  // Circular LunarBlur disc — same surface family as the roadmap book ring,
  // sized to host the 96px book cover with breathing room.
  Widget BookDisc() {
    final BorderRadius discRadius = BorderRadius.circular(PURCHASE_SHEET_BOOK_DISC_SIZE / 2);

    final Widget bookCover = RLSkillBookImage(
      courseColor: getCourseColor(),
      size: PURCHASE_SHEET_BOOK_SIZE,
    );

    return SizedBox(
      width: PURCHASE_SHEET_BOOK_DISC_SIZE,
      height: PURCHASE_SHEET_BOOK_DISC_SIZE,
      child: RLLunarBlur(
        borderRadius: discRadius,
        borderColor: RLDS.transparent,
        child: Center(child: bookCover),
      ),
    );
  }

  // Mirrors CourseRoadmapScreen.PurchaseButton — frosted LunarBlur surface,
  // accent-coloured label, same price string built from PurchaseConstants.
  Widget PurchaseButton() {
    final Color accentColor = getCourseAccentColor();

    const EdgeInsets buttonPadding = EdgeInsets.symmetric(
      vertical: RLDS.spacing16,
      horizontal: RLDS.spacing24,
    );

    final List<Widget> labelChildren;

    if (isPurchasing) {
      labelChildren = [
        RLTypography.bodyLarge(RLUIStrings.ROADMAP_PURCHASE_LOADING_LABEL, color: accentColor),
      ];
    } else {
      // "Buy for 10 <plume>" — same shape as the roadmap purchase
      // button so both surfaces read as the same family.
      final String labelWithCost =
          '${RLUIStrings.ROADMAP_PURCHASE_LABEL} '
          '${PurchaseConstants.COURSE_PURCHASE_COST}';

      labelChildren = [
        RLTypography.bodyLarge(labelWithCost, color: accentColor),

        const Spacing.width(RLDS.spacing8),

        const RLFeatherIcon(size: RLDS.iconSmall),
      ];
    }

    void onButtonTap() {
      HapticsService.lightImpact();
      SoundService.playRandomTextClick();
      handlePurchaseTap();
    }

    final VoidCallback? buttonTap = isPurchasing ? null : onButtonTap;

    // Outer GestureDetector with HitTestBehavior.opaque so the entire
    // padded surface picks up taps. Without it the gap between the label
    // and the feather icon swallows hits, since the inner Div has no
    // background fill of its own.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: buttonTap,
      child: RLLunarBlur(
        borderRadius: RLDS.borderRadiusSmall,
        borderColor: RLDS.transparent,
        child: Div.row(
          labelChildren,
          width: double.infinity,
          padding: buttonPadding,
          mainAxisAlignment: MainAxisAlignment.center,
        ),
      ),
    );
  }

  Future<void> handlePurchaseTap() async {
    if (isPurchasing) {
      return;
    }

    // Capture the root navigator before the async gap so we can mount the
    // Feathers sheet on it after popping this one — the sheet's own
    // context is invalidated by the pop, but the root navigator's
    // context survives.
    final NavigatorState innerNavigator = Navigator.of(context);
    final NavigatorState rootNavigator = Navigator.of(context, rootNavigator: true);
    final BuildContext rootContext = rootNavigator.context;

    setState(() {
      isPurchasing = true;
    });

    final String courseId = getCourseId();
    final PurchaseResult result = await PurchaseService.purchaseCourse(courseId);

    if (!mounted) {
      return;
    }

    setState(() {
      isPurchasing = false;
    });

    if (result == PurchaseResult.success) {
      SoundService.playPurchase();
      Navigator.of(context).pop();
      RLToast.success(context, RLUIStrings.ROADMAP_PURCHASE_SUCCESS, playSound: false);
      return;
    }

    if (result == PurchaseResult.insufficientFeathers) {
      // Reader doesn't have enough feathers — close this purchase sheet
      // and surface the Feathers Plan sheet so they can top up directly
      // instead of bouncing through a toast and finding their own way to
      // the wallet. rootContext was captured before the await and points
      // to the root navigator widget, which outlives this sheet's pop.
      innerNavigator.pop();
      // ignore: use_build_context_synchronously
      FeathersBottomSheet.show(rootContext);
      return;
    }

    if (result == PurchaseResult.alreadyOwned) {
      Navigator.of(context).pop();
      return;
    }

    RLToast.error(context, RLUIStrings.ERROR_UNKNOWN);
  }
}
