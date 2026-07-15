import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({
    super.key,
    required this.onIncome,
    required this.onExpense,
    required this.onReports,
  });

  final VoidCallback onIncome;
  final VoidCallback onExpense;
  final VoidCallback onReports;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            title: "Income",
            icon: Icons.add_circle_outline,
            color: AppColors.income,
            onTap: onIncome,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionButton(
            title: "Expense",
            icon: Icons.remove_circle_outline,
            color: AppColors.expense,
            onTap: onExpense,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ActionButton(
            title: "Reports",
            icon: Icons.bar_chart,
            color: AppColors.phfBlue,
            onTap: onReports,
          ),
        )
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton(
      {required this.title,
      required this.icon,
      required this.color,
      required this.onTap});

  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(children: [
          Icon(
            icon,
            color: color,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.bold, color: color),
          )
        ]),
      ),
    );
  }
}
