import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/RLConstants.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLTheme.dart';

const double EMOTIONAL_SLIDE_ICON_SIZE = 32.0;
const double EMOTIONAL_SLIDE_SPACING = 16.0;
const double EMOTIONAL_SLIDE_VERTICAL_PADDING = 40.0;

class CCEmotionalSlide extends StatelessWidget {
  final String text;
  final String? iconName;

  const CCEmotionalSlide({
    super.key,
    required this.text,
    this.iconName,
  });

  @override
  Widget build(BuildContext context) {
    // Extract styling above build method
    final TextStyle motivationalTextStyle = RLTypography.bodyLargeStyle
        .copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: RLTheme.textPrimary.withValues(alpha: 0.7),
          height: 1.2,
        );

    return Div.column(
      [
        // Simple motivational content on plain background
        SimpleMotivationalContent(
          motivationalTextStyle: motivationalTextStyle,
        ),
      ],
      color: RLTheme.backgroundDark,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: EMOTIONAL_SLIDE_VERTICAL_PADDING,
      ),
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }

  Widget SimpleMotivationalContent({
    required TextStyle motivationalTextStyle,
  }) {
    return Div.column(
      [
        // Small motivational icon
        MotivationalIcon(),

        const Spacing.height(EMOTIONAL_SLIDE_SPACING),

        // Short motivational text
        MotivationalText(textStyle: motivationalTextStyle),
      ],
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }

  Widget MotivationalIcon() {
    final IconData motivationalIconData = getIconDataFromName();
    final Color motivationalIconColor = RLTheme.primaryGreen.withValues(
      alpha: 0.8,
    );

    return Icon(
      motivationalIconData,
      size: EMOTIONAL_SLIDE_ICON_SIZE,
      color: motivationalIconColor,
    );
  }

  Widget MotivationalText({required TextStyle textStyle}) {
    return Text(text, style: textStyle, textAlign: TextAlign.center);
  }

  IconData getIconDataFromName() {
    switch (iconName?.toLowerCase()) {
      case 'rocket':
        return Icons.rocket_launch;
      case 'star':
        return Icons.star;
      case 'fire':
        return Icons.local_fire_department;
      case 'trophy':
        return Icons.emoji_events;
      case 'heart':
        return Icons.favorite;
      case 'thumbs_up':
        return Icons.thumb_up;
      case 'celebration':
        return Icons.celebration;
      case 'target':
        return Icons.track_changes;
      case 'lightning':
        return Icons.flash_on;
      case 'crown':
        return Icons.workspace_premium;
      case 'check':
        return Icons.check_circle_outline;
      case 'progress':
        return Icons.trending_up;
      default:
        return Icons.rocket_launch; // Default icon
    }
  }
}
