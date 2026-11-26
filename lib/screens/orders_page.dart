import 'dart:convert';

import 'package:flutter/material.dart';

import '../constants.dart';
import '../services/order_state.dart';
import '../widgets/search_bar_field.dart';
import 'product_reviews_page.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedTab = 0;

  static const List<String> _tabs = [
    'Akan Diterima',
    'Untuk Diulas',
    'Pengembalian',
    'Pesanan Selesai',
    'Ditolak',
  ];

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

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text.trim().toLowerCase();

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            _SearchField(controller: _searchController),
            const SizedBox(height: 14),
            _TabRow(
              tabs: _tabs,
              selectedIndex: _selectedTab,
              onSelected: (i) => setState(() => _selectedTab = i),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<OrderList>(
                stream: OrderState.instance.userOrdersStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(color: kDarkGreen),
                    );
                  }

                  final allOrders = snapshot.data ?? [];
                  final currentTab = _tabs[_selectedTab];

                  final filtered = allOrders.where((o) {
                    final s = o.status.toLowerCase();
                    final bool matchesTab;
                    if (currentTab == 'Akan Diterima') {
                      // Mencakup pesanan yang masih menunggu konfirmasi penjual ('pending' / 'baru' / 'perlu dibayar')
                      // maupun yang sudah diterima penjual ('akan diterima' / 'diproses')
                      matchesTab =
                          s == 'akan diterima' ||
                          s == 'pending' ||
                          s == 'baru' ||
                          s == 'diproses' ||
                          s == 'perlu dibayar';
                    } else {
                      matchesTab = s == currentTab.toLowerCase();
                    }

                    if (!matchesTab) return false;

                    if (query.isEmpty) return true;
                    return o.items.any(
                      (item) =>
                          item.description.toLowerCase().contains(query) ||
                          item.storeName.toLowerCase().contains(query),
                    );
                  }).toList();

                  if (filtered.isEmpty) {
                    return const _EmptyState();
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _OrderCard(order: filtered[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  const _SearchField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SearchBarField(
      controller: controller,
      hintText: 'Cari Pesanan Anda',
    );
  }
}

class _TabRow extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _TabRow({
    required this.tabs,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: tabs.length,
        separatorBuilder: (_, _) => const SizedBox(width: 20),
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onSelected(index),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tabs[index],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected
                        ? kDarkGreen
                        : kDarkGreen.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 4),
                if (isSelected)
                  Container(width: 20, height: 2, color: kDarkGreen)
                else
                  const SizedBox(height: 2),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderData order;
  const _OrderCard({required this.order});

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match.group(1) ?? ''}.',
    );
  }

  Future<void> _advanceStatus(BuildContext context, String nextStatus) async {
    if (order.id.isEmpty) return;
    try {
      await OrderState.instance.updateOrderStatus(order.id, nextStatus);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status pesanan diperbarui menjadi $nextStatus'),
            backgroundColor: kDarkGreen,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui status: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _openReturnDialog(BuildContext context) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Ajukan Pengembalian',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: kDarkGreen,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tuliskan alasan pengembalian untuk pesanan ini:',
              style: TextStyle(
                fontSize: 12.5,
                color: kDarkGreen.withValues(alpha: 0.75),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Contoh: Barang tidak sesuai / rusak...',
                isDense: true,
                contentPadding: const EdgeInsets.all(10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: kDarkGreen.withValues(alpha: 0.25),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kDarkGreen, width: 1.6),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'Batal',
              style: TextStyle(color: kDarkGreen.withValues(alpha: 0.65)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: kDarkGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: const Text('Ajukan'),
          ),
        ],
      ),
    );

    reasonController.dispose();

    if (confirmed == true && context.mounted) {
      await _advanceStatus(context, 'Pengembalian');
    }
  }

  Future<void> _openReviewForItem(BuildContext context, OrderItem item) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductReviewsPage(
          productName: item.description,
          storeName: item.storeName,
          allowWrite: true,
        ),
      ),
    );
  }

  void _handleReviewAction(BuildContext context) {
    if (order.items.isEmpty) return;

    if (order.items.length == 1) {
      _openReviewForItem(context, order.items.first);
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilih Produk untuk Diulas',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: kDarkGreen,
                ),
              ),
              const SizedBox(height: 12),
              ...order.items.map(
                (item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: _OrderItemThumb(imageSource: item.image),
                  title: Text(
                    item.description,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: kDarkGreen,
                    ),
                  ),
                  subtitle: Text(
                    item.storeName,
                    style: TextStyle(
                      fontSize: 12,
                      color: kDarkGreen.withValues(alpha: 0.6),
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: kDarkGreen),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _openReviewForItem(context, item);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusLower = order.status.toLowerCase();
    final isRejected = statusLower == 'ditolak';
    final isPending =
        statusLower == 'pending' ||
        statusLower == 'baru' ||
        statusLower == 'perlu dibayar';
    final isAccepted =
        statusLower == 'akan diterima' || statusLower == 'diproses';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRejected
              ? Colors.redAccent.withValues(alpha: 0.35)
              : kDarkGreen.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (isRejected)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Ditolak Penjual',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                )
              else if (isPending)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Menunggu Konfirmasi Penjual',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                )
              else
                Text(
                  isAccepted ? 'Akan Diterima' : order.status,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: kDarkGreen,
                  ),
                ),
              Text(
                '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
                style: TextStyle(
                  fontSize: 11,
                  color: kDarkGreen.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          const Divider(height: 18),
          ...order.items.map(
            (OrderItem item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _OrderItemThumb(imageSource: item.image),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: kDarkGreen.withValues(alpha: 0.85),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${item.storeName} · x${item.quantity}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: kDarkGreen.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Rp${_formatPrice(item.price * item.quantity)}',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: kDarkGreen,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: kDarkGreen,
                ),
              ),
              Text(
                'Rp${_formatPrice(order.total)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: kDarkGreen,
                ),
              ),
            ],
          ),
          if (isRejected) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Pesanan ini ditolak oleh penjual.',
                style: TextStyle(
                  fontSize: 11.5,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ] else if (isPending) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.4),
                  ),
                ),
                child: const Text(
                  'Pending · Menunggu Penjual',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ),
            ),
          ] else if (isAccepted ||
              statusLower == 'untuk diulas' ||
              statusLower == 'pengembalian') ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: statusLower == 'untuk diulas'
                  ? Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: () => _openReturnDialog(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                            side: const BorderSide(color: Colors.redAccent),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Kembalikan',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () => _handleReviewAction(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: kDarkGreen,
                            side: const BorderSide(color: kDarkGreen),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Beri Ulasan',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () =>
                              _advanceStatus(context, 'Pesanan Selesai'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kDarkGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text(
                            'Selesaikan Pesanan',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    )
                  : statusLower == 'pengembalian'
                  ? ElevatedButton(
                      onPressed: () =>
                          _advanceStatus(context, 'Pesanan Selesai'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kDarkGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Selesaikan Pengembalian',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () => _advanceStatus(context, 'Untuk Diulas'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kDarkGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Pesanan Diterima',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
          ],
        ],
      ),
    );
  }
}

class _OrderItemThumb extends StatelessWidget {
  final String imageSource;
  const _OrderItemThumb({required this.imageSource});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: kLightGreen,
        borderRadius: BorderRadius.circular(8),
      ),
      child: _buildImage(),
    );
  }

  Widget _buildImage() {
    if (imageSource.isEmpty) {
      return Icon(
        Icons.image_outlined,
        color: kDarkGreen.withValues(alpha: 0.4),
        size: 20,
      );
    }
    if (imageSource.startsWith('assets/')) {
      return Image.asset(
        imageSource,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Icon(
          Icons.image_outlined,
          color: kDarkGreen.withValues(alpha: 0.4),
          size: 20,
        ),
      );
    }
    if (imageSource.startsWith('http://') ||
        imageSource.startsWith('https://')) {
      return Image.network(
        imageSource,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Icon(
          Icons.image_outlined,
          color: kDarkGreen.withValues(alpha: 0.4),
          size: 20,
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
          Icons.image_outlined,
          color: kDarkGreen.withValues(alpha: 0.4),
          size: 20,
        ),
      );
    } catch (_) {
      return Icon(
        Icons.image_outlined,
        color: kDarkGreen.withValues(alpha: 0.4),
        size: 20,
      );
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 56,
            color: kDarkGreen.withValues(alpha: 0.25),
          ),
          const SizedBox(height: 12),
          Text(
            'Belum ada pesanan',
            style: TextStyle(
              fontSize: 14,
              color: kDarkGreen.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}
