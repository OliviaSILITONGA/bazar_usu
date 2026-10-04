import 'package:flutter/material.dart';

import 'chat_list_page.dart';
import 'profile_page.dart';

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              child: ValueListenableBuilder<List<OrderData>>(
                valueListenable: OrderState.instance.orders,
                builder: (context, orders, _) {
                  final filtered = orders
                      .where((o) => o.status == _tabs[_selectedTab])
                      .toList();

                  if (filtered.isEmpty) {
                    return const _EmptyState();
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _OrderCard(order: filtered[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const _BottomNavBar(),
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
        separatorBuilder: (_, __) => const SizedBox(width: 20),
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

  @override
  Widget build(BuildContext context) {
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
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: kLightGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.image_outlined,
                      color: kDarkGreen.withValues(alpha: 0.4),
                      size: 20,
                    ),
                  ),
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
        ],
      ),
    );
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
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(
                Icons.home,
                color: kDarkGreen.withValues(alpha: 0.5),
                size: 26,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OrdersPage()),
                );
              },
              child: const Icon(
                Icons.receipt_long_outlined,
                color: kDarkGreen,
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