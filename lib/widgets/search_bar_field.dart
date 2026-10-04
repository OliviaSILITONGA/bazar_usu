import 'package:flutter/material.dart';

import '../../constants.dart';

/// Search bar standar dipakai di beberapa halaman (Home, Pesanan, dll)
/// supaya desainnya konsisten di seluruh aplikasi — latar putih + shadow
/// lembut (kSoftShadow), tanpa border tebal, mengikuti kRadiusPill.
class SearchBarField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool readOnly;

  /// Widget tambahan di sebelah kanan search bar (mis. ikon notifikasi,
  /// keranjang). Opsional — kalau null, search bar akan memenuhi lebar.
  final List<Widget>? trailing;

  const SearchBarField({
    super.key,
    required this.controller,
    this.hintText = 'Cari...',
    this.onChanged,
    this.onTap,
    this.readOnly = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(kRadiusPill),
                boxShadow: kSoftShadow,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    color: kDarkGreen.withValues(alpha: 0.55),
                    size: 21,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onChanged: onChanged,
                      onTap: onTap,
                      readOnly: readOnly,
                      style: const TextStyle(fontSize: 13.5, color: kDarkGreen),
                      decoration: InputDecoration(
                        isDense: true,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        hintText: hintText,
                        hintStyle: TextStyle(
                          color: kDarkGreen.withValues(alpha: 0.4),
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 14),
            ...trailing!,
          ],
        ],
      ),
    );
  }
}