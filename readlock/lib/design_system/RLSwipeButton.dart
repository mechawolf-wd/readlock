// Slide-to-confirm button. Centralised swipe primitive for any irreversible
// action that benefits from a deliberate physical commitment instead of a
// single tap. The reader drags the thumb the full width of the track to
// fire onConfirm; releasing early snaps the thumb back to rest.
//
// Sized to mirror RLButton's natural height (vertical spacing16 padding
// around an iconLarge thumb glyph) so the swipe surface drops into any
// column where an RLButton would sit. Corners are intentionally sharp
// (no radius anywhere on this surface) to flag the swipe as a different
// affordance from the rest of the bordered, rounded UI. The progress
// fill and the thumb share the caller's colour and live inside the
// same vertical inset, so as the bar grows it reads as one continuous
// strip with the thumb at its leading edge instead of a separate puck.
// Haptics fire at three moments: light on grab, a selection click at
// the commit threshold, and a heavy impact on release.

import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/services/feedback/HapticsService.dart';

// Geometry. Track height is computed from RLButton's vertical padding
// and the icon glyph the thumb carries, so the swipe button stands at
// the same height an RLButton would render with a label of similar
// content weight (16 + 24 + 16 = 56). The thumb and the progress fill
// both sit inside a shared vertical inset (border + breathing room)
// so they share the same top / bottom margin and read as one element.
const double RL_SWIPE_BUTTON_VERTICAL_PADDING = RLDS.spacing16;
const double RL_SWIPE_BUTTON_TRACK_HEIGHT =
    (RL_SWIPE_BUTTON_VERTICAL_PADDING * 2) + RLDS.iconLarge;

// Breathing room between the thumb / fill and the painted border, on
// top of the borderWidth itself. Picks the design-system 4px step so
// the thumb visibly floats inside the track instead of butting up
// against the line. Applied symmetrically to all four sides so the
// thumb's left / right gap at rest matches the top / bottom gap.
const double RL_SWIPE_BUTTON_INNER_INSET = RLDS.spacing4;
const double RL_SWIPE_BUTTON_INNER_PADDING =
    RLDS.borderWidth + RL_SWIPE_BUTTON_INNER_INSET;
const double RL_SWIPE_BUTTON_THUMB_SIZE =
    RL_SWIPE_BUTTON_TRACK_HEIGHT - (RL_SWIPE_BUTTON_INNER_PADDING * 2);

// Drag fraction past which a release will commit instead of snap back.
// Tuned high enough that an accidental nudge cannot fire the action, low
// enough that the reader does not need pixel-perfect travel to the edge.
const double RL_SWIPE_BUTTON_CONFIRM_THRESHOLD = 0.92;

// Snap-back duration when the user releases below the threshold. Short
// enough to feel responsive, long enough to read as a deliberate undo.
const Duration RL_SWIPE_BUTTON_SNAP_DURATION = Duration(milliseconds: 220);

// Track base tint. Sits at 15% of the caller colour so the empty track
// reads as a soft chamber; the progress fill paints in the caller's
// solid colour (matching the thumb) so the two merge into one bar.
const double RL_SWIPE_BUTTON_TRACK_BASE_ALPHA = 0.15;

class RLSwipeButton extends StatefulWidget {
  final String label;
  final Color color;
  final IconData thumbIcon;
  final VoidCallback onConfirm;

  const RLSwipeButton({
    super.key,
    required this.label,
    required this.color,
    required this.onConfirm,
    this.thumbIcon = Pixel.arrowright,
  });

  @override
  State<RLSwipeButton> createState() => RLSwipeButtonState();
}

class RLSwipeButtonState extends State<RLSwipeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController snapController;
  double dragFraction = 0.0;
  double snapStartFraction = 0.0;
  double trackPixelWidth = 0.0;
  bool hasCrossedThreshold = false;
  bool hasCommitted = false;

  @override
  void initState() {
    super.initState();

    snapController = AnimationController(
      vsync: this,
      duration: RL_SWIPE_BUTTON_SNAP_DURATION,
    );

    snapController.addListener(handleSnapTick);
  }

  @override
  void dispose() {
    snapController.removeListener(handleSnapTick);
    snapController.dispose();

    super.dispose();
  }

  void handleSnapTick() {
    setState(() {
      dragFraction = snapStartFraction * (1.0 - snapController.value);
    });
  }

  void handleDragStart(DragStartDetails details) {
    if (hasCommitted) {
      return;
    }

    snapController.stop();
    HapticsService.lightImpact();

    setState(() {
      hasCrossedThreshold = false;
    });
  }

  void handleDragUpdate(DragUpdateDetails details) {
    if (hasCommitted) {
      return;
    }

    final double thumbTravel = trackPixelWidth - RL_SWIPE_BUTTON_THUMB_SIZE;
    final bool hasUsableTrack = thumbTravel > 0;

    if (!hasUsableTrack) {
      return;
    }

    final double nextFraction = (dragFraction + (details.delta.dx / thumbTravel))
        .clamp(0.0, 1.0);

    final bool justCrossedThreshold = !hasCrossedThreshold &&
        nextFraction >= RL_SWIPE_BUTTON_CONFIRM_THRESHOLD;

    if (justCrossedThreshold) {
      HapticsService.selectionClick();
    }

    setState(() {
      dragFraction = nextFraction;
      hasCrossedThreshold = nextFraction >= RL_SWIPE_BUTTON_CONFIRM_THRESHOLD;
    });
  }

  void handleDragEnd(DragEndDetails details) {
    if (hasCommitted) {
      return;
    }

    final bool shouldCommit = dragFraction >= RL_SWIPE_BUTTON_CONFIRM_THRESHOLD;

    if (shouldCommit) {
      commitConfirmation();

      return;
    }

    startSnapBack();
  }

  void commitConfirmation() {
    setState(() {
      hasCommitted = true;
      dragFraction = 1.0;
    });

    HapticsService.heavyImpact();

    widget.onConfirm();
  }

  void startSnapBack() {
    snapStartFraction = dragFraction;
    snapController.value = 0.0;
    snapController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final Color trackBaseColor = widget.color.withValues(
      alpha: RL_SWIPE_BUTTON_TRACK_BASE_ALPHA,
    );

    // Fill matches the thumb 1:1 so the thumb dissolves into the bar
    // it leaves behind, instead of reading as a separate slider puck.
    final Color trackFillColor = widget.color;

    // Sharp corners are intentional on this surface, see the file
    // header. Border outlines the empty track; the fill and thumb live
    // inside the symmetric padding so they share the same vertical
    // inset.
    final BoxDecoration trackDecoration = BoxDecoration(
      color: trackBaseColor,
      border: Border.all(color: widget.color, width: RLDS.borderWidth),
    );

    const EdgeInsets innerPadding = EdgeInsets.all(RL_SWIPE_BUTTON_INNER_PADDING);

    return Container(
      height: RL_SWIPE_BUTTON_TRACK_HEIGHT,
      decoration: trackDecoration,
      child: Padding(
        padding: innerPadding,
        child: LayoutBuilder(
          builder: (context, constraints) {
            trackPixelWidth = constraints.maxWidth;

            return Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Progress fill: grows from the left as the thumb travels.
                ProgressFill(fraction: dragFraction, fillColor: trackFillColor),

                // Centre label, dims as the thumb passes over it. Painted
                // in the caller's colour so it reads as part of the
                // bordered surface.
                TrackLabel(
                  label: widget.label,
                  color: widget.color,
                  fadeFraction: dragFraction,
                ),

                // Draggable thumb.
                ThumbHandle(
                  fraction: dragFraction,
                  color: widget.color,
                  icon: widget.thumbIcon,
                  onDragStart: handleDragStart,
                  onDragUpdate: handleDragUpdate,
                  onDragEnd: handleDragEnd,
                  trackWidth: constraints.maxWidth,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class ProgressFill extends StatelessWidget {
  final double fraction;
  final Color fillColor;

  const ProgressFill({super.key, required this.fraction, required this.fillColor});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: fraction,
        child: ColoredBox(color: fillColor),
      ),
    );
  }
}

class TrackLabel extends StatelessWidget {
  final String label;
  final Color color;
  final double fadeFraction;

  const TrackLabel({
    super.key,
    required this.label,
    required this.color,
    required this.fadeFraction,
  });

  @override
  Widget build(BuildContext context) {
    final double labelOpacity = (1.0 - fadeFraction).clamp(0.0, 1.0);

    return Positioned.fill(
      child: Center(
        child: Opacity(
          opacity: labelOpacity,
          child: RLTypography.bodyLarge(label, color: color),
        ),
      ),
    );
  }
}

class ThumbHandle extends StatelessWidget {
  final double fraction;
  final double trackWidth;
  final Color color;
  final IconData icon;
  final void Function(DragStartDetails) onDragStart;
  final void Function(DragUpdateDetails) onDragUpdate;
  final void Function(DragEndDetails) onDragEnd;

  const ThumbHandle({
    super.key,
    required this.fraction,
    required this.trackWidth,
    required this.color,
    required this.icon,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    final double thumbTravel = trackWidth - RL_SWIPE_BUTTON_THUMB_SIZE;
    final bool hasUsableTrack = thumbTravel > 0;
    final double safeTravel = hasUsableTrack ? thumbTravel : 0.0;
    final double thumbOffset = safeTravel * fraction;

    // Sharp-cornered thumb. Shares the caller colour with the progress
    // fill so the bar reads as one continuous strip, with the thumb
    // sitting at its leading edge.
    final BoxDecoration thumbDecoration = BoxDecoration(color: color);

    final Widget ThumbIcon = Icon(
      icon,
      color: RLDS.white,
      size: RLDS.iconLarge,
    );

    return Positioned(
      left: thumbOffset,
      top: 0,
      child: GestureDetector(
        onHorizontalDragStart: onDragStart,
        onHorizontalDragUpdate: onDragUpdate,
        onHorizontalDragEnd: onDragEnd,
        child: Container(
          width: RL_SWIPE_BUTTON_THUMB_SIZE,
          height: RL_SWIPE_BUTTON_THUMB_SIZE,
          decoration: thumbDecoration,
          alignment: Alignment.center,
          child: ThumbIcon,
        ),
      ),
    );
  }
}
