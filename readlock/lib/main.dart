import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readlock/main_navigation.dart';

void main() {
  runApp(const RelevantApp());
}

class RelevantApp extends StatelessWidget {
  const RelevantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: appTheme(),
      home: const MainNavigation(),
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeData appTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.tealAccent),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      useMaterial3: true,
      textTheme: GoogleFonts.dmSansTextTheme(
        ThemeData.light().textTheme,
      ),
    );
  }
}
