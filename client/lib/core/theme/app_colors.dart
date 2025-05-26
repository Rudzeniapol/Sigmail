    import 'package:flutter/material.dart';

    class AppColors {
      // Базовые цвета, которые могут быть переопределены схемами
      static const Color primaryBase = Color(0xFF6200EE); // Пример
      static const Color secondaryBase = Color(0xFF03DAC6); // Пример
      static const Color backgroundBase = Color(0xFFFFFFFF);
      static const Color surfaceBase = Color(0xFFFFFFFF);
      static const Color errorBase = Color(0xFFB00020);
      // ... и другие базовые цвета

      // Можно определить конкретные цвета для элементов, если они не зависят от схемы
      static const Color onlineIndicator = Colors.green;
      static const Color offlineIndicator = Colors.grey;
    }