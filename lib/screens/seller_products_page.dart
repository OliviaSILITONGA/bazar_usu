import 'dart:io';

import 'package:flutter/material.dart';

import '../constants.dart';
import '../services/seller_state.dart';
import 'add_edit_product_page.dart';

class SellerProductsPage extends StatelessWidget {
  const SellerProductsPage({super.key});

  void _openProductForm(BuildContext context, {SellerProduct? existing}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditProductPage(existing: existing),
      ),
    );
  }

  void _confirmDelete(BuildContext context, SellerProduct product) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Hapus Produk'),
        content: Text('Yakin ingin menghapus "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              SellerAccountState.instance.deleteProduct(product.id);
              Navigator.pop(dialogContext);
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

  @override
  Widget build(BuildContext context) {
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
        child: ValueListenableBuilder<List<SellerProduct>>(
          valueListenable: SellerAccountState.instance.myProducts,
          builder: (context, products, _) {
            if (products.isEmpty) {
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
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
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
                      _ProductThumb(imagePath: product.imagePath),
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
                        onPressed: () =>
                            _openProductForm(context, existing: product),
                        icon: Icon(
                          Icons.edit_outlined,
                          size: 19,
                          color: kDarkGreen.withValues(alpha: 0.7),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _confirmDelete(context, product),
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
  final String? imagePath;
  const _ProductThumb({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final hasImage = imagePath != null && imagePath!.isNotEmpty;
    return Container(
      width: 52,
      height: 52,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: kLightGreen,
        borderRadius: BorderRadius.circular(10),
      ),
      child: hasImage
          ? Image.file(
              File(imagePath!),
              width: 52,
              height: 52,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Icon(
                Icons.image_outlined,
                color: kDarkGreen.withValues(alpha: 0.4),
              ),
            )
          : Icon(
              Icons.image_outlined,
              color: kDarkGreen.withValues(alpha: 0.4),
            ),
    );
  }
}