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
    // 3 Tab: Daftar Bazar, Jenis Bazar, Lokasi Lapak
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Dialog Tambah Jenis / Kategori Bazar (Untuk Tab ke-2)
  void _showAddCategoryDialog() {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Jenis Bazar Baru'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Nama Jenis / Kategori',
              hintText: 'Contoh: Makanan Berat',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kGreen),
              onPressed: () async {
                final namaKat = nameController.text.trim();
                if (namaKat.isNotEmpty) {
                  await FirebaseFirestore.instance
                      .collection('bazaar_categories')
                      .doc(namaKat)
                      .set({
                        'nama': namaKat,
                        'createdAt': FieldValue.serverTimestamp(),
                      }, SetOptions(merge: true));
                  if (!context.mounted) return;
                  Navigator.pop(context);
                }
              },
              child: const Text(
                'Tambah',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // Dialog Tambah / Edit Lokasi Lapak Bazar (Untuk Tab ke-3)
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
        title: const Text(
          'Kelola Bazar & Lapak',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: kGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amberAccent,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
          tabs: const [
            Tab(text: 'Daftar Bazar'),
            Tab(text: 'Jenis Bazar'),
            Tab(text: 'Lokasi Lapak'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // =================================================================
          // TAB 1: DAFTAR BAZAR / DANUSAN (Nama Toko dari 'tenants')
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
                return const Center(child: Text('Belum ada bazar terdaftar'));
              }

              final docs = snapshot.data!.docs;

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final namaBazar =
                      data['storeName'] ??
                      data['namaToko'] ??
                      data['nama'] ??
                      'Bazar Tanpa Nama';
                  final pemilik =
                      data['ownerName'] ?? data['namaPemilik'] ?? '-';
                  final lokasi =
                      data['lokasi'] ?? data['fakultas'] ?? 'Area USU';
                  final status = data['status'] ?? 'pending';
                  final isApproved = status == 'approved';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    child: ListTile(
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
                      subtitle: Text(
                        'Pemilik: $pemilik\nLokasi: $lokasi',
                        style: const TextStyle(fontSize: 12),
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
          // TAB 2: JENIS BAZAR (Otomatis Terisi dari Pendaftaran Penjual)
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
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text(
                      'Tambah Kategori Baru',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: _showAddCategoryDialog,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('bazaar_categories')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, catSnapshot) {
                      if (catSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: kGreen),
                        );
                      }

                      if (!catSnapshot.hasData ||
                          catSnapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text('Belum ada kategori bazar terdaftar'),
                        );
                      }

                      final catDocs = catSnapshot.data!.docs;

                      // Pantau koleksi 'tenants' untuk menghitung jumlah toko per kategori secara akurat
                      return StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('tenants')
                            .snapshots(),
                        builder: (context, tenantSnapshot) {
                          final allTenants = tenantSnapshot.hasData
                              ? tenantSnapshot.data!.docs
                              : [];

                          return ListView.builder(
                            itemCount: catDocs.length,
                            itemBuilder: (context, index) {
                              final doc = catDocs[index];
                              final data = doc.data() as Map<String, dynamic>;
                              final namaKat = data['nama'] ?? doc.id;

                              // Hitung berapa toko di 'tenants' yang memilih kategori ini
                              final jumlahToko = allTenants.where((tDoc) {
                                final tData =
                                    tDoc.data() as Map<String, dynamic>;
                                final tKat =
                                    (tData['kategori'] ??
                                            tData['category'] ??
                                            '')
                                        .toString()
                                        .toLowerCase();
                                return tKat == namaKat.toString().toLowerCase();
                              }).length;

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor: kGreen.withValues(
                                      alpha: 0.1,
                                    ),
                                    child: const Icon(
                                      Icons.category,
                                      color: kGreen,
                                    ),
                                  ),
                                  title: Text(
                                    namaKat,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '$jumlahToko toko menggunakan kategori ini',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.red,
                                    ),
                                    onPressed: () async {
                                      await FirebaseFirestore.instance
                                          .collection('bazaar_categories')
                                          .doc(doc.id)
                                          .delete();
                                    },
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

          // =================================================================
          // TAB 3: LOKASI LAPAK BAZAR (Tempat/Fakultas yang bisa ditambah)
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
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('bazaar_spots')
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: kGreen),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text('Belum ada lokasi lapak terdaftar'),
                        );
                      }

                      final spotDocs = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: spotDocs.length,
                        itemBuilder: (context, index) {
                          final doc = spotDocs[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final namaTempat = data['nama'] ?? 'Tanpa Nama';
                          final detailLokasi = data['lokasi'] ?? '-';
                          final kapasitas = data['kapasitas'] ?? 10;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              title: Text(
                                namaTempat,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                'Detail: $detailLokasi\nKapasitas: $kapasitas Lapak',
                                style: const TextStyle(fontSize: 12),
                              ),
                              isThreeLine: true,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                      size: 20,
                                    ),
                                    onPressed: () =>
                                        _showAddEditSpotDialog(doc: doc),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    onPressed: () async {
                                      await FirebaseFirestore.instance
                                          .collection('bazaar_spots')
                                          .doc(doc.id)
                                          .delete();
                                    },
                                  ),
                                ],
                              ),
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
        ],
      ),
    );
  }
}
