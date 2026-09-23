import 'package:flutter/material.dart';

import '../constants.dart';

class ManageUsersPage extends StatefulWidget {
  const ManageUsersPage({super.key});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Semua';

  // Data simulasi daftar pengguna sistem Bazar USU
  final List<Map<String, dynamic>> _users = [
    {
      'id': '1',
      'nama': 'Budi Santoso',
      'email': 'budi.fasilkom@usu.ac.id',
      'role': 'Penjual',
      'fakultas': 'Fasilkom-TI',
      'isActive': true,
    },
    {
      'id': '2',
      'nama': 'Siti Rahma',
      'email': 'siti.feb@usu.ac.id',
      'role': 'Penjual',
      'fakultas': 'Ekonomi & Bisnis',
      'isActive': true,
    },
    {
      'id': '3',
      'nama': 'Rian Pratama',
      'email': 'rian.fh@usu.ac.id',
      'role': 'Pembeli',
      'fakultas': 'Hukum',
      'isActive': true,
    },
    {
      'id': '4',
      'nama': 'Anisa Putri',
      'email': 'anisa.fk@usu.ac.id',
      'role': 'Pembeli',
      'fakultas': 'Kedokteran',
      'isActive': false,
    },
    {
      'id': '5',
      'nama': 'Admin Bazar',
      'email': 'admin@usu.ac.id',
      'role': 'Admin',
      'fakultas': 'Biro Kampus',
      'isActive': true,
    },
  ];

  void _toggleUserStatus(int index) {
    setState(() {
      _users[index]['isActive'] = !_users[index]['isActive'];
    });

    final status = _users[index]['isActive'] ? 'diaktifkan' : 'dinonaktifkan';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Akun ${_users[index]['nama']} berhasil $status.'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _changeRoleDialog(int index) {
    String currentRole = _users[index]['role'];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Ubah Peran - ${_users[index]['nama']}'),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: ['Pembeli', 'Penjual', 'Admin'].map((role) {
                  return RadioListTile<String>(
                    title: Text(role),
                    value: role,
                    groupValue: currentRole,
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => currentRole = val);
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
              onPressed: () {
                setState(() {
                  _users[index]['role'] = currentRole;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Peran ${_users[index]['nama']} diubah menjadi $currentRole',
                    ),
                  ),
                );
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
    // Logika pencarian dan filter pengguna
    final filteredUsers = _users.where((user) {
      final matchesSearch =
          user['nama'].toString().toLowerCase().contains(
            _searchController.text.toLowerCase(),
          ) ||
          user['email'].toString().toLowerCase().contains(
            _searchController.text.toLowerCase(),
          );
      final matchesFilter =
          _selectedFilter == 'Semua' || user['role'] == _selectedFilter;
      return matchesSearch && matchesFilter;
    }).toList();

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
          // Baris Pencarian & Filter
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
                    children: ['Semua', 'Pembeli', 'Penjual', 'Admin'].map((
                      role,
                    ) {
                      final isSelected = _selectedFilter == role;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(role),
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
                              setState(() => _selectedFilter = role);
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

          // Daftar Pengguna
          Expanded(
            child: filteredUsers.isEmpty
                ? const Center(child: Text('Pengguna tidak ditemukan'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      final originalIndex = _users.indexWhere(
                        (u) => u['id'] == user['id'],
                      );

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
                            backgroundColor: user['isActive']
                                ? kGreen.withValues(alpha: 0.1)
                                : Colors.grey.shade200,
                            child: Icon(
                              user['role'] == 'Admin'
                                  ? Icons.admin_panel_settings
                                  : user['role'] == 'Penjual'
                                  ? Icons.store
                                  : Icons.person,
                              color: user['isActive'] ? kGreen : Colors.grey,
                            ),
                          ),
                          title: Row(
                            children: [
                              Text(
                                user['nama'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  decoration: user['isActive']
                                      ? TextDecoration.none
                                      : TextDecoration.lineThrough,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildRoleBadge(user['role']),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                user['email'],
                                style: const TextStyle(fontSize: 12),
                              ),
                              Text(
                                'Fakultas: ${user['fakultas']}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'role') {
                                _changeRoleDialog(originalIndex);
                              } else if (value == 'status') {
                                _toggleUserStatus(originalIndex);
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
                                      user['isActive']
                                          ? Icons.block
                                          : Icons.check_circle_outline,
                                      size: 18,
                                      color: user['isActive']
                                          ? Colors.red
                                          : Colors.green,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      user['isActive']
                                          ? 'Nonaktifkan'
                                          : 'Aktifkan',
                                      style: TextStyle(
                                        color: user['isActive']
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
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    Color color;
    switch (role) {
      case 'Admin':
        color = Colors.purple;
        break;
      case 'Penjual':
        color = Colors.orange;
        break;
      default:
        color = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        role,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
