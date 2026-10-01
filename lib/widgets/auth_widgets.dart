import 'package:flutter/material.dart';

import '../constants.dart';

// ==================== KARTU PEMBUNGKUS LOGIN/REGISTER ====================
// NOTE: API tetap sama (hanya menerima `children`) supaya login_screen.dart
// dan register_screen.dart tidak perlu diubah sama sekali.
class AuthCard extends StatelessWidget {
  final List<Widget> children;
  const AuthCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Foto jajanan sebagai backdrop lembut, senada dengan referensi.
          Image.asset(
            'assets/images/hero_food.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: kLightGreen),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xCCE8F0DE), Color(0xFFF3F8ED)],
                stops: [0.0, 0.42],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 32,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(kRadiusLg),
                    boxShadow: kSoftShadow,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/images/logo.png',
                          height: 72,
                          errorBuilder: (_, __, ___) => Column(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: kLightGreen,
                                ),
                                child: const Icon(
                                  Icons.storefront_rounded,
                                  color: kDarkGreen,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Bazar USU',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: kDarkGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 26),
                      ...children,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== FIELD FORM AUTH ====================
class AuthField extends StatelessWidget {
  final String label;
  final bool obscure;
  final TextInputType? keyboardType;
  final TextEditingController? controller;

  const AuthField({
    super.key,
    required this.label,
    this.obscure = false,
    this.keyboardType,
    this.controller,
  });

  OutlineInputBorder _border(Color color, double width) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(kRadiusMd),
    borderSide: BorderSide(color: color, width: width),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: kDarkGreen,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14, color: kDarkGreen),
          decoration: InputDecoration(
            filled: true,
            fillColor: kLightGreen.withValues(alpha: 0.5),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: _border(Colors.transparent, 0),
            enabledBorder: _border(Colors.transparent, 0),
            focusedBorder: _border(kDarkGreen, 1.6),
          ),
        ),
      ],
    );
  }
}

// ==================== TOMBOL UTAMA AUTH ====================
class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const AuthButton({super.key, required this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: kDarkGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kRadiusPill),
          ),
        ),
        onPressed: onPressed ?? () {},
        child: Text(
          text,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}