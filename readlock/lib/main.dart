import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readlock/MainNavigation.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/design_system/RLNightShift.dart';
import 'package:readlock/firebase_options.dart';
import 'package:readlock/services/ConnectivityService.dart';
import 'package:readlock/services/purchases/StoreKitService.dart';
import 'package:readlock/services/NightShiftBrightnessService.dart';
import 'package:readlock/services/NightShiftScheduleService.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  silenceEngineWindowAssertionSpam();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Drives the panel brightness from the Night Shift slider so the dim
  // step actually lowers the screen below the OS minimum.
  NightShiftBrightnessService.initialize();

  // Auto-applies the warmth level from the user's daily Night Shift
  // schedule (Apple-style window) so the slider flips on at sundown
  // and back off in the morning without per-screen wiring.
  NightShiftScheduleService.initialize();

  // Subscribes to platform connectivity changes so any screen that depends
  // on network reachability (CoursesScreen) can flip to an offline state
  // the moment the device drops its transport.
  ConnectivityService.initialize();

  // Connects to the App Store, fetches subscription products, and starts
  // the purchase stream listener. Gracefully no-ops when products have
  // not been created in App Store Connect yet.
  StoreKitService.initialize();

  runApp(const ReadlockApp());
}

// Drops the noisy "Assertion failed: .../lib/_engine/engine/window.dart:99:12"
// errors that the Flutter engine fires in a tight loop on some platforms.
// Every other error still goes through the default handler.
void silenceEngineWindowAssertionSpam() {
  final defaultOnError = FlutterError.onError;

  FlutterError.onError = (FlutterErrorDetails details) {
    final String message = details.exceptionAsString();
    final bool isEngineWindowSpam = message.contains('engine/window.dart');

    if (isEngineWindowSpam) {
      return;
    }

    if (defaultOnError != null) {
      defaultOnError(details);
      return;
    }

    FlutterError.presentError(details);
  };
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
      scrollBehavior: const NoScrollbarBehavior(),
    );
  }

  // Wraps every routed page (and any modal/bottom sheet pushed on top of
  // the Navigator) so the colour-temperature shift applies app-wide.
  Widget NightShiftWrapper(BuildContext context, Widget? child) {
    final Widget content = child ?? const SizedBox.shrink();

    return RLNightShift(child: content);
  }

  ThemeData getTheme() {
    final PageTransitionsTheme topSlideTransitions = PageTransitionsTheme(
      builders: {
        for (final TargetPlatform platform in TargetPlatform.values)
          platform: const TopSlidePageTransitionsBuilder(),
      },
    );

    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: RLDS.primary, brightness: Brightness.dark),
      scaffoldBackgroundColor: RLDS.surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: RLDS.surface,
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

// App-wide scroll behaviour that strips the desktop/web scrollbar so every
// scrollable surface (lists, sheets, scroll views) reads as a clean
// touch-style scroll. Wheel + drag inputs are still routed through.
class NoScrollbarBehavior extends MaterialScrollBehavior {
  const NoScrollbarBehavior();

  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }

  @override
  Set<PointerDeviceKind> get dragDevices => const {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}
