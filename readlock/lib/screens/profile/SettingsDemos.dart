// Settings demo widgets showing live previews of reading options.
// Each demo mirrors exactly what CCTextContent / ProgressiveText does in a
// real swipe:
//   - Font: readingMedium promoted to fontSize 18 / height 1.5 (the style
//     ProgressiveText.getConsistentTextStyle applies to every line)
//   - Reveal animation: character-by-character typewriter via a transparent
//     tail (no layout shift as chars fill in)
//   - Blur: sigma 4 / opacity 0.2 on completed sentences (the ProgressiveText
//     / BlurOverlay defaults)
//   - Colored text: RLDS.markupGreen + FontWeight.bold (the exact style
//     ProgressiveText applies to <c:g>…</c:g> markup)

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:readlock/bottom_sheets/user/FontPickerBottomSheet.dart';
import 'package:readlock/constants/RLReadingColumn.dart';
import 'package:readlock/constants/RLReadingFont.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/design_system/RLCard.dart';
import 'package:readlock/design_system/RLLunarBlur.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/utility_widgets/text_animation/BionicText.dart';
import 'package:readlock/utility_widgets/visual_effects/BlurOverlay.dart';

// Shared surface used by every reading-settings demo so Reveal, Blur,
// Coloured text, Bionic, Reading font, and RSVP all share the same frosted
// LunarBlur look as the rest of the app's cards. Alpha sits between the
// subtle and elevated card presets so the demo panes read as clearly
// tinted without competing with hero cards.
const EdgeInsets demoSurfacePadding = EdgeInsets.all(RLDS.spacing12);
const EdgeInsets demoSurfaceMargin = EdgeInsets.only(bottom: RLDS.spacing16);
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
      return GestureDetector(onTap: onTap, child: surface);
    }

    return surface;
  }
}

// Mirrors ProgressiveText.getConsistentTextStyle — every swipe renders at
// fontSize 18 / height 1.6 regardless of the caller's passed style. The
// demos must use the same style or the preview won't match the swipe.
//
// Getter (not a `final`) so it re-evaluates against the current
// selectedReadingFontNotifier value on each call. Demos that need to
// live-update on a font change wrap their output in demoFontListener below.
TextStyle get demoReadingStyle {
  return RLTypography.readingMediumStyle.copyWith(fontSize: 18, height: 1.6);
}

// Wraps a demo's body in a ValueListenableBuilder on the reading-font
// notifier so flipping the font in the picker immediately rebuilds the
// demo with the new typeface. Every demo that consumes demoReadingStyle
// (RevealDemo, BlurDemo, ColoredTextDemo) needs this; the ReadingFontDemo
// itself subscribes directly.
Widget demoFontListener(WidgetBuilder builder) {
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

  const RevealDemo({super.key, required this.isEnabled});

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
    return demoFontListener(DemoBody);
  }

  Widget DemoBody(BuildContext context) {
    return DemoSurface(
      child: Align(alignment: Alignment.centerLeft, child: AnimatedTextDisplay()),
    );
  }

  Widget AnimatedTextDisplay() {
    if (widget.isEnabled) {
      return Text(demoText, style: demoReadingStyle);
    }

    return AnimatedBuilder(animation: animationController, builder: buildTypewriterFrame);
  }

  // Renders the current typewriter frame — visible prefix painted in the
  // swipe's text colour, hidden tail painted transparent so the layout stays
  // reserved from the first frame (same technique ProgressiveText uses).
  Widget buildTypewriterFrame(BuildContext context, Widget? child) {
    final int charCount = (animationController.value * demoText.length).toInt();
    final String visibleText = demoText.substring(0, charCount);
    final String hiddenText = demoText.substring(charCount);

    return RichText(
      text: TextSpan(
        style: demoReadingStyle,
        children: [
          TextSpan(text: visibleText),

          TextSpan(
            text: hiddenText,
            style: const TextStyle(color: RLDS.transparent),
          ),
        ],
      ),
    );
  }
}

// Demo widget for Blur setting.
// Uses the same BlurOverlay as every covered-text surface in a real swipe,
// so the demo is a truthful preview of the Apple-Music-style lyrics blur
// (sigma + opacity sourced from RLDS.lyricsBlur* via BlurOverlay defaults).
class BlurDemo extends StatelessWidget {
  final bool isEnabled;

  const BlurDemo({super.key, required this.isEnabled});

  @override
  Widget build(BuildContext context) {
    return demoFontListener(DemoBody);
  }

  Widget DemoBody(BuildContext context) {
    return DemoSurface(
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

  const ColoredTextDemo({super.key, required this.isEnabled});

  @override
  Widget build(BuildContext context) {
    return demoFontListener(DemoBody);
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

  const BionicDemo({super.key, required this.isEnabled});

  @override
  Widget build(BuildContext context) {
    return demoFontListener(DemoBody);
  }

  Widget DemoBody(BuildContext context) {
    return DemoSurface(
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
    void onDemoTap() => FontPickerBottomSheet.show(context);

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

// Live preview + picker for the reading column width. Shows a sample
// paragraph at the selected maxWidth so the reader can see line-length
// change as they tap between Narrow / Comfortable / Wide. Picker sits inside
// the demo card (same self-contained pattern as RSVPDemo's WPM slider).
// Subscribes to selectedReadingColumnNotifier so the sample rewraps live.
class ReadingColumnDemo extends StatelessWidget {
  const ReadingColumnDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return demoFontListener(DemoBody);
  }

  Widget DemoBody(BuildContext context) {
    return DemoSurface(
      child: ValueListenableBuilder<ReadingColumn>(
        valueListenable: selectedReadingColumnNotifier,
        builder: ColumnContentBuilder,
      ),
    );
  }

  Widget ColumnContentBuilder(
    BuildContext context,
    ReadingColumn column,
    Widget? unusedChild,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ColumnOptionTabs(column: column),

        const Spacing.height(RLDS.spacing12),

        SampleParagraph(column: column),
      ],
    );
  }
}

// Renders the sample paragraph inside a centered ConstrainedBox that
// matches the content viewer's column frame exactly — Wide is
// unconstrained (full width), the others cap at the option's maxWidth.
class SampleParagraph extends StatelessWidget {
  final ReadingColumn column;

  const SampleParagraph({super.key, required this.column});

  @override
  Widget build(BuildContext context) {
    final double? maxWidth = maxWidthFor(column);
    final Widget sampleText = Text(
      RLUIStrings.DEMO_READING_COLUMN_TEXT,
      style: demoReadingStyle,
    );

    final bool isUnconstrained = maxWidth == null;

    if (isUnconstrained) {
      return sampleText;
    }

    final BoxConstraints sampleConstraints = BoxConstraints(maxWidth: maxWidth);

    return Center(child: ConstrainedBox(constraints: sampleConstraints, child: sampleText));
  }
}

// Three-tab row for the reader to pick a column width. Mirrors the segment
// tab style used on CourseRoadmapScreen so the picker reads as the same
// family of tab group: frosted RLLunarBlur pill behind the selected label,
// transparent row for the rest.
class ColumnOptionTabs extends StatelessWidget {
  final ReadingColumn column;

  const ColumnOptionTabs({super.key, required this.column});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: TabWidgets(),
    );
  }

  List<Widget> TabWidgets() {
    final List<Widget> tabs = [];

    for (int optionIndex = 0; optionIndex < READING_COLUMN_OPTIONS.length; optionIndex++) {
      final bool isFirstTab = optionIndex == 0;

      if (!isFirstTab) {
        tabs.add(const Spacing.width(RLDS.spacing8));
      }

      final ReadingColumnOption option = READING_COLUMN_OPTIONS[optionIndex];
      final bool isSelected = option.column == column;

      tabs.add(ColumnOptionTab(option: option, isSelected: isSelected));
    }

    return tabs;
  }
}

class ColumnOptionTab extends StatelessWidget {
  final ReadingColumnOption option;
  final bool isSelected;

  const ColumnOptionTab({super.key, required this.option, required this.isSelected});

  // Padding matches CourseRoadmapScreen.SegmentTabChip so both tab groups
  // share the same chip dimensions across the app.
  static const EdgeInsets tabPadding = EdgeInsets.symmetric(
    horizontal: RLDS.spacing16,
    vertical: RLDS.spacing8,
  );

  @override
  Widget build(BuildContext context) {
    final Color labelColor = isSelected ? RLDS.info : RLDS.textSecondary;
    final Widget tabLabel = RLTypography.bodyMedium(option.displayName, color: labelColor);

    void onTabTap() {
      selectedReadingColumnNotifier.value = option.column;
    }

    if (isSelected) {
      return GestureDetector(
        onTap: onTabTap,
        child: RLLunarBlur(
          borderRadius: RLDS.borderRadiusSmall,
          surfaceAlpha: RL_CARD_ALPHA,
          padding: tabPadding,
          child: tabLabel,
        ),
      );
    }

    return Div.row([tabLabel], padding: tabPadding, onTap: onTabTap);
  }
}

// RSVP (Rapid Serial Visual Presentation): flashes words one at a time in a
// fixed position so the reader's eyes stay still. The red letter is the
// Optimal Recognition Point — pinned to the column centre so every word
// lines up on the same X axis (the Spritz / Spreeder technique). Range
// 150–800 wpm covers the full usable span (average silent reading sits
// near 250; comprehension plateaus around 400–600 with practice). Default
// 300 is the recommended starting point. When the parent switch is off,
// the word stream pauses on a static sample so the card reads like a
// disabled preview, matching the other demos in the section.
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

  int currentWpm = defaultWpm;
  int wordIndex = 0;
  Timer? advanceTimer;

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

    final bool didTurnOn = widget.isEnabled && !oldWidget.isEnabled;
    final bool didTurnOff = !widget.isEnabled && oldWidget.isEnabled;

    if (didTurnOn) {
      scheduleNextWord();
    }

    if (didTurnOff) {
      advanceTimer?.cancel();
    }
  }

  @override
  void dispose() {
    advanceTimer?.cancel();
    super.dispose();
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
    setState(() {
      currentWpm = newWpm.round();
    });

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
    return demoFontListener(DemoBody);
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
