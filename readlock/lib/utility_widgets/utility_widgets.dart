// Utility widgets for simplified Flutter UI development
// Provides Div widget for layout and Spacing widget for consistent spacing

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/constants/typography.dart';
import 'package:readlock/constants/app_theme.dart';

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
  /// List of child widgets to display
  ///
  /// Examples:
  /// ```dart
  /// children: [Text('Hello'), Text('World')]
  /// children: [Icon(Icons.home), SizedBox(width: 10), Text('Home')]
  /// ```
  final List<Widget>? children;

  /// Width of the container
  ///
  /// Examples:
  /// ```dart
  /// width: 200.0        // Fixed width
  /// width: 150          // Fixed width (int)
  /// width: 'full'       // Full available width
  /// ```
  final dynamic width;

  /// Height of the container
  ///
  /// Examples:
  /// ```dart
  /// height: 100.0       // Fixed height
  /// height: 80          // Fixed height (int)
  /// height: 'full'      // Full available height
  /// ```
  final dynamic height;

  /// Padding inside the container
  ///
  /// Examples:
  /// ```dart
  /// padding: 16.0                              // All sides
  /// padding: 20                                // All sides (int)
  /// padding: [12.0, 16.0]                     // [vertical, horizontal]
  /// padding: [8.0, 16.0, 12.0, 20.0]         // [top, right, bottom, left]
  /// padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0)
  /// padding: EdgeInsets.only(left: 16.0, right: 16.0)
  /// ```
  final dynamic padding;

  /// Margin outside the container
  ///
  /// Examples:
  /// ```dart
  /// margin: 8.0                               // All sides
  /// margin: 12                                // All sides (int)
  /// margin: [10.0, 15.0]                     // [vertical, horizontal]
  /// margin: [5.0, 10.0, 15.0, 20.0]         // [top, right, bottom, left]
  /// margin: EdgeInsets.all(16.0)
  /// margin: EdgeInsets.fromLTRB(10, 5, 10, 15)
  /// ```
  final dynamic margin;

  /// Layout direction - automatically set by constructors
  final String? direction;

  /// Custom decoration for the container
  ///
  /// Examples:
  /// ```dart
  /// decoration: BoxDecoration(
  ///   gradient: LinearGradient(colors: [Colors.blue, Colors.purple]),
  ///   boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 4)]
  /// )
  /// decoration: BoxDecoration(
  ///   border: Border.all(color: Colors.red, width: 2)
  /// )
  /// ```
  final Decoration? decoration;

  /// Background color of the container
  ///
  /// Examples:
  /// ```dart
  /// color: Colors.blue                        // Color object
  /// color: Color(0xFF1976D2)                 // Custom color
  /// color: 'red'                             // String color name
  /// color: 'blue'                            // String color name
  /// color: 'green'                           // String color name
  /// color: 'yellow'                          // String color name
  /// color: 'orange'                          // String color name
  /// color: 'purple'                          // String color name
  /// color: 'pink'                            // String color name
  /// color: 'cyan'                            // String color name
  /// color: 'teal'                            // String color name
  /// color: 'lime'                            // String color name
  /// color: 'indigo'                          // String color name
  /// color: 'amber'                           // String color name
  /// color: 'brown'                           // String color name
  /// color: 'grey'                            // String color name
  /// color: 'gray'                            // String color name
  /// color: 'black'                           // String color name
  /// color: 'white'                           // String color name
  /// color: 'transparent'                     // String color name
  /// ```
  final dynamic color;

  /// Main axis alignment for child widgets
  ///
  /// Examples:
  /// ```dart
  /// mainAxisAlignment: MainAxisAlignment.center        // Enum
  /// mainAxisAlignment: MainAxisAlignment.spaceBetween  // Enum
  /// mainAxisAlignment: 'start'                         // String
  /// mainAxisAlignment: 'center'                        // String
  /// mainAxisAlignment: 'spaceBetween'                  // String
  /// mainAxisAlignment: 'spaceEvenly'                   // String
  /// ```
  final dynamic mainAxisAlignment;

  /// Cross axis alignment for child widgets
  ///
  /// Examples:
  /// ```dart
  /// crossAxisAlignment: CrossAxisAlignment.center      // Enum
  /// crossAxisAlignment: CrossAxisAlignment.stretch     // Enum
  /// crossAxisAlignment: 'start'                        // String
  /// crossAxisAlignment: 'center'                       // String
  /// crossAxisAlignment: 'stretch'                      // String
  /// crossAxisAlignment: 'baseline'                     // String
  /// ```
  final dynamic crossAxisAlignment;

  /// Whether to show a green debug border
  ///
  /// Examples:
  /// ```dart
  /// debugBorder: true                         // Show debug border
  /// debugBorder: false                        // Hide debug border
  /// ```
  final bool? debugBorder;

  /// Border radius for the container
  ///
  /// Examples:
  /// ```dart
  /// radius: 8.0                              // All corners
  /// radius: 12                               // All corners (int)
  /// radius: [8.0, 12.0, 16.0, 4.0]         // [topLeft, topRight, bottomRight, bottomLeft]
  /// radius: BorderRadius.circular(10.0)      // BorderRadius object
  /// radius: BorderRadius.only(
  ///   topLeft: Radius.circular(8.0),
  ///   topRight: Radius.circular(8.0)
  /// )
  /// ```
  final dynamic radius;

  const Div.column({
    super.key,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.color,
    this.decoration,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.debugBorder,
    this.radius,
  }, [this.children]) : direction = DIRECTION_VERTICAL;

  const Div.row({
    super.key,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.color,
    this.decoration,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.debugBorder,
    this.radius,
  }, [this.children]) : direction = DIRECTION_HORIZONTAL;

  const Div.emptyColumn({
    super.key,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.color,
    this.decoration,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.debugBorder,
    this.radius,
  }) : children = null,
       direction = DIRECTION_VERTICAL;

  const Div.emptyRow({
    super.key,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.color,
    this.decoration,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.debugBorder,
    this.radius,
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
      return convertToDouble(width);
    }

    final bool isFullWidthString = width is String && width == 'full';

    if (isFullWidthString) {
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
      return convertToDouble(height);
    }

    final bool isFullHeightString =
        height is String && height == 'full';

    if (isFullHeightString) {
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
      final double value = convertToDouble(paddingValue);
      return EdgeInsets.all(value);
    }

    final bool isEdgeInsetsObject = paddingValue is EdgeInsets;

    if (isEdgeInsetsObject) {
      return paddingValue;
    }

    final bool isListValue = paddingValue is List;

    if (isListValue) {
      return createEdgeInsetsFromList(paddingValue);
    }

    throw Exception('Invalid padding type');
  }

  EdgeInsets createEdgeInsetsFromList(List<dynamic> paddingList) {
    final bool hasTwoValues = paddingList.length == 2;

    if (hasTwoValues) {
      final double vertical = convertToDouble(paddingList[0]);
      final double horizontal = convertToDouble(paddingList[1]);

      return EdgeInsets.symmetric(
        vertical: vertical,
        horizontal: horizontal,
      );
    }

    final bool hasFourValues = paddingList.length == 4;

    if (hasFourValues) {
      final double top = convertToDouble(paddingList[0]);
      final double right = convertToDouble(paddingList[1]);
      final double bottom = convertToDouble(paddingList[2]);
      final double left = convertToDouble(paddingList[3]);

      return EdgeInsets.fromLTRB(left, top, right, bottom);
    }

    throw Exception(
      'Invalid list length for padding. Expected 2 or 4 values.',
    );
  }

  BorderRadius? getBorderRadius() {
    return createBorderRadiusFromValue(radius);
  }

  BorderRadius? createBorderRadiusFromValue(dynamic value) {
    final bool hasValue = value != null;

    if (!hasValue) {
      return null;
    }

    final bool isNumericValue = value is double || value is int;

    if (isNumericValue) {
      final double radiusValue = convertToDouble(value);
      return BorderRadius.all(Radius.circular(radiusValue));
    }

    final bool isBorderRadiusObject = value is BorderRadius;

    if (isBorderRadiusObject) {
      return value;
    }

    final bool isListValue = value is List;

    if (isListValue) {
      final List radiusList = value;
      final bool hasFourValues = radiusList.length == 4;

      if (hasFourValues) {
        final double topLeft = convertToDouble(radiusList[0]);
        final double topRight = convertToDouble(radiusList[1]);
        final double bottomRight = convertToDouble(radiusList[2]);
        final double bottomLeft = convertToDouble(radiusList[3]);

        return BorderRadius.only(
          topLeft: Radius.circular(topLeft),
          topRight: Radius.circular(topRight),
          bottomRight: Radius.circular(bottomRight),
          bottomLeft: Radius.circular(bottomLeft),
        );
      }
    }

    return null;
  }

  Decoration? getDecoration() {
    final bool hasCustomDecoration = decoration != null;
    final bool hasDebugBorder = debugBorder == true;
    final bool hasBackgroundColor = color != null;
    final bool hasBorderRadius = radius != null;

    if (hasCustomDecoration) {
      // If it's a BoxDecoration, merge backgroundColor, debugBorder, and borderRadius
      if (decoration is BoxDecoration) {
        final BoxDecoration originalDecoration =
            decoration as BoxDecoration;
        final BorderRadiusGeometry? radiusToUse =
            getBorderRadius() ?? originalDecoration.borderRadius;

        return originalDecoration.copyWith(
          color: hasBackgroundColor
              ? getColorValue(color)
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
      final Border? debugBorderValue = hasDebugBorder
          ? Border.all(color: const Color.fromRGBO(0, 255, 0, 1))
          : null;

      final Color? backgroundColorValue = hasBackgroundColor
          ? getColorValue(color)
          : null;

      return BoxDecoration(
        border: debugBorderValue,
        color: backgroundColorValue,
        borderRadius: getBorderRadius(),
      );
    }

    return null;
  }

  Color? getContainerColor(Decoration? effectiveDecoration) {
    // Only use Container's color property when no decoration is provided
    final bool shouldUseContainerColor =
        effectiveDecoration == null && color != null;

    if (shouldUseContainerColor) {
      return getColorValue(color);
    }

    return null;
  }

  Color? getColorValue(dynamic colorValue) {
    if (colorValue == null) {
      return null;
    }

    if (colorValue is Color) {
      return colorValue;
    }

    if (colorValue is String) {
      return getColorFromString(colorValue);
    }

    return null;
  }

  double convertToDouble(dynamic value) {
    if (value is int) {
      return value.toDouble();
    }

    if (value is double) {
      return value;
    }

    throw Exception('Value must be int or double');
  }

  Color? getColorFromString(String colorString) {
    switch (colorString.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'pink':
        return Colors.pink;
      case 'cyan':
        return Colors.cyan;
      case 'teal':
        return Colors.teal;
      case 'lime':
        return Colors.lime;
      case 'indigo':
        return Colors.indigo;
      case 'amber':
        return Colors.amber;
      case 'brown':
        return Colors.brown;
      case 'grey':
        return Colors.grey;
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'transparent':
        return Colors.transparent;
      default:
        return null;
    }
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
  /// The spacing value in logical pixels
  ///
  /// Examples:
  /// ```dart
  /// Spacing.height(16.0)     // 16px vertical spacing
  /// Spacing.height(24.0)     // 24px vertical spacing
  /// Spacing.width(8.0)       // 8px horizontal spacing
  /// Spacing.width(32.0)      // 32px horizontal spacing
  /// ```
  final double value;

  /// The type of spacing - automatically set by constructors
  ///
  /// Values:
  /// - 'height': Creates vertical spacing (SizedBox with height)
  /// - 'width': Creates horizontal spacing (SizedBox with width)
  ///
  /// Examples:
  /// ```dart
  /// Spacing.height(16.0)     // Creates SizedBox(height: 16.0)
  /// Spacing.width(20.0)      // Creates SizedBox(width: 20.0)
  /// ```
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

class RenderIf {
  /// Conditionally renders a widget based on a boolean condition
  ///
  /// If condition is true, returns `ifTrue` widget
  /// If condition is false, returns `ifFalse` widget (or SizedBox.shrink() if not provided)
  ///
  /// Examples:
  /// ```dart
  /// RenderIf.condition(isLoggedIn, Text('Welcome back!'))
  /// RenderIf.condition(hasError, ErrorWidget(), Text('All good!'))
  /// RenderIf.condition(items.isNotEmpty, ItemsList())
  /// ```
  static Widget condition(
    bool condition,
    Widget ifTrue, [
    Widget? ifFalse,
  ]) {
    if (condition) {
      return ifTrue;
    } else {
      return ifFalse ?? const SizedBox.shrink();
    }
  }
}

class StatsBar extends StatelessWidget {
  const StatsBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Div.row({}, [StreakCounter(), const Spacer(), AhaCounter()]);
  }

  Widget StreakCounter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Div.row({}, [
        const Icon(
          Icons.local_fire_department,
          color: Colors.orange,
          size: 20,
        ),
        const Spacing.width(8),
        Typography.text('7'),
      ]),
    );
  }

  Widget AhaCounter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Div.row({}, [
        const Icon(
          Icons.lightbulb,
          color: AppTheme.primaryGreen,
          size: 20,
        ),
        const Spacing.width(8),
        Typography.text('23'),
      ]),
    );
  }
}
