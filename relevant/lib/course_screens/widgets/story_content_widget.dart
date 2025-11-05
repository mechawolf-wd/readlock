// Story Content Widget
// 
// This file contains the StoryContentWidget that displays narrative story content
// with progressive text reveal animation. Used for presenting story-based learning
// content in courses with smooth text animations and continue interactions.

import 'package:flutter/material.dart';
import 'package:relevant/course_screens/models/course_model.dart';
import 'package:relevant/constants/app_theme.dart';
import 'package:relevant/course_screens/widgets/progressive_text_widget.dart';

class StoryContentWidget extends StatelessWidget {
  final StoryContent content;

  const StoryContentWidget({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingXXL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StoryTitle(),

          const SizedBox(height: AppTheme.spacingXXL),

          StoryImage(),

          const SizedBox(height: AppTheme.spacingXXL),

          StoryText(),
        ],
      ),
    );
  }

  /// @Widget: Large heading displaying the story or narrative title
  Widget StoryTitle() {
    return Text(content.title, style: AppTheme.headingLarge);
  }

  /// @Widget: Optional hero image that supports the story content
  Widget StoryImage() {
    if (content.imageUrl == null) {
      return const SizedBox.shrink();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Image.network(
        content.imageUrl ?? '',
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: StoryImageErrorBuilder,
        loadingBuilder: StoryImageLoadingBuilder,
      ),
    );
  }

  /// @Widget: Fallback display when story image fails to load
  Widget StoryImageErrorBuilder(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: AppTheme.grey300,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: const Center(
        child: Icon(
          Icons.image_not_supported,
          size: 48,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }

  /// @Widget: Loading indicator shown while story image is downloading
  Widget StoryImageLoadingBuilder(
    BuildContext context,
    Widget child,
    ImageChunkEvent? loadingProgress,
  ) {
    if (loadingProgress == null) {
      return child;
    }

    final double progressValue =
        loadingProgress.expectedTotalBytes != null
        ? loadingProgress.cumulativeBytesLoaded /
              (loadingProgress.expectedTotalBytes ?? 1)
        : 0.0;

    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: AppTheme.grey300,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Center(
        child: CircularProgressIndicator(value: progressValue),
      ),
    );
  }

  /// @Widget: Main narrative content with progressive text reveal animation
  Widget StoryText() {
    return ProgressiveTextWidget(
      text: content.text,
      revealDuration: const Duration(milliseconds: 200),
    );
  }
}
