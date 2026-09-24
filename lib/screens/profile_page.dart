import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../constants.dart';

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
              const _MenuSection(
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
                  _MenuItemData(icon: Icons.star_border, label: 'Ulasan'),
                ],
              ),
              const SizedBox(height: 20),
              const _MenuSection(
                title: 'Lainnya',
                items: [
                  _MenuItemData(
                    icon: Icons.settings_outlined,
                    label: 'Pengaturan',
                  ),
                  _MenuItemData(icon: Icons.help_outline, label: 'Bantuan'),
                  _MenuItemData(icon: Icons.swap_horiz, label: 'Beralih Akun'),
                  _MenuItemData(icon: Icons.flag_outlined, label: 'Laporkan'),
                  _MenuItemData(
                    icon: Icons.logout,
                    label: 'Keluar',
                    isDestructive: true,
                  ),
                ],
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
      onTap: () {},
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
