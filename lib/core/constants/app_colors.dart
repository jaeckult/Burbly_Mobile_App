import 'package:flutter/material.dart';

/// Centralized color constants for the Burbly app.
/// Using these instead of hardcoded color values throughout the codebase.
class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF64B5F6);

  // Accent Colors
  static const Color accent = Color(0xFF00BCD4);
  static const Color accentDark = Color(0xFF0097A7);

  // Background Colors (Light Theme)
  static const Color backgroundLight = Color(0xFFF8F9FF);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF0F4FF);

  // Background Colors (Dark Theme)
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color surfaceVariantDark = Color(0xFF2C2C2C);

  // Text Colors (Light Theme)
  static const Color textPrimaryLight = Color(0xFF1E293B);
  static const Color textSecondaryLight = Color(0xFF475569);
  static const Color textTertiaryLight = Color(0xFF94A3B8);

  // Text Colors (Dark Theme)
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  static const Color textTertiaryDark = Color(0xFF808080);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFF81C784);
  static const Color warning = Color(0xFFFFC107);
  static const Color warningLight = Color(0xFFFFD54F);
  static const Color error = Color(0xFFF44336);
  static const Color errorLight = Color(0xFFE57373);
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0xFF64B5F6);

  // Deck Card Colors (Default palette)
  static const List<String> deckColorPalette = [
    '2196F3', // Blue
    '4CAF50', // Green
    'FF9800', // Orange
    '9C27B0', // Purple
    'E91E63', // Pink
    '00BCD4', // Cyan
    'F44336', // Red
    '607D8B', // Blue Grey
    '795548', // Brown
    '3F51B5', // Indigo
  ];

  // Study Status Colors
  static const Color overdueColor = Color(0xFFF44336);
  static const Color dueNowColor = Color(0xFFFF9800);
  static const Color reviewedColor = Color(0xFF4CAF50);
  static const Color newCardColor = Color(0xFF2196F3);
  static const Color learningColor = Color(0xFF9C27B0);

  // Border Colors
  static const Color borderLight = Color(0xFFE1E8FF);
  static const Color borderDark = Color(0xFF404040);

  // Shadow Colors
  static const Color shadowLight = Color(0x1A1E293B);
  static const Color shadowDark = Color(0x4D000000);

  /// Get a default deck color from the palette by index
  static String getDeckColor(int index) {
    return deckColorPalette[index % deckColorPalette.length];
  }

  /// Parse a hex color string safely
  static Color fromHex(String? hexColor, {Color fallback = primary}) {
    if (hexColor == null || hexColor.isEmpty) return fallback;
    try {
      String cleanHex = hexColor.replaceAll('#', '').toUpperCase();
      if (cleanHex.length == 6) {
        return Color(int.parse('0xFF$cleanHex'));
      }
      return fallback;
    } catch (e) {
      return fallback;
    }
  }

  /// Create a gradient for deck cards
  static LinearGradient deckCardGradient(String? coverColor) {
    final color = fromHex(coverColor);
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        color,
        color.withOpacity(0.7),
      ],
    );
  }
}
