import 'package:hive_flutter/hive_flutter.dart';
import 'package:phf_money_app/features/settings/data/theme_storage.dart';

class AppInitializer {
  static Future<void> initialize() async {
    try {
      // Initialize Hive
      await Hive.initFlutter();

      // Open settings box
      await Hive.openBox<Map>(
        ThemeStorage.boxName,
      );

      // Load saved settings
      final themeStorage = ThemeStorage();

      themeStorage.getTheme();
    } catch (e) {
      throw Exception(
        "App initialization failed: $e",
      );
    }
  }
}
