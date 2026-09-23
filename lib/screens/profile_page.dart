import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

import '../constants.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              SizedBox(height: 16),
              _ProfileHeader(),
              SizedBox(height: 24),
              _MenuSection(
                title: 'Akun',
                items: [
                  _MenuItemData(
                    icon: Icons.receipt_long_outlined,
                    label: 'Riwayat Pesanan',
                  ),
                  _MenuItemData(
                    icon: Icons.location_on_outlined,
                    label: 'Alamat Tersimpan',
                  ),
                  _MenuItemData(
                    icon: Icons.favorite_border,
                    label: 'Toko Favorit',
                  ),
                  _MenuItemData(
                    icon: Icons.credit_card_outlined,
                    label: 'Metode Pembayaran',
                  ),
                ],
              ),
              SizedBox(height: 20),
              _MenuSection(
                title: 'Lainnya',
                items: [
                  _MenuItemData(
                    icon: Icons.settings_outlined,
                    label: 'Pengaturan',
                  ),
                  _MenuItemData(icon: Icons.help_outline, label: 'Bantuan'),
                  _MenuItemData(icon: Icons.swap_horiz, label: 'Beralih Akun'),
                  _MenuItemData(
                    icon: Icons.logout,
                    label: 'Keluar',
                    isDestructive: true,
                  ),
                ],
              ),
              SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const _BottomNavBar(),
    );
  }
}

// ==================== HEADER PROFIL ====================
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: kLightGreen,
            child: Icon(
              Icons.person,
              color: kDarkGreen.withValues(alpha: 0.6),
              size: 34,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nama Pengguna',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: kDarkGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'email@students.usu.ac.id',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: kDarkGreen.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.edit_outlined,
            color: kDarkGreen.withValues(alpha: 0.6),
            size: 20,
          ),
        ],
      ),
    );
  }
}

// ==================== SECTION MENU ====================
class _MenuItemData {
  final IconData icon;
  final String label;
  final bool isDestructive;
  const _MenuItemData({
    required this.icon,
    required this.label,
    this.isDestructive = false,
  });
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItemData> items;
  const _MenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: kDarkGreen.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kDarkGreen.withValues(alpha: 0.12)),
            ),
            child: Column(
              children: List.generate(items.length, (index) {
                final item = items[index];
                return Column(
                  children: [
                    _MenuTile(data: item),
                    if (index != items.length - 1)
                      Divider(
                        height: 1,
                        indent: 50,
                        color: kDarkGreen.withValues(alpha: 0.08),
                      ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final _MenuItemData data;
  const _MenuTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final color = data.isDestructive ? Colors.redAccent : kDarkGreen;
    return InkWell(
      onTap: () {}, // sambungkan ke halaman masing-masing nanti
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Icon(data.icon, size: 20, color: color.withValues(alpha: 0.85)),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                data.label,
                style: TextStyle(fontSize: 13.5, color: color),
              ),
            ),
            if (!data.isDestructive)
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

// ==================== BOTTOM NAV BAR ====================
class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: kDarkGreen.withValues(alpha: 0.15)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(
                Icons.home,
                color: kDarkGreen.withValues(alpha: 0.5),
                size: 26,
              ),
            ),
            Icon(
              Icons.receipt_long_outlined,
              color: kDarkGreen.withValues(alpha: 0.5),
              size: 24,
            ),
            Icon(
              Icons.chat_bubble_outline,
              color: kDarkGreen.withValues(alpha: 0.5),
              size: 24,
            ),
            Icon(Icons.person, color: kDarkGreen, size: 26),
          ],
        ),
      ),
    );
  }
}
