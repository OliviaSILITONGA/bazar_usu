import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import '../constants.dart';

enum NotifType { delivery, promo, points }

class NotifData {
  final NotifType type;
  final String title;
  final String message;
  final String time;
  bool isRead;

  NotifData({
    required this.type,
    required this.title,
    required this.message,
    required this.time,
    this.isRead = false,
  });
}

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final List<NotifData> _notifs = [
    NotifData(
      type: NotifType.delivery,
      title: 'Driver sedang menuju lokasimu!',
      message: 'Budi Santoso (B 1234 XYZ) akan tiba dalam 8 menit. Siapkan pesananmu ya.',
      time: '2 menit lalu',
    ),
    NotifData(
      type: NotifType.promo,
      title: 'Voucher Diskon 50% untukmu!',
      message: 'Pakai kode GREEN50 untuk potongan hingga Rp 25.000. Berlaku sampai malam ini.',
      time: '1 jam lalu',
    ),
    NotifData(
      type: NotifType.delivery,
      title: 'Pesanan sedang disiapkan',
      message: 'Ayam Geprek Mozzarella dari Geprek Juara sedang dimasak oleh resto.',
      time: '3 jam lalu',
      isRead: true,
    ),
    NotifData(
      type: NotifType.promo,
      title: 'Gratis Ongkir Sepuasnya!',
      message: 'Nikmati gratis ongkir tanpa minimum order setiap hari Jumat. Yuk pesan sekarang!',
      time: 'Kemarin',
      isRead: true,
    ),
    NotifData(
      type: NotifType.points,
      title: 'GreenBite Points bertambah 120',
      message: 'Poin dari transaksi terakhirmu sudah masuk. Yuk tukar dengan reward menarik!',
      time: '2 hari lalu',
      isRead: true,
    ),
  ];

  int get _unreadCount => _notifs.where((n) => !n.isRead).length;

  void _markAllRead() {
    setState(() {
      for (final n in _notifs) {
        n.isRead = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _NotifHeader(unreadCount: _unreadCount, onMarkAllRead: _markAllRead),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                itemCount: _notifs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) => _NotifCard(data: _notifs[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== HEADER ====================
class _NotifHeader extends StatelessWidget {
  final int unreadCount;
  final VoidCallback onMarkAllRead;

  const _NotifHeader({required this.unreadCount, required this.onMarkAllRead});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notifikasi',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kDarkGreen),
                ),
                const SizedBox(height: 2),
                Text(
                  '$unreadCount pesan belum dibaca',
                  style: TextStyle(fontSize: 12.5, color: kDarkGreen.withValues(alpha: 0.6)),
                ),
              ],
            ),
          ),
          if (unreadCount > 0)
            TextButton.icon(
              onPressed: onMarkAllRead,
              icon: const Icon(Icons.check, size: 16, color: kDarkGreen),
              label: const Text('Tandai dibaca', style: TextStyle(color: kDarkGreen, fontSize: 12.5)),
              style: TextButton.styleFrom(
                backgroundColor: kLightGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close, color: kDarkGreen.withValues(alpha: 0.6)),
          ),
        ],
      ),
    );
  }
}

// ==================== KARTU NOTIFIKASI ====================
class _NotifCard extends StatelessWidget {
  final NotifData data;
  const _NotifCard({required this.data});

  IconData get _icon {
    switch (data.type) {
      case NotifType.delivery:
        return Icons.local_shipping_outlined;
      case NotifType.promo:
        return Icons.sell_outlined;
      case NotifType.points:
        return Icons.stars_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: data.isRead ? Colors.white : kLightGreen,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kDarkGreen.withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: kDarkGreen.withValues(alpha: 0.2)),
            ),
            child: Icon(_icon, size: 18, color: kDarkGreen),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: kDarkGreen),
                ),
                const SizedBox(height: 4),
                Text(
                  data.message,
                  style: TextStyle(fontSize: 12.5, color: kDarkGreen.withValues(alpha: 0.75), height: 1.4),
                ),
                const SizedBox(height: 6),
                Text(
                  data.time,
                  style: TextStyle(fontSize: 11, color: kDarkGreen.withValues(alpha: 0.5)),
                ),
              ],
            ),
          ),
          if (!data.isRead)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 2),
              decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
            ),
        ],
      ),
    );
  }
}