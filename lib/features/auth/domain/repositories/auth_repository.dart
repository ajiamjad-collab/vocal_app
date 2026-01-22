import '../entities/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> authStateChanges();

  /// ✅ rememberMe added
  Future<AppUser> signInEmail(String email, String password, {required bool rememberMe});

  Future<AppUser> signUpEmail(String email, String password);

  /// ✅ rememberMe added
  Future<AppUser> signInGoogle({required bool rememberMe});

  Future<void> sendEmailVerification();
  Future<void> resetPassword(String email);
  Future<AppUser?> reloadUser();

  Future<void> reauthenticateWithPassword(String email, String password);
  Future<void> deleteAccount();

  Future<void> signOut();
}
