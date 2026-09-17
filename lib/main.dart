import 'package:flutter/material.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3E5C3A)),
        scaffoldBackgroundColor: const Color(0xFFE8F0DE),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
