// Duolingo-inspired gamified profile screen
// Showcases mockups of engaging learning patterns adapted for book reading

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLTheme.dart';

const String PROFILE_GREETING = 'Welcome back, Alex!';
const String DAILY_GOAL_LABEL = 'Daily Goal';
const String ACHIEVEMENT_GALLERY_LABEL = 'Achievement Gallery';
const String READING_LEAGUE_LABEL = 'Reading League';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: RLTheme.backgroundDark,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Div.column([
            ReadingLeagueCard(),

            const Spacing.height(20),

            AchievementGallery(),

            const Spacing.height(24),

            MenuSection(),
          ], crossAxisAlignment: CrossAxisAlignment.stretch),
        ),
      ),
    );
  }
}

class MenuSection extends StatelessWidget {
  const MenuSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Div.column([
      // Account & Subscription
      MenuItem(
        icon: Icons.person,
        title: 'Account',
        onTap: () {},
      ),

      MenuItem(
        icon: Icons.card_membership,
        title: 'Reader Pass',
        onTap: () {},
      ),

      MenuDivider(),

      // App Settings
      MenuItem(
        icon: Icons.notifications,
        title: 'Notifications',
        onTap: () {},
      ),

      MenuItem(
        icon: Icons.volume_up,
        title: 'Sounds',
        onTap: () {},
      ),

      MenuItem(
        icon: Icons.vibration,
        title: 'Haptics',
        onTap: () {},
      ),

      MenuDivider(),

      // Support & Information
      MenuItem(
        icon: Icons.info,
        title: 'About',
        onTap: () {},
      ),

      MenuItem(
        icon: Icons.help,
        title: 'Help',
        onTap: () {},
      ),

      MenuItem(
        icon: Icons.bug_report,
        title: 'Report a problem',
        onTap: () {},
      ),

      MenuItem(
        icon: Icons.new_releases,
        title: 'Product Updates',
        onTap: () {},
      ),

      MenuDivider(),

      // Account Actions & Legal
      MenuItem(
        icon: Icons.gavel,
        title: 'Legal',
        onTap: () {},
      ),

      MenuItem(
        icon: Icons.logout,
        title: 'Log out',
        onTap: () {},
        textColor: Colors.red,
      ),

      const Spacing.height(24),

      Center(
        child: RLTypography.bodyMedium(
          'Version 1.0.0',
          color: RLTheme.textPrimary.withValues(alpha: 0.5),
        ),
      ),
    ]);
  }
}

class MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;

  const MenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Div.row([
      Icon(
        icon,
        color: textColor ?? RLTheme.textPrimary.withValues(alpha: 0.7),
        size: 20,
      ),

      const Spacing.width(16),

      Expanded(
        child: RLTypography.bodyMedium(
          title,
          color: textColor ?? RLTheme.textPrimary,
        ),
      ),

      Icon(
        Icons.chevron_right,
        color: RLTheme.textPrimary.withValues(alpha: 0.3),
        size: 20,
      ),
    ], 
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
      onTap: onTap,
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
        color: RLTheme.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: RLTheme.textPrimary.withValues(alpha: 0.1),
        ),
      ),
      child: Div.column([
        RLTypography.bodyMedium(
          'This widget was replaced by new Duolingo-inspired components above',
          color: RLTheme.textPrimary.withValues(alpha: 0.5),
          textAlign: TextAlign.center,
        ),

        const Spacing.height(20),

        Div.row([
          StatisticItem(
            label: 'Books Read',
            value: '127',
            icon: Icons.menu_book,
            color: RLTheme.primaryBlue,
          ),

          StatisticItem(
            label: 'Hours Spent',
            value: '342h',
            icon: Icons.access_time,
            color: RLTheme.primaryGreen,
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
          child: Icon(icon, color: color, size: 20),
        ),

        const Spacing.height(8),

        RLTypography.headingMedium(value),

        const Spacing.height(4),

        RLTypography.bodyMedium(
          label,
          color: RLTheme.textPrimary.withValues(alpha: 0.6),
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
          const Icon(Icons.emoji_events, color: Colors.white, size: 24),

          const Spacing.width(12),

          RLTypography.bodyLarge(
            ACHIEVEMENT_GALLERY_LABEL,
            color: Colors.white,
          ),

          const Spacer(),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: RLTypography.bodyMedium(
              '47/100',
              color: Colors.white,
            ),
          ),
        ]),

        const Spacing.height(20),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Div.row([
            ...[
              {
                'icon': Icons.local_fire_department,
                'title': 'Streak Master',
                'desc': '30 day streak',
                'earned': true,
              },
              {
                'icon': Icons.school,
                'title': 'Book Worm',
                'desc': '10 books read',
                'earned': true,
              },
              {
                'icon': Icons.lightbulb,
                'title': 'Insight Hunter',
                'desc': '100 insights',
                'earned': true,
              },
              {
                'icon': Icons.speed,
                'title': 'Speed Reader',
                'desc': '5 books in a week',
                'earned': false,
              },
              {
                'icon': Icons.quiz,
                'title': 'Quiz Master',
                'desc': '50 perfect scores',
                'earned': false,
              },
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

                  RLTypography.bodyMedium(
                    badge['title'] as String,
                    color: Colors.white,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const Spacing.height(2),

                  RLTypography.bodyMedium(
                    badge['desc'] as String,
                    color: Colors.white.withValues(alpha: 0.8),
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
          child: RLTypography.bodyMedium(
            'Complete 3 more chapters to unlock \'Quiz Master\' badge! 🏆',
            color: Colors.white.withValues(alpha: 0.9),
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
          const Icon(Icons.leaderboard, color: Colors.white, size: 24),

          const Spacing.width(12),

          Expanded(
            child: RLTypography.bodyLarge(
              READING_LEAGUE_LABEL,
              color: Colors.white,
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: RLTypography.bodyMedium('GOLD', color: Colors.white),
          ),
        ]),

        const Spacing.height(16),

        RLTypography.bodyMedium(
          'You\'re #3 out of 47 in your reading group this week!',
          color: Colors.white.withValues(alpha: 0.9),
          textAlign: TextAlign.center,
        ),

        const Spacing.height(16),

        ...[
          {'rank': 1, 'name': 'Sarah Chen', 'aha': 2847, 'you': false},
          {
            'rank': 2,
            'name': 'Mike Johnson',
            'aha': 2156,
            'you': false,
          },
          {'rank': 3, 'name': 'You', 'aha': 1923, 'you': true},
          {'rank': 4, 'name': 'Emma Davis', 'aha': 1845, 'you': false},
        ].asMap().entries.map((entry) {
          final person = entry.value;
          final bool isYou = person['you'] as bool;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: isYou
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(8),
              border: isYou
                  ? Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                    )
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
                  child: RLTypography.bodyMedium(
                    '${person['rank']}',
                    color: (person['rank'] as int) <= 3
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ),

              const Spacing.width(12),

              Expanded(
                child: RLTypography.bodyMedium(
                  person['name'] as String,
                  color: Colors.white,
                ),
              ),

              RLTypography.bodyMedium(
                '${person['aha']} Aha',
                color: Colors.white.withValues(alpha: 0.8),
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
            RLTheme.primaryGreen.withValues(alpha: 0.1),
            RLTheme.primaryBlue.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: RLTheme.primaryGreen.withValues(alpha: 0.3),
        ),
      ),
      child: Div.column([
        Div.row([
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: RLTheme.primaryGreen,
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
              RLTypography.bodyLarge(
                'Speed Reader!',
                color: RLTheme.primaryGreen,
              ),

              const Spacing.height(4),

              RLTypography.bodyMedium(
                'Read 5 books in one week',
                color: RLTheme.textPrimary.withValues(alpha: 0.8),
              ),
            ], crossAxisAlignment: CrossAxisAlignment.start),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: RLTheme.primaryGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: RLTypography.bodyMedium(
              '+50 Aha',
              color: Colors.white,
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
        color: RLTheme.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: RLTheme.textPrimary.withValues(alpha: 0.1),
        ),
      ),
      child: Div.column([
        RLTypography.bodyLarge('Course Progress'),

        const Spacing.height(16),

        Div.row([
          RLTypography.bodyMedium('Current Course:'),

          const Spacer(),

          RLTypography.bodyMedium('UX Design Fundamentals'),
        ], mainAxisAlignment: MainAxisAlignment.spaceBetween),

        const Spacing.height(8),

        Div.row([
          RLTypography.bodyMedium('Progress:'),

          const Spacer(),

          RLTypography.bodyMedium(
            '8/12 chapters',
            color: RLTheme.primaryBlue,
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
                color: RLTheme.textPrimary.withValues(alpha: 0.1),
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
                    colors: [RLTheme.primaryBlue, RLTheme.primaryGreen],
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
            color: RLTheme.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Div.row([
            Icon(Icons.timer, color: RLTheme.primaryBlue, size: 16),

            const Spacing.width(8),

            RLTypography.bodyMedium(
              'Estimated 45 minutes to complete',
              color: RLTheme.primaryBlue,
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
      RLTypography.bodyLarge('Quick Actions'),

      const Spacing.height(16),

      Div.row([
        Expanded(
          child: ActionButton(
            label: 'Continue Reading',
            icon: Icons.play_arrow,
            color: RLTheme.primaryBlue,
            onTap: () {},
          ),
        ),

        const Spacing.width(12),

        Expanded(
          child: ActionButton(
            label: 'Browse Library',
            icon: Icons.library_books,
            color: RLTheme.primaryGreen,
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
    return Div.row(
      [
        Icon(icon, color: color, size: 20),

        const Spacing.width(8),

        RLTypography.bodyMedium(label, color: color),
      ],
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        color: color.withValues(alpha: 0.1),
      ),
      radius: BorderRadius.circular(12),
      mainAxisAlignment: MainAxisAlignment.center,
      onTap: onTap,
    );
  }
}

class MenuDivider extends StatelessWidget {
  const MenuDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: RLTheme.textPrimary.withValues(alpha: 0.1),
    );
  }
}
