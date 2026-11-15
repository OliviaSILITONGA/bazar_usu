import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/database_service.dart';
import '../constants.dart';
import '../services/seller_profile_extra_state.dart';

class SellerEditProfilePage extends StatefulWidget {
  const SellerEditProfilePage({super.key});

  @override
  State<SellerEditProfilePage> createState() => _SellerEditProfilePageState();
}

class _SellerEditProfilePageState extends State<SellerEditProfilePage> {
  late final TextEditingController _descriptionController;

  File? _photo; // foto baru (hanya untuk state lokal, tidak dipakai di web)
  Uint8List? _pickedBytes; // foto baru yang baru dipilih (untuk preview)
  Uint8List? _photoBytes; // foto lama dari Firestore
  String? _newPhotoBase64; // foto baru dalam bentuk base64

  String _namaToko = '-';
  String _kategori = '-';
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final extra = SellerProfileExtraState.instance.data.value;
    _descriptionController = TextEditingController(text: extra.description);
    _loadTenant();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  // Ambil data toko dari Firestore
  Future<void> _loadTenant() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final data = await DatabaseService().getTenant(user.uid);
      if (data != null && mounted) {
        Uint8List? fotoBytes;
        final foto = data['fotoBase64'] as String?;
        if (foto != null && foto.isNotEmpty) {
          try {
            fotoBytes = base64Decode(foto);
          } catch (e) {
            debugPrint('Foto toko di Firestore tidak valid: $e');
          }
        }

        setState(() {
          _namaToko = (data['namaToko'] as String?) ?? '-';
          _kategori = (data['kategori'] as String?) ?? '-';
          _descriptionController.text = (data['deskripsi'] as String?) ?? '';
          _photoBytes = fotoBytes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data toko: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 70, // dikompres supaya ukurannya kecil
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    setState(() {
      _pickedBytes = bytes;
      _photo = kIsWeb ? null : File(picked.path);
      _newPhotoBase64 = base64Encode(bytes);
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw 'Sesi login tidak ditemukan';

      final deskripsi = _descriptionController.text.trim();

      // Simpan deskripsi (+ foto kalau ada yang baru) ke koleksi 'tenants'
      await DatabaseService().updateTenantData(
        uid: user.uid,
        deskripsi: deskripsi,
        fotoBase64: _newPhotoBase64,
      );

      // Perbarui state lokal aplikasi
      SellerProfileExtraState.instance.update(
        SellerProfileExtra(
          description: deskripsi,
          photo: _photo ?? SellerProfileExtraState.instance.data.value.photo,
        ),
      );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan profil toko: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  // Foto yang ditampilkan: foto baru > foto dari Firestore > kosong.
  // Pakai bytes (MemoryImage) supaya jalan di semua platform, termasuk web.
  ImageProvider? get _avatarImage {
    if (_pickedBytes != null) return MemoryImage(_pickedBytes!);
    if (_photoBytes != null) return MemoryImage(_photoBytes!);
    return null;
  }

  // Kotak deskripsi: satu TextField saja (tanpa Container pembungkus)
  Widget _buildDescriptionField() {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: kDarkGreen.withValues(alpha: 0.15)),
    );

    return TextField(
      controller: _descriptionController,
      maxLines: 5,
      minLines: 4,
      maxLength: 200,
      textCapitalization: TextCapitalization.sentences,
      style: const TextStyle(fontSize: 13.5, color: kDarkGreen, height: 1.4),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintText: 'Ceritakan tentang tokomu...',
        hintStyle: TextStyle(color: kDarkGreen.withValues(alpha: 0.4)),
        counterStyle: TextStyle(
          fontSize: 11,
          color: kDarkGreen.withValues(alpha: 0.5),
        ),
        border: border,
        enabledBorder: border,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: kDarkGreen, width: 1.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatar = _avatarImage;

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
                      'Edit Profil Toko',
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
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: kDarkGreen),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: GestureDetector(
                              onTap: _pickPhoto,
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    radius: 46,
                                    backgroundColor: Colors.grey.shade300,
                                    backgroundImage: avatar,
                                    onBackgroundImageError: avatar == null
                                        ? null
                                        : (e, _) => debugPrint(
                                            'Gagal render foto toko: $e',
                                          ),
                                    child: avatar == null
                                        ? const Icon(
                                            Icons.camera_alt_outlined,
                                            size: 32,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Ubah foto toko',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: kDarkGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: kDarkGreen.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Column(
                              children: [
                                _InfoRow(label: 'Nama Toko', value: _namaToko),
                                Divider(
                                  height: 1,
                                  indent: 16,
                                  endIndent: 16,
                                  color: kDarkGreen.withValues(alpha: 0.08),
                                ),
                                _InfoRow(label: 'Kategori', value: _kategori),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Text(
                              'Nama toko & kategori diatur saat pendaftaran toko.',
                              style: TextStyle(
                                fontSize: 11,
                                color: kDarkGreen.withValues(alpha: 0.45),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Text(
                              'Deskripsi Toko',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: kDarkGreen.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildDescriptionField(),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 46,
                            child: ElevatedButton(
                              onPressed: _saving ? null : _save,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kDarkGreen,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: _saving
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Simpan Perubahan',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
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

// Baris info read-only (label di kiri, nilai di kanan)
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
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
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: kDarkGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}