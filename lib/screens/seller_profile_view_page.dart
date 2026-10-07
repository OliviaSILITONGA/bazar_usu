import 'package:flutter/material.dart';

import '../constants.dart';
import '../services/seller_state.dart';
import '../services/seller_profile_extra_state.dart';
import 'seller_edit_profile_page.dart';

class SellerProfileViewPage extends StatelessWidget {
  const SellerProfileViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
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
                      'Detail Toko',
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
            Expanded(
              child: ValueListenableBuilder<SellerApplication?>(
                valueListenable: SellerAccountState.instance.myApplication,
                builder: (context, app, _) {
                  return ValueListenableBuilder<SellerProfileExtra>(
                    valueListenable: SellerProfileExtraState.instance.data,
                    builder: (context, extra, __) {
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: kDarkGreen.withValues(alpha: 0.12),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: kLightGreen,
                                    border: Border.all(
                                      color: kDarkGreen.withValues(alpha: 0.3),
                                    ),
                                    image: extra.photo != null
                                        ? DecorationImage(
                                            image: FileImage(extra.photo!),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: extra.photo == null
                                      ? Icon(
                                          Icons.storefront,
                                          color: kDarkGreen.withValues(
                                            alpha: 0.7,
                                          ),
                                          size: 32,
                                        )
                                      : null,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Center(
                                child: Text(
                                  app?.namaToko ?? 'Toko Kamu',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: kDarkGreen,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Center(
                                child: Text(
                                  app?.kategori ?? '-',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: kDarkGreen.withValues(alpha: 0.65),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              if (extra.description.trim().isNotEmpty)
                                Text(
                                  extra.description,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                    height: 1.4,
                                  ),
                                )
                              else
                                Center(
                                  child: Text(
                                    'Belum ada deskripsi toko.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: kDarkGreen.withValues(alpha: 0.4),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 20),
                              Center(
                                child: OutlinedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const SellerEditProfilePage(),
                                      ),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: kDarkGreen,
                                    side: BorderSide(
                                      color: kDarkGreen.withValues(alpha: 0.3),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 28,
                                      vertical: 12,
                                    ),
                                  ),
                                  child: const Text(
                                    'Edit Profil Toko',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
