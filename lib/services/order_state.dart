import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OrderItem {
  final String storeName;
  final String description;
  final int price;
  final int quantity;
  final String image;

  const OrderItem({
    required this.storeName,
    required this.description,
    required this.price,
    required this.quantity,
    this.image = '',
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    final rawPrice = map['price'] ?? map['harga'] ?? 0;
    final rawQty = map['quantity'] ?? map['qty'] ?? 1;

    return OrderItem(
      storeName: (map['storeName'] ?? map['namaToko'] ?? '').toString(),
      description: (map['description'] ?? map['name'] ?? map['nama'] ?? '')
          .toString(),
      price: rawPrice is int
          ? rawPrice
          : int.tryParse(rawPrice.toString()) ?? 0,
      quantity: rawQty is int ? rawQty : int.tryParse(rawQty.toString()) ?? 1,
      image: (map['image'] ?? map['imageBase64'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'storeName': storeName,
      'description': description,
      'price': price,
      'quantity': quantity,
      'image': image,
    };
  }
}

class OrderData {
  final String id;
  final String buyerId;
  final String sellerId;
  final List<OrderItem> items;
  final int total;
  final String status; // 'Perlu dibayar' | 'Akan Diterima' | 'Untuk Diulas' | 'Pesanan Selesai'
  final DateTime createdAt;

  const OrderData({
    required this.id,
    this.buyerId = '',
    this.sellerId = '',
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
  });

  factory OrderData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    final rawItems = data['items'] as List<dynamic>? ?? [];
    final parsedItems = rawItems
        .map((e) => OrderItem.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();

    final rawTotal = data['total'] ?? data['totalPrice'] ?? 0;
    final parsedTotal = rawTotal is int
        ? rawTotal
        : int.tryParse(rawTotal.toString()) ?? 0;

    final rawTimestamp = data['createdAt'];
    final parsedDate = rawTimestamp is Timestamp
        ? rawTimestamp.toDate()
        : DateTime.now();

    return OrderData(
      id: doc.id,
      buyerId: (data['buyerId'] ?? data['userId'] ?? '').toString(),
      sellerId: (data['sellerId'] ?? data['tenantId'] ?? '').toString(),
      items: parsedItems,
      total: parsedTotal,
      status: (data['status'] ?? 'Perlu dibayar').toString(),
      createdAt: parsedDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'buyerId': buyerId,
      'userId': buyerId,
      'sellerId': sellerId,
      'tenantId': sellerId,
      'items': items.map((e) => e.toMap()).toList(),
      'total': total,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

typedef OrderList = List<OrderData>;

class OrderState {
  OrderState._internal() {
    _listenToFirestore();
  }
  static final OrderState instance = OrderState._internal();

  final ValueNotifier<OrderList> orders = ValueNotifier<OrderList>([]);

  void _listenToFirestore() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        orders.value = [];
        return;
      }

      FirebaseFirestore.instance.collection('orders').snapshots().listen((
        snapshot,
      ) {
        final myOrders =
            snapshot.docs
                .map((doc) => OrderData.fromFirestore(doc))
                .where((o) => o.buyerId == user.uid)
                .toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

        orders.value = myOrders;
      });
    });
  }

  // Stream real-time pesanan milik pembeli yang sedang login
  Stream<OrderList> userOrdersStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream.value([]);

    return FirebaseFirestore.instance.collection('orders').snapshots().map((
      snapshot,
    ) {
      final list =
          snapshot.docs
              .map((doc) => OrderData.fromFirestore(doc))
              .where((o) => o.buyerId == uid)
              .toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<String> _resolveSellerIdFromTenants(OrderData order) async {
    final currentSellerId = order.sellerId.trim();
    if (currentSellerId.isNotEmpty &&
        !currentSellerId.toLowerCase().startsWith('seller_')) {
      return currentSellerId;
    }

    final targetNames = <String>{
      ...order.items
          .map((item) => item.storeName.trim().toLowerCase())
          .where((name) => name.isNotEmpty),
      if (currentSellerId.toLowerCase().startsWith('seller_'))
        currentSellerId
            .toLowerCase()
            .replaceFirst('seller_', '')
            .replaceAll('_', ' '),
    };

    if (targetNames.isEmpty) return currentSellerId;

    try {
      final tenantsSnap = await FirebaseFirestore.instance
          .collection('tenants')
          .limit(200)
          .get();
      for (final doc in tenantsSnap.docs) {
        final data = doc.data();
        final storeTitle = (data['namaToko'] ?? data['storeName'] ?? '')
            .toString()
            .trim()
            .toLowerCase();
        if (storeTitle.isNotEmpty && targetNames.contains(storeTitle)) {
          final ownerUid =
              (data['uid'] ?? data['ownerId'] ?? data['userId'] ?? doc.id)
                  .toString()
                  .trim();
          if (ownerUid.isNotEmpty) return ownerUid;
        }
      }
    } catch (_) {}

    return currentSellerId;
  }

  // Simpan pesanan baru ke Firestore
  Future<void> addOrder(OrderData order) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw 'Sesi login tidak ditemukan';

    final resolvedSellerId = await _resolveSellerIdFromTenants(order);
    final buyerName = FirebaseAuth.instance.currentUser?.displayName?.trim();

    final docRef = order.id.isNotEmpty
        ? FirebaseFirestore.instance.collection('orders').doc(order.id)
        : FirebaseFirestore.instance.collection('orders').doc();

    await docRef.set({
      ...order.toMap(),
      'buyerId': uid,
      'userId': uid,
      if (buyerName != null && buyerName.isNotEmpty) 'buyerName': buyerName,
      'sellerId': resolvedSellerId,
      'tenantId': resolvedSellerId,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Perbarui status pesanan di Firestore
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
