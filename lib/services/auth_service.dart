import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Mendapatkan user yang sedang login
  User? get currentUser => _auth.currentUser;

  // Fungsi Register dengan Email & Password
  Future<User?> registerWithEmailPassword(String email, String password) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw _getReadableError(e.code);
    }
  }

  // Fungsi Login dengan Email & Password
  Future<User?> loginWithEmailPassword(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw _getReadableError(e.code);
    }
  }

  // Fungsi Mengirim Tautan Reset Password
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _getReadableError(e.code);
    }
  }

  // Fungsi Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Terjemahan pesan error Firebase ke Bahasa Indonesia
  String _getReadableError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Email ini sudah terdaftar.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'weak-password':
        return 'Password terlalu lemah (minimal 6 karakter).';
      case 'user-not-found':
        return 'Akun dengan email ini tidak ditemukan.';
      case 'wrong-password':
        return 'Password yang Anda masukkan salah.';
      default:
        return 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }
}
