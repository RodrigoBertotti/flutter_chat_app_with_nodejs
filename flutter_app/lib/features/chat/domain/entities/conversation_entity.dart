import 'package:flutter_chat_app_with_mysql/features/chat/domain/entities/message_entity.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/domain/entities/user_entity.dart';

class ConversationEntity {
  final UserEntity user;
  final MessageEntity? lastMessage;
  final bool isTyping;
  final int unreadMessagesAmount;

  ConversationEntity({required this.user, this.lastMessage, required this.isTyping, required this.unreadMessagesAmount,});

}