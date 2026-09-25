import 'package:flutter/material.dart';

import 'chat_list_page.dart';
import 'orders_page.dart';
import 'profile_page.dart';

import '../constants.dart';

class FiturAI extends StatefulWidget {
  const FiturAI({super.key});

  @override
  State<FiturAI> createState() => _FiturAIState();
}

class _FiturAIState extends State<FiturAI> {
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              const _TopBar(),
              const SizedBox(height: 20),
              const _TitleSection(),
              const SizedBox(height: 20),
              _SearchField(controller: _searchController),
              const SizedBox(height: 16),
              const _SearchButton(),
              const SizedBox(height: 28),
              const Text(
                'Atau pilih cepat berdasarkan mood:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: kDarkGreen),
              ),
              const SizedBox(height: 14),
              const _MoodChips(),
              const SizedBox(height: 28),
              const _SectionTitle(title: '💡 Hasil Rekomendasi Pintar'),
              const SizedBox(height: 14),
              const _RecommendationGrid(),
              const SizedBox(height: 16),
              const Text(
                'Cocok dengan kriteria jajanan korea viral\nyang asam manis',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: kDarkGreen, height: 1.4),
              ),
              const SizedBox(height: 90),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const _BottomNavBar(),
    );
  }
}

// ==================== TOP BAR ====================
class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Bazar USU',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: kDarkGreen,
          ),
        ),
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: kDarkGreen,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.smart_toy_outlined,
            color: Colors.white,
            size: 24,
          ),
        ),
      ],
    );
  }
}

// ==================== JUDUL & SUBJUDUL ====================
class _TitleSection extends StatelessWidget {
  const _TitleSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Tanya BABU\n(Bazar Assistant By USU)',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: kDarkGreen,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          '✨ Mau ajan apa hari ini?\nKetik mood, selera, atau kriteria makananmu!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: kDarkGreen.withValues(alpha: 0.85),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

// ==================== KOLOM PENCARIAN ====================
class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  const _SearchField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
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
                hintText: 'jajanan korea viral yang asam manis...',
                hintStyle: TextStyle(
                  color: kDarkGreen.withValues(alpha: 0.5),
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== TOMBOL CARI ====================
class _SearchButton extends StatelessWidget {
  const _SearchButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ElevatedButton.icon(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: kDarkGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        icon: const Icon(Icons.bolt, size: 18),
        label: const Text(
          'Cari dengan BABU',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// ==================== CHIP MOOD ====================
class _MoodChips extends StatelessWidget {
  const _MoodChips();

  static const List<String> _moods = [
    'Pedas 🌶️',
    'Manis kayak kamu >‹',
    'Murah untuk anak kos 💰',
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: _moods.map((m) => _MoodChip(label: m)).toList(),
    );
  }
}

class _MoodChip extends StatelessWidget {
  final String label;
  const _MoodChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: kLightGreen,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kDarkGreen.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 12,
          color: kDarkGreen,
          fontWeight: FontWeight.w500,
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
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: kDarkGreen,
      ),
    );
  }
}

// ==================== HASIL REKOMENDASI ====================
class _RecommendationGrid extends StatelessWidget {
  const _RecommendationGrid();

  static const List<_ProductData> _products = [
    _ProductData(
      name: 'Dinsum Mentai',
      price: 'Rp 15.000',
      seller: 'AIF (Accounting Intelligence Fair)',
      image: 'assets/products/DINSUM.jpg',
    ),
    _ProductData(
      name: 'Taiso (Tahu isi Bakso)',
      price: 'Rp 10.000',
      seller: 'KMK Teknik Kimia',
      image: 'assets/products/TAISO.webp',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: 0.78,
      children: _products.map((p) => _ProductCard(data: p)).toList(),
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
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
