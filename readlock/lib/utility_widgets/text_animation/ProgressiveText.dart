// Progressive text widget utility for typewriter-style text animation
// Provides ProgressiveText widget for character-by-character text reveal with sentence navigation

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/utility_widgets/visual_effects/BlurOverlay.dart';

// Class to represent a segment of text with optional highlighting
class TextSegmentWithHighlighting {
  final String textContent;
  final bool shouldBeHighlighted;
  final Color? highlightColor;
  final int segmentStartPosition;
  final int segmentEndPosition;

  const TextSegmentWithHighlighting({
    required this.textContent,
    required this.shouldBeHighlighted,
    required this.highlightColor,
    required this.segmentStartPosition,
    required this.segmentEndPosition,
  });
}

// Legacy class for backward compatibility
class HighlightSegment {
  final String text;
  final bool isHighlighted;
  final Color? color;
  final int startIndex;
  final int endIndex;

  const HighlightSegment({
    required this.text,
    required this.isHighlighted,
    required this.color,
    required this.startIndex,
    required this.endIndex,
  });
}

class ProgressiveText extends StatefulWidget {
  static const double DEFAULT_BOTTOM_SPACING = 8.0;
  static const Duration AUTO_REVEAL_DELAY = Duration(milliseconds: 300);

  // Required properties
  // List of text sentences to reveal progressively
  final List<String> textSegments;

  // Animation properties
  // Delay between each character reveal in milliseconds
  final Duration typewriterCharacterDelay;
  // Whether to automatically reveal next sentence after current one completes
  final bool automaticallyRevealNextSentence;

  // Visual styling properties
  // Text style to apply to all revealed text
  final TextStyle? textStyle;
  // Padding around the entire progressive text widget
  final EdgeInsets? contentPadding;
  // Cross axis alignment for text display
  final CrossAxisAlignment? textAlignment;

  // Blur effect properties for completed sentences
  // Whether to apply blur effect to completed sentences
  final bool blurCompletedSentences;
  // Intensity of the blur effect (sigma value)
  final double completedSentenceBlurIntensity;
  // Opacity level for completed sentences with blur
  final double completedSentenceOpacity;

  // Interaction properties
  // Custom tap callback (overrides default reveal behavior)
  final VoidCallback? onTapCallback;
  // Whether to enable tap interaction for revealing next sentence
  final bool enableTapToReveal;
  // Callback triggered when all text segments have been fully revealed
  final VoidCallback? onAllSegmentsRevealed;

  const ProgressiveText({
    super.key,
    required this.textSegments,
    this.typewriterCharacterDelay = const Duration(milliseconds: 10),
    this.automaticallyRevealNextSentence = false,
    this.textStyle,
    this.contentPadding,
    this.textAlignment,
    this.blurCompletedSentences = true,
    this.completedSentenceBlurIntensity = 4,
    this.completedSentenceOpacity = 0.2,
    this.onTapCallback,
    this.enableTapToReveal = true,
    this.onAllSegmentsRevealed,
  });

  @override
  State<ProgressiveText> createState() => ProgressiveTextState();
}

class ProgressiveTextState extends State<ProgressiveText> {
  // Text state management
  // All sentences to be displayed progressively
  late List<String> textSentences;
  // Blur on/off state for each completed sentence (true = blurred)
  late List<bool> sentenceBlurStates;

  // Animation state tracking
  // Index of the sentence currently being revealed (0-based)
  int currentSentenceNumber = 0;
  // Flag indicating if typewriter animation is actively running
  bool isRevealingCurrentSentence = false;

  // Current sentence reveal state
  // Full text of the sentence being animated
  String currentSentenceText = '';
  // Current character index in the typewriter animation
  int currentCharacterPosition = 0;
  // Portion of current sentence that has been revealed so far
  String revealedText = '';

  // Initializes the widget state when first created
  // Sets up text data and starts the typewriter animation for the first sentence
  @override
  void initState() {
    super.initState();

    // Set up the sentences array and blur states from widget properties
    initializeTextState();

    // Check if there's any content to display
    final bool hasSentencesToReveal = textSentences.isNotEmpty;

    if (hasSentencesToReveal) {
      // Prepare the first sentence for display
      initializeCurrentSentence();

      // Start the typewriter animation for the first sentence
      startCurrentSentenceReveal();
    }
  }

  // Resets the current sentence state to prepare for revealing a new sentence
  // Sets the text, resets character position, and clears revealed text
  void initializeCurrentSentence() {
    final bool hasCurrentSentence =
        currentSentenceNumber < textSentences.length;

    if (hasCurrentSentence) {
      // Use clean text for animation (without highlight markers)
      currentSentenceText = getCleanText(
        textSentences[currentSentenceNumber],
      );
      currentCharacterPosition = 0;
      revealedText = '';
    }
  }

  // Begins the typewriter animation for the current sentence
  // Reveals one character at a time with the specified delay
  // Automatically triggers next sentence if automaticallyRevealNextSentence is true
  void startCurrentSentenceReveal() async {
    final bool isAlreadyRevealing = isRevealingCurrentSentence;
    final bool hasTextToReveal = currentSentenceText.isNotEmpty;
    final bool canStartRevealAnimation =
        !isAlreadyRevealing && hasTextToReveal;

    if (!canStartRevealAnimation) {
      return;
    }

    final bool isWidgetStillMounted = mounted;

    if (isWidgetStillMounted) {
      setState(() {
        isRevealingCurrentSentence = true;
        currentCharacterPosition = 0;
        revealedText = '';
      });
    }

    int characterIndex = 0;

    while (characterIndex < currentSentenceText.length && mounted) {
      final bool isStillMounted = mounted;
      final bool isStillRevealing = isRevealingCurrentSentence;
      final bool shouldContinueAnimation =
          isStillMounted && isStillRevealing;

      if (!shouldContinueAnimation) {
        break;
      }

      final bool canUpdateState = mounted;

      if (canUpdateState) {
        setState(() {
          currentCharacterPosition = characterIndex;
          revealedText = currentSentenceText.substring(
            0,
            characterIndex + 1,
          );
        });
      }

      await Future.delayed(widget.typewriterCharacterDelay);
      characterIndex++;
    }

    final bool canCompleteRevealAnimation = mounted;

    if (canCompleteRevealAnimation) {
      setState(() {
        isRevealingCurrentSentence = false;
      });

      // Check if all sentences have been revealed
      final bool isLastSentence =
          currentSentenceNumber == textSentences.length - 1;

      if (isLastSentence && widget.onAllSegmentsRevealed != null) {
        widget.onAllSegmentsRevealed!();
      }

      final bool shouldAutoAdvanceToNextSentence =
          widget.automaticallyRevealNextSentence;

      if (shouldAutoAdvanceToNextSentence) {
        final bool hasMoreSentencesToReveal =
            currentSentenceNumber < textSentences.length - 1;

        if (hasMoreSentencesToReveal) {
          await Future.delayed(ProgressiveText.AUTO_REVEAL_DELAY);
          revealNextSentence();
        }
      }
    }
  }

  // Advances to the next sentence in the sequence
  // Updates the sentence counter and starts revealing the new sentence
  void revealNextSentence() {
    final bool hasMoreSentencesToReveal =
        currentSentenceNumber < textSentences.length - 1;
    final bool canUpdateUI = mounted;
    final bool shouldAdvanceToNextSentence =
        hasMoreSentencesToReveal && canUpdateUI;

    if (shouldAdvanceToNextSentence) {
      setState(() {
        currentSentenceNumber++;
      });

      initializeCurrentSentence();
      startCurrentSentenceReveal();
    }
  }

  // Immediately reveals all remaining text without animation
  // Jumps to the last sentence and displays it fully
  void revealAll() {
    final bool canRevealAllText = mounted;

    if (canRevealAllText) {
      setState(() {
        isRevealingCurrentSentence = false;
        currentSentenceNumber = textSentences.length - 1;

        initializeCurrentSentence();

        currentCharacterPosition = currentSentenceText.length - 1;
        revealedText = currentSentenceText;
      });
    }
  }

  // Handles tap interactions on the widget
  // Either calls custom callback or reveals the next sentence
  void handleTap() {
    final bool hasCustomCallback = widget.onTapCallback != null;

    if (hasCustomCallback) {
      widget.onTapCallback!();

      return;
    }

    final bool isNotCurrentlyAnimating = !isRevealingCurrentSentence;
    final bool hasUnrevealedSentences =
        currentSentenceNumber < textSentences.length - 1;
    final bool canAdvanceToNextSentenceOnTap =
        isNotCurrentlyAnimating && hasUnrevealedSentences;

    if (canAdvanceToNextSentenceOnTap) {
      revealNextSentence();
    }
  }

  // Toggles the blur effect on/off for a specific completed sentence
  // Allows users to tap completed sentences to make them readable again
  void toggleBlurForSentence(int sentenceIndex) {
    final bool isValidSentenceIndex =
        sentenceIndex < sentenceBlurStates.length;

    if (isValidSentenceIndex) {
      setState(() {
        sentenceBlurStates[sentenceIndex] =
            !sentenceBlurStates[sentenceIndex];
      });
    }
  }

  // Cleanup method called when widget is removed from the widget tree
  // Ensures animation state is properly reset
  @override
  void dispose() {
    isRevealingCurrentSentence = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Main content container
    final Widget content = Div.column([
      RevealedTextDisplay(),
    ], crossAxisAlignment: CrossAxisAlignment.start);

    final bool shouldDisableTapInteraction = !widget.enableTapToReveal;

    if (shouldDisableTapInteraction) {
      return content;
    }

    // Clickable wrapper with mouse cursor hint
    final Widget clickableContent = MouseRegion(
      cursor: SystemMouseCursors.click,
      child: content,
    );

    return Div.column(
      [clickableContent],
      onTap: handleTap,
      crossAxisAlignment: 'start',
    );
  }

  // Main display widget for revealed sentences
  Widget RevealedTextDisplay() {
    final List<Widget> sentenceWidgets = [];

    // Add completed sentence widgets
    for (int i = 0; i < currentSentenceNumber; i++) {
      sentenceWidgets.add(
        CompletedSentenceWidget(
          key: ValueKey('sentence_$i'),
          sentenceIndex: i,
          sentenceText: textSentences[i],
          shouldBlur: shouldBlurSentence(i),
          blurIntensity: widget.completedSentenceBlurIntensity,
          blurOpacity: widget.completedSentenceOpacity,
          textStyle: getConsistentTextStyle(),
          onTap: () => toggleBlurForSentence(i),
        ),
      );
    }

    // Add current sentence if it exists
    final bool hasActiveSentenceToDisplay =
        currentSentenceNumber < textSentences.length;

    if (hasActiveSentenceToDisplay) {
      sentenceWidgets.add(CurrentSentenceDisplay());
    }

    return Div.column(
      sentenceWidgets,
      crossAxisAlignment: CrossAxisAlignment.start,
    );
  }

  // Display widget for currently revealing sentence
  Widget CurrentSentenceDisplay() {
    if (revealedText.isEmpty) {
      return const SizedBox.shrink();
    }

    final String originalText = textSentences[currentSentenceNumber];
    final bool hasHighlights = originalText.contains('<c:');

    if (hasHighlights) {
      return buildProgressiveHighlightedText(
        originalText,
        revealedText,
      );
    }

    // Simplified regular text without highlights - no unnecessary wrapping
    return RichText(
      textAlign: TextAlign.left,
      text: TextSpan(
        text: revealedText,
        style: getConsistentTextStyle(),
      ),
    );
  }

  // Build progressively revealed text with highlighting
  Widget buildProgressiveHighlightedText(
    String originalText,
    String revealedCleanText,
  ) {
    final List<TextSpan> spans = _buildProgressiveHighlightSpans(
      originalText,
      revealedCleanText,
    );

    return RichText(
      text: TextSpan(children: spans),
      textAlign: TextAlign.left,
    );
  }

  // Optimized method to build highlight spans without intermediate objects
  List<TextSpan> _buildProgressiveHighlightSpans(
    String originalText,
    String revealedCleanText,
  ) {
    final List<TextSpan> spans = [];
    final RegExp highlightRegex = RegExp(r'<c:(g)>([^<]*)</c:\1>');
    String remaining = originalText;
    int cleanTextPosition = 0;
    final int revealedLength = revealedCleanText.length;
    final TextStyle baseStyle = getConsistentTextStyle();

    while (remaining.isNotEmpty && cleanTextPosition < revealedLength) {
      final RegExpMatch? match = highlightRegex.firstMatch(remaining);

      if (match == null) {
        // Handle remaining text without highlights
        final int remainingRevealLength =
            revealedLength - cleanTextPosition;
        if (remainingRevealLength > 0) {
          final String visibleText =
              remaining.length <= remainingRevealLength
              ? remaining
              : remaining.substring(0, remainingRevealLength);
          spans.add(TextSpan(text: visibleText, style: baseStyle));
        }
        break;
      }

      // Handle text before highlight
      if (match.start > 0) {
        final String beforeText = remaining.substring(0, match.start);
        final int beforeTextEnd = cleanTextPosition + beforeText.length;

        if (cleanTextPosition < revealedLength) {
          final int visibleLength = (beforeTextEnd <= revealedLength)
              ? beforeText.length
              : revealedLength - cleanTextPosition;

          if (visibleLength > 0) {
            spans.add(
              TextSpan(
                text: beforeText.substring(0, visibleLength),
                style: baseStyle,
              ),
            );
          }
        }

        cleanTextPosition += beforeText.length;
        if (cleanTextPosition >= revealedLength) {
          break;
        }
      }

      // Handle highlighted text
      final String colorCode = match.group(1)!;
      final String highlightedText = match.group(2)!;
      final int highlightEnd =
          cleanTextPosition + highlightedText.length;

      if (cleanTextPosition < revealedLength) {
        final int visibleLength = (highlightEnd <= revealedLength)
            ? highlightedText.length
            : revealedLength - cleanTextPosition;

        if (visibleLength > 0) {
          final Color highlightColor = getHighlightColor(colorCode);
          spans.add(
            TextSpan(
              text: highlightedText.substring(0, visibleLength),
              style: baseStyle.copyWith(
                color: highlightColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }
      }

      cleanTextPosition += highlightedText.length;
      remaining = remaining.substring(match.end);
    }

    return spans;
  }

  // Build spans for visible text segments
  List<TextSpan> buildVisibleSpans(
    List<HighlightSegment> segments,
    String revealedCleanText,
  ) {
    final List<TextSpan> spans = [];
    int cleanTextPosition = 0;

    for (final segment in segments) {
      final int segmentStart = cleanTextPosition;
      final int segmentEnd = cleanTextPosition + segment.text.length;
      final int revealedLength = revealedCleanText.length;

      final bool segmentNotReachedYet = revealedLength <= segmentStart;

      if (segmentNotReachedYet) {
        break;
      }

      final bool segmentPartiallyVisible = revealedLength < segmentEnd;
      final int visibleEnd = segmentPartiallyVisible
          ? revealedLength
          : segmentEnd;

      final bool hasVisibleContent = visibleEnd > segmentStart;

      if (hasVisibleContent) {
        final String visibleText = segment.text.substring(
          0,
          visibleEnd - segmentStart,
        );

        final TextStyle spanStyle = getSpanStyle(segment);

        spans.add(TextSpan(text: visibleText, style: spanStyle));
      }

      cleanTextPosition += segment.text.length;
    }

    return spans;
  }

  // Get text style for a highlight segment
  TextStyle getSpanStyle(HighlightSegment segment) {
    final bool isHighlighted = segment.isHighlighted;
    final TextStyle baseStyle = getConsistentTextStyle();

    final TextStyle highlightedStyle = baseStyle.copyWith(
      color: segment.color,
      fontWeight: FontWeight.bold,
    );

    return isHighlighted ? highlightedStyle : baseStyle;
  }

  // Helper methods

  // Initializes the text sentences and blur states from widget properties
  // Called once during initState to set up the initial data
  void initializeTextState() {
    textSentences = widget.textSegments;
    sentenceBlurStates = List.filled(textSentences.length, true);
  }

  // Remove highlight markers and return clean text for animation
  String removeHighlightMarkersFromText(String originalText) {
    return originalText.replaceAll(RegExp(r'<c:g>|</c:g>'), '');
  }

  // Check if text contains educational highlight markers
  bool textContainsEducationalHighlights(String text) {
    return text.contains('<c:');
  }

  // Legacy method aliases for compatibility
  String getCleanText(String originalText) {
    return removeHighlightMarkersFromText(originalText);
  }

  bool hasHighlightMarkers(String text) {
    return textContainsEducationalHighlights(text);
  }

  List<HighlightSegment> parseHighlights(String originalText) {
    final segments = parseTextIntoHighlightSegments(originalText);

    return segments
        .map(
          (segment) => HighlightSegment(
            text: segment.textContent,
            isHighlighted: segment.shouldBeHighlighted,
            color: segment.highlightColor,
            startIndex: segment.segmentStartPosition,
            endIndex: segment.segmentEndPosition,
          ),
        )
        .toList();
  }

  // Parse text into segments with highlight information for rendering
  List<TextSegmentWithHighlighting> parseTextIntoHighlightSegments(
    String originalText,
  ) {
    final List<TextSegmentWithHighlighting> segments = [];
    String remaining = originalText;
    int offset = 0;

    while (remaining.isNotEmpty) {
      final RegExpMatch? match = RegExp(
        r'<c:(g)>([^<]*)</c:\1>',
      ).firstMatch(remaining);

      final bool hasNoMoreHighlights = match == null;

      if (hasNoMoreHighlights) {
        final bool hasRemainingText = remaining.isNotEmpty;

        if (hasRemainingText) {
          segments.add(
            TextSegmentWithHighlighting(
              textContent: remaining,
              shouldBeHighlighted: false,
              highlightColor: null,
              segmentStartPosition: offset,
              segmentEndPosition: offset + remaining.length,
            ),
          );
        }
        break;
      }

      final bool hasTextBeforeHighlight = match.start > 0;

      if (hasTextBeforeHighlight) {
        final String beforeText = remaining.substring(0, match.start);

        segments.add(
          TextSegmentWithHighlighting(
            textContent: beforeText,
            shouldBeHighlighted: false,
            highlightColor: null,
            segmentStartPosition: offset,
            segmentEndPosition: offset + beforeText.length,
          ),
        );

        offset += beforeText.length;
      }

      final String colorCode = match.group(1)!;
      final String highlightedText = match.group(2)!;
      final Color highlightColor = getHighlightColor(colorCode);

      segments.add(
        TextSegmentWithHighlighting(
          textContent: highlightedText,
          shouldBeHighlighted: true,
          highlightColor: highlightColor,
          segmentStartPosition: offset,
          segmentEndPosition: offset + highlightedText.length,
        ),
      );

      offset += highlightedText.length;

      remaining = remaining.substring(match.end);
    }

    return segments;
  }

  // Get color based on marker code
  Color getHighlightColor(String code) {
    switch (code) {
      case 'g':
        return Colors.green.shade600;
      default:
        return Colors.green.shade600; // Fallback to green for any unknown codes
    }
  }

  // Determines whether a specific sentence should have blur effect applied
  // Returns true if blur is enabled and the sentence's blur state is active
  bool shouldBlurSentence(int sentenceIndex) {
    final bool isBlurFeatureDisabled = !widget.blurCompletedSentences;

    if (isBlurFeatureDisabled) {
      return false;
    }

    final bool isIndexOutOfBounds =
        sentenceIndex >= sentenceBlurStates.length;

    if (isIndexOutOfBounds) {
      return false;
    }

    return sentenceBlurStates[sentenceIndex];
  }

  // Create text widget for a specific sentence
  Widget SentenceText(int sentenceIndex) {
    final String originalText = textSentences[sentenceIndex];

    // Check if text has highlights
    if (hasHighlightMarkers(originalText)) {
      return buildHighlightedText(originalText);
    }

    // Regular text without highlights
    return Text(
      originalText,
      style: getConsistentTextStyle(),
      textAlign: TextAlign.left,
    );
  }

  // Build text with highlighting support
  Widget buildHighlightedText(String text) {
    final List<HighlightSegment> segments = parseHighlights(text);
    final List<TextSpan> spans = [];

    for (final segment in segments) {
      final TextStyle baseStyle = getConsistentTextStyle();
      final TextStyle highlightedStyle = baseStyle.copyWith(
        color: segment.color,
        fontWeight: FontWeight.bold,
      );
      final TextStyle segmentStyle = segment.isHighlighted
          ? highlightedStyle
          : baseStyle;

      spans.add(TextSpan(text: segment.text, style: segmentStyle));
    }

    return RichText(
      text: TextSpan(children: spans),
      textAlign: TextAlign.left,
    );
  }

  // Get consistent text style for all text (both revealed and completed)
  // Ensures no visual jump when toggling blur state
  TextStyle getConsistentTextStyle() {
    final TextStyle baseStyle =
        widget.textStyle ?? RLTypography.bodyMediumStyle;

    return baseStyle.copyWith(fontSize: 16, height: 1.5);
  }
}

// Separate widget for completed sentences to prevent unnecessary rebuilds
class CompletedSentenceWidget extends StatelessWidget {
  final int sentenceIndex;
  final String sentenceText;
  final bool shouldBlur;
  final double blurIntensity;
  final double blurOpacity;
  final TextStyle textStyle;
  final VoidCallback onTap;

  const CompletedSentenceWidget({
    super.key,
    required this.sentenceIndex,
    required this.sentenceText,
    required this.shouldBlur,
    required this.blurIntensity,
    required this.blurOpacity,
    required this.textStyle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget sentenceWidget = Div.column(
      [_buildSentenceText()],
      crossAxisAlignment: CrossAxisAlignment.start,
      padding: const [0, 0, ProgressiveText.DEFAULT_BOTTOM_SPACING, 0],
    );

    if (shouldBlur) {
      sentenceWidget = BlurOverlay(
        blurSigma: blurIntensity,
        opacity: blurOpacity,
        child: sentenceWidget,
      );
    }

    return Div.column(
      [sentenceWidget],
      crossAxisAlignment: CrossAxisAlignment.start,
      onTap: onTap,
    );
  }

  Widget _buildSentenceText() {
    // Check if text has highlights
    final bool hasHighlights = sentenceText.contains('<c:');

    if (hasHighlights) {
      return _buildHighlightedText();
    }

    return Text(
      sentenceText,
      style: textStyle,
      textAlign: TextAlign.left,
    );
  }

  Widget _buildHighlightedText() {
    final List<TextSpan> spans = [];
    final RegExp highlightRegex = RegExp(r'<c:(g)>([^<]*)</c:\1>');
    String remaining = sentenceText;

    while (remaining.isNotEmpty) {
      final RegExpMatch? match = highlightRegex.firstMatch(remaining);

      if (match == null) {
        // Add remaining text without highlighting
        if (remaining.isNotEmpty) {
          spans.add(TextSpan(text: remaining, style: textStyle));
        }
        break;
      }

      // Add text before highlight
      if (match.start > 0) {
        final String beforeText = remaining.substring(0, match.start);
        spans.add(TextSpan(text: beforeText, style: textStyle));
      }

      // Add highlighted text
      final String colorCode = match.group(1)!;
      final String highlightedText = match.group(2)!;
      final Color highlightColor = _getHighlightColor(colorCode);

      spans.add(
        TextSpan(
          text: highlightedText,
          style: textStyle.copyWith(
            color: highlightColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      remaining = remaining.substring(match.end);
    }

    return RichText(
      text: TextSpan(children: spans),
      textAlign: TextAlign.left,
    );
  }

  Color _getHighlightColor(String code) {
    switch (code) {
      case 'g':
        return Colors.green.shade600;
      case 'r':
        return Colors.red.shade600;
      default:
        return Colors.grey;
    }
  }
}
