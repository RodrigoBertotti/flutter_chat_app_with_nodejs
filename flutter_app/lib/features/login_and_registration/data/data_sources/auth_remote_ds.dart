import 'dart:developer';
import 'package:askless/index.dart';
import 'package:flutter_chat_app_with_mysql/features/login_and_registration/domain/entities/failures/credential_failure.dart';
import 'package:flutter_chat_app_with_mysql/features/login_and_registration/domain/entities/failures/invalid_refresh_token_failure.dart';
import 'package:flutter_chat_app_with_mysql/features/login_and_registration/domain/entities/tokens_entity.dart';
import '../../../../core/domain/entities/failures/failure.dart';
import '../../../../main.dart';
import '../../domain/entities/failures/invalid_email_failure.dart';
import '../../domain/entities/failures/invalid_password_failure.dart';
import '../models/tokens_model.dart';

class AuthRemoteDS {


  Future<void> logout () async {
    await AsklessClient.instance.create(route: "logout", body: {});
    AsklessClient.instance.clearAuthentication();
  }

  Future<TokensEntity> getAccessTokenWithEmailAndPassword ({required String email, required String password}) async {
    final res = (await AsklessClient.instance.create(route: "login", body: {"email": email, "password": password}));
    log("connectWithEmailAndPassword, result is ${res.success ? "success" : "error"}");
    if (!res.success) {
      log("connectWithEmailAndPassword error with code ${res.error!.code}: ${res.error!.description}");
      if (res.error!.code == "INVALID_EMAIL")   { throw InvalidEmailFailure(); }
      if (res.error!.code == "INVALID_PASSWORD"){ throw InvalidPasswordFailure(); }
      throw Failure();
    }
    return TokensModel.fromMap(res.output);
  }

  /// throws [CredentialFailure]
  Future<void> authenticateWithAccessToken ({required String accessToken, bool neverTimeout = false}) async {
    final res = (await AsklessClient.instance.authenticate(credential: { "accessToken": accessToken }, neverTimeout: neverTimeout));
    log ("AUTHENTICATED: ${res.success}");
    if (!res.success) {
      log("connectWithAccessToken error: ${res.error!.code}");
      // if (res.errorCode == "EXPIRED_ACCESS_TOKEN") { // <-- Another option
      if (res.error!.isCredentialError) {
        throw CredentialFailure(credentialErrorCode: res.error!.code);
      }
      throw Failure();
    }
  }

  Future<TokensEntity> useRefreshTokenToGetNewAccessToken({required int userId, required String refreshToken}) async {
    final res = await AsklessClient.instance.create(route: "accessToken", body: {
      "refreshToken": refreshToken,
      "userId": userId,
    }, neverTimeout: false);
    if (res.success) {
      return TokensModel.fromMap(res.output);
    }
    if (res.error!.code == "INVALID_REFRESH_TOKEN") {
      throw InvalidRefreshTokenFailure();
    }
    log("Unknown error when trying to refresh the token: ${res.error!.code}");
    throw Failure();
  }

}
