// Duolingo-inspired gamified profile screen
// Showcases mockups of engaging learning patterns adapted for book reading

import 'package:flutter/material.dart' hide Typography;
import 'package:relevant/constants/typography.dart';
import 'package:relevant/utility_widgets/utility_widgets.dart';
import 'package:relevant/constants/app_theme.dart';

const String PROFILE_GREETING = 'Welcome back, Alex!';
const String DAILY_GOAL_LABEL = 'Daily Goal';
const String ACHIEVEMENT_GALLERY_LABEL = 'Achievement Gallery';
const String READING_LEAGUE_LABEL = 'Reading League';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.backgroundDark,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Div.column([
            DuolingoProfileHeader(),
            
            const Spacing.height(24),
            
            EnhancedStreakCard(),
            
            const Spacing.height(20),
            
            DailyGoalCard(),
            
            const Spacing.height(20),
            
            AchievementGallery(),
            
            const Spacing.height(20),
            
            ReadingLeagueCard(),
          ], crossAxisAlignment: CrossAxisAlignment.stretch),
        ),
      ),
    );
  }
}

class DuolingoProfileHeader extends StatelessWidget {
  const DuolingoProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF58CC02), Color(0xFF89E219)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Div.column([
        Div.row([
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              color: Colors.white,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: const Icon(
              Icons.person,
              color: Color(0xFF58CC02),
              size: 32,
            ),
          ),

          const Spacing.width(16),

          Expanded(
            child: Div.column([
              Text(
                PROFILE_GREETING,
                style: Typography.bodyLargeStyle.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              const Spacing.height(4),

              Text(
                'Level 12 Knowledge Seeker',
                style: Typography.bodyMediumStyle.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 14,
                ),
              ),
            ], crossAxisAlignment: CrossAxisAlignment.start),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Div.row([
              const Icon(
                Icons.local_fire_department,
                color: Colors.white,
                size: 18,
              ),

              const Spacing.width(6),

              Text(
                '23 day streak',
                style: Typography.bodyMediumStyle.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ]),
          ),
        ], crossAxisAlignment: CrossAxisAlignment.center),

        const Spacing.height(16),

        Div.row([
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Div.row([
              const Icon(
                Icons.star,
                color: Colors.white,
                size: 16,
              ),

              const Spacing.width(4),

              Text(
                '2,847 Aha',
                style: Typography.bodyMediumStyle.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ]),
          ),

          const Spacing.width(12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Div.row([
              const Icon(
                Icons.emoji_events,
                color: Colors.white,
                size: 16,
              ),

              const Spacing.width(4),

              Text(
                '47 badges',
                style: Typography.bodyMediumStyle.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ]),
          ),

          const Spacing.width(12),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Div.row([
              const Icon(
                Icons.school,
                color: Colors.white,
                size: 16,
              ),

              const Spacing.width(4),

              Text(
                '12 books',
                style: Typography.bodyMediumStyle.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ]),
          ),
        ]),
      ]),
    );
  }
}

class EnhancedStreakCard extends StatelessWidget {
  const EnhancedStreakCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFF9600).withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Div.column([
        Div.row([
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFF9600),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.local_fire_department,
              color: Colors.white,
              size: 28,
            ),
          ),

          const Spacing.width(16),

          Expanded(
            child: Div.column([
              Text(
                '23 Day Streak!',
                style: Typography.bodyLargeStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: const Color(0xFFFF9600),
                ),
              ),

              const Spacing.height(4),

              Text(
                '+85 Aha earned today',
                style: Typography.bodyMediumStyle.copyWith(
                  color: AppTheme.primaryGreen,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ], crossAxisAlignment: CrossAxisAlignment.start),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFF9600).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'PERFECT!',
              style: Typography.bodyMediumStyle.copyWith(
                color: const Color(0xFFFF9600),
                fontWeight: FontWeight.bold,
                fontSize: 10,
                letterSpacing: 1,
              ),
            ),
          ),
        ]),

        const Spacing.height(20),

        Div.row([
          ...List.generate(7, (dayIndex) {
            final bool isCompleted = dayIndex < 6;
            final bool isToday = dayIndex == 6;
            final bool isFuture = dayIndex > 6;
            
            return Expanded(
              child: Container(
                height: 40,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? const Color(0xFFFF9600)
                      : isToday
                          ? const Color(0xFFFF9600)
                          : AppTheme.textPrimary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: isToday 
                      ? Border.all(color: const Color(0xFFFF9600), width: 2)
                      : null,
                ),
                child: Div.column([
                  const Spacing.height(4),
                  Text(
                    ['M', 'T', 'W', 'T', 'F', 'S', 'S'][dayIndex],
                    style: Typography.bodyMediumStyle.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isCompleted || isToday
                          ? Colors.white
                          : AppTheme.textPrimary.withValues(alpha: 0.4),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacing.height(2),
                  Icon(
                    isCompleted
                        ? Icons.local_fire_department
                        : isToday
                            ? Icons.local_fire_department
                            : Icons.circle_outlined,
                    color: isCompleted || isToday
                        ? Colors.white
                        : AppTheme.textPrimary.withValues(alpha: 0.3),
                    size: 14,
                  ),
                ], mainAxisAlignment: MainAxisAlignment.center),
              ),
            );
          }),
        ]),

        const Spacing.height(16),

        Text(
          'You\'re in the top 10% of readers this week! 🎉',
          style: Typography.bodyMediumStyle.copyWith(
            color: AppTheme.textPrimary.withValues(alpha: 0.8),
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
        ),
      ]),
    );
  }
}

class DailyGoalCard extends StatelessWidget {
  const DailyGoalCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1CB0F6), Color(0xFF00B4D8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Div.column([
        Div.row([
          const Icon(
            Icons.flag,
            color: Colors.white,
            size: 24,
          ),

          const Spacing.width(12),

          Text(
            DAILY_GOAL_LABEL,
            style: Typography.bodyLargeStyle.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const Spacer(),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '85/100 Aha',
              style: Typography.bodyMediumStyle.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ]),

        const Spacing.height(16),

        Container(
          height: 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: Colors.white.withValues(alpha: 0.3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: 0.85,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: Colors.white,
              ),
            ),
          ),
        ),

        const Spacing.height(12),

        Text(
          '15 Aha to go! You\'re almost there 💪',
          style: Typography.bodyMediumStyle.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
        ),
      ]),
    );
  }
}



class ReadingStatsCard extends StatelessWidget {
  const ReadingStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.textPrimary.withValues(alpha: 0.1),
        ),
      ),
      child: Div.column([
        Text(
          'This widget was replaced by new Duolingo-inspired components above',
          style: Typography.bodyMediumStyle.copyWith(
            color: AppTheme.textPrimary.withValues(alpha: 0.5),
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),

        const Spacing.height(20),

        Div.row([
          StatisticItem(
            label: 'Books Read',
            value: '127',
            icon: Icons.menu_book,
            color: AppTheme.primaryBlue,
          ),

          StatisticItem(
            label: 'Hours Spent',
            value: '342h',
            icon: Icons.access_time,
            color: AppTheme.primaryGreen,
          ),

          StatisticItem(
            label: 'Avg. Rating',
            value: '4.6★',
            icon: Icons.star,
            color: Colors.orange,
          ),
        ], mainAxisAlignment: MainAxisAlignment.spaceBetween),
      ]),
    );
  }
}

class StatisticItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const StatisticItem({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Div.column([
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),

        const Spacing.height(8),

        Text(
          value,
          style: Typography.bodyLargeStyle.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const Spacing.height(4),

        Text(
          label,
          style: Typography.bodyMediumStyle.copyWith(
            fontSize: 12,
            color: AppTheme.textPrimary.withValues(alpha: 0.6),
          ),
        ),
      ], crossAxisAlignment: CrossAxisAlignment.center),
    );
  }
}

class AchievementGallery extends StatelessWidget {
  const AchievementGallery({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Div.column([
        Div.row([
          const Icon(
            Icons.emoji_events,
            color: Colors.white,
            size: 24,
          ),

          const Spacing.width(12),

          Text(
            ACHIEVEMENT_GALLERY_LABEL,
            style: Typography.bodyLargeStyle.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const Spacer(),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '47/100',
              style: Typography.bodyMediumStyle.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ),
        ]),

        const Spacing.height(20),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Div.row([
            ...[
              {'icon': Icons.local_fire_department, 'title': 'Streak Master', 'desc': '30 day streak', 'earned': true},
              {'icon': Icons.school, 'title': 'Book Worm', 'desc': '10 books read', 'earned': true},
              {'icon': Icons.lightbulb, 'title': 'Insight Hunter', 'desc': '100 insights', 'earned': true},
              {'icon': Icons.speed, 'title': 'Speed Reader', 'desc': '5 books in a week', 'earned': false},
              {'icon': Icons.quiz, 'title': 'Quiz Master', 'desc': '50 perfect scores', 'earned': false},
            ].map((badge) {
              final bool earned = badge['earned'] as bool;
              return Container(
                width: 80,
                margin: const EdgeInsets.only(right: 16),
                child: Div.column([
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: earned 
                          ? Colors.white 
                          : Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: earned 
                            ? Colors.transparent 
                            : Colors.white.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      badge['icon'] as IconData,
                      color: earned 
                          ? const Color(0xFFFFD700) 
                          : Colors.white.withValues(alpha: 0.4),
                      size: 28,
                    ),
                  ),

                  const Spacing.height(8),

                  Text(
                    badge['title'] as String,
                    style: Typography.bodyMediumStyle.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const Spacing.height(2),

                  Text(
                    badge['desc'] as String,
                    style: Typography.bodyMediumStyle.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 9,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ]),
              );
            }),
          ]),
        ),

        const Spacing.height(16),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Complete 3 more chapters to unlock \'Quiz Master\' badge! 🏆',
            style: Typography.bodyMediumStyle.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ]),
    );
  }
}

class ReadingLeagueCard extends StatelessWidget {
  const ReadingLeagueCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Div.column([
        Div.row([
          const Icon(
            Icons.leaderboard,
            color: Colors.white,
            size: 24,
          ),

          const Spacing.width(12),

          Expanded(
            child: Text(
              READING_LEAGUE_LABEL,
              style: Typography.bodyLargeStyle.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'GOLD',
              style: Typography.bodyMediumStyle.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 10,
                letterSpacing: 1,
              ),
            ),
          ),
        ]),

        const Spacing.height(16),

        Text(
          'You\'re #3 out of 47 in your reading group this week!',
          style: Typography.bodyMediumStyle.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 13,
          ),
          textAlign: TextAlign.center,
        ),

        const Spacing.height(16),

        ...[
          {'rank': 1, 'name': 'Sarah Chen', 'aha': 2847, 'you': false},
          {'rank': 2, 'name': 'Mike Johnson', 'aha': 2156, 'you': false},
          {'rank': 3, 'name': 'You', 'aha': 1923, 'you': true},
          {'rank': 4, 'name': 'Emma Davis', 'aha': 1845, 'you': false},
        ].asMap().entries.map((entry) {
          final person = entry.value;
          final bool isYou = person['you'] as bool;
          
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isYou 
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: isYou 
                  ? Border.all(color: Colors.white.withValues(alpha: 0.3))
                  : null,
            ),
            child: Div.row([
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: person['rank'] == 1
                      ? const Color(0xFFFFD700)
                      : person['rank'] == 2
                          ? const Color(0xFFC0C0C0)
                          : person['rank'] == 3
                              ? const Color(0xFFCD7F32)
                              : Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '${person['rank']}',
                    style: Typography.bodyMediumStyle.copyWith(
                      color: (person['rank'] as int) <= 3 ? Colors.white : Colors.white.withValues(alpha: 0.8),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),

              const Spacing.width(12),

              Expanded(
                child: Text(
                  person['name'] as String,
                  style: Typography.bodyMediumStyle.copyWith(
                    color: Colors.white,
                    fontWeight: isYou ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ),

              Text(
                '${person['aha']} Aha',
                style: Typography.bodyMediumStyle.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
            ]),
          );
        }),
      ]),
    );
  }
}


class OLD_AchievementShowcase extends StatelessWidget {
  const OLD_AchievementShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryGreen.withValues(alpha: 0.1),
            AppTheme.primaryBlue.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryGreen.withValues(alpha: 0.3),
        ),
      ),
      child: Div.column([
        Div.row([
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.emoji_events,
              color: Colors.white,
              size: 28,
            ),
          ),

          const Spacing.width(16),

          Expanded(
            child: Div.column([
              Text(
                'Speed Reader!',
                style: Typography.bodyLargeStyle.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryGreen,
                ),
              ),

              const Spacing.height(4),

              Text(
                'Read 5 books in one week',
                style: Typography.bodyMediumStyle.copyWith(
                  color: AppTheme.textPrimary.withValues(alpha: 0.8),
                ),
              ),
            ], crossAxisAlignment: CrossAxisAlignment.start),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '+50 Aha',
              style: Typography.bodyMediumStyle.copyWith(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ], crossAxisAlignment: CrossAxisAlignment.center),
      ]),
    );
  }
}

class CourseProgressCard extends StatelessWidget {
  const CourseProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.textPrimary.withValues(alpha: 0.1),
        ),
      ),
      child: Div.column([
        Text(
          'Course Progress',
          style: Typography.bodyLargeStyle.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),

        const Spacing.height(16),

        Div.row([
          Typography.bodyMedium('Current Course:'),

          const Spacer(),

          Text(
            'UX Design Fundamentals',
            style: Typography.bodyMediumStyle.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ], mainAxisAlignment: MainAxisAlignment.spaceBetween),

        const Spacing.height(8),

        Div.row([
          Typography.bodyMedium('Progress:'),

          const Spacer(),

          Text(
            '8/12 chapters',
            style: Typography.bodyMediumStyle.copyWith(
              color: AppTheme.primaryBlue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ], mainAxisAlignment: MainAxisAlignment.spaceBetween),

        const Spacing.height(12),

        Stack(
          children: [
            Container(
              width: double.infinity,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: AppTheme.textPrimary.withValues(alpha: 0.1),
              ),
            ),

            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.67,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryBlue, AppTheme.primaryGreen],
                  ),
                ),
              ),
            ),
          ],
        ),

        const Spacing.height(16),

        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Div.row([
            Icon(
              Icons.timer,
              color: AppTheme.primaryBlue,
              size: 16,
            ),

            const Spacing.width(8),

            Text(
              'Estimated 45 minutes to complete',
              style: Typography.bodyMediumStyle.copyWith(
                color: AppTheme.primaryBlue,
                fontSize: 12,
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Div.column([
      Text(
        'Quick Actions',
        style: Typography.bodyLargeStyle.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),

      const Spacing.height(16),

      Div.row([
        Expanded(
          child: ActionButton(
            label: 'Continue Reading',
            icon: Icons.play_arrow,
            color: AppTheme.primaryBlue,
            onTap: () {},
          ),
        ),

        const Spacing.width(12),

        Expanded(
          child: ActionButton(
            label: 'Browse Library',
            icon: Icons.library_books,
            color: AppTheme.primaryGreen,
            onTap: () {},
          ),
        ),
      ]),

      const Spacing.height(12),

      ActionButton(
        label: 'View All Achievements',
        icon: Icons.emoji_events,
        color: Colors.orange,
        onTap: () {},
        fullWidth: true,
      ),
    ]);
  }
}

class ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool fullWidth;

  const ActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
            ),
          ),
          child: Div.row([
            Icon(
              icon,
              color: color,
              size: 20,
            ),

            const Spacing.width(8),

            Text(
              label,
              style: Typography.bodyMediumStyle.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ], mainAxisAlignment: MainAxisAlignment.center),
        ),
      ),
    );
  }
}
