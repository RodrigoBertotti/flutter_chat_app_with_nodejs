


import 'package:flutter_chat_app_with_mysql/features/chat/data/models/message_model.dart';

class LastChatMessagesFromEachUserResult {
  final List<MessageModel> lastMessageList;
  final int unreadMessagesAmount;

  LastChatMessagesFromEachUserResult({required this.lastMessageList, required this.unreadMessagesAmount});
}