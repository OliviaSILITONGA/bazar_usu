import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../constants.dart';
import '../widgets/auth_widgets.dart';
import 'home_page_user.dart';
import 'ktm_pending_page.dart';

class KtmVerificationPage extends StatefulWidget {
  final String userName;
  final String userNim;

  const KtmVerificationPage({
    super.key,
    required this.userName,
    required this.userNim,
  });

  @override
  State<KtmVerificationPage> createState() => _KtmVerificationPageState();
}

class _KtmVerificationPageState extends State<KtmVerificationPage> {
  Uint8List? _imageBytes; // Menyimpan bytes gambar agar aman di Web & HP
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengambil gambar: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Wrap(
              children: [
                const ListTile(
                  title: Text(
                    'Pilih Sumber Foto KTM',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                // Jika di Web, kamera mungkin tidak tersedia langsung, tapi tetap kita sediakan
                if (!kIsWeb)
                  ListTile(
                    leading: const Icon(Icons.camera_alt, color: kDarkGreen),
                    title: const Text('Ambil lewat Kamera'),
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: kDarkGreen),
                  title: Text(
                    kIsWeb ? 'Pilih File KTM' : 'Pilih dari Galeri/File',
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitVerification() async {
    if (_imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap unggah foto KTM terlebih dahulu!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesi login tidak ditemukan.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    try {
      // Ubah bytes gambar ke string base64
      final base64Ktm = base64Encode(_imageBytes!);

      // Simpan foto KTM dan status verifikasi ke Cloud Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'ktmPhoto': base64Ktm,
        'ktmStatus': 'pending', // Status: pending, approved, rejected
        'nim': widget.userNim,
        'nama': widget.userName,
        'submittedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Foto KTM berhasil dikirim! Menunggu verifikasi admin.',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Berhasil verifikasi dan masuk ke HomePageUser
      // Ganti bagian Navigator ini di _submitVerification:
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const KtmPendingPage()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengirim verifikasi: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verifikasi KTM'),
        backgroundColor: kDarkGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Halo ${widget.userName},',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kDarkGreen,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'NIM: ${widget.userNim}',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Untuk memverifikasi status Anda sebagai mahasiswa USU, silakan unggah foto Kartu Tanda Mahasiswa (KTM) Anda.',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 24),

            // Area Tampilan / Input Foto KTM
            GestureDetector(
              onTap: _showImagePickerOptions,
              child: Container(
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _imageBytes != null
                        ? kDarkGreen
                        : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child: _imageBytes != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Menggunakan Image.memory agar aman di Web maupun HP
                            Image.memory(_imageBytes!, fit: BoxFit.cover),
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Ubah',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo_outlined,
                            size: 48,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Ketuk untuk Unggah / Pilih File KTM',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 32),

            AuthButton(
              text: 'Selesaikan Pendaftaran',
              onPressed: _submitVerification,
            ),
          ],
        ),
      ),
    );
  }
}
