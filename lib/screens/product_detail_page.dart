import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../services/cart_state.dart';
import '../services/favorite_products_state.dart';
import 'chat_detail_page.dart';
import 'checkout_page.dart';
import 'product_reviews_page.dart';

class ReviewData {
  final int stars;
  final String comment;
  const ReviewData({required this.stars, required this.comment});
}

typedef ProductReviewList = List<ReviewData>;

class ProductDetailPage extends StatefulWidget {
  final String name;
  final String storeName;
  final int originalPrice;
  final int discountPrice;
  final double rating;
  final int reviewCount;
  final String prepTime;
  final int kcal;
  final String description;
  final String image;
  final List<ReviewData> reviews;

  const ProductDetailPage({
    super.key,
    required this.name,
    required this.storeName,
    required this.originalPrice,
    required this.discountPrice,
    required this.rating,
    required this.reviewCount,
    required this.prepTime,
    this.kcal = 0,
    required this.description,
    this.image = '',
    this.reviews = const [],
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _quantity = 1;

  Stream<ProductReviewList> _productReviewsStream() {
    final targetProduct = widget.name.trim().toLowerCase();
    final targetStore = widget.storeName.trim().toLowerCase();

    return FirebaseFirestore.instance.collection('reviews').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs
          .where((doc) {
            final data = doc.data();
            final pName = (data['productName'] ?? '')
                .toString()
                .trim()
                .toLowerCase();
            final sName = (data['storeName'] ?? '')
                .toString()
                .trim()
                .toLowerCase();
            return pName == targetProduct &&
                (targetStore.isEmpty || sName == targetStore);
          })
          .map((doc) {
            final data = doc.data();
            final rawStars = data['stars'] ?? data['rating'] ?? 5;
            final stars = rawStars is int
                ? rawStars
                : int.tryParse(rawStars.toString()) ?? 5;
            return ReviewData(
              stars: stars.clamp(1, 5),
              comment: (data['comment'] ?? '').toString(),
            );
          })
          .toList();
    });
  }

  void _openAllBuyerReviewsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductReviewsPage(
          productName: widget.name,
          storeName: widget.storeName,
          allowWrite: false,
        ),
      ),
    );
  }

  void _toggleFavorite(bool isCurrentlyFavorited) {
    final product = FavoriteProductData(
      storeName: widget.storeName,
      description: widget.name,
      price: widget.discountPrice,
      image: widget.image,
    );
    if (isCurrentlyFavorited) {
      FavoriteProductsState.instance.remove(product);
    } else {
      FavoriteProductsState.instance.addProduct(product);
    }
  }

  void _openChatWithSeller() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatDetailPage(contactName: widget.storeName),
      ),
    );
  }

  void _addToCart() {
    CartState.instance.addItem(
      storeName: widget.storeName,
      description: widget.name,
      price: widget.discountPrice,
      image: widget.image,
      quantity: _quantity,
    );
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Berhasil!'),
        content: Text('${widget.name} (x$_quantity) ditambahkan ke keranjang.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Oke'),
          ),
        ],
      ),
    );
  }

  void _buyNow() {
    final item = CartItem(
      storeName: widget.storeName,
      description: widget.name,
      price: widget.discountPrice,
      image: widget.image,
      quantity: _quantity,
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutPage(
          items: [item],
          total: widget.discountPrice * _quantity,
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match.group(1) ?? ''}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ProductPhoto(
              image: widget.image,
              onClose: () => Navigator.pop(context),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: StreamBuilder<ProductReviewList>(
                stream: _productReviewsStream(),
                builder: (context, snapshot) {
                  final reviews = snapshot.data ?? const <ReviewData>[];
                  final displayReviewCount = reviews.length;
                  final displayRating = reviews.isNotEmpty
                      ? reviews.fold<int>(0, (acc, r) => acc + r.stars) /
                            reviews.length
                      : widget.rating;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _RatingRow(
                        rating: displayRating,
                        reviewCount: displayReviewCount,
                        prepTime: widget.prepTime,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.name,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.storeName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: kDarkGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          ValueListenableBuilder<FavProductList>(
                            valueListenable:
                                FavoriteProductsState.instance.products,
                            builder: (context, favProducts, _) {
                              final isFavorited = favProducts.any(
                                (p) =>
                                    p.storeName == widget.storeName &&
                                    p.description == widget.name,
                              );
                              return GestureDetector(
                                onTap: () => _toggleFavorite(isFavorited),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.redAccent.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ),
                                  child: Icon(
                                    isFavorited
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: Colors.redAccent,
                                    size: 22,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _PriceRow(
                        originalPrice: widget.originalPrice,
                        discountPrice: widget.discountPrice,
                        formatPrice: _formatPrice,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _ChatButton(onTap: _openChatWithSeller),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Ulasan Produk',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          GestureDetector(
                            onTap: _openAllBuyerReviewsPage,
                            child: const Text(
                              'Lihat Semua',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: kDarkGreen,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      if (reviews.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0F0F0),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Text(
                            'Belum ada ulasan untuk produk ini.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        )
                      else
                        ...reviews
                            .take(3)
                            .map(
                              (r) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: GestureDetector(
                                  onTap: _openAllBuyerReviewsPage,
                                  child: _ReviewBubble(review: r),
                                ),
                              ),
                            ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _BottomBar(
        quantity: _quantity,
        onQuantityChanged: (q) => setState(() => _quantity = q),
        totalPrice: widget.discountPrice * _quantity,
        formatPrice: _formatPrice,
        onAddToCart: _addToCart,
        onBuyNow: _buyNow,
      ),
    );
  }
}

class _ProductPhoto extends StatelessWidget {
  final String image;
  final VoidCallback onClose;
  const _ProductPhoto({required this.image, required this.onClose});

  Widget _buildImage() {
    Widget fallback() => Container(
      height: 260,
      width: double.infinity,
      color: kLightGreen,
      child: Icon(
        Icons.image_outlined,
        color: kDarkGreen.withValues(alpha: 0.35),
        size: 56,
      ),
    );

    if (image.isEmpty) return fallback();

    if (image.startsWith('assets/')) {
      return Image.asset(
        image,
        height: 260,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback(),
      );
    }

    if (image.startsWith('http://') || image.startsWith('https://')) {
      return Image.network(
        image,
        height: 260,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback(),
      );
    }

    try {
      final cleanBase64 = image.contains(',') ? image.split(',').last : image;
      return Image.memory(
        base64Decode(cleanBase64),
        height: 260,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback(),
      );
    } catch (_) {
      return fallback();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _buildImage(),
        Positioned(
          top: 44,
          right: 16,
          child: GestureDetector(
            onTap: onClose,
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 20, color: Colors.black87),
            ),
          ),
        ),
      ],
    );
  }
}

class _RatingRow extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final String prepTime;

  const _RatingRow({
    required this.rating,
    required this.reviewCount,
    required this.prepTime,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.star, size: 16, color: Colors.amber),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '($reviewCount ulasan)',
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
        const SizedBox(width: 6),
        const Text('•', style: TextStyle(color: Colors.black38)),
        const SizedBox(width: 6),
        Text(
          prepTime,
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  final int originalPrice;
  final int discountPrice;
  final String Function(int) formatPrice;

  const _PriceRow({
    required this.originalPrice,
    required this.discountPrice,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    final hasDiscount = originalPrice > discountPrice;
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 10,
      runSpacing: 8,
      children: [
        if (hasDiscount)
          Text(
            'Rp${formatPrice(originalPrice)}',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black38,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        Text(
          'Rp${formatPrice(discountPrice)}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

class _ChatButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ChatButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: kDarkGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        icon: const Icon(Icons.chat_bubble_outline, size: 18),
        label: const Text(
          'Chat dengan Penjual',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _ReviewBubble extends StatelessWidget {
  final ReviewData review;
  const _ReviewBubble({required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              5,
              (i) => Icon(
                Icons.star,
                size: 14,
                color: i < review.stars ? Colors.amber : Colors.black12,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              review.comment,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onQuantityChanged;
  final int totalPrice;
  final String Function(int) formatPrice;
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;

  const _BottomBar({
    required this.quantity,
    required this.onQuantityChanged,
    required this.totalPrice,
    required this.formatPrice,
    required this.onAddToCart,
    required this.onBuyNow,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Jumlah',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: kDarkGreen.withValues(alpha: 0.7),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black26),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: quantity > 1
                            ? () => onQuantityChanged(quantity - 1)
                            : null,
                        icon: const Icon(Icons.remove, size: 18),
                        color: Colors.black87,
                        padding: const EdgeInsets.all(6),
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        quantity.toString(),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        onPressed: () => onQuantityChanged(quantity + 1),
                        icon: const Icon(Icons.add, size: 18),
                        color: Colors.black87,
                        padding: const EdgeInsets.all(6),
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                SizedBox(
                  width: 50,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: onAddToCart,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      foregroundColor: kDarkGreen,
                      side: const BorderSide(color: kDarkGreen, width: 1.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Icon(
                      Icons.add_shopping_cart_outlined,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: onBuyNow,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kDarkGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Beli Sekarang',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 1,
                              height: 14,
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Rp${formatPrice(totalPrice)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
