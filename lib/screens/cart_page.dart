import 'package:flutter/material.dart';

import '../constants.dart';
import '../services/cart_state.dart';
import '../services/favorite_products_state.dart';
import 'checkout_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool _editMode = false;

  void _toggleEditMode() {
    setState(() => _editMode = !_editMode);
  }

  void _hapusTerpilih(List<CartItem> items) {
    final selected = items.where((e) => e.selected).toList();
    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih produk yang ingin dihapus dulu')),
      );
      return;
    }
    CartState.instance.removeItems(selected);
    if (CartState.instance.items.value.isEmpty) {
      setState(() => _editMode = false);
    }
  }

  void _favoritkanTerpilih(List<CartItem> items) {
    final selected = items.where((e) => e.selected).toList();
    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih produk yang ingin difavoritkan dulu'),
        ),
      );
      return;
    }
    for (final item in selected) {
      FavoriteProductsState.instance.addProduct(
        FavoriteProductData(
          storeName: item.storeName,
          description: item.description,
          price: item.price,
        ),
      );
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Produk ditambahkan ke favorit')),
    );
  }

  Future<void> _handleCheckout(List<CartItem> items, int total) async {
    final selected = items.where((e) => e.selected).toList();
    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih produk yang ingin di-checkout dulu'),
        ),
      );
      return;
    }

    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutPage(items: selected, total: total),
      ),
    );

    if (result == true && mounted) {
      CartState.instance.removeItems(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: ValueListenableBuilder<List<CartItem>>(
          valueListenable: CartState.instance.items,
          builder: (context, items, _) {
            final allSelected =
                items.isNotEmpty && items.every((e) => e.selected);
            final total = items
                .where((e) => e.selected)
                .fold<int>(0, (sum, e) => sum + e.price * e.quantity);

            return Column(
              children: [
                _CartHeader(
                  itemCount: items.length,
                  editMode: _editMode,
                  onEditToggle: _toggleEditMode,
                ),
                Expanded(
                  child: items.isEmpty
                      ? const _EmptyCart()
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: items.length,
                          separatorBuilder: (_, __) => Divider(
                            height: 1,
                            color: kDarkGreen.withValues(alpha: 0.1),
                          ),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return _CartItemTile(
                              item: item,
                              onSelectedChanged: (v) {
                                item.selected = v ?? false;
                                CartState.instance.notifyChanged();
                              },
                              onQtyChanged: (q) {
                                item.quantity = q;
                                CartState.instance.notifyChanged();
                              },
                            );
                          },
                        ),
                ),
                _CheckoutBar(
                  editMode: _editMode,
                  allSelected: allSelected,
                  onSelectAllChanged: (v) {
                    for (final e in items) {
                      e.selected = v ?? false;
                    }
                    CartState.instance.notifyChanged();
                  },
                  total: total,
                  onHapus: () => _hapusTerpilih(items),
                  onFavoritkan: () => _favoritkanTerpilih(items),
                  onCheckout: () => _handleCheckout(items, total),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ==================== STATE KOSONG ====================
class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 48,
            color: kDarkGreen.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          Text(
            'Keranjang masih kosong',
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

// ==================== HEADER ====================
class _CartHeader extends StatelessWidget {
  final int itemCount;
  final bool editMode;
  final VoidCallback onEditToggle;

  const _CartHeader({
    required this.itemCount,
    required this.editMode,
    required this.onEditToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios_new, size: 18, color: kDarkGreen),
          ),
          Expanded(
            child: Text(
              'Keranjang($itemCount)',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: kDarkGreen,
              ),
            ),
          ),
          TextButton(
            onPressed: onEditToggle,
            child: Text(
              editMode ? 'Selesai' : 'Edit',
              style: TextStyle(
                color: kDarkGreen.withValues(alpha: 0.6),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== ITEM KERANJANG ====================
class _CartItemTile extends StatelessWidget {
  final CartItem item;
  final ValueChanged<bool?> onSelectedChanged;
  final ValueChanged<int> onQtyChanged;

  const _CartItemTile({
    required this.item,
    required this.onSelectedChanged,
    required this.onQtyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: item.selected,
                onChanged: onSelectedChanged,
                activeColor: kDarkGreen,
              ),
              Text(
                item.storeName,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: kDarkGreen,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(width: 4),
              Checkbox(
                value: item.selected,
                onChanged: onSelectedChanged,
                activeColor: kDarkGreen,
              ),
              const SizedBox(width: 4),
              Container(
                width: 64,
                height: 64,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: kLightGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: (item.image != null && item.image!.isNotEmpty)
                    ? Image.asset(
                        item.image!,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.image_outlined,
                          color: kDarkGreen.withValues(alpha: 0.4),
                        ),
                      )
                    : Icon(
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
                    const SizedBox(height: 6),
                    Text(
                      'Rp${_formatPrice(item.price)}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _QuantityStepper(
                      quantity: item.quantity,
                      onChanged: onQtyChanged,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
  }
}

// ==================== STEPPER JUMLAH ====================
class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;

  const _QuantityStepper({required this.quantity, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kLightGreen,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: quantity > 1 ? () => onChanged(quantity - 1) : null,
            icon: const Icon(Icons.remove, size: 16),
            color: kDarkGreen,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          Text(
            '$quantity',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: kDarkGreen,
            ),
          ),
          IconButton(
            onPressed: () => onChanged(quantity + 1),
            icon: const Icon(Icons.add, size: 16),
            color: kDarkGreen,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }
}

// ==================== BAR CHECKOUT / EDIT ====================
class _CheckoutBar extends StatelessWidget {
  final bool editMode;
  final bool allSelected;
  final ValueChanged<bool?> onSelectAllChanged;
  final int total;
  final VoidCallback onHapus;
  final VoidCallback onFavoritkan;
  final VoidCallback onCheckout;

  const _CheckoutBar({
    required this.editMode,
    required this.allSelected,
    required this.onSelectAllChanged,
    required this.total,
    required this.onHapus,
    required this.onFavoritkan,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: kDarkGreen.withValues(alpha: 0.1)),
          ),
        ),
        child: Row(
          children: [
            Checkbox(
              value: allSelected,
              onChanged: onSelectAllChanged,
              activeColor: kDarkGreen,
            ),
            Text(
              'Semua',
              style: TextStyle(
                fontSize: 13,
                color: kDarkGreen.withValues(alpha: 0.8),
              ),
            ),
            const Spacer(),
            if (editMode) ...[
              OutlinedButton(
                onPressed: onFavoritkan,
                style: OutlinedButton.styleFrom(
                  foregroundColor: kDarkGreen,
                  side: BorderSide(color: kDarkGreen.withValues(alpha: 0.4)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Favoritkan',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: onHapus,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Hapus',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ] else ...[
              Text(
                'Rp${_formatPrice(total)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: kDarkGreen,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: onCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kDarkGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Checkout',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
  }
}