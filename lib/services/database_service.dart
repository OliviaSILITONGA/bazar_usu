import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Menyimpan data profil user baru saat registrasi
  Future<void> saveUserData({
    required String uid,
    required String email,
    required String nama,
    String role = 'buyer',
  }) async {
    await _db.collection('users').doc(uid).set({
      'uid': uid,
      'email': email,
      'nama': nama,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Mengambil data profil user berdasarkan UID
  Future<DocumentSnapshot> getUserData(String uid) async {
    return await _db.collection('users').doc(uid).get();
  }

  // Mengajukan pendaftaran tenant/toko baru (status pending)
  Future<void> registerTenant({
    required String uid,
    required String namaToko,
    required String deskripsi,
  }) async {
    await _db.collection('tenants').doc(uid).set({
      'uid': uid,
      'namaToko': namaToko,
      'deskripsi': deskripsi,
      'status': 'pending', // Status menunggu verifikasi admin
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Memperbarui profil user di Cloud Firestore
  Future<void> updateUserData({
    required String uid,
    required String nama,
    required String username,
    required String bio,
    required String address,
    required String phone,
  }) async {
    // Ganti .update() dengan .set(..., SetOptions(merge: true))
    return await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'nama': nama,
      'username': username,
      'bio': bio,
      'alamat': address,
      'telepon': phone,
      'role': 'buyer', // pastikan field role tetap ada
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Memperbarui data toko/tenant di Cloud Firestore
  Future<void> updateTenantData({
    required String uid,
    String? namaToko,
    String? kategori,
    String? nomorHp,
    required String deskripsi,
  }) async {
    final Map<String, dynamic> dataToUpdate = {
      'deskripsi': deskripsi,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (namaToko != null) dataToUpdate['namaToko'] = namaToko;
    if (kategori != null) dataToUpdate['kategori'] = kategori;
    if (nomorHp != null) dataToUpdate['nomorHp'] = nomorHp;

    await _db.collection('tenants').doc(uid).update(dataToUpdate);
  }
}
