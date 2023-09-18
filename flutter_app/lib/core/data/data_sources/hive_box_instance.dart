import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:crypto/crypto.dart';

class HiveBoxInstance {
  late final String _localStorageEncryptionKey;
  Box? _box;

  HiveBoxInstance ({required String localStorageEncryptionKey}) {
    _localStorageEncryptionKey = localStorageEncryptionKey;
  }

  Box get box {
    assert(_box != null, "Ops! You should call init() and wait for it result before trying to get the box");
    return _box!;
  }

  Future<Box> initialize() async {
    if (_box != null){
      return _box!;
    }
    await Hive.initFlutter();
    return _box = await Hive.openBox("my-flutter-client-example-box", encryptionCipher: HiveAesCipher(sha256.convert(utf8.encode(_localStorageEncryptionKey)).bytes));
  }

}