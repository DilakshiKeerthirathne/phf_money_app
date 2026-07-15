import 'package:hive_flutter/hive_flutter.dart';

class ThemeStorage {
  static const boxName = 'settings_box';
  static const key = 'theme_mode';

  Future<void> saveTheme(String mode) async {
    final box = Hive.box<Map>(boxName);

    await box.put(
      key,
      {
        'value': mode,
      },
    );
  }

  String getTheme() {
    final box = Hive.box<Map>(boxName);

    final data = box.get(
      key,
      defaultValue: {
        'value': 'system',
      },
    );

    return data?['value'] ?? 'system';
  }
}
