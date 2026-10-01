import 'package:flutter/material.dart';

import '../constants.dart';
import '../services/seller_state.dart';
import 'seller_main_navigation_page.dart';

class SellerRegistrationPage extends StatefulWidget {
  const SellerRegistrationPage({super.key});

  @override
  State<SellerRegistrationPage> createState() =>
      _SellerRegistrationPageState();
}

class _SellerRegistrationPageState extends State<SellerRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaTokoController = TextEditingController();
  final _nomorHpController = TextEditingController();
  final _alasanController = TextEditingController();

  static const _kategoriOptions = [
    'Makanan Berat',
    'Makanan Ringan',
    'Minuman',
    'Alat Tulis',
    'Aksesoris & Souvenir',
    'Lainnya',
  ];
  String _kategori = _kategoriOptions.first;

  @override
  void dispose() {
    _namaTokoController.dispose();
    _nomorHpController.dispose();
    _alasanController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    SellerAccountState.instance.submitApplication(
      namaToko: _namaTokoController.text.trim(),
      kategori: _kategori,
      nomorHp: _nomorHpController.text.trim(),
      alasan: _alasanController.text.trim(),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Toko Berhasil Dibuat'),
        content: const Text(
          'Toko kamu sudah aktif dan siap berjualan. Kamu akan diarahkan '
          'ke dashboard penjual.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // tutup dialog
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => const SellerMainNavigationPage(),
                ),
              );
            },
            child: const Text('Mulai Berjualan'),
          ),
        ],
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
        title: const Text(
          'Daftar Jadi Penjual',
          style: TextStyle(color: kDarkGreen, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Isi data toko kamu di bawah ini. Admin akan meninjau '
                'dan memverifikasi sebelum akun penjual kamu aktif.',
                style: TextStyle(
                  fontSize: 13,
                  color: kDarkGreen.withValues(alpha: 0.75),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              _FieldLabel('Nama Toko'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _namaTokoController,
                decoration: _fieldDecoration('Contoh: Kedai Ciau'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 18),
              _FieldLabel('Kategori'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _kategori,
                decoration: _fieldDecoration(null),
                items: _kategoriOptions
                    .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                    .toList(),
                onChanged: (v) => setState(() => _kategori = v ?? _kategori),
              ),
              const SizedBox(height: 18),
              _FieldLabel('Nomor WhatsApp'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nomorHpController,
                keyboardType: TextInputType.phone,
                decoration: _fieldDecoration('Contoh: 081234567890'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 18),
              _FieldLabel('Alasan / Deskripsi Toko'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _alasanController,
                maxLines: 4,
                decoration: _fieldDecoration(
                  'Ceritakan singkat tentang toko kamu...',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kDarkGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Kirim Pendaftaran',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String? hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: kDarkGreen.withValues(alpha: 0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: kDarkGreen.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kDarkGreen, width: 2),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: kDarkGreen,
      ),
    );
  }
}