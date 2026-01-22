import 'package:flutter/material.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;

  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Enterprise-ish: subtle gradients + soft “glow” cards read well on web/mobile
    final colors = isDark
        ? const [
            Color(0xFF0B1220),
            Color(0xFF111827),
            Color(0xFF0F172A),
          ]
        : const [
            Color(0xFFEEF2FF),
            Color(0xFFE0F2FE),
            Color(0xFFF8FAFC),
          ];

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: SafeArea(child: child),
    );
  }
}
