import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../services/seller_state.dart';
import 'add_edit_product_page.dart';

class SellerProductsPage extends StatelessWidget {
  const SellerProductsPage({super.key});

  void _openProductForm(
    BuildContext context, {
    SellerProduct? existing,
    String? existingCategory,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditProductPage(
          existing: existing,
          existingCategory: existingCategory,
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String docId, String productName) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Produk'),
        content: Text('Yakin ingin menghapus "$productName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await FirebaseFirestore.instance
                    .collection('products')
                    .doc(docId)
                    .delete();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Produk berhasil dihapus'),
                      backgroundColor: kDarkGreen,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus produk: $e'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
  }

  // Konversi dokumen Firestore menjadi objek SellerProduct agar form Edit tetap kompatibel
  SellerProduct _mapDocToSellerProduct(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final rawPrice = data['price'] ?? data['harga'] ?? 0;
    final price = rawPrice is int
        ? rawPrice
        : int.tryParse(rawPrice.toString()) ?? 0;

    return SellerProduct(
      id: doc.id,
      name: (data['name'] ?? data['nama'] ?? 'Produk').toString(),
      price: price,
      description: (data['description'] ?? data['deskripsi'] ?? '').toString(),
      imagePath:
          (data['imageBase64'] ?? data['imageUrl'] ?? data['imagePath'] ?? '')
              .toString(),
    );
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
          'Kelola Produk',
          style: TextStyle(color: kDarkGreen, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kDarkGreen,
        onPressed: () => _openProductForm(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('products').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: kDarkGreen),
              );
            }

            // Filter produk milik penjual yang sedang login
            final allDocs = snapshot.data?.docs ?? [];
            final myDocs = allDocs.where((doc) {
              final data = doc.data() as Map<String, dynamic>? ?? {};
              final ownerId =
                  data['sellerId'] ?? data['tenantId'] ?? data['uid'] ?? '';
              return ownerId == uid;
            }).toList();

            if (myDocs.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Belum ada produk. Ketuk tombol + untuk menambahkan '
                    'produk pertama toko kamu.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: kDarkGreen.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
              itemCount: myDocs.length,
              itemBuilder: (context, index) {
                final doc = myDocs[index];
                final data = doc.data() as Map<String, dynamic>? ?? {};
                final product = _mapDocToSellerProduct(doc);
                final imageSource =
                    (data['imageBase64'] ??
                            data['imageUrl'] ??
                            data['imagePath'] ??
                            '')
                        .toString();

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: kDarkGreen.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Row(
                    children: [
                      _ProductThumb(imageSource: imageSource),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: kDarkGreen,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Rp${_formatPrice(product.price)}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: kDarkGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _openProductForm(
                          context,
                          existing: product,
                          existingCategory:
                              (data['category'] ?? data['kategori'] ?? '')
                                  .toString(),
                        ),
                        icon: Icon(
                          Icons.edit_outlined,
                          size: 19,
                          color: kDarkGreen.withValues(alpha: 0.7),
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            _confirmDelete(context, doc.id, product.name),
                        icon: const Icon(
                          Icons.delete_outline,
                          size: 19,
                          color: Colors.redAccent,
                        ),
                      ),
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

// ==================== THUMBNAIL FOTO PRODUK ====================
class _ProductThumb extends StatelessWidget {
  final String imageSource;
  const _ProductThumb({required this.imageSource});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: kLightGreen,
        borderRadius: BorderRadius.circular(10),
      ),
      child: _buildImage(),
    );
  }

  Widget _buildImage() {
    if (imageSource.isEmpty) {
      return Icon(
        Icons.image_outlined,
        color: kDarkGreen.withValues(alpha: 0.4),
      );
    }

    // 1. Jika berupa URL internet (Firebase Storage / HTTP)
    if (imageSource.startsWith('http://') ||
        imageSource.startsWith('https://')) {
      return Image.network(
        imageSource,
        width: 52,
        height: 52,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Icon(
          Icons.image_outlined,
          color: kDarkGreen.withValues(alpha: 0.4),
        ),
      );
    }

    // 2. Jika berupa path file lokal (Android/iOS non-Web)
    if (!kIsWeb &&
        (imageSource.startsWith('/') || imageSource.contains(':\\'))) {
      return Image.file(
        File(imageSource),
        width: 52,
        height: 52,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Icon(
          Icons.image_outlined,
          color: kDarkGreen.withValues(alpha: 0.4),
        ),
      );
    }

    // 3. Jika berupa string Base64
    try {
      final cleanBase64 = imageSource.contains(',')
          ? imageSource.split(',').last
          : imageSource;
      final bytes = base64Decode(cleanBase64);
      return Image.memory(
        bytes,
        width: 52,
        height: 52,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Icon(
          Icons.image_outlined,
          color: kDarkGreen.withValues(alpha: 0.4),
        ),
      );
    } catch (_) {
      return Icon(
        Icons.image_outlined,
        color: kDarkGreen.withValues(alpha: 0.4),
      );
    }
  }
}
