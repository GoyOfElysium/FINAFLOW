import 'package:flutter/material.dart';

enum TransactionType { income, expense }

class TransactionCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final TransactionType type;

  const TransactionCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });
}

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final String categoryId;
  final DateTime date;
  final String? projectTag;
  final String? note;
  final String? projectId; // Untuk mereferensikan proyek dari Supabase

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.date,
    this.projectTag,
    this.note,
    this.projectId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type.name,
      'categoryId': categoryId,
      'date': date.toIso8601String(),
      'projectTag': projectTag,
      'note': note,
      'projectId': projectId,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      type: TransactionType.values.firstWhere((e) => e.name == map['type']),
      categoryId: map['categoryId'],
      date: DateTime.parse(map['date']),
      projectTag: map['projectTag'],
      note: map['note'],
      projectId: map['projectId'],
    );
  }

  factory TransactionModel.fromSupabase(Map<String, dynamic> map) {
    final categoryMap = map['kategori'] as Map<String, dynamic>?;
    final projectMap = map['proyek'] as Map<String, dynamic>?;

    final jenisKategori = categoryMap?['jenis_kategori'] ?? 'pengeluaran';
    final type = jenisKategori == 'pemasukan' ? TransactionType.income : TransactionType.expense;

    final deskripsi = map['deskripsi'] as String? ?? '';
    String title = deskripsi;
    String? note;
    if (deskripsi.contains('\n')) {
      var parts = deskripsi.split('\n');
      title = parts[0];
      note = parts.sublist(1).join('\n');
    }

    return TransactionModel(
      id: map['id_transaksi'].toString(),
      title: title,
      amount: (map['nominal'] as num).toDouble(),
      type: type,
      categoryId: map['id_kategori'].toString(),
      date: DateTime.parse(map['tanggal']),
      projectTag: projectMap != null ? projectMap['nama_proyek'] : null,
      note: note,
      projectId: map['id_proyek']?.toString(),
    );
  }
}

// Kategori Transaksi
class Categories {
  static List<TransactionCategory> _customCategories = [];

  static void setCategories(List<TransactionCategory> cats) {
    _customCategories = cats;
  }

  static const List<TransactionCategory> income = [
    TransactionCategory(
      id: 'freelance',
      name: 'Freelance',
      icon: Icons.laptop_mac,
      color: Color(0xFF16A34A),
      type: TransactionType.income,
    ),
    TransactionCategory(
      id: 'project',
      name: 'Proyek',
      icon: Icons.work_outline,
      color: Color(0xFF0891B2),
      type: TransactionType.income,
    ),
    TransactionCategory(
      id: 'konsultasi',
      name: 'Konsultasi',
      icon: Icons.people_outline,
      color: Color(0xFF7C3AED),
      type: TransactionType.income,
    ),
    TransactionCategory(
      id: 'lain_income',
      name: 'Lainnya',
      icon: Icons.add_circle_outline,
      color: Color(0xFF9333EA),
      type: TransactionType.income,
    ),
  ];

  static const List<TransactionCategory> expense = [
    TransactionCategory(
      id: 'operasional',
      name: 'Operasional',
      icon: Icons.business_center_outlined,
      color: Color(0xFFDC2626),
      type: TransactionType.expense,
    ),
    TransactionCategory(
      id: 'software',
      name: 'Software/Tools',
      icon: Icons.computer_outlined,
      color: Color(0xFFEA580C),
      type: TransactionType.expense,
    ),
    TransactionCategory(
      id: 'marketing',
      name: 'Marketing',
      icon: Icons.campaign_outlined,
      color: Color(0xFFDB2777),
      type: TransactionType.expense,
    ),
    TransactionCategory(
      id: 'transport',
      name: 'Transportasi',
      icon: Icons.directions_car_outlined,
      color: Color(0xFF0369A1),
      type: TransactionType.expense,
    ),
    TransactionCategory(
      id: 'makan',
      name: 'Makan & Minum',
      icon: Icons.restaurant_outlined,
      color: Color(0xFFD97706),
      type: TransactionType.expense,
    ),
    TransactionCategory(
      id: 'lain_expense',
      name: 'Lainnya',
      icon: Icons.more_horiz,
      color: Color(0xFF6B7280),
      type: TransactionType.expense,
    ),
  ];

  static TransactionCategory? findById(String id) {
    try {
      return [..._customCategories, ...income, ...expense].firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  static TransactionCategory fromSupabase(Map<String, dynamic> row) {
    final name = row['nama_kategori'] as String;
    final id = row['id_kategori'].toString();
    final jenis = row['jenis_kategori'] as String;
    final type = jenis == 'pemasukan' ? TransactionType.income : TransactionType.expense;

    final preset = findByName(name, type);
    return TransactionCategory(
      id: id,
      name: name,
      icon: preset?.icon ?? Icons.category_outlined,
      color: preset?.color ?? (type == TransactionType.income ? const Color(0xFF16A34A) : const Color(0xFFDC2626)),
      type: type,
    );
  }

  static TransactionCategory? findByName(String name, TransactionType type) {
    final list = type == TransactionType.income ? income : expense;
    try {
      return list.firstWhere((c) => c.name.toLowerCase() == name.toLowerCase());
    } catch (_) {
      try {
        return list.firstWhere((c) =>
            name.toLowerCase().contains(c.name.toLowerCase()) ||
            c.name.toLowerCase().contains(name.toLowerCase()));
      } catch (_) {
        return null;
      }
    }
  }
}
