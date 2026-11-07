import 'dart:async';

import 'package:flutter/material.dart';

import 'home_page.dart';

// ==================== SPLASH SCREEN ====================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  Timer? _fallbackTimer;

  @override
  void initState() {
    super.initState();

    // Kurangi durasi jadi 2.5 detik agar tidak terlalu lama
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _opacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 40),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
    ]).animate(_controller);

    _controller.forward();

    // Listener saat animasi selesai
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToHome();
      }
    });

    // PENGAMAN (FALLBACK TIMER):
    // Jaga-jaga jika animasi macet/tidak mentrigger navigasi,
    // dalam waktu 3 detik aplikasi dipaksa pindah halaman.
    _fallbackTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        _navigateToHome();
      }
    });
  }

  void _navigateToHome() {
    // Batalkan timer agar tidak terpanggil dua kali
    _fallbackTimer?.cancel();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _fallbackTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F0DE),
      body: Center(
        child: FadeTransition(
          opacity: _opacity,
          child: Image.asset('assets/images/LogoUSU.gif', width: 220),
        ),
      ),
    );
  }
}
