// Bottom sheet that lets the reader pick the app's display language.
// Available locales come from TranslationService (fetched from
// /config/locales). Tapping a locale loads its translations from
// Firestore and persists the choice to the user profile.

import 'package:flutter/material.dart';
import 'package:readlock/bottom_sheets/RLBottomSheet.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/constants/RLTypography.dart';
import 'package:readlock/constants/RLUIStrings.dart';
import 'package:readlock/design_system/RLUtility.dart';
import 'package:readlock/services/TranslationService.dart';
import 'package:readlock/services/auth/UserService.dart';
import 'package:readlock/services/feedback/HapticsService.dart';

import 'package:pixelarticons/pixel.dart';

const EdgeInsets LANGUAGE_PICKER_CONTENT_PADDING = EdgeInsets.fromLTRB(
  RLDS.spacing24,
  RLDS.spacing0,
  RLDS.spacing24,
  RLDS.spacing24,
);

const EdgeInsets LANGUAGE_OPTION_ROW_PADDING = EdgeInsets.symmetric(
  vertical: RLDS.spacing12,
);

const double LANGUAGE_OPTION_UNSELECTED_OPACITY = 0.40;

class LanguagePickerBottomSheet {
  static void show(BuildContext context) {
    RLBottomSheet.show(context, child: const LanguagePickerSheet());
  }
}

class LanguagePickerSheet extends StatefulWidget {
  const LanguagePickerSheet({super.key});

  @override
  State<LanguagePickerSheet> createState() => LanguagePickerSheetState();
}

class LanguagePickerSheetState extends State<LanguagePickerSheet> {
  static const Icon HeaderIcon = Icon(
    Pixel.arttext,
    color: RLDS.info,
    size: RLDS.iconLarge,
  );

  List<LocaleOption> locales = TranslationService.localeOptions;
  String selectedLocale = currentLocaleNotifier.value;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    fetchLocales();
  }

  // Refresh the locale list from Firestore in case new languages were
  // added since the last app launch. The picker shows the cached list
  // immediately, then replaces it if Firestore returns a fresher one.
  Future<void> fetchLocales() async {
    final List<LocaleOption> freshLocales = await TranslationService.fetchAvailableLocales();
    final bool isUnmounted = !mounted;

    if (isUnmounted) {
      return;
    }

    setState(() {
      locales = freshLocales;
    });
  }

  Future<void> handleOptionTap(LocaleOption locale) async {
    final bool isAlreadySelected = locale.code == selectedLocale;

    if (isAlreadySelected) {
      return;
    }

    final bool isBusy = isLoading;

    if (isBusy) {
      return;
    }

    HapticsService.selectionClick();

    setState(() {
      isLoading = true;
    });

    final bool didLoad = await TranslationService.setLocale(locale.code);
    final bool isUnmounted = !mounted;

    if (isUnmounted) {
      return;
    }

    if (didLoad) {
      setState(() {
        selectedLocale = locale.code;
        isLoading = false;
      });

      // Persist to user profile (fire-and-forget)
      UserService.updateLanguage(locale.code);
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: LANGUAGE_PICKER_CONTENT_PADDING,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          HeaderRow(),

          const Spacing.height(RLDS.spacing16),

          // Locale options
          LocaleOptionList(),
        ],
      ),
    );
  }

  Widget HeaderRow() {
    return Div.row([
      HeaderIcon,

      const Spacing.width(RLDS.spacing12),

      RLTypography.headingMedium(RLUIStrings.LANGUAGE_PICKER_TITLE),
    ], mainAxisAlignment: MainAxisAlignment.start);
  }

  Widget LocaleOptionList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: LocaleOptionRows(),
    );
  }

  List<Widget> LocaleOptionRows() {
    final List<Widget> rows = [];

    for (int optionIndex = 0; optionIndex < locales.length; optionIndex++) {
      final LocaleOption locale = locales[optionIndex];
      final bool isSelected = locale.code == selectedLocale;

      void onRowTap() => handleOptionTap(locale);

      rows.add(
        LanguageOptionRow(
          locale: locale,
          isSelected: isSelected,
          onTap: onRowTap,
        ),
      );
    }

    return rows;
  }
}

// Single row in the language picker. Shows the locale's native label
// (e.g. "English", "Polski"). Selected row at full opacity, others faded.
class LanguageOptionRow extends StatelessWidget {
  final LocaleOption locale;
  final bool isSelected;
  final VoidCallback onTap;

  const LanguageOptionRow({
    super.key,
    required this.locale,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double rowOpacity = isSelected ? 1.0 : LANGUAGE_OPTION_UNSELECTED_OPACITY;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Opacity(
        opacity: rowOpacity,
        child: Padding(
          padding: LANGUAGE_OPTION_ROW_PADDING,
          child: RLTypography.bodyLarge(locale.label, color: RLDS.textPrimary),
        ),
      ),
    );
  }
}
