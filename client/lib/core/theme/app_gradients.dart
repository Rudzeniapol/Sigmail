    import 'package:flutter/material.dart';

    class AppGradients {
      static const LinearGradient primaryGradient = LinearGradient(
        colors: [Color(0xFF6200EE), Color(0xFF3700B3)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

      static const LinearGradient secondaryGradient = LinearGradient(
        colors: [Color(0xFF03DAC6), Color(0xFF018786)],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      );

      // Градиент для фона сообщений
      static LinearGradient messageBubbleGradient(BuildContext context) {
        final theme = Theme.of(context);
        return LinearGradient(
          colors: [theme.colorScheme.primary.withOpacity(0.8), theme.colorScheme.primaryContainer.withOpacity(0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      }
       // Градиент для фона экранов
      static LinearGradient screenBackground(BuildContext context) {
        final theme = Theme.of(context);
        return LinearGradient(
          colors: [theme.colorScheme.background, theme.colorScheme.surface.withOpacity(0.8)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      }
    }