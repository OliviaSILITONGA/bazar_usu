import 'package:flutter/material.dart';

class CartItem {
  final String storeName;
  final String description;
  final int price;
  final String? image;
  int quantity;
  bool selected;

  CartItem({
    required this.storeName,
    required this.description,
    required this.price,
    this.image,
    this.quantity = 1,
    this.selected = false,
  });
}

/// State global keranjang, mirip pola OrderState/FavoriteStoresState —
/// singleton yang bisa diakses dari halaman manapun.
class CartState {
  CartState._internal();
  static final CartState instance = CartState._internal();

  final ValueNotifier<List<CartItem>> items = ValueNotifier<List<CartItem>>([]);

  void addItem({
    required String storeName,
    required String description,
    required int price,
    String? image,
    int quantity = 1,
  }) {
    final current = List<CartItem>.from(items.value);
    final existingIndex = current.indexWhere(
      (e) => e.storeName == storeName && e.description == description,
    );
    if (existingIndex != -1) {
      current[existingIndex].quantity += quantity;
    } else {
      current.add(
        CartItem(
          storeName: storeName,
          description: description,
          price: price,
          image: image,
          quantity: quantity,
        ),
      );
    }
    items.value = current;
  }

  void removeItems(List<CartItem> toRemove) {
    items.value = items.value.where((e) => !toRemove.contains(e)).toList();
  }

  /// Dipanggil setelah mengubah field quantity/selected langsung pada objek
  /// di dalam list, supaya ValueListenableBuilder tahu harus rebuild.
  void notifyChanged() {
    items.value = List<CartItem>.from(items.value);
  }
}