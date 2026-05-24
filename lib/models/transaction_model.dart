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

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.date,
    this.projectTag,
    this.note,
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
    );
  }
}

// Kategori Transaksi
class Categories {
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
      return [...income, ...expense].firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
