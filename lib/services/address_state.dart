import 'package:flutter/material.dart';

class AddressData {
  final String label;
  final String recipientName;
  final String phone;
  final String fullAddress;
  final bool isPrimary;

  const AddressData({
    required this.label,
    required this.recipientName,
    required this.phone,
    required this.fullAddress,
    this.isPrimary = false,
  });
}

class AddressState {
  AddressState._internal();
  static final AddressState instance = AddressState._internal();

  final ValueNotifier<List<AddressData>> addresses =
      ValueNotifier<List<AddressData>>([]);

  void addAddress(AddressData address) {
    final list = List<AddressData>.from(addresses.value);
    if (address.isPrimary) {
      for (var i = 0; i < list.length; i++) {
        final old = list[i];
        list[i] = AddressData(
          label: old.label,
          recipientName: old.recipientName,
          phone: old.phone,
          fullAddress: old.fullAddress,
          isPrimary: false,
        );
      }
    }
    list.add(address);
    addresses.value = list;
  }

  void removeAt(int index) {
    final list = List<AddressData>.from(addresses.value)..removeAt(index);
    addresses.value = list;
  }
}
