// 8-bit starfield background — a field of square pixel "stars" that drift
// slowly (parallax-layered). Designed to sit behind the course roadmap.
//
// Sharp rectangular dots, no anti-aliasing, no twinkling — just a calm
// slow scroll to give the screen a tiny bit of life.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:readlock/constants/RLDesignSystem.dart';

// * Tuning defaults — tweak at the call site via constructor props.
const int STARFIELD_DEFAULT_STAR_COUNT = 80;
const double STARFIELD_DEFAULT_STAR_SIZE = 2.0;
const double STARFIELD_DEFAULT_DRIFT_SPEED = 8.0;
const int STARFIELD_RANDOM_SEED = 42;
// Pitch-black background — RLDS.black is a near-black grey, we want the
// actual void behind the pixel stars.
const Color STARFIELD_BACKGROUND_COLOR = Color(0xFF000000);

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

class RLStarfieldBackgroundState extends State<RLStarfieldBackground>
    with SingleTickerProviderStateMixin {
  late Ticker ticker;
  late List<StarSpec> stars;
  double elapsedSeconds = 0.0;

  @override
  void initState() {
    super.initState();
    stars = generateStars();
    ticker = createTicker(handleTick);
    ticker.start();
  }

  @override
  void dispose() {
    ticker.dispose();
    super.dispose();
  }

  void handleTick(Duration elapsed) {
    setState(() {
      elapsedSeconds = elapsed.inMicroseconds / 1e6;
    });
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

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: STARFIELD_BACKGROUND_COLOR,
      child: SizedBox.expand(
        child: CustomPaint(
          painter: StarfieldPainter(
            stars: stars,
            elapsedSeconds: elapsedSeconds,
            driftSpeed: widget.driftSpeed,
            starColor: widget.starColor,
          ),
        ),
      ),
    );
  }
}

class StarfieldPainter extends CustomPainter {
  final List<StarSpec> stars;
  final double elapsedSeconds;
  final double driftSpeed;
  final Color starColor;

  const StarfieldPainter({
    required this.stars,
    required this.elapsedSeconds,
    required this.driftSpeed,
    required this.starColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bool hasNoArea = size.width <= 0 || size.height <= 0;

    if (hasNoArea) {
      return;
    }

    final Paint paint = Paint()
      ..isAntiAlias = false
      ..filterQuality = FilterQuality.none;

    for (final StarSpec star in stars) {
      final double baseY = star.normalizedY * size.height;
      final double drift = elapsedSeconds * driftSpeed * star.speedMultiplier;
      // Wrap around the top as stars scroll off the bottom so the field loops.
      final double y = (baseY + drift) % size.height;
      final double x = star.normalizedX * size.width;

      paint.color = starColor.withValues(alpha: star.opacity);

      final Rect starRect = Rect.fromLTWH(x, y, star.size, star.size);

      canvas.drawRect(starRect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant StarfieldPainter oldDelegate) {
    final bool timeChanged = oldDelegate.elapsedSeconds != elapsedSeconds;
    final bool colorChanged = oldDelegate.starColor != starColor;
    final bool speedChanged = oldDelegate.driftSpeed != driftSpeed;

    return timeChanged || colorChanged || speedChanged;
  }
}
