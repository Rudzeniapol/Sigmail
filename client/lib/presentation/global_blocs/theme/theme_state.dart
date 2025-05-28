import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:sigmail_client/presentation/global_blocs/theme/app_theme.dart';

abstract class ThemeState extends Equatable {
  final ThemeData themeData;
  final AppThemeOption currentThemeOption;
  final bool inAppNotificationsEnabled;
  final bool soundEffectsEnabled;

  const ThemeState({
    required this.themeData,
    required this.currentThemeOption,
    this.inAppNotificationsEnabled = true, // Значение по умолчанию
    this.soundEffectsEnabled = false,   // Значение по умолчанию
  });

  @override
  List<Object> get props => [themeData, currentThemeOption, inAppNotificationsEnabled, soundEffectsEnabled];

  ThemeState copyWith({
    ThemeData? themeData,
    AppThemeOption? currentThemeOption,
    bool? inAppNotificationsEnabled,
    bool? soundEffectsEnabled,
  }) {
    // Этот метод не будет напрямую вызываться для создания экземпляров абстрактного класса,
    // но его полезно иметь для конкретных реализаций, если они захотят его использовать.
    // В нашем случае ThemeLoaded будет иметь свой copyWith.
    if (this is ThemeLoaded) {
      return (this as ThemeLoaded).copyWith(
        themeData: themeData,
        currentThemeOption: currentThemeOption,
        inAppNotificationsEnabled: inAppNotificationsEnabled,
        soundEffectsEnabled: soundEffectsEnabled,
      );
    } else if (this is ThemeInitial) {
       return ThemeInitial( // ThemeInitial не должен меняться так просто, он базовый
        // themeData: themeData ?? this.themeData, 
        // currentThemeOption: currentThemeOption ?? this.currentThemeOption, 
        // inAppNotificationsEnabled: inAppNotificationsEnabled ?? this.inAppNotificationsEnabled, 
        // soundEffectsEnabled: soundEffectsEnabled ?? this.soundEffectsEnabled,
       );
    }
    throw UnimplementedError('copyWith not implemented for this state type');
  }
}

class ThemeInitial extends ThemeState {
  ThemeInitial() : super(
    themeData: AppThemes.lightTheme, 
    currentThemeOption: AppThemeOption.system, 
    // Начальные значения для настроек также можно загружать из SharedPreferences в ThemeBloc
    // пока используем значения по умолчанию из конструктора ThemeState
  );
}

class ThemeLoaded extends ThemeState {
  const ThemeLoaded({
    required ThemeData themeData,
    required AppThemeOption themeOption,
    bool inAppNotificationsEnabled = true,
    bool soundEffectsEnabled = false,
  }) : super(
    themeData: themeData, 
    currentThemeOption: themeOption,
    inAppNotificationsEnabled: inAppNotificationsEnabled,
    soundEffectsEnabled: soundEffectsEnabled,
  );

  @override
  ThemeLoaded copyWith({
    ThemeData? themeData,
    AppThemeOption? currentThemeOption,
    bool? inAppNotificationsEnabled,
    bool? soundEffectsEnabled,
  }) {
    return ThemeLoaded(
      themeData: themeData ?? this.themeData,
      themeOption: currentThemeOption ?? this.currentThemeOption,
      inAppNotificationsEnabled: inAppNotificationsEnabled ?? this.inAppNotificationsEnabled,
      soundEffectsEnabled: soundEffectsEnabled ?? this.soundEffectsEnabled,
    );
  }
} 