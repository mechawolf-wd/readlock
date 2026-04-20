// Motivational breathing slide between lesson sections
// Gives the reader a short emotional pause with an icon and an encouraging message

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLDesignSystem.dart';


import 'package:pixelarticons/pixel.dart';
class CCPause extends StatelessWidget {
  final String text;
  final String? iconName;

  const CCPause({super.key, required this.text, this.iconName});

  @override
  Widget build(BuildContext context) {
    // Extract styling above build method
    final TextStyle motivationalTextStyle = RLTypography.readingLargeStyle.copyWith(
      fontWeight: FontWeight.w600,
      color: RLDS.textPrimary.withValues(alpha: 0.7),
    );

    return Div.column(
      [
        // Simple motivational content on plain background
        SimpleMotivationalContent(motivationalTextStyle: motivationalTextStyle),
      ],
      color: RLDS.backgroundDark,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 40,
      ),
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }

  Widget SimpleMotivationalContent({required TextStyle motivationalTextStyle}) {
    return Div.column(
      [
        // Small motivational icon
        MotivationalIcon(),

        const Spacing.height(16),

        // Short motivational text
        MotivationalText(textStyle: motivationalTextStyle),
      ],
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }

  Widget MotivationalIcon() {
    final IconData motivationalIconData = getIconDataFromName();
    final Color motivationalIconColor = RLDS.success.withValues(alpha: 0.8);

    final Widget IconWidget = Icon(
      motivationalIconData,
      size: 32,
      color: motivationalIconColor,
    );

    return IconWidget;
  }

  Widget MotivationalText({required TextStyle textStyle}) {
    return Text(text, style: textStyle, textAlign: TextAlign.center);
  }

  IconData getIconDataFromName() {
    switch (iconName?.toLowerCase()) {
      case 'rocket':
        {
          return Pixel.trendingup;
        }
      case 'star':
        {
          return Pixel.moonstars;
        }
      case 'fire':
        {
          return Pixel.zap;
        }
      case 'trophy':
        {
          return Pixel.trophy;
        }
      case 'heart':
        {
          return Pixel.heart;
        }
      case 'thumbs_up':
        {
          return Pixel.heart;
        }
      case 'celebration':
        {
          return Pixel.trophy;
        }
      case 'target':
        {
          return Pixel.reload;
        }
      case 'lightning':
        {
          return Pixel.zap;
        }
      case 'crown':
        {
          return Pixel.trophy;
        }
      case 'check':
        {
          return Pixel.check;
        }
      case 'progress':
        {
          return Pixel.trendingup;
        }
      default:
        {
          return Pixel.trendingup;
        }
    }
  }
}
