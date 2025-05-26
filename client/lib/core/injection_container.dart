import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigmail_client/core/config/app_config.dart';
import 'package:sigmail_client/core/network/auth_interceptor.dart';
import 'package:sigmail_client/data/data_sources/local/auth_local_data_source.dart';
import 'package:sigmail_client/data/data_sources/remote/auth_remote_data_source.dart';
import 'package:sigmail_client/data/data_sources/remote/chat_remote_data_source.dart';
import 'package:sigmail_client/data/data_sources/realtime/chat_realtime_data_source.dart';
import 'package:sigmail_client/data/data_sources/realtime/user_realtime_data_source.dart';
import 'package:sigmail_client/data/repositories/auth_repository_impl.dart';
import 'package:sigmail_client/data/repositories/chat_repository_impl.dart';
import 'package:sigmail_client/data/repositories/user_repository_impl.dart';
import 'package:sigmail_client/domain/repositories/auth_repository.dart';
import 'package:sigmail_client/domain/repositories/chat_repository.dart';
import 'package:sigmail_client/domain/repositories/user_repository.dart';
import 'package:sigmail_client/domain/use_cases/auth/get_current_user_use_case.dart';
import 'package:sigmail_client/domain/use_cases/auth/login_user_use_case.dart';
import 'package:sigmail_client/domain/use_cases/auth/logout_user_use_case.dart';
import 'package:sigmail_client/domain/use_cases/auth/observe_auth_changes_use_case.dart';
import 'package:sigmail_client/domain/use_cases/auth/register_user_use_case.dart';
import 'package:sigmail_client/domain/use_cases/chat/create_chat_use_case.dart';
import 'package:sigmail_client/domain/use_cases/chat/get_chat_messages_use_case.dart';
import 'package:sigmail_client/domain/use_cases/chat/get_chats_use_case.dart';
import 'package:sigmail_client/domain/use_cases/chat/observe_chat_details_use_case.dart';
import 'package:sigmail_client/domain/use_cases/chat/observe_messages_use_case.dart';
import 'package:sigmail_client/domain/use_cases/chat/send_message_use_case.dart';
import 'package:sigmail_client/domain/use_cases/user/observe_user_status_use_case.dart';
import 'package:sigmail_client/presentation/blocs/chat_list/chat_list_bloc.dart';
import 'package:sigmail_client/presentation/blocs/user_status/user_status_bloc.dart';
import 'package:sigmail_client/presentation/global_blocs/auth/auth_bloc.dart';
import 'package:sigmail_client/presentation/global_blocs/auth/auth_event.dart';
import 'package:sigmail_client/presentation/bloc/typing_status_bloc/typing_status_bloc.dart';
import 'package:sigmail_client/presentation/blocs/message/message_bloc.dart';
import 'package:sigmail_client/domain/use_cases/attachment/get_presigned_upload_url_use_case.dart';
import 'package:sigmail_client/domain/use_cases/attachment/upload_file_to_s3_use_case.dart';
import 'package:sigmail_client/domain/use_cases/attachment/send_message_with_attachment_use_case.dart';

final sl = GetIt.instance; // sl - service locator

Future<void> initServiceLocator() async {
  // В этом методе мы будем регистрировать все зависимости

  // Пример регистрации:
  // sl.registerLazySingleton<MyService>(() => MyServiceImpl());

  // TODO: Регистрация зависимостей для:
  // 1. Core (например, HttpClient, SharedPreferences)
  // 2. Data Sources (локальные и удаленные)
  // 3. Repositories
  // 4. Use Cases
  // 5. BLoCs / Cubits (если они не создаются через BlocProvider в UI)

  // Core
  sl.registerSingletonAsync<SharedPreferences>(() => SharedPreferences.getInstance());
  
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio();
    dio.options.baseUrl = AppConfig.baseUrl;
    dio.options.connectTimeout = const Duration(seconds: 15);
    dio.options.receiveTimeout = const Duration(seconds: 15);
    dio.interceptors.add(AuthInterceptor());
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true, requestHeader: true, responseHeader: true, error: true));
    return dio;
  });

  // Data Sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl<SharedPreferences>()),
  );
  sl.registerLazySingleton<ChatRemoteDataSource>(() => ChatRemoteDataSourceImpl(sl<Dio>()));
  sl.registerLazySingleton<ChatRealtimeDataSource>(() => ChatRealtimeDataSourceImpl());
  await sl.isReady<SharedPreferences>();

  // Регистрация UserRealtimeDataSource
  sl.registerLazySingleton<UserRealtimeDataSource>(() => UserRealtimeDataSourceImpl());

  // Предполагается, что UserRemoteDataSource будет нужен для UserRepository,
  // если нет, то его регистрация и передача в UserRepositoryImpl не нужны.
  // sl.registerLazySingleton<UserRemoteDataSource>(() => UserRemoteDataSourceImpl(sl<Dio>()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSource>(), sl<AuthLocalDataSource>()),
  );
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(
      remoteDataSource: sl<ChatRemoteDataSource>(), 
      realtimeDataSource: sl<ChatRealtimeDataSource>(),
    ),
  );

  // Регистрация UserRepository
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(
      // remoteDataSource: sl<UserRemoteDataSource>(), // УДАЛЯЕМ ПЕРЕДАЧУ ПАРАМЕТРА
      realtimeDataSource: sl<UserRealtimeDataSource>(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => LoginUserUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => RegisterUserUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => LogoutUserUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl<AuthRepository>()));
  sl.registerLazySingleton(() => ObserveAuthChangesUseCase(sl<AuthRepository>()));

  // Chat Use Cases
  sl.registerLazySingleton(() => GetChatsUseCase(sl<ChatRepository>()));
  sl.registerLazySingleton(() => CreateChatUseCase(sl<ChatRepository>()));
  sl.registerLazySingleton(() => GetChatMessagesUseCase(sl<ChatRepository>()));
  sl.registerLazySingleton(() => SendMessageUseCase(sl<ChatRepository>()));
  sl.registerLazySingleton(() => ObserveMessagesUseCase(sl<ChatRepository>()));
  sl.registerLazySingleton(() => ObserveChatDetailsUseCase(sl<ChatRepository>()));

  // Attachment Use Cases
  sl.registerLazySingleton(() => GetPresignedUploadUrlUseCase(sl<ChatRepository>()));
  sl.registerLazySingleton(() => UploadFileToS3UseCase(sl<ChatRepository>()));
  sl.registerLazySingleton(() => SendMessageWithAttachmentUseCase(sl<ChatRepository>()));

  // Регистрация ObserveUserStatusUseCase
  sl.registerLazySingleton(() => ObserveUserStatusUseCase(sl<UserRepository>()));

  // BLoCs / Cubits
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(
      loginUser: sl<LoginUserUseCase>(),
      registerUser: sl<RegisterUserUseCase>(),
      logoutUser: sl<LogoutUserUseCase>(),
      getCurrentUser: sl<GetCurrentUserUseCase>(),
      observeAuthChanges: sl<ObserveAuthChangesUseCase>(),
      userRealtimeDataSource: sl<UserRealtimeDataSource>(), 
      userStatusBloc: sl<UserStatusBloc>(),
    )..add(AuthCheckRequested()),
  );

  sl.registerFactory<ChatListBloc>(
    () => ChatListBloc(
      getChatsUseCase: sl<GetChatsUseCase>(), 
      createChatUseCase: sl<CreateChatUseCase>(), 
      observeChatDetailsUseCase: sl<ObserveChatDetailsUseCase>(),
    ),
  );

  // Регистрация UserStatusBloc
  sl.registerFactory<UserStatusBloc>(
    () => UserStatusBloc(
      observeUserStatusUseCase: sl<ObserveUserStatusUseCase>(),
    ),
  );

  // Регистрация MessageBloc (новая, правильная)
  sl.registerFactoryParam<MessageBloc, String, void>(
    (chatId, _) => MessageBloc(
      chatId: chatId, 
      getChatMessagesUseCase: sl<GetChatMessagesUseCase>(),
      sendMessageUseCase: sl<SendMessageUseCase>(),
      observeMessagesUseCase: sl<ObserveMessagesUseCase>(),
      getPresignedUploadUrlUseCase: sl<GetPresignedUploadUrlUseCase>(),
      uploadFileToS3UseCase: sl<UploadFileToS3UseCase>(),
      sendMessageWithAttachmentUseCase: sl<SendMessageWithAttachmentUseCase>(),
    ),
  );

  // Регистрация TypingStatusBloc (новая, правильная)
  sl.registerFactory<TypingStatusBloc>(
    () => TypingStatusBloc(sl<ChatRealtimeDataSource>()),
  );

  // TODO: Зарегистрировать ChatMessageBloc и т.д. если они появятся
} 