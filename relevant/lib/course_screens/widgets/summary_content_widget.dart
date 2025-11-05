// Summary Content Widget
// 
// This file contains the SummaryContentWidget that displays course summary
// and conclusion content. Provides overview of completed content and key
// takeaways from the learning journey.

import 'package:flutter/material.dart';
import 'package:relevant/course_screens/models/course_model.dart';
import 'package:relevant/constants/app_constants.dart';
import 'package:relevant/constants/app_theme.dart';

class SummaryContentWidget extends StatelessWidget {
  final SummaryContent content;

  const SummaryContentWidget({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingXXL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SummaryHeader(),

          const SizedBox(height: AppTheme.spacingXXL),

          MainInsightSection(),

          const SizedBox(height: AppTheme.spacingXXXL),

          RealWorldExamplesSection(),

          const SizedBox(height: AppTheme.spacingXXL),
        ],
      ),
    );
  }

  /// @Widget: Celebratory header with icon and completion message
  Widget SummaryHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppTheme.spacingM),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreenLight,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          ),
          child: const Icon(
            Icons.celebration,
            color: AppTheme.primaryGreen,
            size: 32,
          ),
        ),

        const SizedBox(width: AppTheme.spacingL),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                content.title,
                style: AppTheme.headingLarge.copyWith(
                  color: AppTheme.primaryGreen,
                ),
              ),

              const SizedBox(height: AppTheme.spacingXS),

              Text(
                'Course completed! Here\'s what you\'ve learned and how to apply it.',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// @Widget: Key takeaway or main learning from the completed course
  Widget MainInsightSection() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingXL),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreenVeryLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: AppTheme.primaryGreenMedium,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb,
                color: AppTheme.primaryGreen,
                size: 24,
              ),

              const SizedBox(width: AppTheme.spacingS),

              Text(
                'Key Takeaway',
                style: AppTheme.headingSmall.copyWith(
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingM),

          Text(
            content.mainInsight,
            style: AppTheme.bodyLarge.copyWith(
              height: 1.6,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  /// @Widget: Section showing practical applications and success stories
  Widget RealWorldExamplesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppConstants.REAL_WORLD_APPLICATIONS, style: AppTheme.headingMedium),

        const SizedBox(height: AppTheme.spacingL),

        Text(
          'Here are some ways people have successfully applied these concepts:',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),

        const SizedBox(height: AppTheme.spacingXL),

        Column(
          children: content.examples
              .asMap()
              .entries
              .map((entry) => ExampleCard(entry.value, entry.key + 1))
              .toList(),
        ),
      ],
    );
  }

  /// @Widget: Individual example card showing real-world application scenarios
  Widget ExampleCard(RealWorldExample example, int exampleIndex) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingL),
      padding: const EdgeInsets.all(AppTheme.spacingXL),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: AppTheme.grey600Medium,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.primaryAmberMedium,
                  borderRadius: BorderRadius.circular(
                    AppTheme.radiusSmall,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$exampleIndex',
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryAmber,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: AppTheme.spacingM),

              Expanded(
                child: Text(
                  example.context,
                  style: AppTheme.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingM),

          Text(
            example.application,
            style: AppTheme.bodyMedium.copyWith(height: 1.5),
          ),

          const SizedBox(height: AppTheme.spacingM),

          Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreenLight,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.trending_up,
                  color: AppTheme.primaryGreen,
                  size: 16,
                ),

                const SizedBox(width: AppTheme.spacingS),

                Expanded(
                  child: Text(
                    example.outcome,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.primaryGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
