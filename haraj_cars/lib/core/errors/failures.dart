/// Base class for all failures in the application
abstract class Failure {
  final String message;
  final String? code;
  
  const Failure(this.message, [this.code]);
}

/// Server-related failures
class ServerFailure extends Failure {
  const ServerFailure(super.message, [super.code]);
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, [super.code]);
}

/// Authentication-related failures
class AuthFailure extends Failure {
  const AuthFailure(super.message, [super.code]);
}

/// Permission-related failures
class PermissionFailure extends Failure {
  const PermissionFailure(super.message, [super.code]);
}

/// Validation-related failures
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, [super.code]);
}

/// Cache-related failures
class CacheFailure extends Failure {
  const CacheFailure(super.message, [super.code]);
}

/// File-related failures
class FileFailure extends Failure {
  const FileFailure(super.message, [super.code]);
}

/// Generic unexpected failures
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message, [super.code]);
}
