import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FavoriteProductData {
  final String? id;
  final String storeName;
  final String description;
  final int price;
  final String image;

  const FavoriteProductData({
    this.id,
    required this.storeName,
    required this.description,
    required this.price,
    this.image = '',
  });

  factory FavoriteProductData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final rawPrice = data['price'] ?? 0;
    final parsedPrice = rawPrice is int
        ? rawPrice
        : int.tryParse(rawPrice.toString()) ?? 0;

    return FavoriteProductData(
      id: doc.id,
      storeName: (data['storeName'] ?? '').toString(),
      description: (data['description'] ?? data['name'] ?? '').toString(),
      price: parsedPrice,
      image: (data['image'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'storeName': storeName,
      'description': description,
      'price': price,
      'image': image,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

typedef FavProductList = List<FavoriteProductData>;

class FavoriteProductsState {
  FavoriteProductsState._internal() {
    _listenToFirestore();
  }
  static final FavoriteProductsState instance =
      FavoriteProductsState._internal();

  final ValueNotifier<FavProductList> products = ValueNotifier<FavProductList>(
    [],
  );

  CollectionReference? _userFavProductsCollection() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('favorite_products');
  }

  void _listenToFirestore() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        products.value = [];
        return;
      }
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorite_products')
          .snapshots()
          .listen((snapshot) {
            products.value = snapshot.docs
                .map((doc) => FavoriteProductData.fromFirestore(doc))
                .toList();
          });
    });
  }

  Stream<FavProductList> favoriteProductsStream() {
    final col = _userFavProductsCollection();
    if (col == null) return Stream.value([]);

    return col.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => FavoriteProductData.fromFirestore(doc))
          .toList(),
    );
  }

  String _generateDocId(String storeName, String description) {
    return '${storeName.trim()}_${description.trim()}'
        .replaceAll('/', '_')
        .toLowerCase();
  }

  Future<void> addProduct(FavoriteProductData product) async {
    final col = _userFavProductsCollection();
    if (col == null) return;

    final docId =
        product.id ?? _generateDocId(product.storeName, product.description);
    await col.doc(docId).set(product.toMap());
  }

  Future<void> remove(FavoriteProductData product) async {
    final col = _userFavProductsCollection();
    if (col == null) return;

    final docId =
        product.id ?? _generateDocId(product.storeName, product.description);
    await col.doc(docId).delete();
  }
}
