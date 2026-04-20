// Bird picker shared state, data, and sprite widget
// The selected bird is held in a top-level ValueNotifier so any screen
// (menu, bookshelf header, etc.) can observe and react via ValueListenableBuilder.

import 'package:flame/cache.dart';
import 'package:flame/extensions.dart';
import 'package:flame/widgets.dart';
import 'package:flutter/material.dart';
import 'package:readlock/constants/RLUIStrings.dart';

// * Sprite sheet layout — most birds use 64x64 tiles, peacock uses 128x128
const double BIRD_DEFAULT_FRAME_SIZE = 64.0;
const double BIRD_PEACOCK_FRAME_SIZE = 128.0;
const double BIRD_ANIMATION_STEP_TIME = 0.15;
const double BIRD_PREVIEW_SIZE_LARGE = 128.0;
const double BIRD_PREVIEW_SIZE_SMALL = 96.0;
const String BIRD_ASSET_PREFIX = 'assets/birds/';

class BirdOption {
  final String name;
  final String assetFile;
  final int firstFrame;
  final int frameCount;
  final double frameSize;

  const BirdOption({
    required this.name,
    required this.assetFile,
    required this.firstFrame,
    required this.frameCount,
    this.frameSize = BIRD_DEFAULT_FRAME_SIZE,
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

  BirdOption(
    name: RLUIStrings.BIRD_CROW,
    assetFile: 'Crow.png',
    firstFrame: 1,
    frameCount: 4,
  ),

  BirdOption(
    name: RLUIStrings.BIRD_PEACOCK,
    assetFile: 'Peacock.png',
    firstFrame: 1,
    frameCount: 4,
    frameSize: BIRD_PEACOCK_FRAME_SIZE,
  ),
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
    final SpriteAnimationData animationData = SpriteAnimationData.sequenced(
      amount: bird.frameCount,
      stepTime: BIRD_ANIMATION_STEP_TIME,
      textureSize: Vector2.all(bird.frameSize),
      texturePosition: Vector2(bird.firstFrame * bird.frameSize, 0),
    );

    final double renderedSize = previewSize * zoom;

    final Widget animationWidget = SpriteAnimationWidget.asset(
      path: bird.assetFile,
      images: birdImageCache,
      data: animationData,
    );

    return SizedBox(
      width: previewSize,
      height: previewSize,
      child: ClipRect(
        child: OverflowBox(
          maxWidth: renderedSize,
          maxHeight: renderedSize,
          child: animationWidget,
        ),
      ),
    );
  }
}
