import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Импорт для SystemUiOverlayStyle

enum AppThemeOption {
  system,
  light,
  dark,
}

extension AppThemeOptionExtension on AppThemeOption {
  String get name {
    switch (this) {
      case AppThemeOption.system:
        return 'System';
      case AppThemeOption.light:
        return 'Light Theme';
      case AppThemeOption.dark:
        return 'Dark Theme';
    }
  }
}

class AppThemes {
  // Основные цвета для удобного переиспользования
  static const Color _lightPrimaryColor = Color(0xFF56CCF2); // Яркий голубой
  static const Color _lightAccentColor = Color(0xFFF2994A);  // Мягкий оранжевый
  static const Color _lightBackgroundColor = Color(0xFFF5F7FA); // Очень светлый серо-голубой
  static const Color _lightSurfaceColor = Colors.white;
  static const Color _lightOnPrimaryColor = Colors.white;
  static const Color _lightOnAccentColor = Colors.white;
  static const Color _lightTextColor = Color(0xFF333333);

  static const Color _darkPrimaryColor = Color(0xFF4A90E2);   // Глубокий синий
  static const Color _darkAccentColor = Color(0xFF50E3C2);    // Яркий бирюзовый (tealish)
  static const Color _darkBackgroundColor = Color(0xFF1C1C2E);  // Очень темный индиго
  static const Color _darkSurfaceColor = Color(0xFF2A2A40);   // Темно-синий/фиолетовый
  static const Color _darkOnPrimaryColor = Colors.white;
  static const Color _darkOnAccentColor = Color(0xFF1A1A2E); // Очень темный для контраста с ярким акцентом
  static const Color _darkTextColor = Color(0xFFE0E0E0);

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: _lightPrimaryColor,
    scaffoldBackgroundColor: _lightBackgroundColor,
    colorScheme: ColorScheme.light(
      primary: _lightPrimaryColor,
      onPrimary: _lightOnPrimaryColor,
      secondary: _lightAccentColor,
      onSecondary: _lightOnAccentColor,
      surface: _lightSurfaceColor,
      onSurface: _lightTextColor,
      background: _lightBackgroundColor,
      onBackground: _lightTextColor,
      error: Colors.redAccent,
      onError: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 1,
      scrolledUnderElevation: 2,
      titleTextStyle: TextStyle(
        color: _lightTextColor,
        fontSize: 20, 
        fontWeight: FontWeight.w500
      ),
      iconTheme: IconThemeData(color: _lightPrimaryColor),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _lightAccentColor,
      foregroundColor: _lightOnAccentColor,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _lightPrimaryColor,
        foregroundColor: _lightOnPrimaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _lightPrimaryColor,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _lightSurfaceColor.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _lightPrimaryColor.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _lightPrimaryColor, width: 2),
      ),
      labelStyle: const TextStyle(color: _lightTextColor),
      hintStyle: TextStyle(color: _lightTextColor.withOpacity(0.6)),
    ),
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: _lightSurfaceColor,
      surfaceTintColor: Colors.transparent,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: _lightSurfaceColor,
      selectedItemColor: _lightPrimaryColor,
      unselectedItemColor: _lightTextColor.withOpacity(0.6),
      elevation: 5,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),
    textTheme: TextTheme(
        displayLarge: TextStyle(color: _lightTextColor, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: _lightTextColor, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(color: _lightTextColor, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(color: _lightTextColor, fontWeight: FontWeight.w600),
        headlineMedium: TextStyle(color: _lightTextColor, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(color: _lightTextColor, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: _lightTextColor, fontWeight: FontWeight.w500),
        titleMedium: TextStyle(color: _lightTextColor.withOpacity(0.8)),
        titleSmall: TextStyle(color: _lightTextColor.withOpacity(0.7)),
        bodyLarge: TextStyle(color: _lightTextColor, fontSize: 16),
        bodyMedium: TextStyle(color: _lightTextColor.withOpacity(0.9), fontSize: 14),
        bodySmall: TextStyle(color: _lightTextColor.withOpacity(0.7), fontSize: 12),
        labelLarge: TextStyle(color: _lightPrimaryColor, fontWeight: FontWeight.w500),
      ).apply(
        bodyColor: _lightTextColor,
        displayColor: _lightTextColor,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      useMaterial3: true,
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: _darkPrimaryColor,
    scaffoldBackgroundColor: _darkBackgroundColor,
    colorScheme: ColorScheme.dark(
      primary: _darkPrimaryColor,
      onPrimary: _darkOnPrimaryColor,
      secondary: _darkAccentColor,
      onSecondary: _darkOnAccentColor,
      surface: _darkSurfaceColor,
      onSurface: _darkTextColor,
      background: _darkBackgroundColor,
      onBackground: _darkTextColor,
      error: Colors.red[400]!,
      onError: Colors.black,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 1,
      scrolledUnderElevation: 2,
      titleTextStyle: TextStyle(
        color: _darkOnPrimaryColor, 
        fontSize: 20, 
        fontWeight: FontWeight.w500
      ),
      iconTheme: IconThemeData(color: _darkOnPrimaryColor),
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _darkAccentColor,
      foregroundColor: _darkOnAccentColor,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkPrimaryColor,
        foregroundColor: _darkOnPrimaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _darkAccentColor,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkSurfaceColor.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _darkPrimaryColor.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _darkAccentColor, width: 2),
      ),
      labelStyle: const TextStyle(color: _darkTextColor),
      hintStyle: TextStyle(color: _darkTextColor.withOpacity(0.6)),
    ),
     cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: _darkSurfaceColor,
      surfaceTintColor: Colors.transparent,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: _darkSurfaceColor,
      selectedItemColor: _darkAccentColor,
      unselectedItemColor: _darkTextColor.withOpacity(0.6),
      elevation: 5,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),
    textTheme: TextTheme(
        displayLarge: TextStyle(color: _darkTextColor, fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: _darkTextColor, fontWeight: FontWeight.bold),
        displaySmall: TextStyle(color: _darkTextColor, fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(color: _darkTextColor, fontWeight: FontWeight.w600),
        headlineMedium: TextStyle(color: _darkTextColor, fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(color: _darkTextColor, fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: _darkTextColor, fontWeight: FontWeight.w500),
        titleMedium: TextStyle(color: _darkTextColor.withOpacity(0.8)),
        titleSmall: TextStyle(color: _darkTextColor.withOpacity(0.7)),
        bodyLarge: TextStyle(color: _darkTextColor, fontSize: 16),
        bodyMedium: TextStyle(color: _darkTextColor.withOpacity(0.9), fontSize: 14),
        bodySmall: TextStyle(color: _darkTextColor.withOpacity(0.7), fontSize: 12),
        labelLarge: TextStyle(color: _darkAccentColor, fontWeight: FontWeight.w500),
      ).apply(
        bodyColor: _darkTextColor,
        displayColor: _darkTextColor,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      useMaterial3: true,
  );
} 