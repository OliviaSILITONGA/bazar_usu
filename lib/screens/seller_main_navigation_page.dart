import 'package:flutter/material.dart';

import '../constants.dart';
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

  static const _pages = [
    SellerHomePage(),
    SellerProductsPage(),
    SellerOrdersPage(),
    SellerProfilePage(),
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
              _NavItem(
                icon: Icons.storefront_outlined,
                selectedIcon: Icons.storefront,
                selected: _index == 0,
                onTap: () => setState(() => _index = 0),
              ),
              _NavItem(
                icon: Icons.inventory_2_outlined,
                selectedIcon: Icons.inventory_2,
                selected: _index == 1,
                onTap: () => setState(() => _index = 1),
              ),
              _NavItem(
                icon: Icons.receipt_long_outlined,
                selectedIcon: Icons.receipt_long,
                selected: _index == 2,
                onTap: () => setState(() => _index = 2),
              ),
              _NavItem(
                icon: Icons.person_outline,
                selectedIcon: Icons.person,
                selected: _index == 3,
                onTap: () => setState(() => _index = 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
      onTap: onTap,
      child: Icon(
        selected ? selectedIcon : icon,
        color: selected ? kDarkGreen : kDarkGreen.withValues(alpha: 0.45),
        size: selected ? 26 : 24,
      ),
    );
  }
}