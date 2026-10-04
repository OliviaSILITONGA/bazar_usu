import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../constants.dart';
import '../services/seller_state.dart';

/// Screen penuh untuk menambah atau mengedit produk milik toko penjual.
/// Dipakai dari SellerProductsPage (tombol + dan ikon edit).
class AddEditProductPage extends StatefulWidget {
  final SellerProduct? existing;
  const AddEditProductPage({super.key, this.existing});

  @override
  State<AddEditProductPage> createState() => _AddEditProductPageState();
}

class _AddEditProductPageState extends State<AddEditProductPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _descController;

  File? _photoFile;

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
    final existingImagePath = widget.existing?.imagePath;
    if (existingImagePath != null && existingImagePath.isNotEmpty) {
      _photoFile = File(existingImagePath);
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
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() => _photoFile = File(picked.path));
    }
  }

  void _removePhoto() {
    setState(() => _photoFile = null);
  }

  void _save() {
    final name = _nameController.text.trim();
    final price = int.tryParse(_priceController.text.trim()) ?? 0;

    if (name.isEmpty || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dan harga produk wajib diisi')),
      );
      return;
    }

    if (_isEditing) {
      SellerAccountState.instance.updateProduct(
        SellerProduct(
          id: widget.existing!.id,
          name: name,
          price: price,
          description: _descController.text.trim(),
          imagePath: _photoFile?.path,
        ),
      );
    } else {
      SellerAccountState.instance.addProduct(
        name: name,
        price: price,
        description: _descController.text.trim(),
        imagePath: _photoFile?.path,
      );
    }

    Navigator.pop(context);
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
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        foregroundColor: kDarkGreen,
        title: Text(
          _isEditing ? 'Edit Produk' : 'Tambah Produk',
          style: const TextStyle(color: kDarkGreen, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            _PhotoPicker(
              photoFile: _photoFile,
              onTap: _pickPhoto,
              onRemove: _photoFile != null ? _removePhoto : null,
            ),
            const SizedBox(height: 24),
            _Label('Nama Produk'),
            const SizedBox(height: 6),
            TextField(
              controller: _nameController,
              decoration: _decoration('Contoh: Donat'),
            ),
            const SizedBox(height: 16),
            _Label('Harga (Rp)'),
            const SizedBox(height: 6),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: _decoration('Contoh: 4000'),
            ),
            const SizedBox(height: 16),
            _Label('Deskripsi (opsional)'),
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
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kDarkGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
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
  final File? photoFile;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  const _PhotoPicker({
    required this.photoFile,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
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
              child: photoFile != null
                  ? Image.file(
                      photoFile!,
                      width: double.infinity,
                      height: 160,
                      fit: BoxFit.cover,
                    )
                  : Column(
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
                    ),
            ),
          ),
          if (photoFile != null)
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
          if (photoFile != null)
            Positioned(
              left: 8,
              bottom: 8,
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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