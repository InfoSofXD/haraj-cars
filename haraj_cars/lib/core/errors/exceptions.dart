/// Base class for all exceptions in the application
abstract class AppException implements Exception {
  final String message;
  final String? code;
  
  const AppException(this.message, [this.code]);
}

/// Server-related exceptions
class ServerException extends AppException {
  const ServerException(super.message, [super.code]);
}

/// Network-related exceptions
class NetworkException extends AppException {
  const NetworkException(super.message, [super.code]);
}

/// Authentication-related exceptions
class AuthException extends AppException {
  const AuthException(super.message, [super.code]);
}

/// Permission-related exceptions
class PermissionException extends AppException {
  const PermissionException(super.message, [super.code]);
}

/// Validation-related exceptions
class ValidationException extends AppException {
  const ValidationException(super.message, [super.code]);
}

/// Cache-related exceptions
class CacheException extends AppException {
  const CacheException(super.message, [super.code]);
}

/// File-related exceptions
class FileException extends AppException {
  const FileException(super.message, [super.code]);
}

/// Generic unexpected exceptions
class UnexpectedException extends AppException {
  const UnexpectedException(super.message, [super.code]);
}
