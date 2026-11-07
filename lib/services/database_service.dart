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
}
