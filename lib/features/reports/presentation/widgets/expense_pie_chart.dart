import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:phf_money_app/features/reports/presentation/providers/report_providers.dart';

class ExpensePieChart extends StatelessWidget {
  const ExpensePieChart({
    super.key,
    required this.items,
  });

  final List<CategoryBreakdownItem> items;

  @override
  Widget build(BuildContext context) {
    final total = items.fold<double>(0, (sum, item) => sum + item.amount);

    return SizedBox(
      height: 220,
      child: PieChart(
        PieChartData(
          sections: items.map((item) {
            final percent = total == 0 ? 0 : item.amount / total * 100;

            return PieChartSectionData(
              value: item.amount,
              title: '${percent.toStringAsFixed(0)}%',
              radius: 70,
              titleStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
