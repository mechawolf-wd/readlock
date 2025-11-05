import 'package:flutter/material.dart';

class Div extends StatelessWidget {
  final List<Widget> children;

  final double? width;
  final double? height;

  // EdgeInsets or double
  final dynamic padding;
  final dynamic margin;

  final String? direction;

  final Decoration? decoration;
  final Color? backgroundColor;

  final MainAxisAlignment? mainAxisAlignment;
  final CrossAxisAlignment? crossAxisAlignment;

  const Div(
    this.children, {
    super.key,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.direction = 'vertical',
    this.decoration,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
  });

  Widget childLayout() {
    if (direction == 'horizontal') {
      return Row(
        mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
        crossAxisAlignment:
            crossAxisAlignment ?? CrossAxisAlignment.center,
        children: children,
      );
    } else {
      return Column(
        mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
        crossAxisAlignment:
            crossAxisAlignment ?? CrossAxisAlignment.center,
        children: children,
      );
    }
  }

  // building padding based on type of marign and padding
  // if it is a number we create EdgeInsets.all
  // if it is EdgeInsets we use it directly

  EdgeInsets buildPadding(dynamic padding) {
    if (padding == null) {
      return const EdgeInsets.all(0);
    } else if (padding is double) {
      return EdgeInsets.all(padding);
    } else if (padding is EdgeInsets) {
      return padding;
    } else {
      throw Exception('Invalid padding type');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: buildPadding(padding),
      margin: buildPadding(margin),
      width: width ?? 0,
      height: height ?? 0,
      decoration: decoration,
      color: backgroundColor,
      child: childLayout(),
    );
  }
}
