import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class ManageBazaarPage extends StatefulWidget {
  const ManageBazaarPage({super.key});

  @override
  State<ManageBazaarPage> createState() => _ManageBazaarPageState();
}

class _ManageBazaarPageState extends State<ManageBazaarPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Dialog Tambah / Edit Lokasi Lapak Bazar (Tab 2)
  void _showAddEditSpotDialog({DocumentSnapshot? doc}) {
    final nameController = TextEditingController(
      text: doc != null ? doc['nama'] : '',
    );
    final locationController = TextEditingController(
      text: doc != null ? doc['lokasi'] : '',
    );
    final capacityController = TextEditingController(
      text: doc != null ? doc['kapasitas'].toString() : '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            doc == null ? 'Tambah Lokasi Lapak Baru' : 'Edit Lokasi Lapak',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lokasi / Fakultas',
                  hintText: 'Contoh: FEB, Fasilkom-TI, Pendopo USU',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Detail Patokan Tempat',
                  hintText: 'Contoh: Pelataran Parkiran FEB',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: capacityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Kapasitas Maksimal Bazar',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kGreen),
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    capacityController.text.isNotEmpty) {
                  final kapasitas = int.tryParse(capacityController.text) ?? 10;

                  if (doc == null) {
                    await FirebaseFirestore.instance
                        .collection('bazaar_spots')
                        .add({
                          'nama': nameController.text.trim(),
                          'lokasi': locationController.text.trim(),
                          'kapasitas': kapasitas,
                          'createdAt': FieldValue.serverTimestamp(),
                        });
                  } else {
                    await FirebaseFirestore.instance
                        .collection('bazaar_spots')
                        .doc(doc.id)
                        .update({
                          'nama': nameController.text.trim(),
                          'lokasi': locationController.text.trim(),
                          'kapasitas': kapasitas,
                        });
                  }
                  if (!context.mounted) return;
                  Navigator.pop(context);
                }
              },
              child: const Text(
                'Simpan',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
      appBar: AppBar(
        title: const Text('Kelola Bazar & Lapak Bazar'),
        backgroundColor: kGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          tabs: const [
            Tab(text: 'Daftar Bazar (Toko)'),
            Tab(text: 'Lokasi Lapak Bazar'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // =================================================================
          // TAB 1: DAFTAR BAZAR (Mengambil langsung dari koleksi 'tenants')
          // =================================================================
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('tenants')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: kGreen),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text('Belum ada akun bazar/toko terdaftar'),
                );
              }

              final tenantDocs = snapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: tenantDocs.length,
                itemBuilder: (context, index) {
                  final doc = tenantDocs[index];
                  final data = doc.data() as Map<String, dynamic>;

                  // Sesuaikan nama field dengan struktur dokumen di koleksi 'tenants' kamu
                  final namaBazar =
                      data['storeName'] ??
                      data['namaToko'] ??
                      data['nama'] ??
                      'Bazar Tanpa Nama';
                  final pemilik =
                      data['ownerName'] ?? data['namaPemilik'] ?? '-';
                  final lokasi =
                      data['lokasi'] ??
                      data['fakultas'] ??
                      data['spot'] ??
                      'Area USU';
                  final status = data['status'] ?? 'pending';

                  final isApproved = status == 'approved';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: isApproved
                            ? kGreen.withValues(alpha: 0.1)
                            : Colors.orange.withValues(alpha: 0.1),
                        child: Icon(
                          Icons.storefront,
                          color: isApproved ? kGreen : Colors.orange,
                        ),
                      ),
                      title: Text(
                        namaBazar,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            'Pemilik/Organisasi: $pemilik',
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            'Lokasi Lapak: $lokasi',
                            style: const TextStyle(
                              fontSize: 12,
                              color: kDarkGreen,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isApproved
                              ? Colors.green.shade100
                              : Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isApproved ? 'Aktif' : 'Pending',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isApproved
                                ? Colors.green.shade800
                                : Colors.orange.shade800,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),

          // =================================================================
          // TAB 2: LOKASI LAPAK BAZAR (Menghitung jumlah bazar per lokasi)
          // =================================================================
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    icon: const Icon(Icons.add_location_alt),
                    label: const Text('Tambah Lokasi Lapak Baru'),
                    onPressed: () => _showAddEditSpotDialog(),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  // Menggunakan nested StreamBuilder untuk mencocokkan lokasi dengan jumlah bazar di 'tenants'
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('bazaar_spots')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, spotSnapshot) {
                      if (spotSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: kGreen),
                        );
                      }

                      if (!spotSnapshot.hasData ||
                          spotSnapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text('Belum ada lokasi lapak terdaftar'),
                        );
                      }

                      final spotDocs = spotSnapshot.data!.docs;

                      return StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('tenants')
                            .where('status', isEqualTo: 'approved')
                            .snapshots(),
                        builder: (context, tenantSnapshot) {
                          final activeTenants = tenantSnapshot.hasData
                              ? tenantSnapshot.data!.docs
                              : [];

                          return ListView.builder(
                            itemCount: spotDocs.length,
                            itemBuilder: (context, index) {
                              final doc = spotDocs[index];
                              final data = doc.data() as Map<String, dynamic>;

                              final namaTempat = data['nama'] ?? 'Tanpa Nama';
                              final detailLokasi = data['lokasi'] ?? '-';
                              final kapasitas = data['kapasitas'] ?? 10;

                              // Hitung ada berapa bazar (toko) aktif yang berlokasi di tempat ini
                              final terisi = activeTenants.where((tDoc) {
                                final tData =
                                    tDoc.data() as Map<String, dynamic>;
                                final tLokasi =
                                    (tData['lokasi'] ??
                                            tData['fakultas'] ??
                                            tData['spot'] ??
                                            '')
                                        .toString()
                                        .toLowerCase();
                                return tLokasi.contains(
                                  namaTempat.toString().toLowerCase(),
                                );
                              }).length;

                              final isFull = terisi >= kapasitas;

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              namaTempat,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isFull
                                                  ? Colors.red.shade100
                                                  : Colors.green.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              isFull ? 'Penuh' : 'Tersedia',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: isFull
                                                    ? Colors.red.shade800
                                                    : Colors.green.shade800,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.place_outlined,
                                            size: 16,
                                            color: Colors.grey.shade600,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              detailLokasi,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey.shade700,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Jumlah Bazar: $terisi / $kapasitas Bazar',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: kDarkGreen,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.edit,
                                                  size: 20,
                                                  color: Colors.blue,
                                                ),
                                                onPressed: () =>
                                                    _showAddEditSpotDialog(
                                                      doc: doc,
                                                    ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  size: 20,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () async {
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection(
                                                        'bazaar_spots',
                                                      )
                                                      .doc(doc.id)
                                                      .delete();
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
