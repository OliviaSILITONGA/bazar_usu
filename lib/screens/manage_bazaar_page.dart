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

  static const List<String> _usuFaculties = [
    'Fakultas Kedokteran (FK)',
    'Fakultas Hukum (FH)',
    'Fakultas Pertanian (FP)',
    'Fakultas Teknik (FT)',
    'Fakultas Ekonomi dan Bisnis (FEB)',
    'Fakultas Kedokteran Gigi (FKG)',
    'Fakultas Ilmu Budaya (FIB)',
    'Fakultas Matematika dan Ilmu Pengetahuan Alam (FMIPA)',
    'Fakultas Ilmu Sosial dan Ilmu Politik (FISIP)',
    'Fakultas Kesehatan Masyarakat (FKM)',
    'Fakultas Psikologi (FSI)',
    'Fakultas Farmasi (FF)',
    'Fakultas Keperawatan (FKep)',
    'Fakultas Ilmu Komputer dan Teknologi Informasi (Fasilkom-TI)',
    'Fakultas Kehutanan',
    'Fakultas Vokasi',
  ];

  @override
  void initState() {
    super.initState();
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
    final docData = doc?.data() as Map<String, dynamic>?;

    String? selectedFaculty;
    final existingFaculty = (docData?['fakultas'] ?? '').toString().trim();
    if (_usuFaculties.contains(existingFaculty)) {
      selectedFaculty = existingFaculty;
    } else if (docData != null) {
      final namaLama = (docData['nama'] ?? '').toString().trim();
      for (final f in _usuFaculties) {
        if (namaLama.contains(f) ||
            existingFaculty.toLowerCase() == f.toLowerCase()) {
          selectedFaculty = f;
          break;
        }
      }
    }

    final departmentController = TextEditingController(
      text: (docData?['jurusan'] ?? docData?['prodi'] ?? '').toString(),
    );
    final locationController = TextEditingController(
      text: (docData?['lokasi'] ?? docData?['letak'] ?? '').toString(),
    );
    final capacityController = TextEditingController(
      text: docData != null ? (docData['kapasitas'] ?? '').toString() : '',
    );

    String? errorText;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                doc == null ? 'Tambah Lokasi Lapak Baru' : 'Edit Lokasi Lapak',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: selectedFaculty,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Pilih Fakultas',
                        hintText: 'Pilih fakultas USU',
                      ),
                      items: _usuFaculties
                          .map(
                            (faculty) => DropdownMenuItem<String>(
                              value: faculty,
                              child: Text(
                                faculty,
                                style: const TextStyle(fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedFaculty = value;
                          errorText = null;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: departmentController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Jurusan / Program Studi',
                        hintText: 'Contoh: Ilmu Komputer / Teknik Elektro',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: locationController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Letak / Detail Patokan Tempat',
                        hintText: 'Contoh: Gedung D Lt. 1 / Selasar Depan',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: capacityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Kapasitas Maksimal Bazar',
                        hintText: 'Contoh: 10',
                      ),
                    ),
                    if (errorText != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        errorText!,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
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
                    final jurusan = departmentController.text.trim();
                    final letak = locationController.text.trim();
                    final kapasitasText = capacityController.text.trim();

                    if (selectedFaculty == null || selectedFaculty!.isEmpty) {
                      setDialogState(() {
                        errorText = 'Silakan pilih fakultas terlebih dahulu.';
                      });
                      return;
                    }
                    if (jurusan.isEmpty || letak.isEmpty) {
                      setDialogState(() {
                        errorText = 'Jurusan dan letak lokasi wajib diisi.';
                      });
                      return;
                    }

                    final kapasitas = int.tryParse(kapasitasText) ?? 10;
                    final namaGabungan = '$selectedFaculty - $jurusan';

                    final payload = <String, dynamic>{
                      'nama': namaGabungan,
                      'fakultas': selectedFaculty,
                      'jurusan': jurusan,
                      'lokasi': letak,
                      'letak': letak,
                      'kapasitas': kapasitas,
                    };

                    if (doc == null) {
                      await FirebaseFirestore.instance
                          .collection('bazaar_spots')
                          .add({
                            ...payload,
                            'createdAt': FieldValue.serverTimestamp(),
                          });
                    } else {
                      await FirebaseFirestore.instance
                          .collection('bazaar_spots')
                          .doc(doc.id)
                          .update({
                            ...payload,
                            'updatedAt': FieldValue.serverTimestamp(),
                          });
                    }

                    if (!context.mounted) return;
                    Navigator.pop(context);
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
      },
    );
  }

  String _formatTenantLocation(Map<String, dynamic> data) {
    final alamatToko =
        (data['alamatToko'] ??
                data['lokasiBazar'] ??
                data['alamat'] ??
                data['address'] ??
                '')
            .toString()
            .trim();
    if (alamatToko.isNotEmpty) return alamatToko;

    final lokasi = (data['lokasi'] ?? '').toString().trim();
    final fakultas = (data['fakultas'] ?? '').toString().trim();
    if (lokasi.isNotEmpty && fakultas.isNotEmpty) {
      return '$fakultas - $lokasi';
    }
    if (lokasi.isNotEmpty) return lokasi;
    if (fakultas.isNotEmpty) return fakultas;
    return '';
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
          // TAB 1: DAFTAR BAZAR / DANUSAN (Nama Toko & Pemilik dari 'tenants')
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
                  final tenantId = docs[index].id;

                  final namaBazar =
                      (data['storeName'] ??
                              data['namaToko'] ??
                              data['nama'] ??
                              'Bazar Tanpa Nama')
                          .toString();

                  final pemilikLangsung =
                      data['namaPemilik'] ??
                      data['ownerName'] ??
                      data['namaOwner'] ??
                      data['owner'] ??
                      data['nama'];

                  final lokasi = _formatTenantLocation(data);
                  final status = data['status'] ?? 'pending';
                  final isApproved = status == 'approved';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    child:
                        pemilikLangsung != null &&
                            pemilikLangsung.toString().trim().isNotEmpty
                        ? _buildTenantTile(
                            namaBazar,
                            pemilikLangsung.toString(),
                            lokasi,
                            isApproved,
                          )
                        : FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('users')
                                .doc(tenantId)
                                .get(),
                            builder: (context, userSnapshot) {
                              String pemilikNama = '-';
                              if (userSnapshot.hasData &&
                                  userSnapshot.data!.exists) {
                                final userData =
                                    userSnapshot.data!.data()
                                        as Map<String, dynamic>?;
                                pemilikNama =
                                    (userData?['nama'] ??
                                            userData?['name'] ??
                                            userData?['email'] ??
                                            '-')
                                        .toString();
                              }
                              return _buildTenantTile(
                                namaBazar,
                                pemilikNama,
                                lokasi,
                                isApproved,
                              );
                            },
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
                              final namaKat = (data['nama'] ?? doc.id)
                                  .toString();

                              final jumlahToko = allTenants.where((tDoc) {
                                final tData =
                                    tDoc.data() as Map<String, dynamic>;
                                final tKat =
                                    (tData['kategori'] ??
                                            tData['category'] ??
                                            '')
                                        .toString()
                                        .toLowerCase();
                                return tKat == namaKat.toLowerCase();
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
          // TAB 3: LOKASI LAPAK BAZAR (Fakultas -> Jurusan & Letak)
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
                          final fakultas = (data['fakultas'] ?? '')
                              .toString()
                              .trim();
                          final jurusan = (data['jurusan'] ?? '')
                              .toString()
                              .trim();
                          final namaTempat =
                              (data['nama'] ??
                                      (fakultas.isNotEmpty && jurusan.isNotEmpty
                                          ? '$fakultas - $jurusan'
                                          : (fakultas.isNotEmpty
                                                ? fakultas
                                                : 'Tanpa Nama')))
                                  .toString();
                          final detailLokasi =
                              (data['lokasi'] ?? data['letak'] ?? '-')
                                  .toString();
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
                                '${jurusan.isNotEmpty ? 'Jurusan: $jurusan\n' : ''}Letak: $detailLokasi\nKapasitas: $kapasitas Lapak',
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

  Widget _buildTenantTile(
    String namaBazar,
    String pemilik,
    String lokasi,
    bool isApproved,
  ) {
    return ListTile(
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
        lokasi.isNotEmpty
            ? 'Pemilik: $pemilik\nLokasi: $lokasi'
            : 'Pemilik: $pemilik',
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isApproved ? Colors.green.shade100 : Colors.orange.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          isApproved ? 'Aktif' : 'Pending',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isApproved ? Colors.green.shade800 : Colors.orange.shade800,
          ),
        ),
      ),
    );
  }
}
