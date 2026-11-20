import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class ProductReviewItem {
  final String id;
  final String productName;
  final String storeName;
  final int stars;
  final String comment;
  final String userName;
  final DateTime createdAt;

  const ProductReviewItem({
    required this.id,
    required this.productName,
    required this.storeName,
    required this.stars,
    required this.comment,
    this.userName = 'Pembeli',
    required this.createdAt,
  });

  factory ProductReviewItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final rawStars = data['stars'] ?? data['rating'] ?? 5;
    final parsedStars = rawStars is int
        ? rawStars
        : int.tryParse(rawStars.toString()) ?? 5;

    final rawDate = data['createdAt'];
    final date = rawDate is Timestamp ? rawDate.toDate() : DateTime.now();

    return ProductReviewItem(
      id: doc.id,
      productName: (data['productName'] ?? '').toString(),
      storeName: (data['storeName'] ?? '').toString(),
      stars: parsedStars.clamp(1, 5),
      comment: (data['comment'] ?? '').toString(),
      userName: (data['userName'] ?? 'Pembeli').toString(),
      createdAt: date,
    );
  }
}

typedef ReviewItemList = List<ProductReviewItem>;

class ProductReviewsPage extends StatefulWidget {
  final String productName;
  final String storeName;
  final bool allowWrite;

  const ProductReviewsPage({
    super.key,
    required this.productName,
    required this.storeName,
    this.allowWrite = false,
  });

  @override
  State<ProductReviewsPage> createState() => _ProductReviewsPageState();
}

class _ProductReviewsPageState extends State<ProductReviewsPage> {
  final TextEditingController _commentController = TextEditingController();
  int _selectedRating = 5;
  int? _filterStar;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Stream<ReviewItemList> _reviewsStream() {
    final targetProduct = widget.productName.trim().toLowerCase();
    final targetStore = widget.storeName.trim().toLowerCase();

    return FirebaseFirestore.instance.collection('reviews').snapshots().map((
      snapshot,
    ) {
      final list =
          snapshot.docs
              .map((doc) => ProductReviewItem.fromFirestore(doc))
              .where((r) {
                final matchProduct =
                    r.productName.trim().toLowerCase() == targetProduct;
                final matchStore =
                    targetStore.isEmpty ||
                    r.storeName.trim().toLowerCase() == targetStore;
                return matchProduct && matchStore;
              })
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return list;
    });
  }

  Future<void> _submitReview() async {
    if (!widget.allowWrite || _isSubmitting) return;

    final comment = _commentController.text.trim();
    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tulis komentar ulasan terlebih dahulu'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan login terlebih dahulu untuk memberi ulasan'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      String reviewerName = user.displayName ?? 'Pembeli';
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userDoc.exists) {
        final uData = userDoc.data() ?? {};
        final dbName = (uData['nama'] ?? uData['name'] ?? '').toString().trim();
        if (dbName.isNotEmpty) reviewerName = dbName;
      }

      await FirebaseFirestore.instance.collection('reviews').add({
        'productName': widget.productName,
        'storeName': widget.storeName,
        'stars': _selectedRating,
        'rating': _selectedRating,
        'comment': comment,
        'userId': user.uid,
        'userName': reviewerName,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _commentController.clear();
      setState(() {
        _selectedRating = 5;
        _isSubmitting = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ulasan berhasil dikirim'),
          backgroundColor: kDarkGreen,
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim ulasan: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year.toString();
    return '$day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        foregroundColor: kDarkGreen,
        title: Text(
          widget.allowWrite ? 'Beri Ulasan' : 'Ulasan Pembeli',
          style: const TextStyle(
            color: kDarkGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<ReviewItemList>(
          stream: _reviewsStream(),
          builder: (context, snapshot) {
            final allReviews = snapshot.data ?? [];
            final count = allReviews.length;
            final avgRating = count == 0
                ? 0.0
                : allReviews.fold<int>(0, (acc, r) => acc + r.stars) / count;

            final visibleReviews = _filterStar == null
                ? allReviews
                : allReviews.where((r) => r.stars == _filterStar).toList();

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: kDarkGreen.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.productName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: kDarkGreen,
                        ),
                      ),
                      if (widget.storeName.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          widget.storeName,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: kDarkGreen.withValues(alpha: 0.65),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 28),
                          const SizedBox(width: 6),
                          Text(
                            count == 0 ? '-' : avgRating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '($count ulasan)',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (widget.allowWrite) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: kDarkGreen.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tulis Ulasan Kamu',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: kDarkGreen,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: List.generate(5, (i) {
                            final starVal = i + 1;
                            return IconButton(
                              onPressed: () =>
                                  setState(() => _selectedRating = starVal),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 36,
                                minHeight: 36,
                              ),
                              icon: Icon(
                                starVal <= _selectedRating
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Colors.amber,
                                size: 28,
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _commentController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: 'Bagikan pengalamanmu setelah menerima barang ini...',
                            isDense: true,
                            contentPadding: const EdgeInsets.all(12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: kDarkGreen.withValues(alpha: 0.25),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: kDarkGreen,
                                width: 1.8,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submitReview,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kDarkGreen,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Kirim Ulasan',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _FilterChip(
                        label: 'Semua',
                        selected: _filterStar == null,
                        onTap: () => setState(() => _filterStar = null),
                      ),
                      ...List.generate(5, (i) {
                        final star = 5 - i;
                        return Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: _FilterChip(
                            label: '$star ★',
                            selected: _filterStar == star,
                            onTap: () => setState(() => _filterStar = star),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(
                      child: CircularProgressIndicator(color: kDarkGreen),
                    ),
                  )
                else if (visibleReviews.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 36),
                    alignment: Alignment.center,
                    child: Text(
                      'Belum ada ulasan pembeli.',
                      style: TextStyle(
                        fontSize: 13,
                        color: kDarkGreen.withValues(alpha: 0.6),
                      ),
                    ),
                  )
                else
                  ...visibleReviews.map(
                    (rev) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: kDarkGreen.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                rev.userName,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: kDarkGreen,
                                ),
                              ),
                              Text(
                                _formatDate(rev.createdAt),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: kDarkGreen.withValues(alpha: 0.5),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: List.generate(
                              5,
                              (i) => Icon(
                                Icons.star,
                                size: 14,
                                color: i < rev.stars
                                    ? Colors.amber
                                    : Colors.black12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            rev.comment,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? kDarkGreen : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? kDarkGreen : kDarkGreen.withValues(alpha: 0.25),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: selected ? Colors.white : kDarkGreen,
          ),
        ),
      ),
    );
  }
}
