import 'package:flutter/material.dart';

/// State global sederhana untuk menyimpan daftar nama toko yang diikuti
/// (favorit) oleh pengguna. Dibuat singleton seperti SellerAccountState,
/// supaya bisa diakses dari halaman mana pun tanpa passing data manual.
class FavoriteStoresState {
  FavoriteStoresState._internal();
  static final FavoriteStoresState instance = FavoriteStoresState._internal();

  final ValueNotifier<Set<String>> favorites = ValueNotifier<Set<String>>({});

  bool isFavorite(String storeName) {
    return favorites.value.contains(storeName);
  }

  void toggle(String storeName) {
    final updated = Set<String>.from(favorites.value);
    if (updated.contains(storeName)) {
      updated.remove(storeName);
    } else {
      updated.add(storeName);
    }
    favorites.value = updated;
  }
}
