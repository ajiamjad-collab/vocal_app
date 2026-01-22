class AppException implements Exception {
  final String message;
  final String? code;
  final Object? cause;

  /// ✅ if true => show Retry button / auto retry is safe
  final bool retryable;

  AppException(
    this.message, {
    this.code,
    this.cause,
    this.retryable = false,
  });

  @override
  String toString() => 'AppException(code: $code, message: $message)';
}

class NetworkException extends AppException {
  NetworkException(
    super.message, {
    super.code,
    super.cause,
    super.retryable = true,
  });
}

class AuthAppException extends AppException {
  AuthAppException(
    super.message, {
    super.code,
    super.cause,
    super.retryable = false,
  });
}

class ValidationException extends AppException {
  ValidationException(
    super.message, {
    super.code,
    super.cause,
    super.retryable = false,
  });
}

class UnknownAppException extends AppException {
  UnknownAppException(
    super.message, {
    super.code,
    super.cause,
    super.retryable = true,
  });
}
