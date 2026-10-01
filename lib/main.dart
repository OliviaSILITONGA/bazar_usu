import 'package:flutter/material.dart';

import 'constants.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bazar USU',
      debugShowCheckedModeBanner:
          false, // <- ini yang menghilangkan tulisan DEBUG
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: kDarkGreen),
        scaffoldBackgroundColor: kLightGreen,
        useMaterial3: true,
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          headlineSmall: TextStyle(
            fontWeight: FontWeight.bold,
            color: kDarkGreen,
          ),
          titleLarge: TextStyle(fontWeight: FontWeight.bold, color: kDarkGreen),
          titleMedium: TextStyle(
            fontWeight: FontWeight.w600,
            color: kDarkGreen,
          ),
          bodyMedium: TextStyle(color: kDarkGreen, height: 1.4),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: kBg,
          foregroundColor: kDarkGreen,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: kDarkGreen,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kDarkGreen,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kRadiusPill),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: kDarkGreen,
            side: const BorderSide(color: kDarkGreen),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(kRadiusPill),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(kRadiusMd),
            borderSide: BorderSide(color: kDarkGreen.withValues(alpha: 0.2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(kRadiusMd),
            borderSide: BorderSide(color: kDarkGreen.withValues(alpha: 0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(kRadiusMd),
            borderSide: const BorderSide(color: kDarkGreen, width: 1.6),
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kRadiusMd),
            side: const BorderSide(color: kBorder),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}