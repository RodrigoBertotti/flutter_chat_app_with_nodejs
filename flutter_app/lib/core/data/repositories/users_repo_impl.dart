import 'dart:async';
import 'dart:developer';
import 'package:collection/collection.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_chat_app_with_mysql/features/login_and_registration/domain/entities/failures/email_already_exists_failure.dart';
import '../data_sources/users_local_ds.dart';
import '../../../features/chat/domain/entities/user_entity.dart';
import 'package:flutter_chat_app_with_mysql/core/domain/entities/failures/failure.dart';
import '../../domain/repositories/users_repo.dart';
import '../data_sources/users_remote_ds.dart';

class UsersRepoImpl extends UsersRepo {
  final UsersRemoteDS usersRemoteDataSource;
  final UsersLocalDS usersLocalDatasource;

  UsersRepoImpl({required this.usersRemoteDataSource, required this.usersLocalDatasource});


  ///  Creates a new user
  ///
  /// left can only be an instance of:
  /// - [EmailAlreadyExistsFailure]
  /// - [Failure]
  @override
  Future<Either<Failure, UserEntity>> createUser({required String firstName, required String lastName, required String email, required String password}) async {
    try {
      final user = await usersRemoteDataSource.createUser(firstName: firstName, lastName: lastName, email: email, password: password,);
      return right(user);
    } on EmailAlreadyExistsFailure catch (f) {
      return left(f);
    } catch (e) {
      if(e is Failure){
        return left(e);
      }
      rethrow;
    }
  }
  
  /// Reads all users the current user can talk to
  ///
  /// It's also creates a cache locally
  @override
  Stream<List<UserEntity>> streamUsersToTalkStream() {
    final stream = usersRemoteDataSource.streamUsersToTalk();
    final controller = StreamController<List<UserEntity>>();
    final remoteStreamSubscription = stream.listen((output) async {
      await usersLocalDatasource.saveUsersLocally(output);
      controller.add(output);
    }, onDone: () {
      if (!controller.isClosed) { controller.close(); }
    });
    controller.onCancel = () { try { remoteStreamSubscription.cancel(); } catch(e) { log(e.toString());}};
    final firstEvent = usersLocalDatasource.getUsersToTalkLocally();
    if (firstEvent != null) {
      controller.add(firstEvent);
    }
    return controller.stream;
  }

  @override
  Future<Either<Failure, UserEntity>> readUser(int userId) async {
    final user = usersLocalDatasource.readUserLocally(userId);
    if (user != null) {
      return right(user);
    }
    try {
      final res = await usersRemoteDataSource.readUsersToTalk();
      await usersLocalDatasource.saveUsersLocally(res);
      final user = res.firstWhereOrNull((element) => element.userId == userId);
      log("user != null: "+(user != null).toString());
      assert(user != null,'user "$userId" not found in: ${res.map((e) => "${e.userId}, ").toList()}');
      return right(user!);
    } catch (e) {
      print(e);
      if (e is Failure) {
        return left(e);
      } else {
        rethrow;
      }
    }
  }

}