import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:vocal_app/features/auth/domain/entities/app_user.dart';
import 'package:vocal_app/features/auth/domain/usecases/delete_account.dart';
import 'package:vocal_app/features/auth/domain/usecases/reauthenticate.dart';
import 'package:vocal_app/features/auth/domain/usecases/reload_user.dart';
import 'package:vocal_app/features/auth/domain/usecases/reset_password.dart';
import 'package:vocal_app/features/auth/domain/usecases/send_verification.dart';
import 'package:vocal_app/features/auth/domain/usecases/sign_in_email.dart';
import 'package:vocal_app/features/auth/domain/usecases/sign_in_google.dart';
import 'package:vocal_app/features/auth/domain/usecases/sign_out.dart';
import 'package:vocal_app/features/auth/domain/usecases/sign_up_email.dart';
import 'package:vocal_app/features/profile/domain/usecases/create_user_profile.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/errors/error_logger.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/storage/local_storage.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SignInEmail signInEmail;
  final SignInGoogle signInGoogle;
  final SignUpEmail signUpEmail;
  final SendVerification sendVerification;
  final ResetPassword resetPassword;
  final ReloadUser reloadUser;
  final Reauthenticate reauthenticate;
  final DeleteAccount deleteAccount;
  final SignOut signOut;
  final LocalStorage localStorage;

  final CreateUserProfile createUserProfile;

  StreamSubscription<User?>? _firebaseAuthSub;

  AuthEvent? _lastRetryableEvent;

  AuthBloc({
    required this.signInEmail,
    required this.signInGoogle,
    required this.signUpEmail,
    required this.sendVerification,
    required this.resetPassword,
    required this.reloadUser,
    required this.reauthenticate,
    required this.deleteAccount,
    required this.signOut,
    required this.localStorage,
    required this.createUserProfile,
  }) : super(const AuthInitial()) {
    on<AuthStarted>(_onStarted);
    on<AuthUserChanged>(_onAuthUserChanged);

    on<SignInEmailRequested>(_onSignInEmail);
    on<SignUpEmailRequested>(_onSignUpEmail);
    on<SignInGoogleRequested>(_onSignInGoogle);

    on<SendEmailVerificationRequested>(_onSendVerification);
    on<ForgotPasswordRequested>(_onForgotPassword);
    on<ReloadUserRequested>(_onReloadUser);
    on<ReauthenticateRequested>(_onReauth);

    // ✅ NEW delete flows
    on<DeleteAccountWithPasswordRequested>(_onDeleteAccountWithPassword);
    on<DeleteAccountWithGoogleRequested>(_onDeleteAccountWithGoogle);

    // legacy (keep)
    on<DeleteAccountRequested>(_onDeleteAccount);

    on<SignOutRequested>(_onSignOut);

    on<AuthRetryLastRequested>(_onRetryLast);
  }

  static Stream<dynamic> get routerRefreshStream =>
      sl<FirebaseAuth>().authStateChanges();

  bool _isUnauthCode(String? code) {
    if (code == null) return false;
    if (code == 'unauthenticated') return true;

    // ✅ IMPORTANT FIX:
    // Do NOT treat 'invalid-credential' as unauthenticated.
    // Wrong password during reauth throws invalid-credential,
    // and forcing signOut causes rebuild/assertion issues + bad UX.
    const authUnauthCodes = {
      'user-token-expired',
      'invalid-user-token',
      'user-disabled',
      'user-not-found',
      // 'invalid-credential',  ❌ removed
      'invalid-id-token',
      'session-cookie-expired',
      'requires-recent-login',
    };

    return authUnauthCodes.contains(code);
  }

  Future<void> _handleUnauthenticated(
    Emitter<AuthState> emit,
    AppException ex,
  ) async {
    emit(AuthError(ex));
    try {
      await signOut();
    } catch (_) {}
    emit(const Unauthenticated());
  }

  void _rememberRetryable(AuthEvent event, AppException ex) {
    if (!ex.retryable) return;
    if (event is SignOutRequested) return;
    if (event is DeleteAccountRequested) return;
    if (event is DeleteAccountWithPasswordRequested) return;
    if (event is DeleteAccountWithGoogleRequested) return;
    _lastRetryableEvent = event;
  }

  Future<void> _handleError(
    Emitter<AuthState> emit,
    AuthEvent sourceEvent,
    Object err,
    StackTrace st,
  ) async {
    ErrorLogger.log(err, st);
    final ex = ErrorMapper.map(err);

    if (_isUnauthCode(ex.code)) {
      await _handleUnauthenticated(emit, ex);
      return;
    }

    _rememberRetryable(sourceEvent, ex);
    emit(AuthError(ex));
  }

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    await _firebaseAuthSub?.cancel();
    await Future.delayed(const Duration(milliseconds: 450));

    final firebaseUser = sl<FirebaseAuth>().currentUser;

    if (firebaseUser == null) {
      add(const AuthUserChanged(null));
    } else {
      add(
        AuthUserChanged(
          AppUser(
            uid: firebaseUser.uid,
            email: firebaseUser.email,
            emailVerified: firebaseUser.emailVerified,
          ),
        ),
      );
    }

    _firebaseAuthSub = sl<FirebaseAuth>().authStateChanges().listen(
      (firebaseUser) {
        if (firebaseUser == null) {
          add(const AuthUserChanged(null));
          return;
        }

        add(
          AuthUserChanged(
            AppUser(
              uid: firebaseUser.uid,
              email: firebaseUser.email,
              emailVerified: firebaseUser.emailVerified,
            ),
          ),
        );
      },
      onError: (_, _) => add(const AuthUserChanged(null)),
    );
  }

  Future<void> _onAuthUserChanged(
    AuthUserChanged event,
    Emitter<AuthState> emit,
  ) async {
    final user = event.user;

    if (user == null) {
      emit(const Unauthenticated());
      return;
    }

    if (!user.emailVerified) {
      emit(EmailNotVerified(user));
    } else {
      emit(Authenticated(user));
    }
  }

  Future<void> _onSignInEmail(
    SignInEmailRequested e,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await signInEmail(
        e.email,
        e.password,
        rememberMe: e.rememberMe,
      );

      await localStorage.setRememberMe(e.rememberMe);
      if (e.rememberMe) {
        await localStorage.setRememberedEmail(e.email);
      } else {
        await localStorage.clearRememberedEmail();
      }

      if (!user.emailVerified) {
        emit(EmailNotVerified(user));
      } else {
        emit(Authenticated(user));
      }
    } catch (err, st) {
      await _handleError(emit, e, err, st);
      emit(const Unauthenticated());
    }
  }

  Future<void> _onSignUpEmail(
    SignUpEmailRequested e,
    Emitter<AuthState> emit,
  ) async {
    if (!e.agreed) {
      emit(
        AuthError(
          ValidationException(
            'Please accept Terms & Privacy Policy to continue.',
            code: 'invalid-argument',
          ),
        ),
      );
      emit(const Unauthenticated());
      return;
    }

    if (e.firstName.trim().isEmpty || e.lastName.trim().isEmpty) {
      emit(
        AuthError(
          ValidationException(
            'First name and Last name are required.',
            code: 'invalid-argument',
          ),
        ),
      );
      emit(const Unauthenticated());
      return;
    }

    emit(const AuthLoading());
    try {
      final user = await signUpEmail(e.email, e.password);

      await createUserProfile(
        firstName: e.firstName,
        lastName: e.lastName,
      );

      await sendVerification();
      emit(EmailNotVerified(user));
    } catch (err, st) {
      await _handleError(emit, e, err, st);
      emit(const Unauthenticated());
    }
  }

  Future<void> _onSignInGoogle(
    SignInGoogleRequested e,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final rememberMe = await localStorage.getRememberMe();

      final user = await signInGoogle(rememberMe: rememberMe);

      final display = (sl<FirebaseAuth>().currentUser?.displayName ?? '').trim();
      final parts =
          display.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();

      final first = parts.isNotEmpty ? parts.first : 'User';
      final last = parts.length >= 2 ? parts.sublist(1).join(' ') : 'Account';

      await createUserProfile.ensureForGoogle(
        fallbackFirstName: first,
        fallbackLastName: last,
      );

      if (!user.emailVerified) {
        emit(EmailNotVerified(user));
      } else {
        emit(Authenticated(user));
      }
    } catch (err, st) {
      await _handleError(emit, e, err, st);
      emit(const Unauthenticated());
    }
  }

  Future<void> _onSendVerification(
    SendEmailVerificationRequested e,
    Emitter<AuthState> emit,
  ) async {
    try {
      await sendVerification();
    } catch (err, st) {
      await _handleError(emit, e, err, st);
    }
  }

  Future<void> _onForgotPassword(
    ForgotPasswordRequested e,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await resetPassword(e.email);
      emit(const Unauthenticated());
    } catch (err, st) {
      await _handleError(emit, e, err, st);
      emit(const Unauthenticated());
    }
  }

  Future<void> _onReloadUser(
    ReloadUserRequested e,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await reloadUser();

      if (user == null) {
        emit(const Unauthenticated());
        return;
      }

      if (!user.emailVerified) {
        emit(
          AuthError(
            ValidationException(
              "Email not verified yet. Please verify and tap 'I verified'.",
              code: 'failed-precondition',
            ),
          ),
        );
        emit(EmailNotVerified(user));
        return;
      }

      emit(Authenticated(user));
    } catch (err, st) {
      await _handleError(emit, e, err, st);

      final firebaseUser = sl<FirebaseAuth>().currentUser;
      if (firebaseUser == null) {
        emit(const Unauthenticated());
      }
    }
  }

  /// ✅ Existing reauth page flow (kept)
  Future<void> _onReauth(
    ReauthenticateRequested e,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await reauthenticate(e.email, e.password);
      emit(const AuthReauthenticated());
    } catch (err, st) {
      await _handleError(emit, e, err, st);
    }
  }

  /// ✅ NEW: Password popup -> reauth current user -> delete
  Future<void> _onDeleteAccountWithPassword(
    DeleteAccountWithPasswordRequested e,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final firebaseUser = sl<FirebaseAuth>().currentUser;
      final email = (firebaseUser?.email ?? '').trim();

      if (email.isEmpty) {
        throw ValidationException(
          'No email found for this account. Use Google re-auth instead.',
          code: 'failed-precondition',
        );
      }

      // 1) Re-authenticate with current account email + entered password
      await reauthenticate(email, e.password);

      // 2) Delete
      await deleteAccount();

      emit(const Unauthenticated());
    } catch (err, st) {
      await _handleError(emit, e, err, st);
    }
  }

  /// ✅ NEW: Google popup -> reauth with Google credential -> delete
  Future<void> _onDeleteAccountWithGoogle(
    DeleteAccountWithGoogleRequested e,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = sl<FirebaseAuth>().currentUser;
      if (user == null) {
        throw ValidationException(
          'You are not logged in.',
          code: 'unauthenticated',
        );
      }

      // Ask Google to re-auth (shows account chooser if needed)
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        throw ValidationException(
          'Google sign-in cancelled.',
          code: 'cancelled',
        );
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await user.reauthenticateWithCredential(credential);

      // Then delete
      await deleteAccount();

      emit(const Unauthenticated());
    } catch (err, st) {
      await _handleError(emit, e, err, st);
    }
  }

  /// Legacy delete (kept)
  Future<void> _onDeleteAccount(
    DeleteAccountRequested e,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await deleteAccount();
      emit(const Unauthenticated());
    } catch (err, st) {
      await _handleError(emit, e, err, st);
    }
  }

  Future<void> _onSignOut(
    SignOutRequested e,
    Emitter<AuthState> emit,
  ) async {
    try {
      await signOut();
    } catch (err, st) {
      await _handleError(emit, e, err, st);
    }
    emit(const Unauthenticated());
  }

  Future<void> _onRetryLast(
    AuthRetryLastRequested e,
    Emitter<AuthState> emit,
  ) async {
    final last = _lastRetryableEvent;
    if (last == null) {
      emit(
        AuthError(
          ValidationException(
            'Nothing to retry. Please try again.',
            code: 'failed-precondition',
          ),
        ),
      );
      return;
    }

    _lastRetryableEvent = null;
    add(last);
  }

  @override
  Future<void> close() async {
    await _firebaseAuthSub?.cancel();
    return super.close();
  }
}
