import 'package:flutter_chat_app_with_mysql/features/chat/domain/entities/chat_content_entity.dart';

import '../repositories/messages_repo.dart';


class MessagesStream {
  final MessagesRepo messagesRepository;

  MessagesStream({required this.messagesRepository});

  Stream<ChatContentEntity> call({required int userId}) {
    return messagesRepository.messagesStream(userId: userId);
  }

}