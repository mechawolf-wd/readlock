import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:relevant/main_navigation.dart';

void main() {
  runApp(const RelevantApp());
}

class RelevantApp extends StatelessWidget {
  const RelevantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Design Course',
      theme: appTheme(),
      home: const MainNavigation(),
      debugShowCheckedModeBanner: false,
    );
  }

  ThemeData appTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: Colors.grey[900],
      useMaterial3: true,
      textTheme: GoogleFonts.crimsonTextTextTheme(
        ThemeData.dark().textTheme,
      ),
    );
  }
}
