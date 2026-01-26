import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PublicUserProfile {
  final String publicUserId;
  final String firstName;
  final String lastName;
  final String photoUrl;

  const PublicUserProfile({
    required this.publicUserId,
    required this.firstName,
    required this.lastName,
    required this.photoUrl,
  });

  String get fullName => '${firstName.trim()} ${lastName.trim()}'.trim();
}

abstract class UserProfileRemoteDataSource {
  Future<String> createUserProfile({
    required String firstName,
    required String lastName,
  });

  Future<void> ensureProfileExistsForGoogleUser({
    required String fallbackFirstName,
    required String fallbackLastName,
  });

  Stream<PublicUserProfile> watchMyPublicProfile();
  Future<void> updateMyName({required String firstName, required String lastName});
  Future<void> setMyProfilePhotoUrl({required String photoUrl});
}

class UserProfileRemoteDataSourceImpl implements UserProfileRemoteDataSource {
  final FirebaseFunctions functions;
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  static const String publicProfileCollection = "Personal";

  UserProfileRemoteDataSourceImpl({
    required this.functions,
    required this.firestore,
    required this.auth,
  });

  @override
  Future<String> createUserProfile({
    required String firstName,
    required String lastName,
  }) async {
    final u = auth.currentUser;
    if (u == null) throw Exception('No authenticated user.');

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

    final userRef = firestore.collection('Users').doc(u.uid);
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

    final docRef = firestore.collection('Users').doc(u.uid);
    final snap = await docRef.get();

    if (!snap.exists) {
      await createUserProfile(
        firstName: fallbackFirstName,
        lastName: fallbackLastName,
      );
    }
  }

  @override
  Stream<PublicUserProfile> watchMyPublicProfile() async* {
    final uid = auth.currentUser?.uid;
    if (uid == null) throw Exception("Not signed in");

    final usersDocStream = firestore.collection("Users").doc(uid).snapshots();

    await for (final usersSnap in usersDocStream) {
      final data = usersSnap.data() ?? {};
      final publicUserId = (data["publicUserId"] ?? "").toString().trim();
      if (publicUserId.isEmpty) continue;

      final publicStream =
          firestore.collection(publicProfileCollection).doc(publicUserId).snapshots();

      await for (final pubSnap in publicStream) {
        final pub = pubSnap.data() ?? {};
        yield PublicUserProfile(
          publicUserId: publicUserId,
          firstName: (pub["firstName"] ?? "").toString(),
          lastName: (pub["lastName"] ?? "").toString(),
          photoUrl: (pub["photoUrl"] ?? "").toString(),
        );
      }
    }
  }

  @override
  Future<void> updateMyName({required String firstName, required String lastName}) async {
    final callable = functions.httpsCallable("updateMyName");
    await callable.call({
      "firstName": firstName.trim(),
      "lastName": lastName.trim(),
    });
  }

  @override
  Future<void> setMyProfilePhotoUrl({required String photoUrl}) async {
    final callable = functions.httpsCallable("setMyProfilePhotoUrl");
    await callable.call({
      "photoUrl": photoUrl.trim(),
    });
  }
}
