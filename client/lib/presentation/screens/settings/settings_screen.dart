import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sigmail_client/presentation/global_blocs/theme/app_theme.dart';
import 'package:sigmail_client/presentation/global_blocs/theme/theme_bloc.dart';
import 'package:sigmail_client/presentation/global_blocs/theme/theme_event.dart';
import 'package:sigmail_client/presentation/global_blocs/theme/theme_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          final bool inAppNotificationsEnabled = state.inAppNotificationsEnabled;
          final bool soundEffectsEnabled = state.soundEffectsEnabled;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: <Widget>[
              Text(
                'Appearance',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildThemeSelection(context, state.currentThemeOption),
              const Divider(height: 32, thickness: 1),
              Text(
                'User Experience',
                 style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Enable In-App Notifications'),
                subtitle: const Text('Show notifications within the app'),
                value: inAppNotificationsEnabled,
                onChanged: (bool value) {
                  context.read<ThemeBloc>().add(ToggleInAppNotifications(value));
                },
                secondary: const Icon(Icons.notifications_active_outlined),
              ),
              SwitchListTile(
                title: const Text('Enable Sound Effects'),
                subtitle: const Text('Play sounds for actions like message sent'),
                value: soundEffectsEnabled,
                onChanged: (bool value) {
                  context.read<ThemeBloc>().add(ToggleSoundEffects(value));
                },
                secondary: const Icon(Icons.volume_up_outlined),
              ),
               const Divider(height: 32, thickness: 1),
              Text(
                'Other',
                 style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ListTile(
                title: const Text('About'),
                leading: const Icon(Icons.info_outline),
                onTap: () {
                   showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('About Sigmail'),
                      content: const Text('Sigmail Client v1.0.0\nDeveloped with Flutter.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildThemeSelection(BuildContext context, AppThemeOption currentOption) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: AppThemeOption.values.map((option) {
        return RadioListTile<AppThemeOption>(
          title: Text(option.name),
          value: option,
          groupValue: currentOption,
          onChanged: (AppThemeOption? value) {
            if (value != null) {
              context.read<ThemeBloc>().add(ChangeTheme(value));
            }
          },
          secondary: _getIconForThemeOption(option),
        );
      }).toList(),
    );
  }

  Icon _getIconForThemeOption(AppThemeOption option) {
    switch (option) {
      case AppThemeOption.light:
        return const Icon(Icons.wb_sunny_outlined);
      case AppThemeOption.dark:
        return const Icon(Icons.nightlight_round_outlined);
      case AppThemeOption.system:
      default:
        return const Icon(Icons.settings_system_daydream_outlined);
    }
  }
}
