import 'package:flutter/foundation.dart';

// ==================== STATUS AKUN PENJUAL ====================
enum SellerStatus { none, pending, approved, rejected }

// ==================== DATA PENDAFTARAN TOKO ====================
class SellerApplication {
  final String id;
  final String namaToko;
  final String kategori;
  final String nomorHp;
  final String alasan;

  SellerApplication({
    required this.id,
    required this.namaToko,
    required this.kategori,
    required this.nomorHp,
    required this.alasan,
  });
}

// ==================== DATA PRODUK TOKO PENJUAL ====================
class SellerProduct {
  final String id;
  String name;
  int price;
  String description;

  SellerProduct({
    required this.id,
    required this.name,
    required this.price,
    this.description = '',
  });
}

// ==================== DATA PESANAN MASUK ====================
enum OrderStatus { baru, diproses, selesai, ditolak }

class SellerOrder {
  final String id;
  final String pembeli;
  final String produk;
  final int total;
  OrderStatus status;

  SellerOrder({
    required this.id,
    required this.pembeli,
    required this.produk,
    required this.total,
    this.status = OrderStatus.baru,
  });
}

// ==================== STATE GLOBAL PENJUAL (SIMULASI, IN-MEMORY) ====================
// Catatan: ini simulasi frontend saja (belum terhubung backend),
// jadi datanya cukup disimpan di singleton ini selama app berjalan.
class SellerAccountState {
  SellerAccountState._internal() {
    // Data demo bawaan supaya halaman verifikasi admin tidak kosong.
    pendingApplications.value = [
      SellerApplication(
        id: _nextId(),
        namaToko: 'Kopi Danusan FASILKOM',
        kategori: 'Minuman',
        nomorHp: '081234567890',
        alasan: 'Penggalangan dana untuk kegiatan inaugurasi angkatan 2024.',
      ),
      SellerApplication(
        id: _nextId(),
        namaToko: 'Risol Lumer FEB',
        kategori: 'Makanan Ringan',
        nomorHp: '082198765432',
        alasan: 'Penjualan produk UMKM mahasiswa kewirausahaan.',
      ),
      SellerApplication(
        id: _nextId(),
        namaToko: 'Merchandise USU Unik',
        kategori: 'Aksesoris & Souvenir',
        nomorHp: '085311223344',
        alasan:
            'Kreativitas usaha mandiri berupa stiker dan gantungan kunci kampus.',
      ),
    ];

    // Data demo pesanan masuk supaya halaman Pesanan tidak kosong.
    myOrders.value = [
      SellerOrder(
        id: _nextId(),
        pembeli: 'Rani Puspita',
        produk: 'Donat (3 pcs)',
        total: 12000,
      ),
      SellerOrder(
        id: _nextId(),
        pembeli: 'Fajar Ramadhan',
        produk: 'Kue Kering Coklat',
        total: 8000,
      ),
    ];
  }

  static final SellerAccountState instance = SellerAccountState._internal();

  int _idCounter = 1000;
  String _nextId() => (_idCounter++).toString();

  // Status akun penjual milik user yang sedang login (simulasi 1 user).
  final ValueNotifier<SellerStatus> status = ValueNotifier(SellerStatus.none);

  // Pendaftaran milik user ini sendiri (kalau ada).
  final ValueNotifier<SellerApplication?> myApplication = ValueNotifier(null);

  // Antrean pendaftaran yang perlu diverifikasi admin.
  final ValueNotifier<List<SellerApplication>> pendingApplications =
      ValueNotifier([]);

  // Produk milik toko user ini.
  final ValueNotifier<List<SellerProduct>> myProducts = ValueNotifier([]);

  // Pesanan masuk untuk toko user ini.
  final ValueNotifier<List<SellerOrder>> myOrders = ValueNotifier([]);

  // ---------------- Pendaftaran ----------------
  void submitApplication({
    required String namaToko,
    required String kategori,
    required String nomorHp,
    required String alasan,
  }) {
    final app = SellerApplication(
      id: _nextId(),
      namaToko: namaToko,
      kategori: kategori,
      nomorHp: nomorHp,
      alasan: alasan,
    );
    myApplication.value = app;
    // Statis: langsung disetujui tanpa menunggu verifikasi admin,
    // karena belum ada backend yang menghubungkan sesi admin & user.
    status.value = SellerStatus.approved;
  }

  void approve(String id) {
    pendingApplications.value = pendingApplications.value
        .where((a) => a.id != id)
        .toList();
    if (myApplication.value?.id == id) {
      status.value = SellerStatus.approved;
    }
  }

  void reject(String id) {
    pendingApplications.value = pendingApplications.value
        .where((a) => a.id != id)
        .toList();
    if (myApplication.value?.id == id) {
      status.value = SellerStatus.rejected;
    }
  }

  // ---------------- Produk ----------------
  void addProduct({
    required String name,
    required int price,
    String description = '',
  }) {
    final product = SellerProduct(
      id: _nextId(),
      name: name,
      price: price,
      description: description,
    );
    myProducts.value = [...myProducts.value, product];
  }

  void updateProduct(SellerProduct updated) {
    myProducts.value = myProducts.value
        .map((p) => p.id == updated.id ? updated : p)
        .toList();
  }

  void deleteProduct(String id) {
    myProducts.value = myProducts.value.where((p) => p.id != id).toList();
  }

  // ---------------- Pesanan ----------------
  void updateOrderStatus(String id, OrderStatus newStatus) {
    myOrders.value = myOrders.value.map((o) {
      if (o.id == id) {
        o.status = newStatus;
      }
      return o;
    }).toList();
  }
}