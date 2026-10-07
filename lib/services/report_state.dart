import 'dart:io';

import 'package:flutter/foundation.dart';

enum ReportCategory {
  transactionIssue,
  productSellerViolation,
  technicalBug,
  suggestion,
}

extension ReportCategoryLabel on ReportCategory {
  String get label {
    switch (this) {
      case ReportCategory.transactionIssue:
        return 'Masalah Transaksi';
      case ReportCategory.productSellerViolation:
        return 'Pelanggaran Produk/Penjual';
      case ReportCategory.technicalBug:
        return 'Kendala Teknis / Bug Aplikasi';
      case ReportCategory.suggestion:
        return 'Saran & Masukan';
    }
  }
}

enum ReportStatus { pending, inProgress, resolved }

extension ReportStatusLabel on ReportStatus {
  String get label {
    switch (this) {
      case ReportStatus.pending:
        return 'Pending / Diterima';
      case ReportStatus.inProgress:
        return 'Diproses';
      case ReportStatus.resolved:
        return 'Selesai / Ditutup';
    }
  }
}

class ReportData {
  final String id;
  final ReportCategory category;
  final String? referenceId; // ID transaksi / nama produk (opsional)
  final String description;
  final File? evidenceImage;
  final ReportStatus status;
  final DateTime createdAt;

  ReportData({
    required this.id,
    required this.category,
    this.referenceId,
    required this.description,
    this.evidenceImage,
    this.status = ReportStatus.pending,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

/// Penyimpanan laporan sederhana di memori (hilang kalau app ditutup).
/// Nanti kalau sudah ada backend, tinggal ganti isi method-method ini
/// supaya memanggil API alih-alih List biasa.
class ReportState {
  ReportState._();
  static final ReportState instance = ReportState._();

  final ValueNotifier<List<ReportData>> reports = ValueNotifier([]);

  void addReport(ReportData report) {
    reports.value = [report, ...reports.value];
  }

  void removeAt(int index) {
    final updated = [...reports.value];
    updated.removeAt(index);
    reports.value = updated;
  }
}
