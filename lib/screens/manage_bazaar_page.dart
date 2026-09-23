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

  // Data simulasi Lapak Bazar
  final List<Map<String, dynamic>> _spots = [
    {
      'id': '1',
      'nama': 'Lapak Gedung A - Pendopo USU',
      'lokasi': 'Fasilkom-TI / Samping Perpustakaan',
      'kapasitas': 10,
      'terisi': 8,
      'status': 'Aktif',
    },
    {
      'id': '2',
      'nama': 'Lapak Parkiran FEB',
      'lokasi': 'Pelataran Fakultas Ekonomi',
      'kapasitas': 15,
      'terisi': 15,
      'status': 'Penuh',
    },
    {
      'id': '3',
      'nama': 'Lapak Lapangan Pancasila',
      'lokasi': 'Area Tengah Kampus USU',
      'kapasitas': 20,
      'terisi': 5,
      'status': 'Aktif',
    },
  ];

  // Data simulasi Kategori Produk
  final List<Map<String, dynamic>> _categories = [
    {
      'id': '1',
      'nama': 'Makanan Berat',
      'icon': Icons.restaurant,
      'jumlahToko': 12,
    },
    {
      'id': '2',
      'nama': 'Minuman & Danusan',
      'icon': Icons.local_drink,
      'jumlahToko': 18,
    },
    {
      'id': '3',
      'nama': 'Camilan & Dessert',
      'icon': Icons.icecream,
      'jumlahToko': 9,
    },
    {
      'id': '4',
      'nama': 'Merchandise & Stiker',
      'icon': Icons.card_giftcard,
      'jumlahToko': 5,
    },
    {
      'id': '5',
      'nama': 'Jasa & Pre-Order',
      'icon': Icons.build,
      'jumlahToko': 3,
    },
  ];

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

  // Dialog Tambah / Edit Lapak
  void _showAddEditSpotDialog({Map<String, dynamic>? spot, int? index}) {
    final nameController = TextEditingController(
      text: spot != null ? spot['nama'] : '',
    );
    final locationController = TextEditingController(
      text: spot != null ? spot['lokasi'] : '',
    );
    final capacityController = TextEditingController(
      text: spot != null ? spot['kapasitas'].toString() : '',
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(spot == null ? 'Tambah Area Lapak' : 'Edit Area Lapak'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama Area Lapak'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Lokasi / Patokan',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: capacityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Kapasitas Toko'),
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
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    capacityController.text.isNotEmpty) {
                  setState(() {
                    if (spot == null) {
                      _spots.add({
                        'id': DateTime.now().millisecondsSinceEpoch.toString(),
                        'nama': nameController.text,
                        'lokasi': locationController.text,
                        'kapasitas':
                            int.tryParse(capacityController.text) ?? 10,
                        'terisi': 0,
                        'status': 'Aktif',
                      });
                    } else if (index != null) {
                      _spots[index]['nama'] = nameController.text;
                      _spots[index]['lokasi'] = locationController.text;
                      _spots[index]['kapasitas'] =
                          int.tryParse(capacityController.text) ??
                          _spots[index]['kapasitas'];
                    }
                  });
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

  // Dialog Tambah Kategori
  void _showAddCategoryDialog() {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Tambah Kategori Baru'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Nama Kategori',
              hintText: 'Contoh: Aksesoris',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kGreen),
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  setState(() {
                    _categories.add({
                      'id': DateTime.now().millisecondsSinceEpoch.toString(),
                      'nama': nameController.text,
                      'icon': Icons.category,
                      'jumlahToko': 0,
                    });
                  });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
      appBar: AppBar(
        title: const Text('Lapak & Kategori'),
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
            Tab(text: 'Area Lapak Bazar'),
            Tab(text: 'Kategori Produk'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: AREA LAPAK
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
                    label: const Text('Tambah Area Lapak Baru'),
                    onPressed: () => _showAddEditSpotDialog(),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: _spots.length,
                    itemBuilder: (context, index) {
                      final spot = _spots[index];
                      final isFull = spot['terisi'] >= spot['kapasitas'];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      spot['nama'],
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
                                      borderRadius: BorderRadius.circular(12),
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
                                      spot['lokasi'],
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
                                    'Kapasitas: ${spot['terisi']} / ${spot['kapasitas']} Toko',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
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
                                        onPressed: () => _showAddEditSpotDialog(
                                          spot: spot,
                                          index: index,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          size: 20,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          setState(
                                            () => _spots.removeAt(index),
                                          );
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
                  ),
                ),
              ],
            ),
          ),

          // TAB 2: KATEGORI PRODUK
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
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Kategori Baru'),
                    onPressed: _showAddCategoryDialog,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: kGreen.withValues(alpha: 0.1),
                            child: Icon(cat['icon'] as IconData, color: kGreen),
                          ),
                          title: Text(
                            cat['nama'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${cat['jumlahToko']} toko menggunakan kategori ini',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              setState(() => _categories.removeAt(index));
                            },
                          ),
                        ),
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
