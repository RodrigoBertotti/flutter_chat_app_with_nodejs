



import 'package:flutter_chat_app_with_mysql/features/chat/domain/entities/message_entity.dart';

class ChatListItemEntity {

}

class SeparatorDateForMessages extends ChatListItemEntity {
  DateTime date;

  SeparatorDateForMessages({required this.date});

}

class MessageChatListItemEntity extends ChatListItemEntity {
  final MessageEntity message;

  MessageChatListItemEntity({required this.message});

}

class TypingIndicatorChatListItemEntity extends ChatListItemEntity {

}