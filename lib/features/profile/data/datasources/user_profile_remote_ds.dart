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

  /// ✅ Always ensures users/{uid} exists
  /// 1) Try Cloud Function (server-side create of users/{uid} + user/{publicId})
  /// 2) Verify users/{uid} exists
  /// 3) If missing -> fallback create from CLIENT (allowed by your rules)
  @override
  Future<String> createUserProfile({
    required String firstName,
    required String lastName,
  }) async {
    final u = auth.currentUser;
    if (u == null) throw Exception('No authenticated user.');

    final uid = u.uid;
    final email = u.email;

    String publicUserId = '';

    // 1) Try Cloud Function
    try {
      final callable = functions.httpsCallable('createUserProfile');
      final res = await callable.call(<String, dynamic>{
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
      });

      final raw = res.data;
      final Map<String, dynamic> data = Map<String, dynamic>.from(raw as Map);
      publicUserId = (data['publicUserId'] ?? '').toString().trim();
    } on FirebaseFunctionsException {
      // ignore here; fallback to client write below
    } catch (_) {
      // ignore here; fallback to client write below
    }

    // 2) Verify users/{uid} exists
    final userRef = firestore.collection('users').doc(uid);
    final snap = await userRef.get();

    // 3) Fallback client create if missing
    if (!snap.exists) {
      await userRef.set({
        'uid': uid,
        'email': email,
        'firstName': firstName.trim(),
        'lastName': lastName.trim(),
        'displayName': '${firstName.trim()} ${lastName.trim()}'.trim(),
        'publicUserId': publicUserId, // may be empty if function failed
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'provider': u.providerData.map((p) => p.providerId).toList(),
        'photoUrl': u.photoURL,
      }, SetOptions(merge: true));
    } else {
      // If doc exists but missing names, repair it (optional)
      final data = snap.data() ?? {};
      final hasName = (data['firstName'] ?? '').toString().trim().isNotEmpty;
      if (!hasName) {
        await userRef.set({
          'firstName': firstName.trim(),
          'lastName': lastName.trim(),
          'displayName': '${firstName.trim()} ${lastName.trim()}'.trim(),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
    }

    return publicUserId; // can be empty if function failed
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
