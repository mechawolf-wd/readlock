// 8-bit starfield background — a field of square pixel "stars" that drift
// slowly (parallax-layered). Designed to sit behind the course roadmap.
//
// Sharp rectangular dots, no anti-aliasing, no twinkling — just a calm
// slow scroll to give the screen a tiny bit of life.
//
// The drift clock is shared across every mounted RLStarfieldBackground via
// StarfieldClock so navigating between screens (roadmap → bird loader →
// course viewer) never snaps the drift back to 0. Instances subscribe on
// mount, unsubscribe on dispose; the stopwatch pauses only while zero
// starfields are on screen and resumes from where it left off otherwise.

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:readlock/constants/RLDesignSystem.dart';

// * Tuning defaults, tweak at the call site via constructor props.
const int STARFIELD_DEFAULT_STAR_COUNT = 80;
const double STARFIELD_DEFAULT_STAR_SIZE = 2.0;
const double STARFIELD_DEFAULT_DRIFT_SPEED = 8.0;
const int STARFIELD_RANDOM_SEED = 42;

// Quantize the shared clock so painters only repaint ~20x per second
// instead of every display refresh. The drift is slow (8 px/s), so this
// is visually indistinguishable from per-frame updates but cuts paint
// work by 3-6x on high-refresh displays and on the web canvas.
const double STARFIELD_TICK_INTERVAL_SECONDS = 0.05;
// Pitch-black background — RLDS.black is a near-black grey, we want the
// actual void behind the pixel stars.
const Color STARFIELD_BACKGROUND_COLOR = Color(0xFF000000);

// * Shared app-wide drift clock. A Stopwatch is the source of truth so
// stop/start cycles preserve the elapsed value, and a Ticker is used only
// to pump a `ValueNotifier` at display refresh rate while at least one
// starfield is subscribed.
class StarfieldClock {
  static final ValueNotifier<double> elapsed = ValueNotifier<double>(0.0);
  static final Stopwatch stopwatch = Stopwatch();
  static Ticker? ticker;
  static int subscriberCount = 0;

  static void subscribe() {
    subscriberCount++;

    final bool isFirstSubscriber = subscriberCount == 1;

    if (!isFirstSubscriber) {
      return;
    }

    stopwatch.start();
    ticker ??= Ticker(handleTick);

    final Ticker activeTicker = ticker!;
    final bool tickerIsStopped = !activeTicker.isActive;

    if (tickerIsStopped) {
      activeTicker.start();
    }
  }

  static void unsubscribe() {
    subscriberCount--;

    final bool hasSubscribers = subscriberCount > 0;

    if (hasSubscribers) {
      return;
    }

    subscriberCount = 0;
    ticker?.stop();
    stopwatch.stop();
  }

  static void handleTick(Duration unused) {
    final double rawElapsedSeconds = stopwatch.elapsedMicroseconds / 1e6;
    final double quantizedElapsedSeconds =
        (rawElapsedSeconds / STARFIELD_TICK_INTERVAL_SECONDS).floorToDouble() *
            STARFIELD_TICK_INTERVAL_SECONDS;

    final bool bucketUnchanged = quantizedElapsedSeconds == elapsed.value;

    if (bucketUnchanged) {
      return;
    }

    elapsed.value = quantizedElapsedSeconds;
  }
}

// * One star's immutable spec — position is a 0..1 normalised coordinate so
// the painter can map it to whatever size the widget resolves to.
class StarSpec {
  final double normalizedX;
  final double normalizedY;
  final double size;
  final double opacity;
  final double speedMultiplier;

  const StarSpec({
    required this.normalizedX,
    required this.normalizedY,
    required this.size,
    required this.opacity,
    required this.speedMultiplier,
  });
}

class RLStarfieldBackground extends StatefulWidget {
  final int starCount;
  final double starSize;
  final double driftSpeed;
  final Color starColor;

  const RLStarfieldBackground({
    super.key,
    this.starCount = STARFIELD_DEFAULT_STAR_COUNT,
    this.starSize = STARFIELD_DEFAULT_STAR_SIZE,
    this.driftSpeed = STARFIELD_DEFAULT_DRIFT_SPEED,
    this.starColor = RLDS.onSurface,
  });

  @override
  State<RLStarfieldBackground> createState() => RLStarfieldBackgroundState();
}

class RLStarfieldBackgroundState extends State<RLStarfieldBackground> {
  late List<StarSpec> stars;
  late List<Color> starColors;

  @override
  void initState() {
    super.initState();
    stars = generateStars();
    starColors = computeStarColors();
    StarfieldClock.subscribe();
  }

  @override
  void didUpdateWidget(covariant RLStarfieldBackground oldWidget) {
    super.didUpdateWidget(oldWidget);

    final bool starCountChanged = oldWidget.starCount != widget.starCount;
    final bool starSizeChanged = oldWidget.starSize != widget.starSize;
    final bool starColorChanged = oldWidget.starColor != widget.starColor;

    final bool needsRegenerate = starCountChanged || starSizeChanged;

    if (needsRegenerate) {
      stars = generateStars();
    }

    if (needsRegenerate || starColorChanged) {
      starColors = computeStarColors();
    }
  }

  @override
  void dispose() {
    StarfieldClock.unsubscribe();
    super.dispose();
  }

  List<StarSpec> generateStars() {
    final Random random = Random(STARFIELD_RANDOM_SEED);

    return List.generate(widget.starCount, (starIndex) {
      return StarSpec(
        normalizedX: random.nextDouble(),
        normalizedY: random.nextDouble(),
        // Size jitter: 0.8..2.0x the base so the field has depth.
        size: widget.starSize * (0.8 + random.nextDouble() * 1.2),
        // Opacity jitter: 0.35..1.0 so dim stars recede, bright ones pop.
        opacity: 0.35 + random.nextDouble() * 0.65,
        // Parallax layers: 0.4..1.4x the base drift speed.
        speedMultiplier: 0.4 + random.nextDouble() * 1.0,
      );
    });
  }

  List<Color> computeStarColors() {
    return List<Color>.generate(
      stars.length,
      (starIndex) => widget.starColor.withValues(alpha: stars[starIndex].opacity),
      growable: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: STARFIELD_BACKGROUND_COLOR,
      child: RepaintBoundary(
        child: SizedBox.expand(
          child: CustomPaint(
            painter: StarfieldPainter(
              stars: stars,
              starColors: starColors,
              elapsedListenable: StarfieldClock.elapsed,
              driftSpeed: widget.driftSpeed,
            ),
          ),
        ),
      ),
    );
  }
}

class StarfieldPainter extends CustomPainter {
  final List<StarSpec> stars;
  final List<Color> starColors;
  final ValueListenable<double> elapsedListenable;
  final double driftSpeed;

  StarfieldPainter({
    required this.stars,
    required this.starColors,
    required this.elapsedListenable,
    required this.driftSpeed,
  }) : super(repaint: elapsedListenable);

  @override
  void paint(Canvas canvas, Size size) {
    final bool hasNoArea = size.width <= 0 || size.height <= 0;

    if (hasNoArea) {
      return;
    }

    final double elapsedSeconds = elapsedListenable.value;

    final Paint paint = Paint()
      ..isAntiAlias = false
      ..filterQuality = FilterQuality.none;

    final int starCount = stars.length;

    for (int starIndex = 0; starIndex < starCount; starIndex++) {
      final StarSpec star = stars[starIndex];

      final double baseY = star.normalizedY * size.height;
      final double drift = elapsedSeconds * driftSpeed * star.speedMultiplier;
      // Wrap around the top as stars scroll off the bottom so the field loops.
      final double y = (baseY + drift) % size.height;
      final double x = star.normalizedX * size.width;

      paint.color = starColors[starIndex];

      final Rect starRect = Rect.fromLTWH(x, y, star.size, star.size);

      canvas.drawRect(starRect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant StarfieldPainter oldDelegate) {
    final bool listenableChanged = oldDelegate.elapsedListenable != elapsedListenable;
    final bool colorsChanged = oldDelegate.starColors != starColors;
    final bool speedChanged = oldDelegate.driftSpeed != driftSpeed;

    return listenableChanged || colorsChanged || speedChanged;
  }
}
