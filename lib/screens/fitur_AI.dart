import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../constants.dart';
import '../services/babu_ai_service.dart';
import '../services/cart_state.dart';

class FiturAI extends StatefulWidget {
  const FiturAI({super.key});

  @override
  State<FiturAI> createState() => _FiturAIState();
}

class _FiturAIState extends State<FiturAI> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _hasSearched = false;
  bool _isLoadingInitial = true;
  bool _usedGeminiApi = false;

  List<BabuProductItem> _initialRecommendations = [];
  List<BabuProductItem> _results = [];
  String _lastQuery = '';
  String _aiSummary = '';

  @override
  void initState() {
    super.initState();
    _loadInitialRecommendations();
  }

  Future<void> _loadInitialRecommendations() async {
    try {
      final recs = await BabuAiService.instance
          .getPersonalizedInitialRecommendations();
      if (!mounted) return;
      setState(() {
        _initialRecommendations = recs;
        _isLoadingInitial = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingInitial = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ==================== LOGIKA PENCARIAN AI BABU ====================
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

    FocusScope.of(context).unfocus();

    setState(() {
      _isSearching = true;
      _hasSearched = false;
    });

    final response = await BabuAiService.instance.searchWithBabu(query);
    if (!mounted) return;

    setState(() {
      _results = response.products;
      _aiSummary = response.summary;
      _usedGeminiApi = response.usedGeminiApi;
      _isSearching = false;
      _hasSearched = true;
      _lastQuery = query.trim();
    });
  }

  void _selectMood(String moodQuery) {
    _searchController.text = moodQuery;
    _runSearch(moodQuery);
  }

  void _handleAddToCart(BabuProductItem product) {
    CartState.instance.addItem(
      storeName: product.sellerName,
      description: product.name,
      price: product.price,
      image: product.image.isEmpty ? null : product.image,
    );

    BabuAiService.instance.logInteraction(
      actionType: 'add_to_cart',
      query: _lastQuery,
      product: product,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} ditambahkan ke keranjang!'),
        backgroundColor: kDarkGreen,
        duration: const Duration(seconds: 2),
      ),
    );
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
                Row(
                  children: [
                    Expanded(
                      child: _SectionTitle(
                        title: _results.isEmpty
                            ? '😢 Tidak Ditemukan'
                            : '💡 Hasil Rekomendasi Pintar',
                      ),
                    ),
                    if (_results.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: kLightGreen,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _usedGeminiApi ? 'Gemini AI' : 'BABU Smart',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: kDarkGreen,
                          ),
                        ),
                      ),
                  ],
                ),
                if (_aiSummary.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: kLightGreen.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: kDarkGreen.withValues(alpha: 0.18),
                      ),
                    ),
                    child: Text(
                      _aiSummary,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: kDarkGreen,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                if (_results.isEmpty)
                  _EmptyResultState(query: _lastQuery)
                else
                  _RecommendationGrid(
                    products: _results,
                    onAddToCart: _handleAddToCart,
                  ),
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
                if (_isLoadingInitial)
                  const _LoadingState()
                else if (_initialRecommendations.isEmpty)
                  const _EmptyResultState(query: 'produk bazar')
                else
                  _RecommendationGrid(
                    products: _initialRecommendations,
                    onAddToCart: _handleAddToCart,
                  ),
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
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== TOP BAR ====================
class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    final canGoBack = Navigator.of(context).canPop();

    return Row(
      children: [
        if (canGoBack)
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            color: kDarkGreen,
            tooltip: 'Kembali',
          ),
        Image.asset(
          'assets/icon/icon.png',
          height: 50,
          errorBuilder: (_, _, _) => const Text(
            'Bazar USU',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kDarkGreen,
            ),
          ),
        ),
        const Spacer(),
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
          '✨ Mau jajan apa hari ini?\nKetik mood, selera, atau kriteria makananmu!',
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
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: BorderSide(color: kDarkGreen.withValues(alpha: 0.4)),
    );

    return SizedBox(
      height: 48,
      child: TextField(
        controller: controller,
        style: const TextStyle(fontSize: 14, color: kDarkGreen),
        textInputAction: TextInputAction.search,
        textAlignVertical: TextAlignVertical.center,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: kDarkGreen.withValues(alpha: 0.7),
          ),
          hintText: 'jajanan korea viral yang asam manis...',
          hintStyle: TextStyle(
            color: kDarkGreen.withValues(alpha: 0.5),
            fontSize: 13,
          ),
          border: border,
          enabledBorder: border,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: kDarkGreen, width: 1.5),
          ),
        ),
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
      height: 48,
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
    'Manis kayak kamu ><': 'manis',
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
            'BABU sedang menganalisis bazar & seleramu...',
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
  final List<BabuProductItem> products;
  final ValueChanged<BabuProductItem> onAddToCart;

  const _RecommendationGrid({
    required this.products,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: 0.70,
      children: products
          .map((p) => _ProductCard(data: p, onAddTap: () => onAddToCart(p)))
          .toList(),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final BabuProductItem data;
  final VoidCallback onAddTap;

  const _ProductCard({required this.data, required this.onAddTap});

  Uint8List? _decodeBase64(String raw) {
    try {
      final clean = raw.contains(',') ? raw.split(',').last : raw;
      return base64Decode(clean);
    } catch (_) {
      return null;
    }
  }

  Widget _buildProductImage() {
    final src = data.image.trim();
    if (src.isEmpty) {
      return _fallbackImage();
    }
    if (src.startsWith('assets/')) {
      return Image.asset(
        src,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _fallbackImage(),
      );
    }
    if (src.startsWith('http://') || src.startsWith('https://')) {
      return Image.network(
        src,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _fallbackImage(),
      );
    }
    final bytes = _decodeBase64(src);
    if (bytes != null) {
      return Image.memory(
        bytes,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _fallbackImage(),
      );
    }
    return _fallbackImage();
  }

  Widget _fallbackImage() {
    return Container(
      width: double.infinity,
      color: kLightGreen,
      child: Icon(
        Icons.fastfood_outlined,
        color: kDarkGreen.withValues(alpha: 0.45),
        size: 32,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        BabuAiService.instance.logInteraction(
          actionType: 'click',
          product: data,
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
            Expanded(child: _buildProductImage()),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                        data.formattedPrice,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: kDarkGreen,
                        ),
                      ),
                      GestureDetector(
                        onTap: onAddTap,
                        child: Container(
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
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data.sellerName,
                    style: TextStyle(
                      fontSize: 11,
                      color: kDarkGreen.withValues(alpha: 0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (data.aiReason.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      data.aiReason,
                      style: TextStyle(
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                        color: kDarkGreen.withValues(alpha: 0.65),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
