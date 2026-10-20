import 'package:flutter/material.dart';
import 'mystic_colors.dart';

abstract final class MysticTheme {
  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      primary: MysticColors.gold,
      onPrimary: MysticColors.midnight,
      secondary: MysticColors.paleGold,
      surface: MysticColors.deepOcean,
      onSurface: MysticColors.ivory,
      error: MysticColors.error,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: MysticColors.midnight,
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: MysticColors.paleGold,
          fontSize: 30,
          fontWeight: FontWeight.w700,
          letterSpacing: .4,
        ),
        headlineSmall: TextStyle(
          color: MysticColors.paleGold,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: MysticColors.ivory,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: MysticColors.ivory, height: 1.5),
        bodyMedium: TextStyle(color: Color(0xFFD8D2C7), height: 1.45),
      ),
      dividerColor: MysticColors.gold.withValues(alpha: .24),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: MysticColors.deepOcean.withValues(alpha: .84),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: MysticColors.gold),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: MysticColors.gold.withValues(alpha: .45),
          ),
        ),
      ),
    );
  }
}
