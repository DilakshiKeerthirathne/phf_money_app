import 'package:hive_flutter/hive_flutter.dart';

class HiveBoxes {
  HiveBoxes._();

  static const String accounts = 'accounts_box';
  static const String categories = 'categories_box';
  static const String transactions = 'transactions_box';
  static const String budgets = 'budgets_box';
  static const String settings = 'settings_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<Map>(accounts);
    await Hive.openBox<Map>(categories);
    await Hive.openBox<Map>(transactions);
    await Hive.openBox<Map>(budgets);
    await Hive.openBox<Map>(settings);
  }
}
