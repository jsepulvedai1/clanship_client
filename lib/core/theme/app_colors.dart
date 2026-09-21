import 'package:flutter/material.dart';

class AppColors {
  // Brand Default Colors (Fijos corporativos Clanship)
  static const Color defaultPrimary = Color(0xFF0B6E4F); // Green (#0B6E4F)
  static const Color defaultSecondary = Color(0xFF0D2B45); // Deep Blue (#0D2B45)
  static const Color defaultAccent = Color(0xFFF28C28); // Orange (#F28C28)

  // Centralized Dynamic Colors (Responden al tema global y festividades)
  static Color _primary = defaultPrimary;
  static Color _secondary = defaultSecondary;
  static Color _accent = defaultAccent;

  static Color get primary => _primary;
  static Color get secondary => _secondary;
  static Color get accent => _accent;

  static void setSeasonalOverrides({
    Color? primary,
    Color? secondary,
    Color? accent,
  }) {
    _primary = primary ?? defaultPrimary;
    _secondary = secondary ?? defaultSecondary;
    _accent = accent ?? defaultAccent;
  }

  static void resetDefaults() {
    _primary = defaultPrimary;
    _secondary = defaultSecondary;
    _accent = defaultAccent;
  }

  // Neutral Colors (Slate Palette)
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF2E3135); // Graphite Grey (#2E3135)

  // Surface Colors
  static const Color black = Color(0xFF000000); // AMOLED Black
  static const Color white = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF121212);

  // Semantic Colors
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFFF59E0B);
  static const Color urgency = Color(0xFFFF5271);
}
