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
  bool _isSearching = false;
  bool _hasSearched = false;
  List<_ProductData> _results = [];
  String _lastQuery = '';

  // ==================== DATASET SIMULASI ====================
  static const List<_ProductData> _allProducts = [
    _ProductData(
      name: 'Dinsum Mentai',
      price: 'Rp 15.000',
      seller: 'AIF (Accounting Intelligence Fair)',
      image: 'assets/products/DINSUM.jpg',
      keywords: ['korea', 'viral', 'asam', 'manis', 'pedas'],
    ),
    _ProductData(
      name: 'Taiso (Tahu isi Bakso)',
      price: 'Rp 10.000',
      seller: 'KMK Teknik Kimia',
      image: 'assets/products/TAISO.webp',
      keywords: ['murah', 'anak kos', 'gurih', 'asin'],
    ),
    _ProductData(
      name: 'Ayam Geprek Mozzarella',
      price: 'Rp 18.000',
      seller: 'Geprek Juara',
      image: 'assets/products/ayam_penyet.png',
      keywords: ['pedas', 'nampol', 'ayam', 'keju'],
    ),
    _ProductData(
      name: 'Teh Manis Dingin',
      price: 'Rp 5.000',
      seller: 'Kedai Kak Wati',
      image: 'assets/products/teh_manis_dingin.png',
      keywords: ['manis', 'dingin', 'murah', 'anak kos', 'minuman'],
    ),
    _ProductData(
      name: 'Donat Coklat',
      price: 'Rp 3.000',
      seller: 'Toko Roti',
      image: 'assets/products/donat_coklat.png',
      keywords: ['manis', 'murah', 'anak kos', 'coklat', 'jajanan'],
    ),
    _ProductData(
      name: 'Kue Kering',
      price: 'Rp 8.000',
      seller: 'Olip Bakery',
      image: 'assets/products/kue_kering.png',
      keywords: ['manis', 'renyah', 'jajanan'],
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ==================== LOGIKA PENCARIAN (SIMULASI AI) ====================
  Future<void> _runSearch(String query) async {
    if (query.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ketik dulu mood atau kriteria makananmu!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isSearching = true;
      _hasSearched = false;
    });

    // Simulasi delay "BABU sedang berpikir" supaya terasa seperti AI
    await Future.delayed(const Duration(milliseconds: 700));

    final queryWords = query
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '') // buang emoji/simbol
        .split(' ')
        .where((w) => w.trim().isNotEmpty)
        .toList();

    final matched = _allProducts.where((product) {
      final productText =
          ('${product.name} ${product.seller} ${product.keywords.join(' ')}')
              .toLowerCase();
      return queryWords.any((word) => productText.contains(word));
    }).toList();

    setState(() {
      _results = matched;
      _isSearching = false;
      _hasSearched = true;
      _lastQuery = query;
    });
  }

  void _selectMood(String moodQuery) {
    _searchController.text = moodQuery;
    _runSearch(moodQuery);
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
              _SearchField(
                controller: _searchController,
                onSubmitted: _runSearch,
              ),
              const SizedBox(height: 16),
              _SearchButton(
                onPressed: () => _runSearch(_searchController.text),
              ),
              const SizedBox(height: 28),
              const Text(
                'Atau pilih cepat berdasarkan mood:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: kDarkGreen),
              ),
              const SizedBox(height: 14),
              _MoodChips(onSelected: _selectMood),
              const SizedBox(height: 28),

              // ==================== AREA HASIL ====================
              if (_isSearching) ...[
                const _LoadingState(),
              ] else if (_hasSearched) ...[
                _SectionTitle(
                  title: _results.isEmpty
                      ? '😢 Tidak Ditemukan'
                      : '💡 Hasil Rekomendasi Pintar',
                ),
                const SizedBox(height: 14),
                if (_results.isEmpty)
                  _EmptyResultState(query: _lastQuery)
                else
                  _RecommendationGrid(products: _results),
                const SizedBox(height: 16),
                if (_results.isNotEmpty)
                  Text(
                    'Cocok dengan kriteria "$_lastQuery"',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: kDarkGreen,
                      height: 1.4,
                    ),
                  ),
              ] else ...[
                const _SectionTitle(title: '💡 Rekomendasi Untukmu'),
                const SizedBox(height: 14),
                _RecommendationGrid(products: _allProducts.take(2).toList()),
                const SizedBox(height: 16),
                Text(
                  'Ketik mood atau kriteria untuk mencari lebih spesifik ✨',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: kDarkGreen.withValues(alpha: 0.7),
                    height: 1.4,
                  ),
                ),
              ],
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
        Image.asset(
          'assets/icon/icon.png',
          height: 50,
          errorBuilder: (_, __, ___) => const Text(
            'Bazar USU',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kDarkGreen,
            ),
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
  final ValueChanged<String> onSubmitted;
  const _SearchField({required this.controller, required this.onSubmitted});

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
              textInputAction: TextInputAction.search,
              onSubmitted: onSubmitted,
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
  final VoidCallback onPressed;
  const _SearchButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ElevatedButton.icon(
        onPressed: onPressed,
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
  final ValueChanged<String> onSelected;
  const _MoodChips({required this.onSelected});

  static const Map<String, String> _moods = {
    'Pedas 🌶️': 'pedas',
    'Manis kayak kamu >‹': 'manis',
    'Murah untuk anak kos 💰': 'murah anak kos',
  };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      children: _moods.entries
          .map((e) => _MoodChip(label: e.key, onTap: () => onSelected(e.value)))
          .toList(),
    );
  }
}

class _MoodChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _MoodChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
      ),
    );
  }
}

// ==================== STATE LOADING ====================
class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 3, color: kDarkGreen),
          ),
          const SizedBox(height: 14),
          Text(
            'BABU sedang mencari rekomendasi...',
            style: TextStyle(
              fontSize: 13,
              color: kDarkGreen.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== STATE TIDAK DITEMUKAN ====================
class _EmptyResultState extends StatelessWidget {
  final String query;
  const _EmptyResultState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 40,
            color: kDarkGreen.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 10),
          Text(
            'Belum ada jajanan yang cocok dengan "$query"',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: kDarkGreen.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Coba kata kunci lain, misal "pedas" atau "murah"',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: kDarkGreen.withValues(alpha: 0.5),
            ),
          ),
        ],
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
  final List<_ProductData> products;
  const _RecommendationGrid({required this.products});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: 0.78,
      children: products.map((p) => _ProductCard(data: p)).toList(),
    );
  }
}

class _ProductData {
  final String name;
  final String price;
  final String seller;
  final String image;
  final List<String> keywords;
  const _ProductData({
    required this.name,
    required this.price,
    required this.seller,
    required this.image,
    required this.keywords,
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
