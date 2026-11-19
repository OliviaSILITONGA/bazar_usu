import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../services/favorite_stores_state.dart';
import 'chat_detail_page.dart';
import 'product_detail_page.dart';

// ==================== DATA PRODUK TOKO ====================
class StoreProductData {
  final String name;
  final int price;
  final String description;
  final String image;

  const StoreProductData({
    required this.name,
    required this.price,
    this.description = 'Deskripsi produk belum tersedia, silakan tambahkan detail lebih lanjut nanti.',
    this.image = '',
  });
}

// ==================== DATA PROFIL TOKO ====================
class StoreProfileData {
  final String name;
  final String description;
  final double rating;
  final String image;
  final List<StoreProductData> products;

  const StoreProfileData({
    required this.name,
    required this.description,
    required this.rating,
    this.image = '',
    required this.products,
  });
}

const Map<String, StoreProfileData> kStoreProfiles = {
  'Kue Kering Tho': StoreProfileData(
    name: 'Kue Kering Tho',
    description: 'Menjual makanan ringan yang murah dan pastinya Enak',
    rating: 4.8,
    products: [
      StoreProductData(name: 'Donat', price: 4000),
      StoreProductData(name: 'Kue Kering Tiramisu', price: 8000),
      StoreProductData(name: 'Kue Kering Coklat', price: 8000),
    ],
  ),
  'Kedai ciau': StoreProfileData(
    name: 'Kedai ciau',
    description:
        'Menjual makanan berat dengan harga bersahabat untuk mahasiswa.',
    rating: 4.7,
    products: [
      StoreProductData(name: 'Ayam Penyet', price: 15000),
      StoreProductData(name: 'Donat', price: 4000),
    ],
  ),
  'Kedai Kak Wati': StoreProfileData(
    name: 'Kedai Kak Wati',
    description: 'Menyediakan nasi dan minuman segar untuk keseharian kamu.',
    rating: 4.6,
    products: [
      StoreProductData(name: 'Nasi Ayam Penyet', price: 15000),
      StoreProductData(name: 'Teh Manis Dingin', price: 5000),
    ],
  ),
  'Olip Bakery': StoreProfileData(
    name: 'Olip Bakery',
    description: 'Toko kue kering rumahan dengan berbagai varian rasa.',
    rating: 4.8,
    products: [StoreProductData(name: 'Kue Kering', price: 8000)],
  ),
  'FKB': StoreProfileData(
    name: 'FKB',
    description: 'Menjual alat tulis dan perlengkapan kuliah.',
    rating: 4.5,
    products: [StoreProductData(name: 'Alat Tulis', price: 100000)],
  ),
  'Toko Roti': StoreProfileData(
    name: 'Toko Roti',
    description: 'Aneka roti dan donat segar setiap hari.',
    rating: 4.6,
    products: [StoreProductData(name: 'Donat Coklat', price: 3000)],
  ),
  'KFC': StoreProfileData(
    name: 'KFC',
    description: 'Gerai ayam goreng favorit di sekitar kampus.',
    rating: 4.7,
    products: [],
  ),
  'Ko yana': StoreProfileData(
    name: 'Ko yana',
    description: 'Menjual jajanan dan minuman kekinian.',
    rating: 4.6,
    products: [],
  ),
};

StoreProfileData resolveStoreProfile(String storeName) {
  return kStoreProfiles[storeName] ??
      StoreProfileData(
        name: storeName,
        description: 'Toko ini belum menambahkan deskripsi.',
        rating: 4.8,
        products: const [],
      );
}

typedef StoreProductList = List<StoreProductData>;

class StoreDetailPage extends StatefulWidget {
  final String storeName;
  const StoreDetailPage({super.key, required this.storeName});

  @override
  State<StoreDetailPage> createState() => _StoreDetailPageState();
}

class _StoreDetailPageState extends State<StoreDetailPage> {
  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
  }

  Stream<StoreProfileData> _storeProfileStream() {
    final fallback = resolveStoreProfile(widget.storeName);
    final targetLower = widget.storeName.trim().toLowerCase();

    return FirebaseFirestore.instance.collection('tenants').snapshots().map((
      snapshot,
    ) {
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final namaToko = (data['namaToko'] ?? data['storeName'] ?? '')
            .toString()
            .trim();
        if (namaToko.toLowerCase() == targetLower) {
          final desc = (data['deskripsi'] ?? data['description'] ?? '')
              .toString()
              .trim();
          final rawRating = data['rating'] ?? 4.8;
          final rating = rawRating is num ? rawRating.toDouble() : 4.8;
          final foto = (data['fotoBase64'] ?? data['imageUrl'] ?? '')
              .toString();

          return StoreProfileData(
            name: namaToko,
            description: desc.isNotEmpty
                ? desc
                : 'Selamat datang di $namaToko! Temukan berbagai pilihan terbaik kami.',
            rating: rating,
            image: foto,
            products: fallback.products,
          );
        }
      }
      return fallback;
    });
  }

  Stream<StoreProductList> _storeProductsStream() {
    final fallbackProducts = resolveStoreProfile(widget.storeName).products;
    final targetLower = widget.storeName.trim().toLowerCase();

    return FirebaseFirestore.instance.collection('products').snapshots().map((
      snapshot,
    ) {
      final dbProducts = snapshot.docs
          .where((doc) {
            final data = doc.data();
            final seller = (data['namaToko'] ?? data['seller'] ?? '')
                .toString()
                .trim();
            return seller.toLowerCase() == targetLower;
          })
          .map((doc) {
            final data = doc.data();
            final rawPrice = data['price'] ?? data['harga'] ?? 0;
            final price = rawPrice is int
                ? rawPrice
                : int.tryParse(rawPrice.toString()) ?? 0;
            final imgBase64 = (data['imageBase64'] ?? '').toString();
            final imgUrl =
                (data['imageUrl'] ?? data['imagePath'] ?? data['image'] ?? '')
                    .toString();

            return StoreProductData(
              name: (data['name'] ?? data['nama'] ?? 'Produk').toString(),
              price: price,
              description: (data['description'] ?? data['deskripsi'] ?? '')
                  .toString(),
              image: imgBase64.isNotEmpty ? imgBase64 : imgUrl,
            );
          })
          .toList();

      if (dbProducts.isEmpty) return fallbackProducts;
      return [...dbProducts, ...fallbackProducts];
    });
  }

  @override
  Widget build(BuildContext context) {
    final fallbackProfile = resolveStoreProfile(widget.storeName);

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: StreamBuilder<StoreProfileData>(
          stream: _storeProfileStream(),
          builder: (context, profileSnap) {
            final profile = profileSnap.data ?? fallbackProfile;

            return StreamBuilder<StoreProductList>(
              stream: _storeProductsStream(),
              builder: (context, productSnap) {
                final products = productSnap.data ?? profile.products;

                return SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _TopBar(title: 'Detail Toko'),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                        child: ValueListenableBuilder<StoreNameSet>(
                          valueListenable:
                              FavoriteStoresState.instance.favorites,
                          builder: (context, favSet, _) {
                            final liked = favSet.contains(profile.name);
                            return _StoreHeaderCard(
                              profile: profile,
                              productCount: products.length,
                              liked: liked,
                              onLikeTap: () => FavoriteStoresState.instance
                                  .toggle(profile.name),
                              onChatTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChatDetailPage(
                                      contactName: profile.name,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Detail Produk',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: kDarkGreen,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: products.isEmpty
                            ? const _EmptyProducts()
                            : Column(
                                children: products
                                    .map(
                                      (p) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        child: _StoreProductTile(
                                          storeName: profile.name,
                                          rating: profile.rating,
                                          product: p,
                                          formatPrice: _formatPrice,
                                        ),
                                      ),
                                    )
                                    .toList(),
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

// ==================== TOP BAR ====================
class _TopBar extends StatelessWidget {
  final String title;
  const _TopBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            color: kDarkGreen,
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: kDarkGreen,
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

// ==================== HEADER TOKO ====================
class _StoreHeaderCard extends StatelessWidget {
  final StoreProfileData profile;
  final int productCount;
  final bool liked;
  final VoidCallback onLikeTap;
  final VoidCallback onChatTap;

  const _StoreHeaderCard({
    required this.profile,
    required this.productCount,
    required this.liked,
    required this.onLikeTap,
    required this.onChatTap,
  });

  Widget _buildStoreLogo(String imageSource) {
    if (imageSource.isEmpty) {
      return Icon(
        Icons.storefront_outlined,
        color: kDarkGreen.withValues(alpha: 0.7),
        size: 30,
      );
    }
    if (imageSource.startsWith('http://') ||
        imageSource.startsWith('https://')) {
      return Image.network(
        imageSource,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Icon(
          Icons.storefront_outlined,
          color: kDarkGreen.withValues(alpha: 0.7),
          size: 30,
        ),
      );
    }
    try {
      final cleanBase64 = imageSource.contains(',')
          ? imageSource.split(',').last
          : imageSource;
      return Image.memory(
        base64Decode(cleanBase64),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Icon(
          Icons.storefront_outlined,
          color: kDarkGreen.withValues(alpha: 0.7),
          size: 30,
        ),
      );
    } catch (_) {
      return Icon(
        Icons.storefront_outlined,
        color: kDarkGreen.withValues(alpha: 0.7),
        size: 30,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: kDarkGreen.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kLightGreen,
                  border: Border.all(color: kDarkGreen.withValues(alpha: 0.3)),
                ),
                child: _buildStoreLogo(profile.image),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: onLikeTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: liked ? Colors.redAccent : Colors.white,
                        border: Border.all(color: Colors.redAccent),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        liked ? 'Diikuti' : 'Ikuti',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: liked ? Colors.white : Colors.redAccent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: onChatTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: kDarkGreen.withValues(alpha: 0.5),
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Pesan',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: kDarkGreen,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            profile.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kDarkGreen,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.star, size: 15, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                profile.rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 6),
              const Text('|', style: TextStyle(color: Colors.black38)),
              const SizedBox(width: 6),
              Text(
                '$productCount Produk',
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            profile.description,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== ITEM PRODUK TOKO ====================
class _StoreProductTile extends StatelessWidget {
  final String storeName;
  final double rating;
  final StoreProductData product;
  final String Function(int) formatPrice;

  const _StoreProductTile({
    required this.storeName,
    required this.rating,
    required this.product,
    required this.formatPrice,
  });

  Widget _buildProductThumb(String imageSource) {
    if (imageSource.isEmpty) {
      return Icon(
        Icons.image_outlined,
        color: kDarkGreen.withValues(alpha: 0.4),
        size: 24,
      );
    }
    if (imageSource.startsWith('assets/')) {
      return Image.asset(
        imageSource,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Icon(
          Icons.image_outlined,
          color: kDarkGreen.withValues(alpha: 0.4),
          size: 24,
        ),
      );
    }
    if (imageSource.startsWith('http://') ||
        imageSource.startsWith('https://')) {
      return Image.network(
        imageSource,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Icon(
          Icons.image_outlined,
          color: kDarkGreen.withValues(alpha: 0.4),
          size: 24,
        ),
      );
    }
    try {
      final cleanBase64 = imageSource.contains(',')
          ? imageSource.split(',').last
          : imageSource;
      return Image.memory(
        base64Decode(cleanBase64),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Icon(
          Icons.image_outlined,
          color: kDarkGreen.withValues(alpha: 0.4),
          size: 24,
        ),
      );
    } catch (_) {
      return Icon(
        Icons.image_outlined,
        color: kDarkGreen.withValues(alpha: 0.4),
        size: 24,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(
              name: product.name,
              storeName: storeName,
              originalPrice: product.price,
              discountPrice: product.price,
              rating: rating == 0 ? 4.5 : rating,
              reviewCount: 0,
              prepTime: '15-20 min',
              kcal: 250,
              description: product.description.isNotEmpty
                  ? product.description
                  : 'Deskripsi produk belum tersedia, silakan tambahkan detail lebih lanjut nanti.',
              image: product.image,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kDarkGreen.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: kLightGreen,
                borderRadius: BorderRadius.circular(10),
              ),
              child: _buildProductThumb(product.image),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                product.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kDarkGreen,
                ),
              ),
            ),
            Text(
              'Rp${formatPrice(product.price)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: kDarkGreen,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              color: kDarkGreen.withValues(alpha: 0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== STATE KOSONG ====================
class _EmptyProducts extends StatelessWidget {
  const _EmptyProducts();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kDarkGreen.withValues(alpha: 0.12)),
      ),
      alignment: Alignment.center,
      child: Text(
        'Toko ini belum menambahkan produk.',
        style: TextStyle(
          fontSize: 13,
          color: kDarkGreen.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}
