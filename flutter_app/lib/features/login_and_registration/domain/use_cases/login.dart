import 'package:dartz/dartz.dart';
import 'package:flutter_chat_app_with_mysql/core/domain/entities/failures/failure.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/domain/repositories/messages_repo.dart';
import '../../../../core/domain/repositories/auth_repo.dart';


class Login {
  final AuthRepo authRepository;
  final MessagesRepo messagesRepository;

  Login({required this.authRepository, required this.messagesRepository});

  Future<Either<Failure, void>> call ({required String email, required String password}) async {
    return authRepository.authenticateWithEmailAndPassword(email: email, password: password);
  }

}