import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/finance_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/transaction_model.dart';
import '../../models/budget_model.dart';
import '../../widgets/currency_formatter.dart';
import '../auth/login_screen.dart';
import '../transaction/add_transaction_screen.dart';
import '../report/report_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    final warnings = provider.warningBudgets;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: RefreshIndicator(
        onRefresh: () => provider.fetchAllData(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
          // Blue curved AppBar header
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppTheme.primary,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.exit_to_app_rounded, color: Colors.white),
                onPressed: () => _showLogoutDialog(context),
              ),
            ],
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
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative circle
                    Positioned(
                      top: -30,
                      right: -30,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Top row: logo + greeting
                            Row(
                              children: [
                                Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                      Icons.account_balance_wallet_rounded,
                                      color: AppTheme.primary,
                                      size: 22),
                                ),
                                const SizedBox(width: 10),
                                const Text('FinaFlow',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800)),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Hai, ${provider.userName}! 👋',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Balance info card
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.25)),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text('Saldo Bersih',
                                            style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12)),
                                        const SizedBox(height: 4),
                                        Text(
                                          CurrencyFormatter.format(
                                              provider.netBalance),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 24,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.account_balance_rounded,
                                        color: Colors.white, size: 22),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Warning Banner
                  if (warnings.isNotEmpty) ...[
                    _WarningBanner(warnings: warnings),
                    const SizedBox(height: 16),
                  ],

                  // Financial summary card — Finansialku style
                  _FinancialSummaryCard(provider: provider),
                  const SizedBox(height: 20),

                  // Quick action buttons — orange & blue like reference
                  Row(
                    children: [
                      Expanded(
                        child: _QuickActionButton(
                          icon: Icons.receipt_long_rounded,
                          label: 'Catat Transaksi',
                          color: AppTheme.primary,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const AddTransactionScreen()),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickActionButton(
                          icon: Icons.bar_chart_rounded,
                          label: 'Laporan',
                          color: AppTheme.accent,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ReportScreen()),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Line Chart - Tren 6 Bulan
                  _SectionHeader(title: 'Tren Keuangan 6 Bulan'),
                  const SizedBox(height: 12),
                  _LineChartCard(provider: provider),
                  const SizedBox(height: 24),

                  // Transaksi Terbaru
                  _SectionHeader(title: 'Transaksi Terbaru'),
                  const SizedBox(height: 12),
                  if (provider.recentTransactions.isEmpty)
                    _EmptyState(message: 'Belum ada transaksi')
                  else
                    ...provider.recentTransactions.map(
                      (tx) => _TransactionItem(tx: tx),
                    ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
     ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Keluar Aplikasi',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Apakah kamu yakin ingin keluar dari FinaFlow?'),
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
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<FinanceProvider>().logout();
              if (!ctx.mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}

// ─── Financial Summary Card (Finansialku list style) ─────────────────────────
class _FinancialSummaryCard extends StatelessWidget {
  final FinanceProvider provider;
  const _FinancialSummaryCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _SummaryRow(
            label: 'Pemasukan',
            value: CurrencyFormatter.format(provider.monthlyIncome),
            valueColor: AppTheme.income,
            icon: Icons.trending_up_rounded,
            iconBg: const Color(0xFFDCFCE7),
            iconColor: AppTheme.income,
            isFirst: true,
          ),
          Divider(
              height: 1,
              indent: 20,
              endIndent: 20,
              color: AppTheme.divider.withValues(alpha: 0.7)),
          _SummaryRow(
            label: 'Pengeluaran',
            value: '-${CurrencyFormatter.format(provider.monthlyExpense)}',
            valueColor: AppTheme.expense,
            icon: Icons.trending_down_rounded,
            iconBg: const Color(0xFFFEE2E2),
            iconColor: AppTheme.expense,
          ),
          Divider(
              height: 1,
              indent: 20,
              endIndent: 20,
              color: AppTheme.divider.withValues(alpha: 0.7)),
          _SummaryRow(
            label: 'Saldo Saat Ini',
            value: CurrencyFormatter.format(provider.netBalance),
            valueColor: AppTheme.primary,
            icon: Icons.account_balance_wallet_rounded,
            iconBg: AppTheme.surface,
            iconColor: AppTheme.primary,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final bool isFirst;
  final bool isLast;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(20) : Radius.zero,
          bottom: isLast ? const Radius.circular(20) : Radius.zero,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label,
                style: const TextStyle(
                    fontSize: 14, color: AppTheme.textPrimary)),
          ),
          Text(value,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: valueColor)),
        ],
      ),
    );
  }
}

// ─── Quick Action Button ──────────────────────────────────────────────────────
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) => Text(title,
      style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary));
}

// ─── Line Chart Card ──────────────────────────────────────────────────────────
class _LineChartCard extends StatelessWidget {
  final FinanceProvider provider;
  const _LineChartCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final data = provider.getLast6MonthsData();
    final maxY = data.fold<double>(0, (max, d) {
      final m = [d['income'] as double, d['expense'] as double]
          .reduce((a, b) => a > b ? a : b);
      return m > max ? m : max;
    });

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _Legend(color: AppTheme.income, label: 'Pemasukan'),
              const SizedBox(width: 16),
              _Legend(color: AppTheme.expense, label: 'Pengeluaran'),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: AppTheme.divider, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (val, meta) {
                        if (val.toInt() >= 0 && val.toInt() < data.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              DateFormatter.formatShortMonth(
                                  data[val.toInt()]['month'] as DateTime),
                              style: const TextStyle(
                                  fontSize: 11, color: AppTheme.textSecondary),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 48,
                      getTitlesWidget: (val, _) => Text(
                        CurrencyFormatter.formatCompact(val),
                        style: const TextStyle(
                            fontSize: 9, color: AppTheme.textSecondary),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                minY: 0,
                maxY: maxY * 1.2,
                lineBarsData: [
                  LineChartBarData(
                    spots: data
                        .asMap()
                        .entries
                        .map((e) => FlSpot(
                            e.key.toDouble(), e.value['income'] as double))
                        .toList(),
                    isCurved: true,
                    color: AppTheme.income,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.income.withValues(alpha: 0.08),
                    ),
                  ),
                  LineChartBarData(
                    spots: data
                        .asMap()
                        .entries
                        .map((e) => FlSpot(
                            e.key.toDouble(), e.value['expense'] as double))
                        .toList(),
                    isCurved: true,
                    color: AppTheme.expense,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.expense.withValues(alpha: 0.08),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
              width: 12,
              height: 3,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 6),
          Text(label,
              style:
                  const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        ],
      );
}

// ─── Transaction Item ─────────────────────────────────────────────────────────
class _TransactionItem extends StatelessWidget {
  final TransactionModel tx;
  const _TransactionItem({required this.tx});

  @override
  Widget build(BuildContext context) {
    final category = Categories.findById(tx.categoryId);
    final isIncome = tx.type == TransactionType.income;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (category?.color ?? AppTheme.primary).withValues(alpha: 0.12),
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
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(category?.name ?? tx.categoryId,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary)),
                    if (tx.projectTag != null) ...[
                      const Text(' · ',
                          style: TextStyle(color: AppTheme.textSecondary)),
                      Text(tx.projectTag!,
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.primary)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : '-'}${CurrencyFormatter.format(tx.amount)}',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isIncome ? AppTheme.income : AppTheme.expense),
              ),
              const SizedBox(height: 2),
              Text(DateFormatter.formatFull(tx.date),
                  style: const TextStyle(
                      fontSize: 10, color: AppTheme.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Warning Banner ───────────────────────────────────────────────────────────
class _WarningBanner extends StatelessWidget {
  final List<BudgetModel> warnings;
  const _WarningBanner({required this.warnings});

  @override
  Widget build(BuildContext context) {
    final exceeded = warnings.where((w) => w.isExceeded).length;
    final warning = warnings.where((w) => w.isWarning).length;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: exceeded > 0
            ? AppTheme.expense.withValues(alpha: 0.07)
            : AppTheme.warning.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: exceeded > 0
              ? AppTheme.expense.withValues(alpha: 0.25)
              : AppTheme.warning.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: exceeded > 0
                  ? AppTheme.expense.withValues(alpha: 0.12)
                  : AppTheme.warning.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              exceeded > 0 ? Icons.error_outline : Icons.warning_amber_outlined,
              color: exceeded > 0 ? AppTheme.expense : AppTheme.warning,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              exceeded > 0
                  ? '$exceeded anggaran melebihi batas! Periksa halaman Anggaran.'
                  : '$warning anggaran mendekati batas (≥75%). Perhatikan pengeluaranmu!',
              style: TextStyle(
                  fontSize: 13,
                  color: exceeded > 0 ? AppTheme.expense : AppTheme.warning,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(40),
        alignment: Alignment.center,
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.surface,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.inbox_outlined,
                  size: 36, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 12),
            Text(message,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 14)),
          ],
        ),
      );
}
