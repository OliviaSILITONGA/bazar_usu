import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../constants.dart';
import '../services/database_service.dart';
import '../services/profile_state.dart';
import '../widgets/profile_avatar.dart';

// Batas ukuran foto (setelah dikompres) supaya aman di dokumen Firestore (maks 1 MB).
const int _maxPhotoBytes = 500 * 1024;

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _bioController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;

  String? _currentPhoto; // foto tersimpan (base64 / URL) dari ProfileState
  Uint8List? _newPhotoBytes; // foto baru yang baru dipilih, belum disimpan
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final profile = ProfileState.instance.data.value;
    _nameController = TextEditingController(text: profile.name);
    _usernameController = TextEditingController(text: profile.username);
    _bioController = TextEditingController(text: profile.bio);
    _addressController = TextEditingController(text: profile.address);
    _phoneController = TextEditingController(text: profile.phone);

    final Object? photo = profile.photo;
    _currentPhoto = photo is String ? photo : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showMessage(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : kDarkGreen,
      ),
    );
  }

  Future<void> _pickPhoto() async {
    // Dikecilkan & dikompres dulu supaya ringan disimpan di Firestore.
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 70,
    );
    if (picked == null) return;

    // readAsBytes() jalan di HP maupun Chrome (tidak pakai dart:io File).
    final bytes = await picked.readAsBytes();
    if (!mounted) return;

    if (bytes.lengthInBytes > _maxPhotoBytes) {
      _showMessage('Ukuran foto terlalu besar, pilih foto lain.');
      return;
    }
    setState(() => _newPhotoBytes = bytes);
  }

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    try {
      final name = _nameController.text.trim().isEmpty
          ? 'Nama Pengguna'
          : _nameController.text.trim();
      final username = _usernameController.text.trim();
      final bio = _bioController.text.trim();
      final address = _addressController.text.trim();
      final phone = _phoneController.text.trim();

      // Tentukan foto yang akan disimpan
      // Jika ada foto baru (bytes), ubah ke base64. Jika tidak, pakai foto lama.
      // Jika keduanya kosong/null, gunakan string kosong '' agar field tetap ada di database.
      final String photoToSend = _newPhotoBytes != null
          ? base64Encode(_newPhotoBytes!)
          : (_currentPhoto ?? '');

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // 1. Update data teks utama melalui DatabaseService
        await DatabaseService().updateUserData(
          uid: user.uid,
          nama: name,
          username: username,
          bio: bio,
          address: address,
          phone: phone,
        );

        // 2. Simpan/Merge field 'foto' secara terpisah ke Firestore agar pasti masuk ke database
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'foto': photoToSend,
        }, SetOptions(merge: true));
      }

      // Perbarui state lokal agar UI langsung berubah secara real-time
      ProfileState.instance.update(
        ProfileData(
          name: name,
          username: username,
          bio: bio,
          address: address,
          phone: phone,
          photo: photoToSend,
        ),
      );

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _showMessage('Gagal menyimpan profil: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                    color: kDarkGreen,
                  ),
                  const Expanded(
                    child: Text(
                      'Edit Profil',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: kDarkGreen,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ---------- Foto profil ----------
                    Center(
                      child: GestureDetector(
                        onTap: _pickPhoto,
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                ProfileAvatar(
                                  photo: _newPhotoBytes ?? _currentPhoto,
                                  radius: 44,
                                ),
                                const Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: CircleAvatar(
                                    radius: 14,
                                    backgroundColor: kDarkGreen,
                                    child: Icon(
                                      Icons.camera_alt,
                                      size: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Ubah foto',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: kDarkGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _FormCard(
                      children: [
                        _EditRow(label: 'Nama', controller: _nameController),
                        _EditRow(
                          label: 'Nama pengguna',
                          controller: _usernameController,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Info Dasar',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: kDarkGreen.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _FormCard(
                      children: [
                        _EditRow(label: 'Bio', controller: _bioController),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Lainnya',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: kDarkGreen.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _FormCard(
                      children: [
                        _EditRow(
                          label: 'Alamat',
                          controller: _addressController,
                          maxLines: 2,
                        ),
                        _EditRow(
                          label: 'No. Telp',
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 46,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kDarkGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Simpan Perubahan',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== KARTU FORM ====================
class _FormCard extends StatelessWidget {
  final List<Widget> children;
  const _FormCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kDarkGreen.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: kDarkGreen.withValues(alpha: 0.08),
              ),
          ],
        ],
      ),
    );
  }
}

// ==================== BARIS EDIT (LABEL KIRI, FIELD KANAN) ====================
class _EditRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType? keyboardType;

  const _EditRow({
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: kDarkGreen.withValues(alpha: 0.6),
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: maxLines,
              keyboardType: keyboardType,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: kDarkGreen,
              ),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                isCollapsed: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
