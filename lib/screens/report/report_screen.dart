import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/finance_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/transaction_model.dart';
import '../../widgets/currency_formatter.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  int _touchedPieIndex = -1;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FinanceProvider>();
    final expenseByCategory = provider.getExpenseByCategory();
    final monthlyData = provider.getLast6MonthsData();

    final List<Color> pieColors = [
      const Color(0xFFDC2626),
      const Color(0xFFEA580C),
      const Color(0xFFDB2777),
      const Color(0xFF0369A1),
      const Color(0xFFD97706),
      const Color(0xFF6B7280),
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: RefreshIndicator(
        onRefresh: () => provider.fetchAllData(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
          // Blue curved header
          SliverAppBar(
            expandedHeight: 230,
            pinned: true,
            backgroundColor: AppTheme.primary,
            elevation: 0,
            title: const Text('Laporan Keuangan',
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
                    padding: const EdgeInsets.fromLTRB(20, 56, 20, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text('Saldo Keseluruhan',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyFormatter.format(provider.netBalance),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _HeaderStat(
                                label: 'Pemasukan',
                                amount: provider.totalIncome,
                                color: const Color(0xFF86EFAC),
                                icon: Icons.arrow_downward_rounded,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _HeaderStat(
                                label: 'Pengeluaran',
                                amount: provider.totalExpense,
                                color: const Color(0xFFFCA5A5),
                                icon: Icons.arrow_upward_rounded,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Pie Chart
                const _SectionTitle(title: 'Pengeluaran per Kategori'),
                const SizedBox(height: 12),
                if (expenseByCategory.isEmpty)
                  _EmptyCard(message: 'Belum ada data pengeluaran')
                else
                  _PieChartCard(
                    data: expenseByCategory,
                    colors: pieColors,
                    touchedIndex: _touchedPieIndex,
                    onTouch: (i) => setState(() => _touchedPieIndex = i),
                  ),
                const SizedBox(height: 22),

                // Bar Chart
                const _SectionTitle(title: 'Perbandingan 6 Bulan Terakhir'),
                const SizedBox(height: 12),
                _BarChartCard(data: monthlyData),
                const SizedBox(height: 22),

                // Breakdown
                const _SectionTitle(title: 'Rincian Pengeluaran'),
                const SizedBox(height: 12),
                if (expenseByCategory.isEmpty)
                  _EmptyCard(message: 'Belum ada data')
                else
                  ...expenseByCategory.entries
                      .toList()
                      .asMap()
                      .entries
                      .map((entry) {
                    final i = entry.key;
                    final cat = Categories.findById(entry.value.key);
                    final amount = entry.value.value;
                    final total = expenseByCategory.values
                        .fold(0.0, (s, v) => s + v);
                    return _CategoryRow(
                      categoryName: cat?.name ?? entry.value.key,
                      icon: cat?.icon ?? Icons.category_outlined,
                      color: pieColors[i % pieColors.length],
                      amount: amount,
                      percentage: total > 0 ? (amount / total * 100) : 0,
                    );
                  }),
              ]),
            ),
          ),
        ],
      ),
     ),
    );
  }
}

// ─── Header Stat ──────────────────────────────────────────────────────────────
class _HeaderStat extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;
  const _HeaderStat(
      {required this.label,
      required this.amount,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.2), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white, size: 14),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 10)),
                  Text(CurrencyFormatter.formatCompact(amount),
                      style: TextStyle(
                          color: color,
                          fontSize: 13,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ),
      );
}

// ─── Section Title ────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Text(title,
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary)),
        ],
      );
}

// ─── Pie Chart Card ───────────────────────────────────────────────────────────
class _PieChartCard extends StatelessWidget {
  final Map<String, double> data;
  final List<Color> colors;
  final int touchedIndex;
  final ValueChanged<int> onTouch;
  const _PieChartCard({
    required this.data,
    required this.colors,
    required this.touchedIndex,
    required this.onTouch,
  });

  @override
  Widget build(BuildContext context) {
    final total = data.values.fold(0.0, (s, v) => s + v);
    final entries = data.entries.toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 220,
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      pieTouchData: PieTouchData(
                        touchCallback: (event, response) {
                          if (!event.isInterestedForInteractions ||
                              response?.touchedSection == null) {
                            onTouch(-1);
                            return;
                          }
                          onTouch(response!
                              .touchedSection!.touchedSectionIndex);
                        },
                      ),
                      startDegreeOffset: -90,
                      sections: entries.asMap().entries.map((entry) {
                        final i = entry.key;
                        final e = entry.value;
                        final isTouched = i == touchedIndex;
                        final pct = total > 0 ? e.value / total * 100 : 0;

                        return PieChartSectionData(
                          color: colors[i % colors.length],
                          value: e.value,
                          radius: isTouched ? 82 : 68,
                          title: isTouched
                              ? '${pct.toStringAsFixed(1)}%'
                              : '',
                          titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                          badgePositionPercentageOffset: 0.9,
                        );
                      }).toList(),
                      centerSpaceRadius: 50,
                      sectionsSpace: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Legend
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: entries.asMap().entries.map((entry) {
                    final i = entry.key;
                    final cat = Categories.findById(entry.value.key);
                    final pct = total > 0
                        ? entry.value.value / total * 100
                        : 0.0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: colors[i % colors.length],
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(cat?.name ?? entry.value.key,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textPrimary,
                                      fontWeight: FontWeight.w600)),
                              Text('${pct.toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                      fontSize: 10,
                                      color: AppTheme.textSecondary)),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Total Pengeluaran: ${CurrencyFormatter.format(total)}',
              style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bar Chart Card ───────────────────────────────────────────────────────────
class _BarChartCard extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  const _BarChartCard({required this.data});

  @override
  Widget build(BuildContext context) {
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
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _LegendDot(color: AppTheme.income, label: 'Pemasukan'),
              const SizedBox(width: 16),
              _LegendDot(color: AppTheme.expense, label: 'Pengeluaran'),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY * 1.2,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        CurrencyFormatter.formatCompact(rod.toY),
                        const TextStyle(color: Colors.white, fontSize: 11),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (val, _) {
                        if (val.toInt() < data.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              DateFormatter.formatShortMonth(
                                  data[val.toInt()]['month'] as DateTime),
                              style: const TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.textSecondary),
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
                      reservedSize: 52,
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
                gridData: FlGridData(
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) =>
                      const FlLine(color: AppTheme.divider, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                barGroups: data.asMap().entries.map((entry) {
                  final i = entry.key;
                  final d = entry.value;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: d['income'] as double,
                        color: AppTheme.income,
                        width: 10,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6)),
                      ),
                      BarChartRodData(
                        toY: d['expense'] as double,
                        color: AppTheme.expense,
                        width: 10,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(6)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Legend Dot ───────────────────────────────────────────────────────────────
class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(3))),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: AppTheme.textSecondary)),
        ],
      );
}

// ─── Category Row ─────────────────────────────────────────────────────────────
class _CategoryRow extends StatelessWidget {
  final String categoryName;
  final IconData icon;
  final Color color;
  final double amount;
  final double percentage;
  const _CategoryRow({
    required this.categoryName,
    required this.icon,
    required this.color,
    required this.amount,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(categoryName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: AppTheme.textPrimary)),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      minHeight: 7,
                      backgroundColor: AppTheme.divider,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(CurrencyFormatter.formatCompact(amount),
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: color)),
                Text('${percentage.toStringAsFixed(1)}%',
                    style: const TextStyle(
                        fontSize: 10, color: AppTheme.textSecondary)),
              ],
            ),
          ],
        ),
      );
}

// ─── Empty Card ───────────────────────────────────────────────────────────────
class _EmptyCard extends StatelessWidget {
  final String message;
  const _EmptyCard({required this.message});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.bar_chart_rounded,
                  size: 40, color: AppTheme.textSecondary),
              const SizedBox(height: 10),
              Text(message,
                  style: const TextStyle(color: AppTheme.textSecondary)),
            ],
          ),
        ),
      );
}
