import 'dart:async';
import 'dart:developer';
import 'package:askless/index.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/data/models/message_model.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/domain/entities/sending_text_message_entity.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/domain/entities/sending_typing_entity.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/domain/entities/message_entity.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/domain/entities/model_source.dart';
import 'package:random_string/random_string.dart';
import 'package:flutter_chat_app_with_mysql/core/domain/entities/failures/failure.dart';
import '../models/sending_text_message_model.dart';
import '../models/sending_typing_model.dart';

class TypingEvent {}

class MessagesRemoteDS {

  MessagesRemoteDS();

  Stream<List<MessageModel>> messagesStream({required int userId}) {
    return AsklessClient.instance.readStream(
        route: 'messages',
        params: {
          "userId": userId
        },
    ).map((event) {
      assert(event != null);
      return (event as List<dynamic>).map((msg) => MessageModel.fromMap(msg, ModelSource.server,)).toList();
    });
  }

  Stream<List<int>> streamConversationsWithUnreceivedMessages () {
    log("conversations-with-unreceived-messages");
    return AsklessClient.instance.readStream(route: 'conversations-with-unreceived-messages',).map((event) => List<int>.from(event));
  }

  Future<DateTime> notifyLoggedUserReadConversation({required int senderUserId, required DateTime lastMessageReadHasBeenReceivedAt}) async {
    final res = await AsklessClient.instance.create(route: 'messages-were-read', body: { "senderUserId": senderUserId, "lastMessageReadHasBeenReceivedAtMsSinceEpoch": lastMessageReadHasBeenReceivedAt.millisecondsSinceEpoch });
    log("notifyLoggedUserReadConversation: ${res.success ? "send successfully" : "failed with code: ${res.error!.code} and description:  ${res.error!.description}"}", );
    if(!res.success){
      throw Failure();
    }
    return DateTime.fromMillisecondsSinceEpoch(res.output["readAtMsSinceEpoch"]);
  }

  Future<void> notifyLoggedUserIsTyping({required SendingTypingEntity data}) async {
    final res = await AsklessClient.instance.create(route: 'user-typed', body: SendingTypingModel.fromEntity(data).toMap());
    log("notifyLoggedUserIsTyping: ${res.success ? "send successfully" : "failed with code: ${res.error!.code} and description:  ${res.error!.description}"}", );
    if(!res.success){
      throw Failure();
    }
  }

  Future<MessageEntity> sendMessage({required SendingMessageEntity message}) async {
    final res = await AsklessClient.instance.create(route: 'message', body: SendingMessageModel.fromEntity(message).toMap(), neverTimeout: true);
    log("sendMessage: ${res.success ? "send successfully" : "failed with code: ${res.error!.code} and description:  ${res.error!.description}"}", );
    if(!res.success){
      throw Failure("Ops! Message couldn't be sent. Please, try again later");
    }
    return MessageModel.fromMap(res.output, ModelSource.server);
  }

  Stream<List<MessageEntity>> messagesWereUpdated({required int userId}) {
    log("messageHasBeenUpdated");
    return AsklessClient.instance.readStream(
      route: 'messages-were-updated',
      params: {
        "userId": userId,
      },
    ).map((message) => MessageModel.fromMapList(message, ModelSource.server));
  }

  Stream<TypingEvent> typingStream({required int typingUserId}) {
    log("typingStream has been called");
    return AsklessClient.instance.readStream(
      route: 'is-typing',
      params: { "typingUserId": typingUserId },
    ).where((event) {
      log("TYPING: $event");
      return event == "TYPING";
    }).map((event) {
      assert(event != null);
      return TypingEvent();
    });
  }

}
