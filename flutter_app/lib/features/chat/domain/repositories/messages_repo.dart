import 'package:dartz/dartz.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/domain/entities/chat_content_entity.dart';
import 'package:flutter_chat_app_with_mysql/core/domain/entities/failures/failure.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/domain/entities/message_entity.dart';
import '../entities/conversation_entity.dart';
import '../entities/sending_text_message_entity.dart';
import '../entities/sending_typing_entity.dart';



abstract class MessagesRepo {

  Stream<ChatContentEntity> messagesStream({required int userId});

  Future<Either<Failure, void>> notifyLoggedUserIsTyping({required SendingTypingEntity data});

  Future<Either<Failure, void>> sendMessage({required SendingMessageEntity message});

  Future<Either<Failure, void>> notifyLoggedUserReadConversation({required int userId});

  Stream<List<ConversationEntity>> conversationsStream();

  Future<void> start();
  Future<void> close();

}