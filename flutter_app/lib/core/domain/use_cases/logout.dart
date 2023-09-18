import 'package:flutter_chat_app_with_mysql/features/chat/domain/repositories/messages_repo.dart';
import 'package:flutter_chat_app_with_mysql/core/domain/repositories/auth_repo.dart';


class Logout {
  final AuthRepo authRepository;
  final MessagesRepo messagesRepository;

  Logout({required this.authRepository, required this.messagesRepository,});

  Future<void> call () async {
    await authRepository.logout();
  }

}