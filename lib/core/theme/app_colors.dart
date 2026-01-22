import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  /// ✅ Global gradient
  static const LinearGradient kGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2563EB),
      Color(0xFF06B6D4),
    ],
  );

  static const Color primary = Color(0xFF2563EB);
  static const Color secondary = Color(0xFF06B6D4);
}
