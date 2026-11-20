import 'package:flutter/material.dart';

import '../constants.dart';
import '../services/chat_service.dart';
import 'seller_chat_room_page.dart';

class SellerChatListPage extends StatefulWidget {
  const SellerChatListPage({super.key});

  @override
  State<SellerChatListPage> createState() => _SellerChatListPageState();
}

class _SellerChatListPageState extends State<SellerChatListPage> {
  final _searchController = TextEditingController();
  bool _searching = false;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _searching = !_searching;
      if (!_searching) {
        _query = '';
        _searchController.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final myId = ChatService.instance.currentUserId;

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: StreamBuilder<ChatThreadList>(
                stream: ChatService.instance.threadsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(color: kDarkGreen),
                    );
                  }

                  final q = _query.trim().toLowerCase();
                  final contacts = (snapshot.data ?? []).where((c) {
                    if (q.isEmpty) return true;
                    return c.title.toLowerCase().contains(q) ||
                        c.lastMessage.toLowerCase().contains(q);
                  }).toList();

                  if (contacts.isEmpty) {
                    return _buildEmpty();
                  }

                  return ListView.builder(
                    itemCount: contacts.length,
                    itemBuilder: (context, i) => _ContactTile(
                      contact: contacts[i],
                      currentUserId: myId,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SellerChatRoomPage(
                              threadId: contacts[i].id,
                              contactName: contacts[i].title,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 8, 8),
      child: SizedBox(
        height: 48,
        child: _searching
            ? Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      onChanged: (v) => setState(() => _query = v),
                      style: const TextStyle(fontSize: 14, color: kDarkGreen),
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Cari pembeli...',
                        hintStyle: TextStyle(
                          color: kDarkGreen.withValues(alpha: 0.5),
                          fontSize: 13,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: kDarkGreen.withValues(alpha: 0.7),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: kDarkGreen.withValues(alpha: 0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: kDarkGreen.withValues(alpha: 0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(
                            color: kDarkGreen,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _toggleSearch,
                    icon: const Icon(Icons.close, color: kDarkGreen),
                  ),
                ],
              )
            : Stack(
                alignment: Alignment.center,
                children: [
                  const Text(
                    'Kontak Masuk',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: kDarkGreen,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: _toggleSearch,
                      icon: const Icon(Icons.search, color: kDarkGreen),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildEmpty() {
    final searching = _query.trim().isNotEmpty;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            searching ? Icons.search_off : Icons.chat_bubble_outline,
            size: 44,
            color: kDarkGreen.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 10),
          Text(
            searching
                ? 'Tidak ada pembeli bernama $_query'
                : 'Belum ada pesan masuk',
            style: TextStyle(
              fontSize: 13,
              color: kDarkGreen.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  final ChatThreadModel contact;
  final String currentUserId;
  final VoidCallback onTap;

  const _ContactTile({
    required this.contact,
    required this.currentUserId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final unread = contact.unreadFor(currentUserId);
    final hasUnread = unread > 0;
    final isFromMe = contact.lastSenderId == currentUserId;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: kLightGreen,
                  child: Icon(
                    Icons.person,
                    color: kDarkGreen.withValues(alpha: 0.5),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contact.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: kDarkGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        contact.lastMessage.isEmpty
                            ? 'Belum ada pesan'
                            : (isFromMe ? 'Kamu: ' : '') + contact.lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: hasUnread
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: kDarkGreen.withValues(
                            alpha: hasUnread ? 0.85 : 0.55,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      contact.lastMessage.isEmpty
                          ? ''
                          : ChatService.instance.formatRelativeTime(
                              contact.updatedAt,
                            ),
                      style: TextStyle(
                        fontSize: 11.5,
                        color: kDarkGreen.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (hasUnread)
                      Container(
                        constraints: const BoxConstraints(minWidth: 20),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: kDarkGreen,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          unread.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      const SizedBox(height: 18),
                  ],
                ),
              ],
            ),
          ),
        ),
        Divider(
          height: 1,
          indent: 74,
          color: kDarkGreen.withValues(alpha: 0.1),
        ),
      ],
    );
  }
}
