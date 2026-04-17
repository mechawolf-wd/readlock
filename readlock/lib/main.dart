import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readlock/MainNavigation.dart';
import 'package:readlock/constants/RLDesignSystem.dart';
import 'package:readlock/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
    );
  }

  ThemeData getTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.tealAccent,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: RLDS.backgroundDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: RLDS.backgroundDark,
        foregroundColor: RLDS.textPrimary,
        elevation: 0,
        iconTheme: IconThemeData(color: RLDS.textPrimary),
      ),
      useMaterial3: true,
      textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
    );
  }
}
