import 'package:dartz/dartz.dart';
import 'package:flutter_chat_app_with_mysql/core/domain/entities/failures/failure.dart';
import 'package:random_string/random_string.dart';
import '../entities/sending_text_message_entity.dart';
import '../repositories/messages_repo.dart';


class SendMessage {
  final MessagesRepo messagesRepository;

  SendMessage({required this.messagesRepository});

  Future<Either<Failure, void>> call({required String text, required int receiverUserId}) {
    return messagesRepository.sendMessage(message: SendingMessageEntity(messageId: randomAlphaNumeric(28), text: text, receiverUserId: receiverUserId));
  }

}