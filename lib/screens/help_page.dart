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

Future<void> _launchWhatsApp(
  BuildContext context, {
  required String phoneNumber,
  required String message,
}) async {
  final uri = Uri.parse(
    'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}',
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

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: _HeroHeader()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ========== 1. FAQ ==========
                    _SectionCard(
                      icon: Icons.quiz_outlined,
                      title: 'Pertanyaan Umum (FAQ)',
                      children: const [
                        _FaqCategory(
                          title: 'Akun & Profil',
                          items: [
                            _FaqItem(
                              'Bagaimana cara mendaftar akun di Bazar USU?',
                              'Buka halaman Daftar, isi data diri (nama, email kampus, nomor HP), buat kata sandi, lalu verifikasi lewat email/OTP yang dikirim.',
                            ),
                            _FaqItem(
                              'Saya lupa kata sandi, bagaimana cara menggantinya?',
                              'Di halaman Login, tekan "Lupa Kata Sandi", masukkan email terdaftar, lalu ikuti instruksi reset yang dikirim ke email kamu.',
                            ),
                            _FaqItem(
                              'Bagaimana cara jadi penjual (danusan)?',
                              'Buka menu Profil > Beralih ke Akun Penjual, lalu lengkapi formulir pendaftaran toko. Admin akan meninjau dan memberi tahu status persetujuannya.',
                            ),
                          ],
                        ),
                        _FaqCategory(
                          title: 'Pemesanan & Transaksi',
                          items: [
                            _FaqItem(
                              'Bagaimana cara melakukan pemesanan?',
                              'Pilih produk, tekan "Tambah" untuk masuk ke keranjang, lalu buka Keranjang dan ikuti langkah checkout.',
                            ),
                            _FaqItem(
                              'Bisakah saya membatalkan pesanan?',
                              'Bisa, selama penjual belum memproses pesanan. Buka halaman Pesanan Saya, pilih pesanan terkait, lalu tekan Batalkan.',
                            ),
                            _FaqItem(
                              'Berapa lama batas waktu konfirmasi pesanan oleh penjual?',
                              'Penjual wajib mengonfirmasi pesanan dalam 1x24 jam. Jika tidak ada respon, pesanan otomatis bisa dibatalkan.',
                            ),
                          ],
                        ),
                        _FaqCategory(
                          title: 'Pembayaran',
                          items: [
                            _FaqItem(
                              'Metode pembayaran apa saja yang didukung?',
                              'QRIS, transfer bank, dan Cash on Delivery (COD) saat ambil/terima pesanan.',
                            ),
                            _FaqItem(
                              'Bagaimana cara konfirmasi bukti pembayaran?',
                              'Setelah transfer, unggah bukti bayar di halaman detail pesanan agar penjual bisa memverifikasi.',
                            ),
                          ],
                        ),
                        _FaqCategory(
                          title: 'Pengambilan / Pengiriman',
                          items: [
                            _FaqItem(
                              'Di mana titik temu untuk COD?',
                              'Lokasi titik temu biasanya di area stand penjual di sekitar kampus, tertera di detail toko/pesanan.',
                            ),
                            _FaqItem(
                              'Apakah ada pengantaran ke lokasi di dalam kampus?',
                              'Beberapa penjual menyediakan opsi antar di area kampus dengan biaya tambahan, tergantung kebijakan masing-masing toko.',
                            ),
                            _FaqItem(
                              'Jam berapa stand biasanya buka?',
                              'Jam operasional berbeda tiap penjual, bisa dicek di halaman profil toko masing-masing.',
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // ========== 2. PANDUAN PENGGUNAAN ==========
                    _SectionCard(
                      icon: Icons.menu_book_outlined,
                      title: 'Panduan Penggunaan',
                      children: [
                        _SubHeading('Panduan Pembeli'),
                        const _NumberedItem(
                          1,
                          'Buka aplikasi Bazar USU. Cek alamat antar di bagian atas ("Antar ke") sebelum pesan.',
                        ),
                        const _NumberedItem(
                          2,
                          'Cari menu lewat kategori (Semua, Promo, Terdekat, Terlaris, dll) atau scroll di beranda.',
                        ),
                        const _NumberedItem(
                          3,
                          'Tekan "Tambah" pada menu yang diinginkan — otomatis masuk ke Keranjang.',
                        ),
                        const _NumberedItem(
                          4,
                          'Buka "Keranjang", cek pesanan dan total harga, lalu ikuti langkah checkout.',
                        ),
                        const _NumberedItem(
                          5,
                          'Pantau status pesanan sampai makanan diantar/siap diambil.',
                        ),
                        const SizedBox(height: 16),
                        _SubHeading('Panduan Penjual'),
                        const _NumberedItem(
                          1,
                          'Buka menu Profil, lalu tekan "Beralih ke Akun Penjual".',
                        ),
                        const _NumberedItem(
                          2,
                          'Isi formulir pendaftaran toko (nama toko, kategori, kontak) dan tunggu persetujuan admin.',
                        ),
                        const _NumberedItem(
                          3,
                          'Setelah disetujui, buka Dashboard Penjual untuk mulai mengunggah produk.',
                        ),
                        const _NumberedItem(
                          4,
                          'Tekan "Tambah Produk", isi nama, harga, foto, deskripsi, dan kategori.',
                        ),
                        const _NumberedItem(
                          5,
                          'Atur stok atau kuota pre-order (PO) kalau produk dijual dengan sistem PO.',
                        ),
                        const _NumberedItem(
                          6,
                          'Pantau pesanan masuk di Dashboard, lalu proses sesuai statusnya (Diterima → Diproses → Selesai).',
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // ========== 3. KONTAK & DUKUNGAN ==========
                    _SectionCard(
                      icon: Icons.support_agent_outlined,
                      title: 'Layanan Kontak & Dukungan',
                      initiallyExpanded: true,
                      children: [
                        _SubHeading('Kontak Admin'),
                        const SizedBox(height: 4),
                        ...kAdmins.map(
                          (admin) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _AdminWhatsAppButton(
                              admin: admin,
                              onTap: () => _launchWhatsApp(
                                context,
                                phoneNumber: admin.phoneNumber,
                                message:
                                    'Halo ${admin.name}, saya mau bertanya seputar Bazar USU...',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _SubHeading('Jam Operasional Layanan'),
                        const SizedBox(height: 4),
                        Text(
                          'Admin aktif membalas pesan setiap Senin–Jumat, pukul 08.00–20.00 WIB. '
                          'Di luar jam tersebut, balasan bisa lebih lama.',
                          style: TextStyle(
                            fontSize: 13,
                            color: kDarkGreen.withValues(alpha: 0.8),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _SubHeading('Formulir Laporan Kendala'),
                        const SizedBox(height: 8),
                        const _ComplaintFormCard(),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // ========== 4. KEBIJAKAN & KETENTUAN ==========
                    _SectionCard(
                      icon: Icons.gavel_outlined,
                      title: 'Kebijakan & Ketentuan Platform',
                      children: const [
                        _SubHeading('Syarat & Ketentuan (T&C)'),
                        SizedBox(height: 4),
                        _BulletItem(
                          'Setiap pengguna wajib mendaftar menggunakan data yang valid dan email aktif.',
                        ),
                        _BulletItem(
                          'Penjual bertanggung jawab atas kebenaran informasi produk yang diunggah (harga, stok, foto).',
                        ),
                        _BulletItem(
                          'Transaksi di luar platform (di luar kesepakatan yang tercatat) bukan tanggung jawab Bazar USU.',
                        ),
                        _BulletItem(
                          'Admin berhak menonaktifkan akun yang melanggar ketentuan penggunaan.',
                        ),
                        SizedBox(height: 14),
                        _SubHeading('Kebijakan Pembatalan & Pengembalian'),
                        SizedBox(height: 4),
                        _BulletItem(
                          'Pembeli bisa membatalkan pesanan sebelum dikonfirmasi penjual tanpa dikenai sanksi.',
                        ),
                        _BulletItem(
                          'Jika stok produk ternyata habis, penjual wajib menginformasikan dan membatalkan pesanan tersebut.',
                        ),
                        _BulletItem(
                          'Pengembalian dana (refund) untuk pembayaran non-tunai diproses sesuai kebijakan metode pembayaran terkait.',
                        ),
                        _BulletItem(
                          'Produk yang tidak sesuai pesanan bisa dilaporkan lewat Formulir Laporan Kendala di atas.',
                        ),
                        SizedBox(height: 14),
                        _SubHeading('Panduan Komunitas / Etika'),
                        SizedBox(height: 4),
                        _BulletItem(
                          'Produk yang dijual harus legal dan sesuai aturan kampus (makanan, minuman, jajanan, kebutuhan mahasiswa).',
                        ),
                        _BulletItem(
                          'Dilarang menjual barang terlarang, berbahaya, atau melanggar hukum.',
                        ),
                        _BulletItem(
                          'Jaga komunikasi yang sopan antara pembeli dan penjual.',
                        ),
                        _BulletItem(
                          'Laporkan akun atau transaksi mencurigakan lewat fitur Laporkan di halaman Profil.',
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Kebijakan ini masih bisa disesuaikan mengikuti aturan resmi dari pihak kampus/penyelenggara.',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontStyle: FontStyle.italic,
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== HERO HEADER (background foto + logo) ====================
class _HeroHeader extends StatelessWidget {
  const _HeroHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 230,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/hero_food.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: kLightGreen),
            ),
          ),
          // gradient supaya foto memudar ke warna background halaman
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [kBg.withValues(alpha: 0.25), kBg],
                  stops: const [0.0, 0.92],
                ),
              ),
            ),
          ),
          // tombol kembali
          Positioned(
            top: 8,
            left: 8,
            child: _CircleIconButton(
              icon: Icons.arrow_back_ios_new,
              onTap: () => Navigator.pop(context),
            ),
          ),
          // logo + judul
          Positioned(
            left: 20,
            right: 20,
            bottom: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    'assets/icon/icon.png',
                    width: 75,
                    height: 75,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 75,
                      height: 75,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.storefront, color: kDarkGreen),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Pusat Bantuan',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: kDarkGreen,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'FAQ, panduan, dan kontak admin Bazar USU',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: kDarkGreen.withValues(alpha: 0.75),
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

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: kDarkGreen),
      ),
    );
  }
}

// ==================== KARTU SECTION (bisa dibuka/tutup) ====================
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;
  final bool initiallyExpanded;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.children,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kDarkGreen.withValues(alpha: 0.12)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          shape: const Border(),
          collapsedShape: const Border(),
          backgroundColor: Colors.white,
          collapsedBackgroundColor: Colors.white,
          iconColor: kDarkGreen,
          collapsedIconColor: kDarkGreen,
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
          leading: Icon(icon, color: kDarkGreen, size: 22),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 14.5,
              fontWeight: FontWeight.bold,
              color: kDarkGreen,
            ),
          ),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== FAQ ====================
class _FaqItem {
  final String question;
  final String answer;
  const _FaqItem(this.question, this.answer);
}

class _FaqCategory extends StatelessWidget {
  final String title;
  final List<_FaqItem> items;
  const _FaqCategory({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SubHeading(title),
          const SizedBox(height: 6),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.question,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: kDarkGreen,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.answer,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: kDarkGreen.withValues(alpha: 0.75),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubHeading extends StatelessWidget {
  final String text;
  const _SubHeading(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.bold,
        color: kDarkGreen.withValues(alpha: 0.9),
        letterSpacing: 0.2,
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
      padding: const EdgeInsets.only(bottom: 6, top: 4),
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

// ==================== TOMBOL WHATSAPP ADMIN ====================
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

// ==================== FORMULIR LAPORAN KENDALA ====================
class _ComplaintFormCard extends StatefulWidget {
  const _ComplaintFormCard();

  @override
  State<_ComplaintFormCard> createState() => _ComplaintFormCardState();
}

class _ComplaintFormCardState extends State<_ComplaintFormCard> {
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String hint) => InputDecoration(
    isDense: true,
    hintText: hint,
    hintStyle: const TextStyle(fontSize: 12.5),
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

  void _submit() {
    final subject = _subjectController.text.trim();
    final description = _descriptionController.text.trim();

    if (subject.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Subjek dan deskripsi kendala wajib diisi!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    final message =
        'Halo Admin, saya ingin melaporkan kendala:\n\n'
        'Subjek: $subject\n'
        'Deskripsi: $description';

    _launchWhatsApp(
      context,
      phoneNumber: kAdmins.first.phoneNumber,
      message: message,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _subjectController,
          decoration: _decoration('Subjek (misal: Pesanan tidak sesuai)'),
          style: const TextStyle(fontSize: 13),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: _decoration('Jelaskan kendala yang kamu alami...'),
          style: const TextStyle(fontSize: 13),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: kDarkGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.send, size: 16),
            label: const Text('Kirim Laporan via WhatsApp'),
          ),
        ),
      ],
    );
  }
}
