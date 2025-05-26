    import 'package:flutter/material.dart';
    import 'color_schemes.dart'; // Импортируем наши схемы

    // Перечисление для доступных тем
    enum AppThemeType { light, dark, oceanBreeze }

    class AppTheme {
      static ThemeData getThemeData(AppThemeType themeType) {
        ColorScheme colorScheme;
        switch (themeType) {
          case AppThemeType.dark:
            colorScheme = darkColorScheme;
            break;
          case AppThemeType.oceanBreeze:
            colorScheme = oceanBreezeColorScheme;
            break;
          case AppThemeType.light:
          default:
            colorScheme = lightColorScheme;
            break;
        }

        return ThemeData(
          useMaterial3: true,
          colorScheme: colorScheme,
          fontFamily: 'YourPreferredFont', // Укажите ваш шрифт (например, 'Montserrat', 'Roboto')
          
          // Кастомизация виджетов
          appBarTheme: AppBarTheme(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            elevation: 4.0,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              fontFamily: 'YourPreferredFont', // Убедитесь, что шрифт здесь тоже указан
            ),
          ),
          
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0), // Скругленные кнопки
              ),
            ),
          ),

          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: colorScheme.primary, width: 2.0),
            ),
            labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
            hintStyle: TextStyle(color: colorScheme.onSurfaceVariant.withOpacity(0.7)),
            // Можно добавить градиентную подсветку или анимацию для focusedBorder через кастомный InputBorder
          ),

          cardTheme: CardTheme(
            elevation: 2.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            color: colorScheme.surfaceVariant, // или colorScheme.surface
          ),

          listTileTheme: ListTileThemeData(
            iconColor: colorScheme.primary,
            // Можно добавить кастомный splashColor с градиентом при нажатии
          ),

          // ... другие кастомизации (textTheme, bottomNavigationBarTheme и т.д.)
           textTheme: TextTheme(
            displayLarge: TextStyle(fontSize: 57.0, fontWeight: FontWeight.bold, color: colorScheme.onBackground),
            displayMedium: TextStyle(fontSize: 45.0, fontWeight: FontWeight.bold, color: colorScheme.onBackground),
            displaySmall: TextStyle(fontSize: 36.0, fontWeight: FontWeight.bold, color: colorScheme.onBackground),
            headlineLarge: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold, color: colorScheme.onBackground),
            headlineMedium: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold, color: colorScheme.onBackground),
            headlineSmall: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w500, color: colorScheme.onBackground),
            titleLarge: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w500, color: colorScheme.onSurface),
            titleMedium: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500, letterSpacing: 0.15, color: colorScheme.onSurface),
            titleSmall: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500, letterSpacing: 0.1, color: colorScheme.onSurface),
            bodyLarge: TextStyle(fontSize: 16.0, letterSpacing: 0.5, color: colorScheme.onBackground),
            bodyMedium: TextStyle(fontSize: 14.0, letterSpacing: 0.25, color: colorScheme.onBackground),
            bodySmall: TextStyle(fontSize: 12.0, letterSpacing: 0.4, color: colorScheme.onBackground),
            labelLarge: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w500, letterSpacing: 0.1, color: colorScheme.onPrimary), // Для кнопок
            labelMedium: TextStyle(fontSize: 12.0, letterSpacing: 0.5, color: colorScheme.onSurfaceVariant),
            labelSmall: TextStyle(fontSize: 11.0, letterSpacing: 0.5, color: colorScheme.onSurfaceVariant),
          ),
        );
      }
    }