import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../constants.dart';
import 'seller_main_navigation_page.dart';
import 'seller_registration_page.dart';
import 'main_navigation_page.dart';

class SellerStatusPage extends StatefulWidget {
  const SellerStatusPage({super.key});

  @override
  State<SellerStatusPage> createState() => _SellerStatusPageState();
}

class _SellerStatusPageState extends State<SellerStatusPage> {
  bool _isNavigating = false;

  void _navigateTo(Widget page) {
    if (_isNavigating) return;
    _isNavigating = true;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => page),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Sesi login tidak ditemukan.')),
      );
    }

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        title: const Text(
          'Status Pendaftaran Toko',
          style: TextStyle(color: kDarkGreen, fontWeight: FontWeight.bold),
        ),
        foregroundColor: kDarkGreen,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tenants')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: kDarkGreen),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            // Jika data toko belum ada, arahkan ke halaman pendaftaran toko
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.storefront_outlined,
                    size: 64,
                    color: kDarkGreen,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Kamu Belum Memiliki Toko',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: kDarkGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Daftarkan toko kamu sekarang untuk mulai berjualan di Bazar USU.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SellerRegistrationPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kDarkGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Daftar Toko Sekarang',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final status = data['status'] ?? 'pending';
          final namaToko = data['namaToko'] ?? 'Toko Kamu';

          // Jika disetujui, pindah ke dashboard penjual menggunakan helper _navigateTo
          if (status == 'approved') {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _navigateTo(const SellerMainNavigationPage());
            });
            return const Center(
              child: CircularProgressIndicator(color: kDarkGreen),
            );
          }

          bool isRejected = status == 'rejected';

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  isRejected
                      ? Icons.cancel_outlined
                      : Icons.hourglass_top_rounded,
                  size: 64,
                  color: isRejected ? Colors.redAccent : Colors.orange,
                ),
                const SizedBox(height: 16),
                Text(
                  isRejected
                      ? 'Pendaftaran Ditolak'
                      : 'Menunggu Verifikasi Admin',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isRejected ? Colors.redAccent : kDarkGreen,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isRejected
                      ? 'Maaf, pengajuan toko "$namaToko" belum disetujui admin. Kamu bisa mencoba mendaftar ulang dengan data yang lebih valid.'
                      : 'Pengajuan toko "$namaToko" sedang ditinjau oleh admin. Halaman ini akan otomatis memperbarui statusnya setelah disetujui.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54, height: 1.4),
                ),
                const SizedBox(height: 28),
                if (isRejected)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SellerRegistrationPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kDarkGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: const Text(
                      'Daftar Ulang Toko',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    _navigateTo(const MainNavigationPage());
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kDarkGreen,
                    side: BorderSide(color: kDarkGreen.withValues(alpha: 0.3)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Kembali ke Akun Pembeli',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
