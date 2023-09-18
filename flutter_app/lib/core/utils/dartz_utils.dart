import 'package:dartz/dartz.dart';

R asRight<R> (Either either) {
  if(either.isLeft()){
    throw "asRight failed, because is left";
  }
  return (either as Right).value;
}