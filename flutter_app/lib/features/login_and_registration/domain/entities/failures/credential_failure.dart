

import 'package:flutter_chat_app_with_mysql/core/domain/entities/failures/failure.dart';

class CredentialFailure extends Failure {
  final String credentialErrorCode;

  CredentialFailure({required this.credentialErrorCode});

}