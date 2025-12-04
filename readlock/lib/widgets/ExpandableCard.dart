// Expandable card widget that shows title and icon when collapsed
// Expands to show full content when tapped

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLTheme.dart';

const double CARD_BORDER_RADIUS = 16.0;
const double HEADER_PADDING = 20.0;
const double ICON_SIZE_MAIN = 24.0;
const double ICON_SIZE_ARROW = 20.0;
const double DIVIDER_HEIGHT = 1.0;
const double CONTENT_PADDING_HORIZONTAL = 20.0;
const double CONTENT_PADDING_TOP = 16.0;
const double CONTENT_PADDING_BOTTOM = 20.0;

class ExpandableCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Widget expandedContent;
  final Gradient? gradient;
  final Color? backgroundColor;
  final Color? titleColor;
  final Color? iconColor;
  final bool initiallyExpanded;

  const ExpandableCard({
    super.key,
    required this.title,
    required this.icon,
    required this.expandedContent,
    this.gradient,
    this.backgroundColor,
    this.titleColor,
    this.iconColor,
    this.initiallyExpanded = false,
  });

  @override
  State<ExpandableCard> createState() => ExpandableCardState();
}

class ExpandableCardState extends State<ExpandableCard> {
  late bool isExpanded;

  @override
  void initState() {
    super.initState();
    isExpanded = widget.initiallyExpanded;
  }

  void handleExpansionToggle() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final BoxDecoration cardDecoration = getCardDecoration();
    final Color titleColor = getTitleColor();
    final Color iconColor = getIconColor();
    final Widget headerSection = HeaderSection(titleColor, iconColor);
    final Widget expandedSection = ExpandedSection(titleColor);

    return Container(
      decoration: cardDecoration,
      child: Div.column([headerSection, expandedSection]),
    );
  }

  BoxDecoration getCardDecoration() {
    final bool hasGradient = widget.gradient != null;
    final Color fallbackColor =
        widget.backgroundColor ?? RLTheme.backgroundLight;

    final Border? cardBorder = hasGradient
        ? null
        : Border.all(color: RLTheme.textPrimary.withValues(alpha: 0.1));

    return BoxDecoration(
      gradient: widget.gradient,
      color: fallbackColor,
      borderRadius: BorderRadius.circular(CARD_BORDER_RADIUS),
      border: cardBorder,
    );
  }

  Color getTitleColor() {
    final bool hasCustomColor = widget.titleColor != null;

    if (hasCustomColor) {
      return widget.titleColor!;
    }

    final bool hasGradient = widget.gradient != null;

    return hasGradient ? Colors.white : RLTheme.textPrimary;
  }

  Color getIconColor() {
    final bool hasCustomColor = widget.iconColor != null;

    if (hasCustomColor) {
      return widget.iconColor!;
    }

    final bool hasGradient = widget.gradient != null;

    return hasGradient ? Colors.white : RLTheme.primaryBlue;
  }

  Widget HeaderSection(Color titleColor, Color iconColor) {
    final Widget mainIcon = MainIcon(iconColor);
    final Widget titleText = TitleText(titleColor);
    final Widget arrowIcon = ArrowIcon(titleColor);

    return Div.row(
      [
        mainIcon,

        const Spacing.width(12),

        Expanded(child: titleText),

        arrowIcon,
      ],
      padding: const EdgeInsets.all(HEADER_PADDING),
      onTap: handleExpansionToggle,
    );
  }

  Widget MainIcon(Color iconColor) {
    return Icon(widget.icon, color: iconColor, size: ICON_SIZE_MAIN);
  }

  Widget TitleText(Color titleColor) {
    return RLTypography.bodyLarge(widget.title, color: titleColor);
  }

  Widget ArrowIcon(Color titleColor) {
    final IconData chevronIcon = isExpanded
        ? Icons.expand_less
        : Icons.expand_more;

    return Icon(
      chevronIcon,
      color: titleColor.withValues(alpha: 0.7),
      size: ICON_SIZE_ARROW,
    );
  }

  Widget ExpandedSection(Color titleColor) {
    return RenderIf.condition(
      isExpanded,

      Div.column([DividerLine(titleColor), ContentContainer()]),
    );
  }

  Widget DividerLine(Color titleColor) {
    return Container(
      height: DIVIDER_HEIGHT,
      color: titleColor.withValues(alpha: 0.1),
      margin: const EdgeInsets.symmetric(
        horizontal: CONTENT_PADDING_HORIZONTAL,
      ),
    );
  }

  Widget ContentContainer() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        CONTENT_PADDING_HORIZONTAL,
        CONTENT_PADDING_TOP,
        CONTENT_PADDING_HORIZONTAL,
        CONTENT_PADDING_BOTTOM,
      ),
      child: widget.expandedContent,
    );
  }
}
