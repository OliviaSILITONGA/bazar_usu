import 'package:flutter/material.dart';

import '../constants.dart';
import 'product_detail_page.dart';

// ==================== DATA PRODUK TOKO ====================
class StoreProductData {
  final String name;
  final int price;
  final String description;

  const StoreProductData({
    required this.name,
    required this.price,
    this.description = 'Deskripsi produk belum tersedia, silakan tambahkan detail lebih lanjut nanti.',
  });
}

// ==================== DATA PROFIL TOKO ====================
class StoreProfileData {
  final String name;
  final String description;
  final double rating;
  final List<StoreProductData> products;

  const StoreProfileData({
    required this.name,
    required this.description,
    required this.rating,
    required this.products,
  });
}

// Data toko sementara (hardcode), disesuaikan dengan nama-nama toko yang
// sudah dipakai di Home Page User. Ganti dengan data dari backend nanti.
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
        rating: 0,
        products: const [],
      );
}

class StoreDetailPage extends StatefulWidget {
  final String storeName;
  const StoreDetailPage({super.key, required this.storeName});

  @override
  State<StoreDetailPage> createState() => _StoreDetailPageState();
}

class _StoreDetailPageState extends State<StoreDetailPage> {
  bool _liked = false;

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = resolveStoreProfile(widget.storeName);

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _TopBar(title: 'Detail Toko'),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: _StoreHeaderCard(
                  profile: profile,
                  liked: _liked,
                  onLikeTap: () => setState(() => _liked = !_liked),
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
                child: profile.products.isEmpty
                    ? const _EmptyProducts()
                    : Column(
                        children: profile.products
                            .map(
                              (p) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
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
          const SizedBox(width: 40), // seimbangkan lebar tombol back
        ],
      ),
    );
  }
}

// ==================== HEADER TOKO ====================
class _StoreHeaderCard extends StatelessWidget {
  final StoreProfileData profile;
  final bool liked;
  final VoidCallback onLikeTap;

  const _StoreHeaderCard({
    required this.profile,
    required this.liked,
    required this.onLikeTap,
  });

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
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kLightGreen,
                  border: Border.all(color: kDarkGreen.withValues(alpha: 0.3)),
                ),
                child: Icon(
                  Icons.storefront_outlined,
                  color: kDarkGreen.withValues(alpha: 0.7),
                  size: 30,
                ),
                // Ganti dengan Image.asset/Image.network logo toko asli.
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
                        'Ikuti',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: liked ? Colors.white : Colors.redAccent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
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
                '${profile.products.length} Produk',
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
              description: product.description,
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
              decoration: BoxDecoration(
                color: kLightGreen,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.image_outlined,
                color: kDarkGreen.withValues(alpha: 0.4),
                size: 24,
              ),
              // Ganti dengan Image.asset/Image.network foto produk asli.
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

// ==================== STATE KOSONG (BELUM ADA PRODUK) ====================
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
