// Transition Content Widget
//
// This file contains the TransitionContentWidget that displays transitional
// content between course sections. Provides smooth navigation bridges and
// contextual information for section changes.

import 'package:flutter/material.dart';
import 'package:relevant/course_screens/models/course_model.dart';
import 'package:relevant/constants/app_theme.dart';

class TransitionContentWidget extends StatelessWidget {
  final TransitionContent content;

  const TransitionContentWidget({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TransitionIcon(),

            const SizedBox(height: AppTheme.spacingXL),

            TransitionMessage(),

            const SizedBox(height: AppTheme.spacingL),

            CallToActionText(),
          ],
        ),
      ),
    );
  }

  /// @Widget: Animated icon indicating progression between course sections
  Widget TransitionIcon() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlueLight,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.arrow_forward,
        color: AppTheme.primaryBlue,
        size: 32,
      ),
    );
  }

  /// @Widget: Encouraging message preparing user for the next content
  Widget TransitionMessage() {
    return Text(
      content.message,
      style: AppTheme.headingMedium.copyWith(height: 1.4),
      textAlign: TextAlign.center,
    );
  }

  /// @Widget: Motivational text prompting user to continue learning
  Widget CallToActionText() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingL,
        vertical: AppTheme.spacingM,
      ),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreenLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: AppTheme.primaryGreenHeavy),
      ),
      child: Text(
        content.callToAction,
        style: AppTheme.bodyLarge.copyWith(
          color: AppTheme.primaryGreen,
          fontWeight: FontWeight.w600,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
