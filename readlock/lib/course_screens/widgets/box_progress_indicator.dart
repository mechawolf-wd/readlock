// Box progress indicator widget displaying progress as tiny colored boxes
// Each box represents a content section and changes color when swiped through
import 'package:flutter/material.dart';
import 'package:relevant/constants/app_theme.dart';
import 'package:relevant/utility_widgets/utility_widgets.dart';

const double BOX_SIZE = 8.0;
const double BOX_SPACING = 4.0;
const double BOX_BORDER_RADIUS = 2.0;

class BoxProgressIndicator extends StatelessWidget {
  final int totalBoxes;
  final int currentIndex;
  final Color activeColor;

  const BoxProgressIndicator({
    super.key,
    required this.totalBoxes,
    required this.currentIndex,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Div.row(
      BoxItems(),
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }

  List<Widget> BoxItems() {
    final List<Widget> boxes = [];
    
    for (int boxIndex = 0; boxIndex < totalBoxes; boxIndex++) {
      final bool isActive = boxIndex <= currentIndex;
      
      boxes.add(
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: BOX_SIZE,
          height: BOX_SIZE,
          decoration: BoxDecoration(
            color: isActive ? activeColor : AppTheme.backgroundLight,
            borderRadius: BorderRadius.circular(BOX_BORDER_RADIUS),
          ),
        ),
      );
      
      if (boxIndex < totalBoxes - 1) {
        boxes.add(const Spacing.width(BOX_SPACING));
      }
    }
    
    return boxes;
  }
}