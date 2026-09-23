import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import '../constants.dart';

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
            const Expanded(child: _EmptyState()),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 44,
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
                  hintText: 'Cari Pesanan Anda',
                  hintStyle: TextStyle(
                    color: kDarkGreen.withValues(alpha: 0.5),
                    fontSize: 14,
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
            Icon(Icons.receipt_long, color: kDarkGreen, size: 24),
            Icon(
              Icons.chat_bubble_outline,
              color: kDarkGreen.withValues(alpha: 0.5),
              size: 24,
            ),
            Icon(
              Icons.person_outline,
              color: kDarkGreen.withValues(alpha: 0.5),
              size: 26,
            ),
          ],
        ),
      ),
    );
  }
}
