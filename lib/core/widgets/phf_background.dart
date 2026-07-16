import 'package:flutter/material.dart';

class PHFBackground extends StatelessWidget {
  const PHFBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [
                  Color(0xFF121212),
                  Color(0xFF1E1E1E),
                ]
              : const [
                  Color(0xFFEAF3FF),
                  Color(0xFFF7FAFF),
                ],
        ),
      ),
      child: child,
    );
  }
}
