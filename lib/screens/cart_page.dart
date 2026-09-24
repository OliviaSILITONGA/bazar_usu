import 'package:flutter/material.dart';
import '../constants.dart';

class CartItem {
  final String storeName;
  final String description;
  final int price;
  int quantity;
  bool selected;

  CartItem({
    required this.storeName,
    required this.description,
    required this.price,
    this.quantity = 1,
    this.selected = false,
  });
}

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final List<CartItem> _items = [
    CartItem(storeName: 'PAK SEBLAK', description: 'Seblak dengan mie, kerupuk dll', price: 36000),
    CartItem(storeName: 'PAK SEBLAK', description: 'Seblak dengan mie, kerupuk dll', price: 36000),
    CartItem(storeName: 'PAK SEBLAK', description: 'Seblak dengan mie, kerupuk dll', price: 36000),
    CartItem(storeName: 'PAK SEBLAK', description: 'Seblak dengan mie, kerupuk dll', price: 36000),
  ];

  bool _editMode = false; // true = lagi mode edit (tampil Favoritkan/Hapus)

  bool get _allSelected => _items.every((e) => e.selected);

  int get _total => _items
      .where((e) => e.selected)
      .fold(0, (sum, e) => sum + (e.price * e.quantity));

  void _toggleAll(bool? value) {
    setState(() {
      for (final item in _items) {
        item.selected = value ?? false;
      }
    });
  }

  void _toggleEditMode() {
    setState(() {
      _editMode = !_editMode;
    });
  }

  void _hapusTerpilih() {
    final adaTerpilih = _items.any((e) => e.selected);
    if (!adaTerpilih) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih produk yang ingin dihapus dulu')),
      );
      return;
    }
    setState(() {
      _items.removeWhere((e) => e.selected);
      if (_items.isEmpty) _editMode = false;
    });
  }

  void _favoritkanTerpilih() {
    final adaTerpilih = _items.any((e) => e.selected);
    if (!adaTerpilih) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih produk yang ingin difavoritkan dulu')),
      );
      return;
    }
    // TODO: sambungkan ke logic/database favorit kamu di sini
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Produk ditambahkan ke favorit')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            _CartHeader(
              itemCount: _items.length,
              editMode: _editMode,
              onEditToggle: _toggleEditMode,
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _items.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: kDarkGreen.withValues(alpha: 0.1),
                ),
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return _CartItemTile(
                    item: item,
                    onSelectedChanged: (v) => setState(() => item.selected = v ?? false),
                    onQtyChanged: (q) => setState(() => item.quantity = q),
                  );
                },
              ),
            ),
            _CheckoutBar(
              editMode: _editMode,
              allSelected: _allSelected,
              onSelectAllChanged: _toggleAll,
              total: _total,
              onHapus: _hapusTerpilih,
              onFavoritkan: _favoritkanTerpilih,
            ),
          ],
        ),
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
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kDarkGreen),
            ),
          ),
          TextButton(
            onPressed: onEditToggle,
            child: Text(
              editMode ? 'Selesai' : 'Edit',
              style: TextStyle(color: kDarkGreen.withValues(alpha: 0.6), fontSize: 14),
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
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: kDarkGreen),
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
                decoration: BoxDecoration(
                  color: kLightGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.image_outlined, color: kDarkGreen.withValues(alpha: 0.4)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.description,
                      style: TextStyle(fontSize: 13, color: kDarkGreen.withValues(alpha: 0.85)),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Rp${_formatPrice(item.price)}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.redAccent),
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
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: kDarkGreen),
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

  const _CheckoutBar({
    required this.editMode,
    required this.allSelected,
    required this.onSelectAllChanged,
    required this.total,
    required this.onHapus,
    required this.onFavoritkan,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: kDarkGreen.withValues(alpha: 0.1))),
        ),
        child: Row(
          children: [
            Checkbox(value: allSelected, onChanged: onSelectAllChanged, activeColor: kDarkGreen),
            Text('Semua', style: TextStyle(fontSize: 13, color: kDarkGreen.withValues(alpha: 0.8))),
            const Spacer(),
            if (editMode) ...[
              OutlinedButton(
                onPressed: onFavoritkan,
                style: OutlinedButton.styleFrom(
                  foregroundColor: kDarkGreen,
                  side: BorderSide(color: kDarkGreen.withValues(alpha: 0.4)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: const Text('Favoritkan', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: onHapus,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: const Text('Hapus', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ] else ...[
              Text(
                'Rp${_formatPrice(total)}',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: kDarkGreen),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {}, // sambungkan ke proses checkout nanti
                style: ElevatedButton.styleFrom(
                  backgroundColor: kDarkGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.bold)),
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