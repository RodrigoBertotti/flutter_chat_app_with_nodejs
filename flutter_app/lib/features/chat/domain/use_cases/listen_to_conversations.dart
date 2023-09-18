import 'dart:developer';

import 'package:flutter_chat_app_with_mysql/features/chat/domain/repositories/messages_repo.dart';

import '../entities/conversation_entity.dart';



class ListenToConversationsWithMessages {
  final MessagesRepo messagesRepo;
  ListenToConversationsWithMessages({required this.messagesRepo});

  Stream<List<ConversationEntity>> call() {
    log("ListenToConversationsWithMessages called");
    return messagesRepo.conversationsStream();
  }

}