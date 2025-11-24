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
    color: AppTheme.textPrimary,
  );

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Div.column(
          [
            // Header
            Div.column([
              // Drag handle
              Div.emptyRow(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textPrimary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              const Spacing.height(16),

              // Title and close button
              Div.row([
                Typography.headingMedium(title),

                const Spacer(),

                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: CloseIcon,
                ),
              ]),
            ], padding: const EdgeInsets.all(MODAL_PADDING)),

            // Body content`
            Expanded(
              child: Div.column(
                [
                  ProgressiveText(
                    textSegments: [content],
                    crossAxisAlignment: CrossAxisAlignment.start,
                  ),
                ],
                padding: const EdgeInsets.symmetric(
                  horizontal: MODAL_PADDING,
                ),
              ),
            ),

            // Footer - button
            Div.column(
              [
                Typography.bodyMedium(
                  CLOSE_BUTTON_LABEL,
                  color: Colors.white,
                ),
              ],
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primaryGreen,
                borderRadius: BorderRadius.circular(BORDER_RADIUS),
              ),
              mainAxisAlignment: MainAxisAlignment.center,
              margin: const EdgeInsets.all(MODAL_PADDING),
              onTap: () => Navigator.of(context).pop(),
            ),
          ],
          decoration: const BoxDecoration(
            color: AppTheme.backgroundLight,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
        );
      },
    );
  }
}
