


class Failure extends Error {
  dynamic _err;

  Failure([dynamic err]) {
    _err = err;
  }

  String get error => _err ?? "An error occurred, please try again later";

  @override
  String toString() {
    return "Failure: $error";
  }
}