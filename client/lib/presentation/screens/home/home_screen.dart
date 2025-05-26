import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sigmail_client/core/navigation/app_router.dart';
import 'package:sigmail_client/presentation/global_blocs/auth/auth_bloc.dart';
import 'package:sigmail_client/presentation/global_blocs/auth/auth_event.dart';
import 'package:sigmail_client/presentation/global_blocs/auth/auth_state.dart';
import 'package:sigmail_client/presentation/screens/home/chat_list_screen.dart'; // Импорт

class MyHomePage extends StatelessWidget {
  final String title;
  const MyHomePage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        String appBarTitle = title;
        String? userEmail;

        if (state is Authenticated) {
          appBarTitle = state.user.username;
          userEmail = state.user.email;
        }

        // Если пользователь аутентифицирован, показываем ChatListScreen
        // ChatListScreen сам является Scaffold, так что он заменит этот Scaffold
        if (state is Authenticated) {
          return const ChatListScreen();
        }

        // Если не аутентифицирован или идет проверка, показываем стандартный Scaffold
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(appBarTitle),
          ),
          drawer: (state is Authenticated || state is AuthLoading) // Показываем Drawer если есть юзер или грузим
              ? Drawer(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: <Widget>[
                      DrawerHeader(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state is Authenticated ? state.user.username : 'Загрузка...',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
                            ),
                            if (userEmail != null)
                              Text(
                                userEmail,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                              ),
                          ],
                        ),
                      ),
                      if (state is Authenticated)
                        ListTile(
                          leading: const Icon(Icons.logout),
                          title: const Text('Выйти'),
                          onTap: () {
                            context.read<AuthBloc>().add(LogoutRequested());
                            // Navigator.pop(context); // Закрываем Drawer
                            // GoRouter сам обработает редирект на /login после выхода
                          },
                        ),
                      if (state is! Authenticated && state is! AuthLoading) // Если не авторизован и не грузится
                         ListTile(
                          leading: const Icon(Icons.login),
                          title: const Text('Войти'),
                          onTap: () {
                            // context.go(AppRoutes.login); // Используем AppRoutes
                            GoRouter.of(context).go(AppRoutes.login);
                          },
                        ),
                    ],
                  ),
                )
              : null, // Не показываем Drawer, если пользователь точно не аутентифицирован
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (state is AuthLoading || state is AuthInitial) // Если грузится или начальное состояние
                  const CircularProgressIndicator()
                else if (state is Unauthenticated || state is AuthFailure) // Если не аутентифицирован или ошибка
                  // Показываем заглушку или индикатор, ожидая редиректа на LoginScreen
                  const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.transparent)) // Прозрачный, чтобы не было видно, если редирект быстрый
                  // Или можно просто: const SizedBox.shrink() / Container()
                  // Либо оставить текст, но это значит редирект не происходит как надо
                // else if (state is Authenticated) // Этот блок теперь не должен достигаться
                //    Text(
                //     'Добро пожаловать, ${state.user.username}!',
                //   )
                else // Для любых других непредвиденных состояний
                   const Text(
                    'Неизвестное состояние аутентификации.',
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
