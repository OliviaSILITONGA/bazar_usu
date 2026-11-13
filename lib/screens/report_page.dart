import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../constants.dart';
import '../services/report_state.dart';

class ReportPage extends StatelessWidget {
  const ReportPage({super.key});

  void _openReportForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _ReportFormSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

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
                      'Laporkan',
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
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                children: [
                  // ---------- Banner catatan ----------
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCF3D8),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE9D08C)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: Color(0xFF8A6D1D),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Berikan detail laporan sejelas mungkin (kategori, ID transaksi/produk, dan deskripsi) supaya tim Bazar USU bisa memprosesnya lebih cepat.',
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color(0xFF6B5312)
                                  .withValues(alpha: 0.9),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ---------- Tombol buat laporan ----------
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _openReportForm(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kDarkGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text(
                        'Buat Laporan Baru',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),

                  // ---------- Riwayat laporan (Dari Firestore) ----------
                  Text(
                    'Riwayat Laporan',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: kDarkGreen.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 10),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('reports')
                        .where('userId', isEqualTo: user?.uid ?? '')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(color: kDarkGreen),
                          ),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.inbox_outlined,
                                  size: 44,
                                  color: kDarkGreen.withValues(alpha: 0.3),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Belum ada laporan yang dikirim',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: kDarkGreen.withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final reportDocs = snapshot.data!.docs;

                      return Column(
                        children: List.generate(reportDocs.length, (index) {
                          final doc = reportDocs[index];
                          final data = doc.data() as Map<String, dynamic>;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _FirestoreReportCard(
                              docId: doc.id,
                              data: data,
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== KARTU RIWAYAT LAPORAN FIRESTORE ====================
class _FirestoreReportCard extends StatelessWidget {
  final String docId;
  final Map<String, dynamic> data;
  const _FirestoreReportCard({required this.docId, required this.data});

  Color get _statusColor {
    final status = data['status'] ?? 'Menunggu';
    if (status == 'Diproses') return const Color(0xFF3B82F6);
    if (status == 'Selesai') return const Color(0xFF34A853);
    return const Color(0xFFE09A2E);
  }

  @override
  Widget build(BuildContext context) {
    final category = data['category'] ?? 'Masalah Transaksi';
    final referenceId = data['referenceId'] ?? '';
    final description = data['description'] ?? '';
    final status = data['status'] ?? 'Menunggu';
    final imageUrl = data['imageUrl'];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kDarkGreen.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  category,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: kDarkGreen,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: _statusColor,
                  ),
                ),
              ),
            ],
          ),
          if (referenceId.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'ID Transaksi/Produk: $referenceId',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: kDarkGreen.withValues(alpha: 0.75),
              ),
            ),
          ],
          const SizedBox(height: 6),
          Text(
            description,
            style: TextStyle(
              fontSize: 12.5,
              color: kDarkGreen.withValues(alpha: 0.75),
              height: 1.4,
            ),
          ),
          if (imageUrl != null && imageUrl.toString().isNotEmpty) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                imageUrl,
                height: 110,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Text('Gagal memuat gambar bukti'),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () async {
                await FirebaseFirestore.instance
                    .collection('reports')
                    .doc(docId)
                    .delete();
              },
              child: Icon(
                Icons.delete_outline,
                size: 18,
                color: Colors.redAccent.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== FORM BUAT LAPORAN ====================
class _ReportFormSheet extends StatefulWidget {
  const _ReportFormSheet();

  @override
  State<_ReportFormSheet> createState() => _ReportFormSheetState();
}

class _ReportFormSheetState extends State<_ReportFormSheet> {
  ReportCategory _category = ReportCategory.transactionIssue;
  final _referenceController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _evidenceImage;
  bool _isLoading = false;

  @override
  void dispose() {
    _referenceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (picked != null) {
      setState(() => _evidenceImage = File(picked.path));
    }
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

  Future<void> _submit() async {
    final description = _descriptionController.text.trim();

    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Deskripsi masalah wajib diisi!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      // Simpan data laporan langsung ke Cloud Firestore
      await FirebaseFirestore.instance.collection('reports').add({
        'userId': user?.uid ?? '',
        'pelapor': user?.email ?? 'Mahasiswa USU',
        'category': _category.label,
        'referenceId': _referenceController.text.trim(),
        'description': description,
        'status': 'Menunggu',
        'createdAt': FieldValue.serverTimestamp(),
        'imageUrl': null, // Jika ada upload storage bisa dimasukkan di sini
      });

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Laporan berhasil dikirim ke Admin. Terima kasih!'),
          backgroundColor: kDarkGreen,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengirim laporan: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
              'Buat Laporan',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: kDarkGreen,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Kategori Laporan',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: kDarkGreen.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<ReportCategory>(
              initialValue: _category,
              decoration: _decoration('Pilih kategori'),
              items: ReportCategory.values
                  .map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(
                        c.label,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _category = value);
              },
            ),
            const SizedBox(height: 14),
            Text(
              'ID Transaksi / Nama Produk (Opsional)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: kDarkGreen.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _referenceController,
              decoration: _decoration('Contoh: #INV12345 atau nama penjual'),
            ),
            const SizedBox(height: 14),
            Text(
              'Deskripsi Masalah',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: kDarkGreen.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: _decoration(
                'Jelaskan detail kendala yang kamu alami...',
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Unggah Bukti / Tangkapan Layar (Opsional)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: kDarkGreen.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 6),
            if (_evidenceImage == null)
              OutlinedButton.icon(
                onPressed: _pickImage,
                style: OutlinedButton.styleFrom(
                  foregroundColor: kDarkGreen,
                  side: BorderSide(color: kDarkGreen.withValues(alpha: 0.4)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: const Icon(Icons.upload_outlined, size: 18),
                label: const Text('Pilih Foto dari Galeri'),
              )
            else
              Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      _evidenceImage!,
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: GestureDetector(
                      onTap: () => setState(() => _evidenceImage = null),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kDarkGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Kirim Laporan',
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
