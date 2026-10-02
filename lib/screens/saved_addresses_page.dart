import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import '../constants.dart';
import '../services/address_state.dart';

class SavedAddressesPage extends StatelessWidget {
  const SavedAddressesPage({super.key});

  void _openAddForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _AddAddressSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                    color: kDarkGreen,
                  ),
                  const Expanded(
                    child: Text(
                      'Alamat Tersimpan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: kDarkGreen,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            Expanded(
              child: ValueListenableBuilder<List<AddressData>>(
                valueListenable: AddressState.instance.addresses,
                builder: (context, addresses, _) {
                  if (addresses.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_off_outlined,
                              size: 48,
                              color: kDarkGreen.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Belum ada alamat tersimpan',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: kDarkGreen.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    itemCount: addresses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final addr = addresses[index];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: kDarkGreen.withValues(alpha: 0.12),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  addr.label,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                    color: kDarkGreen,
                                  ),
                                ),
                                if (addr.isPrimary) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: kLightGreen,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Utama',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        color: kDarkGreen,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                                const Spacer(),
                                GestureDetector(
                                  onTap: () =>
                                      AddressState.instance.removeAt(index),
                                  child: Icon(
                                    Icons.delete_outline,
                                    size: 19,
                                    color: Colors.redAccent.withValues(
                                      alpha: 0.8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${addr.recipientName} (${addr.phone})',
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              addr.fullAddress,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: kDarkGreen.withValues(alpha: 0.75),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddForm(context),
        backgroundColor: kDarkGreen,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Tambah Alamat',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// ==================== FORM TAMBAH ALAMAT ====================
class _AddAddressSheet extends StatefulWidget {
  const _AddAddressSheet();

  @override
  State<_AddAddressSheet> createState() => _AddAddressSheetState();
}

class _AddAddressSheetState extends State<_AddAddressSheet> {
  final _labelController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isPrimary = false;
  bool _isFetchingLocation = false;

  Future<void> _useCurrentLocation() async {
    setState(() => _isFetchingLocation = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Layanan lokasi (GPS) tidak aktif. Aktifkan dulu di pengaturan HP.';
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw 'Izin lokasi ditolak.';
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw 'Izin lokasi ditolak permanen. Aktifkan lewat pengaturan aplikasi.';
      }

      final position = await Geolocator.getCurrentPosition();
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final formatted = [
          p.street,
          p.subLocality,
          p.locality,
          p.administrativeArea,
          p.country,
        ].where((s) => s != null && s.trim().isNotEmpty).join(', ');
        setState(() => _addressController.text = formatted);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isFetchingLocation = false);
    }
  }

  void _save() {
    if (_labelController.text.trim().isEmpty ||
        _nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua field wajib diisi!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    AddressState.instance.addAddress(
      AddressData(
        label: _labelController.text.trim(),
        recipientName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        fullAddress: _addressController.text.trim(),
        isPrimary: _isPrimary,
      ),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _labelController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String hint) => InputDecoration(
    isDense: true,
    hintText: hint,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: kDarkGreen.withValues(alpha: 0.3)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: kDarkGreen, width: 2),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Tambah Alamat',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: kDarkGreen,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _labelController,
              decoration: _decoration('Label (misal: Rumah, Kos)'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: _decoration('Nama Penerima'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: _decoration('Nomor HP'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _addressController,
              maxLines: 3,
              decoration: _decoration('Alamat Lengkap'),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isFetchingLocation ? null : _useCurrentLocation,
                style: OutlinedButton.styleFrom(
                  foregroundColor: kDarkGreen,
                  side: BorderSide(color: kDarkGreen.withValues(alpha: 0.4)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: _isFetchingLocation
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: kDarkGreen,
                        ),
                      )
                    : const Icon(Icons.my_location, size: 18),
                label: Text(
                  _isFetchingLocation
                      ? 'Mengambil lokasi...'
                      : 'Gunakan Lokasi Saat Ini',
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Checkbox(
                  value: _isPrimary,
                  onChanged: (v) => setState(() => _isPrimary = v ?? false),
                  activeColor: kDarkGreen,
                ),
                const Text(
                  'Jadikan alamat utama',
                  style: TextStyle(fontSize: 13, color: kDarkGreen),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kDarkGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'Simpan',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
