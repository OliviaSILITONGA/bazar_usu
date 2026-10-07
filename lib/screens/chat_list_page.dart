import 'package:flutter/material.dart';

import 'orders_page.dart';
import 'profile_page.dart';
import 'chat_detail_page.dart';

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

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  static const List<ChatItemData> _allChats = [
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

  final TextEditingController _searchController = TextEditingController();
  List<ChatItemData> _filteredChats = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _filteredChats = _allChats; // Inisialisasi awal menampilkan semua chat
  }

  void _filterChats(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredChats = _allChats;
      } else {
        _filteredChats = _allChats.where((chat) {
          final nameLower = chat.name.toLowerCase();
          final msgLower = chat.lastMessage.toLowerCase();
          final searchLower = query.toLowerCase();

          return nameLower.contains(searchLower) ||
              msgLower.contains(searchLower);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header dengan fungsionalitas Toggle Search Bar
            _ChatListHeader(
              isSearching: _isSearching,
              searchController: _searchController,
              onSearchChanged: _filterChats,
              onToggleSearch: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) {
                    _searchController.clear();
                    _filteredChats = _allChats;
                  }
                });
              },
            ),

            // Menampilkan daftar chat atau tampilan kosong jika tidak ditemukan
            Expanded(
              child: _filteredChats.isEmpty
                  ? Center(
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
                    )
                  : ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: _filteredChats.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: kDarkGreen.withValues(alpha: 0.1),
                        indent: 80,
                      ),
                      itemBuilder: (context, index) {
                        final chat = _filteredChats[index];
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
      bottomNavigationBar: const _BottomNavBar(),
    );
  }
}

// ==================== HEADER ====================
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
                  const SizedBox(width: 48), // Penyeimbang tata letak judul
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

// ==================== BOTTOM NAV BAR ====================
class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: kDarkGreen.withValues(alpha: 0.15)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(
                Icons.home,
                color: kDarkGreen.withValues(alpha: 0.5),
                size: 26,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OrdersPage()),
                );
              },
              child: Icon(
                Icons.receipt_long_outlined,
                color: kDarkGreen.withValues(alpha: 0.5),
                size: 24,
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: const Icon(Icons.chat_bubble, color: kDarkGreen, size: 24),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                );
              },
              child: Icon(
                Icons.person_outline,
                color: kDarkGreen.withValues(alpha: 0.5),
                size: 26,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
