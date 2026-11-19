import 'package:flutter/material.dart';

import '../constants.dart';
import '../services/chat_service.dart';

class SellerChatRoomPage extends StatefulWidget {
  final String contactName;
  final String? threadId;
  final String? peerUserId;

  const SellerChatRoomPage({
    super.key,
    required this.contactName,
    this.threadId,
    this.peerUserId,
  });

  @override
  State<SellerChatRoomPage> createState() => _SellerChatRoomPageState();
}

class _SellerChatRoomPageState extends State<SellerChatRoomPage> {
  final _messageController = TextEditingController();
  late final String _threadId;
  bool _isSending = false;

  static const _quickReplies = [
    'Pesanan sedang diproses',
    'Pesanan siap diambil',
    'Terima kasih sudah memesan!',
    'Maaf, stok sedang habis',
  ];

  @override
  void initState() {
    super.initState();
    _threadId = (widget.threadId != null && widget.threadId!.trim().isNotEmpty)
        ? widget.threadId!.trim()
        : ChatService.instance.buildThreadId(widget.contactName);
    _initRoom();
  }

  Future<void> _initRoom() async {
    try {
      await ChatService.instance.ensureThread(
        contactName: widget.contactName,
        peerUserId: widget.peerUserId,
      );
      await ChatService.instance.markAsRead(_threadId);
    } catch (_) {}
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    if (_isSending) return;
    final clean = text.trim();
    if (clean.isEmpty) return;

    setState(() => _isSending = true);
    if (text == _messageController.text) {
      _messageController.clear();
    }

    try {
      await ChatService.instance.sendMessage(
        threadId: _threadId,
        contactName: widget.contactName,
        text: clean,
        peerUserId: widget.peerUserId,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim pesan: ' + e.toString()),
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
  Widget build(BuildContext context) {
    final myId = ChatService.instance.currentUserId;

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(4, 6, 16, 6),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: kDarkGreen.withValues(alpha: 0.1)),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                    color: kDarkGreen,
                  ),
                  CircleAvatar(
                    radius: 19,
                    backgroundColor: kLightGreen,
                    child: Icon(
                      Icons.person,
                      size: 20,
                      color: kDarkGreen.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.contactName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: kDarkGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<ChatMessageList>(
                stream: ChatService.instance.messagesStream(_threadId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      !snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(color: kDarkGreen),
                    );
                  }

                  final messages = snapshot.data ?? [];
                  if (messages.isEmpty) {
                    return Center(
                      child: Text(
                        'Mulai percakapan dengan ' + widget.contactName,
                        style: TextStyle(
                          fontSize: 13,
                          color: kDarkGreen.withValues(alpha: 0.5),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, i) {
                      final m = messages[messages.length - 1 - i];
                      return _MessageBubble(
                        text: m.text,
                        clockText: ChatService.instance.formatClock(
                          m.createdAt,
                        ),
                        mine: m.senderId == myId,
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                itemCount: _quickReplies.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) => GestureDetector(
                  onTap: () => _send(_quickReplies[i]),
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: kLightGreen,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: kDarkGreen.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      _quickReplies[i],
                      style: const TextStyle(
                        fontSize: 12,
                        color: kDarkGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      minLines: 1,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _send,
                      style: const TextStyle(fontSize: 14, color: kDarkGreen),
                      decoration: InputDecoration(
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Tulis pesan...',
                        hintStyle: TextStyle(
                          color: kDarkGreen.withValues(alpha: 0.45),
                          fontSize: 13.5,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: kDarkGreen.withValues(alpha: 0.25),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(
                            color: kDarkGreen.withValues(alpha: 0.25),
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
                  const SizedBox(width: 8),
                  Material(
                    color: kDarkGreen,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: _isSending
                          ? null
                          : () => _send(_messageController.text),
                      child: const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(Icons.send, color: Colors.white, size: 20),
                      ),
                    ),
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

class _MessageBubble extends StatelessWidget {
  final String text;
  final String clockText;
  final bool mine;

  const _MessageBubble({
    required this.text,
    required this.clockText,
    required this.mine,
  });

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.of(context).size.width * 0.75;

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        margin: const EdgeInsets.symmetric(vertical: 3),
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
        decoration: BoxDecoration(
          color: mine ? kDarkGreen : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(mine ? 16 : 4),
            bottomRight: Radius.circular(mine ? 4 : 16),
          ),
          border: mine
              ? null
              : Border.all(color: kDarkGreen.withValues(alpha: 0.12)),
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
                  fontSize: 14,
                  height: 1.35,
                  color: mine ? Colors.white : kDarkGreen,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              clockText,
              style: TextStyle(
                fontSize: 10,
                color: mine
                    ? Colors.white.withValues(alpha: 0.7)
                    : kDarkGreen.withValues(alpha: 0.45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
