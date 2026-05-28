import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/finance_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/transaction_model.dart';
import '../../widgets/currency_formatter.dart';
import 'add_transaction_screen.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  String _filter = 'Semua';
  final List<String> _filters = ['Semua', 'Pemasukan', 'Pengeluaran'];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    final allTx = provider.transactions;

    final filtered = allTx.where((tx) {
      if (_filter == 'Pemasukan') return tx.type == TransactionType.income;
      if (_filter == 'Pengeluaran') return tx.type == TransactionType.expense;
      return true;
    }).toList();

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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                            color: selected ? AppTheme.primary : AppTheme.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color:
                                  selected ? AppTheme.primary : AppTheme.divider,
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
  
            // Transaction list
            provider.isLoading && allTx.isEmpty
                ? const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
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
                                child: const Icon(Icons.receipt_long_outlined,
                                    size: 40, color: AppTheme.textSecondary),
                              ),
                              const SizedBox(height: 16),
                              const Text('Belum ada transaksi',
                                  style: TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 6),
                              const Text('Tap tombol + untuk menambahkan',
                                  style: TextStyle(
                                      color: AppTheme.textSecondary, fontSize: 13)),
                            ],
                          ),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (ctx, i) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _TxCard(
                                tx: filtered[i],
                                onDelete: () =>
                                    _confirmDelete(context, filtered[i].id),
                              ),
                            ),
                            childCount: filtered.length,
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
          MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                    CurrencyFormatter.formatCompact(amount),
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

// ─── Transaction Card ─────────────────────────────────────────────────────────
class _TxCard extends StatelessWidget {
  final TransactionModel tx;
  final VoidCallback onDelete;
  const _TxCard({required this.tx, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final category = Categories.findById(tx.categoryId);
    final isIncome = tx.type == TransactionType.income;

    return Dismissible(
      key: Key(tx.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.expense.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child:
            const Icon(Icons.delete_outline_rounded, color: AppTheme.expense),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: (category?.color ?? AppTheme.primary)
                    .withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(category?.icon ?? Icons.swap_horiz,
                  color: category?.color ?? AppTheme.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tx.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppTheme.textPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: (category?.color ?? AppTheme.primary)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(category?.name ?? '-',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: category?.color ?? AppTheme.primary)),
                      ),
                      if (tx.projectTag != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('# ${tx.projectTag}',
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isIncome ? '+' : '-'}${CurrencyFormatter.formatCompact(tx.amount)}',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isIncome ? AppTheme.income : AppTheme.expense),
                ),
                const SizedBox(height: 3),
                Text(DateFormatter.formatFull(tx.date),
                    style: const TextStyle(
                        fontSize: 10, color: AppTheme.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
