import 'package:flutter/material.dart';

import '../constants.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Data simulasi Transaksi
  final List<Map<String, dynamic>> _transactions = [
    {
      'id': 'TRX-9901',
      'pembeli': 'Rian Pratama',
      'toko': 'Kopi Danusan FASILKOM',
      'total': 'Rp 28.000',
      'metode': 'QRIS / E-Wallet',
      'waktu': 'Hari ini, 14:20 WIB',
      'status': 'Selesai',
    },
    {
      'id': 'TRX-9902',
      'pembeli': 'Anisa Putri',
      'toko': 'Risol Lumer FEB',
      'total': 'Rp 15.000',
      'metode': 'Tunai',
      'waktu': 'Hari ini, 13:05 WIB',
      'status': 'Selesai',
    },
    {
      'id': 'TRX-9903',
      'pembeli': 'Budi Santoso',
      'toko': 'Merchandise USU Unik',
      'total': 'Rp 45.000',
      'metode': 'QRIS / E-Wallet',
      'waktu': 'Kemarin, 16:45 WIB',
      'status': 'Dibatalkan',
    },
  ];

  // Data simulasi Laporan Pengaduan
  final List<Map<String, dynamic>> _complaints = [
    {
      'id': 'LPR-001',
      'pelapor': 'Budi Santoso (Pembeli)',
      'terlaporkan': 'Toko Es Bunga USU',
      'subjek': 'Keterlambatan Pesanan & Pesanan Tidak Sesuai',
      'deskripsi': 'Pesanan minuman tidak sesuai varian dan menunggu lebih dari 30 menit.',
      'tanggal': '23 Sep 2026',
      'status': 'Menunggu',
    },
    {
      'id': 'LPR-002',
      'pelapor': 'Siti Rahma (Penjual)',
      'terlaporkan': 'Penjual Tanpa Izin Lapak',
      'subjek': 'Penggunaan Area Tanpa Izin Admin',
      'deskripsi': 'Ada lapak liar yang menutupi akses masuk ke booth resmi di Lapangan Pancasila.',
      'tanggal': '22 Sep 2026',
      'status': 'Diproses',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _resolveComplaint(int index) {
    setState(() {
      _complaints[index]['status'] = 'Selesai';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Laporan ${_complaints[index]['id']} telah ditandai Selesai.',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
      appBar: AppBar(
        title: const Text('Laporan & Pengaduan'),
        backgroundColor: kGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          tabs: const [
            Tab(text: 'Riwayat Transaksi'),
            Tab(text: 'Laporan Pengaduan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: TRANSAKSI
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                final trx = _transactions[index];
                final isDone = trx['status'] == 'Selesai';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: isDone
                          ? Colors.green.shade100
                          : Colors.red.shade100,
                      child: Icon(
                        isDone ? Icons.receipt_long : Icons.cancel_outlined,
                        color: isDone ? Colors.green : Colors.red,
                      ),
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          trx['id'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          trx['total'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: kGreen,
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          '${trx['toko']} • ${trx['pembeli']}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${trx['metode']} • ${trx['waktu']}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // TAB 2: PENGADUAN
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: _complaints.length,
              itemBuilder: (context, index) {
                final complaint = _complaints[index];
                final isPending = complaint['status'] == 'Menunggu';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              complaint['id'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: kGreen,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isPending
                                    ? Colors.orange.shade100
                                    : Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                complaint['status'],
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isPending
                                      ? Colors.orange.shade900
                                      : Colors.blue.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          complaint['subjek'],
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          complaint['deskripsi'],
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Pelapor: ${complaint['pelapor']}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    'Terlaporkan: ${complaint['terlaporkan']}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (complaint['status'] != 'Selesai')
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kGreen,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () => _resolveComplaint(index),
                                child: const Text(
                                  'Selesaikan',
                                  style: TextStyle(fontSize: 12),
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
          ),
        ],
      ),
    );
  }
}
