abstract class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException(this.message, [this.statusCode]);

  @override
  String toString() => '$runtimeType: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

class UnauthorizedException extends AppException {
  UnauthorizedException([String message = 'Unauthorized']) : super(message, 401);
}

class NetworkException extends AppException {
  NetworkException([super.message = 'No connectivity or timeout']);
}

class ServerException extends AppException {
  ServerException([super.message = 'Server error', super.statusCode]);
}

class ValidationException extends AppException {
  ValidationException([String message = 'Validation failed']) : super(message, 422);
}

class NotFoundException extends AppException {
  NotFoundException([String message = 'Not found']) : super(message, 404);
}

class ConflictException extends AppException {
  ConflictException([String message = 'Conflict']) : super(message, 409);
}
