import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/store_detail_page.dart';

typedef StoreNameSet = Set<String>;
typedef StoreProfileList = List<StoreProfileData>;

class FavoriteStoresState {
  FavoriteStoresState._internal() {
    _listenToFirestore();
  }
  static final FavoriteStoresState instance = FavoriteStoresState._internal();

  final ValueNotifier<StoreNameSet> favorites = ValueNotifier<StoreNameSet>({});

  CollectionReference? _userFavStoresCollection() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('favorite_stores');
  }

  void _listenToFirestore() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        favorites.value = {};
        return;
      }
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('favorite_stores')
          .snapshots()
          .listen((snapshot) {
            final names = snapshot.docs
                .map((doc) {
                  final data = doc.data();
                  return (data['storeName'] ?? doc.id).toString();
                })
                .where((name) => name.isNotEmpty)
                .toSet();
            favorites.value = names;
          });
    });
  }

  Stream<StoreProfileList> favoriteStoresStream() {
    final col = _userFavStoresCollection();
    if (col == null) return Stream.value([]);

    return col.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        final name = (data['storeName'] ?? doc.id).toString();
        return resolveStoreProfile(name);
      }).toList();
    });
  }

  bool isFavorite(String storeName) {
    return favorites.value.contains(storeName);
  }

  Future<void> toggle(String storeName) async {
    final col = _userFavStoresCollection();
    if (col == null) return;

    final docId = storeName.trim();
    if (docId.isEmpty) return;

    final docRef = col.doc(docId);
    final docSnap = await docRef.get();

    if (docSnap.exists) {
      await docRef.delete();
    } else {
      await docRef.set({
        'storeName': docId,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> remove(String storeName) async {
    final col = _userFavStoresCollection();
    if (col == null) return;
    await col.doc(storeName.trim()).delete();
  }
}
