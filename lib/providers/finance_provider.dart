import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction_model.dart';
import '../models/budget_model.dart';

const _uuid = Uuid();

class FinanceProvider extends ChangeNotifier {
  final List<TransactionModel> _transactions = [];
  final List<BudgetModel> _budgets = [];

  // Auth state sederhana (simulasi)
  bool _isLoggedIn = false;
  String _userName = '';
  String _userEmail = '';

  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;
  String get userEmail => _userEmail;

  List<TransactionModel> get transactions {
    final sorted = _transactions.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return List.unmodifiable(sorted);
  }

  List<BudgetModel> get budgets => List.unmodifiable(_budgets);

  // ─── Auth ───────────────────────────────────────────────────────────────

  bool login(String email, String password) {
    if (email.isNotEmpty && password.length >= 6) {
      _isLoggedIn = true;
      _userEmail = email;
      _userName = email.split('@').first;
      notifyListeners();
      return true;
    }
    return false;
  }

  bool register(String name, String email, String password) {
    if (name.isNotEmpty && email.isNotEmpty && password.length >= 6) {
      _isLoggedIn = true;
      _userName = name;
      _userEmail = email;
      _seedDemoData();
      notifyListeners();
      return true;
    }
    return false;
  }

  void logout() {
    _isLoggedIn = false;
    _userName = '';
    _userEmail = '';
    notifyListeners();
  }

  // ─── Transactions ────────────────────────────────────────────────────────

  void addTransaction(TransactionModel tx) {
    _transactions.add(tx);
    _updateBudgetSpending(tx.categoryId, tx.amount, tx.type);
    notifyListeners();
  }

  void deleteTransaction(String id) {
    final tx = _transactions.firstWhere((t) => t.id == id);
    _transactions.removeWhere((t) => t.id == id);
    // Kurangi spending jika expense
    if (tx.type == TransactionType.expense) {
      final budgetIdx =
          _budgets.indexWhere((b) => b.categoryId == tx.categoryId);
      if (budgetIdx >= 0) {
        _budgets[budgetIdx].spent =
            (_budgets[budgetIdx].spent - tx.amount).clamp(0.0, double.infinity);
      }
    }
    notifyListeners();
  }

  void _updateBudgetSpending(
      String categoryId, double amount, TransactionType type) {
    if (type == TransactionType.expense) {
      final idx = _budgets.indexWhere((b) => b.categoryId == categoryId);
      if (idx >= 0) {
        _budgets[idx].spent += amount;
      }
    }
  }

  // ─── Budget ──────────────────────────────────────────────────────────────

  void addBudget(BudgetModel budget) {
    // Hitung spent dari existing transactions
    final totalSpent = _transactions
        .where((t) =>
            t.categoryId == budget.categoryId &&
            t.type == TransactionType.expense &&
            t.date.month == DateTime.now().month &&
            t.date.year == DateTime.now().year)
        .fold(0.0, (sum, t) => sum + t.amount);

    _budgets.add(budget.copyWith(spent: totalSpent));
    notifyListeners();
  }

  void updateBudget(BudgetModel updated) {
    final idx = _budgets.indexWhere((b) => b.id == updated.id);
    if (idx >= 0) {
      _budgets[idx] = updated;
      notifyListeners();
    }
  }

  void deleteBudget(String id) {
    _budgets.removeWhere((b) => b.id == id);
    notifyListeners();
  }

  List<BudgetModel> get warningBudgets =>
      _budgets.where((b) => b.isWarning || b.isExceeded).toList();

  // ─── Summary / Analytics ─────────────────────────────────────────────────

  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get netBalance => totalIncome - totalExpense;

  double get monthlyIncome {
    final now = DateTime.now();
    return _transactions
        .where((t) =>
            t.type == TransactionType.income &&
            t.date.month == now.month &&
            t.date.year == now.year)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get monthlyExpense {
    final now = DateTime.now();
    return _transactions
        .where((t) =>
            t.type == TransactionType.expense &&
            t.date.month == now.month &&
            t.date.year == now.year)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // Data 6 bulan terakhir untuk line chart
  List<Map<String, dynamic>> getLast6MonthsData() {
    final now = DateTime.now();
    final result = <Map<String, dynamic>>[];

    for (int i = 5; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i, 1);
      final income = _transactions
          .where((t) =>
              t.type == TransactionType.income &&
              t.date.month == month.month &&
              t.date.year == month.year)
          .fold(0.0, (sum, t) => sum + t.amount);
      final expense = _transactions
          .where((t) =>
              t.type == TransactionType.expense &&
              t.date.month == month.month &&
              t.date.year == month.year)
          .fold(0.0, (sum, t) => sum + t.amount);

      result.add({
        'month': month,
        'income': income,
        'expense': expense,
      });
    }
    return result;
  }

  // Data pengeluaran per kategori untuk pie chart
  Map<String, double> getExpenseByCategory() {
    final Map<String, double> result = {};
    for (final tx
        in _transactions.where((t) => t.type == TransactionType.expense)) {
      result[tx.categoryId] = (result[tx.categoryId] ?? 0) + tx.amount;
    }
    return result;
  }

  // Transaksi terbaru
  List<TransactionModel> get recentTransactions =>
      transactions.take(5).toList();

  // ─── Demo Data ───────────────────────────────────────────────────────────

  void _seedDemoData() {
    final now = DateTime.now();

    final demoTx = [
      TransactionModel(
        id: _uuid.v4(),
        title: 'Proyek Website Client A',
        amount: 5000000,
        type: TransactionType.income,
        categoryId: 'project',
        date: DateTime(now.year, now.month, 2),
        projectTag: 'Client A',
      ),
      TransactionModel(
        id: _uuid.v4(),
        title: 'Desain Logo Startup',
        amount: 2500000,
        type: TransactionType.income,
        categoryId: 'freelance',
        date: DateTime(now.year, now.month, 5),
        projectTag: 'StartupXYZ',
      ),
      TransactionModel(
        id: _uuid.v4(),
        title: 'Sewa Adobe Creative Cloud',
        amount: 600000,
        type: TransactionType.expense,
        categoryId: 'software',
        date: DateTime(now.year, now.month, 1),
      ),
      TransactionModel(
        id: _uuid.v4(),
        title: 'Biaya Operasional Kantor',
        amount: 1200000,
        type: TransactionType.expense,
        categoryId: 'operasional',
        date: DateTime(now.year, now.month, 3),
      ),
      TransactionModel(
        id: _uuid.v4(),
        title: 'Konsultasi UX Startup',
        amount: 1500000,
        type: TransactionType.income,
        categoryId: 'konsultasi',
        date: DateTime(now.year, now.month, 7),
        projectTag: 'StartupXYZ',
      ),
      TransactionModel(
        id: _uuid.v4(),
        title: 'Marketing Instagram Ads',
        amount: 800000,
        type: TransactionType.expense,
        categoryId: 'marketing',
        date: DateTime(now.year, now.month, 6),
      ),
      TransactionModel(
        id: _uuid.v4(),
        title: 'Freelance Motion Graphic',
        amount: 3000000,
        type: TransactionType.income,
        categoryId: 'freelance',
        date: DateTime(now.year, now.month - 1, 15),
        projectTag: 'Client B',
      ),
      TransactionModel(
        id: _uuid.v4(),
        title: 'Transport Meeting Client',
        amount: 350000,
        type: TransactionType.expense,
        categoryId: 'transport',
        date: DateTime(now.year, now.month, 8),
      ),
    ];

    _transactions.addAll(demoTx);

    // Demo budgets
    _budgets.addAll([
      BudgetModel(
        id: _uuid.v4(),
        categoryId: 'operasional',
        limit: 2000000,
        spent: 1200000,
      ),
      BudgetModel(
        id: _uuid.v4(),
        categoryId: 'software',
        limit: 700000,
        spent: 600000,
      ),
      BudgetModel(
        id: _uuid.v4(),
        categoryId: 'marketing',
        limit: 1000000,
        spent: 800000,
      ),
      BudgetModel(
        id: _uuid.v4(),
        categoryId: 'transport',
        limit: 500000,
        spent: 350000,
      ),
    ]);
  }
}
