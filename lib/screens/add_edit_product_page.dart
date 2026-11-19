import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../constants.dart';
import '../services/seller_state.dart';

/// Screen penuh untuk menambah atau mengedit produk milik toko penjual.
/// Dipakai dari SellerProductsPage (tombol + dan ikon edit).
class AddEditProductPage extends StatefulWidget {
  final SellerProduct? existing;
  final String? existingCategory;

  const AddEditProductPage({super.key, this.existing, this.existingCategory});

  @override
  State<AddEditProductPage> createState() => _AddEditProductPageState();
}

class _AddEditProductPageState extends State<AddEditProductPage> {
  static const List<String> _categories = [
    'Makanan',
    'Minuman',
    'Jajanan',
    'Lainnya',
  ];

  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _descController;

  late String _selectedCategory;
  Uint8List? _photoBytes;
  String? _existingImageUrl;
  bool _isSaving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.name ?? '');
    _priceController = TextEditingController(
      text: widget.existing != null ? widget.existing!.price.toString() : '',
    );
    _descController = TextEditingController(
      text: widget.existing?.description ?? '',
    );

    final initialCat = widget.existingCategory ?? '';
    _selectedCategory = _categories.contains(initialCat)
        ? initialCat
        : 'Makanan';

    final rawImage = widget.existing?.imagePath ?? '';
    if (rawImage.isNotEmpty) {
      if (rawImage.startsWith('http://') || rawImage.startsWith('https://')) {
        _existingImageUrl = rawImage;
      } else {
        try {
          final cleanBase64 = rawImage.contains(',')
              ? rawImage.split(',').last
              : rawImage;
          _photoBytes = base64Decode(cleanBase64);
        } catch (_) {
          _photoBytes = null;
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 700,
      maxHeight: 700,
      imageQuality: 70,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _photoBytes = bytes;
        _existingImageUrl = null;
      });
    }
  }

  void _removePhoto() {
    setState(() {
      _photoBytes = null;
      _existingImageUrl = null;
    });
  }

  Future<void> _save() async {
    if (_isSaving) return;

    final name = _nameController.text.trim();
    final price = int.tryParse(_priceController.text.trim()) ?? 0;
    final description = _descController.text.trim();

    if (name.isEmpty || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama dan harga produk wajib diisi'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesi login tidak ditemukan. Silakan login ulang.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      String imageBase64 = '';
      if (_photoBytes != null) {
        imageBase64 = base64Encode(_photoBytes!);
      }

      final productsRef = FirebaseFirestore.instance.collection('products');

      if (_isEditing) {
        await productsRef.doc(widget.existing!.id).update({
          'name': name,
          'nama': name,
          'price': price,
          'harga': price,
          'category': _selectedCategory,
          'kategori': _selectedCategory,
          'description': description,
          'deskripsi': description,
          'imageBase64': imageBase64,
          if (_existingImageUrl != null) 'imageUrl': _existingImageUrl,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Ambil nama toko dari dokumen tenants agar produk punya info penjual
        String namaToko = '';
        final tenantDoc = await FirebaseFirestore.instance
            .collection('tenants')
            .doc(uid)
            .get();
        if (tenantDoc.exists) {
          final tData = tenantDoc.data();
          namaToko = (tData?['namaToko'] ?? tData?['storeName'] ?? '')
              .toString();
        }

        await productsRef.add({
          'sellerId': uid,
          'tenantId': uid,
          'uid': uid,
          if (namaToko.isNotEmpty) 'namaToko': namaToko,
          'name': name,
          'nama': name,
          'price': price,
          'harga': price,
          'category': _selectedCategory,
          'kategori': _selectedCategory,
          'description': description,
          'deskripsi': description,
          'imageBase64': imageBase64,
          'isAvailable': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing
                ? 'Perubahan produk berhasil disimpan'
                : 'Produk berhasil ditambahkan',
          ),
          backgroundColor: kDarkGreen,
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan produk: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: kDarkGreen.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kDarkGreen, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasAnyPhoto =
        _photoBytes != null || (_existingImageUrl?.isNotEmpty ?? false);

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        foregroundColor: kDarkGreen,
        title: Text(
          _isEditing ? 'Edit Produk' : 'Tambah Produk',
          style: const TextStyle(
            color: kDarkGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            _PhotoPicker(
              photoBytes: _photoBytes,
              imageUrl: _existingImageUrl,
              onTap: _pickPhoto,
              onRemove: hasAnyPhoto ? _removePhoto : null,
            ),
            const SizedBox(height: 24),
            const _Label('Nama Produk'),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              decoration: _decoration('Contoh: Donat'),
            ),
            const SizedBox(height: 16),
            const _Label('Kategori'),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: _decoration('Pilih Kategori'),
              dropdownColor: Colors.white,
              icon: const Icon(Icons.keyboard_arrow_down, color: kDarkGreen),
              items: _categories
                  .map(
                    (cat) => DropdownMenuItem<String>(
                      value: cat,
                      child: Text(
                        cat,
                        style: const TextStyle(fontSize: 14, color: kDarkGreen),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedCategory = val);
                }
              },
            ),
            const SizedBox(height: 16),
            const _Label('Harga (Rp)'),
            const SizedBox(height: 6),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: _decoration('Contoh: 4000'),
            ),
            const SizedBox(height: 16),
            const _Label('Deskripsi (opsional)'),
            const SizedBox(height: 6),
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: _decoration('Deskripsi singkat produk...'),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 48,
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
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _isEditing ? 'Simpan Perubahan' : 'Tambah Produk',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== PEMILIH FOTO PRODUK ====================
class _PhotoPicker extends StatelessWidget {
  final Uint8List? photoBytes;
  final String? imageUrl;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  const _PhotoPicker({
    required this.photoBytes,
    required this.imageUrl,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoBytes != null || (imageUrl?.isNotEmpty ?? false);

    return Center(
      child: Stack(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              height: 160,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: kLightGreen,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kDarkGreen.withValues(alpha: 0.2)),
              ),
              child: _buildPreview(),
            ),
          ),
          if (hasPhoto)
            Positioned(
              right: 8,
              top: 8,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 16, color: Colors.white),
                ),
              ),
            ),
          if (hasPhoto)
            Positioned(
              left: 8,
              bottom: 8,
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit, size: 13, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'Ganti',
                        style: TextStyle(fontSize: 11.5, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    if (photoBytes != null) {
      return Image.memory(
        photoBytes!,
        width: double.infinity,
        height: 160,
        fit: BoxFit.cover,
      );
    }

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        width: double.infinity,
        height: 160,
        fit: BoxFit.cover,
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_a_photo_outlined,
          color: kDarkGreen.withValues(alpha: 0.55),
          size: 32,
        ),
        const SizedBox(height: 8),
        Text(
          'Tambah Foto Produk',
          style: TextStyle(
            fontSize: 13,
            color: kDarkGreen.withValues(alpha: 0.6),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: kDarkGreen,
      ),
    );
  }
}
