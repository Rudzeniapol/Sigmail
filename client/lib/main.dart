import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sigmail_client/core/injection_container.dart' as di;
import 'package:sigmail_client/core/navigation/app_router.dart';
import 'package:sigmail_client/presentation/global_blocs/theme/app_theme.dart';
import 'package:sigmail_client/presentation/global_blocs/theme/theme_bloc.dart';
import 'package:sigmail_client/presentation/global_blocs/theme/theme_state.dart';
import 'package:sigmail_client/presentation/global_blocs/auth/auth_bloc.dart';
import 'package:sigmail_client/presentation/global_blocs/auth/auth_event.dart';
import 'package:sigmail_client/presentation/global_blocs/auth/auth_state.dart';
import 'package:sigmail_client/presentation/blocs/user_status/user_status_bloc.dart';
import 'package:sigmail_client/data/models/user/user_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await di.init();
  // await di.sl<UserRealtimeDataSource>().init(); // Временно закомментировано
  // await di.sl<ChatRealtimeDataSource>().init(); // Временно закомментировано
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authBloc = di.sl<AuthBloc>();
    final appRouter = AppRouter(authBloc);

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => authBloc,
        ),
        BlocProvider<UserStatusBloc>(
          create: (context) => di.sl<UserStatusBloc>(),
        ),
        BlocProvider<ThemeBloc>(
          create: (context) => di.sl<ThemeBloc>(),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          ThemeMode themeMode;
          switch (themeState.currentThemeOption) {
            case AppThemeOption.light:
              themeMode = ThemeMode.light;
              break;
            case AppThemeOption.dark:
              themeMode = ThemeMode.dark;
              break;
            case AppThemeOption.system:
            default:
              themeMode = ThemeMode.system;
              break;
          }

          return MaterialApp.router(
            title: 'Sigmail Client',
            theme: AppThemes.lightTheme, 
            darkTheme: AppThemes.darkTheme, 
            themeMode: themeMode, 
            debugShowCheckedModeBanner: false,
            routerConfig: appRouter.router, 
          );
        },
      ),
    );
  }
}

// MyHomePage был перемещен в presentation/screens/home/home_screen.dart
// Удаляем старый закомментированный код MyHomePage отсюда