import 'dart:async';
import 'dart:developer';
import 'package:flutter_chat_app_with_mysql/features/chat/data/utils.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/domain/entities/chat_content_entity.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/domain/entities/chat_list_item_entity.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/domain/entities/message_entity.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/domain/repositories/messages_repo.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/domain/use_cases/messages_stream.dart';
import 'package:flutter_chat_app_with_mysql/core/domain/repositories/auth_repo.dart';
import 'package:flutter_chat_app_with_mysql/injection_container.dart';



class RealtimeChatPageController {
  final int userId;

  RealtimeChatPageController({required this.userId});

  Stream<List<ChatListItemEntity>> streamChatItems () {
    log("streamChatItems called");
    late StreamSubscription<ChatContentEntity> listening;
    final newController = StreamController<List<ChatListItemEntity>>(onCancel: () {
      log("newController onCancel called");
      try {
        listening.cancel();
      } catch (e) {
        log("chatItemsStream: cancel failed: ${e.toString()}");
      }
    },);
    listening = getIt.get<MessagesStream>().call(userId: userId).listen((chatContent) async {
      final loggedUserId = getIt.get<AuthRepo>().loggedUserId;
      final hasUnreadMessages = chatContent.messages.any((element) => element.readAt == null && element.receiverUserId == loggedUserId);
      if (hasUnreadMessages) {
        await getIt.get<MessagesRepo>().notifyLoggedUserReadConversation(userId: userId,);
      }

      chatContent.messages.sort((a, b) {
        if (a.createdAt.millisecondsSinceEpoch < b.createdAt.millisecondsSinceEpoch){
          return -1;
        }
        return 1;
      });

      final List<ChatListItemEntity> result = [];
      for (int i=0; i < chatContent.messages.length; i++) {
        final currentMessage = chatContent.messages[i];
        if (currentMessage.sentAt != null) {
          final messageBeforeCurrent = i == 0 ? null : chatContent.messages[i - 1];
          if (messageBeforeCurrent == null || (messageBeforeCurrent.sentAt != null && isDifferentDay(currentMessage.sentAt!, messageBeforeCurrent.sentAt!))) {
            result.add(SeparatorDateForMessages(date: currentMessage.sentAt!));
          }
        }
        result.add(MessageChatListItemEntity(message: currentMessage));
      }
      if (chatContent.isTyping) {
        result.add(TypingIndicatorChatListItemEntity());
      }
      newController.add(result);
    }, onDone: () {
      log("RealtimeChatPageController: closing controller (onDone)");
      if(!newController.isClosed) {
        newController.close();
      }
    });
    
    return newController.stream;
  }

}