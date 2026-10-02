import 'package:flutter/material.dart';

class OrderItem {
  final String storeName;
  final String description;
  final int price;
  final int quantity;

  const OrderItem({
    required this.storeName,
    required this.description,
    required this.price,
    required this.quantity,
  });
}

class OrderData {
  final String id;
  final List<OrderItem> items;
  final int total;
  final String status; // 'Perlu dibayar' | 'Akan Diterima' | 'Untuk Diulas' | 'Pesanan Selesai'
  final DateTime createdAt;

  const OrderData({
    required this.id,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
  });
}

/// State global sederhana untuk menyimpan daftar pesanan, mirip pola
/// FavoriteStoresState/SellerAccountState — singleton yang bisa diakses
/// dari halaman manapun tanpa passing data manual.
class OrderState {
  OrderState._internal();
  static final OrderState instance = OrderState._internal();

  final ValueNotifier<List<OrderData>> orders = ValueNotifier<List<OrderData>>(
    [],
  );

  void addOrder(OrderData order) {
    orders.value = [order, ...orders.value];
  }
}
