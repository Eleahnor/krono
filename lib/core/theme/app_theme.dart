import 'package:flutter/material.dart';
import '../constants/colors.dart';

class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: KronoColors.primary,
          primary: KronoColors.primary,
          secondary: KronoColors.deepBlue,
          surface: Colors.white,
          error: KronoColors.error,
        ),
        scaffoldBackgroundColor: const Color(0xFFF3F4FF),
        appBarTheme: const AppBarTheme(
          backgroundColor: KronoColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        tabBarTheme: const TabBarThemeData(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: KronoColors.info,
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: KronoColors.primary,
          brightness: Brightness.dark,
          primary: KronoColors.primary,
          secondary: KronoColors.info,
          surface: KronoColors.navy,
          error: KronoColors.error,
        ),
        scaffoldBackgroundColor: KronoColors.night,
        appBarTheme: const AppBarTheme(
          backgroundColor: KronoColors.deepBlue,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        tabBarTheme: const TabBarThemeData(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: KronoColors.info,
        ),
        cardTheme: const CardThemeData(color: KronoColors.navy),
      );
}
