abstract class AppException implements Exception {
  AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException(super.message);
}

class AuthException extends AppException {
  AuthException(super.message);
}

class StorageException extends AppException {
  StorageException(super.message);
}

class UnknownException extends AppException {
  UnknownException(super.message);
}
