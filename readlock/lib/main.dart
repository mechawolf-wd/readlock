import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readlock/MainNavigation.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/design_system/RLNightShiftOverlay.dart';
import 'package:readlock/firebase_options.dart';
import 'package:readlock/services/NightShiftBrightnessService.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Drives the panel brightness from the Night Shift slider so the dim
  // step actually lowers the screen below the OS minimum.
  NightShiftBrightnessService.initialize();

  runApp(const ReadlockApp());
}

class ReadlockApp extends StatelessWidget {
  const ReadlockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: getTheme(),
      home: const MainNavigation(),
      debugShowCheckedModeBanner: false,
      builder: NightShiftWrapper,
    );
  }

  // Wraps every routed page (and any modal/bottom sheet pushed on top of
  // the Navigator) so the eye-strain tint paints above all content.
  Widget NightShiftWrapper(BuildContext context, Widget? child) {
    final Widget content = child ?? const SizedBox.shrink();

    return RLNightShiftOverlay(child: content);
  }

  ThemeData getTheme() {
    final PageTransitionsTheme topSlideTransitions = PageTransitionsTheme(
      builders: {
        for (final TargetPlatform platform in TargetPlatform.values)
          platform: const TopSlidePageTransitionsBuilder(),
      },
    );

    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: RLDS.primary,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: RLDS.backgroundDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: RLDS.backgroundDark,
        foregroundColor: RLDS.textPrimary,
        elevation: 0,
        iconTheme: IconThemeData(color: RLDS.textPrimary),
      ),
      pageTransitionsTheme: topSlideTransitions,
      useMaterial3: true,
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
    );
  }
}
