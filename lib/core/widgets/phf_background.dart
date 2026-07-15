import 'package:flutter/material.dart';

class PHFBackground extends StatelessWidget {
  const PHFBackground({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFEAF3FF),
            Color(0xFFF7FAFF),
          ],
        ),
      ),
      child: child,
    );
  }
}
