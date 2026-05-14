// Shared continue / advance affordance for every CC swipe that ends in a
// "tap to move on" moment (text content, questions, reflect, pause, lesson
// finish). Single source of truth for the calm full-width text button:
//   - no background, just an accent-coloured label centred in a tap area
//   - wrapped in RLReveal so it fades in on the same timing as every other
//     reveal in the app
//   - default tap navigates the host CourseContentViewer's PageController
//     to the next page; callers that need a different action (the lesson
//     finish screen) pass their own onTap to override.

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/course_screens/CourseAccentScope.dart';
import 'package:readlock/course_screens/CourseContentViewer.dart';
import 'package:readlock/design_system/RLReveal.dart';
import 'package:readlock/services/feedback/HapticsService.dart';

const EdgeInsets CC_CONTINUE_BUTTON_PADDING = EdgeInsets.symmetric(
  vertical: RLDS.spacing16,
  horizontal: RLDS.spacing24,
);

const Duration CC_CONTINUE_PAGE_TRANSITION_DURATION = Duration(milliseconds: 300);
const Curve CC_CONTINUE_PAGE_TRANSITION_CURVE = Curves.easeInOut;

class CCContinueButton extends StatelessWidget {
  // Drives the fade-in. When false the button is invisible AND ignores
  // pointer events (handled by RLReveal) so a still-blurred state doesn't
  // accidentally swallow taps.
  final bool visible;

  // Custom tap handler that overrides the default "advance to next page"
  // behaviour. Passed by surfaces like LessonFinishScreen where the tap
  // also needs to commit elapsed time and pop the route.
  final VoidCallback? onTap;

  // Label override. Defaults to the shared continue copy so every swipe
  // speaks with the same word.
  final String? label;

  const CCContinueButton({super.key, this.visible = true, this.onTap, this.label});

  @override
  Widget build(BuildContext context) {
    return RLReveal(visible: visible, child: ButtonBody(context));
  }

  Widget ButtonBody(BuildContext context) {
    final Color accentColor = CourseAccentScope.of(context, fallback: RLDS.success);
    final String displayLabel = label ?? RLUIStrings.TEXT_CONTENT_CONTINUE_LABEL;

    void onButtonTap() {
      handleTap(context);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onButtonTap,
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: CC_CONTINUE_BUTTON_PADDING,
          child: Center(child: RLTypography.bodyLarge(displayLabel, color: accentColor)),
        ),
      ),
    );
  }

  void handleTap(BuildContext context) {
    HapticsService.lightImpact();

    final VoidCallback? customHandler = onTap;
    final bool hasCustomHandler = customHandler != null;

    if (hasCustomHandler) {
      customHandler();
      return;
    }

    advanceToNextPage(context);
  }

  // Default page-controller hop. No-ops when the button is rendered
  // outside a CourseDetailScreen ancestor (eg. a future preview surface)
  // so the widget stays safe to drop anywhere.
  void advanceToNextPage(BuildContext context) {
    final CourseDetailScreenState? courseDetailScreen = context
        .findAncestorStateOfType<CourseDetailScreenState>();

    final bool hasNoAncestor = courseDetailScreen == null;

    if (hasNoAncestor) {
      return;
    }

    final PageController pageController = courseDetailScreen.pageController;
    final bool hasNoClients = !pageController.hasClients;

    if (hasNoClients) {
      return;
    }

    final double? currentPageDouble = pageController.page;
    final bool hasNoCurrentPage = currentPageDouble == null;

    if (hasNoCurrentPage) {
      return;
    }

    final int currentPage = currentPageDouble.round();
    final int nextPage = currentPage + 1;

    pageController.animateToPage(
      nextPage,
      duration: CC_CONTINUE_PAGE_TRANSITION_DURATION,
      curve: CC_CONTINUE_PAGE_TRANSITION_CURVE,
    );
  }
}
