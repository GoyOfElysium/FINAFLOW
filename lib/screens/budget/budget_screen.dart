import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/finance_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/transaction_model.dart';
import '../../models/budget_model.dart';
import '../../widgets/currency_formatter.dart';
import '../../widgets/error_formatter.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    final budgets = provider.budgets;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: RefreshIndicator(
        onRefresh: () => provider.fetchAllData(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Blue header
            SliverAppBar(
              expandedHeight: 160,
              pinned: true,
              backgroundColor: AppTheme.primary,
              elevation: 0,
              title: const Text('Anggaran',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryDark, AppTheme.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: _MiniStat(
                              label: 'Total Anggaran',
                              amount: budgets.fold(0.0, (s, b) => s + b.limit),
                              icon: Icons.account_balance_outlined,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _MiniStat(
                              label: 'Total Terpakai',
                              amount: budgets.fold(0.0, (s, b) => s + b.spent),
                              icon: Icons.payments_outlined,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
  
            // Warning badge
            if (provider.warningBudgets.isNotEmpty)
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppTheme.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.warning_amber_rounded,
                            color: AppTheme.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${provider.warningBudgets.length} anggaran membutuhkan perhatian',
                          style: const TextStyle(
                              color: AppTheme.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
  
            // Budget list or empty state
            provider.isLoading && budgets.isEmpty
                ? const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : budgets.isEmpty
                    ? SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: AppTheme.surface,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.pie_chart_outline_rounded,
                                    size: 40,
                                    color: AppTheme.textSecondary
                                        .withValues(alpha: 0.6)),
                              ),
                              const SizedBox(height: 16),
                              const Text('Belum ada anggaran',
                                  style: TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 6),
                              const Text('Tap + untuk menetapkan anggaran',
                                  style: TextStyle(
                                      color: AppTheme.textSecondary, fontSize: 13)),
                            ],
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (ctx, i) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _BudgetCard(
                                budget: budgets[i],
                                onEdit: () => _showEditBudgetSheet(ctx, budgets[i]),
                                onDelete: () {
                                  context
                                      .read<FinanceProvider>()
                                      .deleteBudgetSupabase(budgets[i].id);
                                },
                              ),
                            ),
                            childCount: budgets.length,
                          ),
                        ),
                      ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_budget',
        onPressed: () => _showAddBudgetSheet(context),
        backgroundColor: AppTheme.primary,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  void _showAddBudgetSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddBudgetSheet(),
    );
  }

  void _showEditBudgetSheet(BuildContext context, BudgetModel budget) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddBudgetSheet(existing: budget),
    );
  }
}

// ─── Mini Stat ────────────────────────────────────────────────────────────────
class _MiniStat extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  const _MiniStat(
      {required this.label, required this.amount, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 10)),
                  Text(CurrencyFormatter.formatCompact(amount),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ),
      );
}

// ─── Budget Card ──────────────────────────────────────────────────────────────
class _BudgetCard extends StatelessWidget {
  final BudgetModel budget;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _BudgetCard(
      {required this.budget, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final category = Categories.findById(budget.categoryId);
    final status = budget.status;

    final Color statusColor = switch (status) {
      BudgetStatus.exceeded => const Color.fromARGB(255, 239, 68, 68),
      BudgetStatus.warning => const Color.fromARGB(255, 251, 188, 5),
      BudgetStatus.safe => const Color.fromARGB(255, 34, 197, 94),
    };

    final String statusLabel = switch (status) {
      BudgetStatus.exceeded => 'MELEBIHI BATAS',
      BudgetStatus.warning => 'MENDEKATI BATAS',
      BudgetStatus.safe => 'AMAN',
    };

    final IconData statusIcon = switch (status) {
      BudgetStatus.exceeded => Icons.error_rounded,
      BudgetStatus.warning => Icons.warning_rounded,
      BudgetStatus.safe => Icons.check_circle_rounded,
    };

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: status != BudgetStatus.safe
              ? statusColor.withValues(alpha: 0.35)
              : AppTheme.divider,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: status != BudgetStatus.safe
                ? statusColor.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (category?.color ?? AppTheme.primary)
                      .withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(category?.icon ?? Icons.category_outlined,
                    color: category?.color ?? AppTheme.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(category?.name ?? budget.categoryId,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppTheme.textPrimary)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 12),
                    const SizedBox(width: 4),
                    Text(statusLabel,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: statusColor)),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert,
                    color: AppTheme.textSecondary, size: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                onSelected: (val) {
                  if (val == 'edit') onEdit();
                  if (val == 'delete') onDelete();
                },
                itemBuilder: (_) => [
                  const PopupMenuItem(
                      value: 'edit', child: Text('Edit Anggaran')),
                  const PopupMenuItem(
                      value: 'delete',
                      child: Text('Hapus',
                          style: TextStyle(color: AppTheme.expense))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: budget.percentage,
              minHeight: 10,
              backgroundColor: AppTheme.divider,
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _BudgetStat(
                label: 'Terpakai',
                value: CurrencyFormatter.format(budget.spent),
                color: statusColor,
              ),
              _BudgetStat(
                label: 'Sisa',
                value: budget.isExceeded
                    ? '-${CurrencyFormatter.format(budget.spent - budget.limit)}'
                    : CurrencyFormatter.format(budget.remaining),
                color: budget.isExceeded ? AppTheme.expense : AppTheme.income,
              ),
              _BudgetStat(
                label: 'Batas',
                value: CurrencyFormatter.format(budget.limit),
                color: AppTheme.textPrimary,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${(budget.percentage * 100).toStringAsFixed(1)}% dari anggaran telah digunakan',
              style: TextStyle(
                  fontSize: 11,
                  color: statusColor,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _BudgetStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, color: color)),
        ],
      );
}

// ─── Add/Edit Budget Sheet ────────────────────────────────────────────────────
class _AddBudgetSheet extends StatefulWidget {
  final BudgetModel? existing;
  const _AddBudgetSheet({this.existing});

  @override
  State<_AddBudgetSheet> createState() => _AddBudgetSheetState();
}

class _AddBudgetSheetState extends State<_AddBudgetSheet> {
  final _limitCtrl = TextEditingController();
  TransactionCategory? _selectedCategory;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _selectedCategory = Categories.findById(widget.existing!.categoryId);
      _limitCtrl.text = widget.existing!.limit.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _limitCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Pilih kategori terlebih dahulu'),
          backgroundColor: AppTheme.expense,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
      return;
    }
    final limit = double.tryParse(_limitCtrl.text);
    if (limit == null || limit <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Masukkan jumlah anggaran yang valid'),
          backgroundColor: AppTheme.expense,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
      return;
    }

    setState(() => _saving = true);

    try {
      final provider = context.read<FinanceProvider>();

      if (widget.existing != null) {
        await provider.updateBudgetSupabase(
          widget.existing!.id,
          _selectedCategory!.id,
          limit,
        );
      } else {
        await provider.addBudgetSupabase(
          _selectedCategory!.id,
          limit,
        );
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(ErrorFormatter.format(e)),
          backgroundColor: AppTheme.expense,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    // Hanya menampilkan kategori jenis pengeluaran dari database Supabase
    final expenseCategories = provider.categories
        .where((c) => c.type == TransactionType.expense)
        .toList();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppTheme.divider,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.pie_chart_outline_rounded,
                    color: AppTheme.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                widget.existing != null ? 'Edit Anggaran' : 'Tambah Anggaran',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Text('Kategori Pengeluaran',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 10),
          expenseCategories.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Belum ada kategori pengeluaran di database. Buat kategori terlebih dahulu di halaman Transaksi.',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                  ),
                )
              : Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: expenseCategories.map((cat) {
                    final selected = _selectedCategory?.id == cat.id;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected ? cat.color : AppTheme.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: selected ? cat.color : AppTheme.divider),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(cat.icon,
                                color: selected ? Colors.white : cat.color, size: 15),
                            const SizedBox(width: 6),
                            Text(cat.name,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: selected
                                        ? Colors.white
                                        : AppTheme.textPrimary,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
          const SizedBox(height: 18),
          const Text('Batas Anggaran (Rp)',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: _limitCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.attach_money_outlined),
              hintText: 'Contoh: 2000000',
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      widget.existing != null
                          ? 'Simpan Perubahan'
                          : 'Tetapkan Anggaran',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
