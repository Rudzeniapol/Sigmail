import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart'; // Для GoRouter.of(context).go
import 'package:sigmail_client/core/injection_container.dart' as di; // di для Service Locator
import 'package:sigmail_client/core/navigation/app_router.dart';
import 'package:sigmail_client/core/theme/app_theme.dart';
import 'package:sigmail_client/presentation/global_blocs/auth/auth_bloc.dart';
import 'package:sigmail_client/presentation/global_blocs/auth/auth_event.dart';
import 'package:sigmail_client/presentation/global_blocs/auth/auth_state.dart';
import 'package:sigmail_client/presentation/blocs/user_status/user_status_bloc.dart';
import 'package:sigmail_client/data/models/user/user_model.dart'; // Для UserModel

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.initServiceLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    // Получаем AuthBloc из GetIt, чтобы передать его в AppRouter для логики редиректа
    final authBloc = di.sl<AuthBloc>();
    // Создаем экземпляр AppRouter
    final appRouter = AppRouter(authBloc); 

    // Используем MultiBlocProvider для нескольких глобальных BLoC-ов
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => authBloc, // Используем уже созданный authBloc, который был извлечен из sl
        ),
        BlocProvider<UserStatusBloc>(
          create: (context) => di.sl<UserStatusBloc>(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Sigmail Client',
        theme: AppTheme.getThemeData(AppThemeType.light),
        darkTheme: AppTheme.getThemeData(AppThemeType.dark),
        themeMode: ThemeMode.system, // или ThemeMode.light, ThemeMode.dark
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter.router, // Передаем экземпляр router
      ),
    );
  }
}

// MyHomePage был перемещен в presentation/screens/home/home_screen.dart
// Удаляем старый закомментированный код MyHomePage отсюда