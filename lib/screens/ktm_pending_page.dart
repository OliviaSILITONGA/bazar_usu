import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import 'home_page_user.dart';
import 'login_screen.dart'; // Sesuaikan dengan path halaman login kamu

class KtmPendingPage extends StatelessWidget {
  const KtmPendingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const LoginPage();
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: kDarkGreen)),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text('Data pengguna tidak ditemukan.'),
              ),
            ),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final ktmStatus = data['ktmStatus'] ?? 'pending';

        // Jika sudah disetujui admin, otomatis masuk ke HomePageUser
        if (ktmStatus == 'approved') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomePageUser()),
              (route) => false,
            );
          });
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: kDarkGreen,
            foregroundColor: Colors.white,
            title: const Text('Status Verifikasi KTM'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (!context.mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    ktmStatus == 'rejected'
                        ? Icons.cancel_outlined
                        : Icons.hourglass_top_rounded,
                    size: 80,
                    color: ktmStatus == 'rejected' ? Colors.red : kDarkGreen,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    ktmStatus == 'rejected'
                        ? 'Verifikasi KTM Ditolak'
                        : 'Menunggu Verifikasi Admin',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: ktmStatus == 'rejected' ? Colors.red : kDarkGreen,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    ktmStatus == 'rejected'
                        ? 'Maaf, foto KTM Anda ditolak oleh admin. Silakan hubungi pusat bantuan atau daftar ulang dengan foto yang valid.'
                        : 'Akun dan foto KTM Anda sedang ditinjau oleh admin. Halaman ini akan otomatis masuk ke beranda setelah disetujui.',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  if (ktmStatus == 'rejected')
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kDarkGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        if (!context.mounted) return;
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                          (route) => false,
                        );
                      },
                      child: const Text('Keluar / Daftar Ulang'),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
