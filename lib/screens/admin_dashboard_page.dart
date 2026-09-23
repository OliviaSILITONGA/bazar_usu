import 'package:flutter/material.dart';

import '../constants.dart';
import 'login_screen.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F8),
      appBar: AppBar(
        title: const Text('Admin Dashboard - Bazar USU'),
        backgroundColor: kGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ringkasan Aktivitas Admin
            const Text(
              'Ringkasan Sistem',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatCard('Total User', '128', Icons.people, Colors.blue),
                const SizedBox(width: 12),
                _buildStatCard(
                  'Toko/Danusan',
                  '24',
                  Icons.store,
                  Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Menu Pengelolaan Admin
            const Text(
              'Menu Pengelolaan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _buildAdminTile(
              title: 'Verifikasi Pendaftaran Penjual',
              subtitle: '3 toko mahasiswa menunggu persetujuan',
              icon: Icons.verified_user_outlined,
              badgeCount: 3,
              onTap: () {},
            ),
            _buildAdminTile(
              title: 'Kelola Data Pengguna',
              subtitle: 'Lihat, nonaktifkan, atau atur peran akun',
              icon: Icons.manage_accounts_outlined,
              onTap: () {},
            ),
            _buildAdminTile(
              title: 'Kelola Lapak Bazar & Kategori',
              subtitle: 'Atur daftar spot bazar di lingkungan USU',
              icon: Icons.category_outlined,
              onTap: () {},
            ),
            _buildAdminTile(
              title: 'Laporan Transaksi & Pengaduan',
              subtitle: 'Pantau laporan pelanggaran atau masalah pesanan',
              icon: Icons.report_problem_outlined,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String count,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.1),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  count,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminTile({
    required String title,
    required String subtitle,
    required IconData icon,
    int badgeCount = 0,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(icon, color: kGreen, size: 30),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: badgeCount > 0
            ? CircleAvatar(
                radius: 12,
                backgroundColor: Colors.red,
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              )
            : const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
