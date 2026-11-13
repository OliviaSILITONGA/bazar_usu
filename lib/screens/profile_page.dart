import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../services/profile_state.dart';
import '../widgets/profile_avatar.dart';
import 'chat_list_page.dart';
import 'edit_profile_page.dart';
import 'favorite_products_page.dart';
import 'favorite_stores_page.dart';
import 'help_page.dart';
import 'login_screen.dart';
import 'orders_page.dart';
import 'profile_view_page.dart';
import 'report_page.dart';
import 'saved_addresses_page.dart';
import 'seller_status_page.dart';
import 'settings_page.dart';

/// Pindah ke halaman lain (menggantikan Navigator.push + MaterialPageRoute
/// yang sebelumnya ditulis berulang-ulang).
void _open(BuildContext context, Widget page) {
  Navigator.push(context, MaterialPageRoute(builder: (_) => page));
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    _loadUserProfile(); // Tarik data terbaru dari Firestore saat halaman dibuka
  }

  Future<void> _loadUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = doc.data();
      if (data == null) return;

      // Perbarui state lokal dengan data asli dari Firestore
      ProfileState.instance.update(
        ProfileData(
          name: data['nama'] ?? 'Nama Pengguna',
          username: data['username'] ?? '',
          bio: data['bio'] ?? '',
          address: data['alamat'] ?? '',
          phone: data['telepon'] ?? '',
          photo: data['foto'], // sesuai tipe di model ProfileData
        ),
      );

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Gagal memuat profil: $e');
    }
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar'),
        content: const Text('Yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text(
              'Keluar',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              ValueListenableBuilder<ProfileData>(
                valueListenable: ProfileState.instance.data,
                builder: (context, profile, _) => _ProfileHeader(
                  profile: profile,
                  onRowTap: () => _open(context, const ProfileViewPage()),
                  onEditTap: () => _open(context, const EditProfilePage()),
                ),
              ),
              const SizedBox(height: 24),
              _MenuSection(
                title: 'Akun',
                items: [
                  _MenuItemData(
                    icon: Icons.favorite_border,
                    label: 'Produk Favorit',
                    onTap: () => _open(context, const FavoriteProductsPage()),
                  ),
                  _MenuItemData(
                    icon: Icons.location_on_outlined,
                    label: 'Alamat Tersimpan',
                    onTap: () => _open(context, const SavedAddressesPage()),
                  ),
                  _MenuItemData(
                    icon: Icons.store_outlined,
                    label: 'Toko Favorit',
                    onTap: () => _open(context, const FavoriteStoresPage()),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _MenuSection(
                title: 'Lainnya',
                items: [
                  _MenuItemData(
                    icon: Icons.settings_outlined,
                    label: 'Pengaturan',
                    onTap: () => _open(context, const SettingsPage()),
                  ),
                  _MenuItemData(
                    icon: Icons.help_outline,
                    label: 'Bantuan',
                    onTap: () => _open(context, const HelpPage()),
                  ),
                  _MenuItemData(
                    icon: Icons.flag_outlined,
                    label: 'Laporkan',
                    onTap: () => _open(context, const ReportPage()),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _SwitchAccountBanner(
                  onTap: () => _open(context, const SellerStatusPage()),
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _LogoutButton(onTap: () => _handleLogout(context)),
              ),
              const SizedBox(height: 18),
              Center(
                child: Text(
                  'BazarUSU v1.0 • Dibuat dengan sepenuh hati',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: kDarkGreen.withValues(alpha: 0.5),
                  ),
                ),
              ),
              const SizedBox(height: 100),
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
  final ProfileData profile;
  final VoidCallback onRowTap;
  final VoidCallback onEditTap;

  const _ProfileHeader({
    required this.profile,
    required this.onRowTap,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    // Email asli dari akun yang sedang login.
    final email =
        FirebaseAuth.instance.currentUser?.email ?? 'email@students.usu.ac.id';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onRowTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    ProfileAvatar(photo: profile.photo, radius: 34),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: kDarkGreen,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            overflow: TextOverflow.ellipsis,
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
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onEditTap,
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
}

// ==================== SECTION MENU ====================
class _MenuItemData {
  final IconData icon;
  final String label;
  final bool isDestructive;
  final VoidCallback? onTap;

  const _MenuItemData({required this.icon, required this.label, this.onTap})
    : isDestructive = false;
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
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  _MenuTile(data: items[i]),
                  if (i != items.length - 1)
                    Divider(
                      height: 1,
                      indent: 58,
                      color: kDarkGreen.withValues(alpha: 0.08),
                    ),
                ],
              ],
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
      onTap: data.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: kLightGreen,
                shape: BoxShape.circle,
              ),
              child: Icon(
                data.icon,
                size: 17,
                color: color.withValues(alpha: 0.85),
              ),
            ),
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

// ==================== BANNER BERALIH AKUN ====================
class _SwitchAccountBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _SwitchAccountBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFFCF3D8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE9D08C)),
        ),
        child: const Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Color(0xFFE9D08C),
              child: Icon(Icons.storefront, color: Color(0xFF8A6D1D), size: 20),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Beralih ke Akun Penjual',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6B5312),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Kelola toko dan pesananmu',
                    style: TextStyle(fontSize: 11.5, color: Color(0xFF8A7530)),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Color(0xFF8A7530), size: 20),
          ],
        ),
      ),
    );
  }
}

// ==================== TOMBOL KELUAR ====================
class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;

  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, size: 18, color: Colors.redAccent),
            SizedBox(width: 8),
            Text(
              'Keluar',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
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
            _NavIcon(
              icon: Icons.home,
              size: 26,
              onTap: () => Navigator.pop(context),
            ),
            _NavIcon(
              icon: Icons.receipt_long_outlined,
              onTap: () => _open(context, const OrdersPage()),
            ),
            _NavIcon(
              icon: Icons.chat_bubble_outline,
              onTap: () => _open(context, ChatListPage()),
            ),
            _NavIcon(
              icon: Icons.person,
              size: 26,
              isActive: true,
              onTap: () => _open(context, const ProfilePage()),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final bool isActive;
  final VoidCallback onTap;

  const _NavIcon({
    required this.icon,
    required this.onTap,
    this.size = 24,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        icon,
        size: size,
        color: isActive ? kDarkGreen : kDarkGreen.withValues(alpha: 0.5),
      ),
    );
  }
}
