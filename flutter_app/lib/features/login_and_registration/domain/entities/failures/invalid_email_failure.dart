

import 'package:flutter_chat_app_with_mysql/core/domain/entities/failures/failure.dart';

class InvalidEmailFailure extends Failure {

  InvalidEmailFailure() : super("Oops! Looks like this is an invalid email");

}