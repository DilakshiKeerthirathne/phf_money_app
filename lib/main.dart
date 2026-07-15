import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phf_money_app/features/splash/presentation/splash_page.dart'
    show SplashPage;

import 'core/theme/theme_provider.dart';
import 'core/theme/app_theme.dart';

import 'data/local/hive_boxes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await HiveBoxes.init();

  runApp(
    const ProviderScope(
      child: PhfMoneyApp(),
    ),
  );
}

class PhfMoneyApp extends ConsumerWidget {
  const PhfMoneyApp({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'PHF Money Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: const SplashPage(),
    );
  }
}
