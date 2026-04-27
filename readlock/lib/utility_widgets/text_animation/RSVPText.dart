// Rapid Serial Visual Presentation reader.
//
// Flashes one word at a time at the same X position so the reader's eyes
// stay still. Red letter is the Optimal Recognition Point (Spritz
// technique) — pinned to the column centre so every word aligns. Meant as
// a drop-in alternative to ProgressiveText's typewriter: CCTextContent
// picks between the two based on rsvpEnabledNotifier.
//
// Segment model matches ProgressiveText: only the currently revealing
// segment is a live RSVP stream. Prior segments render as settled static
// text above so the reader can glance back without losing the word flash.
// When a segment's stream finishes it freezes into static text; tap
// advances to the next segment (or fires onAllSegmentsRevealed if it was
// the last). Tap mid-stream fast-forwards the current segment to its end.

import 'dart:async';

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/utility_widgets/visual_effects/BlurOverlay.dart';

const int RSVP_DEFAULT_WORDS_PER_MINUTE = 300;

// Vertical room reserved for the flashing word so the layout doesn't jump
// as the RSVP stream plays. Roughly 2× the reading line-height.
const double RSVP_WORD_DISPLAY_HEIGHT = 64.0;

// How long the static tail stays visible after the final segment's stream
// finishes before fading out the RSVP UI. Gives the reader a beat to
// register the last word before the continue button appears.
const Duration RSVP_COMPLETION_SETTLE_DELAY = Duration(milliseconds: 300);

// Cross-fade between the streaming WordDisplay and the settled segment
// text. Long enough to read as a graceful settle, short enough not to
// stall the tap-to-advance flow.
const Duration RSVP_SETTLE_FADE_DURATION = Duration(milliseconds: 280);

// Global toggle — ProfileScreen flips this, CCTextContent listens via
// ValueListenableBuilder so the mode swap is live. Kept in-memory only
// (matches the existing ProfileScreen contract for RSVP).
final ValueNotifier<bool> rsvpEnabledNotifier = ValueNotifier<bool>(false);

// Reading speed for the RSVP stream. The Settings demo's WPM slider writes
// here so a course read picks up whatever pace the reader last set, and
// scheduleNextWord reads `.value` on every tick so a mid-stream change
// (theoretical — Settings can't be opened during a course right now) would
// take effect at the next word boundary.
final ValueNotifier<int> rsvpWordsPerMinuteNotifier = ValueNotifier<int>(
  RSVP_DEFAULT_WORDS_PER_MINUTE,
);

// Optimal Recognition Point offset for a given word. Buckets lifted from
// the Spritz paper — longer words shift the pivot right of position 1 so
// most readers land on it without thinking.
int getRsvpOrpIndex(String word) {
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

class RSVPText extends StatefulWidget {
  final List<String> textSegments;
  final TextStyle? textStyle;
  final VoidCallback? onAllSegmentsRevealed;

  const RSVPText({
    super.key,
    required this.textSegments,
    this.textStyle,
    this.onAllSegmentsRevealed,
  });

  @override
  State<RSVPText> createState() => RSVPTextState();
}

class RSVPTextState extends State<RSVPText> {
  int currentSegmentIndex = 0;
  int currentWordIndex = 0;
  List<String> currentWords = const [];
  bool isCurrentSegmentStreaming = false;
  bool hasFiredCompletionCallback = false;
  Timer? advanceTimer;

  // Per-segment blur state. Previous segments default to blurred (matches
  // ProgressiveText); tapping a blurred segment flips it to crisp so the
  // reader can re-read it without advancing the stream.
  List<bool> segmentBlurEnabled = const [];

  @override
  void initState() {
    super.initState();

    segmentBlurEnabled = List<bool>.filled(widget.textSegments.length, true);

    final bool hasSegments = widget.textSegments.isNotEmpty;

    if (hasSegments) {
      prepareSegmentAtIndex(currentSegmentIndex);
      scheduleNextWord();
    }
  }

  @override
  void dispose() {
    advanceTimer?.cancel();
    super.dispose();
  }

  // Split a segment into flashable tokens. Keeps punctuation attached to
  // the trailing word so the reader sees "end." as one beat, not two.
  List<String> splitSegmentIntoWords(String segment) {
    final List<String> tokens = segment.trim().split(RegExp(r'\s+'));
    final bool hasNoTokens = tokens.length == 1 && tokens.first.isEmpty;

    if (hasNoTokens) {
      return const [];
    }

    return tokens;
  }

  void prepareSegmentAtIndex(int segmentIndex) {
    final bool isOutOfRange = segmentIndex >= widget.textSegments.length;

    if (isOutOfRange) {
      currentWords = const [];
      isCurrentSegmentStreaming = false;
      return;
    }

    currentWords = splitSegmentIntoWords(widget.textSegments[segmentIndex]);
    currentWordIndex = 0;
    isCurrentSegmentStreaming = currentWords.isNotEmpty;
  }

  void scheduleNextWord() {
    advanceTimer?.cancel();

    final bool hasNothingToSchedule = !isCurrentSegmentStreaming;

    if (hasNothingToSchedule) {
      return;
    }

    // Read the live notifier value each tick so the WPM slider in Settings
    // is the single source of truth for reading pace.
    final int wordsPerMinute = rsvpWordsPerMinuteNotifier.value;
    final int intervalMs = (60000 / wordsPerMinute).round();
    advanceTimer = Timer(Duration(milliseconds: intervalMs), advanceToNextWord);
  }

  void toggleBlurForSegment(int segmentIndex) {
    final bool isOutOfRange =
        segmentIndex < 0 || segmentIndex >= segmentBlurEnabled.length;

    if (isOutOfRange) {
      return;
    }

    setState(() {
      segmentBlurEnabled[segmentIndex] = !segmentBlurEnabled[segmentIndex];
    });
  }

  void advanceToNextWord() {
    final bool isUnmounted = !mounted;

    if (isUnmounted) {
      return;
    }

    final int nextWordIndex = currentWordIndex + 1;
    final bool isSegmentComplete = nextWordIndex >= currentWords.length;

    if (isSegmentComplete) {
      settleCurrentSegment();
      return;
    }

    setState(() {
      currentWordIndex = nextWordIndex;
    });

    scheduleNextWord();
  }

  // Freeze the current segment as static text and handle the last-segment
  // case by firing the completion callback.
  void settleCurrentSegment() {
    advanceTimer?.cancel();
    advanceTimer = null;

    setState(() {
      isCurrentSegmentStreaming = false;
      currentWordIndex = currentWords.length - 1;
    });

    final bool isLastSegment = currentSegmentIndex >= widget.textSegments.length - 1;
    final bool shouldFireCompletion = isLastSegment && !hasFiredCompletionCallback;

    if (shouldFireCompletion) {
      hasFiredCompletionCallback = true;

      Future.delayed(RSVP_COMPLETION_SETTLE_DELAY, () {
        final bool stillMounted = mounted;

        if (!stillMounted) {
          return;
        }

        widget.onAllSegmentsRevealed?.call();
      });
    }
  }

  void handleTap() {
    final bool isUnmounted = !mounted;

    if (isUnmounted) {
      return;
    }

    final bool shouldFastForward = isCurrentSegmentStreaming;

    if (shouldFastForward) {
      settleCurrentSegment();
      return;
    }

    final bool hasMoreSegments = currentSegmentIndex < widget.textSegments.length - 1;

    if (!hasMoreSegments) {
      return;
    }

    setState(() {
      currentSegmentIndex++;
      prepareSegmentAtIndex(currentSegmentIndex);
    });

    scheduleNextWord();
  }

  // Mirrors ProgressiveText's getConsistentTextStyle: forces fontSize 18 /
  // height 1.6 on top of whatever the caller passed (CCTextContent passes
  // readingMediumStyle = 16). Keeps the rendered reading size identical
  // between the typewriter and RSVP modes — switching the toggle in
  // Settings doesn't change how big the text looks.
  TextStyle getBaseTextStyle() {
    final TextStyle baseStyle = widget.textStyle ?? RLTypography.readingMediumStyle;

    return baseStyle.copyWith(fontSize: 18, height: 1.6);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Previously-revealed segments — each owns its own tap so a tap
        // there toggles the segment's blur (mirrors ProgressiveText) and
        // does NOT bubble up to the advance handler below.
        PreviousSegmentsList(),

        // Current segment area + filler share the advance gesture: tapping
        // the WordDisplay, the settled-current text, or anywhere below
        // either fast-forwards the stream or steps to the next segment.
        Expanded(
          child: GestureDetector(
            onTap: handleTap,
            behavior: HitTestBehavior.opaque,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CurrentSegmentArea(),

                const Expanded(child: SizedBox.expand()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Vertical list of every segment behind the current one. Each entry is
  // its own tappable BlurredSegment so the tap toggles that specific
  // segment's blur — mirroring ProgressiveText's per-sentence unblur.
  Widget PreviousSegmentsList() {
    final List<Widget> children = PreviousSegmentChildren();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  List<Widget> PreviousSegmentChildren() {
    final List<Widget> children = [];
    final TextStyle staticStyle = getBaseTextStyle();

    for (int segmentIndex = 0; segmentIndex < currentSegmentIndex; segmentIndex++) {
      children.add(
        BlurredSegment(
          segmentIndex: segmentIndex,
          segmentText: widget.textSegments[segmentIndex],
          segmentStyle: staticStyle,
        ),
      );

      children.add(const Spacing.height(RLDS.spacing12));
    }

    return children;
  }

  // Crossfade between the live word stream and the settled segment text.
  // AnimatedSwitcher's default builder is FadeTransition — exactly the
  // gentle opacity fade the user asked for when a segment finishes.
  Widget CurrentSegmentArea() {
    final TextStyle staticStyle = getBaseTextStyle();
    final Widget activeChild = isCurrentSegmentStreaming
        ? KeyedSubtree(
            key: ValueKey<String>('rsvp-streaming-$currentSegmentIndex'),
            child: WordDisplay(),
          )
        : KeyedSubtree(
            key: ValueKey<String>('rsvp-settled-$currentSegmentIndex'),
            child: SettledCurrentSegment(staticStyle),
          );

    return AnimatedSwitcher(
      duration: RSVP_SETTLE_FADE_DURATION,
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: activeChild,
    );
  }

  Widget SettledCurrentSegment(TextStyle staticStyle) {
    final bool isOutOfRange = currentSegmentIndex >= widget.textSegments.length;

    if (isOutOfRange) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.topLeft,
      child: Text(widget.textSegments[currentSegmentIndex], style: staticStyle),
    );
  }

  // Three-column flash: left-aligned pre-ORP, centred ORP letter, right-
  // aligned post-ORP. Using Expanded+Align on the outer columns pins the
  // ORP to the horizontal midpoint regardless of word length.
  Widget WordDisplay() {
    final String currentWord = currentWords[currentWordIndex];
    final int orpIndex = getRsvpOrpIndex(currentWord);
    final String preOrp = currentWord.substring(0, orpIndex);
    final String orpLetter = currentWord.substring(orpIndex, orpIndex + 1);
    final String postOrp = currentWord.substring(orpIndex + 1);

    final TextStyle baseStyle = getBaseTextStyle();
    final TextStyle orpStyle = baseStyle.copyWith(
      color: RLDS.primary,
      fontWeight: FontWeight.bold,
    );

    return SizedBox(
      height: RSVP_WORD_DISPLAY_HEIGHT,
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

  // Lyrics-style blur on a previously-read segment with its own tap
  // gesture: a tap toggles this segment's blur (mirrors ProgressiveText's
  // CompletedSentenceWidget) instead of bubbling up to the advance
  // handler, so reviewing a past segment doesn't accidentally skip the
  // current stream forward.
  Widget BlurredSegment({
    required int segmentIndex,
    required String segmentText,
    required TextStyle segmentStyle,
  }) {
    final bool isBlurred = segmentBlurEnabled[segmentIndex];

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => toggleBlurForSegment(segmentIndex),
      child: BlurOverlay(
        enabled: isBlurred,
        child: Text(segmentText, style: segmentStyle),
      ),
    );
  }
}
