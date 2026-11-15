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
    required String kategori,
    required String nomorHp,
    required String deskripsi,
  }) async {
    await _db.collection('tenants').doc(uid).set({
      'uid': uid,
      'namaToko': namaToko,
      'kategori': kategori,
      'nomorHp': nomorHp,
      'deskripsi': deskripsi,
      'status': 'pending', // Status menunggu verifikasi admin
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Mengambil data toko/tenant berdasarkan UID pemilik
  Future<Map<String, dynamic>?> getTenant(String uid) async {
    final doc = await _db.collection('tenants').doc(uid).get();
    return doc.data();
  }

  // Memantau data toko/tenant secara real-time
  Stream<Map<String, dynamic>?> tenantStream(String uid) {
    return _db.collection('tenants').doc(uid).snapshots().map((s) => s.data());
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
    await _db.collection('users').doc(uid).set({
      'nama': nama,
      'username': username,
      'bio': bio,
      'alamat': address,
      'telepon': phone,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Memperbarui profil toko (hanya deskripsi & foto).
  // Nama toko & kategori sengaja tidak bisa diubah dari sini.
  Future<void> updateTenantData({
    required String uid,
    required String deskripsi,
    String? fotoBase64,
  }) async {
    final Map<String, dynamic> dataToUpdate = {
      'deskripsi': deskripsi,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (fotoBase64 != null) dataToUpdate['fotoBase64'] = fotoBase64;

    await _db.collection('tenants').doc(uid).update(dataToUpdate);
  }
}