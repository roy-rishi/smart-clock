import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import "theme.dart";
import "login_page.dart";

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const LoginPage(),
      title: "Smart Clock",
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightScheme,
        brightness: Brightness.light,
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkScheme,
        brightness: Brightness.dark,
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme).apply(
            displayColor: darkScheme.onBackground,
            bodyColor: darkScheme.onBackground,
            decorationColor: darkScheme.onBackground,
          ),
      ),
    );
  }
}
