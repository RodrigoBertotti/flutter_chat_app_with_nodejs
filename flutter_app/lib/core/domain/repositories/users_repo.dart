import 'package:dartz/dartz.dart';
import '../entities/failures/failure.dart';
import '../../../features/chat/domain/entities/user_entity.dart';


abstract class UsersRepo {


  Future<Either<Failure, UserEntity>> createUser({
    required String firstName, required String lastName,
    required String email, required String password,
  });

  Stream<List<UserEntity>> streamUsersToTalkStream();

  Future<Either<Failure, UserEntity>> readUser(int userId);

}