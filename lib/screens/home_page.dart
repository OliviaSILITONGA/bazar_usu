import 'package:flutter/material.dart';

// Warna-warna utama yang dipakai berulang di halaman ini
const Color kDarkGreen = Color(0xFF3E5C3A);
const Color kLightGreen = Color(0xFFE8F0DE);
const Color kCardGreen = Color(0xFFD8E4C8);

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFD3E4C0), Color(0xFFEFF5E7)],
            stops: [0.0, 0.6],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _TopNavBar(),
                const _HeroImage(),
                const SizedBox(height: 24),
                const _HeadlineSection(),
                const SizedBox(height: 28),
                const _ActionButtons(),
                const SizedBox(height: 40),
                const _LogoBanner(),
                const SizedBox(height: 32),
                const _SectionTitle(title: 'Fitur Unggulan'),
                const SizedBox(height: 20),
                const _FeatureGrid(),
                const SizedBox(height: 40),
                const _SectionTitle(title: 'Cara Kerja'),
                const SizedBox(height: 20),
                const _HowItWorks(),
                const SizedBox(height: 40),
                const _NeedHelpSection(),
                const SizedBox(height: 20),
                const _DisclaimerBox(),
                const SizedBox(height: 24),
                const _Footer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== TOP NAV BAR ====================
class _TopNavBar extends StatelessWidget {
  const _TopNavBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          // Logo kecil + nama
          Image.asset('assets/icon/icon.png', width: 60, height: 60),
          const SizedBox(width: 8),
          const Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _NavLink('Tentang'),
                  _NavLink('Fitur'),
                  _NavLink('Cara kerja'),
                ],
              ),
            ),
          ),
          _NavButton(label: 'Login', filled: false, onPressed: () {}),
          const SizedBox(width: 8),
          _NavButton(label: 'Daftar', filled: true, onPressed: () {}),
        ],
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  const _NavLink(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        label,
        style: const TextStyle(fontSize: 13, color: kDarkGreen),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback onPressed;

  const _NavButton({
    required this.label,
    required this.filled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: filled ? kDarkGreen : kLightGreen,
        foregroundColor: filled ? Colors.white : kDarkGreen,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: filled
              ? BorderSide.none
              : const BorderSide(color: kDarkGreen, width: 1),
        ),
        textStyle: const TextStyle(fontSize: 12),
      ),
      child: Text(label),
    );
  }
}

// ==================== HERO IMAGE ====================
class _HeroImage extends StatelessWidget {
  const _HeroImage();

  @override
  Widget build(BuildContext context) {
    // Ganti dengan foto jajanan kampus asli kamu.
    // Daftarkan path ini juga di pubspec.yaml -> flutter: assets:
    return Image.asset(
      'assets/images/hero_food.jpg',
      width: double.infinity,
      height: 200,
      fit: BoxFit.cover,
    );
  }
}

// ==================== HEADLINE + ILUSTRASI ====================
class _HeadlineSection extends StatelessWidget {
  const _HeadlineSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Jajanan & Kebutuhan Kampus, Semua Jadi Satu di BazarUsu!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: kDarkGreen,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Platform online marketplace khusus mahasiswa USU buat kamu '
                  'yang mau jualan atau cari produk seputar kampus dengan '
                  'gampang, cepat, dan aman. Pas banget buat pejuang danus '
                  '(dana usaha) dan pemburu jajanan kampus!',
                  style: TextStyle(
                    fontSize: 13,
                    color: kDarkGreen.withValues(alpha: 0.85),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Ganti dengan ilustrasi burger & minuman kamu, atau hapus
          // Image.asset ini dan pakai Icon bawaan kalau tidak punya ilustrasi custom.
          Image.asset(
            'assets/images/illustration_food.png',
            width: 90,
            height: 90,
          ),
        ],
      ),
    );
  }
}

// ==================== TOMBOL AKSI ====================
class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: kDarkGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text('Jelalahi Bazar'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: kDarkGreen,
                side: const BorderSide(color: kDarkGreen),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text('Mulai Berjualan'),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== LOGO BESAR DI TENGAH ====================
class _LogoBanner extends StatelessWidget {
  const _LogoBanner();

  @override
  Widget build(BuildContext context) {
    return Center(child: Image.asset('assets/images/LogoUSU.gif', width: 180));
  }
}

// ==================== JUDUL SECTION ====================
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: kDarkGreen,
        ),
      ),
    );
  }
}

// ==================== GRID FITUR UNGGULAN ====================
class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid();

  static const List<_FeatureData> _features = [
    _FeatureData(
      icon: Icons.shopping_basket_outlined,
      title: 'Katalog Produk',
      description: 'Temukan berbagai macam jajanan kampus dan kebutuhan mahasiswa USU dengan mudah.',
    ),
    _FeatureData(
      icon: Icons.receipt_long_outlined,
      title: 'Pesanan & Transaksi Mudah',
      description:
          'Deskripsi Pesanan untuk mengatur COD atau pengiriman di area USU.',
    ),
    _FeatureData(
      icon: Icons.location_on_outlined,
      title: 'Real Time Lokasi',
      description: 'Fitur peta interaktif untuk menentukan real time lokasi kamu sekarang.',
    ),
    _FeatureData(
      icon: Icons.auto_awesome_outlined,
      title: 'Rekomendasi Pintar (AI)',
      description: 'Cari jajanan sesuai mood, selera rasa, atau budget kamu secara instan teknologi AI.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.85,
        children: _features.map((f) => _FeatureCard(data: f)).toList(),
      ),
    );
  }
}

class _FeatureData {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureData({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class _FeatureCard extends StatelessWidget {
  final _FeatureData data;
  const _FeatureCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: kDarkGreen.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: kCardGreen,
            radius: 18,
            child: Icon(data.icon, color: kDarkGreen, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            data.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: kDarkGreen,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            data.description,
            style: TextStyle(
              fontSize: 11,
              color: kDarkGreen.withValues(alpha: 0.8),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== CARA KERJA ====================
class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  static const List<_StepData> _steps = [
    _StepData(icon: Icons.person_outline, label: 'Buat Akun dan masuk'),
    _StepData(icon: Icons.search, label: 'Cari atau Pasang Produk'),
    _StepData(icon: Icons.description_outlined, label: 'Transaksi & Nikmati'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _steps.map((s) => _StepItem(data: s)).toList(),
      ),
    );
  }
}

class _StepData {
  final IconData icon;
  final String label;
  const _StepData({required this.icon, required this.label});
}

class _StepItem extends StatelessWidget {
  final _StepData data;
  const _StepItem({required this.data});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: kDarkGreen.withValues(alpha: 0.4)),
              color: kCardGreen,
            ),
            child: Icon(data.icon, color: kDarkGreen, size: 26),
          ),
          const SizedBox(height: 10),
          Text(
            data.label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: kDarkGreen),
          ),
        ],
      ),
    );
  }
}

// ==================== NEED HELP ====================
class _NeedHelpSection extends StatelessWidget {
  const _NeedHelpSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Need Help?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kDarkGreen,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Bisa hubungi nomor di bawah ini yaa..!',
            style: TextStyle(
              fontSize: 13,
              color: kDarkGreen.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 8),
          const _ContactRow(name: 'Cindy Aulia', phone: '0813-1499-1815'),
          const SizedBox(height: 2),
          const _ContactRow(name: 'SILI TONGA', phone: '0857-6298-2801'),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final String name;
  final String phone;
  const _ContactRow({required this.name, required this.phone});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 13, color: kDarkGreen),
        children: [
          TextSpan(
            text: '$name : ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: phone),
        ],
      ),
    );
  }
}

// ==================== DISCLAIMER BOX ====================
class _DisclaimerBox extends StatelessWidget {
  const _DisclaimerBox();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kCardGreen,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kDarkGreen.withValues(alpha: 0.3)),
        ),
        child: Text(
          '"Aplikasi ini masih dalam tahap pengembangan aktif sebagai bagian '
          'dari proyek perkuliahan. Mohon maaf atas segala kekurangan, kendala '
          'teknis, atau bug yang mungkin Anda temukan selama menggunakannya. '
          'Masukan dan saran Anda sangat berarti untuk penyempurnaan proyek ini."',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            color: kDarkGreen.withValues(alpha: 0.9),
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

// ==================== FOOTER ====================
class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: kDarkGreen,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Column(
        children: const [
          Text(
            'BazarUsu-Market Place Mahasiswa USU',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 11),
          ),
          SizedBox(height: 4),
          Text(
            '© 2026 BazarUsu. All rights reserved.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
