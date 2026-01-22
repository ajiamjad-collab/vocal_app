enum FailureType {
  offline,
  timeout,
  cancelled,
  unauthorized,
  forbidden,
  notFound,
  server,
  badRequest,
  unknown,
}

class AppFailure implements Exception {
  final FailureType type;
  final String message;
  final int? statusCode;

  const AppFailure(this.type, this.message, {this.statusCode});

  @override
  String toString() => 'AppFailure($type, $statusCode): $message';
}
