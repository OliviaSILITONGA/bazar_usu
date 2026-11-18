import 'package:flutter/material.dart';

import '../constants.dart';
import 'chat_list_page.dart';
import 'home_page_user.dart'; // <- sesuaikan dengan nama file HomePageUser kamu
import 'orders_page.dart';
import 'profile_page.dart';
import 'fitur_AI.dart';

/// Halaman induk yang memegang SATU bottom navigation bar untuk 4 tab:
/// Beranda, Pesanan, Chat, dan Profil.
///
/// Pindah tab = ganti index (bukan Navigator.push), jadi tidak ada lagi
/// halaman yang bertumpuk dan navbar yang dobel.
class MainNavigationPage extends StatefulWidget {
  /// Tab yang aktif saat pertama dibuka:
  /// 0 = Beranda, 1 = Pesanan, 2 = Chat, 3 = Profil.
  final int initialIndex;

  const MainNavigationPage({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  late int _currentIndex = widget.initialIndex;

  // Dibuat sekali. IndexedStack menjaga state tiap tab
  // (posisi scroll, teks pencarian, dll) saat berpindah tab.
  final List<Widget> _pages = const [
    HomePageUser(),
    OrdersPage(),
    ChatListPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Tombol back di tab lain -> kembali ke Beranda dulu, baru keluar app.
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) setState(() => _currentIndex = 0);
      },
      child: Scaffold(
        backgroundColor: kBg,
        body: IndexedStack(index: _currentIndex, children: _pages),
        bottomNavigationBar: _BottomNavBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
        ),
      ),
    );
  }
}

// ==================== BOTTOM NAV BAR (SATU-SATUNYA) ====================
class _NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNavBar({required this.currentIndex, required this.onTap});

  static const List<_NavItemData> _items = [
    _NavItemData(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: 'Beranda',
    ),
    _NavItemData(
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long,
      label: 'Pesanan',
    ),
    _NavItemData(
      icon: Icons.chat_bubble_outline,
      activeIcon: Icons.chat_bubble,
      label: 'Chat',
    ),
    _NavItemData(
      icon: Icons.person_outline,
      activeIcon: Icons.person,
      label: 'Profil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SafeArea(
        top: false,
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: kDarkGreen.withValues(alpha: 0.15)),
            ),
          ),
          child: Row(
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final isActive = index == currentIndex;

              return Expanded(
                child: Semantics(
                  button: true,
                  selected: isActive,
                  label: item.label,
                  child: InkWell(
                    onTap: () => onTap(index),
                    child: Center(
                      child: Icon(
                        isActive ? item.activeIcon : item.icon,
                        size: 26,
                        color: isActive
                            ? kDarkGreen
                            : kDarkGreen.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
