import 'dart:async'; // Для StreamSubscription
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sigmail_client/core/injection_container.dart'; // Для sl
// import 'package:sigmail_client/main.dart'; // Удаляем этот импорт MyHomePage
import 'package:sigmail_client/presentation/global_blocs/auth/auth_bloc.dart';
import 'package:sigmail_client/presentation/global_blocs/auth/auth_state.dart';
import 'package:sigmail_client/presentation/screens/auth/login_screen.dart'; // Импорт LoginScreen
import 'package:sigmail_client/presentation/screens/auth/register_screen.dart'; // Импорт RegisterScreen
import 'package:sigmail_client/presentation/screens/home/chat_list_screen.dart'; // Импорт
import 'package:sigmail_client/presentation/screens/home/home_screen.dart'; // Оставляем этот импорт MyHomePage
import 'package:sigmail_client/presentation/screens/chat/chat_screen.dart'; // <--- Добавляем импорт
// import 'package:sigmail_client/presentation/screens/error_screen.dart'; // Для errorBuilder

// TODO: Позже сюда нужно будет добавить импорты для других экранов
// import 'package:sigmail_client/presentation/screens/auth/login_screen.dart';
// import 'package:sigmail_client/presentation/screens/auth/register_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String chatList = '/chats'; // Новый маршрут
  static const String chatMessages = '/chats/:chatId'; // <--- Новый маршрут для сообщений чата
  static const String chatMessagesNamed = 'chatMessages'; // <--- Имя для этого маршрута
  // static const String chatMessagesRoute = '/chat'; // База для /chat/:id
}

// Вспомогательный класс для GoRouter, чтобы слушать Stream от BLoC
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    // notifyListeners(); // Убрал начальный вызов, т.к. redirect и так сработает при инициализации
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class AppRouter {
  final AuthBloc authBloc;
  AppRouter(this.authBloc);

  late final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    initialLocation: AppRoutes.home,
    // Добавляем refreshListenable, чтобы GoRouter реагировал на изменения состояния AuthBloc
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.home,
        builder: (BuildContext context, GoRouterState state) {
          return const MyHomePage(title: 'Sigmail Home');
        },
        // Главная страница (/) может сразу перенаправлять на /chats, если пользователь залогинен
        // Это будет обработано в redirect ниже, но можно и здесь, если нужно.
        // Либо MyHomePage сам решит, что показать (ChatListScreen или экран входа)
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (BuildContext context, GoRouterState state) {
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (BuildContext context, GoRouterState state) {
          return const RegisterScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.chatList, 
        builder: (BuildContext context, GoRouterState state) {
          return const ChatListScreen();
        },
        routes: <RouteBase>[
          GoRoute(
            path: ':chatId', // Будет /chats/:chatId
            name: AppRoutes.chatMessagesNamed, // Имя для context.goNamed
            builder: (BuildContext context, GoRouterState state) {
              final chatId = state.pathParameters['chatId']!;
              // TODO: Передавать не только chatId, но и объект ChatModel или хотя бы имя чата, если нужно
              // Это можно сделать через extra: state.extra as ChatModel (если передавать)
              // Или ChatScreen сам будет загружать детали чата по chatId
              return ChatScreen(chatId: chatId);
            },
          ),
        ],
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final authState = authBloc.state;
      final currentLocation = state.uri.toString(); // Используем uri.toString() для полного пути

      final isAuthenticated = authState is Authenticated;
      // Убрали isAuthenticating из прямой логики редиректа, 
      // т.к. refreshListenable теперь будет реагировать на смену состояний.
      // AuthInitial или AuthLoading на /home будут показывать индикатор в MyHomePage.
      
      final onAuthScreens = currentLocation == AppRoutes.login || currentLocation == AppRoutes.register;

      // Логика редиректа:
      // 1. Если пользователь не аутентифицирован и находится не на экране входа/регистрации,
      //    перенаправляем его на экран входа.
      if (!isAuthenticated && !onAuthScreens) {
        // Если текущее состояние - AuthInitial или AuthLoading, то экран /home (MyHomePage)
        // сам покажет индикатор загрузки. Не нужно редиректить отсюда, чтобы избежать мерцания.
        if (authState is AuthInitial || authState is AuthLoading) {
            return null; // Остаемся на текущем экране, MyHomePage покажет индикатор
        }
        return AppRoutes.login;
      }

      // 2. Если пользователь аутентифицирован и находится на экране входа/регистрации,
      //    перенаправляем его на главный экран.
      if (isAuthenticated && onAuthScreens) {
        return AppRoutes.home; 
      }
      
      // Во всех остальных случаях редирект не нужен.
      return null;
    },
    // errorBuilder: (context, state) => ErrorScreen(error: state.error), // TODO: Создать ErrorScreen
  );
}

// Если решите использовать refreshListenable, нужно обернуть Stream от AuthBloc
// class BlocListenable extends ChangeNotifier {
//   final Stream _stream;
//   late final StreamSubscription _subscription;
// 
//   BlocListenable(this._stream) {
//     _subscription = _stream.listen((_) => notifyListeners());
//   }
// 
//   @override
//   void dispose() {
//     _subscription.cancel();
//     super.dispose();
//   }
// }

// Пример GoRouterObserver для логирования навигации (опционально)
// class GoRouterObserver extendsNavigatorObserver {
//   @override
//   void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
//     print('Pushed: ${route.settings.name}');
//   }
// 
//   @override
//   void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
//     print('Popped: ${route.settings.name}');
//   }
// 
//   @override
//   void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
//     print('Replaced: ${oldRoute?.settings.name} with ${newRoute?.settings.name}');
//   }
// 
//   @override
//   void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
//     print('Removed: ${route.settings.name}');
//   }
// } 