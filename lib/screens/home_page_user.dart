import 'package:flutter/material.dart';

import 'fitur_AI.dart'; // sesuaikan path kalau file ini di folder berbeda

const kDarkGreen = Color(0xFF3E5C3A);
const kLightGreen = Color(0xFFE8F0DE);
const kBg = Color(0xFFF3F8ED);

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
                  const SizedBox(height: 100), // ruang untuk bottom nav
                ],
              ),
            ),
          ),
          // Tombol bulat AI di pojok kanan bawah
          Positioned(
            right: 16,
            bottom: 80, // di atas bottom nav bar
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
          const SizedBox(width: 12),
          Icon(Icons.shopping_cart_outlined, color: kDarkGreen, size: 26),
        ],
      ),
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
          ),
          SizedBox(width: 12),
          _PromoCard(
            title: 'Donat Coklat',
            price: 'Rp 3.000',
            seller: 'Toko Roti',
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

  const _PromoCard({
    required this.title,
    required this.price,
    required this.seller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: kDarkGreen.withValues(alpha: 0.6),
        // Kalau sudah punya gambar produk, tambahkan:
        // image: const DecorationImage(image: AssetImage('assets/images/xxx.jpg'), fit: BoxFit.cover),
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
            Text(
              seller,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
    _ProductData(name: 'Ayam Penyet', price: 'Rp 15.000', seller: 'Kedai ciau'),
    _ProductData(
      name: 'Teh Manis Dingin',
      price: 'Rp 5.000',
      seller: 'Kedai Kak Wati',
    ),
    _ProductData(
      name: 'Donat Aneka Rasa',
      price: 'Rp 3.000',
      seller: 'Toko Roti',
    ),
    _ProductData(
      name: 'Cookies Coklat',
      price: 'Rp 4.000',
      seller: 'Kedai Snack',
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
  const _ProductData({
    required this.name,
    required this.price,
    required this.seller,
  });
}

class _ProductCard extends StatelessWidget {
  final _ProductData data;
  const _ProductCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            child: Container(
              width: double.infinity,
              color: kLightGreen,
              child: Icon(
                Icons.image_outlined,
                color: kDarkGreen.withValues(alpha: 0.4),
                size: 32,
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
                      child: const Icon(Icons.add, size: 16, color: kDarkGreen),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  data.seller,
                  style: TextStyle(
                    fontSize: 11,
                    color: kDarkGreen.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
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
            Icon(
              Icons.receipt_long_outlined,
              color: kDarkGreen.withValues(alpha: 0.5),
              size: 24,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChatListPage()),
                );
              },
              child: Icon(
                Icons.chat_bubble_outline,
                color: kDarkGreen.withValues(alpha: 0.5),
                size: 24,
              ),
            ),
            Icon(
              Icons.person_outline,
              color: kDarkGreen.withValues(alpha: 0.5),
              size: 26,
            ),
          ],
        ),
      ),
    );
  }
}
