import 'package:flutter/material.dart';

import '../constants.dart';
import '../services/seller_state.dart';
import 'seller_orders_page.dart';
import 'seller_products_page.dart';

class SellerHomePage extends StatelessWidget {
  const SellerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final state = SellerAccountState.instance;

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ValueListenableBuilder<SellerApplication?>(
                valueListenable: state.myApplication,
                builder: (context, app, _) {
                  return Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: kLightGreen,
                          border: Border.all(
                            color: kDarkGreen.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Icon(
                          Icons.storefront,
                          color: kDarkGreen.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              app?.namaToko ?? 'Toko Kamu',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: kDarkGreen,
                              ),
                            ),
                            Text(
                              'Dashboard Penjual',
                              style: TextStyle(
                                fontSize: 12,
                                color: kDarkGreen.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
              ValueListenableBuilder<List<SellerProduct>>(
                valueListenable: state.myProducts,
                builder: (context, products, _) {
                  return ValueListenableBuilder<List<SellerOrder>>(
                    valueListenable: state.myOrders,
                    builder: (context, orders, __) {
                      final orderBaru = orders
                          .where((o) => o.status == OrderStatus.baru)
                          .length;
                      return Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.inventory_2_outlined,
                              label: 'Produk Aktif',
                              value: '${products.length}',
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SellerProductsPage(),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.receipt_long_outlined,
                              label: 'Pesanan Baru',
                              value: '$orderBaru',
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SellerOrdersPage(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Akses Cepat',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: kDarkGreen,
                ),
              ),
              const SizedBox(height: 12),
              _QuickAction(
                icon: Icons.add_box_outlined,
                title: 'Tambah Produk',
                subtitle: 'Tambahkan produk baru ke toko kamu',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SellerProductsPage()),
                ),
              ),
              const SizedBox(height: 10),
              _QuickAction(
                icon: Icons.list_alt_outlined,
                title: 'Kelola Pesanan',
                subtitle: 'Terima atau tolak pesanan yang masuk',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SellerOrdersPage()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kDarkGreen.withValues(alpha: 0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: kDarkGreen, size: 22),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: kDarkGreen,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: kDarkGreen.withValues(alpha: 0.65),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kDarkGreen.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: kLightGreen,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: kDarkGreen, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: kDarkGreen,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: kDarkGreen.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: kDarkGreen.withValues(alpha: 0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}