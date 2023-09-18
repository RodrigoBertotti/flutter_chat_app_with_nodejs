

import 'package:flutter_chat_app_with_mysql/features/chat/domain/entities/sending_typing_entity.dart';

class SendingTypingModel extends SendingTypingEntity {
  /// Field name:
  static const _kReceiverUserId = "receiverUserId";

  SendingTypingModel({required int receiverUserId}) : super(receiverUserId: receiverUserId);
  
  SendingTypingModel.fromEntity(SendingTypingEntity entity) : super(receiverUserId: entity.receiverUserId);

  Map<String, dynamic> toMap () => {
    _kReceiverUserId: receiverUserId,
  };

}