import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants.dart';

class _AdminData {
  final String name;
  final String phoneNumber; // format: kode negara (62) + nomor tanpa 0 di depan
  const _AdminData({required this.name, required this.phoneNumber});
}

const List<_AdminData> kAdmins = [
  _AdminData(name: 'Cindy Aulia', phoneNumber: '6281314991815'),
  _AdminData(name: 'SILI TONGA', phoneNumber: '6285762983801'),
];

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  Future<void> _openWhatsApp(BuildContext context, _AdminData admin) async {
    final uri = Uri.parse(
      'https://wa.me/${admin.phoneNumber}'
      '?text=${Uri.encodeComponent('Halo ${admin.name}, saya mau bertanya seputar Bazar USU...')}',
    );

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tidak bisa membuka WhatsApp. Pastikan WhatsApp terpasang di HP kamu.',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ---------- Header ----------
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
                      'Bantuan',
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
            // ---------- Isi manual (scrollable) ----------
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                children: [
                  const Text(
                    'User Manual Bazar USU',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: kDarkGreen,
                    ),
                  ),
                  const SizedBox(height: 20),

                  const _ManualSection(
                    title: '1. Apa Itu Bazar USU?',
                    children: [
                      _Paragraph(
                        'Bazar USU itu marketplace kuliner buat mahasiswa. Di sini kita bisa '
                        'cari makanan lokal, minuman segar, sama jajanan favorit di sekitar '
                        'kampus, terus langsung pesan dari HP. Banyak juga menu yang lagi '
                        'promo, jadi lumayan hemat buat anak kos.',
                      ),
                    ],
                  ),

                  const _ManualSection(
                    title: '2. Cara Mulai',
                    children: [
                      _NumberedItem(
                        1,
                        'Buka aplikasi Bazar USU di HP kamu. Gak perlu ribet.',
                      ),
                      _NumberedItem(
                        2,
                        'Lihat alamat antar di bagian paling atas (tulisan "Antar ke"). Pastikan alamatnya sudah benar sebelum pesan.',
                      ),
                      _NumberedItem(
                        3,
                        'Di bawahnya ada banner "Bazar USU AI" dan deretan kategori.',
                      ),
                      _NumberedItem(
                        4,
                        'Scroll ke bawah ke bagian "Rekomendasi Untukmu". Di situ ada menu-menu yang bisa dipilih.',
                      ),
                    ],
                  ),

                  _ManualSection(
                    title: '3. Tombol di Bagian Bawah',
                    children: [
                      const _Paragraph(
                        'Ada empat tombol yang selalu muncul di bawah layar:',
                      ),
                      const SizedBox(height: 10),
                      _InfoTable(
                        rows: const [
                          ['Beranda', 'Balik ke halaman utama.'],
                          [
                            'Pencarian',
                            'Cari menu atau penjual yang diinginkan.',
                          ],
                          [
                            'Keranjang',
                            'Lihat menu yang sudah dipilih. Angka kecil di ikonnya menunjukkan jumlah item.',
                          ],
                          ['Profil', 'Atur akun dan data diri.'],
                        ],
                      ),
                    ],
                  ),

                  const _ManualSection(
                    title: '4. Kategori Menu',
                    children: [
                      _Paragraph(
                        'Di bawah banner ada tombol kategori. Tinggal diketuk buat menyaring '
                        'menu yang tampil:',
                      ),
                      SizedBox(height: 6),
                      _BulletItem('Semua: menampilkan semua menu.'),
                      _BulletItem('Promo Hari Ini: menu yang lagi diskon.'),
                      _BulletItem(
                        'Terdekat: penjual yang paling dekat dari alamat kita.',
                      ),
                      _BulletItem(
                        'Terlaris: menu yang paling banyak dipesan orang.',
                      ),
                      _BulletItem(
                        'Jajanan Lokal: martabak, pisang goreng, dan sejenisnya.',
                      ),
                      _BulletItem('Minuman Segar: kopi, teh, jus.'),
                      _BulletItem(
                        'Healthy Food: salad, gado-gado, dan menu sehat lainnya.',
                      ),
                    ],
                  ),

                  const _ManualSection(
                    title: '5. Cara Baca Kartu Menu',
                    children: [
                      _Paragraph(
                        'Setiap menu punya kartu yang isinya kira-kira begini:',
                      ),
                      SizedBox(height: 6),
                      _BulletItem(
                        'Foto makanan, lengkap dengan tulisan persen (contoh -34%) yang artinya diskon.',
                      ),
                      _BulletItem(
                        'Angka bintang (contoh 4.8) adalah rating dari pembeli. Makin tinggi makin bagus.',
                      ),
                      _BulletItem(
                        'Nama penjual dan jenis makanannya, contoh: Geprek Juara, Ayam & Sambal.',
                      ),
                      _BulletItem(
                        'Waktu dan jarak (contoh 15-20 min, 1.2 km) adalah perkiraan makanan siap dan jarak penjual dari kita.',
                      ),
                      _BulletItem(
                        'Dua harga: yang dicoret harga asli, satunya lagi harga setelah diskon.',
                      ),
                      _BulletItem(
                        'Tombol "Tambah" buat memasukkan menu ke keranjang.',
                      ),
                    ],
                  ),

                  _ManualSection(
                    title: '6. Contoh Menu yang Ada',
                    children: [
                      const _Paragraph(
                        'Beberapa menu yang tersedia di halaman utama:',
                      ),
                      const SizedBox(height: 10),
                      _InfoTable(
                        rows: const [
                          [
                            'Ayam & Sambal',
                            'Ayam Geprek Mozzarella, Ayam Bakar Taliwang',
                          ],
                          [
                            'Minuman',
                            'Es Kopi Susu Gula Aren, Thai Tea Original, Iced Matcha Latte',
                          ],
                          [
                            'Masakan Rumahan',
                            'Nasi Goreng Kampung, Soto Ayam Lamongan, Nasi Rendang Padang',
                          ],
                          [
                            'Bakso & Mie',
                            'Bakso Urat Jumbo, Mie Ayam Ceker Special',
                          ],
                          [
                            'Jajanan',
                            'Martabak Manis Coklat Keju, Pisang Goreng Keju Coklat, Dimsum Ayam Komplit',
                          ],
                          [
                            'Sehat & Segar',
                            'Salad Buah Segar, Gado-Gado Jakarta, Jus Alpukat Coklat',
                          ],
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Menu dan harga bisa berubah sewaktu-waktu, jadi lihat langsung di aplikasinya ya.',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontStyle: FontStyle.italic,
                          color: kDarkGreen.withValues(alpha: 0.65),
                        ),
                      ),
                    ],
                  ),

                  const _ManualSection(
                    title: '7. Cara Pesan',
                    children: [
                      _NumberedItem(
                        1,
                        'Pilih menu yang diinginkan, bisa lewat kategori atau langsung scroll.',
                      ),
                      _NumberedItem(
                        2,
                        'Tekan tombol "Tambah". Menu otomatis masuk ke keranjang. Kalau mau menu lain, tinggal tekan "Tambah" lagi di menu itu.',
                      ),
                      _NumberedItem(
                        3,
                        'Buka "Keranjang" di tombol bawah. Cek lagi pesanan dan total harganya.',
                      ),
                      _NumberedItem(
                        4,
                        'Kalau sudah pas, ikuti langkah di layar buat konfirmasi pesanan.',
                      ),
                      _NumberedItem(
                        5,
                        'Tunggu makanan diantar ke alamat yang tertera di bagian atas.',
                      ),
                      SizedBox(height: 10),
                      _Paragraph(
                        'Catatan: kalau keranjang masih kosong, akan muncul tulisan "Keranjangmu '
                        'masih kosong". Kalau pesan dari beberapa penjual sekaligus, waktu '
                        'sampainya bisa beda-beda tergantung jaraknya.',
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),
                  Divider(color: kDarkGreen.withValues(alpha: 0.15)),
                  const SizedBox(height: 20),

                  // ---------- Kontak Admin WhatsApp ----------
                  const Text(
                    'Masih Butuh Bantuan?',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: kDarkGreen,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Kalau manual di atas belum menjawab pertanyaan kamu, langsung hubungi admin kami lewat WhatsApp.',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: kDarkGreen.withValues(alpha: 0.7),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...kAdmins.map(
                    (admin) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _AdminWhatsAppButton(
                        admin: admin,
                        onTap: () => _openWhatsApp(context, admin),
                      ),
                    ),
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

// ==================== WIDGET-WIDGET PEMBANTU ====================

class _ManualSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _ManualSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: kDarkGreen,
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _Paragraph extends StatelessWidget {
  final String text;
  const _Paragraph(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        color: kDarkGreen.withValues(alpha: 0.8),
        height: 1.5,
      ),
    );
  }
}

class _NumberedItem extends StatelessWidget {
  final int number;
  final String text;
  const _NumberedItem(this.number, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$number. ',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: kDarkGreen,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: kDarkGreen.withValues(alpha: 0.8),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BulletItem extends StatelessWidget {
  final String text;
  const _BulletItem(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•  ',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: kDarkGreen.withValues(alpha: 0.8),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: kDarkGreen.withValues(alpha: 0.8),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tabel sederhana 2 kolom (judul kiri tebal, keterangan kanan)
class _InfoTable extends StatelessWidget {
  final List<List<String>> rows;
  const _InfoTable({required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kDarkGreen.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: List.generate(rows.length, (index) {
          final row = rows[index];
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 92,
                      child: Text(
                        row[0],
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: kDarkGreen,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        row[1],
                        style: TextStyle(
                          fontSize: 12.5,
                          color: kDarkGreen.withValues(alpha: 0.75),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (index != rows.length - 1)
                Divider(height: 1, color: kDarkGreen.withValues(alpha: 0.08)),
            ],
          );
        }),
      ),
    );
  }
}

class _AdminWhatsAppButton extends StatelessWidget {
  final _AdminData admin;
  final VoidCallback onTap;
  const _AdminWhatsAppButton({required this.admin, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFDFF5E3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF8FD8A3)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Color(0xFF25D366),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.chat, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    admin.name,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: kDarkGreen,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Chat admin via WhatsApp',
                    style: TextStyle(fontSize: 11.5, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: kDarkGreen, size: 20),
          ],
        ),
      ),
    );
  }
}
