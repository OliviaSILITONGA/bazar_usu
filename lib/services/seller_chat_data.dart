class SellerChatMessage {
  final String text;
  final bool fromMe; // true = pesan dari penjual, false = dari pembeli
  final DateTime time;

  const SellerChatMessage({
    required this.text,
    required this.fromMe,
    required this.time,
  });
}

class SellerChatContact {
  final String name;
  final List<SellerChatMessage> messages;
  int unread;

  SellerChatContact({
    required this.name,
    required this.messages,
    this.unread = 0,
  });

  SellerChatMessage? get last => messages.isEmpty ? null : messages.last;
}

// Format waktu untuk daftar kontak: "baru saja", "5mnt", "3jam", "2hari"
String formatChatTime(DateTime t) {
  final d = DateTime.now().difference(t);
  if (d.inMinutes < 1) return 'baru saja';
  if (d.inMinutes < 60) return '${d.inMinutes}mnt';
  if (d.inHours < 24) return '${d.inHours}jam';
  return '${d.inDays}hari';
}

// Format jam untuk gelembung chat: "14:05"
String formatClock(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

// Data contoh (hanya tersimpan selama aplikasi berjalan)
final List<SellerChatContact> sellerChatContacts = _buildSample();

List<SellerChatContact> _buildSample() {
  final now = DateTime.now();
  return [
    SellerChatContact(
      name: 'Yana',
      unread: 2,
      messages: [
        SellerChatMessage(
          text: 'Halo kak, dinsum mentainya masih ada?',
          fromMe: false,
          time: now.subtract(const Duration(minutes: 12)),
        ),
        SellerChatMessage(
          text: 'Masih ada kak, mau berapa porsi?',
          fromMe: true,
          time: now.subtract(const Duration(minutes: 10)),
        ),
        SellerChatMessage(
          text: 'Aku pesan 2 porsi ya kak',
          fromMe: false,
          time: now.subtract(const Duration(minutes: 3)),
        ),
        SellerChatMessage(
          text: 'Bisa diambil di depan gedung Fasilkom-TI jam 12?',
          fromMe: false,
          time: now.subtract(const Duration(minutes: 2)),
        ),
      ],
    ),
    SellerChatContact(
      name: 'Olivia',
      unread: 1,
      messages: [
        SellerChatMessage(
          text: 'Pesananku sudah sampai, makasih kak!',
          fromMe: false,
          time: now.subtract(const Duration(hours: 1)),
        ),
      ],
    ),
    SellerChatContact(
      name: 'KMK Ilmu Komputer',
      messages: [
        SellerChatMessage(
          text: 'Kak, bisa pesan 20 porsi untuk acara hari Jumat?',
          fromMe: false,
          time: now.subtract(const Duration(hours: 5)),
        ),
        SellerChatMessage(
          text: 'Bisa kak, nanti kami kabari total harganya ya.',
          fromMe: true,
          time: now.subtract(const Duration(hours: 4)),
        ),
      ],
    ),
    SellerChatContact(
      name: 'UKM AISEC',
      messages: [
        SellerChatMessage(
          text: 'Terima kasih kak, makanannya enak!',
          fromMe: false,
          time: now.subtract(const Duration(days: 2)),
        ),
        SellerChatMessage(
          text: 'Sama-sama kak, ditunggu pesanan berikutnya 😊',
          fromMe: true,
          time: now.subtract(const Duration(days: 2)),
        ),
      ],
    ),
    SellerChatContact(
      name: 'SILI TONGA',
      messages: [
        SellerChatMessage(
          text: 'Pesanan dengan nomor resi BZR-0192 sudah diterima.',
          fromMe: false,
          time: now.subtract(const Duration(days: 3)),
        ),
      ],
    ),
  ];
}