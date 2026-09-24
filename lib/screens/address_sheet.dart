import 'package:flutter/material.dart';
import '../constants.dart';

class SavedAddress {
  final String id;
  String label; // Rumah / Kantor / Lainnya
  String address;
  String note;

  SavedAddress({
    required this.id,
    required this.label,
    required this.address,
    this.note = '',
  });
}

/// Panggil ini dari mana saja untuk memunculkan bottom sheet pilih alamat.
/// Return SavedAddress kalau user berhasil memilih/menyimpan alamat, null kalau batal.
Future<SavedAddress?> showAddressPickerSheet(
  BuildContext context, {
  List<SavedAddress>? initialAddresses,
}) {
  return showModalBottomSheet<SavedAddress>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _AddressPickerSheet(initialAddresses: initialAddresses),
  );
}

class _AddressPickerSheet extends StatefulWidget {
  final List<SavedAddress>? initialAddresses;
  const _AddressPickerSheet({this.initialAddresses});

  @override
  State<_AddressPickerSheet> createState() => _AddressPickerSheetState();
}

class _AddressPickerSheetState extends State<_AddressPickerSheet> {
  late List<SavedAddress> _addresses;
  String? _activeId;
  bool _showForm = false;

  @override
  void initState() {
    super.initState();
    _addresses = widget.initialAddresses ??
        [
          SavedAddress(
            id: '1',
            label: 'Rumah',
            address: 'Jl. Sudirman No. 12, Jakarta Pusat',
            note: 'Pagar hijau, sebelah warung kopi',
          ),
          SavedAddress(
            id: '2',
            label: 'Kantor',
            address: 'Monas Building Lt. 8, Jl. Medan Merdeka, Jakarta',
            note: 'Titip ke resepsionis lobby',
          ),
        ];
    _activeId = _addresses.isNotEmpty ? _addresses.first.id : null;
  }

  void _pilihAlamat(SavedAddress addr) {
    setState(() => _activeId = addr.id);
    Navigator.pop(context, addr);
  }

  void _tambahAlamat(SavedAddress addr) {
    setState(() {
      _addresses.add(addr);
      _activeId = addr.id;
      _showForm = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _showForm
            ? _AddAddressForm(
                key: const ValueKey('form'),
                onCancel: () => setState(() => _showForm = false),
                onSave: _tambahAlamat,
              )
            : _AddressListView(
                key: const ValueKey('list'),
                addresses: _addresses,
                activeId: _activeId,
                onClose: () => Navigator.pop(context),
                onSelect: _pilihAlamat,
                onAddNew: () => setState(() => _showForm = true),
              ),
      ),
    );
  }
}

// ==================== LIST ALAMAT ====================
class _AddressListView extends StatelessWidget {
  final List<SavedAddress> addresses;
  final String? activeId;
  final VoidCallback onClose;
  final ValueChanged<SavedAddress> onSelect;
  final VoidCallback onAddNew;

  const _AddressListView({
    super.key,
    required this.addresses,
    required this.activeId,
    required this.onClose,
    required this.onSelect,
    required this.onAddNew,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Pilih Alamat Antar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: kDarkGreen,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onClose,
                child: Icon(Icons.close, color: kDarkGreen.withValues(alpha: 0.6)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...addresses.map((addr) {
            final isActive = addr.id == activeId;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => onSelect(addr),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isActive ? kLightGreen.withValues(alpha: 0.5) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isActive ? kDarkGreen : kDarkGreen.withValues(alpha: 0.15),
                      width: isActive ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: kLightGreen,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.location_on_outlined, color: kDarkGreen, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  addr.label,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: kDarkGreen,
                                  ),
                                ),
                                if (isActive) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: kDarkGreen,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'Aktif',
                                      style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              addr.address,
                              style: TextStyle(fontSize: 13, color: kDarkGreen.withValues(alpha: 0.85)),
                            ),
                            if (addr.note.trim().isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Catatan: ${addr.note}',
                                style: TextStyle(fontSize: 11.5, color: kDarkGreen.withValues(alpha: 0.55)),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (isActive)
                        const Icon(Icons.check_circle, color: kDarkGreen, size: 20),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 4),
          DottedAddButton(onTap: onAddNew),
        ],
      ),
    );
  }
}

/// Tombol "+ Tambah Alamat Baru" dengan border putus-putus.
class DottedAddButton extends StatelessWidget {
  final VoidCallback onTap;
  const DottedAddButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: CustomPaint(
        painter: _DashedBorderPainter(color: kDarkGreen.withValues(alpha: 0.5)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: kDarkGreen, size: 18),
              const SizedBox(width: 6),
              const Text(
                'Tambah Alamat Baru',
                style: TextStyle(color: kDarkGreen, fontWeight: FontWeight.bold, fontSize: 13.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(16),
    );
    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      const dashWidth = 6.0;
      const dashSpace = 4.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashWidth),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ==================== FORM TAMBAH ALAMAT ====================
class _AddAddressForm extends StatefulWidget {
  final VoidCallback onCancel;
  final ValueChanged<SavedAddress> onSave;

  const _AddAddressForm({super.key, required this.onCancel, required this.onSave});

  @override
  State<_AddAddressForm> createState() => _AddAddressFormState();
}

class _AddAddressFormState extends State<_AddAddressForm> {
  String _label = 'Rumah';
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alamat lengkap tidak boleh kosong')),
      );
      return;
    }
    widget.onSave(
      SavedAddress(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        label: _label,
        address: _addressController.text.trim(),
        note: _noteController.text.trim(),
      ),
    );
  }

  Widget _labelChip(String value) {
    final selected = _label == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _label = value),
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? kDarkGreen : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: selected ? kDarkGreen : kDarkGreen.withValues(alpha: 0.3)),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: selected ? Colors.white : kDarkGreen,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      isDense: true,
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
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Pilih Alamat Antar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kDarkGreen),
                ),
              ),
              GestureDetector(
                onTap: widget.onCancel,
                child: Icon(Icons.close, color: kDarkGreen.withValues(alpha: 0.6)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Label Alamat', style: TextStyle(fontSize: 13, color: kDarkGreen, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: [
              _labelChip('Rumah'),
              _labelChip('Kantor'),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _label = 'Lainnya'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _label == 'Lainnya' ? kDarkGreen : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: _label == 'Lainnya' ? kDarkGreen : kDarkGreen.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      'Lainnya',
                      style: TextStyle(
                        color: _label == 'Lainnya' ? Colors.white : kDarkGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text('Alamat Lengkap', style: TextStyle(fontSize: 13, color: kDarkGreen, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(controller: _addressController, decoration: _inputDecoration('Jl. Contoh No. 1, Kota')),
          const SizedBox(height: 18),
          const Text('Catatan untuk Driver (opsional)', style: TextStyle(fontSize: 13, color: kDarkGreen, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(controller: _noteController, decoration: _inputDecoration('Warna pagar, patokan, dll.')),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kDarkGreen,
                    side: BorderSide(color: kDarkGreen.withValues(alpha: 0.4)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kDarkGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Simpan & Pakai Alamat', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}