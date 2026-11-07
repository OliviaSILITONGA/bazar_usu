import 'package:flutter/foundation.dart';

class ProfileData {
  final String name;
  final String username;
  final String bio;
  final String address;
  final String phone;

  /// Foto profil: teks base64 (dari Firestore) atau URL. null = belum ada foto.
  final String? photo;

  const ProfileData({
    this.name = 'Nama Pengguna',
    this.username = '',
    this.bio = '',
    this.address = '',
    this.phone = '',
    this.photo,
  });
}

/// State global profil pengguna, mirip pola OrderState/FavoriteStoresState —
/// singleton yang bisa dibaca & diubah dari halaman manapun.
class ProfileState {
  ProfileState._internal();
  static final ProfileState instance = ProfileState._internal();

  final ValueNotifier<ProfileData> data = ValueNotifier<ProfileData>(
    const ProfileData(),
  );

  void update(ProfileData newData) {
    data.value = newData;
  }
}
