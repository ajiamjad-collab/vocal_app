import 'app_exception.dart';

class Failure {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  factory Failure.fromException(AppException e) =>
      Failure(e.message, code: e.code);
}
