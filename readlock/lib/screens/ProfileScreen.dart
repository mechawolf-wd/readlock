// Duolingo-inspired gamified profile screen
// Showcases mockups of engaging learning patterns adapted for book reading

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLTheme.dart';
import 'package:readlock/widgets/ExpandableCard.dart';
import 'package:readlock/utility_widgets/AccountBottomSheet.dart';

const String PROFILE_GREETING = 'Welcome back, Alex!';
const String DAILY_GOAL_LABEL = 'Daily Goal';
const String ACHIEVEMENT_GALLERY_LABEL = 'Achievement Gallery';
const String READING_LEAGUE_LABEL = 'Reading League';
const String TYPEWRITER_SOUND = 'Typewriter';
const String SWITCHES_SOUND = 'Switches';
const String OIIA_SOUND = 'OIIA';

class ProfileScreen extends StatefulWidget {
  final bool showReadingLeagueExpanded;

  const ProfileScreen({
    super.key,
    this.showReadingLeagueExpanded = false,
  });

  @override
  State<ProfileScreen> createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RLTheme.backgroundDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ProfileContent(
            showReadingLeagueExpanded: widget.showReadingLeagueExpanded,
          ),
        ),
      ),
    );
  }
}

class ProfileContent extends StatefulWidget {
  final bool showReadingLeagueExpanded;

  const ProfileContent({
    super.key,
    this.showReadingLeagueExpanded = false,
  });

  @override
  State<ProfileContent> createState() => ProfileContentState();
}

class ProfileContentState extends State<ProfileContent> {
  bool soundsEnabled = true;
  bool hapticsEnabled = true;
  bool revealAllTrueFalse = false;
  bool blurEnabled = true;
  String textSpeed = 'Classic';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // TODO: Re-enable Reading League when ready
        // ReadingLeagueCard(
        //   initiallyExpanded: widget.showReadingLeagueExpanded,
        // ),
        //
        // const Spacing.height(20),

        // TODO: Re-enable Achievement Gallery when ready
        // const AchievementGallery(),
        //
        // const Spacing.height(20),

        // TODO: Re-enable Learning Statistics when ready
        // const LearningStatsCard(),
        //
        // const Spacing.height(20),

        const SoundPickerCard(),

        const Spacing.height(24),

        MenuSection(
          soundsEnabled: soundsEnabled,
          hapticsEnabled: hapticsEnabled,
          revealAllTrueFalse: revealAllTrueFalse,
          blurEnabled: blurEnabled,
          textSpeed: textSpeed,
          onSoundsToggled: (value) =>
              setState(() => soundsEnabled = value),
          onHapticsToggled: (value) =>
              setState(() => hapticsEnabled = value),
          onRevealAllTrueFalseToggled: (value) =>
              setState(() => revealAllTrueFalse = value),
          onBlurToggled: (value) =>
              setState(() => blurEnabled = value),
          onTextSpeedChanged: (value) =>
              setState(() => textSpeed = value),
        ),
      ],
    );
  }
}

class LearningStatsCard extends StatelessWidget {
  const LearningStatsCard({super.key});

  static const Widget ShareIcon = Icon(
    Icons.share,
    color: RLTheme.white,
    size: 20,
  );

  @override
  Widget build(BuildContext context) {
    final BoxDecoration cardDecoration = BoxDecoration(
      color: RLTheme.primaryBlue,
      borderRadius: BorderRadius.circular(16),
    );

    void handleShareTap() {
      // Share functionality
    }

    return Container(
      decoration: cardDecoration,
      padding: const EdgeInsets.all(20),
      child: Div.column([
        // Header row
        Div.row([
          RLTypography.headingMedium(
            'Learning Statistics',
            color: RLTheme.white,
          ),

          const Spacer(),

          GestureDetector(
            onTap: handleShareTap,
            child: ShareIcon,
          ),
        ]),

        const Spacing.height(20),

        // Stats row
        StatsRow(),
      ]),
    );
  }

  Widget StatsRow() {
    return Div.row([
      // Days equivalent stat
      const Expanded(
        child: StatItem(
          value: '127',
          unit: 'days',
          label: 'at 1h/day',
        ),
      ),

      // Divider
      Container(
        width: 1,
        height: 48,
        color: Colors.white.withValues(alpha: 0.2),
      ),

      // Lessons completed stat
      const Expanded(
        child: StatItem(
          value: '42',
          unit: 'lessons',
          label: 'completed',
        ),
      ),
    ]);
  }
}

class StatItem extends StatelessWidget {
  final String value;
  final String unit;
  final String label;

  const StatItem({
    super.key,
    required this.value,
    required this.unit,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Div.column([
      Div.row([
        RLTypography.headingLarge(
          value,
          color: Colors.white,
        ),

        const Spacing.width(4),

        RLTypography.bodyMedium(
          unit,
          color: Colors.white.withValues(alpha: 0.8),
        ),
      ], mainAxisAlignment: MainAxisAlignment.center),

      const Spacing.height(4),

      RLTypography.bodyMedium(
        label,
        color: Colors.white.withValues(alpha: 0.6),
        textAlign: TextAlign.center,
      ),
    ], crossAxisAlignment: CrossAxisAlignment.center);
  }
}

class MenuSection extends StatelessWidget {
  final bool soundsEnabled;
  final bool hapticsEnabled;
  final bool revealAllTrueFalse;
  final bool blurEnabled;
  final String textSpeed;
  final ValueChanged<bool> onSoundsToggled;
  final ValueChanged<bool> onHapticsToggled;
  final ValueChanged<bool> onRevealAllTrueFalseToggled;
  final ValueChanged<bool> onBlurToggled;
  final ValueChanged<String> onTextSpeedChanged;

  const MenuSection({
    super.key,
    required this.soundsEnabled,
    required this.hapticsEnabled,
    required this.revealAllTrueFalse,
    required this.blurEnabled,
    required this.textSpeed,
    required this.onSoundsToggled,
    required this.onHapticsToggled,
    required this.onRevealAllTrueFalseToggled,
    required this.onBlurToggled,
    required this.onTextSpeedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Div.column([
      // Account & Subscription
      MenuItem(
        icon: Icons.person,
        title: 'Account',
        onTap: () => AccountBottomSheet.show(context),
      ),

      MenuItem(
        icon: Icons.card_membership,
        title: 'Reader Pass',
        onTap: () {},
      ),

      const MenuDivider(),

      // App Settings
      SwitchMenuItem(
        icon: Icons.volume_up,
        title: 'Sounds',
        value: soundsEnabled,
        onChanged: onSoundsToggled,
      ),

      SwitchMenuItem(
        icon: Icons.vibration,
        title: 'Haptics',
        value: hapticsEnabled,
        onChanged: onHapticsToggled,
      ),

      const MenuDivider(),

      // Reading Settings
      SwitchMenuItem(
        icon: Icons.visibility,
        title: 'Reveal all true false',
        value: revealAllTrueFalse,
        onChanged: onRevealAllTrueFalseToggled,
      ),

      SwitchMenuItem(
        icon: Icons.blur_on,
        title: 'Blur',
        value: blurEnabled,
        onChanged: onBlurToggled,
      ),

      SegmentedMenuItem(
        icon: Icons.speed,
        title: 'Text speed',
        options: const ['Careful', 'Classic', 'Speed'],
        selectedOption: textSpeed,
        onChanged: onTextSpeedChanged,
      ),

      const MenuDivider(),

      // Support & Information
      MenuItem(
        icon: Icons.notifications,
        title: 'Notifications',
        onTap: () {},
      ),

      MenuItem(icon: Icons.info, title: 'About', onTap: () {}),

      MenuItem(icon: Icons.help, title: 'Help', onTap: () {}),

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

      const MenuDivider(),

      // Account Actions & Legal
      MenuItem(icon: Icons.gavel, title: 'Legal', onTap: () {}),

      MenuItem(
        icon: Icons.logout,
        title: 'Log out',
        onTap: () {},
        textColor: RLTheme.errorColor,
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
    final Color iconColor =
        textColor ?? RLTheme.textPrimary.withValues(alpha: 0.7);
    final Color titleColor = textColor ?? RLTheme.textPrimary;

    return Div.row(
      [
        Icon(icon, color: iconColor, size: 20),

        const Spacing.width(16),

        Expanded(
          child: RLTypography.bodyMedium(title, color: titleColor),
        ),

        Icon(
          Icons.chevron_right,
          color: RLTheme.textPrimary.withValues(alpha: 0.3),
          size: 20,
        ),
      ],
      padding: const EdgeInsets.symmetric(vertical: 16),
      onTap: onTap,
    );
  }
}

class AchievementGallery extends StatelessWidget {
  const AchievementGallery({super.key});

  @override
  Widget build(BuildContext context) {
    final LinearGradient achievementGradient = const LinearGradient(
      colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final Widget achievementContent = this.achievementContent();

    return ExpandableCard(
      title: ACHIEVEMENT_GALLERY_LABEL,
      icon: Icons.emoji_events,
      gradient: achievementGradient,
      titleColor: Colors.white,
      iconColor: Colors.white,
      expandedContent: achievementContent,
    );
  }

  Widget achievementContent() {
    return Div.column([
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: getAchievementBadges(),
      ),
    ]);
  }

  Widget getAchievementBadges() {
    final List<Map<String, dynamic>> badgeData = [
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
        'desc': '5 titles in a week',
        'earned': false,
      },
    ];

    final List<Widget> badges = badgeData.map((badge) {
      final bool earned = badge['earned'] as bool;

      final Color badgeBackgroundColor = earned
          ? Colors.white
          : Colors.white.withValues(alpha: 0.2);

      final Color badgeBorderColor = earned
          ? Colors.transparent
          : Colors.white.withValues(alpha: 0.3);

      final BoxDecoration badgeDecoration = BoxDecoration(
        color: badgeBackgroundColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: badgeBorderColor, width: 2),
      );

      final Color iconColor = earned
          ? const Color(0xFFFFD700)
          : Colors.white.withValues(alpha: 0.4);

      return Container(
        width: 80,
        margin: const EdgeInsets.only(right: 16),
        child: Div.column([
          Container(
            width: 60,
            height: 60,
            decoration: badgeDecoration,
            child: Icon(
              badge['icon'] as IconData,
              color: iconColor,
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
    }).toList();

    return Div.row(badges);
  }
}

class ReadingLeagueCard extends StatelessWidget {
  final bool initiallyExpanded;

  const ReadingLeagueCard({super.key, this.initiallyExpanded = false});

  @override
  Widget build(BuildContext context) {
    final LinearGradient leagueGradient = const LinearGradient(
      colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final Widget leagueContent = readingLeagueContent();

    return ExpandableCard(
      title: READING_LEAGUE_LABEL,
      icon: Icons.leaderboard,
      gradient: leagueGradient,
      titleColor: Colors.white,
      iconColor: Colors.white,
      expandedContent: leagueContent,
      initiallyExpanded: initiallyExpanded,
    );
  }

  Widget readingLeagueContent() {
    final EdgeInsets leagueBadgePadding = const EdgeInsets.symmetric(
      horizontal: 10,
      vertical: 4,
    );

    final BoxDecoration leagueBadgeDecoration = BoxDecoration(
      color: Colors.white.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(12),
    );

    return Div.column([
      Div.row([
        Container(
          padding: leagueBadgePadding,
          decoration: leagueBadgeDecoration,
          child: RLTypography.bodyMedium('GOLD', color: Colors.white),
        ),
      ], mainAxisAlignment: MainAxisAlignment.end),

      const Spacing.height(16),

      RLTypography.bodyMedium(
        'You\'re #3 out of 47 in your reading group this week!',
        color: Colors.white.withValues(alpha: 0.9),
        textAlign: TextAlign.center,
      ),

      const Spacing.height(16),

      leaderboardList(),
    ]);
  }

  Widget leaderboardList() {
    final List<Map<String, dynamic>> leaderboardData = [
      {'rank': 1, 'name': 'Sarah Chen', 'aha': 2847, 'you': false},
      {'rank': 2, 'name': 'Mike Johnson', 'aha': 2156, 'you': false},
      {'rank': 3, 'name': 'You', 'aha': 1923, 'you': true},
      {'rank': 4, 'name': 'Emma Davis', 'aha': 1845, 'you': false},
    ];

    final List<Widget> leaderboardItems = leaderboardData.map((person) {
      final bool isYou = person['you'] as bool;
      final int rank = person['rank'] as int;

      final Color personBackgroundColor = isYou
          ? Colors.white.withValues(alpha: 0.2)
          : Colors.white.withValues(alpha: 0.05);

      final Border? personBorder = isYou
          ? Border.all(color: Colors.white.withValues(alpha: 0.3))
          : null;

      final BoxDecoration personDecoration = BoxDecoration(
        color: personBackgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: personBorder,
      );

      final Color rankBackgroundColor = rank == 1
          ? const Color(0xFFFFD700)
          : rank == 2
          ? const Color(0xFFC0C0C0)
          : rank == 3
          ? const Color(0xFFCD7F32)
          : Colors.white.withValues(alpha: 0.2);

      final BoxDecoration rankDecoration = BoxDecoration(
        color: rankBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      );

      final bool isTopThree = rank <= 3;
      final Color rankTextColor = isTopThree
          ? Colors.white
          : Colors.white.withValues(alpha: 0.8);

      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        decoration: personDecoration,
        child: Div.row([
          Container(
            width: 24,
            height: 24,
            decoration: rankDecoration,
            child: Center(
              child: RLTypography.bodyMedium(
                '${person['rank']}',
                color: rankTextColor,
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
    }).toList();

    return Div.column(leaderboardItems);
  }
}

class SoundPickerCard extends StatefulWidget {
  const SoundPickerCard({super.key});

  @override
  State<SoundPickerCard> createState() => SoundPickerCardState();
}

class SoundPickerCardState extends State<SoundPickerCard> {
  String selectedSound = TYPEWRITER_SOUND;

  @override
  Widget build(BuildContext context) {
    final Widget soundContent = soundPickerContent();

    return ExpandableCard(
      title: 'Sound Settings',
      icon: Icons.volume_up,
      backgroundColor: RLTheme.backgroundLight,
      titleColor: RLTheme.textPrimary,
      iconColor: RLTheme.textSecondary,
      expandedContent: soundContent,
    );
  }

  Widget soundPickerContent() {
    final List<Map<String, dynamic>> soundOptions = [
      {
        'name': TYPEWRITER_SOUND,
        'icon': Icons.keyboard,
      },
      {
        'name': SWITCHES_SOUND,
        'icon': Icons.toggle_on,
      },
      {
        'name': OIIA_SOUND,
        'icon': Icons.music_note,
      },
    ];

    final List<Widget> soundBlocks = soundOptions.map((sound) {
      final bool isSelected = selectedSound == sound['name'];

      return Expanded(
        child: soundBlock(
          name: sound['name'] as String,
          icon: sound['icon'] as IconData,
          isSelected: isSelected,
          onTap: () => selectSound(sound['name'] as String),
        ),
      );
    }).toList();

    return Div.row(
      soundBlocks,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    );
  }

  Widget soundBlock({
    required String name,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final Color backgroundColor = isSelected
        ? RLTheme.primaryBlue.withValues(alpha: 0.1)
        : Colors.transparent;

    final Color borderColor = isSelected
        ? RLTheme.primaryBlue
        : RLTheme.textPrimary.withValues(alpha: 0.2);

    final Color iconColor = isSelected
        ? RLTheme.primaryBlue
        : RLTheme.textSecondary;

    final Color textColor = isSelected
        ? RLTheme.primaryBlue
        : RLTheme.textPrimary;

    final BoxDecoration blockDecoration = BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: borderColor),
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: blockDecoration,
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Div.column([
          Icon(icon, color: iconColor, size: 24),

          const Spacing.height(8),

          RLTypography.bodyMedium(
            name,
            color: textColor,
            textAlign: TextAlign.center,
            maxLines: 1,
          ),
        ], crossAxisAlignment: CrossAxisAlignment.center),
      ),
    );
  }

  void selectSound(String soundName) {
    setState(() {
      selectedSound = soundName;
    });
  }
}

class SwitchMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SwitchMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final Color iconColor = RLTheme.textPrimary.withValues(alpha: 0.7);
    final Color titleColor = RLTheme.textPrimary;

    return Div.row([
      Icon(icon, color: iconColor, size: 20),

      const Spacing.width(16),

      Expanded(
        child: RLTypography.bodyMedium(title, color: titleColor),
      ),

      Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: RLTheme.primaryBlue,
        activeTrackColor: RLTheme.primaryBlue.withValues(alpha: 0.3),
        inactiveThumbColor: RLTheme.textPrimary.withValues(alpha: 0.5),
        inactiveTrackColor: RLTheme.textPrimary.withValues(alpha: 0.1),
      ),
    ], padding: const EdgeInsets.symmetric(vertical: 16));
  }
}

class SegmentedMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> options;
  final String selectedOption;
  final ValueChanged<String> onChanged;

  const SegmentedMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.options,
    required this.selectedOption,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final Color iconColor = RLTheme.textPrimary.withValues(alpha: 0.7);
    final Color titleColor = RLTheme.textPrimary;

    return Div.column([
      Div.row([
        Icon(icon, color: iconColor, size: 20),

        const Spacing.width(16),

        Expanded(
          child: RLTypography.bodyMedium(title, color: titleColor),
        ),
      ]),

      const Spacing.height(12),

      // Segmented options
      SegmentedOptions(
        options: options,
        selectedOption: selectedOption,
        onChanged: onChanged,
      ),
    ], padding: const EdgeInsets.symmetric(vertical: 16));
  }

  Widget SegmentedOptions({
    required List<String> options,
    required String selectedOption,
    required ValueChanged<String> onChanged,
  }) {
    final BoxDecoration containerDecoration = BoxDecoration(
      color: RLTheme.textPrimary.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(8),
    );

    return Container(
      decoration: containerDecoration,
      padding: const EdgeInsets.all(4),
      child: Row(
        children: OptionButtons(options, selectedOption, onChanged),
      ),
    );
  }

  List<Widget> OptionButtons(
    List<String> options,
    String selectedOption,
    ValueChanged<String> onChanged,
  ) {
    return options.map((option) {
      final bool isSelected = option == selectedOption;

      final BoxDecoration optionDecoration = BoxDecoration(
        color: isSelected ? RLTheme.primaryBlue : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
      );

      final Color textColor = isSelected
          ? RLTheme.white
          : RLTheme.textPrimary.withValues(alpha: 0.6);

      return Expanded(
        child: GestureDetector(
          onTap: () => onChanged(option),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: optionDecoration,
            child: Center(
              child: RLTypography.bodyMedium(option, color: textColor),
            ),
          ),
        ),
      );
    }).toList();
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
