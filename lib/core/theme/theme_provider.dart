import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/settings/data/theme_storage.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>(
  (ref) => ThemeNotifier(),
);

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system) {
    loadTheme();
  }

  final storage = ThemeStorage();

  void loadTheme() {
    final value = storage.getTheme();

    switch (value) {
      case 'light':
        state = ThemeMode.light;
        break;

      case 'dark':
        state = ThemeMode.dark;
        break;

      default:
        state = ThemeMode.system;
    }
  }

  Future<void> changeTheme(ThemeMode mode) async {
    state = mode;

    await storage.saveTheme(
      mode.name,
    );
  }
}
