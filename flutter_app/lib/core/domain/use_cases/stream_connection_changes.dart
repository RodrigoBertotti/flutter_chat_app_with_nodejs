import 'package:askless/index.dart';
import 'package:flutter_chat_app_with_mysql/core/domain/repositories/connection_repo.dart';


class StreamConnectionChanges {
  final ConnectionRepo connectionChangesRepo;

  StreamConnectionChanges({required this.connectionChangesRepo});

  Stream<ConnectionDetails> call ({bool immediately = false}) {
    return connectionChangesRepo.streamConnectionChanges(immediately: immediately);
  }

}