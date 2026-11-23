import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constants.dart';

enum NotifType { delivery, promo, points }

class NotifData {
  final String? id;
  final NotifType type;
  final String title;
  final String message;
  final String time;
  final DateTime createdAt;
  bool isRead;

  NotifData({
    this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.time,
    DateTime? createdAt,
    this.isRead = false,
  }) : createdAt = createdAt ?? DateTime.now();

  static NotifType _parseType(String? raw) {
    switch ((raw ?? '').trim().toLowerCase()) {
      case 'promo':
        return NotifType.promo;
      case 'points':
        return NotifType.points;
      case 'delivery':
      default:
        return NotifType.delivery;
    }
  }

  static String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays == 1) return 'Kemarin';
    return '${diff.inDays} hari lalu';
  }

  factory NotifData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final ts = data['createdAt'];
    final dt = ts is Timestamp ? ts.toDate() : DateTime.now();

    return NotifData(
      id: doc.id,
      type: _parseType(data['type']?.toString()),
      title: (data['title'] ?? 'Update Pesanan').toString(),
      message: (data['message'] ?? '').toString(),
      time: _formatTimeAgo(dt),
      createdAt: dt,
      isRead: data['isRead'] == true,
    );
  }
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    NotifType type = NotifType.delivery,
    String? orderId,
    String? storeName,
    String? status,
  }) async {
    final targetUid = userId.trim();
    if (targetUid.isEmpty) return;

    await _db.collection('notifications').add({
      'userId': targetUid,
      'type': type.name,
      'title': title.trim(),
      'message': message.trim(),
      'orderId': orderId ?? '',
      'storeName': storeName ?? '',
      'status': status ?? '',
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> notifyOrderStatusChange({
    required String buyerId,
    required String orderId,
    required String storeName,
    required String newStatus,
    List<String> itemNames = const [],
  }) async {
    final cleanBuyerId = buyerId.trim();
    if (cleanBuyerId.isEmpty) return;

    final cleanStore = storeName.trim().isEmpty ? 'Danusan' : storeName.trim();
    final itemsSummary = itemNames.where((e) => e.trim().isNotEmpty).join(', ');
    final itemLabel = itemsSummary.isNotEmpty ? ' ($itemsSummary)' : '';
    final statusLower = newStatus.trim().toLowerCase();

    String title;
    String message;

    if (statusLower == 'akan diterima' || statusLower == 'diproses') {
      title = 'Pesanan diterima oleh $cleanStore!';
      message =
          'Pesananmu$itemLabel di $cleanStore sudah diterima dan sedang disiapkan/diproses.';
    } else if (statusLower == 'ditolak') {
      title = 'Pesanan ditolak oleh $cleanStore';
      message =
          'Maaf, pesananmu$itemLabel di $cleanStore ditolak. Cek tab Ditolak di halaman pesanan untuk detailnya.';
    } else if (statusLower == 'untuk diulas') {
      title = 'Pesanan tiba / siap diulas';
      message =
          'Pesananmu$itemLabel dari $cleanStore sudah diterima. Yuk beri ulasan atau selesaikan pesanan!';
    } else if (statusLower == 'pesanan selesai' || statusLower == 'selesai') {
      title = 'Pesanan selesai';
      message =
          'Transaksi pesanan$itemLabel di $cleanStore telah selesai. Terima kasih sudah berbelanja!';
    } else if (statusLower == 'pengembalian') {
      title = 'Pengajuan pengembalian diproses';
      message =
          'Pengembalian pesanan$itemLabel di $cleanStore sedang ditindaklanjuti.';
    } else {
      title = 'Status pesanan: $newStatus';
      message =
          'Update terbaru untuk pesananmu$itemLabel di $cleanStore: $newStatus.';
    }

    await createNotification(
      userId: cleanBuyerId,
      title: title,
      message: message,
      type: NotifType.delivery,
      orderId: orderId,
      storeName: cleanStore,
      status: newStatus,
    );
  }

  Stream<List<NotifData>> userNotificationsStream() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value([]);

    return _db
        .collection('notifications')
        .where('userId', isEqualTo: uid)
        .snapshots()
        .map((snap) {
          final list =
              snap.docs.map((doc) => NotifData.fromFirestore(doc)).toList()
                ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  Future<void> markAsRead(String notifId) async {
    if (notifId.trim().isEmpty) return;
    await _db.collection('notifications').doc(notifId.trim()).update({
      'isRead': true,
    });
  }

  Future<void> markAllUserNotificationsRead() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final snap = await _db
        .collection('notifications')
        .where('userId', isEqualTo: uid)
        .where('isRead', isEqualTo: false)
        .get();

    if (snap.docs.isEmpty) return;

    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  Future<void> _markAllRead() async {
    try {
      await NotificationService.instance.markAllUserNotificationsRead();
    } catch (_) {}
  }

  Future<void> _handleTapNotif(NotifData item) async {
    if (item.isRead) return;
    if (item.id != null && item.id!.isNotEmpty) {
      try {
        await NotificationService.instance.markAsRead(item.id!);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: StreamBuilder<List<NotifData>>(
          stream: NotificationService.instance.userNotificationsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: kDarkGreen),
              );
            }

            final items = snapshot.data ?? [];
            final unreadCount = items.where((n) => !n.isRead).length;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _NotifHeader(
                  unreadCount: unreadCount,
                  onMarkAllRead: _markAllRead,
                ),
                Expanded(
                  child: items.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.notifications_none_outlined,
                                size: 56,
                                color: kDarkGreen.withValues(alpha: 0.3),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Belum ada notifikasi',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: kDarkGreen.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          itemCount: items.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return _NotifCard(
                              data: item,
                              onTap: () => _handleTapNotif(item),
                            );
                          },
                        ),
                ),
              ],
            );
          },
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
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kDarkGreen,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$unreadCount pesan belum dibaca',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: kDarkGreen.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          if (unreadCount > 0)
            TextButton.icon(
              onPressed: onMarkAllRead,
              icon: const Icon(Icons.check, size: 16, color: kDarkGreen),
              label: const Text(
                'Tandai dibaca',
                style: TextStyle(color: kDarkGreen, fontSize: 12.5),
              ),
              style: TextButton.styleFrom(
                backgroundColor: kLightGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
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
  final VoidCallback onTap;

  const _NotifCard({required this.data, required this.onTap});

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
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: kDarkGreen,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.message,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: kDarkGreen.withValues(alpha: 0.75),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    data.time,
                    style: TextStyle(
                      fontSize: 11,
                      color: kDarkGreen.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            if (!data.isRead)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 2),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
