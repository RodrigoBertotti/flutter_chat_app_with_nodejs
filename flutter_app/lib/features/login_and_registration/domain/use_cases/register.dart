import 'package:dartz/dartz.dart';
import 'package:flutter_chat_app_with_mysql/core/domain/repositories/users_repo.dart';
import '../../../../core/domain/entities/failures/failure.dart';
import '../../../chat/domain/entities/user_entity.dart';


class Register {

  final UsersRepo usersRepository;

  Register({required this.usersRepository});

  Future<Either<Failure, UserEntity>> call ({
    required String firstName, required String lastName,
    required String email, required String password,
  }) {
    return usersRepository.createUser(firstName: firstName, lastName: lastName, email: email, password: password,);
  }

}