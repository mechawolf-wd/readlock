// Onboarding screen — runs after registration to set the reader's profile
// bird and reading preferences before they reach the bookshelf.
//
// One step per page: bird, typeface, column width, then the toggle-driven
// reading options (Progressive → Focus → Accent → Bionic) ordered
// most-important to special-mode. Each step reuses the same demo widget
// that lives under it in Settings (SettingsDemos.dart) so what the reader
// sees here is the exact preview they would see in Settings.
//
// Chrome: full-screen route, starfield painted edge-to-edge, lunar-blur
// cards floating on top for every step except the bird picker, which sits
// directly on the starfield. The page view doesn't scroll by hand —
// navigation is exclusively the chevron buttons in the footer.

import 'package:flutter/material.dart';
import 'package:readlock/services/feedback/HapticsService.dart';
import 'package:pixelarticons/pixel.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/design_system/RLStarfieldBackground.dart';
import 'package:readlock/design_system/RLSwitch.dart';
import 'package:readlock/models/UserModel.dart';
import 'package:readlock/screens/profile/BirdPicker.dart';
import 'package:readlock/screens/profile/SettingsDemos.dart';
import 'package:readlock/services/auth/UserService.dart';
import 'package:readlock/utility_widgets/text_animation/BionicText.dart';

const EdgeInsets ONBOARDING_PAGE_PADDING = EdgeInsets.symmetric(horizontal: RLDS.spacing24);
const EdgeInsets ONBOARDING_FOOTER_PADDING = EdgeInsets.fromLTRB(
  RLDS.spacing24,
  RLDS.spacing16,
  RLDS.spacing24,
  RLDS.spacing24,
);
// Tap-area padding around each chevron — RLDS.spacing12 gives a 44pt tap
// target with the iconXLarge glyph at its centre, matching Apple's HIG
// minimum without growing the footer past the safe area gap below.
const EdgeInsets ONBOARDING_ARROW_BUTTON_PADDING = EdgeInsets.all(RLDS.spacing12);

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  // Pushes the onboarding screen as a full-screen route. Returns the route
  // future so callers can await it (e.g. continue with post-onboarding
  // navigation once the reader finishes the flow).
  static Future<void> show(BuildContext context) {
    return Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (BuildContext routeContext) => const OnboardingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: STARFIELD_BACKGROUND_COLOR,
      body: Stack(
        children: [
          // Starfield paints first — fills the screen behind every card.
          Positioned.fill(child: RLStarfieldBackground()),

          // Step pager + footer sit on top of the starfield.
          Positioned.fill(child: OnboardingFlow()),
        ],
      ),
    );
  }
}

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => OnboardingFlowState();
}

class OnboardingFlowState extends State<OnboardingFlow> {
  late final PageController pageController;
  int currentStepIndex = 0;

  // * Reading-preference state — mirrors ProfileContent. Loaded once from
  // /users/{id} on mount so the onboarding starts from the user's saved
  // values; every toggle persists fire-and-forget so closing mid-flow
  // doesn't drop a choice.
  bool revealAllTrueFalse = false;
  bool blurEnabled = true;
  bool coloredTextEnabled = true;
  bool bionicEnabled = false;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
    fetchUserPreferences();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  Future<void> fetchUserPreferences() async {
    final UserModel? user = await UserService.getCurrentUserProfile();
    final bool isUnmounted = !mounted;
    final bool hasNoUser = user == null;

    if (isUnmounted || hasNoUser) {
      return;
    }

    setState(() {
      revealAllTrueFalse = user.reveal;
      blurEnabled = user.blur;
      coloredTextEnabled = user.coloredText;
      bionicEnabled = user.bionic;
    });
  }

  // * Step list — built lazily so each step can read live state via the
  // closure rather than each step holding a local copy of the toggle
  // values. Order is fixed: identity → reading basics → toggles → modes.
  List<OnboardingStepSpec> getStepSpecs() {
    final bool progressiveEnabled = !revealAllTrueFalse;

    return [
      // Bird step — no header, no card. The carousel floats directly on
      // the starfield so the chosen bird reads as the screen's hero.
      const OnboardingStepSpec(body: BirdCarousel()),

      const OnboardingStepSpec(title: RLUIStrings.MENU_READING_FONT, body: ReadingFontDemo()),

      const OnboardingStepSpec(
        title: RLUIStrings.MENU_READING_COLUMN,
        body: ReadingColumnDemo(),
      ),

      OnboardingStepSpec(
        title: RLUIStrings.MENU_REVEAL,
        toggle: OnboardingToggle(
          value: progressiveEnabled,
          onChanged: handleProgressiveToggled,
        ),
        body: RevealDemo(isEnabled: revealAllTrueFalse),
      ),

      OnboardingStepSpec(
        title: RLUIStrings.MENU_BLUR,
        toggle: OnboardingToggle(value: blurEnabled, onChanged: handleBlurToggled),
        body: BlurDemo(isEnabled: blurEnabled),
      ),

      OnboardingStepSpec(
        title: RLUIStrings.MENU_COLORED_TEXT,
        toggle: OnboardingToggle(
          value: coloredTextEnabled,
          onChanged: handleColoredTextToggled,
        ),
        body: ColoredTextDemo(isEnabled: coloredTextEnabled),
      ),

      OnboardingStepSpec(
        title: RLUIStrings.MENU_BIONIC,
        toggle: OnboardingToggle(value: bionicEnabled, onChanged: handleBionicToggled),
        body: BionicDemo(isEnabled: bionicEnabled),
      ),
    ];
  }

  // * Toggle handlers — same fire-and-forget persistence pattern as
  // ProfileContent so onboarding writes round-trip with Settings writes.

  void handleProgressiveToggled(bool progressiveEnabled) {
    final bool nextRevealAllTrueFalse = !progressiveEnabled;

    setState(() {
      revealAllTrueFalse = nextRevealAllTrueFalse;
    });

    UserService.updateReveal(nextRevealAllTrueFalse);
  }

  void handleBlurToggled(bool value) {
    setState(() => blurEnabled = value);
    UserService.updateBlur(value);
  }

  void handleColoredTextToggled(bool value) {
    setState(() => coloredTextEnabled = value);
    UserService.updateColoredText(value);
  }

  void handleBionicToggled(bool value) {
    setState(() => bionicEnabled = value);
    bionicEnabledNotifier.value = value;
    UserService.updateBionic(value);
  }

  void handleStepChanged(int newStepIndex) {
    HapticsService.selectionClick();

    setState(() {
      currentStepIndex = newStepIndex;
    });
  }

  // Next: scrolls the page view one step to the right. On the final step
  // there's nowhere else to scroll, so it pops the screen — the same
  // forward action the reader's been tapping the whole time.
  void handleNextTap() {
    final List<OnboardingStepSpec> stepSpecs = getStepSpecs();
    final int lastStepIndex = stepSpecs.length - 1;
    final bool isLastStep = currentStepIndex >= lastStepIndex;

    if (isLastStep) {
      Navigator.of(context).maybePop();
      return;
    }

    pageController.nextPage(
      duration: RLDS.opacityFadeDurationStandard,
      curve: RLDS.transitionCurve,
    );
  }

  // Previous: scrolls the page view back one step. The handler is only
  // wired up when there's somewhere to go back to (see footer), so it
  // never needs to guard the first step here.
  void handlePreviousTap() {
    pageController.previousPage(
      duration: RLDS.opacityFadeDurationStandard,
      curve: RLDS.transitionCurve,
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<OnboardingStepSpec> stepSpecs = getStepSpecs();
    final bool canGoBack = currentStepIndex > 0;
    // Next is always live: it advances on intermediate steps and pops the
    // screen on the last step (see handleNextTap), so there's no "disabled
    // forward" state — only Previous goes inert at the start.
    final VoidCallback? previousHandler = canGoBack ? handlePreviousTap : null;

    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: RLDS.spacing24),

          Expanded(
            child: PageView.builder(
              controller: pageController,
              // No hand-scrolling — only the chevron buttons advance the
              // page view, so the flow can't be skipped by mistake.
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: handleStepChanged,
              itemCount: stepSpecs.length,
              itemBuilder: (BuildContext pageContext, int stepIndex) {
                return OnboardingStepPage(spec: stepSpecs[stepIndex]);
              },
            ),
          ),

          OnboardingFooter(onPreviousTap: previousHandler, onNextTap: handleNextTap),
        ],
      ),
    );
  }
}

// One step's static descriptor. `toggle` is null for picker-driven steps
// (typeface, column) and present for every reading-mode step gated by a
// switch. `title` is null when the step doesn't render a header at all
// (the bird picker, where the carousel's selected-name label is its own
// title).
class OnboardingStepSpec {
  final String? title;
  final OnboardingToggle? toggle;
  final Widget body;

  const OnboardingStepSpec({this.title, this.toggle, required this.body});
}

class OnboardingToggle {
  final bool value;
  final ValueChanged<bool> onChanged;

  const OnboardingToggle({required this.value, required this.onChanged});
}

// Single-step page — header (title + optional switch) over the body
// widget. No card frame: every step floats directly on the starfield, so
// the demos read as the hero of each step. The header collapses entirely
// when the spec's title is null.
class OnboardingStepPage extends StatelessWidget {
  final OnboardingStepSpec spec;

  const OnboardingStepPage({super.key, required this.spec});

  @override
  Widget build(BuildContext context) {
    final bool hasTitle = spec.title != null;
    final List<Widget> columnChildren = [];

    if (hasTitle) {
      columnChildren.add(StepHeader(spec: spec));
      columnChildren.add(const SizedBox(height: RLDS.spacing20));
    }

    columnChildren.add(spec.body);

    final Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: columnChildren,
    );

    return Padding(
      padding: ONBOARDING_PAGE_PADDING,
      child: Center(child: SingleChildScrollView(child: content)),
    );
  }
}

// Shared header — heading title with an optional switch trailing. No
// icon: the title carries the entire visual weight of the row, in the
// app's reading-style heading. The switch slot collapses when the spec
// doesn't supply a toggle, so picker-driven steps render the same chrome
// as toggle-driven steps without an empty gap on the right.
class StepHeader extends StatelessWidget {
  final OnboardingStepSpec spec;

  const StepHeader({super.key, required this.spec});

  @override
  Widget build(BuildContext context) {
    // Page-level guard ensures this header is never rendered for a spec
    // without a title, so the bang here is the contract of that guard.
    final String title = spec.title!;
    final OnboardingToggle? toggle = spec.toggle;
    final bool hasToggle = toggle != null;
    final List<Widget> headerChildren = [Expanded(child: RLTypography.headingLarge(title))];

    if (hasToggle) {
      headerChildren.add(RLSwitch(value: toggle.value, onChanged: toggle.onChanged));
    }

    return Row(children: headerChildren);
  }
}

// Footer — two chevron icons sitting at the edges of the screen. No
// labels: the arrows alone say "go back" / "go forward". A null handler
// renders the chevron in the muted text colour and ignores taps, so the
// first step's Previous and the last step's Next read as inert.
class OnboardingFooter extends StatelessWidget {
  final VoidCallback? onPreviousTap;
  final VoidCallback? onNextTap;

  const OnboardingFooter({super.key, this.onPreviousTap, this.onNextTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: ONBOARDING_FOOTER_PADDING,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          OnboardingArrowButton(icon: Pixel.chevronleft, onTap: onPreviousTap),

          OnboardingArrowButton(icon: Pixel.chevronright, onTap: onNextTap),
        ],
      ),
    );
  }
}

// A chevron rendered as a tap target with the same haptic + sizing
// treatment every primary action in the app gets. Disabled state is
// signalled by a muted icon colour and a null tap handler — no separate
// chrome, since the icon is the entire button.
class OnboardingArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const OnboardingArrowButton({super.key, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onTap == null;
    final Color iconColor = isDisabled ? RLDS.textMuted : RLDS.textPrimary;
    final Widget ArrowIcon = Icon(icon, color: iconColor, size: RLDS.iconXLarge);

    return GestureDetector(
      onTap: wrapWithHaptic(onTap),
      behavior: HitTestBehavior.opaque,
      child: Padding(padding: ONBOARDING_ARROW_BUTTON_PADDING, child: ArrowIcon),
    );
  }

  // Same haptic-on-tap pattern RLButton uses, kept inline so the chevron
  // buttons feel identical to every other tappable surface in the app.
  VoidCallback? wrapWithHaptic(VoidCallback? rawHandler) {
    if (rawHandler == null) {
      return null;
    }

    return () {
      HapticsService.lightImpact();
      rawHandler();
    };
  }
}

