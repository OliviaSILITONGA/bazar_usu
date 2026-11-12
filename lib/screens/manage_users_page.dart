import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter =
      'Semua'; // Filter berubah menjadi: 'Semua', 'Aktif', 'Nonaktif'

  Future<void> _toggleUserStatus(
    String docId,
    String nama,
    bool currentStatus,
  ) async {
    try {
      final newStatus = !currentStatus;
      await FirebaseFirestore.instance.collection('users').doc(docId).update({
        'isActive': newStatus,
      });

      if (!mounted) return;
      final statusText = newStatus ? 'diaktifkan' : 'dinonaktifkan';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Akun $nama berhasil $statusText.'),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengubah status: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _changeRoleDialog(String docId, String nama, String currentRole) {
    String selectedRole = currentRole;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ubah Peran - $nama'),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: ['buyer', 'seller', 'admin'].map((role) {
                  String label = role == 'buyer'
                      ? 'Pembeli'
                      : (role == 'seller' ? 'Penjual' : 'Admin');
                  return RadioListTile<String>(
                    title: Text(label),
                    value: role,
                    groupValue: selectedRole,
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selectedRole = val);
                      }
                    },
                  );
                }).toList(),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kGreen),
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(docId)
                      .update({'role': selectedRole});
                  if (!mounted) return;
                  Navigator.pop(context);
                  String label = selectedRole == 'buyer'
                      ? 'Pembeli'
                      : (selectedRole == 'seller' ? 'Penjual' : 'Admin');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Peran $nama diubah menjadi $label'),
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal mengubah peran: $e'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
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
        title: const Text('Kelola Data Pengguna'),
        backgroundColor: kGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Cari nama atau email...',
                    prefixIcon: const Icon(Icons.search, color: kGreen),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(color: kGreen),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    // Filter chip diubah menjadi 'Semua', 'Aktif', 'Nonaktif'
                    children: ['Semua', 'Aktif', 'Nonaktif'].map((filterLabel) {
                      final isSelected = _selectedFilter == filterLabel;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(filterLabel),
                          selected: isSelected,
                          selectedColor: kGreen,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedFilter = filterLabel);
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: kGreen),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('Belum ada pengguna terdaftar'),
                  );
                }

                final docs = snapshot.data!.docs;

                final filteredDocs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final ktmStatus = data['ktmStatus'] ?? 'approved';

                  if (ktmStatus == 'pending' || ktmStatus == 'rejected') {
                    return false;
                  }

                  final nama = (data['nama'] ?? '').toString().toLowerCase();
                  final email = (data['email'] ?? '').toString().toLowerCase();
                  final isActive = data['isActive'] ?? true;

                  final query = _searchController.text.toLowerCase();
                  final matchesSearch =
                      nama.contains(query) || email.contains(query);

                  // Logika Filter berdasarkan status keaktifan akun
                  bool matchesFilter = true;
                  if (_selectedFilter == 'Aktif') {
                    matchesFilter = isActive == true;
                  } else if (_selectedFilter == 'Nonaktif') {
                    matchesFilter = isActive == false;
                  }

                  return matchesSearch && matchesFilter;
                }).toList();

                if (filteredDocs.isEmpty) {
                  return const Center(child: Text('Pengguna tidak ditemukan'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredDocs.length,
                  itemBuilder: (context, index) {
                    final doc = filteredDocs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final docId = doc.id;

                    final nama = data['nama'] ?? 'Tanpa Nama';
                    final email = data['email'] ?? 'Email tidak tersedia';
                    final role = data['role'] ?? 'buyer';
                    final fakultas =
                        data['fakultas'] ?? 'Universitas Sumatera Utara';
                    final isActive = data['isActive'] ?? true;

                    String displayRole = 'Pembeli';
                    if (role == 'admin') {
                      displayRole = 'Admin';
                    } else if (role == 'seller' || role == 'penjual') {
                      displayRole = 'Penjual';
                    }

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
                          backgroundColor: isActive
                              ? kGreen.withValues(alpha: 0.1)
                              : Colors.grey.shade200,
                          child: Icon(
                            displayRole == 'Admin'
                                ? Icons.admin_panel_settings
                                : displayRole == 'Penjual'
                                ? Icons.store
                                : Icons.person,
                            color: isActive ? kGreen : Colors.grey,
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                nama,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: isActive
                                      ? TextDecoration.none
                                      : TextDecoration.lineThrough,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Menampilkan badge status keaktifan (Aktif / Nonaktif)
                            _buildStatusBadge(isActive),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(email, style: const TextStyle(fontSize: 12)),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  'Fakultas: $fakultas',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Menampilkan teks peran kecil di bawah agar tetap terlihat perannya
                                Text(
                                  '• Peran: $displayRole',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'role') {
                              _changeRoleDialog(docId, nama, role);
                            } else if (value == 'status') {
                              _toggleUserStatus(docId, nama, isActive);
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'role',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, size: 18),
                                  SizedBox(width: 8),
                                  Text('Ubah Peran'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'status',
                              child: Row(
                                children: [
                                  Icon(
                                    isActive
                                        ? Icons.block
                                        : Icons.check_circle_outline,
                                    size: 18,
                                    color: isActive ? Colors.red : Colors.green,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isActive ? 'Nonaktifkan' : 'Aktifkan',
                                    style: TextStyle(
                                      color: isActive
                                          ? Colors.red
                                          : Colors.green,
                                    ),
                                  ),
                                ],
                              ),
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
    );
  }

  // Widget Badge untuk Status Keaktifan (Menggantikan _buildRoleBadge)
  Widget _buildStatusBadge(bool isActive) {
    final color = isActive ? kGreen : Colors.red;
    final label = isActive ? 'Aktif' : 'Nonaktif';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
