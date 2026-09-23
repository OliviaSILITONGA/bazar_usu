import 'package:flutter/material.dart';

import '../constants.dart';

class SellerVerificationPage extends StatefulWidget {
  const SellerVerificationPage({super.key});

  @override
  State<SellerVerificationPage> createState() => _SellerVerificationPageState();
}

class _SellerVerificationPageState extends State<SellerVerificationPage> {
  // Data simulasi toko mahasiswa yang mendaftar
  final List<Map<String, String>> _pendingSellers = [
    {
      'id': '1',
      'namaToko': 'Kopi Danusan FASILKOM',
      'pemilik': 'Budi Santoso',
      'nim': '221401051',
      'fakultas': 'Fasilkom-TI',
      'kategori': 'Minuman',
      'nomorHp': '081234567890',
      'alasan': 'Penggalangan dana untuk kegiatan inaugurasi angkatan 2024.',
    },
    {
      'id': '2',
      'namaToko': 'Risol Lumer FEB',
      'pemilik': 'Siti Rahma',
      'nim': '210502110',
      'fakultas': 'Ekonomi & Bisnis',
      'kategori': 'Makanan Ringan',
      'nomorHp': '082198765432',
      'alasan': 'Penjualan produk UMKM mahasiswa kewirausahaan.',
    },
    {
      'id': '3',
      'namaToko': 'Merchandise USU Unik',
      'pemilik': 'Andi Wijaya',
      'nim': '230901005',
      'fakultas': 'ISIP',
      'kategori': 'Aksesoris & Souvenir',
      'nomorHp': '085311223344',
      'alasan':
          'Kreativitas usaha mandiri berupa stiker dan gantungan kunci kampus.',
    },
  ];

  void _approveSeller(int index) {
    final sellerName = _pendingSellers[index]['namaToko'];
    setState(() {
      _pendingSellers.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$sellerName berhasil diverifikasi & disetujui!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _rejectSeller(int index) {
    final sellerName = _pendingSellers[index]['namaToko'];
    setState(() {
      _pendingSellers.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pendaftaran $sellerName ditolak.'),
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
      body: _pendingSellers.isEmpty
          ? Center(
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
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _pendingSellers.length,
              itemBuilder: (context, index) {
                final seller = _pendingSellers[index];
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
                                seller['namaToko']!,
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
                                seller['kategori']!,
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
                          Icons.person,
                          'Pemilik',
                          seller['pemilik']!,
                        ),
                        _buildDetailRow(Icons.badge, 'NIM', seller['nim']!),
                        _buildDetailRow(
                          Icons.school,
                          'Fakultas',
                          seller['fakultas']!,
                        ),
                        _buildDetailRow(
                          Icons.phone,
                          'No. WhatsApp',
                          seller['nomorHp']!,
                        ),
                        _buildDetailRow(
                          Icons.description,
                          'Alasan/Deskripsi',
                          seller['alasan']!,
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
                                onPressed: () => _rejectSeller(index),
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
                                onPressed: () => _approveSeller(index),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
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
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
