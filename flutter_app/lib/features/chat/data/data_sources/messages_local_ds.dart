import 'dart:async';
import 'package:askless/domain/utils/logger.dart';
import 'package:flutter_chat_app_with_mysql/core/data/data_sources/auth_local_ds.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/data/models/message_model.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/domain/entities/message_entity.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/domain/entities/model_source.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/domain/entities/pending_request_to_api_telling_message_was_read.dart';
import '../../../../core/data/data_sources/hive_box_instance.dart';

class MessagesLocalDS {
  static const _kMessages = "messages";
  static const _kPendingRequestListToApiTellingMessagesWereRead = "pendingRequestListToApiTellingMessagesWereRead";

  late final HiveBoxInstance _hive;
  AuthLocalDS authLocalDS;

  MessagesLocalDS({required HiveBoxInstance hiveBoxInstance, required this.authLocalDS}) {
    _hive = hiveBoxInstance;
  }

  List<MessageEntity> getMessages({required int userId}) {
    return _getAllMessages().where((message) => message.senderUserId == userId || message.receiverUserId == userId).toList();
  }

  List<MessageModel> _getAllMessages() {
    return MessageModel.fromMapList(_hive.box.get(_kMessages), ModelSource.localStorage)..sort((a,b) {
      return a.createdAt.compareTo(b.createdAt);
    });
  }

  Future<void> putPendingRequestToApiTellingMessageWasRead({required int senderUserId, required DateTime dateTime}) async {
    final Map<int, int> obj = Map<int, int>.from( _hive.box.get(_kPendingRequestListToApiTellingMessagesWereRead, defaultValue: <int, int>{}));
    obj[senderUserId] = dateTime.millisecondsSinceEpoch;
    await _hive.box.put(_kPendingRequestListToApiTellingMessagesWereRead, obj);
  }
  Future<void> removePendingRequestToApiTellingMessageWasRead({required int senderUserId}) async {
    final Map<int, int> obj = Map<int, int>.from(_hive.box.get(_kPendingRequestListToApiTellingMessagesWereRead, defaultValue: <int, int>{}));
    obj.remove(senderUserId);
    await _hive.box.put(_kPendingRequestListToApiTellingMessagesWereRead, obj);
  }

  Future<List<PendingRequestToApiTellingMessagesWasRead>> getPendingRequestListToApiTellingMessagesWereRead() async {
    final List<PendingRequestToApiTellingMessagesWasRead> res = [];
    final obj = Map<int, int>.from(_hive.box.get(_kPendingRequestListToApiTellingMessagesWereRead, defaultValue: <int, int>{}));
    for (final int senderUserId in obj.keys) {
      final dateTime = DateTime.fromMillisecondsSinceEpoch(obj[senderUserId]!);
      res.add(PendingRequestToApiTellingMessagesWasRead(dateTime: dateTime, senderUserId: senderUserId));
    }
    return res;
  }

  /// Adds or updates a list of messages, keeping the others unchanged
  Future<void> putMessageList({required Iterable<MessageEntity> messageList}) async {
    final currentSavedMessages = _getAllMessages();
    for(final MessageModel ev in messageList.map((e) => MessageModel.fromEntity(e))) {
      final existingIndexByMessageId = currentSavedMessages.indexWhere((MessageModel msg) => msg.messageId == ev.messageId);
      if (existingIndexByMessageId >= 0) {
        if (currentSavedMessages[existingIndexByMessageId].readAt != null && ev.readAt == null) {
          throw "updating readAt to null in ${currentSavedMessages[existingIndexByMessageId].messageId}: ${currentSavedMessages[existingIndexByMessageId].text}";
        }
        currentSavedMessages[existingIndexByMessageId] = ev;
      } else {
        currentSavedMessages.add(ev);
      }
    }
    await _hive.box.put(_kMessages, currentSavedMessages.map((e) => e.toLocalStorageMap()).toList());
  }

  MessageEntity? getLastMessage(int userId) {
    final list = getMessages(userId: userId);
    if (list.isEmpty) {
      return null;
    }
    return list.last;
  }

  int getUnreadMessagesAmount({required int userId}) {
    return getMessages(userId: userId)
        .where((element) => element.readAt == null && element.senderUserId == userId)
        .length;
  }

  List<int> getConversationsUsersIds() {
    logger('getConversationsUsersIds');
    final loggedUserId = authLocalDS.loggedUserId;
    assert(loggedUserId != null);
    final List<int> res = [];
    for (MessageEntity message in _getAllMessages()) {
      final userId = message.senderUserId == loggedUserId ? message.receiverUserId : message.senderUserId;
      if(!res.contains(userId)) {
        assert(loggedUserId != null, 'senderUserId: ${message.senderUserId} receiverUserId: ${message.receiverUserId}');
        res.add(userId);
      }
    }
    return res;
  }

  Future<void> clear () {
    return _hive.box.delete(_kMessages);
  }

}