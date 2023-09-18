import 'dart:async';
import 'dart:developer';
import 'package:askless/index.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_chat_app_with_mysql/features/login_and_registration/domain/entities/failures/email_already_exists_failure.dart';
import 'package:flutter_chat_app_with_mysql/core/domain/entities/failures/failure.dart';
import '../../../features/chat/data/models/user_model.dart';

class UsersRemoteDS {

  /// Fetches for the users
  Stream<List<UserModel>> streamUsersToTalk() {
    final stream = AsklessClient.instance.readStream(route: 'user-list', source: StreamSource.cacheAndRemote);
    return stream.map((output) => UserModel.fromList(output));
  }

  /// Fetches for the users
  Future<List<UserModel>> readUsersToTalk() async {
    final res = await AsklessClient.instance.read(route: 'user-list',);
    if (res.success) {
      return UserModel.fromList(res.output);
    }
    throw Failure("${res.error!.code}: ${res.error!.description}");
  }

  /// Creates a new user
  ///
  /// Throws [EmailAlreadyExistsFailure] if the [email] is already in use
  Future<UserModel> createUser({required String firstName, required String lastName, required String email, required String password}) async {
    final res = await AsklessClient.instance.create(
      route: 'user',
      body: {
        "firstName": firstName,
        "lastName": lastName,
        "email": email,
        "password": password,
      }
    );
    if(res.success){
      return UserModel.fromMap(res.output);
    }
    log("createUser: Error occurred with code ${res.error!.code} and description ${res.error!.description}");
    if(res.error!.code == "DUPLICATED_EMAIL"){
      throw EmailAlreadyExistsFailure();
    }
    throw Failure();
  }
  
}
