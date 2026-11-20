import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatMessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime createdAt;

  const ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.createdAt,
  });

  factory ChatMessageModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final ts = data['createdAt'];
    final dt = ts is Timestamp ? ts.toDate() : DateTime.now();

    return ChatMessageModel(
      id: doc.id,
      senderId: (data['senderId'] ?? '').toString(),
      senderName: (data['senderName'] ?? '').toString(),
      text: (data['text'] ?? '').toString(),
      createdAt: dt,
    );
  }
}

class ChatThreadModel {
  final String id;
  final String title;
  final String lastMessage;
  final String lastSenderId;
  final DateTime updatedAt;
  final Map<String, int> unreadCounts;
  final List<String> participants;

  const ChatThreadModel({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.lastSenderId,
    required this.updatedAt,
    required this.unreadCounts,
    required this.participants,
  });

  factory ChatThreadModel.fromDoc(
    DocumentSnapshot doc, {
    required String currentUserId,
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

    final rawNames = data['participantNames'] as Map<String, dynamic>? ?? {};
    String resolvedTitle = (data['title'] ?? '').toString().trim();

    if (resolvedTitle.isEmpty && rawNames.isNotEmpty) {
      for (final entry in rawNames.entries) {
        if (entry.key.toString() != currentUserId) {
          resolvedTitle = entry.value.toString().trim();
          if (resolvedTitle.isNotEmpty) break;
        }
      }
    }

    if (resolvedTitle.isEmpty) {
      resolvedTitle = (data['contactName'] ?? 'Pengguna').toString();
    }

    return ChatThreadModel(
      id: doc.id,
      title: resolvedTitle,
      lastMessage: (data['lastMessage'] ?? '').toString(),
      lastSenderId: (data['lastSenderId'] ?? '').toString(),
      updatedAt: dt,
      unreadCounts: unreadMap,
      participants: participants,
    );
  }

  int unreadFor(String userId) => unreadCounts[userId] ?? 0;
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

  String buildThreadId(String contactName) {
    final cleanContact = contactName
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    final safeContact = cleanContact.isEmpty ? 'contact' : cleanContact;
    return '${currentUserId}__$safeContact';
  }

  Future<String> ensureThread({
    required String contactName,
    String? peerUserId,
  }) async {
    final cleanName = contactName.trim().isEmpty
        ? 'Kontak'
        : contactName.trim();
    final threadId = buildThreadId(cleanName);
    final docRef = _db.collection('chats').doc(threadId);
    final snap = await docRef.get();

    final participants = <String>[currentUserId];
    if (peerUserId != null && peerUserId.trim().isNotEmpty) {
      participants.add(peerUserId.trim());
    }

    if (!snap.exists) {
      await docRef.set({
        'title': cleanName,
        'contactName': cleanName,
        'participants': participants,
        'participantNames': {
          currentUserId: currentUserName,
          cleanName: cleanName,
        },
        'lastMessage': '',
        'lastSenderId': '',
        'unreadCounts': {currentUserId: 0},
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    return threadId;
  }

  Stream<ChatThreadList> threadsStream() {
    return _db
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map(
                (doc) =>
                    ChatThreadModel.fromDoc(doc, currentUserId: currentUserId),
              )
              .toList();
          list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          return list;
        });
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

  Future<void> sendMessage({
    required String threadId,
    required String contactName,
    required String text,
    String? peerUserId,
  }) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;

    final resolvedThreadId = threadId.trim().isEmpty
        ? buildThreadId(contactName)
        : threadId.trim();

    final threadRef = _db.collection('chats').doc(resolvedThreadId);
    final msgRef = threadRef.collection('messages').doc();

    final participants = <String>[currentUserId];
    if (peerUserId != null && peerUserId.trim().isNotEmpty) {
      participants.add(peerUserId.trim());
    }

    final batch = _db.batch();
    batch.set(msgRef, {
      'senderId': currentUserId,
      'senderName': currentUserName,
      'text': cleanText,
      'createdAt': FieldValue.serverTimestamp(),
    });

    final updateData = <String, dynamic>{
      'title': contactName.trim(),
      'contactName': contactName.trim(),
      'participants': FieldValue.arrayUnion(participants),
      'participantNames.$currentUserId': currentUserName,
      'lastMessage': cleanText,
      'lastSenderId': currentUserId,
      'updatedAt': FieldValue.serverTimestamp(),
      'unreadCounts.$currentUserId': 0,
    };

    if (peerUserId != null && peerUserId.trim().isNotEmpty) {
      updateData['unreadCounts.${peerUserId.trim()}'] = FieldValue.increment(1);
    }

    batch.set(threadRef, updateData, SetOptions(merge: true));
    await batch.commit();
  }

  Future<void> markAsRead(String threadId) async {
    if (threadId.isEmpty) return;
    await _db.collection('chats').doc(threadId).set({
      'unreadCounts': {currentUserId: 0},
    }, SetOptions(merge: true));
  }

  String formatRelativeTime(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'baru saja';
    if (d.inMinutes < 60) return '${d.inMinutes}mnt';
    if (d.inHours < 24) return '${d.inHours}jam';
    return '${d.inDays}hari';
  }

  String formatClock(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
