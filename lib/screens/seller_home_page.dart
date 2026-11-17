import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../services/database_service.dart';
import 'seller_orders_page.dart';
import 'seller_products_page.dart';

typedef TenantMap = Map<String, dynamic>;

class SellerHomePage extends StatefulWidget {
  const SellerHomePage({super.key});

  @override
  State<SellerHomePage> createState() => _SellerHomePageState();
}

class _SellerHomePageState extends State<SellerHomePage> {
  String? _uid;
  Stream<TenantMap?>? _tenantStream;

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser?.uid;
    if (_uid != null) {
      _tenantStream = DatabaseService().tenantStream(_uid!);
    }
  }

  Uint8List? _decodePhoto(String? base64Str) {
    if (base64Str == null || base64Str.isEmpty) return null;
    try {
      return base64Decode(base64Str);
    } catch (_) {
      return null;
    }
  }

  // Menghitung produk milik penjual dari koleksi 'products'
  Stream<int> _activeProductsCountStream(String uid) {
    return FirebaseFirestore.instance.collection('products').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.where((doc) {
        final data = doc.data();
        final ownerId =
            data['sellerId'] ?? data['tenantId'] ?? data['uid'] ?? '';
        return ownerId == uid;
      }).length;
    });
  }

  // Menghitung pesanan berstatus baru/pending milik penjual dari koleksi 'orders'
  Stream<int> _newOrdersCountStream(String uid) {
    return FirebaseFirestore.instance.collection('orders').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.where((doc) {
        final data = doc.data();
        final ownerId =
            data['sellerId'] ?? data['tenantId'] ?? data['uid'] ?? '';
        final status = (data['status'] ?? '').toString().toLowerCase();
        final isNew =
            status == 'baru' ||
            status == 'pending' ||
            status == 'menunggu' ||
            status == 'menunggu konfirmasi';
        return ownerId == uid && isNew;
      }).length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ---------- Header Profil Toko (Dari Firestore 'tenants') ----------
              if (_tenantStream == null)
                _buildHeader('Toko Kamu', null)
              else
                StreamBuilder<TenantMap?>(
                  stream: _tenantStream,
                  builder: (context, snapshot) {
                    final data = snapshot.data;
                    final namaToko =
                        (data?['namaToko'] ?? data?['storeName'] ?? 'Toko Kamu')
                            .toString()
                            .trim();
                    final photoBytes = _decodePhoto(
                      data?['fotoBase64'] as String?,
                    );

                    return _buildHeader(
                      namaToko.isNotEmpty ? namaToko : 'Toko Kamu',
                      photoBytes,
                    );
                  },
                ),
              const SizedBox(height: 20),

              // ---------- Statistik Produk Aktif & Pesanan Baru (Hanya Tampilan) ----------
              if (_uid == null)
                _buildStatsRow(0, 0)
              else
                StreamBuilder<int>(
                  stream: _activeProductsCountStream(_uid!),
                  builder: (context, prodSnapshot) {
                    final productCount = prodSnapshot.data ?? 0;

                    return StreamBuilder<int>(
                      stream: _newOrdersCountStream(_uid!),
                      builder: (context, orderSnapshot) {
                        final newOrderCount = orderSnapshot.data ?? 0;
                        return _buildStatsRow(productCount, newOrderCount);
                      },
                    );
                  },
                ),
              const SizedBox(height: 24),

              // ---------- Akses Cepat (Bisa Ditekan) ----------
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

  Widget _buildHeader(String namaToko, Uint8List? photoBytes) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: kLightGreen,
            border: Border.all(color: kDarkGreen.withValues(alpha: 0.3)),
            image: photoBytes != null
                ? DecorationImage(
                    image: MemoryImage(photoBytes),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: photoBytes == null
              ? Icon(Icons.storefront, color: kDarkGreen.withValues(alpha: 0.7))
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                namaToko,
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
  }

  Widget _buildStatsRow(int productCount, int newOrderCount) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.inventory_2_outlined,
            label: 'Produk Aktif',
            value: '$productCount',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.receipt_long_outlined,
            label: 'Pesanan Baru',
            value: '$newOrderCount',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
