import 'package:equatable/equatable.dart';
import 'package:vocal_app/features/auth/domain/entities/app_user.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthStarted extends AuthEvent {
  const AuthStarted();
}

class SignInEmailRequested extends AuthEvent {
  final String email;
  final String password;
  final bool rememberMe;
  const SignInEmailRequested(this.email, this.password, {required this.rememberMe});

  @override
  List<Object?> get props => [email, password, rememberMe];
}

class SignUpEmailRequested extends AuthEvent {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final bool agreed; // ✅ consent checkbox

  const SignUpEmailRequested({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.agreed,
  });

  @override
  List<Object?> get props => [firstName, lastName, email, password, agreed];
}

class SignInGoogleRequested extends AuthEvent {
  const SignInGoogleRequested();
}

class SendEmailVerificationRequested extends AuthEvent {
  const SendEmailVerificationRequested();
}

class ForgotPasswordRequested extends AuthEvent {
  final String email;
  const ForgotPasswordRequested(this.email);

  @override
  List<Object?> get props => [email];
}

class ReloadUserRequested extends AuthEvent {
  const ReloadUserRequested();
}

class ReauthenticateRequested extends AuthEvent {
  final String email;
  final String password;
  const ReauthenticateRequested(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

/// ✅ NEW: Delete with password popup flow
class DeleteAccountWithPasswordRequested extends AuthEvent {
  final String password;
  const DeleteAccountWithPasswordRequested(this.password);

  @override
  List<Object?> get props => [password];
}

/// ✅ NEW: Delete with Google re-auth popup flow
class DeleteAccountWithGoogleRequested extends AuthEvent {
  const DeleteAccountWithGoogleRequested();
}

class DeleteAccountRequested extends AuthEvent {
  const DeleteAccountRequested();
}

class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}

class AuthUserChanged extends AuthEvent {
  final AppUser? user;
  const AuthUserChanged(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthRetryLastRequested extends AuthEvent {
  const AuthRetryLastRequested();
}
