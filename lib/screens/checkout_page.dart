import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constants.dart';
import '../services/address_state.dart';
import '../services/cart_state.dart';
import '../services/order_state.dart';
import 'saved_addresses_page.dart';

class CheckoutPage extends StatefulWidget {
  final List<CartItem> items;
  final int total;

  const CheckoutPage({super.key, required this.items, required this.total});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  int _selectedPayment = 0;
  int _deliveryMode = 0; // 0 = Diantar, 1 = Ambil Sendiri
  bool _isSubmitting = false;
  AddressData? _selectedAddress;
  String? _selectedAddressId;

  static const int _outsideUsuShippingFee = 3000;

  static const List<_PaymentOption> _payments = [
    _PaymentOption(icon: Icons.account_balance_wallet_outlined, label: 'Dana'),
    _PaymentOption(
      icon: Icons.payments_outlined,
      label: 'Bayar di Tempat (COD)',
    ),
    _PaymentOption(icon: Icons.account_balance_outlined, label: 'Bank Lain'),
  ];

  bool get _isSelfPickup => _deliveryMode == 1;

  bool _isWithinFreeDeliveryArea(AddressData address) {
    final text = '${address.label} ${address.fullAddress}'.toLowerCase();

    // Cek khusus Jalan Pembangunan: hanya gratis jika mengarah ke Pintu 1 s.d. Pintu 4 USU
    final mentionsPembangunan = RegExp(r'\bpembangunan\b').hasMatch(text);
    if (mentionsPembangunan) {
      final hasGate1To4 = RegExp(
        r'(pintu\s*(1|2|3|4|satu|dua|tiga|empat)|gate\s*(1|2|3|4))',
      ).hasMatch(text);
      final hasBeyondGate4 = RegExp(
        r'(pintu\s*(5|6|7|8|9|lima|enam|tujuh|delapan|sembilan)|gate\s*(5|6|7|8|9)|setia\s*budi)',
      ).hasMatch(text);

      if (hasBeyondGate4 && !hasGate1To4) {
        return false;
      }
      return hasGate1To4;
    }

    return RegExp(
      r'(\busu\b|universitas sumatera utara|padang bulan|dr\.\s*mansyur|jaminginting|jamin ginting|tanjung sari|usu\s*kuala)',
    ).hasMatch(text);
  }

  int _calculateShippingFee(AddressData address) {
    if (_isSelfPickup) return 0;
    return _isWithinFreeDeliveryArea(address) ? 0 : _outsideUsuShippingFee;
  }

  String _shippingLabel(AddressData address) {
    if (_isSelfPickup) {
      return 'Ambil Sendiri di Lapak • Gratis Ongkir';
    }
    final fee = _calculateShippingFee(address);
    return fee == 0
        ? 'Gratis Ongkir (Area USU s.d. Pintu 4)'
        : 'Ongkir Rp3.000 (Di Luar Area USU)';
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
  }

  Future<void> _openAddressPicker(
    BuildContext context,
    List<AddressData> addresses,
    AddressData activeAddress,
  ) async {
    final chosen = await showModalBottomSheet<AddressData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _AddressPickerSheet(
        addresses: addresses,
        activeAddress: activeAddress,
      ),
    );

    if (chosen != null && mounted) {
      setState(() {
        _selectedAddress = chosen;
        _selectedAddressId = chosen.id;
      });
    }
  }

  Future<void> _buatPesanan({
    required AddressData activeAddress,
    required int shippingFee,
  }) async {
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

      // Kelompokkan item berdasarkan nama toko (agar jika multi-toko tetap rapi)
      final Map<String, List<CartItem>> itemsByStore = {};
      for (final item in widget.items) {
        itemsByStore.putIfAbsent(item.storeName, () => []).add(item);
      }

      // Ambil daftar tenants sekali untuk mencocokkan namaToko -> sellerId & lokasi toko
      final tenantsSnap = await firestore.collection('tenants').get();
      final Map<String, String> storeToSellerId = {};
      final Map<String, String> storeToLocation = {};
      for (final doc in tenantsSnap.docs) {
        final tData = doc.data();
        final namaToko = (tData['namaToko'] ?? tData['storeName'] ?? '')
            .toString()
            .trim();
        if (namaToko.isNotEmpty) {
          final key = namaToko.toLowerCase();
          storeToSellerId[key] = doc.id;
          final loc =
              (tData['alamatToko'] ??
                      tData['lokasiBazar'] ??
                      tData['lokasi'] ??
                      tData['alamat'] ??
                      '')
                  .toString()
                  .trim();
          if (loc.isNotEmpty) {
            storeToLocation[key] = loc;
          }
        }
      }

      final paymentMethod = _payments[_selectedPayment].label;
      final deliveryMethodText = _isSelfPickup ? 'Ambil Sendiri' : 'Diantar';
      final now = DateTime.now();
      final storeEntries = itemsByStore.entries.toList();

      // Simpan setiap pesanan toko ke koleksi Firestore 'orders'
      for (var i = 0; i < storeEntries.length; i++) {
        final entry = storeEntries[i];
        final storeName = entry.key;
        final storeItems = entry.value;
        final key = storeName.toLowerCase();
        final sellerId = storeToSellerId[key] ?? '';
        final storePickupLocation = storeToLocation[key] ?? '';
        final storeSubtotal = storeItems.fold<int>(
          0,
          (sum, e) => sum + (e.price * e.quantity),
        );
        final storeShipping = i == 0 ? shippingFee : 0;
        final storeGrandTotal = storeSubtotal + storeShipping;

        final docRef = await firestore.collection('orders').add({
          'buyerId': user.uid,
          'userId': user.uid,
          'buyerName': activeAddress.recipientName,
          'buyerPhone': activeAddress.phone,
          'buyerAddress': _isSelfPickup
              ? 'Ambil Sendiri di Lapak'
              : activeAddress.fullAddress,
          'addressLabel': _isSelfPickup ? 'Ambil Sendiri' : activeAddress.label,
          'deliveryMethod': deliveryMethodText,
          'pickupLocation': _isSelfPickup ? storePickupLocation : '',
          'shippingFee': storeShipping,
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
          'total': storeGrandTotal,
          'totalPrice': storeGrandTotal,
          'paymentMethod': paymentMethod,
          'status': 'Perlu dibayar',
          'createdAt': FieldValue.serverTimestamp(),
        });

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
            total: storeGrandTotal,
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
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final storeNames = widget.items
        .map((e) => e.storeName.trim())
        .where((name) => name.isNotEmpty)
        .toSet()
        .toList();

    return StreamBuilder<DocumentSnapshot>(
      stream: uid.isNotEmpty
          ? FirebaseFirestore.instance.collection('users').doc(uid).snapshots()
          : const Stream.empty(),
      builder: (context, userSnap) {
        final userData = userSnap.data?.data() as Map<String, dynamic>? ?? {};
        final fallbackName =
            (userData['nama'] ??
                    userData['name'] ??
                    FirebaseAuth.instance.currentUser?.displayName ??
                    'Pembeli')
                .toString()
                .trim();
        final fallbackPhone = (userData['noHp'] ?? userData['phone'] ?? '')
            .toString()
            .trim();
        final fallbackAddress =
            (userData['alamat'] ??
                    userData['address'] ??
                    'Jl. Dr. Mansyur, Padang Bulan Selayang I, Medan Selayang, Kota Medan, Sumatera Utara')
                .toString()
                .trim();

        return StreamBuilder<List<AddressData>>(
          stream: AddressState.instance.addressesStream(),
          builder: (context, addrSnap) {
            final savedAddresses = addrSnap.data ?? const <AddressData>[];

            AddressData? effectiveSelected;
            if (_selectedAddressId != null) {
              for (final a in savedAddresses) {
                if (a.id == _selectedAddressId) {
                  effectiveSelected = a;
                  break;
                }
              }
            }
            effectiveSelected ??= _selectedAddress;

            AddressData? primaryAddress;
            if (savedAddresses.isNotEmpty) {
              primaryAddress = savedAddresses.firstWhere(
                (a) => a.isPrimary,
                orElse: () => savedAddresses.first,
              );
            }

            final activeAddress =
                effectiveSelected ??
                primaryAddress ??
                AddressData(
                  label: 'Utama',
                  recipientName: fallbackName.isEmpty
                      ? 'Pembeli'
                      : fallbackName,
                  phone: fallbackPhone.isEmpty
                      ? '(+62) 8xx-xxxx-xxxx'
                      : fallbackPhone,
                  fullAddress: fallbackAddress,
                  isPrimary: true,
                );

            final shippingFee = _calculateShippingFee(activeAddress);
            final grandTotal = widget.total + shippingFee;
            final shippingText = _shippingLabel(activeAddress);

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
                          if (!_isSelfPickup) ...[
                            _AddressCard(
                              address: activeAddress,
                              onTap: () => _openAddressPicker(
                                context,
                                savedAddresses,
                                activeAddress,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
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
                          const Text(
                            'Metode Pengiriman',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: kDarkGreen,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _DeliveryModeCard(
                            selectedMode: _deliveryMode,
                            shippingText: shippingText,
                            storeNames: storeNames,
                            onSelectMode: (mode) =>
                                setState(() => _deliveryMode = mode),
                            onTapShippingInfo: _isSelfPickup
                                ? null
                                : () => _openAddressPicker(
                                    context,
                                    savedAddresses,
                                    activeAddress,
                                  ),
                          ),
                          const SizedBox(height: 16),
                          _OrderSummary(
                            subtotal: widget.total,
                            shippingFee: shippingFee,
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
                              children: List.generate(_payments.length, (
                                index,
                              ) {
                                final payment = _payments[index];
                                final isSelected = index == _selectedPayment;
                                return Column(
                                  children: [
                                    InkWell(
                                      onTap: () => setState(
                                        () => _selectedPayment = index,
                                      ),
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
                                                  : Icons
                                                        .radio_button_unchecked,
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
                                        color: kDarkGreen.withValues(
                                          alpha: 0.08,
                                        ),
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
                total: grandTotal,
                itemCount: widget.items.length,
                formatPrice: _formatPrice,
                isSubmitting: _isSubmitting,
                onBuatPesanan: () => _buatPesanan(
                  activeAddress: activeAddress,
                  shippingFee: shippingFee,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _PaymentOption {
  final IconData icon;
  final String label;
  const _PaymentOption({required this.icon, required this.label});
}

// ==================== PILIHAN DIANTAR / AMBIL SENDIRI ====================
class _DeliveryModeCard extends StatelessWidget {
  final int selectedMode; // 0 = Diantar, 1 = Ambil Sendiri
  final String shippingText;
  final List<String> storeNames;
  final ValueChanged<int> onSelectMode;
  final VoidCallback? onTapShippingInfo;

  const _DeliveryModeCard({
    required this.selectedMode,
    required this.shippingText,
    required this.storeNames,
    required this.onSelectMode,
    this.onTapShippingInfo,
  });

  @override
  Widget build(BuildContext context) {
    final isSelfPickup = selectedMode == 1;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kDarkGreen.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: _ModeChoiceButton(
                    icon: Icons.delivery_dining_outlined,
                    label: 'Diantar',
                    selected: !isSelfPickup,
                    onTap: () => onSelectMode(0),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ModeChoiceButton(
                    icon: Icons.storefront_outlined,
                    label: 'Ambil Sendiri',
                    selected: isSelfPickup,
                    onTap: () => onSelectMode(1),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: kDarkGreen.withValues(alpha: 0.08)),
          InkWell(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(14),
            ),
            onTap: onTapShippingInfo,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: isSelfPickup
                  ? _PickupStoreInfo(storeNames: storeNames)
                  : Row(
                      children: [
                        const Icon(
                          Icons.local_shipping_outlined,
                          size: 18,
                          color: kDarkGreen,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Pengantaran s.d. waktu danus tutup • $shippingText',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: kDarkGreen.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                        if (onTapShippingInfo != null)
                          Icon(
                            Icons.chevron_right,
                            color: kDarkGreen.withValues(alpha: 0.4),
                            size: 18,
                          ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeChoiceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModeChoiceButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? kDarkGreen : kBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? kDarkGreen : kDarkGreen.withValues(alpha: 0.12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 17, color: selected ? Colors.white : kDarkGreen),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: selected ? Colors.white : kDarkGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickupStoreInfo extends StatelessWidget {
  final List<String> storeNames;
  const _PickupStoreInfo({required this.storeNames});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('tenants').snapshots(),
      builder: (context, snap) {
        final Map<String, String> storeLocations = {};
        if (snap.hasData) {
          for (final doc in snap.data!.docs) {
            final tData = doc.data() as Map<String, dynamic>;
            final namaToko = (tData['namaToko'] ?? tData['storeName'] ?? '')
                .toString()
                .trim();
            if (namaToko.isNotEmpty) {
              final loc =
                  (tData['alamatToko'] ??
                          tData['lokasiBazar'] ??
                          tData['lokasi'] ??
                          tData['alamat'] ??
                          '')
                      .toString()
                      .trim();
              storeLocations[namaToko.toLowerCase()] = loc.isNotEmpty
                  ? loc
                  : 'Lokasi lapak penjual (Gratis Ongkir)';
            }
          }
        }

        final targets = storeNames.isEmpty ? ['Toko Penjual'] : storeNames;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.storefront_outlined,
                  size: 18,
                  color: kDarkGreen,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ambil di lapak s.d. waktu danus tutup • Gratis Ongkir',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: kDarkGreen.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ...targets.map((store) {
              final locText =
                  storeLocations[store.toLowerCase()] ??
                  'Lokasi lapak penjual (Gratis Ongkir)';
              return Padding(
                padding: const EdgeInsets.only(left: 26, top: 2),
                child: Text(
                  '$store: $locText',
                  style: TextStyle(
                    fontSize: 12,
                    color: kDarkGreen.withValues(alpha: 0.72),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }
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

// ==================== KARTU ALAMAT ====================
class _AddressCard extends StatelessWidget {
  final AddressData address;
  final VoidCallback onTap;

  const _AddressCard({required this.address, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: kDarkGreen.withValues(alpha: 0.12)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
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
                            address.recipientName,
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
                          address.phone,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Colors.black54,
                          ),
                        ),
                        if (address.label.trim().isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color: kLightGreen,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              address.label,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: kDarkGreen,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address.fullAddress,
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
        ),
      ),
    );
  }
}

// ==================== BOTTOM SHEET PILIH ALAMAT ====================
class _AddressPickerSheet extends StatelessWidget {
  final List<AddressData> addresses;
  final AddressData activeAddress;

  const _AddressPickerSheet({
    required this.addresses,
    required this.activeAddress,
  });

  bool _isSameAddress(AddressData a, AddressData b) {
    if (a.id != null && b.id != null && a.id!.isNotEmpty && b.id!.isNotEmpty) {
      return a.id == b.id;
    }
    return a.recipientName == b.recipientName &&
        a.phone == b.phone &&
        a.fullAddress == b.fullAddress;
  }

  bool _isWithinFreeDeliveryArea(AddressData address) {
    final text = '${address.label} ${address.fullAddress}'.toLowerCase();

    final mentionsPembangunan = RegExp(r'\bpembangunan\b').hasMatch(text);
    if (mentionsPembangunan) {
      final hasGate1To4 = RegExp(
        r'(pintu\s*(1|2|3|4|satu|dua|tiga|empat)|gate\s*(1|2|3|4))',
      ).hasMatch(text);
      final hasBeyondGate4 = RegExp(
        r'(pintu\s*(5|6|7|8|9|lima|enam|tujuh|delapan|sembilan)|gate\s*(5|6|7|8|9)|setia\s*budi)',
      ).hasMatch(text);

      if (hasBeyondGate4 && !hasGate1To4) {
        return false;
      }
      return hasGate1To4;
    }

    return RegExp(
      r'(\busu\b|universitas sumatera utara|padang bulan|dr\.\s*mansyur|jaminginting|jamin ginting|tanjung sari|usu\s*kuala)',
    ).hasMatch(text);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Pilih Alamat Pengiriman',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: kDarkGreen,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SavedAddressesPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit_location_alt_outlined, size: 17),
                  label: const Text(
                    'Kelola',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: TextButton.styleFrom(foregroundColor: kDarkGreen),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (addresses.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Text(
                      'Belum ada alamat lain di daftar Alamat Tersimpan.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: kDarkGreen.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SavedAddressesPage(),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kDarkGreen,
                        side: const BorderSide(color: kDarkGreen),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('Buka Alamat Tersimpan'),
                    ),
                  ],
                ),
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: addresses.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final addr = addresses[index];
                    final isSelected = _isSameAddress(addr, activeAddress);
                    final freeOngkir = _isWithinFreeDeliveryArea(addr);

                    return InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => Navigator.pop(context, addr),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? kLightGreen.withValues(alpha: 0.45)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? kDarkGreen
                                : kDarkGreen.withValues(alpha: 0.15),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color: isSelected ? kDarkGreen : Colors.black38,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        addr.label.isEmpty
                                            ? 'Alamat'
                                            : addr.label,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: kDarkGreen,
                                        ),
                                      ),
                                      if (addr.isPrimary) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 1.5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: kLightGreen,
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: const Text(
                                            'Utama',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: kDarkGreen,
                                            ),
                                          ),
                                        ),
                                      ],
                                      const Spacer(),
                                      Text(
                                        freeOngkir
                                            ? 'Gratis Ongkir'
                                            : 'Ongkir Rp3.000',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: freeOngkir
                                              ? kDarkGreen
                                              : Colors.redAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${addr.recipientName} (${addr.phone})',
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    addr.fullAddress,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: kDarkGreen.withValues(alpha: 0.75),
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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
  final int shippingFee;
  final String Function(int) formatPrice;

  const _OrderSummary({
    required this.subtotal,
    required this.shippingFee,
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
            label: 'Harga Produk',
            value: 'Rp${formatPrice(subtotal)}',
          ),
          const SizedBox(height: 6),
          _SummaryRow(
            label: 'Ongkos Kirim',
            value: shippingFee == 0
                ? 'Gratis'
                : 'Rp${formatPrice(shippingFee)}',
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
