import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ai/firebase_ai.dart';

class BabuProductItem {
  final String id;
  final String name;
  final int price;
  final int originalPrice;
  final double rating;
  final int reviewCount;
  final String prepTime;
  final int kcal;
  final String sellerId;
  final String sellerName;
  final String category;
  final String description;
  final String image;
  final String facultyOrLocation;
  final bool isStoreActive;
  final List<String> tags;
  final String aiReason;
  final double matchScore;

  const BabuProductItem({
    required this.id,
    required this.name,
    required this.price,
    this.originalPrice = 0,
    this.rating = 4.8,
    this.reviewCount = 0,
    this.prepTime = '10-15 mnt',
    this.kcal = 0,
    required this.sellerId,
    required this.sellerName,
    this.category = '',
    this.description = '',
    this.image = '',
    this.facultyOrLocation = '',
    this.isStoreActive = true,
    this.tags = const [],
    this.aiReason = '',
    this.matchScore = 0,
  });

  int get effectiveOriginalPrice =>
      originalPrice > price ? originalPrice : price;

  String get formattedPrice {
    final s = price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m.group(1) ?? ''}.',
    );
    return 'Rp $s';
  }

  BabuProductItem copyWith({
    List<String>? tags,
    String? aiReason,
    double? matchScore,
  }) {
    return BabuProductItem(
      id: id,
      name: name,
      price: price,
      originalPrice: originalPrice,
      rating: rating,
      reviewCount: reviewCount,
      prepTime: prepTime,
      kcal: kcal,
      sellerId: sellerId,
      sellerName: sellerName,
      category: category,
      description: description,
      image: image,
      facultyOrLocation: facultyOrLocation,
      isStoreActive: isStoreActive,
      tags: tags ?? this.tags,
      aiReason: aiReason ?? this.aiReason,
      matchScore: matchScore ?? this.matchScore,
    );
  }
}

class BabuRecommendationResult {
  final String summary;
  final List<BabuProductItem> products;
  final bool usedGeminiApi;

  const BabuRecommendationResult({
    required this.summary,
    required this.products,
    required this.usedGeminiApi,
  });
}

class BabuAiService {
  BabuAiService._();
  static final BabuAiService instance = BabuAiService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _modelName = 'gemini-2.5-flash';

  String? get _uid => _auth.currentUser?.uid;

  GenerativeModel _buildModel() {
    return FirebaseAI.googleAI().generativeModel(
      model: _modelName,
      generationConfig: GenerationConfig(
        temperature: 0.3,
        responseMimeType: 'application/json',
      ),
    );
  }

  int _parseInt(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.round();
    final digitsOnly = value.toString().replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(digitsOnly) ?? fallback;
  }

  double _parseDouble(dynamic value, {double fallback = 4.8}) {
    if (value == null) return fallback;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString().replaceAll(',', '.')) ?? fallback;
  }

  List<String> inferProductAttributes({
    required String name,
    required String description,
    required String category,
    required int price,
    List<String> explicitTags = const [],
  }) {
    final tags = <String>{
      ...explicitTags
          .map((e) => e.trim().toLowerCase())
          .where((e) => e.isNotEmpty),
    };

    final raw = '$name $description $category'.toLowerCase();

    if (RegExp(r'(es|teh|kopi|jus|boba|minum|susu|matcha|thai tea|lemon|sirup)')
        .hasMatch(raw)) {
      tags.add('minuman');
    } else {
      tags.add('makanan');
    }

    if (RegExp(
      r'(pedas|geprek|seblak|sambal|balado|mercon|chili|mala|spicy|hot)',
    ).hasMatch(raw)) {
      tags.addAll(['pedas', 'nampol']);
    }
    if (RegExp(
      r'(manis|coklat|cokelat|keju|susu|matcha|donat|kue|bolu|boba|gula|caramel|oreo|tiramisu)',
    ).hasMatch(raw)) {
      tags.add('manis');
    }
    if (RegExp(
      r'(gurih|asin|bakso|tahu|risol|dimsum|dinsum|mentai|ayam|sosis|kentang|goreng|mie|mi)',
    ).hasMatch(raw)) {
      tags.add('gurih');
    }
    if (RegExp(r'(asam|segar|lemon|jeruk|mangga|korea|mentai|tomat|yakult)')
        .hasMatch(raw)) {
      tags.add('asam');
    }

    if (price > 0 && price <= 10000) {
      tags.addAll(['murah', 'hemat', 'anak kos', 'under 10k']);
    } else if (price <= 15000) {
      tags.addAll(['terjangkau', 'anak kos', 'under 15k']);
    }

    if (RegExp(r'(korea|mentai|tteokbokki|corndog|kimbap|ramyeon|korean)')
        .hasMatch(raw)) {
      tags.addAll(['korea', 'viral']);
    }
    if (RegExp(r'(dingin|es|ice|segar)').hasMatch(raw)) {
      tags.add('dingin');
    }

    return tags.toList();
  }

  Future<List<BabuProductItem>> fetchCatalogFromFirestore() async {
    final tenantMap = <String, Map<String, dynamic>>{};
    try {
      final tenantsSnap = await _db.collection('tenants').limit(200).get();
      for (final doc in tenantsSnap.docs) {
        final data = doc.data();
        final ownerUid = (data['uid'] ?? data['ownerId'] ?? doc.id)
            .toString()
            .trim();
        final storeName = (data['namaToko'] ?? data['storeName'] ?? '')
            .toString()
            .trim();
        if (ownerUid.isNotEmpty) tenantMap[ownerUid] = data;
        if (storeName.isNotEmpty) tenantMap[storeName.toLowerCase()] = data;
      }
    } catch (_) {}

    final productsSnap = await _db.collection('products').limit(300).get();
    final items = <BabuProductItem>[];

    for (final doc in productsSnap.docs) {
      final data = doc.data();
      final name = (data['name'] ?? data['nama'] ?? data['title'] ?? '')
          .toString()
          .trim();
      if (name.isEmpty) continue;

      final discountOrMainPrice = _parseInt(
        data['discountPrice'] ??
            data['hargaDiskon'] ??
            data['price'] ??
            data['harga'],
      );
      final rawOriginalPrice = _parseInt(
        data['originalPrice'] ??
            data['hargaAsli'] ??
            data['price'] ??
            data['harga'],
        fallback: discountOrMainPrice,
      );

      final sellerId =
          (data['sellerId'] ?? data['tenantId'] ?? data['uid'] ?? '')
              .toString()
              .trim();
      final tenantInfo =
          tenantMap[sellerId] ??
          tenantMap[(data['storeName'] ?? data['namaToko'] ?? '')
              .toString()
              .trim()
              .toLowerCase()];

      final sellerName =
          (data['storeName'] ??
                  data['namaToko'] ??
                  tenantInfo?['namaToko'] ??
                  tenantInfo?['storeName'] ??
                  'Bazar Mahasiswa USU')
              .toString()
              .trim();

      final category = (data['category'] ?? data['kategori'] ?? '')
          .toString()
          .trim();
      final description = (data['description'] ?? data['deskripsi'] ?? '')
          .toString()
          .trim();
      final image =
          (data['image'] ?? data['imageBase64'] ?? data['imageUrl'] ?? '')
              .toString()
              .trim();
      final faculty =
          (data['fakultas'] ??
                  data['lokasi'] ??
                  tenantInfo?['fakultas'] ??
                  tenantInfo?['lokasi'] ??
                  'Kampus USU')
              .toString()
              .trim();
      final isActive =
          (data['isActive'] ?? tenantInfo?['isActive'] ?? true) == true;
      final rating = _parseDouble(
        data['rating'] ?? tenantInfo?['rating'],
        fallback: 4.8,
      );
      final reviewCount = _parseInt(
        data['reviewCount'] ?? data['jumlahUlasan'],
      );
      final prepTime =
          (data['prepTime'] ?? data['estimasiWaktu'] ?? '10-15 mnt')
              .toString()
              .trim();
      final kcal = _parseInt(data['kcal'] ?? data['kalori']);

      final rawTags = data['tags'] is List
          ? (data['tags'] as List).map((e) => e.toString()).toList()
          : <String>[];

      final tags = inferProductAttributes(
        name: name,
        description: description,
        category: category,
        price: discountOrMainPrice,
        explicitTags: rawTags,
      );

      items.add(
        BabuProductItem(
          id: doc.id,
          name: name,
          price: discountOrMainPrice,
          originalPrice: rawOriginalPrice,
          rating: rating,
          reviewCount: reviewCount,
          prepTime: prepTime.isEmpty ? '10-15 mnt' : prepTime,
          kcal: kcal,
          sellerId: sellerId,
          sellerName: sellerName,
          category: category,
          description: description,
          image: image,
          facultyOrLocation: faculty,
          isStoreActive: isActive,
          tags: tags,
        ),
      );
    }

    return items;
  }

  Future<Map<String, dynamic>> _loadUserPreferenceContext() async {
    final uid = _uid;
    if (uid == null) {
      return {
        'recentQueries': <String>[],
        'preferredTags': <String>[],
        'pastItems': <String>[],
      };
    }

    final recentQueries = <String>[];
    final tagFrequency = <String, int>{};
    final pastItems = <String>[];

    try {
      final historySnap = await _db
          .collection('users')
          .doc(uid)
          .collection('ai_history')
          .orderBy('createdAt', descending: true)
          .limit(15)
          .get();

      for (final doc in historySnap.docs) {
        final d = doc.data();
        final q = (d['query'] ?? '').toString().trim();
        if (q.isNotEmpty && !recentQueries.contains(q)) {
          recentQueries.add(q);
        }
        if (d['tags'] is List) {
          for (final t in (d['tags'] as List)) {
            final key = t.toString().toLowerCase();
            tagFrequency[key] = (tagFrequency[key] ?? 0) + 1;
          }
        }
      }

      final ordersSnap = await _db
          .collection('orders')
          .where('buyerId', isEqualTo: uid)
          .limit(10)
          .get();

      for (final doc in ordersSnap.docs) {
        final items = doc.data()['items'];
        if (items is List) {
          for (final item in items) {
            if (item is Map) {
              final desc = (item['description'] ?? item['name'] ?? '')
                  .toString()
                  .trim();
              if (desc.isNotEmpty) {
                pastItems.add(desc);
                for (final t in inferProductAttributes(
                  name: desc,
                  description: '',
                  category: '',
                  price: 0,
                )) {
                  tagFrequency[t] = (tagFrequency[t] ?? 0) + 2;
                }
              }
            }
          }
        }
      }
    } catch (_) {}

    final sortedTags = tagFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return {
      'recentQueries': recentQueries.take(5).toList(),
      'preferredTags': sortedTags.take(6).map((e) => e.key).toList(),
      'pastItems': pastItems.take(6).toList(),
    };
  }

  Future<void> logInteraction({
    required String actionType,
    String query = '',
    BabuProductItem? product,
    int resultCount = 0,
  }) async {
    final uid = _uid;
    if (uid == null) return;

    try {
      await _db.collection('users').doc(uid).collection('ai_history').add({
        'actionType': actionType,
        'query': query.trim(),
        'productId': product?.id ?? '',
        'productName': product?.name ?? '',
        'sellerName': product?.sellerName ?? '',
        'tags': product?.tags ?? <String>[],
        'resultCount': resultCount,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  Future<List<BabuProductItem>> getPersonalizedInitialRecommendations() async {
    final catalog = await fetchCatalogFromFirestore();
    if (catalog.isEmpty) return [];

    final pref = await _loadUserPreferenceContext();
    final preferredTags = List<String>.from(pref['preferredTags'] ?? []);

    final scored = catalog.map((p) {
      double score = p.isStoreActive ? 1.0 : 0.0;
      for (final tag in preferredTags) {
        if (p.tags.contains(tag)) score += 2.0;
      }
      return p.copyWith(matchScore: score);
    }).toList()..sort((a, b) => b.matchScore.compareTo(a.matchScore));

    return scored.take(4).toList();
  }

  Future<BabuRecommendationResult> searchWithBabu(String userQuery) async {
    final cleanQuery = userQuery.trim();
    final catalog = await fetchCatalogFromFirestore();
    if (catalog.isEmpty) {
      return const BabuRecommendationResult(
        summary: 'Belum ada produk bazar yang terdaftar di database saat ini.',
        products: [],
        usedGeminiApi: false,
      );
    }

    final prefContext = await _loadUserPreferenceContext();
    final preferredTags = List<String>.from(prefContext['preferredTags'] ?? []);

    try {
      final aiResult = await _queryFirebaseAiLogic(
        query: cleanQuery,
        catalog: catalog,
        prefContext: prefContext,
      );
      if (aiResult != null) {
        await logInteraction(
          actionType: 'search',
          query: cleanQuery,
          resultCount: aiResult.products.length,
        );
        return aiResult;
      }
    } catch (_) {}

    final fallbackResults = _rankLocally(
      query: cleanQuery,
      catalog: catalog,
      preferredTags: preferredTags,
    );

    await logInteraction(
      actionType: 'search',
      query: cleanQuery,
      resultCount: fallbackResults.length,
    );

    final summary = fallbackResults.isEmpty
        ? 'BABU belum menemukan menu bazar yang pas untuk "$cleanQuery".'
        : 'BABU memilih ${fallbackResults.length} menu bazar paling cocok dengan "$cleanQuery" berdasarkan rasa, harga, dan lokasi aktif.';

    return BabuRecommendationResult(
      summary: summary,
      products: fallbackResults,
      usedGeminiApi: false,
    );
  }

  Future<BabuRecommendationResult?> _queryFirebaseAiLogic({
    required String query,
    required List<BabuProductItem> catalog,
    required Map<String, dynamic> prefContext,
  }) async {
    final catalogPayload = catalog.take(60).map((p) {
      return {
        'id': p.id,
        'name': p.name,
        'price': p.price,
        'seller': p.sellerName,
        'location': p.facultyOrLocation,
        'active': p.isStoreActive,
        'description': p.description,
        'tags': p.tags,
      };
    }).toList();

    final prompt =
        '''
Kamu adalah BABU (Bazar Assistant By USU), asisten rekomendasi kuliner & bazar mahasiswa di Universitas Sumatera Utara (USU).
Tugasmu: pilih dan urutkan produk dari KATALOG FIRESTORE di bawah ini yang paling sesuai dengan permintaan pembeli.

Permintaan pembeli: "$query"
Riwayat preferensi pembeli: ${jsonEncode(prefContext)}
Katalog produk bazar aktif: ${jsonEncode(catalogPayload)}

Aturan:
1. Hanya boleh memilih id produk yang ada di katalog di atas (jangan mengarang produk baru).
2. Pertimbangkan kecocokan rasa (pedas, manis, gurih, asam), kategori, rentang harga (misal "murah anak kos" <= Rp 10.000 - Rp 15.000), status aktif bazar, lokasi/fakultas, dan riwayat preferensi pembeli.
3. Balas HANYA dalam format JSON valid tanpa markdown ```json:
{
  "summary": "1 kalimat ringkas ramah khas anak kampus USU menjelaskan hasil rekomendasi",
  "recommendations": [
    {"id": "id_produk", "reason": "alasan singkat maks 12 kata kenapa cocok"}
  ]
}
''';

    final model = _buildModel();
    final response = await model.generateContent([Content.text(prompt)]);
    final rawText = response.text;
    if (rawText == null || rawText.trim().isEmpty) return null;

    final cleanJson = rawText
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();
    final parsed = jsonDecode(cleanJson) as Map<String, dynamic>;
    final summary = (parsed['summary'] ?? '').toString().trim();
    final recs = parsed['recommendations'] as List<dynamic>? ?? [];

    final catalogById = {for (final item in catalog) item.id: item};
    final matchedProducts = <BabuProductItem>[];

    for (final rec in recs) {
      if (rec is Map) {
        final id = (rec['id'] ?? '').toString().trim();
        final reason = (rec['reason'] ?? '').toString().trim();
        final found = catalogById[id];
        if (found != null) {
          matchedProducts.add(found.copyWith(aiReason: reason));
        }
      }
    }

    return BabuRecommendationResult(
      summary: summary.isNotEmpty
          ? summary
          : 'Rekomendasi terbaik dari BABU untuk "$query"',
      products: matchedProducts,
      usedGeminiApi: true,
    );
  }

  List<BabuProductItem> _rankLocally({
    required String query,
    required List<BabuProductItem> catalog,
    required List<String> preferredTags,
  }) {
    final cleaned = query
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), ' ')
        .trim();
    final tokens = cleaned
        .split(RegExp(r'\s+'))
        .where((w) => w.length >= 2)
        .toList();

    final wantsCheap = RegExp(r'(murah|hemat|kos|terjangkau|ekonomis)')
        .hasMatch(cleaned);

    final scored = <BabuProductItem>[];
    for (final product in catalog) {
      double score = 0;
      final matchedReasons = <String>[];

      final searchable =
          '${product.name} ${product.sellerName} ${product.category} ${product.description} ${product.facultyOrLocation} ${product.tags.join(' ')}'
              .toLowerCase();

      for (final token in tokens) {
        if (product.name.toLowerCase().contains(token)) {
          score += 5.0;
          matchedReasons.add('Nama menu cocok "$token"');
        } else if (product.tags.contains(token)) {
          score += 4.0;
          matchedReasons.add('Cita rasa/kategori $token');
        } else if (searchable.contains(token)) {
          score += 2.5;
          matchedReasons.add('Sesuai kata kunci $token');
        }
      }

      if (wantsCheap && product.price > 0 && product.price <= 12000) {
        score += 4.5;
        matchedReasons.add('Ramah kantong anak kos');
      }

      if (score > 0) {
        for (final prefTag in preferredTags) {
          if (product.tags.contains(prefTag)) {
            score += 1.0;
          }
        }
        if (product.isStoreActive) {
          score += 1.5;
        }

        final reasonText = matchedReasons.isNotEmpty
            ? matchedReasons.take(2).join(' • ')
            : 'Cocok dengan preferensimu';

        scored.add(product.copyWith(matchScore: score, aiReason: reasonText));
      }
    }

    scored.sort((a, b) => b.matchScore.compareTo(a.matchScore));
    return scored;
  }
}
