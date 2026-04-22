// Bird picker shared state, data, and sprite widget
// The selected bird is held in a top-level ValueNotifier so any screen
// (menu, bookshelf header, etc.) can observe and react via ValueListenableBuilder.

import 'package:flame/cache.dart';
import 'package:flame/extensions.dart';
import 'package:flame/widgets.dart';
import 'package:flutter/material.dart';
import 'package:readlock/constants/RLUIStrings.dart';

// * Sprite sheet layout — every bird sits in 32x32 art centered inside a
// 64x64 cell. The widget samples the inner region per frame to drop the
// transparent padding around each bird.
const double BIRD_FRAME_SIZE = 64.0;
const double BIRD_CONTENT_SIZE = 32.0;
const double BIRD_ANIMATION_STEP_TIME = 0.20;
const double BIRD_PREVIEW_SIZE_LARGE = 128.0;
const double BIRD_PREVIEW_SIZE_SMALL = 96.0;
const String BIRD_ASSET_PREFIX = 'assets/birds/';

class BirdOption {
  final String name;
  final String assetFile;
  final int firstFrame;
  final int frameCount;

  const BirdOption({
    required this.name,
    required this.assetFile,
    required this.firstFrame,
    required this.frameCount,
  });
}

// * All birds use their Idle tag (Sparrow starts at 0, the rest at 1)
const List<BirdOption> BIRD_OPTIONS = [
  BirdOption(
    name: RLUIStrings.BIRD_SPARROW,
    assetFile: 'Sparrow.png',
    firstFrame: 0,
    frameCount: 4,
  ),

  BirdOption(
    name: RLUIStrings.BIRD_PIGEON,
    assetFile: 'Pigeon.png',
    firstFrame: 1,
    frameCount: 4,
  ),

  BirdOption(
    name: RLUIStrings.BIRD_COLLARED_DOVE,
    assetFile: 'CollaredDove.png',
    firstFrame: 1,
    frameCount: 4,
  ),

  BirdOption(name: RLUIStrings.BIRD_CROW, assetFile: 'Crow.png', firstFrame: 1, frameCount: 4),
];

// Shared Images cache so Flame.images doesn't need reconfiguring globally
final Images birdImageCache = Images(prefix: BIRD_ASSET_PREFIX);

// * Shared selection — the source of truth read by the bottom sheet and any
// * surface that wants to display the user's chosen bird (eg. bookshelf title).
final ValueNotifier<BirdOption> selectedBirdNotifier = ValueNotifier(BIRD_OPTIONS.first);

class BirdAnimationSprite extends StatelessWidget {
  final BirdOption bird;
  final double previewSize;
  final double zoom;

  const BirdAnimationSprite({
    super.key,
    required this.bird,
    this.previewSize = BIRD_PREVIEW_SIZE_LARGE,
    this.zoom = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    const double innerOffset = (BIRD_FRAME_SIZE - BIRD_CONTENT_SIZE) / 2;

    final List<SpriteAnimationFrameData> frames = List.generate(bird.frameCount, (frameIndex) {
      final double cellOriginX = (bird.firstFrame + frameIndex) * BIRD_FRAME_SIZE;

      return SpriteAnimationFrameData(
        srcPosition: Vector2(cellOriginX + innerOffset, innerOffset),
        srcSize: Vector2.all(BIRD_CONTENT_SIZE),
        stepTime: BIRD_ANIMATION_STEP_TIME,
      );
    });

    final SpriteAnimationData animationData = SpriteAnimationData(frames);

    final double renderedSize = previewSize * zoom;

    final Widget animationWidget = SpriteAnimationWidget.asset(
      path: bird.assetFile,
      images: birdImageCache,
      data: animationData,
    );

    return SizedBox(width: renderedSize, height: renderedSize, child: animationWidget);
  }
}
