// Course Roadmap Widget
//
// This file contains the enhanced course roadmap visualization widget that displays
// a course's learning journey with flowing visual connections, progress tracking,
// and interactive content nodes. Features include gradient backgrounds, enhanced
// node styling with status indicators, content type badges, and section organization.

import 'package:relevant/globals.dart';
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
    return Div.column(
      [
        SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingXXL),
          child: Div.column([
            CourseProgressHeader(),

            Spacing.height(AppTheme.spacingXXXL),

            FlowingRoadmapPath(),
          ], crossAxisAlignment: CrossAxisAlignment.start),
        ),
      ],
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
    );
  }

  Widget CourseProgressHeader() {
    return Builder(
      builder: (BuildContext context) {
        final int totalNodes = getTotalContentCount();
        final int completedNodes = getCompletedContentCount();
        final double progressPercentage = totalNodes > 0
            ? (completedNodes / totalNodes)
            : 0.0;

        return Div.column(
          [
            Div.row([
              const Icon(
                Icons.route,
                color: AppTheme.primaryDeepPurple,
                size: 32,
              ),

              Spacing.width(AppTheme.spacingL),

              Expanded(
                child: Div.column([
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
                ], crossAxisAlignment: CrossAxisAlignment.start),
              ),
            ]),

            Spacing.height(AppTheme.spacingXXL),

            Stack(
              children: [
                Div.emptyRow(
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppTheme.grey300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Div.emptyRow(
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

            Spacing.height(AppTheme.spacingL),

            Div.row([
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
            ], mainAxisAlignment: MainAxisAlignment.spaceBetween),
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
          padding: const EdgeInsets.all(AppTheme.spacingXXL),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryDeepPurpleLight,
                AppTheme.primaryBrownVeryLight,
              ],
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            border: Border.all(color: AppTheme.primaryDeepPurpleMedium),
          ),
        );
      },
    );
  }

  Widget FlowingRoadmapPath() {
    return Div.column(BuildFlowingSections());
  }

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

  Widget EnhancedRoadmapSection({
    required CourseSection section,
    required int sectionIndex,
    required bool isLastSection,
  }) {
    return Div.column([
      SectionHeaderCard(
        title: section.title,
        sectionIndex: sectionIndex,
      ),

      Spacing.height(AppTheme.spacingXXL),

      FlowingContentPath(section: section, sectionIndex: sectionIndex),
    ], margin: const EdgeInsets.symmetric(vertical: AppTheme.spacingL));
  }

  Widget FlowingContentPath({
    required CourseSection section,
    required int sectionIndex,
  }) {
    return CustomPaint(
      child: Div.column(
        [
          Wrap(
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
        ],
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingXXL,
          vertical: AppTheme.spacingL,
        ),
      ),
    );
  }

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
      child: Div.column([
        Stack(
          alignment: Alignment.center,
          children: [
            Div.column(
              [
                Icon(
                  nodeIcon,
                  color: getNodeIconColor(status),
                  size: 32,
                ),

                Spacing.height(4),

                Text(
                  '$nodeNumber',
                  style: TextStyle(
                    color: getNodeIconColor(status),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.center,
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
            ),
            if (status == NodeStatus.current)
              Div.emptyRow(
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

        Spacing.height(AppTheme.spacingM),

        Div.row(
          [
            Text(
              contentTypeLabel,
              style: AppTheme.captionText.copyWith(
                color: getContentTypeBadgeTextColor(status),
                fontSize: 10,
              ),
            ),
          ],
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingM,
            vertical: AppTheme.spacingS,
          ),
          decoration: BoxDecoration(
            color: getContentTypeBadgeColor(content, status),
            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          ),
        ),
      ]),
    );
  }

  Widget FlowingSectionConnector() {
    return Div.column(
      [
        Div.emptyColumn(
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
        Div.emptyColumn(
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
      margin: const EdgeInsets.symmetric(vertical: AppTheme.spacingXXL),
    );
  }

  Widget SectionHeaderCard({
    required String title,
    required int sectionIndex,
  }) {
    return Div.row(
      [
        Div.row(
          [
            Text(
              '${sectionIndex + 1}',
              style: AppTheme.captionText.copyWith(
                color: AppTheme.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          padding: const EdgeInsets.all(AppTheme.spacingS),
          decoration: const BoxDecoration(
            color: AppTheme.primaryBrown,
            shape: BoxShape.circle,
          ),
        ),

        Spacing.width(AppTheme.spacingL),

        Text(
          title,
          style: AppTheme.headingSmall.copyWith(
            color: AppTheme.primaryBrown,
          ),
          textAlign: TextAlign.center,
        ),
      ],
      mainAxisAlignment: MainAxisAlignment.center,
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
        border: Border.all(color: AppTheme.primaryBrownHeavy),
      ),
    );
  }

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

  Color getNodeColor(NodeStatus status) {
    switch (status) {
      case NodeStatus.locked:
        {
          return AppTheme.grey300;
        }
      case NodeStatus.available:
        {
          return AppTheme.blue100;
        }
      case NodeStatus.completed:
        {
          return AppTheme.green600;
        }
      case NodeStatus.current:
        {
          return AppTheme.amber200;
        }
    }
  }

  Color getNodeIconColor(NodeStatus status) {
    switch (status) {
      case NodeStatus.locked:
        {
          return AppTheme.grey600;
        }
      case NodeStatus.available:
        {
          return AppTheme.blue600;
        }
      case NodeStatus.completed:
        {
          return AppTheme.white;
        }
      case NodeStatus.current:
        {
          return AppTheme.amber700;
        }
    }
  }

  IconData getNodeIcon(CourseContent content, NodeStatus status) {
    if (status == NodeStatus.completed) {
      return Icons.check;
    } else if (status == NodeStatus.locked) {
      return Icons.lock;
    }

    if (content is TextContent) {
      return Icons.menu_book;
    } else if (content is QuestionContent) {
      return Icons.quiz;
    }

    return Icons.circle;
  }

  int getTotalContentCount() {
    return course.sections.fold(
      0,
      (total, section) => total + section.content.length,
    );
  }

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

  Gradient getNodeGradient(NodeStatus status) {
    switch (status) {
      case NodeStatus.locked:
        {
          return LinearGradient(
            colors: [AppTheme.grey300, AppTheme.grey400],
          );
        }
      case NodeStatus.available:
        {
          return LinearGradient(
            colors: [AppTheme.blue100, AppTheme.blue200],
          );
        }
      case NodeStatus.completed:
        {
          return LinearGradient(
            colors: [AppTheme.green600, AppTheme.green800],
          );
        }
      case NodeStatus.current:
        {
          return LinearGradient(
            colors: [AppTheme.amber200, AppTheme.amber700],
          );
        }
    }
  }

  Color getNodeBorderColor(NodeStatus status) {
    switch (status) {
      case NodeStatus.locked:
        {
          return AppTheme.grey400;
        }
      case NodeStatus.available:
        {
          return AppTheme.blue600;
        }
      case NodeStatus.completed:
        {
          return AppTheme.green800;
        }
      case NodeStatus.current:
        {
          return AppTheme.amber700;
        }
    }
  }

  List<BoxShadow> getNodeShadow(NodeStatus status) {
    switch (status) {
      case NodeStatus.locked:
        {
          return [];
        }
      case NodeStatus.available:
        {
          return [
            BoxShadow(
              color: AppTheme.blue600Medium,
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ];
        }
      case NodeStatus.completed:
        {
          return [
            BoxShadow(
              color: AppTheme.green600Heavy,
              blurRadius: 6,
              spreadRadius: 2,
            ),
          ];
        }
      case NodeStatus.current:
        {
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

  String getContentTypeLabel(CourseContent content) {
    if (content is TextContent) {
      return 'LESSON';
    } else if (content is QuestionContent) {
      return 'QUIZ';
    }
    return 'CONTENT';
  }

  Color getContentTypeBadgeColor(
    CourseContent content,
    NodeStatus status,
  ) {
    if (status == NodeStatus.locked) {
      return AppTheme.grey300;
    }

    if (content is TextContent) {
      return AppTheme.brown200Heavy;
    } else if (content is QuestionContent) {
      return AppTheme.blue200Heavy;
    }
    return AppTheme.grey300Heavy;
  }

  Color getContentTypeBadgeTextColor(NodeStatus status) {
    return status == NodeStatus.locked
        ? AppTheme.grey600
        : AppTheme.textPrimary;
  }
}
