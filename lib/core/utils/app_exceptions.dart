class AppException implements Exception {
  final String message;
  final String prefix;

  AppException([this.message = '', this.prefix = '']);

  @override
  String toString() {
    return "$prefix$message";
  }
}

class ValidationException extends AppException {
  ValidationException([String message = 'Invalid Input Data']) : super(message, 'Validation Error: ');
}

class AuthException extends AppException {
  AuthException([String message = 'Authentication Failed']) : super(message, 'Auth Error: ');
}

class NetworkException extends AppException {
  NetworkException([String message = 'No Internet Connection']) : super(message, 'Network Error: ');
}

class ServerException extends AppException {
  ServerException([String message = 'Internal Server Error']) : super(message, 'Server Error: ');
}
