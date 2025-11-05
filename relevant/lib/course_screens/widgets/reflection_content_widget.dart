// Reflection Content Widget
// 
// This file contains the ReflectionContentWidget that displays reflective
// questions and prompts for users to input thoughtful responses. Provides
// text input interfaces and handles reflection submission.

import 'package:flutter/material.dart';
import 'package:relevant/course_screens/models/course_model.dart';
import 'package:relevant/constants/app_constants.dart';
import 'package:relevant/constants/app_theme.dart';

class ReflectionContentWidget extends StatefulWidget {
  final ReflectionContent content;
  final VoidCallback onReflectionComplete;

  const ReflectionContentWidget({
    super.key,
    required this.content,
    required this.onReflectionComplete,
  });

  @override
  State<ReflectionContentWidget> createState() =>
      ReflectionContentWidgetState();
}

class ReflectionContentWidgetState
    extends State<ReflectionContentWidget> {
  bool hasReflected = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingXXL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReflectionTitle(),

          const SizedBox(height: AppTheme.spacingXXL),

          ReflectionPrompt(),

          const SizedBox(height: AppTheme.spacingXXXL),

          ThinkingPointsList(),

          const SizedBox(height: AppTheme.spacingXXXL),

          ReflectionButton(),

          const SizedBox(height: AppTheme.spacingXXL),

          InsightSection(),
        ],
      ),
    );
  }

  /// @Widget: Header with psychology icon and reflection topic title
  Widget ReflectionTitle() {
    return Row(
      children: [
        Icon(Icons.psychology, color: AppTheme.brown600, size: 28),

        const SizedBox(width: AppTheme.spacingM),

        Expanded(
          child: Text(
            widget.content.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  /// @Widget: Highlighted prompt box encouraging deep thinking about the topic
  Widget ReflectionPrompt() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.brown50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.brown200),
      ),
      child: Text(
        widget.content.prompt,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppTheme.textPrimary,
          height: 1.5,
        ),
      ),
    );
  }

  /// @Widget: List of guided questions to help focus reflection
  Widget ThinkingPointsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppConstants.CONSIDER_THESE_POINTS,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.grey700,
          ),
        ),

        const SizedBox(height: AppTheme.spacingL),

        for (final String point in widget.content.thinkingPoints)
          ThinkingPoint(point),
      ],
    );
  }

  /// @Widget: Individual bullet point with a thought-provoking question
  Widget ThinkingPoint(String point) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppTheme.brown400,
              shape: BoxShape.circle,
            ),
          ),

          const SizedBox(width: AppTheme.spacingM),

          Expanded(
            child: Text(
              point,
              style: const TextStyle(
                fontSize: 16,
                height: 1.4,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// @Widget: Interactive button to mark reflection as complete with feedback
  Widget ReflectionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: hasReflected ? null : completeReflection,
        style: ElevatedButton.styleFrom(
          backgroundColor: hasReflected
              ? AppTheme.green600
              : AppTheme.brown600,
          foregroundColor: AppTheme.white,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasReflected ? Icons.check_circle : Icons.lightbulb,
              size: 20,
            ),

            const SizedBox(width: AppTheme.spacingS),

            Text(
              hasReflected
                  ? AppConstants.REFLECTION_COMPLETE
                  : AppConstants.IVE_THOUGHT_ABOUT_THIS,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// @Widget: Special section revealing key insights after reflection is complete
  Widget InsightSection() {
    if (!hasReflected) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.amber50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.amber200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.emoji_objects, color: AppTheme.amber700),

              const SizedBox(width: AppTheme.spacingS),

              const Text(
                AppConstants.KEY_INSIGHT,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.backgroundDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingM),

          Text(
            widget.content.insight,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: AppTheme.backgroundDark,
            ),
          ),
        ],
      ),
    );
  }

  /// @Method: Complete reflection and show insight
  void completeReflection() {
    setState(() {
      hasReflected = true;
    });
    widget.onReflectionComplete();
  }
}
