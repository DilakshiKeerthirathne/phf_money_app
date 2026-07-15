import 'package:hive_flutter/hive_flutter.dart';

class CurrencyStorage {
  static const boxName = 'settings_box';
  static const key = 'currency';

  String getCurrency() {
    final box = Hive.box<Map>(boxName);

    final data = box.get(
      key,
      defaultValue: {
        'value': 'Rs.',
      },
    );

    return data?['value'] ?? 'Rs.';
  }

  Future<void> saveCurrency(String currency) async {
    final box = Hive.box<Map>(boxName);

    await box.put(
      key,
      {
        'value': currency,
      },
    );
  }
}
