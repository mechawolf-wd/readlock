// Bottom modal sheet widget for displaying course explanations and hints
// Features progressive text animation and consistent styling

import 'package:flutter/material.dart' hide Typography;
import 'package:readlock/utility_widgets/Utility.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLTheme.dart';
import 'package:readlock/utility_widgets/text_animation/ProgressiveText.dart';

const String CLOSE_BUTTON_LABEL = 'Got it';
const double MODAL_PADDING = 24.0;
const double BUTTON_VERTICAL_PADDING = 16.0;
const double BORDER_RADIUS = 12.0;

class ExplanationDialog extends StatelessWidget {
  final String title;
  final String content;

  const ExplanationDialog({
    super.key,
    required this.title,
    required this.content,
  });

  // Icon definitions
  static const Icon CloseIcon = Icon(
    Icons.close,
    color: RLTheme.textPrimary,
  );

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: RLTheme.backgroundLight,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Div.column([
            // Header
            Div.column([
              // Title and close button
              Div.row([
                RLTypography.headingMedium(title),

                const Spacer(),

                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: CloseIcon,
                ),
              ]),
            ], padding: MODAL_PADDING),

            // Body content
            Expanded(
              child: Container(
                width: double.infinity,
                alignment: Alignment.topLeft,
                padding: const EdgeInsets.symmetric(
                  horizontal: MODAL_PADDING,
                ),
                child: ProgressiveText(
                  textSegments: [content],
                  textAlignment: CrossAxisAlignment.start,
                ),
              ),
            ),

            // Footer - button
            Div.column(
              [
                RLTypography.bodyMedium(
                  CLOSE_BUTTON_LABEL,
                  color: Colors.white,
                ),
              ],
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: RLTheme.primaryGreen,
                borderRadius: BorderRadius.circular(BORDER_RADIUS),
              ),
              mainAxisAlignment: MainAxisAlignment.center,
              margin: MODAL_PADDING,
              onTap: () => Navigator.of(context).pop(),
            ),
          ]),
        );
      },
    );
  }
}
