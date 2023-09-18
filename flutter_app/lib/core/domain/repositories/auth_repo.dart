import 'package:dartz/dartz.dart';
import '../entities/failures/failure.dart';

enum ConnectResult {
  /// `userId` is not null
  connectedAndAuthenticated,
  /// `userId` is null
  connectedButNotAuthenticated,
  notConnected,
}

abstract class AuthRepo {
  Future<void> start({required void Function() onAutoReauthenticationFails});
  int? get loggedUserId;
  bool isAuthenticated ();
  Future<void> logout();
  Future<Either<Failure, void>> authenticateWithEmailAndPassword({required String email, required String password});
  void onAutoReauthenticationFails ({required void Function() onAutoReauthenticationFails});
  void addOnLoggedInListener(void Function() listener);
  void addOnLogoutListener(void Function() listener);
}
