import 'package:flutter/material.dart';

import '../constants.dart';
import '../services/order_state.dart';
import '../services/cart_state.dart';

class CheckoutPage extends StatefulWidget {
  final List<CartItem> items;
  final int total;

  const CheckoutPage({super.key, required this.items, required this.total});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  int _selectedPayment = 0;

  static const List<_PaymentOption> _payments = [
    _PaymentOption(icon: Icons.account_balance_wallet_outlined, label: 'Dana'),
    _PaymentOption(
      icon: Icons.account_balance_outlined,
      label: 'Transfer Bank',
    ),
    _PaymentOption(
      icon: Icons.payments_outlined,
      label: 'Bayar di Tempat (COD)',
    ),
  ];

  static const int _ongkir = 0; // gratis ongkir simulasi
  int get _grandTotal => widget.total + _ongkir;

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
  }

  void _buatPesanan() {
    final orderItems = widget.items
        .map(
          (e) => OrderItem(
            storeName: e.storeName,
            description: e.description,
            price: e.price,
            quantity: e.quantity,
          ),
        )
        .toList();

    OrderState.instance.addOrder(
      OrderData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        items: orderItems,
        total: _grandTotal,
        status: 'Akan Diterima',
        createdAt: DateTime.now(),
      ),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Pesanan Berhasil Dibuat'),
        content: const Text(
          'Pesananmu sedang diproses dan bisa dilihat di halaman Pesanan.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // tutup dialog
              Navigator.pop(
                context,
                true,
              ); // kembali ke keranjang, beri sinyal sukses
            },
            child: const Text('Oke'),
          ),
        ],
      ),
    );
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
                  const SizedBox(height: 8),
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
                  const SizedBox(height: 16),
                  _OrderSummary(
                    subtotal: widget.total,
                    ongkir: _ongkir,
                    total: _grandTotal,
                    formatPrice: _formatPrice,
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
                  children: const [
                    Text(
                      'Nama Pengguna',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: kDarkGreen,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '(+62) 8xx-xxxx-xxxx',
                      style: TextStyle(fontSize: 12.5, color: Colors.black54),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Jl. Dr. Mansyur, Padang Bulan Selayang I, Medan Selayang, Kota Medan, Sumatera Utara',
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
  }
}

// ==================== ITEM PRODUK DI CHECKOUT ====================
class _CheckoutItemTile extends StatelessWidget {
  final CartItem item;
  final String Function(int) formatPrice;
  const _CheckoutItemTile({required this.item, required this.formatPrice});

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
                decoration: BoxDecoration(
                  color: kLightGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.image_outlined,
                  color: kDarkGreen.withValues(alpha: 0.4),
                ),
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
  final int ongkir;
  final int total;
  final String Function(int) formatPrice;

  const _OrderSummary({
    required this.subtotal,
    required this.ongkir,
    required this.total,
    required this.formatPrice,
  });

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
            label: 'Subtotal Produk',
            value: 'Rp${formatPrice(subtotal)}',
          ),
          const SizedBox(height: 6),
          _SummaryRow(
            label: 'Ongkos Kirim',
            value: ongkir == 0 ? 'Gratis' : 'Rp${formatPrice(ongkir)}',
          ),
          const Divider(height: 20),
          _SummaryRow(
            label: 'Total',
            value: 'Rp${formatPrice(total)}',
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
  final VoidCallback onBuatPesanan;

  const _CheckoutBottomBar({
    required this.total,
    required this.itemCount,
    required this.formatPrice,
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
          children: [
            Expanded(
              child: Column(
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
              onPressed: onBuatPesanan,
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
              child: const Text(
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
