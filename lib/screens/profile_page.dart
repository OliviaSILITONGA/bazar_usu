import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'chat_list_page.dart';
import 'orders_page.dart';
import 'seller_main_navigation_page.dart';
import 'seller_registration_page.dart';
import 'favorite_stores_page.dart';
import 'favorite_products_page.dart';
import 'saved_addresses_page.dart';
import 'login_screen.dart';

import '../constants.dart';
import '../services/seller_state.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _name = 'Nama Pengguna';
  File? _photoFile;

  Future<void> _openEditSheet() async {
    final nameController = TextEditingController(text: _name);
    File? tempPhoto = _photoFile;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Edit Profil',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: kDarkGreen,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final picked = await picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (picked != null) {
                          setSheetState(() => tempPhoto = File(picked.path));
                        }
                      },
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 44,
                            backgroundColor: kLightGreen,
                            backgroundImage: tempPhoto != null
                                ? FileImage(tempPhoto!)
                                : null,
                            child: tempPhoto == null
                                ? Icon(
                                    Icons.person,
                                    color: kDarkGreen.withValues(alpha: 0.6),
                                    size: 44,
                                  )
                                : null,
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: const BoxDecoration(
                                color: kDarkGreen,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Ketuk untuk ganti foto',
                      style: TextStyle(
                        fontSize: 12,
                        color: kDarkGreen.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Nama Pengguna',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: kDarkGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: kDarkGreen.withValues(alpha: 0.4),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: kDarkGreen,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _name = nameController.text.trim().isEmpty
                              ? _name
                              : nameController.text.trim();
                          _photoFile = tempPhoto;
                        });
                        Navigator.pop(sheetContext);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kDarkGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        'Simpan',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _handleSwitchAccount() {
    final status = SellerAccountState.instance.status.value;

    switch (status) {
      case SellerStatus.none:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SellerRegistrationPage()),
        );
        break;
      case SellerStatus.pending:
        _showInfoDialog(
          title: 'Menunggu Verifikasi',
          message: 'Pendaftaran toko kamu sedang ditinjau oleh admin. Kamu akan bisa beralih ke akun penjual setelah disetujui.',
        );
        break;
      case SellerStatus.rejected:
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Pendaftaran Ditolak'),
            content: const Text(
              'Pendaftaran toko kamu sebelumnya belum disetujui admin. Kamu bisa mencoba mendaftar ulang dengan data yang lebih lengkap.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Nanti'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SellerRegistrationPage(),
                    ),
                  );
                },
                child: const Text('Daftar Ulang'),
              ),
            ],
          ),
        );
        break;
      case SellerStatus.approved:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const SellerMainNavigationPage()),
        );
        break;
    }
  }

  void _showInfoDialog({required String title, required String message}) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Oke'),
          ),
        ],
      ),
    );
  }

  void _handleLogout() {
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
              Navigator.of(dialogContext).pop();
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
              _ProfileHeader(
                name: _name,
                photoFile: _photoFile,
                onEditTap: _openEditSheet,
              ),
              const SizedBox(height: 24),
              _MenuSection(
                title: 'Akun',
                items: [
                  _MenuItemData(
                    icon: Icons.favorite_border,
                    label: 'Produk Favorit',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FavoriteProductsPage(),
                        ),
                      );
                    },
                  ),
                  _MenuItemData(
                    icon: Icons.location_on_outlined,
                    label: 'Alamat Tersimpan',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SavedAddressesPage(),
                        ),
                      );
                    },
                  ),
                  _MenuItemData(
                    icon: Icons.store_outlined,
                    label: 'Toko Favorit',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FavoriteStoresPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _MenuSection(
                title: 'Lainnya',
                items: [
                  const _MenuItemData(
                    icon: Icons.settings_outlined,
                    label: 'Pengaturan',
                  ),
                  const _MenuItemData(
                    icon: Icons.help_outline,
                    label: 'Bantuan',
                  ),
                  const _MenuItemData(
                    icon: Icons.flag_outlined,
                    label: 'Laporkan',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _SwitchAccountBanner(onTap: _handleSwitchAccount),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _LogoutButton(onTap: _handleLogout),
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
  final String name;
  final File? photoFile;
  final VoidCallback onEditTap;

  const _ProfileHeader({
    required this.name,
    required this.photoFile,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: kLightGreen,
            backgroundImage: photoFile != null ? FileImage(photoFile!) : null,
            child: photoFile == null
                ? Icon(
                    Icons.person,
                    color: kDarkGreen.withValues(alpha: 0.6),
                    size: 34,
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
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
          GestureDetector(
            onTap: onEditTap,
            child: Icon(
              Icons.edit_outlined,
              color: kDarkGreen.withValues(alpha: 0.6),
              size: 20,
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
  const _MenuItemData({
    required this.icon,
    required this.label,
    this.isDestructive = false,
    this.onTap,
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
                        indent: 58,
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
      onTap: data.onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
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

// ==================== BANNER BERALIH AKUN (WIDGET BARU) ====================
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
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFFE9D08C),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.storefront,
                color: Color(0xFF8A6D1D),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
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
            const Icon(Icons.chevron_right, color: Color(0xFF8A7530), size: 20),
          ],
        ),
      ),
    );
  }
}

// ==================== TOMBOL KELUAR (WIDGET BARU) ====================
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
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(
                Icons.home,
                color: kDarkGreen.withValues(alpha: 0.5),
                size: 26,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OrdersPage()),
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                color: kDarkGreen.withValues(alpha: 0.5),
                size: 24,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ChatListPage()),
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                color: kDarkGreen.withValues(alpha: 0.5),
                size: 24,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              ),
              child: const Icon(Icons.person, color: kDarkGreen, size: 26),
            ),
          ],
        ),
      ),
    );
  }
}
