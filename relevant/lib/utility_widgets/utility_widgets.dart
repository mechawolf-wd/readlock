// Utility widgets for simplified Flutter UI development
// Provides Div widget for layout and Spacing widget for consistent spacing

import 'package:flutter/material.dart';

// String constants for directions
const String DIRECTION_VERTICAL = 'vertical';
const String DIRECTION_HORIZONTAL = 'horizontal';

// String constants for alignments
const String ALIGNMENT_START = 'start';
const String ALIGNMENT_END = 'end';
const String ALIGNMENT_CENTER = 'center';
const String ALIGNMENT_SPACE_BETWEEN = 'spaceBetween';
const String ALIGNMENT_SPACE_AROUND = 'spaceAround';
const String ALIGNMENT_SPACE_EVENLY = 'spaceEvenly';
const String ALIGNMENT_STRETCH = 'stretch';
const String ALIGNMENT_BASELINE = 'baseline';

class Div extends StatelessWidget {
  final List<Widget>? children;
  final dynamic width;
  final dynamic height;
  final dynamic padding;
  final dynamic margin;
  final String? direction;
  final Decoration? decoration;
  final Color? backgroundColor;
  final dynamic mainAxisAlignment;
  final dynamic crossAxisAlignment;
  final bool? debugBorder;
  final dynamic borderRadius;

  const Div.column(
    this.children, {
    super.key,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.decoration,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.debugBorder,
    this.borderRadius,
  }) : direction = DIRECTION_VERTICAL;

  const Div.row(
    this.children, {
    super.key,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.decoration,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.debugBorder,
    this.borderRadius,
  }) : direction = DIRECTION_HORIZONTAL;

  const Div.emptyColumn({
    super.key,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.decoration,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.debugBorder,
    this.borderRadius,
  }) : children = null,
       direction = DIRECTION_VERTICAL;

  const Div.emptyRow({
    super.key,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.decoration,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.debugBorder,
    this.borderRadius,
  }) : children = null,
       direction = DIRECTION_HORIZONTAL;

  MainAxisAlignment getMainAxisAlignment(dynamic alignment) {
    if (alignment == null) {
      return MainAxisAlignment.start;
    }

    if (alignment is MainAxisAlignment) {
      return alignment;
    }

    if (alignment is String) {
      switch (alignment) {
        case ALIGNMENT_START:
          return MainAxisAlignment.start;
        case ALIGNMENT_END:
          return MainAxisAlignment.end;
        case ALIGNMENT_CENTER:
          return MainAxisAlignment.center;
        case ALIGNMENT_SPACE_BETWEEN:
          return MainAxisAlignment.spaceBetween;
        case ALIGNMENT_SPACE_AROUND:
          return MainAxisAlignment.spaceAround;
        case ALIGNMENT_SPACE_EVENLY:
          return MainAxisAlignment.spaceEvenly;
        default:
          return MainAxisAlignment.start;
      }
    }

    return MainAxisAlignment.start;
  }

  CrossAxisAlignment getCrossAxisAlignment(dynamic alignment) {
    if (alignment == null) {
      return CrossAxisAlignment.center;
    }

    if (alignment is CrossAxisAlignment) {
      return alignment;
    }

    if (alignment is String) {
      switch (alignment) {
        case ALIGNMENT_START:
          return CrossAxisAlignment.start;
        case ALIGNMENT_END:
          return CrossAxisAlignment.end;
        case ALIGNMENT_CENTER:
          return CrossAxisAlignment.center;
        case ALIGNMENT_STRETCH:
          return CrossAxisAlignment.stretch;
        case ALIGNMENT_BASELINE:
          return CrossAxisAlignment.baseline;
        default:
          return CrossAxisAlignment.center;
      }
    }

    return CrossAxisAlignment.center;
  }

  double? getWidth() {
    if (width == null) {
      return null;
    }

    final bool isNumericValue = width is double || width is int;

    if (isNumericValue) {
      return (width is int)
          ? (width as int).toDouble()
          : (width as double);
    }

    if (width is String && width == 'full') {
      return double.infinity;
    }

    return null;
  }

  double? getHeight() {
    if (height == null) {
      return null;
    }

    final bool isNumericValue = height is double || height is int;

    if (isNumericValue) {
      return (height is int)
          ? (height as int).toDouble()
          : (height as double);
    }

    if (height is String && height == 'full') {
      return double.infinity;
    }

    return null;
  }

  Widget ChildLayout() {
    final bool isHorizontal = direction == DIRECTION_HORIZONTAL;

    if (isHorizontal) {
      return Row(
        mainAxisAlignment: getMainAxisAlignment(mainAxisAlignment),
        crossAxisAlignment: getCrossAxisAlignment(crossAxisAlignment),
        children: children ?? [],
      );
    } else {
      return Column(
        mainAxisAlignment: getMainAxisAlignment(mainAxisAlignment),
        crossAxisAlignment: getCrossAxisAlignment(crossAxisAlignment),
        children: children ?? [],
      );
    }
  }

  EdgeInsets buildEdgeInsets(dynamic paddingValue) {
    if (paddingValue == null) {
      return const EdgeInsets.all(0);
    }

    final bool isNumericValue =
        paddingValue is double || paddingValue is int;

    if (isNumericValue) {
      final double value = (paddingValue is int)
          ? paddingValue.toDouble()
          : paddingValue as double;
      return EdgeInsets.all(value);
    }

    if (paddingValue is EdgeInsets) {
      return paddingValue;
    }

    throw Exception('Invalid padding type');
  }

  BorderRadius? getBorderRadius() {
    return createBorderRadiusFromValue(borderRadius);
  }

  BorderRadius? createBorderRadiusFromValue(dynamic value) {
    final bool hasValue = value != null;

    if (!hasValue) {
      return null;
    }

    final bool isNumericValue = value is double || value is int;

    if (isNumericValue) {
      final double radius = (value is int)
          ? value.toDouble()
          : value as double;

      return BorderRadius.all(Radius.circular(radius));
    }

    final bool isBorderRadiusObject = value is BorderRadius;

    if (isBorderRadiusObject) {
      return value;
    }

    final bool isListValue = value is List<double>;
    final bool hasCorrectListLength = isListValue && value.length == 4;

    if (hasCorrectListLength) {
      return BorderRadius.only(
        topLeft: Radius.circular(value[0]),
        topRight: Radius.circular(value[1]),
        bottomRight: Radius.circular(value[2]),
        bottomLeft: Radius.circular(value[3]),
      );
    }

    return null;
  }

  Decoration? getDecoration() {
    final bool hasCustomDecoration = decoration != null;
    final bool hasDebugBorder = debugBorder == true;
    final bool hasBackgroundColor = backgroundColor != null;
    final bool hasBorderRadius = borderRadius != null;

    if (hasCustomDecoration) {
      // If it's a BoxDecoration, merge backgroundColor, debugBorder, and borderRadius
      if (decoration is BoxDecoration) {
        final BoxDecoration originalDecoration =
            decoration as BoxDecoration;
        final BorderRadiusGeometry? radiusToUse =
            getBorderRadius() ?? originalDecoration.borderRadius;

        return originalDecoration.copyWith(
          color: hasBackgroundColor
              ? backgroundColor
              : originalDecoration.color,
          border: hasDebugBorder
              ? Border.all(color: const Color.fromRGBO(0, 255, 0, 1))
              : originalDecoration.border,
          borderRadius: radiusToUse,
        );
      }
      return decoration;
    }

    final bool needsBoxDecoration =
        hasDebugBorder || hasBackgroundColor || hasBorderRadius;

    if (needsBoxDecoration) {
      return BoxDecoration(
        border: hasDebugBorder
            ? Border.all(color: const Color.fromRGBO(0, 255, 0, 1))
            : null,
        color: hasBackgroundColor ? backgroundColor : null,
        borderRadius: getBorderRadius(),
      );
    }

    return null;
  }

  Color? getContainerColor(Decoration? effectiveDecoration) {
    // Only use Container's color property when no decoration is provided
    final bool shouldUseContainerColor =
        effectiveDecoration == null && backgroundColor != null;

    if (shouldUseContainerColor) {
      return backgroundColor;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final Decoration? effectiveDecoration = getDecoration();
    final Color? containerColor = getContainerColor(
      effectiveDecoration,
    );

    return Container(
      padding: buildEdgeInsets(padding),
      margin: buildEdgeInsets(margin),
      width: getWidth(),
      height: getHeight(),
      decoration: effectiveDecoration,
      color: containerColor,
      child: ChildLayout(),
    );
  }
}

class Spacing extends StatelessWidget {
  final double value;
  final String type;

  const Spacing.height(this.value, {super.key}) : type = 'height';

  const Spacing.width(this.value, {super.key}) : type = 'width';

  @override
  Widget build(BuildContext context) {
    if (type == 'height') {
      return SizedBox(height: value);
    } else {
      return SizedBox(width: value);
    }
  }
}
