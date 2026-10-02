import 'package:flutter/material.dart';

import '../constants.dart';
import '../services/favorite_products_state.dart';

class FavoriteProductsPage extends StatelessWidget {
  const FavoriteProductsPage({super.key});

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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      'Produk Favorit',
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
              child: ValueListenableBuilder<List<FavoriteProductData>>(
                valueListenable: FavoriteProductsState.instance.products,
                builder: (context, products, _) {
                  if (products.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.favorite_border,
                              size: 48,
                              color: kDarkGreen.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Belum ada produk favorit',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: kDarkGreen.withValues(alpha: 0.7),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Tekan "Favoritkan" di halaman Keranjang untuk menambahkannya ke sini.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: kDarkGreen.withValues(alpha: 0.5),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: products.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Container(
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
                              width: 56,
                              height: 56,
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
                                    product.description,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: kDarkGreen,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    product.storeName,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: kDarkGreen.withValues(alpha: 0.6),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Rp${_formatPrice(product.price)}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => FavoriteProductsState.instance
                                  .remove(product),
                              child: const Icon(
                                Icons.favorite,
                                color: Colors.redAccent,
                                size: 22,
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
          ],
        ),
      ),
    );
  }
}
