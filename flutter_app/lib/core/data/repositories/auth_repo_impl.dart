import 'dart:developer';
import 'package:dartz/dartz.dart';
import 'package:flutter_chat_app_with_mysql/core/data/data_sources/auth_local_ds.dart';
import 'package:flutter_chat_app_with_mysql/features/chat/domain/repositories/messages_repo.dart';
import 'package:flutter_chat_app_with_mysql/features/login_and_registration/data/data_sources/auth_remote_ds.dart';
import 'package:flutter_chat_app_with_mysql/features/login_and_registration/domain/entities/failures/credential_failure.dart';
import 'package:flutter_chat_app_with_mysql/features/login_and_registration/domain/entities/tokens_entity.dart';
import '../../../injection_container.dart';
import '../../domain/entities/failures/failure.dart';
import '../../domain/repositories/auth_repo.dart';
import '../data_sources/hive_box_instance.dart';


class AuthRepoImpl extends AuthRepo {
  final AuthLocalDS authLocalDS;
  final AuthRemoteDS authRemoteDS;
  final List<void Function()> _onLoggedInListener = [];
  final List<void Function()> _onLogoutListeners = [];


  AuthRepoImpl({required this.authLocalDS, required this.authRemoteDS});

  @override
  int? get loggedUserId => authLocalDS.loggedUserId;

  Future<void> _saveTokenInfo (TokensEntity token) async {
    await authLocalDS.setLoggedUserId(loggedUserId: token.userId);
    await authLocalDS.setAccessToken(accessToken: token.accessToken);
    await authLocalDS.setAccessTokenExpiration(accessTokenExpiration: token.accessTokenExpiration);
    await authLocalDS.setRefreshToken(refreshToken: token.refreshToken);
  }

  @override
  bool isAuthenticated () => (authLocalDS.getAccessToken()) != null;

  @override
  void addOnLogoutListener(void Function() listener) {
    _onLogoutListeners.add(listener);
  }

  @override
  Future<void> start ({required void Function() onAutoReauthenticationFails}) async {
    final accessToken = authLocalDS.getAccessToken();
    if (accessToken != null) {
      final res = await authenticateWithAccessToken(accessToken: accessToken, neverTimeout: true);
      res.fold((l) {
        this.onAutoReauthenticationFails(onAutoReauthenticationFails: onAutoReauthenticationFails);
      }, (r) {
        log("valid accessToken");
      });
    }
  }

  @override
  Future<void> onAutoReauthenticationFails ({required void Function() onAutoReauthenticationFails}) async {
    final tokenRes = await _refreshTokenAndSaveLocally();
    tokenRes.fold((l) {
      log("onExpiredAccessToken failed: ${(l.error)}");
      onAutoReauthenticationFails();
    }, (r) async {
      final authRes = await authenticateWithAccessToken(accessToken: r.accessToken, neverTimeout: true);
      authRes.fold((l) {
        log("onExpiredAccessToken: could not reconnect with the previous accessToken${l is CredentialFailure ? " with credentialErrorCode: ${l.credentialErrorCode}" : ""}");
        onAutoReauthenticationFails();
      }, (r) {
        log("onExpiredAccessToken handled successfully");
      });
    });
  }

  @override
  Future<void> logout() async {
    await authRemoteDS.logout();
    await authLocalDS.clear();
    for (final listener in _onLogoutListeners) {
      listener();
    }
    getIt.get<HiveBoxInstance>().box.deleteAll(getIt.get<HiveBoxInstance>().box.keys);
  }

  Future<Either<Failure, TokensEntity>> _refreshTokenAndSaveLocally() async {
    final refreshToken = authLocalDS.getRefreshToken();
    assert(loggedUserId != null);
    assert(refreshToken != null);
    try {
      final tokensEntity = await authRemoteDS.useRefreshTokenToGetNewAccessToken(userId: loggedUserId!, refreshToken: refreshToken!);
      await _saveTokenInfo(tokensEntity);
      return right(tokensEntity);
    } catch (e){
      log("Could not get and save the refreshToken automatically: ${e.toString()}");
      if (e is Failure) {
        return left(e);
      } else {
        rethrow;
      }
    }
  }

  /// Left can be: CredentialFailure or Failure
  Future<Either<Failure, void>> authenticateWithAccessToken({required String accessToken, bool neverTimeout = false}) async {
    try {
      await authRemoteDS.authenticateWithAccessToken(accessToken: accessToken, neverTimeout: neverTimeout);
      log("authenticateWithAccessToken is a success");
      for (final listener in _onLoggedInListener) {
        listener();
      }
      await getIt.get<MessagesRepo>().start();
      return right(null);
    } catch (e) {
      log("authenticateWithAccessToken failed: ${e.toString()}");
      if (e is Failure) {
        return left(e);
      }
      rethrow;
    }
  }

  @override
  Future<Either<Failure, void>> authenticateWithEmailAndPassword({required String email, required String password}) async {
    try {
      final tokensEntity = await authRemoteDS.getAccessTokenWithEmailAndPassword(email: email, password: password);
      await _saveTokenInfo(tokensEntity);
      return authenticateWithAccessToken(accessToken: tokensEntity.accessToken);
    } catch (e) {
      log("authenticateWithEmailAndPassword failed: ${e.toString()}");
      if (e is Failure) {
        return left(e);
      } else {
        rethrow;
      }
    }
  }

  @override
  void addOnLoggedInListener(void Function() listener, {bool immediately=true}) {
    _onLoggedInListener.add(listener);
    if (immediately && loggedUserId != null) {
      listener();
    }
  }

}
