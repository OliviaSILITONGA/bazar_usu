import 'dart:io';

import 'package:flutter/material.dart';

class SellerProfileExtra {
  final String description;
  final File? photo;

  const SellerProfileExtra({this.description = '', this.photo});
}

/// State tambahan untuk profil toko (foto & deskripsi) yang belum ada di
/// SellerApplication — singleton terpisah supaya tidak perlu mengubah
/// struktur data pendaftaran toko yang sudah ada.
class SellerProfileExtraState {
  SellerProfileExtraState._internal();
  static final SellerProfileExtraState instance =
      SellerProfileExtraState._internal();

  final ValueNotifier<SellerProfileExtra> data =
      ValueNotifier<SellerProfileExtra>(const SellerProfileExtra());

  void update(SellerProfileExtra newData) {
    data.value = newData;
  }
}
