import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0F14) : Colors.white,
      body: Center(
        child: SizedBox(
          height: 140,
          child: Image(
            image: AssetImage(
              isDark ? 'assets/logos/logo_white.png' : 'assets/logos/logo_black.png',
            ),
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
