import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../services/database_service.dart';
import 'login_screen.dart';
import 'main_navigation_page.dart';
import 'seller_profile_view_page.dart';
import 'seller_edit_profile_page.dart';

class SellerProfilePage extends StatefulWidget {
  const SellerProfilePage({super.key});

  @override
  State<SellerProfilePage> createState() => _SellerProfilePageState();
}

class _SellerProfilePageState extends State<SellerProfilePage> {
  late final Stream<Map<String, dynamic>?>? _tenantStream;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    _tenantStream = uid == null ? null : DatabaseService().tenantStream(uid);
  }

  Uint8List? _decodePhoto(String? base64Str) {
    if (base64Str == null || base64Str.isEmpty) return null;
    try {
      return base64Decode(base64Str);
    } catch (e) {
      debugPrint('Foto toko tidak valid: $e');
      return null;
    }
  }

  void _switchToBuyer(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Beralih ke Akun Pembeli'),
        content: const Text(
          'Kamu akan kembali ke tampilan pembeli. Toko dan produk kamu '
          'tetap tersimpan dan bisa diakses lagi kapan saja.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MainNavigationPage()),
              );
            },
            child: const Text('Beralih'),
          ),
        ],
      ),
    );
  }

  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  // Kartu profil toko di bagian atas
  Widget _buildShopCard(BuildContext context, Map<String, dynamic>? data) {
    final namaToko = (data?['namaToko'] as String?)?.trim() ?? '';
    final kategori = (data?['kategori'] as String?)?.trim() ?? '';
    final photoBytes = _decodePhoto(data?['fotoBase64'] as String?);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kDarkGreen.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SellerProfileViewPage(),
                  ),
                );
              },
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: kLightGreen,
                      border: Border.all(
                        color: kDarkGreen.withValues(alpha: 0.3),
                      ),
                      image: photoBytes != null
                          ? DecorationImage(
                              image: MemoryImage(photoBytes),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: photoBytes == null
                        ? Icon(
                            Icons.storefront,
                            color: kDarkGreen.withValues(alpha: 0.7),
                            size: 26,
                          )
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          namaToko.isNotEmpty ? namaToko : 'Toko Kamu',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: kDarkGreen,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          kategori.isNotEmpty ? kategori : '-',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: kDarkGreen.withValues(alpha: 0.65),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SellerEditProfilePage(),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.edit_outlined,
                color: kDarkGreen.withValues(alpha: 0.6),
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_tenantStream == null)
                _buildShopCard(context, null)
              else
                StreamBuilder<Map<String, dynamic>?>(
                  stream: _tenantStream,
                  builder: (context, snapshot) {
                    // Saat loading/error, tetap tampilkan kartu dengan nilai cadangan
                    return _buildShopCard(context, snapshot.data);
                  },
                ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kDarkGreen.withValues(alpha: 0.12)),
                ),
                child: Column(
                  children: [
                    _ProfileMenuTile(
                      icon: Icons.swap_horiz,
                      label: 'Beralih ke Akun Pembeli',
                      onTap: () => _switchToBuyer(context),
                    ),
                    Divider(
                      height: 1,
                      indent: 50,
                      color: kDarkGreen.withValues(alpha: 0.08),
                    ),
                    _ProfileMenuTile(
                      icon: Icons.logout,
                      label: 'Keluar',
                      isDestructive: true,
                      onTap: () => _logout(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDestructive;
  final VoidCallback onTap;

  const _ProfileMenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.redAccent : kDarkGreen;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color.withValues(alpha: 0.85)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 13.5, color: color),
              ),
            ),
            if (!isDestructive)
              Icon(
                Icons.chevron_right,
                size: 18,
                color: kDarkGreen.withValues(alpha: 0.4),
              ),
          ],
        ),
      ),
    );
  }
}