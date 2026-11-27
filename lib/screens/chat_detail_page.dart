import 'package:flutter/material.dart';

import '../constants.dart';
import '../services/chat_service.dart';
import 'store_detail_page.dart';

class ChatDetailPage extends StatefulWidget {
  final String contactName;
  final String? threadId;
  final String? peerUserId;

  const ChatDetailPage({
    super.key,
    required this.contactName,
    this.threadId,
    this.peerUserId,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late String _threadId;
  late String _displayStoreName;
  String? _resolvedSellerId;
  bool _isSending = false;
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _displayStoreName = widget.contactName;
    _threadId = (widget.threadId != null && widget.threadId!.trim().isNotEmpty)
        ? widget.threadId!.trim()
        : '';
    _initBuyerThread();
  }

  Future<void> _initBuyerThread() async {
    try {
      final sellerId =
          (widget.peerUserId != null && widget.peerUserId!.trim().isNotEmpty)
          ? widget.peerUserId!.trim()
          : await ChatService.instance.resolveSellerIdByStoreName(
              widget.contactName,
            );
      final resolvedStore =
          await ChatService.instance.resolveStoreNameBySellerId(sellerId) ??
          widget.contactName;
      final computedThreadId = _threadId.isNotEmpty
          ? _threadId
          : ChatService.instance.buildBuyerSellerThreadId(
              buyerId: ChatService.instance.currentUserId,
              sellerKey: sellerId,
            );

      if (mounted) {
        setState(() {
          _resolvedSellerId = sellerId;
          _displayStoreName = resolvedStore;
          _threadId = computedThreadId;
        });
      }

      await ChatService.instance.markAsRead(computedThreadId);
    } catch (_) {}
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchQuery = '';
        _searchController.clear();
      }
    });
  }

  void _openStoreDetail() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StoreDetailPage(storeName: _displayStoreName),
      ),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_isSending) return;
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);
    _messageController.clear();

    try {
      final sellerId =
          _resolvedSellerId ??
          await ChatService.instance.resolveSellerIdByStoreName(
            _displayStoreName,
          );
      final activeThreadId = _threadId.isNotEmpty
          ? _threadId
          : ChatService.instance.buildBuyerSellerThreadId(
              buyerId: ChatService.instance.currentUserId,
              sellerKey: sellerId,
            );

      if (_threadId != activeThreadId && mounted) {
        setState(() {
          _resolvedSellerId = sellerId;
          _threadId = activeThreadId;
        });
      }

      await ChatService.instance.sendBuyerMessage(
        sellerName: _displayStoreName,
        sellerId: sellerId,
        threadId: activeThreadId,
        text: text,
      );
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim pesan: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myId = ChatService.instance.currentUserId;

    return Scaffold(
      backgroundColor: kBg,
      resizeToAvoidBottomInset: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: _ChatDetailHeader(
          contactName: _displayStoreName,
          isSearching: _isSearching,
          searchController: _searchController,
          onSearchChanged: (v) => setState(() => _searchQuery = v),
          onToggleSearch: _toggleSearch,
          onProfileTap: _openStoreDetail,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _threadId.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(color: kDarkGreen),
                  )
                : StreamBuilder<ChatMessageList>(
                    stream: ChatService.instance.messagesStream(_threadId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting &&
                          !snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(color: kDarkGreen),
                        );
                      }

                      final allMessages = snapshot.data ?? [];
                      final q = _searchQuery.trim().toLowerCase();
                      final messages = q.isEmpty
                          ? allMessages
                          : allMessages
                                .where((m) => m.text.toLowerCase().contains(q))
                                .toList();

                      if (messages.isEmpty) {
                        return Center(
                          child: Text(
                            q.isEmpty
                                ? 'Mulai percakapan dengan $_displayStoreName'
                                : 'Pesan tidak ditemukan',
                            style: TextStyle(
                              fontSize: 13,
                              color: kDarkGreen.withValues(alpha: 0.5),
                            ),
                          ),
                        );
                      }

                      if (q.isEmpty) {
                        _scrollToBottom();
                      }

                      return ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          final isMe = msg.senderId == myId;
                          return _ChatBubble(
                            text: msg.text,
                            timeText: ChatService.instance.formatClock(
                              msg.createdAt,
                            ),
                            isMe: isMe,
                            isRead: msg.isRead,
                          );
                        },
                      );
                    },
                  ),
          ),
          _MessageInputBar(
            controller: _messageController,
            isSending: _isSending,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}

class _ChatDetailHeader extends StatelessWidget {
  final String contactName;
  final bool isSearching;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onToggleSearch;
  final VoidCallback onProfileTap;

  const _ChatDetailHeader({
    required this.contactName,
    required this.isSearching,
    required this.searchController,
    required this.onSearchChanged,
    required this.onToggleSearch,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kDarkGreen,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: isSearching
              ? Row(
                  children: [
                    IconButton(
                      onPressed: onToggleSearch,
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        autofocus: true,
                        onChanged: onSearchChanged,
                        style: const TextStyle(fontSize: 14, color: kDarkGreen),
                        decoration: InputDecoration(
                          isDense: true,
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Cari pesan di obrolan...',
                          hintStyle: TextStyle(
                            color: kDarkGreen.withValues(alpha: 0.5),
                            fontSize: 13,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 9,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      onPressed: onToggleSearch,
                      icon: const Icon(Icons.close, color: Colors.white),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                )
              : Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: onProfileTap,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: kLightGreen,
                                child: Icon(
                                  Icons.person,
                                  color: kDarkGreen.withValues(alpha: 0.6),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      contactName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'ketuk ini untuk melihat profil',
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.75,
                                        ),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onToggleSearch,
                      icon: const Icon(
                        Icons.search,
                        color: Colors.white,
                        size: 22,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final String text;
  final String timeText;
  final bool isMe;
  final bool isRead;

  const _ChatBubble({
    required this.text,
    required this.timeText,
    required this.isMe,
    required this.isRead,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        decoration: BoxDecoration(
          color: isMe ? kDarkGreen : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isMe ? 14 : 2),
            bottomRight: Radius.circular(isMe ? 2 : 14),
          ),
          border: isMe
              ? null
              : Border.all(color: kDarkGreen.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                text,
                style: TextStyle(
                  color: isMe ? Colors.white : kDarkGreen,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeText,
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe
                        ? Colors.white.withValues(alpha: 0.7)
                        : kDarkGreen.withValues(alpha: 0.45),
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    isRead ? Icons.done_all : Icons.done,
                    size: 13,
                    color: isRead
                        ? const Color(0xFF7BE3FF)
                        : Colors.white.withValues(alpha: 0.75),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageInputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;

  const _MessageInputBar({
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kBg,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                style: const TextStyle(fontSize: 14, color: kDarkGreen),
                decoration: InputDecoration(
                  isDense: true,
                  filled: true,
                  fillColor: Colors.white,
                  hintText: 'Ketikkan sesuatu...',
                  hintStyle: TextStyle(
                    color: kDarkGreen.withValues(alpha: 0.5),
                    fontSize: 13.5,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: kDarkGreen.withValues(alpha: 0.35),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(
                      color: kDarkGreen.withValues(alpha: 0.35),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: kDarkGreen, width: 1.5),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: isSending ? null : onSend,
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: kDarkGreen,
                  shape: BoxShape.circle,
                ),
                child: isSending
                    ? const Padding(
                        padding: EdgeInsets.all(11),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
