import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/errors/error_mapper.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_ds.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;

  AuthRepositoryImpl({required this.remote});

  AppUser _mapUser(User u) => AppUser(
        uid: u.uid,
        email: u.email,
        emailVerified: u.emailVerified,
      );

  @override
  Stream<AppUser?> authStateChanges() {
    return remote.authStateChanges().map((u) => u == null ? null : _mapUser(u));
  }

  @override
  Future<AppUser> signInEmail(String email, String password, {required bool rememberMe}) async {
    try {
      final u = await remote.signInEmail(email, password, rememberMe: rememberMe);
      return _mapUser(u);
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<AppUser> signUpEmail(String email, String password) async {
    try {
      final u = await remote.signUpEmail(email, password);
      return _mapUser(u);
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<AppUser> signInGoogle({required bool rememberMe}) async {
    try {
      final u = await remote.signInGoogle(rememberMe: rememberMe);
      return _mapUser(u);
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      await remote.sendEmailVerification();
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await remote.resetPassword(email);
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  /// ✅ reload already calls sync in your remote; keep this safe extra guard
  @override
  Future<AppUser?> reloadUser() async {
    try {
      final u = await remote.reloadUser();
      if (u == null) return null;

      // ✅ optional extra enterprise-safe sync
      if (u.emailVerified) {
        try {
          await remote.syncEmailVerificationStatus();
        } catch (_) {}
      }

      return _mapUser(u);
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<void> reauthenticateWithPassword(String email, String password) async {
    try {
      await remote.reauthenticateWithPassword(email, password);
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      await remote.deleteAccount();
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await remote.signOut();
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }
}
