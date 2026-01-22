import 'dart:async';
import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'app_exception.dart';

class ErrorMapper {
  static AppException map(Object e) {
    if (e is AppException) return e;

    // ✅ Firebase Auth errors
    if (e is FirebaseAuthException) {
      return AuthAppException(
        _authMessage(e.code),
        code: e.code,
        cause: e,
        retryable: false,
      );
    }

    // ✅ Cloud Functions errors
    if (e is FirebaseFunctionsException) {
      final code = e.code;
      return AppException(
        _functionsMessage(code, message: e.message),
        code: code,
        cause: e,
        retryable: isRetryableCode(code),
      );
    }

    // ✅ Firestore/Storage/FCM/etc. (FirebaseException base)
    if (e is FirebaseException) {
      final code = e.code;
      return AppException(
        _firebaseMessage(code, message: e.message),
        code: code,
        cause: e,
        retryable: isRetryableCode(code),
      );
    }

    // ✅ Offline / DNS / socket
    if (e is SocketException) {
      return NetworkException(
        'No internet connection. Please check your network.',
        code: 'no-internet',
        cause: e,
        retryable: true,
      );
    }

    // ✅ Timeout
    if (e is TimeoutException) {
      return NetworkException(
        'Request timed out. Please try again.',
        code: 'timeout',
        cause: e,
        retryable: true,
      );
    }

    return UnknownAppException(
      'Something went wrong. Please try again.',
      code: 'unknown',
      cause: e,
      retryable: true,
    );
  }

  static bool isRetryable(Object e) => map(e).retryable;

  static bool isRetryableCode(String? code) {
    const retryableCodes = {
      'timeout',
      'no-internet',
      'unavailable',
      'deadline-exceeded',
      'resource-exhausted',
      'internal',
      'network-error',
      'unknown',
      'cancelled',
      'too-many-requests',
    };
    return retryableCodes.contains(code);
  }

  // ======================
  // Firebase Auth messages
  // ======================
  static String _authMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'Email is already in use.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'requires-recent-login':
        return 'Please re-authenticate to continue.';
      case 'popup-closed-by-user':
        return 'Google sign-in was cancelled.';
      default:
        return 'Authentication failed ($code).';
    }
  }

  // =========================
  // Cloud Functions messages
  // =========================
  static String _functionsMessage(String code, {String? message}) {
    switch (code) {
      case 'unauthenticated':
        return 'Please login again to continue.';
      case 'permission-denied':
        return 'You do not have permission to perform this action.';
      case 'invalid-argument':
        return message?.trim().isNotEmpty == true ? message!.trim() : 'Invalid request data.';
      case 'failed-precondition':
        return message?.trim().isNotEmpty == true
            ? message!.trim()
            : 'Operation not allowed in the current state.';
      case 'not-found':
        return 'Requested data not found.';
      case 'already-exists':
        return 'Data already exists.';
      case 'resource-exhausted':
        return 'Too many requests. Please try again later.';
      case 'internal':
        return 'Server error. Please try again later.';
      case 'unavailable':
        return 'Service temporarily unavailable.';
      case 'deadline-exceeded':
        return 'Request took too long. Please try again.';
      default:
        return 'Server error ($code). Please try again.';
    }
  }

  // ==================================
  // FirebaseException (Firestore/etc.)
  // ==================================
  static String _firebaseMessage(String code, {String? message}) {
    switch (code) {
      case 'permission-denied':
        return 'You don’t have permission to access this data.';
      case 'unauthenticated':
        return 'Please login again to continue.';
      case 'unavailable':
        return 'Service is currently unavailable. Please try again.';
      case 'deadline-exceeded':
        return 'Request took too long. Please try again.';
      case 'not-found':
        return 'Requested data not found.';
      case 'already-exists':
        return 'Data already exists.';
      case 'resource-exhausted':
        return 'Too many requests. Please try again later.';
      case 'cancelled':
        return 'Request was cancelled. Please try again.';
      case 'aborted':
        return 'Operation was aborted. Please try again.';
      case 'invalid-argument':
        return message?.trim().isNotEmpty == true ? message!.trim() : 'Invalid data.';
      default:
        final m = (message ?? '').trim();
        return m.isNotEmpty ? m : 'Firebase error ($code). Please try again.';
    }
  }
}
