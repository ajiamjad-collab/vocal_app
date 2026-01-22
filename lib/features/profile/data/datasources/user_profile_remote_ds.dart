import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class UserProfileRemoteDataSource {
  Future<String> createUserProfile({
    required String firstName,
    required String lastName,
  });

  Future<void> ensureProfileExistsForGoogleUser({
    required String fallbackFirstName,
    required String fallbackLastName,
  });
}

class UserProfileRemoteDataSourceImpl implements UserProfileRemoteDataSource {
  final FirebaseFunctions functions;
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  UserProfileRemoteDataSourceImpl({
    required this.functions,
    required this.firestore,
    required this.auth,
  });

  /// ✅ Ensures profile exists (server authoritative)
  /// - Creates users/{uid} + user/{publicUserId} using Cloud Function
  /// - Verifies users/{uid} exists afterwards
  /// - No client-side fallback (Firestore rules block it by design)
  @override
  Future<String> createUserProfile({
    required String firstName,
    required String lastName,
  }) async {
    final u = auth.currentUser;
    if (u == null) throw Exception('No authenticated user.');

    // 1) Call Cloud Function (server-side create)
    final callable = functions.httpsCallable('createUserProfile');

    final res = await callable.call(<String, dynamic>{
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
    });

    final raw = res.data;
    final Map<String, dynamic> data = Map<String, dynamic>.from(raw as Map);

    final publicUserId = (data['publicUserId'] ?? '').toString().trim();
    if (publicUserId.isEmpty) {
      throw Exception('Profile created but publicUserId missing.');
    }

    // 2) Verify users/{uid} exists (helps detect deployment/region misconfig)
    final userRef = firestore.collection('users').doc(u.uid);
    final snap = await userRef.get();
    if (!snap.exists) {
      throw Exception('Profile creation did not complete. Please retry.');
    }

    return publicUserId;
  }

  @override
  Future<void> ensureProfileExistsForGoogleUser({
    required String fallbackFirstName,
    required String fallbackLastName,
  }) async {
    final u = auth.currentUser;
    if (u == null) return;

    final docRef = firestore.collection('users').doc(u.uid);
    final snap = await docRef.get();

    if (!snap.exists) {
      await createUserProfile(
        firstName: fallbackFirstName,
        lastName: fallbackLastName,
      );
    }
  }
}
