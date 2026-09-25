import 'package:flutter/material.dart';

import '../constants.dart';
import 'fitur_AI.dart';
import 'chat_list_page.dart';
import 'orders_page.dart';
import 'profile_page.dart';
import 'notification_page.dart';
import 'cart_page.dart';
import 'product_detail_page.dart';
import 'store_detail_page.dart';

class HomePageUser extends StatefulWidget {
  const HomePageUser({super.key});

  @override
  State<HomePageUser> createState() => _HomePageUserState();
}

class _HomePageUserState extends State<HomePageUser> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  _SearchBar(controller: _searchController),
                  const SizedBox(height: 20),
                  const _CategoryRow(),
                  const SizedBox(height: 20),
                  const _PromoBanner(),
                  const SizedBox(height: 24),
                  const _SectionTitle(title: 'Produk Favorite'),
                  const SizedBox(height: 12),
                  const _FavoriteGrid(),
                  const SizedBox(height: 24),
                  const _SectionTitle(title: 'Bazar Favorit'),
                  const SizedBox(height: 14),
                  const _PopularStoresRow(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 80,
            child: _AIButton(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FiturAI()),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const _BottomNavBar(),
    );
  }
}

// ==================== SEARCH BAR ====================
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    const int cartCount = 2;
    const int notifCount = 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                border: Border.all(color: kDarkGreen.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: kDarkGreen.withValues(alpha: 0.7)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      style: const TextStyle(fontSize: 14, color: kDarkGreen),
                      decoration: InputDecoration(
                        isDense: true,
                        border: InputBorder.none,
                        hintText: 'Mau Makan Apa Hari Ini?',
                        hintStyle: TextStyle(
                          color: kDarkGreen.withValues(alpha: 0.5),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 14),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => NotificationPage()),
              );
            },
            child: _IconWithBadge(
              icon: Icons.notifications_none,
              count: notifCount,
            ),
          ),
          const SizedBox(width: 14),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CartPage()),
              );
            },
            child: _IconWithBadge(
              icon: Icons.shopping_cart_outlined,
              count: cartCount,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconWithBadge extends StatelessWidget {
  final IconData icon;
  final int count;

  const _IconWithBadge({required this.icon, required this.count});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon, color: kDarkGreen, size: 26),
        if (count > 0)
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              constraints: const BoxConstraints(minWidth: 17),
              decoration: const BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$count',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ==================== KATEGORI ====================
class _CategoryRow extends StatelessWidget {
  const _CategoryRow();

  static const List<_CategoryData> _categories = [
    _CategoryData(icon: Icons.set_meal_outlined, label: 'Makanan'),
    _CategoryData(icon: Icons.local_drink_outlined, label: 'Minuman'),
    _CategoryData(icon: Icons.cookie_outlined, label: 'Jajanan'),
    _CategoryData(icon: Icons.inventory_2_outlined, label: 'Lainnya...'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _categories.map((c) => _CategoryItem(data: c)).toList(),
      ),
    );
  }
}

class _CategoryData {
  final IconData icon;
  final String label;
  const _CategoryData({required this.icon, required this.label});
}

class _CategoryItem extends StatelessWidget {
  final _CategoryData data;
  const _CategoryItem({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: kLightGreen,
            border: Border.all(color: kDarkGreen.withValues(alpha: 0.3)),
          ),
          child: Icon(data.icon, color: kDarkGreen, size: 26),
        ),
        const SizedBox(height: 6),
        Text(
          data.label,
          style: const TextStyle(fontSize: 12, color: kDarkGreen),
        ),
      ],
    );
  }
}

// ==================== BANNER PROMO ====================
class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: const [
          _PromoCard(
            title: 'Nasi Ayam Penyet',
            price: 'Rp 15.000',
            seller: 'Kedai Kak Wati',
            image: 'assets/products/nasi_ayam_penyet.png',
          ),
          SizedBox(width: 12),
          _PromoCard(
            title: 'Donat Coklat',
            price: 'Rp 3.000',
            seller: 'Toko Roti',
            image: 'assets/products/donat_coklat.png',
          ),
        ],
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  final String title;
  final String price;
  final String seller;
  final String image;
  const _PromoCard({
    required this.title,
    required this.price,
    required this.seller,
    required this.image,
  });

  int _priceToInt(String priceText) {
    return int.tryParse(priceText.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: kDarkGreen.withValues(alpha: 0.6),
        image: DecorationImage(
          image: AssetImage(image),
          fit: BoxFit.cover,
          onError: (_, __) {},
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0),
              Colors.black.withValues(alpha: 0.55),
            ],
          ),
        ),
        padding: const EdgeInsets.all(14),
        alignment: Alignment.bottomLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            Text(
              price,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StoreDetailPage(storeName: seller),
                  ),
                );
              },
              child: Text(
                seller,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 12,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailPage(
                      name: title,
                      storeName: seller,
                      originalPrice: _priceToInt(price),
                      discountPrice: _priceToInt(price),
                      rating: 4.7,
                      reviewCount: 120,
                      prepTime: '15-20 min',
                      kcal: 250,
                      description: 'Deskripsi produk belum tersedia, silakan tambahkan detail lebih lanjut nanti.',
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: kLightGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Lihat Detail',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: kDarkGreen,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== JUDUL SECTION ====================
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: kDarkGreen,
        ),
      ),
    );
  }
}

// ==================== GRID PRODUK FAVORIT ====================
class _FavoriteGrid extends StatelessWidget {
  const _FavoriteGrid();

  static const List<_ProductData> _products = [
    _ProductData(
      name: 'Ayam Penyet',
      price: 'Rp 15.000',
      seller: 'Kedai ciau',
      image: 'assets/products/nasi_ayam_penyet.png',
    ),
    _ProductData(
      name: 'Teh Manis Dingin',
      price: 'Rp 5.000',
      seller: 'Kedai Kak Wati',
      image: 'assets/products/teh_manis_dingin.png',
    ),
    _ProductData(
      name: 'Donat',
      price: 'Rp 4.000',
      seller: 'Kedai ciau',
      image: 'assets/products/donat_coklat.png',
    ),
    _ProductData(
      name: 'Kue Kering',
      price: 'Rp 8.000',
      seller: 'Olip Bakery',
      image: 'assets/products/kue_kering.png',
    ),
    _ProductData(
      name: 'Alat Tulis',
      price: 'Rp 10.000',
      seller: 'FKB',
      image: 'assets/products/alat_tulis.jfif',
    ),
    _ProductData(
      name: 'Kue Kering',
      price: 'Rp 8.000',
      seller: 'Olip Bakery,',
      image: 'assets/products/kue_kering.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.78,
        children: _products.map((p) => _ProductCard(data: p)).toList(),
      ),
    );
  }
}

class _ProductData {
  final String name;
  final String price;
  final String seller;
  final String image;
  const _ProductData({
    required this.name,
    required this.price,
    required this.seller,
    required this.image,
  });
}

class _ProductCard extends StatelessWidget {
  final _ProductData data;
  const _ProductCard({required this.data});

  int _priceToInt(String priceText) {
    return int.tryParse(priceText.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(
              name: data.name,
              storeName: data.seller,
              originalPrice: _priceToInt(data.price),
              discountPrice: _priceToInt(data.price),
              rating: 4.7,
              reviewCount: 120,
              prepTime: '15-20 min',
              kcal: 250,
              description: 'Deskripsi produk belum tersedia, silakan tambahkan detail lebih lanjut nanti.',
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kDarkGreen.withValues(alpha: 0.15)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Image.asset(
                data.image,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: double.infinity,
                  color: kLightGreen,
                  child: Icon(
                    Icons.image_outlined,
                    color: kDarkGreen.withValues(alpha: 0.4),
                    size: 32,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: kDarkGreen,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        data.price,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: kDarkGreen,
                        ),
                      ),
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: kLightGreen,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: kDarkGreen.withValues(alpha: 0.4),
                          ),
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 16,
                          color: kDarkGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              StoreDetailPage(storeName: data.seller),
                        ),
                      );
                    },
                    child: Text(
                      data.seller,
                      style: TextStyle(
                        fontSize: 11,
                        color: kDarkGreen.withValues(alpha: 0.7),
                        decoration: TextDecoration.underline,
                        decorationColor: kDarkGreen.withValues(alpha: 0.35),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== TOMBOL AI BULAT ====================
class _AIButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AIButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: kDarkGreen,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(
          Icons.smart_toy_outlined,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}

// ==================== BAZAR FAVORIT (TOKO POPULER) ====================
class _PopularStoresRow extends StatelessWidget {
  const _PopularStoresRow();

  static const List<_StoreData> _stores = [
    _StoreData(name: 'Kue Kering Tho', image: 'assets/products/kue_kering.png'),
    _StoreData(name: 'KFC', image: 'assets/products/kfc.png'),
    _StoreData(name: 'Ko yana', image: 'assets/products/donat_coklat.png'),
    _StoreData(name: 'SILI TONGA', image: 'assets/images/AI_HOSHINO.jpg'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _stores.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) => _StoreAvatar(data: _stores[index]),
      ),
    );
  }
}

class _StoreData {
  final String name;
  final String image;
  const _StoreData({required this.name, required this.image});
}

class _StoreAvatar extends StatelessWidget {
  final _StoreData data;
  const _StoreAvatar({required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StoreDetailPage(storeName: data.name),
          ),
        );
      },
      child: SizedBox(
        width: 68,
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kLightGreen,
                border: Border.all(color: kDarkGreen.withValues(alpha: 0.3)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                data.image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.storefront_outlined,
                  color: kDarkGreen.withValues(alpha: 0.6),
                  size: 26,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              data.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: kDarkGreen),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== BOTTOM NAV BAR ====================
class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: kDarkGreen.withValues(alpha: 0.15)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(Icons.home, color: kDarkGreen, size: 26),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OrdersPage()),
                );
              },
              child: Icon(
                Icons.receipt_long_outlined,
                color: kDarkGreen.withValues(alpha: 0.5),
                size: 24,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ChatListPage()),
                );
              },
              child: Icon(
                Icons.chat_bubble_outline,
                color: kDarkGreen.withValues(alpha: 0.5),
                size: 24,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                );
              },
              child: Icon(
                Icons.person_outline,
                color: kDarkGreen.withValues(alpha: 0.5),
                size: 26,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
