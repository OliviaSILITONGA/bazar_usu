import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class SellerOrdersPage extends StatelessWidget {
  const SellerOrdersPage({super.key});

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
  }

  String _sellerStatusLabel(String rawStatus) {
    final s = rawStatus.toLowerCase();
    if (s == 'perlu dibayar' || s == 'baru') return 'Baru';
    if (s == 'akan diterima' || s == 'diproses') return 'Diproses';
    if (s == 'untuk diulas' || s == 'pesanan selesai' || s == 'selesai') {
      return 'Selesai';
    }
    if (s == 'ditolak') return 'Ditolak';
    return rawStatus;
  }

  Color _statusColor(String label) {
    switch (label) {
      case 'Baru':
        return Colors.orange;
      case 'Diproses':
        return Colors.blue;
      case 'Selesai':
        return Colors.green;
      case 'Ditolak':
        return Colors.red;
      default:
        return kDarkGreen;
    }
  }

  Future<void> _updateOrderStatus(
    BuildContext context,
    String docId,
    String firestoreStatus,
    String feedbackText,
  ) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(docId).update({
        'status': firestoreStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(feedbackText), backgroundColor: kDarkGreen),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui pesanan: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  String _buildProductsSummary(Map<String, dynamic> data) {
    final rawItems = data['items'];
    if (rawItems is List && rawItems.isNotEmpty) {
      return rawItems
          .map((e) {
            if (e is Map) {
              final name = (e['name'] ?? e['description'] ?? 'Produk')
                  .toString();
              final qty = e['quantity'] ?? e['qty'] ?? 1;
              return '$name (x$qty)';
            }
            return e.toString();
          })
          .join(', ');
    }
    return (data['produk'] ?? 'Produk Pesanan').toString();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        foregroundColor: kDarkGreen,
        title: const Text(
          'Pesanan Masuk',
          style: TextStyle(color: kDarkGreen, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('orders').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: kDarkGreen),
              );
            }

            final allDocs = snapshot.data?.docs ?? [];
            final myOrders =
                allDocs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>? ?? {};
                  final sellerId = (data['sellerId'] ?? data['tenantId'] ?? '')
                      .toString();
                  return sellerId == uid;
                }).toList()..sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>? ?? {};
                  final bData = b.data() as Map<String, dynamic>? ?? {};
                  final aTime = aData['createdAt'] is Timestamp
                      ? (aData['createdAt'] as Timestamp).toDate()
                      : DateTime(2000);
                  final bTime = bData['createdAt'] is Timestamp
                      ? (bData['createdAt'] as Timestamp).toDate()
                      : DateTime(2000);
                  return bTime.compareTo(aTime);
                });

            if (myOrders.isEmpty) {
              return Center(
                child: Text(
                  'Belum ada pesanan masuk.',
                  style: TextStyle(
                    fontSize: 13,
                    color: kDarkGreen.withValues(alpha: 0.6),
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: myOrders.length,
              itemBuilder: (context, index) {
                final doc = myOrders[index];
                final data = doc.data() as Map<String, dynamic>? ?? {};

                final buyerName =
                    (data['buyerName'] ?? data['pembeli'] ?? 'Pembeli')
                        .toString();
                final buyerAddress = (data['buyerAddress'] ?? '').toString();
                final paymentMethod = (data['paymentMethod'] ?? '').toString();
                final rawStatus = (data['status'] ?? 'Perlu dibayar')
                    .toString();
                final statusLabel = _sellerStatusLabel(rawStatus);
                final statusColor = _statusColor(statusLabel);

                final rawTotal = data['total'] ?? data['totalPrice'] ?? 0;
                final total = rawTotal is int
                    ? rawTotal
                    : int.tryParse(rawTotal.toString()) ?? 0;

                final produkSummary = _buildProductsSummary(data);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: kDarkGreen.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              buyerName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: kDarkGreen,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              statusLabel,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        produkSummary,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                      if (buyerAddress.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Alamat: $buyerAddress',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: kDarkGreen.withValues(alpha: 0.65),
                          ),
                        ),
                      ],
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Rp${_formatPrice(total)}',
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: kDarkGreen,
                            ),
                          ),
                          if (paymentMethod.isNotEmpty)
                            Text(
                              paymentMethod,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: kDarkGreen.withValues(alpha: 0.65),
                              ),
                            ),
                        ],
                      ),
                      if (statusLabel == 'Baru') ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _updateOrderStatus(
                                  context,
                                  doc.id,
                                  'Ditolak',
                                  'Pesanan ditolak',
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text('Tolak'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _updateOrderStatus(
                                  context,
                                  doc.id,
                                  'Akan Diterima',
                                  'Pesanan diterima & sedang diproses',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kDarkGreen,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text('Terima'),
                              ),
                            ),
                          ],
                        ),
                      ] else if (statusLabel == 'Diproses') ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _updateOrderStatus(
                              context,
                              doc.id,
                              'Pesanan Selesai',
                              'Pesanan ditandai selesai',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kDarkGreen,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Tandai Selesai'),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
