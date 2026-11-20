import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../widgets/search_bar_field.dart';
import 'cart_page.dart';
import 'fitur_AI.dart';
import 'notification_page.dart';
import 'product_detail_page.dart';
import 'store_detail_page.dart';

typedef ProductList = List<ProductData>;

class HomePageUser extends StatefulWidget {
  const HomePageUser({super.key});

  @override
  State<HomePageUser> createState() => _HomePageUserState();
}

class _HomePageUserState extends State<HomePageUser> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = _selectedCategory == category ? null : category;
    });
  }

  String _formatPrice(int price) {
    final formatted = price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
    return 'Rp $formatted';
  }

  Stream<ProductList> _productsStream() {
    return FirebaseFirestore.instance.collection('products').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final rawPrice = data['price'] ?? data['harga'] ?? 0;
        final priceInt = rawPrice is int
            ? rawPrice
            : int.tryParse(
                    rawPrice.toString().replaceAll(RegExp(r'[^0-9]'), ''),
                  ) ??
                  0;

        final imgBase64 = (data['imageBase64'] ?? '').toString();
        final imgUrl =
            (data['imageUrl'] ?? data['imagePath'] ?? data['image'] ?? '')
                .toString();

        return ProductData(
          id: doc.id,
          name: (data['name'] ?? data['nama'] ?? 'Produk').toString(),
          price: _formatPrice(priceInt),
          priceInt: priceInt,
          seller: (data['namaToko'] ?? data['seller'] ?? 'Toko Bazar')
              .toString(),
          image: imgBase64.isNotEmpty ? imgBase64 : imgUrl,
          category: (data['category'] ?? data['kategori'] ?? 'Lainnya')
              .toString(),
          description: (data['description'] ?? data['deskripsi'] ?? '')
              .toString(),
          isPromo: data['isPromo'] == true || data['promo'] == true,
          reviews: const [],
        );
      }).toList();
    });
  }

  List<ProductData> _filterProducts(ProductList allProducts) {
    final query = _searchController.text.trim().toLowerCase();
    return allProducts.where((p) {
      final matchesQuery =
          query.isEmpty ||
          p.name.toLowerCase().contains(query) ||
          p.seller.toLowerCase().contains(query);
      final matchesCategory =
          _selectedCategory == null ||
          p.category.toLowerCase() == _selectedCategory!.toLowerCase();
      return matchesQuery && matchesCategory;
    }).toList();
  }

  bool get _isFiltering =>
      _searchController.text.trim().isNotEmpty || _selectedCategory != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Stack(
        children: [
          SafeArea(
            child: StreamBuilder<ProductList>(
              stream: _productsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(color: kDarkGreen),
                  );
                }

                final allProducts = snapshot.data ?? const <ProductData>[];
                final filtered = _filterProducts(allProducts);
                final promoProducts = allProducts
                    .where((p) => p.isPromo)
                    .toList();

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),
                      _SearchBar(controller: _searchController),
                      const SizedBox(height: 20),
                      _CategoryRow(
                        selectedCategory: _selectedCategory,
                        onSelected: _onCategorySelected,
                      ),
                      const SizedBox(height: 20),
                      if (_isFiltering) ...[
                        _SectionTitle(
                          title: _selectedCategory != null
                              ? 'Kategori: $_selectedCategory (${filtered.length})'
                              : 'Hasil Pencarian (${filtered.length})',
                        ),
                        const SizedBox(height: 12),
                        filtered.isEmpty
                            ? const _EmptySearchResult()
                            : _ProductGrid(products: filtered),
                      ] else ...[
                        if (promoProducts.isNotEmpty) ...[
                          _PromoBanner(products: promoProducts),
                          const SizedBox(height: 24),
                        ],
                        const _SectionTitle(title: 'Produk Favorite'),
                        const SizedBox(height: 12),
                        allProducts.isEmpty
                            ? const _EmptyBackendState(
                                message: 'Belum ada produk di database',
                              )
                            : _ProductGrid(products: allProducts),
                        const SizedBox(height: 24),
                        const _SectionTitle(title: 'Bazar Favorit'),
                        const SizedBox(height: 14),
                        const _PopularStoresRow(),
                      ],
                      const SizedBox(height: 100),
                    ],
                  ),
                );
              },
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
    );
  }
}

// ==================== SEARCH BAR ====================
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    const int cartCount = 0;
    const int notifCount = 0;

    return SearchBarField(
      controller: controller,
      hintText: 'Mau Makan Apa Hari Ini?',
      trailing: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationPage()),
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
              MaterialPageRoute(builder: (_) => const CartPage()),
            );
          },
          child: _IconWithBadge(
            icon: Icons.shopping_cart_outlined,
            count: cartCount,
          ),
        ),
      ],
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
  final String? selectedCategory;
  final ValueChanged<String> onSelected;

  const _CategoryRow({
    required this.selectedCategory,
    required this.onSelected,
  });

  static const List<_CategoryData> _categories = [
    _CategoryData(icon: Icons.set_meal_outlined, label: 'Makanan'),
    _CategoryData(icon: Icons.local_drink_outlined, label: 'Minuman'),
    _CategoryData(icon: Icons.cookie_outlined, label: 'Jajanan'),
    _CategoryData(icon: Icons.inventory_2_outlined, label: 'Lainnya'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _categories
            .map(
              (c) => _CategoryItem(
                data: c,
                isSelected: selectedCategory == c.label,
                onTap: () => onSelected(c.label),
              ),
            )
            .toList(),
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
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.data,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? kDarkGreen : kLightGreen,
              border: Border.all(
                color: kDarkGreen.withValues(alpha: isSelected ? 1 : 0.3),
              ),
            ),
            child: Icon(
              data.icon,
              color: isSelected ? Colors.white : kDarkGreen,
              size: 26,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            data.label,
            style: TextStyle(
              fontSize: 12,
              color: kDarkGreen,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== BANNER PROMO ====================
class _PromoBanner extends StatelessWidget {
  final List<ProductData> products;
  const _PromoBanner({required this.products});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: products.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) => _PromoCard(data: products[index]),
      ),
    );
  }
}

class _PromoCard extends StatelessWidget {
  final ProductData data;
  const _PromoCard({required this.data});

  Widget _buildBannerImage(String imageSource) {
    if (imageSource.startsWith('http://') ||
        imageSource.startsWith('https://')) {
      return Image.network(
        imageSource,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const SizedBox.shrink(),
      );
    }

    if (imageSource.isNotEmpty) {
      try {
        final cleanBase64 = imageSource.contains(',')
            ? imageSource.split(',').last
            : imageSource;
        return Image.memory(
          base64Decode(cleanBase64),
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => const SizedBox.shrink(),
        );
      } catch (_) {
        return const SizedBox.shrink();
      }
    }

    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: kDarkGreen.withValues(alpha: 0.65)),
            _buildBannerImage(data.image),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.05),
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    data.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    data.price,
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
                          builder: (_) =>
                              StoreDetailPage(storeName: data.seller),
                        ),
                      );
                    },
                    child: Text(
                      data.seller,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                            name: data.name,
                            storeName: data.seller,
                            originalPrice: data.priceInt,
                            discountPrice: data.priceInt,
                            rating: 0,
                            reviewCount: 0,
                            prepTime: '15-20 min',
                            kcal: 250,
                            description: data.description,
                            image: data.image,
                            reviews: data.reviews,
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

// ==================== MODEL PRODUK ====================
class ProductData {
  final String id;
  final String name;
  final String price;
  final int priceInt;
  final String seller;
  final String image;
  final String category;
  final String description;
  final bool isPromo;
  final List<ReviewData> reviews;

  const ProductData({
    this.id = '',
    required this.name,
    required this.price,
    this.priceInt = 0,
    required this.seller,
    required this.image,
    required this.category,
    this.description = '',
    this.isPromo = false,
    this.reviews = const [],
  });
}

// ==================== GRID PRODUK ====================
class _ProductGrid extends StatelessWidget {
  final List<ProductData> products;
  const _ProductGrid({required this.products});

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
        children: products.map((p) => _ProductCard(data: p)).toList(),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductData data;
  const _ProductCard({required this.data});

  Widget _buildProductImage(String imageSource) {
    if (imageSource.isEmpty) {
      return Container(
        width: double.infinity,
        color: kLightGreen,
        child: Icon(
          Icons.image_outlined,
          color: kDarkGreen.withValues(alpha: 0.4),
          size: 32,
        ),
      );
    }

    if (imageSource.startsWith('http://') ||
        imageSource.startsWith('https://')) {
      return Image.network(
        imageSource,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          width: double.infinity,
          color: kLightGreen,
          child: Icon(
            Icons.image_outlined,
            color: kDarkGreen.withValues(alpha: 0.4),
            size: 32,
          ),
        ),
      );
    }

    try {
      final cleanBase64 = imageSource.contains(',')
          ? imageSource.split(',').last
          : imageSource;
      return Image.memory(
        base64Decode(cleanBase64),
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          width: double.infinity,
          color: kLightGreen,
          child: Icon(
            Icons.image_outlined,
            color: kDarkGreen.withValues(alpha: 0.4),
            size: 32,
          ),
        ),
      );
    } catch (_) {
      return Container(
        width: double.infinity,
        color: kLightGreen,
        child: Icon(
          Icons.image_outlined,
          color: kDarkGreen.withValues(alpha: 0.4),
          size: 32,
        ),
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
              name: data.name,
              storeName: data.seller,
              originalPrice: data.priceInt,
              discountPrice: data.priceInt,
              rating: 0,
              reviewCount: 0,
              prepTime: '15-20 min',
              kcal: 250,
              description: data.description,
              image: data.image,
              reviews: data.reviews,
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
            Expanded(child: _buildProductImage(data.image)),
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

// ==================== STATE PENCARIAN / KOSONG ====================
class _EmptySearchResult extends StatelessWidget {
  const _EmptySearchResult();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: kDarkGreen.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          Text(
            'Produk tidak ditemukan',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: kDarkGreen.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Coba kata kunci atau kategori lain',
            style: TextStyle(
              fontSize: 12.5,
              color: kDarkGreen.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyBackendState extends StatelessWidget {
  final String message;
  const _EmptyBackendState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            fontSize: 13,
            color: kDarkGreen.withValues(alpha: 0.55),
          ),
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

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('tenants').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const SizedBox(
            height: 90,
            child: Center(child: CircularProgressIndicator(color: kDarkGreen)),
          );
        }

        final stores = (snapshot.data?.docs ?? [])
            .map((doc) {
              final data = doc.data() as Map<String, dynamic>? ?? {};
              final name = (data['namaToko'] ?? data['storeName'] ?? '')
                  .toString()
                  .trim();
              final foto = (data['fotoBase64'] ?? '').toString();
              return _StoreData(name: name, image: foto);
            })
            .where((s) => s.name.isNotEmpty)
            .toList();

        if (stores.isEmpty) {
          return const _EmptyBackendState(
            message: 'Belum ada toko terdaftar di database',
          );
        }

        return SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: stores.length,
            separatorBuilder: (_, _) => const SizedBox(width: 16),
            itemBuilder: (context, index) => _StoreAvatar(data: stores[index]),
          ),
        );
      },
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

  Widget _buildAvatarImage(String imageSource) {
    if (imageSource.isEmpty) {
      return Icon(
        Icons.storefront_outlined,
        color: kDarkGreen.withValues(alpha: 0.6),
        size: 26,
      );
    }

    if (imageSource.startsWith('http://') ||
        imageSource.startsWith('https://')) {
      return Image.network(
        imageSource,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Icon(
          Icons.storefront_outlined,
          color: kDarkGreen.withValues(alpha: 0.6),
          size: 26,
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
          color: kDarkGreen.withValues(alpha: 0.6),
          size: 26,
        ),
      );
    } catch (_) {
      return Icon(
        Icons.storefront_outlined,
        color: kDarkGreen.withValues(alpha: 0.6),
        size: 26,
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
              child: _buildAvatarImage(data.image),
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
