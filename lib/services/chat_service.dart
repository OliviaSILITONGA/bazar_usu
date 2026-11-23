import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatMessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String text;
  final DateTime createdAt;
  final bool isRead;

  const ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderRole = 'buyer',
    required this.text,
    required this.createdAt,
    this.isRead = false,
  });

  factory ChatMessageModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final ts = data['createdAt'];
    final dt = ts is Timestamp ? ts.toDate() : DateTime.now();

    return ChatMessageModel(
      id: doc.id,
      senderId: (data['senderId'] ?? '').toString(),
      senderName: (data['senderName'] ?? '').toString(),
      senderRole: (data['senderRole'] ?? 'buyer').toString(),
      text: (data['text'] ?? '').toString(),
      createdAt: dt,
      isRead: data['isRead'] == true,
    );
  }
}

class ChatThreadModel {
  final String id;
  final String sellerId;
  final String sellerName;
  final String buyerId;
  final String buyerName;
  final String title;
  final String lastMessage;
  final String lastSenderId;
  final String lastSenderRole;
  final DateTime updatedAt;
  final Map<String, int> unreadCounts;
  final List<String> participants;

  const ChatThreadModel({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    required this.buyerId,
    required this.buyerName,
    required this.title,
    required this.lastMessage,
    required this.lastSenderId,
    required this.lastSenderRole,
    required this.updatedAt,
    required this.unreadCounts,
    required this.participants,
  });

  factory ChatThreadModel.fromDoc(
    DocumentSnapshot doc, {
    required String currentUserId,
    required bool isSellerView,
  }) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final ts = data['updatedAt'];
    final dt = ts is Timestamp ? ts.toDate() : DateTime.now();

    final rawUnread = data['unreadCounts'] as Map<String, dynamic>? ?? {};
    final unreadMap = <String, int>{};
    rawUnread.forEach((key, value) {
      unreadMap[key.toString()] = value is int
          ? value
          : int.tryParse(value.toString()) ?? 0;
    });

    final rawParticipants = data['participants'] as List<dynamic>? ?? [];
    final participants = rawParticipants.map((e) => e.toString()).toList();

    final sellerId = (data['sellerId'] ?? '').toString().trim();
    final sellerName = (data['sellerName'] ?? '').toString().trim();
    final buyerId = (data['buyerId'] ?? '').toString().trim();
    final buyerName = (data['buyerName'] ?? '').toString().trim();

    String resolvedTitle;
    if (isSellerView) {
      resolvedTitle = buyerName.isNotEmpty
          ? buyerName
          : (data['buyerName'] ?? data['title'] ?? 'Pembeli').toString();
    } else {
      resolvedTitle = sellerName.isNotEmpty
          ? sellerName
          : (data['sellerName'] ?? data['title'] ?? 'Penjual').toString();
    }

    return ChatThreadModel(
      id: doc.id,
      sellerId: sellerId,
      sellerName: sellerName.isEmpty ? resolvedTitle : sellerName,
      buyerId: buyerId,
      buyerName: buyerName.isEmpty ? 'Pembeli' : buyerName,
      title: resolvedTitle,
      lastMessage: (data['lastMessage'] ?? '').toString(),
      lastSenderId: (data['lastSenderId'] ?? '').toString(),
      lastSenderRole: (data['lastSenderRole'] ?? 'buyer').toString(),
      updatedAt: dt,
      unreadCounts: unreadMap,
      participants: participants,
    );
  }

  int unreadFor(String userId) => unreadCounts[userId] ?? 0;

  bool isLastMessageReadByPeer(String currentUserId) {
    if (lastSenderId != currentUserId) return false;
    final peerId = currentUserId == buyerId ? sellerId : buyerId;
    if (peerId.isEmpty) return false;
    return (unreadCounts[peerId] ?? 0) == 0;
  }
}

typedef ChatMessageList = List<ChatMessageModel>;
typedef ChatThreadList = List<ChatThreadModel>;

class ChatService {
  ChatService._();
  static final ChatService instance = ChatService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUserId => _auth.currentUser?.uid ?? 'guest_user';

  String get currentUserName {
    final user = _auth.currentUser;
    if (user == null) return 'Pengguna';
    final display = (user.displayName ?? '').trim();
    if (display.isNotEmpty) return display;
    final email = (user.email ?? '').trim();
    if (email.contains('@')) return email.split('@').first;
    return 'Pengguna';
  }

  String _slug(String input) {
    final s = input
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    return s.isEmpty ? 'user' : s;
  }

  String buildBuyerSellerThreadId({
    required String buyerId,
    required String sellerKey,
  }) {
    return 'buyer_' + _slug(buyerId) + '__seller_' + _slug(sellerKey);
  }

  Future<String> resolveCurrentUserDisplayName() async {
    final user = _auth.currentUser;
    if (user == null) return currentUserName;

    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data() ?? {};
        final dbName = (data['nama'] ?? data['name'] ?? '').toString().trim();
        if (dbName.isNotEmpty) return dbName;
      }
    } catch (_) {}

    return currentUserName;
  }

  /// Mengecek koleksi `users` dan `tenants` agar cocok meskipun nama toko ditulis berbeda kapitalisasi.
  /// Mencari UID akun penjual berdasarkan nama toko / danus di Firestore.
  Future<String> resolveSellerIdByStoreName(String storeName) async {
    final cleanStore = storeName.trim();
    if (cleanStore.isEmpty) return 'seller_unknown';

    final lowerStore = cleanStore.toLowerCase();

    try {
      // 1. Cek koleksi `tenants` terlebih dahulu (karena namaToko disimpan di sini)
      final tenantsSnap = await _db.collection('tenants').limit(200).get();
      for (final doc in tenantsSnap.docs) {
        final data = doc.data();
        final tName = (data['namaToko'] ?? data['storeName'] ?? '')
            .toString()
            .trim()
            .toLowerCase();
        if (tName == lowerStore) {
          final ownerId =
              (data['uid'] ?? data['ownerId'] ?? data['userId'] ?? doc.id)
                  .toString()
                  .trim();
          if (ownerId.isNotEmpty) return ownerId;
        }
      }

      // 2. Fallback cek koleksi `users`
      final snapshot = await _db.collection('users').limit(200).get();
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final s1 = (data['storeName'] ?? '').toString().trim().toLowerCase();
        final s2 = (data['namaToko'] ?? '').toString().trim().toLowerCase();
        final s3 = (data['nama'] ?? data['name'] ?? '')
            .toString()
            .trim()
            .toLowerCase();
        if (s1 == lowerStore || s2 == lowerStore || s3 == lowerStore) {
          return doc.id;
        }
      }
    } catch (_) {}

    return 'seller_' + _slug(cleanStore);
  }

  /// Stream thread untuk halaman chat PEMBELI.
  Stream<ChatThreadList> buyerThreadsStream() {
    final uid = currentUserId;
    return _db
        .collection('chats')
        .where('participants', arrayContains: uid)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .where((doc) {
                final data = doc.data();
                final bId = (data['buyerId'] ?? '').toString();
                final sId = (data['sellerId'] ?? '').toString();
                return bId == uid && sId != uid;
              })
              .map(
                (doc) => ChatThreadModel.fromDoc(
                  doc,
                  currentUserId: uid,
                  isSellerView: false,
                ),
              )
              .toList();
          list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          return list;
        });
  }

  /// Stream thread untuk halaman chat PENJUAL.
  /// Menggabungkan query berdasarkan `sellerId == uid` dan `participants arrayContains uid`
  /// (dengan fallback slug nama toko jika sellerId lama belum memakai UID akun).
  Stream<ChatThreadList> sellerThreadsStream() async* {
    final uid = currentUserId;
    final storeKeys = <String>{uid};

    try {
      // Cek dokumen `tenants/{uid}` secara langsung
      final myTenantDoc = await _db.collection('tenants').doc(uid).get();
      if (myTenantDoc.exists) {
        final tData = myTenantDoc.data() ?? {};
        for (final key in [tData['namaToko'], tData['storeName']]) {
          final raw = (key ?? '').toString().trim();
          if (raw.isNotEmpty) {
            storeKeys.add('seller_' + _slug(raw));
          }
        }
      }

      // Cek juga jika ada dokumen tenants dengan field `uid == uid`
      final tenantsByUid = await _db
          .collection('tenants')
          .where('uid', isEqualTo: uid)
          .get();
      for (final doc in tenantsByUid.docs) {
        final tData = doc.data();
        for (final key in [tData['namaToko'], tData['storeName']]) {
          final raw = (key ?? '').toString().trim();
          if (raw.isNotEmpty) {
            storeKeys.add('seller_' + _slug(raw));
          }
        }
      }

      // Cek koleksi `users/{uid}`
      final userDoc = await _db.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final uData = userDoc.data() ?? {};
        for (final key in [
          uData['storeName'],
          uData['namaToko'],
          uData['nama'],
          uData['name'],
        ]) {
          final raw = (key ?? '').toString().trim();
          if (raw.isNotEmpty) {
            storeKeys.add('seller_' + _slug(raw));
          }
        }
      }
    } catch (_) {}

    await for (final snapshot in _db.collection('chats').snapshots()) {
      final list = snapshot.docs
          .where((doc) {
            final data = doc.data();
            final sId = (data['sellerId'] ?? '').toString().trim();
            final bId = (data['buyerId'] ?? '').toString().trim();
            final participants = (data['participants'] as List<dynamic>? ?? [])
                .map((e) => e.toString().trim())
                .toList();
            final hasBuyerMsg = data['hasBuyerMessage'] == true;
            final lastMsg = (data['lastMessage'] ?? '').toString().trim();

            final matchesSeller =
                sId == uid ||
                participants.contains(uid) ||
                storeKeys.contains(sId);

            return matchesSeller &&
                bId.isNotEmpty &&
                bId != uid &&
                (hasBuyerMsg || lastMsg.isNotEmpty);
          })
          .map(
            (doc) => ChatThreadModel.fromDoc(
              doc,
              currentUserId: uid,
              isSellerView: true,
            ),
          )
          .toList();

      list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      yield list;
    }
  }

  Stream<ChatMessageList> messagesStream(String threadId) {
    return _db
        .collection('chats')
        .doc(threadId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ChatMessageModel.fromDoc(doc))
              .toList(),
        );
  }

  /// Mengirim pesan dari sisi PEMBELI ke PENJUAL.
  Future<void> sendBuyerMessage({
    required String sellerName,
    required String text,
    String? sellerId,
    String? threadId,
  }) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;

    final uid = currentUserId;
    final cleanSellerName = sellerName.trim().isEmpty
        ? 'Penjual'
        : sellerName.trim();
    final resolvedSellerId = (sellerId != null && sellerId.trim().isNotEmpty)
        ? sellerId.trim()
        : await resolveSellerIdByStoreName(cleanSellerName);

    final resolvedThreadId = (threadId != null && threadId.trim().isNotEmpty)
        ? threadId.trim()
        : buildBuyerSellerThreadId(buyerId: uid, sellerKey: resolvedSellerId);

    final buyerDisplayName = await resolveCurrentUserDisplayName();

    final threadRef = _db.collection('chats').doc(resolvedThreadId);
    final msgRef = threadRef.collection('messages').doc();

    final batch = _db.batch();
    batch.set(msgRef, {
      'senderId': uid,
      'senderName': buyerDisplayName,
      'senderRole': 'buyer',
      'text': cleanText,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    batch.set(threadRef, {
      'buyerId': uid,
      'buyerName': buyerDisplayName,
      'sellerId': resolvedSellerId,
      'sellerName': cleanSellerName,
      'title': cleanSellerName,
      'participants': FieldValue.arrayUnion([uid, resolvedSellerId]),
      'hasBuyerMessage': true,
      'lastMessage': cleanText,
      'lastSenderId': uid,
      'lastSenderRole': 'buyer',
      'updatedAt': FieldValue.serverTimestamp(),
      'unreadCounts': {uid: 0, resolvedSellerId: FieldValue.increment(1)},
    }, SetOptions(merge: true));

    await batch.commit();
  }

  /// Mengirim pesan balasan dari sisi PENJUAL ke PEMBELI.
  Future<void> sendSellerMessage({
    required String threadId,
    required String buyerName,
    required String text,
    String? buyerId,
  }) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty || threadId.trim().isEmpty) return;

    final uid = currentUserId;
    final sellerDisplayName = await resolveCurrentUserDisplayName();

    final threadRef = _db.collection('chats').doc(threadId.trim());
    final msgRef = threadRef.collection('messages').doc();

    final batch = _db.batch();
    batch.set(msgRef, {
      'senderId': uid,
      'senderName': sellerDisplayName,
      'senderRole': 'seller',
      'text': cleanText,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    final unreadMap = <String, dynamic>{uid: 0};
    final updateData = <String, dynamic>{
      'sellerId': uid,
      'sellerName': sellerDisplayName,
      'buyerName': buyerName.trim().isEmpty ? 'Pembeli' : buyerName.trim(),
      'participants': FieldValue.arrayUnion([uid]),
      'lastMessage': cleanText,
      'lastSenderId': uid,
      'lastSenderRole': 'seller',
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (buyerId != null && buyerId.trim().isNotEmpty) {
      updateData['buyerId'] = buyerId.trim();
      updateData['participants'] = FieldValue.arrayUnion([uid, buyerId.trim()]);
      unreadMap[buyerId.trim()] = FieldValue.increment(1);
    }
    updateData['unreadCounts'] = unreadMap;

    batch.set(threadRef, updateData, SetOptions(merge: true));
    await batch.commit();
  }

  Future<void> markAsRead(String threadId) async {
    if (threadId.trim().isEmpty) return;
    final uid = currentUserId;
    await _db.collection('chats').doc(threadId.trim()).set({
      'unreadCounts': {uid: 0},
    }, SetOptions(merge: true));

    try {
      final msgs = await _db
          .collection('chats')
          .doc(threadId.trim())
          .collection('messages')
          .where('senderId', isNotEqualTo: uid)
          .get();
      if (msgs.docs.isNotEmpty) {
        final batch = _db.batch();
        for (final doc in msgs.docs) {
          if (doc.data()['isRead'] != true) {
            batch.update(doc.reference, {'isRead': true});
          }
        }
        await batch.commit();
      }
    } catch (_) {}
  }

  String formatRelativeTime(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'baru saja';
    if (d.inMinutes < 60) return d.inMinutes.toString() + 'mnt';
    if (d.inHours < 24) return d.inHours.toString() + 'jam';
    return d.inDays.toString() + 'hari';
  }

  String formatClock(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return h + ':' + m;
  }
}
