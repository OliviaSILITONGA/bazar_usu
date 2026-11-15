import 'package:flutter/material.dart';

import '../constants.dart';
import '../services/seller_chat_data.dart';
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

  // Kontak yang sudah difilter & diurutkan dari pesan terbaru
  List<SellerChatContact> get _contacts {
    final q = _query.trim().toLowerCase();
    final list = sellerChatContacts
        .where((c) => c.name.toLowerCase().contains(q))
        .toList();
    final fallback = DateTime(2000);
    list.sort(
      (a, b) => (b.last?.time ?? fallback).compareTo(a.last?.time ?? fallback),
    );
    return list;
  }

  Future<void> _openRoom(SellerChatContact contact) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SellerChatRoomPage(contact: contact)),
    );
    if (mounted) setState(() {}); // segarkan preview & badge
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
    final contacts = _contacts;

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: contacts.isEmpty
                  ? _buildEmpty()
                  : ListView.builder(
                      itemCount: contacts.length,
                      itemBuilder: (context, i) => _ContactTile(
                        contact: contacts[i],
                        onTap: () => _openRoom(contacts[i]),
                      ),
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
                ? 'Tidak ada pembeli bernama "$_query"'
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
  final SellerChatContact contact;
  final VoidCallback onTap;
  const _ContactTile({required this.contact, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final last = contact.last;
    final hasUnread = contact.unread > 0;

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
                        contact.name,
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
                        last == null
                            ? 'Belum ada pesan'
                            : '${last.fromMe ? 'Kamu: ' : ''}${last.text}',
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
                      last == null ? '' : formatChatTime(last.time),
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
                          '${contact.unread}',
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