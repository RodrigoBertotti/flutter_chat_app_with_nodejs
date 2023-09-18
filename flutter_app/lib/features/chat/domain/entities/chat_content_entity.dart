import 'package:flutter_chat_app_with_mysql/features/chat/domain/entities/message_entity.dart';


class ChatContentEntity {
  final List<MessageEntity> messages;
  final bool isTyping;

  ChatContentEntity({required this.messages, required this.isTyping});

}