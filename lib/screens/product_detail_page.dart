import 'package:flutter/material.dart';

import '../constants.dart';

class ReviewData {
  final int stars;
  final String comment;
  const ReviewData({required this.stars, required this.comment});
}

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

  const ProductDetailPage({
    super.key,
    required this.name,
    required this.storeName,
    required this.originalPrice,
    required this.discountPrice,
    required this.rating,
    required this.reviewCount,
    required this.prepTime,
    required this.kcal,
    required this.description,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _quantity = 1;

  static const List<ReviewData> _reviews = [
    ReviewData(stars: 5, comment: 'Ayam Gepreknya pedes nampol, porsinya pas!'),
    ReviewData(
      stars: 4,
      comment: 'Nasi Rendangnya enak banget, tapi sayang porsinya agak kecil.',
    ),
  ];

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
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ProductPhoto(onClose: () => Navigator.pop(context)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _RatingRow(
                        rating: widget.rating,
                        reviewCount: widget.reviewCount,
                        prepTime: widget.prepTime,
                      ),
                      const SizedBox(height: 10),
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
                      const SizedBox(height: 14),
                      _KcalAndPriceRow(
                        kcal: widget.kcal,
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
                      _ChatButton(onTap: () {}),
                      const SizedBox(height: 24),
                      const Text(
                        'Ulasan Makanan',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ..._reviews.map(
                        (r) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _ReviewBubble(review: r),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomBar(
              quantity: _quantity,
              onQuantityChanged: (q) => setState(() => _quantity = q),
              totalPrice: widget.discountPrice * _quantity,
              formatPrice: _formatPrice,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== FOTO PRODUK + TOMBOL X ====================
class _ProductPhoto extends StatelessWidget {
  final VoidCallback onClose;
  const _ProductPhoto({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 260,
          width: double.infinity,
          color: kLightGreen,
          child: Icon(
            Icons.image_outlined,
            color: kDarkGreen.withValues(alpha: 0.35),
            size: 56,
          ),
          // Ganti dengan Image.asset/Image.network foto produk asli.
        ),
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

// ==================== RATING & WAKTU ====================
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

// ==================== KALORI & HARGA ====================
class _KcalAndPriceRow extends StatelessWidget {
  final int kcal;
  final int originalPrice;
  final int discountPrice;
  final String Function(int) formatPrice;

  const _KcalAndPriceRow({
    required this.kcal,
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: kLightGreen,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.local_fire_department,
                size: 14,
                color: kDarkGreen,
              ),
              const SizedBox(width: 4),
              Text(
                '$kcal kcal',
                style: const TextStyle(
                  fontSize: 12,
                  color: kDarkGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
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

// ==================== TOMBOL CHAT DENGAN PENJUAL ====================
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

// ==================== BUBBLE ULASAN ====================
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

// ==================== BAR BAWAH ====================
class _BottomBar extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onQuantityChanged;
  final int totalPrice;
  final String Function(int) formatPrice;

  const _BottomBar({
    required this.quantity,
    required this.onQuantityChanged,
    required this.totalPrice,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        child: Row(
          children: [
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
                  ),
                  Text(
                    '$quantity',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => onQuantityChanged(quantity + 1),
                    icon: const Icon(Icons.add, size: 18),
                    color: Colors.black87,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed:
                      () {}, // sambungkan ke logika tambah ke keranjang nanti
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kDarkGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Tambah ke Keranjang',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Rp${formatPrice(totalPrice)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
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
