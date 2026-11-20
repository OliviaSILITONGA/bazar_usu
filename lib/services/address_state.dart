import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddressData {
  final String? id;
  final String label;
  final String recipientName;
  final String phone;
  final String fullAddress;
  final bool isPrimary;

  const AddressData({
    this.id,
    required this.label,
    required this.recipientName,
    required this.phone,
    required this.fullAddress,
    this.isPrimary = false,
  });

  factory AddressData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AddressData(
      id: doc.id,
      label: data['label'] ?? '',
      recipientName: data['recipientName'] ?? '',
      phone: data['phone'] ?? '',
      fullAddress: data['fullAddress'] ?? '',
      isPrimary: data['isPrimary'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'recipientName': recipientName,
      'phone': phone,
      'fullAddress': fullAddress,
      'isPrimary': isPrimary,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}

class AddressState {
  AddressState._internal();
  static final AddressState instance = AddressState._internal();

  CollectionReference? _userAddressCollection() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('addresses');
  }

  // Stream real-time daftar alamat milik user yang sedang login
  Stream<List<AddressData>> addressesStream() {
    final col = _userAddressCollection();
    if (col == null) return Stream.value([]);

    return col
        .orderBy('isPrimary', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AddressData.fromFirestore(doc))
              .toList(),
        );
  }

  // Tambah alamat baru ke Firestore
  Future<void> addAddress(AddressData address) async {
    final col = _userAddressCollection();
    if (col == null) throw 'Sesi login tidak ditemukan';

    final batch = FirebaseFirestore.instance.batch();

    // Jika alamat baru dijadikan utama, nonaktifkan status utama pada alamat lain
    if (address.isPrimary) {
      final existingPrimary = await col
          .where('isPrimary', isEqualTo: true)
          .get();
      for (final doc in existingPrimary.docs) {
        batch.update(doc.reference, {'isPrimary': false});
      }
    }

    final newDocRef = col.doc();
    batch.set(newDocRef, {
      ...address.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  // Jadikan alamat tertentu sebagai alamat utama
  Future<void> setPrimaryAddress(String addressId) async {
    final col = _userAddressCollection();
    if (col == null) return;

    final batch = FirebaseFirestore.instance.batch();
    final allDocs = await col.get();

    for (final doc in allDocs.docs) {
      batch.update(doc.reference, {'isPrimary': doc.id == addressId});
    }

    await batch.commit();
  }

  // Hapus alamat dari Firestore
  Future<void> deleteAddress(String addressId) async {
    final col = _userAddressCollection();
    if (col == null) return;
    await col.doc(addressId).delete();
  }
}
