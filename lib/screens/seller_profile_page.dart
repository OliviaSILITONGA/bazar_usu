import 'package:flutter/material.dart';

import '../constants.dart';
import '../services/seller_state.dart';
import 'login_screen.dart';
import 'main_navigation_page.dart';

class SellerProfilePage extends StatelessWidget {
  const SellerProfilePage({super.key});

  void _switchToBuyer(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
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

  @override
  Widget build(BuildContext context) {
    final state = SellerAccountState.instance;

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ValueListenableBuilder<SellerApplication?>(
                valueListenable: state.myApplication,
                builder: (context, app, _) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: kDarkGreen.withValues(alpha: 0.12),
                      ),
                    ),
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
                          ),
                          child: Icon(
                            Icons.storefront,
                            color: kDarkGreen.withValues(alpha: 0.7),
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                app?.namaToko ?? 'Toko Kamu',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: kDarkGreen,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                app?.kategori ?? '-',
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
                  );
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
              child: Text(label, style: TextStyle(fontSize: 13.5, color: color)),
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