import 'package:equatable/equatable.dart';
import 'package:vocal_app/features/auth/domain/entities/app_user.dart';
import '../../../../core/errors/app_exception.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class EmailNotVerified extends AuthState {
  final AppUser user;
  const EmailNotVerified(this.user);

  @override
  List<Object?> get props => [user];
}

class Authenticated extends AuthState {
  final AppUser user;
  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthError extends AuthState {
  final AppException exception;
  const AuthError(this.exception);

  String get message => exception.message;
  bool get retryable => exception.retryable;

  @override
  List<Object?> get props => [exception.message, exception.code, exception.retryable];
}

/// ✅ IMPORTANT: emitted when re-auth succeeds so ReAuthPage can pop(true)
class AuthReauthenticated extends AuthState {
  const AuthReauthenticated();
}
