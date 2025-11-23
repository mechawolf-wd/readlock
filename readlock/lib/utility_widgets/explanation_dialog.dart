// Bottom modal sheet widget for displaying course explanations and hints
// Features progressive text animation and consistent styling

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/utility_widgets/utility_widgets.dart';
import 'package:readlock/constants/typography.dart';
import 'package:readlock/constants/app_theme.dart';
import 'package:readlock/utility_widgets/text_animation/progressive_text.dart';

const String CLOSE_BUTTON_LABEL = 'Got it';
const double MODAL_PADDING = 24.0;
const double BUTTON_VERTICAL_PADDING = 16.0;
const double BORDER_RADIUS = 12.0;
const double MODAL_HEIGHT_FRACTION = 0.75;

class ExplanationDialog extends StatelessWidget {
  final String title;
  final String content;

  const ExplanationDialog({
    super.key,
    required this.title,
    required this.content,
  });

  // Icon and styling definitions
  static const Icon CloseIcon = Icon(
    Icons.close,
    color: AppTheme.textPrimary,
  );
  static const Color backgroundColor = AppTheme.backgroundLight;
  static const Color buttonColor = AppTheme.primaryGreen;

  @override
  Widget build(BuildContext context) {
    return Container(
      height:
          MediaQuery.of(context).size.height * MODAL_HEIGHT_FRACTION,
      decoration: Style.modalDecoration,
      child: SafeArea(child: ModalContent()),
    );
  }

  Widget ModalContent() {
    return Div.column([ModalHeader(), ModalBody(), ModalFooter()]);
  }

  Widget ModalHeader() {
    return Builder(
      builder: (context) => Div.column([
        Div.row([
          const Spacer(),

          Container(
            width: 40,
            height: 4,
            decoration: Style.dragHandleDecoration,
          ),

          const Spacer(),
        ]),

        const Spacing.height(16),

        Div.row([
          Typography.headingMedium(title),

          const Spacer(),

          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: CloseIcon,
          ),
        ], crossAxisAlignment: CrossAxisAlignment.start),
      ], padding: const EdgeInsets.all(MODAL_PADDING)),
    );
  }

  Widget ModalBody() {
    return Expanded(
      child: Div.column(
        [
          ProgressiveText(
            textSegments: [content],
            textStyle: Style.dialogTextStyle,
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
        ],
        padding: const EdgeInsets.symmetric(horizontal: MODAL_PADDING),
        crossAxisAlignment: CrossAxisAlignment.start,
        width: double.infinity,
      ),
    );
  }

  Widget ModalFooter() {
    return Builder(
      builder: (context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(MODAL_PADDING),
        child: ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: Style.closeButtonStyle,
          child: Typography.text(
            CLOSE_BUTTON_LABEL,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class Style {
  static final TextStyle dialogTextStyle = Typography.bodyLargeStyle
      .copyWith(fontSize: 16, height: 1.6);

  static final ButtonStyle closeButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppTheme.primaryGreen,
    padding: const EdgeInsets.symmetric(
      vertical: BUTTON_VERTICAL_PADDING,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(BORDER_RADIUS),
    ),
  );

  static final BoxDecoration modalDecoration = BoxDecoration(
    color: AppTheme.backgroundLight,
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(20),
      topRight: Radius.circular(20),
    ),
  );

  static final BoxDecoration dragHandleDecoration = BoxDecoration(
    color: AppTheme.textPrimary.withValues(alpha: 0.3),
    borderRadius: const BorderRadius.all(Radius.circular(2)),
  );
}
