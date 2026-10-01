import 'package:flutter/material.dart';

import '../constants.dart';
import '../services/seller_state.dart';

class SellerProductsPage extends StatelessWidget {
  const SellerProductsPage({super.key});

  Future<void> _openProductForm(
    BuildContext context, {
    SellerProduct? existing,
  }) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final priceController = TextEditingController(
      text: existing != null ? existing.price.toString() : '',
    );
    final descController = TextEditingController(
      text: existing?.description ?? '',
    );

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                existing == null ? 'Tambah Produk' : 'Edit Produk',
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: kDarkGreen,
                ),
              ),
              const SizedBox(height: 18),
              _Label('Nama Produk'),
              const SizedBox(height: 6),
              TextField(
                controller: nameController,
                decoration: _decoration('Contoh: Donat'),
              ),
              const SizedBox(height: 14),
              _Label('Harga (Rp)'),
              const SizedBox(height: 6),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: _decoration('Contoh: 4000'),
              ),
              const SizedBox(height: 14),
              _Label('Deskripsi (opsional)'),
              const SizedBox(height: 6),
              TextField(
                controller: descController,
                maxLines: 3,
                decoration: _decoration('Deskripsi singkat produk...'),
              ),
              const SizedBox(height: 22),
              SizedBox(
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    final price =
                        int.tryParse(priceController.text.trim()) ?? 0;
                    if (name.isEmpty || price <= 0) {
                      ScaffoldMessenger.of(sheetContext).showSnackBar(
                        const SnackBar(
                          content: Text('Nama dan harga produk wajib diisi'),
                        ),
                      );
                      return;
                    }
                    if (existing == null) {
                      SellerAccountState.instance.addProduct(
                        name: name,
                        price: price,
                        description: descController.text.trim(),
                      );
                    } else {
                      SellerAccountState.instance.updateProduct(
                        SellerProduct(
                          id: existing.id,
                          name: name,
                          price: price,
                          description: descController.text.trim(),
                        ),
                      );
                    }
                    Navigator.pop(sheetContext);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kDarkGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: Text(
                    existing == null ? 'Tambah' : 'Simpan Perubahan',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: kLightGreen,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.image_outlined,
                          color: kDarkGreen.withValues(alpha: 0.4),
                        ),
                      ),
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

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: kDarkGreen.withValues(alpha: 0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: kDarkGreen, width: 2),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: kDarkGreen,
      ),
    );
  }
}