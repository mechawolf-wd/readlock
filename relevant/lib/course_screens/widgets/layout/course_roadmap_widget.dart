// Course Roadmap Widget
// 
// This file contains the enhanced course roadmap visualization widget that displays
// a course's learning journey with flowing visual connections, progress tracking,
// and interactive content nodes. Features include gradient backgrounds, enhanced
// node styling with status indicators, content type badges, and section organization.

import 'package:flutter/material.dart';
import 'package:relevant/constants/app_theme.dart';
import 'package:relevant/course_screens/models/course_model.dart';

enum NodeStatus { locked, available, completed, current }

class CourseRoadmapWidget extends StatelessWidget {
  final Course course;
  final int currentSectionIndex;
  final int currentContentIndex;
  final Function(int sectionIndex, int contentIndex) onNodeTap;

  const CourseRoadmapWidget({
    super.key,
    required this.course,
    required this.currentSectionIndex,
    required this.currentContentIndex,
    required this.onNodeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.backgroundDark,
            AppTheme.backgroundDarkDark,
            AppTheme.backgroundLightHeavy,
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingXXL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CourseProgressHeader(),

            const SizedBox(height: AppTheme.spacingXXXL),

            FlowingRoadmapPath(),
          ],
        ),
      ),
    );
  }

  /// @Widget: Header card showing course title and overall progress statistics
  Widget CourseProgressHeader() {
    return Builder(
      builder: (BuildContext context) {
        final int totalNodes = getTotalContentCount();
        final int completedNodes = getCompletedContentCount();
        final double progressPercentage = totalNodes > 0
            ? (completedNodes / totalNodes)
            : 0.0;

        return Container(
          padding: const EdgeInsets.all(AppTheme.spacingXXL),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryDeepPurpleLight,
                AppTheme.primaryBrownVeryLight,
              ],
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            border: Border.all(
              color: AppTheme.primaryDeepPurpleMedium,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.route,
                    color: AppTheme.primaryDeepPurple,
                    size: 32,
                  ),

                  const SizedBox(width: AppTheme.spacingL),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.title,
                          style: AppTheme.headingLarge.copyWith(
                            color: AppTheme.primaryDeepPurple,
                          ),
                        ),

                        Text(
                          'Your Learning Journey',
                          style: AppTheme.bodyMedium.copyWith(
                            color: AppTheme.grey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppTheme.spacingXXL),

              Stack(
                children: [
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: AppTheme.grey300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    height: 8,
                    width:
                        MediaQuery.of(context).size.width *
                        0.7 *
                        progressPercentage,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppTheme.primaryDeepPurple,
                          AppTheme.primaryBrown,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppTheme.spacingL),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(progressPercentage * 100).round()}% Complete',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.primaryDeepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '$completedNodes of $totalNodes lessons',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.grey600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// @Widget: Visual roadmap displaying course sections in a flowing layout
  Widget FlowingRoadmapPath() {
    return Column(children: BuildFlowingSections());
  }

  /// @Widget: Builder for course sections with connecting visual flow elements
  List<Widget> BuildFlowingSections() {
    final List<Widget> sections = [];

    for (
      int sectionIndex = 0;
      sectionIndex < course.sections.length;
      sectionIndex++
    ) {
      sections.add(
        EnhancedRoadmapSection(
          section: course.sections[sectionIndex],
          sectionIndex: sectionIndex,
          isLastSection: sectionIndex == course.sections.length - 1,
        ),
      );

      if (sectionIndex < course.sections.length - 1) {
        sections.add(FlowingSectionConnector());
      }
    }

    return sections;
  }

  /// @Widget: Individual course section with header and content nodes
  Widget EnhancedRoadmapSection({
    required CourseSection section,
    required int sectionIndex,
    required bool isLastSection,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppTheme.spacingL),
      child: Column(
        children: [
          SectionHeaderCard(
            title: section.title,
            sectionIndex: sectionIndex,
          ),

          const SizedBox(height: AppTheme.spacingXXL),

          FlowingContentPath(
            section: section,
            sectionIndex: sectionIndex,
          ),
        ],
      ),
    );
  }

  /// @Widget: Vertical path connecting individual content items within a section
  Widget FlowingContentPath({
    required CourseSection section,
    required int sectionIndex,
  }) {
    return CustomPaint(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingXXL,
          vertical: AppTheme.spacingL,
        ),
        child: Wrap(
          spacing: AppTheme.spacingXXL,
          runSpacing: AppTheme.spacingXXL,
          alignment: WrapAlignment.center,
          children: [
            for (
              int contentIndex = 0;
              contentIndex < section.content.length;
              contentIndex++
            )
              EnhancedContentNode(
                content: section.content[contentIndex],
                sectionIndex: sectionIndex,
                contentIndex: contentIndex,
                status: getNodeStatus(sectionIndex, contentIndex),
                nodeNumber: contentIndex + 1,
              ),
          ],
        ),
      ),
    );
  }

  /// @Widget: Interactive content node showing status and type information
  Widget EnhancedContentNode({
    required CourseContent content,
    required int sectionIndex,
    required int contentIndex,
    required NodeStatus status,
    required int nodeNumber,
  }) {
    // Enhanced node styling
    final IconData nodeIcon = getNodeIcon(content, status);
    final bool isInteractive = status != NodeStatus.locked;
    final String contentTypeLabel = getContentTypeLabel(content);

    return GestureDetector(
      onTap: isInteractive
          ? () => onNodeTap(sectionIndex, contentIndex)
          : null,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: getNodeGradient(status),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: status == NodeStatus.current
                        ? AppTheme.primaryDeepPurple
                        : getNodeBorderColor(status),
                    width: status == NodeStatus.current ? 4 : 2,
                  ),
                  boxShadow: getNodeShadow(status),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      nodeIcon,
                      color: getNodeIconColor(status),
                      size: 32,
                    ),

                    const SizedBox(height: 4),

                    Text(
                      '$nodeNumber',
                      style: TextStyle(
                        color: getNodeIconColor(status),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              if (status == NodeStatus.current)
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primaryDeepPurpleHeavy,
                      width: 2,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: AppTheme.spacingM),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingM,
              vertical: AppTheme.spacingS,
            ),
            decoration: BoxDecoration(
              color: getContentTypeBadgeColor(content, status),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Text(
              contentTypeLabel,
              style: AppTheme.captionText.copyWith(
                color: getContentTypeBadgeTextColor(status),
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// @Widget: Visual connector element linking different course sections
  Widget FlowingSectionConnector() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppTheme.spacingXXL),
      child: Column(
        children: [
          Container(
            width: 2,
            height: 30,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.primaryDeepPurpleHeavy,
                  AppTheme.primaryBrownMedium,
                ],
              ),
            ),
          ),
          Icon(
            Icons.keyboard_arrow_down,
            color: AppTheme.primaryBrownMedium,
            size: 24,
          ),
          Container(
            width: 2,
            height: 30,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.primaryBrownMedium,
                  AppTheme.primaryDeepPurpleHeavy,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// @Widget: Section title card with progress indicator and visual styling
  Widget SectionHeaderCard({
    required String title,
    required int sectionIndex,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingXXL,
        vertical: AppTheme.spacingL,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBrownLight,
            AppTheme.primaryDeepPurpleVeryLight,
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: AppTheme.primaryBrownHeavy,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingS),
            decoration: const BoxDecoration(
              color: AppTheme.primaryBrown,
              shape: BoxShape.circle,
            ),
            child: Text(
              '${sectionIndex + 1}',
              style: AppTheme.captionText.copyWith(
                color: AppTheme.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: AppTheme.spacingL),

          Text(
            title,
            style: AppTheme.headingSmall.copyWith(
              color: AppTheme.primaryBrown,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// @Method: Get node status based on progress
  NodeStatus getNodeStatus(int sectionIndex, int contentIndex) {
    if (sectionIndex < currentSectionIndex) {
      return NodeStatus.completed;
    } else if (sectionIndex == currentSectionIndex) {
      if (contentIndex < currentContentIndex) {
        return NodeStatus.completed;
      } else if (contentIndex == currentContentIndex) {
        return NodeStatus.current;
      } else {
        return NodeStatus.available;
      }
    } else {
      return NodeStatus.locked;
    }
  }

  /// @Method: Get node color based on status
  Color getNodeColor(NodeStatus status) {
    switch (status) {
      case NodeStatus.locked: {
        return AppTheme.grey300;
      }
      case NodeStatus.available: {
        return AppTheme.blue100;
      }
      case NodeStatus.completed: {
        return AppTheme.green600;
      }
      case NodeStatus.current: {
        return AppTheme.amber200;
      }
    }
  }

  /// @Method: Get node icon color based on status
  Color getNodeIconColor(NodeStatus status) {
    switch (status) {
      case NodeStatus.locked: {
        return AppTheme.grey600;
      }
      case NodeStatus.available: {
        return AppTheme.blue600;
      }
      case NodeStatus.completed: {
        return AppTheme.white;
      }
      case NodeStatus.current: {
        return AppTheme.amber700;
      }
    }
  }

  /// @Method: Get appropriate icon for content type and status
  IconData getNodeIcon(CourseContent content, NodeStatus status) {
    if (status == NodeStatus.completed) {
      return Icons.check;
    } else if (status == NodeStatus.locked) {
      return Icons.lock;
    }

    if (content is StoryContent) {
      return Icons.menu_book;
    } else if (content is QuestionContent) {
      return Icons.quiz;
    } else if (content is ReflectionContent) {
      return Icons.psychology;
    }

    return Icons.circle;
  }

  /// @Method: Get total content count across all sections
  int getTotalContentCount() {
    return course.sections.fold(
      0,
      (total, section) => total + section.content.length,
    );
  }

  /// @Method: Get completed content count
  int getCompletedContentCount() {
    int completed = 0;

    for (
      int sectionIndex = 0;
      sectionIndex < course.sections.length;
      sectionIndex++
    ) {
      final CourseSection section = course.sections[sectionIndex];

      for (
        int contentIndex = 0;
        contentIndex < section.content.length;
        contentIndex++
      ) {
        final NodeStatus status = getNodeStatus(
          sectionIndex,
          contentIndex,
        );

        if (status == NodeStatus.completed) {
          completed++;
        }
      }
    }

    return completed;
  }

  /// @Method: Get enhanced node gradient based on status
  Gradient getNodeGradient(NodeStatus status) {
    switch (status) {
      case NodeStatus.locked: {
        return LinearGradient(
          colors: [AppTheme.grey300, AppTheme.grey400],
        );
      }
      case NodeStatus.available: {
        return LinearGradient(
          colors: [AppTheme.blue100, AppTheme.blue200],
        );
      }
      case NodeStatus.completed: {
        return LinearGradient(
          colors: [AppTheme.green600, AppTheme.green800],
        );
      }
      case NodeStatus.current: {
        return LinearGradient(
          colors: [AppTheme.amber200, AppTheme.amber700],
        );
      }
    }
  }

  /// @Method: Get node border color based on status
  Color getNodeBorderColor(NodeStatus status) {
    switch (status) {
      case NodeStatus.locked: {
        return AppTheme.grey400;
      }
      case NodeStatus.available: {
        return AppTheme.blue600;
      }
      case NodeStatus.completed: {
        return AppTheme.green800;
      }
      case NodeStatus.current: {
        return AppTheme.amber700;
      }
    }
  }

  /// @Method: Get node shadow based on status
  List<BoxShadow> getNodeShadow(NodeStatus status) {
    switch (status) {
      case NodeStatus.locked: {
        return [];
      }
      case NodeStatus.available: {
        return [
          BoxShadow(
            color: AppTheme.blue600Medium,
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ];
      }
      case NodeStatus.completed: {
        return [
          BoxShadow(
            color: AppTheme.green600Heavy,
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ];
      }
      case NodeStatus.current: {
        return [
          BoxShadow(
            color: AppTheme.amber700Heavy,
            blurRadius: 8,
            spreadRadius: 3,
          ),
        ];
      }
    }
  }

  /// @Method: Get content type label for display
  String getContentTypeLabel(CourseContent content) {
    if (content is StoryContent) {
      return 'STORY';
    } else if (content is QuestionContent) {
      return 'QUIZ';
    } else if (content is ReflectionContent) {
      return 'REFLECT';
    }
    return 'LESSON';
  }

  /// @Method: Get content type badge color
  Color getContentTypeBadgeColor(
    CourseContent content,
    NodeStatus status,
  ) {
    if (status == NodeStatus.locked) {
      return AppTheme.grey300;
    }

    if (content is StoryContent) {
      return AppTheme.brown200Heavy;
    } else if (content is QuestionContent) {
      return AppTheme.blue200Heavy;
    } else if (content is ReflectionContent) {
      return AppTheme.amber200Heavy;
    }
    return AppTheme.grey300Heavy;
  }

  /// @Method: Get content type badge text color
  Color getContentTypeBadgeTextColor(NodeStatus status) {
    return status == NodeStatus.locked
        ? AppTheme.grey600
        : AppTheme.textPrimary;
  }
}
