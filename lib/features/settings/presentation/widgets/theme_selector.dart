import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/theme_provider.dart';

class ThemeSelector extends ConsumerWidget {
  const ThemeSelector({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(themeProvider);

    return ListTile(
      leading: const Icon(
        Icons.dark_mode_outlined,
      ),
      title: const Text(
        "Theme",
      ),
      subtitle: Text(
        current.name.toUpperCase(),
      ),
      trailing: DropdownButton<ThemeMode>(
        value: current,
        underline: const SizedBox(),
        items: const [
          DropdownMenuItem(
            value: ThemeMode.system,
            child: Text(
              "System",
            ),
          ),
          DropdownMenuItem(
            value: ThemeMode.light,
            child: Text(
              "Light",
            ),
          ),
          DropdownMenuItem(
            value: ThemeMode.dark,
            child: Text(
              "Dark",
            ),
          ),
        ],
        onChanged: (value) {
          if (value != null) {
            ref.read(themeProvider.notifier).changeTheme(value);
          }
        },
      ),
    );
  }
}
