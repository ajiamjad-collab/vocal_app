import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/offline/offline_queue.dart';

abstract class AuthRemoteDataSource {
  Stream<User?> authStateChanges();

  /// ✅ RememberMe added
  Future<User> signInEmail(String email, String password, {required bool rememberMe});

  Future<User> signUpEmail(String email, String password);

  /// ✅ RememberMe added
  Future<User> signInGoogle({required bool rememberMe});

  Future<void> sendEmailVerification();
  Future<void> resetPassword(String email);

  /// ✅ Reloads Firebase user from server (updates emailVerified)
  Future<User?> reloadUser();

  Future<void> reauthenticateWithPassword(String email, String password);
  Future<void> deleteAccount();

  Future<void> signOut();

  /// ✅ Sync Auth.emailVerified -> Firestore users/{uid}.emailVerified via Cloud Function
  Future<void> syncEmailVerificationStatus();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth auth;
  final GoogleSignIn googleSignIn;

  /// ✅ Inject from service locator (with correct region)
  final FirebaseFunctions functions;

  /// ✅ Offline queue (optional but recommended)
  final OfflineQueue offlineQueue;

  AuthRemoteDataSourceImpl({
    required this.auth,
    required this.googleSignIn,
    required this.functions,
    required this.offlineQueue,
  });

  @override
  Stream<User?> authStateChanges() => auth.authStateChanges();

  /// ✅ Web-only persistence (Remember Me)
  Future<void> _applyWebPersistence(bool rememberMe) async {
    if (!kIsWeb) return;

    // LOCAL => survives browser restart (Remember Me)
    // SESSION => clears when tab/window closes
    final p = rememberMe ? Persistence.LOCAL : Persistence.SESSION;

    try {
      await auth.setPersistence(p);
    } catch (_) {
      // ignore: some environments may throw, but login can still work
    }
  }

  @override
  Future<User> signInEmail(String email, String password, {required bool rememberMe}) async {
    await _applyWebPersistence(rememberMe);

    final cred = await auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return cred.user!;
  }

  @override
  Future<User> signUpEmail(String email, String password) async {
    // For signup we typically keep default persistence.
    final cred = await auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return cred.user!;
  }

  /// ✅ Works on Mobile + Web + RememberMe
  @override
  Future<User> signInGoogle({required bool rememberMe}) async {
    await _applyWebPersistence(rememberMe);

    if (kIsWeb) {
      try {
        final provider = GoogleAuthProvider();
        provider.setCustomParameters({'prompt': 'select_account'});
        final userCred = await auth.signInWithPopup(provider);
        return userCred.user!;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'popup-closed-by-user' || e.code == 'cancelled-popup-request') {
          throw FirebaseAuthException(code: 'popup-closed-by-user', message: 'Cancelled');
        }
        rethrow;
      }
    }

    final googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      throw FirebaseAuthException(code: 'popup-closed-by-user', message: 'Cancelled');
    }

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCred = await auth.signInWithCredential(credential);
    return userCred.user!;
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = auth.currentUser;
    if (user == null) return;
    await user.sendEmailVerification();
  }

  @override
  Future<void> resetPassword(String email) async {
    await auth.sendPasswordResetEmail(email: email.trim());
  }

  /// ✅ UPDATED:
  /// - reload Firebase user
  /// - if verified, sync emailVerified -> Firestore via Cloud Function
  @override
  Future<User?> reloadUser() async {
    final user = auth.currentUser;
    if (user == null) return null;

    await user.reload();
    final refreshed = auth.currentUser;

    if (refreshed?.emailVerified == true) {
      await syncEmailVerificationStatus();
    }

    return refreshed;
  }

  @override
  Future<void> reauthenticateWithPassword(String email, String password) async {
    final user = auth.currentUser;
    if (user == null) return;

    final credential = EmailAuthProvider.credential(email: email.trim(), password: password);
    await user.reauthenticateWithCredential(credential);
  }

  @override
  Future<void> deleteAccount() async {
    final user = auth.currentUser;
    if (user == null) return;
    await user.delete();
  }

  @override
  Future<void> signOut() async {
    await auth.signOut();

    // On web, googleSignIn.signOut() doesn't control Firebase popup sessions.
    // On mobile, it's good to sign out from GoogleSignIn too.
    if (!kIsWeb) {
      await googleSignIn.signOut();
    }
  }

  /// ✅ Cloud Function call to sync emailVerified status into Firestore
  @override
  Future<void> syncEmailVerificationStatus() async {
    try {
      await functions.httpsCallable("syncEmailVerificationStatus").call();
    } on FirebaseFunctionsException catch (e) {
      // If offline / temporarily unavailable, queue and retry later
      if (e.code == 'unavailable' || e.code == 'deadline-exceeded') {
        await offlineQueue.enqueue("sync_email_verified", {});
        return;
      }
      rethrow;
    }
  }
}
