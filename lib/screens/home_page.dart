import 'package:flutter/material.dart';

import '../constants.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController = PageController();
  int _page = 0;

  static const _slideCount = 3;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Foto jajanan sebagai backdrop lembut di seluruh slide.
          Image.asset(
            'assets/images/hero_food.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: kLightGreen),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xB3E8F0DE), Color(0xFFF3F8ED)],
                stops: [0.0, 0.3],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const _TopNavBar(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (i) => setState(() => _page = i),
                    children: const [
                      _SlideHero(),
                      _SlideFitur(),
                      _SlideCaraKerjaDanInfo(),
                    ],
                  ),
                ),
                _DotIndicator(count: _slideCount, index: _page),
                const SizedBox(height: 16),
                const _BottomActions(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
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
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: const Icon(
              Icons.storefront_rounded,
              color: kDarkGreen,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Bazar USU',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: kDarkGreen,
              ),
            ),
          ),
          _PillButton(
            label: 'Login',
            filled: false,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
          const SizedBox(width: 8),
          _PillButton(
            label: 'Daftar',
            filled: true,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback onPressed;

  const _PillButton({
    required this.label,
    required this.filled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: filled ? kDarkGreen : Colors.white,
        foregroundColor: filled ? Colors.white : kDarkGreen,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kRadiusPill),
        ),
        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      child: Text(label),
    );
  }
}

// ==================== SLIDE 1: HERO + HEADLINE ====================
class _SlideHero extends StatelessWidget {
  const _SlideHero();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(kRadiusLg),
            child: Image.asset(
              'assets/images/hero_food.jpg',
              width: double.infinity,
              height: 180,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(height: 180, color: kCardGreen),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Jajanan & Kebutuhan Kampus,\nSemua Jadi Satu di BazarUsu!',
            textAlign: TextAlign.center,
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
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: kDarkGreen.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== SLIDE 2: FITUR UNGGULAN ====================
class _SlideFitur extends StatelessWidget {
  const _SlideFitur();

  static const List<_FeatureData> _features = [
    _FeatureData(
      icon: Icons.shopping_basket_outlined,
      title: 'Katalog Produk',
      description:
          'Temukan berbagai macam jajanan kampus dan kebutuhan mahasiswa '
          'USU dengan mudah.',
    ),
    _FeatureData(
      icon: Icons.receipt_long_outlined,
      title: 'Pesanan & Transaksi Mudah',
      description:
          'Deskripsi Pesanan untuk mengatur COD atau pengiriman di area '
          'USU.',
    ),
    _FeatureData(
      icon: Icons.location_on_outlined,
      title: 'Real Time Lokasi',
      description:
          'Fitur peta interaktif untuk menentukan real time lokasi kamu '
          'sekarang.',
    ),
    _FeatureData(
      icon: Icons.auto_awesome_outlined,
      title: 'Rekomendasi Pintar (AI)',
      description:
          'Cari jajanan sesuai mood, selera rasa, atau budget kamu secara '
          'instan dengan teknologi AI.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Column(
        children: [
          Image.asset(
            'assets/images/LogoUSU.gif',
            width: 120,
            errorBuilder: (_, __, ___) => const SizedBox(height: 0),
          ),
          const SizedBox(height: 12),
          const Text(
            'Fitur Unggulan',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: kDarkGreen,
            ),
          ),
          const SizedBox(height: 18),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.88,
            children: _features.map((f) => _FeatureCard(data: f)).toList(),
          ),
        ],
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(kRadiusMd),
        boxShadow: kSoftShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: kLightGreen,
            ),
            child: Icon(data.icon, color: kDarkGreen, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            data.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12.5,
              color: kDarkGreen,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            data.description,
            style: TextStyle(
              fontSize: 10.5,
              color: kDarkGreen.withValues(alpha: 0.75),
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== SLIDE 3: CARA KERJA + NEED HELP + DISCLAIMER ====================
class _SlideCaraKerjaDanInfo extends StatelessWidget {
  const _SlideCaraKerjaDanInfo();

  static const List<_StepData> _steps = [
    _StepData(icon: Icons.person_outline, label: 'Buat Akun\ndan Masuk'),
    _StepData(icon: Icons.search, label: 'Cari atau\nPasang Produk'),
    _StepData(icon: Icons.handshake_outlined, label: 'Transaksi\n& Nikmati'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Cara Kerja',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: kDarkGreen,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _steps.map((s) => _StepItem(data: s)).toList(),
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(kRadiusMd),
              boxShadow: kSoftShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Need Help?',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: kDarkGreen,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Bisa hubungi nomor di bawah ini yaa..!',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: kDarkGreen.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 8),
                const _ContactRow(name: 'Cindy Aulia', phone: '0813-1499-1815'),
                const SizedBox(height: 2),
                const _ContactRow(name: 'SILI TONGA', phone: '0857-6298-2801'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: kCardGreen,
              borderRadius: BorderRadius.circular(kRadiusMd),
            ),
            child: Text(
              '"Aplikasi ini masih dalam tahap pengembangan aktif sebagai '
              'bagian dari proyek perkuliahan. Mohon maaf atas segala '
              'kekurangan, kendala teknis, atau bug yang mungkin Anda '
              'temukan selama menggunakannya. Masukan dan saran Anda sangat '
              'berarti untuk penyempurnaan proyek ini."',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5,
                fontStyle: FontStyle.italic,
                color: kDarkGreen.withValues(alpha: 0.85),
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'BazarUsu – Market Place Mahasiswa USU\n'
            '© 2026 BazarUsu. All rights reserved.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.5,
              color: kDarkGreen.withValues(alpha: 0.6),
              height: 1.5,
            ),
          ),
        ],
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
    return Column(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: Icon(data.icon, color: kDarkGreen, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          data.label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 11,
            color: kDarkGreen,
            height: 1.3,
          ),
        ),
      ],
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
        style: const TextStyle(fontSize: 12.5, color: kDarkGreen),
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

// ==================== DOT INDICATOR ====================
class _DotIndicator extends StatelessWidget {
  final int count;
  final int index;
  const _DotIndicator({required this.count, required this.index});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active ? kDarkGreen : kDarkGreen.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(kRadiusPill),
          ),
        );
      }),
    );
  }
}

// ==================== TOMBOL AKSI (PIN DI BAWAH) ====================
class _BottomActions extends StatelessWidget {
  const _BottomActions();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kDarkGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(kRadiusPill),
                ),
              ),
              child: const Text('Jelajahi Bazar'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterPage()),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: kDarkGreen,
                side: const BorderSide(color: kDarkGreen),
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(kRadiusPill),
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