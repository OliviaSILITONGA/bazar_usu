import 'package:flutter/material.dart';

import '../constants.dart';
import 'seller_chat_list_page.dart';
import 'seller_home_page.dart';
import 'seller_orders_page.dart';
import 'seller_products_page.dart';
import 'seller_profile_page.dart';

class SellerMainNavigationPage extends StatefulWidget {
  const SellerMainNavigationPage({super.key});

  @override
  State<SellerMainNavigationPage> createState() =>
      _SellerMainNavigationPageState();
}

class _SellerMainNavigationPageState extends State<SellerMainNavigationPage> {
  int _index = 0;

  // Urutan halaman harus sama dengan urutan ikon di _navItems
  static const _pages = [
    SellerHomePage(),
    SellerProductsPage(),
    SellerOrdersPage(),
    SellerChatListPage(),
    SellerProfilePage(),
  ];

  static const _navItems = [
    _NavData(Icons.storefront_outlined, Icons.storefront),
    _NavData(Icons.inventory_2_outlined, Icons.inventory_2),
    _NavData(Icons.receipt_long_outlined, Icons.receipt_long),
    _NavData(Icons.chat_bubble_outline, Icons.chat_bubble),
    _NavData(Icons.person_outline, Icons.person),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: IndexedStack(index: _index, children: _pages),
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
              for (int i = 0; i < _navItems.length; i++)
                _NavItem(
                  icon: _navItems[i].icon,
                  selectedIcon: _navItems[i].selectedIcon,
                  selected: _index == i,
                  onTap: () => setState(() => _index = i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavData {
  final IconData icon;
  final IconData selectedIcon;
  const _NavData(this.icon, this.selectedIcon);
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 56,
        height: 64,
        child: Icon(
          selected ? selectedIcon : icon,
          color: selected ? kDarkGreen : kDarkGreen.withValues(alpha: 0.45),
          size: selected ? 26 : 24,
        ),
      ),
    );
  }
}