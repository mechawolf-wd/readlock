// Intro Content Widget
//
// This file contains the IntroContentWidget that displays course introduction
// content with welcoming text and introductory information. Used to present
// course overview and initial content to users.

import 'package:flutter/material.dart';
import 'package:relevant/course_screens/models/course_model.dart';
import 'package:relevant/constants/app_constants.dart';
import 'package:relevant/constants/app_theme.dart';

class IntroContentWidget extends StatelessWidget {
  final IntroContent content;

  const IntroContentWidget({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingXXL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WelcomeHeader(),

          const SizedBox(height: AppTheme.spacingXXL),

          QuestionSection(),

          const SizedBox(height: AppTheme.spacingXXL),

          OverviewSection(),

          const SizedBox(height: AppTheme.spacingXXXL),

          LearningPointsSection(),

          const SizedBox(height: AppTheme.spacingXXL),
        ],
      ),
    );
  }

  /// @Widget: Course introduction header with title and welcoming message
  Widget WelcomeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlueLight,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          ),
          child: const Icon(
            Icons.school,
            color: AppTheme.primaryBlue,
            size: 32,
          ),
        ),

        const SizedBox(height: AppTheme.spacingL),

        Text(content.title, style: AppTheme.headingLarge),
      ],
    );
  }

  /// @Widget: Thought-provoking question to engage learner interest
  Widget QuestionSection() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingXL),
      decoration: BoxDecoration(
        color: AppTheme.primaryAmberVeryLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: AppTheme.primaryAmberMedium,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.help_outline,
                color: AppTheme.primaryAmber,
                size: 24,
              ),

              const SizedBox(width: AppTheme.spacingS),

              Text(
                'The Big Question',
                style: AppTheme.headingSmall.copyWith(
                  color: AppTheme.primaryAmber,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingM),

          Text(
            content.question,
            style: AppTheme.bodyLarge.copyWith(
              fontStyle: FontStyle.italic,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  /// @Widget: Course overview highlighting what learners will discover
  Widget OverviewSection() {
    final List<String> overviewSentences = content.overview.split('. ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppConstants.WHAT_YOULL_DISCOVER, style: AppTheme.headingMedium),

        const SizedBox(height: AppTheme.spacingL),

        Column(
          children: overviewSentences.asMap().entries.map((entry) {
            final sentence = entry.value.trim();
            if (sentence.isEmpty) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                  ),

                  const SizedBox(width: AppTheme.spacingM),

                  Expanded(
                    child: Text(
                      sentence.endsWith('.') ? sentence : '$sentence.',
                      style: AppTheme.bodyMedium.copyWith(height: 1.5),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// @Widget: List of key learning objectives and expected outcomes
  Widget LearningPointsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'In This Course, You\'ll Learn:',
          style: AppTheme.headingSmall.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),

        const SizedBox(height: AppTheme.spacingL),

        Column(
          children: content.learningPoints
              .map(LearningPointItem)
              .toList(),
        ),
      ],
    );
  }

  /// @Widget: Individual learning point with bullet and descriptive text
  Widget LearningPointItem(String point) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingM),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppTheme.primaryGreen,
              shape: BoxShape.circle,
            ),
          ),

          const SizedBox(width: AppTheme.spacingM),

          Expanded(
            child: Text(
              point,
              style: AppTheme.bodyMedium.copyWith(height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
