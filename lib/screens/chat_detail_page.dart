import 'package:flutter/material.dart';

const kDarkGreen = Color(0xFF3E5C3A);
const kLightGreen = Color(0xFFE8F0DE);
const kBg = Color(0xFFF3F8ED);

class ChatMessage {
  final String text;
  final bool
  isMe; // true = bubble kanan (kita), false = bubble kiri (lawan chat)

  const ChatMessage({required this.text, required this.isMe});
}

class ChatDetailPage extends StatefulWidget {
  final String contactName;
  const ChatDetailPage({super.key, required this.contactName});

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(ChatMessage(text: text, isMe: true));
      _messageController.clear();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Column(
          children: [
            _ChatDetailHeader(contactName: widget.contactName),
            Expanded(
              child: _messages.isEmpty
                  ? const SizedBox.shrink()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        return _ChatBubble(message: msg);
                      },
                    ),
            ),
            _MessageInputBar(
              controller: _messageController,
              onSend: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== HEADER ====================
class _ChatDetailHeader extends StatelessWidget {
  final String contactName;
  const _ChatDetailHeader({required this.contactName});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: kDarkGreen,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 20,
            backgroundColor: kLightGreen,
            child: Icon(Icons.person, color: kDarkGreen.withValues(alpha: 0.6)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
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
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.search, color: Colors.white, size: 22),
        ],
      ),
    );
  }
}

// ==================== BUBBLE CHAT ====================
class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
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
        child: Text(
          message.text,
          style: TextStyle(
            color: isMe ? Colors.white : kDarkGreen,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

// ==================== KOLOM KETIK ====================
class _MessageInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _MessageInputBar({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: kDarkGreen.withValues(alpha: 0.4)),
              ),
              child: TextField(
                controller: controller,
                style: const TextStyle(fontSize: 14, color: kDarkGreen),
                decoration: InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  hintText: 'Ketikkan sesuatu...',
                  hintStyle: TextStyle(
                    color: kDarkGreen.withValues(alpha: 0.5),
                    fontSize: 13,
                  ),
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: kDarkGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
