import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigmail_client/presentation/global_blocs/theme/app_theme.dart';
import 'package:sigmail_client/presentation/global_blocs/theme/theme_event.dart';
import 'package:sigmail_client/presentation/global_blocs/theme/theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final SharedPreferences _prefs;
  static const String _themePrefKey = 'app_theme_option';
  static const String _inAppNotificationsPrefKey = 'in_app_notifications_enabled';
  static const String _soundEffectsPrefKey = 'sound_effects_enabled';

  ThemeBloc(this._prefs) : super(ThemeInitial()) {
    on<LoadTheme>(_onLoadTheme);
    on<ChangeTheme>(_onChangeTheme);
    on<ToggleInAppNotifications>(_onToggleInAppNotifications);
    on<ToggleSoundEffects>(_onToggleSoundEffects);
  }

  void _onLoadTheme(LoadTheme event, Emitter<ThemeState> emit) {
    final String? themeOptionString = _prefs.getString(_themePrefKey);
    AppThemeOption themeOption = AppThemeOption.system;
    if (themeOptionString != null) {
      try {
        themeOption = AppThemeOption.values.firstWhere((e) => e.toString() == themeOptionString);
      } catch (e) {
        // Если сохраненное значение некорректно, используем системную тему
        themeOption = AppThemeOption.system;
      }
    }

    final bool inAppNotificationsEnabled = _prefs.getBool(_inAppNotificationsPrefKey) ?? true; // дефолт true
    final bool soundEffectsEnabled = _prefs.getBool(_soundEffectsPrefKey) ?? false; // дефолт false
    
    emit(_getThemeStateFromOption(themeOption, inAppNotificationsEnabled, soundEffectsEnabled));
  }

  void _onChangeTheme(ChangeTheme event, Emitter<ThemeState> emit) {
    _prefs.setString(_themePrefKey, event.themeOption.toString());
    if (state is ThemeLoaded) {
      final currentLoadedState = state as ThemeLoaded;
      emit(_getThemeStateFromOption(
        event.themeOption, 
        currentLoadedState.inAppNotificationsEnabled, 
        currentLoadedState.soundEffectsEnabled
      ));
    } else { // Если состояние было ThemeInitial
       emit(_getThemeStateFromOption(
        event.themeOption, 
        true, // дефолтное значение из ThemeState
        false // дефолтное значение из ThemeState
      ));
    }
  }

  void _onToggleInAppNotifications(ToggleInAppNotifications event, Emitter<ThemeState> emit) {
    _prefs.setBool(_inAppNotificationsPrefKey, event.isEnabled);
    if (state is ThemeLoaded) {
      emit((state as ThemeLoaded).copyWith(inAppNotificationsEnabled: event.isEnabled));
    } else if (state is ThemeInitial) { // Маловероятно, но для полноты
        final initial = state as ThemeInitial;
         emit(ThemeLoaded(
            themeData: initial.themeData, 
            themeOption: initial.currentThemeOption,
            inAppNotificationsEnabled: event.isEnabled,
            soundEffectsEnabled: initial.soundEffectsEnabled
        ));
    }
  }

  void _onToggleSoundEffects(ToggleSoundEffects event, Emitter<ThemeState> emit) {
    _prefs.setBool(_soundEffectsPrefKey, event.isEnabled);
     if (state is ThemeLoaded) {
      emit((state as ThemeLoaded).copyWith(soundEffectsEnabled: event.isEnabled));
    } else if (state is ThemeInitial) { // Маловероятно, но для полноты
        final initial = state as ThemeInitial;
         emit(ThemeLoaded(
            themeData: initial.themeData, 
            themeOption: initial.currentThemeOption,
            inAppNotificationsEnabled: initial.inAppNotificationsEnabled,
            soundEffectsEnabled: event.isEnabled
        ));
    }
  }

  ThemeState _getThemeStateFromOption(AppThemeOption option, bool inAppNotifications, bool soundEffects) {
    ThemeData themeData;
    switch (option) {
      case AppThemeOption.light:
        themeData = AppThemes.lightTheme;
        break;
      case AppThemeOption.dark:
        themeData = AppThemes.darkTheme;
        break;
      case AppThemeOption.system:
      default:
        // Для системной темы, мы должны слушать изменения системной темы.
        // Пока что, для простоты, системная тема будет использовать светлую.
        // В реальном приложении здесь нужно было бы использовать WidgetsBinding.instance.window.platformBrightness
        // и обновлять тему при его изменении.
        // Однако, MaterialApp сам умеет это делать, если themeMode = ThemeMode.system.
        // Поэтому, когда выбран system, мы можем вернуть одну из тем, а MaterialApp разберется.
        // Либо, ThemeLoaded может хранить ThemeMode.
        // Пока просто вернем светлую, а MaterialApp будет переключать.
        themeData = AppThemes.lightTheme; 
    }
    return ThemeLoaded(
      themeData: themeData, 
      themeOption: option,
      inAppNotificationsEnabled: inAppNotifications,
      soundEffectsEnabled: soundEffects,
    );
  }
} 