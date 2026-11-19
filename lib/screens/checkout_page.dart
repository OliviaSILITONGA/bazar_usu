import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../services/cart_state.dart';
import '../services/order_state.dart';

class CheckoutPage extends StatefulWidget {
  final List<CartItem> items;
  final int total;

  const CheckoutPage({super.key, required this.items, required this.total});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  int _selectedPayment = 0;
  bool _isSubmitting = false;

  static const List<_PaymentOption> _payments = [
    _PaymentOption(icon: Icons.account_balance_wallet_outlined, label: 'Dana'),
    _PaymentOption(
      icon: Icons.payments_outlined,
      label: 'Bayar di Tempat (COD)',
    ),
    _PaymentOption(icon: Icons.account_balance_outlined, label: 'Bank Lain'),
  ];

  static const int _ongkir = 0;
  int get _grandTotal => widget.total + _ongkir;

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
  }

  Future<void> _buatPesanan() async {
    if (_isSubmitting) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesi login tidak ditemukan. Silakan login ulang.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final firestore = FirebaseFirestore.instance;

      // 1. Ambil profil pembeli (nama & alamat) dari koleksi users
      String buyerName = user.displayName ?? 'Pembeli';
      String buyerPhone = '';
      String buyerAddress =
          'Jl. Dr. Mansyur, Padang Bulan Selayang I, Medan Selayang, Kota Medan';

      final userDoc = await firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final uData = userDoc.data() ?? {};
        final dbName = (uData['nama'] ?? uData['name'] ?? '').toString().trim();
        final dbPhone = (uData['noHp'] ?? uData['phone'] ?? '')
            .toString()
            .trim();
        final dbAddr = (uData['alamat'] ?? uData['address'] ?? '')
            .toString()
            .trim();
        if (dbName.isNotEmpty) buyerName = dbName;
        if (dbPhone.isNotEmpty) buyerPhone = dbPhone;
        if (dbAddr.isNotEmpty) buyerAddress = dbAddr;
      }

      // 2. Kelompokkan item berdasarkan nama toko (agar jika multi-toko tetap rapi)
      final Map<String, List<CartItem>> itemsByStore = {};
      for (final item in widget.items) {
        itemsByStore.putIfAbsent(item.storeName, () => []).add(item);
      }

      // Ambil daftar tenants sekali untuk mencocokkan namaToko -> sellerId
      final tenantsSnap = await firestore.collection('tenants').get();
      final Map<String, String> storeToSellerId = {};
      for (final doc in tenantsSnap.docs) {
        final tData = doc.data();
        final namaToko = (tData['namaToko'] ?? tData['storeName'] ?? '')
            .toString()
            .trim();
        if (namaToko.isNotEmpty) {
          storeToSellerId[namaToko.toLowerCase()] = doc.id;
        }
      }

      final paymentMethod = _payments[_selectedPayment].label;
      final now = DateTime.now();

      // 3. Simpan setiap pesanan toko ke koleksi Firestore 'orders'
      for (final entry in itemsByStore.entries) {
        final storeName = entry.key;
        final storeItems = entry.value;
        final sellerId = storeToSellerId[storeName.toLowerCase()] ?? '';
        final storeSubtotal = storeItems.fold<int>(
          0,
          (sum, e) => sum + (e.price * e.quantity),
        );

        final docRef = await firestore.collection('orders').add({
          'buyerId': user.uid,
          'userId': user.uid,
          'buyerName': buyerName,
          'buyerPhone': buyerPhone,
          'buyerAddress': buyerAddress,
          'sellerId': sellerId,
          'tenantId': sellerId,
          'namaToko': storeName,
          'storeName': storeName,
          'items': storeItems
              .map(
                (e) => {
                  'storeName': e.storeName,
                  'name': e.description,
                  'description': e.description,
                  'price': e.price,
                  'quantity': e.quantity,
                },
              )
              .toList(),
          'total': storeSubtotal,
          'totalPrice': storeSubtotal,
          'paymentMethod': paymentMethod,
          'status': 'Perlu dibayar',
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Sinkronkan juga ke state lokal OrderState
        OrderState.instance.addOrder(
          OrderData(
            id: docRef.id,
            items: storeItems
                .map(
                  (e) => OrderItem(
                    storeName: e.storeName,
                    description: e.description,
                    price: e.price,
                    quantity: e.quantity,
                  ),
                )
                .toList(),
            total: storeSubtotal,
            status: 'Perlu dibayar',
            createdAt: now,
          ),
        );
      }

      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Pesanan Berhasil Dibuat'),
          content: const Text(
            'Pesananmu sudah masuk ke sistem penjual dan bisa dipantau di halaman Pesanan.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context, true);
              },
              child: const Text('Oke'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat pesanan: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            const _CheckoutHeader(title: 'Checkout'),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                children: [
                  const _AddressCard(),
                  const SizedBox(height: 16),
                  const Text(
                    'Produk Dipesan',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: kDarkGreen,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...widget.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _CheckoutItemTile(
                        item: item,
                        formatPrice: _formatPrice,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: kDarkGreen.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.local_shipping_outlined,
                          size: 18,
                          color: kDarkGreen,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Estimasi tiba 1-2 hari • Gratis Ongkir',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: kDarkGreen.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: kDarkGreen.withValues(alpha: 0.4),
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _OrderSummary(
                    subtotal: widget.total,
                    formatPrice: _formatPrice,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Metode Pembayaran',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: kDarkGreen,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: kDarkGreen.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Column(
                      children: List.generate(_payments.length, (index) {
                        final payment = _payments[index];
                        final isSelected = index == _selectedPayment;
                        return Column(
                          children: [
                            InkWell(
                              onTap: () =>
                                  setState(() => _selectedPayment = index),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      payment.icon,
                                      size: 20,
                                      color: kDarkGreen,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        payment.label,
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          color: kDarkGreen,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      isSelected
                                          ? Icons.check_circle
                                          : Icons.radio_button_unchecked,
                                      color: isSelected
                                          ? kDarkGreen
                                          : Colors.black26,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (index != _payments.length - 1)
                              Divider(
                                height: 1,
                                indent: 50,
                                color: kDarkGreen.withValues(alpha: 0.08),
                              ),
                          ],
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _CheckoutBottomBar(
        total: _grandTotal,
        itemCount: widget.items.length,
        formatPrice: _formatPrice,
        isSubmitting: _isSubmitting,
        onBuatPesanan: _buatPesanan,
      ),
    );
  }
}

class _PaymentOption {
  final IconData icon;
  final String label;
  const _PaymentOption({required this.icon, required this.label});
}

// ==================== HEADER ====================
class _CheckoutHeader extends StatelessWidget {
  final String title;
  const _CheckoutHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            color: kDarkGreen,
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: kDarkGreen,
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

// ==================== ALAMAT ====================
class _AddressCard extends StatelessWidget {
  const _AddressCard();

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return StreamBuilder<DocumentSnapshot>(
      stream: uid.isNotEmpty
          ? FirebaseFirestore.instance.collection('users').doc(uid).snapshots()
          : const Stream.empty(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
        final name =
            (data['nama'] ??
                    data['name'] ??
                    FirebaseAuth.instance.currentUser?.displayName ??
                    'Nama Pengguna')
                .toString();
        final phone = (data['noHp'] ?? data['phone'] ?? '(+62) 8xx-xxxx-xxxx')
            .toString();
        final address =
            (data['alamat'] ??
                    data['address'] ??
                    'Jl. Dr. Mansyur, Padang Bulan Selayang I, Medan Selayang, Kota Medan, Sumatera Utara')
                .toString();

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kDarkGreen.withValues(alpha: 0.12)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on, color: kDarkGreen, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: kDarkGreen,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          phone,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: kDarkGreen.withValues(alpha: 0.75),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: kDarkGreen.withValues(alpha: 0.4),
                size: 20,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ==================== ITEM PRODUK DI CHECKOUT ====================
class _CheckoutItemTile extends StatelessWidget {
  final CartItem item;
  final String Function(int) formatPrice;
  const _CheckoutItemTile({required this.item, required this.formatPrice});

  Widget _buildImage(String? imageSource) {
    final fallback = Icon(
      Icons.image_outlined,
      color: kDarkGreen.withValues(alpha: 0.4),
    );

    if (imageSource == null || imageSource.isEmpty) return fallback;

    if (imageSource.startsWith('assets/')) {
      return Image.asset(
        imageSource,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
      );
    }

    if (imageSource.startsWith('http://') ||
        imageSource.startsWith('https://')) {
      return Image.network(
        imageSource,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
      );
    }

    try {
      final cleanBase64 = imageSource.contains(',')
          ? imageSource.split(',').last
          : imageSource;
      return Image.memory(
        base64Decode(cleanBase64),
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
      );
    } catch (_) {
      return fallback;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kDarkGreen.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.storeName,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: kDarkGreen,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: kLightGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: _buildImage(item.image),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: kDarkGreen.withValues(alpha: 0.85),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'x${item.quantity}',
                      style: TextStyle(
                        fontSize: 12,
                        color: kDarkGreen.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Rp${formatPrice(item.price * item.quantity)}',
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==================== RINGKASAN PESANAN ====================
class _OrderSummary extends StatelessWidget {
  final int subtotal;
  final String Function(int) formatPrice;

  const _OrderSummary({required this.subtotal, required this.formatPrice});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kDarkGreen.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Pesanan',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: kDarkGreen,
            ),
          ),
          const SizedBox(height: 10),
          _SummaryRow(
            label: 'Harga Produk',
            value: 'Rp${formatPrice(subtotal)}',
            bold: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: bold ? 14 : 13,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            color: kDarkGreen,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: bold ? 15 : 13,
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            color: bold ? kDarkGreen : kDarkGreen.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

// ==================== BAR BAWAH ====================
class _CheckoutBottomBar extends StatelessWidget {
  final int total;
  final int itemCount;
  final String Function(int) formatPrice;
  final bool isSubmitting;
  final VoidCallback onBuatPesanan;

  const _CheckoutBottomBar({
    required this.total,
    required this.itemCount,
    required this.formatPrice,
    required this.isSubmitting,
    required this.onBuatPesanan,
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total ($itemCount item)',
                    style: TextStyle(
                      fontSize: 12,
                      color: kDarkGreen.withValues(alpha: 0.6),
                    ),
                  ),
                  Text(
                    'Rp${formatPrice(total)}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: kDarkGreen,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: isSubmitting ? null : onBuatPesanan,
              style: ElevatedButton.styleFrom(
                backgroundColor: kDarkGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Buat Pesanan',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
