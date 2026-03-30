import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

class LightTheme {
  static final AppColors _colors = LightAppColors();

  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: _colors.primary,
        secondary: _colors.secondary,
        surface: _colors.surface,
        error: _colors.error,
        onPrimary: _colors.surface,
        onSecondary: _colors.surface,
        onSurface: _colors.textPrimary,
        onSurfaceVariant: _colors.textSecondary,
        onError: _colors.surface,
        outline: _colors.outline,
      ),
      scaffoldBackgroundColor: _colors.background,
      textTheme: appTextTheme(_colors),
      appBarTheme: AppBarTheme(
        backgroundColor: _colors.surfaceVariant,
        foregroundColor: _colors.textPrimary,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: _colors.surface,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _colors.surfaceVariant,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _colors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _colors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _colors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _colors.primary,
          foregroundColor: _colors.surface,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _colors.primary,
          side: BorderSide(color: _colors.primary),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _colors.surfaceVariant,
        selectedColor: _colors.primary.withValues(alpha: 0.3),
        labelStyle: appTextTheme(_colors).bodyMedium,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
