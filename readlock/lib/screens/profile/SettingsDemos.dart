// Settings demo widgets showing live previews of reading options.
// Each demo mirrors exactly what CCTextContent / ProgressiveText does in a
// real swipe:
//   - Font: readingMedium promoted to fontSize 18 / height 1.5 (the style
//     ProgressiveText.getConsistentTextStyle applies to every line)
//   - Reveal animation: character-by-character typewriter where each char
//     crossfades in from alpha 0 → 1 over progressiveTextLeadingCharacterFadeDuration
//     (the same per-character fade ProgressiveText runs in a real swipe).
//     The hidden tail is rendered transparent so layout never reflows.
//   - Blur: sigma 4 / opacity 0.2 on completed sentences (the ProgressiveText
//     / BlurOverlay defaults)
//   - Colored text: RLDS.markupGreen + FontWeight.bold (the exact style
//     ProgressiveText applies to <c:g>…</c:g> markup)

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:readlock/services/feedback/HapticsService.dart';
import 'package:readlock/bottom_sheets/user/FontPickerBottomSheet.dart';
import 'package:readlock/constants/RLReadingColumn.dart';
import 'package:readlock/constants/RLReadingFont.dart';
import 'package:readlock/constants/RLReadingJustified.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/design_system/RLLunarBlur.dart';
import 'package:readlock/design_system/RLSegmentTabs.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/utility_widgets/text_animation/BionicText.dart';
import 'package:readlock/services/auth/UserService.dart';
import 'package:readlock/utility_widgets/text_animation/ProgressiveText.dart';
import 'package:readlock/utility_widgets/text_animation/RSVPText.dart';
import 'package:readlock/utility_widgets/visual_effects/BlurOverlay.dart';

// Shared surface used by every reading-settings demo so Reveal, Blur,
// Coloured text, Bionic, Reading font, and RSVP all share the same frosted
// LunarBlur look as the rest of the app's cards. Alpha sits between the
// subtle and elevated card presets so the demo panes read as clearly
// tinted without competing with hero cards.
const EdgeInsets demoSurfacePadding = EdgeInsets.all(RLDS.spacing12);
const EdgeInsets demoSurfaceMargin = EdgeInsets.only(bottom: RLDS.spacing4);
const double demoSurfaceAlpha = 0.28;

class DemoSurface extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const DemoSurface({super.key, required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    final Widget surface = Container(
      margin: demoSurfaceMargin,
      child: RLLunarBlur(
        surfaceAlpha: demoSurfaceAlpha,
        padding: demoSurfacePadding,
        child: SizedBox(width: double.infinity, child: child),
      ),
    );

    final bool hasTapHandler = onTap != null;

    if (hasTapHandler) {
      return GestureDetector(onTap: handleTap, child: surface);
    }

    return surface;
  }

  void handleTap() {
    HapticsService.selectionClick();
    onTap!.call();
  }
}

// Mirrors ProgressiveText.getConsistentTextStyle — every swipe renders at
// fontSize 18 / height 1.6 regardless of the caller's passed style. The
// demos must use the same style or the preview won't match the swipe.
//
// Getter (not a `final`) so it re-evaluates against the current
// selectedReadingFontNotifier value on each call. Demos that need to
// live-update on a font change wrap their output in DemoFontListener below.
TextStyle get demoReadingStyle {
  return RLTypography.readingMediumStyle.copyWith(fontSize: 18, height: 1.6);
}

// Wraps a demo's body in a ValueListenableBuilder on the reading-font
// notifier so flipping the font in the picker immediately rebuilds the
// demo with the new typeface. Every demo that consumes demoReadingStyle
// (RevealDemo, BlurDemo, ColoredTextDemo) needs this; the ReadingFontDemo
// itself subscribes directly.
Widget DemoFontListener(WidgetBuilder builder) {
  Widget fontBuilder(BuildContext context, ReadingFont font, Widget? unusedChild) {
    return builder(context);
  }

  return ValueListenableBuilder<ReadingFont>(
    valueListenable: selectedReadingFontNotifier,
    builder: fontBuilder,
  );
}

// Matches ProgressiveText's inline-highlight render for <c:g>…</c:g> markup.
// Both colour and weight need to match or the demo understates the visual
// weight of a highlighted key term in the real swipe.
final Color demoHighlightColor = RLDS.markupGreen;
const FontWeight demoHighlightWeight = FontWeight.bold;

// Demo widget for Reveal setting
// Shows text appearing all at once vs character by character
class RevealDemo extends StatefulWidget {
  final bool isEnabled;
  final VoidCallback? onTap;

  const RevealDemo({super.key, required this.isEnabled, this.onTap});

  @override
  State<RevealDemo> createState() => RevealDemoState();
}

class RevealDemoState extends State<RevealDemo> with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  static const String demoText = RLUIStrings.DEMO_REVEAL_TEXT;
  bool isPaused = false;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    animationController.addStatusListener(handleAnimationStatus);
    animationController.forward();
  }

  void handleAnimationStatus(AnimationStatus status) {
    final bool isAnimationComplete = status == AnimationStatus.completed;

    if (isAnimationComplete && !isPaused) {
      isPaused = true;

      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) {
          isPaused = false;
          animationController.reset();
          animationController.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    animationController.removeStatusListener(handleAnimationStatus);
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DemoFontListener(DemoBody);
  }

  Widget DemoBody(BuildContext context) {
    return DemoSurface(
      onTap: widget.onTap,
      child: Align(alignment: Alignment.centerLeft, child: AnimatedTextDisplay()),
    );
  }

  Widget AnimatedTextDisplay() {
    // Both branches render the same RichText shape so toggling Progressive
    // doesn't swap widget types under the same slot — Text vs RichText
    // measure baselines slightly differently and the demo would visibly
    // nudge on toggle. Keeping the root identical pins the layout.
    if (widget.isEnabled) {
      return RichText(text: TextSpan(style: demoReadingStyle, text: demoText));
    }

    return AnimatedBuilder(animation: animationController, builder: TypewriterFrame);
  }

  // Renders the current typewriter frame — each revealed character carries
  // its own alpha so it crossfades in from 0 → 1 over the same window
  // ProgressiveText uses (progressiveTextLeadingCharacterFadeDuration).
  // Unrevealed characters render transparent so the layout stays reserved
  // from the first frame.
  Widget TypewriterFrame(BuildContext context, Widget? child) {
    final List<TextSpan> characterSpans = buildFadingCharacterSpans();

    return RichText(
      text: TextSpan(style: demoReadingStyle, children: characterSpans),
    );
  }

  // Builds one TextSpan per character with a per-character alpha based on
  // elapsed-since-reveal / fade duration. Mirrors ProgressiveText's
  // getCharacterFadeAlpha so the demo is a truthful preview of the swipe.
  List<TextSpan> buildFadingCharacterSpans() {
    final int textLength = demoText.length;
    final double totalAnimationMs =
        animationController.duration!.inMilliseconds.toDouble();
    final double currentMs = animationController.value * totalAnimationMs;
    final double charStepMs = totalAnimationMs / textLength;
    final double fadeWindowMs =
        progressiveTextLeadingCharacterFadeDuration.inMilliseconds.toDouble();
    final Color baseColor = demoReadingStyle.color ?? RLDS.textPrimary;

    TextSpan buildCharacterSpan(int characterIndex) {
      final double revealAtMs = characterIndex * charStepMs;
      final double elapsedSinceReveal = currentMs - revealAtMs;
      final double characterAlpha = (elapsedSinceReveal / fadeWindowMs).clamp(0.0, 1.0);
      final TextStyle characterStyle = TextStyle(
        color: baseColor.withValues(alpha: characterAlpha),
      );

      return TextSpan(text: demoText[characterIndex], style: characterStyle);
    }

    return List.generate(textLength, buildCharacterSpan);
  }
}

// Demo widget for Blur setting.
// Uses the same BlurOverlay as every covered-text surface in a real swipe,
// so the demo is a truthful preview of the Apple-Music-style lyrics blur
// (sigma + opacity sourced from RLDS.lyricsBlur* via BlurOverlay defaults).
class BlurDemo extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback? onTap;

  const BlurDemo({super.key, required this.isEnabled, this.onTap});

  @override
  Widget build(BuildContext context) {
    return DemoFontListener(DemoBody);
  }

  Widget DemoBody(BuildContext context) {
    return DemoSurface(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlurredSentence(),

          const Spacing.height(RLDS.spacing8),

          Text(RLUIStrings.DEMO_BLUR_CURRENT, style: demoReadingStyle),
        ],
      ),
    );
  }

  Widget BlurredSentence() {
    return BlurOverlay(
      enabled: isEnabled,
      child: Text(RLUIStrings.DEMO_BLUR_PREVIOUS, style: demoReadingStyle),
    );
  }
}

// Demo widget for Colored text setting
// Shows how highlighted terms appear in the content
class ColoredTextDemo extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback? onTap;

  const ColoredTextDemo({super.key, required this.isEnabled, this.onTap});

  @override
  Widget build(BuildContext context) {
    return DemoFontListener(DemoBody);
  }

  Widget DemoBody(BuildContext context) {
    // When disabled, the highlight matches the surrounding text (no colour,
    // normal weight) — same as ProgressiveText would render raw text without
    // <c:g> markup. When enabled, matches the markupGreen + bold style
    // ProgressiveText applies via RLDS.getMarkupColor('g').
    Color highlightColor = RLDS.textPrimary;
    FontWeight keyTermsFontWeight = FontWeight.normal;

    if (isEnabled) {
      highlightColor = demoHighlightColor;
      keyTermsFontWeight = demoHighlightWeight;
    }

    final TextStyle highlightStyle = TextStyle(
      color: highlightColor,
      fontWeight: keyTermsFontWeight,
    );

    return DemoSurface(
      onTap: onTap,
      child: Align(
        alignment: Alignment.centerLeft,
        child: RichText(
          text: TextSpan(
            style: demoReadingStyle,
            children: [
              TextSpan(text: RLUIStrings.DEMO_COLORED_HIGHLIGHT, style: highlightStyle),

              const TextSpan(text: RLUIStrings.DEMO_COLORED_SUFFIX),
            ],
          ),
        ),
      ),
    );
  }
}

// Demo widget for Bionic reading setting.
// Same card geometry as the other demos; when enabled, bolds the first ~40%
// of each word via the shared bionicSpans helper so the preview is the
// exact transformation that would be applied to reading content.
class BionicDemo extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback? onTap;

  const BionicDemo({super.key, required this.isEnabled, this.onTap});

  @override
  Widget build(BuildContext context) {
    return DemoFontListener(DemoBody);
  }

  Widget DemoBody(BuildContext context) {
    return DemoSurface(
      onTap: onTap,
      child: Align(alignment: Alignment.centerLeft, child: BionicSample()),
    );
  }

  Widget BionicSample() {
    if (!isEnabled) {
      return Text(RLUIStrings.DEMO_BIONIC_TEXT, style: demoReadingStyle);
    }

    final List<InlineSpan> spans = bionicSpans(RLUIStrings.DEMO_BIONIC_TEXT, demoReadingStyle);

    return RichText(text: TextSpan(children: spans));
  }
}

// Live preview of the currently-selected reading font. Subscribes to
// selectedReadingFontNotifier so flipping the font in the picker updates
// this demo in place — same reactive pattern as the profile bird.
// Tapping the box opens the FontPickerBottomSheet so the preview doubles
// as the affordance for changing the font.
class ReadingFontDemo extends StatelessWidget {
  const ReadingFontDemo({super.key});

  @override
  Widget build(BuildContext context) {
    void onDemoTap() {
      HapticsService.selectionClick();
      FontPickerBottomSheet.show(context);
    }

    return DemoSurface(
      onTap: onDemoTap,
      child: ValueListenableBuilder<ReadingFont>(
        valueListenable: selectedReadingFontNotifier,
        builder: FontSampleBuilder,
      ),
    );
  }

  Widget FontSampleBuilder(BuildContext context, ReadingFont font, Widget? unusedChild) {
    // Matches ProgressiveText.getConsistentTextStyle — every swipe renders
    // readingMedium promoted to fontSize 18 / height 1.6 — so the preview
    // is a truthful render of what the reader will see in CCTextContent.
    final TextStyle sampleStyle = RLTypography.readingMediumStyleFor(
      font,
    ).copyWith(fontSize: 18, height: 1.6);

    return Align(
      alignment: Alignment.centerLeft,
      child: Text(RLUIStrings.FONT_DEMO_SAMPLE_TEXT, style: sampleStyle),
    );
  }
}

// Live preview + picker for the reading column width. The tab row sits
// above the sample card at full width so the picker reads as a header for
// the preview below — change the tab, the paragraph below rewraps to match.
// Subscribes to selectedReadingColumnNotifier so the sample rewraps live.
class ReadingColumnDemo extends StatelessWidget {
  const ReadingColumnDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return DemoFontListener(DemoBody);
  }

  Widget DemoBody(BuildContext context) {
    return ValueListenableBuilder<ReadingColumn>(
      valueListenable: selectedReadingColumnNotifier,
      builder: ColumnContentBuilder,
    );
  }

  Widget ColumnContentBuilder(
    BuildContext context,
    ReadingColumn column,
    Widget? unusedChild,
  ) {
    return Container(
      margin: demoSurfaceMargin,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ColumnOptionTabs(column: column),

          const Spacing.height(RLDS.spacing12),

          SampleSurface(column: column),
        ],
      ),
    );
  }
}

// Wraps the sample paragraph in the shared frosted demo surface. The
// surface itself spans the full available width — same outer footprint
// regardless of the picked column — and the column choice only changes
// the horizontal padding inside, so the text wraps shorter for Newspaper
// and longer for Classic without the box itself resizing. LayoutBuilder
// gives us the slot width so we can compute "how much extra inset do we
// need to squeeze the line down to the column's maxWidth".
class SampleSurface extends StatelessWidget {
  final ReadingColumn column;

  const SampleSurface({super.key, required this.column});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: AtSlot);
  }

  Widget AtSlot(BuildContext context, BoxConstraints constraints) {
    final double slotWidth = constraints.maxWidth;
    final double widthFraction = previewWidthFractionFor(column);
    final EdgeInsets innerPadding = computeInnerPadding(slotWidth, widthFraction);

    // Keying on the live font so a typeface change remounts the paragraph.
    // The canonicalised const SampleParagraph below would otherwise be
    // skipped on rebuild and stay on the old typeface.
    final ValueKey<ReadingFont> fontKey = ValueKey<ReadingFont>(
      selectedReadingFontNotifier.value,
    );

    return GestureDetector(
      onTap: handleSampleTap,
      behavior: HitTestBehavior.opaque,
      child: RLLunarBlur(
        surfaceAlpha: demoSurfaceAlpha,
        padding: innerPadding,
        child: SizedBox(
          key: fontKey,
          width: double.infinity,
          child: const SampleParagraph(),
        ),
      ),
    );
  }

  // Tapping the sample box cycles to the next column option, so the
  // preview itself doubles as an affordance for changing the column style.
  void handleSampleTap() {
    HapticsService.selectionClick();

    final int currentIndex = READING_COLUMN_OPTIONS.indexWhere(
      (ReadingColumnOption option) => option.column == column,
    );
    final int nextIndex = (currentIndex + 1) % READING_COLUMN_OPTIONS.length;
    final ReadingColumn nextColumn = READING_COLUMN_OPTIONS[nextIndex].column;

    selectedReadingColumnNotifier.value = nextColumn;

    UserService.updateReadingColumn(nextColumn.name);
  }

  // Holds the base demo padding (top/bottom + a minimum horizontal inset)
  // and adds whatever extra horizontal inset is needed to bring the text
  // run down to a fraction of the slot. Percentage based so the picker
  // produces a visible change on small phones too, where absolute maxWidth
  // values would both clamp to the slot width.
  EdgeInsets computeInnerPadding(double slotWidth, double widthFraction) {
    final double basePadding = demoSurfacePadding.left;
    final double textBudget = slotWidth - basePadding * 2;
    final double targetTextWidth = slotWidth * widthFraction;
    final double overflowToShave = (textBudget - targetTextWidth).clamp(0.0, textBudget);
    final double extraInsetPerSide = overflowToShave / 2;

    return EdgeInsets.fromLTRB(
      basePadding + extraInsetPerSide,
      demoSurfacePadding.top,
      basePadding + extraInsetPerSide,
      demoSurfacePadding.bottom,
    );
  }
}

// Renders the sample paragraph inside the surface. Width is governed by
// the parent SampleSurface's padding, so this widget just paints the
// text and lets the padded box do the column work.
class SampleParagraph extends StatelessWidget {
  const SampleParagraph({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      RLUIStrings.DEMO_READING_COLUMN_TEXT,
      style: demoReadingStyle,
    );
  }
}

// Adapter — maps the reading-column options to the shared RLSegmentTabs
// component and routes selection to the notifier.
class ColumnOptionTabs extends StatelessWidget {
  final ReadingColumn column;

  const ColumnOptionTabs({super.key, required this.column});

  @override
  Widget build(BuildContext context) {
    final List<RLSegmentTabOption<ReadingColumn>> tabOptions = READING_COLUMN_OPTIONS
        .map(
          (ReadingColumnOption option) => RLSegmentTabOption<ReadingColumn>(
            value: option.column,
            label: option.displayName,
          ),
        )
        .toList();

    return RLSegmentTabs<ReadingColumn>(
      options: tabOptions,
      selectedValue: column,
      onChanged: handleColumnChanged,
    );
  }

  void handleColumnChanged(ReadingColumn newColumn) {
    selectedReadingColumnNotifier.value = newColumn;

    UserService.updateReadingColumn(newColumn.name);
  }
}

// RSVP (Rapid Serial Visual Presentation): flashes words one at a time in a
// fixed position so the reader's eyes stay still. The red letter is the
// Optimal Recognition Point — pinned to the column centre so every word
// lines up on the same X axis (the Spritz / Spreeder technique). Range
// 150–800 wpm covers the full usable span (average silent reading sits
// near 250; comprehension plateaus around 400–600 with practice). Default
// 300 is the recommended starting point. The demo only animates while the
// parent toggle is on, so the preview reflects the actual feature state.
class RSVPDemo extends StatefulWidget {
  final bool isEnabled;

  const RSVPDemo({super.key, required this.isEnabled});

  @override
  State<RSVPDemo> createState() => RSVPDemoState();
}

class RSVPDemoState extends State<RSVPDemo> {
  static final List<String> demoWords = RLUIStrings.DEMO_RSVP_TEXT.split(' ');
  static const double minWpm = 150.0;
  static const double maxWpm = 800.0;
  static const int defaultWpm = 300;

  // Slider drags fire onChanged on every notch, so we coalesce the
  // Firestore write until the reader's settled on a value. Long enough
  // to swallow a full sweep, short enough that letting go feels saved.
  static const Duration wpmPersistDebounce = Duration(milliseconds: 400);

  // Initial value is read from the notifier so the slider remembers the
  // last setting between Profile screen re-mounts.
  int currentWpm = rsvpWordsPerMinuteNotifier.value;
  int wordIndex = 0;
  Timer? advanceTimer;
  Timer? wpmPersistTimer;

  @override
  void initState() {
    super.initState();

    if (widget.isEnabled) {
      scheduleNextWord();
    }
  }

  @override
  void didUpdateWidget(covariant RSVPDemo oldWidget) {
    super.didUpdateWidget(oldWidget);

    final bool justEnabled = widget.isEnabled && !oldWidget.isEnabled;
    final bool justDisabled = !widget.isEnabled && oldWidget.isEnabled;

    if (justEnabled) {
      scheduleNextWord();
    }

    if (justDisabled) {
      advanceTimer?.cancel();
      advanceTimer = null;
    }
  }

  @override
  void dispose() {
    flushPendingWpmPersist();

    advanceTimer?.cancel();

    super.dispose();
  }

  // Flushes any pending debounced wpm write so a value the reader dragged
  // to but never settled on isn't lost when the sheet closes mid-drag.
  void flushPendingWpmPersist() {
    final bool hasPendingWrite = wpmPersistTimer?.isActive ?? false;

    wpmPersistTimer?.cancel();
    wpmPersistTimer = null;

    if (hasPendingWrite) {
      UserService.updateRsvpWordsPerMinute(currentWpm);
    }
  }

  void scheduleNextWord() {
    advanceTimer?.cancel();
    final int intervalMs = (60000 / currentWpm).round();
    advanceTimer = Timer(Duration(milliseconds: intervalMs), advanceToNextWord);
  }

  void advanceToNextWord() {
    final bool isUnmounted = !mounted;

    if (isUnmounted) {
      return;
    }

    setState(() {
      wordIndex = (wordIndex + 1) % demoWords.length;
    });

    scheduleNextWord();
  }

  void handleWpmChanged(double newWpm) {
    final int roundedWpm = newWpm.round();
    final bool hasWpmChanged = roundedWpm != currentWpm;

    setState(() {
      currentWpm = roundedWpm;
    });

    // Tick haptic on every notch change — same selectionClick the bird
    // carousel uses, so dragging the slider feels physically detented
    // instead of silent.
    if (hasWpmChanged) {
      HapticsService.selectionClick();
    }

    // Mirror to the global notifier so a course read with RSVP enabled
    // picks up the same pace next time CCTextContent mounts an RSVPText.
    rsvpWordsPerMinuteNotifier.value = roundedWpm;

    // Persist the picked pace to the user profile, debounced so a drag
    // across notches coalesces into one Firestore write once the reader
    // settles. dispose flushes any pending write if the sheet closes
    // before the timer fires.
    if (hasWpmChanged) {
      wpmPersistTimer?.cancel();
      wpmPersistTimer = Timer(wpmPersistDebounce, () {
        UserService.updateRsvpWordsPerMinute(roundedWpm);
      });
    }

    // Reschedule with the new interval only if the demo is currently
    // running — otherwise the new pace just waits for the toggle to flip.
    if (widget.isEnabled) {
      scheduleNextWord();
    }
  }

  // Optimal Recognition Point position — the letter the eye anchors on.
  // Buckets lifted from the Spritz paper: longer words shift the pivot
  // slightly right of position 1 so most readers land it without thinking.
  int getOrpIndex(String word) {
    final int length = word.length;

    if (length <= 1) {
      return 0;
    }
    if (length <= 5) {
      return 1;
    }
    if (length <= 9) {
      return 2;
    }
    if (length <= 13) {
      return 3;
    }

    return 4;
  }

  @override
  Widget build(BuildContext context) {
    return DemoFontListener(DemoBody);
  }

  Widget DemoBody(BuildContext context) {
    return DemoSurface(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [WordDisplay(), const Spacing.height(RLDS.spacing8), WpmControl()],
      ),
    );
  }

  Widget WordDisplay() {
    final String currentWord = demoWords[wordIndex];
    final int orpIndex = getOrpIndex(currentWord);
    final String preOrp = currentWord.substring(0, orpIndex);
    final String orpLetter = currentWord.substring(orpIndex, orpIndex + 1);
    final String postOrp = currentWord.substring(orpIndex + 1);

    // Matches the 18 / 1.6 reading style the other demos use, so the
    // word size here reads as the same family as Reveal / Blur / Bionic.
    final TextStyle baseStyle = demoReadingStyle;
    final TextStyle orpStyle = baseStyle.copyWith(
      color: RLDS.primary,
      fontWeight: FontWeight.bold,
    );

    return SizedBox(
      height: RLDS.spacing48,
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(preOrp, style: baseStyle),
            ),
          ),

          Text(orpLetter, style: orpStyle),

          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(postOrp, style: baseStyle),
            ),
          ),
        ],
      ),
    );
  }

  Widget WpmControl() {
    final String wpmLabel = '$currentWpm${RLUIStrings.RSVP_WPM_SUFFIX}';
    final TextStyle wpmLabelStyle = RLTypography.bodyLargeStyle.copyWith(
      fontSize: 20,
      fontWeight: RLDS.weightBold,
      color: RLDS.textPrimary,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Larger than bodyMedium so the live counter reads as the headline
        // value of the card — you're adjusting this number, it should look
        // like the thing you're adjusting.
        Text(wpmLabel, style: wpmLabelStyle),

        const Spacing.height(RLDS.spacing12),

        CupertinoSlider(
          value: currentWpm.toDouble(),
          min: minWpm,
          max: maxWpm,
          activeColor: RLDS.primary,
          onChanged: handleWpmChanged,
        ),
      ],
    );
  }
}

// Live preview of the Justified text toggle. Renders the same sample
// paragraph in either justified or default (left-aligned) mode based on
// justifiedReadingEnabledNotifier, and tapping the surface flips the
// setting through the same handler the SwitchMenuItem uses — so the box
// doubles as a tap-target for the toggle.
class JustifiedReadingDemo extends StatelessWidget {
  // Same callback shape as the SwitchMenuItem onChanged: receives the
  // new desired value. Tapping the demo passes the inverted current
  // value, so the parent runs its full toggle pipeline (local state +
  // notifier + Firestore) and the switch UI tracks the change.
  final ValueChanged<bool> onToggle;

  const JustifiedReadingDemo({super.key, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return DemoFontListener(DemoBody);
  }

  Widget DemoBody(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: justifiedReadingEnabledNotifier,
      builder: SampleBuilder,
    );
  }

  Widget SampleBuilder(BuildContext context, bool isJustified, Widget? unusedChild) {
    final TextAlign sampleAlignment = isJustified ? TextAlign.justify : TextAlign.start;

    void handleDemoTap() => onToggle(!isJustified);

    return DemoSurface(
      onTap: handleDemoTap,
      child: Text(
        RLUIStrings.DEMO_JUSTIFIED_TEXT,
        style: demoReadingStyle,
        textAlign: sampleAlignment,
      ),
    );
  }
}
