import 'package:flutter_chat_app_with_mysql/core/data/data_sources/connection_remote_ds.dart';
import 'package:flutter_chat_app_with_mysql/core/data/data_sources/hive_box_instance.dart';
import 'package:flutter_chat_app_with_mysql/core/data/data_sources/users_local_ds.dart';
import 'package:flutter_chat_app_with_mysql/core/data/repositories/connection_repo_impl.dart';
import 'package:flutter_chat_app_with_mysql/core/domain/repositories/connection_repo.dart';
import 'package:flutter_chat_app_with_mysql/core/domain/use_cases/initialize_app.dart';
import 'package:flutter_chat_app_with_mysql/core/data/data_sources/auth_local_ds.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/data/data_sources/messages_local_ds.dart';
import 'package:flutter_chat_app_with_mysql/features/login_and_registration/data/data_sources/auth_remote_ds.dart';
import 'package:flutter_chat_app_with_mysql/features/login_and_registration/domain/use_cases/login.dart';
import 'package:flutter_chat_app_with_mysql/features/login_and_registration/domain/use_cases/register.dart';
import 'package:get_it/get_it.dart';
import 'core/domain/use_cases/stream_connection_changes.dart';
import 'features/chat/data/data_sources/messages_remote_ds.dart';
import 'core/data/data_sources/users_remote_ds.dart';
import 'features/chat/data/repositories/messages_repo_impl.dart';
import 'core/data/repositories/users_repo_impl.dart';
import 'core/domain/repositories/auth_repo.dart';
import 'features/chat/domain/repositories/messages_repo.dart';
import 'core/domain/repositories/users_repo.dart';
import 'features/chat/domain/use_cases/listen_to_conversations.dart';
import 'features/chat/domain/use_cases/messages_stream.dart';
import 'features/chat/domain/use_cases/notify_logged_user_is_typing.dart';
import 'core/domain/use_cases/stream_users_to_talk.dart';
import 'features/chat/domain/use_cases/send_message.dart';
import 'core/data/repositories/auth_repo_impl.dart';
import 'core/domain/use_cases/logout.dart';
import 'environment.dart' as environment;

/// Service locator
final getIt = GetIt.instance;

void init () {
  getIt.registerLazySingleton(() => HiveBoxInstance(localStorageEncryptionKey: environment.localStorageEncryptionKey));
  getIt.registerLazySingleton(() => UsersRemoteDS());
  getIt.registerLazySingleton(() => MessagesRemoteDS());
  getIt.registerLazySingleton(() => AuthLocalDS(hiveBoxInstance: getIt.get<HiveBoxInstance>()));
  getIt.registerLazySingleton(() => AuthRemoteDS());
  getIt.registerLazySingleton(() => ConnectionRemoteDS());
  getIt.registerLazySingleton(() => MessagesLocalDS(hiveBoxInstance: getIt.get<HiveBoxInstance>(), authLocalDS: getIt.get<AuthLocalDS>()));
  getIt.registerLazySingleton(() => UsersLocalDS(hiveBoxInstance: getIt.get<HiveBoxInstance>()));

  getIt.registerLazySingleton<MessagesRepo>(() => MessagesRepoImpl(usersRepository: getIt.get<UsersRepo>(), authRepo: getIt.get<AuthRepo>(), messagesLocalDataSource: getIt.get<MessagesLocalDS>(), messagesRemoteDataSource: getIt.get<MessagesRemoteDS>()));
  getIt.registerLazySingleton<UsersRepo>(() => UsersRepoImpl(usersRemoteDataSource: getIt.get<UsersRemoteDS>(), usersLocalDatasource: getIt.get<UsersLocalDS>()));
  getIt.registerLazySingleton<AuthRepo>(() => AuthRepoImpl(authLocalDS: getIt.get<AuthLocalDS>(), authRemoteDS: getIt.get<AuthRemoteDS>()));
  getIt.registerLazySingleton<ConnectionRepo>(() => ConnectionRepoImpl(connectionRemoteDS: getIt.get<ConnectionRemoteDS>()));

  getIt.registerLazySingleton<InitializeApp>(() => InitializeApp(authRepo: getIt.get<AuthRepo>(), hiveBoxInstance: getIt.get<HiveBoxInstance>(), messagesRepo: getIt.get<MessagesRepo>(), connectionRepo: getIt.get<ConnectionRepo>()));
  getIt.registerLazySingleton<ListenToConversationsWithMessages>(() => ListenToConversationsWithMessages(messagesRepo: getIt.get<MessagesRepo>()));
  getIt.registerLazySingleton<MessagesStream>(() => MessagesStream(messagesRepository: getIt.get<MessagesRepo>()));
  getIt.registerLazySingleton<NotifyLoggedUserIsTyping>(() => NotifyLoggedUserIsTyping(messagesRepository: getIt.get<MessagesRepo>()));
  getIt.registerLazySingleton<UsersToTalkTo>(() => UsersToTalkTo(usersRepository: getIt.get<UsersRepo>()));
  getIt.registerLazySingleton<SendMessage>(() => SendMessage(messagesRepository: getIt.get<MessagesRepo>()));
  getIt.registerLazySingleton<Login>(() => Login(authRepository: getIt.get<AuthRepo>(), messagesRepository: getIt.get<MessagesRepo>()));
  getIt.registerLazySingleton<Logout>(() => Logout(authRepository: getIt.get<AuthRepo>(), messagesRepository: getIt.get<MessagesRepo>()));
  getIt.registerLazySingleton<Register>(() => Register(usersRepository: getIt.get<UsersRepo>()));
  getIt.registerLazySingleton<StreamConnectionChanges>(() => StreamConnectionChanges(connectionChangesRepo: getIt.get<ConnectionRepo>()));
}

