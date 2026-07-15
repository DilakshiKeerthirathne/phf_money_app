import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../accounts/presentation/pages/accounts_page.dart';
import '../../../categories/presentation/pages/categories_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "More",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppColors.phfBlueDark,
                    AppColors.phfBlue,
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: const [
                  CircleAvatar(
                    radius: 38,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.account_balance_wallet,
                      color: AppColors.phfBlue,
                      size: 40,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "PHF Money",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Personal Finance Manager",
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            _MenuCard(
              icon: Icons.account_balance_wallet,
              title: "Accounts",
              subtitle: "Manage your wallets and accounts",
              color: AppColors.phfBlue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AccountsPage(),
                  ),
                );
              },
            ),
            _MenuCard(
              icon: Icons.category,
              title: "Categories",
              subtitle: "Manage income and expense categories",
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CategoriesPage(),
                  ),
                );
              },
            ),
            _MenuCard(
              icon: Icons.settings,
              title: "Settings",
              subtitle: "Customize your application",
              color: Colors.grey,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SettingsPage(),
                  ),
                );
              },
            ),
            _MenuCard(
              icon: Icons.info_outline,
              title: "About",
              subtitle: "Application information",
              color: Colors.teal,
              onTap: () {},
            ),
            _MenuCard(
              icon: Icons.star_outline,
              title: "Rate App",
              subtitle: "Share your feedback",
              color: Colors.amber,
              onTap: () {},
            ),
            _MenuCard(
              icon: Icons.email_outlined,
              title: "Contact Support",
              subtitle: "Get help and support",
              color: Colors.deepPurple,
              onTap: () {},
            ),
            const Divider(),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                "Version 1.0.0",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 5),
            const Center(
              child: Text(
                "© 2026 PHF Money",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
