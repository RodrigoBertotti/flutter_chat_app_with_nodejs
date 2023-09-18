import '../../domain/entities/message_entity.dart';
import '../../domain/entities/model_source.dart';


class MessageModel extends MessageEntity {
  /// Field names:
  static const String _kMessageId = "messageId";
  static const String _kText = "text";
  static const String _kSenderUserId = "senderUserId";
  static const String _kReceiverUserId = "receiverUserId";
  static const String _kCreatedAtMsSinceEpoch = "createdAtMsSinceEpoch";

  static const String _kReadAtMsSinceEpoch = "readAtMsSinceEpoch";
  static const String _kSentAtMsSinceEpoch = "sentAtMsSinceEpoch";
  static const String _kReceivedAtMsSinceEpoch = "receivedAtMsSinceEpoch";

  static const String _kSendStatus = "sendStatus";
  static const String _kSendStatusPending = "pending";
  static const String _kSendStatusSendSuccessfully = "sendSuccessfully";
  static const String _kSendStatusSendFailed = "sendFailed";


  /// Used to send a new message though websockets
  Map<String,dynamic> toServerMap() => {
    _kMessageId: messageId,
    _kText: text,
    _kReceiverUserId: receiverUserId,
  };

  /// Used to save the message in the local storage offline
  Map<String,dynamic> toLocalStorageMap() {
    final map = toServerMap();
    map[_kMessageId] = messageId;
    map[_kSenderUserId] = senderUserId;
    map[_kCreatedAtMsSinceEpoch] = createdAt.millisecondsSinceEpoch;
    map[_kSendStatus] = {
      SendStatus.pending: _kSendStatusPending,
      SendStatus.sendSuccessfully: _kSendStatusSendSuccessfully,
      SendStatus.sendFailed: _kSendStatusSendFailed,
    }[sendStatus];
    assert(map[_kSendStatus] != null);

    map[_kReadAtMsSinceEpoch] = readAt?.millisecondsSinceEpoch;
    map[_kSentAtMsSinceEpoch] = sentAt?.millisecondsSinceEpoch;
    map[_kReceivedAtMsSinceEpoch] = receivedAt?.millisecondsSinceEpoch;

    return map;
  }

  MessageModel({required String messageId, required String text, required int senderUserId,
    required int receiverUserId, required DateTime? sentAt,
    DateTime? receivedAt, DateTime? readAt, required DateTime createdAt, required SendStatus sendStatus, })
      : super(
        readAt: readAt,
        sendStatus: sendStatus,
        receiverUserId: receiverUserId,
        senderUserId: senderUserId,
        messageId: messageId,
        text: text,
        sentAt: sentAt,
        receivedAt: receivedAt,
        createdAt: createdAt,
      ) {
    // print ('messageId -> '+messageId);
    // print ('   '+(readAt != null).toString());
  }

  static MessageModel fromMap(map, ModelSource source) {
    assert(map is Map);

    SendStatus sendStatus () {
      if (source == ModelSource.server) {
        return SendStatus.sendSuccessfully;
      }
      SendStatus? sendStatus = {
        _kSendStatusPending : SendStatus.pending,
        _kSendStatusSendSuccessfully : SendStatus.sendSuccessfully,
        _kSendStatusSendFailed : SendStatus.sendFailed,
      }[map[_kSendStatus]];
      assert(sendStatus != null);
      return sendStatus!;
    }

    return MessageModel(
      sendStatus: sendStatus(),
      createdAt: map[_kCreatedAtMsSinceEpoch] != null ? DateTime.fromMillisecondsSinceEpoch(map[_kCreatedAtMsSinceEpoch]) : DateTime.fromMillisecondsSinceEpoch(map[_kSentAtMsSinceEpoch]),
      readAt: map[_kReadAtMsSinceEpoch] == null ? null : DateTime.fromMillisecondsSinceEpoch(map[_kReadAtMsSinceEpoch]),
      messageId: map[_kMessageId],
      text: map[_kText],
      senderUserId: map[_kSenderUserId],
      receiverUserId: map[_kReceiverUserId],
      sentAt: map[_kSentAtMsSinceEpoch] == null ? null : DateTime.fromMillisecondsSinceEpoch(map[_kSentAtMsSinceEpoch]),
      receivedAt: map[_kReceivedAtMsSinceEpoch] == null ? null : DateTime.fromMillisecondsSinceEpoch(map[_kReceivedAtMsSinceEpoch]),
    );
  }

  static List<MessageModel> fromMapList(mapList, ModelSource source)
    => List.from(mapList ?? []).map((e) => fromMap(e, source)).toList();

  MessageModel.fromEntity(MessageEntity e) : super(
    sendStatus: e.sendStatus,
    readAt: e.readAt,
    receiverUserId: e.receiverUserId,
    text: e.text,
    senderUserId: e.senderUserId,
    messageId: e.messageId,
    sentAt: e.sentAt,
    receivedAt: e.receivedAt,
    createdAt: e.createdAt,
  );

}
