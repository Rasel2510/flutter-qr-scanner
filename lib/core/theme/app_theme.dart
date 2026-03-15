import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF111827);
  static const Color primaryDark = Color(0xFF000000);
  static const Color primaryLight = Color(0xFFF3F4F6);
  static const Color accent = Color(0xFF6366F1);

  static const Color bg = Color(0xFFF9FAFB);
  static const Color bgCard = Color(0xFFFFFFFF);
  static const Color bgCardLight = Color(0xFFF3F4F6);
  static const Color surface = Color(0xFFF3F4F6);
  static const Color border = Color(0xFFE5E7EB);

  static const Color text = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color orange = Color.fromARGB(77, 211, 22, 249);
  static const Color textMuted = Color(0xFF9CA3AF);

  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
}

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.text,
    height: 1.1,
    letterSpacing: -0.5,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.text,
    height: 1.2,
  );

  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.text,
  );

  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColors.text,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
    letterSpacing: 0.5,
  );

  static const TextStyle mono = TextStyle(
    fontSize: 13,
    fontFamily: 'monospace',
    color: AppColors.text,
    height: 1.6,
  );
}

class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.surface,
          error: AppColors.error,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.bg,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: AppTextStyles.titleLarge,
          iconTheme: IconThemeData(color: AppColors.text),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.bgCard,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textMuted,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.border,
          thickness: 1,
        ),
        fontFamily: 'SF Pro',
      );
}
