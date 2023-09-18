import 'package:askless/index.dart';
import 'package:flutter_chat_app_with_mysql/core/data/data_sources/connection_remote_ds.dart';
import 'package:flutter_chat_app_with_mysql/core/domain/repositories/auth_repo.dart';
import '../../../injection_container.dart';
import '../../domain/repositories/connection_repo.dart';

class ConnectionRepoImpl extends ConnectionRepo {
  final ConnectionRemoteDS connectionRemoteDS;

  ConnectionRepoImpl({required this.connectionRemoteDS,});

  @override
  Stream<ConnectionDetails> streamConnectionChanges({bool immediately = false}) {
    return connectionRemoteDS.streamConnectionChanges(immediately: immediately);
  }

  @override
  void start ({required void Function() onAutoReauthenticationFails}) {
    connectionRemoteDS.start(
      onAutoReauthenticationFails: (credentialErrorCode, clearAuthentication) => getIt.get<AuthRepo>().onAutoReauthenticationFails(onAutoReauthenticationFails: onAutoReauthenticationFails),
    );
  }
  
}
