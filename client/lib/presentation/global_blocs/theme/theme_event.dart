import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:sigmail_client/presentation/global_blocs/theme/app_theme.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object> get props => [];
}

class LoadTheme extends ThemeEvent {}

class ChangeTheme extends ThemeEvent {
  final AppThemeOption themeOption;

  const ChangeTheme(this.themeOption);

  @override
  List<Object> get props => [themeOption];
}

class ToggleInAppNotifications extends ThemeEvent {
  final bool isEnabled;

  const ToggleInAppNotifications(this.isEnabled);

  @override
  List<Object> get props => [isEnabled];
}

class ToggleSoundEffects extends ThemeEvent {
  final bool isEnabled;

  const ToggleSoundEffects(this.isEnabled);

  @override
  List<Object> get props => [isEnabled];
} 