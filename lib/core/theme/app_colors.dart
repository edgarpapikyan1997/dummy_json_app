import 'package:flutter/material.dart';

abstract class AppColors {
  Color get primary;
  Color get secondary;
  Color get background;
  Color get surface;
  Color get error;
  Color get textPrimary;
  Color get textSecondary;
  Color get surfaceVariant;
  Color get outline;
  Color get success;
  Color get star;
}

class LightAppColors implements AppColors {
  @override
  Color get primary => const Color(0xFF6750A4);
  @override
  Color get secondary => const Color(0xFF625B71);
  @override
  Color get background => const Color(0xFFFFFBFE);
  @override
  Color get surface => const Color(0xFFFFFBFE);
  @override
  Color get error => const Color(0xFFB3261E);
  @override
  Color get textPrimary => const Color(0xFF1C1B1F);
  @override
  Color get textSecondary => const Color(0xFF49454F);
  @override
  Color get surfaceVariant => const Color(0xFFE7E0EC);
  @override
  Color get outline => const Color(0xFF79747E);
  @override
  Color get success => const Color(0xFF2E7D32);
  @override
  Color get star => const Color(0xFFF9A825);
}

class DarkAppColors implements AppColors {
  @override
  Color get primary => const Color(0xFFD0BCFF);
  @override
  Color get secondary => const Color(0xFFCCC2DC);
  @override
  Color get background => const Color(0xFF1C1B1F);
  @override
  Color get surface => const Color(0xFF1C1B1F);
  @override
  Color get error => const Color(0xFFF2B8B5);
  @override
  Color get textPrimary => const Color(0xFFE6E1E5);
  @override
  Color get textSecondary => const Color(0xFFCAC4D0);
  @override
  Color get surfaceVariant => const Color(0xFF49454F);
  @override
  Color get outline => const Color(0xFF938F99);
  @override
  Color get success => const Color(0xFF81C784);
  @override
  Color get star => const Color(0xFFFFD54F);
}
