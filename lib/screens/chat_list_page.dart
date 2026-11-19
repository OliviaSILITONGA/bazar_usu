import 'package:flutter/material.dart';

import '../constants.dart';
import '../services/chat_service.dart';
import 'chat_detail_page.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  static const List<String> _defaultContacts = [
    'KMK Ilmu Komputer',
    'KMK Teknik Kimia',
    'Yana',
    'UKM Paduan Suara ULOS',
    'UKM AISEC',
    'Olivia',
    'SILI TONGA',
  ];

  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ChatThreadModel> _mergeWithDefaults(ChatThreadList dbThreads) {
    final mapByTitle = <String, ChatThreadModel>{};
    for (final t in dbThreads) {
      mapByTitle[t.title.trim().toLowerCase()] = t;
    }

    final result = <ChatThreadModel>[...dbThreads];
    for (final name in _defaultContacts) {
      final key = name.trim().toLowerCase();
      if (!mapByTitle.containsKey(key)) {
        result.add(
          ChatThreadModel(
            id: ChatService.instance.buildThreadId(name),
            title: name,
            lastMessage: 'Ketuk untuk mulai chat',
            lastSenderId: '',
            updatedAt: DateTime(2000),
            unreadCounts: const {},
            participants: [ChatService.instance.currentUserId],
          ),
        );
      }
    }

    final q = _query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? result
        : result.where((t) {
            return t.title.toLowerCase().contains(q) ||
                t.lastMessage.toLowerCase().contains(q);
          }).toList();

    filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final myId = ChatService.instance.currentUserId;

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            _ChatListHeader(
              isSearching: _isSearching,
              searchController: _searchController,
              onSearchChanged: (v) => setState(() => _query = v),
              onToggleSearch: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    _query = '';
                    _searchController.clear();
                  }
                });
              },
            ),
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

                  final threads = _mergeWithDefaults(snapshot.data ?? []);

                  if (threads.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: kDarkGreen.withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Kontak tidak ditemukan',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: kDarkGreen.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Coba masukkan kata kunci yang berbeda',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: kDarkGreen.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: threads.length,
                    separatorBuilder: (_, _) => Divider(
                      height: 1,
                      color: kDarkGreen.withValues(alpha: 0.1),
                      indent: 80,
                    ),
                    itemBuilder: (context, index) {
                      final thread = threads[index];
                      final hasUnread = thread.unreadFor(myId) > 0;
                      final hasHistory = thread.updatedAt.year > 2000;
                      final subtitle = hasHistory
                          ? (thread.lastMessage.isEmpty
                                    ? 'Belum ada pesan'
                                    : thread.lastMessage) +
                                ' · ' +
                                ChatService.instance.formatRelativeTime(
                                  thread.updatedAt,
                                )
                          : thread.lastMessage;

                      return _ChatListTile(
                        title: thread.title,
                        subtitle: subtitle,
                        hasUnread: hasUnread,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatDetailPage(
                                contactName: thread.title,
                                threadId: thread.id,
                              ),
                            ),
                          );
                        },
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

class _ChatListHeader extends StatelessWidget {
  final bool isSearching;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onToggleSearch;

  const _ChatListHeader({
    required this.isSearching,
    required this.searchController,
    required this.onSearchChanged,
    required this.onToggleSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: isSearching
            ? Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      autofocus: true,
                      onChanged: onSearchChanged,
                      decoration: InputDecoration(
                        hintText: 'Cari nama atau pesan...',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: kDarkGreen.withValues(alpha: 0.5),
                        ),
                        prefixIcon: const Icon(Icons.search, color: kDarkGreen),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 16,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close, color: kDarkGreen),
                    onPressed: onToggleSearch,
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 48),
                  const Text(
                    'Kontak Masuk',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: kDarkGreen,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search, color: kDarkGreen),
                    onPressed: onToggleSearch,
                  ),
                ],
              ),
      ),
    );
  }
}

class _ChatListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool hasUnread;
  final VoidCallback onTap;

  const _ChatListTile({
    required this.title,
    required this.subtitle,
    required this.hasUnread,
    required this.onTap,
  });

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
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: hasUnread ? FontWeight.w800 : FontWeight.bold,
                      color: kDarkGreen,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: hasUnread
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: kDarkGreen.withValues(
                        alpha: hasUnread ? 0.85 : 0.6,
                      ),
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
