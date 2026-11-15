import 'dart:convert';
import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../services/database_service.dart';
import 'seller_edit_profile_page.dart';

class SellerProfileViewPage extends StatefulWidget {
  const SellerProfileViewPage({super.key});

  @override
  State<SellerProfileViewPage> createState() => _SellerProfileViewPageState();
}

class _SellerProfileViewPageState extends State<SellerProfileViewPage> {
  late final Stream<Map<String, dynamic>?>? _tenantStream;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    _tenantStream = uid == null ? null : DatabaseService().tenantStream(uid);
  }

  Uint8List? _decodePhoto(String? base64Str) {
    if (base64Str == null || base64Str.isEmpty) return null;
    try {
      return base64Decode(base64Str);
    } catch (e) {
      debugPrint('Foto toko tidak valid: $e');
      return null;
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
                      'Detail Toko',
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
              child: _tenantStream == null
                  ? const Center(child: Text('Sesi login tidak ditemukan.'))
                  : StreamBuilder<Map<String, dynamic>?>(
                      stream: _tenantStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Gagal memuat data toko.\n${snapshot.error}',
                                textAlign: TextAlign.center),
                          );
                        }
                        if (snapshot.connectionState ==
                                ConnectionState.waiting &&
                            !snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: kDarkGreen,
                            ),
                          );
                        }

                        final data = snapshot.data;
                        final namaToko =
                            (data?['namaToko'] as String?)?.trim() ?? '';
                        final kategori =
                            (data?['kategori'] as String?)?.trim() ?? '';
                        final deskripsi =
                            (data?['deskripsi'] as String?)?.trim() ?? '';
                        final photoBytes = _decodePhoto(
                          data?['fotoBase64'] as String?,
                        );

                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: kDarkGreen.withValues(alpha: 0.12),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: Container(
                                    width: 72,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: kLightGreen,
                                      border: Border.all(
                                        color:
                                            kDarkGreen.withValues(alpha: 0.3),
                                      ),
                                      image: photoBytes != null
                                          ? DecorationImage(
                                              image: MemoryImage(photoBytes),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                    child: photoBytes == null
                                        ? Icon(
                                            Icons.storefront,
                                            color: kDarkGreen.withValues(
                                              alpha: 0.7,
                                            ),
                                            size: 32,
                                          )
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Center(
                                  child: Text(
                                    namaToko.isNotEmpty
                                        ? namaToko
                                        : 'Toko Kamu',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: kDarkGreen,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Center(
                                  child: Text(
                                    kategori.isNotEmpty ? kategori : '-',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: kDarkGreen.withValues(alpha: 0.65),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                if (deskripsi.isNotEmpty)
                                  Text(
                                    deskripsi,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.black54,
                                      height: 1.4,
                                    ),
                                  )
                                else
                                  Center(
                                    child: Text(
                                      'Belum ada deskripsi toko.',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color:
                                            kDarkGreen.withValues(alpha: 0.4),
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 20),
                                Center(
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const SellerEditProfilePage(),
                                        ),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: kDarkGreen,
                                      side: BorderSide(
                                        color:
                                            kDarkGreen.withValues(alpha: 0.3),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 28,
                                        vertical: 12,
                                      ),
                                    ),
                                    child: const Text(
                                      'Edit Profil Toko',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}