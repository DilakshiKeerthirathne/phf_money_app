import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phf_money_app/features/accounts/presentation/providers/account_providers.dart';
import 'package:phf_money_app/features/budgets/presentation/providers/budget_providers.dart';
import 'package:phf_money_app/features/categories/presentation/providers/category_providers.dart';
import 'package:phf_money_app/features/settings/data/currency_storage.dart';
import 'package:phf_money_app/features/settings/data/export_service.dart';
import 'package:phf_money_app/features/settings/presentation/widgets/currency_selector.dart';
import 'package:phf_money_app/features/settings/presentation/widgets/theme_selector.dart';
import 'package:phf_money_app/features/transactions/presentation/providers/transaction_providers.dart';

import '../../../../core/widgets/phf_background.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          "Settings",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: PHFBackground(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Theme Settings
            _SectionCard(
              title: "Appearance",
              icon: Icons.palette_outlined,
              child: const ThemeSelector(),
            ),

            const SizedBox(height: 20),

            // Application Information
            _SectionCard(
              title: "Application",
              icon: Icons.info_outline,
              child: Column(
                children: const [
                  ListTile(
                    leading: Icon(
                      Icons.account_balance_wallet_outlined,
                    ),
                    title: Text(
                      "PHF Money Manager",
                    ),
                    subtitle: Text(
                      "Personal finance tracking application",
                    ),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(
                      Icons.code,
                    ),
                    title: Text(
                      "Version",
                    ),
                    subtitle: Text(
                      "1.0.0",
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Settings Actions
            _SectionCard(
              title: "Preferences",
              icon: Icons.settings_outlined,
              child: Column(
                children: [
                  // Currency
                  // Currency
                  CurrencySelector(
                    onTap: () {
                      _showCurrencyDialog(context, ref);
                    },
                  ),

                  const Divider(),

                  // Export
                  ListTile(
                    leading: const Icon(
                      Icons.file_download_outlined,
                    ),
                    title: const Text(
                      "Export Data",
                    ),
                    subtitle: const Text(
                      "Export transactions backup",
                    ),
                    onTap: () async {
                      final transactions =
                          ref.read(transactionsProvider).valueOrNull ?? [];

                      if (transactions.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "No transactions available",
                            ),
                          ),
                        );

                        return;
                      }

                      await ExportService().exportTransactions(transactions);
                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Export completed",
                          ),
                        ),
                      );
                    },
                  ),

                  const Divider(),

                  // Reset
                  ListTile(
                    leading: const Icon(
                      Icons.delete_forever,
                      color: Colors.red,
                    ),
                    title: const Text(
                      "Reset Data",
                    ),
                    subtitle: const Text(
                      "Remove all local records",
                    ),
                    onTap: () {
                      _showResetDialog(context, ref);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reset confirmation dialog

  void _showResetDialog(
    BuildContext context,
    WidgetRef ref,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Reset Data?",
          ),
          content: const Text(
            "All transactions, accounts and budgets will be deleted permanently.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Cancel",
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () async {
                // delete transactions
                await ref.read(transactionsProvider.notifier).clearAll();

                // delete accounts
                await ref.read(accountsProvider.notifier).clearAll();

                // delete categories
                await ref.read(categoriesProvider.notifier).clearAll();

                // delete budgets
                await ref.read(budgetsProvider.notifier).clearAll();

                if (!context.mounted) return;

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      "All data deleted",
                    ),
                  ),
                );
              },
              child: const Text(
                "Reset",
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCurrencyDialog(BuildContext context, WidgetRef ref) {
    final currencies = [
      "Rs.",
      "\$",
      "€",
      "£",
    ];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Select Currency",
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: currencies.map((currency) {
              return ListTile(
                title: Text(currency),
                onTap: () async {
                  await CurrencyStorage().saveCurrency(currency);
                  if (!context.mounted) return;

                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;

  final IconData icon;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: Icon(icon),
            title: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
