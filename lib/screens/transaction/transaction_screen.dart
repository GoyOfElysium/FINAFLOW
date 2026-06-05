import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/finance_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/transaction_model.dart';
import '../../widgets/currency_formatter.dart';
import 'add_transaction_screen.dart';
import 'transaction_detail_screen.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  String _filter = 'Semua';
  final List<String> _filters = ['Semua', 'Pemasukan', 'Pengeluaran'];

  // Group transactions by month-year
  Map<String, List<TransactionModel>> _groupByMonth(
      List<TransactionModel> transactions) {
    final Map<String, List<TransactionModel>> grouped = {};
    for (final tx in transactions) {
      final key = DateFormat('MMMM yyyy', 'id_ID').format(tx.date);
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(tx);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    final allTx = provider.transactions;

    final filtered = allTx.where((tx) {
      if (_filter == 'Pemasukan') return tx.type == TransactionType.income;
      if (_filter == 'Pengeluaran') return tx.type == TransactionType.expense;
      return true;
    }).toList();

    final grouped = _groupByMonth(filtered);
    final monthKeys = grouped.keys.toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: RefreshIndicator(
        onRefresh: () => provider.fetchAllData(),
        child: CustomScrollView(
          slivers: [
            // Blue header
            SliverAppBar(
              expandedHeight: 150,
              pinned: true,
              backgroundColor: AppTheme.primary,
              elevation: 0,
              title: const Text('Transaksi',
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
                              label: 'Total Pemasukan',
                              amount: provider.totalIncome,
                              icon: Icons.trending_up_rounded,
                              color: const Color(0xFF86EFAC),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _MiniStat(
                              label: 'Total Pengeluaran',
                              amount: provider.totalExpense,
                              icon: Icons.trending_down_rounded,
                              color: const Color(0xFFFCA5A5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Filter chips
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filters.map((f) {
                    final selected = _filter == f;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _filter = f),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 8),
                          decoration: BoxDecoration(
                            color:
                                selected ? AppTheme.primary : AppTheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected
                                  ? AppTheme.primary
                                  : AppTheme.divider,
                            ),
                          ),
                          child: Text(
                            f,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? Colors.white
                                  : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  ),
                ),
              ),
            ),

            // Transaction list grouped by month
            provider.isLoading && allTx.isEmpty
                ? const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                : filtered.isEmpty
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
                                child: const Icon(
                                    Icons.receipt_long_outlined,
                                    size: 40,
                                    color: AppTheme.textSecondary),
                              ),
                              const SizedBox(height: 16),
                              const Text('Belum ada transaksi',
                                  style: TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 6),
                              const Text(
                                  'Tap tombol + untuk menambahkan',
                                  style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 13)),
                            ],
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding:
                            const EdgeInsets.fromLTRB(0, 8, 0, 100),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (ctx, index) {
                              final monthKey = monthKeys[index];
                              final txList = grouped[monthKey]!;
                              return _MonthSection(
                                monthLabel: monthKey,
                                transactions: txList,
                                onDelete: (id) =>
                                    _confirmDelete(context, id),
                              );
                            },
                            childCount: monthKeys.length,
                          ),
                        ),
                      ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_transaction',
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const AddTransactionScreen()),
        ),
        backgroundColor: AppTheme.primary,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Transaksi',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Transaksi ini akan dihapus permanen.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal',
                  style: TextStyle(color: AppTheme.textSecondary))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.expense,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
            onPressed: () {
              context.read<FinanceProvider>().deleteTransaction(id);
              Navigator.pop(ctx);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

// ─── Mini Stat ────────────────────────────────────────────────────────────────
class _MiniStat extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;
  const _MiniStat(
      {required this.label,
      required this.amount,
      required this.color,
      required this.icon});

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
                  const SizedBox(height: 2),
                  Text(
                    CurrencyFormatter.format(amount),
                    style: TextStyle(
                        color: color,
                        fontSize: 14,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

// ─── Month Section ────────────────────────────────────────────────────────────
class _MonthSection extends StatelessWidget {
  final String monthLabel;
  final List<TransactionModel> transactions;
  final void Function(String id) onDelete;

  const _MonthSection({
    required this.monthLabel,
    required this.transactions,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month header bar
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          color: AppTheme.surface,
          child: Text(
            monthLabel,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryDark,
            ),
          ),
        ),
        // Transaction rows
        Container(
          color: Colors.white,
          child: Column(
            children: transactions.asMap().entries.map((entry) {
              final tx = entry.value;
              final isLast = entry.key == transactions.length - 1;
              return _TxRow(
                tx: tx,
                showDivider: !isLast,
                onDelete: () => onDelete(tx.id),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ─── Transaction Row (reference-style) ────────────────────────────────────────
class _TxRow extends StatelessWidget {
  final TransactionModel tx;
  final bool showDivider;
  final VoidCallback onDelete;

  const _TxRow({
    required this.tx,
    required this.showDivider,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final category = Categories.findById(tx.categoryId);
    final isIncome = tx.type == TransactionType.income;

    // Date parts
    final day = DateFormat('dd').format(tx.date);
    final monthShort = DateFormat('MMM', 'id_ID').format(tx.date);
    final year = DateFormat('yyyy').format(tx.date);

    return Dismissible(
      key: Key(tx.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppTheme.expense.withValues(alpha: 0.08),
        child: const Icon(Icons.delete_outline_rounded,
            color: AppTheme.expense),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TransactionDetailScreen(tx: tx),
            ),
          );
        },
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date column (like reference)
                  SizedBox(
                    width: 44,
                    child: Column(
                      children: [
                        Text(
                          day,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primaryDark,
                            height: 1.1,
                          ),
                        ),
                        Text(
                          monthShort,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          year,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          tx.title.toUpperCase(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppTheme.textPrimary,
                            letterSpacing: 0.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Amount
                        Text(
                          '${isIncome ? '+' : '-'}${CurrencyFormatter.format(tx.amount)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color:
                                isIncome ? AppTheme.income : AppTheme.expense,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Category
                        Text(
                          category?.name ?? '-',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Chevron
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: AppTheme.textSecondary.withValues(alpha: 0.5),
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            // Divider
            if (showDivider)
              Divider(
                height: 1,
                indent: 74,
                endIndent: 16,
                color: AppTheme.divider.withValues(alpha: 0.8),
              ),
          ],
        ),
      ),
    );
  }
}
