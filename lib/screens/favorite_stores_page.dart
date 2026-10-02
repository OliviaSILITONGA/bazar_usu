import 'package:flutter/material.dart';

import '../constants.dart';
import '../services/favorite_stores_state.dart';
import 'store_detail_page.dart';

class FavoriteStoresPage extends StatelessWidget {
  const FavoriteStoresPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _TopBar(title: 'Toko Favorit'),
            Expanded(
              child: ValueListenableBuilder<Set<String>>(
                valueListenable: FavoriteStoresState.instance.favorites,
                builder: (context, favoriteNames, _) {
                  if (favoriteNames.isEmpty) {
                    return const _EmptyFavorites();
                  }

                  final stores = favoriteNames
                      .map(resolveStoreProfile)
                      .toList();

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: stores.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) =>
                        _FavoriteStoreTile(profile: stores[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== TOP BAR ====================
class _TopBar extends StatelessWidget {
  final String title;
  const _TopBar({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 16, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            color: kDarkGreen,
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: kDarkGreen,
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

// ==================== ITEM TOKO FAVORIT ====================
class _FavoriteStoreTile extends StatelessWidget {
  final StoreProfileData profile;
  const _FavoriteStoreTile({required this.profile});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => StoreDetailPage(storeName: profile.name),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kDarkGreen.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kLightGreen,
                border: Border.all(color: kDarkGreen.withValues(alpha: 0.3)),
              ),
              child: Icon(
                Icons.storefront_outlined,
                color: kDarkGreen.withValues(alpha: 0.7),
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: kDarkGreen,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 13, color: Colors.amber),
                      const SizedBox(width: 3),
                      Text(
                        profile.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        '|',
                        style: TextStyle(color: Colors.black26, fontSize: 12),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${profile.products.length} Produk',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.favorite, color: Colors.redAccent, size: 20),
          ],
        ),
      ),
    );
  }
}

// ==================== STATE KOSONG ====================
class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.favorite_border,
              size: 48,
              color: kDarkGreen.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 14),
            Text(
              'Belum ada toko favorit',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: kDarkGreen.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tekan "Ikuti" di halaman detail toko untuk menambahkannya ke sini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: kDarkGreen.withValues(alpha: 0.5),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
