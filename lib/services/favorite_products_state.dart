import 'package:flutter/material.dart';

class FavoriteProductData {
  final String storeName;
  final String description;
  final int price;

  const FavoriteProductData({
    required this.storeName,
    required this.description,
    required this.price,
  });
}

class FavoriteProductsState {
  FavoriteProductsState._internal();
  static final FavoriteProductsState instance =
      FavoriteProductsState._internal();

  final ValueNotifier<List<FavoriteProductData>> products =
      ValueNotifier<List<FavoriteProductData>>([]);

  void addProduct(FavoriteProductData product) {
    final alreadyExists = products.value.any(
      (p) =>
          p.storeName == product.storeName &&
          p.description == product.description,
    );
    if (!alreadyExists) {
      products.value = [product, ...products.value];
    }
  }

  void remove(FavoriteProductData product) {
    products.value = products.value
        .where(
          (p) =>
              !(p.storeName == product.storeName &&
                  p.description == product.description),
        )
        .toList();
  }
}
