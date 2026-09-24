import 'package:flutter/material.dart';

import '../constants.dart';
import 'home_page_user.dart';
import 'orders_page.dart';
import 'chat_list_page.dart';
import 'profile_page.dart';
import 'fitur_AI.dart';

class MainNavigationPage extends StatefulWidget {
  final int initialIndex;
  const MainNavigationPage({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  late int _currentIndex;

  // Daftar 4 halaman utama
  final List<Widget> _pages = const [
    HomePageUser(),
    OrdersPage(),
    ChatListPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack menjaga halaman tetap tersimpan di memori tanpa merender ulang
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: kDarkGreen.withValues(alpha: 0.15)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.receipt_long_outlined,
                activeIcon: Icons.receipt_long,
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.chat_bubble_outline,
                activeIcon: Icons.chat_bubble,
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.person_outline,
                activeIcon: Icons.person,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
  }) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          _currentIndex = index; // Pindah tab secara instan tanpa lag
        });
      },
      child: SizedBox(
        width: 60,
        height: 64,
        child: Icon(
          isSelected ? activeIcon : icon,
          color: isSelected ? kDarkGreen : kDarkGreen.withValues(alpha: 0.5),
          size: isSelected ? 26 : 24,
        ),
      ),
    );
  }
}
