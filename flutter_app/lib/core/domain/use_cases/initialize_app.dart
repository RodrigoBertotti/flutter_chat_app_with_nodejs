import 'package:flutter_chat_app_with_mysql/core/data/data_sources/hive_box_instance.dart';
import 'package:flutter_chat_app_with_mysql/core/domain/repositories/connection_repo.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/domain/repositories/messages_repo.dart';
import 'package:flutter_chat_app_with_mysql/core/domain/repositories/auth_repo.dart';

class InitializeApp {
  final HiveBoxInstance hiveBoxInstance;
  final MessagesRepo messagesRepo;
  final AuthRepo authRepo;
  final ConnectionRepo connectionRepo;
  bool _initialized = false;

  InitializeApp({required this.hiveBoxInstance, required this.connectionRepo, required this.messagesRepo, required this.authRepo});

  Future<void> start({required void Function() onAutoReauthenticationFails}) async {
    if (!_initialized) {
      _initialized = true;
      await hiveBoxInstance.initialize();

      connectionRepo.start(onAutoReauthenticationFails: onAutoReauthenticationFails);
      authRepo.start(onAutoReauthenticationFails: onAutoReauthenticationFails);
      authRepo.addOnLoggedInListener(() {
        messagesRepo.start();
      });
      authRepo.addOnLogoutListener(() {
        messagesRepo.close();
      });
    }
  }

}
