import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:phf_money_app/core/widgets/phf_background.dart';
import '../widgets/expense_pie_chart.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_state.dart';
import '../providers/report_providers.dart';
import '../widgets/income_expense_chart.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(selectedReportMonthProvider);
    final summary = ref.watch(monthlySummaryProvider);
    final breakdown = ref.watch(categoryBreakdownProvider);
    final maxAmount = breakdown.isEmpty
        ? 0.0
        : breakdown.map((e) => e.amount).reduce((a, b) => a > b ? a : b);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Financial Reports",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: PHFBackground(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            _MonthSelector(month: month),
            const SizedBox(height: AppSpacing.md),
            _SummaryRow(summary: summary),
            const SizedBox(height: AppSpacing.md),
            IncomeExpenseChart(
              income: summary.income,
              expense: summary.expense,
            ),
            const SizedBox(height: AppSpacing.lg),
            if (breakdown.isNotEmpty) ...[
              const Text(
                'Expense Distribution',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ExpensePieChart(
                items: breakdown,
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            Text('Where your money went',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            if (breakdown.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: AppSpacing.lg),
                child: EmptyState(
                  icon: Icons.bar_chart,
                  title: 'No expenses recorded for this month',
                ),
              )
            else
              ...breakdown.map(
                  (item) => _CategoryBar(item: item, maxAmount: maxAmount)),
            const SizedBox(height: AppSpacing.lg),
            if (breakdown.isNotEmpty)
              _InsightText(topCategory: breakdown.first, summary: summary),
          ],
        ),
      ),
    );
  }
}

class _MonthSelector extends ConsumerWidget {
  const _MonthSelector({required this.month});
  final String month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = DateFormat('yyyy-MM').parse(month);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            final prev = DateTime(current.year, current.month - 1);
            ref.read(selectedReportMonthProvider.notifier).state =
                DateFormat('yyyy-MM').format(prev);
          },
        ),
        Text(DateFormat('MMMM yyyy').format(current),
            style: Theme.of(context).textTheme.titleMedium),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            final next = DateTime(current.year, current.month + 1);
            ref.read(selectedReportMonthProvider.notifier).state =
                DateFormat('yyyy-MM').format(next);
          },
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.summary});

  final MonthlySummary summary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            label: 'Income',
            value: summary.income,
            color: AppColors.income,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatTile(
            label: 'Expense',
            value: summary.expense,
            color: AppColors.expense,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _StatTile(
            label: 'Net',
            value: summary.net,
            color: summary.net >= 0 ? AppColors.income : AppColors.expense,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile(
      {required this.label, required this.value, required this.color});
  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md, horizontal: AppSpacing.sm),
        child: Column(
          children: [
            Text(label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            const SizedBox(height: 4),
            Text(
              AppFormatters.currency(value),
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: color, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  const _CategoryBar({required this.item, required this.maxAmount});
  final CategoryBreakdownItem item;
  final double maxAmount;

  @override
  Widget build(BuildContext context) {
    final ratio = maxAmount <= 0 ? 0.0 : item.amount / maxAmount;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item.category.name, style: const TextStyle(fontSize: 13)),
              Text(AppFormatters.currency(item.amount),
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 10,
              backgroundColor: Colors.grey.shade200,
              color: AppColors.phfBlue,
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightText extends StatelessWidget {
  const _InsightText({required this.topCategory, required this.summary});
  final CategoryBreakdownItem topCategory;
  final MonthlySummary summary;

  @override
  Widget build(BuildContext context) {
    final pct = summary.expense <= 0
        ? 0
        : (topCategory.amount / summary.expense * 100).round();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.phfBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline, color: AppColors.phfBlue),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'You spent the most on "${topCategory.category.name}" — about $pct% of this month\'s expenses.',
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
