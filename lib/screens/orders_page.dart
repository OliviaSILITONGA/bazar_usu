import 'dart:convert';

import 'package:flutter/material.dart';

import '../constants.dart';
import '../services/order_state.dart';
import '../widgets/search_bar_field.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedTab = 0;

  static const List<String> _tabs = [
    'Perlu dibayar',
    'Akan Diterima',
    'Untuk Diulas',
    'Pesanan Selesai',
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
                    final matchesTab =
                        o.status.toLowerCase() == currentTab.toLowerCase();
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

// ==================== KOLOM PENCARIAN ====================
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

// ==================== TAB STATUS PESANAN ====================
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

// ==================== KARTU PESANAN ====================
class _OrderCard extends StatelessWidget {
  final OrderData order;
  const _OrderCard({required this.order});

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
  }

  Future<void> _advanceStatus(BuildContext context, String nextStatus) async {
    if (order.id.isEmpty) return;
    try {
      await OrderState.instance.updateOrderStatus(order.id, nextStatus);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status pesanan diperbarui menjadi "$nextStatus"'),
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

  @override
  Widget build(BuildContext context) {
    final statusLower = order.status.toLowerCase();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kDarkGreen.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.status,
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
                children: [
                  _OrderItemThumb(imageSource: item.image),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.description,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: kDarkGreen.withValues(alpha: 0.85),
                          ),
                        ),
                        Text(
                          '${item.storeName} · x${item.quantity}',
                          style: TextStyle(
                            fontSize: 11,
                            color: kDarkGreen.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
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
          if (statusLower == 'perlu dibayar' ||
              statusLower == 'akan diterima' ||
              statusLower == 'untuk diulas') ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  if (statusLower == 'perlu dibayar') {
                    _advanceStatus(context, 'Akan Diterima');
                  } else if (statusLower == 'akan diterima') {
                    _advanceStatus(context, 'Untuk Diulas');
                  } else if (statusLower == 'untuk diulas') {
                    _advanceStatus(context, 'Pesanan Selesai');
                  }
                },
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
                child: Text(
                  statusLower == 'perlu dibayar'
                      ? 'Bayar Sekarang'
                      : statusLower == 'akan diterima'
                      ? 'Pesanan Diterima'
                      : 'Selesaikan Pesanan',
                  style: const TextStyle(
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

// ==================== THUMBNAIL ITEM PESANAN ====================
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

// ==================== STATE KOSONG ====================
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
