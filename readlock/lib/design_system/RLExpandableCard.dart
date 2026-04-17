// Expandable card widget that shows title and icon when collapsed
// Expands to show full content when tapped

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/constants/RLDesignSystem.dart';

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
    final bool hasBackgroundColor = widget.backgroundColor != null;

    Color fallbackColor = RLDS.backgroundLight;

    if (hasBackgroundColor) {
      fallbackColor = widget.backgroundColor!;
    }

    Border? cardBorder;

    if (!hasGradient) {
      cardBorder = Border.all(color: RLDS.textPrimary.withValues(alpha: 0.1));
    }

    return BoxDecoration(
      gradient: widget.gradient,
      color: fallbackColor,
      borderRadius: BorderRadius.circular(16.0),
      border: cardBorder,
    );
  }

  Color getTitleColor() {
    final bool hasCustomColor = widget.titleColor != null;

    if (hasCustomColor) {
      return widget.titleColor!;
    }

    final bool hasGradient = widget.gradient != null;

    if (hasGradient) {
      return RLDS.white;
    }

    return RLDS.textPrimary;
  }

  Color getIconColor() {
    final bool hasCustomColor = widget.iconColor != null;

    if (hasCustomColor) {
      return widget.iconColor!;
    }

    final bool hasGradient = widget.gradient != null;

    if (hasGradient) {
      return RLDS.white;
    }

    return RLDS.info;
  }

  Widget HeaderSection(Color titleColor, Color iconColor) {
    final Widget mainIcon = MainIcon(iconColor);
    final Widget titleText = TitleText(titleColor);
    final Widget arrowIcon = ArrowIcon(titleColor);

    return Div.row(
      [mainIcon, const Spacing.width(12), Expanded(child: titleText), arrowIcon],
      padding: const EdgeInsets.all(20.0),
      onTap: handleExpansionToggle,
    );
  }

  Widget MainIcon(Color iconColor) {
    return Icon(widget.icon, color: iconColor, size: 24.0);
  }

  Widget TitleText(Color titleColor) {
    return RLTypography.bodyLarge(widget.title, color: titleColor);
  }

  Widget ArrowIcon(Color titleColor) {
    IconData chevronIcon = Icons.expand_more;

    if (isExpanded) {
      chevronIcon = Icons.expand_less;
    }

    return Icon(chevronIcon, color: titleColor.withValues(alpha: 0.7), size: 20.0);
  }

  Widget ExpandedSection(Color titleColor) {
    return RenderIf.condition(
      isExpanded,

      Div.column([DividerLine(titleColor), ContentContainer()]),
    );
  }

  Widget DividerLine(Color titleColor) {
    return Container(
      height: 1.0,
      color: titleColor.withValues(alpha: 0.1),
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
    );
  }

  Widget ContentContainer() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        20.0,
        16.0,
        20.0,
        20.0,
      ),
      child: widget.expandedContent,
    );
  }
}
