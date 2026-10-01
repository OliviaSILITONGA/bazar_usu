import 'package:flutter/material.dart';

import '../constants.dart';
import '../services/seller_state.dart';

class SellerVerificationPage extends StatelessWidget {
  const SellerVerificationPage({super.key});

  void _approveSeller(BuildContext context, SellerApplication app) {
    SellerAccountState.instance.approve(app.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${app.namaToko} berhasil diverifikasi & disetujui!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _rejectSeller(BuildContext context, SellerApplication app) {
    SellerAccountState.instance.reject(app.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pendaftaran ${app.namaToko} ditolak.'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
      appBar: AppBar(
        title: const Text('Verifikasi Penjual'),
        backgroundColor: kGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ValueListenableBuilder<List<SellerApplication>>(
        valueListenable: SellerAccountState.instance.pendingApplications,
        builder: (context, pendingSellers, _) {
          if (pendingSellers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tidak ada antrean verifikasi!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pendingSellers.length,
            itemBuilder: (context, index) {
              final seller = pendingSellers[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Card
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              seller.namaToko,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: kGreen,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: kGreen.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              seller.kategori,
                              style: const TextStyle(
                                fontSize: 12,
                                color: kGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),

                      // Detail Pendaftar
                      _buildDetailRow(
                        Icons.phone,
                        'No. WhatsApp',
                        seller.nomorHp,
                      ),
                      _buildDetailRow(
                        Icons.description,
                        'Alasan/Deskripsi',
                        seller.alasan,
                      ),

                      const SizedBox(height: 16),

                      // Aksi Setujui / Tolak
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon: const Icon(Icons.close),
                              label: const Text('Tolak'),
                              onPressed: () => _rejectSeller(context, seller),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kGreen,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon: const Icon(Icons.check),
                              label: const Text('Setujui'),
                              onPressed: () => _approveSeller(context, seller),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}