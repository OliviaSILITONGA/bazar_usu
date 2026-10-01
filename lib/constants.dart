import 'package:flutter/material.dart';

// ==================== DESIGN TOKENS — Bazar USU ====================
// Warna
const kGreen = Color(0xFF3A5A40);
const kDarkGreen = Color(0xFF3E5C3A);
const kLightGreen = Color(0xFFE8F0DE);
const kCardGreen = Color(0xFFD8E4C8);
const kBg = Color(0xFFF3F8ED);
const kMuted = Color(0xFF6B7D64); // teks sekunder di atas latar hijau/krem
const kBorder = Color(0x1F3E5C3A); // border tipis (kDarkGreen alpha 12%)

// Radius
const double kRadiusSm = 10;
const double kRadiusMd = 16;
const double kRadiusLg = 24;
const double kRadiusPill = 100;

// Spacing
const double kSpaceXs = 4;
const double kSpaceSm = 8;
const double kSpaceMd = 16;
const double kSpaceLg = 24;
const double kSpaceXl = 32;

// Shadow lembut dipakai di seluruh card
List<BoxShadow> get kSoftShadow => [
  BoxShadow(
    color: kDarkGreen.withValues(alpha: 0.06),
    blurRadius: 16,
    offset: const Offset(0, 6),
  ),
];