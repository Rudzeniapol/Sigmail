import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigmail_client/core/config/app_config.dart';
import 'package:sigmail_client/core/network/auth_interceptor.dart';
import 'package:sigmail_client/core/network/dio_client.dart';
import 'package:sigmail_client/core/network/network_info.dart';
import 'package:sigmail_client/core/network/network_info_impl.dart';
import 'package:sigmail_client/data/data_sources/local/auth_local_data_source.dart';
// import 'package:sigmail_client/data/data_sources/local/settings_local_data_source.dart'; // Файл не найден
import 'package:sigmail_client/data/data_sources/remote/auth_remote_data_source.dart';
import 'package:sigmail_client/data/data_sources/remote/chat_remote_data_source.dart';
// import 'package:sigmail_client/data/data_sources/remote/message_remote_data_source.dart'; // Файл не найден
import 'package:sigmail_client/data/data_sources/profile/profile_remote_data_source.dart';
import 'package:sigmail_client/data/data_sources/profile/profile_remote_data_source_impl.dart';
import 'package:sigmail_client/data/data_sources/realtime/chat_realtime_data_source.dart';
import 'package:sigmail_client/data/data_sources/realtime/user_realtime_data_source.dart';
import 'package:sigmail_client/data/repositories/auth_repository_impl.dart';
import 'package:sigmail_client/data/repositories/chat_repository_impl.dart';
import 'package:sigmail_client/data/repositories/profile_repository_impl.dart';
import 'package:sigmail_client/data/repositories/user_repository_impl.dart';
import 'package:sigmail_client/domain/repositories/auth_repository.dart';
import 'package:sigmail_client/domain/repositories/chat_repository.dart';
import 'package:sigmail_client/domain/repositories/profile_repository.dart';
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
import 'package:sigmail_client/domain/use_cases/message/add_reaction_use_case.dart';
import 'package:sigmail_client/domain/use_cases/message/remove_reaction_use_case.dart';
import 'package:sigmail_client/domain/use_cases/user/observe_user_status_use_case.dart';
import 'package:sigmail_client/domain/use_cases/attachment/get_presigned_upload_url_use_case.dart';
import 'package:sigmail_client/domain/use_cases/attachment/upload_file_to_s3_use_case.dart';
import 'package:sigmail_client/domain/use_cases/attachment/send_message_with_attachment_use_case.dart';
import 'package:sigmail_client/presentation/blocs/chat_list/chat_list_bloc.dart';
import 'package:sigmail_client/presentation/blocs/message/message_bloc.dart';
import 'package:sigmail_client/presentation/blocs/user_status/user_status_bloc.dart';
import 'package:sigmail_client/presentation/global_blocs/auth/auth_bloc.dart';
import 'package:sigmail_client/presentation/blocs/profile/profile_bloc.dart';
import 'package:sigmail_client/presentation/global_blocs/theme/theme_bloc.dart';
import 'package:sigmail_client/data/data_sources/remote/user_remote_data_source.dart';
import 'package:sigmail_client/presentation/bloc/typing_status_bloc/typing_status_bloc.dart';
import 'package:sigmail_client/presentation/blocs/user_search/user_search_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Blocs
  sl.registerFactory(() => AuthBloc(
        loginUser: sl(),
        registerUser: sl(),
        logoutUser: sl(),
        getCurrentUser: sl(),
        observeAuthChanges: sl(),
        userRealtimeDataSource: sl(),
        userStatusBloc: sl(),
      ));
  sl.registerFactory(() => ChatListBloc(
      getChatsUseCase: sl(),
      createChatUseCase: sl(),
      observeChatDetailsUseCase: sl(),
      ));
  sl.registerFactoryParam<MessageBloc, String, void>(
      (chatId, _) => MessageBloc(
          chatId: chatId,
          getChatMessagesUseCase: sl(),
          sendMessageUseCase: sl(),
          observeMessagesUseCase: sl(),
          getPresignedUploadUrlUseCase: sl(),
          uploadFileToS3UseCase: sl(),
          sendMessageWithAttachmentUseCase: sl(),
          addReactionUseCase: sl(),
          removeReactionUseCase: sl(),
          chatRepository: sl(),
      ));
  sl.registerFactory(() => ThemeBloc(sl())); 
  sl.registerFactory(() => UserStatusBloc(observeUserStatusUseCase: sl()));
  sl.registerFactory(() => ProfileBloc(profileRepository: sl(), authBloc: sl()));
  sl.registerLazySingleton(() => TypingStatusBloc(sl()));
  sl.registerFactory(() => UserSearchBloc(userRepository: sl()));

  // Use cases
  sl.registerLazySingleton(() => LoginUserUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUserUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUserUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => ObserveAuthChangesUseCase(sl()));
  sl.registerLazySingleton(() => GetChatsUseCase(sl())); 
  sl.registerLazySingleton(() => CreateChatUseCase(sl()));
  sl.registerLazySingleton(() => SendMessageUseCase(sl()));
  sl.registerLazySingleton(() => ObserveMessagesUseCase(sl()));
  sl.registerLazySingleton(() => GetChatMessagesUseCase(sl()));
  sl.registerLazySingleton(() => ObserveChatDetailsUseCase(sl()));
  sl.registerLazySingleton(() => AddReactionUseCase(sl()));
  sl.registerLazySingleton(() => RemoveReactionUseCase(sl()));
  sl.registerLazySingleton(() => ObserveUserStatusUseCase(sl()));
  sl.registerLazySingleton(() => GetPresignedUploadUrlUseCase(sl()));
  sl.registerLazySingleton(() => UploadFileToS3UseCase(sl()));
  sl.registerLazySingleton(() => SendMessageWithAttachmentUseCase(sl()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl(), sl())); 
  sl.registerLazySingleton<ChatRepository>(
    () => ChatRepositoryImpl(remoteDataSource: sl(), realtimeDataSource: sl()), 
  );
  sl.registerLazySingleton<IProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(remoteDataSource: sl(), realtimeDataSource: sl(), authLocalDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(sl()));
  sl.registerLazySingleton<AuthLocalDataSource>(() => AuthLocalDataSourceImpl(sl()));
  sl.registerLazySingleton<ChatRemoteDataSource>(() => ChatRemoteDataSourceImpl(sl()));
  // sl.registerLazySingleton<IMessageRemoteDataSource>(() => MessageRemoteDataSourceImpl(dio: sl())); // Файл не найден
  // sl.registerLazySingleton<ISettingsLocalDataSource>(() => SettingsLocalDataSourceImpl(sharedPreferences: sl())); // Файл не найден
  sl.registerLazySingleton<IProfileRemoteDataSource>(() => ProfileRemoteDataSourceImpl(dio: sl<Dio>()));
  sl.registerLazySingleton<UserRemoteDataSource>(() => UserRemoteDataSourceImpl(sl()));
  
  // Realtime DataSources
  sl.registerLazySingleton<ChatRealtimeDataSource>(() => ChatRealtimeDataSourceImpl()); 
  sl.registerLazySingleton<UserRealtimeDataSource>(() => UserRealtimeDataSourceImpl(hubUrl: AppConfig.userHubUrl));

  // Core
  sl.registerLazySingleton<AuthInterceptor>(() => AuthInterceptor());
  sl.registerLazySingleton<INetworkInfo>(() => NetworkInfoImpl(connectivity: sl()));
  sl.registerLazySingleton(() => DioClient(AppConfig.baseUrl, sl()).dio); 

  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => Connectivity());
} 