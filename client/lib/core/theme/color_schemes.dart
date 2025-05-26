    import 'package:flutter/material.dart';
    import 'app_colors.dart';

    // Светлая схема (по умолчанию)
    const ColorScheme lightColorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primaryBase, // Например, #4A90E2 (Синий)
      onPrimary: Colors.white,
      primaryContainer: Color(0xFFADCFFF),
      onPrimaryContainer: Color(0xFF001D36),
      secondary: AppColors.secondaryBase, // Например, #50E3C2 (Бирюзовый)
      onSecondary: Colors.black,
      secondaryContainer: Color(0xFF70F3D8),
      onSecondaryContainer: Color(0xFF00201A),
      tertiary: Color(0xFF7B5266), // Дополнительный акцентный цвет
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFFFD8E7),
      onTertiaryContainer: Color(0xFF301122),
      error: AppColors.errorBase, // #B00020 (Красный)
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      background: AppColors.backgroundBase, // #F5F5F5 (Светло-серый)
      onBackground: Colors.black,
      surface: AppColors.surfaceBase, // #FFFFFF (Белый)
      onSurface: Colors.black,
      surfaceVariant: Color(0xFFE0E2EC),
      onSurfaceVariant: Color(0xFF43474E),
      outline: Color(0xFF74777F),
      shadow: Colors.black,
      inverseSurface: Color(0xFF2F3033),
      onInverseSurface: Colors.white,
      inversePrimary: Color(0xFF9ACBFF),
      surfaceTint: AppColors.primaryBase,
    );

    // Темная схема
    const ColorScheme darkColorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF9ACBFF), // Светлее для темного фона
      onPrimary: Color(0xFF003259),
      primaryContainer: Color(0xFF00497E),
      onPrimaryContainer: Color(0xFFD0E4FF),
      secondary: Color(0xFF70F3D8), // Ярче на темном фоне
      onSecondary: Color(0xFF00382E),
      secondaryContainer: Color(0xFF005143),
      onSecondaryContainer: Color(0xFF8CFCEE),
      tertiary: Color(0xFFECB8D0),
      onTertiary: Color(0xFF482537),
      tertiaryContainer: Color(0xFF613B4D),
      onTertiaryContainer: Color(0xFFFFD8E7),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFB4AB),
      background: Color(0xFF1A1C1E), // Темно-серый
      onBackground: Color(0xFFE3E2E6),
      surface: Color(0xFF1A1C1E), // Может быть таким же, как фон, или чуть светлее
      onSurface: Color(0xFFE3E2E6),
      surfaceVariant: Color(0xFF43474E),
      onSurfaceVariant: Color(0xFFC3C6CF),
      outline: Color(0xFF8D9199),
      shadow: Colors.black,
      inverseSurface: Color(0xFFE3E2E6),
      onInverseSurface: Color(0xFF1A1C1E),
      inversePrimary: Color(0xFF0061A5),
      surfaceTint: Color(0xFF9ACBFF),
    );

    // Пример кастомной схемы "Ocean Breeze"
    const ColorScheme oceanBreezeColorScheme = ColorScheme(
        brightness: Brightness.light,
        primary: Color(0xFF00695C), // Темно-бирюзовый
        onPrimary: Colors.white,
        primaryContainer: Color(0xFF79DAD1),
        onPrimaryContainer: Color(0xFF00201C),
        secondary: Color(0xFFF9A825), // Солнечно-желтый
        onSecondary: Colors.black,
        // ... заполнить остальные цвета для Ocean Breeze
        // ... (скопируйте из lightColorScheme и адаптируйте)
        error: Colors.redAccent,
        onError: Colors.white,
        background: Color(0xFFE0F2F1), // Очень светло-бирюзовый
        onBackground: Color(0xFF263238), // Темно-серый синий
        surface: Colors.white,
        onSurface: Color(0xFF263238),
        surfaceVariant: Color(0xFFB2DFDB),
        onSurfaceVariant: Color(0xFF004D40),
        outline: Color(0xFF4DB6AC),
        shadow: Colors.black,
        inverseSurface: Color(0xFF263238),
        onInverseSurface: Colors.white,
        inversePrimary: Color(0xFF4DB6AC),
        surfaceTint: Color(0xFF00695C),
        tertiary: Color(0xFFFF7043), // Коралловый
        onTertiary: Colors.white,
        tertiaryContainer: Color(0xFFFFCCBC),
        onTertiaryContainer: Color(0xFFBF360C),
        secondaryContainer: Color(0xFFFFECB3),
        onSecondaryContainer: Color(0xFFC47900),
        errorContainer: Color(0xFFFFCDD2),
        onErrorContainer: Color(0xFFC62828),
    );