import 'package:flutter/material.dart';

import 'chat_detail_page.dart';
import 'package:flutter/material.dart';
import '../constants.dart';

class ChatItemData {
  final String name;
  final String lastMessage;
  final String time;

  const ChatItemData({
    required this.name,
    required this.lastMessage,
    required this.time,
  });
}

class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  static const List<ChatItemData> _chats = [
    ChatItemData(
      name: 'KMK Teknik Kimia',
      lastMessage: 'Pesanannya dah sampai...',
      time: '1mnt',
    ),
    ChatItemData(
      name: 'Olivia',
      lastMessage: 'Pesanannya dah sampai...',
      time: '1mnt',
    ),
    ChatItemData(
      name: 'Yana',
      lastMessage: 'Pesanan dengan nomor resi...',
      time: '2hari',
    ),
    ChatItemData(
      name: 'UKM Paduan Suara ULOS USU',
      lastMessage: 'Pesanannya dah sampai...',
      time: '1mnt',
    ),
    ChatItemData(
      name: 'Yana',
      lastMessage: 'Pesanan dengan nomor resi...',
      time: '2hari',
    ),
    ChatItemData(
      name: 'Olivia',
      lastMessage: 'Pesanannya dah sampai...',
      time: '1mnt',
    ),
    ChatItemData(
      name: 'Yana',
      lastMessage: 'Pesanan dengan nomor resi...',
      time: '2hari',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            const _ChatListHeader(),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: _chats.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: kDarkGreen.withValues(alpha: 0.1),
                  indent: 80,
                ),
                itemBuilder: (context, index) {
                  final chat = _chats[index];
                  return _ChatListTile(
                    data: chat,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ChatDetailPage(contactName: chat.name),
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

// ==================== HEADER ====================
class _ChatListHeader extends StatelessWidget {
  const _ChatListHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 24), // penyeimbang biar judul center
          const Text(
            'Kontak Masuk',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: kDarkGreen,
            ),
          ),
          Icon(Icons.search, color: kDarkGreen, size: 24),
        ],
      ),
    );
  }
}

// ==================== ITEM KONTAK ====================
class _ChatListTile extends StatelessWidget {
  final ChatItemData data;
  final VoidCallback onTap;

  const _ChatListTile({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: kLightGreen,
              child: Icon(
                Icons.person,
                color: kDarkGreen.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: kDarkGreen,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${data.lastMessage} . ${data.time}',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: kDarkGreen.withValues(alpha: 0.6),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
