import 'package:flutter/material.dart';

abstract class AppColors {
  // Core palette
  static const Color jetBlack = Color(0xFF2D3142);
  static const Color silver = Color(0xFFBFC0C0);
  static const Color white = Color(0xFFFFFFFF);
  static const Color coralGlow = Color(0xFFEF8354);
  static const Color blueSlate = Color(0xFF4F5D75);

  // Extrapolated variants
  static const Color coralLight = Color(0xFFF4A882);
  static const Color coralDark = Color(0xFFD96A3F);
  static const Color blueSlateLight = Color(0xFF6B7A94);
  static const Color silverLight = Color(0xFFE8E8E9);
  static const Color error = Color(0xFFD32F2F);

  // Semantic aliases
  static const Color primary = coralGlow;
  static const Color primaryLight = coralLight;
  static const Color primaryDark = coralDark;
  static const Color secondary = blueSlate;
  static const Color surface = white;
  static const Color surfaceVariant = silverLight;
  static const Color onPrimary = white;
  static const Color onSecondary = white;
  static const Color onSurface = jetBlack;
  static const Color onError = white;
  static const Color divider = silver;
}
