
import 'package:askless/index.dart';

typedef OnDisconnectBecauseInvalidCredential = void Function();

abstract class ConnectionRepo {
  Stream<ConnectionDetails> streamConnectionChanges({bool immediately = false});

  void start ({required void Function() onAutoReauthenticationFails});
}
