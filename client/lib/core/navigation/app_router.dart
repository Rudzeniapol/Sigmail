import 'dart:async'; // Для StreamSubscription
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
// import 'package:sigmail_client/core/injection_container.dart'; // Убираем sl, если AuthNavigationCubit не используется
// import 'package:sigmail_client/main.dart'; // Удаляем этот импорт MyHomePage
import 'package:sigmail_client/data/models/chat/chat_model.dart';
import 'package:sigmail_client/presentation/global_blocs/auth/auth_bloc.dart';
import 'package:sigmail_client/presentation/global_blocs/auth/auth_state.dart';
// import 'package:sigmail_client/presentation/blocs/auth_navigation_cubit.dart'; // УДАЛЯЕМ ЭТОТ ИМПОРТ
import 'package:sigmail_client/presentation/screens/auth/login_screen.dart'; // Импорт LoginScreen
import 'package:sigmail_client/presentation/screens/auth/register_screen.dart'; // Импорт RegisterScreen
import 'package:sigmail_client/presentation/screens/home/chat_list_screen.dart'; // Импорт
import 'package:sigmail_client/presentation/screens/home/home_screen.dart'; // Оставляем этот импорт MyHomePage
import 'package:sigmail_client/presentation/screens/chat/chat_screen.dart'; // <--- Добавляем импорт
import 'package:sigmail_client/presentation/screens/profile/profile_screen.dart'; // Импорт экрана профиля
import 'package:sigmail_client/presentation/screens/settings/settings_screen.dart'; // Импорт экрана настроек
import 'package:sigmail_client/presentation/widgets/main_scaffold_with_bottom_nav.dart'; // Импорт нашего нового shell-виджета
import 'package:sigmail_client/presentation/screens/splash_screen.dart';
// import 'package:sigmail_client/presentation/screens/error_screen.dart'; // Для errorBuilder

// TODO: Позже сюда нужно будет добавить импорты для других экранов
// import 'package:sigmail_client/presentation/screens/auth/login_screen.dart';
// import 'package:sigmail_client/presentation/screens/auth/register_screen.dart';

// Для ShellRoute
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell'); // Для старого ShellRoute, если он был

// Для StatefulShellRoute нам понадобятся ключи для каждой ветки навигации
final GlobalKey<NavigatorState> _chatsTabNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'chatsTab');
final GlobalKey<NavigatorState> _profileTabNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'profileTab');
final GlobalKey<NavigatorState> _settingsTabNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'settingsTab');

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  
  // Маршруты для вкладок
  static const String chats = '/chats'; // Это будет корневой путь для первой вкладки
  static const String chatMessages = '/chats/:chatId'; // Дочерний маршрут для чатов
  static const String chatMessagesNamed = 'chatMessages'; // Имя для удобной навигации

  static const String profile = '/profile'; // Корневой путь для второй вкладки
  static const String settings = '/settings'; // Корневой путь для третьей вкладки

  // Добавляем имя для корневого маршрута вкладок, чтобы на него можно было переходить
  static const String homeShell = '/shell'; // Можно назвать как угодно, например /home
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

  AppRouter(this.authBloc); // Конструктор обновлен, navigatorKey УДАЛЕН

  GoRouter get router => _router;

  late final GoRouter _router = GoRouter(
    navigatorKey: _rootNavigatorKey, // Используем _rootNavigatorKey по умолчанию
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      // Новый StatefulShellRoute для основной навигации с вкладками
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: _rootNavigatorKey, // Используем _rootNavigatorKey, чтобы он был выше по стеку, чем login/register
        builder: (context, state, navigationShell) {
          // Возвращаем наш виджет-обертку с BottomNavigationBar
          return MainScaffoldWithBottomNav(navigationShell: navigationShell);
        },
        branches: <StatefulShellBranch>[
          // Ветка для Чатов
          StatefulShellBranch(
            navigatorKey: _chatsTabNavigatorKey,
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.chats,
                builder: (context, state) => const ChatListScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    name: AppRoutes.chatMessagesNamed, // Имя маршрута для удобной навигации
                    path: ':chatId', // Относительный путь, будет /chats/:chatId
                    builder: (context, state) {
                      final chatId = state.pathParameters['chatId']!;
                      final chatModel = state.extra as ChatModel?;

                      if (chatModel == null) {
                        // TODO: Обработать ситуацию, когда chatModel не передан
                        // Можно, например, вернуться назад или показать экран ошибки
                        // Или загрузить ChatModel по chatId здесь, если это необходимо
                        // Пока просто вернем заглушку или вызовем print
                        print('Error: ChatModel not provided for chat screen with ID: $chatId');
                        // return const Scaffold(body: Center(child: Text('Ошибка: Чат не найден')));
                        // Временное решение - возвращаем заглушку, но это нужно исправить
                        // Лучше всего, чтобы ChatListScreen всегда передавал ChatModel.
                        // Если это критично, можно сделать assert(chatModel != null);
                        // или выбросить исключение, или перенаправить на экран ошибки.
                        // Пока для простоты, если модель не пришла, возможно, стоит сделать
                        // заглушку ChatModel с текущим chatId и типом, например, private (чтобы экран не падал)
                        // но это плохая практика.
                        // Правильнее всего - обеспечить передачу.
                        // Если уж совсем никак, то нужно будет в ChatScreen иметь логику загрузки ChatModel по ID.
                        return ChatScreen(chat: ChatModel(id: chatId, type: ChatTypeModel.private, creatorId: '', createdAt: DateTime.now())); // ВРЕМЕННАЯ ЗАГЛУШКА
                      }
                      return ChatScreen(chat: chatModel);
                    },
                  ),
                ],
              ),
            ],
          ),
          // Ветка для Профиля
          StatefulShellBranch(
            navigatorKey: _profileTabNavigatorKey,
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
          // Ветка для Настроек
          StatefulShellBranch(
            navigatorKey: _settingsTabNavigatorKey,
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      // Получаем состояние напрямую из authBloc, переданного в конструктор AppRouter
      final currentAuthState = authBloc.state; 
      final bool isAuthenticated = currentAuthState is Authenticated;
      // Предполагаем, что AuthLoading или AuthInitial могут считаться isAuthenticating
      final bool isAuthenticating = currentAuthState is AuthLoading || currentAuthState is AuthInitial;
      
      final String location = state.matchedLocation; 

      print('[GoRouter-Redirect] Location: $location, AuthState: ${currentAuthState.runtimeType}, isAuthenticated: $isAuthenticated, isAuthenticating: $isAuthenticating');

      if (isAuthenticating && location != AppRoutes.splash) { // Если аутентификация в процессе и мы не на сплэше
        // Можно добавить явный редирект на сплэш, если это не обрабатывается начальной загрузкой
        // или если хотим быть уверены, что пользователь видит сплэш в этот момент.
        // Однако, если initialLocation = AppRoutes.splash, это может быть избыточным.
        // print('[GoRouter-Redirect] Authenticating, ensuring splash screen. current $location');
        // return AppRoutes.splash; 
      }

      final bool isOnAuthScreens = location == AppRoutes.login || location == AppRoutes.register;
      final bool isOnProtectedShell = location == AppRoutes.chats || 
                                    location == AppRoutes.profile || 
                                    location == AppRoutes.settings ||
                                    location.startsWith(AppRoutes.chats + '/') || 
                                    location.startsWith(AppRoutes.profile + '/') || 
                                    location.startsWith(AppRoutes.settings + '/'); 

      if (!isAuthenticated && !isAuthenticating) { // Только если аутентификация завершилась и неуспешна
        if (isOnProtectedShell) { // Если пытаемся попасть на защищенный экран
            print('[GoRouter-Redirect] Not authenticated (and not authenticating), redirecting from $location to Login.');
            return AppRoutes.login;
        }
        // Если мы на сплэше и не аутентифицированы (и не в процессе), тоже на логин
        if (location == AppRoutes.splash) {
             print('[GoRouter-Redirect] Not authenticated (and not authenticating) on Splash, redirecting to Login.');
            return AppRoutes.login;
        }
      } else if (isAuthenticated) { // Если аутентифицирован
        if (isOnAuthScreens || location == AppRoutes.splash) { 
          print('[GoRouter-Redirect] Authenticated, redirecting from $location to Chats.');
          return AppRoutes.chats; 
        }
      }
      print('[GoRouter-Redirect] No redirect needed for $location.');
      return null; 
    },
    // Возвращаем GoRouterRefreshStream для прослушивания AuthBloc
    refreshListenable: GoRouterRefreshStream(authBloc.stream), 
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