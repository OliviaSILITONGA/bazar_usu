import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../constants.dart';

/// Mengubah data foto menjadi ImageProvider.
/// Format yang didukung:
///  - Uint8List : foto yang baru dipilih (belum disimpan)
///  - String    : URL (diawali "http") atau teks base64 dari Firestore
///  - null / kosong / tidak valid -> null (avatar menampilkan ikon)
ImageProvider? profileImageProvider(Object? photo) {
  if (photo == null) return null;

  if (photo is Uint8List) return MemoryImage(photo);

  if (photo is String) {
    final value = photo.trim();
    if (value.isEmpty) return null;
    if (value.startsWith('http')) return NetworkImage(value);
    try {
      return MemoryImage(base64Decode(value));
    } catch (_) {
      return null;
    }
  }

  return null;
}

/// Avatar profil yang dipakai di semua halaman (Profil, Lihat Profil, Edit Profil).
/// Karena fotonya dari Firestore, tampil sama di HP, emulator, maupun Chrome.
class ProfileAvatar extends StatefulWidget {
  final Object? photo;
  final double radius;

  const ProfileAvatar({super.key, required this.photo, this.radius = 34});

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  // Disimpan supaya base64 tidak di-decode ulang setiap build (anti kedip).
  ImageProvider? _provider;

  @override
  void initState() {
    super.initState();
    _provider = profileImageProvider(widget.photo);
  }

  @override
  void didUpdateWidget(ProfileAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.photo != widget.photo) {
      _provider = profileImageProvider(widget.photo);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: kLightGreen,
      backgroundImage: _provider,
      onBackgroundImageError: _provider == null ? null : (_, _) {},
      child: _provider == null
          ? Icon(
              Icons.person,
              color: kDarkGreen.withValues(alpha: 0.6),
              size: widget.radius,
            )
          : null,
    );
  }
}
